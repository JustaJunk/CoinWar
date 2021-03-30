// CryptoDualSystem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CryptoDualLifePoints.sol";

contract CryptoDualSystem is CryptoDualLifePoints {

	address cardAddress;

	constructor(address _cardAddress) CryptoDualLifePoints(800000000000) {
		cardAddress = _cardAddress;
	}

	function dual(address _player1, uint[] calldata _cardIds1,
				  address _player2, uint[] calldata _cardIds2) {

	}
}