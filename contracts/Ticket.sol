// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Ticket is ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721("Ticket", "TKT") {}

  struct TicketInfo {
    uint showId;
    uint date;
    uint seatId;
  }

  mapping(uint256 => TicketInfo) public tokenIdToTicketInfo;

  function createTicket(address _buyer, uint _showId, uint _date, uint _seatId)
    public payable returns (uint256)
  {
    _tokenIds.increment();

    uint256 newTokenId = _tokenIds.current();
    tokenIdToTicketInfo[newTokenId] = TicketInfo({
      showId: _showId,
      date: _date,
      seatId: _seatId
    });
    _mint(_buyer, newTokenId); // assign ticket with newTokenId to the sender address (ownership)

    return newTokenId;
  }

  // burn token: tokenIdToTicketInfo(address = 0)
}
