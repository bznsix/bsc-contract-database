{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\nimport \"./IERC20Metadata.sol\";\nimport \"./Context.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * The default value of {decimals} is 18. To change this, you should override\n * this function so it returns a different value.\n *\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\n * instead returning `false` on failure. This behavior is nonetheless\n * conventional and does not conflict with the expectations of ERC20\n * applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20, IERC20Metadata {\n    mapping(address =\u003e uint256) private _balances;\n\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}.\n     *\n     * All two of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual override returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual override returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the default value returned by this function, unless\n     * it\u0027s overridden.\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual override returns (uint8) {\n        return 18;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address to, uint256 amount) public virtual override returns (bool) {\n        address owner = _msgSender();\n        _transfer(owner, to, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on\n     * `transferFrom`. This is semantically equivalent to an infinite approval.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        address owner = _msgSender();\n        _approve(owner, spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * NOTE: Does not update the allowance if the current allowance\n     * is the maximum `uint256`.\n     *\n     * Requirements:\n     *\n     * - `from` and `to` cannot be the zero address.\n     * - `from` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``from``\u0027s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {\n        address spender = _msgSender();\n        _spendAllowance(from, spender, amount);\n        _transfer(from, to, amount);\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        address owner = _msgSender();\n        _approve(owner, spender, allowance(owner, spender) + addedValue);\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        address owner = _msgSender();\n        uint256 currentAllowance = allowance(owner, spender);\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\n        unchecked {\n            _approve(owner, spender, currentAllowance - subtractedValue);\n        }\n\n        return true;\n    }\n\n    /**\n     * @dev Moves `amount` of tokens from `from` to `to`.\n     *\n     * This internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `from` must have a balance of at least `amount`.\n     */\n    function _transfer(address from, address to, uint256 amount) internal virtual {\n        require(from != address(0), \"ERC20: transfer from the zero address\");\n        require(to != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(from, to, amount);\n\n        uint256 fromBalance = _balances[from];\n        require(fromBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\n        unchecked {\n            _balances[from] = fromBalance - amount;\n            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by\n            // decrementing then incrementing.\n            _balances[to] += amount;\n        }\n\n        emit Transfer(from, to, amount);\n\n        _afterTokenTransfer(from, to, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply += amount;\n        unchecked {\n            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.\n            _balances[account] += amount;\n        }\n        emit Transfer(address(0), account, amount);\n\n        _afterTokenTransfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        uint256 accountBalance = _balances[account];\n        require(accountBalance \u003e= amount, \"ERC20: burn amount exceeds balance\");\n        unchecked {\n            _balances[account] = accountBalance - amount;\n            // Overflow not possible: amount \u003c= accountBalance \u003c= totalSupply.\n            _totalSupply -= amount;\n        }\n\n        emit Transfer(account, address(0), amount);\n\n        _afterTokenTransfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.\n     *\n     * Does not update the allowance amount in case of infinite allowance.\n     * Revert if not enough allowance is available.\n     *\n     * Might emit an {Approval} event.\n     */\n    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {\n        uint256 currentAllowance = allowance(owner, spender);\n        if (currentAllowance != type(uint256).max) {\n            require(currentAllowance \u003e= amount, \"ERC20: insufficient allowance\");\n            unchecked {\n                _approve(owner, spender, currentAllowance - amount);\n            }\n        }\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * will be transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}\n\n    /**\n     * @dev Hook that is called after any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * has been transferred to `to`.\n     * - when `from` is zero, `amount` tokens have been minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens have been burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}\n}\n"},"ERC20Capped.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./ERC20.sol\";\n\n/**\n * @dev Extension of {ERC20} that adds a cap to the supply of tokens.\n */\nabstract contract ERC20Capped is ERC20 {\n    uint256 private immutable _cap;\n\n    /**\n     * @dev Sets the value of the `cap`. This value is immutable, it can only be\n     * set once during construction.\n     */\n    constructor(uint256 cap_) {\n        require(cap_ \u003e 0, \"ERC20Capped: cap is 0\");\n        _cap = cap_;\n    }\n\n    /**\n     * @dev Returns the cap on the token\u0027s total supply.\n     */\n    function cap() public view virtual returns (uint256) {\n        return _cap;\n    }\n\n    /**\n     * @dev See {ERC20-_mint}.\n     */\n    function _mint(address account, uint256 amount) internal virtual override {\n        require(ERC20.totalSupply() + amount \u003c= cap(), \"ERC20Capped: cap exceeded\");\n        super._mint(account, amount);\n    }\n}\n"},"ERC20Pausable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/ERC20Pausable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./ERC20.sol\";\nimport \"./Pausable.sol\";\n\n/**\n * @dev ERC20 token with pausable token transfers, minting and burning.\n *\n * Useful for scenarios such as preventing trades until the end of an evaluation\n * period, or having an emergency switch for freezing all token transfers in the\n * event of a large bug.\n *\n * IMPORTANT: This contract does not include public pause and unpause functions. In\n * addition to inheriting this contract, you must define both functions, invoking the\n * {Pausable-_pause} and {Pausable-_unpause} internal functions, with appropriate\n * access control, e.g. using {AccessControl} or {Ownable}. Not doing so will\n * make the contract unpausable.\n */\nabstract contract ERC20Pausable is ERC20, Pausable {\n    /**\n     * @dev See {ERC20-_beforeTokenTransfer}.\n     *\n     * Requirements:\n     *\n     * - the contract must not be paused.\n     */\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {\n        super._beforeTokenTransfer(from, to, amount);\n\n        require(!paused(), \"ERC20Pausable: token transfer while paused\");\n    }\n}\n"},"HomeUnity.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./ERC20.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Ownable2Step.sol\";\nimport \"./ERC20Capped.sol\";\nimport \"./ERC20Pausable.sol\";\n\ncontract HomeUnity is ERC20, ERC20Pausable, ERC20Capped, Ownable2Step {\n    using SafeMath for uint256;\n\n    constructor()\n        ERC20(\"Property Management System\", \"PMS\")\n        ERC20Capped(24000000000000000) { // 6 decimals\n    }\n\n    function decimals() public pure override returns (uint8) {\n        return 6;\n    }\n\n    function mint(address destination, uint256 amount) external onlyOwner {\n        _mint(destination, amount);\n    }\n\n    function pause()  external onlyOwner {\n        _pause();\n    }\n\n    function unpause()  external onlyOwner {\n        _unpause();\n    }\n\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {\n        super._beforeTokenTransfer(from, to, amount);\n    }\n\n    function _mint(address destination, uint256 amount) internal override(ERC20, ERC20Capped) {\n        super._mint(destination, amount);\n    }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n *\n * _Available since v4.1._\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"Ownable2Step.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Ownable.sol\";\n\n/**\n * @dev Contract module which provides access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership} and {acceptOwnership}.\n *\n * This module is used through inheritance. It will make available all functions\n * from parent (Ownable).\n */\nabstract contract Ownable2Step is Ownable {\n    address private _pendingOwner;\n\n    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Returns the address of the pending owner.\n     */\n    function pendingOwner() public view virtual returns (address) {\n        return _pendingOwner;\n    }\n\n    /**\n     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual override onlyOwner {\n        _pendingOwner = newOwner;\n        emit OwnershipTransferStarted(owner(), newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual override {\n        delete _pendingOwner;\n        super._transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev The new owner accepts the ownership transfer.\n     */\n    function acceptOwnership() public virtual {\n        address sender = _msgSender();\n        require(pendingOwner() == sender, \"Ownable2Step: caller is not the new owner\");\n        _transferOwnership(sender);\n    }\n}\n"},"Pausable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\nabstract contract Pausable is Context {\n    /**\n     * @dev Emitted when the pause is triggered by `account`.\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by `account`.\n     */\n    event Unpaused(address account);\n\n    bool private _paused;\n\n    /**\n     * @dev Initializes the contract in unpaused state.\n     */\n    constructor() {\n        _paused = false;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    modifier whenNotPaused() {\n        _requireNotPaused();\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    modifier whenPaused() {\n        _requirePaused();\n        _;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view virtual returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Throws if the contract is paused.\n     */\n    function _requireNotPaused() internal view virtual {\n        require(!paused(), \"Pausable: paused\");\n    }\n\n    /**\n     * @dev Throws if the contract is not paused.\n     */\n    function _requirePaused() internal view virtual {\n        require(paused(), \"Pausable: not paused\");\n    }\n\n    /**\n     * @dev Triggers stopped state.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    function _pause() internal virtual whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Returns to normal state.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    function _unpause() internal virtual whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)\n\npragma solidity ^0.8.0;\n\n// CAUTION\n// This version of SafeMath should only be used with Solidity 0.8 or later,\n// because it relies on the compiler\u0027s built in overflow checks.\n\n/**\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\n *\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\n * now has built in overflow checking.\n */\nlibrary SafeMath {\n    /**\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            uint256 c = a + b;\n            if (c \u003c a) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b \u003e a) return (false, 0);\n            return (true, a - b);\n        }\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n            // benefit is lost if \u0027b\u0027 is also tested.\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n            if (a == 0) return (true, 0);\n            uint256 c = a * b;\n            if (c / a != b) return (false, 0);\n            return (true, c);\n        }\n    }\n\n    /**\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a / b);\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\n     *\n     * _Available since v3.4._\n     */\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\n        unchecked {\n            if (b == 0) return (false, 0);\n            return (true, a % b);\n        }\n    }\n\n    /**\n     * @dev Returns the addition of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `+` operator.\n     *\n     * Requirements:\n     *\n     * - Addition cannot overflow.\n     */\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a + b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting on\n     * overflow (when the result is negative).\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a - b;\n    }\n\n    /**\n     * @dev Returns the multiplication of two unsigned integers, reverting on\n     * overflow.\n     *\n     * Counterpart to Solidity\u0027s `*` operator.\n     *\n     * Requirements:\n     *\n     * - Multiplication cannot overflow.\n     */\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a * b;\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator.\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a / b;\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting when dividing by zero.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return a % b;\n    }\n\n    /**\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\n     * overflow (when the result is negative).\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {trySub}.\n     *\n     * Counterpart to Solidity\u0027s `-` operator.\n     *\n     * Requirements:\n     *\n     * - Subtraction cannot overflow.\n     */\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003c= a, errorMessage);\n            return a - b;\n        }\n    }\n\n    /**\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\n     * division by zero. The result is rounded towards zero.\n     *\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\n     * uses an invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a / b;\n        }\n    }\n\n    /**\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\n     * reverting with custom message when dividing by zero.\n     *\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\n     * message unnecessarily. For custom revert reasons use {tryMod}.\n     *\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\n     * invalid opcode to revert (consuming all remaining gas).\n     *\n     * Requirements:\n     *\n     * - The divisor cannot be zero.\n     */\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        unchecked {\n            require(b \u003e 0, errorMessage);\n            return a % b;\n        }\n    }\n}\n"}}