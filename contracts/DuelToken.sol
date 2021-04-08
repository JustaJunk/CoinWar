// DuelToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ERC20.sol";

contract DuelToken is ERC20 {

    uint private _totalSupply;

    mapping (address => uint) private _balances;
    mapping (address => mapping(address => uint)) private _allowances;

    constructor(uint _initalSupply) {
        _totalSupply = _initalSupply;
        _balances[msg.sender] = _initalSupply;
    }

    function totalSupply() override external view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _account) override external view returns (uint) {
        return _balances[_account];
    }

    function transfer(address _recipient, uint _amount) override external returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) override external view returns (uint) {
        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint _amount) override external returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint _amount) override external returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint currentAllowance = _allowances[_sender][msg.sender];
        require(currentAllowance >= _amount);
        _approve(_sender, msg.sender, currentAllowance - _amount);

        return true;
    }

    function _transfer(address _sender, address _recipient, uint _amount) internal {
        require(_sender != address(0));
        require(_recipient != address(0));
        uint senderBalance = _balances[_sender];
        _balances[_sender] = senderBalance - _amount;
        _balances[_recipient] += _amount;

        emit Transfer(_sender, _recipient, _amount);
    }

    function _mint(address _account, uint _amount) internal {
        require(_account != address(0));
        _balances[_account] += _amount;
        _totalSupply += _amount;

        emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint _amount) internal {
        require(_account != address(0));
        uint accountBalance = _balances[_account];
        require(accountBalance >= _amount);
        _balances[_account] = accountBalance - _amount;
        _totalSupply -= _amount;

        emit Transfer(_account, address(0), _amount);
    }

    function _approve(address _owner, address _spender, uint _amount) internal {
        require(_owner != address(0));
        require(_spender != address(0));
        _allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }
}