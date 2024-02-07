// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    address public _owner;
    modifier onlyOwner() {
        require(msg.sender == _owner, "only owner can do this!!!");
        _;
    }

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
        return 8;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _owner = account;

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount*(10**uint(decimals()));
        _balances[account] += amount*(10**uint(decimals()));
        emit Transfer(address(0), account, amount*(10**uint(decimals())));

        _afterTokenTransfer(address(0), account, amount);
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

contract Token_ANTBOT is ERC20{
        constructor() ERC20("ANTBOT","ANTBOT"){
        _owner = msg.sender;
        _mint(msg.sender, 1000000000);
        deputy = msg.sender;
    }
    uint256 public sellFees = 5;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public blacklists;
    address public deputy = address(0);
    event ChangeDeputy(address sender, address oldDeputy, address newDeputy);
    event SetAutomatedMarketMakerPair(address pair, bool value);
    event SetBlackList(address user, bool value);
    event SetSellFees(uint256 value);

    struct TransferInfo {
        address to_;
        uint256 count_;
    }
    
    function transfers(TransferInfo[] memory tfis) public {
        for(uint256 i = 0; i < tfis.length; i++) {
            TransferInfo memory tfi = tfis[i];
            super.transfer(tfi.to_, tfi.count_);
        }
    }

    function blacklist(address user, bool value) external {
        require(msg.sender == deputy, "only deputy can do this");  
        blacklists[user] = value;
        emit SetBlackList(user, value);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external {
        require(msg.sender == deputy, "only deputy can do this"); 
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setSellFees(uint256 value) external {
        require(msg.sender == deputy, "only deputy can do this");  
        require(value < 100, "Sell fees must be < 100.");
        sellFees = value;
        emit SetSellFees(value);
    }

    function setDeputy(address deputy_) public onlyOwner{
        address oldDeputy = deputy;
        deputy = deputy_;        
        emit ChangeDeputy(msg.sender, oldDeputy, deputy_);
    }

    function transfer_ownership(address newOwner_) public onlyOwner{
        _owner = newOwner_;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(!blacklists[to] && !blacklists[from], "Blacklisted");
        if (sellFees == 0) {
            super._transfer(from, to, amount);
            return;
        }
        if (automatedMarketMakerPairs[to]) {
            uint256 fees = amount * sellFees / 100;
            if (fees > 0) {
                super._burn(from, fees);
                amount -= fees;
            }            
        }
        super._transfer(from, to, amount);
    }
    
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}