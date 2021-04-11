# deploy.py
from brownie import (
    network, accounts, config,
    MockV3Aggregator,
    CardFactory, DuelPoints, DuelCards, JustaDuel)

def get_dev_account():
    if network.show_active() == "development":
        return accounts[0]
    elif network.show_active() in config["networks"]:
        return accounts.add(config["wallets"]["from_key"])
    else:
        return accounts[0]

def get_mocks(num):
    return [MockV3Aggregator.deploy(0,(i+1)*1000, {"from": accounts[1]}) for i in range(num)]

def card_factory():
    return CardFactory.deploy(
            "Duel Cards", "DuC",
            {"from": get_dev_account()},
            publish_source=config["verify"])

def duel_points():
    return DuelPoints.deploy(
            {"from": get_dev_account()},
            publish_source=config["verify"])

def duel_cards():
    dev = get_dev_account()
    dup = duel_points()
    duc = DuelCards.deploy(
            dup.address,
            {"from": dev},
            publish_source=config["verify"])
    dup.setDuelCardsAddress(duc.address, {"from": dev})
    return duc, dup

def justa_duel():
    dev = get_dev_account()
    dup = duel_points()
    duc = JustaDuel.deploy(
            dup.address,
            {"from": dev},
            publish_source=config["verify"])
    dup.setDuelCardsAddress(duc.address, {"from": dev})
    return duc, dup

def main():
    dev = get_dev_account()
    duc, dup = justa_duel()
    if network.show_active() == "development":
        mocks = get_mocks(4)
        addrs = [mock.address for mock in mocks]
    elif network.show_active() in config["networks"]:
        mocks = None
        addrs = [config["networks"][network.show_active()]["eth_usd_price_feed"],
                 config["networks"][network.show_active()]["uni_usd_price_feed"],
                 config["networks"][network.show_active()]["comp_usd_price_feed"],
                 config["networks"][network.show_active()]["link_usd_price_feed"]]
    else:
        print("Invalid network to deploy")
        return

    [duc.setAddressType(addrs[i], i+1, {"from":dev}) for i in range(4)]
    return duc, dup, mocks


