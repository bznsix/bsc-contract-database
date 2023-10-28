{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.3.2 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"gtErc20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.3.2 (token/ERC20/ERC20.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./IERC20Metadata.sol\";\r\nimport \"./Ownable.sol\";\r\nimport \"./IPancakePair.sol\";\r\nimport \"./SafeMath.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n * For a generic mechanism see {ERC20PresetMinterPauser}.\r\n *\r\n * TIP: For a detailed writeup see our guide\r\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\r\n * to implement supply mechanisms].\r\n *\r\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\r\n * instead returning `false` on failure. This behavior is nonetheless\r\n * conventional and does not conflict with the expectations of ERC20\r\n * applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See {IERC20-approve}.\r\n */\r\ncontract GtERC20 is Ownable, IERC20, IERC20Metadata {\r\n    using SafeMath for uint256;\r\n    mapping(address =\u003e uint256) private _balances;\r\n\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    address private _pancakePair0;\r\n    address private _pancakePair1;\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    mapping(address =\u003e bool) private _isExcludedFromFee;\r\n\r\n    /**\r\n     * @dev Sets the values for {name} and {symbol}.\r\n     *\r\n     * The default value of {decimals} is 18. To select a different value for\r\n     * {decimals} you should overload it.\r\n     *\r\n     * All two of these values are immutable: they can only be set once during\r\n     * construction.\r\n     */\r\n    constructor() {\r\n        _name = \"GT\";\r\n        _symbol = \"GT\";\r\n        _totalSupply = 1e26;\r\n        _decimals = 18;\r\n        \r\n        _balances[_msgSender()] = _totalSupply;\r\n        setEnableWhiteList(false);\r\n    }\r\n\r\n    function setPancakePairAddr(address addr0, address addr1) public onlyOwner {\r\n        _pancakePair0 = addr0;\r\n        _pancakePair1 = addr1;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view virtual override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the\r\n     * name.\r\n     */\r\n    function symbol() public view virtual override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\r\n     *\r\n     * Tokens usually opt for a value of 18, imitating the relationship between\r\n     * Ether and Wei. This is the value {ERC20} uses, unless this function is\r\n     * overridden;\r\n     *\r\n     * NOTE: This information is only used for _display_ purposes: it in\r\n     * no way affects any of the arithmetic of the contract, including\r\n     * {IERC20-balanceOf} and {IERC20-transfer}.\r\n     */\r\n    function decimals() public view virtual override returns (uint8) {\r\n        return _decimals;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view virtual override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view virtual override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `recipient` cannot be the zero address.\r\n     * - the caller must have a balance of at least `amount`.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `sender` and `recipient` cannot be the zero address.\r\n     * - `sender` must have a balance of at least `amount`.\r\n     * - the caller must have allowance for ``sender``\u0027s tokens of at least\r\n     * `amount`.\r\n     */\r\n    function transferFrom(\r\n        address sender,\r\n        address recipient,\r\n        uint256 amount\r\n    ) public virtual override returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n\r\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\r\n        require(currentAllowance \u003e= amount, \"Btb ERC20: transfer amount exceeds allowance\");\r\n        unchecked {\r\n            _approve(sender, _msgSender(), currentAllowance - amount);\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     * - `spender` must have allowance for the caller of at least\r\n     * `subtractedValue`.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\r\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\r\n        unchecked {\r\n            _approve(_msgSender(), spender, currentAllowance - subtractedValue);\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves `amount` of tokens from `sender` to `recipient`.\r\n     *\r\n     * This internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `sender` cannot be the zero address.\r\n     * - `recipient` cannot be the zero address.\r\n     * - `sender` must have a balance of at least `amount`.\r\n     */\r\n    function _transfer(\r\n        address sender,\r\n        address recipient,\r\n        uint256 amount\r\n    ) internal onlyNotPause onlyWhiteList virtual {\r\n\r\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\r\n        //require(recipient != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _beforeTokenTransfer(sender, recipient, amount);\r\n\r\n        uint256 burn_amount = 0;\r\n        uint256 receive_amount = amount;\r\n\r\n        if(recipient == _pancakePair0 || recipient == _pancakePair1) {\r\n            burn_amount = amount * 5 / 100;\r\n            receive_amount = amount.sub(burn_amount);\r\n        }\r\n\r\n        if(sender == _pancakePair0 || sender == _pancakePair1) {\r\n            burn_amount = amount * 5 / 100;\r\n            receive_amount = amount.sub(burn_amount);\r\n        }\r\n\r\n        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {\r\n            burn_amount = 0;\r\n            receive_amount = amount;\r\n        }\r\n\r\n        if(recipient==address(0)){\r\n            burn_amount = amount;\r\n            receive_amount = 0;\r\n        }\r\n\r\n        if(receive_amount\u003e0){\r\n            _balances[sender] = _balances[sender].sub(receive_amount, \"ERC20: transfer amount exceeds balance\");\r\n            _balances[recipient] = _balances[recipient].add(receive_amount);\r\n        }\r\n\r\n        emit Transfer(sender, recipient, amount);\r\n\r\n        _afterTokenTransfer(sender, recipient, amount);\r\n\r\n\r\n        if( burn_amount \u003e 0) {\r\n            _burn(sender, burn_amount);\r\n        }\r\n    }\r\n\r\n    function isExcludedFromFee(address account) public view returns (bool) {\r\n        return _isExcludedFromFee[account];\r\n    }\r\n\r\n    function excludeFromFee(address account) public onlyOwner {\r\n        _isExcludedFromFee[account] = true;\r\n    }\r\n\r\n    function includeInFee(address account) public onlyOwner {\r\n        _isExcludedFromFee[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `account` cannot be the zero address.\r\n     * - `account` must have at least `amount` tokens.\r\n     */\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _beforeTokenTransfer(account, address(0), amount);\r\n\r\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n\r\n    function burnFrom(address account, uint256 amount) public virtual returns (bool){\r\n        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, \"ERC20: burn amount exceeds allowance\");\r\n\r\n        _approve(account, _msgSender(), decreasedAllowance);\r\n        _burn(account, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\r\n     *\r\n     * This internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `owner` cannot be the zero address.\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function _approve(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before any transfer of tokens. This includes\r\n     * minting and burning.\r\n     *\r\n     * Calling conditions:\r\n     *\r\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\r\n     * will be transferred to `to`.\r\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\r\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\r\n     * - `from` and `to` are never both zero.\r\n     *\r\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\r\n     */\r\n    function _beforeTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n\r\n    /**\r\n     * @dev Hook that is called after any transfer of tokens. This includes\r\n     * minting and burning.\r\n     *\r\n     * Calling conditions:\r\n     *\r\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\r\n     * has been transferred to `to`.\r\n     * - when `from` is zero, `amount` tokens have been minted for `to`.\r\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens have been burned.\r\n     * - `from` and `to` are never both zero.\r\n     *\r\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\r\n     */\r\n    function _afterTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint256 amount\n    ) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.3.2 (token/ERC20/extensions/IERC20Metadata.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"},"IPancakePair.sol":{"content":"pragma solidity ^0.8.0;\n\ninterface IPancakePair {\n    event Approval(address indexed owner, address indexed spender, uint value);\n    event Transfer(address indexed from, address indexed to, uint value);\n\n    function name() external pure returns (string memory);\n    function symbol() external pure returns (string memory);\n    function decimals() external pure returns (uint8);\n    function totalSupply() external view returns (uint);\n    function balanceOf(address owner) external view returns (uint);\n    function allowance(address owner, address spender) external view returns (uint);\n\n    function approve(address spender, uint value) external returns (bool);\n    function transfer(address to, uint value) external returns (bool);\n    function transferFrom(address from, address to, uint value) external returns (bool);\n\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\n    function PERMIT_TYPEHASH() external pure returns (bytes32);\n    function nonces(address owner) external view returns (uint);\n\n    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;\n\n    event Mint(address indexed sender, uint amount0, uint amount1);\n    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);\n    event Swap(\n        address indexed sender,\n        uint amount0In,\n        uint amount1In,\n        uint amount0Out,\n        uint amount1Out,\n        address indexed to\n    );\n    event Sync(uint112 reserve0, uint112 reserve1);\n\n    function MINIMUM_LIQUIDITY() external pure returns (uint);\n    function factory() external view returns (address);\n    function token0() external view returns (address);\n    function token1() external view returns (address);\n    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\n    function price0CumulativeLast() external view returns (uint);\n    function price1CumulativeLast() external view returns (uint);\n    function kLast() external view returns (uint);\n\n    function mint(address to) external returns (uint liquidity);\n    function burn(address to) external returns (uint amount0, uint amount1);\n    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;\n    function skim(address to) external;\n    function sync() external;\n\n    function initialize(address, address) external;\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.3.2 (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n    \n    //address private _gameServerCaller ;\n    \n    //address private _nftMinterContractAddress;\n    \n    bool private _pause = false;\n    \n    mapping(address =\u003e bool) private _whiteListCanTransfer;\n    \n    bool private _enableWhiteList = false;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n    event GSCallerShipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _pause = false;\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    modifier onlyNotPause() {\n        require(!_pause, \"Pause: status of transfer is pause!\");\n        _;\n    }\n    \n    function currentWhiteListStatu() public view returns(bool){\n        return _enableWhiteList;\n    }\n    \n    function setEnableWhiteList(bool newVal) public onlyOwner {\n        _enableWhiteList = newVal;\n    }\n    \n    function addAddressToWhiteLsit(address user) public onlyOwner {\n        _whiteListCanTransfer[user] = true;\n    }\n    \n    function removeAddressFromWhiteLst(address user) public onlyOwner {\n        _whiteListCanTransfer[user] = false;\n    }\n    \n    modifier onlyWhiteList() {\n        if (_enableWhiteList) {\n            if (!_whiteListCanTransfer[_msgSender()]){\n                require(1!=1, \"Ownable:_msgSender is not in white list!\");\n            }\n        }\n        _;\n    }\n    //check white list ,not look _enableWhiteList\n    modifier onlyWhiteListStritly() {\n        if (!_whiteListCanTransfer[_msgSender()]){\n            require(1!=1, \"Ownable:_msgSender is not in white list!\");\n        }\n        _;\n    }\n    \n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n    \n    function modifyTransferStatu(bool newStatu) public virtual onlyOwner {\n        _pause = newStatu;\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.3.2 (utils/math/SafeMath.sol)\n\npragma solidity ^0.8.0;\n\n// CAUTION\n// This version of SafeMath should only be used with Solidity 0.8 or later,\n// because it relies on the compiler\u0027s built in overflow checks.\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\n *\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\n * now has built in overflow checking.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            uint256 c = a + b;\n            if (c \u003c a) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b \u003e a) return (false, 0);\n            return (true, a - b);\n        }\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n            // benefit is lost if \u0027b\u0027 is also tested.\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n            if (a == 0) return (true, 0);\n            uint256 c = a * b;\n            if (c / a != b) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a / b);\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a % b);\n        }\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a + b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a * b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator.\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003c= a, errorMessage);\n            return a - b;\n        }\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a / b;\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(\n        uint256 a,\n        uint256 b,\n        string memory errorMessage\n    ) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a % b;\n        }\n    }\n}\n"}}