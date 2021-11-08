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
  // Show 1
  shows.push();
	uint256 newIndex = shows.length - 1;
	shows[newIndex].id = 0;
	shows[newIndex].title = "Show 1";
	shows[newIndex].date = 1234;
	shows[newIndex].availableSeats = 3;
	shows[newIndex].state = defaultState;
  shows[newIndex].seats[0] = Seat({id: 0, showTitle: "Show 1", date: 1234, price: 123, col: 1, row: 2, seatView: "assja", isAvailable: true});
  //shows[0].seats[1] = Seat({id: 1, showTitle: "Show 1", date: 1234, price: 123, col: 1, row: 2, seatView: "assja", isAvailable: true});
  //shows[0].seats[2] = Seat({id: 2, showTitle: "Show 1", date: 1234, price: 123, col: 1, row: 2, seatView: "assja", isAvailable: true});

  // Show 2
  // ...
}

modifier onlyOwner() {
    require(isOwner());
    _;
}

function isOwner() private view returns (bool) {
    return msg.sender == owner;
}

/*
Task 2:

seat must be specified by the user
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
