require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config();

module.exports ={
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  networks: {
    'lisk': {
      url: 'https://rpc.sepolia-api.lisk.com',
      accounts: [process.env.WALLET_KEY],
      gasPrice: 1000000000,
    },
  },
}

//npx hardhat ignition deploy ./ignition/modules/Lock.js --network localhost


