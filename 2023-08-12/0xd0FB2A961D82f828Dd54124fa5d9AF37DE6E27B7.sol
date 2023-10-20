// SPDX-License-Identifier: Unlicensed 
// Not open source - Custom contract created for Stratton Token
// by GEN https://TokensByGEN.com TG: https://t.me/GenTokens_GEN


/*


    Stratton [STN]
    Backed by Gold, Property, and Land

    Total Supply: 1 trillion (1,000,000,000,000)
    Decimals: 4
    Tax: 10% buy tax & 10% sell tax


    Come Join the Stratton community and be part of an exciting building from the ground-up project!
    It will be backed by gold, property, and land, our community token combines stability with growth potential.
    Experience the power of tangible assets in the crypto world and be part of something extraordinary.
    Don't miss out on this thrilling journey.

    
    Facebook: Stratton STN Official 
    Telegram: t.me/Stratton_Official
    Twitter: @Stratton_stn
    Website: stratton-finance.com


*/


pragma solidity 0.8.19;
 
interface IERC20 {

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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


contract Stratton is Context, IERC20 { 


    // Contract Wallets - All set to Owner wallet during deployment, Will be updated post launch! 
    address private _owner = 0xeE274Af61f00a6c7cE4de585bcA0454cb2c1eF8E;
    address public Wallet_Liquidity = 0xeE274Af61f00a6c7cE4de585bcA0454cb2c1eF8E;
    
    address payable public Wallet_Marketing = payable(0xeE274Af61f00a6c7cE4de585bcA0454cb2c1eF8E);
    address payable public Wallet_Gold = payable(0xeE274Af61f00a6c7cE4de585bcA0454cb2c1eF8E);
    address payable public Wallet_Property = payable(0xeE274Af61f00a6c7cE4de585bcA0454cb2c1eF8E);

    // Burn Wallet
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Token Info
    string private  constant _name = "Stratton"; 
    string private  constant _symbol = "STN"; 
    uint8 private constant _decimals = 4;
    uint256 private constant _tTotal = 1_000_000_000_000 * 10 ** _decimals;

    // Project Links
    string private _Website;
    string private _Telegram;
    string private _LP_Lock;

    // Limits
    uint256 private max_Hold = _tTotal;
    uint256 private max_Tran = _tTotal;

    // Fees
    uint8 public _Fee__Buy_Liquidity;
    uint8 public _Fee__Buy_Marketing;
    uint8 public _Fee__Buy_Gold;
    uint8 public _Fee__Buy_Property;

    uint8 public _Fee__Sell_Liquidity;
    uint8 public _Fee__Sell_Marketing;
    uint8 public _Fee__Sell_Gold;
    uint8 public _Fee__Sell_Property;

    // Total Fee for Swap
    uint8 private _SwapFeeTotal_Buy;
    uint8 private _SwapFeeTotal_Sell;

    // Factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;




    constructor () {

        // Set PancakeSwap Router Address
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        // Create Initial Pair With BNB
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // Set Initial LP Pair
        _isPair[uniswapV2Pair] = true;   

        // Wallets Excluded From Limits
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[DEAD] = true;
        _isLimitExempt[uniswapV2Pair] = true;
        _isLimitExempt[_owner] = true;

        // Wallets With Pre-Launch Access
        _isWhitelisted[_owner] = true;

        // Wallets Excluded From Fees
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[DEAD] = true;
        _isExcludedFromFee[_owner] = true;

        // Transfer Supply To Owner
        _tOwned[_owner] = _tTotal;

        // Emit token transfer to owner
        emit Transfer(address(0), _owner, _tTotal);

        // Emit Ownership Transfer
        emit OwnershipTransferred(address(0), _owner);

    }

    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_Buy_fees(uint8 Marketing, uint8 Liquidity, uint8 Gold, uint8 Property);
    event updated_Sell_fees(uint8 Marketing, uint8 Liquidity, uint8 Gold, uint8 Property);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    // Restrict Function to Current Owner
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    mapping (address => bool) public _isWhitelisted;                            // Pre-Launch Access


    // Public Token Info
    function Token_Information() external view returns(address Owner_Wallet,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       string memory Liquidity_Lock,
                                                       string memory Custom_Contract_By) {

                                                           
        string memory Creator = "https://tokensbygen.com";

        uint8 Total_buy =  _Fee__Buy_Liquidity    +
                           _Fee__Buy_Marketing    +
                           _Fee__Buy_Gold         +
                           _Fee__Buy_Property     ;

        uint8 Total_sell = _Fee__Sell_Liquidity   +
                           _Fee__Sell_Marketing   +
                           _Fee__Sell_Gold        +
                           _Fee__Sell_Property    ;


        uint256 _max_Hold = max_Hold / 10 ** _decimals;
        uint256 _max_Tran = max_Tran / 10 ** _decimals;

        if (_max_Tran > _max_Hold) {

            _max_Tran = _max_Hold;
        }


        // Return Token Data
        return (_owner,
                _max_Tran,
                _max_Hold,
                Total_buy,
                Total_sell,
                _Website,
                _Telegram,
                _LP_Lock,
                Creator);

    }

    // Fee Processing Triggers
    uint8 private swapTrigger = 11; 
    uint8 private swapCounter = 1;    
    
    // Fee Processing Bools                  
    bool public processingFees;
    bool public feeProcessingEnabled;
    bool public noFeeWhenProcessing;

    // Launch Settings
    bool private Trade_Open;
    bool private No_Fee_Transfers = true;

    // Fee Tracker
    bool private takeFee;



    function Add_Presale_CA(address Presale_CA) external onlyOwner {

        _isLimitExempt[Presale_CA] = true;
        _isExcludedFromFee[Presale_CA] = true;
        _isWhitelisted[Presale_CA] = true;

    }


    /*
    
    -----------------
    BUY AND SELL FEES
    -----------------

    */


    // Buy Fees
    function Fees_on_Buy(

        uint8 Marketing_on_BUY, 
        uint8 Liquidity_on_BUY, 
        uint8 Gold_on_BUY, 
        uint8 Property_on_BUY

        ) external onlyOwner {

        require (Marketing_on_BUY   + 
                 Liquidity_on_BUY   + 
                 Gold_on_BUY        +
                 Property_on_BUY    <= 10, "F1"); // Buy fees are limited to 10%

        // Update Fees
        _Fee__Buy_Marketing = Marketing_on_BUY;
        _Fee__Buy_Liquidity = Liquidity_on_BUY;
        _Fee__Buy_Gold      = Gold_on_BUY;
        _Fee__Buy_Property  = Property_on_BUY;

        // Fees For Processing
        _SwapFeeTotal_Buy = _Fee__Buy_Marketing + _Fee__Buy_Liquidity + _Fee__Buy_Gold + _Fee__Buy_Property;
        emit updated_Buy_fees(_Fee__Buy_Marketing, _Fee__Buy_Liquidity, _Fee__Buy_Gold, _Fee__Buy_Property);
    }

    // Sell Fees
    function Fees_on_Sell(

        uint8 Marketing_on_SELL,
        uint8 Liquidity_on_SELL, 
        uint8 Gold_on_SELL, 
        uint8 Property_on_SELL

        ) external onlyOwner {

        require (Marketing_on_SELL  + 
                 Liquidity_on_SELL  +
                 Gold_on_SELL       +
                 Property_on_SELL   <= 12, "F2"); // Sell fees are limited to 12%

        // Update Fees
        _Fee__Sell_Marketing = Marketing_on_SELL;
        _Fee__Sell_Liquidity = Liquidity_on_SELL;
        _Fee__Sell_Gold      = Gold_on_SELL;
        _Fee__Sell_Property  = Property_on_SELL;

        // Fees For Processing
        _SwapFeeTotal_Sell = _Fee__Sell_Marketing + _Fee__Sell_Liquidity + _Fee__Sell_Gold + _Fee__Sell_Property;
        emit updated_Sell_fees(_Fee__Sell_Marketing, _Fee__Sell_Liquidity, _Fee__Sell_Gold, _Fee__Sell_Property);
    }


    /*
    
    ------------------------------------------
    SET MAX TRANSACTION AND MAX HOLDING LIMITS
    ------------------------------------------

    To protect buyers, these values must be set to a minimum of 0.5% of the total supply
    Wallet limits are set as a number of tokens, not as a percent of supply!

    Total Supply is 1,000,000,000,000

    Common percent values in token amounts, to avoid errors, copy and paste these numbers... 

    0.5% = 5000000000 (Lowest possible amount you can enter as a limit)
    1.0% = 10000000000
    1.5% = 15000000000
    2.0% = 20000000000
    2.5% = 25000000000
    3.0% = 30000000000

    100% = 1000000000000


    */

    function Wallet_Limits(

        uint256 Max_Tokens_Each_Transaction,
        uint256 Max_Total_Tokens_Per_Wallet 

        ) external onlyOwner {

            require(Max_Tokens_Each_Transaction >= 5000000000, "L1"); // Max Transaction must be greater than 0.5% of supply
            require(Max_Total_Tokens_Per_Wallet >= 5000000000, "L2"); // Max Wallet must be greater than 0.5% of supply

            max_Tran = Max_Tokens_Each_Transaction;
            max_Hold = Max_Total_Tokens_Per_Wallet;

            emit updated_Wallet_Limits(max_Tran, max_Hold);

    }


    // Open Trade
    function Open_Trade() external onlyOwner {

        feeProcessingEnabled = true;
        Trade_Open = true;

    }










    /*
    
    ---------------------------------
    NO FEE WALLET TO WALLET TRANSFERS
    ---------------------------------

    Default = true

    Having no fee on wallet-to-wallet transfers means that people can move tokens between wallets, 
    or send them to friends etc without incurring a fee. 

    If false, the 'Buy' fee will apply to all wallet to wallet transfers.

    */

    function No_Fee_Wallet_Transfers(bool true_or_false) public onlyOwner {

        No_Fee_Transfers = true_or_false;

    }




    /*

    ----------------------
    UPDATE PROJECT WALLETS
    ----------------------

    */

    function Update_Wallet_Liquidity(

        address Liquidity_Collection_Wallet

        ) external onlyOwner {

        require(Liquidity_Collection_Wallet != address(0), "W1"); // Enter a valid BSC Address
        Wallet_Liquidity = Liquidity_Collection_Wallet;

    }

    function Update_Wallet_Marketing(

        address payable Marketing_Wallet

        ) external onlyOwner {

        require(Marketing_Wallet != address(0), "W2"); // Enter a valid BSC Address
        Wallet_Marketing = payable(Marketing_Wallet);

    }

    function Update_Wallet_Gold(

        address payable Gold_Wallet

        ) external onlyOwner {

        require(Gold_Wallet != address(0), "W3"); // Enter a valid BSC Address
        Wallet_Gold = payable(Gold_Wallet);

    }


    function Update_Wallet_Property(

        address payable Property_Wallet

        ) external onlyOwner {

        require(Property_Wallet != address(0), "W4"); // Enter a valid BSC Address
        Wallet_Property = payable(Property_Wallet);

    }



    /*

    --------------------
    UPDATE PROJECT LINKS
    --------------------

    */

    function Update_Links_Website(

        string memory Website_URL

        ) external onlyOwner{

        _Website = Website_URL;

    }


    function Update_Links_Telegram(

        string memory Telegram_URL

        ) external onlyOwner{

        _Telegram = Telegram_URL;

    }


    function Update_Links_Liquidity_Lock(

        string memory LP_Lock_URL

        ) external onlyOwner{

        _LP_Lock = LP_Lock_URL;

    }


    /* 

    ----------------------------
    CONTRACT OWNERSHIP FUNCTIONS
    ----------------------------

    */



    // Transfer to New Owner
    function Ownership_TRANSFER(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "O1"); // Enter a valid BSC Address

        emit OwnershipTransferred(_owner, newOwner);

        // Remove old owner status 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhitelisted[owner()]     = false;

        _owner = newOwner;

        // Add new owner status
        _isLimitExempt[owner()]     = true;
        _isExcludedFromFee[owner()] = true;
        _isWhitelisted[owner()]     = true;

    }

  
    // Renounce Ownership
    function Ownership_RENOUNCE() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        // Remove old owner status 
        _isLimitExempt[owner()]     = false;
        _isExcludedFromFee[owner()] = false;
        _isWhitelisted[owner()]     = false;

