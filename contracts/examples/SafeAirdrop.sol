// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
    SafeAirdrop - An ERC20 token which lets verified users
    claim 100 tokens each one time
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ISybil {
    function check(address) external view returns (bool);
}

contract SafeAirdrop is ERC20 {
    mapping (address => bool) public claimed;

    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    constructor() ERC20("Safe Airdrop Token", "SAT") {
    }

    function airdrop() public {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        require(claimed[msg.sender] == false, "Already claimed");
        claimed[msg.sender] = true;
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}
