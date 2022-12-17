// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*━━┓     ┏┓    ┏┓ ┏━━━┓┏━━━┓┏━━━┓
┃┏━┓┃     ┃┃    ┃┃ ┗┓┏┓┃┃┏━┓┃┃┏━┓┃
┃┗━━┓┏┓ ┏┓┃┗━┓┏┓┃┃  ┃┃┃┃┃┃ ┃┃┃┃ ┃┃
┗━━┓┃┃┃ ┃┃┃┏┓┃┣┫┃┃  ┃┃┃┃┃┗━┛┃┃┃ ┃┃
┃┗━┛┃┃┗━┛┃┃┗┛┃┃┃┃┗┓┏┛┗┛┃┃┏━┓┃┃┗━┛┃
┗━━━┛┗━┓┏┛┗━━┛┗┛┗━┛┗━━━┛┗┛ ┗┛┗━━━┛
━━━━ ┏━┛┃ ━━━━ SybilDAO.com ━━━━━━
━━━━ ┗━━┛ ━━━━ Version: 0.2 ━━━━*/

/*
    SybilMintNFT - An ERC721 NFT which allows verified users
    to mint one NFT each
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

interface ISybil {
    function check(address) external view returns (bool);
}

contract SybilMintNFT is ERC721 {
    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    uint256 public tokenId;
    mapping (address => bool) public claimed;

    constructor() ERC721("A SAFE MINT NFT", "NFT") {
    }

    function tokenURI(uint256) override public pure returns (string memory) {
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "SybilDAO", "description": "An example NFT from SybilDAO", "image": "https://sybildao.com/img/icon.png"}'))));
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function mint() public {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        require(tokenId < 1000, "All 1000 tokens have been minted");
        require(balanceOf(msg.sender) == 0, "You already have an NFT");
        require(claimed[msg.sender] == false, "Already claimed");
        claimed[msg.sender] = true;
        _safeMint(msg.sender, tokenId);
        tokenId = tokenId + 1;
    }
}
