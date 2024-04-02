const { ethers, upgrades } = require("hardhat");
require('dotenv').config();
const fs = require('fs');

function updateContractAddress(newContractAddress) {
  // Read the contents of the file
  fs.readFile('.env', 'utf8', (err, data) => {
    if (err) {
      console.error('Error reading file:', err);
      return;
    }

    // Update the CONTRACT_ADDRESS value
    const updatedData = data.replace(/^CONTRACT_ADDRESS=.*/m, `CONTRACT_ADDRESS=${newContractAddress}`);

    // Write the updated data back to the file
    fs.writeFile('.env', updatedData, 'utf8', (err) => {
      if (err) {
        console.error('Error writing file:', err);
        return;
      }
      console.log('CONTRACT_ADDRESS updated successfully.');
    });
  });
}

async function main() {
  const sample = await ethers.getContractFactory("BOSSToken");
  console.log("Deploying BOSS...");
  const v1contract = await upgrades.deployProxy(sample, [
    process.env.SWAP_ROUTER
  ], {kind:'uups', initializer: "initialize" });
  await v1contract.deployed();

  
  let caddress = await v1contract.address;
  updateContractAddress(caddress)
  console.log("Contract deployed to:", await v1contract.address);
  console.log("Logic Contract implementation address is : ",await upgrades.erc1967.getImplementationAddress(v1contract.address));
  const contract = sample.attach(
    caddress
  );

  console.log(await contract.setTeamAddress(process.env.TEAM_ADDRESS));
  console.log(await contract.setMarketingAddress(process.env.MARKETING_ADDRESS));
  console.log(await contract.createRole("0xf0887ba65ee2024ea881d91b74c2450ef19e1557f03bed3ea9f16b037cbe2dc9", process.env.DEPLOYER_ADDRESS));
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
