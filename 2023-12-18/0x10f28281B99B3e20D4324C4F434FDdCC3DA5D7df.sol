// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the ERC token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only autotetherally asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            _owner = newOwner;
        }
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

contract DwbToken is IERC20, Ownable {
    using SafeMath for uint256;
    IERC20 public tether;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _symbol;
    string private _name;
    uint8 private _decimals;
    uint256 private _tetherLiquidity;
    uint256 private _totalSupply;

    struct Transaction {
        string txType;
        uint256 amount;
        uint256 time;
    }
    mapping(address => Transaction[]) internal reports;

    constructor() {
        _name = "DWB Token";
        _symbol = "DWB";
        _decimals = 18;
        _tetherLiquidity = 0;
        _totalSupply = 0;
        tether = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function tetherLiquidity() public view returns (uint256) {
        return _tetherLiquidity;
    }

    function price() public view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(_tetherLiquidity, 10 ** uint256(_decimals)),
                _totalSupply
            );
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "Decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "Transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function transfer(
        address recipient,
        uint256 _amount
    ) external returns (bool) {
        require(
            _balances[_msgSender()] >=
                SafeMath.div(SafeMath.mul(_amount, 102), 100),
            "Insufficient balance."
        );

        uint256 recivedAmount = SafeMath.div(SafeMath.mul(_amount, 102), 100);
        uint256 sentAmount = SafeMath.div(SafeMath.mul(_amount, 99), 100);
        uint256 remainAmount = SafeMath.sub(recivedAmount, sentAmount);
        uint256 ownerAmount = SafeMath.div(remainAmount, 3);
        uint256 burnAmount = SafeMath.div(SafeMath.mul(remainAmount, 2), 3);

        _transfer(_msgSender(), address(this), recivedAmount);
        _transfer(address(this), recipient, sentAmount);
        _transfer(address(this), owner(), ownerAmount);

        emit Transfer(address(this), address(0), burnAmount);
        _balances[address(this)] = _balances[address(this)].sub(burnAmount);
        _totalSupply = _totalSupply.sub(burnAmount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 _amount
    ) external returns (bool) {
        require(
            _balances[sender] >= SafeMath.div(SafeMath.mul(_amount, 102), 100),
            "Insufficient balance."
        );

        uint256 recivedAmount = SafeMath.div(SafeMath.mul(_amount, 102), 100);
        uint256 sentAmount = SafeMath.div(SafeMath.mul(_amount, 99), 100);
        uint256 remainAmount = SafeMath.sub(recivedAmount, sentAmount);
        uint256 ownerAmount = SafeMath.div(remainAmount, 3);
        uint256 burnAmount = SafeMath.div(SafeMath.mul(remainAmount, 2), 3);

        _transfer(sender, address(this), recivedAmount);
        _transfer(address(this), recipient, sentAmount);
        _transfer(address(this), owner(), ownerAmount);

        emit Transfer(address(this), address(0), burnAmount);
        _balances[address(this)] = _balances[address(this)].sub(burnAmount);
        _totalSupply = _totalSupply.sub(burnAmount);

        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(_amount)
        );
        return true;
    }

    // Buy token = Mint new token
    function buy(address _wallet, uint256 _amount) external payable {
        require(_wallet != address(0), "Invalid wallet address");
        require(_amount > 0, "Tether amount should be greater than zero");
        tether.transferFrom(_msgSender(), address(this), _amount);
        mintToken(_wallet, _amount);
    }

    function mintToken(address _address, uint256 _amount) private {
        // _amount is tether
        uint256 liquidityFee = SafeMath.div(SafeMath.mul(_amount, 15), 1000);
        uint256 ownerFee = SafeMath.div(SafeMath.mul(_amount, 5), 1000);
        uint256 remainAmount = SafeMath.sub(
            _amount,
            SafeMath.add(liquidityFee, ownerFee)
        );
        _tetherLiquidity = SafeMath.add(_tetherLiquidity, liquidityFee);
        uint256 userMintAmount = SafeMath.div(
            SafeMath.mul(remainAmount, _totalSupply),
            _tetherLiquidity
        );
        uint256 ownerMintAmount = SafeMath.div(
            SafeMath.mul(ownerFee, _totalSupply),
            _tetherLiquidity
        );
        _tetherLiquidity = SafeMath.add(
            _tetherLiquidity,
            SafeMath.add(remainAmount, ownerFee)
        );
        _totalSupply = SafeMath.add(
            _totalSupply,
            SafeMath.add(userMintAmount, ownerMintAmount)
        );
        _balances[_address] = SafeMath.add(_balances[_address], userMintAmount);
        _balances[owner()] = SafeMath.add(_balances[owner()], ownerMintAmount);
        emit Transfer(address(0), _address, userMintAmount);
        emit Transfer(address(0), owner(), ownerMintAmount);
    }

    // Sell token = Burn token
    function sell(uint256 _amount) external payable {
        // _amount is DWB
        require(_msgSender() != address(0), "Burn from the zero address!");
        require(_amount > 0, "Amount should be greater than zero.");
        require(_balances[_msgSender()] >= _amount, "Insufficient balance.");
        emit Transfer(_msgSender(), address(this), _amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(_amount);
        transferTether(_amount);
        burnToken(_amount);
    }

    // Transfer tether to seller
    function transferTether(uint256 _amount) private {
        // Calculate the amount of tether to transfer based on the DWB amount.
        uint256 tetherAmount = SafeMath.div(
            SafeMath.mul(_amount, _tetherLiquidity),
            _totalSupply
        );
        uint256 sentAmount = SafeMath.div(SafeMath.mul(tetherAmount, 99), 100);

        // Transfer Ether to the message sender.
        require(
            tether.transfer(_msgSender(), sentAmount),
            "Token transfer failed"
        );

        // Update the tether liquidity.
        _tetherLiquidity = _tetherLiquidity.sub(
            SafeMath.div(SafeMath.mul(tetherAmount, 995), 1000)
        );
        uint256 ownerAmount = SafeMath.div(SafeMath.mul(_amount, 5), 1000);
        _balances[owner()] = SafeMath.add(_balances[owner()], ownerAmount);
        emit Transfer(address(this), owner(), ownerAmount);
    }

    // Burn seller's tokens
    function burnToken(uint256 _amount) private {
        // _amount is DWB
        emit Transfer(
            address(this),
            address(0),
            SafeMath.div(SafeMath.mul(_amount, 995), 1000)
        );
        _totalSupply = _totalSupply.sub(
            SafeMath.div(SafeMath.mul(_amount, 995), 1000)
        );
    }

    // External add liquidity
    function addLiquidity(uint256 _amount) external payable {
        require(_amount > 0, "tether amount should be greater than zero");
        tether.transferFrom(_msgSender(), address(this), _amount);

        if (_totalSupply == 0) {
            uint256 frozen = SafeMath.mul(10000, 10 ** _decimals);
            _totalSupply = SafeMath.add(_totalSupply, frozen);
            // 1 Terher and 10000 DWB Frozen forever.
            _balances[address(this)] = SafeMath.add(
                _balances[address(this)],
                frozen
            );
        }
        _tetherLiquidity = SafeMath.add(_tetherLiquidity, _amount);
    }
}