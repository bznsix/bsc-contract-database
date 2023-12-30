// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Stake is Ownable {
    using SafeMath for uint256;
    address public tnrToken;

    struct RewardData {
        uint256 rewardRate3;
        uint256 rewardRate6;
        uint256 rewardRate12;
        uint256 divisorRate;
        uint8 term0;
        uint8 term1;
        uint8 term2;
        address owner;
        uint256 commission;
    }

    struct StakerData {
        address tokenAddress;
        uint256 startStaking;
        uint256 endStaking;
        uint256 totalStaked;
        uint256 reward;
        uint256 rate;
        uint256 rateDiv;
    }

    mapping(address => StakerData[]) private stakers;
    mapping(address => RewardData) public reward;
    mapping(address => bool) public stakingTokens;

    mapping(address => uint256) private totalReward;

    event TokensStaked(address indexed user, uint256 amount, uint256 duration);
    event TokensUnstaked(address indexed user, uint256 amount);

    constructor(
        address _token, 

        address _tnrToken, 
        uint256 _commission
    ) {
        stakingTokens[_token] = true;
        stakingTokens[_tnrToken] = true;

        tnrToken = _tnrToken;

        reward[_token] = RewardData(
            6,
            6,
            6,
            100,
            2,
            3, 
            6,
            msg.sender,
            _commission
        );

        reward[_tnrToken] = RewardData(
            10,
            12,
            14,
            100,
            3,
            6, 
            12,
            msg.sender,
            0
        );
    }

    function getStakerData() public view returns(StakerData[] memory) {
        return stakers[msg.sender];
    }

    function getMaxAvail(address _token, uint256 _duration) public view returns(uint256) {
        require(stakingTokens[_token], "Token staking is not active");

        if (_duration < reward[_token].term0 || IERC20(_token).balanceOf(address(this)) <= totalReward[_token]) {
            return 0;

        } else if (_duration < reward[_token].term1) {
            return IERC20(_token).balanceOf(address(this)).sub(totalReward[_token])
                .mul(reward[_token].divisorRate)
                .mul(12)
                .div(reward[_token].term0)
                .div(reward[_token].rewardRate3);

        } else if (_duration < reward[_token].term2) {
            return IERC20(_token).balanceOf(address(this)).sub(totalReward[_token])
                .mul(reward[_token].divisorRate)
                .mul(12)
                .div(reward[_token].term1)
                .div(reward[_token].rewardRate6);
        } else {
            return IERC20(_token).balanceOf(address(this)).sub(totalReward[_token])
                .mul(reward[_token].divisorRate)
                .mul(12)
                .div(reward[_token].term2)
                .div(reward[_token].rewardRate12);        
        }
    }

    function stake(address _token, uint256 _amount, uint256 _duration) public {
        require(stakingTokens[_token], "Token staking is not active");
        require(_amount > 0, "Amount must be greater than zero");
        require(_duration >= reward[_token].term0, "Duration must be greater than or equal MIN month");

        if (_duration < reward[_token].term1) {
            require(getMaxAvail(_token, reward[_token].term0) >= _amount, "Amount is more than available");

            stakers[msg.sender].push(StakerData(
                _token,
                block.timestamp,
                block.timestamp.add(uint256(2592000).mul(reward[_token].term0)), 
                _amount, 
                _amount.mul(reward[_token].rewardRate3).div(reward[_token].divisorRate).mul(reward[_token].term0).div(12),
                reward[_token].rewardRate3,
                reward[_token].divisorRate
            ));

        } else if (_duration < reward[_token].term2) {
            require(getMaxAvail(_token, reward[_token].term1) >= _amount, "Amount is more than available");

            stakers[msg.sender].push(StakerData(
                _token,
                block.timestamp,
                block.timestamp.add(uint256(2592000).mul(reward[_token].term1)), 
                _amount, 
                _amount.mul(reward[_token].rewardRate6).div(reward[_token].divisorRate).mul(reward[_token].term1).div(12),
                reward[_token].rewardRate6,
                reward[_token].divisorRate
            ));

        } else {
            require(getMaxAvail(_token, reward[_token].term2) >= _amount, "Amount is more than available");

            stakers[msg.sender].push(StakerData(
                _token,
                block.timestamp,
                block.timestamp.add(uint256(2592000).mul(reward[_token].term2)), 
                _amount, 
                _amount.mul(reward[_token].rewardRate12).div(reward[_token].divisorRate).mul(reward[_token].term2).div(12),
                reward[_token].rewardRate12,
                reward[_token].divisorRate
            ));

        }

        totalReward[_token] = totalReward[_token].add(stakers[msg.sender][stakers[msg.sender].length.sub(1)].totalStaked).add(stakers[msg.sender][stakers[msg.sender].length.sub(1)].reward);
        
        if (_token != tnrToken) {
            IERC20(tnrToken).transferFrom(msg.sender, address(this), reward[_token].commission);
        }
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        emit TokensStaked(msg.sender, _amount, _duration);
    }

    function claim(address _token, uint256 _index) public {
        require(stakers[msg.sender].length > 0, "Stake already withdraw");

        uint256 _claimAmount = 0;

        if (stakers[msg.sender][_index].tokenAddress == _token && stakers[msg.sender][_index].endStaking < block.timestamp) {
            _claimAmount = _claimAmount.add(stakers[msg.sender][_index].totalStaked).add(stakers[msg.sender][_index].reward);
            totalReward[_token] = totalReward[_token].sub(stakers[msg.sender][_index].totalStaked.add(stakers[msg.sender][_index].reward));
            stakers[msg.sender][stakers[msg.sender].length.sub(1)] = stakers[msg.sender][_index];
            emit TokensUnstaked(msg.sender, stakers[msg.sender][_index].totalStaked.add(stakers[msg.sender][_index].reward));
            stakers[msg.sender].pop();
        }

        require(_claimAmount > 0, "Available for claim 0");

        IERC20(_token).transfer(msg.sender, _claimAmount);
    }

    // only owner token

    function withdraw(address _token, uint256 _amount) public {
        require(reward[_token].owner == msg.sender, "You're not the owner");
        require(IERC20(_token).balanceOf(address(this)) >= totalReward[_token].add(_amount), "The balance is equal to or less than the reward");
        IERC20(_token).transfer(
            msg.sender, 
            _amount);
    }

    function maxWithdraw(address _token) public onlyOwner view returns(uint256) {
        require(reward[_token].owner == msg.sender, "You're not the owner");
        return IERC20(_token).balanceOf(address(this)).sub(totalReward[_token]);
    }

    function setRewardRate(
        address _token, 
        uint256 _rewardRate3, 
        uint256 _rewardRate6, 
        uint256 _rewardRate12, 
        uint256 _divisorRate,
        uint8 _term0,
        uint8 _term1,
        uint8 _term2,
        uint256 _commission
    ) public {
        require(reward[_token].owner == msg.sender, "You're not the owner");
        reward[_token].rewardRate3 = _rewardRate3;
        reward[_token].rewardRate6 = _rewardRate6;
        reward[_token].rewardRate12 = _rewardRate12;
        reward[_token].divisorRate = _divisorRate;
        reward[_token].term0 = _term0;
        reward[_token].term1 = _term1;
        reward[_token].term2 = _term2;
        reward[_token].commission = _commission;
    }

    // only owner contract

    function getStakersData(address _address) public onlyOwner view returns(StakerData[] memory) {
        return stakers[_address];
    }

    function setCommissionToken(address _token) public onlyOwner {
        tnrToken = _token;
    }

    function addToken(
        address _token, 
        uint256 _rewardRate3, 
        uint256 _rewardRate6, 
        uint256 _rewardRate12, 
        uint256 _divisorRate,
        uint8 _term0,
        uint8 _term1,
        uint8 _term2,
        address _ownerToken,
        uint256 _commission
    ) public onlyOwner() {
        require(!stakingTokens[_token], "Token has already been added");
        stakingTokens[_token] = true;
        reward[_token].rewardRate3 = _rewardRate3;
        reward[_token].rewardRate6 = _rewardRate6;
        reward[_token].rewardRate12 = _rewardRate12;
        reward[_token].divisorRate = _divisorRate;
        reward[_token].term0 = _term0;
        reward[_token].term1 = _term1;
        reward[_token].term2 = _term2;
        reward[_token].owner = _ownerToken;
        reward[_token].commission = _commission;
    }

    function deleteToken(address _token) public onlyOwner() {
        require(stakingTokens[_token], "Token has already been delete");
        stakingTokens[_token] = false;
        IERC20(_token).transfer(
            reward[_token].owner, 
            IERC20(_token).balanceOf(address(this)).sub(totalReward[_token])
        );
    }
}