const { ethers, upgrades } = require("hardhat");
require('dotenv').config();

async function main() {
  const sample = await ethers.getContractFactory("BOSSToken");
  console.log("Disabled swap fee...");
  const contract = sample.attach(
    process.env["CONTRACT_ADDRESS"]
  );

  console.log(await contract.toggleSwapFee(false));
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
