const { ethers } = require("hardhat");
require('dotenv').config();

async function main() {
    const Token = await ethers.getContractFactory("BOSSToken");
    console.log("Update BOSS...");
    const token = Token.attach(
        process.env["CONTRACT_ADDRESS"]
    );


    let tmpRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    let mainRouter = "0x5b0AB9AFe2e5a6eA801fe93BF65478d5A2f8e903";
    console.log(await token.updateRouter(tmpRouter));
    console.log(await token.updateRouter(mainRouter));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
