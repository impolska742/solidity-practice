import { ethers } from "hardhat";

async function main() {
  // Get the contract to deploy.
  const Lottery = await ethers.getContractFactory("Lottery");

  // Deploy contract.
            
  const lottery = await Lottery.deploy(ethers.utils.parseEther("0.1"), 2681);
  await lottery.deployed();

  console.log("Lottery is deployed to ", lottery.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
