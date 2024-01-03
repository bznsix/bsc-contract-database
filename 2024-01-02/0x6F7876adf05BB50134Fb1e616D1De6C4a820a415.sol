// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

contract ERC20Token {
    string public constant NAME = "Web High";
    string public constant SYMBOL = "WEBH";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000 * (10 ** uint256(DECIMALS));

    address public owner;

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = TOTAL_SUPPLY;
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address delegate) public view returns (uint256) {
        return allowed[_owner][delegate];
    }

    function transferFrom(address _owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[_owner], "Insufficient balance");
        require(numTokens <= allowed[_owner][msg.sender], "Not enough allowance");

        balances[_owner] -= numTokens;
        allowed[_owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(_owner, buyer, numTokens);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}