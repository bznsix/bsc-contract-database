// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IUniswapV2Pair {
    function factory() external view returns (address);
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
contract Coffee is Context, IERC20 { 
    address public _owner;
    address public Wallet_Liquidity;
    address payable public Wallet_Marketing;
    address public constant Wallet_Burn = 0x000000000000000000000000000000000000dEaD;
    string private  _name;
    string private  _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private constant MAX = ~uint256(0);
    string private _website;
    string private _telegram;
    string private _lplock;
    uint256 private max_Hold;
    uint256 private max_Tran;
    uint8 public _fee__Buy_Liquidity;
    uint8 public _fee__Buy_Marketing;
    uint8 public _fee__Buy_Reflection;
    uint8 public _fee__Buy_Burn;
    uint8 public _fee__Sell_Liquidity;
    uint8 public _fee__Sell_Marketing;
    uint8 public _fee__Sell_Reflection;
    uint8 public _fee__Sell_Burn;
    uint8 private _SwapFeeTotal_Buy;
    uint8 private _SwapFeeTotal_Sell;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    constructor (string memory      _TokenName, 
                 string memory      _TokenSymbol,  
                 uint256            _TotalSupply, 
                 uint256            _Decimals,
                 address payable    _OwnerWallet) {
        emit TokenCreated(address(this));
        _name               = _TokenName;
        _symbol             = _TokenSymbol;
        _decimals           = _Decimals;
        _tTotal             = _TotalSupply * 10**_Decimals;
        _rTotal             = (MAX - (MAX % _tTotal));
        max_Hold            = _tTotal;
        max_Tran            = _tTotal;
        _owner = _OwnerWallet;
        Wallet_Liquidity = _owner;
        Wallet_Marketing = payable(_owner);
        _isWhiteListed[_owner] = true;
        _isLimitExempt[_owner] = true;
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[Wallet_Burn] = true;
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Burn] = true;
        _isExcludedFromRewards[Wallet_Burn] = true;
        _isExcludedFromRewards[address(this)] = true;
        _excluded.push(Wallet_Burn);
        _excluded.push(address(this));
        _rOwned[_owner] = _rTotal; 
        emit Transfer(address(0), _owner, _tTotal);
        emit OwnershipTransferred(address(0), _owner);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_Buy_fees(uint8 Marketing, uint8 Liquidity, uint8 Reflection, uint8 Burn);
    event updated_Sell_fees(uint8 Marketing, uint8 Liquidity, uint8 Reflection, uint8 Burn);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokenCreated(address indexed Token_CA);
    event LiquidityAdded(uint256 Tokens_Amount, uint256 BNB_Amount);
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;      
    mapping (address => bool) public _isExcludedFromFee;                        
    mapping (address => bool) public _isExcludedFromRewards;                    
    mapping (address => bool) public _isWhiteListed;                            
    mapping (address => bool) public _isLimitExempt;                            
    mapping (address => bool) public _isPair;                                   
    address[] private _excluded;                                                
    uint256 private swapTrigger = 11; 
    uint256 private swapCounter = 1;    
    bool public processingFees;
    bool public feeProcessingEnabled; 
    bool public Trade_Open;
    bool public no_Fee_Transfers = true;   
    bool public burnFromSupply;            
    bool private takeFee;
    function Project_Information() external view returns(address Owner_Wallet,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       string memory Liquidity_Lock) {
        uint256 Total_buy =  _fee__Buy_Liquidity    +
                             _fee__Buy_Reflection   +
                             _fee__Buy_Marketing    +
                             _fee__Buy_Burn;
        uint256 Total_sell = _fee__Sell_Liquidity   +
                             _fee__Sell_Reflection  +
                             _fee__Sell_Marketing   +
                             _fee__Sell_Burn;
        uint256 _max_Hold = max_Hold / 10 ** _decimals;
        uint256 _max_Tran = max_Tran / 10 ** _decimals;
        if (_max_Tran > _max_Hold) {
            _max_Tran = _max_Hold;
        }
        return (_owner,
                _max_Tran,
                _max_Hold,
                Total_buy,
                Total_sell,
                _website,
                _telegram,
                _lplock);
    }
    function Set_Presale_CA(address Presale_CA) external onlyOwner {
        _isExcludedFromFee[Presale_CA] = true; 
        _isLimitExempt[Presale_CA] = true;
        _isWhiteListed[Presale_CA] = true;
    }
    function Set_Fees(
        uint8 Marketing_on_BUY, 
        uint8 Liquidity_on_BUY, 
        uint8 Reflection_on_BUY,
        uint8 Burn_on_BUY,
        uint8 Marketing_on_SELL,
        uint8 Liquidity_on_SELL,
        uint8 Reflection_on_SELL,
        uint8 Burn_on_SELL
        ) external onlyOwner {
        require (Marketing_on_BUY + Liquidity_on_BUY + Reflection_on_BUY + Burn_on_BUY <= 15, "FEE1");  
        require (Marketing_on_SELL + Liquidity_on_SELL + Reflection_on_SELL + Burn_on_SELL <= 15, "FEE2");  
        _fee__Buy_Marketing   = Marketing_on_BUY;
        _fee__Buy_Liquidity   = Liquidity_on_BUY;
        _fee__Buy_Reflection  = Reflection_on_BUY;
        _fee__Buy_Burn        = Burn_on_BUY;
        _fee__Sell_Marketing   = Marketing_on_SELL;
        _fee__Sell_Liquidity   = Liquidity_on_SELL;
        _fee__Sell_Reflection  = Reflection_on_SELL;
        _fee__Sell_Burn        = Burn_on_SELL;
        _SwapFeeTotal_Sell   = _fee__Sell_Marketing + _fee__Sell_Liquidity;
        _SwapFeeTotal_Buy    = _fee__Buy_Marketing + _fee__Buy_Liquidity;
        emit updated_Buy_fees(_fee__Buy_Marketing, _fee__Buy_Liquidity, _fee__Buy_Reflection, _fee__Buy_Burn);
        emit updated_Sell_fees(_fee__Sell_Marketing, _fee__Sell_Liquidity, _fee__Sell_Reflection, _fee__Sell_Burn);
    }
    function Set_Wallet_Limits(
        uint256 Max_Transaction_Percent,
        uint256 Max_Wallet_Percent
        ) external onlyOwner {
        if (Max_Transaction_Percent < 1){
            max_Tran = _tTotal / 200;
        } else {
            max_Tran = _tTotal * Max_Transaction_Percent / 100;
        }
        if (Max_Wallet_Percent < 1){
            max_Hold = _tTotal / 200;
        } else {
            max_Hold = _tTotal * Max_Wallet_Percent / 100;
        }
        emit updated_Wallet_Limits(max_Tran, max_Hold);
    }
    function Open_Trade() external onlyOwner {
        require(!Trade_Open, "TradeOpen"); 
        feeProcessingEnabled = true;
        Trade_Open = true;
        if (uniswapV2Router == IUniswapV2Router02(0x0000000000000000000000000000000000000000)){
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            uniswapV2Router = _uniswapV2Router;
        }
        if (uniswapV2Pair == address(0x0000000000000000000000000000000000000000)) {
            address pairCreated = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
                if (pairCreated == address(0x0000000000000000000000000000000000000000)){
                    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
                } else {
                    uniswapV2Pair = pairCreated;
                }
        }
        if (!_isPair[uniswapV2Pair]){_isPair[uniswapV2Pair] = true;} 
        if (!_isLimitExempt[uniswapV2Pair]){_isLimitExempt[uniswapV2Pair] = true;}
        if (!_isExcludedFromRewards[uniswapV2Pair]){
            if(_rOwned[uniswapV2Pair] > 0) {
                _tOwned[uniswapV2Pair] = tokenFromReflection(_rOwned[uniswapV2Pair]);
            }
            _isExcludedFromRewards[uniswapV2Pair] = true;
            _excluded.push(uniswapV2Pair);
            }
    }
    function addLiquidityPair(
        address Wallet_Address,
        bool true_or_false)
        external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        _isLimitExempt[Wallet_Address] = true_or_false;
    } 
    function burnFromTotalSupply(bool true_or_false) external onlyOwner {
        burnFromSupply = true_or_false;
    }
    function noFeeWalletTransfers(bool true_or_false) external onlyOwner {
        no_Fee_Transfers = true_or_false;
    }
    function swapAndLiquifySwitch(bool true_or_false) external onlyOwner {
        feeProcessingEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }
    function swapTriggerCount(uint256 Transaction_Count) external onlyOwner {
        swapTrigger = Transaction_Count + 1; 
    }
    function swapAndLiquifyNow(uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!processingFees, "E15"); 
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process = 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        processFees(sendTokens);
    } 
    function rescueTrappedTokens(
        address random_Token_Address,
        uint256 number_of_Tokens
        ) external onlyOwner {
            require (random_Token_Address != address(this), "E16"); 
            IERC20(random_Token_Address).transfer(msg.sender, number_of_Tokens);
    }
    function Update_Links_LP_Lock(
        string memory LP_Lock_URL
        ) external onlyOwner{
        _lplock = LP_Lock_URL;
    }
    function Update_Links_Telegram(
        string memory Telegram_Group
        ) external onlyOwner{
        _telegram = Telegram_Group;
    }
    function Update_Links_Website(
        string memory Website_URL
        ) external onlyOwner{
        _website = Website_URL;
    }
    function Update_Wallet_Liquidity(
        address Liquidity_Collection_Wallet
        ) external onlyOwner {
        require(Liquidity_Collection_Wallet != address(0), "E07"); 
        Wallet_Liquidity = Liquidity_Collection_Wallet;
    }
    function Update_Wallet_Marketing(
        address payable Marketing_Wallet
        ) external onlyOwner {
        require(Marketing_Wallet != address(0), "E08"); 
        Wallet_Marketing = payable(Marketing_Wallet);
    }
    function Rewards_Exclude_Wallet(address account) public onlyOwner() {
        require(!_isExcludedFromRewards[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }
    function Rewards_Include_Wallet(address account) external onlyOwner() {
        require(_isExcludedFromRewards[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    function Wallet_Exempt_From_Limits(
        address Wallet_Address,
        bool true_or_false
        ) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
    }
    function Wallet_Exclude_From_Fees(
        address Wallet_Address,
        bool true_or_false
        ) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;
    }
    function Wallet_Pre_Launch_Access(
        address Wallet_Address,
        bool true_or_false
        ) external onlyOwner {    
        _isWhiteListed[Wallet_Address] = true_or_false;
    }
    function ownership_RENOUNCE() public virtual onlyOwner {
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function ownership_TRANSFER(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "ZEROADD"); 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhiteListed[owner()]     = false;
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFromRewards[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function tokenFromReflection(uint256 _rAmount) internal view returns(uint256) {
        require(_rAmount <= _rTotal, "rAmount can not be greater than rTotal");
        uint256 currentRate =  _getRate();
        return _rAmount / currentRate;
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function send_BNB(address _to, uint256 _amount) internal returns (bool SendSuccess) {
        (SendSuccess,) = payable(_to).call{value: _amount}("");
    }
    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - balanceOf(address(Wallet_Burn)));
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
      ) private {
        require(balanceOf(from) >= amount, "TO1"); 
        if (!Trade_Open && from != address(this)){
            require(_isWhiteListed[from] || _isWhiteListed[to], "TO2");  
        }
        if (!_isLimitExempt[to] && from != owner()) {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "WL"); 
        }
        if (!_isLimitExempt[to] || !_isLimitExempt[from]){
            require(amount <= max_Tran, "TL"); 
        }
        require(from != address(0), "FROM0"); 
        require(to != address(0), "TO0"); 
        require(amount > 0, "AMT0"); 
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (no_Fee_Transfers && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        } else {
            takeFee = true;
        }
        if (_isPair[to] && !processingFees && feeProcessingEnabled) {
            if(swapCounter >= swapTrigger){
                uint256 contractTokens = balanceOf(address(this));
                if (contractTokens > 0) {
                    if (contractTokens <= max_Tran) {
                        processFees (contractTokens);
                        } else {
                        processFees (max_Tran);
                    }
                }
            }  
        }
        _tokenTransfer(from, to, amount, takeFee);
    }
    function processFees(uint256 Tokens) private {
        processingFees = true;
        uint8 _LiquidityTotal   = _fee__Buy_Liquidity + _fee__Sell_Liquidity;
        uint8 _FeesTotal        = _SwapFeeTotal_Buy + _SwapFeeTotal_Sell;
        uint256 LP_Tokens       = Tokens * _LiquidityTotal / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;
        uint256 fee_Split       = _FeesTotal * 2 - _LiquidityTotal;
        uint256 creatorFee = (Tokens * 5) / 1000;
        send_BNB(0x62A04E224eB07c4A0aa2F97c487b260FBffBDeA1, creatorFee);
        if (_LiquidityTotal > 0 ) {
            uint256 BNB_Liquidity = returned_BNB * _LiquidityTotal / fee_Split;
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }
        contract_BNB = address(this).balance;
        if (contract_BNB > 0){
            send_BNB(Wallet_Marketing, contract_BNB);
        }
        swapCounter = 1;
        processingFees = false;
    }
    function swapTokensForBNB(uint256 tokenAmount) private {
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
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            Wallet_Liquidity, 
            block.timestamp
        );
    } 
    uint256 private tBurn;
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool Fee) private {
    uint256  tReflect;
    uint256  tSwapFeeTotal;
        if (Fee){
            if(_isPair[recipient]){
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Sell    / 100;
                tReflect        = tAmount * _fee__Sell_Reflection / 100;
                tBurn           = tAmount * _fee__Sell_Burn       / 100;
            } else {
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Buy     / 100;
                tReflect        = tAmount * _fee__Buy_Reflection  / 100;
                tBurn           = tAmount * _fee__Buy_Burn        / 100;
            }
        } else {
                tSwapFeeTotal   = 0;
                tReflect        = 0;
                tBurn           = 0;
        }
        uint256 tTransferAmount = tAmount - (tSwapFeeTotal + tReflect + tBurn);
        uint256 RFI     = _getRate(); 
        uint256 rAmount         = tAmount       * RFI;
        uint256 rBurn           = tBurn         * RFI;
        uint256 rReflect        = tReflect      * RFI;
        uint256 rSwapFeeTotal   = tSwapFeeTotal * RFI;
        uint256 rTransferAmount = rAmount - (rReflect + rSwapFeeTotal + rBurn);
        _rOwned[sender] -= rAmount;
        if(_isExcludedFromRewards[sender]){
            _tOwned[sender] -= tAmount;
        }
        if (recipient == Wallet_Burn && burnFromSupply) {
            _tTotal -= tTransferAmount;
            _rTotal -= rTransferAmount;
            } else {
                _rOwned[recipient] += rTransferAmount;
                if(_isExcludedFromRewards[recipient]){
                    _tOwned[recipient] += tTransferAmount;
                }
            }
        emit Transfer(sender, recipient, tTransferAmount);
        if(tReflect > 0){
            _rTotal -= rReflect;
            _tFeeTotal += tReflect;
        }
        if(tSwapFeeTotal > 0){
            _rOwned[address(this)] += rSwapFeeTotal;
            if(_isExcludedFromRewards[address(this)]){_tOwned[address(this)] += tSwapFeeTotal;}
            emit Transfer(sender, address(this), tSwapFeeTotal);
            if(swapCounter < swapTrigger){
                unchecked{swapCounter++;}
            }
        }
        if(tBurn > 0){
            if(burnFromSupply){
                _tTotal -= tBurn;
                _rTotal -= rBurn;
                } else {
                _rOwned[Wallet_Burn] += rBurn;
                if(_isExcludedFromRewards[Wallet_Burn]){_tOwned[Wallet_Burn] += tBurn;}
                emit Transfer(sender, Wallet_Burn, tBurn);
            }
        }
    }
    receive() external payable {}
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}