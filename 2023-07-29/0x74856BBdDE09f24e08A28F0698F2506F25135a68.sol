// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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

abstract contract Excludes {
    mapping(address => bool) internal _Excludes;

    function setExclude(address _user, bool b) public {
        _authorizeExcludes();
        _Excludes[_user] = b;
    }

    function setExcludes(address[] memory _user, bool b) public {
        _authorizeExcludes();
        for (uint256 i = 0; i < _user.length; i++) {
            _Excludes[_user[i]] = b;
        }
    }

    function isExcludes(address _user) public view returns (bool) {
        return _Excludes[_user];
    }

    function _authorizeExcludes() internal virtual {}
}

abstract contract Ownable is Context {
    address internal _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TokenStation {
    constructor(address token) {
        IERC20(token).approve(msg.sender, type(uint256).max);
    }
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPair {
    function sync() external;

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function totalSupply() external view returns (uint256);
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        _takeTransfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _takeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[from] = fromBalance.sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance.sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            _approve(owner, spender, currentAllowance.sub(amount));
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract SwapUSDT is ERC20 {
    using SafeMath for uint256;
    address public pair;
    IRouter public router;
    address[] internal _buyPath;
    address[] internal _sellPath;
    IERC20 public TokenB;

    function isPair(address _pair) public view returns (bool) {
        return pair == _pair;
    }

    function getPrice4USDT(uint256 amountDesire) public view returns (uint256) {
        uint256[] memory amounts = router.getAmountsOut(
            amountDesire,
            _sellPath
        );
        if (amounts.length > 1) return amounts[1];
        return 0;
    }

    function _initPair(address _router, address pairB)
        internal
        returns (address)
    {
        TokenB = IERC20(pairB);
        router = IRouter(_router);
        pair = IFactory(router.factory()).createPair(pairB, address(this));
        address[] memory path = new address[](2);
        path[0] = pairB;
        path[1] = address(this);
        _buyPath = path;
        address[] memory path2 = new address[](2);
        path2[0] = address(this);
        path2[1] = pairB;
        _sellPath = path2;

        TokenB.approve(_router, type(uint256).max);
        _approve(address(this), _router, type(uint256).max);

        return pair;
    }

    function swapAndSend2this(
        uint256 amount,
        address to,
        address _tokenStation
    ) internal {
        IERC20 USDT = IERC20(_sellPath[1]);
        swapAndSend2fee(amount, _tokenStation);
        USDT.transferFrom(_tokenStation, to, USDT.balanceOf(_tokenStation));
    }

    function swapAndSend2fee(uint256 amount, address to) internal {
        swapAndSend2feeWithPath(amount, to, _sellPath);
    }

    function swapAndSend2feeWithPath(
        uint256 amount,
        address to,
        address[] memory path
    ) internal {
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function isAddLiquidity() internal view returns (bool isAddLP) {
        address token0 = IPair(pair).token0();
        address token1 = IPair(pair).token1();
        (uint256 r0, uint256 r1, ) = IPair(pair).getReserves();
        uint256 bal0 = IERC20(token0).balanceOf(pair);
        uint256 bal1 = IERC20(token1).balanceOf(pair);
        if (token0 == address(this)) return bal1.sub(r1) > 1000;
        else return bal0.sub(r0) > 1000;
    }

    function isRemoveLiquidity() internal view returns (bool isRemoveLP) {
        address token0 = IPair(pair).token0();
        if (token0 == address(this)) return false;
        (uint256 r0, , ) = IPair(pair).getReserves();
        uint256 bal0 = IERC20(token0).balanceOf(pair);
        return r0 > bal0.add(1000);
    }

    function addLiquidityAutomatically(uint256 amountToken) internal {
        super._takeTransfer(address(this), pair, amountToken);
        IPair(pair).sync();
    }

    function addLiquidity(
        uint256 amountToken,
        address to,
        address _tokenStation
    ) internal {
        uint256 half = amountToken.div(2);
        IERC20 USDT = IERC20(_sellPath[1]);
        uint256 amountBefore = USDT.balanceOf(_tokenStation);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            half,
            0,
            _sellPath,
            _tokenStation,
            block.timestamp
        );
        uint256 amountAfter = USDT.balanceOf(_tokenStation);
        uint256 amountDiff = amountAfter.sub(amountBefore);
        USDT.transferFrom(_tokenStation, address(this), amountDiff);
        if (amountDiff > 0 && (amountToken - half) > 0) {
            router.addLiquidity(
                _sellPath[0],
                _sellPath[1],
                amountToken.sub(half),
                amountDiff,
                0,
                0,
                to,
                block.timestamp.add(9)
            );
        }
    }
}

abstract contract Token is SwapUSDT, Excludes, Ownable {
    using SafeMath for uint256;
    uint256 public calcBase;
    uint256 public feeMarketingBuy;
    uint256 public feeMarketingSell;
    uint256 public feeLiquiditySell;
    uint256 public feeMarketingAll;
    uint256 public feeLiquidityAll;
    uint256 public feeBuyAll;
    uint256 public feeSellAll;
    uint256 public feeAll;
    address public address1;
    address public address2;
    uint256 public amountKeep;
    TokenStation public _TokenStation;
    uint256 public thePrice;
    uint256 public thePrice500U;
    uint256 public lastUpdateTime;
    uint256 public decreaseRate;
    bool public canSell = true;
    uint256 public swapTokensAt = 0.001 ether;
    uint256 public feeFromSeller;
    uint256 public feeFromBuyer;

    bool inSwap;
    bool allCanBuy = false;

    function _initToken(
        uint256 totalSupply_,
        address _address1,
        address _address2,
        uint256 _thePrice500U,
        address usdt_
    ) internal {
        calcBase = 10000;
        address1 = _address1;
        address2 = _address2;
        thePrice500U = _thePrice500U;
        _mint(_address2, totalSupply_);
        super.setExclude(_msgSender(), true);
        super.setExclude(address(this), true);
        super.setExclude(_address1, true);
        super.setExclude(_address2, true);
        _refreshFeeAll();
        _TokenStation = new TokenStation(usdt_);
    }

    function initPrice() public onlyOwner {
        uint256 currentPrice = super.getPrice4USDT(1 ether);
        _initPrice(currentPrice);
    }

    bool private locked;
    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override noReentrancy {
        if (isExcludes(from) || isExcludes(to)) {
            super._transfer(from, to, amount);
            return;
        }
        uint256 currentPrice = super.getPrice4USDT(1 ether);
        if (!allCanBuy) {
            allCanBuy = currentPrice >= thePrice500U ? true : false;
        }
        uint256 fees;
        if (isPair(from)) {
            //Buy
            if (!allCanBuy) {
                require(currentPrice >= thePrice500U, "not allowed");
            }

            fees = _handFeeBuys(from, amount);
            if (fees > 0) {
                amount = amount.sub(fees);
            }
        } else if (isPair(to)) {
            //Sell
            _checkPrice();
            require(canSell, "cannot sell today due to price decrease");
            if (balanceOf(from) < amount.add(amountKeep)) {
                amount = balanceOf(from).sub(amountKeep);
            }
            fees = _handFeeSells(from, amount);
            if (fees > 0) {
                amount = amount.sub(fees);
            }
        } else {
            if (feeFromBuyer > 0) {
                handBuysSwap();
            }
            if (feeFromSeller > 0) {
                handSellsSwap();
            }
        }

        super._transfer(from, to, amount);
    }

    function _checkPrice() internal {
        // TODO
        // uint256 daysSinceLastUpdate = (block.timestamp.sub(lastUpdateTime)).div(
        //     1 days
        // );
        uint256 daysSinceLastUpdate = (block.timestamp.sub(lastUpdateTime)).div(
            6 minutes
        );
        uint256 currentPrice = super.getPrice4USDT(1 ether);
        if (thePrice == 0) {
            _initPrice(currentPrice);
            return;
        }

        if (daysSinceLastUpdate <= 1) {
            if (thePrice > currentPrice) {
                //在跌
                decreaseRate = (
                    ((thePrice.sub(currentPrice)).mul(100)).div(thePrice)
                );
            } else {
                //在涨
                decreaseRate = 0;
            }

            if (decreaseRate >= 20) {
                canSell = false;
            } else {
                canSell = true;
            }
        } else {
            _initPrice(currentPrice);
        }
    }

    function _initPrice(uint256 currentPrice) private {
        decreaseRate = 0;
        lastUpdateTime = block.timestamp;
        thePrice = currentPrice;
        canSell = true;
    }

    function handBuysSwap() internal {
        if (inSwap) return;
        _handBuysSwap();
    }

    function _handBuysSwap() internal lockSwap {
        if (feeFromBuyer >= swapTokensAt) {
            super.swapAndSend2fee(feeFromBuyer, address(address1));
            feeFromBuyer = 0;
        }
    }

    function handSellsSwap() internal {
        if (inSwap) return;
        _handSellsSwap();
    }

    function _handSellsSwap() internal lockSwap {
        if (feeFromSeller >= swapTokensAt) {
            uint256 _feeLiquidity = feeFromSeller.div(3);
            super.addLiquidity(_feeLiquidity, address2, address(_TokenStation));

            uint256 _feeAddress2 = feeFromSeller.sub(_feeLiquidity);
            super.swapAndSend2fee(_feeAddress2, address(address2));
            feeFromSeller = 0;
        }
    }

    function _handFeeBuys(address from, uint256 amount)
        private
        returns (uint256 fee)
    {
        if (feeBuyAll == 0) return fee;
        fee = (amount.mul(feeBuyAll)).div(calcBase);
        super._takeTransfer(from, address(this), fee);
        feeFromBuyer = feeFromBuyer + fee;
    }

    function _handFeeSells(address from, uint256 amount)
        private
        returns (uint256 fee)
    {
        if (feeSellAll == 0) return fee;
        fee = (amount.mul(feeSellAll)).div(calcBase);
        super._takeTransfer(from, address(this), fee);
        feeFromSeller = feeFromSeller + fee;
    }

    function _refreshFeeAll() private {
        feeMarketingAll = feeMarketingBuy.add(feeMarketingSell);
        feeLiquidityAll = feeLiquiditySell;
        feeBuyAll = feeMarketingBuy;
        feeSellAll = feeMarketingSell.add(feeLiquiditySell);
        feeAll = feeBuyAll.add(feeSellAll);
    }

    //TODO 是否删除代码
    function setSwapTokensAt(uint256 num) public onlyOwner {
        swapTokensAt = num;
    }

    modifier lockSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    //TODO 是否去掉onlyOwner，改成打给固定地址
    function rescueLossToken(
        IERC20 token_,
        address _recipient,
        uint256 amount
    ) public onlyOwner {
        token_.transfer(_recipient, amount);
    }

    //TODO 是否去掉onlyOwner，改成打给固定地址
    function rescueLossTokenAll(IERC20 token_, address _recipient)
        public
        onlyOwner
    {
        rescueLossToken(token_, _recipient, token_.balanceOf(address(this)));
    }

    function _authorizeExcludes() internal virtual override onlyOwner {}
}

contract GA is Token {
    //TODO 名字
    constructor() ERC20("LU", "LU") {
        uint256 _totalSupply = 5000000 ether;
        //TODO// 地址1(地址待定)
        address _address1 = address(0xb163Db1fE2c61fA85E111F8a5B937fd2bfDFD2c3);
        //TODO// 地址2(地址待定)
        address _address2 = address(0x7d0216019F51d868D1cC097Ba0014B54F9830006);
        // 路由
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // 交易对U
        address _usdt = 0x55d398326f99059fF775485246999027B3197955;
        super._initPair(_router, _usdt);
        // 代币价格小于500u, 仅项目方指定地址可以购买
        uint256 _thePrice500U = 5 ether; //TODO
        // 购买费用,1%手续费给指定地址（地址1）
        feeMarketingBuy = 100;
        // 卖出费用,4%手续费给指定地址（地址2）
        feeMarketingSell = 400;
        // 卖出费用,2%给Lp
        feeLiquiditySell = 200;

        super._initToken(
            _totalSupply,
            _address1,
            _address2,
            _thePrice500U,
            _usdt
        );
        // 防止卖空，保留持币数
        amountKeep = 0.0001 ether;
    }
}