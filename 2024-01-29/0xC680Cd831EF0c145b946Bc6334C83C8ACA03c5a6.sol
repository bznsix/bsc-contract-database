/**
 *Submitted for verification at BscScan.com on 2024-01-29
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-29
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

    using SafeMath for uint256;    

    struct APW {
        address user;
        uint256 value;
    }

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

    struct TopRefInfo {
        address user;
        uint256 refAmount;
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

    ISwapRouter private immutable _swapRouter;
    uint256 private constant MAX = ~uint256(0);
    TokenDistributor _tokenDistributor;

    mapping(address => Order[]) orders;

    mapping(address => Order[]) orderForMe;

    mapping(address => Order[]) PurchaseOrder;

    mapping(address => MintOrder[]) myMintOrder;

    mapping(address => Profit[]) myProfit;

    mapping(address => PVOrder[]) PVTradeOrder;

    TopRefInfo[] public TopMember;

    Order[] allOrders;

    address[] public Miners;

    mapping(address => uint256) minersIndex;

    uint256 startTime = 0;

    // pecAddress = _tokenA;
    // tgyAddress = _tokenB;
    // pairAddress = _tokenC;
    // topMemberFeeAddress = _tokenD;
    // lpFeeAddress = _tokenE;
    // pecPairAddress = _tokenF;
    // [0]0xbf6bb896E84Ace9c056B850424bf79c9D1642cCC
    // [1]0x6904114DAC24b3ABEdF06d9C40e480efCB5eF717
    // [2]0xB9FF2C5A96aACfD377B60c25A2657bb627aC529d
    // [3]0x8FC85a4A607cFfe37166E44939eE830f0440A502
    // [4]0x8FC85a4A607cFfe37166E44939eE830f0440A502
    // [5]0x896fa1E648Eb898720e34BE3Aecd590169196fA0

    address public usdtAddress = address(0x29F5A8C21C714A4bE4a6AF751045F3BBD4a6e8CD);

    address public pecAddress = address(0xbf6bb896E84Ace9c056B850424bf79c9D1642cCC);

    address public tgyAddress = address(0x6904114DAC24b3ABEdF06d9C40e480efCB5eF717);

    address public pairAddress = address(0xB9FF2C5A96aACfD377B60c25A2657bb627aC529d);

    address public pecPairAddress = address(0x896fa1E648Eb898720e34BE3Aecd590169196fA0);

    address public tgyMemberAddress = address(0xA52938eA64F865b72e9c79390940D8C14741af1E);

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);

    address public marketingAddress = address(0x8FC85a4A607cFfe37166E44939eE830f0440A502);

    address public lpFeeAddress = address(0x8FC85a4A607cFfe37166E44939eE830f0440A502);

    address public topMemberFeeAddress = address(0x8FC85a4A607cFfe37166E44939eE830f0440A502);

    mapping(address => uint256) _purchaseValue;

    mapping(address => uint256) _creditValue;

    mapping(address => uint256) tgyEnableWithdraw;

    address public _tokenDistributorAddress;

    uint256 public buyTGYToBurnPercent = 200;
    uint256 public buyPECToBurnPercent = 100;
    uint256 public refRewardPercent = 100;
    uint256 public addLpPercent = 600;
    uint256 public mixFund = 100*1e18;
    uint256 public totalCV = 0;

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
    }

    event TransferPV(address indexed sender, address indexed to, uint256 value);
    event AirdropPV(address indexed to, uint256 value);

    function mintTGY(uint256 _amount) external {
        TGYMEMBER tm = TGYMEMBER(tgyMemberAddress);
        bool enable = tm.checkRegisted(msg.sender);
        require(enable, "Not enable");
        IERC20 usdtToken = IERC20(usdtAddress);
        IERC20 pecToken = IERC20(pecAddress);
        uint256 userPecBalance = pecToken.balanceOf(msg.sender);
        (uint256 usdtAmount) = queryUsdtAmountWithPEC(userPecBalance);
        require(usdtAmount >= 10*1e18, "Under PEC mix");
        require(_amount >= mixFund, "Under USDT mix");
        bool tURES = usdtToken.transferFrom(msg.sender, address(this), _amount);
        require(tURES, "Transfer USDT error.");
        (uint256 rewardAmount) = swapUsdtToPECAndAction(_amount);
        _purchaseValue[msg.sender] += _amount * 3;
        (uint256 _cValue) = caculCredit(startTime, _amount);
        _creditValue[msg.sender] += _cValue;
        totalCV += _cValue;
        address refMember = tm.getParentMember(msg.sender);
        if(refMember!=address(0)){
            pecToken.transfer(refMember, rewardAmount);
            updateTopMember(_amount, refMember);
        }else {
            pecToken.transfer(msg.sender, rewardAmount);
        }
        myMintOrder[msg.sender].push(MintOrder(msg.sender, true, _amount, 0, _amount * 3, _cValue));
        addMiners(msg.sender);
    }

    function mintTGYByPEC(uint256 _amount) external {
        TGYMEMBER tm = TGYMEMBER(tgyMemberAddress);
        bool enable = tm.checkRegisted(msg.sender);
        require(enable, "Not enable");
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
        (uint256 usdtAmount) = queryUsdtAmountWithPEC(realPecAmount);
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
            pecToken.transfer(refMember, rewardAmount);
            updateTopMember(usdtAmount, refMember);
        }else {
            pecToken.transfer(msg.sender, rewardAmount);
        }
        addMiners(msg.sender);
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
        tgyToken.transfer(lpFeeAddress, lpFee);
        tgyToken.transfer(topMemberFeeAddress, topMemberFee);
        uint256 totalFee = rewardFee + lpFee + topMemberFee;
        tgyToken.transfer(msg.sender, amount - totalFee);
    }
    
    function dealAction() external onlyOwner {
        IERC20 tgyToken = IERC20(tgyAddress);
        uint256 totalTGY =  2888 * 1e18;
        (uint256 usdtAmount) = queryUsdtAmountWithTGY(totalTGY);
        tgyToken.transferFrom(pairAddress, address(this), totalTGY);
        ISwapPair mainPair = ISwapPair(pairAddress);
        mainPair.sync();
        for (uint i ; i < Miners.length; i++) 
        {
            tgyEnableWithdraw[Miners[i]] += _creditValue[Miners[i]] * totalTGY / totalCV;
            uint256 usedCV = _creditValue[Miners[i]] * usdtAmount / totalCV;
            _creditValue[Miners[i]] -= usedCV;
            myProfit[Miners[i]].push(Profit(Miners[i], _creditValue[Miners[i]] * totalTGY / totalCV, usedCV));
            totalCV -= usedCV;
        }
    }

    function addMiners(address _owner) private {
        if (minersIndex[_owner] == 0) {
            if (0 == Miners.length || Miners[0] != _owner) {
                minersIndex[_owner] = Miners.length;
                Miners.push(_owner);
            }
        }
    }

    function queryUsdtAmountWithPEC(uint256 amount) public view returns(uint256 usdtAmount){
         ISwapPair mainPair = ISwapPair(pecPairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        usdtAmount = _swapRouter.quote(amount,r1, r0);
    }

    function queryUsdtAmountWithTGY(uint256 amount) public view returns(uint256 usdtAmount){
         ISwapPair mainPair = ISwapPair(pairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        //⚠️注意 这里有可能是币上U下，部署时注意辨别
        uint256 pecAmount = _swapRouter.quote(amount,r0, r1);
        return queryUsdtAmountWithPEC(pecAmount);
    }

    function queryPecAmount(uint256 amount) public view returns(uint256 pecAmount){
         ISwapPair mainPair = ISwapPair(pecPairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        pecAmount = _swapRouter.quote(amount,r0, r1);
    }
 
    function updateTopMember(uint256 _amount, address _reffer) private {
        bool isNewTopMember;
        for (uint i; i < TopMember.length; i ++) 
        {
            if (_reffer == TopMember[i].user){
                isNewTopMember = true;
                TopMember[i].refAmount += _amount;
            }
        }
        if (!isNewTopMember){
            if (TopMember.length < 100){
                TopMember.push(TopRefInfo(_reffer, _amount));
            }else {
                for (uint i; i < TopMember.length; i ++){
                    if (TopMember[i].refAmount < _amount){
                        TopMember[i].user = _reffer;
                        TopMember[i].refAmount = _amount;
                    }
                }
            }
        }
    }

    function swapUsdtToPECAndAction(uint256 usdtAmount) private returns (uint256 rewardAmount){
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

    // function swapUsdtToToken(uint256 tokenAmount, address _token, address _reciverAddress, bool addLp) private {
    //     address[] memory path = new address[](2);
    //     path[0] = usdtAddress;
    //     path[1] = _token;
    //     if(addLp){
    //          _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //             tokenAmount,
    //             0,
    //             path,
    //             address(_tokenDistributor),
    //             block.timestamp
    //         );
    //         IERC20 token = IERC20(_token);
    //         token.transferFrom(address(_tokenDistributor), pairAddress, token.balanceOf(address(_tokenDistributor)));
    //         ISwapPair mainPair = ISwapPair(pairAddress);
    //         mainPair.sync();
    //     } else {
    //         if(_token == address(tgyAddress)){
    //             _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //                 tokenAmount,
    //                 0,
    //                 path,
    //                 address(_reciverAddress),
    //                 block.timestamp
    //             );
    //             IERC20 token = IERC20(pecAddress);
    //             uint256 pecAmount = token.balanceOf(address(_tokenDistributor));
    //             token.transferFrom(address(_tokenDistributor), address(this), pecAmount);
    //             address[] memory path2 = new address[](2);
    //             path2[0] = pecAddress;
    //             path2[1] = _token;
    //             _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //                 pecAmount,
    //                 0,
    //                 path2,
    //                 address(burnAddress),
    //                 block.timestamp
    //             );
    //         }else{
    //             _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //                 tokenAmount,
    //                 0,
    //                 path,
    //                 address(_reciverAddress),
    //                 block.timestamp
    //             );
    //         }
    //     }
    // }

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
        require(_purchaseValue[msg.sender] >= value);
        require(value > 0, "Error Value");
        uint index = PVTradeOrder[msg.sender].length;
        uint index2 = PVTradeOrder[to].length;
        PVTradeOrder[msg.sender].push(PVOrder(index, true, msg.sender, to, value, usdtAmount, block.timestamp, 0, false, false));
        PVTradeOrder[to].push(PVOrder(index2, false, msg.sender, to, value, usdtAmount, block.timestamp, 0, false, false));
        emit TransferPV(msg.sender, to, value);
    }

    function dealPVOrder(uint256 index) external {
        IERC20 usdtToken = IERC20(usdtAddress);
        bool haveOrder;
        for (uint i; i < PVTradeOrder[msg.sender].length; i++) 
        {
            if(index == PVTradeOrder[msg.sender][i].index){
                require(!PVTradeOrder[msg.sender][i].done, "Have DONE");
                haveOrder = true;
                PVTradeOrder[msg.sender][i].done = true;
                PVTradeOrder[msg.sender][i].updateTime = block.timestamp;
                bool tURes = usdtToken.transferFrom(msg.sender, PVTradeOrder[msg.sender][i].seller, PVTradeOrder[msg.sender][i].usdtAmount);
                require(tURes, "Transfe USDT Failed");
                _purchaseValue[msg.sender] += PVTradeOrder[msg.sender][i].pvValue;
            }
        }
        require(haveOrder, "Order Not Found");
    }

    function cancelPVOrder(uint256 index) external {
        bool haveOrder;
        for (uint i; i < PVTradeOrder[msg.sender].length; i++) 
        {
            if(index == PVTradeOrder[msg.sender][i].index){
                require(!PVTradeOrder[msg.sender][i].done, "Have DONE");
                haveOrder = true;
                PVTradeOrder[msg.sender][i].cancel = true;
                PVTradeOrder[msg.sender][i].updateTime = block.timestamp;
                _purchaseValue[msg.sender] += PVTradeOrder[msg.sender][i].pvValue;
            }
        }
        require(haveOrder, "Order Not Found");
    }

    function makeSellOrder(address _bnuyer, uint256 _tgyAmount, uint256 _usdtAmount) external {
        IERC20 pecToken = IERC20(pecAddress);
        uint256 userPecBalance = pecToken.balanceOf(msg.sender);
        (uint256 usdtAmount) = queryUsdtAmountWithPEC(userPecBalance);
        require(usdtAmount > 10*1e18, "Under PEC mix");
        IERC20 tgyToken = IERC20(tgyAddress);
        require(tgyToken.balanceOf(msg.sender) >= _tgyAmount, "Error TgyBalance");
        require(tgyToken.allowance(msg.sender, address(this)) >= _tgyAmount, "Allowance TGY ERROR");
        require(_bnuyer != address(0), "Error Buyer");
        uint256 _tgyPrice = _usdtAmount.div(_tgyAmount).mul(1e18);
        Order[] storage myOrders = orders[msg.sender];
        Order[] storage sOrder = orderForMe[_bnuyer];
        uint index = myOrders.length;
        uint aIndex = allOrders.length;
        myOrders.push(Order(index,aIndex, true, msg.sender, _bnuyer, _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
        if (_bnuyer!= address(0)){
            uint sOrderIndex = sOrder.length;
            sOrder.push(Order(sOrderIndex,aIndex, true, msg.sender, _bnuyer, _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
        }
        allOrders.push(Order(index,aIndex, true, msg.sender, _bnuyer, _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
    }

    // function makeSellOrder(uint256 _tgyAmount, uint256 _usdtAmount) external {
    //     IERC20 pecToken = IERC20(pecAddress);
    //     uint256 userPecBalance = pecToken.balanceOf(msg.sender);
    //     (uint256 usdtAmount) = queryUsdtAmountWithPEC(userPecBalance);
    //     require(usdtAmount > 10*1e18, "Under PEC mix");
    //     IERC20 tgyToken = IERC20(tgyAddress);
    //     require(tgyToken.balanceOf(msg.sender) >= _tgyAmount, "Error TgyBalance");
    //     require(tgyToken.allowance(msg.sender, address(this)) >= _tgyAmount, "Allowance TGY ERROR");
    //     uint256 _tgyPrice = _usdtAmount.div(_tgyAmount).mul(1e18);
    //     Order[] storage myOrders = orders[msg.sender];
    //     uint index = myOrders.length;
    //     uint aIndex = allOrders.length;
    //     myOrders.push(Order(index,aIndex, true, msg.sender, address(0), _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
    //     allOrders.push(Order(index,aIndex, true, msg.sender, address(0), _tgyAmount, _tgyPrice, _usdtAmount, block.timestamp, 0, false, false,0));
    // }

    function cancelOrder(uint _index) external {
        Order[] storage _orders = orders[msg.sender];
        bool haveOrder;
        for (uint i; i < _orders.length; i++) 
        { 
            if (_orders[i].index == _index){
                require(!_orders[i].done, "Have Done");
                _orders[i].cancel = true;
                _orders[i].updateTime = block.timestamp;
                updateAllOrderCancel(_orders[i].aIndex);
                haveOrder = true;
            }
        }
        require(haveOrder, "Order Not Found.");
    }

    //购买
    function dealOrder(address _seller, uint _index) external {
        Order[] storage _orders = orders[_seller];
        bool haveOrder;
        for (uint i; i < _orders.length; i++) 
        {
            if (_orders[i].index == _index){
                require(!_orders[i].done, "Have Done");
                if (_orders[i].buyer != address(0)){
                    require(msg.sender == _orders[i].buyer , "Error buyer");
                }
                (uint256 usdtAmount) = queryUsdtAmountWithTGY(_orders[i].tgyAmount);
                require(_purchaseValue[msg.sender] >= usdtAmount, "Purchase Value not enough");
                _purchaseValue[msg.sender] -= usdtAmount;
                _orders[i].done = true;
                _orders[i].usePV = usdtAmount;
                _orders[i].updateTime = block.timestamp;
                updateAllOrder(_orders[i].aIndex);
                IERC20 usdtToken = IERC20(usdtAddress);
                uint256 sellFee = _orders[i].usdtAmount * 5 / 100;
                uint256 rUsdtAmount = _orders[i].tgyAmount - sellFee;
                bool tUsdtRes = usdtToken.transferFrom(msg.sender, marketingAddress, sellFee);
                bool tUsdtRes2 = usdtToken.transferFrom(msg.sender, _orders[i].seller, rUsdtAmount);
                require(tUsdtRes, "USDT TERROR");
                require(tUsdtRes2, "USDT2 TERROR");
                IERC20 tgyToken = IERC20(tgyAddress);
                uint256 buyFee = _orders[i].tgyAmount * 5/100;
                uint256 rTgyAmount = _orders[i].tgyAmount - buyFee;
                bool tTgyRes = tgyToken.transferFrom(_orders[i].seller, msg.sender, buyFee);
                bool tTgyRes2 = tgyToken.transferFrom(_orders[i].seller, tgyAddress, rTgyAmount);
                require(tTgyRes, "TGY TERROR");
                require(tTgyRes2, "TGY TERROR");
                PurchaseOrder[msg.sender].push(_orders[i]);
                haveOrder = true;
            }
        }
        require(haveOrder, "Order Not Found.");
    }

    function updateAllOrder(uint256 aIndex) private {
        for (uint i; i < allOrders.length; i++) 
        {
            if(aIndex == allOrders[i].aIndex){
                allOrders[i].done = true;
                allOrders[i].updateTime = block.timestamp;
            }
        }
    }

    function updateAllOrderCancel(uint256 aIndex) private {
        for (uint i; i < allOrders.length; i++) 
        {
            if(aIndex == allOrders[i].aIndex){
                allOrders[i].cancel = true;
                allOrders[i].updateTime = block.timestamp;
            }
        }
    }

    function allOrderPage(uint start, uint size) public view  returns(Order[] memory _orders2, uint256 h){
        Order[] memory _orders = new Order[](allOrders.length);
        uint j = 0;
        for (uint i = allOrders.length; i > 0; i--) 
        {
            _orders[j] = allOrders[i - 1];
            j++;
        }
        _orders2 = new Order[](size);
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

     function getOrderForMe(uint start, uint size, address _owner) public view  returns(Order[] memory _orders2, uint256 h){
        Order[] memory _orders = new Order[](orderForMe[_owner].length);
        uint j = 0;
        for (uint i = orderForMe[_owner].length; i > 0; i--) 
        {
             _orders[j] = orderForMe[_owner][i - 1];
            j++;
        }
        _orders2 = new Order[](size);
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
            }else{
                continue;
            }
        }
    }

    function getMyMintOrder(uint start, uint size, address _owner) public view  returns(MintOrder[] memory _orders2, uint256 h){
        MintOrder[] memory _orders = new MintOrder[](myMintOrder[_owner].length);
        uint j = 0;
        for (uint i = myMintOrder[_owner].length; i > 0; i--) 
        {
             _orders[j] = myMintOrder[_owner][i - 1];
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

    // function pendingOrderPage(uint start, uint size) public view  returns(Order[] memory _orders2, uint256 h){
    //     Order[] memory _orders = new Order[](allOrders.length);
    //     uint j = 0;
    //     for (uint i = allOrders.length; i > 0; i--) 
    //     {
    //         if(!allOrders[i - 1].done){
    //              _orders[j] = allOrders[i - 1];
    //              j++;
    //         }
    //     }
    //     _orders2 = new Order[](size);
    //     for (uint k = start; k < _orders.length; k++) 
    //     {
    //         if (h<size){
    //             _orders2[h] = _orders[k];
    //             h++;
    //         }else{
    //             continue;
    //         }
    //     }
    // }

    function doneOrderPage(uint start, uint size) public view  returns(Order[] memory _orders2, uint256 h){
        Order[] memory _orders = new Order[](allOrders.length);
        uint j = 0;
        for (uint i = allOrders.length; i > 0; i--) 
        {
            if(allOrders[i - 1].done){
                 _orders[j] = allOrders[i - 1];
                 j++;
            }
        }
        _orders2 = new Order[](size);
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

    function pvOrderPage(uint start, uint size, address _owner) public view  returns(PVOrder[] memory _orders2, uint256 h){
        PVOrder[] memory _orders = new PVOrder[](PVTradeOrder[_owner].length);
        uint j = 0;
        for (uint i = PVTradeOrder[_owner].length; i > 0; i--) 
        {
             _orders[j] = PVTradeOrder[_owner][i - 1];
            j++;
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

    function getCreditValue(address _owner) public view returns(uint256){
        return _creditValue[_owner];
    }

    function getTgyEnableWithdraw(address _owner) public view returns(uint256){
        return tgyEnableWithdraw[_owner];
    }

    function setAddress(address _tokenA, address _tokenB, address _tokenC, address _tokenD, address _tokenE, address _tokenF) external onlyOwner {
        pecAddress = _tokenA;
        tgyAddress = _tokenB;
        pairAddress = _tokenC;
        topMemberFeeAddress = _tokenD;
        lpFeeAddress = _tokenE;
        pecPairAddress = _tokenF;
    }

    function setStartTime() external onlyOwner {
        startTime = block.timestamp;
    }
}