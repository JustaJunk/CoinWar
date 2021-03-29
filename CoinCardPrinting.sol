// coincard.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract CoinCardPrinting {
 
    enum CoinType{ETH, LINK, UNI, COMP}
   
    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedLINK;
    AggregatorV3Interface internal priceFeedUNI;
    AggregatorV3Interface internal priceFeedCOMP;
    
    event NewCardBase(uint baseId, CoinType coinType, uint price);
    event NewCoinCard(uint cardId, CoinType coinType, uint power);
    
    int significand = 1000;
    
    struct CoinCard {
        CoinType    coinType;
        int         value;
    }
    
    CoinCard[] public cardBases;
    CoinCard[] public coinCards;
  
    mapping (uint => address) public cardBaseToDualist;
    mapping (uint => address) public coinCardToDualist;
    mapping (address => uint) dualistCardCount;

    constructor() {
        priceFeedETH = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        priceFeedLINK = AggregatorV3Interface(0x396c5E36DD0a0F5a5D33dae44368D4193f69a1F0);
        priceFeedUNI = AggregatorV3Interface(0xDA5904BdBfB4EF12a3955aEcA103F51dc87c7C39);
        priceFeedCOMP = AggregatorV3Interface(0xECF93D14d25E02bA2C13698eeDca9aA98348EFb6);
    }
    
    function setETHBase() public {
        (,int basePrice,,,) = priceFeedETH.latestRoundData();
        cardBases.push(CoinCard(CoinType.ETH,basePrice));
        cardBaseToDualist[cardBases.length-1] = msg.sender;
    }
    
    function printETHCard(uint _baseId) public {
        require(cardBaseToDualist[_baseId] == msg.sender,
                "This card base is not yours");
        require(cardBases[_baseId].coinType ==  CoinType.ETH,
                "The coin type of card base is not ETH");
        (,int nowPrice,,,) = priceFeedETH.latestRoundData();
        int power = nowPrice*significand/cardBases[_baseId].value - significand;
        coinCards.push(CoinCard(CoinType.ETH,power));
        coinCardToDualist[coinCards.length-1] = msg.sender;
    }

    function setLINKBase() public {
        (,int basePrice,,,) = priceFeedLINK.latestRoundData();
        cardBases.push(CoinCard(CoinType.LINK,basePrice));
        cardBaseToDualist[cardBases.length-1] = msg.sender;
    }
    
    function printLINKCard(uint _baseId) public {
        require(cardBaseToDualist[_baseId] == msg.sender,
                "This card base is not yours");
        require(cardBases[_baseId].coinType ==  CoinType.LINK,
                "The coin type of card base is not LINK");
        (,int nowPrice,,,) = priceFeedLINK.latestRoundData();
        int power = nowPrice*significand/cardBases[_baseId].value - significand;
        coinCards.push(CoinCard(CoinType.LINK,power));
        coinCardToDualist[coinCards.length-1] = msg.sender;
    }

    function setUNIBase() public {
        (,int basePrice,,,) = priceFeedUNI.latestRoundData();
        cardBases.push(CoinCard(CoinType.UNI,basePrice));
        cardBaseToDualist[cardBases.length-1] = msg.sender;
    }
    
    function printUNICard(uint _baseId) public {
        require(cardBaseToDualist[_baseId] == msg.sender,
                "This card base is not yours");
        require(cardBases[_baseId].coinType ==  CoinType.UNI,
                "The coin type of card base is not UNI");
        (,int nowPrice,,,) = priceFeedUNI.latestRoundData();
        int power = nowPrice*significand/cardBases[_baseId].value - significand;
        coinCards.push(CoinCard(CoinType.UNI,power));
        coinCardToDualist[coinCards.length-1] = msg.sender;
    }

    function setCOMPBase() public {
        (,int basePrice,,,) = priceFeedCOMP.latestRoundData();
        cardBases.push(CoinCard(CoinType.COMP,basePrice));
        cardBaseToDualist[cardBases.length] = msg.sender;
    }
    
    function printCOMPCard(uint _baseId) public {
        require(cardBaseToDualist[_baseId] == msg.sender,
                "This card base is not yours");
        require(cardBases[_baseId].coinType ==  CoinType.COMP,
                "The coin type of card base is not COMP");
        (,int nowPrice,,,) = priceFeedCOMP.latestRoundData();
        int power = nowPrice*significand/cardBases[_baseId].value - significand;
        coinCards.push(CoinCard(CoinType.COMP,power));
        coinCardToDualist[coinCards.length-1] = msg.sender;
    }
}