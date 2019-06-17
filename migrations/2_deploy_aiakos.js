var aiakos = artifacts.require("Aiakos");
module.exports = function(deployer) {
   deployer.deploy(aiakos, 2);
};
