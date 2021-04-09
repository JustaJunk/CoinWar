# deploy_card_factory.py
import os
from brownie import network, accounts, config, CardFactory

def get_price_feed_address():
	if network.show_active() not in config["networks"]:
		return
	return [config["networks"][network.show_active()]["eth_usd_price_feed"],
    		config["networks"][network.show_active()]["link_usd_price_feed"],
    		config["networks"][network.show_active()]["uni_usd_price_feed"],
    		config["networks"][network.show_active()]["comp_usd_price_feed"]]

def get_token_init():
	return ["Duel Live Points", "DLP", 77e27]

def main():
    if network.show_active() not in config["networks"]:
        print("Invalid network to deploy")
        return

    dev = accounts.add(config["wallets"]["from_key"])
    return CardFactory.deploy(
        get_price_feed_address(),
        {"from": dev},
        publish_source=config["verify"]
        )