// CardHelper.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardFactory.sol";

contract CardHelper is CardFactory {

    function getSeedsByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory seedList = new uint[](ownerSeedCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < cards.length; i++) {
          	if (seedToOwner[i] == _owner) {
            	seedList[counter] = i;
            	counter++;
          	}
        }
        return seedList;
    }

    function getCardsByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory cardList = new uint[](ownerCardCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < cards.length; i++) {
          	if (cardToOwner[i] == _owner) {
            	cardList[counter] = i;
            	counter++;
          	}
        }
        return cardList;
  	}
}