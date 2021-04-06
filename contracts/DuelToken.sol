// DuelToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardOwnership.sol";

contract DuelToken is CardOwnership {

    uint private _totalSupply;

    mapping (address => uint) private _tokenBalances;
    mapping (address => mapping(address => uint)) private _tokenAllowances;

    constructor(uint _initalSupply) {
        _totalSupply = _initalSupply;
        _tokenBalances[msg.sender] = _initalSupply;
    }

    function totalSupply() override external view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _account) override external view returns (uint) {
        return _tokenBalances[_account];
    }

    function transfer(address _recipient, uint _amount) override external returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) override external view returns (uint) {
        return _tokenAllowances[_owner][_spender];
    }

    function approve(address _spender, uint _amount) override external returns (bool) {
        _tokenApprove(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint _amount) override external returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint currentAllowance = _tokenAllowances[_sender][msg.sender];
        require(currentAllowance >= _amount);
        _tokenApprove(_sender, msg.sender, currentAllowance - _amount);

        return true;
    }

    function _transfer(address _sender, address _recipient, uint _amount) internal {
        require(_sender != address(0));
        require(_recipient != address(0));
        uint senderBalance = _tokenBalances[_sender];
        _tokenBalances[_sender] = senderBalance - _amount;
        _tokenBalances[_recipient] += _amount;

        emit Transfer(_sender, _recipient, _amount);
    }

    function _mint(address _account, uint _amount) internal {
        require(_account != address(0));
        _tokenBalances[_account] += _amount;
        _totalSupply += _amount;

        emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint _amount) internal {
        require(_account != address(0));
        uint accountBalance = _tokenBalances[_account];
        require(accountBalance >= _amount);
        _tokenBalances[_account] = accountBalance - _amount;
        _totalSupply -= _amount;

        emit Transfer(_account, address(0), _amount);
    }

    function _approve(address _owner, address _spender, uint _amount) internal {
        require(_owner != address(0));
        require(_spender != address(0));
        _tokenAllowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }
}