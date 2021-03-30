// ERC20.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

	function totalSupply() external view returns (uint);
    function balanceOf(address _account) external view returns (uint);
    function transfer(address _recipient, uint _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint);
    function approve(address _spender, uint _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint _amount) external returns (bool);
}