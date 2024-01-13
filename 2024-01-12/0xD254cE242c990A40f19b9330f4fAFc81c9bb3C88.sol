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


interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


// ILinkedin.
interface ILinkedin {
    function mySuper(address user) external view returns (address);
    function myJuniors(address user) external view returns (address[] memory);
    function getSuperList(address user, uint256 list) external view returns (address[] memory);
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


// BLQ Locked V1.
contract BLQLockedV1 is Ownable, ReentrancyGuard, ContractGuard {
    using SafeMath for uint256;


    // sign address.
    address public signer;
    // nonce only one.
    mapping(uint256 => bool) public nonceUsed;

    mapping(address => bool) public isBurnToken;    // is burn token.
    address[] public burnTokens;
    
    uint256[2] public superEarnRatio = [1000, 500]; // 10%% and 5%%.
    address public linkedin;                        // linkedin.
    bool public isSuperEarn = true;                 // is super earn.
    uint256 constant private DENOMINATOR = 10000;   // denominator.
    

    constructor(address signer_, address linkedin_) {
        signer = signer_;
        linkedin = linkedin_;
    }


    event UserLockPay(uint256 indexed nonce, address user, uint256 ID, address token, uint256 amount, uint256 time);
    event UserEarnGain(uint256 indexed nonce, address user, address token, uint256 amount, uint256 time, 
    address superAddress, uint256 superAmount, address superSuperAddress, uint256 superSuperAmount);
    event TakeMoneyGain(uint256 indexed nonce, address user, uint256 ID, address token, uint256 amount, uint256 time);
    event TeamEarnGain(uint256 indexed nonce, address user, address token, uint256 amount, uint256 time);


    // take eth.
    function takeETH(address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransferETH(to, value);
    }

    // take token.
    function takeToken(address token, address to , uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }

    // set signer.
    function setSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "address error");
        signer = newSigner;
    }

    // set is burn token.
    function setIsBurnToken(address newBurnToken, bool newStatus) external onlyOwner {
        isBurnToken[newBurnToken] = newStatus;
        burnTokens.push(newBurnToken);
    }

    // get burn tokens.
    function getBurnTokens() external view returns(address[] memory) {
        return burnTokens;
    }

    // set superEarnRatio.
    function setSuperEarnRatio(uint256 superRatio, uint256 superSuperRatio) external onlyOwner {
        superEarnRatio[0] = superRatio;
        superEarnRatio[1] = superSuperRatio;
    }

    // set linkedin.
    function setLinkedin(address newLinkedin) external onlyOwner {
        require(newLinkedin != address(0), "address error");
        linkedin = newLinkedin;
    }

    // set is super earn.
    function setIsSuperEarn(bool newStatus) external onlyOwner {
        isSuperEarn = newStatus;
    }
    

    // user lock pay.
    function userLockPay(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _time,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("userLockPay",address(this),_user,_ID,_token,_amount,_nonce,_time,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        if(isBurnToken[_token]) {
            uint256 _balancesOfBefore = IERC20(_token).balanceOf(address(this));
            TransferHelper.safeTransferFrom(_token, _user, address(this), _amount);
            uint256 _balancesOfLast = IERC20(_token).balanceOf(address(this));

            uint256 _amount2 = _balancesOfLast.sub(_balancesOfBefore);
            IERC20(_token).burn(_amount2);
        }else {
            TransferHelper.safeTransferFrom(_token, _user, address(this), _amount);
        }

        emit UserLockPay(_nonce, _user, _ID, _token, _amount, _time);
    }

    // user gain.
    function userEarnGain(
        address _user,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _time,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("userEarnGain",address(this),_user,_token,_amount,_nonce,_time,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        TransferHelper.safeTransfer(_token, _user, _amount);

        // super.
        address _superAddress = ILinkedin(linkedin).mySuper(_user);
        address _superSuperAddress = ILinkedin(linkedin).mySuper(_superAddress);
        uint256 _superAmount = _superAddress == address(0) ? 0 : _amount.mul(superEarnRatio[0]).div(DENOMINATOR);
        uint256 _superSuperAmount = _superSuperAddress == address(0) ? 0 :_amount.mul(superEarnRatio[1]).div(DENOMINATOR);
        if(isSuperEarn) {
            if(_superAddress != address(0) && _superAmount > 0) TransferHelper.safeTransfer(_token, _superAddress, _superAmount);
            if(_superSuperAddress != address(0) && _superSuperAmount > 0) TransferHelper.safeTransfer(_token, _superSuperAddress, _superSuperAmount);
            emit UserEarnGain(_nonce, _user, _token, _amount, _time, _superAddress, _superAmount, _superSuperAddress, _superSuperAmount);
        }else {
            emit UserEarnGain(_nonce, _user, _token, _amount, _time, _superAddress, 0, _superSuperAddress, 0);
        }

    }

    // take money gain.
    function takeMoneyGain(
        address _user,
        uint256 _ID,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _time,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("takeMoneyGain",address(this),_user,_ID,_token,_amount,_nonce,_time,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        TransferHelper.safeTransfer(_token, _user, _amount);

        emit TakeMoneyGain(_nonce, _user, _ID, _token, _amount, _time);
    }

    // team earn gain.
    function teamEarnGain(
        address _user,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        uint256 _time,
        uint256 _deadline,
        bytes memory _signature
    ) external nonReentrant nonContract {
        require(msg.sender == _user, "not you");
        require(_amount > 0, "amount is zero");
        require(_deadline > block.timestamp, "have expired");

        // verify sginer.
        bytes32 hashData = keccak256(abi.encodePacked("teamEarnGain",address(this),_user,_token,_amount,_nonce,_time,_deadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signerAddress = recoverSigner(messageHash, _signature);
        require(signerAddress != address(0), "Signer address is zero address");
        require(signerAddress == signer, "Signer is error");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;
        
        // ok.
        require(isContract(_token), "token error");
        TransferHelper.safeTransfer(_token, _user, _amount);
        emit TeamEarnGain(_nonce, _user, _token, _amount, _time);
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