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

contract LQDXPool is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  uint256 public coreDecimal = 10000_0000;
  uint256 public baseUnit = 30 days;
  uint256 public TGE = 1705654800; // 9:00 AM, Jan 19th, 2024
  address public LQDX;
  address public relayer;

  struct Role {
    uint256 unlockTGE;
    uint256 cliff;
    uint256 vestingPeriod;
  }

  struct MintLog {
    uint256 allocation;
    uint256 lastIssue;
  }

  mapping(string => Role) public roles;
  mapping(string => mapping(address => MintLog)) public userRole;
  mapping(string => address[]) public userList;

  constructor (address _LQDX, address _relayer) {
    require(_LQDX != address(0), "LQDXPool: wrong LQDX");
    require(_relayer != address(0), "LQDXPool: wrong relayer");
    LQDX = _LQDX;
    relayer = _relayer;
    roles["Seed"] = Role(200_0000, 9, 15);        //  2%  9 15
    roles["PrivateA"] = Role(500_0000, 10, 12);   //  5% 10 12
    roles["PrivateB"] = Role(700_0000, 6, 12);    //  7%  6 12
    roles["PreSale"] = Role(1000_0000, 3, 6);     // 10%  3  6
    roles["Public"] = Role(2000_0000, 3, 3);      // 20%  3  3
    roles["Staking"] = Role(0, 3, 20);            //  0%  3 20
    roles["Liquidity"] = Role(5000_0000, 0, 1);   // 50%  0  1
    roles["Treasury"] = Role(0, 3, 21);           //  0%  3 21
    roles["Advisor"] = Role(0, 12, 24);           //  0% 12 24
    roles["KOL"] = Role(1000_0000, 0, 18);        // 10%  0 18
    roles["Team"] = Role(0, 12, 24);              //  0% 12 24
    roles["Eco"] = Role(0, 1, 19);                //  0%  1 19
    roles["Advisor1"] = Role(500_0000, 9, 12);    //  5%  9 12
  }

  function getUserList(string memory role) public view returns(address[] memory) {
    return userList[role];
  }

  function getAvailableToken(string memory role, address user, uint256 ts) public view returns(uint256) {
    uint256 amount = 0;
    if (ts == 0) {
      ts = block.timestamp;
    }
    if (userRole[role][user].lastIssue == 0) {
      amount = roles[role].unlockTGE * userRole[role][user].allocation / coreDecimal;
    }
    if (userRole[role][user].lastIssue <= (TGE + (roles[role].cliff + roles[role].vestingPeriod) * baseUnit)) {
      uint256 cliffTs = TGE + roles[role].cliff * baseUnit;
      if (ts >= cliffTs) {
        uint256 period = ts - cliffTs;
        period = period / baseUnit;
        if (period > roles[role].vestingPeriod) {
          period = roles[role].vestingPeriod;
        }
        if (userRole[role][user].lastIssue > cliffTs) {
          uint256 usedPeriod = (userRole[role][user].lastIssue - cliffTs) / baseUnit;
          period = period - usedPeriod;
        }
        if (period > 0) {
          amount += period * userRole[role][user].allocation * (coreDecimal - roles[role].unlockTGE) / (coreDecimal * roles[role].vestingPeriod);
        }
      }
    }
    return amount;
  }

  function getAvailableTime(string memory role, address user) public view returns(uint256) {
    if (roles[role].unlockTGE + roles[role].cliff + roles[role].vestingPeriod == 0) return 0;
    if (userRole[role][user].allocation == 0) return 0;
    if (userRole[role][user].lastIssue == 0) {
      return block.timestamp;
    }
    else {
      uint256 cliffTs = TGE + roles[role].cliff * baseUnit;
      if (userRole[role][user].lastIssue > (TGE + (roles[role].cliff + roles[role].vestingPeriod) * baseUnit)) return 0;
      if (userRole[role][user].lastIssue < cliffTs) return cliffTs;
      uint256 usedPeriod = (userRole[role][user].lastIssue - cliffTs) / baseUnit;
      return cliffTs + (usedPeriod + 1) * baseUnit;
    }
  }

  function _issueToken(string memory role, address user) internal {
    if (userRole[role][user].lastIssue == 0) {
      uint256 amount = roles[role].unlockTGE * userRole[role][user].allocation / coreDecimal;
      if (amount > 0) {
        IERC20(LQDX).safeTransfer(user, amount);
      }
    }
    if (userRole[role][user].lastIssue <= (TGE + (roles[role].cliff + roles[role].vestingPeriod) * baseUnit)) {
      uint256 cliffTs = TGE + roles[role].cliff * baseUnit;
      if (block.timestamp >= cliffTs) {
        uint256 period = block.timestamp - cliffTs;
        period = period / baseUnit;
        if (period > roles[role].vestingPeriod) {
          period = roles[role].vestingPeriod;
        }
        if (userRole[role][user].lastIssue > cliffTs) {
          uint256 usedPeriod = (userRole[role][user].lastIssue - cliffTs) / baseUnit;
          period = period - usedPeriod;
        }
        if (period > 0) {
          uint256 amount = period * userRole[role][user].allocation * (coreDecimal - roles[role].unlockTGE) / (coreDecimal * roles[role].vestingPeriod);
          if (amount > 0) {
            IERC20(LQDX).safeTransfer(user, amount);
          }
        }
      }
    }
    userRole[role][user].lastIssue = block.timestamp;
  }

  function mint(string memory role, address[] memory user) public nonReentrant {
    require(msg.sender == relayer, "LQDXPool: wrong relayer");
    require(roles[role].unlockTGE + roles[role].cliff + roles[role].vestingPeriod > 0, "LQDXPool: wrong role");
    uint256 len = user.length;
    for (uint256 x = 0; x < len; x++) {
      _issueToken(role, user[x]);
    }
  }

  function _userExist(string memory role, address user) internal view returns(bool) {
    uint256 len = userList[role].length;
    for (uint256 i=0; i<len; i++) {
      if (userList[role][i] == user) return true;
    }
    return false;
  }

  function _insertUserRole(string memory role, address user, uint256 amount) internal {
    if (_userExist(role, user)) {
      userRole[role][user].allocation = amount;
    }
    else {
      userList[role].push(user);
      userRole[role][user] = MintLog(amount, 0);
    }
  }

  function _removeUserRole(string memory role, address user) internal {
    if (_userExist(role, user)) {
      uint256 len = userList[role].length;
      for (uint256 i=0; i<len; i++) {
        if (userList[role][i] == user) {
          userList[role][i] = userList[role][len-1];
          break;
        }
      }
      userList[role].pop();
      delete userRole[role][user];
    }
  }

  function addUserRole(string memory role, address[] memory user, uint256[] memory amount) public onlyOwner {
    require(roles[role].unlockTGE + roles[role].cliff + roles[role].vestingPeriod > 0, "LQDXPool: wrong role");
    require(user.length == amount.length, "LQDXPool: wrong parameter");
    uint256 len = user.length;
    for (uint256 x = 0; x < len; x ++) {
      _insertUserRole(role, user[x], amount[x]);
    }
  }

  function changeUserRole(string memory role, address user, uint256 alloc, uint256 lastIssue) public onlyOwner {
    require(roles[role].unlockTGE + roles[role].cliff + roles[role].vestingPeriod > 0, "LQDXPool: wrong role");
    userRole[role][user].allocation = alloc;
    userRole[role][user].lastIssue = lastIssue;
  }

  function removeUserRole(string memory role, address[] memory user) public onlyOwner {
    require(roles[role].unlockTGE + roles[role].cliff + roles[role].vestingPeriod > 0, "LQDXPool: wrong role");
    uint256 len = user.length;
    for (uint256 x = 0; x < len; x ++) {
      _removeUserRole(role, user[x]);
    }
  }

  function withdrawLQDX() public onlyOwner {
    if (IERC20(LQDX).balanceOf(address(this)) > 0) {
      IERC20(LQDX).safeTransfer(msg.sender, IERC20(LQDX).balanceOf(address(this)));
    }
  }
}
