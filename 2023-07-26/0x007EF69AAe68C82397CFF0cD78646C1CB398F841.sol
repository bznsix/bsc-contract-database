// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
 
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
     
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function approve(address spender, uint256 amount) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
                
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

    contract LiquidityManager is Context, IERC20, Ownable {
    using Address for address payable;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _lastTrnx;
  
    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);

    address public Coin = 0x55d398326f99059fF775485246999027B3197955;
    address public Token;

    uint256 public InitalTokenNumberPerCoin = 100_000_000;
    uint256 public InitalTokenPoolSize = 100_000;
    
    uint256 public ThresoldValue = 50;
    uint256 public adjFlag = 0;
    
    uint256 public InitalTokenPoolValue = InitalTokenPoolSize  * 10 ** 18;
    uint256 public InitialCoinPoolValue =  InitalTokenPoolValue / InitalTokenNumberPerCoin;
    
    uint256 public AllowedPriceVariation = InitalTokenNumberPerCoin * ThresoldValue /10000;    
    uint256 public genesis_block = block.number;
    uint256 private deadline;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    string private constant _name = "Liqudity Manager";
    string private constant _symbol = "MNST";
    uint256 lpFees;
   
    struct TotFeesPaidStruct {
        uint256 liquidity;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rLiquidity;
        uint256 tTransferAmount;
        uint256 tLiquidity;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);
    
    constructor(address routerAddress,address _pair) {
        IRouter _router = IRouter(routerAddress);
        router = _router;
        pair = _pair;
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public view returns (address ) {
        return Token;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    

    function balanceOf(address account) public view override returns (uint256) {
        return IERC20(Token).balanceOf(account);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return IERC20(Token).allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
       IERC20(Token).approve(spender,amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public override returns (bool) {
        IERC20(Token).transfer( recipient, amount);
        return true;
    }

    function transferFrom(address token ,address recipient, uint256 amount) public  returns (bool) {
        IERC20(token).transfer( recipient, amount);
        return true;
    }
    
    function getExchangeRateRate() public view returns(uint256) {
        return IERC20(Token).balanceOf(pair)/IERC20(Coin).balanceOf(pair);
    }

    function getTokenBalance() public view returns(uint256){
        require(Token != address(0), "ERC20: Balance not possible from the zero address");
        uint256 rate = IERC20(Token).balanceOf(pair);
        return rate;
    }

    function getCoinBalance() public view returns(uint256){
        require(Coin != address(0), "ERC20: Balance not possible from the zero address");
        uint256 rate = IERC20(Coin).balanceOf(pair);
        return rate;
    }

    function detectPoolVarition() public view returns (bool,uint256,uint256,uint256){
        if(Coin == address(0) || Token == address(0)) return (false,0,0,0);
        uint256 CurrentTokenBalance = IERC20(Token).balanceOf(pair);
        uint256 CurrentCoinBalance = IERC20(Coin).balanceOf(pair);
        if(CurrentTokenBalance==0 || CurrentCoinBalance==0) return (false,0,0,0);
        uint256 CurrentTokenNumberPerCoin = CurrentTokenBalance*10**5/CurrentCoinBalance;
        uint256 CurrentPriceVariation = abs(CurrentTokenNumberPerCoin , InitalTokenNumberPerCoin*10**5);
        if(CurrentPriceVariation > AllowedPriceVariation*10**5){
            if(CurrentTokenNumberPerCoin > InitalTokenNumberPerCoin*10**5){
                uint256 Token_Out =(CurrentPriceVariation * CurrentCoinBalance/2)/10**5;
                uint256 Coin_in = ((1*10**18)/(InitalTokenNumberPerCoin*10**5) - (1*10**18)/CurrentTokenNumberPerCoin)*CurrentTokenBalance/2/(1*10**13);
                return (true,Token_Out,Coin_in,1);
            }
            if(CurrentTokenNumberPerCoin < InitalTokenNumberPerCoin*10**5){
                uint256 Token_in =(CurrentPriceVariation * CurrentCoinBalance/2)/10**5;
                uint256 Coin_Out = ((1*10**18)/CurrentTokenNumberPerCoin - (1*10**18)/(InitalTokenNumberPerCoin*10**5))*CurrentTokenBalance/2/(1*10**13);
                return (true,Token_in,Coin_Out,2);
            }
            else{
                return (false,0,0,3);
            }
        }
        else{
                return (false,0,0,4);
        }
    }
    
    function AdjustLiquidity() external {
        uint256 _Token;
        uint256 coin;
        uint256 dir;
        bool Status;
        (Status,_Token,coin,dir)=detectPoolVarition();
        if(Status){
            if(dir==1){
                swapEthForToken(coin,_Token);
            }
            if(dir==2){
               swapTokensForBNB(coin,_Token);
            }
        }
    } 

    function swapTokensForBNB(uint256 coinAmount,uint256 tokenAmount) private {
        // generate the pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = Token;
        path[1] = Coin;

        approve(address(router), tokenAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            coinAmount*(100-50)/100,
            path,
            address(this),
            block.timestamp + 3600
        );
    }

    function swapEthForToken(uint256 coinAmount,uint256 tokenAmount) private  {
        // generate the pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = Coin;
        path[1] = Token;
        
        IERC20(Coin).approve(address(router), coinAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            coinAmount,
            tokenAmount*(100-50)/100,
            path,
            address(this),
            block.timestamp + 3600
        );
    }

    function abs(uint256  x, uint256 y) private pure returns (uint256) {
        if(x>=y)
        {
           return (x-y);
        }
        else
        {
           return(y-x);
        }
    }

    function setLiquidityFeePercent(uint256 _newlpFee) external onlyOwner {
        lpFees = _newlpFee;
    }

    function setThresoldValue(uint256 _newThresoldValue) external onlyOwner {
        ThresoldValue = _newThresoldValue;
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner {
        require(newRouter != address(0),"New router address can not be zero");
        router = IRouter(newRouter);
        require(newPair != address(0),"New pair address can not be zero");
        pair = newPair;

    }

    function updateCoinAndToken(address _Coin,address _Token) external onlyOwner {
        require(_Token != address(0),"New Token address can not be zero");
        require(_Coin != address(0),"New Token address can not be zero");
        Token = _Token;
         Coin = _Coin;
    }


    function updatePoolSize(uint256 NewInitalTokenNumberPerCoin, uint256 NewInitalTokenPoolSize) external onlyOwner {
        require(NewInitalTokenNumberPerCoin != 0 && NewInitalTokenPoolSize != 0,"New Values can not be zero");
        InitalTokenNumberPerCoin =NewInitalTokenNumberPerCoin;
        InitalTokenPoolSize =NewInitalTokenPoolSize;
    }
    
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    function rescueAnyBEP20Tokens(address _tokenAddr,address _to,uint256 _amount) public onlyOwner {
        require(_tokenAddr != address(0), "tokenAddress cannot be the zero address");
        require(_to != address(0), "receiver cannot be the zero address");
        require(_amount > 0, "amount should be greater than zero");
        IERC20 token = IERC20(_tokenAddr);
        bool success = IERC20(token).transfer(_to, _amount);
        require(success, "Token transfer failed");
    }

    receive() external payable {}
}