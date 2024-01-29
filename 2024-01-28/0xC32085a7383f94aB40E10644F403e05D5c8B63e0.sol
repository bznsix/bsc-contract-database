pragma solidity ^0.8.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

interface FactoryInterface {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface RouterInterface {
	function WETH() external view returns (address);
    function factory() external view returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
}

library FeeLib {
	struct FeeRule {
		address recipient;
		uint8 ruletype;	// 0 for transfer, 1 for swapping to usdt, 2 for lp
		bytes additionalData;
	}
	
	struct FeeRate {
		string description;
		uint256 buyFee;
		uint256 sellFee;
		FeeRule underlyingRule;
	}
	
	struct BatchedSwapOutput {
		address to;
		uint256 inTokens;
	}
}

contract FeeManager {
	address constant ROUTER_ADDRESS_MAINNET = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
	address constant ROUTER_ADDRESS_TESTNET = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

	address constant USDT_ADDRESS_MAINNET = 0x55d398326f99059fF775485246999027B3197955;
	address constant USDT_ADDRESS_TESTNET = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

	address public immutable pairAddr;
	address public immutable routerAddr;
	address public immutable wbnbAddr;
	address public immutable usdtAddr;
	address public immutable tokenAddr;
	
	FeeLib.FeeRule[] public rules;
	uint256[] public pendingAmounts;
	
	
	
	modifier onlyToken {
		require(msg.sender == tokenAddr, "NOT_TOKEN");
		_;
	}
	
	constructor(address _tokenAddr) {
		address _routerAddr = (block.chainid == 56)?ROUTER_ADDRESS_MAINNET:ROUTER_ADDRESS_TESTNET;
		address _usdtAddr = (block.chainid == 56)?USDT_ADDRESS_MAINNET:USDT_ADDRESS_TESTNET;
	
		RouterInterface _router = RouterInterface(_routerAddr);
		
		pairAddr = FactoryInterface(_router.factory()).createPair(_tokenAddr, _usdtAddr);
		
		routerAddr = _routerAddr;
		usdtAddr = _usdtAddr;
		tokenAddr = _tokenAddr;
		wbnbAddr = _router.WETH();
	}
	
	function _execSwap(address[] memory _route, uint256 inAmt, address to) private returns (uint256 obtained) {
		address _routerAddr = routerAddr;
		ERC20Interface _arrivalToken = ERC20Interface(_route[_route.length-1]);
		
		uint256 bal = _arrivalToken.balanceOf(to);
		
		ERC20Interface(_route[0]).approve(_routerAddr, inAmt);
		
		RouterInterface(_routerAddr).swapExactTokensForTokensSupportingFeeOnTransferTokens(inAmt, 0, _route, to, block.timestamp);

		return _arrivalToken.balanceOf(to) - bal;
	}
	
	function _execLP(address tokenA, address tokenB, uint256 amountA, uint256 amountB, address to) private returns (uint256 obtained) {
		address _routerAddr = routerAddr;
		ERC20Interface(tokenA).approve(_routerAddr, amountA);
		ERC20Interface(tokenB).approve(_routerAddr, amountB);
		(,,obtained) = RouterInterface(_routerAddr).addLiquidity(tokenA, tokenB, amountA, amountB, 0, 0, to, block.timestamp);
	}
	
	function _swapForUSDT(uint256 tokens, address to) private returns (uint256) {
		address[] memory _route = new address[](2);
		_route[0] = tokenAddr;
		_route[1] = usdtAddr;
		return _execSwap(_route, tokens, to);
	}
	
	function swapAndLiquify(uint256 amountToken, address to) private returns (uint256 toLP) {
		uint256 half = amountToken/2;
		uint256 otherHalf = amountToken-half;
		uint256 obtained = _swapForUSDT(half, address(this));
		return _execLP(tokenAddr, usdtAddr, otherHalf, obtained, to);
	}
	
	function dispatchUSDT(uint256 swapped, uint256 usdtAmount) private {
		ERC20Interface _usdt = ERC20Interface(usdtAddr);
	
		for (uint256 i=0; i<rules.length; i++) {
			if (rules[i].ruletype == 1) {
				uint256 toSend = (pendingAmounts[i] * usdtAmount) / swapped;
				_usdt.transfer(rules[i].recipient, toSend);
				pendingAmounts[i] = 0;
			}
		}
	}
	
	function dispatchLP(uint256 swapped, uint256 usdtAmount) private {
		ERC20Interface _usdt = ERC20Interface(pairAddr);
	
		for (uint256 i=0; i<rules.length; i++) {
			if (rules[i].ruletype == 2) {
				uint256 toSend = (pendingAmounts[i] * usdtAmount) / swapped;
				_usdt.transfer(rules[i].recipient, toSend);
				pendingAmounts[i] = 0;
			}
		}
	}
	
	function batchExecRules() public {
		address _tokenAddr = tokenAddr;
		uint256 toSwap;
		uint256 toLP;
	
		for (uint256 i=0; i<rules.length; i++) {
			FeeLib.FeeRule storage _rule = rules[i];
			
			if (_rule.ruletype == 0) {
				ERC20Interface(_tokenAddr).transfer(_rule.recipient, pendingAmounts[i]);
				pendingAmounts[i] = 0;
			} else if (_rule.ruletype == 1) {
				toSwap += pendingAmounts[i];
			} else if (_rule.ruletype == 2) {
				toLP += pendingAmounts[i];
			}
		}
		if (toSwap > 0) {
			uint256 obtained = _swapForUSDT(toSwap, address(this));
			dispatchUSDT(toSwap, obtained);
		}
		if (toLP > 0) {
			uint256 obtained = swapAndLiquify(toSwap, address(this));
			dispatchLP(toSwap, obtained);
		}
	}

	function setRules(FeeLib.FeeRule[] memory _rules) public onlyToken {
		require(msg.sender == tokenAddr, "NOT_TOKEN");
		// replaces pending amounts with a fresh list
		pendingAmounts = new uint256[](_rules.length);
        delete rules;
        for (uint256 k=0; k<_rules.length; k++) {
            rules[k] = _rules[k];
        }

	}

	function _accrueFee(uint256 ruleIndex, uint256 amount) private {
		pendingAmounts[ruleIndex] += amount; 
	}
	
	function accrueFee(uint256 ruleIndex, uint256 amount) public onlyToken {
		_accrueFee(ruleIndex, amount);
	}
	
	function accrueFees(uint256[] calldata fees) public onlyToken {
		for (uint256 k=0; k<fees.length; k++) {
			if (fees[k] > 0) {
				_accrueFee(k, fees[k]);
			}
		}
	}
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);
	event OwnershipRenounced();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
	
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
	
