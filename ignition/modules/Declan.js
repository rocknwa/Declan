const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const DeployDeclan = buildModule("Declan", (m) => {
  const declan = m.contract("Declan");
  return { declan };
});

module.exports = DeployDeclan;
