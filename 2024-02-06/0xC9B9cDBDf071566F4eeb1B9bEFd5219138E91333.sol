/**
 *Submitted for verification at BscScan.com on 2024-02-03
*/

/**
 *Submitted for verification at BscScan.com on 2024-02-02
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

contract TokenDistributor {
    uint256 private constant MAX = ~uint256(0);
    constructor (address tokenA, address tokenB, address tokenC) {
        IERC20(tokenA).approve(msg.sender, MAX);
        IERC20(tokenB).approve(msg.sender, MAX);
        IERC20(tokenC).approve(msg.sender, MAX);
    }
}

contract PECToken {

    address[] public holders;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

}

contract TGYMEMBER {

    address public masterAddress = address(0xc9660E1D0c6138E4180Ac7555C68898d3B4c2c69);
    uint256 public totalMember = 0;
    address[] members;
    mapping(address => bool) avaliable; 
    mapping(address => address[]) downMember;
    mapping(address => uint256) totalDownMember;
    mapping(address => address) parentMember;

    constructor() {
        avaliable[masterAddress] = true;
        members.push(masterAddress);
        totalMember++;
    }
    
    function join(address ref) external {
        require(avaliable[ref], "REF NOTENABLE");
        require(!avaliable[msg.sender], "ALREADY REGISTED");
        avaliable[msg.sender] = true;
        downMember[ref].push(msg.sender);
        parentMember[msg.sender] = ref;
        totalDownMember[ref] += 1;
        members.push(msg.sender);
        totalMember++;
    }

    function checkRegisted(address _owner) public view returns(bool){
        return avaliable[_owner];
    }

    function getDownMember(address _owner) public view returns(address[] memory){
        return downMember[_owner];
    }

    function getTotalDownMember(address _owner) public view returns(uint256){
        return totalDownMember[_owner];
    }

    function getParentMember(address _owner) public view returns(address){
        return parentMember[_owner];
    }

    function getMemberByIndex(uint256 index) public view returns(address){
        return members[index];
    }

    function getTotalMember() public view returns(uint256){
        return totalMember;
    }
}

contract UTIL {
   
    function caculCredit(uint256 startTime, uint256 amount) public view returns(uint256 _cValue){
        uint timeElapsed = block.timestamp - startTime;
		uint times = timeElapsed / 1 days;
        if(times>0){
            _cValue = amount + amount*(times-1)/100;
        }else{
            _cValue = amount;
        }
        return _cValue;
    }
}

contract TGYMINT is Ownable, UTIL {
    struct Order {
        uint aIndex;
        bool isSell;
        address seller;
        address buyer;
        uint256 tgyAmount;
        uint256 tgyPrice;
        uint256 usdtAmount;
        uint256 startTime;
        uint256 updateTime;
        bool done;
        bool cancel;
        uint256 usePV;
    }

    struct PVOrder {
        uint index;
        bool isSell;
        address seller;
        address buyer;
        uint256 pvValue;
        uint256 usdtAmount;
        uint256 startTime;
        uint256 updateTime;
        bool done;
        bool cancel;
    }
    struct MintOrder {
        address user;
        bool isUsdt;
        uint256 usdtAmount;
        uint256 pecAmount;
        uint256 pv;
        uint256 cv;
    }
    struct Profit {
        address user;
        uint256 tgyAmount;
        uint256 cv;
    }
    struct RefInfo {
        address user;
        uint256 refAmount;
    }

    struct Deal {
        address user;
        uint256 amount;
    }

    RefInfo[20] topUsers;
    using SafeMath for uint256;    
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address pecAddress = address(0xF2dC0cC5F644E009709Ae4Adb4264bC2c1fD17aF);
    address tgyAddress = address(0xF7ce554709210C0B274454A0158Bf49d765964F2);
    address pairAddress = address(0xC7CEbC88C3e6628C974223Ed3007b763180E0139);
    address pecPairAddress = address(0xF66691dC468f78D825d7355aB83041fD232Dea8A);
    address tgyMemberAddress = address(0xA52938eA64F865b72e9c79390940D8C14741af1E);
    address burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address marketingAddress = address(0x074F008143Acfa23F9291F546fB00B67EBF392f5);
    address adminAddress = address(0xc9660E1D0c6138E4180Ac7555C68898d3B4c2c69);
    //-----
    ISwapRouter private immutable _swapRouter;
    uint256 private constant MAX = ~uint256(0);
    TokenDistributor _tokenDistributor;
    mapping(address => Order[]) orders;
    mapping(address => MintOrder[]) myMintOrder;
    mapping(address => Profit[]) public myProfit;
    mapping(address => PVOrder[]) PVTradeOrder;
    mapping(address => uint256) myRefInfo;
    Order[] allOrders;
    PVOrder[] allPVOrders;
    address[] Miners;
    mapping(address => uint256) minersIndex;
    mapping(address => bool) isActive;
    uint256 public startTime = 0;
    uint256 public topMemberStartTime = 0;
    uint256 public dealActionStartTime = 0;
    mapping(address => uint256) _purchaseValue;
    mapping(address => uint256) _creditValue;
    mapping(address => uint256) tgyEnableWithdraw;
    mapping(address => uint256) pendingTGY;
    mapping(address => uint256) pendingPV;
    address public _tokenDistributorAddress;
    bool atokenIsPEC = true;
    uint256 buyTGYToBurnPercent = 200;
    uint256 buyPECToBurnPercent = 100;
    uint256 refRewardPercent = 100;
    uint256 addLpPercent = 600;
    uint256 mixFund = 100*1e18;
    uint256 public totalCV = 0;
    uint256 public todayTotalCV = 0;
    uint256 perDayTotalReward = 0;
    bool public enableset = true;
    uint256 tgyPrice;
    uint256 enableTimes;
    mapping(address => uint256) mintTimes;
    mapping(address => uint256) public claimTime;
    mapping(address => uint256) public tempCV;

    constructor(){
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _swapRouter = swapRouter;
        IERC20 token = IERC20(usdtAddress);
        IERC20 pecToken = IERC20(pecAddress);
        IERC20 tgyToken = IERC20(tgyAddress);
        token.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), MAX);
        pecToken.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), MAX);
        tgyToken.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), MAX);
        _tokenDistributor = new TokenDistributor(usdtAddress, pecAddress, tgyAddress);
        _tokenDistributorAddress = address(_tokenDistributor);
        startTime = block.timestamp;
        topMemberStartTime = block.timestamp;
        dealActionStartTime = block.timestamp;
    }

    function mintTGY(uint256 _amount) external {
        //====
        TGYMEMBER tm = TGYMEMBER(tgyMemberAddress);
        require(tm.checkRegisted(msg.sender), "Not enable");
        IERC20 usdtToken = IERC20(usdtAddress);
        IERC20 pecToken = IERC20(pecAddress);
        uint256 userPecBalance = pecToken.balanceOf(msg.sender);
        (uint256 usdtAmount) = que(userPecBalance);
        require(usdtAmount >= 10*1e18, "Under PEC mix");
        require(_amount >= mixFund, "Under USDT mix");
        bool tURES = usdtToken.transferFrom(msg.sender, address(this), _amount);
        require(tURES, "Transfer USDT error.");
        (uint256 rewardAmount) = mintAction(_amount);
        _purchaseValue[msg.sender] += _amount * 3;
        (uint256 _cValue) = caculCredit(startTime, _amount);
        address refMember = tm.getParentMember(msg.sender);
        if(refMember!=address(0)){
            if(isActive[refMember]){
                pecToken.transfer(refMember, rewardAmount);
                updateTop10Member(refMember, _amount);
            }else {
                pecToken.transfer(adminAddress, rewardAmount);
            }
        }else {
            pecToken.transfer(msg.sender, rewardAmount);
        }
        addM(msg.sender);
        myMintOrder[msg.sender].push(MintOrder(msg.sender, true, _amount, 0, _amount * 3, _cValue));
        if(!isActive[msg.sender]){
            isActive[msg.sender] = true;
        }
        checkPertimes(true, _cValue);
    }

    function mintTGYByPEC(uint256 _amount) external {
        TGYMEMBER tm = TGYMEMBER(tgyMemberAddress);
        require(tm.checkRegisted(msg.sender), "Not enable");
        IERC20 pecToken = IERC20(pecAddress);
        (uint256 remPecAmount) = queryPecAmount(10*1e18);
        uint256 userPecBalance = pecToken.balanceOf(msg.sender);
        uint256 realPecAmount;
        require(_amount >= remPecAmount, "PEC Balance Error");
        if ((userPecBalance - _amount) >= remPecAmount){
            realPecAmount = _amount;
        }else {
            realPecAmount = _amount - remPecAmount;
        }
        (uint256 usdtAmount) = que(realPecAmount);
        require(usdtAmount >= mixFund, "Under USDT mix");
        //---
        bool tPRES = pecToken.transferFrom(msg.sender, address(this), realPecAmount);
        require(tPRES, "Transfer PEC error.");
        pecToken.transfer(burnAddress, realPecAmount * buyPECToBurnPercent / 1000);
        swapTGYToBurn(realPecAmount * buyTGYToBurnPercent / 1000);
        pecToken.transfer(pairAddress, realPecAmount * addLpPercent / 1000);
        ISwapPair mainPair = ISwapPair(pairAddress);
        mainPair.sync();
        uint256 rewardAmount = pecToken.balanceOf(address(this));
        //---
        _purchaseValue[msg.sender] += usdtAmount * 3;
        (uint256 _cValue) = caculCredit(startTime, usdtAmount);
        address refMember = tm.getParentMember(msg.sender);
        if(refMember!=address(0)){
            if(isActive[refMember]){
                pecToken.transfer(refMember, rewardAmount);
                updateTop10Member(refMember, _amount);
            }else{
                pecToken.transfer(adminAddress, rewardAmount);
            }
        }else {
            pecToken.transfer(msg.sender, rewardAmount);
        }
        if(!isActive[msg.sender]){
            isActive[msg.sender] = true;
        }
        addM(msg.sender);
        myMintOrder[msg.sender].push(MintOrder(msg.sender, false, 0, _amount,  usdtAmount * 3, _cValue));
        checkPertimes(true, _cValue);
    }

    function dealPVandCV(Deal[] memory _deal) external onlyOwner {
        require(enableset,"NotE");
        for (uint i = 0; i < _deal.length; i++) 
        {
            address user = _deal[i].user;
            if(!isActive[user]){
                isActive[user] = true;
            }
            uint256 uAmount = _deal[i].amount;
            _purchaseValue[user] += uAmount * 3;
            uint256 _cValue = uAmount * 150 / 100;
            _creditValue[user] += _cValue;
            totalCV += _cValue;//注意
            myMintOrder[user].push(MintOrder(user, true, uAmount, 0,  uAmount * 3, _cValue));
        }
    }

    function withdrawTGY() external {
        require(tgyEnableWithdraw[msg.sender] > 0, "Balance not enough");
        uint256 amount = 0;
        amount = tgyEnableWithdraw[msg.sender];
        tgyEnableWithdraw[msg.sender] = 0;
        IERC20 tgyToken = IERC20(tgyAddress);
        uint256 rewardFee = amount * 10 / 100;
        TGYMEMBER tm = TGYMEMBER(tgyMemberAddress);
        address refMember = tm.getParentMember(msg.sender);
        if(refMember != address(0)){
            tgyToken.transfer(refMember, rewardFee);
        }else{
            rewardFee = 0;
        }
        uint256 lpFee = amount * 5 / 100;
        uint256 topMemberFee = amount * 5 / 100;
        perDayTotalReward += topMemberFee;
        swapTGYToPEC(lpFee);
        pT10R(topMemberFee);
        uint256 totalFee = rewardFee + lpFee + topMemberFee;
        tgyToken.transfer(msg.sender, amount - totalFee);
        checkPertimes(false, 0);
    }
    

    function claimCV() external  {
        require(tempCV[msg.sender] >0, "ERR");
        require(claimTime[msg.sender] >0, "ERR");
        bool success;
       if (block.timestamp - claimTime[msg.sender] > 1 days){
            if(tempCV[msg.sender] > 0){
                totalCV += tempCV[msg.sender];
                _creditValue[msg.sender] += tempCV[msg.sender];
                claimTime[msg.sender] = 0;
                tempCV[msg.sender] = 0;
                success = true;
            }
       }
       require(success, "FAILED");
    }

    function mintMyTGY() external  {
        require(isActive[msg.sender], "NOT ACTIVE");
        address miner = Miners[minersIndex[msg.sender]];
        require(miner != address(0), "ERR ADDRESS");
        require(mintTimes[msg.sender] < enableTimes, "Mint Not Enable");
        if(_creditValue[msg.sender] > 0){
            uint256 totalTGY =  2888 * 1e18;
            uint256 pm;
            pm = _creditValue[msg.sender] * totalTGY / todayTotalCV;
            uint256 usedCV = (pm/1e18) * tgyPrice;
            if(usedCV > _creditValue[msg.sender]){
                pm = (usedCV - _creditValue[msg.sender])/1e18 * tgyPrice;
                usedCV = _creditValue[msg.sender];
                _creditValue[msg.sender] = 0;
            }else{
                pm = _creditValue[msg.sender] * totalTGY / todayTotalCV;
                _creditValue[msg.sender] -= usedCV;
            }
            tgyEnableWithdraw[msg.sender] += pm;
            myProfit[msg.sender].push(Profit(msg.sender, pm, usedCV));
            totalCV -= usedCV;
            mintTimes[msg.sender] = enableTimes;
        }
    }

    function queryEnableWithdraw(address _owner) public view returns (uint256 _ew)  {
        if(!isActive[msg.sender]){
            return 0;
        }
        uint256 totalTGY =  2888 * 1e18;
        address miner = Miners[minersIndex[_owner]];
        if(mintTimes[_owner] < enableTimes){
            if(_creditValue[miner] > 0){
                _ew = _creditValue[miner] * totalTGY / todayTotalCV;
            }
        }else{
            _ew = 0;
        }
    }

    function addM(address _owner) private {
        if (minersIndex[_owner] == 0) {
            if (0 == Miners.length || Miners[0] != _owner) {
                minersIndex[_owner] = Miners.length;
                Miners.push(_owner);
            }
        }
    }

    function que(uint256 amount) public view returns(uint256 usdtAmount){
         ISwapPair mainPair = ISwapPair(pecPairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        usdtAmount = _swapRouter.quote(amount,r1, r0);
    }

    function quawt(uint256 amount) public view returns(uint256 usdtAmount){
         ISwapPair mainPair = ISwapPair(pairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        if(atokenIsPEC){
            uint256 pecAmount = _swapRouter.quote(amount,r0, r1);
            return que(pecAmount);
        }else{
            uint256 pecAmount = _swapRouter.quote(amount,r1, r0);
            return que(pecAmount);
        }
    }

    function queryPecAmount(uint256 amount) public view returns(uint256 pecAmount){
         ISwapPair mainPair = ISwapPair(pecPairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        pecAmount = _swapRouter.quote(amount,r0, r1);
    }

    function checkPertimes(bool isMint, uint256 _amount) private {
        uint timeElapsed = block.timestamp - dealActionStartTime;
		uint times = timeElapsed / 1 days;
        if(times > 0){
            dealActionStartTime += times * 1 days;
            tgyPrice = quawt(1e18);
            IERC20 tgyToken = IERC20(tgyAddress);
            uint256 totalTGY =  2888 * 1e18;
            todayTotalCV = totalCV;
            enableTimes ++;
            tgyToken.transferFrom(pairAddress, address(this), totalTGY);
            ISwapPair mainPair = ISwapPair(pairAddress);
            mainPair.sync();
            if(isMint && _amount>0){
                if(tempCV[msg.sender] > 0){
                    totalCV += tempCV[msg.sender];
                    _creditValue[msg.sender] += tempCV[msg.sender];
                }else {
                    tempCV[msg.sender] = _amount;
                }
                claimTime[msg.sender] = dealActionStartTime;
            }
        }else{
            if(isMint && _amount>0){
                tempCV[msg.sender] += _amount;
                claimTime[msg.sender] = dealActionStartTime;
            }
        }
        
    }

    function updateTop10Member(address _reffer, uint _amount) public {
        uint timeElapsed = block.timestamp - topMemberStartTime;
		uint times = timeElapsed / 1 days;
        if(times > 0){
            for (uint i = 0; i < topUsers.length; i++) {
                topUsers[i] = RefInfo(address(0), 0);
            }
            topMemberStartTime += times * 1 days;
            myRefInfo[_reffer] = _amount;
            perDayTotalReward = 0;
        }else{
            myRefInfo[_reffer] += _amount;
        }
        int index = -1;
        for (uint i = 0; i < topUsers.length; i++) {
            if (topUsers[i].user == _reffer) {
                index = int(i);
                break;
            }
        }
        if (index == -1) {
            topUsers[19] = RefInfo(_reffer, _amount);
        } else {
            topUsers[uint(index)].refAmount += _amount;
        }
        for (uint i = 0; i < topUsers.length; i++) {
            for (uint j = i + 1; j < topUsers.length; j++) {
                if (topUsers[j].refAmount > topUsers[i].refAmount) {
                    RefInfo memory temp = topUsers[i];
                    topUsers[i] = topUsers[j];
                    topUsers[j] = temp;
                }
            }
        }
    }

    function pT10R(uint256 amount) private {
        IERC20 tgyToken = IERC20(tgyAddress);
        uint256 validUsersCount = 0;
        for (uint i = 0; i < 10; i++) {
            if (topUsers[i].user != address(0)) {
                validUsersCount++;
            }
        }
        if (validUsersCount > 0){
            uint256 amountPerUser = amount / validUsersCount;
            for (uint i = 0; i < 10; i++) {
                if (topUsers[i].user != address(0)) {
                    tgyToken.transfer(topUsers[i].user, amountPerUser);
                }
            }
        }
    }

    function mintAction(uint256 usdtAmount) private returns (uint256 rewardAmount){
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = pecAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20 token = IERC20(pecAddress);
        uint256 pecAmount = token.balanceOf(address(_tokenDistributor));
        token.transferFrom(address(_tokenDistributor), burnAddress, pecAmount * buyPECToBurnPercent / 1000);
        token.transferFrom(address(_tokenDistributor), address(this), pecAmount * buyTGYToBurnPercent / 1000);
        swapTGYToBurn(pecAmount * buyTGYToBurnPercent / 1000);
        token.transferFrom(address(_tokenDistributor), pairAddress, pecAmount * addLpPercent / 1000);
        ISwapPair mainPair = ISwapPair(pairAddress);
        mainPair.sync();
        rewardAmount = token.balanceOf(address(_tokenDistributor));
        token.transferFrom(address(_tokenDistributor), address(this), rewardAmount);
    }

    function swapTGYToBurn(uint256 pecAmount) private {
        address[] memory path = new address[](2);
        path[0] = pecAddress;
        path[1] = tgyAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            pecAmount,
            0,
            path,
            burnAddress,
            block.timestamp
        );
    }

    function swapTGYToPEC(uint256 tgyAmount) private {
        address[] memory path = new address[](2);
        path[0] = tgyAddress;
        path[1] = pecAddress;
        address reciver = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tgyAmount,
            0,
            path,
            reciver,
            block.timestamp
        );
        IERC20 pecToken = IERC20(pecAddress);
        pecToken.transferFrom(reciver, pecAddress, pecToken.balanceOf(reciver));
    }

    function swapPECToToken(uint256 tokenAmount, address _token, address _reciverAddress, bool addLp) private {
        address[] memory path = new address[](2);
        path[0] = pecAddress;
        path[1] = _token;
        if(addLp){
             _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(_tokenDistributor),
                block.timestamp
            );
            IERC20 token = IERC20(_token);
            token.transferFrom(address(_tokenDistributor), pairAddress, token.balanceOf(address(_tokenDistributor)));
            ISwapPair mainPair = ISwapPair(pairAddress);
            mainPair.sync();
        }   else {
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(_reciverAddress),
                block.timestamp
            );
        }
    }

    function makeSellPvOrder(address to, uint256 value, uint256 usdtAmount) external {
        require(to != address(0), "Error Address");
        require(_purchaseValue[msg.sender] >= value, "PBE");
        require(value > 0, "Error Value");
        pendingPV[msg.sender] += value;
        _purchaseValue[msg.sender] -= value;
        uint index = allPVOrders.length;
        allPVOrders.push(PVOrder(index, true, msg.sender, to, value, usdtAmount, block.timestamp, 0, false, false));
    }

    function dealPVOrder(uint256 index) external {
        IERC20 usdtToken = IERC20(usdtAddress);
        require(!allPVOrders[index].done, "HD");
        require(!allPVOrders[index].cancel, "HC");
        allPVOrders[index].done = true;
        allPVOrders[index].updateTime = block.timestamp;
        bool tURes = usdtToken.transferFrom(msg.sender, allPVOrders[index].seller, allPVOrders[index].usdtAmount);
        require(tURes, "TUF");
        allPVOrders[index].done = true;
        allPVOrders[index].updateTime = block.timestamp;
        pendingPV[allPVOrders[index].seller] -= allPVOrders[index].pvValue;
        _purchaseValue[msg.sender] += allPVOrders[index].pvValue;
    }

    function cancelPVOrder(uint256 index) external {
        require(!allPVOrders[index].done, "HD");
        require(!allPVOrders[index].cancel, "HC");
        allPVOrders[index].cancel = true;
        allPVOrders[index].updateTime = block.timestamp;
        allPVOrders[index].done = false;
        allPVOrders[index].updateTime = block.timestamp;
        pendingPV[msg.sender] -= allPVOrders[index].pvValue;
        _purchaseValue[msg.sender] += allPVOrders[index].pvValue;
    }

    function makeSellOrder(address _buyer, uint256 _tgyAmount, uint256 _usdtAmount) external {
        IERC20 pecToken = IERC20(pecAddress);
        uint256 userPecBalance = pecToken.balanceOf(msg.sender);
        (uint256 usdtAmount) = que(userPecBalance);
        require(usdtAmount > 10*1e18, "UPM");
        IERC20 tgyToken = IERC20(tgyAddress);
        require(tgyToken.balanceOf(msg.sender) >= _tgyAmount, "ETB");
        require(tgyToken.allowance(msg.sender, address(this)) >= _tgyAmount, "ATE");
        uint256 enabelSell = tgyToken.balanceOf(msg.sender) - pendingTGY[msg.sender];
        require((enabelSell - _tgyAmount) >=0, "ESNE");
        pendingTGY[msg.sender] += _tgyAmount;
        uint256 _tgyPrice = _usdtAmount/_tgyAmount*1e18;
        uint aIndex = allOrders.length;

        allOrders.push(Order(aIndex, true, msg.sender, _buyer, _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
    }

    function cancelOrder(uint _aIndex) external {
        bool haveOrder;
        address seller = allOrders[_aIndex].seller;
        require(seller == msg.sender, "ErrSeller");
        haveOrder = true;
        allOrders[_aIndex].cancel = true;
        allOrders[_aIndex].updateTime = block.timestamp;
        pendingTGY[msg.sender] -= allOrders[_aIndex].tgyAmount;
        require(haveOrder, "ONF.");
    }

    //=====
    function dealOrder(uint256 _index) external {
        bool haveOrder;
        for (uint i; i < allOrders.length; i++) 
        {
            if (allOrders[i].aIndex == _index){
                require(!allOrders[i].done, "HD");
                require(!allOrders[i].cancel, "HC");
                if (allOrders[i].buyer != address(0)){
                    require(msg.sender == allOrders[i].buyer , "EB");
                }
                uint256 usdtAmount = allOrders[i].usdtAmount;
                require(_purchaseValue[msg.sender] >= usdtAmount, "PVNE");
                _purchaseValue[msg.sender] -= usdtAmount;
                allOrders[i].done = true;
                allOrders[i].usePV = usdtAmount;
                allOrders[i].buyer = msg.sender;
                allOrders[i].updateTime = block.timestamp;
                IERC20 usdtToken = IERC20(usdtAddress);
                uint256 sellFee = allOrders[i].usdtAmount * 5 / 100;
                uint256 rUsdtAmount = allOrders[i].usdtAmount - sellFee;
                usdtToken.transferFrom(msg.sender, marketingAddress, sellFee);
                usdtToken.transferFrom(msg.sender, allOrders[i].seller, rUsdtAmount);
                IERC20 tgyToken = IERC20(tgyAddress);
                uint256 tgyAmount = allOrders[i].tgyAmount;
                uint256 buyFee = tgyAmount * 5/100;
                tgyToken.transferFrom(allOrders[i].seller, address(this), tgyAmount);
                uint256 rTgyAmount = tgyAmount - buyFee;
                tgyToken.transfer(msg.sender, rTgyAmount);
                tgyToken.transfer(tgyAddress, buyFee);
                address seller = allOrders[i].seller;
                pendingTGY[seller] -= tgyAmount;
                haveOrder = true;
            }
        }
        require(haveOrder, "ONF.");
    }

    function getAllOrder(bool isAll, bool sSeller, bool isBuyer, bool isSorder, address seller, address buyer, uint start, uint size) public view returns(Order[] memory _orders2, uint256 h){
        Order[] memory _orders = new Order[](size);
        uint j = 0;
        uint k = 0;
        for(uint i =0; i < allOrders.length && j < size; i++){
            bool shouldAdd = false;
            if(isAll && !allOrders[i].done && allOrders[i].buyer == address(0) && !allOrders[i].cancel){
                shouldAdd = true;
            }
            if(sSeller && allOrders[i].seller == seller){
                shouldAdd = true;
            }
            if(isBuyer && allOrders[i].buyer == buyer && allOrders[i].done){
                shouldAdd = true;
            }
            if(isSorder && allOrders[i].buyer == buyer && !allOrders[i].done && !allOrders[i].cancel){
                shouldAdd = true;
            }
            if(shouldAdd && k >= start){
                _orders[j] = allOrders[i];
                j++;
            }
            if(shouldAdd){
                k++;
            }
        }
        return (_orders, j);
    }

    function getPVOrder(bool sSeller, bool isBuyer, bool isSorder, address seller, address buyer, uint start, uint size) public view returns(PVOrder[] memory _orders2, uint256 h){
        PVOrder[] memory _orders = new PVOrder[](size);
        uint j = 0;
        uint k = 0;
        for(uint i =0; i < allPVOrders.length && j < size; i++){
            bool shouldAdd = false;
            if(sSeller && allPVOrders[i].seller == seller){
                shouldAdd = true;
            }
            if(isBuyer && allPVOrders[i].buyer == buyer && allPVOrders[i].done){
                shouldAdd = true;
            }
            if(isSorder && allPVOrders[i].buyer == buyer && !allPVOrders[i].done && !allPVOrders[i].cancel){
                shouldAdd = true;
            }
            if(shouldAdd && k >= start){
                _orders[j] = allPVOrders[i];
                j++;
            }
            if(shouldAdd){
                k++;
            }
        }
        return (_orders, j);
    }


    function getMyMintOrder(uint start, uint size, address _owner) public view  returns(MintOrder[] memory _orders2, uint256 h){
        MintOrder[] memory _orders = new MintOrder[](myMintOrder[_owner].length);
        uint j = 0;
        for (uint i = myMintOrder[_owner].length; i > 0; i--) 
        {
             _orders[j] =myMintOrder[_owner][i - 1];
            j++;
        }
        _orders2 = new MintOrder[](size);
        for (uint k = start; k < _orders.length; k++) 
        {
            if (h<size){
                _orders2[h] = _orders[k];
                h++;
            }else{
                continue;
            }
        }
    }

    function getPurchaseValue(address _owner) public view returns(uint256){
        return _purchaseValue[_owner];
    }

    function getTotalCV() public view returns(uint256){
        return totalCV;
    }

    function getTopMember() public view returns(RefInfo[20] memory){
        return topUsers;
    }

    function getPendingTGY(address _owner) public view returns(uint256){
        return pendingTGY[_owner];
    }

    function getPendingPV(address _owner) public view returns(uint256){
        return pendingPV[_owner];
    }

    function getMyRefInfo(address _owner) public view returns(uint256){
        return myRefInfo[_owner];
    }

    function getCreditValue(address _owner) public view returns(uint256){
        return _creditValue[_owner];
    }

    function getTgyEnableWithdraw(address _owner) public view returns(uint256){
        return tgyEnableWithdraw[_owner];
    }

    function setAddress(address _tokenB, address _tokenC) external onlyOwner {
        tgyAddress = _tokenB;
        pairAddress = _tokenC;
    }

    function setAtokenIsPEC(bool _is) external onlyOwner {
        atokenIsPEC = _is;
    }
   
    function setEnableset(bool _enable) external onlyOwner {
        enableset = _enable;
    }

    function setTopMemberStartTime(uint256 _timestamp) external onlyOwner {
        topMemberStartTime = _timestamp;
    }

    function setDealActionStartTime(uint256 _timestamp) external onlyOwner {
        dealActionStartTime = _timestamp;
    }

    function showTGYUSDTVALUE(uint256 _amount) public view  returns (uint256 _usdtValue) {
        _usdtValue = quawt(_amount * 1e18);
    }
}