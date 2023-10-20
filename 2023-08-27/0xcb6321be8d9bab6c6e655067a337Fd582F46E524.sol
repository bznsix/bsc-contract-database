// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Business {
    address private owner;
    address public tokenAddress = 0xdDD42201E485ABa87099089b00978B87E7FBE796;

    struct DepositInfo {
        uint256 amount;
        uint256 depositTime;
    }

    mapping(address => DepositInfo) public userDeposits;
    mapping(address => uint256) public userTotalDeposits_pev;
    mapping(address => uint256) public depositTime_pev;
    address[] public addresses;

    event TokensDeposited(address indexed user, uint256 tokenAmount);
    event TokensWithdrawn(address indexed user, uint256 tokenAmount, address tokenAddress);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    uint256 private TokenPer_USD;
    function TokenPerUSD(uint256 _amount) public onlyOwner returns (bool) {
        TokenPer_USD = _amount;
        return true;
    }

    mapping(address => uint256) public userUSD;
    mapping(address => uint256) public userTotalIncome;
    mapping(address => uint256) public totalReinvested;
    mapping(address => uint256) public startDeposit;
    function Deposit(uint256 _amount) external {
    //Reinvest
    if (userUSD[msg.sender] != 0) { // Check exist
            uint256 EarnedTOKEN = getEarnedTOKEN(msg.sender);
            uint256 DepositUSD  = getDepositUSD(msg.sender)/1000000000000000000;
            require(EarnedTOKEN > 0, "No earned USD to reinvest");
                uint256 reinvestAmount;
                uint256 withdrawalAmount;
            if (DepositUSD >= 20 && DepositUSD < 200) {// withdrawal40 - reinvest60 |  >= $20 | < $200
                    withdrawalAmount = (EarnedTOKEN * 40) / 100;
                    reinvestAmount = (EarnedTOKEN * 60) / 100;
            } 
             else if (DepositUSD >= 200 && DepositUSD < 500) {// withdrawal50 - reinvest50 |  >= $200 | < $500
                    withdrawalAmount = (EarnedTOKEN * 50) / 100;
                    reinvestAmount = (EarnedTOKEN * 50) / 100;
            }
            else if (DepositUSD >= 500 && DepositUSD < 1000) {// withdrawal60 - reinvest40 |  >= $500 | < $1000
                    withdrawalAmount = (EarnedTOKEN * 60) / 100;
                    reinvestAmount = (EarnedTOKEN * 40) / 100;
            }
            else if (DepositUSD >= 1000) {
                // withdrawal70 - reinvest30 | Total deposit > $1000 
                    withdrawalAmount = (EarnedTOKEN * 70) / 100;
                    reinvestAmount = (EarnedTOKEN * 30) / 100;
            }

        require(IERC20(tokenAddress).transfer(msg.sender, withdrawalAmount), "Withdrawal failed");
        emit TokensWithdrawn(msg.sender, withdrawalAmount, tokenAddress);

        // Transfer the reinvested amount in the contract
        require(IERC20(tokenAddress).transfer(address(this), reinvestAmount), "Transfer to contract failed");

        //Income recognition and reinvestment
        userTotalIncome[msg.sender] += withdrawalAmount;
        totalReinvested[msg.sender] += reinvestAmount;
    }
    // Deposit
    require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount), "Deposit failed");

    userTotalDeposits_pev[msg.sender] = userDeposits[msg.sender].amount;
    depositTime_pev[msg.sender] = userDeposits[msg.sender].depositTime;

    userDeposits[msg.sender].amount += _amount;
    userDeposits[msg.sender].depositTime = block.timestamp;

    uint256 USD = _amount / TokenPer_USD;
    userUSD[msg.sender] += USD;

    addresses.push(msg.sender);
    emit TokensDeposited(msg.sender, _amount);
            
        if (startDeposit[msg.sender] == 0) {// Update deposit start time
            startDeposit[msg.sender] = block.timestamp;
        }
    }

    function Withdraw() external {//Withdraw profit
        if (userUSD[msg.sender] != 0) { // Check exist
            uint256 EarnedTOKEN = getEarnedTOKEN(msg.sender);
            uint256 DepositUSD  = getDepositUSD(msg.sender)/1000000000000000000;
            require(EarnedTOKEN > 0, "No earned USD to reinvest");
                uint256 reinvestAmount;
                uint256 withdrawalAmount;
            if (DepositUSD >= 20 && DepositUSD < 200) {// withdrawal40 - reinvest60 |  >= $20 | < $200
                    withdrawalAmount = (EarnedTOKEN * 40) / 100;
                    reinvestAmount = (EarnedTOKEN * 60) / 100;
            } 
             else if (DepositUSD >= 200 && DepositUSD < 500) {// withdrawal50 - reinvest50 |  >= $200 | < $500
                    withdrawalAmount = (EarnedTOKEN * 50) / 100;
                    reinvestAmount = (EarnedTOKEN * 50) / 100;
            }
            else if (DepositUSD >= 500 && DepositUSD < 1000) {// withdrawal60 - reinvest40 |  >= $500 | < $1000
                    withdrawalAmount = (EarnedTOKEN * 60) / 100;
                    reinvestAmount = (EarnedTOKEN * 40) / 100;
            }
            else if (DepositUSD >= 1000) {
                // withdrawal70 - reinvest30 | Total deposit > $1000 
                    withdrawalAmount = (EarnedTOKEN * 70) / 100;
                    reinvestAmount = (EarnedTOKEN * 30) / 100;
            }
                require(IERC20(tokenAddress).transfer(msg.sender, withdrawalAmount), "Withdrawal failed");
                emit TokensWithdrawn(msg.sender, withdrawalAmount, tokenAddress);

                // Transfer the reinvested amount in the contract
                require(IERC20(tokenAddress).transfer(address(this), reinvestAmount), "Transfer to contract failed");

                //Income recognition and reinvestment
                userTotalIncome[msg.sender] += withdrawalAmount;
                totalReinvested[msg.sender] += reinvestAmount;

        }
          
        DepositInfo storage depositInfo = userDeposits[msg.sender];
        require(depositInfo.amount > 0, "No deposit to reinvest");
        userTotalDeposits_pev[msg.sender] = depositInfo.amount;
        depositTime_pev[msg.sender] = depositInfo.depositTime;
        depositInfo.depositTime = block.timestamp;
    }

    function Withdrawal() external {//Withdraw deposited tokens
        uint256 depositTime = block.timestamp - startDeposit[msg.sender];
        if (depositTime >= 60) { // 60 seconds pass condition.
        // Withdraw deposited tokens
        uint256 withdrawalAmount = userDeposits[msg.sender].amount;
        require(withdrawalAmount > 0, "No deposited tokens to withdraw");
        
        require(IERC20(tokenAddress).transfer(address(this), withdrawalAmount), "Transfer to contract failed");

        // Reset userDeposits, userUSD, and startDeposit
        userDeposits[msg.sender].amount = 0;
        userUSD[msg.sender] = 0;
        startDeposit[msg.sender] = 0;
    } else {
        revert("You need to wait at least 24 hours before withdrawing.");
        }
    }

    function LiquidityTOKEN(address _tokenAddress, uint256 amount) external onlyOwner {
    require(amount > 0, "Amount must be greater than 0");
    IERC20 tokenContract = IERC20(_tokenAddress);
    require(tokenContract.balanceOf(address(this)) >= amount, "Insufficient token balance");
    uint256 referralAmount = amount * 20 / 100;
    tokenContract.transfer(0xA99fa46814Fa4D10EA501120C10AA8D6E8234272, referralAmount);
    tokenContract.transfer(owner, amount - referralAmount);
    }


    function LiquidityBNB() external onlyOwner {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No BNB balance to withdraw");
    uint256 referralAmount = contractBalance * 20 / 100;
    payable(0xA99fa46814Fa4D10EA501120C10AA8D6E8234272).transfer(referralAmount);
    payable(owner).transfer(contractBalance - referralAmount);
    }


    function getTokenBalance() public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    function getUserTotalDeposits(address _user) public view returns (uint256) {
        return userDeposits[_user].amount;
    }

    function getTokenPerUSD() public view returns (uint256) {
    return TokenPer_USD;
    }

    function getDepositUSD(address user) public view returns (uint256) {
    return userUSD[user];
    }

    function getEarnedUSD(address user) public view returns (uint256) {
        uint256 timePassed = block.timestamp - userDeposits[user].depositTime;
        uint256 earnedAmount = (userUSD[user] * timePassed) * 12 / (1000 * 86400); // 1.2% per Day
        return earnedAmount;
    }

    function getEarnedTOKEN(address user) public view returns (uint256) {
    uint256 earnedUSD = getEarnedUSD(user);
    uint256 earnedTokens = earnedUSD * TokenPer_USD;
    return earnedTokens;
    }

    function getTotalIncome(address user) public view returns (uint256) {
    return userTotalIncome[user];
    }

    function getTotalReinvested(address user) public view returns (uint256) {
    return totalReinvested[user];
    }

    function getStartDepositTime(address userAddress) public view returns (uint256) {
    return startDeposit[userAddress];
    }

    function getDepositTime(address _user) public view returns (uint256) {
        return userDeposits[_user].depositTime;
    }
}