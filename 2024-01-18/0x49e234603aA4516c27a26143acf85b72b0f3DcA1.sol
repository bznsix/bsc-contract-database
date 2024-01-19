// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

abstract contract Context { 

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
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


contract StakingContract is Ownable {
    IERC20 public stakingToken; // The token users stake
    uint256 public lastUpdateTime; // Last time rewards were updated
    address walletHolder;

    mapping(address => uint256) public stakedBalance;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Log(string message, uint256 amount);
    event Log(string message, address addres);

    constructor(address _tokenAddress) {
        stakingToken = IERC20(_tokenAddress);
        walletHolder = msg.sender;
        lastUpdateTime = block.timestamp;
    }

    function changeWalletHolder(address _holder)  public onlyOwner {
        walletHolder = _holder;
    }

    function getWalletHolder()  public view returns (address) {
        return walletHolder;
    }

    function stake(uint256 amount) external {
        emit Log("Amount staking: ", amount);
        emit Log("Staker: ", msg.sender);
        require(amount > 0, "Cannot stake 0");
        stakingToken.transferFrom(msg.sender, walletHolder, amount);
        stakedBalance[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    function getStakedTokenAmount(address staker) public view returns  (uint256) {
        return stakedBalance[staker];
    }

    function withdraw(address receiver, uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot withdraw 0");
        require(stakedBalance[receiver] <= amount, "Insufficient Balance");
        stakedBalance[receiver] -= amount;
        stakingToken.transfer(receiver, amount);
        emit Withdrawn(receiver, amount);
    }

    function withdrawStakeWithoutTransfer(address _holder, uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot withdraw 0");
        require(stakedBalance[_holder] >= amount, "Insufficient Balance");
        stakedBalance[_holder] -= amount;
        emit Withdrawn(_holder, amount);
    }
    // 63518869000
}