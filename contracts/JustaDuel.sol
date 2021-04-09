// JustaDuel.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CardSystem.sol";

contract JustaDuel is CardSystem {

    event DuelResult(address indexed _winner, address indexed _loser, int _gain);
    uint private _noneCardId = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint public waitRoomCount;

    uint[5][] private _waitRoom;
    mapping (uint => address) public roomIdToPlayer;
    mapping (uint => bool) public roomIdFinished;
    mapping (address => uint) public playerWinCount;

    constructor(
        address _ethAggregatorAddress,
        address _linkAggregatorAddress,
        address _uniAggregatorAddress,
        address _compAggregatorAddress,
        string memory _name,
        string memory _symbol,
        uint _initalSupply)
        CardSystem(
            _ethAggregatorAddress,
            _linkAggregatorAddress,
            _uniAggregatorAddress,
            _compAggregatorAddress,
            _name,
            _symbol,
            _initalSupply)
    {
        waitRoomCount = 0;
    }

    modifier checkCardIds(uint[5] calldata _cardIds) {
        require(_cardIds.length == 5);
        uint cardId;
        for (uint i = 0; i < 5; i++) {
            if (i != _noneCardId)
            {
                cardId = _cardIds[i];
                require(cardToOwner[cardId] == msg.sender);
                require(uint(cards[cardId].coinType) == i%4);
                require(cards[cardId].power >= 0);
            }
        }
        _;
    }

    function makeDuel(uint[5] calldata _cardIds) external checkCardIds(_cardIds) {
        _waitRoom.push(_cardIds);
        roomIdToPlayer[waitRoomCount] = msg.sender;
        roomIdFinished[waitRoomCount] = false;
        waitRoomCount += 1;
    }

    function takeDuel(uint _roomId, uint[5] calldata _cardIds) external checkCardIds(_cardIds) {
        require(!roomIdFinished[_roomId]);
        address maker = roomIdToPlayer[_roomId];
        int gain = _duel(_cardIds, _waitRoom[_roomId]);
        if (gain > 0) {
            playerWinCount[msg.sender] += 1;
            emit DuelResult(msg.sender, maker, gain);
        }
        else {
            playerWinCount[maker] += 1;
            emit DuelResult(maker, msg.sender, -gain);
        }
    }

    function _duel(uint[5] calldata _takerCardIds,
                   uint[5] storage _makerCardIds) private view returns (int){

        int[5] memory takerPowers;
        int[5] memory makerPowers;
        uint cardId;

        for (uint i = 0; i < 5; i++) {
            cardId = _takerCardIds[i];
            if (cardId == _noneCardId) {
                takerPowers[i] = 0;
            }
            else {
                takerPowers[i] = cards[cardId].power;
            }

            cardId = _makerCardIds[i];
            if (cardId == _noneCardId) {
                makerPowers[i] = 0;
            }
            else {
                makerPowers[i] = cards[cardId].power;
            }
        }

        int takerBase = takerPowers[0];
        int makerBase = makerPowers[0];

        // UNI swap
        bool doSwap = false;
        if (takerPowers[2] > makerBase) {
            doSwap = !doSwap;
        }
        if (makerPowers[2] > takerBase) {
            doSwap = !doSwap;
        }
        if (doSwap) {
            takerPowers[0] = makerBase;
            makerPowers[0] = takerBase;
        }

        // LINK with ally
        takerPowers[0] += takerPowers[1]*takerPowers[4]/1000;
        makerPowers[0] += makerPowers[1]*makerPowers[4]/1000;

        // COMP from enemy
        takerPowers[0] += takerPowers[3]*makerPowers[4]/1000;
        makerPowers[0] += makerPowers[3]*takerPowers[4]/1000;

        return takerPowers[0] - makerPowers[0];
    }
}