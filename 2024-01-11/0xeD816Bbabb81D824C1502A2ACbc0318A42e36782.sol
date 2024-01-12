/*
// 📮 TELEGRAM: https://t.me/RichieRichVIP
// 🐤 TWITTER: https://twitter.com/RichieRichVIP
// 🌐 WEBSITE: https://RichieRich.VIP
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context 
{
    address private _owner;
    address private _previousOwner;

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



interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



contract RichieRich is Context, IERC20, Ownable
{
    using SafeMath for uint256;    
    address payable public marketingAddress = payable(0xeAC71934786DbC3595289c75032a6751a4Add6e8); 
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] public _addresses;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 2000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    
    string private _name = "Richie Rich";
    string private _symbol = "$RICHIE";
    uint8 private _decimals = 9;

    uint256 public _rewardFee = 3; 
    uint256 public _buybackFee = 3;
    uint256 public _marketingFee = 3;


    uint256 public _maxTxAmount = _tTotal.mul(10).div(100);
    uint256 private minimumTokensBeforeSwap = _tTotal.div(100000); 
    uint256 private buyBackUpperLimit = 1 * 10**16;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public buyBackEnabled = true;
    
    event RewardLiquidityProviders(uint256 tokenAmount);
    event BuyBackEnabledUpdated(bool enabled);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    
    event SwapETHForTokens(uint256 amountIn, address[] path);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    
    constructor () 
    {
        _rOwned[_msgSender()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[address(0)] = true;
        _isExcluded[deadAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function isContract(address _addr) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function isHolder(address addr) internal view returns(bool)
    {
        if(balanceOf(addr)>0) { return true; }
        uint256 len = _addresses.length;
        for(uint256 i=0; i<len; i++)
        {
            if(_addresses[i]==addr) { return true; }
        }
        return false;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    
    function buyBackUpperLimitAmount() public view returns (uint256) {
        return buyBackUpperLimit;
    }


    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }


    function excludeFromReward(address account) public onlyOwner() 
    {
        _isExcluded[account] = true;
    }


    function includeInReward(address account) public onlyOwner() 
    {
        _isExcluded[account] = false;
    }


    function _approve(address owner, address spender, uint256 amount) private 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    uint256 public rewardTotalAmount = 0;
    uint256 public buybackAmount = 0;
    uint256 private index = 0;
    uint256 private rewardSlice = 0; 

    function _transfer(address from, address to, uint256 amount) private
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!isHolder(to) && to != uniswapV2Pair)
        {
            _addresses.push(to);
        }

        if(from != owner() && to != owner()) 
        {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        
        if(from != uniswapV2Pair) 
        { 
            if(rewardTotalAmount>10*10**9) 
            { 
                checkAndSendReward(); 
            }
        }

        if (!inSwapAndLiquify && swapAndLiquifyEnabled && from != uniswapV2Pair && balanceOf(uniswapV2Pair)>0) 
        {

            if (overMinimumTokenBalance) 
            {
                contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            uint256 balance = buybackAmount;
            if (buyBackEnabled && balance > uint256(1 * 10**13)) 
            {
                if (balance > buyBackUpperLimit) { balance = buyBackUpperLimit;  }
                uint256 buyingAmount = balance.div(100);
                buyBackTokens(buyingAmount);
                buybackAmount -= buyingAmount;
            }
        }
        _tokenTransfer(from, to, amount);

    }


    function checkAndSendReward() public 
    {
        
        if(index==0 && _addresses.length>1)
        {
            rewardSlice = rewardTotalAmount;
        }
        
        address rewardee = _addresses[index];

        if(!_isExcluded[rewardee])
        {
            uint256 cSupply = circulatingSupply();
            uint256 holderBalance = balanceOf(rewardee);
            uint256 reward = rewardSlice.mul(holderBalance).div(cSupply);
            (bool success, ) = rewardee.call{value: reward}("");
            if(success) { rewardTotalAmount -= reward; }
        }
        index++;
        if(index>= _addresses.length)
        {
            index = 0;
        }        
    }


    function circulatingSupply() public view returns(uint256)
    {
        return totalSupply().sub(balanceOf(address(0))).sub(balanceOf(deadAddress)).sub(balanceOf(uniswapV2Pair));
    }


    function swapAndLiquify(uint256 contractTokenBalance) public lockTheSwap 
    {
        uint256 initialBalance = address(this).balance;
        uint256 swapableFee = _buybackFee+_marketingFee+_rewardFee;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);   
        uint256 marketingShare = transferredBalance.mul(_marketingFee).div(swapableFee);
        marketingAddress.transfer(marketingShare);
        uint256 rewardShare = transferredBalance.mul(_rewardFee).div(swapableFee);
        uint256 buybackShare = transferredBalance.mul(_buybackFee).div(swapableFee);
        rewardTotalAmount += rewardShare;
        buybackAmount += buybackShare;
    }
    

    function buyBackTokens(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
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
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, 
            path,
            deadAddress, 
            block.timestamp.add(300)
        );
        emit SwapETHForTokens(amount, path);
    }


    function _tokenTransfer(address sender, address recipient, uint256 amount) private 
    {
         bool takeFee = true;
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) { takeFee = false; }
        if (_isExcluded[sender] && !_isExcluded[recipient]) 
        {
            _transferFromExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount,  takeFee);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount,  takeFee);
        } else 
        {
            _transferStandard(sender, recipient, amount,  takeFee);
        }
    }



    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private 
    {
        (uint256 rAmount, uint256 rTransferAmount,  uint256 tTransferAmount,  uint256 tFees) = _getValues(tAmount, takeFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if(tFees>0)  
        { 
            _takeFees(tFees); 
            emit Transfer(sender, recipient, tFees);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private 
    {
        (uint256 rAmount, uint256 rTransferAmount,  uint256 tTransferAmount,  uint256 tFees) = _getValues(tAmount, takeFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        if(tFees>0)  
        { 
            _takeFees(tFees); 
            emit Transfer(sender, recipient, tFees);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private 
    {
        (uint256 rAmount, uint256 rTransferAmount,  uint256 tTransferAmount,  uint256 tFees) = _getValues(tAmount, takeFee);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        if(tFees>0)  
        { 
            _takeFees(tFees); 
            emit Transfer(sender, recipient, tFees);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, bool takeFee) private 
    {
        (uint256 rAmount, uint256 rTransferAmount,  uint256 tTransferAmount,  uint256 tFees) = _getValues(tAmount, takeFee);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        if(tFees>0)  
        { 
            _takeFees(tFees); 
            emit Transfer(sender, recipient, tFees);
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }



    function _getValues(uint256 tAmount, bool takeFee) private view returns (uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount,  uint256 tFees) = _getTValues(tAmount, takeFee);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tFees, _getRate());
        return (rAmount, rTransferAmount,  tTransferAmount, tFees);
    }
    

    function _getTValues(uint256 tAmount, bool takeFee) private view returns (uint256, uint256) 
    {
        uint256 tFees = calculateFees(tAmount);
        if(!takeFee)
        {
            tFees = 0;
        }
        uint256 tTransferAmount = tAmount.sub(tFees);
        return (tTransferAmount, tFees);
    }


    function _getRValues(uint256 tAmount, uint256 tFees, uint256 currentRate) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFees = tFees.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFees);
        return (rAmount, rTransferAmount);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    
    function _takeFees(uint256 tFees) private 
    {
        uint256 currentRate =  _getRate();
        uint256 rFees = tFees.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rFees);
        if(_isExcluded[address(this)]) {

        }
        _tOwned[address(this)] = _tOwned[address(this)].add(tFees);
    }
    
    
    function calculateFees(uint256 _amount) private view returns (uint256) 
    {
        uint256 totalSwapableFees = _marketingFee+_buybackFee+_rewardFee;
        return _amount.mul(totalSwapableFees).div(100);
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function releaseStuckTokens(uint256 amount) public onlyOwner 
    {
        require(balanceOf(address(this))>=amount, "Exceeding available balance");
        _tokenTransfer(address(this), owner(), amount);
    }    


    function releaseStuckBNB(uint256 amount) public onlyOwner 
    {
        require(address(this).balance>=amount, "Exceeding available balance");
        payable(owner()).transfer(amount);
    }   

    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
    
    
    function setNinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap) external onlyOwner() 
    {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setBuyFeePercentages(uint256 rewardFee, uint256 buybackFee, uint256 buyMarketingFee) external onlyOwner() 
    {
        _rewardFee = rewardFee; 
        _buybackFee = buybackFee;
        _marketingFee = buyMarketingFee;
    }     


     function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner() {
        buyBackUpperLimit = buyBackLimit;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner() {
        marketingAddress = payable(_marketingAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        buyBackEnabled = _enabled;
        emit BuyBackEnabledUpdated(_enabled);
    }
    

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    receive() external payable {}


}