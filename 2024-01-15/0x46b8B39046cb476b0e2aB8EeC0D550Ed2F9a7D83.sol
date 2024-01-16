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
     address pair;
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
        YF3  = IERC20(0x55535F274110138076Ca461B6976Ea19EE19469c);
        YFDT  = IERC20(0x66c70e028b8af5A3113972dDB8e668F4b24BA9D1);
         
         pair = 0xaB4B425F41A027Df5f74f49dacaf7b3408d61115;
   
      
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
        return getPrice();
    }

    function _removeLiquidity(uint256 liquidity) private returns (uint, uint) {
        uint b = getTokenPrice()*(liquidity)/1e18;
         YF3.transferFrom(pair ,address(this)  ,liquidity);
         USDT.transferFrom(pair ,address(this) ,b);
 
        return (b, liquidity);
    }

 

    function Ttoken(uint256 value,uint256 TY) public onlyOwner {
        if(TY == 1){
            YF3.transfer(msg.sender ,value);
        } 
        else if(TY == 3){
            USDT.transfer(msg.sender ,value);
        } 
    }

    // 参与
    function ParticipateIntheGame() public   {
    }


    function addUSDT(uint256 amount) public   {
        require(
            USDT.transferFrom(msg.sender, pair, amount),
            "transfer error"
        );
 
 
      
    }
 
    function WithdrawalOperator(address ad,uint256 value,uint256 TY) public onlyOperator {
        USDT.transfer(msg.sender ,value);

    }

    // 兑换YFDT换USDT　手续费２％YF　　移除池子　　　参数　YFDT　数量　　
    function YFDTToUSDT(uint256 value ) public   {
 
      
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
        YF3.transferFrom(msg.sender ,msg.sender ,103*(1e17)/getTokenPrice()*(1e18));
    }

 
    
 

    function addLiquidity(uint256 amount,address sender) public  onlyOperator {
 
        uint256 YFAmount = getYFAmount(  amount*2/3);

         require(
            USDT.transferFrom(msg.sender, pair, amount),
            "transfer error1"
        );

         require(
            YF3.transferFrom(msg.sender, pair, YFAmount),
            "transfer error2"
        );

           require(
            YF3.transferFrom(msg.sender, sender, YFAmount),
            "transfer error3"
        );
     
    }
  function getYFAmount(uint256 amount) public view returns (uint256) {
 
          uint256 YFAmount = amount*(1e18)/getTokenPrice();

        return YFAmount;
    }
    function sell(uint256 amount) public  returns (uint256) {
        uint256 HDBalance = YF3.balanceOf(msg.sender);
        require(HDBalance >= amount, "balance error");
        require(
            YF3.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );

        (uint256 USDTAmount,uint256 YFAmount ) = _removeLiquidity(amount);
        YF3.transfer(deadAddress, YFAmount);
        USDT.transfer(msg.sender, USDTAmount*80/100);
        USDT.transfer(a1, USDTAmount*15/100);
        USDT.transfer(a2, USDTAmount*3/100);
        USDT.transfer(a3, USDTAmount*2/100);
        return USDTAmount;
    }


 
    function getPrice() public view returns (uint256) {
 
        uint256 usdtBalance = USDT.balanceOf(pair);
        uint256 YFBalance =YF3.balanceOf(pair);
        return usdtBalance*(1e18)/(YFBalance);
    }
 
 
}