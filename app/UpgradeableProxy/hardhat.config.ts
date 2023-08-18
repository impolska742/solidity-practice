import "@openzeppelin/hardhat-upgrades"
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.2",
  networks: {
    mumbai: {
      url: `${process.env.MUMBAI_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
      chainId: 80001,
    },
    goerli: {
      url: `${process.env.GOERLI_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
      chainId: 5,
    },
    mainnet: {
      url: `${process.env.MAINNET_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    matic: {
      url: `${process.env.MATIC_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    arbitrumGoerli: {
      url: `${process.env.ARBITRUM_GOERLI_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    arbitrumOne: {
      url: `${process.env.ARBITRUM_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: `${process.env.ETHERSCAN_API_KEY}`,
      goerli: `${process.env.ETHERSCAN_API_KEY}`,
      polygonMumbai: `${process.env.POLYGONSCAN_API_KEY}`,
      polygon: `${process.env.POLYGONSCAN_API_KEY}`,
      arbitrumOne: `${process.env.ARBISCAN_API_KEY}`,
      arbitrumGoerli: `${process.env.ARBISCAN_API_KEY}`,
    },
  },
};

export default config;
