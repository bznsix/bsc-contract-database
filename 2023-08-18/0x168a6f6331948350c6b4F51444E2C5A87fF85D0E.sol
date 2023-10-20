// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/IMasterChefv3.sol";
import "./interfaces/IFeeTierStrate.sol";

import "./utils/Ownable.sol";

contract LCPoolPCv3Ledger is Ownable {
  address public v3MasterChef;
  address public feeStrate;

  uint256 private constant MULTIPLIER = 1_0000_0000_0000_0000;

  // token0 -> token1 -> fee -> nftId
  mapping (address => mapping(address => mapping(uint24 => uint256))) public poolToNftId;

  struct RewardTVLRate {
    uint256 reward;
    uint256 prevReward;
    uint256 tvl;
    uint256 rtr;
    uint256 reInvestIndex;
    bool reInvested;
    uint256 updatedAt;
  }

  struct ReinvestInfo {
    uint256 reward;
    uint256 liquidity;
    uint256 updatedAt;
  }

  struct StakeInfo {
    uint256 amount;   // Staked liquidity
    uint256 debtReward;
    uint256 rtrIndex; // RewardTVLRate index
    uint256 updatedAt;
  }

  // account -> nftid -> basketId -> info basketid=0?lcpool
  mapping (address => mapping (uint256 => mapping (uint256 => StakeInfo))) public userInfo;
  // nftid => info
  mapping (uint256 => RewardTVLRate[]) public poolInfoAll;
  // nftid -> reinvest
  mapping (uint256 => ReinvestInfo[]) public reInvestInfo;

  mapping (address => bool) public managers;
  modifier onlyManager() {
    require(managers[msg.sender], "LC pool ledger: !manager");
    _;
  }

  constructor (
    address _v3MasterChef,
    address _feeStrate
  ) {
    require(_v3MasterChef != address(0), "LC pool ledger: master chef");
    require(_feeStrate != address(0), "LC pool ledger: feeStrate");

    v3MasterChef = _v3MasterChef;
    feeStrate = _feeStrate;
    managers[msg.sender] = true;
  }

  function setPoolToNftId(address token0, address token1, uint24 fee, uint256 id) public onlyManager {
    poolToNftId[token0][token1][fee] = id;
  }

  function getLastRewardAmount(uint256 tokenId) public view returns(uint256) {
    if (tokenId != 0 && poolInfoAll[tokenId].length > 0) {
      return poolInfoAll[tokenId][poolInfoAll[tokenId].length-1].prevReward;
    }
    return 0;
  }

  function getUserLiquidity(address account, uint256 tokenId, uint256 basketId) public view returns(uint256) {
    return userInfo[account][tokenId][basketId].amount;
  }

  function updateInfo(address acc, uint256 tId, uint256 bId, uint256 liquidity, uint256 reward, uint256 rewardAfter, uint256 exLp, bool increase) public onlyManager {
    uint256[] memory ivar = new uint256[](6);
    ivar[0] = 0;      // prevTvl
    ivar[1] = 0;      // prevTotalReward
    ivar[2] = reward; // blockReward
    ivar[3] = 0;      // exUserLp
    ivar[4] = 0;      // userReward
    ivar[5] = 0;      // rtr
    if (poolInfoAll[tId].length > 0) {
      RewardTVLRate memory prevRTR = poolInfoAll[tId][poolInfoAll[tId].length-1];
      ivar[0] = prevRTR.tvl;
      ivar[1] = prevRTR.reward;
      ivar[2] = (ivar[2] >= prevRTR.prevReward) ? (ivar[2] - prevRTR.prevReward) : 0;
      ivar[5] = prevRTR.rtr;
    }
    ivar[5] += (ivar[0] > 0 ? ivar[2] * MULTIPLIER / ivar[0] : 0);
    
    (ivar[3], ivar[4]) = getSingleReward(acc, tId, bId, reward, false);

    bool reInvested = false;
    if (exLp > 0) {
      ReinvestInfo memory tmp = ReinvestInfo({
        reward: reward,
        liquidity: exLp,
        updatedAt: block.timestamp
      });
      reInvestInfo[tId].push(tmp);
      reInvested = true;
      ivar[3] += ivar[4] * exLp / reward;
      ivar[0] += exLp;
      userInfo[acc][tId][bId].amount += ivar[3];
      ivar[4] = 0;
    }

    RewardTVLRate memory tmpRTR = RewardTVLRate({
      reward: ivar[1] + ivar[2],
      prevReward: rewardAfter,
      tvl: increase ? ivar[0] + liquidity : (ivar[0] >= liquidity ? ivar[0] - liquidity : 0),
      rtr: ivar[5],
      reInvestIndex: reInvestInfo[tId].length,
      reInvested: reInvested,
      updatedAt: block.timestamp
    });
    poolInfoAll[tId].push(tmpRTR);
    
    if (increase) {
      userInfo[acc][tId][bId].amount += liquidity;
      userInfo[acc][tId][bId].debtReward = ivar[4];
    }
    else {
      if (userInfo[acc][tId][bId].amount >= liquidity) {
        userInfo[acc][tId][bId].amount -= liquidity;
      }
      else {
        userInfo[acc][tId][bId].amount = 0;
      }
      userInfo[acc][tId][bId].debtReward = 0;
    }
    userInfo[acc][tId][bId].rtrIndex = poolInfoAll[tId].length - 1;
    userInfo[acc][tId][bId].updatedAt = block.timestamp;
  }

  function getSingleReward(address acc, uint256 tId, uint256 bId, uint256 currentReward, bool cutfee) public view returns(uint256, uint256) {
    uint256[] memory jvar = new uint256[](7);
    jvar[0] = 0;  // extraLp
    jvar[1] = userInfo[acc][tId][bId].debtReward; // reward
    jvar[2] = userInfo[acc][tId][bId].amount;     // stake[j]
    jvar[3] = 0; // reward for one stage

    if (jvar[2] > 0) {
      uint256 t0 = userInfo[acc][tId][bId].rtrIndex;
      uint256 tn = poolInfoAll[tId].length;
      uint256 index = t0;
      while (index < tn) {
        if (poolInfoAll[tId][index].rtr >= poolInfoAll[tId][t0].rtr) {
          jvar[3] = (jvar[2] + jvar[0]) * (poolInfoAll[tId][index].rtr - poolInfoAll[tId][t0].rtr) / MULTIPLIER;
        }
        else {
          jvar[3] = 0;
        }
        if (poolInfoAll[tId][index].reInvested) {
          jvar[0] += jvar[3] * reInvestInfo[tId][poolInfoAll[tId][index].reInvestIndex-1].liquidity / reInvestInfo[tId][poolInfoAll[tId][index].reInvestIndex-1].reward;
          t0 = index;
          jvar[3] = 0;
        }
        index ++;
      }
      jvar[1] += jvar[3];

      if (poolInfoAll[tId][tn-1].tvl > 0 && currentReward >= poolInfoAll[tId][tn-1].prevReward) {
        jvar[1] = jvar[1] + (jvar[2] + jvar[0]) * (currentReward - poolInfoAll[tId][tn-1].prevReward) / poolInfoAll[tId][tn-1].tvl;
      }
    }

    if (cutfee == false) {
      return (jvar[0], jvar[1]);
    }

    (jvar[4], jvar[5]) = IFeeTierStrate(feeStrate).getTotalFee(bId);
    require(jvar[5] > 0, "LC pool ledger: wrong fee configure");
    jvar[6] = jvar[1] * jvar[4] / jvar[5]; // rewardLc

    if (jvar[6] > 0) {
      uint256[] memory feeIndexs = IFeeTierStrate(feeStrate).getAllTier();
      uint256 len = feeIndexs.length;
      uint256 maxFee = IFeeTierStrate(feeStrate).getMaxFee();
      for (uint256 i=0; i<len; i++) {
        (, ,uint256 fee) = IFeeTierStrate(feeStrate).getTier(feeIndexs[i]);
        uint256 feeAmount = jvar[6] * fee / maxFee;
        if (feeAmount > 0 && jvar[1] >= feeAmount) {
          jvar[1] -= feeAmount;
        }
      }
    }

    return (jvar[0], jvar[1]);
  }

  function getReward(address account, uint256[] memory tokenId, uint256[] memory basketIds) public view
    returns(uint256[] memory, uint256[] memory)
  {
    uint256 bLen = basketIds.length;
    uint256 len = tokenId.length * bLen;
    uint256[] memory extraLp = new uint256[](len);
    uint256[] memory reward = new uint256[](len);
    for (uint256 x = 0; x < tokenId.length; x ++) {
      uint256 currentReward = IMasterChefv3(v3MasterChef).pendingCake(tokenId[x]);
      if (poolInfoAll[tokenId[x]].length > 0) {
        currentReward += poolInfoAll[tokenId[x]][poolInfoAll[tokenId[x]].length-1].prevReward;
      }
      for (uint256 y = 0; y < bLen; y ++) {
        (extraLp[x*bLen + y], reward[x*bLen + y]) = getSingleReward(account, tokenId[x], basketIds[y], currentReward, true);
      }
    }
    return (extraLp, reward);
  }

  function poolInfoLength(uint256 tokenId) public view returns(uint256) {
    return poolInfoAll[tokenId].length;
  }

  function reInvestInfoLength(uint256 tokenId) public view returns(uint256) {
    return reInvestInfo[tokenId].length;
  }

  function setManager(address account, bool access) public onlyOwner {
    managers[account] = access;
  }

  function setFeeStrate(address _feeStrate) external onlyManager {
    require(_feeStrate != address(0), "LC pool ledger: Fee Strate");
    feeStrate = _feeStrate;
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity >=0.8.0 <0.9.0;

import "./Context.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity >=0.8.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface INonfungiblePositionManagerStruct {
  struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
  }
}// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./INonfungiblePositionManagerStruct.sol";

interface IMasterChefv3 is INonfungiblePositionManagerStruct {
  function decreaseLiquidity(
    DecreaseLiquidityParams memory params
  ) external payable returns (uint256 amount0, uint256 amount1);
  
  function increaseLiquidity(
    IncreaseLiquidityParams memory params
  ) external payable returns (uint128 liquidity, uint256 amount0, uint256 amount1);

  function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

  function withdraw(uint256 _tokenId, address _to) external returns (uint256 reward);

  function harvest(uint256 _tokenId, address _to) external returns (uint256 reward);

  function pendingCake(uint256 _tokenId) external view returns (uint256 reward);
}// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IFeeTierStrate {
  function getMaxFee() external view returns(uint256);
  function getDepositFee(uint256 id) external view returns(uint256, uint256);
  function getTotalFee(uint256 id) external view returns(uint256, uint256);
  function getWithdrawFee(uint256 id) external view returns(uint256, uint256);
  function getAllTier() external view returns(uint256[] memory);
  function getTier(uint256 index) external view returns(address, string memory, uint256);
}