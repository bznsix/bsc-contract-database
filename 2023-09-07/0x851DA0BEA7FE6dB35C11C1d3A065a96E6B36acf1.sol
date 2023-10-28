{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address payable) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes memory) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\nimport \"./Context.sol\";\nimport \"./IERC20.sol\";\nimport \"./SafeMath.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\ncontract ERC20 is Context, IERC20 {\n    using SafeMath for uint256;\n\n    mapping (address =\u003e uint256) private _balances;\n\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n    uint8 private _decimals;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with\n     * a default value of 18.\n     *\n     * To select a different value for {decimals}, use {_setupDecimals}.\n     *\n     * All three of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor (string memory name_, string memory symbol_) public {\n        _name = name_;\n        _symbol = symbol_;\n        _decimals = 18;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5,05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is\n     * called.\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual returns (uint8) {\n        return _decimals;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual override returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual override returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `recipient` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * Requirements:\n     *\n     * - `sender` and `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``sender``\u0027s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \"ERC20: transfer amount exceeds allowance\"));\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \"ERC20: decreased allowance below zero\"));\n        return true;\n    }\n\n    /**\n     * @dev Moves tokens `amount` from `sender` to `recipient`.\n     *\n     * This is internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `sender` cannot be the zero address.\n     * - `recipient` cannot be the zero address.\n     * - `sender` must have a balance of at least `amount`.\n     */\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"ERC20: transfer from the zero address\");\n        require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(sender, recipient, amount);\n\n        _balances[sender] = _balances[sender].sub(amount, \"ERC20: transfer amount exceeds balance\");\n        _balances[recipient] = _balances[recipient].add(amount);\n        emit Transfer(sender, recipient, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply = _totalSupply.add(amount);\n        _balances[account] = _balances[account].add(amount);\n        emit Transfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        _balances[account] = _balances[account].sub(amount, \"ERC20: burn amount exceeds balance\");\n        _totalSupply = _totalSupply.sub(amount);\n        emit Transfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Sets {decimals} to a value other than the default one of 18.\n     *\n     * WARNING: This function should only be called from the constructor. Most\n     * applications that interact with token contracts will not expect\n     * {decimals} to ever change, and may work incorrectly if it does.\n     */\n    function _setupDecimals(uint8 decimals_) internal virtual {\n        _decimals = decimals_;\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * will be to transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\n\ninterface IERC20 {\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `recipient`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `sender` to `recipient` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\nimport \"./Context.sol\";\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor () internal {\n        address msgSender = _msgSender();\n        _owner = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}\n"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\nlibrary SafeMath {\n\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a, \"SafeMath: subtraction overflow\");\n        return a - b;\n    }\n\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) return 0;\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003e 0, \"SafeMath: division by zero\");\n        return a / b;\n    }\n\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003e 0, \"SafeMath: modulo by zero\");\n        return a % b;\n    }\n\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003c= a, errorMessage);\n        return a - b;\n    }\n\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b \u003e 0, errorMessage);\n        return a / b;\n    }\n\n}\n"},"Token.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\npragma solidity \u003e=0.6.0 \u003c0.8.0;\n\nimport \"./ERC20.sol\";\nimport \"./SafeMath.sol\";\nimport \"./Ownable.sol\";\n\n\ncontract Token is ERC20, Ownable {\n    using SafeMath for uint256;\n\n    uint256 private constant _percent = 21;\n    uint256 private constant _stakingPeriodInDays = 365;\n    uint256 private constant _withdrawalPeriod = 2 weeks;\n\n    constructor()  ERC20(\u0027Oracle Meta Technologies\u0027, \u0027OMT\u0027) {\n        _setupDecimals(4);\n        _mint(msg.sender, 1_100_000_000 * 1e4);\n    }\n\n    struct Stake {\n        uint256 id;\n        uint256 startAt;\n        uint256 reward;\n        uint256 profitCount;\n        uint256 amount;\n    }\n\n    address[] private _stakeholders;\n\n    mapping(address =\u003e Stake[]) private _stakes;\n\n    function createStake(uint256 _amount) external returns (bool)\n    {\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n\n        _burn(msg.sender, _amount);\n        _addStakeholder(msg.sender);\n        uint256 stakeNumber = _stakes[msg.sender].length + 1;\n\n        _stakes[msg.sender].push(\n            Stake({\n                id: stakeNumber,\n                amount: _amount,\n                reward : 0,\n                profitCount: 0,\n                startAt: block.timestamp\n            })\n        );\n\n        return true;\n    }\n\n    function isStakeholder(address _address) public view returns (bool, uint256)\n    {\n        for (uint256 s = 0; s \u003c _stakeholders.length; s += 1){\n            if (_address == _stakeholders[s]) return (true, s);\n        }\n        return (false, 0);\n    }\n\n    function getStake(address _stakeholder, uint256 _id) public view returns (uint256, uint256, uint256, uint256, uint256)\n    {\n        for (uint256 s = 0; s \u003c _stakes[_stakeholder].length; s += 1) {\n            if (_stakes[_stakeholder][s].id == _id) {\n                return (\n                    _stakes[_stakeholder][s].id,\n                    _stakes[_stakeholder][s].startAt,\n                    _stakes[_stakeholder][s].reward,\n                    _stakes[_stakeholder][s].profitCount,\n                    _stakes[_stakeholder][s].amount\n                );\n            }\n        }\n\n        return (0,0,0,0,0);\n    }\n\n    function totalStakes() public view returns (uint256)\n    {\n        uint256 _totalStakes = 0;\n        for (uint256 s = 0; s \u003c _stakeholders.length; s += 1){\n            _totalStakes += _stakes[_stakeholders[s]].length;\n        }\n        return _totalStakes;\n    }\n\n    function stakesCount(address _address) public view virtual returns (uint)\n    {\n        return _stakes[_address].length;\n    }\n\n    function getStakesIds(address _stakeholder) external view returns (uint[] memory)\n    {\n        uint[] memory ids = new uint[](_stakes[_stakeholder].length);\n\n        for (uint256 s = 0; s \u003c _stakes[_stakeholder].length; s += 1) {\n            ids[s] = _stakes[_stakeholder][s].id;\n        }\n\n        return ids;\n    }\n\n    ////\n\n    function calculateDailyReward(address _stakeholder, uint256 _stakeId) public view returns(uint256)  {\n        (,,,,uint256 amount) = getStake(_stakeholder, _stakeId);\n        return _stakeDailyProfit(amount);\n    }\n\n    function getAvailableProfitCount(address _stakeholder, uint256 _stakeId) public view returns (uint256)\n    {\n        (,uint256 startAt,,uint256 profitCount,) = getStake(_stakeholder, _stakeId);\n\n        return _stakeAvailableProfits(startAt, profitCount);\n    }\n\n    function getAward(uint256 _stakeId) public view returns (uint256)\n    {\n        (,uint256 startAt,,uint256 profitCount, uint256 amount) = getStake(msg.sender, _stakeId);\n\n        return _stakeAward(amount, startAt, profitCount);\n    }\n\n    function makeAward(uint256 _stakeId) public payable returns (bool) {\n        (,uint256 startAt,,uint256 profitCount, uint256 amount) = getStake(msg.sender, _stakeId);\n\n\n        uint256 award = _stakeAward(amount, startAt, profitCount);\n        uint256 availableProfitCount = _stakeAvailableProfits(startAt, profitCount);\n\n        if (award \u003c= 0) {\n            return false;\n        }\n\n        if (availableProfitCount \u003c= 0) {\n            return false;\n        }\n\n        award = _takeOfCommissionFromAward(award);\n\n        for (uint256 s = 0; s \u003c _stakes[msg.sender].length; s += 1) {\n            if (_stakes[msg.sender][s].id == _stakeId) {\n                _stakes[msg.sender][s].profitCount = _stakes[msg.sender][s].profitCount.add(availableProfitCount);\n                _stakes[msg.sender][s].reward = _stakes[msg.sender][s].reward.add(award);\n            }\n        }\n\n        _mint(msg.sender, award);\n\n        return true;\n    }\n\n    function isStakeMayBeClosed(uint256 _stakeId) public view returns (bool)\n    {\n        (,uint256 startAt,,,) = getStake(msg.sender, _stakeId);\n\n        return _isStakeMayClosed(startAt);\n    }\n\n    function closeStaking(uint256 _stakeId) public payable returns (bool)\n    {\n        (,uint256 startAt,,uint256 profitCount, uint256 amount) = getStake(msg.sender, _stakeId);\n\n\n        if (_isStakeMayClosed(startAt) == false) {\n            return false;\n        }\n\n        uint256 award = _stakeAward(amount, startAt, profitCount);\n\n        award = _takeOfCommissionFromAward(award);\n\n        uint256 availableProfitCount = _stakeAvailableProfits(startAt, profitCount);\n\n        for (uint256 s = 0; s \u003c _stakes[msg.sender].length; s += 1) {\n            if (_stakes[msg.sender][s].id == _stakeId) {\n                delete _stakes[msg.sender][s];\n            }\n        }\n        if (_stakes[msg.sender].length == 0) {\n            (,uint256 index) = isStakeholder(msg.sender);\n            delete _stakeholders[index];\n        }\n\n        amount = amount.add(award);\n        if (amount \u003e 0) {\n            _mint(msg.sender, amount);\n        }\n        return true;\n    }\n\n    function _addStakeholder(address _stakeholder) private\n    {\n        (bool _isStakeholder, ) = isStakeholder(_stakeholder);\n        if(!_isStakeholder) _stakeholders.push(_stakeholder);\n    }\n\n    function  _stakeDailyProfit(uint256 _amount) private view returns (uint256) {\n\n        return _amount.div(100).mul(_percent).div(_stakingPeriodInDays);\n    }\n\n    function _stakeAvailableProfits(uint256 startAt, uint256 profitCount) private view returns (uint256) {\n        uint256 diff = block.timestamp.sub(startAt);\n        uint256 availableProfits = diff.div(_withdrawalPeriod).sub(profitCount);\n        uint256 maxAvailableProfitCount = 26 - profitCount;\n        if (availableProfits \u003e maxAvailableProfitCount) {\n            return maxAvailableProfitCount;\n        }\n        return availableProfits;\n    }\n\n    function _stakeAward(uint256 amount, uint256 startAt, uint256 profitCount) private view returns (uint256)\n    {\n        uint256 availableProfits = _stakeAvailableProfits(startAt, profitCount);\n        uint256 profitByDay = _stakeDailyProfit(amount);\n        if (profitByDay \u003c= 0) {\n            return 0;\n        }\n\n        return profitByDay.mul(14).mul(availableProfits);\n    }\n\n    function _isStakeMayClosed(uint256 startAt) private view returns (bool)\n    {\n        return (block.timestamp - startAt) / 365 days \u003e= 1;\n    }\n\n    function _takeOfCommissionFromAward(uint256 amount) private returns (uint256)\n    {\n        uint256 commission = amount.div(1000).mul(23);\n        _mint(owner(), commission.div(2));\n        return amount.sub(commission);\n    }\n\n}\n"}}