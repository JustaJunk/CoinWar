# deploy.py
from brownie import (
    network, accounts, config, 
    MockV3Aggregator,
    CardFactory, CardOwnership, CardSystem, JustaDuel)


def get_price_feed_address():
    if network.show_active() == "development":
        mocks = [MockV3Aggregator.deploy(0,(i+1)*1000, {"from": accounts[0]}) for i in range(4)]
        return [mock.address for mock in mocks]
    if network.show_active() in config["networks"]:
        return [config["networks"][network.show_active()]["eth_usd_price_feed"],
                config["networks"][network.show_active()]["link_usd_price_feed"],
                config["networks"][network.show_active()]["uni_usd_price_feed"],
                config["networks"][network.show_active()]["comp_usd_price_feed"]]
    else:
        return []

def card_factory():
    price_feed_address = get_price_feed_address()
    if price_feed_address:
        dev = accounts.add(config["wallets"]["from_key"])
        return CardFactory.deploy(
            price_feed_address,
            {"from": dev},
            publish_source=config["verify"]
            )
    else:
        print("Invalid network to deploy")
        return

def card_ownership():
    price_feed_address = get_price_feed_address()
    if price_feed_address:
        dev = accounts.add(config["wallets"]["from_key"])
        return CardOwnership.deploy(
            price_feed_address,
            {"from": dev},
            publish_source=config["verify"]
            )
    else:
        print("Invalid network to deploy")
        return

def card_system():
    price_feed_address = get_price_feed_address()
    if price_feed_address:
        dev = accounts.add(config["wallets"]["from_key"])
        return CardSystem.deploy(
            price_feed_address,
            {"from": dev},
            publish_source=config["verify"]
            )
    else:
        print("Invalid network to deploy")
        return

def justa_duel():
    price_feed_address = get_price_feed_address()
    if price_feed_address:
        dev = accounts.add(config["wallets"]["from_key"])
        return JustaDuel.deploy(
            price_feed_address,
            {"from": dev},
            publish_source=config["verify"]
            )
    else:
        print("Invalid network to deploy")
        return    

def main():
    card_system()
