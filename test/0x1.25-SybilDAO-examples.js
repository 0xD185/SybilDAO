const { expect } = require("chai")
const { ethers } = require("hardhat")
const { time } = require("@nomicfoundation/hardhat-network-helpers")

describe("SybilDAO", function () {
    let syb, treasury, erc1155

    before(async () => {
        ;[owner, user1] = await ethers.getSigners()
        const networkData = await ethers.provider.getNetwork()
        const sybilDaoContract = await ethers.getContractFactory("SybilDAO")
        syb = await sybilDaoContract.deploy()
        const treasuryAddress = await syb.treasury()
        treasury = await ethers.getContractAt("SybilTreasury", treasuryAddress)
        const erc1155Contract = await ethers.getContractFactory("ERC1155example")
        erc1155 = await erc1155Contract.deploy()
    })

    it("SybilDAO SYB token balance check", async function () {
        const tx1 = await syb.balanceOf(owner.address)
        expect(tx1).to.be.gt(0)
    })

    it("Check treasury is deployed correctly", async function () {
        const multisigWallet = await treasury.multisig()
        expect(multisigWallet).to.be.eq(owner.address)
    })

    it("Check treasury has correct balance of SYB", async function () {
        const bal = await syb.balanceOf(treasury.address)
        const expected = ethers.utils.parseEther("50000000")
        expect(bal).to.be.eq(expected)
    })

    it("Check treasury staking works", async function () {
        const tx = await syb.treasurystake()
        await tx.wait()
        const staked = await syb.staked(treasury.address)
        const expected = ethers.utils.parseEther("50000000")
        expect(staked).to.be.eq(expected)
        const bal = await syb.balanceOf(treasury.address)
        expect(bal).to.be.eq(0)
    })

    it("Check owner can set merkle root", async function () {
        const tx = await syb.updateMerkleRoot(`0x610e4805fea81e5b7d991c4a298ec475dae1ff4cbb45396b3de0212b087dc94b`)
        await tx.wait()
        const root = await syb.merkleRoot()
        expect(root).to.be.eq(`0x610e4805fea81e5b7d991c4a298ec475dae1ff4cbb45396b3de0212b087dc94b`)
    })

    it("Check user1 can verify", async function () {
        const authCode = `0x4d9e1e97cf39756af661e5259db9fd69b8558a7c08447b108a33821a9ccf0a0d`
        const proof = [
            `0xda4e29f266b4ab93e6c307851d679d383cdb87705e6a40ee28b5898f2ba523ec`,
            `0xf0c9a8e2e0cecd11cbbfd47628048fcde2dbfce3e43959481efac58e7331c4aa`,
        ]
        const fee = ethers.utils.parseEther("0.003")
        const tx = await syb.connect(user1).verify(user1.address, authCode, proof, { value: fee })
        await tx.wait()
        const check = await syb.connect(owner).check(user1.address)
        expect(check).to.be.eq(true)
    })

    it("Check the owner has a zero starting balance", async function () {
        const bal = await erc1155.balanceOf(owner.address, 0)
        const expected = ethers.utils.parseEther("0")
        expect(bal).to.be.eq(expected)
    })

    it("Check if the user has claimed", async function () {
        const claimed = await erc1155.claimed(owner.address)
        expect(claimed).to.be.eq(false)
    })
})
