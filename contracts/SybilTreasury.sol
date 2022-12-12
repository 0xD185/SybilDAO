// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./SybilDAO.sol";

contract SybilTreasury {
    address payable sybilDAO;
    address public multisig;

    constructor(address _multisig) {
        sybilDAO = payable(msg.sender);
        multisig = _multisig;
    }

    function stake(uint _amount) external {
        require(msg.sender == sybilDAO, "SybilDAO only");
        SybilDAO(sybilDAO).stake(_amount);
    }

    function claim() external {
        require(msg.sender == multisig, "Multisig only");
        SybilDAO(sybilDAO).claimAndRestake();
        payable(multisig).transfer(address(this).balance);
    }

    receive() external payable  {
    }
}
