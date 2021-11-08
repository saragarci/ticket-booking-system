// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Ticket is ERC721 {
  constructor() ERC721("Ticket", "TKT") {}

  struct TicketInfo {
    uint showId;
    uint date;
    uint seatId;
  }

  mapping(uint256 => TicketInfo) public tokenIdToTicketInfo;

  // burn token: tokenIdToTicketInfo(address = 0)
}
