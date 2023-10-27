// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.9;

contract Web3DAO {
    function stringCompare(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    event SafeTransferEvent(address indexed previousSafe, address indexed newSafe);
    event SetManagerEvent(address indexed previousManager, address indexed newManager);
    event EnrollEvent(address indexed userAddress, address indexed uplineAddress);
    event InvestEvent(address indexed userAddress, uint256 amount, uint256 rate, uint256 convertedAmount);
    event Web3AIEvent(address indexed toAddress, uint256 amount, uint256 percentage);
    event PayoutEvent(address indexed toAddress, uint256 amount, uint status);
    event SafeTransferCoinEvent(address indexed toAddress, uint256 amount, uint status);
    event Web3AIAddrEvent(address indexed fromAddress, address indexed toAddress, uint oldPercent, uint newPercent);
    event ChangePcpPoolDurationEvent(uint oldDuration, uint newDuration);

    struct User {
        uint id;
        address addr;
        uint uplineID;
    }

    struct TreeSponsor {
        uint userID;
        uint uplineID;
        uint level;
    }

    struct UserPortfolio {
        uint id;
        uint userID;
        uint256 amount;
        uint256 rate;
    }

    address private owner;
    address private manager;
    address private web3AIAddr;

    mapping (uint => User) private userAry;
    mapping (address => uint) private addressIDAry;
    mapping (uint => TreeSponsor) private treeSponsorAry;
    mapping (uint => UserPortfolio) private portfolioAry;
    mapping (uint => uint[]) private userPortfolioAry;

    uint private userID;
    uint private portfolioID;
    uint private pcpPoolEndTime;
    uint private pcpPoolDuration;
    uint256 private web3AIPercent;
    uint256 private diffPercent;
    uint256 private maxAmount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Not manager");
        _;
    }

    modifier onlyOwnerOrManager() {
        require((msg.sender == owner) || (msg.sender == manager), "Only for owner or manager");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        manager = payable(msg.sender);
        web3AIAddr = 0x2FB8395f1beFb63F65d8F2932EeB5774009576F7;
        userID = 1000000;
        portfolioID = 1000000;
        pcpPoolDuration = 24 hours;
        web3AIPercent = (0.15 * 1 ether);
        diffPercent = (0.01 * 1 ether);
        maxAmount = (50 * 1 ether);

        User memory userData = User({
            id: userID,
            addr: owner,
            uplineID: 0
        });

        userAry[userID] = userData;
        addressIDAry[owner] = userID;

        TreeSponsor memory treeSponsorData = TreeSponsor({
            userID: userID,
            uplineID: 0,
            level: 0
        });

        treeSponsorAry[userID] = treeSponsorData;

        userID++;
    }

    function safeTransfer(address _safe) public onlyOwner {
        address oldSafe = owner;
        owner = _safe;
        emit SafeTransferEvent(oldSafe, _safe);
    }

    function setManager(address _manager) public onlyOwnerOrManager {
        address oldManager = manager;
        manager = _manager;
        emit SetManagerEvent(oldManager, _manager);
    }

    function checkUpline(address uplineAddress) public view returns (bool) {
        uint uplineID = addressIDAry[uplineAddress];

        if (uplineID == 0) {
            return false;
        }

        return true;
    }

    function enroll(address uplineAddress) public {
        uint uplineID = addressIDAry[uplineAddress];
        uint uplineLevel = treeSponsorAry[uplineID].level;

        require(addressIDAry[msg.sender] == 0, "User existed");
        require(uplineID != 0, "Upline not exist");
        require(msg.sender != uplineAddress, "Upline cannot be self");

        User memory userData = User({
            id: userID,
            addr: msg.sender,
            uplineID: uplineID
        });

        userAry[userID] = userData;
        addressIDAry[msg.sender] = userID;

        TreeSponsor memory treeSponsorData = TreeSponsor({
            userID: userID,
            uplineID: uplineID,
            level: (uplineLevel + 1)
        });

        treeSponsorAry[userID] = treeSponsorData;

        emit EnrollEvent(msg.sender, uplineAddress);

        userID++;
    }

    function invest(uint256 amount, uint256 rate) public payable {
        uint _userID = addressIDAry[msg.sender];
        uint256 reentryAmount = msg.value;

        require(_userID != 0, "User not exist");

        uint256 calAmount = ((reentryAmount * rate) / 1 ether);
        uint256 diffAmount = ((amount * diffPercent) / 1 ether);
        require((calAmount >= (amount - diffAmount) && calAmount <= (amount + diffAmount)), "The rate is invalid");

        UserPortfolio memory userPortfolioData = UserPortfolio({
            id: portfolioID,
            userID: _userID,
            amount: amount,
            rate: rate
        });

        portfolioAry[portfolioID] = userPortfolioData;
        userPortfolioAry[_userID].push(portfolioID);

        emit InvestEvent(msg.sender, amount, rate, reentryAmount);

        uint256 web3AIAmount = (amount * web3AIPercent);
        uint256 web3AIValue = (web3AIAmount / rate);
        payable(web3AIAddr).transfer(web3AIValue);

        emit Web3AIEvent(web3AIAddr, web3AIValue, web3AIPercent);

        pcpPoolEndTime = (block.timestamp + pcpPoolDuration);
    }

    function getPcpPoolEndTime() public view returns (uint) {
        return pcpPoolEndTime;
    }

    function payout(address[] calldata addressAry, uint256[] calldata amountAry) public onlyManager payable {
        require(addressAry.length < 10, "Only 10 addresses at once");

        uint256 balance = address(this).balance;

        for (uint i = 0; i < addressAry.length; i++) {
            address userAddress = addressAry[i];
            uint256 amount = amountAry[i];
            uint _userID = addressIDAry[userAddress];
            uint status = 0;

            if (_userID != 0 && balance > 0) {
                if (amount > maxAmount) {
                    status = 3;
                    emit PayoutEvent(userAddress, amount, status);
                    continue;

                } else if (balance >= amount) {
                    status = 1;
                    
                } else {
                    amount = balance;
                    status = 2;
                }

                balance -= amount;
                payable(userAddress).transfer(amount);
            }
            emit PayoutEvent(userAddress, amount, status);
        }
    }

    function safeTransferCoin(address _address, uint256 _amount) public onlyOwner payable {
        uint256 balance = address(this).balance;
        uint _status = 0;

        if (balance > 0 && balance >= _amount) {
            _status = 1;
            payable(_address).transfer(_amount);
        }
        emit SafeTransferCoinEvent(_address, _amount, _status);
    }
    
    function getManager() public onlyOwnerOrManager view returns (address) {
        return manager;
    }

    function getUser(address _address) public view returns (uint, address, uint) {
        uint _userID = addressIDAry[_address];
        return (userAry[_userID].id, userAry[_userID].addr, userAry[_userID].uplineID);
    }

    function getTreeSponsor(address _address) public view returns (uint, uint, uint) {
        uint _userID = addressIDAry[_address];
        return (treeSponsorAry[_userID].userID, treeSponsorAry[_userID].uplineID, treeSponsorAry[_userID].level);
    }

    function getAllUserPortfolio(address _address) public view returns (uint[] memory) {
        uint _userID = addressIDAry[_address];
        return userPortfolioAry[_userID];
    }

    function getUserPortfolio(uint _portfolioID) public view returns (uint, uint, uint256, uint256) {
        return (portfolioAry[_portfolioID].id, portfolioAry[_portfolioID].userID, portfolioAry[_portfolioID].amount, portfolioAry[_portfolioID].rate);
    }

    function getWeb3AI() public view returns (address, uint256) {
        return (web3AIAddr, web3AIPercent);
    }

    function changeWeb3AI(address _address, uint256 _percentage) public onlyOwner {
        address oldWeb3AIAddr = web3AIAddr;
        uint256 oldWeb3AIPercent = web3AIPercent;
        web3AIAddr = _address;
        web3AIPercent = _percentage;
        emit Web3AIAddrEvent(oldWeb3AIAddr, _address, oldWeb3AIPercent, _percentage);
    }

    function getPcpPoolDuration() public view returns (uint) {
        return pcpPoolDuration;
    }

    function changePcpPoolDuration(uint duration) public onlyManager {
        uint oldDuration = pcpPoolDuration;
        pcpPoolDuration = duration;
        emit ChangePcpPoolDurationEvent(oldDuration, duration);
    }
}