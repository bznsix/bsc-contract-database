// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {
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

interface IUniswapV2Router01 {
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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}



contract BoredApeBuyCoinnManage is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    string private _name = "BoredApeBuyCoinnManage";
    string private _symbol = "BoredApeBuyCoinnManage";

    IUniswapV2Router01 public swapRouter;
    IERC20 public UsdtToken;
    IERC20 public coinToken;
    uint256 public slipCoe=950;// slipCoe/1000

    address public fundAddress;
    uint256 public byPriceUsdt=10*10**18;
    struct sBuyPropertys {
        uint256 id;
        address addr;
        uint256 buyAmount;
        uint256 time;
    }

    mapping(uint256 => sBuyPropertys) private _buyPropertys;
    mapping(address => uint256[]) private _buyIds;
    uint256 private _sumCount;
    
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    
    event BuyCoins(address indexed user, uint256 amount,uint256 id);

    constructor(){
        coinToken = IERC20(0xdd079B3678dfB01e451Ae58A37B0dEb39C90aDF3);
        UsdtToken = IERC20(0xFE3B8Dc3929E578019110Dc21546043787958818);
        swapRouter = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        fundAddress = 0x0ff1A9FB9712DaD271dE16C2fCFD82AC89b7BE57;
    }
    
    /* ========== VIEWS ========== */
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
   function balanceOf(address account) external view  returns (uint256) {
        return _balances[account];
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function sumCount() external view returns(uint256){
        return _sumCount;
    }

    //read info
    function buyInfo(uint256 iD) external view returns (
        uint256 id,
        address addr,
        uint256 buyAmount,
        uint256 time
        ) {
        require(iD <= _sumCount, "BoredApeBuyCoinnManage: exist num!");
        id = _buyPropertys[iD].id;
        addr = _buyPropertys[iD].addr;
        buyAmount = _buyPropertys[iD].buyAmount;
        time = _buyPropertys[iD].time;
        return (id,addr,buyAmount,time);
    }
    function buyNum(address addr) external view returns (uint256) {
        return _buyIds[addr].length;
    }
    function buyIthId(address addr,uint256 ith) external view returns (uint256) {
        require(ith < _buyIds[addr].length, "BoredApeBuyCoinnManage: not exist!");
        return _buyIds[addr][ith];
    }

    function buyInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        address[] memory addrArr,
        uint256[] memory buyAmountArr,
        uint256[] memory timeArr
        ) {
        require(toId <= _sumCount, "BoredApeBuyCoinnManage: exist num!");
        require(fromId <= toId, "BoredApeBuyCoinnManage: exist num!");
        idArr = new uint256[](toId-fromId+1);
        addrArr = new address[](toId-fromId+1);
        buyAmountArr = new uint256[](toId-fromId+1);
        timeArr = new uint256[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            idArr[i] = _buyPropertys[ith].id;
            addrArr[i] = _buyPropertys[ith].addr;
            buyAmountArr[i] = _buyPropertys[ith].buyAmount;
            timeArr[i] = _buyPropertys[ith].time;
            i = i+1;
        }
        return (idArr,addrArr,buyAmountArr,timeArr);
    }
    
    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "BoredApeBuyCoinnManage: not in White Adress");
        return _WhiteContractArr[ith];
    }
    //---write---//
    function buyCoin(uint256 amount,uint256 time) external nonReentrant{
        uint256 amountUsdt = amount*byPriceUsdt;
        require(isWhiteContract(_msgSender()), "BoredApeBuyCoinnManage: Contract not in white list!");
       
        swapTokensForToken(amountUsdt);

        _sumCount = _sumCount.add(1);
        _buyIds[_msgSender()].push(_sumCount);

        _buyPropertys[_sumCount].id = _sumCount;
        _buyPropertys[_sumCount].addr = _msgSender();
        _buyPropertys[_sumCount].buyAmount = amount;
        _buyPropertys[_sumCount].time = time;

        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit BuyCoins(msg.sender, amount, _sumCount);
    }

    function swapTokensForToken(uint256 amountIn) private  {
        UsdtToken.transferFrom(_msgSender(), address(this), amountIn);

        UsdtToken.safeApprove(address(swapRouter), amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = address(UsdtToken);
        path[1] = address(coinToken);

        uint256[] memory amountOut = swapRouter.getAmountsOut(amountIn, path);
        uint256 amountOutMin = amountOut[1]*slipCoe/1000;

        swapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            DEAD_ADDRESS,
            block.timestamp
        );
    }
    //---write onlyOwner---//
   function setParameters(address coinAddr,address usdtAddr, address swapRouterAddr,address fundAddr) external onlyOwner {
        coinToken = IERC20(coinAddr);
        UsdtToken = IERC20(usdtAddr);
        swapRouter = IUniswapV2Router01(swapRouterAddr);
        fundAddress = fundAddr;
    }
   function setSlipCoe(uint256 tSlipCoe) external onlyOwner {
        require(tSlipCoe <= 1000, "BoredApeBuyCoinnManage:SlipCoe too big");
        slipCoe = tSlipCoe;
    }
    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "BoredApeBuyCoinnManage:Account is already White list");
        require(account.isContract(), "BoredApeBuyCoinnManage: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "BoredApeBuyCoinnManage:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }


    
}