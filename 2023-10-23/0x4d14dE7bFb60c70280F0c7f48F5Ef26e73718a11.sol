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
        // Solidity only automatically asserts when dividing by 0
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

contract Rayo is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _tetherBalances;
    mapping(address => uint256) private _tetherFrozenBalances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _symbol;
    string private _name;
    uint8 private _decimals;
    uint256 private _tetherLiquidity;
    uint256 private _totalSupply;
    uint256 private _price;
    IERC20 public token;
    uint256 private _ICOLiquidity;
    uint256 private _ICOCoefficient;
    uint256 private _totalFrozen;
    address[] internal ICONodes;
    address private partner1;
    address private partner2;
    address private partner3;

    struct Transaction {
        string txType;
        uint256 amount;
        uint256 frozenAmount;
        uint256 time;
    }
    mapping(address => Transaction[]) internal reports;

    constructor() {
        _name = "Rayo Token";
        _symbol = "RAYO";
        _decimals = 18;
        _tetherLiquidity = 1000000000000000000; // 1 Tether
        _totalSupply = 100000000000000000000000; // 100000 Rayo
        _price = _tetherLiquidity / _totalSupply; // First price: 0.00001 Tether
        _balances[msg.sender] = _totalSupply;
        token = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _ICOCoefficient = 6;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setPartner(
        address _address1,
        address _address2,
        address _address3
    ) public onlyOwner {
        require(
            partner1 == address(0) &&
                partner2 == address(0) &&
                partner3 == address(0),
            "It's done before."
        );
        require(
            _address1 != address(0) &&
                _address2 != address(0) &&
                _address3 != address(0),
            "Zero address!"
        );
        partner1 = _address1;
        partner2 = _address2;
        partner3 = _address3;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function getPartners() external view returns (address, address, address) {
        return (partner1, partner2, partner3);
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

    function balanceOfTether(address account) public view returns (uint256) {
        return _tetherBalances[account];
    }

    function balanceOfFrozenTether(
        address account
    ) public view returns (uint256) {
        return _tetherFrozenBalances[account];
    }

    function ICOLiquidity() public view returns (uint256) {
        return _ICOLiquidity;
    }

    function ICOCoefficient() public view returns (uint256) {
        return _ICOCoefficient;
    }

    function totalFrozen() public view returns (uint256) {
        return _totalFrozen;
    }

    function getICONodes() public view returns (address[] memory) {
        return ICONodes;
    }

    function getICONodesCount() public view returns (uint256) {
        return ICONodes.length;
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
                SafeMath.div(SafeMath.mul(_amount, 101), 100),
            ""
        );

        uint256 recivedAmount = SafeMath.div(SafeMath.mul(_amount, 101), 100);
        uint256 sentAmount = SafeMath.div(SafeMath.mul(_amount, 98), 100);
        uint256 remainAmount = SafeMath.sub(recivedAmount, sentAmount);
        uint256 ownerAmount = SafeMath.div(SafeMath.mul(remainAmount, 4), 10);
        uint256 burnAmount = SafeMath.div(SafeMath.mul(remainAmount, 6), 10);

        _transfer(_msgSender(), address(this), recivedAmount);
        _transfer(address(this), recipient, sentAmount);
        _transfer(address(this), partner1, SafeMath.div(ownerAmount, 3));
        _transfer(address(this), partner2, SafeMath.div(ownerAmount, 3));
        _transfer(address(this), partner3, SafeMath.div(ownerAmount, 3));

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
            _balances[sender] >= SafeMath.div(SafeMath.mul(_amount, 101), 100),
            ""
        );

        uint256 recivedAmount = SafeMath.div(SafeMath.mul(_amount, 101), 100);
        uint256 sentAmount = SafeMath.div(SafeMath.mul(_amount, 98), 100);
        uint256 remainAmount = SafeMath.sub(recivedAmount, sentAmount);
        uint256 ownerAmount = SafeMath.div(SafeMath.mul(remainAmount, 4), 10);
        uint256 burnAmount = SafeMath.div(SafeMath.mul(remainAmount, 6), 10);

        _transfer(sender, address(this), recivedAmount);
        _transfer(address(this), recipient, sentAmount);
        _transfer(address(this), partner1, SafeMath.div(ownerAmount, 3));
        _transfer(address(this), partner2, SafeMath.div(ownerAmount, 3));
        _transfer(address(this), partner3, SafeMath.div(ownerAmount, 3));

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
    function buy(uint256 _amount) external payable {
        // _amount is Tether
        require(_msgSender() != address(0), "Mint to the zero address");
        require(_amount > 0, "Amount should be greater than zero.");
        require(
            token.allowance(_msgSender(), address(this)) >= _amount,
            "Token allowance not enough"
        );
        require(
            token.balanceOf(_msgSender()) >= _amount,
            "Insufficient token balance"
        );
        token.transferFrom(_msgSender(), address(this), _amount);
        mintToken(_msgSender(), _amount);
    }

    function mintToken(address _address, uint256 _amount) private {
        // _amount is Tether
        uint256 userMintAmount = SafeMath.div(
            SafeMath.mul(
                SafeMath.div(SafeMath.mul(_amount, 98), 100),
                _totalSupply
            ),
            _tetherLiquidity
        );
        uint256 ownerMintAmount = SafeMath.div(
            SafeMath.mul(
                SafeMath.div(SafeMath.mul(_amount, 6), 1000),
                _totalSupply
            ),
            _tetherLiquidity
        );
        _totalSupply = SafeMath.add(_totalSupply, userMintAmount);
        _totalSupply = SafeMath.add(_totalSupply, ownerMintAmount);
        _tetherLiquidity = SafeMath.add(_tetherLiquidity, _amount);
        _balances[_address] = SafeMath.add(_balances[_address], userMintAmount);
        _balances[partner1] = SafeMath.add(
            _balances[partner1],
            SafeMath.div(ownerMintAmount, 3)
        );
        _balances[partner2] = SafeMath.add(
            _balances[partner2],
            SafeMath.div(ownerMintAmount, 3)
        );
        _balances[partner3] = SafeMath.add(
            _balances[partner3],
            SafeMath.div(ownerMintAmount, 3)
        );
        emit Transfer(address(0), _address, userMintAmount);
        emit Transfer(address(0), partner1, SafeMath.div(ownerMintAmount, 3));
        emit Transfer(address(0), partner2, SafeMath.div(ownerMintAmount, 3));
        emit Transfer(address(0), partner3, SafeMath.div(ownerMintAmount, 3));
    }

    // Sell token = Burn token
    function sell(uint256 _amount) external payable {
        // _amount is RAYO
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
        // _amount is RAYO
        uint256 tetherAmount = SafeMath.div(
            SafeMath.mul(_amount, _tetherLiquidity),
            _totalSupply
        );
        require(
            token.transfer(
                _msgSender(),
                SafeMath.div(SafeMath.mul(tetherAmount, 99), 100)
            ),
            "Token transfer failed"
        );
        _tetherLiquidity = _tetherLiquidity.sub(
            SafeMath.div(SafeMath.mul(tetherAmount, 994), 1000)
        );
        uint256 ownerAmount = SafeMath.div(SafeMath.mul(_amount, 6), 1000);
        _balances[partner1] = SafeMath.add(
            _balances[partner1],
            SafeMath.div(ownerAmount, 3)
        );
        _balances[partner2] = SafeMath.add(
            _balances[partner2],
            SafeMath.div(ownerAmount, 3)
        );
        _balances[partner3] = SafeMath.add(
            _balances[partner3],
            SafeMath.div(ownerAmount, 3)
        );
        emit Transfer(address(this), partner1, SafeMath.div(ownerAmount, 3));
        emit Transfer(address(this), partner2, SafeMath.div(ownerAmount, 3));
        emit Transfer(address(this), partner3, SafeMath.div(ownerAmount, 3));
    }

    // Burn seller's tokens
    function burnToken(uint256 _amount) private {
        // _amount is RAYO
        emit Transfer(
            address(this),
            address(0),
            SafeMath.div(SafeMath.mul(_amount, 994), 1000)
        );
        _totalSupply = _totalSupply.sub(
            SafeMath.div(SafeMath.mul(_amount, 994), 1000)
        );
    }

    // ICO
    function ICO(uint256 _amount) public payable {
        // _amount is Tether
        require(_msgSender() != address(0), "Mint to the zero address");
        require(_amount > 0, "Amount should be greater than zero.");
        require(
            token.allowance(_msgSender(), address(this)) >= _amount,
            "Token allowance not enough"
        );
        require(
            token.balanceOf(_msgSender()) >= _amount,
            "Insufficient token balance"
        );
        require(
            SafeMath.add(_ICOLiquidity, SafeMath.div(_amount, 2)) <=
                SafeMath.mul(500000, 10 ** uint256(_decimals)),
            "The ICO amount is over the limit (500.000 $)."
        );
        token.transferFrom(_msgSender(), address(this), _amount);
        mintToken(_msgSender(), SafeMath.div(_amount, 2));
        startICO(SafeMath.div(_amount, 2));
        addAddress();
    }

    function startICO(uint256 _amount) private {
        uint256 userFrozenAmount = checkFrozen(_amount);
        _tetherFrozenBalances[_msgSender()] = SafeMath.add(
            _tetherFrozenBalances[_msgSender()],
            userFrozenAmount
        );
        _totalFrozen = SafeMath.add(_totalFrozen, userFrozenAmount);
        _tetherBalances[owner()] = SafeMath.add(
            _tetherBalances[owner()],
            _amount
        );
    }

    function checkFrozen(uint256 _amount) private returns (uint256) {
        uint256 userFrozenAmount;
        uint256 remainAmount = _amount;
        uint256 steps = changeStep(remainAmount);
        while (steps > 0) {
            uint256 firstPartAmount = getFirstPartAmount();
            userFrozenAmount = SafeMath.add(
                userFrozenAmount,
                SafeMath.mul(firstPartAmount, _ICOCoefficient)
            );
            reportsFun(
                "ICO",
                _msgSender(),
                firstPartAmount,
                SafeMath.mul(firstPartAmount, _ICOCoefficient)
            );
            _ICOCoefficient = SafeMath.sub(_ICOCoefficient, 1);
            _ICOLiquidity = SafeMath.add(_ICOLiquidity, firstPartAmount);
            remainAmount = SafeMath.sub(remainAmount, firstPartAmount);
            steps = changeStep(remainAmount);
        }
        if (steps == 0) {
            if (remainAmount != 0) {
                userFrozenAmount = SafeMath.add(
                    userFrozenAmount,
                    SafeMath.mul(remainAmount, _ICOCoefficient)
                );
                _ICOLiquidity = SafeMath.add(_ICOLiquidity, remainAmount);
                reportsFun(
                    "ICO",
                    _msgSender(),
                    remainAmount,
                    SafeMath.mul(remainAmount, _ICOCoefficient)
                );
            }
        }
        return userFrozenAmount;
    }

    function changeStep(uint256 _amount) private view returns (uint256) {
        return
            SafeMath.sub(
                uint256(
                    SafeMath.div(
                        SafeMath.add(_ICOLiquidity, _amount),
                        SafeMath.mul(100000, 10 ** uint256(_decimals))
                    )
                ),
                uint256(
                    SafeMath.div(
                        _ICOLiquidity,
                        SafeMath.mul(100000, 10 ** uint256(_decimals))
                    )
                )
            );
    }

    function getFirstPartAmount() private view returns (uint256) {
        return
            SafeMath.sub(
                SafeMath.mul(
                    SafeMath.add(
                        uint256(
                            SafeMath.div(
                                _ICOLiquidity,
                                SafeMath.mul(100000, 10 ** uint256(_decimals))
                            )
                        ),
                        1
                    ),
                    SafeMath.mul(100000, 10 ** uint256(_decimals))
                ),
                _ICOLiquidity
            );
    }

    function reportsFun(
        string memory _title,
        address _address,
        uint256 _amount,
        uint256 _frozenAmount
    ) internal {
        require(_address != address(0), "Address should not be zero.");
        require(_amount > 0, "Amount must be greater than zero.");
        reports[_address].push(
            Transaction({
                txType: _title,
                amount: _amount,
                frozenAmount: _frozenAmount,
                time: block.timestamp
            })
        );
    }

    function addAddress() private {
        bool exists = false;
        for (uint i = 0; i < ICONodes.length; i++) {
            if (ICONodes[i] == _msgSender()) {
                exists = true;
                break;
            }
        }
        if (exists == false) {
            ICONodes.push(_msgSender());
        }
    }

    // Add projects Profit to liquidity
    function projectsProfit(uint256 _amount) public payable {
        // _amount is Tether
        require(
            token.allowance(_msgSender(), address(this)) >= _amount,
            "Token allowance is not enough."
        );
        require(
            token.balanceOf(_msgSender()) >= _amount,
            "Insufficient token balance."
        );
        require(_amount > 0, "Amount should be greater than zero.");
        token.transferFrom(_msgSender(), address(this), _amount);
        _tetherLiquidity = SafeMath.add(
            _tetherLiquidity,
            SafeMath.div(_amount, 2)
        );
        releasICO(SafeMath.div(_amount, 2));
    }

    function releasICO(uint256 _amount) private {
        uint256 remainShare = _amount;
        uint256 totalShare;
        for (uint i = 0; i < ICONodes.length; i++) {
            uint256 share = SafeMath.div(
                SafeMath.mul(_tetherFrozenBalances[ICONodes[i]], _amount),
                _totalFrozen
            );
            if (share > _tetherFrozenBalances[ICONodes[i]]) {
                share = _tetherFrozenBalances[ICONodes[i]];
            }
            _tetherFrozenBalances[ICONodes[i]] = SafeMath.sub(
                _tetherFrozenBalances[ICONodes[i]],
                share
            );
            _tetherBalances[ICONodes[i]] = SafeMath.add(
                _tetherBalances[ICONodes[i]],
                share
            );
            totalShare = SafeMath.add(totalShare, share);
            if (share != 0) {
                reportsFun("Releas ICO", ICONodes[i], share, 0);
            }
        }
        _totalFrozen = SafeMath.sub(_totalFrozen, totalShare);
        remainShare = SafeMath.sub(_amount, totalShare);
        _tetherBalances[owner()] = SafeMath.add(
            _tetherBalances[owner()],
            remainShare
        );
    }

    function getUserTransactions(
        address _wallet
    ) public view returns (Transaction[] memory) {
        return reports[_wallet];
    }

    function getReportsHistory() public view returns (Transaction[] memory) {
        uint256 totalTransactions = 0;
        for (uint256 i = 0; i < ICONodes.length; i++) {
            totalTransactions += reports[ICONodes[i]].length;
        }

        Transaction[] memory allTransactions = new Transaction[](
            totalTransactions
        );
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < ICONodes.length; i++) {
            Transaction[] memory userTransactions = reports[ICONodes[i]];
            for (uint256 j = 0; j < userTransactions.length; j++) {
                allTransactions[currentIndex] = userTransactions[j];
                currentIndex++;
            }
        }
        return allTransactions;
    }

    // Withdraw Tether
    function withdraw(uint256 _amount) public {
        // _amount is Tether
        require(_amount > 0, "Amount should be greater than zero.");
        if (
            _msgSender() != owner() &&
            _msgSender() != partner1 &&
            _msgSender() != partner2 &&
            _msgSender() != partner3
        ) {
            require(
                _tetherBalances[_msgSender()] >= _amount,
                "Insufficient balance."
            );
            _tetherBalances[_msgSender()] = SafeMath.sub(
                _tetherBalances[_msgSender()],
                _amount
            );
            require(
                token.transfer(_msgSender(), _amount),
                "Token transfer failed"
            );
        } else {
            uint256 partnerShare = SafeMath.div(_amount, 3);
            require(
                token.transfer(partner1, partnerShare),
                "Token transfer failed"
            );
            require(
                token.transfer(partner2, partnerShare),
                "Token transfer failed"
            );
            require(
                token.transfer(partner3, partnerShare),
                "Token transfer failed"
            );
            _tetherBalances[owner()] = SafeMath.sub(
                _tetherBalances[owner()],
                _amount
            );
        }
    }

    // Distribute
    function distribute(
        address[] memory recipients,
        uint256[] memory amounts
    ) public payable {
        require(recipients.length == amounts.length, "Invalid input");

        uint256 amountSum = getTotalAmount(amounts);
        require(amountSum > 0, "Amount must be grather than zero.");

        require(
            token.allowance(_msgSender(), address(this)) >= amountSum,
            "Token allowance not enough"
        );
        require(
            token.balanceOf(_msgSender()) >= amountSum,
            "Insufficient token balance"
        );
        token.transferFrom(_msgSender(), address(this), amountSum);
        distributeDepositAmounts(recipients, amounts, amountSum);
    }

    function getTotalAmount(
        uint256[] memory amounts
    ) private pure returns (uint256) {
        uint256 amountSum = 0;
        for (uint256 i = 0; i < amounts.length; i++)
            amountSum = SafeMath.add(amountSum, amounts[i]);
        return amountSum;
    }

    function distributeDepositAmounts(
        address[] memory recipients,
        uint256[] memory amounts,
        uint256 amountSum
    ) private {
        uint256 shareAmount = 0;
        for (uint i = 0; i < recipients.length; i++) {
            address currentRecipient = recipients[i];
            require(
                currentRecipient != address(0),
                "Invalid recipient address"
            );

            uint256 currentAmount = amounts[i];
            require(currentAmount > 0, "Invalid percentage");

            shareAmount = SafeMath.add(shareAmount, currentAmount);
            mintToken(
                currentRecipient,
                SafeMath.div(SafeMath.mul(currentAmount, 2), 10)
            );
            require(
                token.transfer(
                    currentRecipient,
                    SafeMath.div(SafeMath.mul(currentAmount, 8), 10)
                ),
                "Token transfer failed"
            );
        }
        if (SafeMath.sub(amountSum, shareAmount) > 0) {
            require(
                token.transfer(
                    _msgSender(),
                    SafeMath.sub(amountSum, shareAmount)
                ),
                "Token transfer failed"
            );
        }
    }
}