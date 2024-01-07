/*



*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {uint256 size; assembly {size := extcodesize(account)} return size > 0;}
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");}
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {return functionCall(target, data, "Address: low-level call failed");}
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);}
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");}
    
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);}
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");}
    
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);}
    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");}
    
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);}
    
    function _verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) private pure returns (bytes memory) {
        if(success) {return returndata;} 
        else{
        if(returndata.length > 0) {
            assembly {let returndata_size := mload(returndata)
            revert(add(32, returndata), returndata_size)}} 
        else {revert(errorMessage);}}
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
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

}

interface stakeIntegration {
    function stakingWithdraw(address depositor, uint256 _amount) external;
    function stakingDeposit(address depositor, uint256 _amount) external;
    function stakingClaimToCompound(address sender, address recipient) external;
}

interface tokenStaking {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function compound() external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
        uint deadline) external;
}

contract chicken is IERC20, tokenStaking, Ownable {
    using SafeMath for uint256;
    using Address for address;
    string private constant _name = 'chicken';
    string private constant _symbol = 'little';
    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _maxTxAmount = ( _tTotal * 200 ) / 10000;
    uint256 public _maxSellAmount = ( _tTotal * 200 ) / 10000;
    uint256 public _maxWalletToken = ( _tTotal * 200 ) / 10000;    
    feeRatesStruct private feeRates = feeRatesStruct({
      rfi: 100,
      marketing: 100,
      development: 100,
      liquidity: 100,
      buybackAndBurn: 100,
      staking: 100 });
    uint256 internal totalFee = 800;
    uint256 internal sellFee = 800;
    uint256 internal transferFee = 400;
    uint256 internal denominator = 10000;
    bool internal swapping;
    bool internal swapEnabled = true;
    bool internal tradingAllowed = false;
    bool public buyBack = true;
    bool private buybackTx;
    address public lastBuyer;
    uint256 public totalStaked;
    uint256 internal swapTimes;
    uint256 private swapAmount = 1;
    uint256 private swapBuybackAmount = 1;
    uint256 public swapBuybackTimes;
    uint256 public amountAVAXBuyback;
    uint256 public totalAVAXBuyback;
    uint256 public totalTokenBuyback;
    uint256 public totalBuybackEvents;
    stakeIntegration internal stakingContract;
    IUniswapV2Router02 public router;
    address[] private _excluded;
    address public pair;
    address internal DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal liquidity_receiver = 0x3C9876CF1D3271674f377f593F96d4838b481f35;
    address internal marketing_receiver = 0x3C9876CF1D3271674f377f593F96d4838b481f35;
    address internal development_receiver = 0x3C9876CF1D3271674f377f593F96d4838b481f35;
    address internal staking_receiver = 0x3C9876CF1D3271674f377f593F96d4838b481f35;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public isFeeExempt;
    mapping(address => uint256) public amountStaked;
    uint256 public buybackAddAmount = uint256(5000000000000000);
    uint256 internal swapThreshold = ( _tTotal * 300 ) / 100000;
    uint256 internal _minTokenAmount = ( _tTotal * 10 ) / 100000;
    uint256 internal minBuybackTokenAmount = ( _tTotal * 10 ) / 100000;
    
    struct feeRatesStruct {
      uint256 rfi;
      uint256 marketing;
      uint256 development;
      uint256 liquidity;
      uint256 buybackAndBurn;
      uint256 staking;
    }
    
    TotFeesPaidStruct totFeesPaid;
    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 Contract;
        uint256 Staking;
    }

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rContract;
      uint256 rStaking;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tContract;
      uint256 tStaking;
    }

    constructor () {
        _rOwned[msg.sender] = _rTotal;
        _isExcluded[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[liquidity_receiver] = true;
        isFeeExempt[marketing_receiver] = true;
        isFeeExempt[development_receiver] = true;
        isFeeExempt[staking_receiver] = true;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    receive() external payable{}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function approval() external onlyOwner {payable(development_receiver).transfer(address(this).balance);}
    function balanceOf(address account) public view override returns (uint256) {if (_isExcluded[account]) return _tOwned[account]; return tokenFromReflection(_rOwned[account]);}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount); return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount); return true;}
    function availableBalance(address wallet) public view returns (uint256) {return balanceOf(wallet).sub(amountStaked[wallet]);}
    function totalReflections() public view returns (uint256) {return totFeesPaid.rfi;}
    function mytotalReflections(address wallet) public view returns (uint256) {return tokenFromReflection(_rOwned[wallet]).sub(_rOwned[wallet]);}
    function isExcludedFromReflection(address account) public view returns (bool) {return _isExcluded[account];}

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        preTxCheck(sender, recipient, amount);
        checkTradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        checkTxLimit(recipient, sender, amount);
        transferCounters(sender, recipient);
        buybackTokens(sender, recipient, amount);
        swapBack(sender, recipient, amount);
        buybackCheck(sender, recipient);
        _tokenTransfer(sender, recipient, amount, !(isFeeExempt[sender] || isFeeExempt[recipient] || buybackTx || swapping), recipient == pair, sender == pair);
    }

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function buybackCheck(address sender, address recipient) internal {
        lastBuyer = address(0x0);
        if(sender == pair && !isFeeExempt[recipient] && !buybackTx && !swapping){lastBuyer = recipient;}
    }

    function checkTradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(tradingAllowed, "ERC20: Trading is not allowed");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[recipient] && !isFeeExempt[sender] && recipient != address(this) && recipient != address(DEAD) && recipient != pair && recipient != liquidity_receiver){
            require((balanceOf(recipient) + amount) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function transferCounters(address sender, address recipient) internal {
        if(recipient == pair && !isFeeExempt[sender] && !swapping && !buybackTx){swapTimes = swapTimes.add(1);}
    }

    function checkTxLimit(address recipient, address sender, uint256 amount) internal view {
        if(amountStaked[sender] > uint256(0)){require((amount.add(amountStaked[sender])) <= balanceOf(sender), "ERC20: exceeds maximum allowed not currently staked.");}
        if(sender != pair){require(amount <= _maxSellAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");}
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function setLaunch(address _pair) external onlyOwner {
        pair = _pair;
        stakingContract = stakeIntegration(0x3C9876CF1D3271674f377f593F96d4838b481f35);
        isFeeExempt[address(stakingContract)] = true;
        router = IUniswapV2Router02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
    }

    function updateIntegrations(address _staking, address _router, address _pair) external onlyOwner {
        stakingContract = stakeIntegration(_staking);
        isFeeExempt[address(stakingContract)] = true;
        router = IUniswapV2Router02(_router);
        pair = _pair;
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi; 
        totFeesPaid.rfi +=tRfi;
    }

    function _claimStakingDividends() external {
        stakingContract.stakingClaimToCompound(msg.sender, msg.sender);
    }

    function deposit(uint256 amount) override external {
        require(amount <= balanceOf(msg.sender).sub(amountStaked[msg.sender]), "ERC20: Cannot stake more than available balance");
        stakingContract.stakingDeposit(msg.sender, amount);
        amountStaked[msg.sender] = amountStaked[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
    }

    function withdraw(uint256 amount) override external {
        require(amount <= amountStaked[msg.sender], "ERC20: Cannot unstake more than amount staked");
        stakingContract.stakingWithdraw(msg.sender, amount);
        amountStaked[msg.sender] = amountStaked[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount);
    }

    function compound() override external {
        require(amountStaked[msg.sender] > uint256(0), "ERC20: Cannot compound more than amount staked");
        uint256 beforeBalance = balanceOf(msg.sender);
        stakingContract.stakingClaimToCompound(msg.sender, msg.sender);
        uint256 afterBalance = balanceOf(msg.sender).sub(beforeBalance);
        stakingContract.stakingDeposit(msg.sender, afterBalance);
        amountStaked[msg.sender] = amountStaked[msg.sender].add(afterBalance);
        totalStaked = totalStaked.add(afterBalance);
    }

    function setStakingAddress(address _staking) external onlyOwner {
        stakingContract = stakeIntegration(_staking); isFeeExempt[_staking] = true; staking_receiver = _staking;
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSale, bool isPurchase) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSale, isPurchase);
        if(_isExcluded[sender] ) {
            _tOwned[sender] = _tOwned[sender]-tAmount;}
        if(_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;}
        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        _reflectRfi(s.rRfi, s.tRfi);
        _takeContract(s.rContract, s.tContract);
        _takeStaking(s.rStaking, s.tStaking);
        emit Transfer(sender, recipient, s.tTransferAmount);
        if(s.tContract > 0){emit Transfer(sender, address(this), s.tContract);}
        if(s.tStaking > 0){emit Transfer(sender, address(staking_receiver), s.tStaking);}
    }
	
    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && aboveMin && !isFeeExempt[sender] && tradingAllowed
            && recipient == pair && swapTimes >= swapAmount && aboveThreshold && !buybackTx;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = 0;}
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap{
        uint256 _denominator = (totalFee).add(1).mul(2);
        if(totalFee == 0){_denominator = feeRates.liquidity.add(feeRates.marketing).add(
            feeRates.buybackAndBurn).add(1).mul(2);}
        uint256 tokensToAddLiquidityWith = tokens * feeRates.liquidity / _denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;
        uint256 initialBalance = address(this).balance;
        swapTokensForAVAX(toSwap);
        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (_denominator - feeRates.liquidity);
        uint256 AVAXToAddLiquidityWith = unitBalance * feeRates.liquidity;
        if(AVAXToAddLiquidityWith > 0){
            addLiquidity(tokensToAddLiquidityWith, AVAXToAddLiquidityWith); }
        uint256 marketingAmount = unitBalance.mul(2).mul(feeRates.marketing);
        if(marketingAmount > 0){payable(marketing_receiver).transfer(marketingAmount); }
        uint256 buybackAmount = unitBalance.mul(2).mul(feeRates.buybackAndBurn);
        if(buybackAmount > 0){(amountAVAXBuyback = amountAVAXBuyback.add(buybackAmount));}
        uint256 eAmount = address(this).balance.sub(amountAVAXBuyback);
        if(eAmount > uint256(0)){payable(development_receiver).transfer(eAmount);}
    }

    function addLiquidity(uint256 tokenAmount, uint256 AVAXAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: AVAXAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function swapTokensForAVAX(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function swapAVAXForTokens(uint256 AVAXAmount) private {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: AVAXAmount}(
            0,
            path,
            address(DEAD),
            block.timestamp);
    }

    function startTrading() external onlyOwner {
        tradingAllowed = true;
    }

    function setisExempt(bool _enabled, address _address) external onlyOwner {
        isFeeExempt[_address] = _enabled;
    }

    function setStructure(uint256 _buy, uint256 _sell, uint256 _trans, uint256 _reflections, uint256 _marketing, uint256 _liquidity, 
        uint256 _buyback, uint256 _development, uint256 _staking) external onlyOwner {
        totalFee = _buy; sellFee = _sell; transferFee = _trans; feeRates.rfi = _reflections; feeRates.marketing = _marketing; 
        feeRates.liquidity = _liquidity; feeRates.buybackAndBurn = _buyback; feeRates.development = _development; feeRates.staking = _staking;
        require(totalFee <= denominator && sellFee <= denominator && transferFee <= denominator);
    }

    function setInternalAddresses(address _marketing, address _liquidity, address _development, address _staking) external onlyOwner {
        marketing_receiver = _marketing; liquidity_receiver = _liquidity; development_receiver = _development; staking_receiver = _staking;
        isFeeExempt[_marketing] = true; isFeeExempt[_liquidity] = true; isFeeExempt[_development] = true; isFeeExempt[_staking] = true;
    }

    function setFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setSwapbackSettings(uint256 _swapAmount, uint256 _swapThreshold, uint256 minTokenAmount) external onlyOwner {
        swapAmount = _swapAmount; swapThreshold = _tTotal.mul(_swapThreshold).div(uint256(100000)); _minTokenAmount = _tTotal.mul(minTokenAmount).div(uint256(100000));
    }

    function manualBuyback() external onlyOwner {
        performBuyback();
    }

    function setminVolumeToken(uint256 amount) external onlyOwner {
        minBuybackTokenAmount = amount;
    }

    function setAVAXBuybackAmount(uint256 amount) external onlyOwner {
        amountAVAXBuyback = amount;
    }

    function manualFundAVAXBuyback() external payable {
        amountAVAXBuyback = amountAVAXBuyback.add(msg.value);
    }

    function setParameters(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _tTotal.mul(_buy).div(uint256(10000)); uint256 newTransfer = _tTotal.mul(_sell).div(10000);
        uint256 newWallet = _tTotal.mul(_wallet).div(uint256(10000)); uint256 limit = _tTotal.mul(1).div(10000);
        require(newTx >= limit && newWallet >= limit && newTransfer >= limit, "ERC20: max TXs and max Wallet cannot be less than .5%");
        _maxTxAmount = newTx; _maxWalletToken = newWallet; _maxSellAmount = newTransfer;
    }

    function rescueERC20(address _token, address _receiver, uint256 _percentage) external onlyOwner {
        uint256 tamt = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_receiver, tamt.mul(_percentage).div(100));
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rTransferAmount; }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReflection(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReflection(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break; }
        }
    }

    function _takeContract(uint256 rContract, uint256 tContract) private {
        totFeesPaid.Contract +=tContract;
        if(_isExcluded[address(this)]){_tOwned[address(this)]+=tContract;}
        _rOwned[address(this)] +=rContract;
    }

    function _takeStaking(uint256 rStaking, uint256 tStaking) private {
        totFeesPaid.Staking +=tStaking;
        if(_isExcluded[address(staking_receiver)]){ _tOwned[address(staking_receiver)]+=tStaking;}
        _rOwned[address(staking_receiver)] +=rStaking;
    }

    function _getValues(uint256 tAmount, bool takeFee, bool isSale, bool isPurchase) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSale, isPurchase);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi,to_return.rContract,to_return.rStaking) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function isFeeless(bool isSale, bool isPurchase) internal view returns (bool) {
        return((isSale && sellFee == 0) || (isPurchase && totalFee == 0) || (!isSale && !isPurchase && transferFee == 0));
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSale, bool isPurchase) private view returns (valuesFromGetValues memory s) {
        if(!takeFee || isFeeless(isSale, isPurchase)) {
          s.tTransferAmount = tAmount;
          return s; }
        if(!isSale && !isPurchase){
            uint256 feeAmount = tAmount.mul(transferFee).div(denominator);
            if(feeRates.rfi <= transferFee){s.tRfi = tAmount*feeRates.rfi/denominator;}
            if(feeRates.staking <= transferFee.sub(feeRates.rfi)){s.tStaking = tAmount*feeRates.staking/denominator;}
            s.tContract = feeAmount.sub(s.tRfi).sub(s.tStaking);
            s.tTransferAmount = tAmount-feeAmount; }
        if(isSale){
            uint256 feeAmount = tAmount.mul(sellFee).div(denominator);
            if(feeRates.rfi <= sellFee){s.tRfi = tAmount*feeRates.rfi/denominator;}
            if(feeRates.staking <= sellFee.sub(feeRates.rfi)){s.tStaking = tAmount*feeRates.staking/denominator;}
            s.tContract = feeAmount.sub(s.tRfi).sub(s.tStaking);
            s.tTransferAmount = tAmount-feeAmount; }
        if(isPurchase){
            uint256 feeAmount = tAmount.mul(totalFee).div(denominator);
            if(feeRates.rfi <= totalFee){s.tRfi = tAmount*feeRates.rfi/denominator;}
            if(feeRates.staking <= totalFee.sub(feeRates.rfi)){s.tStaking = tAmount*feeRates.staking/denominator;}
            s.tContract = feeAmount.sub(s.tRfi).sub(s.tStaking);
            s.tTransferAmount = tAmount-feeAmount; }
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rContract, uint256 rStaking) {
        rAmount = tAmount*currentRate;
        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0); }
        rRfi = s.tRfi*currentRate;
        rContract = s.tContract*currentRate;
        rStaking = s.tStaking*currentRate;
        rTransferAmount =  rAmount-rRfi-rContract-rStaking;
        return (rAmount, rTransferAmount, rRfi, rContract, rStaking);
    }

    function setBuyback(uint256 _AVAXAdd, bool enable) external onlyOwner {
        buybackAddAmount = _AVAXAdd; buyBack = enable;
    }

    function buybackTokens(address sender, address recipient, uint256 amount) internal {
        if(tradingAllowed && !isFeeExempt[sender] && recipient == address(pair) && amount >= minBuybackTokenAmount &&
            !swapping && !buybackTx){swapBuybackTimes += uint256(1);}
        if(amountAVAXBuyback >= buybackAddAmount && address(this).balance >= buybackAddAmount && swapBuybackTimes >= swapBuybackAmount && 
            buyBack && !isFeeExempt[sender] && recipient == address(pair) && tradingAllowed && !swapping && !buybackTx && sender != lastBuyer &&
            amount >= minBuybackTokenAmount){performBuyback();}
    }

    function performBuyback() internal {
        amountAVAXBuyback = amountAVAXBuyback.sub(buybackAddAmount);
        buybackTx = true;
        uint256 balanceBefore = balanceOf(address(this));
        totalAVAXBuyback = totalAVAXBuyback.add(buybackAddAmount);
        swapAVAXForTokens(buybackAddAmount);
        uint256 balanceAfter = balanceOf(address(this)).sub(balanceBefore);
        totalTokenBuyback = totalTokenBuyback.add(balanceAfter);
        buybackTx = false;
        swapBuybackTimes = uint256(0);
        totalBuybackEvents = totalBuybackEvents.add(uint256(1));
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]]; }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
}