// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    await hre.run('compile')

    // We get the contract to deploy
    const zkDAODBIToken = await hre.ethers.getContractFactory("DBIToken")
    const DBIToken = await zkDAODBIToken.deploy()

    await DBIToken.deployed()

    console.log("DBI Token deployed to:", DBIToken.address)

    const DBIPaymentToken = await hre.ethers.getContractFactory("DBIPayment")
    const DBIPayment = await DBIPaymentToken.deploy('0x985458E523dB3d53125813eD68c274899e9DfAb4', DBIToken.address, 150)

    await DBIPayment.deployed()

    console.log("DBI Token deployed to:", DBIToken.address)
    console.log("DBI Payment deployed to:", DBIPayment.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
