import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_URL,
      accounts: [`${process.env.PRIVATE_KEY}`],
      chainId: 11155111
    },
    goerli: {
      url: `${process.env.GOERLI_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
      chainId: 5,
    },
  }
};

export default config;
