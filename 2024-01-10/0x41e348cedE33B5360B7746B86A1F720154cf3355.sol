// SPDX-License-Identifier: No
pragma solidity = 0.8.19;

//--- Context ---//

abstract contract Context {
constructor() {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691 
        return msg.data;
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


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}



//--- Factory ---//
interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);

}


//--- Pair ---//

interface IV2Pair {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;

}



//--- Router ---//

interface IRouter01 {
        function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
        function factory() external pure returns (address);
        function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
        function WETH() external pure returns (address);
        function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
        function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
        function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    
}

interface IRouter02 is IRouter01 {
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
        function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
}








interface IERC20 {
        event Transfer(address indexed from, address indexed to, uint256 value);
        function name() external view returns (string memory);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        function allowance(address _owner, address spender) external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function approve(address spender, uint256 amount) external returns (bool);
        function symbol() external view returns (string memory);
        function totalSupply() external view returns (uint256);
        function decimals() external view returns (uint8);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    
}




interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}






contract PANDE is  Ownable, IERC20 {

    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function decimals() external pure override returns (uint8) { if (_Tsup == 0) { revert(); } return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function totalSupply() external pure override returns (uint256) { if (_Tsup == 0) { revert(); } return _Tsup; }


    mapping (address => bool) private _noFee;
    mapping (address => bool) private isLpPair;
    mapping (address => bool) private liquidityAdd;
    mapping (address => bool) private _pad;
    mapping (address => uint256) private balance;
    mapping (address => mapping (address => uint256)) private _allowances;


    string constant private _symbol = "PANDE";
    address public lppairaddress;
    uint8 constant private _decimals = 8;
    uint256 private liquidityAllocation = 0;
    address payable private _market_address = payable(0x25D2064f614A1Cc3487C12e1b6D1965c12bB8b2c);
    uint128 public swapTokensAtAmount_b_;
    string constant private _name = "Pandemonium Token";
    uint16 public _maxTxAmount_b_;
    uint256 constant public _Tsup = 5850000000000000000000000;
    uint256 constant public bfee = 30;
    uint256 constant public _SellFee = 30;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private _sAlc = 50;
    uint256 constant public _swapth = _Tsup / 1_000;
    uint256 constant public tferfee = 0;
    uint256 private _buy_allocation = 50;
    uint8 private ten_num = 10;
    bool public fet_bool = false;
    uint8 public _public_Count_b_;
    IRouter02 public Iswaprouter;
    string constant public copyright = "None";
    uint8 public _maxWalletSize_b_;
    address payable private _devWal = payable(0xdCe4A59E9491FADe0D61cA4519e0979C259fAAd5);
    bool public _is_trading_enabled = false;
    uint256 constant public _FeeDenomin = 1_000;
    uint8 public swapWithLimit_b_;
    uint256 private constant _buyCountThreshold = 47;
    bool private _enable_swap_fees = true;
    uint256 private _buyCount = 0;

    bool private inSwap;

        modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _enableTrading();
    event SwapAndLiquify();

    constructor () {
        Iswaprouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        balance[msg.sender] = _Tsup;

        emit Transfer(address(0), msg.sender, _Tsup);

        lppairaddress = IFactoryV2(Iswaprouter.factory()).createPair(Iswaprouter.WETH(), address(this));
        isLpPair[lppairaddress] = true;

        _approve(msg.sender, address(Iswaprouter), 2**256 - 1);
        _approve(address(this), address(Iswaprouter), type(uint256).max);
    }

    receive() external payable {}

    function _islimitedadd(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !liquidityAdd[ins]  && !liquidityAdd[out] && out != address(0) && out != address(this);
            return isLimited;
    }



    function setPresaleAddress(address[] memory presaleAddresses, bool yesno) external onlyOwner {
        for (uint i = 0; i < presaleAddresses.length; i++) {
            address presale = presaleAddresses[i];
            if (_pad[presale] != yesno) {
                _pad[presale] = yesno;
                _noFee[presale] = yesno;
                liquidityAdd[presale] = yesno;
            }
        }
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }


    function _takeTax(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = bfee;  else if (issell)  fee = _SellFee;  else  fee = tferfee; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / _FeeDenomin;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal inSwapFlag {
        uint256 firstmath = contractTokenBalance / 2;
        uint256 secondMath = contractTokenBalance - firstmath;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Iswaprouter.WETH();

        if (_allowances[address(this)][address(Iswaprouter)] != type(uint256).max) {
            _allowances[address(this)][address(Iswaprouter)] = type(uint256).max;
        }

        try Iswaprouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            firstmath,
            0, 
            path,
            address(this),
            block.timestamp) {} catch {return;}
        
        uint256 newBalance = address(this).balance - initialBalance;

        try Iswaprouter.addLiquidityETH{value: newBalance}(
            address(this),
            secondMath,
            0,
            0,
            DEAD,
            block.timestamp
        ){} catch {return;}

        emit SwapAndLiquify();
    }

    function is_buy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isLpPair[out] && isLpPair[ins];
        return _is_buy;
    }


        function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool take_fee = true;
                require(to != address(0), "ERC20: transfer to the zero address");
                require(from != address(0), "ERC20: transfer from the zero address");
                require(amount > 0, "Transfer amount must be greater than zero");
        
        if (_islimitedadd(from,to)) {
            require(_is_trading_enabled);
        }

        if (is_buy(from, to)) {
            _buyCount++;
            if (_buyCount >= _buyCountThreshold && !_is_trading_enabled) {
                _is_trading_enabled = true;
                emit _enableTrading();
            }
        }

        if(is_sell(from, to) &&  !inSwap && canSwap(from, to)) {
            uint256 contract_balance = balanceOf(address(this));
            if(contract_balance >= _swapth) { 
                if(_buy_allocation > 0 || _sAlc > 0) internalSwap((contract_balance * (_buy_allocation + _sAlc)) / 100);
                if(liquidityAllocation > 0) {swapAndLiquify(contract_balance * liquidityAllocation / 100);}
             }
        }

        if (_noFee[from] || _noFee[to]){
            take_fee = false;
        }
        balance[from] -= amount; uint256 amountAfterFee = (take_fee) ? _takeTax(from, is_buy(from, to), is_sell(from, to), amount) : amount;
        balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;

    }


        function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }



    function canSwap(address ins, address out) internal view returns (bool) {
        bool canswap = _enable_swap_fees && !_pad[ins] && !_pad[out];
        return canswap;
    }

    function is_sell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(
            _msgSender(),
            spender,
            currentAllowance - subtractedValue
        );
        return true;
    }

        function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }



    function internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Iswaprouter.WETH();

        if (_allowances[address(this)][address(Iswaprouter)] != type(uint256).max) {
            _allowances[address(this)][address(Iswaprouter)] = type(uint256).max;
        }

        try Iswaprouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }
        bool success;

        uint256 mktAmount = address(this).balance * 40 / 40; // *** //
        uint256 devAmount = address(this).balance * 0 / 40; // *** //

        if(mktAmount > 0) (success,) = _market_address.call{value: mktAmount, gas: 35000}("");
        if(devAmount > 0) (success,) = _devWal.call{value: devAmount, gas: 35000}("");
    }



}