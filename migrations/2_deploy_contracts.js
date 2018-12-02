var ItemShopToken = artifacts.require('./ItemShopToken.sol')

module.exports = function (deployer) {
  deployer.deploy(ItemShopToken)
}
