// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IUniswapV2Router01 {
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


interface IUniswapV2Router02 is IUniswapV2Router01 {
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


interface IUniswapV2Pair {
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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address public _owner;

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
    event Adipt(address indexed from, uint256 value);
	event Receave(address indexed from, uint256 value);
	event Receiveeveryday(address indexed from, uint256 value);
	event Receivedt(address indexed from, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
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
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
	
	function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

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
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract TokenHelper is Ownable {
    function transferToken(address token, address receiver, uint256 amount) external onlyOwner {
        IERC20(token).transfer(receiver, amount);
    }
}

contract MaskPlus is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
	
	address public FAddress = 0x2eD9a5C8C13b93955103B9a7C167B67Ef4d568a3;
    address public CAddress1 = 0x162e4561C60D7dd2A5BAA833E80aFc6208d0101B;
	address public CAddress2 = 0x162e6dF3B37E8597bf5CB2D8E3b5BF31372cDc10;
	address public CAddress4 = 0x516606d9dc40C205148ce336e2a6CBe6bfc1A7Ea;
	address public CAddress5 = 0xf9d73B5f7B87e159e871E96d10aC3886B0B18641;
	address public CAddress52 = 0xC583437461594F13041Bd121197Fae2439B61999;
	address public getmAddress = 0x34B63b9839b73910752D12F9d4D889A629bc950f;
	address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
	
    uint256 public Fee = 1;
	uint256 public Fee2 = 8;
	uint256 public Daytt = 86400;
	uint256 public Minsa = 2 * 10 ** 18;
	uint256 public usernum=0;
	uint256 public AtAmount;
    uint256 public MaxAtAmount;
	
	struct UserInfo {
        uint256 Allm;
        uint256 Amd;
        uint256 Amt;
        uint256 Amax;
		uint256 Amdt;
        uint256 level;
        uint256 gettime;
		uint256 aditime;
        uint256 rTimes;
        uint256 inviteNumber;
		uint256 inviteNumber2;
		address[] referrals;
    }
    struct Inviter{
        address account;
        uint256 inviteBlockNumber;
        uint256 inviteTimestamp;
    }
	struct Invest{
        uint256 num;
		uint256 num2;
        uint256 investTimestamp;
		uint256 reTime;
		uint256 price;
		bool retrieve ;
    }
	mapping(address => address ) inviter;
    mapping(address => UserInfo) user;
    mapping(address => Inviter[]) memberInviter;
	mapping(address => Invest[]) memberInvest;
	
    bool private swapping;

    TokenHelper public tokenHelper;

    constructor(address tokenOwner) ERC20("MASK PLUS", "MASKS") {
        uint256 totalSupply = 2100000 * (10**18);
		AtAmount = 20 * 10 ** 18;
		MaxAtAmount = 2000 * 10 ** 18;

        _owner = tokenOwner;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		uniswapV2Router = _uniswapV2Router;
        tokenHelper = new TokenHelper();
		
		UserInfo storage user_ = user[tokenOwner];
		user_.level=6;
		user_.Allm=2000;
		inviter[tokenOwner] = tokenOwner;
        _mint(tokenOwner, totalSupply);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) { super._transfer(from, to, 0); return;}
		super._transfer(from, to, amount);
    }


    //#                              Setter                                     #
	function setFAddress(address Address_) public onlyOwner {
        FAddress = Address_;
    }
	function setCAddress1(address Address_) public onlyOwner {
        CAddress1 = Address_;
    }
	function setCAddress2(address Address_) public onlyOwner {
        CAddress2 = Address_;
    }
	function setCAddress4(address Address_) public onlyOwner {
        CAddress4 = Address_;
    }
	function setCAddress5(address Address_) public onlyOwner {
        CAddress5 = Address_;
    }
	function setCAddress52(address Address_) public onlyOwner {
        CAddress52 = Address_;
    }
	function setgetmAddress(address Address_) public onlyOwner {
        getmAddress = Address_;
    }
	
    function setMaxAtAmount(uint256 amount) public onlyOwner {
	    require(amount>0, "ERC20: number error");
        MaxAtAmount = amount;
    }
	function setAtAmount(uint256 amount) public onlyOwner {
	    require(amount>0, "ERC20: number error");
        AtAmount = amount;
    }
	function setMinsa(uint256 a) public onlyOwner {
        Minsa = a;
    }
	function setFee(uint256 a) public onlyOwner {
	    require(a>0, "ERC20: number error");
        Fee = a;
    }
	function setFee2(uint256 a) public onlyOwner {
	    require(a>0, "ERC20: number error");
        Fee2 = a;
    }
	function setDaytt(uint256 a) public onlyOwner {
	    require(a>0, "ERC20: number error");
        Daytt = a;
    }
	
