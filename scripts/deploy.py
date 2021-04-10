# deploy.py
from brownie import (
    network, accounts, config,
    CardFactory, DuelPoints, DuelCards)

def get_dev_account():
    if network.show_active() == "development":
        return accounts[0]
    elif network.show_active() in config["networks"]:
        return accounts.add(config["wallets"]["from_key"])
    else:
        return accounts[0]

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
    dup = duel_points()
    duc = DuelCards.deploy(
            dup.address,
            {"from": get_dev_account()},
            publish_source=config["verify"])
    dup.setDuelCardAddress(duc.address, {"from": get_dev_account()})
    return duc, dup

def main():
    return duel_cards()
