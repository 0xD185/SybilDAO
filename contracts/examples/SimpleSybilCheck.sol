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