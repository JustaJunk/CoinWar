// CardFactory.js
const CardFactory = artifacts.require("CardFactory");
contract("CardFactory", (accounts)) => {
	let [alice, bob] = accounts;
	it("should plant a seed", async () => {
		const contractInstance = await CardFactory.new();
		const result = await contractInstance.plantSeedETH({from: alice});
		assert.equal(result.receipt.status, true);
		assert.equal(result.logs[0].args.seedId, 0);
		assert.equal(result.logs[0].args.coinType, 0);
		console.log(result.logs[0].args.price);
	})
}