// DuelTokenSystem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DuelToken.sol";

contract DuelTokenSystem is DuelToken {

    event MintToken(uint indexed _cardId, uint _value);
    event TurnCard(uint indexed _cardId, int _power);

    constructor() DuelToken(77777777777777) {}

    function MintTokenByCard(uint _cardId) external {
        require(msg.sender == cardToOwner[_cardId]);
        int value = cards[_cardId].power;
        require(value >= 0);
        uint gain = uint(value);
        _itemTransfer(msg.sender, address(0), _cardId);
        delete cards[_cardId];
        _mint(msg.sender, gain);
        ownerCardCount[msg.sender] -= 1;

        emit MintToken(_cardId, gain);
    }

    function TurnCardPower(uint _cardId) external {
        require(msg.sender == cardToOwner[_cardId]);
        int value = cards[_cardId].power;
        require(value < 0);
        uint cost = uint(-value*2);
        _burn(msg.sender, cost);
        cards[_cardId].power = -value;

        emit TurnCard(_cardId, -value);
    }
}