	function mintt(address Address_,uint256 a) public onlyOwner {
	    _mint(Address_, a);
    }
	
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }
	
	function addMemberInviter(address _inviter) public {
        require(!isContract(msg.sender), 'Address: call from contract');
        address parent = inviter[msg.sender];
        if(parent == address(0) && _inviter != msg.sender){
		    usernum=usernum+1;
            
			inviter[msg.sender] = _inviter;
			
            UserInfo storage user1 = user[_inviter];
            require(user1.Allm>0, 'inviter is not exist');
            
			user1.inviteNumber = user1.inviteNumber.add(1);
			
			UserInfo storage user2 = user[msg.sender];
			user2.rTimes = block.timestamp;
			
            Inviter memory invit = Inviter(msg.sender,block.number,block.timestamp);
            addMemberInviter(_inviter,invit);
            
        }
    }

    function addMemberInviter(address _inviter, Inviter memory invit) private {
    if (memberInviter[_inviter].length > 0 && memberInviter[_inviter].length < 100) {
        memberInviter[_inviter].push(invit);
    } else {
        if (memberInviter[_inviter].length >= 100) {
            delete memberInviter[_inviter][0];
            for (uint256 i = 0; i < memberInviter[_inviter].length - 1; i++) {
                memberInviter[_inviter][i] = memberInviter[_inviter][i + 1];
            }
            memberInviter[_inviter].pop();
        }
         memberInviter[_inviter].push(invit);
    }
    }

	function getInviter(address a) public view returns (address){
        return inviter[a];
    }
	
	function adipt(uint256 m) public {
	
	    address parent = inviter[msg.sender];
		address upu = msg.sender;
        UserInfo storage user_ = user[upu];
		require(user_.aditime<block.timestamp-Daytt,"Must be 24 hours apart");
		uint256 mfee=m.mul(Fee).div(100);
		uint256 m2=m.mul(2);
		uint256 m3=m % AtAmount;
        require(m>= AtAmount,"Insufficient Balance");
		require(m>=user_.Amax,"must out last");
		require(m<=MaxAtAmount,"out max");
		require(m3==0,"Insufficient Balance");
		require(IERC20(FAddress).balanceOf(msg.sender)>= m,"Insufficient mask Balance");
		require(user_.rTimes > 0,"user is not exist;");
		require(balanceOf(msg.sender)>= Minsa,"Insufficient Balance");
        require(balanceOf(msg.sender)>= mfee,"Insufficient Balance");
		
        user_.aditime=block.timestamp;
		if(user_.Allm==0)
		{
		    user_.Allm=m;
			user_.Amax=m;
            UserInfo storage user32 = user[parent];
		    user32.inviteNumber2 = user32.inviteNumber2.add(1);
			if(user32.inviteNumber2>=1 && user32.level<1){user32.level=1;}
			if(user32.inviteNumber2>=3 && user32.level<2){user32.level=2;}
			if(user32.inviteNumber2>=5 && user32.level<3){user32.level=3;}
			if(user32.inviteNumber2>=7 && user32.level<4){user32.level=4;}
			if(user32.inviteNumber2>=9 && user32.level<5){user32.level=5;}
			if(user32.inviteNumber2>=11 && user32.level<6){user32.level=6;}
			user32.referrals.push(msg.sender);
		}
		else
		{
		    user_.Allm=user_.Allm+m;
			if(m>user_.Amax){user_.Amax=m;}
		}
		
		address[] memory path = new address[](2);
	    path[0] = FAddress;
		path[1] = busdAddress;
		//path[1] = uniswapV2Router.WETH();
        uint[] memory amount1 = uniswapV2Router.getAmountsOut(1*10**9,path);
        uint256 price=amount1[1];
		
		Invest memory invet = Invest(m,m2,block.timestamp,block.timestamp,price,false);
		memberInvest[msg.sender].push(invet);
		
		_takeMarket1(msg.sender, m); 
		_takeMarket2(msg.sender, m); 
		_takeMarket3(msg.sender, m); 
		_takeMarket4(msg.sender, m); 
		_takeMarket5(msg.sender, m); 
		_takeMarket6(msg.sender, m);
		_takeFee(msg.sender, m);
		_takeInviterFee(msg.sender, m);
		_takeIterationse(msg.sender, m);
        emit Adipt(msg.sender, m);
    }
	
