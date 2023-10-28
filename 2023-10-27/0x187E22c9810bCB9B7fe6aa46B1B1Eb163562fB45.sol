{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"},"market.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport \"./Ownable.sol\";\nimport \"./IERC20.sol\";\nimport \"./Pausable.sol\";\nimport \"./SafeMath.sol\";\n\ncontract crowdsale is Ownable, Pausable {\n    using SafeMath for uint256;\n\n    IERC20 public XPADToken;\n    IERC20 public USDToken;\n\n    address public USDRecipient;\n\n    struct Vesting {\n        uint256 startTimeVesting;\n        uint256 vestingDays;\n        uint256 value;\n        uint256 claimed;\n    }\n    struct Round {\n        uint256 vesting;\n        uint256 price;\n        uint256 priveDiv;\n        uint256 maxTotalAmount;\n    }\n    \n    struct salesInfo {\n        bool pause;\n        uint256 minUSD;\n        uint256 totalSold;\n        address addressUSD;\n        Round[] allRounds;\n        mapping(address =\u003e Vesting[]) addressToS;\n    }\n    mapping(address =\u003e salesInfo) internal salesToken;\n    address[] public allSalesToken;\n\n    event saleEvent(address tokenAddress, uint256 totalSold);\n\n    constructor(address _USDTokenAddress, address _XPADTokenAddress, address _USDRecipient) {\n        pause();\n        USDRecipient = _USDRecipient;\n        XPADToken = IERC20(_XPADTokenAddress);\n        USDToken = IERC20(_USDTokenAddress);\n\n        salesToken[_XPADTokenAddress].allRounds.push(Round(0, 5, 100, 19000000 ether));\n        salesToken[_XPADTokenAddress].allRounds.push(Round(120, 5, 100, 19000000 ether));\n        salesToken[_XPADTokenAddress].allRounds.push(Round(90, 7, 100, 38000000 ether));\n        salesToken[_XPADTokenAddress].allRounds.push(Round(60, 10, 100, 38000000 ether));\n        salesToken[_XPADTokenAddress].allRounds.push(Round(30, 15, 100, 38000000 ether));\n        salesToken[_XPADTokenAddress].minUSD = 100 ether;\n        salesToken[_XPADTokenAddress].pause = false;\n        salesToken[_XPADTokenAddress].addressUSD = _USDTokenAddress;\n        allSalesToken.push(_XPADTokenAddress);\n    }\n\n\n    function getSaleInfo(address _tokenAddress) public view returns (bool, uint256, uint256, address) {\n        return (salesToken[_tokenAddress].pause, salesToken[_tokenAddress].minUSD, salesToken[_tokenAddress].totalSold, salesToken[_tokenAddress].addressUSD);\n    }\n\n    function getRound(address _tokenAddress) public view returns (uint) {\n        uint256 _totalSoldRound = 0;\n        for (uint256 i = 0; i \u003c salesToken[_tokenAddress].allRounds.length; i++) {\n            _totalSoldRound = _totalSoldRound.add(salesToken[_tokenAddress].allRounds[i].maxTotalAmount);\n            if (salesToken[_tokenAddress].totalSold \u003c _totalSoldRound) {\n                return i;\n            }\n        }\n        return 0;\n    }\n\n    function getAllRounds(address _tokenAddress) public view returns (Round[] memory) {\n        return salesToken[_tokenAddress].allRounds;\n    }\n\n    function getAllVesting(address _tokenAddress) public view returns (Vesting[] memory) {\n        return salesToken[_tokenAddress].addressToS[msg.sender];\n    }\n\n    function getCurrentMaxTotalAmount(address _tokenAddress) internal view returns (uint) {\n        uint256 _totalSoldRound = 0;\n        for (uint256 i = 0; i \u003c salesToken[_tokenAddress].allRounds.length; i++) {\n            _totalSoldRound = _totalSoldRound.add(salesToken[_tokenAddress].allRounds[i].maxTotalAmount);\n            if (salesToken[_tokenAddress].totalSold \u003c _totalSoldRound) {\n                return _totalSoldRound;\n            }\n        }\n        return 0;\n    }\n\n    function sale(address _tokenAddress, uint256 amount) public whenNotPaused {  \n        require(salesToken[_tokenAddress].pause == true, \"sale suspended\");\n        uint256 amountUSD;\n        uint256 _round = getRound(_tokenAddress);\n        uint256 _maxAmount = getCurrentMaxTotalAmount(_tokenAddress) - salesToken[_tokenAddress].totalSold;\n\n        if (amount \u003e _maxAmount) {\n            amount = _maxAmount;\n            amountUSD = amount.mul(salesToken[_tokenAddress].allRounds[_round].price).div(salesToken[_tokenAddress].allRounds[_round].priveDiv);\n        } else {\n            amountUSD = amount.mul(salesToken[_tokenAddress].allRounds[_round].price).div(salesToken[_tokenAddress].allRounds[_round].priveDiv);\n            require(amountUSD \u003e= salesToken[_tokenAddress].minUSD, \"The minimum purchase amount for the XPAD token\");\n        }\n\n        salesToken[_tokenAddress].addressToS[msg.sender].push(Vesting(block.timestamp, salesToken[_tokenAddress].allRounds[_round].vesting, amount, 0));\n        salesToken[_tokenAddress].totalSold = salesToken[_tokenAddress].totalSold.add(amount);\n        IERC20(salesToken[_tokenAddress].addressUSD).transferFrom(msg.sender, USDRecipient, amountUSD);\n        emit saleEvent(_tokenAddress, salesToken[_tokenAddress].totalSold);\n    }\n\n    function claim(address _tokenAddress) public {\n        uint256 _climAmount;\n\n        for (uint256 i = 0; i \u003c salesToken[_tokenAddress].addressToS[msg.sender].length; i++) {\n            uint256 _totalTime = block.timestamp.sub(salesToken[_tokenAddress].addressToS[msg.sender][i].startTimeVesting);\n            uint256 _roundClaimAmount;\n            if (_totalTime \u003e= salesToken[_tokenAddress].addressToS[msg.sender][i].vestingDays.mul(86400)) {\n                _roundClaimAmount = salesToken[_tokenAddress].addressToS[msg.sender][i].value;\n            } else {\n                if (salesToken[_tokenAddress].addressToS[msg.sender][i].vestingDays \u003c 30) {\n                    _roundClaimAmount = 0;\n                } else {\n                    _roundClaimAmount = salesToken[_tokenAddress].addressToS[msg.sender][i].value.mul(_totalTime.div(2592000)).div(salesToken[_tokenAddress].addressToS[msg.sender][i].vestingDays.div(30));\n                }\n            }\n            _climAmount = _climAmount.add(_roundClaimAmount).sub(salesToken[_tokenAddress].addressToS[msg.sender][i].claimed);\n            salesToken[_tokenAddress].addressToS[msg.sender][i].claimed = _roundClaimAmount;\n        }\n\n        require(_climAmount \u003e 0, \"Available for claim 0 XPP\");\n        IERC20(_tokenAddress).transfer(msg.sender, _climAmount);\n    }\n\n    function getClaimAmount(address _tokenAddress) public view returns (uint) {\n        uint256 _climAmount;\n\n        for (uint256 i = 0; i \u003c salesToken[_tokenAddress].addressToS[msg.sender].length; i++) {\n            uint256 _totalTime = block.timestamp.sub(salesToken[_tokenAddress].addressToS[msg.sender][i].startTimeVesting);\n            uint256 _roundClaimAmount;\n            if (_totalTime \u003e= salesToken[_tokenAddress].addressToS[msg.sender][i].vestingDays.mul(86400)) {\n                _roundClaimAmount = salesToken[_tokenAddress].addressToS[msg.sender][i].value;\n            } else {\n                if (salesToken[_tokenAddress].addressToS[msg.sender][i].vestingDays \u003c 30) {\n                    _roundClaimAmount = 0;\n                } else {\n                    _roundClaimAmount = salesToken[_tokenAddress].addressToS[msg.sender][i].value.mul(_totalTime.div(2592000)).div(salesToken[_tokenAddress].addressToS[msg.sender][i].vestingDays.div(30));\n                }\n            }\n            _climAmount = _climAmount.add(_roundClaimAmount).sub(salesToken[_tokenAddress].addressToS[msg.sender][i].claimed);\n        }\n        return _climAmount;\n    }\n\n    function getTotalClaimAmount(address _tokenAddress) public view returns (uint) {\n        uint256 _climAmount;\n        for (uint256 i = 0; i \u003c salesToken[_tokenAddress].addressToS[msg.sender].length; i++) {\n            _climAmount = _climAmount.add(salesToken[_tokenAddress].addressToS[msg.sender][i].value).sub(salesToken[_tokenAddress].addressToS[msg.sender][i].claimed);\n        }\n        return _climAmount;\n    }\n\n    // only owner functions\n\n    function pause() public onlyOwner {\n        _pause();\n    }\n\n    function unpause() public onlyOwner {\n        _unpause();\n    }\n\n    function pauseTokenSale(address _tokenAddress) public onlyOwner {\n        salesToken[_tokenAddress].pause = false;\n    }\n\n    function unpauseTokenSale(address _tokenAddress) public onlyOwner {\n        salesToken[_tokenAddress].pause = true;\n    }\n\n    function addTokenSale(address _tokenAddress, uint256 _minUSD, address _addressUSD) public onlyOwner {\n        require(salesToken[_tokenAddress].addressUSD == address(0), \"this token is already being sold\");\n        salesToken[_tokenAddress].pause = false;\n        salesToken[_tokenAddress].minUSD = _minUSD;\n        salesToken[_tokenAddress].addressUSD = _addressUSD;\n        allSalesToken.push(_tokenAddress);\n    }\n\n    function changeTokenSale(address _tokenAddress, uint256 _minUSD, address _addressUSD) public onlyOwner {\n        require(salesToken[_tokenAddress].addressUSD != address(0), \"this token is not for sale yet\");\n        salesToken[_tokenAddress].minUSD = _minUSD;\n        salesToken[_tokenAddress].addressUSD = _addressUSD;\n    }\n\n    function changeRound(address _tokenAddress, uint256 i, uint256 _vesting, uint256 _price, uint256 _priceDiv, uint256 _maxTotalAmount) public onlyOwner {\n        salesToken[_tokenAddress].allRounds[i] = Round(_vesting, _price, _priceDiv, _maxTotalAmount);\n    }\n\n    function addRound(address _tokenAddress, uint256 index, uint256 vesting, uint256 price, uint256 _priceDiv, uint256 maxTotalAmount) public onlyOwner {\n        require(index \u003e= 0 \u0026\u0026 index \u003c= salesToken[_tokenAddress].allRounds.length, \"Invalid index\");\n\n        if (salesToken[_tokenAddress].allRounds.length == 0) {\n            salesToken[_tokenAddress].allRounds.push(Round(vesting, price, _priceDiv, maxTotalAmount));\n        } else {\n            salesToken[_tokenAddress].allRounds.push(salesToken[_tokenAddress].allRounds[salesToken[_tokenAddress].allRounds.length.sub(1)]);\n            for (uint256 i = salesToken[_tokenAddress].allRounds.length.sub(1); i \u003e index; i--) {\n                uint256 prevIndex = i - 1;\n                salesToken[_tokenAddress].allRounds[i] = salesToken[_tokenAddress].allRounds[prevIndex];\n            }\n            salesToken[_tokenAddress].allRounds[index] = Round(vesting, price, _priceDiv, maxTotalAmount);\n        }\n    }\n\n    function deleteRound(address _tokenAddress, uint256 _i) public onlyOwner {\n        for (uint256 i = _i; i \u003c salesToken[_tokenAddress].allRounds.length; i++) {\n            if (i.add(1) \u003c salesToken[_tokenAddress].allRounds.length) {\n                salesToken[_tokenAddress].allRounds[i] = salesToken[_tokenAddress].allRounds[i.add(1)];\n            }\n        }\n        salesToken[_tokenAddress].allRounds.pop();\n    }\n\n    function setTotalSold(address _tokenAddress, uint256 _totalSold) public onlyOwner {\n        salesToken[_tokenAddress].totalSold = _totalSold;\n    }\n\n    function setUSDRecipient(address _address) public onlyOwner {\n        USDRecipient = _address;\n    }\n\n    function withdraw(address _tokenAddress, uint256 _amount) public onlyOwner {\n        IERC20(_tokenAddress).transfer(msg.sender, _amount);\n    }\n\n    function getVestingDataOwner(address _tokenAddress, address _address) public onlyOwner view returns (Vesting[] memory){\n        return salesToken[_tokenAddress].addressToS[_address];\n    }\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"Pausable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\nabstract contract Pausable is Context {\n    /**\n     * @dev Emitted when the pause is triggered by `account`.\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by `account`.\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state.\n     */\n    constructor() {\n        _paused = false;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    modifier whenNotPaused() {\n        _requireNotPaused();\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    modifier whenPaused() {\n        _requirePaused();\n        _;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view virtual returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Throws if the contract is paused.\n     */\n    function _requireNotPaused() internal view virtual {\n        require(!paused(), \"Pausable: paused\");\n    }\n\n    /**\n     * @dev Throws if the contract is not paused.\n     */\n    function _requirePaused() internal view virtual {\n        require(paused(), \"Pausable: not paused\");\n    }\n\n    /**\n     * @dev Triggers stopped state.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    function _pause() internal virtual whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Returns to normal state.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    function _unpause() internal virtual whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)\n\npragma solidity ^0.8.0;\n\n// CAUTION\n// This version of SafeMath should only be used with Solidity 0.8 or later,\n// because it relies on the compiler\u0027s built in overflow checks.\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\n *\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\n * now has built in overflow checking.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            uint256 c = a + b;\n            if (c \u003c a) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b \u003e a) return (false, 0);\n            return (true, a - b);\n        }\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n            // benefit is lost if \u0027b\u0027 is also tested.\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n            if (a == 0) return (true, 0);\n            uint256 c = a * b;\n            if (c / a != b) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a / b);\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a % b);\n        }\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a + b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a * b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator.\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003c= a, errorMessage);\n            return a - b;\n        }\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a / b;\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a % b;\n        }\n    }\n}\n"}}