// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IPancakePair {
    function getReserves() external view returns (uint112, uint112, uint32);

    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IPancakeswapV2Factory {
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

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library PancakeLibrary {
    using SafeMath for uint;
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}


contract VCEToken is Context, IERC20, Ownable {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address private foundationAddress = 0xE9416e671F8d061aBca7B60a804e39FEdB027Fc0;
    address private LianchuangAddress = 0x6FaD6e02591147FF795145BE02c9c4ee492322b5;
    address private placementAddress = 0x7405a824F68E350DfD839dbC40aC1d4aD255761c;
    address private lianchuangWeightedAddress = 0x7D44164cB75D3228Ece996A73c645B43872186Fe;
    address private allocationPoolAddress = 0xB6C506606eC9D9728e6831F11d6c95a2C779dbE8;
    address private potAddress = 0x23f9D080AbE7dA655645A0a6cD8E7c9537660971;

    address private dotReceiverAddress = 0x4Ca4B21498Aea5A2F304B6c210891ba6fB3469e7;
    mapping(address => bool) public isNoFeeAddress;
    uint private _dot = 3;
    bool private _feeLock = false;
    bool private _feeSwitch = true;

    IPancakeRouter02 public pancakeRouter;
    address public pancakeswapPair;
    address public pairToken = 0x55d398326f99059fF775485246999027B3197955;
    // address public pairToken = 0x92eCC3526e68E15089755F479d4bD54593e8190D;
    address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address public  pancakeRouterAddress = 0x3E2b14680108E8C5C45C3ab5Bc04E01397af14cB;

    constructor() {
        uint256 issuedTotalSupply = 100000000;
        _name = "VCE";
        _symbol = "VCE";

        _mint(foundationAddress, 7 * issuedTotalSupply * 10 ** uint(decimals()) / 100);
        _mint(LianchuangAddress, 5 * issuedTotalSupply * 10 ** uint(decimals()) / 100);
        _mint(placementAddress, 15 * issuedTotalSupply * 10 ** uint(decimals()) / 100);
        _mint(lianchuangWeightedAddress, 3 * issuedTotalSupply * 10 ** uint(decimals()) / 100);
        _mint(allocationPoolAddress, 55 * issuedTotalSupply * 10 ** uint(decimals()) / 100);
        _mint(potAddress, 15 * issuedTotalSupply * 10 ** uint(decimals()) / 100);

        isNoFeeAddress[msg.sender] = true;
        isNoFeeAddress[address(this)] = true;
        isNoFeeAddress[foundationAddress] = true;
        isNoFeeAddress[LianchuangAddress] = true;
        isNoFeeAddress[placementAddress] = true;
        isNoFeeAddress[lianchuangWeightedAddress] = true;
        isNoFeeAddress[allocationPoolAddress] = true;
        isNoFeeAddress[potAddress] = true;
        isNoFeeAddress[dotReceiverAddress] = true;
        
        isNoFeeAddress[0x3Fc653208447842770C49E8Eb72F784bC7D65b72] = true;
        isNoFeeAddress[0x8c6bc1C3397B5B45fd19a4cA0c868cC795f2f0e9] = true;
        isNoFeeAddress[0x426cDea7357686fFB5135b744c161cDAe0988Cae] = true;
        isNoFeeAddress[0xa955f036bc8E1369847135b07411018E195DDA66] = true;

        pancakeRouter = IPancakeRouter02(pancakeRouterAddress);
        pancakeswapPair = IPancakeswapV2Factory(pancakeRouter.factory()).createPair(address(this), pairToken);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function setNoFeeAddress(address[] memory list, bool bl) external onlyOwner{
        for(uint8 i=0;i<list.length;i++){
            isNoFeeAddress[list[i]] = bl;
        }
    }

    function setDotReceiverAddress(address reciverAddress) external onlyOwner{
        dotReceiverAddress = reciverAddress;
    }
    
    
    function getDotReceiverAddress() external view onlyOwner returns(address){
        return dotReceiverAddress ;
    }


    function setFeeSwitch(bool feeSwitch) external onlyOwner{
        _feeSwitch = feeSwitch;
    }
    
    function getFeeSwitch() external view onlyOwner returns(bool){
        return _feeSwitch;
    }
    
    
    function getDot() external view onlyOwner returns(uint256){
        return _dot;
    }
    
    
    function setDot(uint256 dot) external onlyOwner{
        _dot = dot;
    }
    

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 senderFeeValue = _dotFee(sender, recipient , amount);
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount - senderFeeValue;

        emit Transfer(sender, recipient, amount);
    }

    function _dotFee(address sender,address recipient ,uint256 amount) private returns (uint256) {
        uint256 senderFeeValue = 0;
        if(_feeSwitch && !_feeLock && !isNoFeeAddress[tx.origin] && recipient == pancakeswapPair){
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(pairToken);
            _feeLock = true;
            senderFeeValue = amount * _dot / 100;
            if( senderFeeValue > 0){
                _balances[address(this)] += senderFeeValue;
                _approve(address(this), address(pancakeRouter), senderFeeValue * 2);
                pancakeRouter.swapExactTokensForTokens(
                    senderFeeValue,
                    0,
                    path,
                    dotReceiverAddress,
                    block.timestamp
                );
            }
            _feeLock = false;
        }
        return senderFeeValue;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function usdtWealth(uint256 amount) public view returns (uint256){
        address token0 = IPancakePair(pancakeswapPair).token0();
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pancakeswapPair).getReserves();
        if (token0 != address(this)) {
            uint112 tmp = reserve0;
            reserve0 = reserve1;
            reserve1 = tmp;
        }
        return (amount * 10 ** 3) * (reserve1 * 10 ** 3) / (reserve0 * 10 ** 3);
    }
    
    
    function transferAllocationPool(uint256 amount) public returns (bool) {
        require(_balances[_msgSender()] >= amount, "ERC20: transfer amount exceeds balance");
        
        uint256 destroyAmount = amount * 80 / 100;
        uint256 allocationPoolAmount = amount * 20 / 100;
        _balances[_msgSender()] -= amount;
        _balances[allocationPoolAddress] += allocationPoolAmount;
        emit Transfer(_msgSender(), allocationPoolAddress, allocationPoolAmount);
        emit Transfer(_msgSender(), address(0), destroyAmount);
        return true;
    }
    
}