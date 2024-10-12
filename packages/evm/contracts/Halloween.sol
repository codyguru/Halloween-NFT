// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HalloweenNFT is ERC721, ERC721URIStorage, ReentrancyGuard {
  using Strings for uint256;

  uint256 private constant MAX_SUPPLY = 100;
  uint256 private constant NUM_NFT_TYPES = 10;
  uint256 private constant MINTING_COOLDOWN = 1 weeks;
  uint256 private constant MAX_TOKENS = 3;

  uint256 private _tokenIdTracker;
  string private _baseTokenURI;

  struct TokenData {
    uint8 nftType;
    uint8 rarity;
  }

  mapping(uint256 => TokenData) private _tokenData;
  mapping(address => uint256) private _lastMintTime;

  uint256[5] private _rarityThresholds = [10, 25, 45, 70, 100];

  event TokenMinted(address indexed to, uint256 tokenId, uint8 nftType, uint8 rarity);

  constructor(string memory baseURI) 
    ERC721("HalloweenNFT", "HAL")
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

  function mint()
    public
    nonReentrant
  {
    require(_tokenIdTracker < MAX_SUPPLY, "Max supply reached");
    require(block.timestamp >= _lastMintTime[msg.sender] + MINTING_COOLDOWN, "Minting cooldown has not elapsed");
    require(balanceOf(msg.sender) < MAX_TOKENS, "Max tokens per user reached");

    uint256 tokenId = _tokenIdTracker++;
    _safeMint(msg.sender, tokenId);
    _lastMintTime[msg.sender] = block.timestamp;

    (uint8 nftType, uint8 rarity) = _generateRandomness(tokenId);

    _tokenData[tokenId] = TokenData({
      nftType: nftType,
      rarity: rarity
    });

    _setTokenURI(tokenId, string(abi.encodePacked(_baseTokenURI, "/", Strings.toString(nftType), ".json")));

    emit TokenMinted(msg.sender, tokenId, nftType, rarity);
  }

  function _generateRandomness(uint256 tokenId)
    internal
    view
    returns (uint8 nftType, uint8 rarity)
  {
    uint256 randomValue = uint256(keccak256(abi.encodePacked(
      block.prevrandao,
      blockhash(block.number - 1),
      block.timestamp,
      msg.sender,
      tokenId,
      address(this).balance,
      tx.gasprice,
      block.number,
      gasleft()
    )));

    nftType = uint8(randomValue % NUM_NFT_TYPES);
    rarity = _calculateRarity(randomValue);
  }

  function _calculateRarity(uint256 randomValue)
    internal
    pure
    returns (uint8)
  {
    uint256 rarityValue = randomValue % 100;
    if (rarityValue < 10) return 1;
    if (rarityValue < 25) return 2;
    if (rarityValue < 45) return 3;
    if (rarityValue < 70) return 4;
    return 5;
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

  function getRarity(uint256 tokenId)
    public
    view
    returns (uint8)
  {
    require(tokenId < _tokenIdTracker, "Token does not exist");
    return _tokenData[tokenId].rarity;
  }

  function getNFTType(uint256 tokenId)
    public
    view 
    returns (uint8)
  {
    require(tokenId < _tokenIdTracker, "Token does not exist");
    return _tokenData[tokenId].nftType;
  }

  function getCurrentToken()
    public
    view
    returns (uint256)
  {
    return _tokenIdTracker - 1;
  }

  function timeUntilNextMint(address user)
    public
    view
    returns (uint256)
  {
    uint256 timeSinceLastMint = block.timestamp - _lastMintTime[user];
    if (timeSinceLastMint >= MINTING_COOLDOWN) {
      return 0;
    }
    return MINTING_COOLDOWN - timeSinceLastMint;
  }
}