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
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);
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

abstract contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor () {
    _status = _NOT_ENTERED;
  }
  
  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}

contract LQDXStaker is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  address public rewardToken;
  address public treasury;

  struct lpHoldInfo {
    uint256 amount;
    uint256 debtReward;
    uint256 timestamp;
  }

  struct allocInfo {
    uint256 alloc;
    uint256 timestamp;
  }

  mapping (address => uint256) public totalStake;
  // account -> stakingtoken -> info
  mapping (address => mapping(address => lpHoldInfo)) public userInfo;
  // token -> alloc
  mapping (address => allocInfo[]) public allocPoints;
  mapping (address => bool) public operators;
  uint256 public totalAllocPoint = 365 * 24 * 3600 * 100 * 100000;
  uint256 public coreDecimal = 1000_000;
  uint256 public deposistFee = 0;
  uint256 public withdrawFee = 10_000;
  uint256 public rewardFee = 10_000;

  event UpdateAlloc(address token, uint256 alloc, address operator);
  event ClaimLiquidXReward(address account, address token, uint256 amount);
  event LQDXStakeingFee(address token, uint256 fee, address treasury);

  constructor(address _treasury, address _rewardToken) {
    treasury = _treasury;
    rewardToken = _rewardToken;
  }

  receive() external payable {
  }

  event Stake(address account, address token, uint256 amount, uint256 tvl, uint256 timestamp);
  event Unstake(address account, address token, uint256 amount, uint256 tvl, uint256 timestamp);

  function stake(address account, address token, uint256 amount) public {
    require(amount > 0, "LQDXStaker: Wrong amount");
    uint256 balance = IERC20(token).balanceOf(address(this));
    IERC20(token).safeTransferFrom(account, address(this), amount);
    amount = IERC20(token).balanceOf(address(this)) - balance;

    claim(account, token);
    userInfo[account][token].amount += amount;
    totalStake[token] += amount;
    emit Stake(account, token, amount, userInfo[account][token].amount, block.timestamp);
  }

  function unstake(address account, address token, uint256 amount) public {
    require(amount > 0, "LQDXStaker: Wrong amount");
    claim(account, token);
    if (userInfo[account][token].amount >= amount) {
      userInfo[account][token].amount -= amount;
      emit Unstake(account, token, amount, userInfo[account][token].amount, block.timestamp);
    }
    else if (userInfo[account][token].amount > 0) {
      amount = userInfo[account][token].amount;
      userInfo[account][token].amount = 0;
      emit Unstake(account, token, amount, 0, block.timestamp);
    }
    else {
      amount = 0;
    }

    if (totalStake[token] >= amount) {
      totalStake[token] -= amount;
    }
    else {
      totalStake[token] = 0;
    }

    if (withdrawFee > 0) {
      amount = _cutFee(token, withdrawFee, amount);
      IERC20(token).safeTransfer(account, amount);
    }
  }

  function getCurrentAllocPoint(address pool) public view returns(uint256) {
    uint256 len = allocPoints[pool].length;
    if (len > 0) {
      return allocPoints[pool][len-1].alloc;
    }
    else {
      return 0;
    }
  }

  function _getStartAlloc(address lpAddress, uint256 timestamp) internal view returns(uint256) {
    uint256 index = 0;
    uint256 len = allocPoints[lpAddress].length;
    for (; index < len; index++) {
      if (allocPoints[lpAddress][index].timestamp > timestamp) break;
    }
    return index;
  }

  function getReward(address account, address token) public view returns(uint256) {
    lpHoldInfo memory userI = userInfo[account][token];
    if (userI.amount > 0) {
      uint256 index = _getStartAlloc(token, userI.timestamp);
      uint256 len = allocPoints[token].length;
      uint256 amount = userI.debtReward;
      uint256 alloc = 0;
      uint256 ts = 0;
      uint256 startTs = userI.timestamp;
      if (index < len && len > 0) {
        for (; index < len; index ++) {
          ts = allocPoints[token][index].timestamp;
          if (index > 0) {
            alloc = allocPoints[token][index-1].alloc;
            if (alloc > 0) {
              amount += userI.amount * alloc * (ts - startTs) / totalAllocPoint;
            }
          }
          startTs = ts;
        }
        alloc = allocPoints[token][index-1].alloc;
      }
      else if (index > 0) {
        alloc = allocPoints[token][index-1].alloc;
        ts = userI.timestamp;
      }
      if (alloc > 0) {
        amount += userI.amount * alloc * (block.timestamp - ts) / totalAllocPoint;
      }
      return amount;
    }
    else {
      return 0;
    }
  }

  function claim(address account, address token) public nonReentrant {
    require(account == msg.sender || operators[msg.sender], "LQDXStaker: FORBIDDEN");
    uint256 amount = getReward(account, token);
    if (amount > 0) {
      uint256 balance = IERC20(rewardToken).balanceOf(address(this));
      if (token == rewardToken) {
        uint256 tvl = totalStake[token];
        if (balance >= tvl) {
          balance -= tvl;
        }
        else {
          balance = 0;
        }
      }
      if (balance >= amount) {
        if (rewardFee > 0) {
          amount = _cutFee(rewardToken, rewardFee, amount);
        }
        IERC20(rewardToken).safeTransfer(account, amount);
        emit ClaimLiquidXReward(account, rewardToken, amount);
        userInfo[account][token].debtReward = 0;
      }
      else {
        if (balance > 0) {
          if (rewardFee > 0) {
            balance = _cutFee(rewardToken, rewardFee, balance);
          }
          IERC20(rewardToken).safeTransfer(account, balance);
          emit ClaimLiquidXReward(account, rewardToken, balance);
        }
        userInfo[account][token].debtReward += (amount - balance);
      }
    }
    userInfo[account][token].timestamp = block.timestamp;
  }

  function forceSetUserInfo(address account, address token, uint256 amount, uint256 timetamp, uint256 debt) public onlyOwner {
    userInfo[account][token].amount = amount;
    userInfo[account][token].debtReward = debt;
    userInfo[account][token].timestamp = timetamp;
  }

  function setAllockPoint(address token, uint256 alloc) public onlyOwner {
    allocInfo memory tmp = allocInfo(alloc, block.timestamp);
    allocPoints[token].push(tmp);
    emit UpdateAlloc(token, alloc, msg.sender);
  }

  function setDepositFee(uint256 fee) public onlyOwner {
    deposistFee = fee;
  }

  function setWithdrawFee(uint256 fee) public onlyOwner {
    withdrawFee = fee;
  }

  function setRewardFee(uint256 fee) public onlyOwner {
    rewardFee = fee;
  }

  function withdrawToken(address token, address target, uint256 amount) public onlyOwner {
    if (token == address(0)) {
      (bool success, ) = payable(target).call{value: amount}("");
      require(success, "LiquidXv2Zap: Failed withdraw");
    }
    else {
      IERC20(token).safeTransfer(target, amount);
    }
  }

  function setOperator(address _operator, bool mode) external onlyOwner {
    operators[_operator] = mode;
  }

  function _cutFee(address _token, uint256 _fee, uint256 _amount) internal returns(uint256) {
    if (_amount > 0) {
      uint256 fee = _amount * _fee / coreDecimal;
      if (fee > 0) {
        if (_token == address(0)) {
          (bool success, ) = payable(treasury).call{value: fee}("");
          require(success, "BridgePlus: Failed cut fee");
        }
        else {
          IERC20(_token).safeTransfer(treasury, fee);
        }
        emit LQDXStakeingFee(_token, fee, treasury);
      }
      return _amount - fee;
    }
    return 0;
  }
}
