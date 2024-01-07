pragma solidity ^0.8.0; 
//SPDX-License-Identifier: UNLICENSED
    library SafeMath { 
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
             uint256 c = a / b;
             return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }

    interface IERC20 {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        function mint(address _from,uint256 amount) external;
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
            function destroy(uint256 amount) external returns (uint256);

    }
    

    contract Base {
        using SafeMath for uint;
 
        receive() external payable {}  
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);
    function transfer(address to, uint256 amount) external returns (bool);

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


contract DataPlayer is Base{
    using SafeMath for uint;
    address  _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
 
    struct Player{
        address superior; 
        address[] subordinate;
        uint256 Time; 
        uint256 nodeLevel; 
    }


    struct Playerxx{
        address Player; 
        uint256 Time; 
        uint256 nodeLevel; 
    }






    mapping(address => Player)  public addressToPlayer;
    mapping(address => bool)  public isNode;

    uint256 public PlayerCount; 

    function owner() public view returns (address) {
        return _owner;
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IPancakeFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}
 
contract  BTC is DataPlayer {
    using SafeMath for uint;
    mapping(uint256 => uint256) public Price;
    IERC20 USDT;
    IERC20  BTC3;
    ISwapRouter router;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    address LPAddress;

    bool public open;
    IUniswapV2Pair pair;

    constructor()
     {
        Price[3] = 1000e18;
        Price[2] = 500e18;
        Price[1] = 200e18;

        _owner = _msgSender();
        isNode[address(this)] = true;  
        open = true;
        LPAddress = msg.sender;

        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        BTC3 = IERC20(0x245D2D01d4a16d5A594e951bb51131E8E508a366);
         
        router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Pair(
            IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(0x55d398326f99059fF775485246999027B3197955, 0x245D2D01d4a16d5A594e951bb51131E8E508a366)
        );

        BTC3.approve(address(router), ~uint256(0));
        USDT.approve(address(router), ~uint256(0));
        pair.approve(address(router), ~uint256(0));
    }

    function register(address _referral) external {
        require(isNode[_referral]  , "is not Node");
        addressToPlayer[msg.sender].superior = _referral;
        addressToPlayer[msg.sender].Time   = block.timestamp;
        addressToPlayer[_referral].subordinate.push(msg.sender);
     }

    function setopen() external onlyOwner {
        open = !open;
     }

    function setLP(address LP) external onlyOwner {
        LPAddress = LP;
     }

    function BUYnode(uint256 PackageType) public  {
        require(!isNode[msg.sender], "isNode");
        require(open, "open");
        require(PackageType > 0 && PackageType <4, "out");  
        USDT.transferFrom(msg.sender, address(this),Price[PackageType]);


        _addLiquidity(Price[PackageType]);
        uint256 addLP = pair.balanceOf(address(this));
 

        if(addressToPlayer[msg.sender].superior != address(this)){
            pair.transfer(addressToPlayer[msg.sender].superior, addLP.div(20));
        }
        pair.transfer(msg.sender, addLP.mul(35).div(100));

        uint256 LPBalance = pair.balanceOf(address(this));
        pair.transfer(LPAddress, LPBalance);

 
        isNode[msg.sender] = true;  
        addressToPlayer[msg.sender].nodeLevel  = PackageType;
    }

    function Tp(uint256 value) public onlyOwner {
        pair.transfer(msg.sender ,value);
    }

 

    function getSubordinate(address Player) public view returns(Playerxx[] memory SubordinateAddress) {
        uint256 totalCount = addressToPlayer[Player].subordinate.length;
        SubordinateAddress = new Playerxx[](totalCount);
        for(uint256 i = 0; i < totalCount ; i++){
            SubordinateAddress[i].Player = addressToPlayer[Player].subordinate[i];
            SubordinateAddress[i].nodeLevel = addressToPlayer[addressToPlayer[Player].subordinate[i]].nodeLevel;
            SubordinateAddress[i].Time = addressToPlayer[addressToPlayer[Player].subordinate[i]].Time;
        }
    }
    function getsuperior(address Player) public view returns(address  superior) {
        superior = addressToPlayer[Player].superior;
     
    }

    function getuserInfo(address Player) public view returns(address  superior,uint256 Time,uint256 nodeLevel,bool ISNode) {
        superior = addressToPlayer[Player].superior;
        Time = addressToPlayer[Player].Time;
        nodeLevel = addressToPlayer[Player].nodeLevel;
        ISNode = isNode[Player];
    }


      function _addLiquidity(uint256 USDTAmount) private  {
        address[] memory path = new address[](2);
        path[0] = address(USDT);                  
        path[1] = address(BTC3);
        uint256 HDAmount = _getHDOut(USDTAmount) * 2;
        BTC3.mint(address(this),HDAmount);
        (, uint256 b, ) = router.addLiquidity(
            address(USDT),
            address(BTC3),
            USDTAmount,
            ~uint256(0),
            0,
            0,
            address(this),
            block.timestamp
        );
        if (b < HDAmount) BTC3.destroy(HDAmount - b);
    }
    function _getHDOut(uint256 USDTAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(BTC3);
        uint256[] memory amounts = router.getAmountsOut(USDTAmount, path);
        return amounts[1];
    }

}