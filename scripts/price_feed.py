# price_feed.py
from brownie import (
    network, accounts, config, 
    MockV3Aggregator)

def get_eth_usd_address():
    if network.show_active() == "development":
        mock = MockV3Aggregator.deploy(0,2000, {"from": accounts[0]})
        return mock.address
    if network.show_active() in config["networks"]:
        return config["networks"][network.show_active()]["eth_usd_price_feed"]
    else:
        print("Invalid network")
        return ""

def get_uni_usd_address():
    if network.show_active() == "development":
        mock = MockV3Aggregator.deploy(0,20, {"from": accounts[0]})
        return mock.address
    if network.show_active() in config["networks"]:
        return config["networks"][network.show_active()]["uni_usd_price_feed"]
    else:
        print("Invalid network")
        return ""

def get_link_usd_address():
    if network.show_active() == "development":
        mock = MockV3Aggregator.deploy(0,30, {"from": accounts[0]})
        return mock.address
    if network.show_active() in config["networks"]:
        return config["networks"][network.show_active()]["link_usd_price_feed"]
    else:
        print("Invalid network")
        return ""

def get_comp_usd_address():
    if network.show_active() == "development":
        mock = MockV3Aggregator.deploy(0,400, {"from": accounts[0]})
        return mock.address
    if network.show_active() in config["networks"]:
        return config["networks"][network.show_active()]["comp_usd_price_feed"]
    else:
        print("Invalid network")
        return ""

def main():
    return  [get_eth_usd_address(),
            get_uni_usd_address(),
            get_comp_usd_address(),
            get_link_usd_address()]