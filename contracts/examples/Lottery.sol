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
    A lottery contract where the issuer sends ETH to the contract
    then verified users can claim one ticket each. The setNextBlock
    function is called to get some random data from a future blockHash
    Then we can call pickWinners which will payout ETH to the winners

    User can set the number of prizes in uint prizes = 5;
    If the contract held 1 ETH this would pay out:
    1st prize = 0.5 ETH
    2nd prize = 0.25 ETH
    3rd prize = 0.125 ETH
    4th prize = 0.0625 ETH
    5th prize = 0.0625 ETH (same to clear contract balance)

    Could also be used with ERC20 tokens/stablecoins using:
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    IERC(tokenAddress).transfer(winners[i], amount);
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface ISybil {
    function check(address) external view returns (bool);
}

contract Lottery is Ownable {
    address constant sybil = 0x7927BEa1eA84614DCeAECa1710cea8a7DeAa1d25;
    address[] public participants;
    mapping(address => bool) oneTicketEach;
    address[] public winners;
    uint prizes = 5; // Set the number of prizes
    uint nextBlock;

    function ticket() external {
        require(ISybil(sybil).check(msg.sender),"Visit: https://sybildao.com/#verify");
        require(oneTicketEach[msg.sender] == false, "Can only claim one ticket");
        require(nextBlock == 0, "Lottery is closed");
        oneTicketEach[msg.sender] = true;
        participants.push(msg.sender);
    }

    function setNextBlock() external onlyOwner {
        require(nextBlock == 0, "Can only be run once");
        nextBlock = block.number + 1;
    }

    function pickWinners() public onlyOwner payable {
        require(participants.length > prizes, "Need more participants");
        uint random = uint(keccak256(abi.encode(blockhash(nextBlock),  participants)));
        uint randomFactor = random % participants.length;
        for (uint i = 0; i < prizes; i++) {
            uint winnerIndex = randomFactor + i;
            // If winnerIndex is greater than array length go back to zero
            if (winnerIndex >= participants.length) winnerIndex = winnerIndex - participants.length;
            winners.push(participants[winnerIndex]);
            console.log(winners[i]);
            if (i < prizes - 1) {
                payable(winners[i]).transfer(address(this).balance / 2);
            } else {
                // Final prize takes same as previous to clear balance
                payable (winners[i]).transfer(address(this).balance);
            }
        }
    }

    receive() external payable  {
    }

}
