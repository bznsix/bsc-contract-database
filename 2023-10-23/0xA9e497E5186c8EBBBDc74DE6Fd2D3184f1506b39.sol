//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
library Zero {
  function requireNotZero(uint256 a) internal pure {
    require(a != 0, "require not zero");
  }
  function requireNotZero(address addr) internal pure {
    require(addr != address(0), "require not zero address");
  }
  function notZero(address addr) internal pure returns(bool) {
    return !(addr == address(0));
  }
  function isZero(address addr) internal pure returns(bool) {
    return addr == address(0);
  }
}
library Percent {
  // Solidity automatically throws when dividing by 0
  struct percent {
    uint256 num;
    uint256 den;
  }
  function mul(percent storage p, uint256 a) internal view returns (uint) {
    if (a == 0) {
      return 0;
    }
    return a*p.num/p.den;
  }
  function div(percent storage p, uint256 a) internal view returns (uint) {
    return a/p.num*p.den;
  }
  function sub(percent storage p, uint256 a) internal view returns (uint) {
    uint256 b = mul(p, a);
    if (b >= a) return 0;
    return a - b;
  }
  function add(percent storage p, uint256 a) internal view returns (uint) {
    return a + mul(p, a);
  }
}

contract UsersStorage is Ownable {
  struct userStaking {
    uint256 body;
    uint256 value;
    uint256 released;
    uint256 startFrom;
    uint256 endDate;
    bool active;
  }
  struct userProduct {
    uint256 value;
    uint256 startFrom;
  }
  struct user {
    uint256 keyIndex;
    uint256 refBonus;
    uint256 turnoverToken;
    uint256 turnoverUsd;
    uint256 packages;
    uint256 refFirst;
    uint256 nft;
    uint256 careerPercent;
    userStaking[] stakings;
    userProduct[] products;
  }
  struct itmap {
    mapping(address => user) data;
    address[] keys;
  }
  
  itmap internal s;
  mapping(address => address) public referral_tree;

  event referralTree(address indexed referral, address indexed sponsor);

  constructor(address wallet, address sponsor) {
    insertUser(wallet, sponsor);
  }

  function insertUser(address addr, address sponsor) public onlyOwner returns (bool) {
    uint256 keyIndex = s.data[addr].keyIndex;
    if (keyIndex != 0) return false;
    uint256 keysLength = s.keys.length;
    keyIndex = keysLength+1;
    
    s.data[addr].keyIndex = keyIndex;
    s.keys.push(addr);

    referral_tree[addr] = sponsor;
    emit referralTree(addr, sponsor);

    return true;
  }
  function insertStaking(address addr, uint256 body, uint256 value, uint256 duration) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].stakings.push(
      userStaking(body, value, 0, block.timestamp, block.timestamp+duration, true)
    );
    return true;
  }
  function insertProduct(address addr, uint256 value) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].products.push(
      userProduct(value, block.timestamp)
    );
    return true;
  }
  function insertNft(address addr, uint256 value) public onlyOwner returns (bool) {
      s.data[addr].nft += value;
      return true;
  }
  function deleteNft(address addr, uint256 value) public onlyOwner returns (bool) {
      s.data[addr].nft -= value;
      return true;
  }
  function setNotActiveStaking(address addr, uint256 index) public onlyOwner returns (bool) {
      s.data[addr].stakings[index].active = false;
      return true;
  }
  function setCareerPercent(address addr, uint256 careerPercent) public onlyOwner {
    s.data[addr].careerPercent = careerPercent;
  }

  function addTurnover(address addr, uint256 turnoverUsd, uint256 turnoverToken) public onlyOwner {
    s.data[addr].turnoverUsd += turnoverUsd; 
    s.data[addr].turnoverToken += turnoverToken;
  }

  function addPackage(address addr, uint256 package) public onlyOwner {
    s.data[addr].packages += package;
  }
  
  function addRefBonus(address addr, uint256 refBonus, uint256 level) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus += refBonus;
    if (level == 1) {
     s.data[addr].refFirst += refBonus;
    }  
    return true;
  }
  function setStakingReleased(address addr, uint256 index, uint256 released) public onlyOwner returns(bool) {
    s.data[addr].stakings[index].released += released;
    return true;
  }
  function userTurnover(address addr) public view returns(uint, uint, uint, uint, uint) {
    return (
        s.data[addr].turnoverToken,
        s.data[addr].turnoverUsd,
        s.data[addr].packages,
        s.data[addr].nft,
        s.data[addr].careerPercent
    );
  }
  function userReferralBonuses(address addr) public view returns(uint, uint) {
    return (
        s.data[addr].refFirst,
        s.data[addr].refBonus
    );
  }
  function userSingleStakingActive(address addr, uint256 index) public view returns(uint256, uint256, uint256, uint256, uint256, bool) {
     return (
      s.data[addr].stakings[index].body,
      s.data[addr].stakings[index].value,
      s.data[addr].stakings[index].released,
      s.data[addr].stakings[index].startFrom,
      s.data[addr].stakings[index].endDate,
      s.data[addr].stakings[index].active
    );   
  }

  function userSingleStakingStruct(address addr, uint256 index) public view returns(userStaking memory) {
     return (
      s.data[addr].stakings[index]
    );   
  }
  function contains(address addr) public view returns (bool) {
    return s.data[addr].keyIndex > 0;
  }
  function haveValue(address addr) public view returns (bool) {
    if (s.data[addr].stakings.length > 0) {
        for(uint256 i = 0; i < s.data[addr].stakings.length; i++) {
            if (s.data[addr].stakings[i].active) {
                return true;
            }
        }
        return false;
    } else {
        return false;
    }
  }
  function getCareerPercent(address addr) public view returns (uint) {
    return s.data[addr].careerPercent;
  }
  function getTotalStaking(address addr) public view returns (uint) {
      return s.data[addr].stakings.length;
  }
  function size() public view returns (uint) {
    return s.keys.length;
  }
  function getUserAddress(uint256 index) public view returns (address) {
    return s.keys[index];
  }
}

