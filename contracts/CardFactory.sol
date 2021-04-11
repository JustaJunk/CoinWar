// CardFactory.sol
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
  
    mapping (uint => address) public seedToOwner;
    mapping (address => uint) internal ownerSeedCount;

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

    function plantSeed(address aggAddress_, bool isLong_) public {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggAddress_);
        (,int price,,uint timeStamp,) = priceFeed.latestRoundData();
        seeds.push(Seed(aggAddress_, price, isLong_, timeStamp));
        seedToOwner[seedCounter] = msg.sender;
        ownerSeedCount[msg.sender] += 1;

        emit NewSeed(seedCounter, aggAddress_, price, isLong_);
        seedCounter += 1;
    }
    
    function printCard(address aggAddress_, uint seedId_) public {
        require(seedToOwner[seedId_] == msg.sender,
                "CardFactory: caller is not the owner of this seed");
        require(seeds[seedId_].aggAddress == aggAddress_,
                "CardFactory: aggregator address not match");

        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggAddress_);
        (,int price,,uint timeStamp,) = priceFeed.latestRoundData();
        int power;
        if (seeds[seedId_].isLong) {
            power = price*1000/seeds[seedId_].price - 1000;
        }
        else {
            power = 1000 - price*1000/seeds[seedId_].price;
        }
        uint interval = timeStamp - seeds[seedId_].timeStamp;
        cards.push(Card(aggAddress_, power, aggAddressToType[aggAddress_], interval));
        _mint(msg.sender, cardCounter);
        seedToOwner[seedId_] = address(0);
        delete seeds[seedId_];
        ownerSeedCount[msg.sender] -= 1;

        emit NewCard(cardCounter, aggAddress_, power, interval);
        cardCounter += 1;
    }

    function getSeedsByOwner(address owner) external view returns(uint[] memory) {
        uint[] memory seedList = new uint[](ownerSeedCount[owner]);
        uint counter = 0;
        for (uint i = 0; i < seeds.length; i++) {
            if (seedToOwner[i] == owner) {
                seedList[counter] = i;
                counter++;
            }
        }
        return seedList;
    }

    function getCardsByOwner(address owner) external view returns(uint[] memory) {
        uint[] memory cardList = new uint[](balanceOf(owner));
        uint counter = 0;
        for (uint i = 0; i < cards.length; i++) {
            if (ownerOf(i) == owner) {
                cardList[counter] = i;
                counter++;
            }
        }
        return cardList;
    }
}