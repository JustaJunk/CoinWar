// CardOwnership.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardHelper.sol";
import "../interfaces/ERC721Card.sol";

contract CardOwnership is CardHelper, ERC721Card {
    
    mapping (uint => address) private _cardApprovals;

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
}