// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Poster.sol";
import "./Ticket.sol";

contract TicketBookingSystem {

/*
 * Task 1
 *
 *
 */

address private owner;

Show [] shows;

struct Show {
  uint id;
  string title;
  uint price;
  Status status;
  uint [] dates;
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
  Seat [][] seats;
}

mapping (uint => uint) showIdToTokenId;
mapping (uint => uint) showIdToPosterId;

modifier minNumShows(uint _showsCount) {
    require(_showsCount>0, "There has to be at least one show!");
    _;
}

modifier minNumRooms(uint _roomsCount) {
    require(_roomsCount>0, "There has to be at least one room!");
    _;
}

modifier validRooms(uint _roomsCount, uint[][] memory _roomDetails) {
    require(_roomsCount == _roomDetails.length,
      "Number of rooms doesn't match the number of room details!");
    _;
}

/*modifier validRoomAssignment(uint[][] memory _showDates,
  uint[][] memory _roomAssignment) {
    require(_showDates.length == _roomAssignment.length,
      "Number of shows dates doesn't match the number of room assignments!");
    _;
}*/

modifier validSeatView(string memory _seatViewUrl) {
    require(bytes(_seatViewUrl).length > 0, "A URL to retrieve seat views must be provided!");
    _;
}

constructor(uint _showsCount, string[] memory _showTitles, uint[] memory _showPrices,
  uint[][] memory _showDates, uint _roomsCount, uint[][] memory _roomDetails,
  uint[][] memory _roomAssignment, string memory _seatViewUrl)
  minNumShows(_showsCount)
  minNumRooms(_roomsCount)
  validRooms(_roomsCount, _roomDetails)
{
  require(_showsCount == _showTitles.length
    && _showsCount == _showPrices.length
    && _showsCount == _showDates.length,
    "Show titles, prices or dates do not match the number of shows!");

  require(_showDates.length == _roomAssignment.length,
    "Number of shows dates doesn't match the number of room assignments!");
  for (uint i=0; i<_showDates.length; i++) {
    require(_showDates[i].length == _roomAssignment[i].length,
    "Number of dates doesn't match the number of room assignments!");
    for (uint j=0; j<_showDates[i].length; j++) {
      require(_roomAssignment[i][j] < _roomsCount, "Room assigned doesn't exist!");
    }
  }
  
  owner = msg.sender;

  for (uint i=0; i<_showsCount; i++) {
    shows.push();
    uint newIndex = shows.length - 1;
    assert(newIndex == i);
    initializeShow(i, _showTitles[i], _showPrices[i]);
    addDatesToShow(i, _showDates[i], _roomDetails, _roomAssignment[i], _seatViewUrl);
  }
}

function initializeShow(uint _idx, string memory _title, uint _price) private {
  shows[_idx].id = _idx;
  shows[_idx].title = _title;
  shows[_idx].price = _price;
  shows[_idx].status = defaultStatus;
}

function addDatesToShow(uint _idx, uint[] memory _showDates, uint[][] memory _roomDetails,
  uint[] memory _roomAssignment, string memory _seatViewUrl) private {
  for (uint j=0; j<_showDates.length; j++) {
    shows[_idx].dates.push(_showDates[j]);
    uint roomIdx = _roomAssignment[j];
    addRoomDetails(_idx, _showDates[j], _roomDetails[roomIdx]);
    addSeatsToRoom(_idx, _showDates[j], _seatViewUrl);
  }
}

function addRoomDetails(uint _showId, uint _dateId, uint[] memory _roomDetails)
  private {
  uint rows = _roomDetails[0];
  uint cols = _roomDetails[1];
  shows[_showId].dateToRoom[_dateId].rows = rows;
  shows[_showId].dateToRoom[_dateId].columns = cols;
  shows[_showId].dateToRoom[_dateId].remainingSeats = rows*cols;
}

function addSeatsToRoom(uint _showId, uint _dateId, string memory _seatViewUrl)
  validSeatView(_seatViewUrl)
  private {
  uint id = 0;
  uint rows = shows[_showId].dateToRoom[_dateId].rows;
  uint cols = shows[_showId].dateToRoom[_dateId].columns;
  for (uint row=0; row<rows; row++) {
    for (uint col=0; col<cols; col++) {
      shows[_showId].dateToRoom[_dateId].seats[row][col] = Seat({
        id: id,
        col: col,
        row: row,
        seatView: _seatViewUrl,
        isAvailable: true
      });
      id++;
    }
  }
}

/*function getShows() public view returns (Show[] memory) {
    return shows;
}*/

/*
modifier onlyOwner() {
    require(isOwner());
    _;
}

function isOwner() private view returns (bool) {
    return msg.sender == owner;
}
*/

/*
 * Task 2
 *
 *
 */

/*modifier validShow() {
    // everything exists
    // show is on sale
    // seat is available
    require();
    _;
}

function buy(uint _showId, uint _date, uint _seatId) public payable
  validShow(_showId, _date, _seatId)
  paidEnough(shows[_showId].seats[_seatId].price)
{
  Ticket.createTicket(msg.sender, _showId, _date, _seatId);
}*/


/*
 * Task 2
 *
 *
 */


/*
Task 5: Validate a ticket

As a general comment, the tasks in the assignment should be considered in a real-world scenario. In this sense, a ticket is valid if
- it has been properly minted by the smart contract or the seller, according to your implementation (as if it was properly printed/released by the retailer)
- it has not been "spent" (so it is still active and has not been used yet)
- it is a ticket for a show that will happen at some point in the future (I suggest to use the Epoch converter https://www.epochconverter.com/ if you want to embed the date of the show)
You can add more flavours to the meaning of "validity", but these are the main three I would focus on
 */


/*
Task 6: Safely trade

We expect this function to safeguard both seller and buyer. In particular,
1) nobody else but the owner should be able to sell his/her ticket
2) the owner must voluntarily set his/her ticket for sale (and set a price)
3) If a ticket is on sale and the buyer sends the money, the buyer must be guaranteed to receive the ticket
This is the minimum required, but you are free to expand the safety notion
 */

}
