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
		uint times = timeElapsed / 30 minutes;
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
        uint index;
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
        uint sIndex;
        uint bIndex;
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
        uint refAmount;
    }
    RefInfo[20] topUsers;
    using SafeMath for uint256;    
    address usdtAddress = address(0x29F5A8C21C714A4bE4a6AF751045F3BBD4a6e8CD);
    address pecAddress = address(0xbf6bb896E84Ace9c056B850424bf79c9D1642cCC);
    address tgyAddress = address(0xd21FFa6e5EedE46C9a3eF883088CFC3a2cF86A15);
    address pairAddress = address(0x177b1720a2DDBe8c3F6eaea7E966B02b8e23976D);
    address pecPairAddress = address(0x896fa1E648Eb898720e34BE3Aecd590169196fA0);
    address tgyMemberAddress = address(0xA52938eA64F865b72e9c79390940D8C14741af1E);
    address burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address marketingAddress = address(0x8FC85a4A607cFfe37166E44939eE830f0440A502);
    address lpFeeAddress = address(0x8FC85a4A607cFfe37166E44939eE830f0440A502);
    ISwapRouter private immutable _swapRouter;
    uint256 private constant MAX = ~uint256(0);
    TokenDistributor _tokenDistributor;
    mapping(address => Order[]) orders;
    mapping(address => MintOrder[]) myMintOrder;
    mapping(address => Profit[]) myProfit;
    mapping(address => PVOrder[]) PVTradeOrder;
    mapping(address => uint256) myRefInfo;
    Order[] allOrders;
    address[] Miners;
    mapping(address => uint256) minersIndex;
    mapping(address => bool) isActive;
    uint256 public startTime = 0;
    uint256 public topMemberStartTime = 0;
    mapping(address => uint256) _purchaseValue;
    mapping(address => uint256) _creditValue;
    mapping(address => uint256) tgyEnableWithdraw;
    mapping(address => uint256) pendingTGY;
    mapping(address => uint256) pendingPV;
    address public _tokenDistributorAddress;
    bool atokenIsPEC = false;
    uint256 buyTGYToBurnPercent = 200;
    uint256 buyPECToBurnPercent = 100;
    uint256 refRewardPercent = 100;
    uint256 addLpPercent = 600;
    uint256 mixFund = 100*1e18;
    uint256 totalCV = 0;
    uint256 perDayTotalReward = 0;

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
        _creditValue[msg.sender] += _cValue;
        totalCV += _cValue;
        address refMember = tm.getParentMember(msg.sender);
        if(refMember!=address(0)){
            if(isActive[refMember]){
                pecToken.transfer(refMember, rewardAmount);
                updateTop10Member(refMember, _amount);
            }
        }else {
            pecToken.transfer(msg.sender, rewardAmount);
        }
        addM(msg.sender);
        myMintOrder[msg.sender].push(MintOrder(msg.sender, true, _amount, 0, _amount * 3, _cValue));
        if(!isActive[msg.sender]){
            isActive[msg.sender] = true;
        }
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
        _creditValue[msg.sender] += _cValue;
        totalCV += _cValue;
        address refMember = tm.getParentMember(msg.sender);
        if(refMember!=address(0)){
            if(isActive[refMember]){
                pecToken.transfer(refMember, rewardAmount);
                updateTop10Member(refMember, _amount);
            }
        }else {
            pecToken.transfer(msg.sender, rewardAmount);
        }
        if(!isActive[msg.sender]){
            isActive[msg.sender] = true;
        }
        addM(msg.sender);
        myMintOrder[msg.sender].push(MintOrder(msg.sender, false, 0, _amount,  usdtAmount * 3, _cValue));
    }

    function withdrawTGY(uint256 amount) external {
        require(tgyEnableWithdraw[msg.sender] > 0, "Balance not enough");
        tgyEnableWithdraw[msg.sender] -= amount;
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
        // tgyToken.transfer(tgyAddress, lpFee);
        swapTGYToPEC(lpFee);
        pT10R(topMemberFee);
        uint256 totalFee = rewardFee + lpFee + topMemberFee;
        tgyToken.transfer(msg.sender, amount - totalFee);
    }
    
    function dealAction() external onlyOwner {
        IERC20 tgyToken = IERC20(tgyAddress);
        uint256 totalTGY =  2888 * 1e18;
        uint256 tgyPrice = quawt(1e18);
        tgyToken.transferFrom(pairAddress, address(this), totalTGY);
        ISwapPair mainPair = ISwapPair(pairAddress);
        mainPair.sync();
        uint256 tUsed = 0;
        for (uint i ; i < Miners.length; i++) 
        {
            if(_creditValue[Miners[i]] > 0){
                uint256 pm;
                pm = _creditValue[Miners[i]] * totalTGY / totalCV;
                uint256 usedCV = (pm/1e18) * tgyPrice;
                if(usedCV > _creditValue[Miners[i]]){
                    pm = (usedCV - _creditValue[Miners[i]])/1e18 * tgyPrice;
                    usedCV = _creditValue[Miners[i]];
                    _creditValue[Miners[i]] = 0;
                }else{
                    pm = _creditValue[Miners[i]] * totalTGY / totalCV;
                    _creditValue[Miners[i]] -= usedCV;
                }
                tgyEnableWithdraw[Miners[i]] += pm;
                myProfit[Miners[i]].push(Profit(Miners[i], pm, usedCV));
                tUsed += usedCV;
            }
        }
        totalCV -= tUsed;
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
 
    function updateTop10Member(address _reffer, uint _amount) public {
        uint timeElapsed = block.timestamp - topMemberStartTime;
		uint times = timeElapsed / 1 days;
        if(times > 0){
            //清空
            for (uint i = 0; i < topUsers.length; i++) {
                topUsers[i] = RefInfo(address(0), 0);
            }
            topMemberStartTime += times * 30 minutes;
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

    function pT10R(uint256 amount) public {
        IERC20 tgyToken = IERC20(tgyAddress);
        uint256 validUsersCount = 0;
        for (uint i = 0; i < 10; i++) {
            if (topUsers[i].user != address(0)) {
                validUsersCount++;
            }
        }
        uint256 amountPerUser = amount / validUsersCount;
        for (uint i = 0; i < 10; i++) {
            if (topUsers[i].user != address(0)) {
                tgyToken.transfer(topUsers[i].user, amountPerUser);
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
        uint index = PVTradeOrder[msg.sender].length;
        uint index2 = PVTradeOrder[to].length;
        PVTradeOrder[msg.sender].push(PVOrder(index,index2, true, msg.sender, to, value, usdtAmount, block.timestamp, 0, false, false));
        PVTradeOrder[to].push(PVOrder(index,index2, false, msg.sender, to, value, usdtAmount, block.timestamp, 0, false, false));
    }

    function dealPVOrder(uint256 index) external {
        IERC20 usdtToken = IERC20(usdtAddress);
        bool haveOrder;
        PVOrder[] storage pv = PVTradeOrder[msg.sender];
        require(!pv[index].done, "HD");
        require(!pv[index].cancel, "HC");
        haveOrder = true;
        pv[index].done = true;
        pv[index].updateTime = block.timestamp;
        bool tURes = usdtToken.transferFrom(msg.sender, pv[index].seller, pv[index].usdtAmount);
        require(tURes, "TUF");
        PVOrder[] storage pv2 = PVTradeOrder[pv[index].seller];
        pv2[pv[index].sIndex].done = true;
        pv2[pv[index].sIndex].updateTime = block.timestamp;
        pendingPV[pv[index].seller] -= pv[index].pvValue;
        _purchaseValue[msg.sender] += pv[index].pvValue;
        require(haveOrder, "ONF");
    }

    function cancelPVOrder(uint256 index) external {
        bool haveOrder;
        PVOrder[] storage pv = PVTradeOrder[msg.sender];
        require(!pv[index].done, "HD");
        require(!pv[index].cancel, "HC");
        haveOrder = true;
        pv[index].cancel = true;
        pv[index].updateTime = block.timestamp;
        PVOrder[] storage pv2 = PVTradeOrder[pv[index].buyer];
        pv2[pv[index].bIndex].done = true;
        pv2[pv[index].bIndex].updateTime = block.timestamp;
        pendingPV[msg.sender] -= pv[index].pvValue;
        _purchaseValue[msg.sender] += pv[index].pvValue;
        require(haveOrder, "ONF");
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
        uint256 _tgyPrice = _usdtAmount.div(_tgyAmount).mul(1e18);
        Order[] storage myOrders = orders[msg.sender];
        uint index = myOrders.length;
        uint aIndex = allOrders.length;
        myOrders.push(Order(index,aIndex, true, msg.sender, _buyer, _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
        allOrders.push(Order(index,aIndex, true, msg.sender, _buyer, _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
    }

    function cancelOrder(uint _aIndex) external {
        bool haveOrder;
        address seller = allOrders[_aIndex].seller;
        require(seller == msg.sender, "ErrSeller");
        haveOrder = true;
        allOrders[_aIndex].cancel = true;
        allOrders[_aIndex].updateTime = block.timestamp;
        pendingTGY[msg.sender] -= allOrders[_aIndex].tgyAmount;
        rto(_aIndex, allOrders);
        require(haveOrder, "ONF.");
    }

    //购买
    function dealOrder(address _seller, uint _index) external {
        Order[] storage _orders = orders[_seller];
        bool haveOrder;
        for (uint i; i < _orders.length; i++) 
        {
            if (_orders[i].index == _index){
                require(!_orders[i].done, "HD");
                require(!_orders[i].cancel, "HC");
                if (_orders[i].buyer != address(0)){
                    require(msg.sender == _orders[i].buyer , "EB");
                }
                uint256 usdtAmount = _orders[i].usdtAmount;
                require(_purchaseValue[msg.sender] >= usdtAmount, "PVNE");
                _purchaseValue[msg.sender] -= usdtAmount;
                _orders[i].done = true;
                _orders[i].usePV = usdtAmount;
                _orders[i].buyer = msg.sender;
                _orders[i].updateTime = block.timestamp;
                IERC20 usdtToken = IERC20(usdtAddress);
                uint256 sellFee = _orders[i].usdtAmount * 5 / 100;
                uint256 rUsdtAmount = _orders[i].tgyAmount - sellFee;
                usdtToken.transferFrom(msg.sender, marketingAddress, sellFee);
                usdtToken.transferFrom(msg.sender, _orders[i].seller, rUsdtAmount);
                IERC20 tgyToken = IERC20(tgyAddress);
                uint256 buyFee = _orders[i].tgyAmount * 5/100;
                uint256 rTgyAmount = _orders[i].tgyAmount - buyFee;
                tgyToken.transferFrom(_orders[i].seller, msg.sender, buyFee);
                tgyToken.transferFrom(_orders[i].seller, tgyAddress, rTgyAmount);
                address seller = _orders[i].seller;
                pendingTGY[seller] -= _orders[i].tgyAmount;
                rto(_orders[i].aIndex, allOrders);
                haveOrder = true;
            }
        }
        require(haveOrder, "ONF.");
    }

    function rto(uint index, Order[] storage _orders) private {
        for(uint i = index; i < _orders.length-1; i++){
            _orders[i] = _orders[i+1];      
        }
        _orders.pop();
    }

    function allOrderPage(bool sSeller, address seller, address buyer, uint start, uint size) public view returns(Order[] memory _orders2, uint256 h){
        Order[] memory _orders = new Order[](size);
        uint j = 0;
        uint k = 0;
        for (uint i = allOrders.length; i > 0 && j < size; i--) {
            if ((sSeller && allOrders[i - 1].seller == seller) || (!sSeller && allOrders[i - 1].buyer == buyer)) {
                if (k >= start) {
                    _orders[j] = allOrders[i - 1];
                    j++;
                }
                k++;
            }
        }
        return (_orders, j);
    }

    function getMyProfitRecord(uint start, uint size, address _owner) public view  returns(Profit[] memory _orders2, uint256 h){
        Profit[] memory _orders = new Profit[](myProfit[_owner].length);
        uint j = 0;
        for (uint i = myProfit[_owner].length; i > 0; i--) 
        {
             _orders[j] = myProfit[_owner][i - 1];
            j++;
        }
        _orders2 = new Profit[](size);
        for (uint k = start; k < _orders.length; k++) 
        {
            if (h<size){
                _orders2[h] = _orders[k];
                h++;
            }
        }
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

    function pvOrderPage(uint start, uint size, address _owner, bool haveDone, bool haveCancel) public view  returns(PVOrder[] memory _orders2, uint256 h){
        PVOrder[] memory _orders = new PVOrder[](PVTradeOrder[_owner].length);
        uint j = 0;
        for (uint i = _orders.length; i > 0; i--) 
        {
            if(_orders[i - 1].done == haveDone && _orders[i - 1].cancel == haveCancel){
                _orders[j] = PVTradeOrder[_owner][i - 1];
                j++;
            }
        }
        _orders2 = new PVOrder[](size);
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
    
    function getPerDayTotalReward() public view returns(uint256)  {
        return perDayTotalReward;
    }

    function setTopMemberStartTime(uint256 _timestamp) external onlyOwner {
        topMemberStartTime = _timestamp;
    }

    function showTGYUSDTVALUE(uint256 _amount) public view  returns (uint256 _usdtValue) {
        _usdtValue = quawt(_amount * 1e18);
    }
}