// CardOwnership.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardDisplay.sol";
import "../interfaces/ERC721.sol";

contract CardOwnership is CardDisplay, ERC721 {
    
    mapping (uint => address) cardApprovals;

    function balanceOf(address _owner) override external view returns (uint) {
        return ownerCardCount[_owner];
    }   

    function ownerOf(uint _cardId) override external view returns (address) {
        return cardToOwner[_cardId];
    }

    function transferFrom(address _from, address _to, uint _cardId) override external payable {
        require(cardToOwner[_cardId] == msg.sender || cardApprovals[_cardId] == msg.sender);
        _transfer(_from, _to, _cardId);
    }

    function approve(address _approved, uint _cardId) override external payable {
        require(cardToOwner[_cardId] == msg.sender);
        cardApprovals[_cardId] = _approved;
        emit Approval(msg.sender, _approved, _cardId);
    }

    function _transfer(address _from, address _to, uint _cardId) private {
        ownerCardCount[_to] = ownerCardCount[_to]++;
        ownerCardCount[msg.sender] = ownerCardCount[msg.sender]--;
        cardToOwner[_cardId] = _to;
        emit Transfer(_from, _to, _cardId);
    }
}