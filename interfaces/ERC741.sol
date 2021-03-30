// ERC741.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface ERC741 {

    // ERC20
    event TokenTransfer(address indexed _from, address indexed _to, uint _value);
    event TokenApproval(address indexed _owner, address indexed _spender, uint _value);

    function tokenTotalSupply() external view returns (uint);
    function tokenBalanceOf(address _account) external view returns (uint);
    function tokenTransfer(address _recipient, uint _amount) external returns (bool);
    function tokenAllowance(address _owner, address _spender) external view returns (uint);
    function tokenApprove(address _spender, uint _amount) external returns (bool);
    function tokenTransferFrom(address _sender, address _recipient, uint _amount) external returns (bool);

    // ERC721
    event ItemTransfer(address indexed _from, address indexed _to, uint indexed _itemId);
    event ItemApproval(address indexed _owner, address indexed _approved, uint indexed _itemId);  

    function itemBalanceOf(address _owner) external view returns (uint);
    function itemOwnerOf(uint _itemId) external view returns (address);
    function itemApprove(address _approved, uint _itemId) external payable;
    function itemTransferFrom(address _from, address _to, uint _itemId) external payable;
}