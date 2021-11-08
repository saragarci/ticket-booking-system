// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Poster is ERC721 {
  constructor() ERC721("Poster", "PTR") {}

  struct PosterInfo {
    uint showId;
    uint date;
    uint seatId;
  }

  mapping(uint256 => PosterInfo) public tokenIdToPosterInfo;
}
