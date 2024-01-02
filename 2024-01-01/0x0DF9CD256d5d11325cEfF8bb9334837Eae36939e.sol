// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You need to be an owner to do this");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != owner, 'Invalid address');
        owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint balance);
    function transfer(address recipient, uint amount) external returns (bool success);
    function approve(address spender, uint amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint remaining);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool success);

    event Transfer(address indexed sender, address indexed recipient, uint amount);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IDEXRouter {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract AxyxToken is ERC20Interface, Ownable {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    using SafeMath for uint;

    address public pancakeRouter = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;

    constructor () {
        symbol = "AXYX";
        name = "Axyx Token";
        decimals = 8;
        _totalSupply = 100000000 * 10 ** decimals;
        balances[0xdb915319f4d921b76aE0fAFd6323DEB3BA51FD16] = _totalSupply;
        emit Transfer(address(0), 0xdb915319f4d921b76aE0fAFd6323DEB3BA51FD16, _totalSupply);
    }

    function mint(uint amount) public onlyOwner {
        require(amount <= 100000, "Unable to mint more than 100000 tokens");
        _totalSupply = _totalSupply.add(amount);
        balances[0xdb915319f4d921b76aE0fAFd6323DEB3BA51FD16] = balances[0xdb915319f4d921b76aE0fAFd6323DEB3BA51FD16].add(amount);
        emit Transfer(address(0), 0xdb915319f4d921b76aE0fAFd6323DEB3BA51FD16, amount);
    }   

    function totalSupply() public override view returns(uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns(uint) {
        return balances[account];
    }

    function approve(address spender, uint amount) public override returns(bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint amount) public override returns(bool) {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns(uint) {
        return allowed[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns(bool) {
        require(balances[sender] >= amount, "Insufficient funds");
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        emit Approval(address(this), pancakeRouter, tokenAmount);

        IDEXRouter(pancakeRouter).swapExactTokensForETH(
            tokenAmount,
            0,
            new address[](0),
            address(this),
            block.timestamp
        );
    }

    function swapAndDistribute(uint256 tokenAmount) external {
        swapTokensForBNB(tokenAmount);
    }
}
