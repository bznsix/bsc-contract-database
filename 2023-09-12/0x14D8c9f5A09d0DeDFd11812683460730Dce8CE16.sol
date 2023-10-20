// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

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
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

pragma solidity ^0.8.2;

abstract contract Initializable {
   
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

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
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

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

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeBEP20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IBEP20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }

  function safeTransferFrom(
    IBEP20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
  }

  function safeApprove(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeBEP20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, value)
    );
  }

  function safeIncreaseAllowance(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IBEP20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance =
      token.allowance(address(this), spender).sub(
        value,
        "SafeBEP20: decreased allowance below zero"
      );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function _callOptionalReturn(IBEP20 token, bytes memory data) private {
    bytes memory returndata =
      address(token).functionCall(data, "SafeBEP20: low-level call failed");
    if (returndata.length > 0) {
      require(
        abi.decode(returndata, (bool)),
        "SafeBEP20: BEP20 operation did not succeed"
      );
    }
  }
}

contract ChefPro is OwnableUpgradeable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public _stakedToken;
    IBEP20 public _rewardToken;

    uint256 [] public _blockRewards;
    uint256 [] public _rewardHeights;

    uint256 public _intervalPerBlock;
    uint256 [] public _lockPeriods;
    uint256 [] public _lockRewards;

    uint256 public _startTime;
    uint256 public _endTime;

    uint256 public _halfHeight;
    uint256 public _halfRate;
    
    uint256 public _totalHashRate;
    uint256 public _totalAmount;
    uint256 public _totalStakingHashRate;
    uint256 public _totalPromoteHashRate;
    
    struct BlockRecord {
        uint256 height;
        uint256 totalHashRate;
    }
    
    struct Order {
        uint256 amount;
        uint256 hashRate;
        uint256 time;
        uint256 height;
        uint256 offsetProfit;
        uint256 status; 
        uint256 start;
        uint256 end;
    }

    struct Info {
        uint256 lastLockId;
        uint256 lastStakingHeight;
        uint256 lastPromoteHeight;
        uint256 stakingNum;
        uint256 promoteNum;
        uint256 stakingHashrate;
        uint256 promoteHashrate;
        uint256 pendingProfit;
    }
    
    BlockRecord[] private _records;
    mapping(address => mapping(uint256 => Order)) private _stakingOrders;
    mapping(address => mapping(uint256 => Order)) private _promoteOrders;
    
    mapping(address => Info) private _infos;
    mapping(address => uint256) private _accTakeProfit;

    uint256[] public _genRewards;
    uint256 public Denominator;
    mapping(address => address) public _inviters;
    
    function initialize (
        address[] memory addrs,
        uint256 rewardPerBlock,
        uint256 intervalPerBlock,
        uint256[] memory lockPeriods,
        uint256[] memory lockRewards,
        uint256[] memory genRewards,
        uint256 startTime,
        uint256 endTime,
        uint256 halfHeight,
        uint256 halfRate
    ) external initializer payable {
        __Ownable_init();

        _stakedToken = IBEP20(addrs[0]);
        _rewardToken = IBEP20(addrs[1]);
        
        _intervalPerBlock = intervalPerBlock;
        if (lockPeriods.length > 0) _lockPeriods = lockPeriods;
        if (lockRewards.length > 0) _lockRewards = lockRewards;
        _startTime = startTime;
        _endTime = endTime;

        _halfHeight = halfHeight;
        _halfRate = halfRate;
    
        _blockRewards.push(rewardPerBlock);
        _rewardHeights.push(_blockHeight());

        Denominator = 1000;
        if (genRewards.length > 0) _genRewards = genRewards;
        payable(addrs[2]).transfer(msg.value);
    }

    function getBlockReward() public view returns(uint256){
        uint256 num = _blockHeight().div(_halfHeight);
        uint256 blockReward = _blockRewards[0];
        for(uint i=0; i<num; i++) {
            blockReward = blockReward.mul(_halfRate).div(Denominator); 
        }
        return blockReward;
    }

    function getAccReward(uint256 height) public view returns(uint256){
        if (_halfHeight > 0) {
            uint256 num = height.div(_halfHeight);
            uint256 accReward = 0;
            uint256 blockReward = _blockRewards[0];
            for(uint i=0; i<num; i++) {
                accReward = blockReward.mul(_halfHeight).add(accReward);
                blockReward = blockReward.mul(_halfRate).div(Denominator);  
            }
            uint256 left = height.mod(_halfHeight);
            if (left > 0) {
                accReward = blockReward.mul(left).add(accReward);
            }
            return accReward;
        }else {
            uint256 len = _rewardHeights.length;
            if (len == 1) {
                return height.sub(_rewardHeights[0]).mul(_blockRewards[0]);
            }
            uint256 accReward = 0;
            uint256 j = len-1;
            for (uint i=0; i<len-1; i++) {
                if (height >= _rewardHeights[i] && height < _rewardHeights[i+1]) {
                    j=i;
                    break;
                }
            }
            for (uint i=0; i<j; i++) {
                accReward = _rewardHeights[i+1].sub(_rewardHeights[i]).mul(_blockRewards[i]).add(accReward);
            }
            if (height > _rewardHeights[j]) {
                accReward = height.sub(_rewardHeights[j]).mul(_blockRewards[j]).add(accReward);
            }
            return accReward;
        }  
    }
    
    function deposit(uint256 lockId, address inviter, uint256 amount) external {
        require(amount > 0, "staking amount is 0");
        require(block.timestamp >= _startTime && block.timestamp < _endTime, "is disable");
        
        uint256 newHashRate;
        if (lockId < _lockRewards.length) {
            newHashRate = amount.mul(_lockRewards[lockId]).div(Denominator);
        }else {
            newHashRate = amount;
        }
        if (_genRewards.length > 0) {
            _inviteHashrate(inviter, address(msg.sender), newHashRate);
        }
        _totalAmount = _totalAmount.add(amount);
        
        uint256 blockHeight = _blockHeight();
        uint256 len = _records.length;
        
         _totalHashRate = _totalHashRate.add(newHashRate);
         _totalStakingHashRate = _totalStakingHashRate.add(newHashRate);
        if (len >0 && _records[len-1].height == blockHeight){
            BlockRecord storage record = _records[len-1];
            record.totalHashRate = record.totalHashRate.add(newHashRate);
        }else{
            _records.push(BlockRecord(blockHeight,_totalHashRate));
        }
        
        uint256 num = _infos[msg.sender].stakingNum;
        len = _records.length;
        if (num > 0 
            && _infos[msg.sender].lastStakingHeight == blockHeight 
            && _infos[msg.sender].lastLockId == lockId){
            Order storage order=_stakingOrders[msg.sender][num-1];
            order.amount = order.amount.add(amount);
            order.hashRate = order.hashRate.add(newHashRate);
        }else{
            _stakingOrders[msg.sender][num].amount = amount;
            _stakingOrders[msg.sender][num].hashRate = newHashRate;
            _stakingOrders[msg.sender][num].time = block.timestamp;
            _stakingOrders[msg.sender][num].height = blockHeight;
            _stakingOrders[msg.sender][num].start = len-1;
            if (lockId < _lockPeriods.length) {
                _stakingOrders[msg.sender][num].end = block.timestamp.add(_lockPeriods[lockId]);
            }else {
                _stakingOrders[msg.sender][num].end = block.timestamp;
            }
            num++;
        }
        
        _infos[msg.sender].lastLockId = lockId;
        _infos[msg.sender].lastStakingHeight = blockHeight;
        _infos[msg.sender].stakingNum = num;
        _infos[msg.sender].stakingHashrate = _infos[msg.sender].stakingHashrate.add(newHashRate);
        
        _stakedToken.transferFrom(address(msg.sender), address(this), amount);
    }

    function _inviteHashrate(address sharer, address from, uint256 hashrate) internal {
        uint256 rewardHashrate;
        address invitee = from;
        if (_inviters[from] == address(0) && _infos[from].stakingNum == 0) {
            _inviters[from] = sharer;
        }
        for (uint i=0; i<_genRewards.length; i++) {
            address inviter = _inviters[invitee];

            if (inviter == address(0) || inviter == invitee){
                return;
            }
            if (_infos[inviter].stakingHashrate == 0){
                invitee = inviter;
                continue;
            } 

            rewardHashrate = hashrate.mul(_genRewards[i]).div(Denominator);

            uint256 blockHeight = _blockHeight();
            uint256 len = _records.length;

            _totalHashRate = _totalHashRate.add(rewardHashrate);
            _totalPromoteHashRate = _totalPromoteHashRate.add(rewardHashrate);

            if (len > 0 && _records[len-1].height == blockHeight){
                BlockRecord storage record = _records[len-1];
                record.totalHashRate = record.totalHashRate.add(rewardHashrate);
            }else{
                _records.push(BlockRecord(blockHeight,_totalHashRate));
            }

            uint256 num = _infos[inviter].promoteNum;
            len = _records.length;
            if (num == 0) {
                _promoteOrders[inviter][num].hashRate = rewardHashrate;
                _promoteOrders[inviter][num].time = block.timestamp;
                _promoteOrders[inviter][num].height = blockHeight;
                _promoteOrders[inviter][num].start = len-1;
                num++;
            }else {
                Order storage order = _promoteOrders[inviter][num-1];
                uint256 orderHashrate = order.hashRate.add(rewardHashrate); 
                
                if (_infos[inviter].lastPromoteHeight == blockHeight){
                    order.hashRate = orderHashrate;
                }else{
                    order.end = len-1;
                    order.status = 1;
                    if (orderHashrate > 0){
                        _promoteOrders[inviter][num].hashRate = orderHashrate;
                        _promoteOrders[inviter][num].time = block.timestamp;
                        _promoteOrders[inviter][num].height = blockHeight;
                        _promoteOrders[inviter][num].start = len-1;
                        num++;
                    }
                }
            }

            _infos[inviter].lastPromoteHeight = blockHeight;
            _infos[inviter].promoteNum = num;
            _infos[inviter].promoteHashrate = _infos[inviter].promoteHashrate.add(rewardHashrate);

            invitee = inviter;
        }
    }
    
    function releaseHeight() external view returns(uint256){
        return _blockHeight();
    }
    
    function _blockHeight() internal view returns(uint256){
        uint256 nowTime = block.timestamp;
        if (nowTime < _startTime){
            return 0;
        }
        if (nowTime > _endTime){
            nowTime = _endTime;
        }
        uint256 blockHeight = nowTime.sub(_startTime).div(_intervalPerBlock);
        return blockHeight;
    }
    
    function queryPreBlockReward()external view returns(uint256){
        uint256 stakingNum = _infos[msg.sender].stakingNum;
        uint256 promoteNum = _infos[msg.sender].promoteNum;
        if (stakingNum == 0 && promoteNum == 0){
            return 0;
        }
        uint256 blockHeight = _blockHeight();
        uint256 len = _records.length;
        if (blockHeight == 0 || len == 0){
            return 0;
        }
        uint256 profit;
        uint256 preHashrate;
        uint256 preBlockHeight = blockHeight - 1;
        for(uint i=0; i<stakingNum; i++){
            Order storage order = _stakingOrders[msg.sender][i];
            if (order.height > preBlockHeight || order.status == 2 && order.end <= preBlockHeight){
                continue;
            }
            preHashrate = preHashrate.add(order.hashRate);
        }
        for(uint i=0; i<promoteNum; i++){
            Order storage order = _promoteOrders[msg.sender][i];
            if (order.height > preBlockHeight || order.status == 1 && order.end <= preBlockHeight){
                continue;
            }
            preHashrate = preHashrate.add(order.hashRate);
        }
        if (preHashrate == 0){
            return 0;
        }
        uint256 totalHashRate;
        uint256 accReward = getAccReward(blockHeight);
        uint256 rewardDiff;
        uint256 blockDiff;
        if (len == 1){
            if (_records[0].height == blockHeight){
                return 0;
            }
            totalHashRate = _records[0].totalHashRate;
            rewardDiff = accReward.sub(getAccReward(_records[0].height));
            blockDiff = blockHeight.sub(_records[0].height);
            profit = preHashrate.mul(rewardDiff).div(blockDiff).div(totalHashRate);
            return profit;
        }
        if (_records[len-1].height == blockHeight){
            totalHashRate = _records[len-2].totalHashRate;
            
            rewardDiff = getAccReward(_records[len-1].height).sub(getAccReward(_records[len-2].height));
            blockDiff = _records[len-1].height.sub(_records[len-2].height);
            profit = preHashrate.mul(rewardDiff).div(blockDiff).div(totalHashRate);
        }else{
            totalHashRate = _records[len-1].totalHashRate;
            rewardDiff = accReward.sub(getAccReward(_records[len-1].height));
            blockDiff = blockHeight.sub(_records[len-1].height);
            profit = preHashrate.mul(rewardDiff).div(blockDiff).div(totalHashRate);
        }
        return profit;
    }
    
    function queryAccReward(address account) public view returns(uint256){
        return _accTakeProfit[account].add(pendingReward(account));
    }
    
    function pendingReward(address account) public view returns(uint256){
        uint256 stakingNum = _infos[account].stakingNum;
        uint256 promoteNum = _infos[account].promoteNum;
        if (stakingNum == 0 && promoteNum == 0){
            return 0;
        }
        uint256 profit;
        uint256 totalProfit;
        uint256 blockHeight = _blockHeight();
        uint256 accReward = getAccReward(blockHeight);
        uint len = _records.length;
        for(uint i=0; i<stakingNum; i++){
            Order storage order = _stakingOrders[account][i];
            if (order.status == 2){
                continue;
            }
            profit = _queryProfit(order,blockHeight,accReward,len);
            totalProfit = totalProfit.add(profit);
        }
        for(uint i=0; i<promoteNum; i++){
            Order storage order = _promoteOrders[account][i];
            if (order.status == 2){
                continue;
            }else if (order.status == 1){
                profit = _queryPromoteProfit(order);
            }else{
                profit = _queryProfit(order,blockHeight,accReward,len);
            }
            totalProfit = totalProfit.add(profit);
        }
        uint256 pendingProfit = _infos[account].pendingProfit;
        totalProfit = totalProfit.add(pendingProfit);
        return totalProfit;
    }
    
    function _queryPromoteProfit(Order storage order)internal view returns(uint256){
        uint256 profit;
        for(uint j=order.start; j<order.end; j++){
            uint256 totalHashRate = _records[j].totalHashRate;
            
            uint256 rewardDiff = getAccReward(_records[j+1].height).sub(getAccReward(_records[j].height));
            profit = rewardDiff.mul(order.hashRate).div(totalHashRate).add(profit);
        }
        if (profit > order.offsetProfit){
            profit = profit.sub(order.offsetProfit);
        }else {
            profit = 0;
        }
        return profit;
    }
    
    function _queryProfit(Order storage order, uint256 blockHeight, uint256 accReward, uint len)internal view returns(uint256){
        uint256 profit;
        uint256 totalHashRate;
        uint256 rewardDiff;
        uint start = order.start;
        for(uint j=start; j<len-1; j++){
            totalHashRate = _records[j].totalHashRate;
            rewardDiff = getAccReward(_records[j+1].height).sub(getAccReward(_records[j].height));
            profit = rewardDiff.mul(order.hashRate).div(totalHashRate).add(profit);
        }
        if (blockHeight > _records[len-1].height){
            totalHashRate = _records[len-1].totalHashRate;
            
            rewardDiff = accReward.sub(getAccReward(_records[len-1].height));
            profit = rewardDiff.mul(order.hashRate).div(totalHashRate).add(profit);
        }
        if (profit > order.offsetProfit){
            profit = profit.sub(order.offsetProfit);
        }else {
            profit = 0;
        }
        return profit;
    }
    
    function _calculateProfit(Order storage order, uint256 blockHeight, uint256 accReward, uint len)internal returns(uint256){
        uint start = order.start;
        uint256 profit;
        uint256 totalHashRate;
        uint256 rewardDiff;
        uint256 preOffsetProfit;
        for(uint j=start; j<len-1; j++){
            totalHashRate = _records[j].totalHashRate;
            
            rewardDiff = getAccReward(_records[j+1].height).sub(getAccReward(_records[j].height));
            profit = rewardDiff.mul(order.hashRate).div(totalHashRate).add(profit);
        }
        if (profit > 0){
            order.start = len-1;
        }
        preOffsetProfit = order.offsetProfit;
        if (blockHeight > _records[len-1].height){
            totalHashRate = _records[len-1].totalHashRate;
            rewardDiff = accReward.sub(getAccReward(_records[len-1].height));
            order.offsetProfit = rewardDiff.mul(order.hashRate).div(totalHashRate);
            profit = profit.add(order.offsetProfit);
        }
        if (profit > preOffsetProfit){
            profit = profit.sub(preOffsetProfit);
        }else{
            profit = 0;
        }
        
        return profit;
    }
    
    function redeemAllToken() external {
        bool canRedeem = canRedeemAllToken(address(msg.sender));
        require(canRedeem, "no free tokens");
        uint256 profit;
        uint256 totalProfit;
        
        uint256 blockHeight = _blockHeight();
        uint256 accReward = getAccReward(blockHeight);
        uint len = _records.length;
        
        uint256 stakingNum = _infos[msg.sender].stakingNum;
        for(uint i=0; i<stakingNum; i++){
            Order storage order = _stakingOrders[msg.sender][i];
            if (order.status == 2 || block.timestamp < order.end){
                continue;
            }
            profit = _calculateProfit(order,blockHeight,accReward,len);
            totalProfit = totalProfit.add(profit);
        }
        require(totalProfit > 0);
        uint256 pendingProfit = _infos[msg.sender].pendingProfit;
        totalProfit = totalProfit.add(pendingProfit);
        
        uint256 allAmount;
        uint256 allHashRate;
        for(uint i=0; i<stakingNum; i++){
            Order storage order = _stakingOrders[msg.sender][i];
            if (order.status == 0 && block.timestamp >= order.end){
                allAmount = allAmount.add(order.amount);
                allHashRate = allHashRate.add(order.hashRate);
                order.status = 2;
                order.end = blockHeight;
            }
        }
        if (allAmount > 0){
            _stakedToken.safeTransfer(address(msg.sender),allAmount);
        }
        _infos[msg.sender].pendingProfit = totalProfit;
        _infos[msg.sender].stakingHashrate = _infos[msg.sender].stakingHashrate.sub(allHashRate);

        _totalAmount = _totalAmount.sub(allAmount);    
        _totalHashRate = _totalHashRate.sub(allHashRate);
        _totalStakingHashRate = _totalStakingHashRate.sub(allHashRate);
        if (len > 0 && _records[len-1].height == blockHeight){
            BlockRecord storage record = _records[len-1];
            record.totalHashRate = record.totalHashRate.sub(allHashRate);
        }else{
            _records.push(BlockRecord(blockHeight,_totalHashRate));
        }
    }
    
    function canRedeemAllToken(address account) public view returns(bool) {
        uint256 stakingNum = _infos[account].stakingNum;
        if (stakingNum == 0) return false;
        uint256 redeemedNum; 
        for(uint i=0; i<stakingNum; i++){
            Order storage order = _stakingOrders[account][i];
            if (order.status == 0 && block.timestamp < order.end){
                return false;
            }
            if (order.status == 2) {
                redeemedNum++;
            }
        }
        if (redeemedNum == stakingNum) {
            return false;
        }
        return true;
    }
    
    function withdraw() external {
        uint256 stakingNum = _infos[msg.sender].stakingNum;
        uint256 promoteNum = _infos[msg.sender].promoteNum;
        require(stakingNum > 0 || promoteNum > 0);
        uint256 profit;
        uint256 totalProfit;
        
        uint256 blockHeight = _blockHeight();
        uint256 accReward = getAccReward(blockHeight);
        uint len = _records.length;
        for(uint i=0; i<stakingNum; i++){
            Order storage order = _stakingOrders[msg.sender][i];
            if (order.status == 2){
                continue;
            }
            profit = _calculateProfit(order,blockHeight,accReward,len);
            totalProfit = totalProfit.add(profit);
        }
        for(uint i=0; i<promoteNum; i++){
            Order storage order = _promoteOrders[msg.sender][i];
            if (order.status == 2){
                continue;
            }else if (order.status == 1){
                profit = _queryPromoteProfit(order);
                order.status = 2;
            }else {
                profit = _calculateProfit(order,blockHeight,accReward,len);
            }
            totalProfit = totalProfit.add(profit);
        }
        uint256 pendingProfit = _infos[msg.sender].pendingProfit;
        totalProfit = totalProfit.add(pendingProfit);
        require(totalProfit > 0);
        _rewardToken.safeTransfer(address(msg.sender),totalProfit);
        _accTakeProfit[msg.sender] = _accTakeProfit[msg.sender].add(totalProfit);
        _infos[msg.sender].pendingProfit = 0;
    }
    
    function redeemToken(uint256 index) external {
        uint256 num = _infos[msg.sender].stakingNum;
        require(num > 0 && num > index);
        Order storage order = _stakingOrders[msg.sender][index];
        require(order.status == 0 && block.timestamp >= order.end);

        uint256 len = _records.length;
        uint256 blockHeight = _blockHeight();
        uint256 accReward = getAccReward(blockHeight);
        uint256 profit = _calculateProfit(order,blockHeight,accReward,len);
      
        _stakedToken.safeTransfer(address(msg.sender),order.amount);
        order.status = 2;
        order.end = blockHeight;
        _infos[msg.sender].pendingProfit = _infos[msg.sender].pendingProfit.add(profit);
        _infos[msg.sender].stakingHashrate = _infos[msg.sender].stakingHashrate.sub(order.hashRate);
        
        _totalAmount = _totalAmount.sub(order.amount);
        _totalHashRate = _totalHashRate.sub(order.hashRate);
        _totalStakingHashRate = _totalStakingHashRate.sub(order.hashRate);
        if (len > 0 && _records[len-1].height == blockHeight){
            BlockRecord storage record = _records[len-1];
            record.totalHashRate = record.totalHashRate.sub(order.hashRate);
        }else{
            _records.push(BlockRecord(blockHeight,_totalHashRate));
        }
    }

    function getStakedNum(address account) public view returns(uint256){
        return _infos[account].stakingNum;
    }

    function getPromoteNum(address account) public view returns(uint256){
        return _infos[account].promoteNum;
    }
    
     function getAllTokenOrder(address account) public view returns(uint256[]memory){
        uint256 num = _infos[account].stakingNum;
        if (num == 0){
            uint256[] memory nullArray = new uint256[](1);
            nullArray[0] = 0;
            return nullArray;
        }
        uint256 size = 5;
        uint256 len = num*size+1;
        uint256[] memory orderArray = new uint256[](len);
        orderArray[0] = num;
        uint j;
        for(uint i=num; i>0;){
            j = i-1;
            Order storage order = _stakingOrders[account][j];
            orderArray[size*j+1] = order.amount;
            orderArray[size*j+2] = 0;
            if (order.status == 0){
                if (block.timestamp >= order.end) {
                    orderArray[size*j+2] = 1;
                } 
            } if (order.status == 2){
              orderArray[size*j+2] = 2;  
            }
            orderArray[size*j+3] = order.time;
            orderArray[size*j+4] = order.end;
            orderArray[size*j+5] = order.hashRate;
            if (i == 1) break;
            i--;
        }
        return orderArray;
    }
    
    function getAllPromoteOrder(address account) public view returns(uint256[]memory){
        uint256 num = _infos[account].promoteNum;
        if (num == 0){
            uint256[] memory nullArray = new uint256[](1);
            nullArray[0] = 0;
            return nullArray;
        }
        uint256 size = 2;
        uint256 len = num*size+1;
        uint256 lastNum = 30;
        if (num > lastNum) {
            len = lastNum*size+1;
        }
        uint256[] memory orderArray = new uint256[](len);
        orderArray[0] = num;
        if (num > lastNum) {
            orderArray[0] = lastNum;
        }
        uint j;
        uint count;
        for(uint i=num; i>0;){
            j = i-1;
            Order storage order = _promoteOrders[account][j];
            orderArray[size*j+1] = order.hashRate;
            orderArray[size*j+2] = order.time;

            count++;
            if (count == lastNum) break;
            if (i == 1) break;
            i--;
        }
        return orderArray;
    }
    
    function getAllOrder(address account) external view returns(uint256[]memory, uint256[]memory){
        return (getAllTokenOrder(account), getAllPromoteOrder(account));
    }

    function userTotalHashRate(address account) public view returns(uint256){
        uint256 stakingHashrate = _infos[account].stakingHashrate;
        uint256 promoteHashrate = _infos[account].promoteHashrate;
        return stakingHashrate.add(promoteHashrate);
    }
    
    function userStakingHashRate(address account) public view returns(uint256){
        return _infos[account].stakingHashrate;
    }

    function userPromoteHashRate(address account) public view returns(uint256){
        return _infos[account].promoteHashrate;
    }

    function userStakingToken(address account) public view returns(uint256){
        uint256 num = _infos[account].stakingNum;
        if (num == 0){
            return 0;
        }
        uint256 totalToken;
        for(uint i=0; i<num; i++){
           Order storage order = _stakingOrders[account][i];
           if (order.status == 2){
                continue;
           }
           totalToken = totalToken.add(order.amount);
        }
        return totalToken;
    }
    
    function userHashrateRatio(address account) public view returns(uint256){
        if (_totalHashRate > 0){
            return userTotalHashRate(account).mul(10**18).div(_totalHashRate);
        }
        return 0;
    }
    
    function emergencyRewardWithdraw(uint256 amount) external onlyOwner {
        require(block.timestamp > _endTime, "Mining is not over yet");
        _rewardToken.safeTransfer(address(msg.sender), amount);
    }

    function emergencyStakeWithdraw(uint256 amount) external onlyOwner {
        require(block.timestamp > _endTime, "Mining is not over yet");
        _stakedToken.safeTransfer(address(msg.sender), amount);
    }

    function recoverWrongTokens(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(_stakedToken), "Cannot be staked token");
        require(tokenAddress != address(_rewardToken), "Cannot be reward token");

        IBEP20(tokenAddress).safeTransfer(address(msg.sender), tokenAmount);
    }

    function stopReward() external onlyOwner {
        _endTime = block.timestamp;
    }

    function updateRewardPerBlock(uint256 rewardPerBlock) external onlyOwner {
        require(_halfHeight == 0, "Is halving mechanism");
        uint256 blockHeight = _blockHeight();
        if (blockHeight == _rewardHeights[_rewardHeights.length - 1]) {
            _blockRewards[_blockRewards.length -1] = rewardPerBlock;
        }else {
            _rewardHeights.push(blockHeight);
            _blockRewards.push(rewardPerBlock);
        }
    }

    function updateIntervalPerBlock(uint256 intervalPerBlock) external onlyOwner {
        require(_totalHashRate == 0, "Pool has started");
        _intervalPerBlock = intervalPerBlock;
    }

    function updateStartAndEndTime(uint256 startTime, uint256 endTime) external onlyOwner {
        if (_totalHashRate == 0) {
            require(startTime < endTime, "New startTime must be lower than new endTime");
            require(block.timestamp < startTime, "New startTime must be higher than current time");
            _startTime = startTime;
        }
        require(block.timestamp < endTime, "New endTime must be higher than current time");
        _endTime = endTime;
    }

    function updateGenerationRewards(uint256 [] memory genRewards) external onlyOwner {
        _genRewards = genRewards;
    }

    function getGenerationRewards() external view returns (uint256[] memory) {
        return _genRewards;
    }

    function updateHalfInfos(uint256 halfHeight, uint256 halfRate) external onlyOwner {
        require(_totalHashRate == 0, "Pool has started");
        _halfHeight = halfHeight;
        _halfRate = halfRate;
    }

    function updateLockInfos(uint256 [] memory lockPeriods, uint256 [] memory lockRewards) external onlyOwner {
        require(lockPeriods.length == lockRewards.length, "Size not match");
        _lockPeriods = lockPeriods;
        _lockRewards = lockRewards;
    }

    function getBaseInfos() external view returns(uint256[] memory, string[] memory, address[] memory, uint256[] memory, uint256[] memory, uint256[] memory){
        uint256[] memory array = new uint256[](15);
        array[0] = _totalAmount;
        array[1] = _intervalPerBlock;
        array[2] = _halfHeight > 0 ? getBlockReward() : _blockRewards[_blockRewards.length - 1];
        array[3] = _startTime;
        array[4] = _endTime;
        array[5] = _stakedToken.decimals();
        array[6] = _rewardToken.decimals();
        array[7] = _halfHeight;
        array[8] = _totalHashRate;
        array[9] = _totalStakingHashRate;
        array[10] = _totalPromoteHashRate;
        array[11] = _blockHeight();
        array[12] = getAccReward(array[11]);
        array[13] = _stakedToken.balanceOf(address(this));
        array[14] = _rewardToken.balanceOf(address(this));
        string[] memory strs = new string[](2);
        strs[0] = _stakedToken.symbol();
        strs[1] = _rewardToken.symbol();
        address[] memory addresses = new address[](2);
        addresses[0] = address(_stakedToken);
        addresses[1] = address(_rewardToken);
        return (array, strs, addresses, _genRewards, _lockPeriods, _lockRewards);
    }

    function getUserInfos(address account) external view returns(uint256[] memory, uint256[] memory, uint256[] memory){
        uint256[] memory array = new uint256[](10);
        array[0] = _stakedToken.balanceOf(account);
        array[1] = _stakedToken.allowance(account, address(this));
        array[2] = userStakingToken(account);
        array[3] = pendingReward(account);
        array[4] = queryAccReward(account);
        array[5] = userHashrateRatio(account);
        array[6] = userTotalHashRate(account);
        array[7] = _infos[account].stakingHashrate;
        array[8] = _infos[account].promoteHashrate;

        uint256 blockReward = _halfHeight > 0 ? getBlockReward() : _blockRewards[_blockRewards.length - 1];
        array[9] = _totalHashRate > 0 ? userTotalHashRate(account).mul(blockReward).div(_totalHashRate) : 0;
        
        return (array, getAllTokenOrder(account), getAllPromoteOrder(account));
    }
}