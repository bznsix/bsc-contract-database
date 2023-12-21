// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.8.10;

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.8.10;

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addTreasuryETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint treasury);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interfaces/IRouter.sol";
import "./Interfaces/IFactory.sol";

contract SaitaRealty is IERC20, Ownable {

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBot;
    mapping(address => bool) private _isPair;

    mapping(address => bool) public canAirdrop;

    address[] private _excluded;
    
    bool private swapping;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 12e10 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    
    uint256 public swapTokensAtAmount = 1_000 * 10 ** 18;                                 
    uint256 public maxTxAmount = 100 * 10**9 * 10**9;
    
    // Anti Dump //
    mapping (address => uint256) public _lastTrade;
    bool public coolDownEnabled = false;
    uint256 public coolDownTime = 30 seconds;

    address public developmentAddress = 0x2084f438b1EFf6Bd5FbdE57215eaB741CAC7aDb7;             
    address public marketingAddress = 0x2084f438b1EFf6Bd5FbdE57215eaB741CAC7aDb7;         
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    address public BUSD = 0x55d398326f99059fF775485246999027B3197955;                       

    string private constant _name = "SaitaRealty";
    string private constant _symbol = "SRLTY";


    struct Taxes {
      uint256 reflection;
      uint256 development;
      uint256 marketing;
      uint256 burn;
      uint256 treasury;
    }

    Taxes public buyTax = Taxes(0,0,50,0,0);
    Taxes public sellTax = Taxes(0,0,50,0,0);
    Taxes public walletToWalletTax = Taxes(0,0,50,0,0);


    struct TotFeesPaidStruct {
        uint256 reflection;
        uint256 development;
        uint256 marketing;
        uint256 burn;
        uint256 treasury;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rReflection;
      uint256 rdevelopment;
      uint256 rmarketing;
      uint256 rBurn;
      uint256 rTreasury;
      uint256 tTransferAmount;
      uint256 tReflection;
      uint256 tdevelopment;
      uint256 tmarketing;
      uint256 tBurn;
      uint256 tTreasury;
    }
    
    struct splitETHStruct{
        uint256 development;
        uint256 marketing;
    }

    splitETHStruct public sellSplitETH = splitETHStruct(0,0);
    splitETHStruct public buySplitETH = splitETHStruct(0,0);
    splitETHStruct public walletToWalletSplitETH = splitETHStruct(0,0);


    struct ETHAmountStruct{
        uint256 development;
        uint256 marketing;
    }

    ETHAmountStruct public ETHAmount;

    event FeesChanged();
    event BatchAirDropped(string _batchId);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    modifier addressValidation(address _addr) {
        require(_addr != address(0), 'SaitaRealty :: Zero address');
        _;
    }

    modifier hasAirdropControl(address _addr) {
        require(canAirdrop[_addr], "SaitaRealty :: No access");
        _;
    }

    constructor (address routerAddress, address owner_) Ownable(msg.sender) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        addPair(pair);
    
        excludeFromReward(pair);

        _transferOwnership(owner_);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[developmentAddress] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "SaitaRealty :: Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "SaitaRealty :: Account is already excluded");
        require(_excluded.length <= 200, "SaitaRealty :: Invalid length");
        require(account != owner(), "SaitaRealty :: Owner cannot be excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function addPair(address _pair) public onlyOwner {
        _isPair[_pair] = true;
    }

    function removePair(address _pair) public onlyOwner {
        _isPair[_pair] = false;
    }

    function isPair(address account) public view returns(bool){
        return _isPair[account];
    }

    function setBuyTaxes(uint256 _reflection, uint256 _development, uint256 _marketing, uint256 _burn, uint256 _treasury) public onlyOwner {
        buyTax.reflection = _reflection;
        buyTax.development = _development;
        buyTax.marketing = _marketing;
        buyTax.burn = _burn;
        buyTax.treasury = _treasury;
        emit FeesChanged();
    }

    function setSellTaxes(uint256 _reflection, uint256 _development, uint256 _marketing, uint256 _burn, uint256 _treasury) public onlyOwner {
        sellTax.reflection = _reflection;
        sellTax.development = _development;
        sellTax.marketing = _marketing;
        sellTax.burn = _burn;
        sellTax.treasury = _treasury;
        emit FeesChanged();
    }

    function setWalletToWalletTaxes(uint256 _reflection, uint256 _development, uint256 _marketing, uint256 _burn, uint256 _treasury) public onlyOwner {
        walletToWalletTax.reflection = _reflection;
        walletToWalletTax.development = _development;
        walletToWalletTax.marketing = _marketing;
        walletToWalletTax.burn = _burn;
        walletToWalletTax.treasury = _treasury;
        emit FeesChanged();
    }

    function setBuySplitETH(uint256 _development, uint256 _marketing) public onlyOwner {
        buySplitETH.development = _development;
        buySplitETH.marketing = _marketing;
        emit FeesChanged();
    }

    function setSellSplitETH(uint256 _development, uint256 _marketing) public onlyOwner {
        sellSplitETH.development = _development;
        sellSplitETH.marketing = _marketing;
        emit FeesChanged();
    }

    function setWalletToWalletSplitETH(uint256 _development, uint256 _marketing) public onlyOwner {
        walletToWalletSplitETH.development = _development;
        walletToWalletSplitETH.marketing = _marketing;
        emit FeesChanged();
    }

    function _reflectReflection(uint256 rReflection, uint256 tReflection) private {
        _rTotal -=rReflection;
        totFeesPaid.reflection += tReflection;
    }

    function _takeTreasury(uint256 rTreasury, uint256 tTreasury) private {
        totFeesPaid.treasury += tTreasury;
        if(_isExcluded[address(this)]) _tOwned[address(this)] += tTreasury;
        _rOwned[address(this)] += rTreasury;
    }

    function _takedevelopment(uint256 rdevelopment, uint256 tdevelopment) private {
        totFeesPaid.development += tdevelopment;
        if(_isExcluded[developmentAddress]) _tOwned[developmentAddress] += tdevelopment;
        _rOwned[developmentAddress] +=rdevelopment;
    }
    
    function _takemarketing(uint256 rmarketing, uint256 tmarketing) private {
        totFeesPaid.marketing += tmarketing;
        if(_isExcluded[address(this)]) _tOwned[address(this)] += tmarketing;
        _rOwned[address(this)] += rmarketing;
    }

    function _takeBurn(uint256 rBurn, uint256 tBurn) private {
        totFeesPaid.burn += tBurn;
        if(_isExcluded[burnAddress])_tOwned[burnAddress] += tBurn;
        _rOwned[burnAddress] += rBurn;
    }

    function _getValues(uint256 tAmount, uint8 takeFee) private  returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rReflection, to_return.rdevelopment,to_return.rmarketing, to_return.rBurn, to_return.rTreasury) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, uint8 takeFee) private returns (valuesFromGetValues memory s) {
        if(takeFee == 0) {
          s.tTransferAmount = tAmount;
          return s;
        } else if(takeFee == 1){
            s.tReflection = (tAmount*sellTax.reflection)/1000;
            s.tdevelopment = (tAmount*sellTax.development)/1000;
            s.tmarketing = tAmount*sellTax.marketing/1000;
            s.tBurn = tAmount*sellTax.burn/1000;
            s.tTreasury = tAmount*sellTax.treasury/1000;
            if(sellTax.treasury > 0) {
                ETHAmount.development += s.tTreasury*sellSplitETH.development/sellTax.treasury;
                ETHAmount.marketing += (s.tTreasury*sellSplitETH.marketing/sellTax.treasury);
            }
            ETHAmount.marketing += s.tmarketing;
            s.tTransferAmount = tAmount-s.tReflection-s.tdevelopment-s.tTreasury-s.tmarketing-s.tBurn;
            return s;
        } else if(takeFee == 2) {
            s.tReflection = (tAmount*buyTax.reflection)/1000;
            s.tdevelopment = (tAmount*buyTax.development)/1000;
            s.tmarketing = tAmount*buyTax.marketing/1000;
            s.tBurn = tAmount*buyTax.burn/1000;
            s.tTreasury = tAmount*buyTax.treasury/1000;
            if(buyTax.treasury > 0) {
                ETHAmount.development += s.tTreasury*buySplitETH.development/buyTax.treasury;
                ETHAmount.marketing += (s.tTreasury*buySplitETH.marketing/buyTax.treasury);
            }
            ETHAmount.marketing += s.tmarketing;
            s.tTransferAmount = tAmount-s.tReflection-s.tdevelopment-s.tTreasury-s.tmarketing-s.tBurn;
            return s;
        } else {
            s.tReflection = tAmount*walletToWalletTax.reflection/1000;
            s.tmarketing = tAmount*walletToWalletTax.marketing/1000;
            s.tBurn = tAmount*walletToWalletTax.burn/1000;
            s.tTreasury = tAmount*walletToWalletSplitETH.marketing/1000;
            ETHAmount.marketing += s.tTreasury + s.tmarketing;
            s.tTransferAmount = tAmount-s.tReflection-s.tTreasury-s.tmarketing-s.tBurn;
        }
        
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, uint8 takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection,uint256 rdevelopment,uint256 rmarketing,uint256 rBurn,uint256 rTreasury) {
        rAmount = tAmount*currentRate;

        if(takeFee == 0) {
          return(rAmount, rAmount, 0,0,0,0,0);
        } else if(takeFee == 1) {
            rReflection = s.tReflection*currentRate;
            rdevelopment = s.tdevelopment*currentRate;
            rTreasury = s.tTreasury*currentRate;
            rmarketing = s.tmarketing*currentRate;
            rBurn = s.tBurn*currentRate;
            rTransferAmount =  rAmount-rReflection-rdevelopment-rTreasury-rmarketing-rBurn;
            return (rAmount, rTransferAmount, rReflection,rdevelopment,rmarketing,rBurn,rTreasury);
        } else if(takeFee == 2) {
            rReflection = s.tReflection*currentRate;
            rdevelopment = s.tdevelopment*currentRate;
            rTreasury = s.tTreasury*currentRate;
            rmarketing = s.tmarketing*currentRate;
            rBurn = s.tBurn*currentRate;
            rTransferAmount =  rAmount-rReflection-rdevelopment-rTreasury-rmarketing-rBurn;
            return (rAmount, rTransferAmount, rReflection,rdevelopment,rmarketing,rBurn,rTreasury);
        } else {
            rReflection = s.tReflection*currentRate;
            rTreasury = s.tTreasury*currentRate;
            rmarketing = s.tmarketing*currentRate;
            rBurn = s.tBurn*currentRate;
            rTransferAmount =  rAmount-rReflection-rTreasury-rmarketing-rBurn;
            return (rAmount, rTransferAmount, rReflection,0,rmarketing,rBurn,rTreasury);
        }

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
            tSupply = tSupply-_tOwned[_excluded[i]];
        }

        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Zero amount");
        require(amount <= balanceOf(from),"Insufficient balance");
        require(!_isBot[from] && !_isBot[to], "SaitaRealty :: You are a bot");
        require(amount <= maxTxAmount ,"SaitaRealty :: Amount is exceeding maxTxAmount");

        if (coolDownEnabled) { 
            uint256 timePassed = block.timestamp - _lastTrade[from];
            require(timePassed > coolDownTime, "SaitaRealty :: You must wait coolDownTime");
        }
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && !swapping) {       //check this !swapping
            if(_isPair[from]) {                         // sell

                _tokenTransfer(from, to, amount, 1);

            } else if(_isPair[to]) {                    // buy
                _tokenTransfer(from, to, amount, 2);
            } else {
                _tokenTransfer(from, to, amount, 3);
            }
        } else {
            _tokenTransfer(from, to, amount, 0);
        }

        _lastTrade[from] = block.timestamp;
        
        if(!swapping && from != pair && to != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            address[] memory path = new address[](3);
                path[0] = address(this);
                path[1] = router.WETH();
                path[2] = BUSD;
            uint _amount = router.getAmountsOut(balanceOf(address(this)), path)[2];
            if(_amount >= swapTokensAtAmount) swapTokensForETH(balanceOf(address(this)));
        }
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, uint8 takeFee) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender] - tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rReflection > 0 || s.tReflection > 0) _reflectReflection(s.rReflection, s.tReflection);
        if(s.rTreasury > 0 || s.tTreasury > 0) {
            _takeTreasury(s.rTreasury,s.tTreasury);
        }
        if(s.rdevelopment > 0 || s.tdevelopment > 0){
            _takedevelopment(s.rdevelopment, s.tdevelopment);
            emit Transfer(sender, developmentAddress, s.tmarketing);
        }
        if(s.rmarketing > 0 || s.tmarketing > 0){
            _takemarketing(s.rmarketing, s.tmarketing);
            emit Transfer(sender, address(this), s.tmarketing);
        }
        if(s.rBurn > 0 || s.tBurn > 0){
            _takeBurn(s.rBurn, s.tBurn);
            emit Transfer(sender, burnAddress, s.tBurn);
        }
        
        emit Transfer(sender, recipient, s.tTransferAmount);
        if(s.tTreasury > 0){
        emit Transfer(sender, address(this), s.tTreasury);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        (bool success, ) = developmentAddress.call{value: (ETHAmount.development * address(this).balance)/tokenAmount}("");
        require(success, 'SaitaRealty :: ETH_TRANSFER_FAILED');
        ETHAmount.development = 0;

        (success, ) = marketingAddress.call{value: (ETHAmount.marketing * address(this).balance)/tokenAmount}("");
        require(success, 'SaitaRealty :: ETH_TRANSFER_FAILED');
        ETHAmount.marketing = 0;
    }

    function updatedevelopmentWallet(address newWallet) external onlyOwner addressValidation(newWallet) {
        require(developmentAddress != newWallet, 'SaitaRealty :: Wallet already set');
        developmentAddress = newWallet;
        _isExcludedFromFee[developmentAddress];
    }

    function updateBurnWallet(address newWallet) external onlyOwner addressValidation(newWallet) {
        require(burnAddress != newWallet, 'SaitaRealty :: Wallet already set');
        burnAddress = newWallet;
        _isExcludedFromFee[burnAddress];
    }

    function updatemarketingWallet(address newWallet) external onlyOwner addressValidation(newWallet) {
        require(marketingAddress != newWallet, 'SaitaRealty :: Wallet already set');
        marketingAddress = newWallet;
        _isExcludedFromFee[marketingAddress];
    }

    function updateStableCoin(address _BUSD) external onlyOwner  addressValidation(_BUSD) {
        require(BUSD != _BUSD, 'SaitaRealty :: Wallet already set');
        BUSD = _BUSD;
    }

    function updateMaxTxAmt(uint256 amount) external onlyOwner {
        require(amount >= 100);
        maxTxAmount = amount * 10**_decimals;
    }

    function updateSwapTokensAtAmount(uint256 amount, uint256 stableTokenDecimal) external onlyOwner {
        require(amount >= 0);
        swapTokensAtAmount = amount * 10**stableTokenDecimal;
    }

    function updateCoolDownSettings(bool _enabled, uint256 _timeInSeconds) external onlyOwner{
        coolDownEnabled = _enabled;
        coolDownTime = _timeInSeconds * 1 seconds;
    }

    function setAntibot(address account, bool state) external onlyOwner{
        require(_isBot[account] != state, 'SaitaRealty :: Value already set');
        _isBot[account] = state;
    }
    
    function bulkAntiBot(address[] memory accounts, bool state) external onlyOwner {
        require(accounts.length <= 100, "SaitaRealty :: Invalid");
        for(uint256 i = 0; i < accounts.length; i++){
            _isBot[accounts[i]] = state;
        }
    }
    
    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner {
        router = IRouter(newRouter);
        pair = newPair;
        addPair(pair);
    }
    
    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }
    
    function airdropTokens(address[] memory recipients, uint256[] memory amounts, string memory _batchId) external hasAirdropControl(msg.sender) {
        require(recipients.length == amounts.length,"SaitaRealty :: Invalid size");
         address sender = owner();

         for(uint256 i; i<recipients.length; i++){
            if(balanceOf(recipients[i]) > 0) revert("SaitaRealty :: Already airdropped");
            address recipient = recipients[i];
            uint256 rAmount = amounts[i]*_getRate();
            _rOwned[sender] = _rOwned[sender]- rAmount;
            _rOwned[recipient] = _rOwned[recipient] + rAmount;
            emit Transfer(sender, recipient, amounts[i]);
         }

        emit BatchAirDropped(_batchId);

        }

    //Use this in case ETH are sent to the contract by mistake
    function rescueETH(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "SaitaRealty :: insufficient ETH balance");
        payable(owner()).transfer(weiAmount);
    }
    
    // Function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Owner cannot transfer out catecoin from this smart contract
    function rescueAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    function setAirdropControl(address[] memory _addr, bool[] memory _access) external onlyOwner {
        require(_addr.length == _access.length, "SaitaRealty :: Different length inputs");
        for(uint i = 0; i< _addr.length; i++) {
            canAirdrop[_addr[i]] = _access[i];
        }
    }

    receive() external payable {
    }

}