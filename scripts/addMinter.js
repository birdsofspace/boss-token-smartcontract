const { ethers, upgrades } = require("hardhat");
require('dotenv').config();

async function main() {
  const sample = await ethers.getContractFactory("BOSSToken");
  console.log("Mint BOSS...");
  const contract = sample.attach(
    process.env["CONTRACT_ADDRESS"]
  );

  console.log(await contract.mint(process.env.DEPLOYER_ADDRESS, ethers.utils.parseUnits("1000", "ether")));
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
