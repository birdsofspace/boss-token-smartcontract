const { ethers, upgrades } = require("hardhat");

async function main() {
  //   const gas = await ethers.provider.getGasPrice();
  const sample = await ethers.getContractFactory("BOSSToken");
  console.log("Deploying BOSS...");
  const v1contract = await upgrades.deployProxy(sample,[
    "0x5b0AB9AFe2e5a6eA801fe93BF65478d5A2f8e903"
  ]);
  await v1contract.deployed();
  console.log("Contract deployed to:", await v1contract.address);
  const contract = sample.attach(
    await v1contract.address
  );
  console.log(await contract.setTeamAddress("0x8FAcCc9091E866052aE9462c152234cc7e61C946"))
  console.log(await contract.setMarketingAddress("0x8FAcCc9091E866052aE9462c152234cc7e61C946"))
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
