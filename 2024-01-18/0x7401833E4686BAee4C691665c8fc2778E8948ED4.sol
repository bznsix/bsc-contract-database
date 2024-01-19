// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IBEP20Metadata is IBEP20 {
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


abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IBEP20Errors {
    error BEP20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error BEP20InvalidSender(address sender);
    error BEP20InvalidReceiver(address receiver);
    error BEP20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error BEP20InvalidApprover(address approver);
    error BEP20InvalidSpender(address spender);
}

interface IBEP721Errors {
    error BEP721InvalidOwner(address owner);
    error BEP721NonexistentToken(uint256 tokenId);
    error BEP721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error BEP721InvalidSender(address sender);
    error BEP721InvalidReceiver(address receiver);
    error BEP721InsufficientApproval(address operator, uint256 tokenId);
    error BEP721InvalidApprover(address approver);
    error BEP721InvalidOperator(address operator);
}


interface IBEP1155Errors {
    error BEP1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error BEP1155InvalidSender(address sender);
    error BEP1155InvalidReceiver(address receiver);
    error BEP1155MissingApprovalForAll(address operator, address owner);
    error BEP1155InvalidApprover(address approver);
    error BEP1155InvalidOperator(address operator);
    error BEP1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}


abstract contract BEP20 is Context, IBEP20, IBEP20Metadata, IBEP20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return 18;
    }

 
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }


    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }


    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }


    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            revert BEP20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert BEP20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }


    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert BEP20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

   
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert BEP20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal virtual {
        if (account == address(0)) {
            revert BEP20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }


    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert BEP20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert BEP20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }


    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert BEP20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}


abstract contract BEP20Burnable is Context, BEP20 {

    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }

    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}


contract Pulimoon is BEP20Burnable, Ownable {
    uint256 public burnFee = 2;
    uint256 public maxWallet;
    uint256 tSupply = 10000000000e18;

    uint256 public startBlock;
    uint256 public constant blocksUntilTradingEnabled = 70;

    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(address => bool) private _isExcludedFromBurnFee;

    constructor(address initialOwner)
        BEP20("Pulimoon", "PULL")
        Ownable(initialOwner)
    {
        maxWallet = (tSupply * 5) / 100;
        _mint(initialOwner, tSupply);
        _isExcludedFromMaxWallet[initialOwner] = true;
        _isExcludedFromBurnFee[initialOwner] = true;
    }

    function startTrade() external onlyOwner {
        require(startBlock == 0, "Trading already started");
        startBlock = block.number;
    }

    function setBurnFee(uint256 _burnFee) external onlyOwner {
        require(_burnFee <= 5, "Burn fee can't exceed 5%");
        burnFee = _burnFee;
    }

    function setMaxWalletPercent(uint256 _maxWalletPercent) external onlyOwner {
        require(_maxWalletPercent <= 30, "Max wallet percent can't exceed 30%");
        require(_maxWalletPercent >= 1, "Max wallet percentage cannot be lower than 1%");
        maxWallet = (totalSupply() * _maxWalletPercent) / 100;
    }

    function excludeFromMaxWallet(address account) external onlyOwner {
        _isExcludedFromMaxWallet[account] = true;
    }

    function includeInMaxWallet(address account) external onlyOwner {
        _isExcludedFromMaxWallet[account] = false;
    }

     function excludeFromBurnFee(address account) external onlyOwner {
        _isExcludedFromBurnFee[account] = true;
    }

    function includeInBurnFee(address account) external onlyOwner {
        _isExcludedFromBurnFee[account] = false;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(block.number >= startBlock + blocksUntilTradingEnabled, "Bot Mode");
        require(balanceOf(recipient) + amount <= maxWallet || _isExcludedFromMaxWallet[recipient], "Max wallet size exceeded");

        uint256 burntAmount = (amount * burnFee) / 100;

        if (burntAmount > 0) {
            super._burn(sender, burntAmount);
            amount -= burntAmount;
        }

        super._transfer(sender, recipient, amount);
    }
}