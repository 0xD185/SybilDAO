// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISybil {
    function check(address) external view returns (bool);
}

/*
    SybilSimpleCheck - A standard check to see require an address
    is authorised before proceeding
*/

contract SybilSimpleCheck {
    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
  
    function test(address _address) external view returns (bool) {
        require(ISybil(sybil).check(_address),"Visit: https://sybildao.com/#verify");
        return true;
    }
}

/*
    SybilMintNFT - An ERC721 NFT which allows verified users
    to mint one NFT each
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract SybilMintNFT is ERC721 {
    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    uint256 public tokenId;

    constructor() ERC721("A SAFE MINT NFT", "NFT") {
    }

    function tokenURI(uint256) override public pure returns (string memory) {
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "SybilDAO", "description": "An example NFT from SybilDAO", "image": "https://sybildao.com/icon.png"}'))));
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function mint() public {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        require(tokenId < 1000, "All 1000 tokens have been minted");
        require(balanceOf(msg.sender) == 0, "You already have an NFT");
        _safeMint(msg.sender, tokenId);
        tokenId = tokenId + 1;
    }
}


/*
    SafeAirdrop - An ERC20 token which lets verified users
    claim 100 tokens each one time
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SafeAirdrop is ERC20 {
    mapping (address => bool) public claimed;

    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    constructor() ERC20("Safe Airdrop Token", "SAT") {
    }
    
    function airdrop() public {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        require(claimed[msg.sender] == false, "Already claimed");
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}