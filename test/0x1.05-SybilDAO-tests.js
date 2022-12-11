const { expect } = require('chai');
const { ethers } = require('hardhat');
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe('SybilDAO', function () {
  let syb, treasury;

  before(async () => {
    [owner,user1] = await ethers.getSigners();
    const networkData = await ethers.provider.getNetwork();
    await hre.run('compile');
    // Deploy usEthDao.sol
    const sybilDaoContract = await ethers.getContractFactory('SybilDAO');
    syb = await sybilDaoContract.deploy();
    const treasuryAddress = await syb.treasury();
    treasury = await ethers.getContractAt('SybilTreasury', treasuryAddress);
  });

  it('SybilDAO SYB token balance check', async function () {
    const tx1 = await syb.balanceOf(owner.address);
    expect(tx1).to.be.gt(0);
  });
  
  it('Check treasury is deployed correctly', async function () {
    const multisigWallet = await treasury.multisig();
    expect(multisigWallet).to.be.eq(owner.address);
  });

  it('Check treasury has correct balance of SYB', async function () {
    const bal = await syb.balanceOf(treasury.address);
    const expected = ethers.utils.parseEther('50000000');
    expect(bal).to.be.eq(expected);
  });

  it('Check treasury staking works', async function () {
    const tx = await syb.treasurystake();
    await tx.wait();
    const staked = await syb.staked(treasury.address);
    const expected = ethers.utils.parseEther('50000000');
    expect(staked).to.be.eq(expected);
    const bal = await syb.balanceOf(treasury.address);
    expect(bal).to.be.eq(0);
  });

  it('Check owner can set merkle root', async function () {
    const tx = await syb.updateMerkleRoot(`0x610e4805fea81e5b7d991c4a298ec475dae1ff4cbb45396b3de0212b087dc94b`);
    await tx.wait();
    const root = await syb.merkleRoot();
    expect(root).to.be.eq(`0x610e4805fea81e5b7d991c4a298ec475dae1ff4cbb45396b3de0212b087dc94b`);
  });

  it('Check user1 can verify', async function () {
    const authCode = `0x4d9e1e97cf39756af661e5259db9fd69b8558a7c08447b108a33821a9ccf0a0d`;
    const proof = [`0xda4e29f266b4ab93e6c307851d679d383cdb87705e6a40ee28b5898f2ba523ec`,`0xf0c9a8e2e0cecd11cbbfd47628048fcde2dbfce3e43959481efac58e7331c4aa`];
    const fee = ethers.utils.parseEther('0.003');
    const tx = await syb.connect(user1).verify(user1.address,authCode,proof, {value: fee});
    await tx.wait();
    const check = await syb.connect(owner).check(user1.address);
    expect(check).to.be.eq(true);
  });

  it('Check fee distribution to SYB holders', async function () {
    const rewards = await syb.stakingRewardsPending(treasury.address);
    const fee = ethers.utils.parseEther('0.003');
    expect(rewards).to.be.eq(fee);
    const contractBalance = await ethers.provider.getBalance(syb.address);
    expect(contractBalance).to.be.eq(fee);
  });

  it('Distribute vested tokens', async function () {
    const claimable1 = await syb.vestedClaimable();
    expect(claimable1).to.be.eq(0);
    const amount = ethers.utils.parseEther('5000000');
    await expect(syb.distributeVestedTokens(user1.address, amount))
      .to.be.revertedWith('No distribution before cliff');
    const unlockTime = (await time.latest()) + 4e7;
    await time.increaseTo(unlockTime);
    const claimable2 = await syb.vestedClaimable();
    expect(claimable2).to.be.gt(0);
    const tx = await syb.distributeVestedTokens(user1.address, amount);
    await tx.wait();
    const bal = await syb.balanceOf(user1.address);
    expect(bal).to.be.eq(amount);
  });

  it('User1 stakes tokens', async function () {
    const amount = ethers.utils.parseEther('5000000');
    const tx = await syb.connect(user1).stake(amount);
    await tx.wait();
    const bal = await syb.staked(user1.address);
    expect(bal).to.be.eq(amount);
  });

  it('Send ETH to contract and check distribution to holders', async function () {
    const amount = ethers.utils.parseEther('1');
    await owner.sendTransaction({ to: syb.address, value: amount });
    const rewards = await syb.stakingRewardsPending(user1.address);
    const expectedMax = amount.div('9');
    const expectedMin = amount.div('11');
    expect(rewards).to.be.lt(expectedMax);
    expect(rewards).to.be.gt(expectedMin);
  });

  it('User1 claimAndRestake tokens', async function () {
    const startBalance = await ethers.provider.getBalance(user1.address);
    const amount = ethers.utils.parseEther('5000000');
    await expect(syb.connect(user1).claimAndRestake())
      .to.be.revertedWith('Tokens are locked for staking period');
    const unlockTime = (await time.latest()) + 4e7;
    await time.increaseTo(unlockTime);
    const tx = await syb.connect(user1).claimAndRestake();
    await tx.wait();
    const staked = await syb.staked(user1.address);
    expect(staked).to.be.eq(amount);
    const endBalance = await ethers.provider.getBalance(user1.address);
    expect(endBalance).to.be.gt(startBalance);
  });

  it('User1 unstakes tokens', async function () {
    const startBalance = await ethers.provider.getBalance(user1.address);
    const amount = ethers.utils.parseEther('5000000');
    await expect(syb.connect(user1).unstake(amount))
      .to.be.revertedWith('Tokens are locked for staking period');
    const unlockTime = (await time.latest()) + 4e7;
    await time.increaseTo(unlockTime);
    const tx = await syb.connect(user1).unstake(amount);
    await tx.wait();
    const staked = await syb.staked(user1.address);
    expect(staked).to.be.eq(0);
    const endBalance = await ethers.provider.getBalance(user1.address);
    expect(endBalance).to.be.gt(startBalance);
  });

  it('Treasury claims staked funds', async function () {
    const startBalance = await ethers.provider.getBalance(owner.address);
    const tx = await treasury.connect(owner).claim();
    await tx.wait();
    const staked = await syb.staked(treasury.address);
    expect(staked).to.be.gt(0);
    const endBalance = await ethers.provider.getBalance(owner.address);
    expect(endBalance).to.be.gt(startBalance);
  });

  it('Buy SYB tokens', async function () {
    const startBalance = await syb.balanceOf(user1.address);
    const tx = await syb.connect(user1).buyTokens({value: 1000000000});
    await tx.wait();
    const endBalance = await syb.balanceOf(user1.address);
    expect(endBalance).to.be.gt(startBalance);
  });

  it('Bulk verify users', async function () {
    const userGroup = [
      `0xdD870fA1b7C4700F2BD7f44238821C26f7392148`,
      `0x583031D1113aD414F02576BD6afaBfb302140225`,
      `0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB`,
    ];
    const tx = await syb.connect(owner).bulkVerify(userGroup);
    await tx.wait();
    for (const user of userGroup) {
      const check = await syb.check(user);
      expect(check).to.be.eq(true);
    }
    const checkFalse = await syb.check(`0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C`);
    expect(checkFalse).to.be.eq(false);
  });

  it('Update system vars', async function () {
    const tx = await syb.connect(owner).updateVariables(100,200);
    await tx.wait();
    const fee = await syb.fee();
    expect(fee).to.be.eq(100);
    const publicSalePrice = await syb.publicSalePrice();
    expect(publicSalePrice).to.be.eq(200);
  });
  
});
