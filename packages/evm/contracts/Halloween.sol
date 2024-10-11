// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HalloweenNFT is ERC721, ERC721URIStorage, Ownable {
  uint256 private _nextTokenId;
  string private _baseTokenURI;

  constructor(address initialOwner) 
    ERC721("HalloweenNFT", "HAL")
    Ownable(initialOwner)
  {}

  function setBaseURI(string memory baseURI) 
    public 
    onlyOwner 
  {
    _baseTokenURI = baseURI;
  }

  function _baseURI() 
    internal 
    view
    override
    returns (string memory)
  {
    return _baseTokenURI;
  }

  function safeMint(address to)
    public
    onlyOwner
    returns (uint256)
  {
    uint256 tokenId = _nextTokenId;
    _safeMint(to, tokenId);
    _nextTokenId++;
    return tokenId;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  function getCurrentToken()
    public
    view
    returns (uint256)
  {
    return _nextTokenId - 1;
  }
}