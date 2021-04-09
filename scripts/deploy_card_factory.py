# deploy_card_factory.py
from brownie import network, accounts, config, CardFactory, MockV3Aggregator
import brownie.scripts.get_cofig as cfg

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

def main():
    price_feed_address = cfg.get_price_feed_address()
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