	function renounceOwnership() public onlyOwner {
		owner = address(0);
		newOwner = address(0);
		emit OwnershipRenounced();
	}
}

contract B2BToken is Owned {
	string public constant name = "B2bTest";
	string public constant symbol = "B2BTest";
	uint8 public constant decimals = 18;
	
	uint256 public constant MAX_FEE = 2500;
	
	uint256 public immutable supply;
	
	FeeManager public feeManager;
	
	bool public SWAP_TOKENS = true;
	bool public WHITELIST_ENABLED = true;
	
	uint256 public constant FEE_DENOMINATOR = 10000;
	
	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowances;
	mapping(address => bool) public whitelisted;
	mapping(address => bool) public excluded;	// excluded from fees
	
	
	address public pairAddr;
	
	string[] public feeDescriptions;
	uint256[] public buyFees;
	uint256[] public sellFees;
	
	
	address public MARKETING_ADDRESS = 0x199adAcd60b01e4AE1E1eb798896937216E837EF;
	address public DONATIONS_ADDRESS = 0xe3A0Cb282f88C2982cc1574Df5b706491dA315D3;
	address public LEADERS_ADDRESS = 0x6bc81BEE231a159E4118926fD73a44eFE109520d;
	address public COMPANY_ADDRESS = 0x662E092Ba0b1a44501C1367BCFaF594991e0BB7f;
	address public LP_RECIPIENT = address(0);	// default behavior: burn LP
	
	// default erc20/bep20 events
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
	// custom events
	event WhitelistStatusChanged(bool enabled);
	event AddressWhitelisted(address indexed holder, bool indexed status);
	event AddressExcluded(address indexed holder, bool indexed status);
	
	constructor(uint256 _totalSupply) {
		supply = _totalSupply;
		balances[msg.sender] = supply;
		emit Transfer(address(0), msg.sender, supply);
		
		feeManager = new FeeManager(address(this));
		
		// excludes fee manager from fees and whitelists it
		address _mgrAddress = address(feeManager);
		whitelisted[_mgrAddress] = true;
		excluded[_mgrAddress] = true;
		
		
		pairAddr = feeManager.pairAddr();
		
		FeeLib.FeeRate[] memory fees = new FeeLib.FeeRate[](6);
		fees[0] = FeeLib.FeeRate("LP", 100, 100, FeeLib.FeeRule(LP_RECIPIENT, 2, ""));
		fees[1] = FeeLib.FeeRate("Donations", 75, 50, FeeLib.FeeRule(DONATIONS_ADDRESS, 1, ""));
		fees[2] = FeeLib.FeeRate("Marketing", 75, 50, FeeLib.FeeRule(MARKETING_ADDRESS, 1, ""));
		fees[3] = FeeLib.FeeRate("Leaders", 25, 25, FeeLib.FeeRule(LEADERS_ADDRESS, 1, ""));
		fees[4] = FeeLib.FeeRate("Company", 75, 50, FeeLib.FeeRule(COMPANY_ADDRESS, 1, ""));
		fees[5] = FeeLib.FeeRate("Burn", 0, 50, FeeLib.FeeRule(address(0), 0, ""));
	}
	
	// view functions
	function totalSupply() public view returns (uint256) {
		return supply - (balances[address(0)] + balances[address(0xdead)]);
	}
	
	function balanceOf(address holder) public view returns (uint256) {
		if ((holder == address(0))||(holder == address(0xdead))) {
			return 0;
		}
		return balances[holder];
	}
	
	function allowance(address tokenOwner, address spender) public view returns (uint256) {
		return allowances[tokenOwner][spender];
	}
	
	// private setup functions - WARNING BEFORE EDITING
	function _setupFees(FeeLib.FeeRate[] memory fees) private {
		FeeLib.FeeRule[] memory _rules = new FeeLib.FeeRule[](fees.length);
		uint256[] memory _buyFees = new uint256[](fees.length); 
		uint256[] memory _sellFees = new uint256[](fees.length); 
	
	
		uint256 totalFeeBuy;
		uint256 totalFeeSell;
	
		for (uint256 k=0; k<fees.length; k++) {
			_buyFees[k] = fees[k].buyFee;
			totalFeeBuy += _buyFees[k];
			
			_sellFees[k] = fees[k].sellFee;
			totalFeeSell += _sellFees[k];

			require((totalFeeBuy <= MAX_FEE) && (totalFeeSell <= MAX_FEE), "MAX_FEE_OVERFLOW");
			
			feeDescriptions[k] = fees[k].description;
			_rules[k] = fees[k].underlyingRule;
		}
		
		buyFees = _buyFees;
		sellFees = _sellFees;
		
		feeManager.setRules(_rules);
	}
	
	function _updateFee(uint256 index, uint256 buy, uint256 sell) private {
		buyFees[index] = buy;
		sellFees[index] = sell;
		
		uint256 totalFeeBuy;
		uint256 totalFeeSell;
		
		for (uint256 i=0; i<buyFees.length; i++) {
			totalFeeBuy += buyFees[i];
			totalFeeSell += sellFees[i];
		}
		require((totalFeeBuy <= MAX_FEE) && (totalFeeSell <= MAX_FEE), "MAX_FEE_OVERFLOW");
	}
	
	// private data fetching functions
	function _calcBuyFees(uint256 amount) private view returns (uint256[] memory, uint256 total) {
		uint256[] storage fees = buyFees;
		uint256[] memory amounts = new uint256[](fees.length);
		for (uint256 k=0; k<fees.length; k++) {
			uint256 f = (amount*fees[k])/FEE_DENOMINATOR;
			amounts[k] = f;
			total += f;
		}
		return (amounts, total);
	}
	
	function _calcSellFees(uint256 amount) private view returns (uint256[] memory, uint256 total) {
		uint256[] storage fees = sellFees;
		uint256[] memory amounts = new uint256[](fees.length);
		for (uint256 k=0; k<fees.length; k++) {
			uint256 f = (amount*fees[k])/FEE_DENOMINATOR;
			amounts[k] = f;
			total += f;
		}
		return (amounts, total);
	}
	
	function isSell(address from, address to) public view returns (bool) {
        from;
		return (to == pairAddr);
	}
	
	
	// private write functions - CAUTION
	function _approve(address tokenOwner, address spender, uint256 tokens) private {
		allowances[tokenOwner][spender] = tokens;
		emit Approval(tokenOwner, spender, tokens);
	}
	
	function accrueFees(uint256[] memory fees, uint256 total) public {
		balances[address(feeManager)] += total;
		feeManager.accrueFees(fees);
		try feeManager.batchExecRules() {
		} catch {
		
		}
	}
	
	function _transfer(address from, address to, uint256 tokens) private {
		bool _isSell = isSell(from, to);
		uint256[] memory fees;
		uint256 totalFees;
	
		require(WHITELIST_ENABLED || whitelisted[from] || whitelisted[to], "Whitelist enabled");
	
		if (excluded[from] || excluded[to]) {
			totalFees = 0;
		} else {
			(fees, totalFees) = _isSell?_calcSellFees(tokens):_calcBuyFees(tokens);
		}
	
		uint256 toAdd = tokens - totalFees;
		
		// WARNING: MAKE SURE COMPILER RUNS SOLIDITY v0.8.x
		// solidity 0.8 has overflow detection
		balances[from] -= tokens;
		balances[to] += toAdd;
		
		if (totalFees > 0) {
			accrueFees(fees, totalFees);
			emit Transfer(from, address(feeManager), totalFees);
		}
		
		emit Transfer(from, to, toAdd);
	}
	
	// public write functions - CAUTION
	function approve(address spender, uint256 tokens) public returns (bool) {
		_approve(msg.sender, spender, tokens);
		return true;
	}
	
	function transfer(address to, uint256 tokens) public returns (bool) {
		_transfer(msg.sender, to, tokens);
		return true;
	}
	
	function transferFrom(address from, address to, uint256 tokens) public returns (bool) {
		allowances[from][msg.sender] -= tokens;
		_transfer(from, to, tokens);
		return true;
	}
	
	// onlyOwner functions
	function setWhitelistEnabled(bool status) public onlyOwner {
		WHITELIST_ENABLED = status;
		emit WhitelistStatusChanged(status);
	}
	
	function setWhitelistStatus(address holder, bool status) public onlyOwner {
		whitelisted[holder] = status;
		emit AddressWhitelisted(holder, status);
	}
	
	function setExclusionStatus(address holder, bool status) public onlyOwner {
		excluded[holder] = status;
		emit AddressExcluded(holder, status);
	}
}