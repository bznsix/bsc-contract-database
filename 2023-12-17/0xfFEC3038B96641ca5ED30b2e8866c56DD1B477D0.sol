pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
  constructor () { }
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PGSwap is Ownable {
    using SafeMath for uint256;

    address public tokenU;
    address public tokenPG;
    uint256 public withdrawFee = 500;

    address public to;

    event Recharge(address from, uint256 amountU, uint256 amountPG);
    event Withdraw(address from, uint256 amountU, uint256 amountPG);
    
    constructor(address _tokenU, address _tokenPG, address _to, address owner) {
        tokenU = _tokenU;
        tokenPG = _tokenPG;
        to = _to;
        transferOwnership(owner);
    }

    function setTo(address _to) external onlyOwner{
        to = _to;
    }

    function setFee(uint256 _fee) external onlyOwner{
        withdrawFee = _fee;
    }

    function recharge(uint256 _amount) public {
        IERC20(tokenU).transferFrom(msg.sender, to, _amount);
        IERC20(tokenPG).transfer(msg.sender, _amount);
        emit Recharge(msg.sender, _amount, _amount);
    }

    function withdraw(uint256 _amount) public {
        uint256 fee = _amount.mul(withdrawFee).div(10000);
        IERC20(tokenPG).transferFrom(msg.sender, address(this), _amount);
        emit Withdraw(msg.sender, _amount.sub(fee), _amount);
    }

    function setWithdrawFee(uint256 _fee) public onlyOwner {
        withdrawFee = _fee;
    }

    function withdrawEth(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function withdrawErc20(
        address con,
        address addr,
        uint256 amount
    ) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

}