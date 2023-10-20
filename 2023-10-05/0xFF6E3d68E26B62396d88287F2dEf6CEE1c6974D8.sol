// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath library to prevent overflow and underflow
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

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}

// ERC20 interface for token operations
interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
}

// Ownable contract for ownership control
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// Lottery contract
contract Lottery is Ownable {
    using SafeMath for uint256;

    // Token contract addresses
    address public token1;
    address public token2;
    address public token3;
    address public token4;
    address public token5;
    uint256 public ticketPrice;

    event TicketPurchased(address indexed buyer, address indexed tokenReceived);
    event TicketPriceChanged(uint256 newPrice);
    event TokenSelected(address indexed tokenSelected);

    constructor(
        address _token1,
        address _token2,
        address _token3,
        address _token4,
        address _token5,
        uint256 _initialTicketPrice
    ) {
        token1 = _token1;
        token2 = _token2;
        token3 = _token3;
        token4 = _token4;
        token5 = _token5;
        ticketPrice = _initialTicketPrice;
    }

    function purchaseTicket() external {
        require(
            ERC20(token5).balanceOf(msg.sender) >= ticketPrice,
            "Insufficient funds"
        );

        uint256 randomNumber = _generateRandomNumber();
        address selectedToken = _selectToken(randomNumber);

        ERC20(token5).transferFrom(msg.sender, address(this), ticketPrice);
        ERC20(selectedToken).transfer(msg.sender, ticketPrice);

        emit TicketPurchased(msg.sender, selectedToken);
    }

    function setTicketPrice(uint256 _newTicketPrice) external onlyOwner {
        ticketPrice = _newTicketPrice;
        emit TicketPriceChanged(_newTicketPrice);
    }

    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.difficulty, msg.sender)));
    }

    function _selectToken(uint256 randomNumber) internal view returns (address) {
        uint256 index = randomNumber % 4;  // 0-3
        if (index == 0) {
            return token1;
        } else if (index == 1) {
            return token2;
        } else if (index == 2) {
            return token3;
        } else {
            return token4;
        }
    }
}