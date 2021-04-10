# test_card_system.py
import pytest
from brownie import CardSystem, MockV3Aggregator, accounts
import brownie

@pytest.fixture(scope="module")
def deploy_card_system(get_all_aggregator, get_dev_account):

    # Arrange
    price_feed_aggs, price_feed_addrs = get_all_aggregator
    card_system = CardSystem.deploy(price_feed_addrs, {"from":get_dev_account})

    # Assert
    assert card_system is not None
    return card_system, price_feed_aggs

##################################################
#
#   CardFactory: plantSeedETH(), seedCount()
#
##################################################
@pytest.mark.require_network("development")
def test_seed_count(deploy_card_system):
    card_system, mocks = deploy_card_system
    init_price = mocks[0].latestAnswer()

    # Assert
    assert card_system.seedCount() == 0

    # Act: plant 10 ETH seeds
    txs = [card_system.plantSeedETH({"from":accounts[i%4]}) for i in range(10)]
    
    # Assert
    assert card_system.seedCount() == 10
    for i in range(10):
        assert txs[i].events["NewSeed"]["seedId"] == i
        assert txs[i].events["NewSeed"]["coinType"] == 0
        assert txs[i].events["NewSeed"]["price"] == init_price
        assert card_system.seeds(i) == (0, init_price)

#############################################
#
#   CardFactory: seedToOwner()
#
#############################################
@pytest.mark.require_network("development")
def test_seed_owner(deploy_card_system):
    card_system, mocks = deploy_card_system

    # Assert
    for i in range(10):
        assert card_system.seedToOwner(i) == accounts[i%4]

#############################################
#
#   CardFactory: getSeedsByOwner()
#
#############################################
@pytest.mark.require_network("development")
def test_get_seeds_by_owner(deploy_card_system):
    card_system, mocks = deploy_card_system

    # Assert
    assert card_system.getSeedsByOwner(accounts[0]) == (0,4,8)
    assert card_system.getSeedsByOwner(accounts[1]) == (1,5,9)
    assert card_system.getSeedsByOwner(accounts[2]) == (2,6)
    assert card_system.getSeedsByOwner(accounts[3]) == (3,7)

#############################################
#
#   CardFactory: print card with wrong coin type
#
#############################################
@pytest.mark.require_network("development")
def test_print_card_wrong_coin_type(deploy_card_system):
    card_system, mocks = deploy_card_system
    accounts0_seeds = card_system.getSeedsByOwner(accounts[0])

    # Assert
    with brownie.reverts():
        tx = card_system.printCardLINK(accounts0_seeds[0], {"from":accounts[0]})
        assert tx.status == 0
        tx = card_system.printCardUNI(accounts0_seeds[1], {"from":accounts[0]})
        assert tx.status == 0
        tx = card_system.printCardCOMP(accounts0_seeds[2], {"from":accounts[0]})
        assert tx.status == 0

#############################################
#
#   CardFactory: print card with wrong owner
#
#############################################
@pytest.mark.require_network("development")
def test_print_card_wrong_owner(deploy_card_system):
    card_system, mocks = deploy_card_system
    accounts0_seeds = card_system.getSeedsByOwner(accounts[0])

    # Assert
    with brownie.reverts():
        for i in range(3):
            tx = card_system.printCardETH(accounts0_seeds[i], {"from":accounts[i+1]})
            assert tx.status == 0


