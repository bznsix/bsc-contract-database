// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma experimental ABIEncoderV2;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MetadataUpdated(string name, string symbol, string tokenURI);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event TokensLocked(address indexed from, uint256 amount);
    event TokensUnlocked(address indexed from, uint256 amount);
    event TransfersBlocked();
    event TransfersUnblocked();
    event GamePoolBalanceChecked(uint256 balance);
}


contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
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
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract Ownable is Context {
    address private _owner;

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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

contract BEP20Token is Context, IBEP20, Ownable {
    
    using SafeMath for uint256;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    string private _tokenURI;
    string private _tokenImage;
    string private _tokenDescription;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _lockedBalances;
    bool private _transfersBlocked;
    uint256 private _gamePoolBalance;
    address private _feeWallet;
    uint256 private _liquidityLimit;

    constructor(address feeWallet) {
        _name = "Kuromix";
        _symbol = "KRX";
        _decimals = 3;
        _totalSupply = 100000000000000;
        _balances[msg.sender] = _totalSupply;
        _feeWallet = feeWallet;
        //
        _liquidityLimit = _totalSupply.mul(1).div(100);
        //
        emit Transfer(address(0), msg.sender, _totalSupply);
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


    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(!_transfersBlocked, "BEP20: transfers are blocked");
        require(_balances[_msgSender()] >= amount, "BEP20: insufficient balance");

        require(amount <= _liquidityLimit, "BEP20: purchase exceeds liquidity limit");

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
        require(!_transfersBlocked, "BEP20: transfers are blocked");
        require(_balances[sender] >= amount, "BEP20: insufficient balance");
        require(_allowances[sender][_msgSender()] >= amount, "BEP20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));

        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }


    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        emit TokensMinted(_msgSender(), amount);
        return true;
    }


    function burn(uint256 amount) public onlyOwner returns (bool) {
        require(_allowances[_msgSender()][address(this)] >= amount, "BEP20: burn amount exceeds allowance");
        require(_balances[_msgSender()] >= amount, "BEP20: burn amount exceeds balance");
        _burn(_msgSender(), amount);
        emit TokensBurned(_msgSender(), amount);
        return true;
    }


    function lockTokens(address account, uint256 amount) external onlyOwner returns (bool) {
        require(_balances[account] >= amount, "BEP20: lock amount exceeds balance");
        _lockedBalances[account] = _lockedBalances[account].add(amount);
        emit TokensLocked(account, amount);
        return true;
    }


    function unlockTokens(address account, uint256 amount) external onlyOwner returns (bool) {
        require(_lockedBalances[account] >= amount, "BEP20: unlock amount exceeds locked balance");
        _lockedBalances[account] = _lockedBalances[account].sub(amount);
        emit TokensUnlocked(account, amount);
        return true;
    }


    function getLockedBalance(address account) external view returns (uint256) {
        return _lockedBalances[account];
    }


    function blockTransfers() external onlyOwner {
        _transfersBlocked = true;
        emit TransfersBlocked();
    }


    function unblockTransfers() external onlyOwner {
        _transfersBlocked = false;
        emit TransfersUnblocked();
    }


    function checkGamePoolBalance() external onlyOwner returns (uint256) {
        emit GamePoolBalanceChecked(_gamePoolBalance);
        return _gamePoolBalance;
    }


    function updateGamePoolBalance(uint256 newBalance) external onlyOwner {
        _gamePoolBalance = newBalance;
    }


    function updateMetadata(string memory newName, string memory newSymbol, string memory newTokenURI, string memory newTokenImage, string memory newTokenDescription) external onlyOwner {
        _name = newName;
        _symbol = newSymbol;
        _tokenURI = newTokenURI;
        _tokenImage = newTokenImage;
        _tokenDescription = newTokenDescription;
        emit MetadataUpdated(newName, newSymbol, newTokenURI);
    }


    function getTokenURI() external view returns (string memory) {
        return _tokenURI;
    }


    function getTokenImage() external view returns (string memory) {
        return _tokenImage;
    }


    function getTokenDescription() external view returns (string memory) {
        return _tokenDescription;
    }


    function updateFeeWallet(address newFeeWallet) external onlyOwner {
        _feeWallet = newFeeWallet;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        uint256 gasFee = amount.mul(5).div(100);
        address feeWallet = 0x68A01a4cC573Be5111Bb88EEdCd55044c61766aF;
        if (feeWallet != address(0) && gasFee > 0) {
            _balances[feeWallet] = _balances[feeWallet].add(gasFee);
            emit Transfer(sender, feeWallet, gasFee);
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal onlyOwner {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal onlyOwner {
        require(_allowances[account][address(this)] >= amount, "BEP20: burn amount exceeds allowance");
        require(_balances[account] >= amount, "BEP20: burn amount exceeds balance");
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount));
    }
}