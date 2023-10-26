// SPDX-License-Identifier: UNLICENSED

/*
   __  ___    __       ______   _ __        ___            __  
  /  |/  /__ / /____ _/ __/ /  (_) /  ___ _/ _ \__ _____  / /__
 / /|_/ / -_) __/ _ `/\ \/ _ \/ / _ \/ _ `/ ___/ // / _ \/  '_/
/_/  /_/\__/\__/\_,_/___/_//_/_/_.__/\_,_/_/   \_,_/_//_/_/\_\ 
                                                               
*/

pragma solidity 0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract MetaShibaPunk is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isInList;
    address[] public _addressList;

    mapping(address => bool) private _noDividend;
    address[] public _noDividendAddressList;
    mapping(address => bool) private _noFee;
    mapping(address => uint256) private _unpaidDividend;

    mapping(address => uint256) private _last_buy;

    mapping(address => bool) private _nftEnabled;
    bool private _nftIntegrating;

    uint256 public _minimumDividend;

    uint256 public _totalSupply;
    uint256 public _totalDividend;
    uint256 public _dividendIndex;

    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address public _buybackFreezeAddress;
    uint256 public _buybackFreezeDeadline;

    mapping(address => bool) private _whiteListed;
    bool public _whiteListEnabled;

    address public _marketingAddress;
    address public _buybackAddress;
    address public _processorAddress;
    uint256 public _marketingMilipercent = 2000;
    uint256 public _buyBackMilipercent = 5000;
    uint256 public _dividendMilipercent = 5000;

    uint256 public _extra_fee = 0;
    uint256 public _extra_fee_duration = 3600;

    bool private swapping = false;

    address constant BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor() {
        _name = 'MetaShibaPunk';
        _symbol = 'PunkT';
        _decimals = 9;
        _totalSupply = 5 * 10**4 * 10**9;

        _balances[_msgSender()] = _totalSupply;
        _marketingAddress = _msgSender();
        _buybackAddress = _msgSender();
        _processorAddress = _msgSender();

        _buybackFreezeDeadline = block.timestamp + 31536000; // 365 days
        _buybackFreezeAddress = address(0);

        _whiteListEnabled = true;

        _nftIntegrating = false;

        _minimumDividend = 1 * 10**18; // BUSD

        tryToAddInList(_msgSender());

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        excludeIncludeDividend(_uniswapV2Pair, true);
        excludeIncludeDividend(address(0), true);
        excludeIncludeDividend(address(this), true);

        excludeIncludeFee(address(0), true);
        excludeIncludeFee(address(this), true);

        _whiteListEnabled = true;
        setWhiteList(address(0), true);
        setWhiteList(address(this), true);
        setWhiteList(_msgSender(), true);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable {}

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'transfer amount exceeds allowance')
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'decreased allowance below zero')
        );
        return true;
    }

    /**
     * @param sender Address of amount sender.
     * @param recipient Address of amount reciever.
     * @param amount Amount of token which sender wants to transfer.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'transfer from the zero address');
        require(recipient != address(0), 'transfer to the zero address');
        require(amount > 0, 'transfer amount must be greater than zero');
        require(sender != _buybackFreezeAddress || block.timestamp > _buybackFreezeDeadline);
        require(!_whiteListEnabled || _whiteListed[sender] || _whiteListed[recipient]);
        require(!_nftIntegrating || recipient != uniswapV2Pair || _whiteListed[sender] || _whiteListed[recipient]);

        tryToAddInList(recipient);
        if (_balances[sender] == amount) amount--;
        _balances[sender] = _balances[sender].sub(amount);

        if (sender == uniswapV2Pair) _last_buy[recipient] =  block.timestamp;

        uint256 totalFee = 0;
        if (!_noFee[sender] && !_noFee[recipient] && !swapping) {
            uint256 total_fee_mp = _marketingMilipercent + _buyBackMilipercent + _dividendMilipercent;
            if (recipient == uniswapV2Pair && _last_buy[sender] + _extra_fee_duration > block.timestamp) 
                total_fee_mp += _extra_fee;
            totalFee = amount.mul(total_fee_mp).div(100000);
        }

        if (sender == uniswapV2Pair) _last_buy[recipient] =  block.timestamp;


        _balances[recipient] = _balances[recipient].add(amount.sub(totalFee));

        if (totalFee > 0) {
            _balances[address(this)] = _balances[address(this)].add(totalFee);
            emit Transfer(recipient, address(this), totalFee);
        }

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'approve from the zero address');
        require(spender != address(0), 'approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'burn from the zero address');

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);
    }

    /**
     * Interface to set address for marketing.
     *
     * @param account Address for collecting marketing.
     *
     * @return boolean.
     */
    function setMarketingAddress(address account) external onlyOwner returns (bool) {
        _marketingAddress = account;
        return true;
    }

    /**
     * Interface to set address for buyback.
     *
     * @param account Address for collecting buyback.
     *
     * @return boolean.
     */
    function setBuybackAddress(address account) external onlyOwner returns (bool) {
        _buybackAddress = account;
        return true;
    }

    /**
     * Interface to set address for processor.
     *
     * @param account Address for collecting processor.
     *
     * @return boolean.
     */
    function setProcessorAddress(address account) external onlyOwner returns (bool) {
        _processorAddress = account;
        return true;
    }

    /**
     * Interface to set address for buybackFreeze.
     *
     * @param account Address for collecting buybackFreeze.
     *
     * @return boolean.
     */
    function setBuybackFreezeAddress(address account) external onlyOwner returns (bool) {
        if (_buybackFreezeAddress == address(0)) {
            _buybackFreezeAddress = account;
            return true;
        }
        return false;
    }

    /**
     * Interface to set buybackFreeze deadline.
     *
     * @param sec time to deadline.
     *
     * @return boolean.
     */
    function setBuybackFreezeDeadline(uint256 sec) external onlyOwner returns (bool) {
        require(_buybackFreezeDeadline < block.timestamp + sec);
        _buybackFreezeDeadline = block.timestamp + sec;
        return true;
    }

    /**
     * Interface to set fee percentage for marketing.
     *
     * @param value Percentage in milipercents.
     *
     * @return boolean
     */
    function setMarketingMilipercent(uint256 value) external onlyOwner returns (bool) {
        _marketingMilipercent = value;
         require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent <= 12000, 'Fee must not increase');
        require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent + _extra_fee <= 99000, 'Fee must not increase');
        return true;
    }

    /**
     * Interface to set fee percentage for buyBack.
     *
     * @param value Percentage in milipercents.
     *
     * @return boolean
     */
    function setBuybackMilipercent(uint256 value) external onlyOwner returns (bool) {
        _buyBackMilipercent = value;
        require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent <= 12000, 'Fee must not increase');
        require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent + _extra_fee <= 99000, 'Fee must not increase');
        return true;
    }



    /**
     * Interface to set fee percentage for dividend.
     *
     * @param value Percentage in milipercents.
     *
     * @return boolean
     */
    function setDividendMilipercent(uint256 value) external onlyOwner returns (bool) {
        _dividendMilipercent = value;
        require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent <= 12000, 'Fee must not increase');
        require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent + _extra_fee <= 99000, 'Fee must not increase');
        return true;
    }


    function setExtraFee(uint256 value) external onlyOwner returns (bool) {
        _extra_fee = value;
        require(_marketingMilipercent + _buyBackMilipercent + _dividendMilipercent + _extra_fee <= 99000, 'Fee must not increase');
        return true;
    }

    function setExtraFeeDuration(uint256 value) external onlyOwner returns (bool) {
        _extra_fee_duration = value;
        return true;
    }



    /**
     * Interface to set Minimum Dividend.
     *
     * @param value Percentage in MinimumDividend.
     *
     * @return boolean
     */
    function setMinimumDividend(uint256 value) external onlyOwner returns (bool) {
        require(value <= 10 * 10**18);
        _minimumDividend = value;
        return true;
    }

    function tryToAddInList(address account) internal {
        if (!_isInList[account]) {
            _isInList[account] = true;
            _addressList.push(account);
        }
    }

    /**
     * Interface to exclude address from fee during recieve.
     *
     * @param account Address of recipient.
     * @param value Boolean.
     *
     * @return boolean
     */
    function excludeIncludeFee(address account, bool value) public onlyOwner returns (bool) {
        _noFee[account] = value;
        return true;
    }

    /**
     * Interface to set whiteListEnabled;
     *
     * @param value Boolean.
     *
     * @return boolean
     */
    function setWhiteListEnabled(bool value) public onlyOwner returns (bool) {
        _whiteListEnabled = value;
        return true;
    }

    function setNftIntegrating(bool value) public onlyOwner returns (bool) {
        _nftIntegrating = value;
        return true;
    }

    function setNftEnabled(address account, bool value) public onlyOwner returns (bool) {
        _nftEnabled[account] = value;
        return true;
    }

    /**
     * Interface to set WhiteList mambers
     *
     * @param account Address of recipient.
     * @param value Boolean.
     *
     * @return boolean
     */
    function setWhiteList(address account, bool value) public onlyOwner returns (bool) {
        _whiteListed[account] = value;
        return true;
    }

    function getUnpaidDividend(address account) public view returns (uint256) {
        return _unpaidDividend[account];
    }

    /**
     * Interface to exclude include dividend receiver.
     *
     * @param account Address of recipient.
     * @param value Boolean.
     *
     * @return boolean
     */
    function excludeIncludeDividend(address account, bool value) public onlyOwner returns (bool) {
        if (value) {
            _noDividendAddressList.push(account);
        }
        _noDividend[account] = value;
        return true;
    }

    function swapEthForDividendToken(uint256 ethAmount) internal returns (bool) {
        // generate the uniswap pair path of weth -> dividend token
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = BUSD;

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any amount of BUSD
            path,
            address(this),
            block.timestamp
        );
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) public returns (bool) {
        require(_msgSender() == _processorAddress || tokenAmount <= _totalSupply.div(1000));
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return true;
    }

    /**
     * Interface to swap BNB to BUSD, split and transfer fees to destination (called before giving dividends).
     *
     * @return boolean
     */

    function convertAndSplitFee() public returns (bool) {
        require(_msgSender() == _processorAddress);
        require(_totalDividend == 0);
        IERC20 BusdToken = IERC20(BUSD);

        uint256 balance = address(this).balance;
        uint256 totalPercent = _marketingMilipercent + _buyBackMilipercent + _dividendMilipercent;
        uint256 marketingFee = (balance * _marketingMilipercent) / totalPercent;
        uint256 buyBackFee = (balance * _buyBackMilipercent) / totalPercent;

        payable(_marketingAddress).transfer(marketingFee);
        payable(_buybackAddress).transfer(buyBackFee);

        uint256 busdBalance = BusdToken.balanceOf(address(this));
        swapEthForDividendToken(address(this).balance);
        uint256 balanceIncrease = BusdToken.balanceOf(address(this)).sub(busdBalance);

        _totalDividend = balanceIncrease;
        return true;
    }

    function getTotalDividendableSupply() public view returns (uint256) {
        uint256 totalDividendableSupply = _totalSupply;
        uint256 noDividendListLength = _noDividendAddressList.length;
        for (uint256 i = 0; i < noDividendListLength; i++) {
            totalDividendableSupply = totalDividendableSupply.sub(_balances[_noDividendAddressList[i]]);
        }
        return totalDividendableSupply;
    }

    /**
     * Interface to give dividends to holders.
     *
     * @return boolean
     */
    function payDividends(uint256 gasThreshold) public returns (uint256, bool) {
        require(_msgSender() == _processorAddress);

        uint256 listLength = _addressList.length;

        IERC20 BusdToken = IERC20(BUSD);

        uint256 totalDividendableSupply = getTotalDividendableSupply();

        while (_dividendIndex < listLength && gasThreshold < gasleft()) {
            address account = _addressList[_dividendIndex];
            if (!_noDividend[account]) {
                uint256 amount = _unpaidDividend[account] +
                    (_totalDividend * _balances[account]) /
                    totalDividendableSupply;

                if (_minimumDividend < amount) {
                    BusdToken.transfer(account, amount);
                    _unpaidDividend[account] = 0;
                } else {
                    _unpaidDividend[account] = amount;
                }
            }
            _dividendIndex++;
        }
        if (_dividendIndex == listLength) {
            _totalDividend = 0;
            _dividendIndex = 0;
        }
        return (_dividendIndex, _dividendIndex < listLength);
    }
}