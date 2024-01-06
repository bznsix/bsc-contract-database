// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "ERC20.sol";
import "Ownable.sol";
import "Address.sol";
import "IRouter.sol";

contract BTLToken is ERC20, Ownable {
    using Address for address;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    bool private _swapping;
    uint256 public constant SELL_BURN_FEE = 150;
    uint256 public constant SELL_NFT_FEE = 50;
    uint256 public constant DAY_BLOCK = 28800;
    uint256 public constant PER_DAY_REWARD = 18;
    uint256 public constant MAX_DEPTH = 50;
    uint128 public constant REWARD_RATIO = 325;
    uint128 public constant LP_BUILDER_RATIO = 375;
    uint128 public constant LP_ADDED_RATIO = 50;
    uint128 public constant SECURE_POOL_RATIO = 50;
    uint128 public constant NFT_REWARD_RATIO = 140;
    uint128 public constant REFER_REWARD_RATIO = 60;
    uint128 private constant PERCENT_BASE = 1e3;
    uint128 private constant LP_DAYS = 35;
    uint256[3] public REFER_RATIO = [500, 500, 0];
    uint256[10] public shareRateList = [10, 10, 10, 5, 5, 5, 5, 5, 5, 5];

    uint256 public rewardPoolAmount;
    uint256 public nftRewardBNBAmount;
    uint256 public nftRewardTokenAmount;
    uint256 public lpAddedAmount;
    uint256 public lpAddedTokenAmount;
    uint256 public referRewardsAmount;

    uint256 public preBuyAmount;
    uint256 public ecologyRewardAmount;
    uint256 public totalUser;
    uint256 public totalInvestTime;
    uint256 public totalValue;
    uint256 public totalWithdrawalValueBNB;
    uint256 public totalWithdrawalValueToken;

    address public dev;

    address public ecologyRewards = 0xa4A7D7d05209b4560984320A5aF240f1f2626D2b;
    address public nftRewardsBNB = 0x294D7DFe544f4a47e401f9a881C1c38456910787;
    address public nftRewardsToken = 0xbfa918417C67D6Ff453BF6CF1FAB25c3855A99c2;

    IRouter public immutable uniswapV2Router;
    address public pair;
    address public wallet = 0x9999999999999999999999999999999999999999;
    bool public investStatus;

    address[] public NftGroup;
    mapping(address => address) public userTop;
    mapping(address => uint256) public userLastActionBlock;
    mapping(address => uint256) public userInvestBNBAmount;
    mapping(address => uint256) public userShareLevel;
    mapping(address => uint256) public userPrebuyBNBAmount;
    mapping(address => uint256) public userClaimRewardBNBValue;
    mapping(address => uint256) public userClaimRewardBNBAmount;
    mapping(address => uint256) public userClaimRewardTokenAmount;
    mapping(address => uint256) public userInviteAddr;
    mapping(address => uint256) public userTotalShareAddr;
    mapping(address => uint256) public teamTotalAddr;
    mapping(address => uint256) public teamTotalInvestValue;

    mapping(address => uint256) public pendingShareRewards;
    mapping(address => uint256) public claimedShareRewards;
    mapping(address => uint256) public pendingTeamRewards;
    mapping(address => uint256) public claimedTeamRewards;

    mapping(address => bool) private _noneFee;
    mapping(address => bool) private _nftGroupMembers;
    mapping(address => UserPreBuy) public userPreBuyList;
    mapping(address => address[]) public children;

    struct UserPreBuy {
        uint256 investAmount;
        uint256 totalPreAmount;
        uint256 remainPreAmount;
        uint256 daysBuyAmount;
        uint256 addedDays;
    }

    event Invest(address indexed from, uint256 indexed times, uint256 value);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        IRouter uniswapV2Router_
    ) payable ERC20(name_, symbol_) {
        dev = owner();
        uniswapV2Router = uniswapV2Router_;
        _mint(dev, totalSupply_ * 10 ** decimals());
        userTop[dev] = address(1);
        _noneFee[dev] = true;
        _noneFee[address(uniswapV2Router)] = true;
    }

    function commons() external view
    returns (
        uint256 _rewardPoolAmount,
        uint256 _preBuyAmount,
        uint256 _ecologyRewardAmount,
        uint256 _totalUser,
        uint256 _totalInvestTime,
        uint256 _totalValue,
        uint256 _totalWithdrawalValueBNB,
        uint256 _totalWithdrawalValueToken,
        uint256 _day_block,
        uint256 _perDayReward,
        uint256 _lpAddedAmount,
        uint256 _lpAddedTokenAmount,
        uint256 _nftRewardBNBAmount,
        uint256 _referRewardsAmount
    )
    {
        _day_block = DAY_BLOCK;
        _perDayReward = PER_DAY_REWARD;
        _rewardPoolAmount = rewardPoolAmount;
        _preBuyAmount = preBuyAmount;
        _nftRewardBNBAmount = nftRewardBNBAmount;
        _totalWithdrawalValueToken = totalWithdrawalValueToken;
        _totalWithdrawalValueBNB = totalWithdrawalValueBNB;
        _ecologyRewardAmount = ecologyRewardAmount;
        _totalUser = totalUser;
        _totalInvestTime = totalInvestTime;
        _totalValue = totalValue;
        _lpAddedAmount = lpAddedAmount;
        _lpAddedTokenAmount = lpAddedTokenAmount;
        _referRewardsAmount = referRewardsAmount;
    }

    function infos(address _addr) external view
    returns (
        address _userTop,
        uint256 _userClaimRewardBNBValue,
        uint256 _userClaimRewardBNBAmount,
        uint256 _userClaimRewardTokenAmount,
        uint256 _userLastActionBlock,
        uint256 _userInvestBNBAmount,
        uint256 _userInviteAddr,
        uint256 _userTotalShareAddr,
        uint256 _teamTotalAddr,
        uint256 _teamTotalInvestValue,
        uint256 _userPrebuyBNBAmount,
        uint256 _userShareLevel,
        bool _isNftMember
    )
    {
        _userTop = userTop[_addr];
        _userLastActionBlock = userLastActionBlock[_addr];
        _userInvestBNBAmount = userInvestBNBAmount[_addr];
        _userPrebuyBNBAmount = userPrebuyBNBAmount[_addr];
        _userClaimRewardBNBValue = userClaimRewardBNBValue[_addr];
        _userClaimRewardBNBAmount = userClaimRewardBNBAmount[_addr];
        _userClaimRewardTokenAmount = userClaimRewardTokenAmount[_addr];
        _userInviteAddr = userInviteAddr[_addr];
        _userTotalShareAddr = userTotalShareAddr[_addr];
        _teamTotalAddr = teamTotalAddr[_addr];
        _teamTotalInvestValue = teamTotalInvestValue[_addr];
        _userShareLevel = userShareLevel[_addr];
        _isNftMember = _nftGroupMembers[_addr];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != to, "Same");
        require(amount > 0, "Zero");
        if (_swapping) {
            super._transfer(from, to, amount);
            return;
        }
        if (from == pair) {
            revert("Buy Forbid");
        }

        if (to == address(this)) {
            address sender = msg.sender;
            require(sender == from, "Bot");
            super._transfer(from, to, amount);
            uint256 userInvestAmount = userInvestBNBAmount[sender];

            if (
                userInvestAmount == 0 ||
                userLastActionBlock[sender] == 0 ||
                (userLastActionBlock[sender] + DAY_BLOCK) > block.number
            ) {
                return;
            }

            uint256 userInvestDay = _getInvestDay(sender);
            uint256 staticPending = _getStaticPendingAmount(sender);

            _distributedShareDepthReward(sender, staticPending);
            _distributedLevelRewards(sender, staticPending);

            uint256 myShareRewards = pendingShareRewards[sender];
            uint256 myTeamRewards = pendingTeamRewards[sender];
            uint256 myTotalRewards = staticPending + myShareRewards + myTeamRewards;
            uint256 myDynamic = myShareRewards + myTeamRewards;

            _countLpAndBuy(sender, userInvestDay);

            claimedShareRewards[sender] += myShareRewards;
            claimedTeamRewards[sender] += myTeamRewards;
            pendingShareRewards[sender] = 0;
            pendingTeamRewards[sender] = 0;

            if (
                (userClaimRewardBNBValue[sender] + myTotalRewards) >= (userInvestAmount * 150) / 100
            ) {
                myTotalRewards = ((userInvestAmount * 150) / 100) - userClaimRewardBNBValue[sender];
            }

            uint256 distributedStaticAmount;
            uint256 distributedDynamicAmount;
            if (myTotalRewards >= staticPending) {
                distributedStaticAmount = staticPending;
                distributedDynamicAmount = myTotalRewards - staticPending;
            } else {
                distributedStaticAmount = myTotalRewards;
                distributedDynamicAmount = 0;
            }

            _distributedRewards(sender, distributedStaticAmount, distributedDynamicAmount);
            _checkAndInitUser(sender);
            return;
        }

        uint256 sellFeeAmount;
        uint256 sellNftAmount;
        if (to == pair) {
            if (!_noneFee[from]) {
                sellFeeAmount = (amount * SELL_BURN_FEE) / PERCENT_BASE;
                sellNftAmount = (amount * SELL_NFT_FEE) / PERCENT_BASE;
            }
        }
        if (sellNftAmount > 0) {
            nftRewardTokenAmount += sellNftAmount;
            super._transfer(from, nftRewardsToken, sellNftAmount);
        }
        if (sellFeeAmount > 0) {
            super._transfer(from, DEAD, sellFeeAmount);
        }
        uint256 transAmount = amount - sellFeeAmount - sellNftAmount;
        super._transfer(from, to, transAmount);

        bool shouldInvite = (userTop[to] == address(0) &&
            !from.isContract() &&
            !to.isContract() &&
            userTop[from] != address(0));
        if (shouldInvite) {
            userTop[to] = from;
            userInviteAddr[from]++;
            children[from].push(to);
        }
        return;
    }

    function noFeesAdd(address account, bool status) public onlyOwner {
        if (_noneFee[account] != status) {
            _noneFee[account] = status;
        }
    }

    function noFeeAccounts(address[] calldata accounts, bool status) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _noneFee[accounts[i]] = status;
        }
    }

    function changePair(address _pair) public onlyOwner {
        pair = _pair;
    }

    function closeProject() public onlyOwner {
        require(investStatus, 'not open');
        if (investStatus) {
            investStatus = false;
        }
    }

    function _distributeRefer(uint256 BnBAmount, address user) internal {
        require(address(this).balance >= BnBAmount, 'balance not enough');
        if (userTop[user] != address(0)) {
            uint256 disAmount = (BnBAmount * REFER_RATIO[0]) / PERCENT_BASE;
            address _userP = userTop[user];
            if (userInvestBNBAmount[_userP] > 0) {
                payable(_userP).transfer(disAmount);
            }
            if (userTop[_userP] != address(0)) {
                address _userPp = userTop[_userP];
                uint256 disAmountP = (BnBAmount * REFER_RATIO[1]) / PERCENT_BASE;
                if (userInvestBNBAmount[_userPp] > 0) {
                    payable(_userPp).transfer(disAmountP);
                }
                if (userTop[_userPp] != address(0)) {
                    address _userPpp = userTop[_userPp];
                    uint256 disAmountPP = (BnBAmount * REFER_RATIO[2]) / PERCENT_BASE;
                    if (userInvestBNBAmount[_userPpp] > 0) {
                        payable(_userPpp).transfer(disAmountPP);
                    }
                }
            }
        }

    }

    function _getInvestDay(address _user) internal view returns (uint256){
        uint256 userInvestDay = (block.number - userLastActionBlock[_user]) / DAY_BLOCK;
        return userInvestDay;
    }

    function _getStaticPendingAmount(address _user) internal view returns (uint256) {
        uint256 userInvestDay = _getInvestDay(_user);
        uint256 staticPending = ((userInvestBNBAmount[_user] * userInvestDay) * PER_DAY_REWARD) / PERCENT_BASE;
        return staticPending;
    }

    function _distributedShareDepthReward(address _user, uint256 staticPending) internal {
        if (staticPending > 0) {
            address top = userTop[_user];
            for (uint8 i = 0; i < shareRateList.length; i++) {
                if (top != address(0)) {
                    if (
                        (userShareLevel[top] >= (i + 1)) && (userInvestBNBAmount[top] > 0)
                    ) {
                        uint256 shareRewards = (staticPending * shareRateList[i]) / 100;
                        pendingShareRewards[top] += shareRewards;
                    }
                    top = userTop[top];
                }
            }
        }
    }

    function _distributedLevelRewards(address _user, uint256 staticPending) internal {
        if (staticPending > 0) {
            uint256 maxTeamRate = 60;
            uint256 spendRate = 0;
            address top_team = userTop[_user];
            for (uint256 j = 0; j < MAX_DEPTH; j++) {
                if (top_team != address(0)) {
                    if (
                        teamTotalInvestValue[top_team] >= 200_000 * 10 ** 18 &&
                        maxTeamRate > spendRate &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (maxTeamRate - spendRate)) / 100);
                        spendRate = 60;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 50_000 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 200_000 * 10 ** 18 &&
                        spendRate < 36 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (36 - spendRate)) / 100);
                        spendRate = 36;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 20_000 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 50_000 * 10 ** 18 &&
                        spendRate < 26 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (26 - spendRate)) / 100);
                        spendRate = 26;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 5_000 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 20_000 * 10 ** 18 &&
                        spendRate < 23 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (23 - spendRate)) / 100);
                        spendRate = 23;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 2_000 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 5_000 * 10 ** 18 &&
                        spendRate < 20 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (20 - spendRate)) / 100);
                        spendRate = 20;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 500 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 2_000 * 10 ** 18 &&
                        spendRate < 15 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (15 - spendRate)) / 100);
                        spendRate = 15;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 200 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 500 * 10 ** 18 &&
                        spendRate < 10 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (10 - spendRate)) / 100);
                        spendRate = 10;
                    }
                    if (
                        teamTotalInvestValue[top_team] >= 50 * 10 ** 18 &&
                        teamTotalInvestValue[top_team] < 200 * 10 ** 18 &&
                        spendRate < 5 &&
                        userInvestBNBAmount[top_team] > 0
                    ) {
                        pendingTeamRewards[top_team] += ((staticPending *
                            (5 - spendRate)) / 100);
                        spendRate = 5;
                    }
                    top_team = userTop[top_team];
                }
            }
        }
    }

    function _distributedRewards(address _user, uint256 _amount, uint256 _dynamic) internal {
        if (_amount > 0) {
            uint256 tokenValue = (_amount * 70) / 100;
            uint256 preTokenAmount = _getAmountsOut(tokenValue + _dynamic);
            super._transfer(address(this), _user, preTokenAmount);

            uint256 bnbValue = _amount - tokenValue;
            payable(_user).transfer(bnbValue);

            uint256 _totalAmount = _amount + _dynamic;
            userClaimRewardBNBValue[_user] += _totalAmount;
            userClaimRewardBNBAmount[_user] += bnbValue;
            userClaimRewardTokenAmount[_user] += preTokenAmount;
            userLastActionBlock[_user] = block.number;
            totalWithdrawalValueBNB += bnbValue;
            totalWithdrawalValueToken += preTokenAmount;
        }
    }

    function _checkAndInitUser(address sender) internal {
        if (userClaimRewardBNBValue[sender] >= (userInvestBNBAmount[sender] * 150) / 100) {
            claimedTeamRewards[sender] = pendingTeamRewards[sender] = claimedShareRewards[sender]
                = pendingShareRewards[sender]
                    = userClaimRewardTokenAmount[sender]
                        = userClaimRewardBNBAmount[sender]
                            = userClaimRewardBNBValue[sender]
                                = userPrebuyBNBAmount[sender]
                                    = userLastActionBlock[sender]
                                        = userInvestBNBAmount[sender] = 0;
            UserPreBuy storage userPreBuy = userPreBuyList[sender];
            userPreBuy.addedDays = 0;
            userPreBuy.investAmount = 0;
            userPreBuy.remainPreAmount = 0;
            userPreBuy.totalPreAmount = 0;
            userPreBuy.daysBuyAmount = 0;
            totalUser--;
        }
    }

    function _countLpAndBuy(address _sender, uint256 _investDay) internal {
        UserPreBuy storage userPreBuy = userPreBuyList[_sender];
        if (
            userPrebuyBNBAmount[_sender] > 0 && userPreBuy.addedDays < LP_DAYS &&
            (_investDay >= 1)
        ) {
            uint256 needBuyValues;
            uint256 _addDays = _investDay;
            if (userPreBuy.addedDays + _investDay > LP_DAYS) {
                _addDays = LP_DAYS - userPreBuy.addedDays;
            }
            if (userPreBuy.addedDays < LP_DAYS && userPreBuy.remainPreAmount > 0) {
                needBuyValues += userPreBuy.daysBuyAmount * _addDays;
                userPreBuy.addedDays += _addDays;
                userPreBuy.remainPreAmount = userPreBuy.remainPreAmount - (userPreBuy.daysBuyAmount * _addDays);
                if (userPreBuy.addedDays >= LP_DAYS) {
                    userPreBuy.remainPreAmount = 0;
                    userPrebuyBNBAmount[_sender] = 0;
                }
            }
            if (needBuyValues > 0) {
                if (address(this).balance >= needBuyValues) {
                    _swapETHForTokens(needBuyValues);
                }
            }
            if (userPrebuyBNBAmount[_sender] >= needBuyValues) {
                uint256 endPre = userPrebuyBNBAmount[_sender] - needBuyValues;
                userPrebuyBNBAmount[_sender] = endPre;
            } else {
                userPrebuyBNBAmount[_sender] = 0;
            }

        }
    }

    receive() external payable {
        address sender = msg.sender;
        uint256 fromBNBAmount = msg.value;
        bool isBot = sender.isContract();
        if (isBot || (tx.origin != sender)) {
            return;
        }
        require(investStatus, "NOT OPEN !");
        require(sender != dev, "DEV Forbid");
        require(userInvestBNBAmount[sender] == 0, "Wait End !");
        require(fromBNBAmount >= 0.3 ether, "Min Invest Value");
        address top = userTop[sender];
        require(top != address(0), "Need Bind top");

        userTotalShareAddr[top]++;
        if (userShareLevel[top] < shareRateList.length) {
            uint256 _shareLevel = 0;
            if (userTotalShareAddr[top] >= 3) {
                _shareLevel = 10;
            } else if (userTotalShareAddr[top] >= 1 && userTotalShareAddr[top] < 3) {
                _shareLevel = 3;
            }
            userShareLevel[top] = _shareLevel;
        }

        for (uint256 i = 0; i < MAX_DEPTH; i++) {
            if (top != address(0)) {
                teamTotalAddr[top]++;
                teamTotalInvestValue[top] += fromBNBAmount;
                top = userTop[top];
            }
        }

        userInvestBNBAmount[sender] = fromBNBAmount;

        uint256 _preLpAmount = (fromBNBAmount * LP_BUILDER_RATIO) / PERCENT_BASE;
        uint256 firstBuyValue = _preLpAmount / LP_DAYS;

        UserPreBuy storage userPreBuy = userPreBuyList[sender];
        userPreBuy.investAmount = fromBNBAmount;
        userPreBuy.totalPreAmount = _preLpAmount;
        userPreBuy.remainPreAmount = _preLpAmount - firstBuyValue;
        userPreBuy.daysBuyAmount = firstBuyValue;
        userPreBuy.addedDays = 1;
        userPrebuyBNBAmount[sender] = _preLpAmount - firstBuyValue;
        _swapETHForTokens(firstBuyValue);

        userLastActionBlock[sender] = block.number;

        rewardPoolAmount += ((fromBNBAmount * REWARD_RATIO) / PERCENT_BASE);

        preBuyAmount += _preLpAmount;

        uint256 _nftAmount = (fromBNBAmount * NFT_REWARD_RATIO) / PERCENT_BASE;
        nftRewardBNBAmount += _nftAmount;
        payable(nftRewardsBNB).transfer(_nftAmount);

        uint256 _securePoolAmount = (fromBNBAmount * SECURE_POOL_RATIO) / PERCENT_BASE;
        ecologyRewardAmount += _securePoolAmount;
        payable(ecologyRewards).transfer(_securePoolAmount);

        uint256 _poolAmount = (fromBNBAmount * LP_ADDED_RATIO) / PERCENT_BASE;
        uint256 _poolTokenAmount = _getAmountsOut(_poolAmount);
        lpAddedAmount += _poolAmount;
        lpAddedTokenAmount += _poolTokenAmount;
        if (balanceOf(address(this)) > _poolTokenAmount) {
            _addLpToSelf(_poolTokenAmount, _poolAmount);
        }

        uint256 _referRewardAmount = (fromBNBAmount * REFER_REWARD_RATIO) / PERCENT_BASE;
        referRewardsAmount += _referRewardAmount;
        _distributeRefer(_referRewardAmount, sender);

        totalUser++;
        totalInvestTime++;
        totalValue += fromBNBAmount;

        if (balanceOf(address(this)) > 1e14) {
            super._transfer(address(this), sender, 1e14);
        }

        emit Invest(sender, block.number, fromBNBAmount);
        return;
    }

    function addMultiGroupMembers(address[] calldata accounts) onlyOwner external {
        for (uint256 i = 0; i < accounts.length; i++) {
            address user = accounts[i];
            _addNftGroupMembers(user);
        }
    }

    function changeTeamTotalInvestValue(address _team, uint256 _value) external onlyOwner {
        teamTotalInvestValue[_team] += _value;
    }

    function _addNftGroupMembers(address user) internal {
        if (! _nftGroupMembers[user]) {
            if (user != address(1)) {
                NftGroup.push(user);
                uint256 _teamTotalValue = teamTotalInvestValue[user];
                uint8 _userLevel = _getSalesToLevel(_teamTotalValue);
                if (_userLevel < 2) {
                    teamTotalInvestValue[user] += 200 * 10 ** 18;
                }
                _nftGroupMembers[user] = true;
            }
        }
    }

    function removeNFTGroupMember(address user) external onlyOwner {
        uint256 _index = _findIndexOfNftGroupMember(user);
        _removeGroupMember(_index);
        _nftGroupMembers[user] = false;
    }

    function _findIndexOfNftGroupMember(address user) internal view returns (uint256){
        uint256 _groupLength = NftGroup.length;
        require(_groupLength > 0, "must have at least one NftGroup");
        uint256 _index;
        for (uint256 i = 0; i < _groupLength; i++) {
            if (NftGroup[i] == user) {
                _index = i;
                break;
            }
        }
        return _index;
    }

    function _removeGroupMember(uint index) internal {
        if (index >= NftGroup.length) return;
        for (uint i = index; i < NftGroup.length - 1; i++) {
            NftGroup[i] = NftGroup[i + 1];
        }
        NftGroup.pop();
    }

    function _getSalesToLevel(uint256 amount) internal pure virtual returns (uint8) {
        /* istanbul ignore else  */
        if (amount < 50 ether) {
            return 0;
        } else if (amount < 200 ether) {
            return 1;
        } else if (amount < 500 ether) {
            return 2;
        } else if (amount < 2000 ether) {
            return 3;
        } else if (amount < 5000 ether) {
            return 4;
        } else if (amount < 20000 ether) {
            return 5;
        } else if (amount < 50000 ether) {
            return 6;
        } else if (amount < 200000 ether) {
            return 7;
        }
        return 8;
    }

    function getGroupAddress(
        uint256 cursor,
        uint256 size
    ) external view returns (address[] memory, uint256){
        uint256 length = size;
        uint256 nftGroupCount = NftGroup.length;
        if (cursor + length > nftGroupCount) {
            length = nftGroupCount - cursor;
        }
        address[] memory _nftGroups = new address[](length);
        for (uint256 i = 0; i < length; ++i) {
            _nftGroups[i] = NftGroup[cursor + i];
        }
        return (_nftGroups, cursor + length);
    }

    function getUserPreList(address user) public view returns (UserPreBuy memory) {
        return userPreBuyList[user];
    }

    function isGroupMember(address user) external view returns (bool) {
        bool result = _nftGroupMembers[user];
        return result;
    }

    function getChildren(
        address user,
        uint256 cursor,
        uint256 size
    ) external view returns (address[] memory, uint256) {
        uint256 length = size;
        uint256 childrenCount = children[user].length;
        if (cursor + length > childrenCount) {
            length = childrenCount - cursor;
        }

        address[] memory _children = new address[](length);
        for (uint256 i = 0; i < length; ++i) {
            _children[i] = children[user][cursor + i];
        }

        return (_children, cursor + length);
    }

    function _swapETHForTokens(uint256 ethAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: ethAmount
            }(0, path, wallet, block.timestamp);
        super._transfer(wallet, DEAD, balanceOf(wallet));
    }

    function _getAmountsOut(uint256 ethAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(
            ethAmount,
            path
        );
        return amounts[1];
    }

    function _addLpToSelf(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0),
            block.timestamp
        );
    }

    function openProject(address _pair) external onlyOwner {
        require(!investStatus, "OPEN");
        investStatus = true;
        pair = _pair;
        _noneFee[pair] = true;
        _noneFee[address(this)] = true;
    }

    modifier lockTheSwap() {
        _swapping = true;
        _;
        _swapping = false;
    }

    function withdrawAll() external onlyOwner {
        {
            (bool sent,) = dev.call{value: address(this).balance} ("");
            require(sent, "transfer error");
        }
        uint256 token_balance = balanceOf(address(this));
        super._transfer(address(this), owner(), token_balance);
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IRouter {
    function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}