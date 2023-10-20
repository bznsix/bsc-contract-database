// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes calldata data) external;
}

contract BX2 is ERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    string public constant name  = "Blue X 2.0";
    string public constant symbol = "BX2";
    uint8 public constant decimals = 18;
    address public deployer;
    address public admin;
    address public feeReceiver;
    uint256 private _totalSupply = 100000 * 10**18;
    uint256 public feePercentage = 3; // 3% fee

    constructor() {
        deployer = msg.sender;
        admin = deployer;
        feeReceiver = admin;
        balances[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address addr) public view override returns (uint256) {
        return balances[addr];
    }

    function allowance(address addr, address spender) public view override returns (uint256) {
        return allowed[addr][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(value <= balances[msg.sender]);
        require(to != address(0));

        uint256 feeAmount;
        uint256 netAmount;

        // Check if sender or receiver is admin and apply no fee if true
        if (msg.sender == admin || to == admin) {
            feeAmount = 0;
            netAmount = value;
        } else {
            feeAmount = value.mul(feePercentage).div(100);
            netAmount = value.sub(feeAmount);
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(netAmount);
        if (feeAmount > 0) {
            balances[feeReceiver] = balances[feeReceiver].add(feeAmount);
            emit Transfer(msg.sender, feeReceiver, feeAmount);
        }

        emit Transfer(msg.sender, to, netAmount);
        return true;
    }

    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
        require(receivers.length == amounts.length, "Array length mismatch");
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], amounts[i]);
        }
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        require(to != address(0));

        uint256 feeAmount;
        uint256 netAmount;

        // Check if sender or receiver is admin and apply no fee if true
        if (from == admin || to == admin) {
            feeAmount = 0;
            netAmount = value;
        } else {
            feeAmount = value.mul(feePercentage).div(100);
            netAmount = value.sub(feeAmount);
        }

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(netAmount);
        if (feeAmount > 0) {
            balances[feeReceiver] = balances[feeReceiver].add(feeAmount);
            emit Transfer(from, feeReceiver, feeAmount);
        }

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, netAmount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function setFeeReceiver(address newFeeReceiver) public {
        require(msg.sender == admin, "Only admin can change the fee receiver");
        feeReceiver = newFeeReceiver;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == deployer, "Only the deployer can transfer ownership");
        require(newOwner != address(0), "Invalid new owner address");
        deployer = newOwner;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}