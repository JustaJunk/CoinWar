# conftest.py
import pytest
from brownie import (
    Contract,
    MockV3Aggregator,
    accounts,
    config,
    network,
)

@pytest.fixture(scope="module")
def get_dev_account():
    if network.show_active() == "development":
        return accounts[0]
    elif network.show_active() in config["networks"]:
        dev_account = accounts.add(config["wallets"]["from_key"])
        return dev_account
    else:
        pytest.skip("Invalid network")
        return

@pytest.fixture(scope="module")
def get_all_aggregator():
    if network.show_active() == "development":
        mocks = [MockV3Aggregator.deploy(0,(i+1)*1000, {"from": accounts[1]}) for i in range(4)]
        return [mock.address for mock in mocks]
    elif network.show_active() in config["networks"]:
        which_network = config["networks"][network.show_active()]
        return [which_network["eth_usd_price_feed"],
                which_network["uni_usd_price_feed"],
                which_network["comp_usd_price_feed"],
                which_network["link_usd_price_feed"]]
    else:
        pytest.skip("Invalid network")
        return