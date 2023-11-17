// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
      if (success) {
          return returndata;
      } else {
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract fzStake is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public FZAddress = address(0x0F085819097334a28f27213cA0e84A9730cc8947);
    address public MKAddress = address(0xD33a88C1cd585B29651d24A038FB8634d31B7dde);
    uint256 public minAmount = 101 * 10 ** 18;
    uint256 public towAmount = 300 * 10 ** 18;
    uint256 public threeAmount = 500 * 10 ** 18;
    uint256 public foveAmount = 1000 * 10 ** 18;
    
    uint256 public DURATION_1 = 1 days;
    uint256 public initTime = 1700064000;

    uint256 private _decimals = 18;

    bool public swapsEnabled = false;
    
    uint256 public totalReferralReward = 0;

    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;


    
    mapping(address => uint256) public _userReward;
    mapping(address => uint256) public _userTime;

    mapping(address => address) internal _parents;
    mapping(address => address[]) _mychilders;

    event BindingParents(address indexed user, address inviter);

    constructor () {
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getMyChilders(address user) public view returns (address[] memory) {
        return _mychilders[user];
    }

    function getParent(address user) public view returns (address) {
        return _parents[user];
    }

    function setSwapsEnabled(bool _enabled) public onlyOwner {
      swapsEnabled = _enabled;
    }

    function setinit_time(uint256 _initTime) public onlyOwner {
      initTime = _initTime;
    }

    function setDURATION_1(uint256 _time) public onlyOwner {
      DURATION_1 = _time;
    }

    function bindParent(address parent) public returns (bool) {
        require(parent != address(0), "ERROR parent");
        require(parent != msg.sender, "ERROR parent");
        require(_parents[msg.sender] == address(0), "ERROR parent");
        require(_parents[parent] != address(0) || parent == owner(), 'ERROR The superior did not participate in IDO');
        _parents[msg.sender] = parent;
        _mychilders[parent].push(msg.sender);
        emit BindingParents(msg.sender, parent);
        return true;
    }

    function getDayByTime(uint256 blockTime) private view returns(uint256) {
        return block.timestamp.sub(blockTime).div(DURATION_1);
    }

    function setParentByAdmin(address user, address parent)  public onlyOwner returns (bool) {
      require(_parents[user] == address(0), "Already bind");
      _parents[user] = parent;
      _mychilders[parent].push(user);
      return true;
    }


    function earned(address account) public view returns (uint256) {

        uint256 currentAmount = IERC20(FZAddress).balanceOf(account);

        if (minAmount > currentAmount) {
            return 0;
        } else {
            if (_userTime[msg.sender] > 0) {

                if (block.timestamp > _userTime[msg.sender].add(DURATION_1)) {
                    return currentAmount.div(100);
                } else {
                    return 0;
                }

            } else {

                if (block.timestamp > initTime.add(DURATION_1)) {
                    return currentAmount.div(100);
                } else {
                    return 0;
                }

            }
        }
    }


    function getReward() public {
        
        uint256 reward = earned(msg.sender);

        require(reward > 0, 'ERROR reward');

        uint256 time = _userTime[msg.sender];
        if (time > 0) {
            uint256 day_s = getDayByTime(time);
            _userTime[msg.sender] = _userTime[msg.sender].add(DURATION_1.mul(day_s));
        } else {
            uint256 day_s = getDayByTime(initTime);
            _userTime[msg.sender] = initTime.add(DURATION_1.mul(day_s));
        }

        _userReward[msg.sender] = _userReward[msg.sender].add(reward);

        _totalSupply = _totalSupply.add(reward);

        safeTransfer(msg.sender, reward);
        _takeInviterFee(msg.sender, reward);
    }


    function _takeInviterFee(address _address, uint256 amount) private {
        address cur = _address;
        uint256 mkAmount = 0;
        for (int256 i = 0; i < 13; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 50;
            } else if (i == 1) {
                rate = 30;
            } else if (i == 2) {
                rate = 20;
            } else {
                rate = 10;
            }
            cur = _parents[cur];
            uint256 curTAmount = amount.div(100).mul(rate);
            if (cur == address(0)) {
                mkAmount = mkAmount.add(curTAmount);
            } else {
                uint256 currentAmount = IERC20(FZAddress).balanceOf(cur);
                if (i == 0 && minAmount < currentAmount) {
                    safeTransfer(cur, curTAmount);
                } else if (i == 1 && towAmount < currentAmount) {
                    safeTransfer(cur, curTAmount);
                } else if (i == 2 && threeAmount < currentAmount) {
                    safeTransfer(cur, curTAmount);
                } else if (i  > 2 && foveAmount < currentAmount) {
                    safeTransfer(cur, curTAmount);
                } else {
                    mkAmount = mkAmount.add(curTAmount);
                }
            }
        }
        safeTransfer(MKAddress, mkAmount);
    }

    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBalance = IERC20(FZAddress).balanceOf(address(this));
        require(_amount <= tokenBalance, "no token");
        IERC20(FZAddress).transfer(_to, _amount);
    }
    
    function donateDust(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

}