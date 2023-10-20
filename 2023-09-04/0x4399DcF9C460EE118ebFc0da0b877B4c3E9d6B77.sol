// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// router inferface
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

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

// Interface of the ERC20 standard as defined in the EIP.
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address from, address to) external view returns (uint256);
    function approve(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

// PriceUSDTCalcuator interface
interface IPriceUSDTCalcuator {
    function tokenPriceUSDT(address token) external view returns (uint256);
    function lpPriceUSDT(address lp) external view returns (uint256);
}

// ETELeaderTracker interface
interface IETELeaderTracker {
    function swapToLeader(address _eteToken) external;
}

// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "owner error");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// new swap V2.
// ete is mos.
// new..
contract NewSwapV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address public priceUSDTCalcuator;  // price usdt calculator contract address.
    address public eteLeaderTracker;    // ete leader tracker contract address.
    address public ete;                 // ete address.
    address public usdt;                // usdt address.
    address public router;              // router address.

    mapping(uint256 => swapMsg) public swapMsgOf; // all swap.
    struct swapMsg {
        address fromToken;  // pay token address.
        bool fromIsLp;      //  from is lp.
        address toToken;    // gain token address.
        bool toIsLp;        //  to is lp.
        bool isOpen;        // is open.
    }
    mapping(address => bool) public priceIsUsdt;      // price is usdt.(like xete, sete, bete, cete, ...)
    mapping(address => uint256) public priceIsExist;  // price is user-defined. (if umos price usdt is 1e19, 1umos = 10usdt, if 0 is not exist).

    uint256 public swapMsgOfCount;               // swap pool count.
    bool public allIsOpen = true;                // all pool is open.
    bool public usdtSwapIsAddLiquidity = true;   // true= is add. false = not add.

    constructor(
        address priceUSDTCalcuator_,
        address eteLeaderTracker_,
        address mos_,
        address usdt_,
        address router_
    ) {
        priceUSDTCalcuator = priceUSDTCalcuator_;
        eteLeaderTracker = eteLeaderTracker_;
        ete = mos_;
        usdt = usdt_;
        router = router_;

        TransferHelper.safeApprove(ete, router, type(uint256).max);
        TransferHelper.safeApprove(usdt, router, type(uint256).max);
    }


    event SwapTo(address account, address fromToken, uint256 fromAmount, address toToken, uint256 toAmount);


    function addApprove(address _token, address _to, uint256 _amount) public onlyOwner {
        TransferHelper.safeApprove(_token, _to, _amount);
    }

    function setPriceUSDTCalcuator(address newPriceUSDTCalcuator) public onlyOwner {
        priceUSDTCalcuator = newPriceUSDTCalcuator;
    }

    function setEteLeaderTracker(address newEteLeaderTracker) public onlyOwner {
        eteLeaderTracker = newEteLeaderTracker;
    }

    function setEte(address newEte) public onlyOwner {
        ete = newEte;
    }

    function setUsdt(address newUsdt) public onlyOwner {
        usdt = newUsdt;
    }

    function setRouter(address newRouter) public onlyOwner {
        router = newRouter;
    }

    function setAllIsOpen(bool newAllIsOpen) public onlyOwner {
        allIsOpen = newAllIsOpen;
    }

    function setUsdtSwapIsAddLiquidity(bool newUsdtSwapIsAddLiquidity) public onlyOwner {
        usdtSwapIsAddLiquidity = newUsdtSwapIsAddLiquidity;
    }
    
    // add price eq usdt of token.
    function addPriceIsUsdt(address _token, bool _isPriceUsdt) public onlyOwner {
        require(_token != address(0), "zero address error 0");
        priceIsUsdt[_token] = _isPriceUsdt;
    }

    // add token price is exist.
    function addPriceIsExist(address _token, uint256 _priceUsdtAmount) public onlyOwner {
        require(_token != address(0), "zero address error 0");
        priceIsExist[_token] = _priceUsdtAmount;
    }

    // add swap msg
    function addSwapMsg(address _fromToken, bool _fromIsLp, address _toToken, bool _toIsLp, bool _isOpen) public onlyOwner {
        require(_fromToken != address(0), "zero address error 0");
        require(_toToken != address(0), "zero address error 1");

        swapMsgOfCount++;
        swapMsgOf[swapMsgOfCount] = swapMsg({
            fromToken: _fromToken,
            fromIsLp: _fromIsLp,
            toToken: _toToken,
            toIsLp: _toIsLp,
            isOpen: _isOpen
        });
    }

    // change swap smg
    function changeSwapMsg(uint256 _index, address _fromToken, bool _fromIsLp, address _toToken, bool _toIsLp, bool _isOpen) public onlyOwner {
        require(_index > 0 && _index <= swapMsgOfCount, "index error");
        require(_fromToken != address(0), "zero address error 0");
        require(_toToken != address(0), "zero address error 1");

        swapMsgOf[_index] = swapMsg({
            fromToken: _fromToken,
            fromIsLp: _fromIsLp,
            toToken: _toToken,
            toIsLp: _toIsLp,
            isOpen: _isOpen
        });
    }

    // get swap lock
    function getAllSwapMsg()external view returns (swapMsg[] memory allSwapMsg){
        uint256 _count = swapMsgOfCount; // save gas.
        allSwapMsg = new swapMsg[](_count);
        for (uint256 i = 1; i <= _count; i++) {
            allSwapMsg[i - 1] = swapMsgOf[i];
        }
    }

    // token -> usdt
    function calculateTokenAmountEqUsdtAmount(address _tokenOrLp, uint256 _tokenAmount, bool _isLp) public view returns (uint256) {
        if(priceIsExist[_tokenOrLp] > 0) {
            // is exist.
            uint256 _price = priceIsExist[_tokenOrLp];
            uint256 usdtAmount = _tokenAmount.mul(_price).div(1e18);
            return usdtAmount;
        }

        if (priceIsUsdt[_tokenOrLp]) {
            // if price eq usdt.
            return _tokenAmount;
        } else if (_isLp) {
            // is lp
            uint256 lpPrice = IPriceUSDTCalcuator(priceUSDTCalcuator).lpPriceUSDT(_tokenOrLp);
            uint256 usdtAmount = _tokenAmount.mul(lpPrice).div(1e18);
            return usdtAmount;
        } else {
            // is token
            uint256 tokenPrice = IPriceUSDTCalcuator(priceUSDTCalcuator).tokenPriceUSDT(_tokenOrLp);
            uint256 usdtAmount = _tokenAmount.mul(tokenPrice).div(1e18);
            return usdtAmount;
        }
    }

    // usdt -> token
    function calculateUsdtAmountEqTokenAmount(address _tokenOrLp, uint256 _usdtAmount, bool _isLp) public view returns (uint256) {
        if(priceIsExist[_tokenOrLp] > 0) {
            // is exist.
            uint256 _price = priceIsExist[_tokenOrLp];
            uint256 tokenAmount = _usdtAmount.mul(1e18).div(_price);
            return tokenAmount;
        }

        if (priceIsUsdt[_tokenOrLp]) {
            // if price eq usdt.
            return _usdtAmount;
        } else if (_isLp) {
            // is lp
            uint256 lpPrice = IPriceUSDTCalcuator(priceUSDTCalcuator).lpPriceUSDT(_tokenOrLp); // 5e18
            uint256 lpAmount = _usdtAmount.mul(1e18).div(lpPrice);
            return lpAmount;
        } else {
            // is token
            uint256 tokenPrice = IPriceUSDTCalcuator(priceUSDTCalcuator).tokenPriceUSDT(_tokenOrLp);
            uint256 tokenAmount = _usdtAmount.mul(1e18).div(tokenPrice);
            return tokenAmount;
        }
    }

    // swap before
    function swapToBefore(uint256 _index, uint256 _fromAmount) public view returns (uint256 toAmount) {
        swapMsg memory _swapMsg = swapMsgOf[_index];
        // calculate to amount.
        uint256 _fromAmountPriceUsdt = calculateTokenAmountEqUsdtAmount(_swapMsg.fromToken, _fromAmount, _swapMsg.fromIsLp);
        toAmount = calculateUsdtAmountEqTokenAmount(_swapMsg.toToken, _fromAmountPriceUsdt, _swapMsg.toIsLp);

        // if from is usdt. fee is 2%.
        if(_swapMsg.fromToken == usdt) {
            toAmount = toAmount.mul(98).div(100);
        }
    }

    // swap
    function swapTo(uint256 _index, uint256 _fromAmount) public nonReentrant {
        require(allIsOpen, "not all open");
        address account = msg.sender;
        swapMsg memory _swapMsg = swapMsgOf[_index];
        require(_swapMsg.isOpen, "not open");
        require(!isContract(account), "not user1");
        require(tx.origin == account, "not user2");

        // calculate to amount.
        uint256 _toAmount = swapToBefore(_index, _fromAmount);
        require(_fromAmount > 0, "from amount is zero");
        require(_toAmount > 0, "to amount is zero");
        TransferHelper.safeTransferFrom(_swapMsg.fromToken, account, address(this), _fromAmount);
        TransferHelper.safeTransfer(_swapMsg.toToken, account, _toAmount);

        // emit
        emit SwapTo(account, _swapMsg.fromToken, _fromAmount, _swapMsg.toToken, _toAmount);
        
        // if is add && fromtoken is usdt, add ete-usdt pool.
        if (usdtSwapIsAddLiquidity && _swapMsg.fromToken == usdt) _addPool(_fromAmount);

        // help swap
        _helpSwap();
    }

    // help swap earn.
    function _helpSwap() private {
        try IETELeaderTracker(eteLeaderTracker).swapToLeader(ete) {} catch {}
    }

    function _addPool(uint256 _usdtAmount) private {
        // swap ete
        uint256 _usdtSwapEteAmount = _usdtAmount.div(2);
        // ete balance before.
        uint256 _eteBalanceBefore = IERC20(ete).balanceOf(address(this));

        // usdt swap ete
        address[] memory _path = new address[](2);
        _path[0] = usdt;
        _path[1] = ete;
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _usdtSwapEteAmount,
            0,
            _path,
            address(this),
            block.timestamp
        );

        // ete balance last.
        uint256 _eteBalanceLast = IERC20(ete).balanceOf(address(this));
        // add pool
        uint256 _eteAddPoolAmount = _eteBalanceLast.sub(_eteBalanceBefore);
        IUniswapV2Router02(router).addLiquidity(
            usdt,
            ete,
            _usdtSwapEteAmount,
            _eteAddPoolAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    // take token
    function takeToken(address token, address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}