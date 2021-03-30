// CryptoDualToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardOwnership.sol";

contract CryptoDualToken is CardOwnership {

    uint private _totalSupply;

	mapping (address => uint) private _tokenBalances;
	mapping (address => mapping(address => uint)) private _tokenAllowances;

	constructor(uint _initalStorage) {
        _totalSupply = _initalStorage;
		_tokenBalances[address(this)] = _initalStorage;
	}

	function tokenTotalSupply() override external view returns (uint) {
		return _totalSupply;
	}

    function tokenSystemStorage() external view returns (uint) {
        return _tokenBalances[address(this)];
    }

	function tokenBalanceOf(address _account) override external view returns (uint) {
		return _tokenBalances[_account];
	}

	function tokenTransfer(address _recipient, uint _amount) override external returns (bool) {
		_tokenTransfer(msg.sender, _recipient, _amount);
		return true;
	}

	function tokenAllowance(address _owner, address _spender) override external view returns (uint) {
		return _tokenAllowances[_owner][_spender];
	}

    function tokenApprove(address _spender, uint _amount) override external returns (bool) {
        _tokenApprove(msg.sender, _spender, _amount);
        return true;
    }

    function tokenTransferFrom(address _sender, address _recipient, uint _amount) override external returns (bool) {
        _tokenTransfer(_sender, _recipient, _amount);

        uint currentAllowance = _tokenAllowances[_sender][msg.sender];
        require(currentAllowance >= _amount);
        _tokenApprove(_sender, msg.sender, currentAllowance - _amount);

        return true;
    }

	function _tokenTransfer(address _sender, address _recipient, uint _amount) internal {
		require(_sender != address(0));
        require(_recipient != address(0));
        uint senderBalance = _tokenBalances[_sender];
        _tokenBalances[_sender] = senderBalance - _amount;
        _tokenBalances[_recipient] += _amount;

        emit TokenTransfer(_sender, _recipient, _amount);
	}

    function _tokenMint(address _account, uint _amount) internal {
        require(_account != address(0));
        uint systemStorage = _tokenBalances[address(this)];
        require(systemStorage > 0);
       	if (systemStorage < _amount) {
       		_amount = systemStorage;
       	}
        _totalSupply += _amount;
        _tokenBalances[_account] += _amount;
        _tokenBalances[address(this)] -= _amount;

        emit TokenTransfer(address(this), _account, _amount);
    }

    function _tokenBurn(address _account, uint _amount) internal {
        require(_account != address(0));
        uint accountBalance = _tokenBalances[_account];
        require(accountBalance >= _amount);
        _tokenBalances[_account] = accountBalance - _amount;
        _totalSupply -= _amount;

        emit TokenTransfer(_account, address(this), _amount);
    }

    function _tokenApprove(address _owner, address _spender, uint _amount) internal {
        require(_owner != address(0));
        require(_spender != address(0));
        _tokenAllowances[_owner][_spender] = _amount;

        emit TokenApproval(_owner, _spender, _amount);
    }
}