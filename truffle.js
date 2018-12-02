const HDWalletProvider = require("truffle-hdwallet-provider");
MNENOMIC = "glass toilet situate text shed evolve witness coil help basket abuse box"
INFURA_API_KEY = "099d1bf4a64847f1a9ed28288d6ae43f"

module.exports = {
  networks: {
    development: {
      host: '52.91.71.107',
      port: 8545,
      network_id: '*' // Match any network id
    },
    ropsten: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://ropsten.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 3,
      gas: 470000,
      gasPrice: 21
    },
    kovan: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://kovan.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 42
    },
    rinkeby: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://rinkeby.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 4
    },
    // main ethereum network(mainnet)
    main: {
      provider: () => new HDWalletProvider( MNENOMIC, "https://mainnet.infura.io/v3/" +  INFURA_API_KEY),
      network_id: 1,
      gas: 470000,
      gasPrice: 21
    }
  }
}
