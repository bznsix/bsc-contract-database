pragma solidity ^0.8.17;

// SPDX-License-Identifier: Unlicensed

interface IERC20 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

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

    function setOwner(address _newOwner) internal {
        _owner = _newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

contract SQUARE is Context, IERC20, Ownable {
    using Address for address;
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    // MAIN WALLET ADDRESSES
    address private MKT = 0x682814DFb095053599DaDE2BdC88BE1cB9F9ECd0;

    // TOKEN GLOBAL VARIABLES
    string constant _name = "Square";
    string constant _symbol = "Square";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 150000000 * 10 ** _decimals;

    // INITIAL MAX WALLET HOLDING SET TO 100%
    uint256 public _maxWalletToken = _totalSupply;

    // MAPPINGS
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public liquidityAddress;
    mapping(address => bool) public _isBlacklisted;

    // BUY & TRANSFER FEE
    
    uint256 public transferTaxRate = 500;
    bool public takeFeeIfNotLiquidity = true;

    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 public marketingFee = 700;

    // SETS UP TOTAL FEE
    uint256 public totalFee = marketingFee;

    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 public constant feeDenominator = 10000;
    // SET UP FEE RECEIVERS
    address public marketingFeeReceiver = MKT;

    bool private swapping;

    // SWITCH TRADING
    bool public tradingOpen = false;

    mapping(address => bool) private _auth;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);

    // TOKEN SWAP SETTINGS
    bool inSwap;
    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply / 10000) * 1; // 0,01%
    uint256 public totalRealized = 0;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = pair;
        _auth[DEAD] = true;
        _auth[ZERO] = true;
        _auth[uniswapV2Pair] = true;
        _auth[owner()] = true;
        _auth[marketingFeeReceiver] = true;
        _auth[address(uniswapV2Router)] = true;
        _auth[address(this)] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[MKT] = true;
        liquidityAddress[uniswapV2Pair] = true;

        // INITIAL DISTRIBUTION
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        // GLOBAL REQUIREMENTS
        require(!_isBlacklisted[sender], "Blacklisted SENDER");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // TRADING STATUS
        checkTradingStatus(sender, recipient);
        // SHOULD I SWAP BACK?
        shouldSwapBack(sender, recipient);
        // SETS AMOUNT TO BE RECEIVED
        setAmountReceived(sender, recipient, amount);
    }

    // SETS RECEIVED AMOUNT
    function setAmountReceived(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, amount)
            : amount;
        // EXCHANGE TOKENS
        _balances[sender] -= amount;
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return amountReceived;
    }

    // SHOULD I SWAP BACK?
    function shouldSwapBack(address from, address to) internal {
        if (
            balanceOf(address(this)) >= swapThreshold &&
            !swapping &&
            !liquidityAddress[from] &&
            from != owner() &&
            to != owner()
        ) {
            if (liquidityAddress[to]) {
                swapping = true;
                swapBack();
                swapping = false;
            }
        }
    }

    // CHECKS TRADING STATUS
    function checkTradingStatus(
        address sender,
        address recipient
    ) internal view {
        if (
            sender != owner() &&
            recipient != owner() &&
            !_auth[sender] &&
            !_auth[recipient]
        ) {
            require(tradingOpen, "Trading not open yet");
        }
    }

    function resetTotalFees() internal {
        totalFee = marketingFee;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        if (
            !liquidityAddress[sender] &&
            !liquidityAddress[recipient] &&
            sender != address(uniswapV2Router) &&
            recipient != address(uniswapV2Router) &&
            msg.sender != address(uniswapV2Router) &&
            !takeFeeIfNotLiquidity
        ) {
            return amount;
        }
        uint256 feeAmount = 0;
        address feeReceiver = address(this);
        bool feeTaken = false;
        if (!feeTaken && liquidityAddress[recipient] && totalFee > 0) {
            feeAmount = ((amount * totalFee) / feeDenominator);
        } else if (!feeTaken) {
            feeAmount = ((amount * transferTaxRate) / feeDenominator);
        }
        if (feeAmount > 0) {
            _balances[feeReceiver] += feeAmount;
            emit Transfer(sender, feeReceiver, feeAmount);
            return (amount - feeAmount);
        } else {
            return amount;
        }
    }

    // SHOULD WE TAKE ANY TRANSACTION FEE ON THIS?
    function shouldTakeFee(
        address sender,
        address recipient
    ) internal view returns (bool) {
        if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            return true;
        } else {
            return false;
        }
    }

    // BASIC TRANSFER METHOD
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

    // SWITCH TRADING
    function tradingStatus(bool _status) public onlyOwner {
        require(_status, "You cannot disable trading.");
        tradingOpen = _status;
    }

    function authorize(address _address, bool _status) external onlyOwner {
        require(
            _auth[_address] != _status,
            "User is already set in that condition"
        );
        _auth[_address] = _status;
    }

    function swapBack() private {
        // SETS UP AMOUNT THAT NEEDS TO BE SWAPPED
        uint256 totalFeeWithoutReserve = (totalFee);

        uint256 amount = (balanceOf(address(this)));
        // CHECKS IF THERE IS ANY FEE THAT NEEDS TOKENS TO BE SWAPPED
        if (totalFeeWithoutReserve > 0 && balanceOf(address(this)) >= amount) {
            uint256 amountToSwap = (amount);
            uint256 amountBNB = swapTokensForEth(amountToSwap);
            if (amountBNB > 0) {
                // PAYS UP MARKETING WALLET WITH ALL BNB LEFT
                if (address(this).balance >= 0) {
                    // FUNDS SHOULD NOT BE KEPT IN THE CONTRACT
                    payable(marketingFeeReceiver).sendValue(
                        address(this).balance
                    );
                }
            }
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
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
        totalRealized += address(this).balance;
        return (address(this).balance);
    }

    function blackList(address _address, bool _enabled) external onlyOwner {
        require(
            _isBlacklisted[_address] != _enabled,
            "Address is already set in that condition"
        );
        _isBlacklisted[_address] = _enabled;
    }

    function checkAuth(address _msgSender) internal view {
        require(_msgSender == owner(), "You are not authorized");
    }

    function setIsFeeExempt(address holder, bool exempt) external {
        checkAuth(msg.sender);
        require(
            isFeeExempt[holder] != exempt,
            "Address is already set in that condition"
        );

        //NICE JOB. YOU DID IT!
        isFeeExempt[holder] = exempt;
    }

    function setFees(uint256 _marketingFee) external {
        checkAuth(msg.sender);

        marketingFee = _marketingFee;

        totalFee = marketingFee;
    }

    function setTransferTaxRate(
        uint256 _transferTaxRate,
        bool _takeFeeIfNotLiquidityAddress
    ) external {
        checkAuth(msg.sender);

        transferTaxRate = _transferTaxRate;
        takeFeeIfNotLiquidity = _takeFeeIfNotLiquidityAddress;
    }

    function setSellingFeeAddress(
        address _liquidityAddress,
        bool _enabled
    ) external {
        checkAuth(msg.sender);
        require(
            liquidityAddress[_liquidityAddress] != _enabled,
            "User is already set in that condition"
        );

        liquidityAddress[_liquidityAddress] = _enabled;
    }

    function setFeeReceivers(address _marketingFeeReceiver) external {
        checkAuth(msg.sender);
        require(
            _marketingFeeReceiver != ZERO &&
                _marketingFeeReceiver != DEAD &&
                _marketingFeeReceiver != uniswapV2Pair,
            "Invalid marketingFeeReceiver"
        );

        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external {
        checkAuth(msg.sender);
        require(
            _amount <= ((totalSupply() / 1000) * 5),
            "MAX_SWAPBACK amount cannot be higher than half percent"
        );

        // NICE JOB. YOU DID IT
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function renounceContract() external {
        checkAuth(msg.sender);

        setOwner(DEAD);
    }

    /**
     * Transfer ownership to new address
     */
    function transferOwnership(address adr) external {
        checkAuth(msg.sender);
        require(
            adr != ZERO && adr != DEAD && adr != address(this),
            "Invalid address"
        );

        // NICE JOB. YOU DID IT!
        address _previousOwner = owner();
        setOwner(adr);
        emit OwnershipTransferred(_previousOwner, adr);
    }

    function clearStuckBalance(uint256 amountPercentage) external {
        require(
            amountPercentage <= 100 && amountPercentage > 0,
            "You can only select a number from 1 to 100"
        );

        checkAuth(msg.sender);

        uint256 amountBNB = address(this).balance;
        uint256 weiAmount = (amountBNB * amountPercentage) / 100;
        payable(msg.sender).sendValue(weiAmount);
    }

    function withdrawTokens(address _tokenAddress) external {
        checkAuth(msg.sender);
        // NICE JOB. YOU DID IT!
        IERC20 ERC20token = IERC20(_tokenAddress);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
        // RESET AFTER SUCESSFULLY COMPLETING TASK
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply() - balanceOf(DEAD) - balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountSquare);
}