        _owner = address(0);
    }







    /*

    --------------
    FEE PROCESSING
    --------------

    */

    // Add Liquidity Pair
    function Process__Add_Liquidity_Pair(

        address Wallet_Address,
        bool true_or_false)

         external onlyOwner {
        _isPair[Wallet_Address] = true_or_false;
        _isLimitExempt[Wallet_Address] = true_or_false;
    } 


    // Auto Fee Processing Switch
    function Process__FeeProcessing(bool true_or_false) external onlyOwner {
        feeProcessingEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }

    // Manually Process Fees
    function Process__ProcessFeesNow(uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!processingFees, "P1"); // Already processing fees!
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        processFees(sendTokens);

    }

    // Remove Random Tokens
    function Process__RescueTokens(

        address random_Token_Address,
        uint256 number_of_Tokens

        ) external onlyOwner {

            // Can Not Remove Native Token
            require (random_Token_Address != address(this), "P2"); // Can not purge the native token - Must be processed as fees!
            IERC20(random_Token_Address).transfer(msg.sender, number_of_Tokens);
            
    }

    // Remove fee for the sell that triggers fee processing
    function Process__RemoveFeeWhenProcessing(bool true_or_false) external onlyOwner {
        noFeeWhenProcessing = true_or_false;
    }

    // Update Swap Count Trigger
    function Process__TriggerCount(uint8 Transaction_Count) external onlyOwner {

        // To Save Gas, Start At 1 Not 0
        swapTrigger = Transaction_Count + 1;
    }



    /*

    ---------------
    WALLET SETTINGS
    ---------------

    */


    // Exclude From Fees
    function Wallet__ExcludeFromFees(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;

    }

    // Exclude From Transaction and Holding Limits
    function Wallet__ExemptFromLimits(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
    }

    // Grant Pre-Launch Access (Whitelist)
    function Wallet__PreLaunchAccess(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {    
        _isWhitelisted[Wallet_Address] = true_or_false;
    }







    /*

    -----------------------------
    BEP20 STANDARD AND COMPLIANCE
    -----------------------------

    */

    function owner() public view returns (address) {
        return _owner;
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
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
        return (_tTotal - balanceOf(address(DEAD)));
    }






   


    /*

    ---------------
    TOKEN TRANSFERS
    ---------------

    */

    function _transfer(
        address from,
        address to,
        uint256 amount
      ) private {



        require(balanceOf(from) >= amount, "T1"); // Sender does not have enough tokens!

        if (!Trade_Open){
        require(_isWhitelisted[from] || _isWhitelisted[to], "T2"); // Trade is not open - Only whitelisted wallets can interact with tokens
        }

        // Wallet Limit
        if (!_isLimitExempt[to]) {

            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "T3"); // Purchase would take balance of max permitted
            
        }

        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt
        if (!_isLimitExempt[to] || !_isLimitExempt[from]) {

            require(amount <= max_Tran, "T4"); // Exceeds max permitted transaction amount
        
        }

        // Compliance and Safety Checks
        require(from != address(0), "T5"); // Enter a valid BSC Address
        require(to != address(0), "T6"); // Enter a valid BSC Address
        require(amount > 0, "T7"); // Amount of tokens can not be 0

         // Check Fee Status
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (No_Fee_Transfers && !_isPair[to] && !_isPair[from])){
            takeFee = false;
            } else {takeFee = true;}

        // Trigger Fee Processing
        if (_isPair[to] && !processingFees && feeProcessingEnabled) {

            // Check Transaction Count
            if(swapCounter >= swapTrigger && (_SwapFeeTotal_Buy + _SwapFeeTotal_Sell > 0)){

                // Check Contract Tokens
                uint256 contractTokens = balanceOf(address(this));

                if (contractTokens > 0) {

                    // Remove the fee for the person that triggers fee processing to mitigate price shift of contract sell
                    if(takeFee && noFeeWhenProcessing){takeFee = false;}

                    // Limit Swap to Max Transaction
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


    /*
    
    ------------
    PROCESS FEES
    ------------

    */

    function processFees(uint256 Tokens) private {

        // Lock Swap
        processingFees = true;  

        // Calculate Tokens for Swap
        uint256 _FeesTotal      = _SwapFeeTotal_Buy + _SwapFeeTotal_Sell;
        uint256 LP_Tokens       = Tokens * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;

        // Swap Tokens
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Avoid Rounding Errors on LP Fee if Odd Number
        uint256 fee_Split       = _FeesTotal * 2 - (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity);

        // Calculate BNB Values
        uint256 BNB_Liquidity   = returned_BNB * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / fee_Split;
        uint256 BNB_Gold        = returned_BNB * (_Fee__Buy_Gold + _Fee__Sell_Gold) * 2 / fee_Split; 
        uint256 BNB_Property    = returned_BNB * (_Fee__Buy_Property + _Fee__Sell_Property) * 2 / fee_Split; 

        // Add Liquidity 
        if (BNB_Liquidity > 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }

        // Deposit Gold BNB
        if(BNB_Gold > 0){

            send_BNB(Wallet_Gold, BNB_Gold);

        }

        // Deposit Property BNB
        if(BNB_Property > 0){

            send_BNB(Wallet_Property, BNB_Property);

        }
        
        // Deposit Marketing BNB
        contract_BNB = address(this).balance;

        if (contract_BNB > 0){

            send_BNB(Wallet_Marketing, contract_BNB);
        }


        // Reset Counter
        swapCounter = 1;

        // Unlock Swap
        processingFees = false;


    }

    // Swap Tokens
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



    // Add Liquidity
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



    /*
    
    ----------------------------------
    TRANSFER TOKENS AND CALCULATE FEES
    ----------------------------------

    */

    uint256 private tSwapFeeTotal;
    uint256 private tTransferAmount;

    

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool Fee) private {

        
        if (Fee){

            if(_isPair[recipient]){

                // Sell Fees
                tSwapFeeTotal = tAmount * _SwapFeeTotal_Sell / 100;

            } else {

                // Buy Fees
                tSwapFeeTotal = tAmount * _SwapFeeTotal_Buy / 100;

            }

        } else {

                // No Fees
                tSwapFeeTotal = 0;

        }

        tTransferAmount = tAmount - tSwapFeeTotal;

        // Remove Tokens from Sender
        _tOwned[sender] -= tAmount;

        // Send tokens to recipient
        _tOwned[recipient] += tTransferAmount;

        emit Transfer(sender, recipient, tTransferAmount);

        // Take Fees for BNB Processing
        if(tSwapFeeTotal > 0){

            _tOwned[address(this)] += tSwapFeeTotal;
            emit Transfer(sender, address(this), tSwapFeeTotal);

            // Increase Transaction Counter
            if (swapCounter < swapTrigger){
               unchecked{swapCounter++;}
            }
                
        }

    }

    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}

}

// Custom contract created for Stratton Token by GEN https://TokensByGEN.com TG: https://t.me/GenTokens_GEN
// Not open source - Can not be used or forked without permission.