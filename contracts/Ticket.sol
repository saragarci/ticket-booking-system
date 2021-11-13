// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

// enum: you can have more than one ticket per seat

contract Ticket is ERC721, Ownable {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  struct TicketInfo {
    uint showId;
    uint date;
    uint seatRow;
    uint seatCol;
  }

  mapping(uint256 => TicketInfo) public tokenIdToTicketInfo;

  constructor() ERC721("Ticket", "TKT") {}

  function createTicket(address _buyer, uint _showId, uint _date, uint _seatRow, uint _seatCol)
    public onlyOwner() returns (uint256)
  {
    _tokenIds.increment();

    uint256 newTokenId = _tokenIds.current();
    _safeMint(_buyer, newTokenId); // assign ticket with newTokenId to the sender address (ownership)
    tokenIdToTicketInfo[newTokenId] = TicketInfo({
      showId: _showId,
      date: _date,
      seatRow: _seatRow,
      seatCol: _seatCol
    });

    return newTokenId;
  }


  // burn
  // _burn
}
