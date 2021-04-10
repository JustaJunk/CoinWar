# mock.py
from brownie import accounts, MockV3Aggregator

def main():
    return MockV3Aggregator.deploy(0,2000, {"from": accounts[0]})