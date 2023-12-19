// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Team369 is IERC20 {
    using SafeMath for uint256;
    string public name = "Team 369";
    string public symbol = "T369";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1500000000 * 10**uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isExcludedFromFee; // Track wallets excluded from burn fee


    address public owner;
    uint8 public burnFee = 2;
    uint8 public maxBurnFee = 4; // Maximum burn fee allowed

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Modify _burn function to account for excluded wallets
    function _burn(address _from, uint256 _amount) internal {
        require(_from != address(0), "Invalid address");
        uint256 actualBurnFee = (_amount.mul(burnFee)).div(100);

        // If the sender is not excluded from fee, apply burn fee
        if (!isExcludedFromFee[_from]) {
            require(actualBurnFee <= (_amount.mul(maxBurnFee)).div(100), "Burn fee exceeds maximum");
        } else {
            actualBurnFee = 0; // If excluded, set burn fee to 0
        }

        uint256 transferAmount = _amount.sub(actualBurnFee);
        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(actualBurnFee);
        emit Transfer(_from, address(0), actualBurnFee);
        emit Transfer(_from, msg.sender, transferAmount);
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[msg.sender], "Insufficient balance");

        _burn(msg.sender, _value);

        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        require(_spender != address(0), "Invalid address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_from != address(0) && _to != address(0), "Invalid addresses");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        _burn(_from, _value);

        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function FeeForBurn(uint8 _fee) public onlyOwner {
        require(_fee <= maxBurnFee, "Burn fee cannot exceed the maximum allowed");
        burnFee = _fee;
    }

    // Function to include a wallet in the burn fee
    function includeInFee(address account) public onlyOwner {
        isExcludedFromFee[account] = false;
    }

    // Function to exclude a wallet from the burn fee
    function excludeFromFee(address account) public onlyOwner {
        isExcludedFromFee[account] = true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    
    function ClaimBNB() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No BNB to recover");
        payable(owner).transfer(balance);
    }

    function ClaimToken(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner, tokenAmount);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}