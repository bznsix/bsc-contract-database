// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract Context 
{
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}


contract Ownable is Context 
{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () 
    {
        _owner = 0x406A576E43ae5F94d8BAf6319667d7d143919d3d;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) 
    {
        return _owner;
    }   
    
    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}


struct Pool {
    address stakingToken;
    address rewardToken;
    uint256 period;
    uint256 apy;
    uint256 maxPossibleStakeAmount;
    uint256 avalReward;
    uint256 issuedReward;
    uint256 stakedAmount;
    uint256 count;
}



contract Staking is Ownable
{
    address public feeToken =   0x9d6DF568D4D3E619B99a5f988ac7b2bCc3408753;
    mapping (uint256 => Pool) public pools;
    mapping (uint256 => address[]) public stakers;
    mapping (address => mapping (uint256 => uint256)) public _stakedAmountInPool;
    mapping (address => mapping (uint256 => uint256)) public poolTime;
    uint256[] public _uids;
    uint256 public timeUnit = 1 * 86400;
    uint256 public stakingFee = 18 * 10**18;
    uint256 public poolFee = 180 * 10**18;


    function fees() public view returns (uint256, uint256) 
    {
        return (stakingFee, poolFee);
    }

    function isPoolExists(uint256 uid) public view returns(bool) 
    {
        for(uint256 i=0; i<_uids.length; i++)
        {
            if(_uids[i]==uid) { return true; }
        }
        return false;
    }


    function isStakerExists(uint256 uid, address addr) public view returns(bool) 
    {
        uint256 len = pools[uid].count;
        for(uint256 i=0; i<len; i++)
        {
            if(stakers[uid][i]==addr) { return true; }
        }
        return false;
    }


    event PoolCreated(address stakingToken, address rewardToken, uint256 periodInDays, uint256 rewardApy, uint256 uid);
    function createPool(address stakingToken, address rewardToken, uint256 periodInDays, uint256 rewardApy, uint256 maxPossibleStakeAmount, uint256 uid) public
    {
        require(!isPoolExists(uid), "Already existing pool ID");
        _uids.push(uid);
        pools[uid] = Pool(stakingToken, rewardToken, periodInDays*timeUnit, rewardApy, maxPossibleStakeAmount, 0, 0, 0, 0);
        emit PoolCreated(stakingToken, rewardToken, periodInDays, rewardApy, uid);
        IERC20(feeToken).transferFrom(msg.sender, address(this), poolFee);
    }


    function supplyReward(uint256 uid, uint256 rewardAmount) public 
    {
        address rewardToken = pools[uid].rewardToken;
        IERC20(rewardToken).transferFrom(msg.sender, address(this), rewardAmount);
        pools[uid].avalReward += rewardAmount;
    }
    

    function getBalanceApprove(address token, address addr, uint256 uid) public view returns (uint256[4] memory data) 
    {
        (,uint256 reward,) = calculateReward(addr, uid);
        data[0] = IERC20(token).balanceOf(addr);
        data[1] = IERC20(token).allowance(addr, address(this));
        data[2] = _stakedAmountInPool[addr][uid];
        data[3] = reward;
        return data;
    }
    

    event Staked(address addr, uint256 uid, uint256 amount);
    function stake(uint256 uid, uint256 amount) public
    {
        bool b = isStakerExists(uid, msg.sender);
        if(!b) {  stakers[uid].push(msg.sender);  }        
        address token = getStakingTokenAddress(uid);
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(feeToken).transferFrom(msg.sender, address(this), stakingFee);
        _stakedAmountInPool[msg.sender][uid] += amount;
        emit Staked(msg.sender, uid, amount);
        poolTime[msg.sender][uid] = block.timestamp;
        pools[uid].stakedAmount += amount;
        require(pools[uid].stakedAmount+amount<=pools[uid].maxPossibleStakeAmount, "Exceeding Max Staking Limit");
        if(!isStakerExists(uid, msg.sender))
        {
            pools[uid].count += 1;
        }
    }


    function updateFee(uint256 _newStakingFee, uint256 _newPoolFee) external onlyOwner()
    {
        stakingFee = _newStakingFee;
        poolFee = _newPoolFee;
    }


    function withdrawFeeTokens() external onlyOwner()
    {
        uint256 amount = IERC20(feeToken).balanceOf(address(this));
        IERC20(feeToken).transfer(owner(), amount);
    }


    function getStakingTokenAddress(uint256 uid) public view returns (address)
    {
        address token = pools[uid].stakingToken; 
        return token;
    }


    event Unstaked(address addr, uint256 uid, uint256 amount);
    function unstake(uint256 uid) public
    {
        uint256 amount = _stakedAmountInPool[msg.sender][uid];
        _stakedAmountInPool[msg.sender][uid] = 0;
        poolTime[msg.sender][uid] = 0;
        pools[uid].stakedAmount += amount;
        address token = getStakingTokenAddress(uid);
        IERC20(token).transfer(msg.sender, amount);
        pools[uid].stakedAmount -= amount;  
        emit Unstaked(msg.sender, uid, amount);     
    }


    function getPeriods(address addr, uint256 uid) public view returns(uint256)
    {
        uint256 stakingTime = poolTime[addr][uid];
        if(stakingTime==0) { return 0; }
        uint256 span = block.timestamp - stakingTime;
        uint256 period = pools[uid].period;
        uint256 periods = span/period;
        return periods;
    }



    function calcReward(address addr, uint256 uid, uint256 periods) public view returns(uint256)
    {
        uint256 stakedAmount = _stakedAmountInPool[addr][uid];
        if(periods==0) { return 0; }
        uint256 apy = pools[uid].apy;
        uint256 rewardPerPeriod = stakedAmount*apy*periods/100;
        return rewardPerPeriod;
    }



    function calculateReward(address addr, uint256 uid) public view returns (uint256, uint256, uint256)
    {        
        uint256 periods = getPeriods(addr, uid);
        uint256 reward = calcReward(addr, uid, periods);
        uint256 decimals = IERC20(pools[uid].rewardToken).decimals();
        return (periods, reward, decimals);
    }



    function claimReward(uint256 uid) public 
    {
        address token = getStakingTokenAddress(uid);
        (uint256 periods, uint256 _reward, ) = calculateReward(msg.sender, uid);
        if(_reward==0) { return; }
        require(pools[uid].avalReward>_reward, "Not Enough Reward Available");
        IERC20(token).transfer(msg.sender, _reward);
        poolTime[msg.sender][uid] += (periods*pools[uid].period);
        pools[uid].avalReward -= _reward;
        pools[uid].issuedReward += _reward;
    }


    function getPoolDetails(uint256 uid) public view returns(uint256[4] memory data) 
    {
        Pool memory pool = pools[uid];
        data[0] = pool.avalReward;
        data[1] = pool.issuedReward;
        data[2] = pool.stakedAmount;
        data[3] = pool.count;
        return data;
    }


    function getTokenMeta(address tokenAddr) public view 
    returns(string memory name, string memory symbol, uint256 decimals)
    {
        IERC20 token = IERC20(tokenAddr);
        return(token.name(), token.symbol(), token.decimals());
    }

    function getPoolLimit(uint256 uid) public view returns(uint256, uint256, uint256)
    {
        return (pools[uid].maxPossibleStakeAmount, pools[uid].stakedAmount, pools[uid].avalReward);
    }


    function getPool(uint256 uid) public view returns(Pool memory)
    {
        return pools[uid];
    }

}