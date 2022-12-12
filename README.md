# SybilDAO
## Zero Knowledge Protocol To Defend DeFi From Sybil Attacks

Verify your address at https://sybildao.com/#verify

### Developer Examples

For developers there are some integration examples at:
https://github.com/0xD185/SybilDAO/tree/main/contracts/examples

- ERC20 Airdrops
- NFT Mints
- Simple Checks

### Explainer

SybilDAO solves the problem of mass sybil attacks in DeFi in a streamlined way that is simple for blockchain developers to implement and has a great UX for end users.

A 3rd party developer can link off to https://sybildao.com/#verify from their dApp and then check to see if the users has verified their wallet address with a simple look up in solidity.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
 
interface ISybil {
    function check(address) external view returns (bool);
}
 
contract SybilDeveloperExample {
    address constant sybil = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
 
    function test(address _address) external view returns (bool) {
        require(ISybil(sybil).check(_address),"Visit: https://sybildao.com/#verify");
        return true;
    }
}

```
### Bot Protection

The system is designed to prevent mass bot attacks which plague airdrops and NFT mints. Here are some of the protections implimented:-

- Cloudflare BOT protection
- VPN/ToR/Botnet blacklists
- Client side analysis
- Transactional cost + gas fee
- IP Restrictions
- hCaptcha integration
- ML Risk Analysis (TBC)

Once the frontend challenge has been completed an API provides a one time authorization code to the clients web browser. This authorization code along with a cryptographic proof enables the verification within the SybilDAO smart contract.

### Partnerships

3rd party DeFi protocols can look up on-chain verified addresses from within their smart contract and get a true/false boolean response.

Whitelisted addresses are immutable and verifiable from any smart contract, these can be used across various DeFi partner promotions and campaigns.

Partnering DeFi protocols can benefit from cross-promtions with SybilDAO. Contact us via DM or Discord to discuss further:
https://sybildao.com/#socials
