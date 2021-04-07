// ERC741.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721Card {

    event CardTransfer(address indexed from, address indexed to, uint indexed cardId);
    event CardApproval(address indexed owner, address indexed approved, uint indexed cardId);  

    function cardBalanceOf(address _owner) external view returns (uint);
    function cardOwnerOf(uint _cardId) external view returns (address);
    function cardApprove(address _approved, uint _cardId) external payable;
    function cardTransferFrom(address _from, address _to, uint _cardId) external payable;
}