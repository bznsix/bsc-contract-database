// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address _spender, uint _value) external returns (bool);

    function transferFrom(address _from, address _to, uint _value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
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

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

contract BBTCToken is IERC20, Ownable {
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private _rewardAddress = 0x15B373DC4EC35a9f05A420894Eda26BCC453b437;
    address private _lpsAddress = 0xd2279630D68629de6B4968e4835F4735700497D0;
    address private _teamAddress = 0xfc5bDb839C35AE589502c1F7B0eB8e12dce5719D;
    address private _tokenAddress = 0x09923e481eb645257289934c5E5C4f5EfCcb7897;
    address private _marketAddress = 0x81c688295bE96B87Be0e86d80567A43173D1006d;
    address private _burnAddress = address(0xdead);

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;

    mapping(address => bool) private _feeWhiteList;

    ISwapRouter private _swapRouter;
    address private currency = 0x55d398326f99059fF775485246999027B3197955;
    mapping(address => bool) private _swapPairList;
 
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    
    TokenDistributor public _lpsDistributor;

    uint256 private _buyRewardFee = 100;
    uint256 private _buyLpsFee = 0;
    uint256 private _buyTeamFee = 150;
    uint256 private _buyTokenFee = 150;
    uint256 private _buyMarketFee = 400;
    uint256 private _buyBurnFee   = 0;

    uint256 private _sellRewardFee = 0;
    uint256 private _sellLpsFee = 500;
    uint256 private _sellTeamFee = 0;
    uint256 private _sellTokenFee = 0;
    uint256 private _sellMarketFee = 1100;
    uint256 private _sellBurnFee   = 200;

    address private rewardToken = 0x55d398326f99059fF775485246999027B3197955;

    address private _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    address[] private rewardPath;

    uint256 public numTokensSellToFund  = 100 * 10**18;

    constructor() {
        _name = "BitBaseWorld";
        _symbol = "BBTC";
        _decimals = 18;
        _tTotal = 21000000 * 10**18;
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address ReceiveAddress = owner();
      
        rewardPath = [address(this), currency];
      
        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);
        _swapPairList[_mainPair] = true;

        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _lpsDistributor = new TokenDistributor(rewardToken);

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override  returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


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

    function _transfer(address from, address to, uint256 amount) private {
        require(balanceOf(from) >= amount, "balanceNotEnough");
        bool takeFee;
        bool isSell;
        if (_swapPairList[from] || _swapPairList[to]) {

            takeFee = true;

            if (_swapPairList[to]) {
                isSell = true;
                if(_feeWhiteList[from]){
                    takeFee = false;
                }
            }else{
                isSell = false;
                if(_feeWhiteList[to]){
                    takeFee = false;
                }
            }

            if (!inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                swapAccmul(contractTokenBalance);
            }

        }

        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell
        );

    }       


    function _tokenTransfer(address sender,address recipient,uint256 tAmount,bool takeFee,bool isSell) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {

                swapFee =  _sellRewardFee + _sellLpsFee + _sellTeamFee + _sellTokenFee + _sellMarketFee;
            
            } else {
                swapFee =  _buyRewardFee + _buyLpsFee + _buyTeamFee + _buyTokenFee + _buyMarketFee;
            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            uint256 burnAmount;
            if (!isSell) {
                
                burnAmount = (tAmount * _buyBurnFee) / 10000;
            } else {
                
                burnAmount = (tAmount * _sellBurnFee) / 10000;
            }
            if (burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(sender, _burnAddress, burnAmount);
            }
        }


        _takeTransfer(sender, recipient, tAmount - feeAmount);

    }

    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );

    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();

    event Failed_addLiquidityETH();

    event Failed_addLiquidity();

    
    function swapToken( uint256 amount,uint256 swapFee) private lockTheSwap {
        if (swapFee == 0) {
            return;
        }
        
        uint256 rewardFee = _sellRewardFee + _buyRewardFee;
        uint256 rewardAmount = (amount * rewardFee ) / swapFee;
        if (rewardAmount > 0) {
            try
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    rewardAmount,
                    0,
                    rewardPath,
                    address(_rewardAddress),
                    block.timestamp
                )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    0
                );
            }
        }

        
        uint256 teamFee = _sellTeamFee + _buyTeamFee;
        uint256 teamAmount = (amount * teamFee ) / swapFee;
        if (teamAmount > 0) {
            try
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    teamAmount,
                    0,
                    rewardPath,
                    address(_teamAddress),
                    block.timestamp
                )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    1
                );
            }
        }

        
        uint256 tokenFee = _sellTokenFee + _buyTokenFee;
        uint256 tokenAmount = (amount * tokenFee ) / swapFee;
        if (tokenAmount > 0) {
            try
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    rewardPath,
                    address(_tokenAddress),
                    block.timestamp
                )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    2
                );
            }
        }
     
        
        uint256 marketFee = _sellMarketFee + _buyMarketFee;
        uint256 marketAmount = (amount * marketFee ) / swapFee;
        if (marketAmount > 0) {
            try
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    marketAmount,
                    0,
                    rewardPath,
                    address(_marketAddress),
                    block.timestamp
                )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    3
                );
            }
        }

        
        uint256 lpFee = _sellLpsFee + _buyLpsFee;
        uint256 lpAmount = (amount * lpFee ) / swapFee / 2;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = currency;
        if(lpAmount > 0){
             try
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    lpAmount,
                    0,
                    path,
                    address(_lpsDistributor),
                    block.timestamp
                )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    4
                );
            }
        }
       
        

        IERC20 FIST = IERC20(currency);
        uint256 lpFist;
        lpFist = FIST.balanceOf(address(_lpsDistributor));

        if (lpFist > 0) {
            FIST.transferFrom(
                address(_lpsDistributor),
                address(this),
                lpFist
            );
        }

        if (lpAmount > 0 && lpFist > 0) {
            try
                _swapRouter.addLiquidity(
                    address(this),
                    currency,
                    lpAmount,
                    lpFist,
                    0,
                    0,
                    _lpsAddress,
                    block.timestamp
                )
            {} catch {
                emit Failed_addLiquidity();
            }
        }

        
    }

    function swapAccmul( uint256 contractTokenBalance) private{
        uint256 swapSellFee = _sellRewardFee + _sellLpsFee + _sellTeamFee + _sellTokenFee + _sellMarketFee;
        uint256 swapBuyFee = _buyRewardFee + _buyLpsFee + _buyTeamFee + _buyTokenFee + _buyMarketFee;
        uint256 swapFee = swapSellFee + swapBuyFee;
        if (contractTokenBalance >= numTokensSellToFund) {
            swapToken(numTokensSellToFund, swapFee); 
        }
    }

    
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFeeWhiteList(
        address addr,
        bool enable
    ) public onlyOwner {

        require(addr != address(0),"_addr cannot be the zero address");

        _feeWhiteList[addr] = enable;
        
    }

    function getFeeWhiteList( address addr) external view  onlyOwner returns (bool) {
        require(addr != address(0),"_addr cannot be the zero address");
        return _feeWhiteList[addr];
    }
    

    function setAddress(address rewardAddress,address lpsAddress,address teamAddress,address tokenAddress,address marketAddress) external onlyOwner {
        require(rewardAddress != address(0),"_addr cannot be the zero address");
        require(lpsAddress != address(0),"_addr cannot be the zero address");
        require(teamAddress != address(0),"_addr cannot be the zero address");
        require(tokenAddress != address(0),"_addr cannot be the zero address");
        require(marketAddress != address(0),"_addr cannot be the zero address");

        _rewardAddress = rewardAddress;
        _lpsAddress = lpsAddress;
        _teamAddress = teamAddress;
        _tokenAddress = tokenAddress;
        _marketAddress = marketAddress;
    }

    function getAddress() public view  onlyOwner  returns (address,address,address,address,address) {
        
        return (_lpsAddress,_teamAddress,_tokenAddress,_marketAddress,_mainPair);
    }

    
    function setFees(uint256[] calldata customs) external onlyOwner {
    
        _buyRewardFee = customs[0];
        _buyLpsFee = customs[1];
        _buyTeamFee = customs[2];
        _buyTokenFee = customs[3];
        _buyMarketFee = customs[4];
        _buyBurnFee   = customs[5];
        
        require(
            _buyRewardFee + _buyLpsFee + _buyTeamFee + _buyTokenFee + _buyMarketFee + _buyBurnFee< 2500,
            "buy!<25"
        );

        _sellRewardFee = customs[6];
        _sellLpsFee = customs[7];
        _sellTeamFee = customs[8];
        _sellTokenFee = customs[9];
        _sellMarketFee = customs[10];
        _sellBurnFee   = customs[11];

        require(
            _sellRewardFee + _sellLpsFee + _sellTeamFee + _sellTokenFee + _sellMarketFee + _sellBurnFee< 2500,
            "sell!<25"
        );

    }

    function getFeesBuy() public view  onlyOwner returns (uint256,uint256,uint256,uint256,uint256,uint256) {
     
        return (_buyRewardFee, _buyLpsFee, _buyTeamFee, _buyTokenFee, _buyMarketFee,_buyBurnFee);
    }

    function getFeesSell() public view  onlyOwner returns (uint256,uint256,uint256,uint256,uint256,uint256) {
   
        return (_sellRewardFee, _sellLpsFee, _sellTeamFee, _sellTokenFee, _sellMarketFee,_sellBurnFee);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        require(addr != address(0),"_addr cannot be the zero address");
        _swapPairList[addr] = enable;
    }

    function setNumTokensSellToFund(uint256 number) external onlyOwner {
        require(number > 0,"_numbermust egt zero");
        numTokensSellToFund = number * 10**18;
    }
    

}