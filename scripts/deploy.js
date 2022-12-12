const { ethers } = require('hardhat');

const main = async () => {
    [owner,user1] = await ethers.getSigners();
    await hre.run('compile');
    const sybilDaoContract = await ethers.getContractFactory('SybilDAO');
    syb = await sybilDaoContract.deploy();
    const treasuryAddress = await syb.treasury();
    treasury = await ethers.getContractAt('SybilTreasury', treasuryAddress);
    console.log(`SybilDAO: ${syb.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
