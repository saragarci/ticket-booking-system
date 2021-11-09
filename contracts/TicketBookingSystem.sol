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
  uint256 newIndex;
  string memory title;
  uint date;
  uint56[3] memory seatPricePerRow;
  string[3][3] memory seatViewImages;
  
  // Show 1
  shows.push();
  newIndex = shows.length - 1;
  title = "The Nutcracker";
  date = 1640714400;
  seatPricePerRow = [10387353452306500, 12464824142767800, 14542294833229100]; // in wei
  seatViewImages = [
    [
      "https://seatplan.com/uploads/reviews/thumbs600/477-20191222170421.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs600/340-20191230203323.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs600/587-20200108214108.jpeg"
    ],
    [
      "https://seatplan.com/uploads/reviews/thumbs600/951-20191220124356.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs600/566-20191220124250.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs600/256-20181230133924.jpeg"
    ],
    [
      "https://seatplan.com/uploads/reviews/thumbs600/63-20200206182556.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs600/397-20200206182841.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs600/14-20191228065209.jpeg"
    ]
  ];
  addShow(newIndex, title, date, seatPricePerRow, seatViewImages);

  // Show 2
  shows.push();
  newIndex = shows.length - 1;
  title = "Mary Poppins";
  date = 1640887200;
  seatPricePerRow = [10387353452306500, 12464824142767800, 14542294833229100]; // in wei
  seatViewImages = [
    [
      "https://seatplan.com/uploads/reviews/thumbs270/165-20191207014504.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs270/35-20200125133301.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs270/23-20211102230427.jpeg"
    ],
    [
      "https://seatplan.com/uploads/reviews/thumbs270/534-20190325111002.png",
      "https://seatplan.com/uploads/reviews/thumbs270/390-20161125190507.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs270/523-20180119205206.jpeg"
    ],
    [
      "https://seatplan.com/uploads/reviews/thumbs270/39-20191026155322.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs270/390-20161125190507.jpeg",
      "https://seatplan.com/uploads/reviews/thumbs270/200-20161214130755.png"
    ]
  ];
  addShow(newIndex, title, date, seatPricePerRow, seatViewImages);
}

function addShow(uint _idx, string memory _title, uint _date, uint56[3] memory _pricePerRow, string[3][3] memory _images) private {
	shows[_idx].id = _idx;
	shows[_idx].title = _title;
	shows[_idx].date = _date;
	shows[_idx].availableSeats = 9;
	shows[_idx].state = defaultState;
  uint id=0;
  for (uint row=0; row<3; row++) {
    for (uint col=0; col<3; col++) {
      shows[_idx].seats.push(Seat({
        id: id,
        showTitle: _title,
        date: _date,
        price: _pricePerRow[row],
        col: col+1,
        row: row+1,
        seatView: _images[row][col],
        isAvailable: true
      }));
      id++;
    }
  }
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
