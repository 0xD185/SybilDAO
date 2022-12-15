async function main() {
    const MyNFT = await ethers.getContractFactory("ERC1155example")
    const myNFT = await MyNFT.deploy()
    const txHash = myNFT.deployTransaction.hash
    const txReceipt = await ethers.provider.waitForTransaction(txHash)
    console.log("Contract deployed to address:", txReceipt.contractAddress)
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        process.exit(1)
    })
