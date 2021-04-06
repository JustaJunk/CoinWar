// ERC741.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface ERC741 {

    // ERC20
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint);
    function balanceOf(address _account) external view returns (uint);
    function transfer(address _recipient, uint _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint);
    function approve(address _spender, uint _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint _amount) external returns (bool);

    // ERC721 (modified)
    event CardTransfer(address indexed from, address indexed to, uint indexed cardId);
    event CardApproval(address indexed owner, address indexed approved, uint indexed cardId);  

    function cardBalanceOf(address _owner) external view returns (uint);
    function cardOwnerOf(uint _cardId) external view returns (address);
    function cardApprove(address _approved, uint _cardId) external payable;
    function cardTransferFrom(address _from, address _to, uint _cardId) external payable;
}