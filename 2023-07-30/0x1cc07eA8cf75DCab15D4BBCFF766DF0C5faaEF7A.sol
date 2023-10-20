// SPDX-License-Identifier:MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IWolf {
    function getUserInfo(
        address _user
    )
        external
        view
        returns (
            bool _isExists,
            uint256 _stakeCount,
            address _referrer,
            uint256 _referrals,
            uint256 _referralRewards,
            uint256 _teamId,
            uint256 _currentStaked,
            uint256 _totalStaked,
            uint256 _totalWithdrawan
        );
}

contract WolfCapitalRefunds is Ownable {
    IWolf public wolf;
    uint256 public totalRequestedAmount;
    uint256 public totalUserRequested;
    address[] public allUsers;
    bool public stopRequest;

    struct User {
        bool isRequested;
        uint256 amount;
    }

    mapping(address => User) internal requestData;

    constructor(address _wolf) {
        wolf = IWolf(_wolf);
    }

    function requestWithdraw() public {
        require(!stopRequest, "admin stoped");
        require(!requestData[msg.sender].isRequested, "already requested");
        uint256 amount = calculateRoi(msg.sender);
        requestData[msg.sender].isRequested = true;
        requestData[msg.sender].amount = amount;
        totalRequestedAmount += amount;
        totalUserRequested++;
        allUsers.push(msg.sender);
    }

    function calculateRoi(address _user) public view returns (uint256 amount_) {
        (, , , , , , , uint256 _totalStaked, uint256 _totalWithdrawan) = wolf
            .getUserInfo(_user);
        if (_totalWithdrawan < _totalStaked)
            return _totalStaked - _totalWithdrawan;
        else return 0;
    }

    function getUserRequestState(
        address _user
    ) public view returns (bool, uint256) {
        return (requestData[_user].isRequested, requestData[_user].amount);
    }

    function stopRequests(bool _state) external onlyOwner {
        stopRequest = _state;
    }

    function setContract(address _wolf) external onlyOwner {
        wolf = IWolf(_wolf);
    }
}