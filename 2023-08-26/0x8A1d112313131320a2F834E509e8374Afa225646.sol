/**
 * Submitted for verification at BscScan.com on 2021-09-15
 * SPDX-License-Identifier: MIT
 */

pragma solidity ^0.6.9;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

contract InitializableOwnable {
    address public _owner;
    address public _new_owner;
    bool internal _initialized;

    event OwnershipTransferPrepared(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier notInitialized() {
        require(!_initialized, "ALREADY_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "NOT_OWNER");
        _;
    }

    function initOwner(address newOwner) public notInitialized {
        _initialized = true;
        _owner = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_owner, newOwner);
        _new_owner = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _new_owner, "INVALID_CLAIM");
        emit OwnershipTransferred(_owner, _new_owner);
        _owner = _new_owner;
        _new_owner = address(0);
    }
}

contract InitializableMintERC20 is InitializableOwnable {
    using SafeMath for uint256;

    string public name;
    uint256 public decimals;
    string public symbol;
    uint256 public totalSupply;
    uint256 public cap;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Mint(address indexed user, uint256 value);
    event Burn(address indexed user, uint256 value);

    function init(
        address _creator,
        uint256 _initSupply,
        uint256 _cap,
        string memory _name,
        string memory _symbol,
        uint256 _decimals
    ) public {
        initOwner(_creator);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initSupply * 10**_decimals;
        balances[_creator] = totalSupply;
        cap = _cap * 10**_decimals;
        emit Transfer(address(0), _creator, totalSupply);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "TO_ADDRESS_IS_EMPTY");
        require(amount <= balances[msg.sender], "BALANCE_NOT_ENOUGH");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(to != address(0), "TO_ADDRESS_IS_EMPTY");
        require(amount <= balances[from], "BALANCE_NOT_ENOUGH");
        require(amount <= allowed[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");

        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    function mint(address user, uint256 value)
        external
        onlyOwner
        returns (bool)
    {
        if (totalSupply.add(value) <= cap) {
            balances[user] = balances[user].add(value);
            totalSupply = totalSupply.add(value);
            emit Mint(user, value);
            emit Transfer(address(0), user, value);
            return true;
        }
        return false;
    }
}
