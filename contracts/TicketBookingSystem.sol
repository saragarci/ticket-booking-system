// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
  uint date;
  uint availableSeats;
  State state;
  Seat [] seats;
  //mapping (Seat => Ticket) seatToTicketId;
  //mapping (Seat => Poster) seatToPosterId;
}

enum State { 
  OnSale,
  SoldOut,
  Closed,
  Cancelled
}

State constant defaultState = State.OnSale;

struct Seat {
  uint id;
  string showTitle;
  uint date;
  uint price;
  uint col; // number
  uint row;
  string seatView;
  bool isAvailable;
}

constructor() {
  owner = msg.sender;
  initialiseShows();
}

function initialiseShows() private {
  uint newIndex;
  
  // Show 1
  shows.push();
	newIndex = shows.length - 1;
  addShow(newIndex, "Cats", 1234);

  // Show 2
  //shows.push();
	//newIndex = shows.length - 1;
  //addShow(newIndex, "Billy Elliot", 1234);
}

function addShow(uint _idx, string memory _title, uint _date) private {
	shows[_idx].id = _idx;
	shows[_idx].title = _title;
	shows[_idx].date = _date;
	shows[_idx].availableSeats = 3;
	shows[_idx].state = defaultState;
  shows[_idx].seats.push(Seat({ id: 0, showTitle: _title, date: _date, price: 123, col: 1, row: 2, seatView: "assja", isAvailable: true }));
  /*shows[_idx].seats[1] = Seat({ id: 1, showTitle: _title, date: _date, price: 123, col: 1, row: 2, seatView: "assja", isAvailable: true });
  shows[_idx].seats[2] = Seat({ id: 2, showTitle: _title, date: _date, price: 123, col: 1, row: 2, seatView: "assja", isAvailable: true });*/
}

  function getShows() public view returns (Show[] memory) {
      return shows;
  }

modifier onlyOwner() {
    require(isOwner());
    _;
}

function isOwner() private view returns (bool) {
    return msg.sender == owner;
}

/*
 * Task 2
 *
 *
 */

// Task 2: seat must be specified by the user



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
