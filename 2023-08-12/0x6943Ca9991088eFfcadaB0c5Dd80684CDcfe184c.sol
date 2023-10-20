// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.4.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.0


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {


    function mint(address minter,uint256 amount) external;
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;


contract XYieldMine {

    IERC20  private XYieldToken   = IERC20(0x542EBC506F1B6DdDd2073E43bD9867551DECDFcE);
    address private devAddr       = 0x3d69eE52a82978143971cC80E54eB88EE8dD3c86;
    uint256 public stage          = 1;
    uint256 public baseAmount     = 100e18;
    uint256 public minAmount      = 1e17;
    uint256 public baseYieldX     = 4e13;
    uint256 public baseYieldY     = 1e13;
    uint256 public baseYieldZ     = 4e13;
    uint256 public tokenPerBlock  = 1e18;
    uint256 public userID         = 1;

    mapping(uint256 => RewardPool) public rewardPoolOfStage;
    mapping(address => mapping(uint256=>UserYield)) public userYieldOfstage;
    mapping(address => uint256) public userReward;
    mapping(address => uint256) public addressToUserID;
    mapping(uint256 => address) public userIDToAddress;
    mapping(address => uint256) public addressToInviteID;

    struct RewardPool{
        uint256     amount;
        uint256     allocPoint;
        uint256     startRewardBlock;
        uint256     lastRewardBlock;
    }

    struct UserYield{
        uint256     amount;
        uint256     withdrawYieldX;
        uint256     withdrawYieldY;
        uint256     withdrawYieldZ;
        uint256     lastWithdrawBlock;
        uint256     lastWithdrawBlockX;
        uint256     lastWithdrawBlockY;
        uint256     lastWithdrawBlockZ;
    }

    struct DepositInfo{
        address     user;
        uint256     stage;
        uint256     amount;
        uint256     depositBlock;
        uint256     time;
    }
    mapping(uint256 => DepositInfo[]) public depositList;
    mapping(address => mapping(uint256 =>uint256[])) private userDepositIDList;

    struct RewardBook{
        uint256     stage;
        uint256     startRewardBlock;
        uint256     lastRewardBlock;
        uint256     tokenPerShare;
    }

    mapping(uint256 => RewardBook[]) public bookList;

    event Deposit(address indexed owner, uint256 indexed stage, uint256 value, uint256 blockNum,uint256 time);
    event Book(uint256 indexed stage,uint256 startRewardBlock, uint256 lastRewardBlock, uint256 tokenPerShare);
    event Withdraw(address indexed owner,uint256 indexed stage,uint256 indexed amountType,uint256 amount, uint256 time);

    constructor() {
        addressToUserID[devAddr] = userID;
        userIDToAddress[userID] = devAddr;
        userID++;
        userReward[devAddr] = 360e18;
        rewardPoolOfStage[stage].startRewardBlock = block.number;
        rewardPoolOfStage[stage].lastRewardBlock = block.number;
    }

    function updateBook() public{
        if(rewardPoolOfStage[stage].amount == 0){
            return;
        }
        uint256 rewardBlock = block.number - rewardPoolOfStage[stage].lastRewardBlock;
        if(rewardBlock == 0){
            return;
        }
        uint256 tokenPerShare = (tokenPerBlock * 85 / 100 * rewardBlock) / (rewardPoolOfStage[stage].amount / minAmount);
        bookList[stage].push(RewardBook(stage,rewardPoolOfStage[stage].lastRewardBlock,block.number,tokenPerShare));
        
        emit Book(stage,rewardPoolOfStage[stage].lastRewardBlock, block.number,tokenPerShare);
        rewardPoolOfStage[stage].lastRewardBlock = block.number;
    }

    function deposit(uint256 inviteID) public payable {
        require(msg.value >= minAmount,"The minimum participation share is 0.1bnb");
        require(inviteID > 0 && inviteID < userID && inviteID != addressToUserID[msg.sender],"Can't is yourself");
        updateBook();
        if(addressToUserID[msg.sender] == 0){
            addressToUserID[msg.sender] = userID;
            userIDToAddress[userID] = msg.sender;
            addressToInviteID[msg.sender] = inviteID;
            userID++;
        }
        
        uint balance = (baseAmount * 2 ** (stage-1)) - rewardPoolOfStage[stage].amount;
        uint userAmount = 0;
        uint copNum = msg.value - (msg.value % minAmount);
        if(balance >= copNum){
            rewardPoolOfStage[stage].amount += copNum;
            userAmount = copNum;
        }else{
            rewardPoolOfStage[stage].amount += balance;
            userAmount = balance;
        }
        uint returnAmount = msg.value - userAmount;
        if(returnAmount > 0){
            payable(msg.sender).transfer(returnAmount);
        }
        depositList[stage].push(DepositInfo(msg.sender,stage,userAmount,block.number,block.timestamp));
        uint newID = depositList[stage].length - 1;
        userDepositIDList[msg.sender][stage].push(newID);
        
        userYieldOfstage[msg.sender][stage].amount += userAmount;
        userReward[userIDToAddress[addressToInviteID[msg.sender]]] += userAmount * 10 / 100;
        if(rewardPoolOfStage[stage].amount == baseAmount * 2 ** (stage-1)){
            stage++;
            rewardPoolOfStage[stage].startRewardBlock = block.number;
            rewardPoolOfStage[stage].lastRewardBlock = block.number;
        }
        emit Deposit(msg.sender,stage,userAmount,block.number,block.timestamp);
    }

    function mintRewardForBookList(uint _stage) public {
        require(userYieldOfstage[msg.sender][_stage].amount > 0,"amount must > 0");
        uint lastWithdrawBlock = userYieldOfstage[msg.sender][_stage].lastWithdrawBlock;
        uint rewardAmount = 0;
        for(uint i = 0; i < bookList[_stage].length;i++){
            if(lastWithdrawBlock >= bookList[_stage][i].lastRewardBlock){
                continue;
            }
            lastWithdrawBlock = bookList[_stage][i].lastRewardBlock;
            uint addShare = 0;
            for(uint j = 0; j < userDepositIDList[msg.sender][_stage].length; j++){
                if(depositList[_stage][userDepositIDList[msg.sender][_stage][j]].depositBlock >= bookList[_stage][i].lastRewardBlock){
                    break;
                }
                addShare += depositList[_stage][userDepositIDList[msg.sender][_stage][j]].amount / minAmount;
            }
            if(addShare == 0){
                continue;
            }
            rewardAmount += bookList[_stage][i].tokenPerShare * addShare;
        }
        require(rewardAmount > 0,"There are no rewards to claim");
        userYieldOfstage[msg.sender][_stage].lastWithdrawBlock = lastWithdrawBlock;
        XYieldToken.mint(msg.sender, rewardAmount);
        rewardPoolOfStage[_stage].allocPoint += rewardAmount;
    }

    function mintReward(uint _stage,uint lvl) public {
        require(_stage < stage,"stage Out of range");
        require(lvl > 0 && lvl <= 3 && (stage - _stage) >= lvl,"Lvl Out of range");
        require(userYieldOfstage[msg.sender][_stage].amount > 0,"amount must > 0");
        uint lastWithdrawBlock = 0;
        if(lvl == 1){
            lastWithdrawBlock = userYieldOfstage[msg.sender][_stage].lastWithdrawBlockX;
        }else if(lvl == 2){
            lastWithdrawBlock = userYieldOfstage[msg.sender][_stage].lastWithdrawBlockY;
        }else if(lvl == 3){
            lastWithdrawBlock = userYieldOfstage[msg.sender][_stage].lastWithdrawBlockZ;
        }
        require(lastWithdrawBlock < rewardPoolOfStage[_stage+lvl].lastRewardBlock,"There are no rewards to claim");
        uint rewardBlock = 0;
        uint rewardAmount = 0;
        if(lastWithdrawBlock == 0){
            rewardBlock = rewardPoolOfStage[_stage+lvl].lastRewardBlock - rewardPoolOfStage[_stage+lvl].startRewardBlock;
        }else{
            rewardBlock = rewardPoolOfStage[_stage+lvl].lastRewardBlock - lastWithdrawBlock;
        }
       
        uint256 tokenPerShare = (tokenPerBlock * 5 / 100 * rewardBlock) / (rewardPoolOfStage[_stage].amount / minAmount);
        rewardAmount = tokenPerShare * userYieldOfstage[msg.sender][_stage].amount / minAmount;
        if(lvl == 1){
            userYieldOfstage[msg.sender][_stage].lastWithdrawBlockX = rewardPoolOfStage[_stage+lvl].lastRewardBlock;
        }else if(lvl == 2){
            userYieldOfstage[msg.sender][_stage].lastWithdrawBlockY = rewardPoolOfStage[_stage+lvl].lastRewardBlock;
        }else if(lvl == 3){
            userYieldOfstage[msg.sender][_stage].lastWithdrawBlockZ = rewardPoolOfStage[_stage+lvl].lastRewardBlock;
        }
        if(rewardAmount > 0){
            XYieldToken.mint(msg.sender, rewardAmount);
            rewardPoolOfStage[_stage].allocPoint += rewardAmount;
        }
    }

    function withdrawXYZ(uint _stage,uint lvl) public{
        require(_stage < stage,"stage Out of range");
        require(lvl > 0 && lvl <= 3 && (stage - _stage) >= lvl,"Lvl Out of range");
        require(userYieldOfstage[msg.sender][_stage].amount > 0,"amount must > 0");
        uint withdrawAmount = 0;
        uint myCount = userYieldOfstage[msg.sender][_stage].amount / minAmount;
        uint currentCount = rewardPoolOfStage[_stage+lvl].amount / minAmount;
        if(lvl == 1){
            uint claimCount = baseAmount * 2 ** _stage / minAmount;
            uint stageYieldX = (baseYieldX / 2 ** (_stage-1));
            uint claimedCount = userYieldOfstage[msg.sender][_stage].withdrawYieldX / myCount / stageYieldX;
            require(claimedCount < claimCount,"Claim complete");
            uint UnclaimedCount = currentCount - claimedCount;
            if(UnclaimedCount > 0){
                withdrawAmount = UnclaimedCount * stageYieldX * myCount;
                userYieldOfstage[msg.sender][_stage].withdrawYieldX += withdrawAmount;
            }
        }else if(lvl == 2){
            uint claimCount = baseAmount * 2 ** (_stage+1) / minAmount;
            uint stageYieldY = (baseYieldY / 2 ** (_stage-1));
            uint claimedCount = userYieldOfstage[msg.sender][_stage].withdrawYieldY / myCount / stageYieldY;
            require(claimedCount < claimCount,"Claim complete");
            uint UnclaimedCount = currentCount - claimedCount;
            if(UnclaimedCount > 0){
                withdrawAmount = UnclaimedCount * stageYieldY * myCount;
                userYieldOfstage[msg.sender][_stage].withdrawYieldY+= withdrawAmount;
            }
        }else if(lvl == 3){
            uint claimCount = baseAmount * 2 ** (_stage+2) / minAmount;
            uint stageYieldZ = (baseYieldZ / 2 ** (_stage-1));
            uint claimedCount = userYieldOfstage[msg.sender][_stage].withdrawYieldZ / myCount / stageYieldZ;
            require(claimedCount < claimCount,"Claim complete");
            uint UnclaimedCount = currentCount - claimedCount;
            if(UnclaimedCount > 0){
                withdrawAmount = UnclaimedCount * stageYieldZ * myCount;
                userYieldOfstage[msg.sender][_stage].withdrawYieldZ += withdrawAmount;
            }
        }
        if(withdrawAmount > 0){
            payable(msg.sender).transfer(withdrawAmount);
            emit Withdraw(msg.sender,stage,1,withdrawAmount,block.timestamp);
        }
    }

    function withdraw(uint amount) public{
        require(userReward[msg.sender] >= amount,"No withdrawable rewards"); //Used to add liquidity
        payable(msg.sender).transfer(amount);
        userReward[msg.sender] -= amount;
        emit Withdraw(msg.sender,stage,2,amount,block.timestamp);
    }

    function getDepositIDList(uint _stage) public view returns(uint256[] memory){
        return userDepositIDList[msg.sender][_stage];
    }
    
    function getBalance() public view returns(uint){return address(this).balance;}
}