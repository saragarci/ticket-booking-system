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

  constructor() ERC721("Ticket", "TKT") {}

  /*struct TicketInfo {
    uint showId;
    uint date;
    uint seatId;
  }*/

  //mapping(uint256 => TicketInfo) public tokenIdToTicketInfo;

  /*function createTicket(address _buyer, uint _showId, uint _date, uint _seatId)
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
  }*/


    /**
    * Custom accessor to create a unique token
    */
    /*function mintUniqueTokenTo(
        address _to,
        uint256 _tokenId,
        string  _tokenURI
    ) public
    {
        super._mint(_to, _tokenId);
        super._setTokenURI(_tokenId, _tokenURI);
    }*/

  // burn
  // _burn
}
