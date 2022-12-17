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
    A simple way to use SybilDAO across multiple functions
    with a onlyVerified modifier
*/

interface ISybil {
    function check(address) external view returns (bool);
}

contract Modifier {
    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    
    modifier onlyVerified() {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        _;
    }

    function mint() public onlyVerified {
        // Only verified users can mint
    }
}
