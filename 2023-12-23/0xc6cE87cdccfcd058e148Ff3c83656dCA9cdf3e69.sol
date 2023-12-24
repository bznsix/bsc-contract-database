// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure returns (bytes calldata) {
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ITRC20Metadata is IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

contract ALBETROS is Context, IBEP20, ITRC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address[] private tokenHolders; // Maintain a list of token holders

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private constant MAX_SUPPLY = 100000000000 * 10**18; // 1000 crores
    uint256 private constant BURN_RATE = 1; // 0.1%
    uint256 private constant MINT_THRESHOLD = 1000 * 10**18; // Mint when total supply reaches 1000 crores
    uint256 private constant MINT_AMOUNT = 100 * 10**18; // 100 cores

    constructor() {
        _name = "ALBETROS";
        _symbol = "ARS";
        _decimals = 18;
        _mint(msg.sender, 100000000000 * 10**18);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

 function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    // Calculate burn amount (0.1% of the transfer amount)
    uint256 burnAmount = (amount * BURN_RATE) / 1000;
   

    // Perform the burn
    _burn(_msgSender(), burnAmount);

    // Transfer the remaining amount to the recipient
    _transfer(_msgSender(), recipient, amount - burnAmount);

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
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }

    function burn(address account, uint256 value) public onlyOwner {
        _burn(account, value);
    }


    function mintAndDistribute() external onlyOwner {

        // Burning condition
        if (_totalSupply < MAX_SUPPLY) {
            uint256 burnAmount = (_totalSupply * BURN_RATE) / 100;
            _burn(address(0), burnAmount);
        }

        // Mint condition
        if (_totalSupply >= MINT_THRESHOLD) {
            _mint(address(this), MINT_AMOUNT);

            // Distribute 10% of the minted tokens to all token holders
            uint256 totalHolders = _getTotalHoldersCount();

            // Distribute to each holder
            for (uint256 i = 0; i < totalHolders; i++) {
                address holder = _getTokenHolderAtIndex(i);
                uint256 holderBalance = balanceOf(holder);
                uint256 distributeAmount = (holderBalance * 10) / 100;
                if (distributeAmount > 0) {
                    _transfer(address(this), holder, distributeAmount);
                }
            }
        }
    }

    // Manual burning function for the owner
    function manualBurn(uint256 amount) external onlyOwner {
        // Ensure that the manual burn amount is within limits
        require(amount > 0, "BEP20: burn amount must be greater than zero");
        require(_totalSupply + amount <= MAX_SUPPLY, "BEP20: total supply exceeds limit");

        // Perform the manual burn
        _burn(address(0), amount);
    }

    // Additional function to get the list of all token holders
    function getTokenHolders() external view onlyOwner returns (address[] memory) {
        return tokenHolders;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        // Maintain a list of token holders
        if (_balances[account] > 0 && account != address(this) && account != owner()) {
            tokenHolders.push(account);
        }

        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address /*from*/,
        address /*to*/,
        uint256 /*amount*/
    ) internal virtual {}

    function _afterTokenTransfer(
        address /*from*/,
        address /*to*/,
        uint256 /*amount*/
    ) internal virtual {}

    function _getTokenHolderAtIndex(uint256 index) internal view returns (address) {
        require(index < _getTotalHoldersCount(), "ALBETROS: index out of range");
        return tokenHolders[index];
    }

    function _getTotalHoldersCount() internal view returns (uint256) {
        return tokenHolders.length;
    }
}