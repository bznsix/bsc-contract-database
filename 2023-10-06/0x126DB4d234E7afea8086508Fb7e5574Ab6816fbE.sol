// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }
}

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

contract TokenMarket {
    using SafeMath for uint256;

    address public tokenAddress; // 被挂单的代币合约地址
    address public paymentTokenAddress; // 用于支付的代币合约地址
    address public owner;

    enum OrderType {Buy, Sell}

    struct Order {
        address user;
        OrderType orderType;
        uint256 orderAmount;
        uint256 orderPrice;
    }

    Order[] public orders;
    uint256 public orderCount;

    event OrderPlaced(address indexed user, OrderType orderType, uint256 orderAmount, uint256 orderPrice, uint256 orderId);
    event OrderCancelled(address indexed user, uint256 orderId);
    event TradeExecuted(address indexed buyer, address indexed seller, uint256 orderAmount, uint256 orderPrice, uint256 paymentAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier validOrder(uint256 orderId) {
        require(orderId < orders.length, "Invalid order ID");
        _;
    }

    // Declare cancelOrder here
    function cancelOrder(uint256 orderId) external validOrder(orderId) {
        Order storage order = orders[orderId];
        require(msg.sender == order.user, "Not the order owner");

        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(order.user, order.orderAmount), "Token transfer failed");

        IERC20 paymentToken = IERC20(paymentTokenAddress);
        require(paymentToken.transfer(order.user, calculatePaymentAmount(order)), "Payment token transfer failed");

        emit OrderCancelled(order.user, orderId);

        // Remove the order by replacing it with the last order in the array
        if (orderId != orders.length - 1) {
            orders[orderId] = orders[orders.length - 1];
        }

        orders.pop();
    }

    constructor(address _tokenAddress, address _paymentTokenAddress) {
        tokenAddress = _tokenAddress;
        paymentTokenAddress = _paymentTokenAddress;
        owner = msg.sender;
    }

    function placeOrder(OrderType _orderType, uint256 _orderAmount, uint256 _orderPrice) external {
        require(_orderAmount > 0 && _orderPrice > 0, "Invalid amount or price");

        IERC20 token = IERC20(tokenAddress);
        IERC20 paymentToken = IERC20(paymentTokenAddress);
        uint256 _paymentAmount = _orderAmount * _orderPrice;

        if (_orderType == OrderType.Buy) {
            // For Buy Order, transfer the payment token from the user to the contract
            require(paymentToken.transferFrom(msg.sender, address(this), _paymentAmount), "Payment token transfer failed");
        } else if (_orderType == OrderType.Sell) {
            // For Sell Order, transfer the order token from the user to the contract
            require(token.transferFrom(msg.sender, address(this), _orderAmount), "Token transfer failed");
        }

        Order memory newOrder = Order({
            user: msg.sender,
            orderType: _orderType,
            orderAmount: _orderAmount,
            orderPrice: _orderPrice
        });

        orders.push(newOrder);

        emit OrderPlaced(msg.sender, _orderType, _orderAmount, _orderPrice, orderCount);

        orderCount++;
    }


    function executeTrade(uint256 orderId) external validOrder(orderId) {
        Order storage order = orders[orderId];

        IERC20 token = IERC20(tokenAddress);
        IERC20 paymentToken = IERC20(paymentTokenAddress);

        require(token.transfer(order.user, order.orderAmount), "Token transfer to buyer failed");
        require(paymentToken.transfer(owner, calculatePaymentAmount(order)), "Payment token transfer to seller failed");

        emit TradeExecuted(msg.sender, order.user, order.orderAmount, order.orderPrice, calculatePaymentAmount(order));

        // Remove the order by replacing it with the last order in the array
        if (orderId != orders.length - 1) {
            orders[orderId] = orders[orders.length - 1];
        }

        orders.pop();
    }

    function calculatePaymentAmount(Order storage order) internal view returns (uint256) {
        return order.orderAmount * order.orderPrice;
    }

    function getOrderCount() external view returns (uint256) {
        return orderCount;
    }
}