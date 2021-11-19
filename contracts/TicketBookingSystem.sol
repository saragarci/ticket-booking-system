// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Poster.sol";
import "./Ticket.sol";

contract TicketBookingSystem is Ownable {

  Show[] shows;

  struct Show {
    uint id;
    string title;
    uint price;
    Status status;
    uint[] dates;
    mapping (uint => Room) dateToRoom;
  }

  enum Status { 
    Scheduled,
    Passed,
    Cancelled
  }

  Status constant defaultStatus = Status.Scheduled;

  struct Seat {
    uint id;
    uint col; // number
    uint row;
    string seatView;
    bool isAvailable;
  }

  struct Room {
    uint rows;
    uint columns;
    uint remainingSeats;
    Seat[][] seats;
  }

  // all tickets indexed by showId
  mapping (uint => uint256[]) showIdToTicketId;

  // all posters indexed by showId
  mapping (uint => uint256[]) showIdToPosterId;

  // map ticketId for sale with its price
  mapping (uint256 => uint256) ticketsForSale;

  // map ticketId for exchange with the preferred [row, col]
  mapping (uint256 => uint256[]) ticketsForExchange;

  Ticket ticketingSystem;
  Poster posterSystem;

  // time (in seconds) before the event starts that tickets can start
  // being validated 
  uint constant ACCESS_ALLOWED_BEFORE = 7200;

  // check that for every show being intitialized there's a title, a price and a date
  modifier validShows(string[] memory _showTitles, uint[] memory _showPrices,
    uint[][] memory _showDates)
  {
    require(_showTitles.length > 0
      && _showTitles.length == _showPrices.length
      && _showPrices.length == _showDates.length,
      "Show titles, prices and dates do not match dimension or are empty!");
    _;
  }

  // check that there's at least one room to host the shows
  modifier validRooms(uint[][] memory _roomDetails)
  {
    require(_roomDetails.length>0, "There has to be at least one room!");
    _;
  }

  // check that for every date there's a valid room assigned
  modifier validRoomAssignment(uint[] memory _showDates, uint[] memory _roomAssignment,
    uint[][] memory _roomDetails)
  {
    require(_showDates.length == _roomAssignment.length,
      "Show dates doesn't match dimension of room assigment!");
          
    for (uint i=0; i<_roomAssignment.length; i++)
      require(_roomAssignment[i] < _roomDetails.length,
        "Room doesn't exist for this assignment!");
    _;
  }

  // check that the url for the seat view is non empty
  modifier validSeatView(string memory _seatViewUrl)
  {
    require(bytes(_seatViewUrl).length > 0, "A URL to retrieve seat views must be provided!");
    _;
  }

  // check that show id exists
  modifier showExists(uint _showId)
  {
    require(shows[_showId].id == _showId, "Show id doesn't exist!");
    _;
  }

  // check that the a show is scheduled for a specific date
  modifier showHasDate(uint _showId, uint _date)
  {
    require(shows[_showId].dateToRoom[_date].rows > 0, "Show does not have date!");
    _;
  }

  // check if a specific seat is available for a show scheduled in a particular date
  modifier showOnDateHasSeatForSale(uint _showId, uint _date, uint _seatRow, uint _seatCol)
  {
    require(shows[_showId].status == Status.Scheduled, "Show is not on sale!");
    require(shows[_showId].dateToRoom[_date].remainingSeats > 0, "Show is sold out!");
    require(shows[_showId].dateToRoom[_date].seats[_seatRow][_seatCol].isAvailable,
      "Seat is not available!");
    _;
  }

  // check if the caller is sending enough Ether
  modifier paidEnough(uint _price)
  { 
    require(msg.value >= _price, "Account does not have enough Ether!"); 
    _;
  }

  // check that the ticket id exists
  modifier ticketExists(uint256 _ticketId)
  {
    require(ticketingSystem.ticketExists(_ticketId), "Ticket doesn't exist!");
    _;
  }

  // check if the caller is the owner of the ticket
  modifier onlyTicketOwner(uint256 _ticketId)
  {
    require(ticketingSystem.ownerOf(_ticketId) == msg.sender, "Account is not ticket owner!");
    _;
  }

  // events used
  event TicketCreated(uint ticketId);
  event TicketDestroyed(uint ticketId);
  event ShowCancelled(uint showId);
  event PosterCreated(uint posterId);
  event TicketForSale(uint ticketId, uint price);
  event TicketForExchange(uint ticketId, uint row, uint column);
  event TicketTraded(uint ticketId);

  // initializes all shows with title, price and dates and associates each date with a room
  // each room is initialized with the number of rows and columns it has, the remaining number
  // of seats and all of its seats
  // every seat is created individually with its row, column and the URL for the seatview
  constructor(string[] memory _showTitles, uint[] memory _showPrices, uint[][] memory _showDates,
    uint[][] memory _roomDetails, uint[][] memory _roomAssignment, string memory _seatViewUrl,
    Ticket ticketContract, Poster posterContract)
    validShows(_showTitles, _showPrices, _showDates)
    validRooms(_roomDetails)
  { 
    ticketingSystem = ticketContract;
    posterSystem = posterContract;

    for (uint i=0; i<_showTitles.length; i++) {
      shows.push();
      uint newIndex = shows.length - 1;
      assert(newIndex == i);
      addDetailsToShow(i, _showTitles[i], _showPrices[i]);
      addDatesToShow(i, _showDates[i], _roomDetails, _roomAssignment[i], _seatViewUrl);
    }
  }

  // add show details: id, title, price and status (by default 'Scheduled')
  function addDetailsToShow(uint _idx, string memory _title, uint _price) private
  {
    shows[_idx].id = _idx;
    shows[_idx].title = _title;
    shows[_idx].price = _price;
    shows[_idx].status = defaultStatus;
  }

  // for every date available for a show assign a room and create all the seats
  // belonging to the room
  function addDatesToShow(uint _idx, uint[] memory _showDates, uint[][] memory _roomDetails,
    uint[] memory _roomAssignment, string memory _seatViewUrl) private
    validRoomAssignment(_showDates, _roomAssignment, _roomDetails)
  {
    for (uint j=0; j<_showDates.length; j++) {
      shows[_idx].dates.push(_showDates[j]);
      uint roomIdx = _roomAssignment[j];
      addDetailsToRoom(_idx, _showDates[j], _roomDetails[roomIdx]);
      addSeatsToRoom(_idx, _showDates[j], _seatViewUrl);
    }
  }

  // add room details: rows, columns and remaining seats (by default is all seats)
  function addDetailsToRoom(uint _showId, uint _dateId, uint[] memory _roomDetails) private
  {
    uint rows = _roomDetails[0];
    uint cols = _roomDetails[1];
    shows[_showId].dateToRoom[_dateId].rows = rows;
    shows[_showId].dateToRoom[_dateId].columns = cols;
    shows[_showId].dateToRoom[_dateId].remainingSeats = rows*cols;
  }

  // add all the seats to the room
  // each seat is initialized with: id, row, column, the seat view ULR and a boolean
  // representing if the seat is available (by default 'True')
  function addSeatsToRoom(uint _showId, uint _dateId, string memory _seatViewUrl) private
    validSeatView(_seatViewUrl)
  {
    uint id = 0;
    uint rows = shows[_showId].dateToRoom[_dateId].rows;
    uint cols = shows[_showId].dateToRoom[_dateId].columns;
    for (uint row=0; row<rows; row++) {
      // add new row
      shows[_showId].dateToRoom[_dateId].seats.push();
      uint newRow = shows[_showId].dateToRoom[_dateId].seats.length - 1;
      assert(newRow == row);
      
      for (uint col=0; col<cols; col++) {
        // add new column
        shows[_showId].dateToRoom[_dateId].seats[row].push();
        uint newCol = shows[_showId].dateToRoom[_dateId].seats[row].length - 1;
        assert(newCol == col);
        
        shows[_showId].dateToRoom[_dateId].seats[row][col] =
          Seat({id: id, col: col, row: row, seatView: _seatViewUrl, isAvailable: true});
        id++;
      }
    }
  }

  // public function to retrieve show details given the show id
  function getShow(uint _showId) public view showExists(_showId) returns (
    uint showId,
    string memory showTitle,
    uint showPrice,
    string memory showStatus,
    uint[] memory dates)
  {
    return (
      shows[_showId].id,
      shows[_showId].title,
      shows[_showId].price,
      showStatusToString(shows[_showId].status),
      shows[_showId].dates
    );
  }

  // public function to retrieve room details given show id and date
  function getRoomForDate(uint _showId, uint _date) public view 
    showExists(_showId)
    showHasDate(_showId, _date)
    returns (Room memory)
  {
    return (shows[_showId].dateToRoom[_date]);
  }

  // helper function to map the show status index to a string
  function showStatusToString(Status _showStatus) internal pure returns (string memory)
  { 
    if (_showStatus == Status.Scheduled) return "Scheduled";
    if (_showStatus == Status.Cancelled) return "Cancelled";
    if (_showStatus == Status.Passed) return "Passed";

    return "Invalid State";
  }

  // task 2: buy function
  // payable function that customers can call to buy a ticket for a specific show
  // data and seat (row and column)
  // it creates an instance of the Ticket contract assinging the caller as the owner
  function buy(uint _showId, uint _date, uint _seatRow, uint _seatCol) public payable
    showOnDateHasSeatForSale(_showId, _date, _seatRow, _seatCol)
    paidEnough(shows[_showId].price)
  {
    // give return if the value sent is higher that the actual ticket price
    uint ticketCost = shows[_showId].price;
    if (msg.value > ticketCost)
      payable(msg.sender).transfer(msg.value - ticketCost);

    // creates ticket instance
    uint256 ticketId = ticketingSystem.createTicket(msg.sender, _showId, _date, _seatRow, _seatCol);
    // the ticket is saved for that specific show
    showIdToTicketId[_showId].push(ticketId);
    // an event is emmited 
    emit TicketCreated(ticketId);
    
    // the seat is marked sa unavailable
    shows[_showId].dateToRoom[_date].seats[_seatRow][_seatCol].isAvailable = false;
    // and the total number of remaining seats in the room decreases by 1
    shows[_showId].dateToRoom[_date].remainingSeats = shows[_showId].dateToRoom[_date].remainingSeats - 1;
  }

  // public function to retrieve the ticket owner given a ticket id
  function getOwnerOfTicket(uint256 _ticketId) public view returns (address)
  {
    return (ticketingSystem.ownerOf(_ticketId));
  }

  // public funtion to retrieve the poster owner given a poster id
  function getOwnerOfPoster(uint256 _posterId) public view returns (address)
  {
    return (posterSystem.ownerOf(_posterId));
  }

  // task 3: verify function
  // returns if a ticket is valid or not and the owner address given a ticket id
  function verify(uint256 _ticketId) public view returns (bool, address)
  { 
    // also validates that the ticket exists (i.e. has not been used before)
    (uint showId, uint date, , ) = ticketingSystem.getTicketInfo(_ticketId);
    // ticket is expired (no longer valid) if the date of the show is past the current date
    bool isExpired = date < block.timestamp;
    // check that show is on scheduled (i.e. has not been cancelled)
    bool showIsOnSchedule = shows[showId].status == Status.Scheduled;
    bool isValid = !isExpired && showIsOnSchedule;
    return (isValid, ticketingSystem.ownerOf(_ticketId)); 
  }

  // public function that only the owner can call to cancel a show given a show id
  // it automatically issues a refund for a the tickets sold for that show
  function cancelShow(uint _showId) public
    onlyOwner()
    showExists(_showId)
  {
    if (shows[_showId].status != Status.Cancelled) {
      shows[_showId].status = Status.Cancelled;
      for (uint i=0; i<showIdToTicketId[_showId].length; i++)
        refund(showIdToTicketId[_showId][i]);

      emit ShowCancelled(_showId);
    }
  }

  // task 4: refund function
  // refunds the price of the ticket to owner of the ticket given a ticket id
  // after the refund is issued the ticket is destroyed (i.e. burned)
  function refund(uint256 _ticketId) private
  {
    // verify that the ticket exists, retrieve who the owner is and whether the ticket 
    // has expired 
    address owner = ticketingSystem.ownerOf(_ticketId);
    (uint showId, uint date, , ) = ticketingSystem.getTicketInfo(_ticketId);
    uint amount = shows[showId].price;
    bool isExpired = date < block.timestamp;
    // if not expired then burn the ticket and transfer the ether to the owner
    if (!isExpired) {
      ticketingSystem.destroyTicket(_ticketId);
      payable(owner).transfer(amount); // refund the Eth
      emit TicketDestroyed(_ticketId);
    }
  }

  // task 5: validate function
  // it can only be called by the owner during a specific timeframe. In particular,
  // after (show date - ACCESS_ALLOWED_BEFORE) and before show date
  // Upon validation the ticket is destroyed (i.e. burned) and a poster is released
  // as an instance of POSTER
  function validate(uint256 _ticketId) public
    onlyOwner()
  {
    address owner = ticketingSystem.ownerOf(_ticketId);
    (uint showId, uint date, , ) = ticketingSystem.getTicketInfo(_ticketId);
    // check that the function is called only during the timeframe
    // after the show date and before ACCESS_ALLOWED_BEFORE (2 hours)
    require(block.timestamp > (date-ACCESS_ALLOWED_BEFORE)
      && block.timestamp < date, "You can only access the show 2 hours before it starts!");
    // check that show is scheduled (i.e. not cancelled)
    require(shows[showId].status == Status.Scheduled, "Show is not on schedule!");
    
    // destroy ticket
    ticketingSystem.destroyTicket(_ticketId);
    emit TicketDestroyed(_ticketId);

    // release poster
    releasePoster(owner, showId);
  }

  // helper function that creates a poster for the user that just got their ticket
  // validated
  function releasePoster(address _attendee, uint _showId) private
  {
    uint256 posterId = posterSystem.createPoster(_attendee, _showId);
    showIdToPosterId[_showId].push(posterId);
    emit PosterCreated(posterId);
  }

  // Public function that allows owners to add their tickets for sale and
  // specify the selling price
  function setTicketForSale(uint256 _ticketId, uint256 _price) public
    onlyTicketOwner(_ticketId)
  {
    ticketsForSale[_ticketId] = _price;
    // an event is sent to notify about this
    emit TicketForSale(_ticketId, _price);
  }

  // Public payable function that allows users to buy a ticket for sale
  function buyTicketForTrade(uint256 _ticketId) public payable
    ticketExists(_ticketId)
  {
    // check that ticket is for sale
    require(ticketsForSale[_ticketId] > 0, "Ticket is not for sale!");
    uint256 ticketCost = ticketsForSale[_ticketId];
    address ownerAddress = ticketingSystem.ownerOf(_ticketId);
    // and that the caller is sending enought Ether to pay for the ticket
    require(msg.value >= ticketCost, "Account does not have enough Ether!");

    // remove ticket from available tickets for sale
    delete ticketsForSale[_ticketId];
    // transfer the ether to the current owner of the ticket
    payable(ownerAddress).transfer(ticketCost);
    // transfer the remaining ether sent
    if (msg.value > ticketCost)
      payable(msg.sender).transfer(msg.value - ticketCost);
    // finally transfer the ticket to the buyer (i.e. caller of the function)
    tradeTicket(ownerAddress, msg.sender, _ticketId);
  }

  // Public function that allows owners to add their tickets for exchange and
  // specify the preference of row and column they would would like to do the exchange for
  function setTicketForExchange(uint256 _ticketId, uint _row, uint _col) public
    onlyTicketOwner(_ticketId)
  {
    ticketsForExchange[_ticketId] = [_row, _col];
    // an event is sent to notify about this
    emit TicketForExchange(_ticketId, _row, _col);
  }

  // Public function that allows users to exchange a ticket given a ticket that
  // has already been set up as 'ticket for exchange' 
  function exchangeTicket(uint256 _ticketId1, uint256 _ticketId2) public
    onlyTicketOwner(_ticketId1)
  {
    // check that ticket1 is for exchnage
    require(ticketsForExchange[_ticketId2].length > 0, "Ticket is not for exchange!");
    (uint showId1, uint date1, uint row1, uint col1) = ticketingSystem.getTicketInfo(_ticketId1);
    (uint showId2, uint date2, , ) = ticketingSystem.getTicketInfo(_ticketId2);
    // both tickets match in show and date
    require(showId1 == showId2 && date1 == date2, "Ticket does not match show and/or date!");
    // and ticket2 matches the preferred row and column
    require(row1 == ticketsForExchange[_ticketId2][0]
      && col1 == ticketsForExchange[_ticketId2][1],
      "This ticket doesn't have the required seat in order to be exhanged!");

    // remove ticket from available tickets for exchange
    delete ticketsForExchange[_ticketId2];
    // do the exchange
    address ownerAddress1 = ticketingSystem.ownerOf(_ticketId1);
    address ownerAddress2 = ticketingSystem.ownerOf(_ticketId2);
    tradeTicket(ownerAddress1, ownerAddress2, _ticketId1);
    tradeTicket(ownerAddress2, ownerAddress1, _ticketId2);
  }

  // task 6: tradeTicket function
  // transfer the ticket from the current owner to a new owner
  function tradeTicket(address _from, address _to, uint256 _ticketId) private
  {
    ticketingSystem.safeTransferFrom(_from, _to, _ticketId);
    emit TicketTraded(_ticketId);
  }

  // emergency function that only the owner call call
  // destroys the contract and claims the funds
  function shutdown() external
    onlyOwner()
  {
    selfdestruct(payable(msg.sender));
  }
}
