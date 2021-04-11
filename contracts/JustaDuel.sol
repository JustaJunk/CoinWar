// JustaDuel.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DuelCards.sol";

contract JustaDuel is DuelCards {

    event DuelRoom(address indexed maker, uint indexed roomId);
    event DuelResult(address indexed winner, address indexed loser, uint gain);

    uint public waitingRoomCounter;
    uint[5][] private _waitingRoom;
    mapping (uint => address) public roomIdToPlayer;
    mapping (address => uint) public playerWinCount;
    mapping (address => uint) public playerLoseCount;

    constructor(address duelPointsAddress) DuelCards(duelPointsAddress) {
        waitingRoomCounter = 0;
    }

    modifier checkCards(uint[5] calldata cardIds) {
        uint cardId;
        uint cardTypeUint;
        for (uint i = 0; i < 5; i++) {
            cardId = cardIds[i];
            require(msg.sender == ownerOf(cardId),
                    "JustaDuel: caller is not the owner of the cards");
            cardTypeUint = uint(aggAddressToType[cards[cardId].aggAddress]);
            require(cards[cardId].power >= 0,
                    "JustaDuel: power of cards must be all positive");
            require(cardTypeUint == 1+i%4 || cardTypeUint == 0,
                    "JustaDuel: card arragement error");
        }
        _;
    }

    function makeDuel(uint[5] calldata cardIds) external checkCards(cardIds) {
        _waitingRoom.push(cardIds);
        roomIdToPlayer[waitingRoomCounter] = msg.sender;

        emit DuelRoom(msg.sender, waitingRoomCounter);
        waitingRoomCounter += 1;
    }

    function takeDuel(uint roomId, uint[5] calldata cardIds) external checkCards(cardIds) {
        address maker = roomIdToPlayer[roomId];
        address taker = msg.sender;
        require(maker != address(0),
                "JustaDuel: room doesn't exit");
        uint takerAllownance = duelPoints.allowance(taker, address(this));
        uint makerAllownance = duelPoints.allowance(maker, address(this));
        require(takerAllownance >= 100e18,
                "JustaDuel: duel taker must have at least 100 duel points approved");

        int gain = _duel(cardIds, _waitingRoom[roomId]);
        uint gainPoints;
        if (gain > 0) {
            gainPoints = uint(gain)*10**18;
            _settle(taker, maker, gainPoints, makerAllownance);
        }
        else {
            gainPoints = uint(-gain)*10**18;
            _settle(maker, maker, gainPoints, takerAllownance);
        }
        roomIdToPlayer[roomId] = address(0);
        delete _waitingRoom[roomId];
    }

    function _duel( uint[5] calldata takerCardIds,
                    uint[5] storage makerCardIds)
                    private view returns (int){

        int[5] memory takerPowers;
        int[5] memory makerPowers;
        Card memory card;

        for (uint i = 0; i < 5; i++) {
            card = cards[takerCardIds[i]];
            if (card.cardType == CardType.NONE) {
                takerPowers[i] = 0;
            }
            else {
                takerPowers[i] = card.power;
            }

            card = cards[makerCardIds[i]];
            if (card.cardType == CardType.NONE) {
                makerPowers[i] = 0;
            }
            else {
                makerPowers[i] = card.power;
            }
        }

        int takerBase = takerPowers[0];
        int makerBase = makerPowers[0];

        // SWAP
        bool doSwap = false;
        if (takerPowers[1] > makerBase) {
            doSwap = !doSwap;
        }
        if (makerPowers[1] > takerBase) {
            doSwap = !doSwap;
        }
        if (doSwap) {
            takerPowers[0] = makerBase;
            makerPowers[0] = takerBase;
        }

        // LEND
        takerPowers[0] += takerPowers[2]*makerPowers[4]/1000;
        makerPowers[0] += makerPowers[2]*takerPowers[4]/1000;

        // LINK
        takerPowers[0] += takerPowers[3]*takerPowers[4]/1000;
        makerPowers[0] += makerPowers[3]*makerPowers[4]/1000;

        return takerPowers[0] - makerPowers[0];
    }

    function _settle(address winner, address loser,
                        uint gain, uint loserAllowance) private {

        playerWinCount[winner] += 1;
        playerLoseCount[loser] += 1;
        if (gain > loserAllowance) {
            gain = loserAllowance;
        }
        duelPoints.transferFrom(loser, winner, gain);

        emit DuelResult(winner, loser, gain);
    }
}