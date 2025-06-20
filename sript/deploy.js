const { ethers } = require("hardhat");

async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy the LendingProtocol contract
  const LendingProtocol = await ethers.getContractFactory("LendingProtocol");
  const lendingProtocol = await LendingProtocol.deploy();

  await lendingProtocol.deployed();

  console.log("LendingProtocol deployed to:", lendingProtocol.address);
  console.log("Transaction hash:", lendingProtocol.deployTransaction.hash);
  
  // Wait for a few block confirmations
  console.log("Waiting for block confirmations...");
  await lendingProtocol.deployTransaction.wait(5);
  
  console.log("Contract deployed successfully on Core Blockchain!");
  console.log("Contract Address:", lendingProtocol.address);
  console.log("Network: Core Testnet");
  console.log("Chain ID: 1114");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
