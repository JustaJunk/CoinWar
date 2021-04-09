// CardFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract CardFactory {
 
    enum CoinType{ETH, LINK, UNI, COMP}
   
    AggregatorV3Interface private priceFeedETH;
    AggregatorV3Interface private priceFeedLINK;
    AggregatorV3Interface private priceFeedUNI;
    AggregatorV3Interface private priceFeedCOMP;
    
    event NewSeed(uint indexed seedId, CoinType indexed coinType, int price);
    event NewCard(uint indexed cardId, CoinType indexed coinType, int seedPrice, int nowPrice, int power);
    
    int private significand = 1000;
    uint public seedCount;
    uint public cardCount;
    
    struct Seed {
        CoinType    coinType;
        int         price;
    }

    struct Card {
        CoinType    coinType;
        int         power;
    }
    
    Seed[] public seeds;
    Card[] public cards;
  
    mapping (uint => address) public seedToOwner;
    mapping (uint => address) public cardToOwner;
    mapping (address => uint) internal ownerSeedCount;
    mapping (address => uint) internal ownerCardCount;

    constructor(address[4] memory _aggregatorAddresses) {
        seedCount = 0;
        cardCount = 0;
        priceFeedETH = AggregatorV3Interface(_aggregatorAddresses[0]);
        priceFeedLINK = AggregatorV3Interface(_aggregatorAddresses[1]);
        priceFeedUNI = AggregatorV3Interface(_aggregatorAddresses[2]);
        priceFeedCOMP = AggregatorV3Interface(_aggregatorAddresses[3]);
    }
    
    modifier checkSeed(uint _seedId, CoinType _coinType) {
        require(seedToOwner[_seedId] == msg.sender);
        require(seeds[_seedId].coinType == _coinType);
        _;
    }

    function _plantSeed(CoinType _coinType, int _price) private {
        seeds.push(Seed(_coinType, _price));
        seedToOwner[seedCount] = msg.sender;
        ownerSeedCount[msg.sender] += 1;

        emit NewSeed(seedCount, _coinType, _price);
        seedCount += 1;
    }  

    function _printCard(CoinType _coinType, uint _seedId, int _price) private {
        int seedPrice = seeds[_seedId].price; 
        int power = _price*significand/seedPrice - significand;
        cards.push(Card(_coinType, power));
        cardToOwner[cardCount] = msg.sender;
        seedToOwner[_seedId] = address(0);
        ownerCardCount[msg.sender] += 1;
        ownerSeedCount[msg.sender] -= 1;

        emit NewCard(cardCount, _coinType, seedPrice, _price, power);
        cardCount += 1;
    }

    function plantSeedETH() public {
        (,int basePrice,,,) = priceFeedETH.latestRoundData();
        _plantSeed(CoinType.ETH, basePrice);
    }
    
    function printCardETH(uint _seedId) public checkSeed (_seedId, CoinType.ETH) {
        (,int nowPrice,,,) = priceFeedETH.latestRoundData();
        _printCard(CoinType.ETH, _seedId, nowPrice);
    }

    function plantSeedLINK() public {
        (,int basePrice,,,) = priceFeedLINK.latestRoundData();
        _plantSeed(CoinType.LINK, basePrice);
    }
    
    function printCardLINK(uint _seedId) public checkSeed (_seedId, CoinType.LINK) {
        (,int nowPrice,,,) = priceFeedLINK.latestRoundData();
        _printCard(CoinType.LINK, _seedId, nowPrice);
    }

    function plantSeedUNI() public {
        (,int basePrice,,,) = priceFeedUNI.latestRoundData();
        _plantSeed(CoinType.UNI, basePrice);
    }
    
    function printCardUNI(uint _seedId) public checkSeed (_seedId, CoinType.UNI) {
        (,int nowPrice,,,) = priceFeedUNI.latestRoundData();
        _printCard(CoinType.UNI, _seedId, nowPrice);
    }

    function plantSeedCOMP() public {
        (,int basePrice,,,) = priceFeedCOMP.latestRoundData();
        _plantSeed(CoinType.COMP, basePrice);
    }
    
    function printCardCOMP(uint _seedId) public checkSeed (_seedId, CoinType.COMP) {
        (,int nowPrice,,,) = priceFeedCOMP.latestRoundData();
        _printCard(CoinType.COMP, _seedId, nowPrice);
    }
}