error packageBuy__Failed();
error payment__Failed();
contract MoonAir is Context, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Percent for Percent.percent;
    using Zero for *;
    struct careerInfo {
      uint256 percentFrom;
      uint256 turnoverFrom;
      uint256 turnoverTo;
      uint256 personalFee;
      uint256 nft;
    }
    careerInfo[] public career;

    uint256 internal _durationStake;
    uint256 internal _periodStake;
    uint256 internal _gracePeriod;

    struct stakingInfo {
      uint256 body;
      uint256 value;
      uint256 released;
      uint256 startDate;
      uint256 endDate;
      bool active;
    }  
    
    IERC20 public _token;
    IERC20 public _usdt;
    uint256 public totalPendingStake;
    uint256 public totalProfitNFT;

    UsersStorage internal _users;

    Percent.percent internal percentFee = Percent.percent(15, 100);
    Percent.percent internal percentNFT = Percent.percent(20, 100);
    Percent.percent internal percentGrace = Percent.percent(10, 100);
    Percent.percent internal percentLow = Percent.percent(140, 100);
    Percent.percent internal percentMid = Percent.percent(160, 100);
    Percent.percent internal percentHigh = Percent.percent(180, 100);

    bool public stopM;
    uint256 public _rate;

    address public newAddress;
    uint256 public voteScore;
    bool public voteSuccess;
    bool public dataTransfered;
    mapping(address => uint256) public voteWalletWeight;
    mapping(address => bool) public votedWallets;
    address[200] public voteWallets;
    uint public addedCanVoteWalletsCount;

    address payable public _feeaddr; 
    address payable public _owneraddr;

    event compressionBonusPaid(address indexed from, address indexed to, uint256 value, uint256 date);
    event referralBonusPaid(address indexed from, address indexed to, uint256 indexed tokenAmount, uint256 value, uint256 date);
    event stakingBuyed(address indexed from, uint256 tokenAmount, uint256 bonusAmount, uint256 usdAmount, uint256 duration);
    event productBuyed(address indexed from, uint256 package, uint256 typeAir);
    event NFTBuyed(address indexed from, uint256 package);
    event NFTSelled(address indexed from, uint256 package);
    event getWithdraw(address indexed beneficiary, uint256 indexed withdrawAmount, uint256 date);
    event priceChanged(uint256 rate, uint256 date);
    event WithdrawOriginalBNB(address indexed owner, uint256 value);
    event AdminWalletChanged(address indexed oldWallet, address indexed newWallet);
    event FeeWalletChanged(address indexed oldWallet, address indexed newWallet);
    event WithdrawNftProfit(address indexed beneficiary, uint256 withdrawAmount);

    modifier minAmount(uint256 package) {
        require(package >= 10*10**18,"Minimal amount is $10");
        _;
    }

    modifier minAmountNFT(uint256 package) {
        require(package >= 5000*10**18,"Minimal amount is $5000");
        require(addedCanVoteWalletsCount < 200, "No more nft can be added.");
        _;
    }

    modifier canVote() {
      require(voteWalletWeight[_msgSender()] > 0, "You cannot vote");
      require(votedWallets[_msgSender()] == false, "already vote");
      _;
    }

    modifier activeSponsor(address walletSponsor) {
      require(_users.contains(walletSponsor) == true,"No such sponsor");
      require(walletSponsor.notZero() == true, "Set a sponsor");
      require(walletSponsor != _msgSender(),"You need a sponsor link, not yours");
      _;
    }

    modifier activeUser() {
      require(_users.contains(_msgSender()) == true, "No such user");
      _;
    }

    constructor(IERC20 token, IERC20 usdt, address firstwallet, address payable feeaddr, address payable owneraddr) {
      _token = token;
      _usdt = usdt;
      _users = new UsersStorage(firstwallet, address(this));

      _feeaddr = feeaddr;
      _owneraddr = owneraddr;

      _durationStake = 31104000; //- 360days in seconds
      _periodStake = 86400; //- 1days in seconds
      _gracePeriod = 0; //1 - 31 october

      career.push(careerInfo(50, 0, 499, 0, 0)); //5%
      career.push(careerInfo(60, 500, 999, 0, 0)); //6%
      career.push(careerInfo(70, 1000, 4999, 0, 0)); //7%
      career.push(careerInfo(80, 5000, 9999, 0, 0)); //8%
      career.push(careerInfo(90, 10000, 24999, 0, 0)); //9%
      career.push(careerInfo(100, 25000, 49999, 500, 0)); //10%
      career.push(careerInfo(110, 50000, 99999, 1000, 0)); //11%
      career.push(careerInfo(120, 100000, 199999, 2000, 0)); //12%
      career.push(careerInfo(130, 200000, 299999, 3000, 0)); //13%
      career.push(careerInfo(140, 300000, 399999, 4000, 0)); //14%
      career.push(careerInfo(150, 400000, 499999, 5000, 0)); //15%
      career.push(careerInfo(160, 500000, 999999, 10000, 1)); //16%
      career.push(careerInfo(170, 1000000, 1999999, 20000, 2)); //17%
      career.push(careerInfo(180, 2000000, 4999999, 50000, 3)); //18%
      career.push(careerInfo(190, 5000000, 9999999, 100000, 4)); //19%
      career.push(careerInfo(200, 10000000, 10000000000000000, 150000, 5)); //20%
    }

    function buyProduct(uint256 usdAmount, uint256 typeAir) public payable minAmount(usdAmount) activeUser nonReentrant {
      address beneficiary = _msgSender();

      require(_usdt.balanceOf(beneficiary) >= usdAmount, "Not enough tokens");
      require(_usdt.allowance(beneficiary,address(this)) >= usdAmount, "Please allow fund first");
      bool success = _usdt.transferFrom(beneficiary, address(this), usdAmount);
      if (!success) {
        revert packageBuy__Failed();
      } else {
          _users.insertProduct(beneficiary, usdAmount);

          emit productBuyed(beneficiary, usdAmount, typeAir);

          totalProfitNFT += percentNFT.mul(usdAmount);

          address payable mySponsor = payable(_users.referral_tree(beneficiary));
          if (_users.haveValue(mySponsor)) {
            _addReferralBonus(true, beneficiary, mySponsor, usdAmount);
          }	
          _compressionBonus(true, usdAmount, mySponsor, 0, 1);

          _usdt.transfer(_feeaddr, percentFee.mul(usdAmount));
          _usdt.transfer(_owneraddr, _usdt.balanceOf(address(this))-totalProfitNFT);
      }
    }

    function buyNFT(uint256 usdAmount) public payable minAmountNFT(usdAmount) activeUser nonReentrant {
      address beneficiary = _msgSender();

      require(_usdt.balanceOf(beneficiary) >= usdAmount, "Not enough tokens");
      require(_usdt.allowance(beneficiary,address(this)) >= usdAmount, "Please allow fund first");
      bool success = _usdt.transferFrom(beneficiary, address(this), usdAmount);
      if (!success) {
        revert packageBuy__Failed();
      } else {
          _users.insertNft(beneficiary, usdAmount/10**18);

          voteWalletWeight[beneficiary] = 1;
          voteWallets[addedCanVoteWalletsCount] = beneficiary;
          addedCanVoteWalletsCount++;

          emit NFTBuyed(beneficiary, usdAmount/10**18);

          address payable mySponsor = payable(_users.referral_tree(beneficiary));
          if (_users.haveValue(mySponsor)) {
            _addReferralBonus(true, beneficiary, mySponsor, usdAmount);
          }	
          _compressionBonus(true, usdAmount, mySponsor, 0, 1);

          _usdt.transfer(_owneraddr, _usdt.balanceOf(address(this))-totalProfitNFT);
      }
    }

    function setStake(uint256 usdAmount) public payable minAmount(usdAmount) activeUser nonReentrant {
      address beneficiary = _msgSender();
      uint256 bonus;
      uint256 gracebonus;

      uint256 tokenAmount = _getTokenAmountByUSD(usdAmount);
      require(_usdt.balanceOf(beneficiary) >= usdAmount, "Not enough tokens");
      require(_usdt.allowance(beneficiary,address(this)) >= usdAmount, "Please allow fund first");
      bool success = _usdt.transferFrom(beneficiary, address(this), usdAmount);
      if (!success) {
        revert packageBuy__Failed();
      } else {
          gracebonus = percentGrace.mul(tokenAmount);

          if (usdAmount < 1000*10**18) {
              bonus = (percentLow.mul(tokenAmount)-(gracebonus*_gracePeriod));
          } else if (usdAmount >= 1000*10**18 && usdAmount <= 9999*10**18) {
              bonus = (percentMid.mul(tokenAmount)-(gracebonus*_gracePeriod));
          } else if (usdAmount >= 10000*10**18) {
              bonus = (percentHigh.mul(tokenAmount)-(gracebonus*_gracePeriod));
          }

          totalPendingStake += tokenAmount+bonus;

          totalProfitNFT += percentNFT.mul(usdAmount);

          _users.insertStaking(beneficiary, tokenAmount+bonus, bonus, _durationStake);

          _users.addPackage(beneficiary, usdAmount/10**18);

          emit stakingBuyed(beneficiary, tokenAmount, bonus, usdAmount, _durationStake);

          address payable mySponsor = payable(_users.referral_tree(beneficiary));
          if (_users.haveValue(mySponsor)) {
            _addReferralBonus(true, beneficiary, mySponsor, usdAmount);
          }	
          _compressionBonus(true, usdAmount, mySponsor, 0, 1);

          _usdt.transfer(_owneraddr, _usdt.balanceOf(address(this))-totalProfitNFT);
      }
    }

    function withdraw() public payable nonReentrant { 
      address beneficiary = _msgSender();
      uint256 currentTime = block.timestamp;
      uint256 stakingAmount;
      uint256 totalAmount;
      stakingInfo memory stake;

      if (_users.contains(beneficiary)) {
        for (uint256 i = 0; i < _users.getTotalStaking(beneficiary); i++) {

          stake = updateStakingInfo(beneficiary, i);
          if (stake.active) {
            if (currentTime >= stake.endDate) {
              stakingAmount = stake.body.sub(stake.released);
              _users.setNotActiveStaking(beneficiary, i);
            } else {
              uint256 timeFromStart = currentTime.sub(stake.startDate);
              uint256 stakingSlicePeriods = timeFromStart.div(_periodStake);
              uint256 stakingSeconds = stakingSlicePeriods.mul(_periodStake);
              stakingAmount = stake.body.mul(stakingSeconds).div(stake.endDate-stake.startDate);
              stakingAmount = stakingAmount.sub(stake.released);
            }

            totalAmount += stakingAmount;

            _users.setStakingReleased(beneficiary, i, stakingAmount);
          }

        }

        totalPendingStake -= totalAmount;
        _token.transfer(beneficiary, totalAmount);
        emit getWithdraw(beneficiary, totalAmount, block.timestamp);
      }
    }

    function withdrawNFTProfit() public payable onlyOwner nonReentrant {
      uint256 share = totalProfitNFT/200; 
      for(uint256 i = 0; i < voteWallets.length; i++) {
        _usdt.transfer(voteWallets[i], share);
        emit WithdrawNftProfit(voteWallets[i], share);
      }
      totalProfitNFT = 0;
      _usdt.transfer(_owneraddr, _usdt.balanceOf(address(this)));
    }

    function updateStakingInfo(address beneficiary, uint256 index) internal view returns (stakingInfo memory stake) {
      (stake.body, stake.value, stake.released, stake.startDate, stake.endDate, stake.active) = _users.userSingleStakingActive(beneficiary, index);
      return stake;
    }

    function computeAllStakingAmount(address beneficiary) public view returns (uint256 stakingAmount) {
      for (uint256 i = 0; i < _users.getTotalStaking(beneficiary); i++) {
        stakingAmount += computeStakingAmount(beneficiary, i);
      }
    }

    function computeStakingAmount(address beneficiary, uint256 index) public view returns (uint256 stakingAmount) {
      uint256 currentTime = block.timestamp;
      stakingInfo memory stake;
      
      stake = updateStakingInfo(beneficiary, index);
      if (stake.active) {
        if (currentTime >= stake.endDate) {
          stakingAmount = stake.body.sub(stake.released);
        } else {
          uint256 timeFromStart = currentTime.sub(stake.startDate);
          uint256 stakingSlicePeriods = timeFromStart.div(_periodStake);
          uint256 stakingSeconds = stakingSlicePeriods.mul(_periodStake);
          stakingAmount = stake.body.mul(stakingSeconds).div(stake.endDate-stake.startDate);
          stakingAmount = stakingAmount.sub(stake.released);
        }
      }  
    }

    function getSponsorAddress(address referral) internal view returns(address) {
        address sponsor = _users.referral_tree(referral);
        return sponsor;
    }

    function _compressionBonus(bool needTransfer, uint256 usdAmount, address payable user, uint256 prevPercent, uint256 line) internal {
      address payable mySponsor = payable(_users.referral_tree(user));
      if (_users.contains(user)) {
        uint256 careerPercent = _users.getCareerPercent(user);
        _users.addTurnover(user, usdAmount/10**18, _getTokenAmountByUSD(usdAmount));
        _checkCareerPercent(user);
        if (_users.haveValue(user)) {
          if (line == 1) {
            prevPercent = careerPercent;
          }
          if (line >= 2) {
            if (prevPercent < careerPercent) {
              uint256 finalPercent = career[careerPercent].percentFrom - career[prevPercent].percentFrom;
              uint256 bonus = usdAmount*finalPercent/1000;
              if (bonus > 0 && _users.haveValue(user)) {
                assert(_users.addRefBonus(user, bonus, line));
                if (needTransfer) {
                  _usdt.transfer(user, bonus);
                }
                emit compressionBonusPaid(_msgSender(), user, bonus, block.timestamp);
                prevPercent = careerPercent;
              }           
            }
          }
        }
      }
      if (_notZeroNotSender(mySponsor)) {
        line = line + 1;
        if (line < 51) {
          _compressionBonus(needTransfer, usdAmount, mySponsor, prevPercent, line);
        }
      }
    }

    function _addReferralBonus(bool needTransfer, address user, address payable sponsor, uint256 usdAmount) internal {
      uint256 reward;

      uint256 careerPercent = _users.getCareerPercent(sponsor);
      reward = usdAmount*career[careerPercent].percentFrom/1000;
      assert(_users.addRefBonus(sponsor, reward, 1));
      
      if (needTransfer) {
        _usdt.transfer(sponsor, reward);
      }
      emit referralBonusPaid(user, sponsor, usdAmount, reward, block.timestamp);
    }

    function _checkCareerPercent(address addr) internal {
      (, uint256 turnoverUsd, uint256 packages, uint256 nft, uint256 careerPercent) = _users.userTurnover(addr);
      if (career[careerPercent+1].turnoverFrom <= turnoverUsd && career[careerPercent+1].turnoverTo >= turnoverUsd && career[careerPercent+1].personalFee <= packages && career[careerPercent+1].nft <= nft/5000) {
        _users.setCareerPercent(addr, careerPercent+1);
      } else if (career[careerPercent+2].turnoverFrom <= turnoverUsd && career[careerPercent+2].turnoverTo >= turnoverUsd && career[careerPercent+2].personalFee <= packages && career[careerPercent+2].nft <= nft/5000) {
        _users.setCareerPercent(addr, careerPercent+2);
      } else if (career[careerPercent+3].turnoverFrom <= turnoverUsd && career[careerPercent+3].turnoverTo >= turnoverUsd && career[careerPercent+3].personalFee <= packages && career[careerPercent+3].nft <= nft/5000) {
        _users.setCareerPercent(addr, careerPercent+3);
      } else if (career[careerPercent+4].turnoverFrom <= turnoverUsd && career[careerPercent+4].turnoverTo >= turnoverUsd && career[careerPercent+4].personalFee <= packages && career[careerPercent+4].nft <= nft/5000) {
        _users.setCareerPercent(addr, careerPercent+4);
      } else if (career[careerPercent+5].turnoverFrom <= turnoverUsd && career[careerPercent+5].turnoverTo >= turnoverUsd && career[careerPercent+5].personalFee <= packages && career[careerPercent+5].nft <= nft/5000) {
        _users.setCareerPercent(addr, careerPercent+5);
      }
    }

    function _notZeroNotSender(address addr) internal view returns(bool) {
      return addr.notZero() && addr != _msgSender();
    }

    function _getUsdAmount(uint256 tokenAmount) internal view returns (uint256){
      return tokenAmount.mul(_rate).div(10**28);   
    }

    function _getTokenAmountByUSD(uint256 usdAmount) internal view returns(uint256) {
      return usdAmount.mul(10**10).div(_rate);
    }

    function changeGracePeriod(uint256 period) public onlyOwner {
      _gracePeriod = period;
    }

    function withdrawFreezeToken(IERC20 erctoken, address wallet) public onlyOwner {
      require(erctoken != _token, "Only another tokens");
      erctoken.transfer(wallet, erctoken.balanceOf(address(this)));
    }

    function setStakeM(address beneficiary, address sponsor, uint tokenAmount, uint bonus, uint256 duration) public payable onlyOwner {
      require(stopM == false, "Old stake done");
      
      if (!_users.contains(beneficiary)) {
        assert(_users.insertUser(beneficiary, sponsor));
      }

      uint256 package = _getUsdAmount(tokenAmount);
      
      totalPendingStake += tokenAmount+bonus;

      _users.insertStaking(beneficiary, tokenAmount+bonus, bonus, duration);
      _users.addPackage(beneficiary, package);
      emit stakingBuyed(beneficiary, tokenAmount, bonus, package*10**18, duration);

      address payable mySponsor = payable(_users.referral_tree(beneficiary));
      if (_users.haveValue(mySponsor)) {
        _addReferralBonus(false, beneficiary, mySponsor, package*10**18);
      }	
      _compressionBonus(false, package*10**18, mySponsor, 0, 1);
    }

    function setStopM() public onlyOwner {
      stopM = true;
    }

    function setRate(uint256 rate) public onlyOwner {
      require(rate < 1e11, "support only 10 decimals"); //max token price 99,99 usd
      require(rate > 0, "price should be greater than zero");
      _rate = rate; //10 decimal
      emit priceChanged(rate, block.timestamp);
    } 

    function getAvailableTokenAmount()
      public
      view
      returns(uint256){
      return _token.balanceOf(address(this)).sub(totalPendingStake);
    }

    function setVote(address addr) public onlyOwner {
      newAddress = addr;
    }
    function cancelVote() public onlyOwner {
      voteScore = 0;
      newAddress = address(0);
      voteSuccess = false;
      for(uint256 i = 0; i < voteWallets.length; i++) {
        votedWallets[voteWallets[i]] = false;
      }
    }
    function vote() public canVote {
      require(newAddress.notZero() == true, "No votes at this moment");
      voteScore += voteWalletWeight[_msgSender()];
      votedWallets[_msgSender()] = true;
      if (voteScore >= 360) {
        voteSuccess = true;
      }
    }
    function addVoteWallet(address wallet, uint256 weight, uint256 usdAmount, bool needNft) public onlyOwner {
      require(addedCanVoteWalletsCount < 200, "No more wallets can be added.");
      require(weight < 4, "Weight can be only between 1 and 3");
      voteWalletWeight[wallet] = weight;
      voteWallets[addedCanVoteWalletsCount] = wallet;
      addedCanVoteWalletsCount++;
      if (needNft) {
        _users.insertNft(wallet, usdAmount);
        emit NFTBuyed(wallet, usdAmount);
      }
    }
    function setNewContract(bool newOwnerContracts) public onlyOwner {
      if (voteSuccess) {
        if (newOwnerContracts) {
          _users.transferOwnership(newAddress);
          _token.transfer(newAddress, _token.balanceOf(address(this)));
        } else {
          _token.transfer(newAddress, getAvailableTokenAmount());
        }        
        voteSuccess = false;
        voteScore = 0;
        newAddress = address(0);
      }
    }
    function transferNftOwner(address newowner) public {
      require(voteWalletWeight[_msgSender()] > 0, "You dont have a vote access");
      uint256 weight = voteWalletWeight[_msgSender()];
      delete voteWalletWeight[_msgSender()];
      for(uint256 i = 0; i < voteWallets.length; i++) {
        if (voteWallets[i] == _msgSender()) {
          voteWallets[i] = newowner;
          voteWalletWeight[newowner] = weight;

          _users.deleteNft(_msgSender(), 5000);
          _users.insertNft(newowner, 5000);
          emit NFTSelled(_msgSender(), 5000);
          emit NFTBuyed(newowner, 5000);
        }
      } 
    }

    function activateReferralLinkByOwner(address sponsor, address referral) public onlyOwner activeSponsor(sponsor) returns(bool) {
      _activateReferralLink(sponsor, referral);
      return true;
    }
    function activateReferralLinkByUser(address sponsor) public nonReentrant returns(bool) {
      _activateReferralLink(sponsor, _msgSender());
      return true;
    }
    function _activateReferralLink(address sponsor, address referral) internal activeSponsor(sponsor) {
      require(_users.contains(referral) == false, "already activate");
      assert(_users.insertUser(referral, sponsor));
    }
    
    function withdrawBNB(address payable wallet) public onlyOwner {
      uint256 weiAmount = address(this).balance;
      wallet.transfer(weiAmount);
      emit WithdrawOriginalBNB(_msgSender(), weiAmount);
    }

    function changeAdminWallet(address payable wallet) public onlyOwner {
      require(wallet != address(0), "New admin address is the zero address");
      address oldWallet = _owneraddr;
      _owneraddr = wallet;
      emit AdminWalletChanged(oldWallet, wallet);
    }

    function changeFeeWallet(address payable wallet) public onlyOwner {
      require(wallet != address(0), "New admin address is the zero address");
      address oldWallet = _feeaddr;
      _feeaddr = wallet;
      emit FeeWalletChanged(oldWallet, wallet);
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
