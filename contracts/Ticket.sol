// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

  // returns a new minted ticket an assigns this to the buyer
  // show id, date, seat row and column are stored in a mapping indexed by token id
  function createTicket(address _buyer, uint _showId, uint _date, uint _seatRow, uint _seatCol)
    public onlyOwner() returns (uint256)
  {
    _tokenIds.increment();

    uint256 newTokenId = _tokenIds.current();
    _safeMint(_buyer, newTokenId);
    tokenIdToTicketInfo[newTokenId] = TicketInfo({
      showId: _showId,
      date: _date,
      seatRow: _seatRow,
      seatCol: _seatCol
    });

    return newTokenId;
  }

  // public function that returns all information for a given token id: show id, date, seat row and column
  function getTicketInfo(uint256 _tokenId) public view returns (uint, uint, uint, uint)
  {
    require(_exists(_tokenId), "Ticket doesn't exist!");
    return (
      tokenIdToTicketInfo[_tokenId].showId,
      tokenIdToTicketInfo[_tokenId].date,
      tokenIdToTicketInfo[_tokenId].seatRow,
      tokenIdToTicketInfo[_tokenId].seatCol
    );
  }

  // public function only the owner can call
  // returns whether a token exists or not (i.e. has not been burned)
  function ticketExists(uint256 _tokenId) public view onlyOwner() returns (bool)
  {
    return _exists(_tokenId);
  }

  // public function only the owner can call
  // burns a token id
  function destroyTicket(uint256 _tokenId) public onlyOwner()
  {
    _burn(_tokenId);
  }
}
