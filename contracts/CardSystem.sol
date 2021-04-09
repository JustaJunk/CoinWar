// CardSystem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardOwnership.sol";
import "@OpenZeppelin/contracts/token/ERC20/ERC20.sol";

contract CardSystem is CardOwnership, ERC20 {

    event MintToken(uint indexed _cardId, uint _value);
    event TurnCard(uint indexed _cardId, int _power);

    constructor(
        address _ethAggregatorAddress,
        address _linkAggregatorAddress,
        address _uniAggregatorAddress,
        address _compAggregatorAddress,
        string memory _name,
        string memory _symbol,
        uint _initalSupply)
        CardOwnership(
            _ethAggregatorAddress,
            _linkAggregatorAddress,
            _uniAggregatorAddress,
            _compAggregatorAddress) 
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, _initalSupply);
    }

    function MintTokenByCard(uint _cardId) external {
        require(msg.sender == cardToOwner[_cardId]);
        int value = cards[_cardId].power;
        require(value >= 0);
        uint gain = uint(value);
        _cardTransfer(msg.sender, address(0), _cardId);
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