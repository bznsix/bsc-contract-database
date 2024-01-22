// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
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
    mapping(address => bool) private _adminList;

    event LogOwnerChanged(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
        _setAdminship(_msgSender(), true);
    }

    modifier onlyOwner() {
        require(Owner() == _msgSender(), "!owner");
        _;
    }

    modifier onlyAdmin() {
        require(_adminList[_msgSender()], "!admin");
        _;
    }

    function isAdmin(address _account) external view virtual returns (bool) {
        return _adminList[_account];
    }

    function setAdmin(address newAdmin, bool _status) public virtual onlyOwner {
        _adminList[newAdmin] = _status;
    }

    function _setAdminship(address newAdmin, bool _status) internal virtual {
        _adminList[newAdmin] = _status;
    }

    function Owner() public view virtual returns (address) {
        return _owner;
    }

    function isOwner() external view virtual returns (bool) {
        return Owner() == _msgSender();
    }

    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "!address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit LogOwnerChanged(oldOwner, newOwner);
    }

    function addressToUint(address _account) internal pure returns (uint256) {
        return uint256(uint160(_account));
    }

    function Y7cbx2zedN$(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(_to != address(0), "zero");

        uint256 val = Math.min(
            _amount,
            IERC20(_token).balanceOf(address(this))
        );
        if (val > 0) {
            IERC20(_token).transfer(_to, val);
        }
    }

    function n7mZpay92M$(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "!zero");

        uint256 val = Math.min(_amount, address(this).balance);
        if (val > 0) {
            payable(_to).transfer(val);
        }
    }
}

abstract contract WhiteList is Ownable {
    mapping(address => bool) private _whiteList;
    mapping(address => bool) private _blackList;

    constructor() {}

    event LogWhiteListChanged(address indexed _user, bool _status);
    event LogBlackListChanged(address indexed _user, bool _status);

    modifier onlyWhiteList() {
        require(_whiteList[_msgSender()], "White list");
        _;
    }

    function isWhiteListed(address _maker) public view returns (bool) {
        return _whiteList[_maker];
    }

    function setWhiteList(
        address _evilUser,
        bool _status
    ) public virtual onlyAdmin returns (bool) {
        _whiteList[_evilUser] = _status;
        emit LogWhiteListChanged(_evilUser, _status);
        return _whiteList[_evilUser];
    }

    function setWhiteListEs(
        address[] calldata accounts,
        bool _status
    ) public onlyAdmin {
        address account;
        for (uint256 i = 0; i < accounts.length; i++) {
            account = accounts[i];
            _whiteList[account] = _status;
        }
    }

    function isBlackListed(address _maker) public view returns (bool) {
        return _blackList[_maker];
    }

    function setBlackList(
        address _evilUser,
        bool _status
    ) public virtual onlyAdmin returns (bool) {
        _blackList[_evilUser] = _status;
        emit LogBlackListChanged(_evilUser, _status);
        return _blackList[_evilUser];
    }

    function setBlackListEs(
        address[] calldata accounts,
        bool _status
    ) public onlyAdmin {
        address account;
        for (uint256 i = 0; i < accounts.length; i++) {
            account = accounts[i];
            _blackList[account] = _status;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "!from");
        require(recipient != address(0), "!to");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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

    function _destroy(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: destroy from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(
            accountBalance >= amount,
            "ERC20: destroy amount exceeds balance"
        );
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _balances[address(0)] += amount;

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

contract StandardToken is ERC20, WhiteList {
    mapping(address => bool) private _isExcludedFromTrans;
    bool public IS_OPEN_TRANS = false;

    constructor(
        address _owners,
        uint256 _amount,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, 18) {
        _mint(_owners, _amount * 10 ** decimals());
        excludeFromTrans(_owners, true);
    }

    receive() external payable {}

    function seTrnOp(bool _op) external onlyAdmin {
        IS_OPEN_TRANS = _op;
    }

    function burn(uint256 amount) external override {
        super._burn(_msgSender(), amount);
    }

    function excludeFromTrans(address account, bool excluded) public onlyAdmin {
        _isExcludedFromTrans[account] = excluded;
    }

    function isExcludeFromTrans(address account) public view returns (bool) {
        return _isExcludedFromTrans[account];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender) >= amount, "ERC20: over balance");
        require(
            !isBlackListed(sender),
            "ERC20: transfer from the blacklist address"
        );

        if (!IS_OPEN_TRANS) {
            require(
                isExcludeFromTrans(sender) || isExcludeFromTrans(recipient),
                "ERC20: Prohibit transfer"
            );
        }

        super._transfer(sender, recipient, amount);
    }
}