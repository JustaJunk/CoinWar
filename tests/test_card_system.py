# test_card_system.py
import pytest
from brownie import CardSystem, MockV3Aggregator, network, accounts

@pytest.fixture
def deploy_card_system(
	get_all_aggregator,
	token_name, token_symbol, token_init_supply,
	get_dev_account):
	# Arrange

	price_feed_aggs, price_feed_addrs = get_all_aggregator
	card_system = CardSystem.deploy(
		price_feed_addrs,
		token_name, token_symbol, token_init_supply,
		{"from":get_dev_account})
	# Assert
	assert card_system is not None
	assert card_system.name() == token_name
	assert card_system.symbol() == token_symbol
	assert card_system.totalSupply() == token_init_supply
	assert card_system.balanceOf(get_dev_account) == token_init_supply
	return card_system, price_feed_aggs

def test_seeds(deploy_card_system, get_all_aggregator, get_dev_account):
	card_sys, mocks = deploy_card_system
	if mocks is None:
		return
	init_price = mocks[0].latestAnswer()
	# Act (ETH:0)
	txs = [card_sys.plantSeedETH({"from":accounts[1+i%4]}) for i in range(10)]
	assert card_sys.seedCount() == 10
	assert card_sys.cardCount() == 0
	assert card_sys.getSeedsByOwner(accounts[1]) == (0,4,8)
	assert card_sys.getSeedsByOwner(accounts[2]) == (1,5,9)
	assert card_sys.getSeedsByOwner(accounts[3]) == (2,6)
	assert card_sys.getSeedsByOwner(accounts[4]) == (3,7)
	for i in range(10):
		assert card_sys.seedToOwner(i) == accounts[1+i%4]
		assert txs[i].events["NewSeed"]["seedId"] == i
		assert txs[i].events["NewSeed"]["coinType"] == 0
		assert txs[i].events["NewSeed"]["price"] == init_price
