{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)\n\npragma solidity ^0.8.0;\n\n// CAUTION\n// This version of SafeMath should only be used with Solidity 0.8 or later,\n// because it relies on the compiler\u0027s built in overflow checks.\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\n *\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\n * now has built in overflow checking.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            uint256 c = a + b;\n            if (c \u003c a) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b \u003e a) return (false, 0);\n            return (true, a - b);\n        }\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n            // benefit is lost if \u0027b\u0027 is also tested.\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n            if (a == 0) return (true, 0);\n            uint256 c = a * b;\n            if (c / a != b) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a / b);\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a % b);\n        }\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a + b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a * b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator.\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003c= a, errorMessage);\n            return a - b;\n        }\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a / b;\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a % b;\n        }\n    }\n}\n"},"stake.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Ownable.sol\";\n\ncontract Stake is Ownable {\n    using SafeMath for uint256;\n    IERC20 public token;\n    uint256 public rewardRate;\n    struct StakerData {\n        uint256 totalStaked;\n        uint256 lastStakedTimestamp;\n        uint256 reward;\n        uint256 lastDayTimestamp;\n    }\n    struct rewardRateData {\n        uint256 rewardRate;\n        uint256 startTimestamp;\n        uint256 endTimestamp;\n    }\n    rewardRateData[] private rewardRateHistory;\n    address public commissionRecipient;\n    mapping(address =\u003e StakerData) private stakers;\n    constructor(IERC20 _token, uint256 _rewardRate) {\n        rewardRate = _rewardRate;\n        token = _token;\n        rewardRateHistory.push(rewardRateData(_rewardRate, block.timestamp, type(uint256).max));\n        commissionRecipient = msg.sender;\n    }\n\n    function calculateReward(address _user) internal view returns (uint256) {\n        StakerData storage staker = stakers[_user];\n        uint256 stakingDuration = block.timestamp.sub(staker.lastStakedTimestamp);\n        uint256 _reward = getRewardRate(staker.lastStakedTimestamp);\n        if (_reward == 0) {\n            return 0;\n        } else {\n            return staker.totalStaked.mul(_reward).mul(stakingDuration).div(315360000000);\n        }\n    }\n\n    function stake(uint256 amount, uint256 stakeDuration) public {\n        require(amount \u003e 0, \"Amount must be greater than 0\");\n        require(stakeDuration \u003e= 30, \"Duration must be greater than or equal 30\");\n        token.transferFrom(msg.sender, address(this), amount);\n\n        // Update staker\u0027s data\n        StakerData storage staker = stakers[msg.sender];\n        staker.reward = staker.reward.add(calculateReward(msg.sender));\n        staker.totalStaked = staker.totalStaked.add(amount);\n        staker.lastStakedTimestamp = block.timestamp;\n        if (staker.lastDayTimestamp \u003c block.timestamp.add(stakeDuration.mul(86400))) {\n            staker.lastDayTimestamp = block.timestamp.add(stakeDuration.mul(86400));\n        }\n    }\n\n    function unstake(uint256 amount) public {\n        StakerData storage staker = stakers[msg.sender];\n        require(staker.totalStaked \u003e= amount \u0026\u0026 staker.totalStaked \u003e 0, \"Not enough staked tokens\");\n        staker.reward = staker.reward.add(calculateReward(msg.sender));\n        staker.totalStaked = staker.totalStaked.sub(amount);\n        staker.lastStakedTimestamp = block.timestamp;\n        if (staker.lastDayTimestamp \u003c= block.timestamp) {\n            token.transfer(msg.sender, amount);\n        } else {\n            token.transfer(commissionRecipient, amount.mul(3).div(10));\n            token.transfer(msg.sender, amount.mul(7).div(10));\n        }\n        if (staker.totalStaked == 0) {\n            staker.lastDayTimestamp = 0;\n        }\n    }\n\n    function claimReward() public {\n        StakerData storage staker = stakers[msg.sender];\n        uint256 reward = staker.reward.add(calculateReward(msg.sender));\n        require(reward \u003e 0, \"No reward to claim\");\n\n        staker.reward = 0;\n        staker.lastStakedTimestamp = block.timestamp;\n\n        token.transfer(msg.sender, reward);\n    }\n\n    function unstakeAll() public {\n        StakerData storage staker = stakers[msg.sender];\n        uint256 reward = staker.reward.add(calculateReward(msg.sender));\n        uint256 _amount = staker.totalStaked;\n\n        require(_amount \u003e 0 || reward \u003e 0, \"Not enough staked tokens\");\n\n        staker.reward = 0;\n        staker.totalStaked = 0;\n        staker.lastStakedTimestamp = block.timestamp;\n\n        if (staker.lastDayTimestamp \u003c= block.timestamp) {\n            token.transfer(msg.sender, _amount.add(reward));\n        } else {\n            token.transfer(commissionRecipient, _amount.mul(3).div(10));\n            token.transfer(msg.sender, _amount.mul(7).div(10).add(reward));\n        }\n        staker.lastDayTimestamp = 0;\n    }\n\n    function getReward() public view returns (uint256) {\n        StakerData storage staker = stakers[msg.sender];\n        uint256 reward = staker.reward.add(calculateReward(msg.sender));\n        return reward;\n    }\n\n    function getRewardRate(uint256 _startTimestemp) internal view returns (uint256) {\n        require(block.timestamp \u003e= _startTimestemp, \"timestemp error\");\n        if (_startTimestemp == 0 || _startTimestemp == block.timestamp) {\n            return 0;\n        }\n        uint256 _i = binarySearch(_startTimestemp);\n        uint256 _rate;\n        uint256 _time = block.timestamp.sub(_startTimestemp);\n        for (uint i = _i; i \u003c rewardRateHistory.length; i++) {\n            if (rewardRateHistory[i].endTimestamp \u003c block.timestamp) {\n                if (i == _i) {\n                    _rate = _rate.add(rewardRateHistory[i].rewardRate.mul(rewardRateHistory[i].endTimestamp.sub(_startTimestemp)));\n                } else {\n                    _rate = _rate.add(rewardRateHistory[i].rewardRate.mul(rewardRateHistory[i].endTimestamp.sub(rewardRateHistory[i].startTimestamp)));\n                }\n            } else {\n                _rate = _rate.add(rewardRateHistory[i].rewardRate.mul(block.timestamp.sub(rewardRateHistory[i].startTimestamp)));\n            }\n        }\n        return _rate.div(_time);\n    }\n\n    function getStakers() public view returns (StakerData memory) {\n        return stakers[msg.sender];\n    }\n\n    function setRewardRate(uint256 _rewardRate) public onlyOwner {\n        rewardRate = _rewardRate;\n        rewardRateHistory[rewardRateHistory.length.sub(1)].endTimestamp = block.timestamp.sub(1);\n        rewardRateHistory.push(rewardRateData(_rewardRate, block.timestamp, type(uint256).max));\n    }\n\n    function withdraw(address _tokenAddress, uint256 _amount) public onlyOwner {\n        IERC20(_tokenAddress).transfer(msg.sender, _amount);\n    }\n\n    function setComRecipient(address _commissionRecipient) public onlyOwner {\n        commissionRecipient = _commissionRecipient;\n    }\n\n    function binarySearch(uint256 _startTimestemp) internal view returns (uint256) {\n        uint256 low = 0;\n        uint256 high = rewardRateHistory.length;\n        while (low \u003c high) {\n            uint256 mid = (low \u0026 high) + (low ^ high) / 2;\n            if (rewardRateHistory[mid].startTimestamp \u003e _startTimestemp) {\n                high = mid;\n            } else if (rewardRateHistory[mid].startTimestamp \u003c= _startTimestemp \u0026\u0026 rewardRateHistory[mid].endTimestamp \u003e= _startTimestemp) {\n                return mid;\n            } else {\n                low = mid.add(1);\n            }\n        }\n        if (low \u003e 0 \u0026\u0026 rewardRateHistory[low.sub(1)].startTimestamp \u003c= _startTimestemp \u0026\u0026 rewardRateHistory[low.sub(1)].endTimestamp \u003e= _startTimestemp) {\n            return low.sub(1);\n        } else {\n            return low;\n        }\n    }\n}"}}