const { ethers, upgrades } = require("hardhat");

const BOX_ADDRESS = '0xfF9D1f0228f575FfE9Fc79ce107e5cB5a3260481'

async function main() {
  const BoxV2 = await ethers.getContractFactory("BoxV2");
  const box = await upgrades.upgradeProxy(BOX_ADDRESS, BoxV2);
  console.log("Box upgraded");
}

main();