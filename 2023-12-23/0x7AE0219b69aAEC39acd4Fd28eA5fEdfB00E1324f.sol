// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

contract Context {

  constructor ()  { }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
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

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
    _owner = address(0x000000000000000000000000000000000000dEaD);
  }


  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract TokenDistributor{
	IBEP20 public BNBKtoken;
	IBEP20 public usdttoken;
	ISwapRouter public _swapRouter;
	address public constant blackHole = 0x000000000000000000000000000000000000dEaD;
    constructor (address _usdttoken,address _router) {
        BNBKtoken = IBEP20(msg.sender);
        usdttoken = IBEP20(_usdttoken);
        ISwapRouter swapRouter = ISwapRouter(_router);
        _swapRouter = swapRouter;
        IBEP20(_usdttoken).approve(_router, uint(~uint256(0)));
        }
	
	function buyAndBurn() external {
    // require(msg.sender == address(BNBKtoken), "permission denied");
		if (IBEP20(usdttoken).balanceOf(address(this)) > 0.1 * 10**18 ){
			address[] memory path = new address[](2);
			path[0] = address(usdttoken);
			path[1] = address(BNBKtoken);
			
			_swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				IBEP20(usdttoken).balanceOf(address(this)),
				0,
				path,
				address(blackHole),
				block.timestamp
			);
		}
    }
	function sell() external {
    // require(msg.sender == address(BNBKtoken), "permission denied");
		if (IBEP20(BNBKtoken).balanceOf(address(this)) > 0 ){
			address[] memory path = new address[](2);
			path[0] = address(BNBKtoken);
			path[1] = address(usdttoken);
			_swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
				IBEP20(BNBKtoken).balanceOf(address(this)),
				0,
				path,
				address(this),
				block.timestamp
			);
		}
    }
	receive() external payable {}
}

contract BNBK is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;
  mapping(address => bool) public _swapPairList;
  mapping(address => bool) private _feeWhiteList;
  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address public _mainPair;
  uint256 public Fee = 3;
  address public usdtToken;
  address public constant blackHole = 0x000000000000000000000000000000000000dEaD;
  uint256 private constant MAX = ~uint256(0);
  ISwapRouter swapRouter;
  TokenDistributor public _tokenDistributor;
  bool private inbuy;


  constructor()  {
    _name = "BNBK";
    _symbol = "BNBK";
    _decimals = 18;
    _totalSupply = 300000000 * 10 **18;
    _balances[address(msg.sender)] = _totalSupply;
    usdtToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20(usdtToken).approve(address(swapRouter), MAX);
    _allowances[address(this)][address(swapRouter)] = MAX;
    _tokenDistributor = new TokenDistributor(usdtToken,address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
    _feeWhiteList[address(_tokenDistributor)] = true;
    _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
    _allowances[address(_tokenDistributor)][address(swapRouter)] = MAX;
    
    
    ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
    address swapPair = swapFactory.createPair(address(this), usdtToken);
    _mainPair = swapPair;
    _swapPairList[swapPair] = true;
    _feeWhiteList[address(this)] = true;
    _feeWhiteList[address(msg.sender)] = true;
    emit Transfer(address(0), address(msg.sender), _totalSupply);
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }


  function symbol() external view override returns (string memory) {
    return _symbol;
  }


  function name() external view override returns (string memory) {
    return _name;
  }


  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }


  function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
  }


  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }


  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }


  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }


  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    bool takeFee;
    if (!_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
          takeFee = true;
          if (_swapPairList[recipient]) {
            if(_balances[address(_tokenDistributor)] > 0 && inbuy){
              TokenDistributor(_tokenDistributor).sell();
              inbuy = !inbuy;
            }else{
              TokenDistributor(_tokenDistributor).buyAndBurn();
              inbuy = !inbuy;
            }

          }

      }
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    uint256 feeAmount;
    if (takeFee) {
      feeAmount = amount * Fee/ 100;
      _balances[address(_tokenDistributor)] = _balances[address(_tokenDistributor)].add(feeAmount);
    }
    
      _balances[address(recipient)] = _balances[address(recipient)].add(amount.sub(feeAmount));
      emit Transfer(sender, recipient, amount);

  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }


  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  receive() external payable {
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}