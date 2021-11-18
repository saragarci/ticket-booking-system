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

  mapping (uint => uint256[]) showIdToTicketId;
  mapping (uint => uint256[]) showIdToPosterId;
  mapping (uint256 => uint256) ticketsForSale;
  mapping (uint256 => uint256[]) ticketsForExchange;

  Ticket ticketingSystem;
  Poster posterSystem;

  uint constant ACCESS_ALLOWED_BEFORE = 7200;

  modifier validShows(string[] memory _showTitles, uint[] memory _showPrices,
    uint[][] memory _showDates)
  {
    require(_showTitles.length > 0
      && _showTitles.length == _showPrices.length
      && _showPrices.length == _showDates.length,
      "Show titles, prices and dates do not match dimension or are empty!");
    _;
  }

  modifier validRooms(uint[][] memory _roomDetails)
  {
    require(_roomDetails.length>0, "There has to be at least one room!");
    _;
  }

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

  modifier validSeatView(string memory _seatViewUrl)
  {
    require(bytes(_seatViewUrl).length > 0, "A URL to retrieve seat views must be provided!");
    _;
  }

  modifier showExists(uint _showId)
  {
    require(shows[_showId].id == _showId, "Show id doesn't exist!");
    _;
  }

  modifier showHasDate(uint _showId, uint _date)
  {
    require(shows[_showId].dateToRoom[_date].rows > 0, "Show does not have date!");
    _;
  }

  modifier showOnDateHasSeatForSale(uint _showId, uint _date, uint _seatRow, uint _seatCol)
  {
    require(shows[_showId].status == Status.Scheduled, "Show is not on sale!");
    require(shows[_showId].dateToRoom[_date].remainingSeats > 0, "Show is sold out!");
    require(shows[_showId].dateToRoom[_date].seats[_seatRow][_seatCol].isAvailable,
      "Seat is not available!");
    _;
  }

  modifier paidEnough(uint _price)
  { 
    require(msg.value >= _price, "Account does not have enough Ether!"); 
    _;
  }

  modifier ticketExists(uint256 _ticketId)
  {
    require(ticketingSystem.ticketExists(_ticketId), "Ticket doesn't exist!");
    _;
  }

  modifier onlyTicketOwner(uint256 _ticketId)
  {
    require(ticketingSystem.ownerOf(_ticketId) == msg.sender, "Account is not ticket owner!");
    _;
  }

  event TicketCreated(uint ticketId);
  event TicketDestroyed(uint ticketId);
  event ShowCancelled(uint showId);
  event PosterCreated(uint posterId);

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

  function addDetailsToShow(uint _idx, string memory _title, uint _price) private
  {
    shows[_idx].id = _idx;
    shows[_idx].title = _title;
    shows[_idx].price = _price;
    shows[_idx].status = defaultStatus;
  }

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

  function addDetailsToRoom(uint _showId, uint _dateId, uint[] memory _roomDetails) private
  {
    uint rows = _roomDetails[0];
    uint cols = _roomDetails[1];
    shows[_showId].dateToRoom[_dateId].rows = rows;
    shows[_showId].dateToRoom[_dateId].columns = cols;
    shows[_showId].dateToRoom[_dateId].remainingSeats = rows*cols;
  }

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

  function getRoomForDate(uint _showId, uint _date) public view 
    showExists(_showId)
    showHasDate(_showId, _date)
    returns (Room memory)
  {
    return (shows[_showId].dateToRoom[_date]);
  }

  function showStatusToString(Status _showStatus) internal pure returns (string memory)
  { 
    if (_showStatus == Status.Scheduled) return "Scheduled";
    if (_showStatus == Status.Cancelled) return "Cancelled";
    if (_showStatus == Status.Passed) return "Passed";

    return "Invalid State";
  }

  function buy(uint _showId, uint _date, uint _seatRow, uint _seatCol) public payable
    showOnDateHasSeatForSale(_showId, _date, _seatRow, _seatCol)
    paidEnough(shows[_showId].price)
  {
    uint ticketCost = shows[_showId].price;
    if (msg.value > ticketCost)
      payable(msg.sender).transfer(msg.value - ticketCost);

    uint256 ticketId = ticketingSystem.createTicket(msg.sender, _showId, _date, _seatRow, _seatCol);
    showIdToTicketId[_showId].push(ticketId);
    emit TicketCreated(ticketId);
    
    shows[_showId].dateToRoom[_date].seats[_seatRow][_seatCol].isAvailable = false;
    shows[_showId].dateToRoom[_date].remainingSeats = shows[_showId].dateToRoom[_date].remainingSeats - 1;
  }

  function getOwnerOfTicket(uint256 _ticketId) public view returns (address)
  {
    return (ticketingSystem.ownerOf(_ticketId));
  }

  function getOwnerOfPoster(uint256 _posterId) public view returns (address)
  {
    return (posterSystem.ownerOf(_posterId));
  }

  function verify(uint256 _ticketId) public view returns (bool, address)
  { 
    (uint showId, uint date, , ) = ticketingSystem.getTicketInfo(_ticketId);
    bool isExpired = date < block.timestamp;
    bool showIsOnSchedule = shows[showId].status == Status.Scheduled;
    bool isValid = !isExpired && showIsOnSchedule;
    return (isValid, ticketingSystem.ownerOf(_ticketId)); 
  }

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

  function refund(uint256 _ticketId) private
  {
    address owner = ticketingSystem.ownerOf(_ticketId);
    (uint showId, uint date, , ) = ticketingSystem.getTicketInfo(_ticketId);
    uint amount = shows[showId].price;
    bool isExpired = date < block.timestamp;
    if (!isExpired) {
      ticketingSystem.destroyTicket(_ticketId);
      payable(owner).transfer(amount); // refund the Eth
      emit TicketDestroyed(_ticketId);
    }
  }

  function validate(uint256 _ticketId) public
    onlyOwner()
  {
    address owner = ticketingSystem.ownerOf(_ticketId);
    (uint showId, uint date, , ) = ticketingSystem.getTicketInfo(_ticketId);
    require(block.timestamp > (date-ACCESS_ALLOWED_BEFORE)
      && block.timestamp < date, "You can only access the show 2 hours before it starts!");
    require(shows[showId].status == Status.Scheduled, "Show is not on schedule!");
    
    ticketingSystem.destroyTicket(_ticketId);
    emit TicketDestroyed(_ticketId);

    releasePoster(owner, showId);
  }

  function releasePoster(address _attendee, uint _showId) private
  {
    uint256 posterId = posterSystem.createPoster(_attendee, _showId);
    showIdToPosterId[_showId].push(posterId);
    emit PosterCreated(posterId);
  }

  function setTicketForSale(uint256 _ticketId, uint256 _price) public
    onlyTicketOwner(_ticketId)
  {
    ticketsForSale[_ticketId] = _price;
  }

  function buyTicket(uint256 _ticketId) public payable
    ticketExists(_ticketId)
  {
    require(ticketsForSale[_ticketId] > 0, "Ticket is not for sale!");
    uint256 ticketCost = ticketsForSale[_ticketId];
    address ownerAddress = ticketingSystem.ownerOf(_ticketId);
    require(msg.value > ticketCost, "Account does not have enough Ether!");

    payable(ownerAddress).transfer(ticketCost);
    if (msg.value > ticketCost)
      payable(msg.sender).transfer(msg.value - ticketCost);
    tradeTicket(ownerAddress, msg.sender, _ticketId);
  }

  function setTicketForExchange(uint256 _ticketId, uint row, uint col) public
    onlyTicketOwner(_ticketId)
  {
    ticketsForExchange[_ticketId] = [row, col];
  }

  function exchangeTicket(uint256 _ticketId1, uint256 _ticketId2) public
    onlyTicketOwner(_ticketId1)
  {
    require(ticketsForExchange[_ticketId2].length > 0, "Ticket is not for exchange!");
    (uint showId1, uint date1, uint row1, uint col1) = ticketingSystem.getTicketInfo(_ticketId1);
    (uint showId2, uint date2, , ) = ticketingSystem.getTicketInfo(_ticketId2);
    require(showId1 == showId2 && date1 == date2, "Ticket does not match show and/or date!");
    require(row1 == ticketsForExchange[_ticketId2][0]
      && col1 == ticketsForExchange[_ticketId2][1],
      "This ticket doesn't have the required seat in order to be exhanged!");
    
    address ownerAddress1 = ticketingSystem.ownerOf(_ticketId1);
    address ownerAddress2 = ticketingSystem.ownerOf(_ticketId2);
    tradeTicket(ownerAddress1, ownerAddress2, _ticketId1);
    tradeTicket(ownerAddress2, ownerAddress1, _ticketId2);
  }

  function tradeTicket(address _from, address _to, uint256 _ticketId) private
  {
    ticketingSystem.safeTransferFrom(_from, _to, _ticketId);
  }

  //function destroy()
  //send fund to owner
}
