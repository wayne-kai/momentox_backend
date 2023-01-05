require('dotenv').config({path: '../.env'});

const MomentoX = artifacts.require("MomentoX");

const chai = require("./chaisetup.js");
const BN = web3.utils.BN;
const expect = chai.expect;
const truffleAssert = require('truffle-assertions');

contract("MomentoX", async function(accounts) {
    const [ contractOwner, nftMinter, nftReceiver ] = accounts;

    it("It's possible to mint", async () => {
        //Tests
        const momentoxInstance = await MomentoX.deployed();
        let txResult = await momentoxInstance.safeMint(nftMinter,"spacebear_1.json");

        truffleAssert.eventEmitted(txResult, 'Transfer', {from: '0x0000000000000000000000000000000000000000', to: nftMinter, tokenId: web3.utils.toBN("0")});

        assert.equal(await momentoxInstance.ownerOf(0), nftMinter, "Owner of Token is the wrong address");
    });
});