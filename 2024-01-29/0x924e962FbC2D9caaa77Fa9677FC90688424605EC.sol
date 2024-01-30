// SPDX-License-Identifier: MIT
pragma solidity = 0.8.19;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {  owner = _owner; }
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    function ownerAddress() public view virtual returns (address) { return owner; }

    event OwnershipTransferred(address owner);
}

interface IFactory{
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter  {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(  uint amountIn,  uint amountOutMin,  address[] calldata path,  address to,  uint deadline ) external;
    function addLiquidityETH(address token, uint amountTokenDesired,   uint amountTokenMin, uint amountETHMin,  address to,  uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TouTiaoToken is IERC20 , Ownable {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private isFeeExempt;
    mapping (address => bool) private IsPair;
    mapping (address => uint256) private balance;

    string constant private _name = "TEST 1.0";
    string constant private _symbol = "TEST 1.0";
    uint8 constant private _decimals = 9;
    uint256 constant private _totalSupply = 21000000 * (10 ** _decimals);
   
    uint256 constant private swapThreshold = 10 * (10 ** _decimals);
    uint256 constant private marketfee = 2;
    uint256 constant private lpfee = 1;
    uint256 constant private burnfee = 1;
    uint256 constant private fee_denominator = 100;

    bool    private tradingAllowed = false; 
    bool    private inSwap;
    IRouter private swapRouter;

    modifier inSwapFlag { inSwap = true; _; inSwap = false;}

    address public Pair;
    address payable private marketingAddress = payable(0x06c52f38f9F952911279178E9551Bc803F3e0322); 
    address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    receive() external payable {}
    constructor() Ownable(msg.sender) {
        swapRouter = IRouter(routerAddress);
        Pair = IFactory(swapRouter.factory()).createPair(swapRouter.WETH(), address(this));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[marketingAddress] = true;


        IsPair[Pair] = true;

        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        _approve(msg.sender, address(swapRouter), type(uint256).max);
        _approve(address(this), address(swapRouter), type(uint256).max);
    }


    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return ownerAddress(); }
    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {return balance[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) { _transfer(msg.sender, recipient, amount); return true; }
    function approve(address spender, uint256 amount) external override returns (bool) {  _approve(msg.sender, spender, amount);return true; }
    function IsBuy(address ins, address out) internal view returns (bool) { return !IsPair[out] && IsPair[ins];}
    function IsSell(address ins, address out) internal view returns (bool) {  return IsPair[out] && !IsPair[ins]; }
   

   
    function SetWalletFree(address account, bool val) public onlyOwner { isFeeExempt[account] = val;}
    function SetWallet(address _newMarketwallet) external onlyOwner { marketingAddress = payable(_newMarketwallet);}
    function luanch() external onlyOwner {tradingAllowed = true;}
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address from, address to, uint256 amount) private returns  (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;

        if(!isFeeExempt[from] && !isFeeExempt[to]){ require(tradingAllowed, "tradingAllowed");}

        if(IsSell(from, to) &&  !inSwap ) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= swapThreshold) { 
               swapAndLiquify(contractTokenBalance);
             }
        }

        if (isFeeExempt[from] || isFeeExempt[to]){takeFee = false;}

        balance[from]  =   balance[from].sub(amount);
        uint256 amountAfterFee = (takeFee) ? takeTaxes(from, amount) : amount;
        balance[to] = balance[to].add(amountAfterFee);
        emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function takeTaxes(address from, uint256 _amount) private returns (uint256) {
        uint256 burnAmount =  _amount * burnfee / fee_denominator;
        if(burnAmount > 0 ) {
            balance[DEAD] =  balance[DEAD].add(burnAmount);
            emit Transfer(from, DEAD, burnAmount);
        }

        uint256 marketAndLP = marketfee.add(lpfee);
        uint256 feeAmount = _amount * marketAndLP / fee_denominator;

        if (feeAmount > 0) {
             balance[address(this)] =  balance[address(this)].add(feeAmount);
            emit Transfer(from, address(this), feeAmount);
        }
        return _amount.sub(feeAmount).sub(burnAmount);
    }

    function swapAndLiquify(uint256 tokens) private inSwapFlag {
        uint256 totalfee = lpfee + marketfee;

        //加池子的数量
        uint256 addlpAmount = (tokens.mul(lpfee).div(totalfee)) / 2;

        //兑换bnb
        swapTokensForBNB(tokens.sub(addlpAmount));

        //当前合约的bnb数量
        uint256 initialBalance = address(this).balance;

        //添加流动性需要的bnb
        uint256 ETHToAddLiquidityWith = (initialBalance.mul(lpfee).div(totalfee)) / 2;
        uint256 marketBNB = initialBalance.sub(ETHToAddLiquidityWith);
        if(ETHToAddLiquidityWith > 0){
            addLiquidity(addlpAmount, ETHToAddLiquidityWith);
        }
        
        if(marketBNB > 0){
            payable(marketingAddress).transfer(marketBNB);
        }
       
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(swapRouter), tokenAmount);
       try swapRouter.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            marketingAddress,
            block.timestamp) {}catch {return;}
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        _approve(address(this), address(swapRouter), tokenAmount);

      try  swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp){} catch{return;}
    }



    // function swapTokenForBNB(uint256 contractTokenBalance) internal inSwapFlag {
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = swapRouter.WETH();

    //     if (_allowances[address(this)][address(swapRouter)] != type(uint256).max) {
    //         _allowances[address(this)][address(swapRouter)] = type(uint256).max;
    //     }

    //     try swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         contractTokenBalance,
    //         0,
    //         path,
    //         address(this),
    //         block.timestamp
    //     ) {} catch {
    //         return;
    //     }

    //     bool success;

    //     if(address(this).balance > 0) (success,) = marketingAddress.call{value: address(this).balance, gas: 35000}("");
    // }

    // function swapAndLiquify(uint256 contractTokenBalance) internal inSwapFlag {
    //     uint256 firstmath = contractTokenBalance / 2;
    //     uint256 secondMath = contractTokenBalance - firstmath;

    //     uint256 initialBalance = address(this).balance;

    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = swapRouter.WETH();

    //     if (_allowances[address(this)][address(swapRouter)] != type(uint256).max) {
    //         _allowances[address(this)][address(swapRouter)] = type(uint256).max;
    //     }

    //     try swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         firstmath,
    //         0, 
    //         path,
    //         address(this),
    //         block.timestamp) {} catch {return;}
        
    //     uint256 newBalance = address(this).balance - initialBalance;

    //     try swapRouter.addLiquidityETH{value: newBalance}(
    //         address(this),
    //         secondMath,
    //         0,
    //         0,
    //         DEAD,
    //         block.timestamp
    //     ){} catch {return;}

    // }


}