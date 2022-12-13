// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
    SybAirdrop - Is the contract we used to airdrop Goerli SYB to users
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ISybil is IERC20 {
    function check(address) external view returns (bool);
}

contract SybAirdrop is Ownable {
    mapping (address => bool) public claimed;

    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;

    function airdrop() external {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        require(claimed[msg.sender] == false, "Already claimed");
        claimed[msg.sender] = true;
        ISybil(sybil).transfer(msg.sender, 100 * 1e18);
    }

    function checkEligible(address _user) external view returns(bool) {
        bool eligible = true;
        if (ISybil(sybil).check(_user) == false) eligible = false;
        if (claimed[_user] == true) eligible = false;
        return eligible;
    }

    function reclaim() external onlyOwner {
        uint256 balance = IERC20(sybil).balanceOf(address(this));
        IERC20(sybil).transfer(msg.sender, balance);
    }
}
