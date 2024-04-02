const { ethers, upgrades } = require("hardhat");
require('dotenv').config();

async function main() {
  const sample = await ethers.getContractFactory("BOSSToken");
  console.log("Adding a minter...");
  const contract = sample.attach(
    process.env["CONTRACT_ADDRESS"]
  );

  console.log(await contract.createRole("0xf0887ba65ee2024ea881d91b74c2450ef19e1557f03bed3ea9f16b037cbe2dc9", process.env.DEPLOYER_ADDRESS));
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
