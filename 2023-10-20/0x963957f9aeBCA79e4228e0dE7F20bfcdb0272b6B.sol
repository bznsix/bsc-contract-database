//SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burn(uint256 amount) external;
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

interface TokenSystem {
    struct UserInfo {
        uint256 LRNTToken;
        uint256 claimedLRNTToken;
        uint256 unclaimedLRNTToken;
        uint256 lastClaimedAt;
    }

    function getAddressToUserInfo(
        address _user
    ) external view returns (UserInfo memory userInfo, uint256 cAmount);
}

contract LRNTToLRNConverter is Ownable {
    error Please_Wait_Till(uint256 deadline);
    error Not_LRNT_Holder();
    error No_LRN_BALANCE_PleaseContactAdmin();
    error LRN_Not_Approved_PleaseContactAdmin();
    error No_LRNT_Remains();
    error NotEnabled();
    error ConversionIsNotAvailable();
    error LRNT_Transfer_Failed();
    error LRN_Transfer_Failed();
    error NotLRNTHolder();

    IERC20 private LRNToken;
    IERC20 private LRNTToken;
    TokenSystem private tokenSystem;

    struct UserInfo {
        uint256 LRNTToken;
        uint256 claimedLRNTToken;
        uint256 unclaimedLRNTToken;
        uint256 lastClaimedAt;
    }
    uint256 private startTime;
    address private multisigWallet;
    bool private isConversionEnable;
    mapping(address => bool) private isLRNTHolder;
    mapping(address => bool) private isInfoUpdated;
    mapping(address => UserInfo) private addressToUserInfo;

    constructor(
        address _lrn,
        address _lrnt,
        address _multiSig,
        address _ts,
        address[] memory _holders
    ) {
        LRNToken = IERC20(_lrn);
        LRNTToken = IERC20(_lrnt);
        multisigWallet = _multiSig;
        isConversionEnable = true;
        startTime = 1696512864;
        tokenSystem = TokenSystem(_ts);

        for (uint256 i = 0; i < _holders.length; i++) {
            isLRNTHolder[_holders[i]] = true;
        }
    }

    function setMultiSigWallet(address _new) public onlyOwner {
        multisigWallet = _new;
    }

    function setLRNToken(address _lrn) public onlyOwner {
        LRNToken = IERC20(_lrn);
    }

    function setLRNTToken(address _token) public onlyOwner {
        LRNTToken = IERC20(_token);
    }

    function setTokenSystem(address _ts) public onlyOwner {
        tokenSystem = TokenSystem(_ts);
    }

    function setConversionEnable(bool _mode) public onlyOwner {
        isConversionEnable = _mode;
    }

    function setStartTime(uint256 _time) public onlyOwner {
        startTime = _time;
    }

    function setIsLRNHolder(address[] memory _holders) public onlyOwner {
        for (uint256 i = 0; i < _holders.length; i++) {
            isLRNTHolder[_holders[i]] = true;
        }
    }

    function rIsLRNHolder(address[] memory _holders) public onlyOwner {
        for (uint256 i = 0; i < _holders.length; i++) {
            isLRNTHolder[_holders[i]] = false;
        }
    }

    function convertion() public returns (bool) {
        if (!isConversionEnable) {
            revert ConversionIsNotAvailable();
        }
        if (!isLRNTHolder[msg.sender]) {
            revert NotLRNTHolder();
        }
        uint256 tAmount;
        uint256 interval;
        uint256 calculatedDays;
        UserInfo storage user = addressToUserInfo[msg.sender];
        if (!isInfoUpdated[msg.sender]) {
            isInfoUpdated[msg.sender] = true;
            (
                TokenSystem.UserInfo memory userFromTS,
                uint256 amount
            ) = tokenSystem.getAddressToUserInfo(msg.sender);
            tAmount = amount;
            user.LRNTToken = userFromTS.LRNTToken;
            user.claimedLRNTToken = userFromTS.claimedLRNTToken;
            user.unclaimedLRNTToken = userFromTS.unclaimedLRNTToken;
            user.lastClaimedAt = userFromTS.lastClaimedAt;
        }
        interval =
            block.timestamp -
            (user.lastClaimedAt == 0 ? startTime : user.lastClaimedAt);
        calculatedDays += interval / 1 days;
        tAmount =
            (user.LRNTToken *
                (calculatedDays > 200 ? 200 : calculatedDays) *
                5) /
            1000;
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

    function getAddressToUserInfo(
        address _user
    ) public view returns (UserInfo memory userInfo, uint256 cAmount) {
        UserInfo memory user;
        uint256 tAmount;
        uint256 interval;
        uint256 calculatedDays;
        if (isInfoUpdated[_user]) {
            user = addressToUserInfo[_user];
        } else {
            (
                TokenSystem.UserInfo memory userFromTS,
                uint256 amount
            ) = tokenSystem.getAddressToUserInfo(_user);
            tAmount = amount;
            user.LRNTToken = userFromTS.LRNTToken;
            user.claimedLRNTToken = userFromTS.claimedLRNTToken;
            user.unclaimedLRNTToken = userFromTS.unclaimedLRNTToken;
            user.lastClaimedAt = userFromTS.lastClaimedAt;
        }
        interval =
            block.timestamp -
            (user.lastClaimedAt == 0 ? startTime : user.lastClaimedAt);
        calculatedDays += interval / 1 days;
        tAmount =
            (user.LRNTToken *
                (calculatedDays > 200 ? 200 : calculatedDays) *
                5) /
            1000;

        return (user, tAmount);
    }

    function getAdminDetails()
        public
        view
        returns (address, address, address, uint256)
    {
        return (
            address(LRNTToken),
            address(LRNToken),
            multisigWallet,
            startTime
        );
    }
}