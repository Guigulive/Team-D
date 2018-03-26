//var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var SafeMath = artifacts.require("./SafeMath.sol")
var Payroll = artifacts.require("./Payroll.sol");

module.exports = function(deployer) {
  //deployer.deploy(SimpleStorage);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Payroll);
  deployer.deploy(Payroll);
};
