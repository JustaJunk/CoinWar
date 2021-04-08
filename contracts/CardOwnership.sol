// CardOwnership.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardFactory.sol";
import "../interfaces/ERC721Card.sol";

contract CardOwnership is CardFactory, ERC721Card {
    
    mapping (uint => address) private _cardApprovals;

    constructor(
        address _ethAggregatorAddress,
        address _linkAggregatorAddress,
        address _uniAggregatorAddress,
        address _compAggregatorAddress) 
        CardFactory(
            _ethAggregatorAddress,
            _linkAggregatorAddress,
            _uniAggregatorAddress,
            _compAggregatorAddress)
    {
    }

    function cardBalanceOf(address _owner) override external view returns (uint) {
        return ownerCardCount[_owner];
    }   

    function cardOwnerOf(uint _cardId) override external view returns (address) {
        return cardToOwner[_cardId];
    }

    function cardApprove(address _approved, uint _cardId) override external payable {
        require(cardToOwner[_cardId] == msg.sender);
        _cardApprovals[_cardId] = _approved;
        emit CardApproval(msg.sender, _approved, _cardId);
    }

    function cardTransferFrom(address _from, address _to, uint _cardId) override external payable {
        require(cardToOwner[_cardId] == msg.sender || _cardApprovals[_cardId] == msg.sender);
        _cardTransfer(_from, _to, _cardId);
    }

    function _cardTransfer(address _from, address _to, uint _cardId) internal {
        ownerCardCount[_to] += 1;
        ownerCardCount[msg.sender] -= 1;
        cardToOwner[_cardId] = _to;
        emit CardTransfer(_from, _to, _cardId);
    }

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