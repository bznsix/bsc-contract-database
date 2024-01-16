// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IBEP20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
}

contract GlaxyGLXStake {
    address[] private owners;
    IBEP20 public token;
    IBEP20 public usdtToken;
    bool public paused;
    uint256 decimals = 18;
    uint256 decimalFactor = 10**uint256(decimals);
    uint256 public minimumRegisterAmount = 5;

    struct UserInfo {
        bool registered;
    }
    mapping(address => uint256) public withdrawalRequests;
    mapping(address => bool) public withdrawalApprovals;
    mapping(address => uint256) public withdrawalRequestsUSDT;
    mapping(address => bool) public withdrawalApprovalsUSDT;
    mapping(address => uint256) public withdrawalRequestsTOKEN;
    mapping(address => bool) public withdrawalApprovalsTOKEN;
    mapping(address => UserInfo) public users;
    mapping(address => bool) private isOwner;
    mapping(address => bool) public frozenAccount;

            // Event to signal withdrawal request
    event WithdrawalRequested(address indexed requester, uint256 tokenAmount);
    event WithdrawalRequestedUSDT(address indexed requester, uint256 tokenAmount);
    event WithdrawalRequestedTOKEN(address indexed requester, uint256 tokenAmount);
    event FrozenFunds(address target, bool frozen);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

         // Modifier to restrict access to owners only
   modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owner can call this function");
        _;
    }


    constructor(address _tokenAddress, address _usdtTokenAddress , address[] memory _initialOwners) {
        token = IBEP20(_tokenAddress);
        usdtToken = IBEP20(_usdtTokenAddress);
            for (uint256 i = 0; i < _initialOwners.length; i++) {
            address owner = _initialOwners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner");
            owners.push(owner);
            isOwner[owner] = true;
        }
    }



    // Function to transfer ownership
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid new owner address");
        require(!isOwner[_newOwner], "Duplicate owner");

        address previousOwner = msg.sender;
        isOwner[previousOwner] = false;
        owners.push(_newOwner);
        
        isOwner[_newOwner] = true;
     
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function setMinRegistrationFees(uint256 _minimumRegisterAmount) public onlyOwner {
        minimumRegisterAmount = _minimumRegisterAmount;
    }


    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getUSDTBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    function setPause(bool _value) public onlyOwner {
        paused = _value;
    }


    function adminRegister(address adminUsers) external onlyOwner {
            users[adminUsers].registered = true;
    }


    function register(uint256 _registrationAmount) external {
        require(_registrationAmount >= minimumRegisterAmount * decimalFactor, "Minimum Registration amount should be 5$");

        uint256 usdtBalance = usdtToken.balanceOf(msg.sender);
        require(usdtBalance >= _registrationAmount, "Insufficient USDT balance");

        bool tokenTransferSuccess = usdtToken.transferFrom( msg.sender, address(this), _registrationAmount);
        require(tokenTransferSuccess, "Token transfer failed");
        users[msg.sender].registered = true;
    }

// Withdraw for users

     // Function to request a withdrawal
    function requestWithdrawal(uint256 _tokenAmount) external {
        require(!paused, "Withdraw is paused!");
        require(_tokenAmount > 0, "Invalid token amount");
        require(!frozenAccount[msg.sender], "Account has been frozen by the admin");
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        uint256 halfAmount = _tokenAmount / 2 ;
        require(tokenBalance >= halfAmount,"Insufficient token balance in the contract");
        require(usdtBalance >= halfAmount,"Insufficient USDT balance in the contract");
        withdrawalRequests[msg.sender] = _tokenAmount;
        withdrawalApprovals[msg.sender] = true;
        emit WithdrawalRequested(msg.sender, _tokenAmount);
    }


    // Function for admin to approve withdrawal requests
