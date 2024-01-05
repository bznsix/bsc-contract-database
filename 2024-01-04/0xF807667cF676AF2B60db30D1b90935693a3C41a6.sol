// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

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

contract BITSPICE_DEPOSIT_CONTRACT is ReentrancyGuard {
    using SafeMath for uint256;

    address private _owner;
    uint256 public _usdt_to_bts_price;
    IERC20 public btsToken;
    IERC20 public usdtToken;

    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Sender is not the owner.");
        _;
    }

    constructor(IERC20 btsAddress,IERC20 USDTAddress) {
        btsToken = btsAddress;
        usdtToken = USDTAddress;
        _owner = msg.sender;
    }

    receive() external payable {}

    function depositUSDT(uint256 amount) public payable nonReentrant {
        require(amount > 0, "Amount should be greater than 0.");
        require(usdtToken.allowance(msg.sender, address(this)) >= amount, "Allowance: Not enough USDT allowance to spend.");
        usdtToken.transferFrom(msg.sender, address(this), amount);

        uint256 usdts = amount*1000000000000000000;
        uint256 totalBTS = usdts/_usdt_to_bts_price;
        btsToken.transfer(msg.sender, totalBTS);
        emit Deposit(msg.sender, amount);
    }

    function depositBTS(uint256 amount) public payable nonReentrant {
        require(amount > 0, "Amount should be greater than 0.");
        require(btsToken.allowance(msg.sender, address(this)) >= amount, "Allowance: Not enough USDT allowance to spend.");
        btsToken.transferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }

    function withdrawUSDT(address account, uint256 amount) public onlyOwner {
        usdtToken.transfer(account, amount);
        emit Withdraw(account, amount);
    }

    function withdrawBTS(address account, uint256 amount) public onlyOwner {
        btsToken.transfer(account, amount);
        emit Withdraw(account, amount);
    }

    function usdt_to_bts_price(uint256 amount) public onlyOwner {
        _usdt_to_bts_price = amount;
    }

    function changeAdmin(address admin) public onlyOwner {
        _owner = admin;
    }
}