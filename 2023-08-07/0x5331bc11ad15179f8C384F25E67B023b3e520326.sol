// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  modifier onlyOwner() {
    _checkOwner();
    _;
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  function _checkOwner() internal view virtual {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}

library Address {
  function isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCallWithValue(target, data, 0, "Address: low-level call failed");
  }

  function functionCall(
      address target,
      bytes memory data,
      string memory errorMessage
  ) internal returns (bytes memory) {
      return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
      address target,
      bytes memory data,
      uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  function verifyCallResultFromTarget(
    address target,
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    if (success) {
      if (returndata.length == 0) {
        require(isContract(target), "Address: call to non-contract");
      }
      return returndata;
    } else {
      _revert(returndata, errorMessage);
    }
  }

  function verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      _revert(returndata, errorMessage);
    }
  }

  function _revert(bytes memory returndata, string memory errorMessage) private pure {
    if (returndata.length > 0) {
      assembly {
        let returndata_size := mload(returndata)
        revert(add(32, returndata), returndata_size)
      }
    } else {
      revert(errorMessage);
    }
  }
}

interface IERC20Permit {
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
  function nonces(address owner) external view returns (uint256);
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library SafeERC20 {
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  function safePermit(
    IERC20Permit token,
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {
    uint256 nonceBefore = token.nonces(owner);
    token.permit(owner, spender, value, deadline, v, r, s);
    uint256 nonceAfter = token.nonces(owner);
    require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

contract LCBridgev2Token is Ownable {
  using SafeERC20 for IERC20;

  address public poolToken;
  uint256 public chainId;
  address public treasury;

  mapping (address => bool) public noFeeWallets;
  mapping (address => bool) public managers;

  uint256 public swapFee = 5000;
  uint256 public platformFee = 300000;
  uint256 private constant coreDecimal = 1000000;
  uint256 private constant MULTIPLIER = 1_0000_0000_0000_0000;

  struct StakeInfo {
    uint256 amount;   // Staked liquidity
    uint256 debtReward;
    uint256 rtr;
    uint256 updatedAt;
  }

  struct SwapVoucher {
    uint256 amount;
    uint256 outChain;
    address toAccount;
    address refundAccount;
  }

  uint256 public totalReward = 0;
  uint256 public prevReward = 0;
  uint256 public rtr = 0;
  uint256 public tvl;
  mapping (address => StakeInfo) public userInfo;
  uint256 private swapIndex = 1;
  uint256 private unstakeDebtIndex = 1;
  mapping (uint256 => SwapVoucher) public voucherLists;

  modifier onlyManager() {
    require(managers[msg.sender], "LCBridgev2: !manager");
    _;
  }

  event Swap(address operator, address receiver, address refund, uint256 amount, uint256 srcChainId, uint256 desChainId, uint256 swapIndex);
  event Redeem(address operator, address account, uint256 amount, uint256 srcChainId, uint256 swapIndex);
  event Stake(address account, uint256 amount);
  event Unstake(address account, uint256 amount, bool force);
  event UnstakeDebt(address account, uint256 amount, uint256 chainId, uint256 index);
  event DebtUnstake(address account, uint256 amount, uint256 chainId, uint256 index);
  event Claim(address acccount, uint256 amount);
  event Refund(address operator, address account, uint256 index, uint256 amount);
  event CutFee(uint256 fee, address treasury, uint256 treasuryFee, uint256 totalFee, uint256 tvl);

  constructor(
    address _poolToken,
    uint256 _chainId,
    address _treasury
  )
  {
    require(_poolToken != address(0), "LCBridgev2: Treasury");
    require(_treasury != address(0), "LCBridgev2: Treasury");
    
    poolToken = _poolToken;
    chainId = _chainId;
    treasury = _treasury;
    managers[msg.sender] = true;
  }

  function swap(address _to, uint256 _amount, address _refund, uint256 _outChainID) public payable returns(uint256) {
    uint256 amount = IERC20(poolToken).balanceOf(address(this));
    IERC20(poolToken).safeTransferFrom(msg.sender, address(this), _amount);
    amount = IERC20(poolToken).balanceOf(address(this)) - amount;
    if (noFeeWallets[msg.sender] == false) {
      amount = _cutFee(amount);
    }
    voucherLists[swapIndex] = SwapVoucher(amount, _outChainID, _to, _refund);
    emit Swap(msg.sender, _to, _refund, amount, chainId, _outChainID, swapIndex);
    swapIndex ++;
    return amount;
  }

  function redeem(address account, uint256 amount, uint256 srcChainId, uint256 _swapIndex, uint256 operatorFee) public onlyManager returns(uint256) {
    require(amount <= address(this).balance, "LCBridgev2: Few redeem liquidity");
    require(amount >= operatorFee, "LCBridgev2: Few redeem liquidity");

    amount -= operatorFee;
    if (amount > 0) {
      IERC20(poolToken).safeTransfer(account, amount);
      emit Redeem(msg.sender, account, amount, srcChainId, _swapIndex);
    }

    return amount;
  }

  function refund(uint256 _index) public onlyManager returns(uint256) {
    uint256 amount = voucherLists[_index].amount;
    IERC20(poolToken).safeTransfer(voucherLists[_index].refundAccount, amount);
    emit Refund(msg.sender, voucherLists[_index].refundAccount, _index, amount);
    return amount;
  }

  function stake(address account, uint256 _amount) public payable returns(uint256) {
    uint256 amount = IERC20(poolToken).balanceOf(address(this));
    IERC20(poolToken).safeTransferFrom(msg.sender, address(this), _amount);
    amount = IERC20(poolToken).balanceOf(address(this)) - amount;
    userInfo[account].debtReward += getReward(account);

    if (tvl > 0) {
      rtr += (totalReward - prevReward) * MULTIPLIER / tvl;
    }
    else {
      rtr = 0;
    }
    prevReward = totalReward;
    tvl += amount;
    
    userInfo[account].amount += amount;
    userInfo[account].rtr = rtr;
    userInfo[account].updatedAt = block.timestamp;
    emit Stake(account, amount);
    return amount;
  }

  function unstake(address account, uint256 amount, bool force) public returns(uint256) {
    require(account == msg.sender || managers[msg.sender] == true, "LCBridgev2: wrong account");
    if (amount > userInfo[account].amount) {
      amount = userInfo[account].amount;
    }

    uint256 reward = getReward(account);
    if (reward > 0) {
      claimReward(account);
    }

    if (amount > 0) {
      uint256 liquidity = address(this).balance;
      uint256 unstakeAmount = amount;
      if (liquidity < amount) {
        unstakeAmount = liquidity;
        if (force) {
          emit UnstakeDebt(account, amount - liquidity, chainId, unstakeDebtIndex);
          unstakeDebtIndex ++;
        }
        else {
          amount = liquidity;
        }
      }

      IERC20(poolToken).safeTransfer(account, unstakeAmount);

      tvl -= amount;
      userInfo[account].amount -= amount;
      emit Unstake(account, amount, force);
    }
    return amount;
  }

  function forceUnstake(address account, uint256 amount, uint256 _chainId, uint256 _debtIndex) public onlyManager {
    IERC20(poolToken).safeTransfer(account, amount);
    emit DebtUnstake(account, amount, _chainId, _debtIndex);
  }

  function getReward(address account) public view returns(uint256) {
    uint256 reward = userInfo[account].debtReward;
    if (userInfo[account].amount > 0) {
      uint256 currentRtr = tvl > 0 ? (totalReward - prevReward) * MULTIPLIER / tvl : 0;
      currentRtr += rtr;
      if (currentRtr >= userInfo[account].rtr) {
        reward += (currentRtr - userInfo[account].rtr) * userInfo[account].amount / MULTIPLIER;
      }
    }
    return reward;
  }

  function claimReward(address account) public returns(uint256) {
    uint256 reward = getReward(account);
    if (reward > 0) {
      IERC20(poolToken).safeTransfer(account, reward);
    }
    uint256 currentRtr = tvl > 0 ? (totalReward - prevReward) * MULTIPLIER / tvl : 0;
    rtr += currentRtr;
    prevReward = totalReward;

    userInfo[account].debtReward = 0;
    userInfo[account].rtr = rtr;
    userInfo[account].updatedAt = block.timestamp;
    emit Claim(account, reward);
    return reward;
  }

  function setManager(address account, bool access) public onlyOwner {
    managers[account] = access;
  }

  function setNoFeeWallets(address account, bool access) public onlyManager {
    noFeeWallets[account] = access;
  }

  function setSwapFee(uint256 _swapFee) public onlyManager {
    swapFee = _swapFee;
  }

  function setPlatformFee(uint256 _platformFee) public onlyManager {
    platformFee = _platformFee;
  }

  function setTreasury(address _treasury) public onlyManager {
    treasury = _treasury;
  }

  function _cutFee(uint256 _amount) internal returns(uint256) {
    if (_amount > 0) {
      uint256 fee = _amount * swapFee / coreDecimal;
      uint256 treasuryFee = fee * platformFee / coreDecimal;
      if (treasuryFee > 0) {
        IERC20(poolToken).safeTransfer(treasury, treasuryFee);
      }
      if (tvl > 0) {
        totalReward += (fee - treasuryFee);
      }
      emit CutFee(fee, treasury, treasuryFee, totalReward, tvl);
      return _amount - fee;
    }
    return 0;
  }
}
