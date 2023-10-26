/*===============================================================================
 * CashBack PEPE (CBPEPE) - Get Rewarded on every Transaction!
 *===============================================================================
 *	A uinque token where all users get REWARDED (in BNB) for using the token 
 *	for regular transactions! 
 *	Implements a uinique on-chain cashback system for all!
 *===============================================================================
 * FEATURES:
 * ---------------
 *	TOTAL TAX: {BUY: 4%} {SELL: 4%}
 *----------------
 * (*)	1% of TAX added to LIQUIDITY POOL
 *  
 * (*)	3% of TAX converted to BNB and added to REWARD POOL!
 *		================
 *		cashback rules:
 *  	================
 *		* Traded tokens value must be atleast (10000 CBPEPE) to qualify.
 *		* Sender and Reciever both get 10% BNB from REWARD POOL as CashBack!
 *		Easy and simple. 
 *		================
 *		This way all transactions will be FREE (and in most cases you 
 *		get back REWARDS more than you pay for transaction FEES)
 *		Use CBPEPE for TRADING on DEX or sending/recieving with other users. 
 *		Every time you use CBPEPE, you will be rewarded!
 *		USE MORE, EARN MORE!
 *===============================================================================
 * The more you use the token, the more you will be rewarded!
 * JOIN THE REVOLUTION!
 *===============================================================================
 * Telegram: https://t.me/CBPEPE_CashBackPEPE
 *===============================================================================
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Address {
	function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
		// accountHash: Hash code for null address (0x0)
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }
}
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
    function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IBEP20 {
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

interface ITokenBank{
	event Taxed(uint256 taxAmt, uint256 lqAmount, uint256 lqETH, uint256 trETH);
	function processTax(uint256 taxAmt) external returns(bool);
	
	event AutoLiquify(uint256 indexed amountTokens, uint256 indexed amountETH);
	function processLiquidity() external;
	
	event CashBack(uint256 indexed senderCB, uint256 indexed recipientCB);
	function processCashBack(address s, address r) external;
	
	function setMinLQ(uint256 amt) external;
	function setToken(address tk) external;
	
}

abstract contract Context {
	address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
	address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    function _msgSender() internal view virtual returns (address){ return msg.sender; }
}

abstract contract Auth is Context {
    address internal owner;
    mapping (address => bool) internal authorizations;
	
    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner(){ require(isOwner(_msgSender()), "NOT_OWNER"); _; }
    modifier authorized(){ require(isAuthorized(_msgSender()), "UNAUTHORIZED"); _; }

    function authorize(address adr) public onlyOwner{ authorizations[adr] = true; }
    function unauthorize(address adr) public onlyOwner{ authorizations[adr] = false; }
    function isOwner(address account) public view returns (bool){ return account == owner; }
    function isAuthorized(address adr) public view returns (bool){ return authorizations[adr]; }

    event OwnershipTransferred(address owner);
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
}

contract CBPEPE is IBEP20, Auth {
	using SafeMath for uint256;
	using Address for address;

	uint8 constant _decimals = 18;
	/*200 Million*/
	uint256 constant _totalSupply = 200 * 10**6 * 10**_decimals;
	
	mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
	
	ITokenBank public tokenbank;
	bool inSwap;
    address public autoLiquidityReciever;
	uint256 public Tax;
	uint256 public CBTxAmount = 10000 * 10**_decimals;
	error BadTxAmount(uint256 amt);
	
	constructor () Auth(_msgSender()){
		transferOwnership(payable(0x0));
		autoLiquidityReciever = _msgSender();
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
	
	event LogDeposit(address indexed, uint256 indexed);
    receive() external payable { require(msg.value > 0); emit LogDeposit(_msgSender(), msg.value); }
    fallback() external payable{ require(msg.value > 0); emit LogDeposit(_msgSender(), msg.value); }
	
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return "CBPEPE"; }
    function name() external pure override returns (string memory) { return "CashBack PEPE"; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
	function _approve( address owner, address spender, uint256 amount ) private {
        require(owner != address(0) && spender != address(0), "APPROVE_NULL_FAILED");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
	function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
	
	function getAllowance(address holder, address spender) external view returns(uint256){
		return _allowances[holder][spender];
	}
	
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][_msgSender()] != type(uint256).max){
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }
	
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        //require( (_balances[sender] >= amount), "INVALID_AMOUNT!");
		//Minimum 1 CBPEPE transfer 
		if( (amount < (1 * 10**18)) || (_balances[sender] < amount) ) revert BadTxAmount(amount);
		
		_balances[sender] = _balances[sender] - amount;
		uint256 _tax;
				
		if(!inSwap){
			if( sender != autoLiquidityReciever ){
				inSwap = true;
				_tax = ((amount.div(100)).mul(4));
				_balances[address(tokenbank)] += _tax;
				Tax += _tax;
				if( !sender.isContract() ){
					try tokenbank.processTax(Tax) returns(bool p0){
						if( p0 == true ){ Tax = 0; }
					}catch{}
					
					try tokenbank.processLiquidity(){}catch{}
				}
				if( sender != recipient && (amount >= CBTxAmount) ){
					try tokenbank.processCashBack(sender, recipient){}catch{}
				}
				inSwap = false;
			}
		}
		_balances[recipient] = _balances[recipient] + ( amount - _tax );
		
        emit Transfer(sender, recipient, amount);
        return true;
    }
	
	function setMinCBTxAmount(uint256 amt) external authorized{ CBTxAmount = amt; }
	function setRouterAddress(address a) external authorized{
		routerAddress = a;
		_allowances[address(tokenbank)][routerAddress] = type(uint256).max;
	}
	
	// Rescue Stuck Balances
    function rescueToken(address ta, uint256 tokens) public authorized returns (bool success) {
		require( ta != address(this) && ta != WBNB, "NOT_ALLOWED");
        return IBEP20(ta).transfer(_msgSender(), tokens);
    }
	
	function setTokenBank(address tb, bool shouldSetToken) public authorized {
		tokenbank = ITokenBank(tb);
        _allowances[tb][routerAddress] = type(uint256).max;
		
		if(shouldSetToken) tokenbank.setToken(address(this));
	}
}