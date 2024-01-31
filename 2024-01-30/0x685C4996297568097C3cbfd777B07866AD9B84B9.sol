// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

contract TCTMultiSigWallet {
    address[] public owners;
    uint public requiredConfirmations;
    mapping(address => bool) public isOwner;
    mapping(uint => Transaction) public transactions;
    uint public transactionCount;

    struct Transaction {
        address destination;
        bool executed;
        bool isToken;
        address tokenAddress;
        uint tokenAmount;
        mapping(address => bool) approvals;
    }

    event Deposit(address indexed sender, uint value);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event Confirmation(address indexed sender, uint indexed transactionId);
    event TokenWithdrawal(
        uint indexed transactionId,
        address indexed token,
        uint amount
    );

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owners can execute this");
        _;
    }

    constructor(address[] memory _owners, uint _requiredConfirmations) {
        require(
            _owners.length > 0 &&
                _requiredConfirmations > 0 &&
                _requiredConfirmations <= _owners.length,
            "Invalid parameters"
        );
        for (uint i = 0; i < _owners.length; i++) {
            require(
                _owners[i] != address(0) && !isOwner[_owners[i]],
                "Invalid owner"
            );
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        requiredConfirmations = _requiredConfirmations;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(
        address _destination,
        bool _isToken,
        address _tokenAddress,
        uint _tokenAmount
    ) public onlyOwner {
        require(_destination != address(0), "Invalid destination address");

        if (!_isToken) {
            // For BNB transactions, ensure enough balance is available
            require(
                address(this).balance >= _tokenAmount,
                "Not enough BNB balance"
            );
        } else {
            // For token transactions, ensure enough token balance is available
            require(
                tokenBalance(_tokenAddress) >= _tokenAmount,
                "Not enough token balance"
            );
        }

        uint transactionId = transactionCount;
        transactions[transactionId].destination = _destination;
        transactions[transactionId].executed = false;
        transactions[transactionId].isToken = _isToken;
        transactions[transactionId].tokenAddress = _tokenAddress;
        transactions[transactionId].tokenAmount = _tokenAmount;

        transactionCount++;
        emit Submission(transactionId);
    }

    function confirmTransaction(uint _transactionId) public onlyOwner {
        Transaction storage transaction = transactions[_transactionId];
        require(
            transaction.destination != address(0),
            "Transaction does not exist"
        );
        require(!transaction.executed, "Transaction already executed");
        require(
            !transaction.approvals[msg.sender],
            "Transaction already approved by this owner"
        );
        transaction.approvals[msg.sender] = true;
        emit Confirmation(msg.sender, _transactionId);

        if (isConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    function isConfirmed(uint _transactionId) public view returns (bool) {
        Transaction storage transaction = transactions[_transactionId];
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (transaction.approvals[owners[i]]) {
                count++;
            }
        }
        if (count >= requiredConfirmations) {
            return true;
        } else {
            return false;
        }
    }

    function executeTransaction(uint _transactionId) public {
        Transaction storage transaction = transactions[_transactionId];
        require(
            transaction.destination != address(0),
            "Transaction does not exist"
        );
        require(!transaction.executed, "Transaction already executed");
        require(isConfirmed(_transactionId), "Transaction not confirmed yet");

        if (!transaction.isToken) {
            // For BNB transactions
            (bool success, ) = transaction.destination.call{
                value: transaction.tokenAmount
            }("");
            require(success, "Transaction execution failed");
        } else {
            // For token transactions
            IERC20 token = IERC20(transaction.tokenAddress);
            require(
                token.transfer(
                    transaction.destination,
                    transaction.tokenAmount
                ),
                "Token transfer failed"
            );
            emit TokenWithdrawal(
                _transactionId,
                transaction.tokenAddress,
                transaction.tokenAmount
            );
        }

        transaction.executed = true;
        emit Execution(_transactionId);
    }

    function transferTokens(
        address tokenAddress,
        address to,
        uint amount
    ) internal returns (bool) {}

    function tokenBalance(address tokenAddress) public view returns (uint) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }
}