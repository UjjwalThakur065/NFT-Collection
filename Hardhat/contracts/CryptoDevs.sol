
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.8 ;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";


contract CryptoDevs is ERC721Enumerable,Ownable{
   
   // To calculate tokenURI
   string _baseTokenURI;

   //   _price is a price of every NFT 
   uint256 public _price = 0.01 ether;

   // to stop the contract in case of any emergecy breakdown
   bool public _paused;

   //  maximum token available for sale is 20  
   uint256 public maxTokenIds = 20; 

   // To keep track of number of tokens sold 
   uint256 public tokenIds;

   // Whitelist contract instance
   IWhitelist whitelist;

   bool public presaleStarted;

   uint256 public presaleEnded;

   modifier onlyWhenNotPaused {
    require(!_paused,"Contract currently paused due to some bugs");
    _;
   }

   constructor(string memory baseURI,address whitelistContract) 
   ERC721("Crypto Devs Token","CDT") {
    _baseTokenURI = baseURI;
    whitelist = IWhitelist(whitelistContract);
   }
////////////////////////////////////////////////////////////////////////////////////
   function startPresale()  public onlyOwner {
    presaleStarted = true;
    presaleEnded = block.timestamp + 5 minutes;
   }

   function presaleMint() public payable onlyWhenNotPaused {

    require(presaleStarted && block.timestamp < presaleEnded,
    "Presale not started yet!");

    require(whitelist.whitelistedAddresses(msg.sender),
    "Your address is not whitelisted , wait for public sale");

    require(tokenIds < maxTokenIds,"All tokens are minted");

    require(msg.value >= _price,"Not sufficent balance to mint token");

    tokenIds += 1;

    _safeMint(msg.sender,tokenIds);
   }
/////////////////////////////////////////////////////////////////////////////////////

   function mint() public payable onlyWhenNotPaused {

    require(presaleStarted && block.timestamp >= presaleEnded,
    "Presale not started yet!");


    require(tokenIds < maxTokenIds,"All tokens are minted");

    require(msg.value >= _price,"Not sufficent balance to mint token");

    tokenIds += 1;

    _safeMint(msg.sender,tokenIds);
   }
//////////////////////////////////////////////////////////////////////////////////////
  function _baseURI() internal view virtual override returns (string memory ) {
   return _baseTokenURI;
  }

  function setPaused(bool val) public onlyOwner {
   _paused = val;
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  function withdraw() public onlyOwner {
   address _owner= owner();
   uint256 amount = address(this).balance;
   (bool sent,) = _owner.call{value:amount}("");
   require(sent,"Failed to withdra ether");
  }

  receive () external payable {}

  fallback () external payable {}
}

// Crypto Devs deployed at: 0xEAbF879bD0a4fE25Aa0dD2C3E1161916623f0F9b