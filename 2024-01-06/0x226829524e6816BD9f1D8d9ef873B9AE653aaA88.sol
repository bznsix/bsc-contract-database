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

contract GlaxyWithdraw {
    address[] private owners;
    IBEP20 public token;
    IBEP20 public usdtToken;
    bool public paused;

   
    // Mapping to track withdrawal requests and approvals
    mapping(address => uint256) public withdrawalRequests;
    mapping(address => bool) public withdrawalApprovals;
    mapping(address => bool) private isOwner;
    mapping(address => bool) public frozenAccount;

        // Event to signal withdrawal request
    event WithdrawalRequested(address indexed requester, uint256 tokenAmount);

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


    // Function to get the current owners
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function setPause(bool _value) public onlyOwner {
        paused = _value;
    }

    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getUSDTBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }


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

     // Function to request a withdrawal
    function requestWithdrawal(uint256 _tokenAmount) external {
 
        require(!paused, "Withdraw is paused!");
        require(_tokenAmount > 0, "Invalid token amount");
        require(!frozenAccount[msg.sender], "Account has been frozen by the admin");

        uint256 tokenBalance = token.balanceOf(address(this));
        require(
            tokenBalance >= _tokenAmount,
            "Insufficient token balance in the contract"
        );

        // Mark the withdrawal request and emit an event
        withdrawalRequests[msg.sender] = _tokenAmount;
               // Mark the withdrawal as approved
        withdrawalApprovals[msg.sender] = true;
        emit WithdrawalRequested(msg.sender, _tokenAmount);
    }
     // Function for admin to approve withdrawal requests
    function approveWithdrawal(address _requester) external onlyOwner {
        require(withdrawalRequests[_requester] > 0, "No pending withdrawal request");

        // Proceed with the withdrawal
        uint256 tokenAmount = withdrawalRequests[_requester];
        bool transferSuccess = token.transfer(_requester, tokenAmount);
        require(transferSuccess, "Token transfer failed");

        // Reset the withdrawal request
        withdrawalRequests[_requester] = 0;
        withdrawalApprovals[_requester] = false;
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