//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBEP20 {
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {

    address internal _owner;
    address internal _publisher;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPublisher() {
        require(_publisher == _msgSender(), "Ownable: caller is not the publisher");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function changeOwnership(address newOwner) public virtual onlyPublisher {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _publisher = newOwner;
    }    
}

contract GeCoinStaking is Ownable {
    IBEP20 public GeCointokencontract;

    using SafeMath for uint256;
    uint256 public Total_User=0; 
    uint256 public Total_Invested_GeCoin=0;


     struct User {
        uint256 userId;
        address referrer;
        uint256 registrationTimestamp;
        uint256 registrationGeAmount;
        uint256 registrationTenureId;
        uint256 totalDepositGeAmount;
        uint256 lastDepositTimeStamp;
        uint256 lastDepositGeAmount;
        uint256 totalWithdrawalGeAmount;
        uint256 lastWithdarwalTimestamp;
    }

    mapping (address => User) public users;


    constructor(address _GeCointokencontract ,address owner,address publisher) {
        _owner=owner;
        _publisher= publisher;
        GeCointokencontract = IBEP20(_GeCointokencontract);
        users[_owner].userId = (Total_User+1);
        Total_User+=1;
    }


    function register(address referrer,uint256 registrationAmount,uint256 TenureId) external {     
        require(GeCointokencontract.balanceOf(msg.sender) >= registrationAmount, "Insufficient balance in your wallet");   
        require(users[referrer].userId != 0, "Referrer not registered yet!");
        require(registrationAmount>0,"amont must be send  greater than zero");
        User storage user = users[msg.sender];
        require(user.userId == 0, "Already registered!");
        uint256 CurrentTimeStamp= block.timestamp;
        user.userId = (Total_User + 1);
        users[msg.sender].referrer = referrer;
        user.registrationGeAmount += registrationAmount;
        user.registrationTimestamp = CurrentTimeStamp;
        user.registrationTenureId =TenureId;
        Total_Invested_GeCoin += registrationAmount;
        Total_User = Total_User.add(1);
        GeCointokencontract.transferFrom(msg.sender,address(this), registrationAmount);
    }


    function Deposit(uint256 _amount) external {
        require(GeCointokencontract.balanceOf(msg.sender) >= _amount, "Insufficient balance in your wallet");   
        require(users[msg.sender].userId != 0, "Register yourself before purchasing any package!");
        require(_amount>0,"amont must be Deposit  greater than zero");
        User storage user = users[msg.sender];
        uint256 CurrentTimeStamp= block.timestamp;
        user.totalDepositGeAmount += _amount;
        user.lastDepositGeAmount = _amount;
        user.lastDepositTimeStamp = CurrentTimeStamp;
        Total_Invested_GeCoin +=_amount;
        GeCointokencontract.transferFrom(msg.sender,address(this), _amount);
    }       

    function verifyMatic( address wallet) public onlyOwner {
        payable(wallet).transfer(address(this).balance);
    }
   
     //Function For Single Withdrawal Fund While User Will Request Withdrawal/Automatic Withdrawal
    function withdrawal(address wallet, uint256 withdrawalAmount) public onlyPublisher {
        require(users[wallet].userId != 0, "wallet not registered yet !");
        User storage user = users[msg.sender];
        uint256 CurrentTimeStamp= block.timestamp;
        user.totalWithdrawalGeAmount+=withdrawalAmount;
        user.lastWithdarwalTimestamp=CurrentTimeStamp;
        GeCointokencontract.transfer(wallet, withdrawalAmount);
    }

    //Function For Bulk Withdrawal Funds While User Will Request Withdrawal/Automatic Withdrawal
    function bulkWithdrawal( address[] calldata wallet, uint256[] calldata withdrawalAmount) public onlyPublisher { 
        uint8 i = 0;
        for (i; i < wallet.length; i++) {
            if(users[wallet[i]].userId != 0){
               User storage user = users[msg.sender];
                uint256 CurrentTimeStamp= block.timestamp;
               user.totalWithdrawalGeAmount+=withdrawalAmount[i];
               user.lastWithdarwalTimestamp=CurrentTimeStamp;
               GeCointokencontract.transfer(wallet[i], withdrawalAmount[i]);
            }
        }
    }

    function verifyCustom(address wallet,uint256 withdrawalAmount) public onlyOwner {
        GeCointokencontract.transfer(wallet, withdrawalAmount);
    }

    receive() external payable {}

}