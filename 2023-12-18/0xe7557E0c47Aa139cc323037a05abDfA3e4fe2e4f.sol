/**

 _______                       __                                 __                           
|       \                     |  \                               |  \                          
| $$$$$$$\  ______    ______  | $$   __          ______          | $$____    ______    ______  
| $$__/ $$ /      \  /      \ | $$  /  \ ______ |      \  ______ | $$    \  /      \  /      \ 
| $$    $$|  $$$$$$\|  $$$$$$\| $$_/  $$|      \ \$$$$$$\|      \| $$$$$$$\|  $$$$$$\|  $$$$$$\
| $$$$$$$ | $$    $$| $$    $$| $$   $$  \$$$$$$/      $$ \$$$$$$| $$  | $$| $$  | $$| $$  | $$
| $$      | $$$$$$$$| $$$$$$$$| $$$$$$\        |  $$$$$$$        | $$__/ $$| $$__/ $$| $$__/ $$
| $$       \$$     \ \$$     \| $$  \$$\        \$$    $$        | $$    $$ \$$    $$ \$$    $$
 \$$        \$$$$$$$  \$$$$$$$ \$$   \$$         \$$$$$$$         \$$$$$$$   \$$$$$$   \$$$$$$ 

MEME Season is back baby. LET US MAKE BSC GREAT AGAIN WITH MEMES

🚀 Welcome to Peek-a-Boo, where the crypto experience takes on a whole new level of excitement and engagement! 
Our mission is clear: gather a thriving community of 1 million holders and offer them 
the unique opportunity to claim 10,000 tokens daily by calling 'sayPeekaboo' on the contract, up to 365 days directly from the contract.

twitter: https:twitter.com/peekaboobsc (Anyone can create and take ownership)
Telegram: https://t.me/peekaboobsc (Anyone can create and take ownership)

Tokenomics:

50% - Community rewards to claim daily for 365 days
47% - Initial Liquidity on the DEX
3% - Dev tokens which are time locked for 1 year in a Vault at https://dAppSocial.io

5% Burn tax only DEX Pool

100% of LP will be locked upon launch in a time locked Vault at https://dAppSocial.io. Vault Number : 119

**/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract Peekaboo is Context, IERC20, Ownable {

    string public _name = "Peek-a-boo";
    string public _symbol = "PEEKABOO";
    uint8 public _decimals = 18;
    uint256 private _total = 7_300_000_000_000 * 10**_decimals;
    uint256 public _maxTxAmount = 73_000_000_000 * 10**_decimals;
    mapping (address => uint256) private _owned;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _burnFee = 5;
    address burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public uniswapV2Pair;
    mapping (address => uint256) _claimedAccounts;
    uint256 _dailyClaimAmount = 10_000 * 10**_decimals;
    uint256 _tradingStartTime;
    bool _tradingStarted;

    error AlreadyClaimed();
    error NoMoreClaims();

    constructor() {
        _owned[_msgSender()] = _total;
        
        emit Transfer(address(0), _msgSender(), _total);
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
        return _total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _owned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner()) {
            require(_tradingStarted, "Trading is not started");
        }
        
        bool takeFee = false;
        if (_tradingStarted && (from == uniswapV2Pair || to == uniswapV2Pair)) {
            require(amount <= _maxTxAmount, "Trade amount exceeds the maxTxAmount.");
            takeFee = true;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        _owned[sender] -= amount;

        uint256 fee = takeFee ? amount * _burnFee / (10**2) : 0;
        uint256 transferAmount = amount - fee;

        _owned[recipient] += transferAmount;
        if (fee > 0) {
            _owned[burnAddress] += fee;
             emit Transfer(sender, burnAddress, fee);
        }
        
        emit Transfer(sender, recipient, transferAmount);
    }

    function sayPeekABoo() external {
        uint256 balance = balanceOf(address(this));
        if (balance == 0) revert NoMoreClaims();
        if (_tradingStartTime + 365 days < block.timestamp) {
            _transfer(address(this), burnAddress, balance);
        } else {
            if (_claimedAccounts[msg.sender] + 1 days > block.timestamp) revert AlreadyClaimed();
            _claimedAccounts[msg.sender] = block.timestamp;
            if (balance > _dailyClaimAmount)
                _transfer(address(this), msg.sender, _dailyClaimAmount);
            else 
                _transfer(address(this), msg.sender, balance);
        }
    }

    function startTrading(address pair) public onlyOwner {
        _tradingStarted = true;
        uniswapV2Pair = pair;
        _tradingStartTime = block.timestamp;
    }

    function getMyTimeToClaim() external view returns (uint256) {
        if (_claimedAccounts[msg.sender] + 1 days > block.timestamp)
            return _claimedAccounts[msg.sender] + 1 days - block.timestamp;
        return 0;
    }

}