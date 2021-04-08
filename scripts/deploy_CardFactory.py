# deploy_CardFactory.py
import os
from brownie import network, accounts, config, CardFactory

def main():
    justa = accounts.add(os.getenv(config['wallets']['from_key']))
    card_factory = CardFactory.deploy({'from':justa})

if __name__ == '__main__':
    main()