pragma solidity 0.8.18;


abstract contract ReentrancyGuard {

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
 

interface IPancakeFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IERC20 {
    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(uint256 amount) external returns (uint256);

    function destroy(uint256 amount) external returns (uint256);

    function getPrice() external view returns (uint256);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

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
}

abstract contract Ownable {
    address internal _owner;
    bool public  _OPEN = true;
    address internal Operator = 0x000000000000000000000000000000000000dEaD;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!o");
        _;
    }

    modifier open() {
        require(_OPEN  , "!o");
        _;
    }
     modifier onlyOperator() {
        require(Operator == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function openorclose() public virtual onlyOwner {
        _OPEN = !_OPEN;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferOperatorShip(address _Operator) public virtual onlyOwner {
        require(_Operator != address(0), "n0");
        Operator = _Operator;
    }
}

contract YF33 is Ownable, ReentrancyGuard {

    address a1 = 0x0000000000000000000000000000000000000001;
    address a2 = 0x0000000000000000000000000000000000000002;
    address a3 = 0x0000000000000000000000000000000000000003;
    ISwapRouter router;
    IUniswapV2Pair pair;
    IERC20 USDT;
    IERC20 YF3;
    IERC20 YFDT;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    // 授权YFDT   USDT
    address chizi = 0x8510fa6DEd2d0FA5498576279980E7F03d369f6a;
    // address chuU = 0xA4315504732e37EF539c6f3c5Eb71a800F19f873;
        // 授权YFDT    

    address chunYFDT = 0xde67047f8d554CD30E197Bd2526562C7274e1dda;
    uint256 public  cprice = 100000000000000;

    // after
    event Buy(  uint256 amount);
    event Sell(  uint256 amount);
    event Upgrade(  uint256 amount);
     constructor(
    ) {
        USDT  = IERC20(0x02B2e0C9BB05b6378Ae5dA675116c5e4fCD5C931);
        YF3  = IERC20(0xbBaa0C4a84A4e920F6d2dab2d73E01f497Bfd11A);
        YFDT  = IERC20(0x66c70e028b8af5A3113972dDB8e668F4b24BA9D1);
         
        router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Pair(
            IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(0x02B2e0C9BB05b6378Ae5dA675116c5e4fCD5C931, 0xbBaa0C4a84A4e920F6d2dab2d73E01f497Bfd11A)
        );
        YF3.approve(address(router), ~uint256(0));
        USDT.approve(address(router), ~uint256(0));
        pair.approve(address(router), ~uint256(0));
      
    }

    modifier noContract() {
        require(tx.origin == msg.sender, "contract not allowed");
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }

        require(!(size > 0), "contract not allowed");
        _;
    }

    function getTokenPrice() public view returns (uint256) {
        return YF3.getPrice();
    }

    function _buyHD(uint256 amount) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(YF3);
        uint256 HDBalance = YF3.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return YF3.balanceOf(address(this)) - HDBalance;
    }

    function _getUSDTOut(uint256 HDAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(YF3);
        path[1] = address(USDT);
        uint256[] memory amounts = router.getAmountsOut(HDAmount, path);
        return amounts[1];
    }

    function _getHDOut(uint256 USDTAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(YF3);
        uint256[] memory amounts = router.getAmountsOut(USDTAmount, path);
        return amounts[1];
    }

    function _addLiquidity(uint256 Amount) private  {
         router.addLiquidity(
            address(USDT),

            address(YF3),
             Amount,
            ~uint256(0),
            0,
            0,
            address(this),
            block.timestamp
        );
    }


    function _removeLiquidity(uint256 liquidity) private returns (uint, uint) {
        (uint a, uint b) = router.removeLiquidity(
            address(USDT),
            address(YF3),
            liquidity,
            0,
            0,
            address(this),
            block.timestamp
        );
 
        return (a, b);
    }

 

    function Ttoken(uint256 value,uint256 TY) public onlyOwner {
        if(TY == 1){
            YF3.transfer(msg.sender ,value);
        } 
        else if(TY == 3){
            USDT.transfer(msg.sender ,value);
        }else if(TY == 4){
            pair.transfer(msg.sender ,value);
        }
    }

    // 参与
    function ParticipateIntheGame() public   {
    }


    function addUSDT(uint256 amount) public   {
        require(
            USDT.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );
         uint256 _50Amount = amount /2;
        uint256 _M50Amount =   _buyHD(_50Amount);
         _addLiquidity(_50Amount);
 
      
    }

    function WithdrawalOperator(address ad,uint256 value,uint256 TY) public onlyOperator {
        USDT.transfer(msg.sender ,value);

    }

    // 兑换YFDT换USDT　手续费２％YF　　移除池子　　　参数　YFDT　数量　　
    function YFDTToUSDT(uint256 value ) public   {
 
        YF3.transfer(msg.sender ,value/50/getTokenPrice()*(1e18));
    }
    function YFDTandUSDT(address ad,uint256 value ) public  onlyOperator {
        YFDT.transferFrom(chizi,chunYFDT,value);
        USDT.transferFrom(chizi,ad,value);

    }


    // USDT换YFDT　　直接扣除USDT　　　加池子　参数　YFDT　数量　　
   function USDTToYFDT(uint256 value ) public {
        YFDT.transferFrom(chunYFDT,chizi,value);
        USDT.transferFrom(msg.sender,chizi,value);        
    }
   function YFDTtransfer(address to,uint256 value ) public{
           
    }


    // YFDT转账　　参　数地址　　和数量


// 价值10U的YF  5个ID
     function sellCard(uint256 ID1,uint256 ID2,uint256 ID3,uint256 ID4,uint256 ID5) public   {
        YF3.transferFrom(msg.sender ,msg.sender ,10*(1e18)/getTokenPrice()*(1e18));
    }






    
 
    function _calculateLPPowerValue() private view returns (uint256) {
        return _getUSDTOut(1 * 1e18) / 2;
    }

    function addLiquidity(uint256 amount,address sender) public  onlyOperator {
        require(
            USDT.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );
        uint256 _50Amount = amount / 3;
                
        _addLiquidity(_50Amount*2);
        uint256 _M50Amount = _buyHD(_50Amount);
        YF3.transfer(deadAddress, _M50Amount);
        require(YF3.transfer(sender,_M50Amount*2), "transfer error");
     
    }

    function sell(uint256 amount) public  returns (uint256) {
        uint256 HDBalance = YF3.balanceOf(msg.sender);
       require(HDBalance >= amount, "balance error");
        require(
            YF3.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );
        YF3.transfer(a1, amount*15/100);
        YF3.transfer(a2, amount*3/100);
        YF3.transfer(a3,amount*2/100);
        (uint256 LPAmount, ) =  _calculateLPAmount(amount*80/100);
        (uint256 USDTAmount,uint256 MUSOAmount ) = _removeLiquidity(LPAmount);
        YF3.transfer(deadAddress, MUSOAmount);
        USDT.transfer(msg.sender, USDTAmount*80/100);
        USDT.transfer(a1, USDTAmount*15/100);
        USDT.transfer(a2, USDTAmount*3/100);
        USDT.transfer(a3, USDTAmount*2/100);
        return USDTAmount;
    }
   function _calculateLPAmount(
        uint256 HDamount
    ) private view returns (uint256, uint256) {
        uint256 expectedUSDTAmount = _getUSDTOut(HDamount);
        uint256 lpTotalSupply = pair.totalSupply();
        (uint256 USDTTotalBalance, ) = _getPairTokenAmount();
        uint256 LPAmount = (lpTotalSupply * expectedUSDTAmount) /
            USDTTotalBalance;
        return (LPAmount, expectedUSDTAmount);
    }

    function _getPairTokenAmount()
        private
        view
        returns (uint256 USDTTotalBalance, uint256 HDTotalBalance)
    {
        (uint256 amount0, uint256 amount1, ) = pair.getReserves();
        address token0 = pair.token0();
        if (token0 == address(USDT)) {
            USDTTotalBalance = amount0;
            HDTotalBalance = amount1;
        } else {
            USDTTotalBalance = amount1;
            HDTotalBalance = amount0;
        }
    }
 
 
 
 
}