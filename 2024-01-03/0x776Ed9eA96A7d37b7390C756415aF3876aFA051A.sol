// SPDX-License-Identifier: MIT
// Telegram: https://t.me/DeGrokBSC
// X (foremerly Twitter): https://twitter.com/DeGrokBSC

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal returns(bool){
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        return success;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IPancakeRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual onlyOwner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}

contract DeGrokToken is Context, Ownable, IERC20 {
    using SafeMath for uint256;
    IPancakeFactory private pancakefactory;
    IPancakeRouter private pancakerouter;
    using Address for address;
    using Address for address payable;


    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) public isExcludedFromFee;
    mapping(address => bool) public _isExcludedFromMaxWalletLimit;
    mapping(address => uint) public amountBurnt;
    mapping(address=>bool) public isBurnedBy;
    mapping(address=>uint) public feeAsBurnedBuy;
    mapping(address=>uint) public feeAsBurnedSell;

    uint totalBurnt;
    address routerAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint public  marketingFeeonBuy;
    uint public marketingFeeonSell;
    uint256 public swapTokensAtAmount;
    address public marketingWallet;
    
    bool    public maxWalletLimitEnabled;
    uint256 public maxWalletAmount;
    bool public swapEnabled;
    bool public finaltaxisSet;
    address public pancakeswapV2Pair;

    event changewallet(address,address);
    event SwapAndSendMarketing(uint256 tokensSwapped, uint256 ethReceived);
    event MaxWalletLimitStateChanged(bool state);
    event MaxWalletLimitAmountChanged(uint256 amount);
    
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_,address _marketing) payable{
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * (10 ** decimals_);
        _balances[_msgSender()] = _totalSupply;


        if (block.chainid == 56) {
            routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        }
        else if (block.chainid==97){
            routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //Mainnet
        } 
        else if (block.chainid == 1 || block.chainid == 4) {
            routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //Mainnet

        } else {   
            routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //Mainnet 
        }
        marketingFeeonBuy = 25;
        marketingFeeonSell = 30;
        _allowances[address(this)][address(routerAddress)] = type(uint256).max;
        swapEnabled = false;
        swapTokensAtAmount = _totalSupply / 5000;

        maxWalletLimitEnabled       = true;
        maxWalletAmount             = _totalSupply / 20;
        pancakerouter = IPancakeRouter(routerAddress);
        pancakefactory = IPancakeFactory(pancakerouter.factory());
        pancakeswapV2Pair = pancakefactory.createPair(address(this), pancakerouter.WETH());
        
        _isExcludedFromMaxWalletLimit[owner()] = true;
        _isExcludedFromMaxWalletLimit[address(this)] = true;
        _isExcludedFromMaxWalletLimit[address(0)] = true;
        _isExcludedFromMaxWalletLimit[address(0xdead)] = true;
        _isExcludedFromMaxWalletLimit[pancakeswapV2Pair] = true;
        _isExcludedFromMaxWalletLimit[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true; //pinklock
        _isExcludedFromMaxWalletLimit[_marketing] = true; //marketing
        isExcludedFromFee[_marketing] = true; //marketing
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[owner()] = true;
        
        marketingWallet = _marketing;
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public  view override returns (uint256) {
        return _balances[account];
    }


function setMaxWalletAmount(uint256 _maxWalletAmount) external onlyOwner {
        require(
            _maxWalletAmount >= totalSupply() / (10 ** decimals()) / 100, 
            "Max wallet percentage cannot be lower than 1%"
        );
        maxWalletAmount = _maxWalletAmount * (10 ** decimals());
        emit MaxWalletLimitAmountChanged(maxWalletAmount);
    }

function setEnableMaxWalletLimit(bool enable) external onlyOwner {
        require(
            enable != maxWalletLimitEnabled, 
            "Max wallet limit is already set to that state"
        );
        maxWalletLimitEnabled = enable;
        emit MaxWalletLimitStateChanged(maxWalletLimitEnabled);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool)  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 fees;
        uint256 contractTokenBalance = balanceOf(address(this));
        bool swapping;
        bool takefee=true;
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if(isExcludedFromFee[sender] || isExcludedFromFee[recipient])
        takefee=false;
        if(canSwap)
        if(!swapping)
        if(takefee)
        if(recipient==pancakeswapV2Pair)  
        {
            swapping = true;
            
            swapAndSendMarketing(contractTokenBalance);
            swapping = false;
        }
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        if(recipient==pancakeswapV2Pair)
            require(swapEnabled || !takefee,"Swap Not enabled");
        else if(sender==pancakeswapV2Pair)
            require(swapEnabled || !takefee,"Swap Not enabled");
        
                
            
        
        //SELL
        if(takefee){
        if(marketingFeeonSell!=0)
        if(recipient==pancakeswapV2Pair)
        {
                fees = amount.mul(isBurnedBy[msg.sender]?feeAsBurnedSell[msg.sender]:marketingFeeonSell).div(100);
        }
        // BUY
        if(marketingFeeonBuy!=0)
        if(sender==pancakeswapV2Pair)
        {
            fees = amount.mul(isBurnedBy[msg.sender]?feeAsBurnedBuy[msg.sender]:marketingFeeonBuy).div(100);
        }
        }
        amount = amount.sub(fees);
        _balances[recipient] = _balances[recipient].add(amount);
        _balances[address(this)] = _balances[address(this)].add(fees);
        if (maxWalletLimitEnabled) 
        {
            if (_isExcludedFromMaxWalletLimit[sender]  == false && 
                _isExcludedFromMaxWalletLimit[recipient]    == false &&
                recipient != pancakeswapV2Pair
            ) {
                uint balance  = balanceOf(recipient);
                require(
                    balance <= maxWalletAmount, 
                    "MaxWallet: Recipient exceeds the maxWalletAmount"
                );
            }
        }
        emit Transfer(sender, recipient, amount);

        return true;
    }

    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
    require(_balances[_msgSender()] >= amount, "Insufficient Balance");
    return _transfer(_msgSender(), recipient, amount);
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(),spender,amount);
        return true;
    }

    function excludeformFee(address _wallet,bool _val) external onlyOwner{
        isExcludedFromFee[_wallet] = _val;
        _isExcludedFromMaxWalletLimit[_wallet] = _val;
    }
     function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function changeMarketingwallet(address _newwallet) external onlyOwner{
        marketingWallet = _newwallet;
        emit changewallet(marketingWallet,_newwallet);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    


    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
    require(_allowances[sender][_msgSender()] >= amount, "No Allowances");
    return _transfer(sender, recipient, amount);
    
    }

    
    event FeeUpdated(uint256 newFee);

    function setFinalTax() external onlyOwner{
        require(!finaltaxisSet,"Already set");
        marketingFeeonBuy = 5;
        marketingFeeonSell = 5;
        finaltaxisSet = true;
        emit FeeUpdated(5);
    }



    function claimStruck() external onlyOwner{
        _transfer(address(this), address(marketingWallet), balanceOf(address(this)));
    }


   
    function swapAndSendMarketing(uint256 tokenAmount) private {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakerouter.WETH();
        try pancakerouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {} catch {}
        uint256 newBalance = address(this).balance - initialBalance;

        payable(marketingWallet).sendValue(newBalance);

        emit SwapAndSendMarketing(tokenAmount, newBalance);
    }
    event TradingEnabled(bool enabled);
    
    function enableTrading() external onlyOwner{
        require(!swapEnabled,"Already Enabled");
        swapEnabled = true;
        emit TradingEnabled(true);
    }
    
    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= balanceOf(msg.sender), "Amount must be less than balance");
        require(finaltaxisSet,"Final tax not set");
        _transfer(msg.sender, address(0xdead), amount);
        totalBurnt = totalBurnt.add(amount);
        amountBurnt[msg.sender] = amountBurnt[msg.sender].add(amount);
        if(amountBurnt[msg.sender]>= 20_000_000_000){ // If 2% of total supply is burnt the tax is 1% for both buy and sell
        feeAsBurnedBuy[msg.sender] = 1;
        feeAsBurnedSell[msg.sender] = 1;
        isBurnedBy[msg.sender] = true;
        }
        else if(amountBurnt[msg.sender]>= 15_000_000_000){ //If 1.5% of total supply is burnt the tax is 2% for both buy and sell
         feeAsBurnedBuy[msg.sender] = 2;
        feeAsBurnedSell[msg.sender] = 2;
        isBurnedBy[msg.sender] = true;
        }
        else if(amountBurnt[msg.sender]>= 10_000_000_000){ //If 1% of total supply is burnt the tax is 3% for both buy and sell
         feeAsBurnedBuy[msg.sender] = 3;
        feeAsBurnedSell[msg.sender] = 3;
        isBurnedBy[msg.sender] = true;
        }
        else if(amountBurnt[msg.sender]>=5_000_000_000){ //If 0.5% of total supply is burnt the tax is 4% for both buy and sell
         feeAsBurnedBuy[msg.sender] = 4;
        feeAsBurnedSell[msg.sender] = 4;
        isBurnedBy[msg.sender] = true;
        }
    }
receive() external payable {}
    
}