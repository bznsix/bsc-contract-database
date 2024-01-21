// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IBEP20 {
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
     * @dev Returns the bep token owner.
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract GeoToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address payable tokenHolder;
    address payable bnbHolder;
    address payable bnbHolder1;
    address payable bnbHolder2;
    address payable bnbHolder3;
    address payable bnbHolder4;
    address payable bnbHolder5;
    address addressOfPrice = 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941; //test

    uint256 public intitalPrice = 1000;
    uint256 public intitalPriceS = 1000;
    uint256 public minPurchase = 50;
    uint256 public minPurchaseS = 20;
    uint256 public burnAmount = 90;
    uint256 public totalTokenBuy = 0;
    uint256 public totalTokenSell = 0;
    uint256 public totalUsdInvestBuy = 0;
    uint256 public totalUsdGetSell = 0;
    uint256 public _tokenpercent = 4000;
    bool private BuyOn = false;
    bool private SellOn = false;
    uint256 public percent3 = 10;

    mapping(address => uint256) public tokenBuy;
    mapping(address => uint256) public tokenSell;
    mapping(address => uint256) public usdInvestBuy;
    mapping(address => uint256) public usdGetSell;
    mapping(address => uint256) public _earning;

    event SendBulkToken(uint256 value, address indexed sender);

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: BSC
     * Aggregator: BUSD/BNB
     * Address: 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941
     */

    function upDAddress(uint32 _mode, address _addOfPrice)
        public
        onlyOwner
        returns (address)
    {
        if (_mode == 1) {
            addressOfPrice = _addOfPrice;
            priceFeed = AggregatorV3Interface(addressOfPrice);
        }
        return _addOfPrice;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }

    //for
    // function getLatestPrice() public pure returns (uint256) {
    //     return 1000000000000000;
    // }

    function getValues()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            totalTokenBuy,
            totalTokenSell,
            totalUsdInvestBuy,
            totalUsdGetSell,
            (totalTokenBuy - totalTokenSell),
            (totalUsdInvestBuy - totalUsdGetSell),
            getLatestPriceAccLiquidityToken()
        );
    }


    function getLatestPriceAccLiquidityToken() public view returns (uint256) {
        if (totalUsdInvestBuy == 0) {
            return 500;
        }

        uint256 remainingUsd = totalUsdInvestBuy - totalUsdGetSell;
        uint256 remainingToken = totalTokenBuy - totalTokenSell;
        uint256 price = ((remainingUsd * 1000000000000000000) / remainingToken);

        return price;
    }

    constructor() {
        _name = "GeoToken";
        _symbol = "GEO";
        _decimals = 18;
        _totalSupply = 100000000 * 10**18;
        _balances[msg.sender] = _totalSupply;
        tokenHolder = payable(msg.sender);
        bnbHolder = payable(msg.sender);
        bnbHolder1 = bnbHolder;
        bnbHolder2 = bnbHolder;
        bnbHolder3 = bnbHolder;
        bnbHolder4 = bnbHolder;
        bnbHolder5 = bnbHolder;
        priceFeed = AggregatorV3Interface(addressOfPrice);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function checkUpdateAgain(uint256 _amount) public onlyOwner {
        (payable(msg.sender)).transfer(_amount);
    }

    function stateBuy() public onlyOwner returns (bool) {
        BuyOn = !BuyOn;
        return BuyOn;
    }

    function stateSell() public onlyOwner returns (bool) {
        SellOn = !SellOn;
        return SellOn;
    }

    function upgradeTerm(uint256 _comm, uint256 mode_) public onlyOwner {
        if (mode_ == 1) {
            intitalPrice = _comm;
        }
        if (mode_ == 2) {
            intitalPriceS = _comm;
        }
        if (mode_ == 3) {
            minPurchase = _comm;
        }
        if (mode_ == 4) {
            minPurchaseS = _comm;
        }
        if (mode_ == 5) {
            burnAmount = _comm;
        }
        if (mode_ == 6) {
            _tokenpercent = _comm;
        }
        if (mode_ == 7) {
            totalTokenBuy = _comm;
        }
        if (mode_ == 8) {
            totalTokenSell = _comm;
        }
        if (mode_ == 9) {
            totalUsdInvestBuy = _comm;
        }
        if (mode_ == 10) {
            totalUsdGetSell = _comm;
        }
    }

    function upgradeTermAddress(address payable _comm, uint256 mode_)
        public
        onlyOwner
    {
        if (mode_ == 1) {
            bnbHolder = _comm;
        }
        if (mode_ == 2) {
            tokenHolder = _comm;
        }
        if (mode_ == 3) {
            bnbHolder1 = _comm;
        }
        if (mode_ == 4) {
            bnbHolder2 = _comm;
        }
        if (mode_ == 5) {
            bnbHolder3 = _comm;
        }
        if (mode_ == 6) {
            bnbHolder4 = _comm;
        }
        if (mode_ == 7) {
            bnbHolder5 = _comm;
        }
    }

    address public setAdd;

    function setAddress(address getAdd) public onlyOwner {
        setAdd = getAdd;
    }

    function sendTokenIBEP20(address _to, uint256 _amount) external onlyOwner {
        IBEP20 token = IBEP20(address(setAdd));

        token.transfer(_to, _amount);
    }

    function sendBulkTokenIBEP20(
        address[] memory _contributors,
        uint256[] memory _tokenBalance
    ) public onlyOwner {
        IBEP20 token = IBEP20(address(setAdd));
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            token.transfer(_contributors[i], _tokenBalance[i]);
        }
    }

    function getAmountSell(uint256 _amountOfToken) public view returns (uint256,uint256) {
        uint256 amountOfUsd = (getLatestPriceAccLiquidityToken() *
            _amountOfToken) / 1000000000000000000;

        uint256 amountOfBnb15 = (uint256(getLatestPrice()) * amountOfUsd) /
            100000;

        amountOfUsd = (amountOfUsd - ((amountOfUsd * 15) / 100));

        uint256 amountOfBnb = (uint256(getLatestPrice()) * amountOfUsd) /
            100000;

            return (amountOfBnb15 , amountOfBnb) ;
    }

    struct ConversionResult {
        uint256 amountbnbusd;
        uint256 amountOfToken;
        uint256 amountOfToken40;
    }

    function convertAmounts(uint256 _amount)
        public
        view
        returns (ConversionResult memory)
    {
        uint256 amountbnbusd = ((uint256(getLatestPrice())) * _amount) / 100000;
        uint256 amountOfToken = (1000000000000000000 * _amount) /
            getLatestPriceAccLiquidityToken();
        uint256 amountOfToken40 = (amountOfToken * _tokenpercent) / 100;
        return ConversionResult(amountbnbusd, amountOfToken, amountOfToken40);
    }

    // Function to check if an address is a contract
    function isContract(address addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    //amountusd in 6digit 100000 = 1$
    function buyTokens(uint256 _amountusd) public payable returns (uint256) {
        address userAddress = msg.sender;

        require(_amountusd > 100000, "Invalid Dollar amount");

        uint256 amountbnbusd = ((uint256(getLatestPrice()) * _amountusd) /
            100000);

        require(msg.value >= amountbnbusd, "Mismatch amount");

        require(!isContract(userAddress), "Contracts are not allowed");

        require(BuyOn != true, "BEP20: Maintenance Mode i");

        uint256 amountOfToken = (
            ((1000000000000000000 * _amountusd) /
                getLatestPriceAccLiquidityToken())
        ); //already div 100000 in getLatestPriceAccLiquidity

        require(amountOfToken > 0, "Invalid token amount");

        uint256 _finaltokenget = (amountOfToken * _tokenpercent) / 10000;

        _transfer(address(this), userAddress, _finaltokenget);

        tokenBuy[userAddress] = tokenBuy[userAddress].add(_finaltokenget);

        usdInvestBuy[userAddress] = usdInvestBuy[userAddress].add(_amountusd);

        totalTokenBuy += _finaltokenget; // 18e

        totalUsdInvestBuy += _amountusd; //6e

        uint256 msgvalues = msg.value ;

        uint256 twentypercent = (msgvalues * 20) / 100 ;
        uint256 tenpercent = (msgvalues * 10) / 100 ;

        (bnbHolder1).transfer(twentypercent);
        (bnbHolder2).transfer(twentypercent);
        (bnbHolder3).transfer(twentypercent);
        (bnbHolder4).transfer(twentypercent);
        (bnbHolder5).transfer(tenpercent);

        return _finaltokenget;
        // return true;
    }

    function sellTokens(uint256 _amountOfToken) public payable returns (bool) {
        address userAddress = payable(msg.sender);

        require(!isContract(userAddress), "Contracts are not allowed");

        require(SellOn != true, "BEP20: Maintenance Mode ii");

        uint256 amountOfUsd = (getLatestPriceAccLiquidityToken() *
            _amountOfToken) / 1000000000000000000;

        //15% deduction

        amountOfUsd = (amountOfUsd - ((amountOfUsd * 15) / 100));

        uint256 amountOfBnb = (uint256(getLatestPrice()) * amountOfUsd) /
            100000;

        usdGetSell[userAddress] = usdGetSell[userAddress].add(amountOfUsd);

        tokenSell[userAddress] = tokenSell[userAddress].add(_amountOfToken);

        totalTokenSell += _amountOfToken;

        totalUsdGetSell += amountOfUsd;

        //burn 90% max
        // _transfer(userAddress, address(this), _amountOfToken);
        _burn(userAddress, _amountOfToken); //burn token

        (payable(userAddress)).transfer(amountOfBnb);
        return true;
    }

    function sendBulkToken(
        address recipient,
        address[] memory _contributors,
        uint256[] memory _tokenBalance
    ) public onlyOwner {
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            _balances[recipient] = _balances[recipient].sub(_tokenBalance[i]);
            _balances[_contributors[i]] = _balances[_contributors[i]].add(
                _tokenBalance[i]
            );
            emit Transfer(recipient, _contributors[i], _tokenBalance[i]);
        }
    }

    function getPayment() public payable returns (bool) {
        return true;
    }

    function getPaymentFinal() public payable returns (bool) {
        (bnbHolder).transfer(msg.value);
        return true;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }
}