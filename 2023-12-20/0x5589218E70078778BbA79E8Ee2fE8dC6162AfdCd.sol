// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface DonativoERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DonativoUSDT {
    address public owner;
    DonativoERC20 public token;

    event TokensDistributed(address[] receivers, uint256[] amounts);

    modifier onlyOwner() {
        //require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = DonativoERC20(_tokenAddress);
    }

    function distributeTokens(address[] memory receivers, uint256[] memory amounts) external onlyOwner {
        require(receivers.length == amounts.length, "Invalid input lengths");

        for (uint256 i = 0; i < receivers.length; i++) {
            token.transferFrom(msg.sender, receivers[i], amounts[i]);
        }

        emit TokensDistributed(receivers, amounts);
    }

}