const { time } = require("@openzeppelin/test-helpers");
// const assert = require("assert");
// const BN = require("bn.js");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
// const { it } = require("ethers/wordlists");

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const cUSDC = "0x39AA39c021dfbaE8faC545936693aC917d5E7563";
const USDC_WHALE= "0xd3f4D3461E9280B73f984E053c72f649EF7b0f1F";

const ERC20 = artifacts.require("Erc20");
const CErc20 = artifacts.require("CErc20");
const Bankless = artifacts.require("Bankless");

contract("Bankless", () => {
    let token;
    let cToken;
    let testCompound;

beforeEach(async () => {
    testCompound = await Bankless.new();
    token = await ERC20.at(USDC);
    cToken = await CErc20.at(cUSDC);
    })

it("should deposit and withdraw USDC with interest", async () => {
    const initBal = await token.balanceOf(USDC_WHALE);
    console.log(`balance: ${initBal}`);
    await token.approve(testCompound.address, 1234567890, { from: USDC_WHALE });
    tx = await testCompound.deposit(1234567890, { from: USDC_WHALE });
    const bal = await token.balanceOf(USDC_WHALE);
    console.log(`balance: ${bal}`);
    // advance 100 blocks to collect interest
    const block = await web3.eth.getBlockNumber();
    await time.advanceBlockTo(block + 300);
    await testCompound.withdraw();
    const bal2 = await token.balanceOf(USDC_WHALE);
    console.log(`balance: ${bal2}`);
});

})



