# test_duel_cards.py
import pytest
from brownie import accounts, MockV3Aggregator, DuelCards, DuelPoints
import brownie

@pytest.mark.require_network("development")
@pytest.fixture(scope="module")
def deploy_duel_cards(get_all_aggregator, get_dev_account):

    # Arrange
    addrs = get_all_aggregator
    dup = DuelPoints.deploy({"from":get_dev_account})
    assert dup is not None
    duc = DuelCards.deploy(dup.address, {"from":get_dev_account})
    assert duc is not None
    dup.setDuelCardsAddress(duc.address, {"from": get_dev_account})
    [duc.setAddressType(addrs[i], i+1, {"from": get_dev_account}) for i in range(len(addrs))]
    mocks = [MockV3Aggregator.at(addr) for addr in addrs]

    # Assert
    return duc, dup, mocks

##################################################
#
#   1. CardFactory: plantSeed(), seedCounter()
#
##################################################
@pytest.mark.require_network("development")
def test_seed_count(deploy_duel_cards):
    duc, _, mocks = deploy_duel_cards

    # Assert
    assert duc.seedCounter() == 0

    # Act: plant 10 seeds
    txs = [duc.plantSeed(mocks[i%4].address, bool(i%2),
                {"from":accounts[i%4]}) for i in range(10)]
    
    # Assert
    assert duc.seedCounter() == 10
    for i in range(10):
        assert txs[i].status == 1
        assert txs[i].events["NewSeed"]["seedId"] == i
        assert txs[i].events["NewSeed"]["aggAddress"] == mocks[i%4].address
        assert txs[i].events["NewSeed"]["price"] == mocks[i%4].latestAnswer()

#############################################
#
#   2. CardFactory: seedOwnerOf()
#
#############################################
@pytest.mark.require_network("development")
def test_seed_to_owner(deploy_duel_cards):
    duc, _, _ = deploy_duel_cards

    # Assert
    for i in range(10):
        assert duc.seedOwnerOf(i) == accounts[i%4]

#############################################
#
#   3. CardFactory: getSeedsByOwner()
#
#############################################
@pytest.mark.require_network("development")
def test_get_seeds_by_owner(deploy_duel_cards):
    duc, _, _ = deploy_duel_cards

    # Assert
    assert duc.getSeedsByOwner(accounts[0]) == (0,4,8)
    assert duc.getSeedsByOwner(accounts[1]) == (1,5,9)
    assert duc.getSeedsByOwner(accounts[2]) == (2,6)
    assert duc.getSeedsByOwner(accounts[3]) == (3,7)

#############################################
#
#   4. CardFactory: printCard() with wrong owner
#
#############################################
@pytest.mark.require_network("development")
def test_print_card_wrong_owner(deploy_duel_cards):
    duc, _, _ = deploy_duel_cards
    acc0_seeds = duc.getSeedsByOwner(accounts[0])

    # Assert
    with brownie.reverts():
        for i in range(3):
            tx = duc.printCard(acc0_seeds[i], {"from":accounts[i+1]})
            assert tx.status == 0

#############################################
#
#   5. CardFactory: printCard(), cardCounter()
#
#############################################
@pytest.mark.require_network("development")
def test_print_card(deploy_duel_cards):
    duc, _, mocks = deploy_duel_cards

    # Act: change price
    changes = [0.5*i for i in range(4)]
    [mocks[i].updateAnswer(mocks[i].latestAnswer()*(1+changes[i])) for i in range(4)]

    # Assert
    assert duc.cardCounter() == 0
    for i in range(7):
        tx = duc.printCard(i, {"from":accounts[i%4]})
        assert tx.status == 1
        assert tx.events["NewCard"]["cardId"] == i
        assert tx.events["NewCard"]["aggAddress"] == mocks[i%4].address
        assert tx.events["NewCard"]["power"] == -(-1)**i*changes[i%4]*1000
    assert duc.cardCounter() == 7

#############################################
#
#   6. CardFactory: getSeedsByOwner() after
#
#############################################
@pytest.mark.require_network("development")
def test_get_seeds_by_owner_after(deploy_duel_cards):
    duc, _, _ = deploy_duel_cards

    # Assert
    assert duc.getSeedsByOwner(accounts[0]) == (8,)
    assert duc.getSeedsByOwner(accounts[1]) == (9,)
    assert duc.getSeedsByOwner(accounts[2]) == ()
    assert duc.getSeedsByOwner(accounts[3]) == (7,)

#############################################
#
#   7. CardFactory: getCardsByOwner()
#
#############################################
@pytest.mark.require_network("development")
def test_get_cards_by_owner(deploy_duel_cards):
    duc, _, _ = deploy_duel_cards

    # Assert
    assert duc.getCardsByOwner(accounts[0]) == (0,4)
    assert duc.getCardsByOwner(accounts[1]) == (1,5)
    assert duc.getCardsByOwner(accounts[2]) == (2,6)
    assert duc.getCardsByOwner(accounts[3]) == (3,)



