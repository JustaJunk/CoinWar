// DuelPoints.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@OpenZeppelin/contracts/token/ERC20/ERC20.sol";
import "@OpenZeppelin/contracts/access/Ownable.sol";

contract DuelPoints is ERC20, Ownable {

    bool public ifSetDuelCardAddress;
    address public duelCardAddress;

    constructor() ERC20("Duel Points", "DuP") {
        _mint(msg.sender, 7777777e18);
        ifSetDuelCardAddress = false;
        duelCardAddress = address(0);
    }

    modifier onlyDuelCard {
        require(msg.sender == duelCardAddress, "DuelPoints: only call by DuelCards");
        _;
    }

    function setDuelCardAddress(address duelCardAddress_) external onlyOwner {
        require(!ifSetDuelCardAddress);
        duelCardAddress = duelCardAddress_;
        ifSetDuelCardAddress = true;
    }

    function mint(address who, uint amount) external onlyDuelCard {
        _mint(who, amount*10**decimals());
    }

    function burn(address who, uint amount) external onlyDuelCard {
        _burn(who, amount*10**decimals());
    }
}