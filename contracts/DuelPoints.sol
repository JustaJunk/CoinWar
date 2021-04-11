// DuelPoints.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@OpenZeppelin/contracts/token/ERC20/ERC20.sol";
import "@OpenZeppelin/contracts/access/Ownable.sol";

contract DuelPoints is ERC20, Ownable {

    bool public ifSetDuelCardsAddress;
    address public duelCardsAddress;

    constructor() ERC20("Duel Points", "DuP") {
        _mint(msg.sender, 7777777e18);
        ifSetDuelCardsAddress = false;
        duelCardsAddress = address(0);
    }

    modifier onlyDuelCard {
        require(msg.sender == duelCardsAddress,
                "DuelPoints: only call by DuelCards");
        _;
    }

    function setDuelCardsAddress(address duelCardsAddress_) external onlyOwner {
        require(!ifSetDuelCardsAddress,
                "DuelPoints: address of DuelCards have been set");
        duelCardsAddress = duelCardsAddress_;
        ifSetDuelCardsAddress = true;
    }

    function mint(address who, uint amount) external onlyDuelCard {
        _mint(who, amount*10**decimals());
    }

    function burn(address who, uint amount) external onlyDuelCard {
        _burn(who, amount*10**decimals());
    }
}