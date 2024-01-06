// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IOwnable{
    function owner() view external returns (address);
    function _checkOwner(address sender) external view returns(bool);
}

contract ContractToken{
    IOwnable ownable;
    address private Owner;
    IERC20 tokenERC20; 
    IERC20 LPTokenERC20;
    uint256 private constant second = 86400; 

    modifier onlyOwner() {
        require(Owner == msg.sender || ownable._checkOwner(msg.sender),"Ownable: caller is not the owner");
        _;
    }

    struct UserDetail{
        uint256 amount;
        uint256 timestamp; 
        uint256 redeemStamp;
    }
    struct Staked{
        uint256 totalLP;
        UserDetail[] userDetail;
        uint256 lastClaimDay; 
        uint256 rewards; 
        uint256 index; 
        uint256 noRewards;
    }
    struct DaysBig{
        uint256 timestamp;
        uint256 bigTotal; 
    }
    DaysBig[] public daysBigList;
    mapping(address => Staked) public stakedLP;
    address[] private stakedList; 
    uint256 public totalStakedLP; 
    event puyLog(address adr,uint256 amount);
    event removeLog(address adr,uint256 amount); 
    event upDaysBigLog(uint256 timestamp,uint256 amount);
    event claimRewardsLog(address msgSender,uint256 amount);
    bool public inLock = true;
    uint256 public size = 5;
    uint256 public denominator = 1000000;

    bool private lock;

    modifier onLock(){
        lock = true;
        _;
        lock = false;
    }
    function OwGetUserNoRewardsTotal() public view onlyOwner returns(uint256){
        uint256 total;
        for(uint256 i = 0 ; i <stakedList.length ; i++){
            Staked memory staked = stakedLP[stakedList[i]];
            total += staked.noRewards;
        }
        return total;
    }
    function OwGetUserInfo(uint256 page) public view onlyOwner returns(address[] memory addressResult,uint256[] memory totalLpResult,uint256[] memory rewardsResult){
        require(page > 0, "Page number should be greater than 0");
        uint256 stakedListLength = stakedList.length;
        uint256 max = (page - 1) * size;
        if(stakedListLength == 0 || stakedListLength <= max){
            return (new address[](0),new uint256[](0),new uint256[](0));
        }
        uint256 start = stakedListLength - max - 1;
        uint256 end = start >= size ? start - size + 1 : 0;
        uint256 itemCount = start - end + 1;
        addressResult = new address[](itemCount);
        totalLpResult = new uint256[](itemCount);
        rewardsResult = new uint256[](itemCount);
        for (uint256 i = start; i >= end; i--) {
            address userAdr = stakedList[i];
            Staked memory staked = stakedLP[userAdr];
            addressResult[start - i] = userAdr;
            totalLpResult[start - i] = staked.totalLP;
            rewardsResult[start - i] = staked.rewards;
            if(i == 0){
                break;
            }
        }
        return (addressResult,totalLpResult,rewardsResult);
    }

    function claimRewards() public virtual onLock {
        address msgSender = msg.sender;
        uint256 amount = getData(msgSender);
        require(amount > 0,'rewards is 0');
        uint256 tokenAmount = tokenERC20.balanceOf(address(this));
        require(tokenAmount >= amount , 'insufficient contract amount');
        Staked storage staked = stakedLP[msgSender];
        staked.noRewards = 0;
        staked.rewards = staked.rewards + amount;
        staked.lastClaimDay = block.timestamp;
        tokenERC20.transfer(msgSender, amount);
        emit claimRewardsLog(msgSender, amount);
    }

    function getUserInfo() public view returns(uint256,uint256,uint256,uint256,uint256){
        address msgSender = msg.sender;
        Staked memory staked = stakedLP[msgSender];
        uint256 scale = 0;
        if(staked.totalLP != 0){
            scale = staked.totalLP * denominator / totalStakedLP;
        }
        uint256 bigTotal = daysBigList[daysBigList.length - 1].bigTotal;
        return (staked.totalLP,staked.lastClaimDay,staked.rewards,scale,bigTotal);
    }

    function getUserDetail(uint256 page) public view returns(uint256[] memory amountResult,uint256[] memory timestampResult,uint256[] memory redeemStampResult,uint256[] memory indexResult){
        require(page > 0, "Page number should be greater than 0");
        address msgSender = msg.sender;
        Staked memory staked = stakedLP[msgSender];
        UserDetail[] memory userDetailList = staked.userDetail;
        uint256 max = (page - 1) * size;
        if(userDetailList.length == 0 || userDetailList.length <= max){
            return (new uint256[](0),new uint256[](0),new uint256[](0),new uint256[](0));
        }
        uint256 start = userDetailList.length - max - 1;
        uint256 end = start >= size ? start - size + 1 : 0;
        uint256 itemCount = start - end + 1;
        amountResult = new uint256[](itemCount);
        timestampResult = new uint256[](itemCount);
        redeemStampResult = new uint256[](itemCount);
        indexResult = new uint256[](itemCount);
        for (uint256 i = start; i >= end; i--) {
            UserDetail memory userDetail = userDetailList[i];
            amountResult[start - i] = userDetail.amount;
            timestampResult[start - i] = userDetail.timestamp;
            redeemStampResult[start - i] = userDetail.redeemStamp;
            indexResult[start - i] = i;
            if(i == 0){
                break; 
            }
        }
        return (amountResult,timestampResult,redeemStampResult,indexResult);
    }

    function perSecond(uint256 bigTotal) private pure returns (uint256){
        return bigTotal / second;
    }

    function data(uint256 bigTotal,uint256 proportion,uint256 startTime,uint256 lastTime) private view returns (uint256){
        return perSecond(bigTotal) * proportion * (startTime - lastTime) / denominator;
    }

    function getData(address userAddress) private view returns(uint256){
        uint256 daysLength = daysBigList.length;
        uint256 timestamp = block.timestamp;
        Staked memory userStaked = stakedLP[userAddress];
        uint256 lastClaimDay = userStaked.lastClaimDay;
        if (userStaked.userDetail.length == 0){
            return 0;
        }
        uint256 proportion = 0;
        if (totalStakedLP != 0){
            proportion = userStaked.totalLP * denominator / totalStakedLP;
        }
        if(daysLength == 1){ 
            DaysBig memory daysBig = daysBigList[0];
            return userStaked.noRewards + data(daysBig.bigTotal, proportion, timestamp, lastClaimDay);
        }
        uint256 k;
        uint256 recentIndex = 0; 
        for(uint256 j = daysLength - 1 ; 0 <= j ; j--){
            if(daysBigList[j].timestamp <= lastClaimDay){
                recentIndex = k == 0 ? j : j + 1;
                break;
            }
            if(j == 0){
                break;
            }
            k++;
        }
        if(k == 0){ 
            DaysBig memory daysBig = daysBigList[daysLength -1];
            return userStaked.noRewards + data(daysBig.bigTotal, proportion, timestamp, lastClaimDay);
        }
        uint256 amount;
        for (uint256 f = recentIndex; f < daysLength; f++) {
            DaysBig memory daysBig = daysBigList[f];
            if(f == recentIndex){
                amount += data(daysBigList[f - 1].bigTotal, proportion, daysBig.timestamp, lastClaimDay);
            }else{
                amount += data(daysBigList[f - 1].bigTotal, proportion, daysBig.timestamp, daysBigList[f - 1].timestamp);
            }
            if(f + 1 >= daysLength){
                amount += data(daysBig.bigTotal, proportion, timestamp, daysBig.timestamp);
            }
        }
        return userStaked.noRewards + amount;
    }

    function stake(uint256 count) external virtual{
        address msgSender = msg.sender;
        require(inLock,"lock");
        require(count > 0,'ERC20: transfer amount 0');
        uint256 amount = LPTokenERC20.balanceOf(msgSender);
        require(count <= amount,'ERC20: transfer amount exceeds balance');
        setData();
        Staked storage userStaked = stakedLP[msgSender];
        userStaked.totalLP = userStaked.totalLP + count;
        userStaked.lastClaimDay = block.timestamp;
        userStaked.userDetail.push(UserDetail(count,block.timestamp,0));
        if(stakedList.length == 0){
            userStaked.index = 0;
            stakedList.push(msgSender);
        }else{
            if(userStaked.index == 0 && stakedList[0] != msgSender){
                userStaked.index = stakedList.length;
                stakedList.push(msgSender);
            }
        }
        totalStakedLP = totalStakedLP + count;
        LPTokenERC20.transferFrom(msgSender, address(this), count);
        emit puyLog(msgSender,count);
    }
    function getNoChaimBalance() public view returns(uint256){
        return getData(msg.sender);
    }

    function setData() private onLock{
        uint256 timestamp = block.timestamp;
        uint256 gas = 500000;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        for(uint256 i = 0; i < stakedList.length; i++){
            if(gasUsed >= gas){
                break ;
            }
            address userAddress = stakedList[i];
            Staked storage userStaked = stakedLP[userAddress];
            userStaked.noRewards = getData(userAddress);
            userStaked.lastClaimDay = timestamp;
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
        }
    }
    function unstake(uint256 index) public virtual {
        address msgSender = msg.sender;
        Staked storage userStaked = stakedLP[msgSender];
        require(userStaked.userDetail.length > index,"index should be less than length");
        UserDetail storage userDetail = userStaked.userDetail[index];
        require(userDetail.redeemStamp == 0,'redeemed');
        userDetail.redeemStamp = block.timestamp;
        uint256 amount = userDetail.amount;
        setData();
        require(userStaked.totalLP - amount >= 0,'numeric error');
        userStaked.totalLP = userStaked.totalLP - amount;
        totalStakedLP = totalStakedLP - amount;
        uint256 thatAmount = LPTokenERC20.balanceOf(address(this));
        require(thatAmount - amount >= 0,'insufficient contract balance');
        LPTokenERC20.transfer(msgSender, amount);
        emit removeLog(msgSender, amount);
    }
    function unStakeAll() public virtual{
        address msgSender = msg.sender;
        Staked storage userStaked = stakedLP[msgSender];
        setData();
        uint256 timestamp = block.timestamp;
        uint256 amount;
        for(uint256 i = 0 ; i < userStaked.userDetail.length;i++){
            UserDetail storage userDetail = userStaked.userDetail[i];
            if(userDetail.redeemStamp != 0){
                continue;
            }
            amount += userDetail.amount;
            userDetail.redeemStamp = timestamp;
        }
        require(userStaked.totalLP - amount >= 0,'numeric error');
        userStaked.totalLP = userStaked.totalLP - amount;
        totalStakedLP = totalStakedLP - amount;
        uint256 thatAmount = LPTokenERC20.balanceOf(address(this));
        require(thatAmount - amount >= 0,'insufficient contract balance');
        LPTokenERC20.transfer(msgSender, amount);
        emit removeLog(msgSender, amount);
    }

    constructor(address ownable_,address contractToken_,address LPToken_,uint256 daysBigTotal_){
        ownable = IOwnable(ownable_);
        Owner = msg.sender;
        tokenERC20 = IERC20(contractToken_);
        LPTokenERC20 = IERC20(LPToken_);
        uint256 _daysBigTotal = daysBigTotal_ * 10 ** IERC20(contractToken_).decimals();
        daysBigList.push(DaysBig(block.timestamp,_daysBigTotal));
    }

    function setOwnable(address ownable_) external virtual onlyOwner{
        ownable = IOwnable(ownable_);
    }

    function setSize(uint256 size_) external virtual onlyOwner{
        size = size_;
    }

    function setInLock(bool bl) external virtual onlyOwner{
        inLock = bl;
    }

    function setStakeLPToken(address token_) external virtual onlyOwner{
        LPTokenERC20 = IERC20(token_);
    }

    function setDaysBig(uint256 amount) external virtual onlyOwner{
        amount = amount * 10 ** tokenERC20.decimals();
        daysBigList.push(DaysBig(block.timestamp,amount));
        emit upDaysBigLog(block.timestamp,amount);
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }
    function claimToken(address token_, uint256 amount_, address to_) external onlyOwner {
        IERC20(token_).transfer(to_, amount_);
    }
    function claimLPToken(address adr) external onlyOwner{
        LPTokenERC20.transfer(adr, LPTokenERC20.balanceOf(address(this)));
    }
    receive() external payable {}
}


contract AToken is ContractToken{
    constructor()ContractToken(
        address(0x3012AD0d396e3cA7c4518684F8e6e1b19761cE54),
        address(0x08801120Ab610F42Eaa5c573112EEc68C19cbD9c),
        address(0xAD5D013A307d6DC3aA2A1c908633a69813c8a282),
        20000
    ){}
}