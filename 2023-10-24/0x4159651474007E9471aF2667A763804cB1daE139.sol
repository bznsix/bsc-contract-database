// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    mapping(address => bool) private _roles;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeRouter01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract PLUS is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _blackList;
	
	mapping (address => bool) private _whiteList; 

    uint256 private constant MAX = ~uint256(0); 
    uint256 private _tTotal = 7613 * 10**18;

    uint256 private _coinMinNum = 713 * 10 ** 18;
	
    string private _name = "PLUS";
    string private _symbol = "PLUS";
    uint8  private _decimals = 18;

    mapping(address => bool) oneContract;
	
	function setOneContract(address adr, bool status) public onlyOwner {
        oneContract[adr] = status;
    }

    mapping(address => address) public inviter; // invite person

    address public burnAddress = address(0); // burn 2 per
	
	uint256 public _buyFee = 35;
	
	uint256 public _sellFee = 35;
	
	uint256 public _removeFee = 35;

    uint256 public _burnFee = 20;

    uint256 public minNum = 1e14;
	
	// fee list end
	address public ownerAddress = address(0xCb4E5dE2eFE62950649b5F11CE8085211F55450d);
	
	address public inviteBurnAddress = address(0xCb4E5dE2eFE62950649b5F11CE8085211F55450d);
	
	address public marketAddress = address(0x51E9ac62Fe8Ee7205f723Ee283D58e2689adF741);

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
	
	bool public notOpen = true;

    bool public canBuy = true;

    bool public canSell = true;

    uint bindMin = 1e16;

    function setMarketAddress(address _setAddress) public onlyOwner{
        marketAddress = _setAddress;
    }

    function setBurnAddress(address _setAddress) public onlyOwner{
        burnAddress = _setAddress;
    }

    function setBuyFee(uint _setFee) public onlyOwner{
        _buyFee = _setFee;
    }

    function setBurnFee(uint _setFee) public onlyOwner{
        _burnFee = _setFee;
    }

    function setSellFee(uint _setFee) public onlyOwner{
        _sellFee = _setFee;
    }

    function setCoinMinNum(uint _setFee) public onlyOwner{
        _coinMinNum = _setFee;
    }

    function setRemoveFee(uint _setFee) public onlyOwner{
        _removeFee = _setFee;
    }

    constructor () {
        _decimals = 18;
        _rOwned[ownerAddress] = _tTotal;
        
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        oneContract[uniswapV2Pair] = true;
        emit Transfer(address(0), ownerAddress, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal.sub(balanceOf(address(0)));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
	function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        if (takeFee){
		    bool willBurn = true;
            if (totalSupply() <= _coinMinNum){
                willBurn = false;
            }
            (uint256 feeAmount, uint256 sendAmount, uint doType)
             = _getTValues(sender, recipient, tAmount, willBurn);

            if (feeAmount != 0){
                _takeInviterFee(sender, recipient, feeAmount, doType, willBurn);
            }
            
            _rOwned[recipient] = _rOwned[recipient].add(sendAmount);
            emit Transfer(sender, recipient, sendAmount);
        } else {
            _rOwned[recipient] = _rOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }
    }
	
	function _getTValues(address sender, address recipient, uint256 tAmount, bool willBurn) private view returns (uint256, uint256, uint) {
        uint256 feeAmount = 0;
		uint256 sendAmount = tAmount;
        uint doType = 0;
		if (oneContract[recipient]) {
			// sell
			feeAmount = tAmount.mul(_sellFee).div(1000);
            doType = 1;
		} else if (sender == address(uniswapV2Router)){
			// removeL
			feeAmount = tAmount.mul(_removeFee).div(1000);
            doType = 2;
		} else if (oneContract[sender]){
			// buy
			feeAmount = tAmount.mul(_buyFee).div(1000);
            doType = 3;
		} else {
            doType = 4;
        }
		sendAmount = sendAmount.sub(feeAmount);
        if (!willBurn){
            sendAmount = sendAmount.add(tAmount.mul(_burnFee).div(1000));
        }
		
		return (feeAmount, sendAmount, doType);
	}

	function giveAllFee (
		address sender, 
		uint256 amount,
        bool willBurn)
	private {
		if (amount > 0) {
			(uint256 burnAmount, uint256 lpAmount, uint256 shareAmunt) = getAllFee (amount);
			_sellToBurn(sender, burnAmount, willBurn);
			_sellToLp(sender, lpAmount);
			_inviteFee(sender, sender, shareAmunt);
        }
	}

    function getAllFee(uint amount) private pure returns(uint, uint, uint){
        uint burnAmount = amount.mul(4).div(7);
        uint lpAmount = burnAmount.div(2);
        uint shareAmount = burnAmount.div(2);
        return (burnAmount, lpAmount, shareAmount);
    }
	
	function _sellToBurn (address sender, uint amount, bool willBurn) private {
        if (willBurn){
            _rOwned[burnAddress] = _rOwned[burnAddress].add(amount);
            emit Transfer(sender, burnAddress, amount);
        }
	}

    function _sellToLp (address sender, uint amount) private {
		_rOwned[marketAddress] = _rOwned[marketAddress].add(amount);
        emit Transfer(sender, marketAddress, amount);
	}
	
	
	function _inviteFee (
		address sender,
		address cur,
		uint256 amount) 
	private {
		address cur1 = cur;
		if (amount != 0){
			for (int256 i = 0; i < 2; i++) {
				uint256 rate;
				if (i == 0) {
					rate = 3;
				} else if (i == 1) {
					rate = 2;
				}
				
				if (cur1 != cur || i == 0){
					cur1 = inviter[cur1];
				} else {
					cur1 = address(0);
				}
				uint256 curTAmount = amount.mul(rate).div(5);
				
				if (cur1 != address(0)){
					_rOwned[cur1] = _rOwned[cur1].add(curTAmount);
					emit Transfer(sender, cur1, curTAmount);
				} else {
					_rOwned[inviteBurnAddress] = _rOwned[inviteBurnAddress].add(curTAmount);
					emit Transfer(sender, inviteBurnAddress, curTAmount);
				}
			}
		}
	}
	
	function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
		uint doType,
        bool willBurn
    ) private {
		// sell
		if (doType == 1 || doType == 2) {
			giveAllFee(sender, tAmount, willBurn);
		} else if (doType == 3){
            giveAllFee(recipient, tAmount, willBurn);
		}
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
    
    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }
	
	function notEx(address account, bool state) public onlyOwner {
        _whiteList[account] = state;
    }
    
    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }
	
	function setNotOpen(bool _enabled) public onlyOwner {
        notOpen = _enabled;
    }

    function setCanBuy(bool _enabled) public onlyOwner {
        canBuy = _enabled;
    }

    function setCanSell(bool _enabled) public onlyOwner {
        canSell = _enabled;
    }


    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function getErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    receive() external payable {}

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
	
	function isWhiteList(address account) public view returns(bool) {
        return _whiteList[account];
    }

    function setMinTrans(uint _setMin) public onlyOwner{
        minNum = _setMin;
    }

    function setBindNum(uint _setNum) public onlyOwner{
        bindMin = _setNum;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(!_blackList[from] && !_blackList[to]);
        require(amount >= minNum, "must more than min");
        require(_rOwned[from].sub(amount) >= minNum, "must last min");
        
        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        bool fromC = isContract(from);
        bool toC = isContract(to);
		bool beforeUser = _whiteList[to] || _whiteList[from];

		if (notOpen && (fromC || toC)) {
		 	require(beforeUser, "error address");
		}

        bool isBuy = oneContract[from];
        bool isSell = oneContract[to];
        
        if (!beforeUser){
            if (isBuy){
                require(canBuy , "can't buy");
            }

            if (isSell){
                require(canSell, "can't SELL");
            }
        }

        bool shouldSetInviter = inviter[to] == address(0) && to != address(0) && !isContract(from) && !isContract(to) && (amount >= bindMin);
		
        _transferStandard(from, to, amount, takeFee);

        if (shouldSetInviter) {
            _setInvite(to, from);
        }
    }

    function setErrorAddress(address errAddress) public onlyOwner{
        inviter[errAddress] = address(0);
    }

    function getInvite(address searchAddress) public view returns(address){
        return inviter[searchAddress];
    }
	
	function _setInvite(address to, address from) private {
		if (inviter[from] != to){
			inviter[to] = from;
		}
	}
}