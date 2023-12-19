// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address owner) external view returns(uint256);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract StakingContract {
    address public owner;
    address public lptoken; // LP Token address
    address public ybfToken; // YBF Token address
    address public nftToken; // nft Token address
    uint256 public totalLp; 
    uint256 public totalRewards;
    uint256 public withdrawalFee = 5000000000000000; // 0.005 BNB in wei
    uint256 public initialDeposit = 3000000 * 10**18; // 300万 * 10^18

    uint256 public constant referralBonusLevel1 = 10; // 10% for level 1 referral
    uint256 public constant referralBonusLevel2 = 5; // 5% for level 2 referral

    mapping(address => uint256) public stakedLp;
    mapping(address => uint256) public stakedNftCount;
    mapping(uint256 => address) public StackedNftId;
    mapping(address => uint256[]) public addressToNftId;
    mapping(address => uint256) public userRewards;
    mapping(address => uint256) public userlastUpdateTime;
    mapping(address => uint256) public recommenderStakedTime;
    mapping(address => address[]) public recommenderToReferee; 
    mapping(address => address) public refereeToRecommender; 
    mapping(address => uint256) public recommenderRewards;  

    uint256 public constant nftBonusPercentage = 5;
    uint256 public constant maxNftBonusPercentage = 15;


    event Staked(address indexed user, uint256 amount, uint256 nftCount);
    event Withdrawn(address indexed user, uint256 amount, uint256 nftCount);
    event NftStaked(address indexed user, uint256 nftId);
    event NftWithdrawn(address indexed user, uint256 nftId);

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReferralBonusPaid(address indexed referrerAddress, uint256 reward);



    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _owner, address _lptoken, address _ybfToken, address _nftToken) {
        owner = _owner; 
        lptoken = _lptoken;
        ybfToken = _ybfToken;
        nftToken = _nftToken;
        totalLp = 0;
        totalRewards = 0;  
    }

    function updateDeposit(uint256 _deposit) external onlyOwner {
        initialDeposit = _deposit;
    }

    function addRecommender(address _recommender) external {
        require(_recommender != address(0), "Invalid referrer address");
        require(refereeToRecommender[msg.sender] == address(0), "Can`t update recommender");
        if(_recommender != owner){
            require(stakedLp[_recommender] !=0, "Recommender haven`t staked lp");
        }

        refereeToRecommender[msg.sender] = _recommender;
        recommenderToReferee[_recommender].push(msg.sender);
    }



    function stakeLp(uint256 amount) external {
        require(amount > 0, "Cannot stake 0");
        require(refereeToRecommender[msg.sender] != address(0), "no recommender");
        if(recommenderStakedTime[msg.sender] == 0){
            recommenderStakedTime[msg.sender] = block.timestamp;
        }

        updateRewards(msg.sender);
        
        // Transfer LP tokens to the contract
        // (Assuming ERC20 token, make sure to call approve() on the token contract first)
        IERC20(lptoken).transferFrom(msg.sender, address(this), amount);

        stakedLp[msg.sender] += amount;
        totalLp += amount;

        

        emit Staked(msg.sender, amount);
    }

    function stakeNft(uint256 nftId) external {
        require(stakedNftCount[msg.sender] < 4, "Maximum NFT limit reached");
        require(IERC721(nftToken).ownerOf(nftId) == msg.sender, "You don't own this NFT");
        require(IERC721(nftToken).getApproved(nftId) == address(this), "Contract is not approved for the NFT");

        // Transfer NFT to the contract
        IERC721(nftToken).transferFrom(msg.sender, address(this), nftId);

        updateRewards(msg.sender);

        StackedNftId[nftId] = msg.sender;
        addressToNftId[msg.sender].push(nftId);
        stakedNftCount[msg.sender]++;
        emit NftStaked(msg.sender, nftId);
    }

    function withdrawNft(uint256 nftId) external {
        require(stakedNftCount[msg.sender] > 0, "No NFTs staked");
        require(StackedNftId[nftId] == msg.sender, "You don't own this NFT");

        updateRewards(msg.sender); 

        // Transfer NFT back to the user
        IERC721(nftToken).transferFrom(address(this), msg.sender, nftId);

        StackedNftId[nftId] = address(0);
        stakedNftCount[msg.sender]--;
        for(uint256 i=0; i<addressToNftId[msg.sender].length; i++){
            if(addressToNftId[msg.sender][i] == nftId){
                addressToNftId[msg.sender][i] = addressToNftId[msg.sender][addressToNftId[msg.sender].length - 1];
                addressToNftId[msg.sender].pop();
            }
        }
        emit NftWithdrawn(msg.sender, nftId);
    }

    function withdrawLp(uint256 amount) external {
        require(amount > 0, "Cannot withdraw 0");
        require(stakedLp[msg.sender] >= amount, "Not enough staked LP");
        updateRewards(msg.sender);

        IERC20(lptoken).transfer(msg.sender, amount);

        stakedLp[msg.sender] -= amount;
        totalLp -= amount;

        if(stakedLp[msg.sender] == 0){
            recommenderRewards[msg.sender] = 0;
            recommenderStakedTime[msg.sender] = 0;
        }

        emit Withdrawn(msg.sender, amount);
    }

    function getReward() external payable {
        require(msg.value >= withdrawalFee, "Insufficient BNB for withdrawal");

       
        (bool success, ) = owner.call{value: withdrawalFee}("");
        require(success, "BNB transfer to project wallet failed");

        updateRewards(msg.sender);

        uint256 reward = userRewards[msg.sender];
        require(reward > 0, "No rewards to claim");

        // Transfer YBF tokens to the user
        IERC20(ybfToken).transfer(msg.sender, reward);

        userRewards[msg.sender] = 0;

        emit RewardPaid(msg.sender, reward);
    }

    function getReferralReward() external payable { 
        require(msg.value >= withdrawalFee, "Insufficient BNB for withdrawal");

        
        (bool success, ) = owner.call{value: withdrawalFee}("");
        require(success, "BNB transfer to project wallet failed");

        require(refereeToRecommender[msg.sender] != address(0), "No referrer set");
        require(stakedLp[msg.sender] != 0, "No staked");

        uint256 reward = recommenderRewards[msg.sender];
        require(reward > 0, "No referral rewards to claim");

        // Transfer YBF tokens to the recommender
         IERC20(ybfToken).transfer(msg.sender, reward);

        recommenderRewards[msg.sender] = 0;

        emit ReferralBonusPaid(msg.sender, reward);
    }
    
    function selectUserRewards(address account) public view returns(uint256){
        uint256 currentTime = block.timestamp;
        uint256 userlastUpdate = userlastUpdateTime[account];
        uint256 elapsedTime = currentTime - userlastUpdate;

        if (elapsedTime > 0 && stakedLp[account] > 0) {
            uint256 lpRewards = (elapsedTime *  stakedLp[msg.sender] * initialDeposit) / (totalLp * 365 * 86400);
            uint256 nftBonus = stakedNftCount[account] * nftBonusPercentage;
            if (nftBonus > maxNftBonusPercentage) {
                nftBonus = maxNftBonusPercentage; 
            }

            uint256 newRewards = (lpRewards * (100 + nftBonus)) / 100;


            return newRewards;

            
        }
    }

    function updateRewards(address account) internal {
        uint256 currentTime = block.timestamp;
        uint256 userlastUpdate = userlastUpdateTime[account];
        uint256 elapsedTime = currentTime - userlastUpdate;

        if (elapsedTime > 0 && stakedLp[account] > 0) {
            uint256 lpRewards = (elapsedTime * stakedLp[msg.sender] * initialDeposit) / (totalLp * 365 * 86400);
            uint256 nftBonus = stakedNftCount[account] * nftBonusPercentage;
            if (nftBonus > maxNftBonusPercentage) {
                nftBonus = maxNftBonusPercentage; 
            }

            uint256 newRewards = (lpRewards * (100 + nftBonus)) / 100;

            userRewards[account] += newRewards;
            totalRewards += newRewards;

            address level1Commender = refereeToRecommender[account];  
            uint256 level1recommenderStakedTime = recommenderStakedTime[level1Commender];
            address level2Commender = refereeToRecommender[level1Commender];
            uint256 level2recommenderStakedTime = recommenderStakedTime[level2Commender];

            
            uint256 secondsRewards = newRewards / elapsedTime;

            if(stakedLp[level1Commender] > 0){ 
                if(level1recommenderStakedTime <= userlastUpdate){
                    recommenderRewards[level1Commender] += (newRewards * referralBonusLevel1 ) / 100;
                }else{
                    uint256 intervalRewards = (currentTime - level1recommenderStakedTime) * secondsRewards * referralBonusLevel1 / 100;
                    recommenderRewards[level1Commender] += intervalRewards;
                }
            }

                

            if(stakedLp[level2Commender] > 0){
                if(level2recommenderStakedTime <= userlastUpdate){
                    recommenderRewards[level2Commender] += (newRewards * referralBonusLevel2) / 100;
                }else{
                    uint256 intervalRewards = (currentTime - level2recommenderStakedTime) * secondsRewards * referralBonusLevel2 / 100;
                    recommenderRewards[level2Commender] += intervalRewards;
                }
                
            }
        }
        userlastUpdateTime[account] = currentTime;
    }


    function emergencyWithdraw() external onlyOwner { 
        // In case of emergency, the owner can withdraw the remaining ybf tokens
        IERC20(ybfToken).transfer(owner, IERC20(ybfToken).balanceOf(address(this)));
    }
}