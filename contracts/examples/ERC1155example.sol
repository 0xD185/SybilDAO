// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

interface ISybil {
    function check(address) external view returns (bool);
}

contract ERC1155example is ERC1155 {
    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    uint256 public tokenId;

    mapping(address => bool) public claimed;

    constructor() ERC1155("") {}

    function mint(address account, uint256 amount, bytes memory data) public {
        require(ISybil(sybil).check(msg.sender), "Visit: https://sybildao.com/#verify");
        require(tokenId < 1000, "All 1000 tokens have been minted");
        require(claimed[msg.sender] == false, "Already claimed");
        claimed[msg.sender] = true;
        tokenId = tokenId + 1;
        _mint(account, tokenId, amount, data);
    }
}
