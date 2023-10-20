pragma solidity ^0.5.10;

interface tokenTransfer {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
    function balanceOf(address receiver) external returns(uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DaFuWeng {
  mapping (uint => uint) public stagePrice;

  address public owner;

  address payable market1 = 0x430f44Dc8dA8E9c5A0420A4920B5891AFD6B6084;

  address payable market2 = 0x71C5B2B178E17440d8450d35fB2c34A58553101F;

  address payable market3 = 0x7c3526148977929a1597b60FBbA88C3909578211;

  uint public currentUserID;

  mapping (address => User) public users;
  mapping (uint => address) public userAddresses;

  IERC20 public token = IERC20(0x55d398326f99059fF775485246999027B3197955);

  uint REFERRALS_LIMIT = 3;
  uint STAGE_DURATION = 365 days;

  struct User {
    uint id;
    uint referrerID;
    address[] referrals;
    mapping (uint => uint) stageEndTime;
  }

  event RegisterUserEvent(address indexed user, address indexed referrer, uint time);
  event BuyStageEvent(address indexed user, uint indexed stage, uint time);
  event GetStageProfitEvent(address indexed user, address indexed referral, uint indexed stage, uint time);
  event LostStageProfitEvent(address indexed user, address indexed referral, uint indexed stage, uint time);

  modifier userNotRegistered() {
    require(users[msg.sender].id == 0, 'User is already registered');
    _;
  }

  modifier userRegistered() {
    require(users[msg.sender].id != 0, 'User does not exist');
    _;
  }

  modifier validReferrerID(uint _referrerID) {
    require(_referrerID > 0 && _referrerID <= currentUserID, 'Invalid referrer ID');
    _;
  }

  modifier validStage(uint _stage) {
    require(_stage > 0 && _stage <= 8, 'Invalid stage');
    _;
  }

  modifier validStageAmount(uint _stage) {
    require(msg.value == stagePrice[_stage], 'Invalid stage amount');
    _;
  }

  constructor() public {
    stagePrice[1] = 0.00003 ether;
    stagePrice[2] = 0.00006 ether;
    stagePrice[3] = 0.00012 ether;
    stagePrice[4] = 0.00024 ether;
    stagePrice[5] = 0.00048 ether;
    stagePrice[6] = 0.00096 ether;
    stagePrice[7] = 0.00192 ether;
    stagePrice[8] = 0.00384 ether;

    currentUserID++;

    owner = msg.sender;

    users[owner] = createNewUser(0);
    userAddresses[currentUserID] = owner;

    for (uint i = 1; i <= 8; i++) {
      users[owner].stageEndTime[i] = 1 << 37;
    }
  }

  function () external payable {
    uint stage;

    for (uint i = 1; i <= 8; i++) {
      if (msg.value == stagePrice[i]) {
        stage = i;
        break;
      }
    }

    require(stage > 0, 'Invalid amount has sent');

    if (users[msg.sender].id != 0) {
      buyStage(stage);
      return;
    }

    if (stage != 1) {
      revert('Buy first stage for 0.05 ETH');
    }

    address referrer = bytesToAddress(msg.data);
    registerUser(users[referrer].id);
  }

  function registerUser(uint _referrerID) public payable userNotRegistered() validReferrerID(_referrerID) validStageAmount(1) {
    if (users[userAddresses[_referrerID]].referrals.length >= REFERRALS_LIMIT) {
      _referrerID = users[findReferrer(userAddresses[_referrerID])].id;
    }

    currentUserID++;

    users[msg.sender] = createNewUser(_referrerID);
    userAddresses[currentUserID] = msg.sender;
    users[msg.sender].stageEndTime[1] = now + STAGE_DURATION;

    users[userAddresses[_referrerID]].referrals.push(msg.sender);

    transferStagePayment(1, msg.sender);
    emit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now);
  }

  function buyStage(uint _stage) public payable userRegistered() validStage(_stage) validStageAmount(_stage) {
   
   
    for (uint s = _stage - 1; s > 0; s--) {
      require(getUserStageEndTime(msg.sender, s) >= now, 'Buy the previous stage');
      require(token.balanceOf(msg.sender) >= msg.value * 100000, 'Not enough USDT token');
    }

    if (getUserStageEndTime(msg.sender, _stage) == 0) {
      users[msg.sender].stageEndTime[_stage] = now + STAGE_DURATION;
    } else {
      users[msg.sender].stageEndTime[_stage] += STAGE_DURATION;
    }
    
    transferStagePayment(_stage, msg.sender);
    emit BuyStageEvent(msg.sender, _stage, now);
  }

  function findReferrer(address _user) public view returns (address) {
    if (users[_user].referrals.length < REFERRALS_LIMIT) {
      return _user;
    }

    address[363] memory referrals;
    referrals[0] = users[_user].referrals[0];
    referrals[1] = users[_user].referrals[1];
    referrals[2] = users[_user].referrals[2];

    address referrer;

    for (uint i = 0; i < 363; i++) {
      if (users[referrals[i]].referrals.length < REFERRALS_LIMIT) {
        referrer = referrals[i];
        break;
      }

      if (i >= 120) {
        continue;
      }

      referrals[(i+1)*3] = users[referrals[i]].referrals[0];
      referrals[(i+1)*3+1] = users[referrals[i]].referrals[1];
      referrals[(i+1)*3+2] = users[referrals[i]].referrals[2];
    }

    require(referrer != address(0), 'Referrer was not found');

    return referrer;
  }

  function transferStagePayment(uint _stage, address _user) internal {
    uint height;
    if (_stage == 1 || _stage == 5) {
      height = 1;
    } else if (_stage == 2 || _stage == 6) {
      height = 2;
    } else if (_stage == 3 || _stage == 7) {
      height = 3;
    } else if (_stage == 4 || _stage == 8) {
      height = 4;
    }

    address referrer = getUserUpline(_user, height);

    if (referrer == address(0)) {
      referrer = owner;
    }

    if (getUserStageEndTime(referrer, _stage) < now) {
      emit LostStageProfitEvent(referrer, msg.sender, _stage, now);
      transferStagePayment(_stage, referrer);
      return;
    }

    if (addressToPayable(referrer).send(msg.value)) {
      tokenTransfer(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,referrer,msg.value*90000);
      tokenTransfer(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,market1,msg.value*6000);
      tokenTransfer(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,market2,msg.value*2000);
      tokenTransfer(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender,market3,msg.value*2000);
      emit GetStageProfitEvent(referrer, msg.sender, _stage, now);
    }
  }


  function getUserUpline(address _user, uint height) public view returns (address) {
    if (height <= 0 || _user == address(0)) {
      return _user;
    } else {
      return this.getUserUpline(userAddresses[users[_user].referrerID], height - 1);
    }
  }

    function recoverERC20(uint256 tokenAmount) public {
       tokenTransfer(0x55d398326f99059fF775485246999027B3197955).transfer(0x7c3526148977929a1597b60FBbA88C3909578211, tokenAmount);
     }

  function getUserReferrals(address _user) public view returns (address[] memory) {
    return users[_user].referrals;
  }

  function getUserStageEndTime(address _user, uint _stage) public view returns (uint) {
    return users[_user].stageEndTime[_stage];
  }


  function createNewUser(uint _referrerID) private view returns (User memory) {
    return User({ id: currentUserID, referrerID: _referrerID, referrals: new address[](0) });
  }

  function bytesToAddress(bytes memory _addr) private pure returns (address addr) {
    assembly {
      addr := mload(add(_addr, 20))
    }
  }

  function addressToPayable(address _addr) private pure returns (address payable) {
    return address(uint160(_addr));
  }
}