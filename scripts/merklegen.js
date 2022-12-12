require("dotenv").config();
const {MerkleTree} = require("merkletreejs");
const keccak256 = require("keccak256");
const fs = require('fs');
 
const maxProofs = 5000;
const salt = process.env.SALT; // .env file
const authCodes = [];
const jsonOutput = [];
let csvOutput = '';

for (let i = 0; i < maxProofs; i++) {
    const bytes32 = keccak256(salt+i);
    authCodes.push(bytes32);
}

merkleTree = new MerkleTree(authCodes, keccak256, {sortPairs: true});
const rootHash = merkleTree.getRoot().toString('hex');
console.log(`Root: 0x${rootHash}`);
console.log(`\n`);

authCodes.forEach((authCode)=> {
    const proof = merkleTree.getHexProof(authCode);
    jsonOutput.push([`0x${authCode.toString('hex')}`,`[${proof}]`]);
    csvOutput = csvOutput + `["0x${authCode.toString('hex')}","${proof.join('","')}"]`+"\n";
    /*
    console.log(`Authentication Code: 0x${authCode.toString('hex')}`);
    console.log(`Merkle Proof: ${proof}`);
    console.log(`\n`);
    console.log(`0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0x${authCode.toString('hex')},[${proof}]`)
    console.log(`----------------------`);
    */
});

console.log(`\n`);
console.log(`Root: 0x${rootHash}`);

fs.writeFileSync("./data/authcodes.json", JSON.stringify(jsonOutput));
fs.writeFileSync(`./data/authcodes.csv`, csvOutput);
