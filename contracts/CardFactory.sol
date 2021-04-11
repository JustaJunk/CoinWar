// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@OpenZeppelin/contracts/token/ERC721/ERC721.sol";
import "@OpenZeppelin/contracts/access/Ownable.sol";


contract CardFactory is ERC721, Ownable {
 
    struct Seed {
        address     aggAddress;
        int         price;
        bool        isLong;
        uint        timeStamp;
    }

    struct Card {
        address     aggAddress;
        int         power;
        CardType    cardType;
        uint        interval;
    }

    event NewSeed(uint indexed seedId, address indexed aggAddress, int price, bool isLong);
    event NewCard(uint indexed cardId, address indexed aggAddress, int power, uint interval);
    
    uint public seedCounter;
    uint public cardCounter;
      
    Seed[] public seeds;
    Card[] public cards;
  
    mapping (uint => address) private _seedOwnerOf;
    mapping (address => uint) private _seedBalanceOf;

    enum CardType {NONE, BASE, SWAP, LEND, LINK}
    mapping (address => CardType) public aggAddressToType;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_) {
        seedCounter = 0;
        cardCounter = 0;
    }

    function setAddressType(address aggAddress, CardType cardType) external onlyOwner {
        require(aggAddressToType[aggAddress] == CardType.NONE,
                "CardFactory: address have been set");
        aggAddressToType[aggAddress] = cardType;
    } 

    function plantSeed(address aggAddress_, bool isLong_) external {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggAddress_);
        (,int price,,uint timeStamp,) = priceFeed.latestRoundData();
        seeds.push(Seed(aggAddress_, price, isLong_, timeStamp));
        _seedOwnerOf[seedCounter] = msg.sender;
        _seedBalanceOf[msg.sender] += 1;

        emit NewSeed(seedCounter, aggAddress_, price, isLong_);
        seedCounter += 1;
    }
    
    function printCard(uint seedId_) external {
        require(seedOwnerOf(seedId_) == msg.sender,
                "CardFactory: caller is not the owner of this seed");

        address seedAggAddr = seeds[seedId_].aggAddress;
        AggregatorV3Interface priceFeed = AggregatorV3Interface(seedAggAddr);
        (,int price,,uint timeStamp,) = priceFeed.latestRoundData();
        int power;
        if (seeds[seedId_].isLong) {
            power = price*1000/seeds[seedId_].price - 1000;
        }
        else {
            power = 1000 - price*1000/seeds[seedId_].price;
        }
        uint interval = timeStamp - seeds[seedId_].timeStamp;
        cards.push(Card(seedAggAddr, power, aggAddressToType[seedAggAddr], interval));
        _mint(msg.sender, cardCounter);
        _seedOwnerOf[seedId_] = address(0);
        delete seeds[seedId_];
        _seedBalanceOf[msg.sender] -= 1;

        emit NewCard(cardCounter, seedAggAddr, power, interval);
        cardCounter += 1;
    }

    function seedOwnerOf(uint seedId) public view returns (address) {
        return _seedOwnerOf[seedId];
    }

    function seedBalanceOf(address owner) public view returns (uint) {
        return _seedBalanceOf[owner];
    }

    function getSeedsByOwner(address owner) external view returns(uint[] memory) {
        uint[] memory seedList = new uint[](seedBalanceOf(owner));
        uint index = 0;
        for (uint i = 0; i < seedCounter; i++) {
            if (seedOwnerOf(i) == owner) {
                seedList[index] = i;
                index++;
            }
        }
        return seedList;
    }

    function getCardsByOwner(address owner) external view returns(uint[] memory) {
        uint[] memory cardList = new uint[](balanceOf(owner));
        uint index = 0;
        for (uint i = 0; i < cardCounter; i++) {
            if (ownerOf(i) == owner) {
                cardList[index] = i;
                index++;
            }
        }
        return cardList;
    }
}