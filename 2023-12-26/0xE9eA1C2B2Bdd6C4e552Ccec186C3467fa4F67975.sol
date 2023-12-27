// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
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
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
abstract contract Ownable {
    address public owner;


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// non reentrant
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


// non contract
abstract contract ContractGuard {

    constructor() {}

    modifier nonContract() {
        require(!isContract(msg.sender), "ContractGuard: not user1 error");
        require(tx.origin == msg.sender, "ContractGuard: not user2 error");
        _;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}


// Matrix Strategy.
contract MatrixStrategy is Ownable, ReentrancyGuard, ContractGuard {
    using SafeMath for uint256;

    // user -> matrix -> bool. 0=all, other=other.
    mapping(address => mapping(uint256 => bool)) public userMatrixState;
    // user -> is team leader. 0=not, 1=v1, 2=v2, 3=v3.
    mapping(address => uint256) public userTeamLeaderState;
    // user -> Money.
    mapping(address => mapping(uint256 => Money)) public userMoney;
    struct Money {
        uint256 earnestMoneyIn;
        uint256 earnestMoneyOut;
        uint256 giveBack;
        uint256 taked;
    }
    // team leader earn count;
    mapping(address => uint256) public userTeamLeaderEarnCount;

    // unlock fee to.
    address public leader1;
    // become team leader fee to.
    address public leader2;
    // sign address.
    address public signer;
    // nonce only one.
    mapping(uint256 => bool) public nonceUsed;
    

    constructor(address leader1_, address leader2_, address signer_) {
        leader1 = leader1_;
        leader2 = leader2_;
        signer = signer_;
    }


    event MyEventUnify(string name, address user, uint256 ID, address token, uint256 amount, uint256 indexed nonce);


    // take token.
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }
    
    // set leader.
    function setLeader1(address newLeader1) external onlyOwner {
        require(newLeader1 != address(0), "address error");
        leader1 = newLeader1;
    }

    // set leader2.
    function setLeader2(address newLeader2) external onlyOwner {
        require(newLeader2 != address(0), "address error");
        leader2 = newLeader2;
    }

    // set signer.
    function setSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "address error");
        signer = newSigner;
    }


    // unlock pay.
    function unlockPay(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(!userMatrixState[_user][0], "already unlock all");
        require(!userMatrixState[_user][_ID], "already unlock");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("unlockPay",address(this),_user,_ID,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        TransferHelper.safeTransferFrom(_token, _user, leader1, _amount);
        userMatrixState[_user][_ID] = true;
        emit MyEventUnify("unlockPay", _user, _ID, _token, _amount, _nonce);
    }

    // become team leader pay.
    function becomeTeamLeaderPay(
        address _user,
        uint256 _level,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_level > userTeamLeaderState[_user], "already is team leader");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("becomeTeamLeaderPay",address(this),_user,_level,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        TransferHelper.safeTransferFrom(_token, _user, leader2, _amount);
        userTeamLeaderState[_user] = _level;
        emit MyEventUnify("becomeTeamLeaderPay", _user, _level, _token, _amount, _nonce);
    }
    
    // earnest money pay.
    function earnestMoneyPay(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_ID != 0, "0 ID error");
        // require(userMatrixState[_user][0] || userMatrixState[_user][_ID], "not unlock");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("earnestMoneyPay",address(this),_user,_ID,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        TransferHelper.safeTransferFrom(_token, _user, address(this), _amount);
        userMoney[_user][_ID].earnestMoneyIn += _amount;
        emit MyEventUnify("earnestMoneyPay", _user, _ID, _token, _amount, _nonce);
    }    

    // earnest money gain.
    function earnestMoneyGain(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("earnestMoneyGain",address(this),_user,_ID,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        userMoney[_user][_ID].earnestMoneyOut += _amount;  // take mongy need verify. can not be more than earnest money.
        require(userMoney[_user][_ID].earnestMoneyIn >= userMoney[_user][_ID].earnestMoneyOut, "earnest money error");
        TransferHelper.safeTransfer(_token, _user, _amount);
        emit MyEventUnify("earnestMoneyGain", _user, _ID, _token, _amount, _nonce);
    }

    // earn give back pay.
    function earnGiveBackPay(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("earnGiveBackPay",address(this),_user,_ID,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        userMoney[_user][_ID].giveBack += _amount;   // take mongy need verify. must have earnest money.
        require(userMoney[_user][_ID].earnestMoneyIn > 0, "not have earnest money error");
        TransferHelper.safeTransferFrom(_token, _user, address(this), _amount);
        emit MyEventUnify("earnGiveBackPay", _user, _ID, _token, _amount, _nonce);
    }

    // earn take gain.
    function earnTakeGain(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("earnTakeGain",address(this),_user,_ID,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        userMoney[_user][_ID].taked += _amount;      // take mongy need verify. must have earnest money.
        require(userMoney[_user][_ID].earnestMoneyIn > 0, "not have earnest money error");
        TransferHelper.safeTransfer(_token, _user, _amount);
        emit MyEventUnify("earnTakeGain", _user, _ID, _token, _amount, _nonce);
    }

    // team leader earn gain.
    function teamLeaderEarnGain(
        address _user,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(userTeamLeaderState[_user] > 0, "not team leader");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("teamLeaderEarnGain",address(this),_user,_token,_amount,_nonce,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        userTeamLeaderEarnCount[_user] += _amount;
        TransferHelper.safeTransfer(_token, _user, _amount);
        emit MyEventUnify("teamLeaderEarnGain", _user, userTeamLeaderState[_user], _token, _amount, _nonce);
    }


    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

}