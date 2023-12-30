// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}


contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    //买币销毁百分比
    uint256 public buyBurnFee = 5;
    //卖币销毁百分比
    uint256 public sellBurnFee = 5;
    //LP自动销毁百分比
    uint256 public lpAutoBurnPercen = 5;
    //MintAdmin
    address public mintAdmin;

    address public marketing;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public minted;

    uint256 public burnTimes;
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 public startTime;
    mapping(address => bool) private _wlList;
    mapping(address => bool) private _blackList;

    mapping(address => address) private _invitor;

    mapping(address => bool) private _swapPairList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    bool private inSwap;
    uint256 private numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address private usdt;
    TokenDistributor private _tokenDistributor;
    uint256 private _txFee = 5;

    IERC20 private _usdtPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    struct Locker {
        uint256 timestamp;
        uint256 amount;
        uint256 releasedAmount;
    }

    mapping (address => Locker[]) public  LockerList;
    mapping (address => uint256) public  suplusReleasedAmount;

    event LPBurnEvent(uint256 indexed timestamp,uint256 indexed times, uint256 indexed burnTimes);

    address public immutable _mainPair;

    constructor (
            string memory Name, 
            string memory Symbol, 
            uint8 Decimals, 
            uint256 Supply, 
            address ReceivedAddress,
            address Marketing
    ){
        marketing = Marketing;
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);
        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);
        _mainPair = usdtPair;
        _swapPairList[usdtPair] = true;
        _allowances[address(this)][address(_swapRouter)] = MAX;
        _tTotal = Supply * 10 ** Decimals;
        _balances[ReceivedAddress] = 210000000 * 10 ** Decimals;
        emit Transfer(address(0), ReceivedAddress, 210000000 * 10 ** Decimals);
        _wlList[ReceivedAddress] = true;
        _wlList[address(this)] = true;
        _wlList[address(_swapRouter)] = true;
        _wlList[msg.sender] = true;
        _wlList[mintAdmin] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function mint(address account, uint256 amount) external  {
        require(msg.sender == mintAdmin, "Unable");
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        minted = minted + amount;
        require((_tTotal - minted) >= 0, "FULL");
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 txFee;
        bool isTransfer = false;
        if (_swapPairList[from] || _swapPairList[to]) {
            //--
            if (!_wlList[from] && !_wlList[to]) {
                if(_swapPairList[to]){
                    txFee = sellBurnFee;
                    uint256 tokenAmount = queryTokenAmount();
                    uint256 maxSellAmount = balanceOf(from) - tokenAmount;
                    if (amount > maxSellAmount) {
                        amount = maxSellAmount;
                    }
                }else {
                    txFee = buyBurnFee;
                }
            }
        } else {
            isTransfer = true;
            if (startTime > 0){
                uint256 tokenAmount = queryTokenAmount();
                uint256 maxSellAmount = balanceOf(from) - tokenAmount;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
            }
        }
        _tokenTransfer(from, to, amount, txFee);
        if (startTime > 0){
            lpBurn(address(_mainPair));
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 taxAmount = 0;
        if (fee > 0) {
            taxAmount = tAmount * fee / 100;
            _takeTransfer(
                sender,
                burnAddress,
                taxAmount
            );
        }
        _takeTransfer(sender, recipient, tAmount - taxAmount);
    }
    
    function queryTokenAmount() public view returns(uint256 rAmount) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        rAmount = _swapRouter.quote(1*1e18,r0, r1);
    }


    function lpBurn(address pairAddress) private {
        uint256 baseAmount = balanceOf(pairAddress);
        uint timeElapsed = block.timestamp - startTime;
        uint times = timeElapsed / 5 minutes;
        if (times > burnTimes){
            uint256 tTimes = times - burnTimes;
            if (tTimes > 0){
                uint256 burnAmount = tTimes * baseAmount * lpAutoBurnPercen / 1000;
                if(burnAmount > 0){
                    burnTimes += tTimes;
                    _balances[pairAddress] = _balances[pairAddress] - burnAmount;
                    _takeTransfer(
                            pairAddress,
                            burnAddress,
                            burnAmount * 80 / 100
                        );
                    _takeTransfer(
                            pairAddress,
                            address(marketing),
                            burnAmount  * 20 / 100
                        );
                    ISwapPair pair = ISwapPair(pairAddress);
                    pair.sync();
                }
            }
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        address tokenOther = usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _wlList[addr] = enable;
    }

    function setStartTime() external onlyOwner {
        startTime = block.timestamp;
    }

    function setBuyBurnFee(uint256 value) external onlyOwner {
        buyBurnFee = value;
    }

    function setSellBurnFee(uint256 value) external onlyOwner {
        sellBurnFee = value;
    }

    function setLpAutoBurnPercen(uint256 value) external onlyOwner {
        lpAutoBurnPercen = value;
    }

    function setMintAdmin(address value) external onlyOwner {
        mintAdmin = value;
    }

    function cancelFee() external {
        require(msg.sender == address(marketing), "Not allow");
        buyBurnFee = 0;
        sellBurnFee = 0;
        lpAutoBurnPercen = 0;
    }

    receive() external payable {}

    function claimBalance() external {
        payable(marketing).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(marketing, amount);
    }

}

contract BSCSATS is AbsToken {
    constructor() AbsToken(
        "SATS02",
        "SATS02",
        18,
        2100000000,
        address(0x076dbFbaCC03459418191FB5b2580c0dDc53d964),
        address(0xE54A3b674E0763AcAC2395981Ac631036A5E6f37)
    ){
    }
}