const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("DBIToken", function () {
    let dbitoken
    let dbiPayment
    let mockToken

    before(async () => {
        const DBIToken = await ethers.getContractFactory("DBIToken")
        dbitoken = await DBIToken.deploy()
        await dbitoken.deployed()

        const signers = await ethers.getSigners()
        owner = signers[0]
        multisig = signers[1]
        recipient = signers[2]

        const MockERC20Token = await ethers.getContractFactory("ERC20Mock")
        mockToken = await MockERC20Token.deploy('USD Coin', 'USDC', owner.address, 1000000000)
        await mockToken.deployed()

        const DBIPaymentToken = await hre.ethers.getContractFactory("DBIPayment")
        dbiPayment = await DBIPaymentToken.deploy(mockToken.address, dbitoken.address, 250)
        await dbiPayment.deployed()

        console.log("DBI Token deployed to:", dbitoken.address)
        console.log("Mock Token deployed to:", mockToken.address)
        console.log("DBI Payment deployed to:", dbiPayment.address)
    })

    it("Should mint and transfer the DBI Token to an account", async function () {
        const balance = await dbitoken.balanceOf(multisig.address, 1)

        expect(balance).to.equal(10000)
    })

    it("Should transfer USDC to DBI Payment and confirm receipt", async function () {
        const initialBalance = await dbiPayment.getTokenBalance()

        const receipt = await mockToken.transfer(dbiPayment.address, 10000000)
        receipt.wait()

        const finalBalance = await dbiPayment.getTokenBalance()

        expect(initialBalance).to.equal(0)
        expect(finalBalance).to.equal(10000000)
    })

    it("Should transfer DBI Token from the Multisig wallet to another wallet and confirm receipt", async function () {
        const initialBalance = await dbitoken.balanceOf(recipient.address, 1)

        const receipt = await dbitoken.connect(multisig).safeTransferFrom(multisig.address, recipient.address, 1, 10, [])
        receipt.wait()

        const finalBalance = await dbitoken.balanceOf(recipient.address, 1)

        expect(initialBalance).to.equal(0)
        expect(finalBalance).to.equal(10)
    })

    it("Should withdraw USDC from the DBI Payment contract from a valid recipient", async function () {
        const initialBalance = await mockToken.balanceOf(recipient.address)

        const receipt = await dbiPayment.connect(recipient).withdraw()
        receipt.wait()

        const finalBalance = await mockToken.balanceOf(recipient.address)

        expect(initialBalance).to.equal(0)
        expect(finalBalance).to.equal(2500)
    })

    it("Should revert with error code when a recipient try to withdraw USDC again from the DBI Payment contract", async function () {
        const withdraw = dbiPayment.connect(recipient).withdraw()
        await expect(withdraw).to.be.revertedWith('You have already withdrawn from this cycle')
    })
})
