// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const CoreWallet = await ethers.getContractFactory("CoreWallet");
  const coreWallet = await CoreWallet.deploy();
  await coreWallet.deployed();

  console.log("CoreWallet address is: ", coreWallet.address);

  const Factory = await ethers.getContractFactory("factory");
  const factory = await Factory.deploy(`${coreWallet.address}`);
  await factory.deployed();

  console.log("Factory contract is: ", factory.address);

  const Wallet = await ethers.getContractFactory("wallet");
  const wallet = await Wallet.deploy(`${factory.address}`);
  await wallet.deployed();

  console.log("Main user wallet address is: ", wallet.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
