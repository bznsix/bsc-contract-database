// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Hailix10Token {
    string public name = "Hailix10";
    string public symbol = "HAIL10";
    uint8 public decimals = 18;
    uint256 public totalSupply = 250_000_000 * 10 ** uint256(decimals);
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public paused;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address public feeCollectionAddress = 0x3136c34786f2306992d5362A2F5D4B08C8b10A1D;

    uint256 public constant BURN_RATE = 5; // 0.5% burn rate
    uint256 public constant FEE_RATE = 5; // 0.5% fee rate

    bool private reentrancyGuard;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier whenNotPaused() {
        require(!paused[msg.sender], "Token transfers are paused for this account.");
        _;
    }

    modifier nonReentrant() {
        require(!reentrancyGuard, "Reentrancy error. This function cannot be called from within another function.");
        reentrancyGuard = true;
        _;
        reentrancyGuard = false;
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        require(allowance[from][msg.sender] >= value, "Allowance exceeded.");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal nonReentrant {
        require(to != address(0), "Invalid token transfer. The recipient address is not valid.");
        require(balanceOf[from] >= value, "Insufficient funds. The user does not have enough tokens to complete this transaction.");

        uint256 burnAmount = (value * BURN_RATE) / 1000;
        uint256 feeAmount = (value * FEE_RATE) / 1000;

        balanceOf[from] -= value;
        balanceOf[to] += value - burnAmount - feeAmount;
        balanceOf[BURN_ADDRESS] += burnAmount;
        balanceOf[feeCollectionAddress] += feeAmount;

        emit Transfer(from, to, value);
        emit Transfer(from, BURN_ADDRESS, burnAmount);
        emit Transfer(from, feeCollectionAddress, feeAmount);
    }

    function setFeeCollectionAddress(address _newFeeCollectionAddress) public onlyOwner {
        feeCollectionAddress = _newFeeCollectionAddress;
    }

    function pause() public onlyOwner {
        paused[msg.sender] = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        paused[msg.sender] = false;
        emit Unpaused(msg.sender);
    }
}