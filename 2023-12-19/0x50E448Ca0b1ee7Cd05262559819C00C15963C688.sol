// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface ISwapPair {
    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function mint(address to) external returns (uint256 liquidity);

    function getReserves()
        external
        view
        returns (
            uint256 reserve0,
            uint256 reserve1,
            uint32 blockTimestampLast
        );

    function totalSupply() external view returns (uint256);
}

interface IPair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

abstract contract Ownable {
    address internal _owner;

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
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);

    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => address) public inviter;
    mapping(address => mapping(address => bool)) public inviterSend;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    uint256 private constant MAX = ~uint256(0);

    address public _mainPair;

    address public _WDD;

    uint256 day1Sec = 86400;

    struct LoanRecord {
        address userAddr; //user Addr
        uint256 startTime;
        uint256 endTime;
        uint256 subSec;
        uint256 amount;
        uint256 claimed;
        uint256 preTotal;
        bool status;
        uint256 lastClaimTime;
        uint256 releaseTime;
    }

    mapping(address => LoanRecord) public loanInfo;

    //relese period time
    uint256 public period1=24000000;
    uint256 public period2=21600000;
    uint256 public period3=19636363;

    mapping(address=>uint256) public childCount;

    constructor(
        address RouterAddress,
        address USDTAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address FundAddress,
        address ReceiveAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        uint256 inviteAmount = 1 * 10**(_decimals - 2);

        if (
            !isContract(from) &&
            !inviterSend[to][from] &&
            amount == inviteAmount
        ) {
            inviterSend[to][from] = true;
        }

        if (amount == inviteAmount) {
            if (
                !isContract(from) &&
                !isContract(to) &&
                inviterSend[from][to] &&
                inviter[from] == address(0)
            ) {
                if(childCount[from]==0){
                    inviter[from] = to;
                    childCount[to] +=1;
                }
                
            }
        }

        _tokenTransfer(from, to, amount);
       
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        if (!isContract(sender)&&!_feeWhiteList[sender] && recipient == address(this)) {

            if (tAmount == 1 * 10**(_decimals - 3)) {
                uint256 profit;
                uint256 curTime = block.timestamp;

                if (curTime >= loanInfo[sender].endTime) {
                    if(loanInfo[sender].preTotal<=loanInfo[sender].claimed){
                        profit=0;
                    }else{
                        profit = loanInfo[sender].preTotal-loanInfo[sender].claimed;
                    }
                   
                    //end
                    loanInfo[sender].status = false;
                } else {
                    profit = getProfit(curTime, loanInfo[sender]);
                }

                loanInfo[sender].claimed += profit;
                loanInfo[sender].lastClaimTime = curTime;

                //cvt wdd
                uint256 price = getUSDTPrice(1 ether, _usdt, _WDD);

                uint256 staticProfit = profit*price/1 ether;

                IERC20(_WDD).transfer(sender, staticProfit);


            } else {
                require(tAmount >= 100 * 10**_decimals, "value not enough ");

                require(!loanInfo[sender].status, "exist order");

                uint256 startTime = block.timestamp;
                uint256 period;
                if(tAmount >= 100 * 10**_decimals&&tAmount <= 999 * 10**_decimals)
                {
                    period=period1;

                }else if(tAmount >= 1000 * 10**_decimals&&tAmount <= 4999 * 10**_decimals){
                     period=period2;
                }else{
                     period=period3;
                }

                loanInfo[sender] = LoanRecord({
                    userAddr: sender,
                    startTime: startTime,
                    endTime: startTime+period,
                    subSec: period,
                    amount: tAmount,
                    claimed: 0,
                    preTotal: tAmount*25/10,
                    status: true,
                    lastClaimTime: startTime,
                    releaseTime: startTime
                });
            }
        }

        _takeTransfer(sender, recipient, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function getProfit(uint256 curTime, LoanRecord memory info)
        internal
        pure
        returns (uint256 profit)
    {
        uint256 num = curTime - info.lastClaimTime;
        uint256 perSecProfit = info.preTotal/info.subSec;
        profit = num*perSecProfit;
    }

    function setWDDAddress(address addr) external onlyOwner {
        _WDD = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setPeriod(uint256 p1,uint256 p2,uint256 p3) external onlyOwner {
        period1=p1;
        period2=p2;
        period3=p3;
    }


    mapping(address => uint256) public activeCount;

    mapping(address => uint256) public totalAdd;

    mapping(address => bool) public enableAddress;

    uint256 public min_active_value = 1 *10**18;

    uint256[10] public envRates = [90, 72, 54, 36, 18, 90, 72, 54, 36, 18];

    function setMinActiveValue(uint256 newValue) public onlyOwner {
        min_active_value = newValue;
    }

  //获取价值token可兑换USDT
    function getUSDTPrice(uint256 _amount, address tokenIn, address tokenOut) public view returns (uint256 amountOut){
        address[] memory path=new address[](2);
        path[0]=tokenIn;
        path[1]=tokenOut;
        uint256[] memory amounts = _swapRouter.getAmountsOut(_amount, path);
        return amounts[amounts.length-1];
    }

    receive() external payable {
  
        if(_feeWhiteList[msg.sender]){
            return;
        }

        address account = msg.sender;
        uint256 value = msg.value;
        require(tx.origin == msg.sender && !isContract(msg.sender), "bot");

        totalAdd[account] =totalAdd[account] +value;

        uint256 price = getUSDTPrice(value, WBNB, _usdt);
    

         _balances[address(this)] = _balances[address(this)] - price;
         _balances[account] = _balances[account] + price;
         emit Transfer(address(this), account, price);

        

        if (!enableAddress[account] && totalAdd[account] >= min_active_value) {
            enableAddress[account] = true;

            if (inviter[account] != address(0)) {
                activeCount[inviter[account]] += 1;
            }
        }

        address parent = inviter[account];

        if(value>=min_active_value){
            for (uint256 i = 0; i < envRates.length; i++) {
                    if (
                            parent != address(0) &&
                            activeCount[parent] > i &&
                            enableAddress[parent]
                    ) {
                            payable(parent).transfer((value * envRates[i]) / 1000);
                    } else {
                            payable(fundAddress).transfer((value * envRates[i]) / 1000);
                    }
                        parent = inviter[parent];
                }
        }
    
    }

  

    function withdrawUSDT(address _addr, uint256 _amount) external onlyOwner {
        require(_addr != address(0), "Can not withdraw to Blackhole");
        IERC20(_usdt).transfer(_addr, _amount);
    }

    function withdrawUDD(address _addr, uint256 _amount) external onlyOwner {
        require(_addr != address(0), "Can not withdraw to Blackhole");
        IERC20(this).transfer(_addr, _amount);
    }

   function withdrawWDD(address _addr, uint256 _amount) external onlyOwner {
        require(_addr != address(0), "Can not withdraw to Blackhole");
        IERC20(_WDD).transfer(_addr, _amount);
    }
    
    function withdrawBNB(address payable _addr, uint256 _amount)
        external
        onlyOwner
    {
        require(_addr != address(0), "Can not withdraw to Blackhole");
        _addr.transfer(_amount);
    }
}

contract UDD is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E), //router
            address(0x55d398326f99059fF775485246999027B3197955), //u
            "UDD",
            "UDD",
            18,
            4200000000,
            address(0x34F5703D3a9C1Eb5BDb5dD6Bf545B847C06e4128), //fund
            address(msg.sender) // receive
        )
    {}
}