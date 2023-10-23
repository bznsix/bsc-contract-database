// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface BEP20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function getOwner() external view returns (address);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract MyToken is BEP20 {
    using SafeMath for uint256;

    address public owner = msg.sender;    
    string public name;
    string public symbol;
    uint8 public _decimals;
    uint public _totalSupply;
    mapping(address => uint256) private _balances;
	
    mapping (address => mapping (address => uint256)) private _allowed;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    constructor(string memory name_in, string memory symbol_in) public {
	    name = name_in;
		symbol = symbol_in;
        _decimals = 9;
        _totalSupply = 1000000 * 10 ** 9;
		_balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address who, address spender) view public override returns (uint256) {
        return _allowed[who][spender];
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
	//2023-10-21，修正v001版本中，transferFrom函数没有对调用者进行控制的漏洞
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
		address spender = msg.sender;
		_spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");        
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 balancecheck = _balances[from];
        require(balancecheck >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = _balances[from]-amount;
        _balances[to] = _balances[to]+amount;
        emit Transfer(from, to, amount); 
    }
	
	function _spendAllowance(address owner_in, address spender_in, uint256 value_in) internal virtual {
        uint256 currentAllowance = allowance(owner_in, spender_in);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value_in) {
                revert ("ERC20: Insufficient Allowance");
            }
            unchecked {
                _approve(owner_in, spender_in, currentAllowance - value_in);
            }
        }
    }
	
	function approve(address spender_in, uint256 value_in) public override returns (bool) {
        address owner_func = msg.sender;
        _approve(owner_func, spender_in, value_in);
        return true;
    }
	
	function _approve(address owner_in, address spender_in, uint256 value_in) internal virtual {
        if (owner_in == address(0)) {
			revert ("ERC20: Invalid Approver");
        }
        if (spender_in == address(0)) {
			revert ("ERC20: Invalid Approver");
        }
        _allowed[owner_in][spender_in] = value_in;
        emit Approval(msg.sender, spender_in, value_in);
    }

}

