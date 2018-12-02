require('babel-register')

module.exports = {
  networks: {
    ganache: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // match bất kỳ network nào
      gas: 470000
    }
  }
}