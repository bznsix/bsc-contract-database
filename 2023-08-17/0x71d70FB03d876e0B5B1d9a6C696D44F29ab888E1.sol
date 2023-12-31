// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256 theTotalSupply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract PrivateSale {
    struct Users {
        uint256 tokenBuy;
        uint256 purchaseTime;
    }

    address public owner;
    IERC20 public constant USDTADDRESS =
        IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public constant AVENTEXADDRESS =
        IERC20(0x1C2E436DEB728ebb39890A1c205a2f12B124884c);
    // IERC20 public constant USDTADDRESS =
    //     IERC20(0x0cd13d6D5A6A6B44ea9Cf84c3F872E83bE2b644C);
    // IERC20 public constant AVENTEXADDRESS =
    //     IERC20(0x3350049f0889A3A77E69aAcF9Ea96c8D7312f164);

    uint256 public buyPrice;
    uint256 public startTime;
    uint256 public endTime;

    mapping(address => Users) public userPrivateSaleDetails;
    mapping(address => uint256) public numberOfRef;
    mapping(address => uint256) public totalBought;
    mapping(address => bool) public isValidRefAddress;
    mapping(address => bool) public alreadyBoughtToken;

    event Received(address, uint256);
    event TokensBought(address, uint256);
    event OwnershipTransferred(address);
    event SetEndTime(address, uint256);
    event SetStartTime(address, uint256);
    event SetBuyPrice(address, uint256);

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not owner");
        _;
    }

    modifier onlyNewBuyer() {
        require(!alreadyBoughtToken[msg.sender], "user already bought tokens");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setPrivatesaleStartTime(uint256 time) external onlyOwner {
        startTime = block.timestamp + time;
        emit SetStartTime(msg.sender, time);
    }

    function setPrivatesaleEndTime(uint256 time) external onlyOwner {
        endTime = block.timestamp + time;
        emit SetEndTime(msg.sender, time);
    }

    function setBuyUnitPrice(uint256 price) external onlyOwner {
        // must be in INT eg. 0.95 => 95, 1.20 => 120
        buyPrice = price;
        emit SetBuyPrice(msg.sender, price);
    }

    // BUY TOKEN & Referral Reward
    function buyTokenWithUsdt(
        address refAddress,
        uint256 amount
    ) external payable onlyNewBuyer {
        require(
            amount >= 100 ether && amount <= 2500 ether,
            "you can bought min 100 and max 2500 only"
        );
        require(totalBought[msg.sender] <= 2500 ether, "you reached max limit");
        require(buyPrice != 0, "Buy price not set");
        uint256 amountInUsd = (amount * buyPrice) / 100;
        // uint256 tokens = amount;

        require(startTime > 0, "Start time not defined");
        require(block.timestamp > startTime, "Private Sale not started yet");
        require(block.timestamp < endTime, "Private Sale finished or stopped!");

        require(
            AVENTEXADDRESS.balanceOf(address(this)) >= amount,
            "Not enough balance on contract"
        );
        if (!isValidRefAddress[msg.sender]) {
            isValidRefAddress[msg.sender] = true;
        }

        if (isValidRefAddress[refAddress] && refAddress != msg.sender) {
            numberOfRef[refAddress]++;
        }
        alreadyBoughtToken[msg.sender] = true;
        userPrivateSaleDetails[msg.sender] = Users({
            tokenBuy: amount,
            purchaseTime: block.timestamp
        });

        require(
            USDTADDRESS.transferFrom(msg.sender, address(this), amountInUsd),
            "Token transfer to contract failed!"
        );
        require(
            AVENTEXADDRESS.transfer(msg.sender, (amount)),
            "transfer token to user failed!"
        );

        emit TokensBought(msg.sender, (amount));
    }

    // Owner Token Withdraw
    function withdrawTokenUsdt() external onlyOwner {
        require(
            USDTADDRESS.transfer(
                msg.sender,
                USDTADDRESS.balanceOf(address(this))
            ),
            "token withdraw fail!"
        );
    }

    function withdrawTokenAventex() external onlyOwner {
        require(
            AVENTEXADDRESS.transfer(
                msg.sender,
                AVENTEXADDRESS.balanceOf(address(this))
            ),
            "token withdraw fail!"
        );
    }

    // Owner ETH Withdraw
    function withdrawETH() external onlyOwner {
        payable(address(msg.sender)).transfer(address(this).balance);
    }

    // Ownership Transfer
    function transferOwnership(address to) external onlyOwner returns (bool) {
        require(to != address(0), "can't transfer at this address");
        owner = to;
        emit OwnershipTransferred(to);
        return true;
    }

    // Fallback
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
