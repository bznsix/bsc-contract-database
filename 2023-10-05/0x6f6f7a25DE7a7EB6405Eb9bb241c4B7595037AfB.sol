//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 amount) external;
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    function isApprovedForAll(
        address account,
        address operator
    ) external view returns (bool);

    function setApprovalForAll(address operator, bool approved) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface IMasterNFT {
    function transferHelper(
        address[] memory _addresses,
        uint256[] memory _tokenIds
    ) external;
}

error PaymentTokenIsNotApproved();
error PaymentError();
error AlreadyStakeHolder();
error StakePeriodNotCompleted();
error NotStakeHolder();
error LRNT_Transfer_Failed();
error LRN_Transfer_Failed();
error No_LRN_BALANCE_PleaseContactAdmin();
error LRN_Not_Approved_PleaseContactAdmin();
error Not_LRNT_Holder();
error No_LRNT_Remains();
error Please_Wait_Till(uint256 deadline);
error NotEnabled();
error ConversionIsNotAvailable();

contract GMETokenSystem is Ownable {
    IERC20 private wisdomToken;
    IERC20 private LRNToken;
    IERC20 private LRNTToken;

    IERC1155 private nftToken;
    IMasterNFT private masterContract;

    address[] private approvedPaymentTokenList;
    address[] private approvedSellTokenList;
    address private multisigWallet;

    mapping(address => bool) private isApprovedToken;
    mapping(address => bool) private isApprovedSellToken;
    mapping(address => StakeInfo) private stakeInfo;
    mapping(address => UserInfo) private addressToUserInfo;

    uint256 private startTime;
    uint256 private months = 2629743;
    uint256 private tokenId;
    uint256 private SMReward = 3;
    uint256 private SMRewardWL = 9;
    uint256 private TMReward = 7;
    uint256 private TMRewardWL = 186;

    uint256 private stableToLRNPrice;

    uint256 private minNFTRewardPerk;
    bool private isNFTRewardEnable;
    bool private isBuyLRNEnable;
    bool private isSellWisdomEnable;
    bool private isConversionEnable;
    mapping(address => bool) private isListed;

    enum Stake {
        WIS,
        WISLRN,
        LRN
    }

    enum Month {
        Six,
        Twelve
    }

    struct UserInfo {
        uint256 LRNTToken;
        uint256 claimedLRNTToken;
        uint256 unclaimedLRNTToken;
        uint256 lastClaimedAt;
    }

    struct StakeInfo {
        uint256 stakedAt;
        uint256 unstakedAt;
        uint256 stakeWISAmount;
        uint256 stakeLRNAmount;
        uint256 rewardWISAmount;
        uint256 totalWISAmount;
        Stake stake;
        Month month;
    }

    constructor(
        address _wisdom,
        address _lrn,
        address _lrnt,
        address _nftToken,
        address _masterContract,
        address[] memory _tokens,
        address _multiSig,
        uint256 _stlPrice
    ) {
        wisdomToken = IERC20(_wisdom);
        LRNToken = IERC20(_lrn);
        LRNTToken = IERC20(_lrnt);
        stableToLRNPrice = _stlPrice;
        nftToken = IERC1155(_nftToken);
        masterContract = IMasterNFT(_masterContract);
        minNFTRewardPerk = 300000 * 10 ** 18;
        multisigWallet = _multiSig;
        for (uint256 i = 0; i < _tokens.length; i++) {
            isApprovedToken[_tokens[i]] = true;
            approvedPaymentTokenList.push(_tokens[i]);
        }
        startTime = block.timestamp;
    }

    function _transferNFT(address _to) internal {
        address[] memory toAddresses = new address[](1);
        toAddresses[0] = _to;
        uint256[] memory ids = new uint256[](1);
        ids[0] = tokenId;
        if (nftToken.balanceOf(address(this), tokenId) > 0) {
            if (
                nftToken.isApprovedForAll(
                    address(this),
                    address(masterContract)
                ) == true
            ) {
                masterContract.transferHelper(toAddresses, ids);
            } else {
                nftToken.setApprovalForAll(address(masterContract), true);
                masterContract.transferHelper(toAddresses, ids);
            }
        }
    }

    function setIsNFTRewardEnable(bool _isEnable) public onlyOwner {
        isNFTRewardEnable = _isEnable;
    }

    function setMinNFTRewardPark(uint256 _park) public onlyOwner {
        minNFTRewardPerk = _park;
    }

    function updateNFTToken(address _new) public onlyOwner {
        nftToken = IERC1155(_new);
    }

    function updateMasterContract(address _new) public onlyOwner {
        masterContract = IMasterNFT(_new);
    }

    function updateTokenId(uint256 _id) public onlyOwner {
        tokenId = _id;
    }

    function setWisdomTokenn(address _wisdom) public onlyOwner {
        wisdomToken = IERC20(_wisdom);
    }

    function setLRNToken(address _lrn) public onlyOwner {
        LRNToken = IERC20(_lrn);
    }

    function setLRNTToken(address _token) public onlyOwner {
        LRNTToken = IERC20(_token);
    }

    function setMultiSigWallet(address _new) public onlyOwner {
        multisigWallet = _new;
    }

    function setStartTime() public onlyOwner {
        startTime = block.timestamp;
    }

    function setConversionEnable(bool _mode) public onlyOwner {
        isConversionEnable = _mode;
    }

    function setStableToLRNPrice(uint256 _newPrice) public onlyOwner {
        stableToLRNPrice = _newPrice;
    }

    function UpdateRewardAmount(
        uint256 _smReward,
        uint256 _smRewardWL,
        uint256 _tmReward,
        uint256 _tmRewardWL
    ) public onlyOwner {
        SMReward = _smReward;
        SMRewardWL = _smRewardWL;
        TMReward = _tmReward;
        TMRewardWL = _tmRewardWL;
    }

    function addPaymentToken(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isApprovedToken[_tokens[i]] = true;
            approvedPaymentTokenList.push(_tokens[i]);
        }
    }

    function addSellToken(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isApprovedSellToken[_tokens[i]] = true;
            approvedSellTokenList.push(_tokens[i]);
        }
    }

    function removePaymentToken(address _token) public onlyOwner {
        isApprovedToken[_token] = false;

        for (uint256 i = 0; i < approvedPaymentTokenList.length; i++) {
            if (approvedPaymentTokenList[i] == _token) {
                approvedPaymentTokenList[i] = approvedPaymentTokenList[
                    approvedPaymentTokenList.length - 1
                ];
                approvedPaymentTokenList.pop();
                break;
            }
        }
    }

    function removeSellToken(address _token) public onlyOwner {
        isApprovedSellToken[_token] = false;

        for (uint256 i = 0; i < approvedSellTokenList.length; i++) {
            if (approvedSellTokenList[i] == _token) {
                approvedSellTokenList[i] = approvedSellTokenList[
                    approvedSellTokenList.length - 1
                ];
                approvedSellTokenList.pop();
                break;
            }
        }
    }

    function withdraw(address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function convertion() public returns (bool) {
        if (!isConversionEnable) {
            revert ConversionIsNotAvailable();
        }
        UserInfo storage user = addressToUserInfo[msg.sender];
        uint256 tAmount;
        uint256 interval;
        uint256 calculatedDays;
        if (isListed[msg.sender]) {
            interval = block.timestamp - user.lastClaimedAt;
            calculatedDays += interval / 1 days;
            tAmount = (user.LRNTToken * calculatedDays * 5) / 1000;
        } else {
            isListed[msg.sender] = true;
            uint256 bal = LRNTToken.balanceOf(msg.sender);
            user.LRNTToken = bal;
            user.unclaimedLRNTToken = bal;
            user.claimedLRNTToken = 0;
            interval = block.timestamp - startTime;
            calculatedDays = interval > 1 days ? interval / 1 days : 1;
            tAmount = (user.LRNTToken * calculatedDays * 5) / 1000;
        }

        if (interval < 1 days) {
            if (user.lastClaimedAt != 0) {
                revert Please_Wait_Till(user.lastClaimedAt + 1 days);
            }
        }

        if (user.LRNTToken == 0) {
            revert Not_LRNT_Holder();
        }

        if (user.unclaimedLRNTToken == 0) {
            revert No_LRNT_Remains();
        }
        uint256 lrnWBal = LRNToken.balanceOf(multisigWallet);
        if (lrnWBal < tAmount) {
            revert No_LRN_BALANCE_PleaseContactAdmin();
        }

        uint256 allow = LRNToken.allowance(multisigWallet, address(this));
        if (allow < tAmount) {
            revert LRN_Not_Approved_PleaseContactAdmin();
        }

        user.claimedLRNTToken += tAmount;
        user.unclaimedLRNTToken -= tAmount;
        user.lastClaimedAt = block.timestamp;

        bool success = LRNTToken.transferFrom(
            msg.sender,
            address(this),
            tAmount
        );
        if (!success) {
            revert LRNT_Transfer_Failed();
        }
        bool successTwo = LRNToken.transferFrom(
            multisigWallet,
            msg.sender,
            tAmount
        );
        if (!successTwo) {
            revert LRN_Transfer_Failed();
        }
        LRNTToken.burn(tAmount);
        return true;
    }

    function buyWisdom(address _paymentToken, uint256 _amount) public {
        if (!isApprovedToken[_paymentToken]) {
            revert PaymentTokenIsNotApproved();
        }

        bool success = IERC20(_paymentToken).transferFrom(
            msg.sender,
            multisigWallet,
            _amount
        );
        if (!success) {
            revert PaymentError();
        }

        wisdomToken.transferFrom(multisigWallet, msg.sender, _amount);
    }

    function buyWisdomWithLRN(uint256 _wAmount) public {
        uint256 lAmount = (_wAmount * stableToLRNPrice) / 10 ** 18;
        bool success = LRNToken.transferFrom(
            msg.sender,
            multisigWallet,
            lAmount
        );
        if (!success) {
            revert PaymentError();
        }
        wisdomToken.transferFrom(multisigWallet, msg.sender, _wAmount);
    }

    function sellWisdom(address _token, uint256 _amount) public {
        if (!isSellWisdomEnable) {
            revert NotEnabled();
        }
        if (!isApprovedSellToken[_token]) {
            revert PaymentTokenIsNotApproved();
        }

        bool success = wisdomToken.transferFrom(
            msg.sender,
            multisigWallet,
            _amount
        );
        if (!success) {
            revert PaymentError();
        }
        IERC20(_token).transferFrom(multisigWallet, msg.sender, _amount);
    }

    function buyLRN(address _paymentToken, uint256 _amount) public {
        if (!isBuyLRNEnable) {
            revert NotEnabled();
        }
        if (!isApprovedToken[_paymentToken]) {
            revert PaymentTokenIsNotApproved();
        }
        uint256 lAmount = (_amount * stableToLRNPrice) / 10 ** 18;
        bool success = IERC20(_paymentToken).transferFrom(
            msg.sender,
            multisigWallet,
            _amount
        );
        if (!success) {
            revert PaymentError();
        }

        LRNToken.transferFrom(multisigWallet, msg.sender, lAmount);
    }

    function stake(Stake _stake, Month _month, uint256 _amount) public {
        if (stakeInfo[msg.sender].stakedAt != 0) {
            revert AlreadyStakeHolder();
        }
        uint256 unstakeTime;
        uint256 WISReward;
        uint256 totalWIS;

        if (_stake == Stake.WIS) {
            if (_month == Month.Six) {
                unstakeTime = block.timestamp + (6 * months);
                WISReward = (_amount * SMReward) / 100;
                totalWIS = _amount + WISReward;
            } else if (_month == Month.Twelve) {
                unstakeTime = block.timestamp + (12 * months);
                WISReward = (_amount * TMReward) / 100;
                totalWIS = _amount + WISReward;
            }
            stakeInfo[msg.sender] = StakeInfo(
                block.timestamp,
                unstakeTime,
                _amount,
                0,
                WISReward,
                totalWIS,
                _stake,
                _month
            );
            bool success = wisdomToken.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert PaymentError();
            }
        } else if (_stake == Stake.WISLRN) {
            if (_month == Month.Six) {
                unstakeTime = block.timestamp + (6 * months);
                WISReward = (_amount * SMRewardWL) / 100;
                totalWIS = _amount + WISReward;
            } else {
                unstakeTime = block.timestamp + (12 * months);
                WISReward = (_amount * TMRewardWL) / 1000;
                totalWIS = _amount + WISReward;
            }
            stakeInfo[msg.sender] = StakeInfo(
                block.timestamp,
                unstakeTime,
                _amount,
                _amount,
                WISReward,
                totalWIS,
                _stake,
                _month
            );
            bool success = wisdomToken.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert PaymentError();
            }
            uint256 lAmount = (_amount * stableToLRNPrice) / 10 ** 18;
            bool successT = LRNToken.transferFrom(
                msg.sender,
                address(this),
                lAmount
            );
            if (!successT) {
                revert PaymentError();
            }
        } else if (_stake == Stake.LRN) {
            if (_month == Month.Six) {
                unstakeTime = block.timestamp + (6 * months);
                WISReward = (_amount * SMReward) / 100;
                totalWIS = WISReward;
            } else {
                unstakeTime = block.timestamp + (12 * months);
                WISReward = (_amount * TMReward) / 100;
                totalWIS = WISReward;
            }
            stakeInfo[msg.sender] = StakeInfo(
                block.timestamp,
                unstakeTime,
                0,
                _amount,
                WISReward,
                totalWIS,
                _stake,
                _month
            );
            bool success = LRNToken.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert PaymentError();
            }
        }

        if (isNFTRewardEnable == true) {
            if (_amount >= minNFTRewardPerk) {
                _transferNFT(msg.sender);
            }
        }
    }

    function unstake() public returns (bool) {
        StakeInfo storage _stake = stakeInfo[msg.sender];
        if (_stake.stakedAt == 0) {
            revert NotStakeHolder();
        }
        if (block.timestamp < _stake.unstakedAt) {
            revert StakePeriodNotCompleted();
        }

        if (_stake.stakeLRNAmount != 0) {
            LRNToken.transfer(msg.sender, _stake.stakeLRNAmount);
        }
        if (_stake.totalWISAmount != 0) {
            wisdomToken.transfer(msg.sender, _stake.totalWISAmount);
        }
        delete stakeInfo[msg.sender];
        return true;
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function getWisdomToken() public view returns (address) {
        return address(wisdomToken);
    }

    function getLRNToken() public view returns (address) {
        return address(wisdomToken);
    }

    function getRewardInfo()
        public
        view
        returns (uint256, uint256, uint256, uint256)
    {
        return (SMReward, TMReward, SMRewardWL, TMRewardWL);
    }

    function getStakeInfo(
        address _user
    ) public view returns (StakeInfo memory) {
        return stakeInfo[_user];
    }

    function getApprovedPaymentTokenList()
        public
        view
        returns (address[] memory)
    {
        return approvedPaymentTokenList;
    }

    function getApprovedSellTokenList() public view returns (address[] memory) {
        return approvedSellTokenList;
    }

    function getIsApprovedToken(address _token) public view returns (bool) {
        return isApprovedToken[_token];
    }

    function getIsApprovedSellToken(address _token) public view returns (bool) {
        return isApprovedSellToken[_token];
    }

    function getMinNFTRewardPark() public view returns (uint256) {
        return minNFTRewardPerk;
    }

    function getIsNFTRewardEnable() public view returns (bool) {
        return isNFTRewardEnable;
    }

    function getWISToLRNPrice() public view returns (uint256) {
        return stableToLRNPrice;
    }

    function updateBuySellStatus(
        bool _sellWisdom,
        bool _buyLRN
    ) public onlyOwner {
        isSellWisdomEnable = _sellWisdom;
        isBuyLRNEnable = _buyLRN;
    }

    function getAddressToUserInfo(
        address _user
    ) public view returns (UserInfo memory userInfo, uint256 cAmount) {
        UserInfo memory user = addressToUserInfo[_user];
        if (user.LRNTToken == 0) {
            uint256 bal = LRNTToken.balanceOf(_user);
            user.LRNTToken = bal;
            user.unclaimedLRNTToken = bal;
        }

        uint256 tAmount;
        uint256 interval;
        uint256 calculatedDays;
        if (isListed[_user]) {
            interval = block.timestamp - user.lastClaimedAt;
            calculatedDays += interval / 1 days;
            tAmount = (user.LRNTToken * calculatedDays * 5) / 1000;
        } else {
            uint256 bal = LRNTToken.balanceOf(_user);
            user.LRNTToken = bal;
            user.unclaimedLRNTToken = bal;
            user.claimedLRNTToken = 0;
            interval = block.timestamp - startTime;
            calculatedDays = interval > 1 days ? interval / 1 days : 1;
            tAmount = (user.LRNTToken * calculatedDays * 5) / 1000;
        }

        return (user, tAmount);
    }

    function getAdminDetails()
        public
        view
        onlyOwner
        returns (address, address, address, uint256)
    {
        return (
            address(LRNTToken),
            address(LRNToken),
            multisigWallet,
            startTime
        );
    }

    function getNFTDetails()
        public
        view
        returns (address tokenContract, address mContract, uint256 id)
    {
        return (address(nftToken), address(masterContract), tokenId);
    }
}