// ERC721.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721 {
	
    event Transfer(address indexed _from, address indexed _to, uint indexed _cardId);
    event Approval(address indexed _owner, address indexed _approved, uint indexed _cardId);

    function balanceOf(address _owner) external view returns (uint);
    function ownerOf(uint _cardId) external view returns (address);
    function transferFrom(address _from, address _to, uint _cardId) external payable;
    function approve(address _approved, uint _cardId) external payable;
}
