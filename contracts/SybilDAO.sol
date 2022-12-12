// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./SybilTreasury.sol";

contract SybilDAO is ERC20, Ownable {

    mapping(address => bool) public check;
    mapping(bytes32 => bool) public authCodesUsed;
    bytes32 public merkleRoot = 0x610e4805fea81e5b7d991c4a298ec475dae1ff4cbb45396b3de0212b087dc94b;
    uint public fee = 3e15; // 0.003 ETH ~ $5
    uint public publicSalePrice = 8e13; // ~ $0.1
    uint vestedClaimed;
    uint publicSale;
    uint totalStaked;
    uint stakingPeriod = 7884000; // 3 months
    mapping(address => uint) public staked;
    mapping(address => uint) public lastStakeTime;
    SybilTreasury public treasury;
    uint constant treasuryAllocation = 50_000_000 ether;
    uint constant teamAllocation = 10_000_000 ether;
    uint constant liquidityAllocation = 10_000_000 ether;
    uint constant partnerAllocation = 10_000_000 ether;
    uint constant privateFundingAllocation = 20_000_000 ether;
    uint constant publicFundingAllocation = 20_000_000 ether;
    uint constant vestedAllocation = 30_000_000 ether;
    uint startTimestamp;
    uint constant vestingPeriod = 208 weeks;
    uint constant cliffPeriod = 52 weeks;

    event Verify(address user);
    event Stake(address user, uint amount);
    event Unstake(address user, uint amount, uint ethShare);

    constructor() ERC20("SybilDAO", "SYB") {
        treasury = new SybilTreasury(msg.sender);
        _mint(address(treasury), treasuryAllocation);
        _mint(address(msg.sender), teamAllocation);
        _mint(address(msg.sender), liquidityAllocation);
        _mint(address(msg.sender), partnerAllocation);
        startTimestamp = block.timestamp;
    }

    function verify(address _user, bytes32 authCode, bytes32[] calldata _merkleProof) external payable {
        require(msg.value >= fee, "No fee sent");
        require(authCodesUsed[authCode] == false, "Auth code already used");
        authCodesUsed[authCode] = true;
        bool result = MerkleProof.verify(_merkleProof, merkleRoot, authCode);
        require(result == true, "Verification failed");
        check[_user] = true;
        emit Verify(_user);
    }

    /* Staking */
    function stake(uint _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Not enough SYB balance");
        _transfer(msg.sender,address(this),_amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;
        lastStakeTime[msg.sender] = block.timestamp;
        emit Stake(msg.sender, _amount);
    }

    function unstake(uint _amount) public {
        require(_amount > 0, "Amount to unstake too low");
        require(block.timestamp > lastStakeTime[msg.sender] + stakingPeriod, "Tokens are locked for staking period");
        require(staked[msg.sender] >= _amount, "Not enough staked balance");
        uint ethShare = stakingRewardsPending(msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
        _transfer(address(this), msg.sender, _amount);
        payable(msg.sender).transfer(ethShare);
        emit Unstake(msg.sender, _amount, ethShare);
    }

    function claimAndRestake() public {
        uint stakingBalance = staked[msg.sender];
        require(stakingBalance > 0, "Not enough staked balance");
        unstake(stakingBalance);
        stake(stakingBalance);
    }

    function stakingRewardsPending(address _user) public view returns (uint) {
        uint ethPerStakedToken = address(this).balance * 1e18 / totalStaked;
        uint ethShare = staked[_user] * ethPerStakedToken / 1e18;
        return ethShare;
    }

    /* Token Distribution */
    function distributeVestedTokens(address _receiver, uint _amount) external onlyOwner {
        require(vestedClaimed + _amount <= privateFundingAllocation + vestedAllocation, "vested allocation exceeded");
        uint timePassed = block.timestamp - startTimestamp;
        require(timePassed > cliffPeriod, "No distribution before cliff");
        uint claimable = (privateFundingAllocation + vestedAllocation) * timePassed / vestingPeriod;
        require(_amount <= claimable, "Amount too high for vesting");
        _mint(_receiver, _amount);
        vestedClaimed += _amount;
    }

    function vestedClaimable() external view returns (uint) {
        uint timePassed = block.timestamp - startTimestamp;
        uint claimable = (privateFundingAllocation + vestedAllocation) * timePassed / vestingPeriod;
        if (timePassed <= cliffPeriod) claimable = 0;
        return claimable;
    }

    function buyTokens() external payable {
        require(block.timestamp > 0, "Public round is not open");
        require(publicSale + msg.value <= publicFundingAllocation, "Public round exceeded");
        uint sybOut = msg.value * 1e18 / publicSalePrice;
        _mint(address(msg.sender), sybOut);
        publicSale += sybOut;
    }

    /* Admin Functions */
    function treasurystake() external onlyOwner {
        treasury.stake(treasuryAllocation); // runs once
    }

    function bulkVerify(address[] calldata _users) external onlyOwner {
        for (uint i=0; i<_users.length; i++) {
            check[_users[i]] = true;
        }
    }

    function updateMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function updateVariables(uint _fee, uint _publicSalePrice) external onlyOwner {
        if (_fee > 0) fee = _fee;
        if (_publicSalePrice > 0) publicSalePrice = _publicSalePrice;
    }

    receive() external payable  {
    }

}