	function Receave5(uint256 i) public {
	    require(i> 0,"is not exist");
		require(balanceOf(msg.sender)>= Minsa,"Insufficient Balance");
	    require(memberInvest[msg.sender][i-1].num> 0,"is not exist");
		require(memberInvest[msg.sender][i-1].retrieve==false,"already receave");
		
		address[] memory path = new address[](2);
	    path[0] = FAddress;
		path[1] = busdAddress;
		//path[1] = uniswapV2Router.WETH();
        uint[] memory amount1 = uniswapV2Router.getAmountsOut(1*10**9,path);
        uint256 price=amount1[1];
		
		uint256 priceo=memberInvest[msg.sender][i-1].price;
		require(price>=priceo.mul(5),"receave fail");
		
		memberInvest[msg.sender][i-1].retrieve=true;
		
		uint256 ramount=memberInvest[msg.sender][i-1].num.mul(20).div(100);
		
		UserInfo storage ruser_ = user[msg.sender];
		if((ruser_.Amd+ruser_.Amt)<ruser_.Allm)
		{
		tokenHelper.transferToken(FAddress, msg.sender, ramount);
		}
		else
		{
		tokenHelper.transferToken(FAddress, address(this), ramount);
		}
		_takeFee(msg.sender,ramount);
        emit Receave(msg.sender, ramount);
    }
	
	function _takeMarket1(address sender, uint256 ddmm) private {
        uint256 Number1=ddmm.mul(15).div(1000);
		IERC20(FAddress).transferFrom(sender,CAddress1,Number1);
    }
	function _takeMarket2(address sender, uint256 ddmm) private {
        uint256 Number2=ddmm.mul(35).div(1000);
		IERC20(FAddress).transferFrom(sender,CAddress2,Number2);
    }
	function _takeMarket3(address sender, uint256 ddmm) private {
        uint256 Number3=ddmm.mul(20).div(100);
		IERC20(FAddress).transferFrom(sender,address(tokenHelper),Number3);
    }
	function _takeMarket4(address sender, uint256 ddmm) private {
        uint256 Number4=ddmm.mul(2).div(100);
		IERC20(FAddress).transferFrom(sender,CAddress4,Number4);
    }
	function _takeMarket5(address sender, uint256 ddmm) private {
        uint256 Number5=ddmm.mul(20).div(1000);
		uint256 Number52=ddmm.mul(10).div(1000);
		IERC20(FAddress).transferFrom(sender,CAddress5,Number5);
		IERC20(FAddress).transferFrom(sender,CAddress52,Number52);
    }
	function _takeMarket6(address sender, uint256 ddmm) private {
        uint256 Number6=ddmm.mul(70).div(100);
		IERC20(FAddress).transferFrom(sender,address(this),Number6);
    }
	function _takeFee(address sender,uint256 tFee) private {
        uint256 Number=tFee.mul(Fee).div(100);
		super._transfer(sender, CAddress4, Number);
    }
	
