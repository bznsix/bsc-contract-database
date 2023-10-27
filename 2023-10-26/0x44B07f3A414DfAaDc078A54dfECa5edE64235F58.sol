// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// chain id.
library ChainId {
    function get() internal view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
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

// safe transfer.
// if is contract maybe is error. if account must success.
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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

// IERC20.
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// context.
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// owner.
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == owner(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

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

// ReentrancyGuard.
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

// Mining
contract MiningV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;


    address public payToken;                     // pay token is usdt.
    address public fuelToken;                    // fuel token.
    address public mos;                          // mos token.
    address public eth;                          // eth token.
    address public router;                       // router.
    address public toUsdt;                       // to usdt address.
    address public toMos;                        // to mos address.
    address public toEth;                        // to eth address.
    bool public isSwap = false;                  // is swap mos and eth.
    uint256[3] public swapRatio = [20, 50, 30];  // 0=swap mos, 1=swap eth, 2=keep usdt toUsdtV2. [20, 50, 30].
    address public toUsdtV2;                     // swap time usdt to address.

    
    // all mining machine.
    mapping(uint256 => MiningMachineMsg) public miningMachine;   // type -> MiningMachine.
    struct MiningMachineMsg {
        uint256 miningMachineType;            // mining machine type.
        uint256 price;                       // price is usdt, pay usdt.
        uint256 earnMul;                     // denominator is 100.
        uint256 count;                       // count number.
        bool isOpen;
    }
    uint256 public miningMachineNextType = 0;   // next type.

    // account all mining machine.
    mapping(address => uint256[]) public accountOrders;                        // account orders.
    mapping(uint256 => OrderMiningMachineMsg) public orderMiningMachine;       // order -> MiningMachine.
    struct OrderMiningMachineMsg {
        uint256 miningMachineType;           // mining machine type.
        uint256 order;                       // order.
        uint256 price;                       // price is usdt, pay usdt.
        uint256 earnMul;                     // denominator is 100.
        uint256 buyTime;                     // buy time.
        address account;                     // order owner.
    }
    uint256 public nextOrderID = 0;  // next order ID.

    // sign.
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)"); // EIP721 domain.
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant RUNLOTTERY_REWARDS_PERMIT_TYPEHASH = keccak256("claim(address account,address token,uint256 amount,uint256 rand)"); // sign function.
    address public signer; // signer.
    mapping(uint256 => bool) public nonceUsed;


    constructor(address payToken_, address fuelToken_, address signer_, address mos_, address eth_, address router_) {
        payToken = payToken_;
        fuelToken = fuelToken_;
        signer = signer_;

        mos = mos_;
        eth = eth_;
        router = router_;
        toUsdt = address(this);
        toMos = address(this);
        toEth = address(this);
        toUsdtV2 = address(this);

        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("Mining")), ChainId.get(), address(this)));
    }


    event AddMiningMachine(uint256 miningMachineType, uint256 price, uint256 earnMul, bool isOpen);
    event ChangeMiningMachine(uint256 miningMachineType, uint256 price, uint256 earnMul, bool isOpen);
    event Buy(uint256 miningMachineType, address account, uint256 orderID, uint256 price, uint256 earnMul, uint256 buyTime);
    event Claim(address account, address token, uint256 amount, uint256 rand);

    
    receive() external payable {}

    function takeETH(address to, uint256 amount) external onlyOwner {
        require(amount > 0, "amount can not be 0");
        require(to != address(0), "invalid to address");
        TransferHelper.safeTransferETH(to, amount);
    }

    function takeToken(address token, address to, uint256 amount) external onlyOwner {
        require(to != address(0), "invalid to address");
        require(isContract(token), "token not contract");
        TransferHelper.safeTransfer(token, to, amount);
    }

    // set pay token.
    function setPayToken(address newPayToken) external onlyOwner {
        require(newPayToken != address(0), "invalid to address");
        payToken = newPayToken;
    }

    // set fuel token.
    function setFuelToken(address newFuelToken) external onlyOwner {
        require(newFuelToken != address(0), "invalid to address");
        fuelToken = newFuelToken;
    }

    // set signer.
    function setSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "invalid to address");
        signer = newSigner;
    }

    // set mos.
    function setMos(address newMos) external onlyOwner {
        require(newMos != address(0), "invalid to address");
        mos = newMos;
    }

    // set eth.
    function setEth(address newEth) external onlyOwner {
        require(newEth != address(0), "invalid to address");
        eth = newEth;
    }

    // set router.
    function setRouter(address newRouter) external onlyOwner {
        require(newRouter != address(0), "invalid to address");
        router = newRouter;
    }

    // set toUsdt.
    function setToUsdt(address newToUsdt) external onlyOwner {
        require(newToUsdt != address(0), "invalid to address");
        toUsdt = newToUsdt;
    }

    // set toMos.
    function setToMos(address newToMos) external onlyOwner {
        require(newToMos != address(0), "invalid to address");
        toMos = newToMos;
    }

    // set toEth.
    function setToEth(address newToEth) external onlyOwner {
        require(newToEth != address(0), "invalid to address");
        toEth = newToEth;
    }

    // set swapRatio.
    function setSwapRatio(uint256[3] memory newSwapRatio) external onlyOwner {
        uint256 _total = newSwapRatio[0] + newSwapRatio[1] + newSwapRatio[2];
        require(_total == 100, "not eq 100");
        swapRatio = newSwapRatio;
    }

    // set toUsdtV2.
    function setToUsdtV2(address newToUsdtV2) external onlyOwner {
        require(newToUsdtV2 != address(0), "invalid to address");
        toUsdtV2 = newToUsdtV2;
    }

    // set isSwap.
    function setIsSwap(bool newIsSwap) external onlyOwner {
        isSwap = newIsSwap;
    }

    // set nonce used.
    function setNonceUsed(uint256 _nonce, bool _status) external onlyOwner {
        require(_nonce != 0, "invalid number");
        nonceUsed[_nonce] = _status;
    }

    // add MiningMachine.
    function addMiningMachine(uint256 _price, uint256 _earnMul, bool _isOpen) external onlyOwner {
        miningMachineNextType++;
        miningMachine[miningMachineNextType] = MiningMachineMsg({
            price: _price,
            miningMachineType: miningMachineNextType,
            earnMul: _earnMul,
            count: 0,
            isOpen: _isOpen
        });
        emit AddMiningMachine(miningMachineNextType, _price, _earnMul, _isOpen);
    }

    // change MiningMachine.
    function changeMiningMachine(uint256 _miningMachineType, uint256 _price, uint256 _earnMul, bool _isOpen) external onlyOwner {
        MiningMachineMsg storage _MiningMachineMsg = miningMachine[_miningMachineType];
        _MiningMachineMsg.price = _price;
        _MiningMachineMsg.earnMul = _earnMul;
        _MiningMachineMsg.isOpen = _isOpen;

        emit ChangeMiningMachine(_miningMachineType, _price, _earnMul, _isOpen);
    }

    // get all MiningMachine.
    function getAllMiningMachine() external view returns(MiningMachineMsg[] memory) {
        uint256 count = miningMachineNextType;
        MiningMachineMsg[] memory _MiningMachines = new MiningMachineMsg[](count);

        for(uint256 i = 1; i <= count; i++) {
            _MiningMachines[i-1] = miningMachine[i];
        }
        return _MiningMachines;
    }

    // _buy.
    function _buy(uint256 _miningMachineType, address _account) private returns(uint256) {
        MiningMachineMsg storage _MiningMachineMsg = miningMachine[_miningMachineType];
        _MiningMachineMsg.count++;
        require(_MiningMachineMsg.isOpen, "not open");
        require(!isContract(_account), "is contract error");

        nextOrderID++;
        accountOrders[_account].push(nextOrderID);
        orderMiningMachine[nextOrderID] = OrderMiningMachineMsg({
            miningMachineType: _miningMachineType,
            order: nextOrderID,
            price: _MiningMachineMsg.price,
            earnMul: _MiningMachineMsg.earnMul,
            buyTime: block.timestamp,
            account: _account
        });
        emit Buy(_miningMachineType, _account, nextOrderID, _MiningMachineMsg.price, _MiningMachineMsg.earnMul, block.timestamp);
        return nextOrderID;
    }

    // _swap mos and eth.
    function _usdtSwapMosAndEth(uint256 _usdtAmount) private {
        require(_usdtAmount > 0, "zero error");
        uint256 _usdtUseMos = _usdtAmount.mul(swapRatio[0]).div(100);
        uint256 _usdtUseEth = _usdtAmount.mul(swapRatio[1]).div(100);
        uint256 _usdtUseUsdt = _usdtAmount.mul(swapRatio[2]).div(100);

        // swap mos.
        address[] memory _path1 = new address[](2);
        _path1[0] = payToken;
        _path1[1] = mos;
        TransferHelper.safeApprove(payToken, router, _usdtUseMos);
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _usdtUseMos,
            0,
            _path1,
            toMos,
            block.timestamp);
        
        // swap eth.
        address[] memory _path2 = new address[](2);
        _path2[0] = payToken;
        _path2[1] = eth;
        TransferHelper.safeApprove(payToken, router, _usdtUseEth);
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _usdtUseEth,
            0,
            _path2,
            toEth,
            block.timestamp);

        // to usdt.
        require(isContract(payToken), "token not contract");
        TransferHelper.safeTransfer(payToken, toUsdtV2, _usdtUseUsdt);
    }

    // buy.
    function buy(uint256 _miningMachineType) external nonReentrant returns(uint256) {
        address _account = msg.sender;
        require(isContract(payToken), "token not contract");
        uint256 _usdtAmount = miningMachine[_miningMachineType].price;
        TransferHelper.safeTransferFrom(payToken, _account, toUsdt, _usdtAmount);  // pay token.
        // is swap
        if(isSwap) {
            _usdtSwapMosAndEth(_usdtAmount);
        }

        return _buy(_miningMachineType, _account);
    }

    // add buy.
    function addBuy(uint256 _miningMachineType, address _account) external onlyOwner returns(uint256) {
        return _buy(_miningMachineType, _account);
    }

    // get account orderIDs
    function getAccountOrders(address account) external view returns(uint256[] memory) {
        return accountOrders[account];
    }

    // get account all orders msg
    function getAccountAllOrdersMsg(address account) external view returns(OrderMiningMachineMsg[] memory) {
        uint256[] memory orders = accountOrders[account];
        uint256 count = orders.length;
        OrderMiningMachineMsg[] memory _OrderMiningMachineMsg = new OrderMiningMachineMsg[](count);

        for(uint256 i = 0; i < count; i++) {
            uint256 _order = orders[i];
            _OrderMiningMachineMsg[i] = orderMiningMachine[_order];
        }
        return _OrderMiningMachineMsg;
    } 

    // claim, take earn. 
    function claim(address account,address token,uint256 amount,uint256 rand,uint8 v,bytes32 r,bytes32 s) external nonReentrant {
        address signatory = signVerify(account,token,amount,rand,v,r,s);
        require(signatory != address(0), "invalid signature");
        require(signatory == signer, "invalid signature signer");
        require(!nonceUsed[rand], "rand used");
        nonceUsed[rand] = true;
        
        // transfer.
        require(msg.sender == account, "not your");
        require(!isContract(account), "is contract error");
        require(isContract(fuelToken), "token not contract 1");
        require(isContract(token), "token not contract 2");
        TransferHelper.safeTransferFrom(fuelToken, account, address(this), amount); // pay fuel.
        TransferHelper.safeTransfer(token, account, amount);

        emit Claim(account, token, amount, rand);
    }

    // sign verify.
    function signVerify(address account,address token,uint256 amount,uint256 rand,uint8 v,bytes32 r,bytes32 s) public view returns(address) {
        bytes32 structHash = keccak256(abi.encode(RUNLOTTERY_REWARDS_PERMIT_TYPEHASH,account,token,amount,rand));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01",DOMAIN_SEPARATOR,structHash));
        address signatory = ecrecover(digest,v,r,s);
        return signatory;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

}