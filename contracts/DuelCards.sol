// DuelCards.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardFactory.sol";
import "../interfaces/DuelPointsInterface.sol";
import "@OpenZeppelin/contracts/token/ERC20/IERC20.sol";

contract DuelCards is CardFactory {

    DuelPointsInterface internal duelPoints;

    constructor(address duelPointsAddress) CardFactory("Duel Cards", "DuC") {
        duelPoints = DuelPointsInterface(duelPointsAddress);
    }

    function burnCard(uint cardId) external {
        require(msg.sender == ownerOf(cardId),
                "DuelCards: caller is not the owner of this card");
        int value = cards[cardId].power;
        require(value >= 0,
                "DuelCards: can only burn the card with positive power");
        uint gain = uint(value);
        _burn(cardId);
        duelPoints.mint(msg.sender, gain);
    }

    function turnCard(uint cardId) external {
        require(msg.sender == ownerOf(cardId),
                "DuelCards: caller is not the owner of this card");
        int value = cards[cardId].power;
        require(value < 0,
                "DuelCards: can only turn the card with negative power");
        uint cost = uint(-value*2);
        duelPoints.burn(msg.sender, cost);
        cards[cardId].power = -value;
    }
}