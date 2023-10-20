// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    address private _owner;

    string private _name;
    string private _symbol;

    uint256[3] private _fees;
    address[3] private _admins;

    mapping(address => bool) private _isExlcudedFromFee;

    constructor(string memory name_, string memory symbol_, uint256 fee1_, uint256 fee2_, uint256 fee3_, address admin1_, address admin2_, address admin3_) {
        _owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _fees[0] = fee1_;
        _fees[1] = fee2_;
        _fees[2] = fee3_;
        _admins[0] = admin1_;
        _admins[1] = admin2_;
        _admins[2] = admin3_;
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function setFees(uint256 fee1, uint256 fee2, uint256 fee3) public returns (bool) {
        require(msg.sender == _owner);
        _fees[0] = fee1;
        _fees[1] = fee2;
        _fees[2] = fee3;
        return true;
    }

    function setAdmins(address admin1, address admin2, address admin3) public returns (bool) {
        require(msg.sender == _owner);
        _admins[0] = admin1;
        _admins[1] = admin2;
        _admins[2] = admin3;
        return true;
    }

    function excludeFromFee(address wallet) public returns (bool) {
        require(msg.sender == _owner);
        _isExlcudedFromFee[wallet] = true;
        return true;
    }

    function includeInFee(address wallet) public returns (bool) {
        require(msg.sender == _owner);
        _isExlcudedFromFee[wallet] = false;
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        if(!_isExlcudedFromFee[to]) {
            uint256 fee1 = amount / 10000 * _fees[0];
            uint256 fee2 = amount / 10000 * _fees[1];
            uint256 fee3 = amount / 10000 * _fees[2];
            _balances[_admins[0]] += fee1;
            _balances[_admins[1]] += fee2;
            _balances[_admins[2]] += fee3;
            amount -= (fee1 + fee2 + fee3);
        }

        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}


pragma solidity ^0.8.4;


contract AZOV is ERC20 {
    constructor(uint256 fee1, uint256 fee2, uint256 fee3, address admin1, address admin2, address admin3) ERC20("AZOV", "AZOV", fee1, fee2, fee3, admin1, admin2, admin3) {
        _mint(msg.sender, 150000000 * 10 ** decimals());
    }
}