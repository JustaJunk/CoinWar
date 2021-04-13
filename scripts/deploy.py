# deploy.py
from brownie import (
    network, accounts, config,
    MockV3Aggregator,
    CardFactory, DuelPoints, DuelCards, JustaDuel)
import brownie

def get_dev_account():
    if network.show_active() == "development":
        return accounts[0]
    elif network.show_active() in config["networks"]:
        return accounts.add(config["wallets"]["from_key"])
    else:
        return accounts[0]

def get_aggregators():
    return [MockV3Aggregator.at(addr) for addr in brownie.run("price_feed")]

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
    aggs = get_aggregators()

    [duc.setAddressType(aggs[i].address, i+1, {"from":dev}) for i in range(4)]
    return duc, dup, aggs


