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
  string title;
  uint seatsCount;
  mapping (uint => Seat) seats;
}

struct Seat {
  uint id;
  string showTitle;
  uint date; // date plus time
  uint price;
  uint col; // number
  uint row;
  string seatView;
  bool isAvailable;
}

constructor() {
  owner = msg.sender;
  initializeShows()
}

function initializeShows() private {
  // add two different shows
}

modifier onlyOwner() {
    require(isOwner());
    _;
}

function isOwner() public view returns (bool) {
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
