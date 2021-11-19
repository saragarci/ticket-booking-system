// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Poster is ERC721, Ownable {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  struct PosterInfo {
    uint showId;
  }

  mapping(uint256 => PosterInfo) public tokenIdToPosterInfo;

  constructor() ERC721("Poster", "PTR") {}

  // returns a new minted poster an assigns this to the buyer
  // show id is stored in a mapping indexed by token id
  function createPoster(address _buyer, uint _showId) public
    onlyOwner() returns (uint256)
  {
    _tokenIds.increment();

    uint256 newTokenId = _tokenIds.current();
    _safeMint(_buyer, newTokenId);
    tokenIdToPosterInfo[newTokenId] = PosterInfo({showId: _showId});

    return newTokenId;
  }
}