	function _takeInviterFee(
        address sender, uint256 tAmount
    ) private {
        address cur = sender;
        uint8[15] memory inviteRate = [50, 40, 30, 20, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = deadWallet;
            }
            uint256 curTAmount;
			UserInfo storage fuser_ = user[cur];
			if((i<5 && fuser_.level>=i+1) || (i>=5 && fuser_.level>=6))
			{
			if(tAmount>fuser_.Amax){curTAmount = fuser_.Amax.mul(rate).div(1000);}else{curTAmount = tAmount.mul(rate).div(1000);}
			if(fuser_.Amd.add(curTAmount)>fuser_.Allm.mul(2)){curTAmount =fuser_.Allm.mul(2).sub(fuser_.Amd); }
            if(curTAmount>0)
            {
			    for (uint256 a = 0; a < memberInvest[cur].length; a++) {
                    if(memberInvest[cur][a].num2>0)
					{
					    if(memberInvest[cur][a].num2<curTAmount){curTAmount=memberInvest[cur][a].num2;}
					    memberInvest[cur][a].num2=memberInvest[cur][a].num2-curTAmount;
					    fuser_.Amd = fuser_.Amd+curTAmount;
						fuser_.Amdt = fuser_.Amdt+curTAmount;
						break;
					}
                }
            }
			}
        }
    }
	
	function _takeIterationse(
        address sender, uint256 m
    ) private {
	    UserInfo storage user6_ = user[sender];
        uint256 iterations=0;
		uint256 shareholderCount = user6_.referrals.length;
		if(shareholderCount>10){shareholderCount=10;}
		uint256 fTAmounto=m.mul(3).div(100);
		uint256 fTAmount;
		while (iterations < shareholderCount) 
		{
			uint256 fTAmounto2=fTAmounto;
			address shareHolder = user6_.referrals[iterations];
			UserInfo storage usertop = user[shareHolder];
			if(m>usertop.Amax){fTAmounto2 = usertop.Amax.mul(3).div(100);}
			fTAmount=fTAmounto2 / shareholderCount;
			if(usertop.Amd.add(fTAmount)>usertop.Allm.mul(2)){fTAmount =usertop.Allm.mul(2).sub(usertop.Amd); }
			if(usertop.level<2){fTAmount =0; }
			if(fTAmount>0)
			{
			    for (uint256 i = 0; i < memberInvest[shareHolder].length; i++) {
                    if(memberInvest[shareHolder][i].num2>0)
					{
					    if(memberInvest[shareHolder][i].num2<fTAmount){fTAmount=memberInvest[shareHolder][i].num2;}
					    memberInvest[shareHolder][i].num2=memberInvest[shareHolder][i].num2-fTAmount;
					    usertop.Amd = usertop.Amd+fTAmount;
						usertop.Amdt = usertop.Amdt+fTAmount;
						break;
					}
                }
				
			}
			iterations++;
		}
    }
	
	function receivebyday() public {
	    require(balanceOf(msg.sender)>= Minsa,"Insufficient Balance");
		UserInfo storage usertop = user[msg.sender];
		uint256 getAmount=0;
		for (uint256 i = 0; i < memberInvest[msg.sender].length; i++) {
			if(memberInvest[msg.sender][i].num2>0)
			{
			    uint256 dayTimestamp =(block.timestamp-memberInvest[msg.sender][i].reTime) / Daytt;
			    uint256 fjs = memberInvest[msg.sender][i].num;
				uint256 fTAmount = fjs.mul(Fee2).div(1000);
				fTAmount=fTAmount.mul(dayTimestamp);
				if(memberInvest[msg.sender][i].num2<fTAmount){fTAmount=memberInvest[msg.sender][i].num2;}
				if(fTAmount>0)
				{
				memberInvest[msg.sender][i].num2=memberInvest[msg.sender][i].num2-fTAmount;
				memberInvest[msg.sender][i].reTime=block.timestamp;
				getAmount=getAmount+fTAmount;
				}
			}
		}
		
		if(getAmount>0)
		{
		uint256 mfee=getAmount.mul(Fee).div(100);
		require(balanceOf(msg.sender)>= mfee,"Insufficient Balance");
		usertop.Amt=usertop.Amt+getAmount;
		IERC20(FAddress).transfer(msg.sender,getAmount);
		_takeFee(msg.sender,getAmount);
		}
        emit Receiveeveryday(msg.sender, getAmount);
    }
	
	function getreceivebyday(address _addr) public view returns (uint){
	    require(balanceOf(msg.sender)>= Minsa,"Insufficient Balance");
		uint256 getAmount=0;
		for (uint256 i = 0; i < memberInvest[_addr].length; i++) {
			if(memberInvest[_addr][i].num2>0)
			{
			    uint256 dayTimestamp =(block.timestamp-memberInvest[_addr][i].reTime) / Daytt;
			    uint256 fjs = memberInvest[_addr][i].num;
				uint256 fTAmount = fjs.mul(Fee2).div(1000);
				fTAmount=fTAmount.mul(dayTimestamp);
				if(memberInvest[_addr][i].num2<fTAmount){fTAmount=memberInvest[_addr][i].num2;}
				if(fTAmount>0)
				{
				getAmount=getAmount+fTAmount;
				}
			}
		}
		
		return getAmount;
    }

	function receivebydt() public {
	    require(balanceOf(msg.sender)>= Minsa,"Insufficient Balance");
		UserInfo storage usertop = user[msg.sender];
		uint256 getAmount=usertop.Amdt;
		if(getAmount>0)
		{
		uint256 mfee=getAmount.mul(Fee).div(100);
		require(balanceOf(msg.sender)>= mfee,"Insufficient Balance");
		usertop.Amdt=0;
		IERC20(FAddress).transfer(msg.sender,getAmount);
		_takeFee(msg.sender,getAmount);
		}
        emit Receivedt(msg.sender, getAmount);
    }
	
	function getUserInvests(address a) public view returns (Invest[] memory invit){
        return memberInvest[a];
    }
	
	function getUserInviters(address a) public view returns (Inviter[] memory invit){
        return memberInviter[a];
    }

    function getUser(address a) public view returns(UserInfo memory member){
        return (user[a]);
    }
	
	function getPrice(address _addr) public view returns (uint){
        address[] memory path = new address[](2);
	    path[0] = _addr;
		path[1] = busdAddress;
		//path[1] = uniswapV2Router.WETH();
        uint[] memory amount1 = uniswapV2Router.getAmountsOut(1*10**9,path);
        return amount1[1];
    }
	
	function getmthis2() public
    {
        IERC20 FIST = IERC20(FAddress);
        uint256 amount = FIST.balanceOf(address(tokenHelper));
        if (amount > 0 && msg.sender==getmAddress) {
			tokenHelper.transferToken(FAddress, getmAddress, amount);
        }
    }
}