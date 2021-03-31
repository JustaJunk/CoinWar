// CardFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

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

    constructor() {
        seedCount = 0;
        cardCount = 0;
        priceFeedETH = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        priceFeedLINK = AggregatorV3Interface(0x396c5E36DD0a0F5a5D33dae44368D4193f69a1F0);
        priceFeedUNI = AggregatorV3Interface(0xDA5904BdBfB4EF12a3955aEcA103F51dc87c7C39);
        priceFeedCOMP = AggregatorV3Interface(0xECF93D14d25E02bA2C13698eeDca9aA98348EFb6);
    }
    
    modifier checkBase(uint _seedId, CoinType _coinType) {
        require(seedToOwner[_seedId] == msg.sender);
        require(seeds[_seedId].coinType == _coinType);
        _;
    }

    function _plantSeed(CoinType _coinType, int _price) private {
        seeds.push(Seed(_coinType, _price));
        seedToOwner[seedCount] = msg.sender;
        emit NewSeed(seedCount, _coinType, _price);
        seedCount += 1;
        ownerSeedCount[msg.sender] += 1;
    }  

    function _printCard(CoinType _coinType, uint _seedId, int _price) private {
        int seedPrice = seeds[_seedId].price; 
        int power = _price*significand/seedPrice - significand;
        cards.push(Card(_coinType, power));
        cardToOwner[cardCount] = msg.sender;
        seedToOwner[_seedId] = address(0);
        emit NewCard(cardCount, _coinType, seedPrice, _price, power);
        cardCount += 1;
        ownerCardCount[msg.sender] += 1;
        ownerSeedCount[msg.sender] -= 1;
    }

    function plantSeedETH() public {
        (,int basePrice,,,) = priceFeedETH.latestRoundData();
        _plantSeed(CoinType.ETH, basePrice);
    }
    
    function printCardETH(uint _seedId) public checkBase(_seedId, CoinType.ETH) {
        (,int nowPrice,,,) = priceFeedETH.latestRoundData();
        _printCard(CoinType.ETH, _seedId, nowPrice);
    }

    function plantSeedLINK() public {
        (,int basePrice,,,) = priceFeedLINK.latestRoundData();
        _plantSeed(CoinType.LINK, basePrice);
    }
    
    function printCardLINK(uint _seedId) public checkBase(_seedId, CoinType.LINK) {
        (,int nowPrice,,,) = priceFeedLINK.latestRoundData();
        _printCard(CoinType.LINK, _seedId, nowPrice);
    }

    function plantSeedUNI() public {
        (,int basePrice,,,) = priceFeedUNI.latestRoundData();
        _plantSeed(CoinType.UNI, basePrice);
    }
    
    function printCardUNI(uint _seedId) public checkBase(_seedId, CoinType.UNI) {
        (,int nowPrice,,,) = priceFeedUNI.latestRoundData();
        _printCard(CoinType.UNI, _seedId, nowPrice);
    }

    function plantSeedCOMP() public {
        (,int basePrice,,,) = priceFeedCOMP.latestRoundData();
        _plantSeed(CoinType.COMP, basePrice);
    }
    
    function printCardCOMP(uint _seedId) public checkBase(_seedId, CoinType.COMP) {
        (,int nowPrice,,,) = priceFeedCOMP.latestRoundData();
        _printCard(CoinType.COMP, _seedId, nowPrice);
    }
}