function approveWithdrawal(address _requester) external onlyOwner {
    require(withdrawalRequests[_requester] > 0, "No pending withdrawal request");

    uint256 tokenAmount = withdrawalRequests[_requester];
    uint256 halfTokenAmount = tokenAmount / 2;

    uint256 contractTokenBalance = token.balanceOf(address(this));
    require(contractTokenBalance >= halfTokenAmount, "Insufficient token balance in the contract");
    uint256 contractUsdtTokenBalance = usdtToken.balanceOf(address(this));
    require(contractUsdtTokenBalance >= halfTokenAmount, "Insufficient USDT token balance in the contract");

    bool transferSuccess = token.transfer(_requester, halfTokenAmount);
    require(transferSuccess, "Token transfer failed");
    bool usdtTransferSuccess = usdtToken.transfer(_requester, halfTokenAmount);
    require(usdtTransferSuccess, "USDT token transfer failed");

    withdrawalRequests[_requester] = 0;
    withdrawalApprovals[_requester] = false;
}

    // Withdraw With USDT

         // Function to request a withdrawal
    function requestWithdrawalUSDT(uint256 _tokenAmount) external {
        require(!paused, "Withdraw is paused!");
        require(_tokenAmount > 0, "Invalid token amount");
        require(!frozenAccount[msg.sender], "Account has been frozen by the admin");
        uint256 tokenBalance = usdtToken.balanceOf(address(this));
        require(tokenBalance >= _tokenAmount,"Insufficient token balance in the contract");
        withdrawalRequestsUSDT[msg.sender] = _tokenAmount;
        withdrawalApprovalsUSDT[msg.sender] = true;
        emit WithdrawalRequestedUSDT(msg.sender, _tokenAmount);
    }
     // Function for admin to approve withdrawal requests
    function approveWithdrawalUSDT(address _requester) external onlyOwner {
        require(withdrawalRequestsUSDT[_requester] > 0, "No pending withdrawal request");
        uint256 tokenAmount = withdrawalRequestsUSDT[_requester];
        bool transferSuccess = usdtToken.transfer(_requester, tokenAmount);
        require(transferSuccess, "Token transfer failed");
        withdrawalRequestsUSDT[_requester] = 0;
        withdrawalApprovalsUSDT[_requester] = false;
    }


    // Withdraw With Token

         // Function to request a withdrawal
    function requestWithdrawalTOKEN(uint256 _tokenAmount) external {
        require(!paused, "Withdraw is paused!");
        require(_tokenAmount > 0, "Invalid token amount");
        require(!frozenAccount[msg.sender], "Account has been frozen by the admin");
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance >= _tokenAmount,"Insufficient token balance in the contract");
        withdrawalRequestsTOKEN[msg.sender] = _tokenAmount;
        withdrawalApprovalsTOKEN[msg.sender] = true;
        emit WithdrawalRequestedTOKEN(msg.sender, _tokenAmount);
    }
     // Function for admin to approve withdrawal requests
    function approveWithdrawalTOKEN(address _requester) external onlyOwner {
        require(withdrawalRequestsTOKEN[_requester] > 0, "No pending withdrawal request");
        uint256 tokenAmount = withdrawalRequestsTOKEN[_requester];
        bool transferSuccess = token.transfer(_requester, tokenAmount);
        require(transferSuccess, "Token transfer failed");
        withdrawalRequestsTOKEN[_requester] = 0;
        withdrawalApprovalsTOKEN[_requester] = false;
    } 


// Withdraw for Admin
    function withdrawTokens(uint256 _tokenAmount) external onlyOwner {
        require(_tokenAmount > 0, "Invalid token amount");

        uint256 tokenBalance = token.balanceOf(address(this));
        require(
            tokenBalance >= _tokenAmount,
            "Insufficient token balance in the contract"
        );

        bool transferSuccess = token.transfer(msg.sender, _tokenAmount);
        require(transferSuccess, "Token transfer failed");
    }

    function withdrawUSDT(uint256 _usdtAmount) external onlyOwner {
        require(_usdtAmount > 0, "Invalid USDT amount");

        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        require(
            usdtBalance >= _usdtAmount,
            "Insufficient USDT balance in the contract"
        );

        bool transferSuccess = usdtToken.transfer(msg.sender, _usdtAmount);
        require(transferSuccess, "USDT transfer failed");
    }

    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
}