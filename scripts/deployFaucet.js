const hre = require("hardhat");
require('dotenv').config();

async function main() {
  const Faucet = await hre.ethers.getContractFactory("Faucet");
  const particlestoken = await Faucet.deploy(process.env["CONTRACT_ADDRESS"]); //change particles token contract address

  const address = await particlestoken.getAddress();

 console.log(`Faucet Contract Address: ${address}`,"\n");
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});