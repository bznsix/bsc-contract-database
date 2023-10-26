// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract MetaAssetServiceStaking{
    using SafeMath for uint256;
    BEP20 public mas = BEP20(0x1C8371f8B85482119C526784F912687Deb84144d);
    address owner;
    
    event Stake(address depositor, uint256 amount);
    event StakeDistribution(address receiver, uint256 amount);
   
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBalance){
        return contractBalance = mas.balanceOf(address(this));
    }

    constructor() {
        owner = msg.sender;
    }

    function stake(uint256 amount) public {
        mas.transferFrom(msg.sender,address(this),amount);
        emit Stake(msg.sender, amount);
    }

    function stakeDistribution(address _address, address coin, uint256 _amount) external onlyOwner{
        BEP20(coin).transfer(_address,_amount);
        emit StakeDistribution(_address,_amount);
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}