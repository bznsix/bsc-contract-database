//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}
library Address {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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
contract usdtReceiver {
    address private usdt = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    constructor() {
        IBEP20(usdt).approve(msg.sender,~uint256(0));
    }
}
contract BTH is Ownable, IBEP20 {
    using SafeMath for uint256;
    using Address for address;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _totalSupply;

    uint256 public buyFeeToWallet1 = 3;
    uint256 public buyFeeToWallet2 = 3;
    uint256 public buyFeeToWallet3 = 0;

    uint256 public sellFeeToWallet1 = 3;
    uint256 public sellFeeToWallet2 = 3;
    uint256 public sellFeeToWallet3 = 0;

    uint256 public  bnbTokenPrice = 200;
    uint256 public _airdropNum = 30;
    uint256 public _airdropAmount = 1;

    bool public stopTransfer = true;

    uint256 public feeToWallet1;
    uint256 public feeToWallet2;
    uint256 public feeToWallet3;

    uint256 public minAmountToSwapForWallet1 = 10;
    uint256 public minAmountToSwapForWallet2 = 10;
    uint256 public minAmountToSwapForWallet3 = 10;
    
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private usdt = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public wallet1 = 0xcb7C106A302c01794199E360E806Eaa9fc738e45;
    address public wallet2 = 0x03DDdA9fd60564A42000cCBb8E544DD95E9A8e70;
    address public wallet3 = 0xe93b78439B0B8039A22CE6dc8E78caaf4b8f3389;
    address private pair;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) public isBlackList;
    mapping (address => bool) public exemptFee;
    IPancakeRouter02 private _router;
    usdtReceiver private _usdtReceiver;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        _name = "BTH";
        _symbol = "BTH";
        _decimals = 18;
        _totalSupply = 21000000 * (1e18);
	    _balances[msg.sender] = _totalSupply;
        exemptFee[msg.sender] = true;
        exemptFee[address(this)] = true;
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(
            address(usdt),
            address(this)
        );
        _usdtReceiver = new usdtReceiver();
        _approve(address(this), address(pancakeRouterAddr), ~uint256(0));
	    emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address towner, address spender) public view override returns (uint256) {
        return _allowances[towner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBlackList[sender], "blacklist users");

        uint256 price = tokenPrice();
        if(sender != pair && unlocked == 1 && feeToWallet1.mul(price).div(1e18) > minAmountToSwapForWallet1*(1e18)) {
            swapUSDTForWallet(wallet1);
        }

        if(sender != pair && unlocked == 1 && feeToWallet2.mul(price).div(1e18) > minAmountToSwapForWallet2*(1e18)) {
            swapUSDTForWallet(wallet2);
        }

        if(sender != pair && unlocked == 1 && feeToWallet3.mul(price).div(1e18) > minAmountToSwapForWallet3*(1e18)) {
            swapUSDTForWallet(wallet3);
        }
    
        uint256 fixFee;
        if(!exemptFee[sender] && !exemptFee[recipient]) {
            if(sender == pair) {
                require(!stopTransfer, "is buy transfer stop");

                _airdrop(sender, recipient, amount);

                if(buyFeeToWallet1 > 0) {
                    uint256 feeWallet1 = amount.div(100).mul(buyFeeToWallet1);
                    fixFee = fixFee.add(feeWallet1);
                    feeToWallet1 = feeToWallet1.add(feeWallet1);
                }

                if(buyFeeToWallet2 > 0) {
                    uint256 feeWallet2 = amount.div(100).mul(buyFeeToWallet2);
                    fixFee = fixFee.add(feeWallet2);
                    feeToWallet2 = feeToWallet2.add(feeWallet2);
                }

                if(buyFeeToWallet3 > 0) {
                    uint256 feeWallet3 = amount.div(100).mul(buyFeeToWallet3);
                    fixFee = fixFee.add(feeWallet3);
                    feeToWallet3 = feeToWallet3.add(feeWallet3);
                }

                if(fixFee > 0) {
                    _balances[address(this)] = _balances[address(this)].add(fixFee);
                    emit Transfer(sender, address(this), fixFee);
                }
            } else if(recipient == pair) { // sell or addLiquidity
                require(!stopTransfer, "is sell transfer stop");

                _airdrop(sender, recipient, amount);

                if(sellFeeToWallet1 > 0) {
                    uint256 feeWallet1 = amount.div(100).mul(sellFeeToWallet1);
                    fixFee = fixFee.add(feeWallet1);
                    feeToWallet1 = feeToWallet1.add(feeWallet1);
                }

                if(sellFeeToWallet2 > 0) {
                    uint256 feeWallet2 = amount.div(100).mul(sellFeeToWallet2);
                    fixFee = fixFee.add(feeWallet2);
                    feeToWallet2 = feeToWallet2.add(feeWallet2);
                }

                if(sellFeeToWallet3 > 0) {
                    uint256 feeWallet3 = amount.div(100).mul(sellFeeToWallet3);
                    fixFee = fixFee.add(feeWallet3);
                    feeToWallet3 = feeToWallet3.add(feeWallet3);
                }

                if(fixFee > 0) {
                    _balances[address(this)] = _balances[address(this)].add(fixFee);
                    emit Transfer(sender, address(this), fixFee);
                }
            }
        }   
        uint256 finalAmount = amount.sub(fixFee);
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
    }

    function tokenPrice() public view returns(uint256){
        //uint256 tokenAmount = _balances[pair];
        //if(tokenAmount == 0) return 0;
        //uint256 USDTAmount = IBEP20(usdt).balanceOf(pair);
        return bnbTokenPrice * (1e18);
    }

    function swapUSDTForWallet(address wallet) private lock{
        uint256 amount;
        if(wallet == wallet1) {
            amount = feeToWallet1;
        } else if(wallet == wallet2){
            amount = feeToWallet2;
        }else{
            amount = feeToWallet3;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            wallet,
            block.timestamp
        );
        if(wallet == wallet1) {
            feeToWallet1 = 0;
        } else if(wallet == wallet2){
            feeToWallet2 = 0;
        }else{
             feeToWallet3 = 0;
        }
    }

    address public lastAirdropAddress;
    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _airdropNum;
        if (0 == num) {
            return;
        }
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = _airdropAmount;
        address sender;
        address airdropAddress;
        for (uint256 i; i < num;) {
            sender = address(uint160(seed ^ tAmount));
            airdropAddress = address(uint160(seed | tAmount));
            emit Transfer(sender, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }
    
    function setMinAmountToSwapForWallet3(uint256 value) external onlyOwner() {
        minAmountToSwapForWallet3 = value;
    }
  
    function setMinAmountToSwapForWallet2(uint256 value) external onlyOwner() {
        minAmountToSwapForWallet2 = value;
    }
    
    function setMinAmountToSwapForWallet1(uint256 value) external onlyOwner() {
        minAmountToSwapForWallet1 = value;
    }

    function addBlackList(address account, bool flag) external onlyOwner() {
        isBlackList[account] = flag;
    }

    function setExemptFee(address account, bool flag) external onlyOwner() {
        exemptFee[account] = flag;
    }

    function setNewWallet1(address account) external onlyOwner() {
        wallet1 = account;
    }

    function setNewWallet2(address account) external onlyOwner() {
        wallet2 = account;
    }

    function setNewWallet3(address account) external onlyOwner() {
        wallet3 = account;
    }

    function setBuyFeeToWallet1(uint256 value) external onlyOwner() {
        buyFeeToWallet1 = value;
    }

    function setBuyFeeToWallet2(uint256 value) external onlyOwner() {
        buyFeeToWallet2 = value;
    }

    function setBuyFeeToWallet3(uint256 value) external onlyOwner() {
        buyFeeToWallet3 = value;
    }

    function setBnbTokenPrice(uint256 value) external onlyOwner() {
        bnbTokenPrice = value;
    }

    function setSellFeeToWallet1(uint256 value) external onlyOwner() {
        sellFeeToWallet1 = value;
    }

    function setSellFeeToWallet2(uint256 value) external onlyOwner() {
        sellFeeToWallet2 = value;
    }

    function setSellFeeToWallet3(uint256 value) external onlyOwner() {
        sellFeeToWallet3 = value;
    }

    function setBatchExemptFee(address [] memory addr, bool enable) external onlyOwner() {
        for (uint i = 0; i < addr.length; i++) {
            exemptFee[addr[i]] = enable;
        }
    }

    function setAirdropAmount(uint256 airdropAmount) external onlyOwner() {
        _airdropAmount = airdropAmount;
    }

    
    function setAirdropNum(uint256 airdropNum) external onlyOwner() {
        _airdropNum = airdropNum;
    }

    function setStopTransfer(bool flag) external onlyOwner() {
          stopTransfer = flag;
    }
}