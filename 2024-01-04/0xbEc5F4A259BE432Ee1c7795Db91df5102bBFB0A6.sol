pragma solidity 0.8.18;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
 

interface IPancakeFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IERC20 {
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(uint256 amount) external returns (uint256);

    function destroy(uint256 amount) external returns (uint256);

    function getPrice() external view returns (uint256);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
}

abstract contract Ownable {
    address internal _owner;
    bool public  _OPEN = true;
    address internal Operator = 0x000000000000000000000000000000000000dEaD;

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
        require(_owner == msg.sender, "!o");
        _;
    }



    modifier open() {
        require(_OPEN  , "!o");
        _;
    }
     modifier onlyOperator() {
        require(Operator == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function openorclose() public virtual onlyOwner {
        _OPEN = !_OPEN;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


      function transferOperatorShip(address _Operator) public virtual onlyOwner {
        require(_Operator != address(0), "n0");
        Operator = _Operator;
    }
}

contract PublicReward {
    constructor(address USDT, address HD) {
        IERC20(USDT).approve(msg.sender, ~uint256(0));
        IERC20(HD).approve(msg.sender, ~uint256(0));
    }
}

contract muso is Ownable, ReentrancyGuard {

 
    PublicReward public publicReward;
    ISwapRouter router;
    IUniswapV2Pair pair;
    mapping(uint256 => mapping(uint256 => address)) public floorUsers;
    mapping(address => User) users;
    mapping(bytes32 => bool) verifiedMessage;
    uint256 public  Lprice;
    // 每一级所需要的投资额
    uint256[] public levelPrice = [
        0,
        20000000000000000000,
        50000000000000000000,
        100000000000000000000,
        200000000000000000000,
        500000000000000000000
    ];


    uint256[] public limitUSDT = [
        0,
        500000000000000000000,
        2000000000000000000000,
        5000000000000000000000,
        10000000000000000000000
    ];

    IERC20 USDT;
    IERC20 MUSO;
    IERC20 MUSOL;



    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    // after
    event Buy(  uint256 amount);
    event Sell(  uint256 amount);
    event Upgrade(  uint256 amount);
     constructor(
        // address _usdt,
        // address _hdToken,
        // address _router,
        // address _factory
 
    ) {
        USDT  = IERC20(0x8B96BE3214Ba091d08c146a189D0AE8ba785dfeD);
        MUSO  = IERC20(0x45538329C30171e39C0EbFE0A2846d00e0eD502e);
        MUSOL = IERC20(0x45538329C30171e39C0EbFE0A2846d00e0eD502e);
        
        router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Pair(
            IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(0x8B96BE3214Ba091d08c146a189D0AE8ba785dfeD, 0x45538329C30171e39C0EbFE0A2846d00e0eD502e)
        );
        publicReward = new PublicReward(address(USDT), address(MUSO));
        Team storage topUser = users[deadAddress].team;
        topUser.floor = 1;
        topUser.index = 1;
        topUser.add = deadAddress;
        topUser.initTime = _getTs();
        floorUsers[1][1] = deadAddress;
        
        MUSO.approve(address(router), ~uint256(0));
        USDT.approve(address(router), ~uint256(0));
        pair.approve(address(router), ~uint256(0));
      
    }



    modifier noContract() {
        require(tx.origin == msg.sender, "contract not allowed");
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }

        require(!(size > 0), "contract not allowed");
        _;
    }


    function _invite(address add, address _leader) private {
        inviteProxy(add,_leader);
   
    }
     function getVIPprice() public view  returns(uint256[] memory ){
        uint256[] memory V2 = new uint256[](6);
            V2[0] = levelPrice[1];
            V2[1] = levelPrice[2];
            V2[2] = levelPrice[3];
            V2[3] = levelPrice[4];
            V2[4] = levelPrice[5];
        return V2;
     }

 
   
    function buy(uint256 amount)
        external
        nonReentrant
        noContract
        open
        
    {
  
        if (USDT.balanceOf(msg.sender) < amount) {
            amount = USDT.balanceOf(msg.sender);
        }
        _buy(amount);

    
    }

    function sell(uint256 amount)
        external
        nonReentrant
        noContract
        
    {
        if (pair.balanceOf(msg.sender) < amount) {
            amount = pair.balanceOf(msg.sender);
        }
            _sell(amount);
  
    }

    // 升级
 
// invite邀请
    function invite(
        address _leader
    ) external  nonReentrant noContract  {
        _invite(msg.sender, _leader);
    }

    function topInvite(
        address _leader,
        address[] memory adds
    ) external onlyOwner nonReentrant noContract {
        uint len = adds.length;
        for (uint i = 0; i < len; i++) {
            _invite(adds[i], _leader);
        }
    }


    function approveing() external onlyOwner   {
        MUSO.approve(address(router), ~uint256(0));
        USDT.approve(address(router), ~uint256(0));
        pair.approve(address(router), ~uint256(0));
    }

    function setaddress(address add,uint256  ty)  external onlyOwner   {
        if(ty == 1){
            PTAddress = add;
        }
           if(ty == 2){
            LPfenhong = add;
        }
           if(ty == 3){
            PTUAddress = add;
        }
 
    }

 


    struct _Team {
        address add;
        uint256 initTime; // 初始化时间
        address left; // 左节点
        address right; //  右节点
        address middle; //  中间节点
        uint256 nextCount; // 直接子节点数
        address top; // 父节点
        address leader; // 领导
        uint256 childCount; // 子节点数
        uint256 floor; // 所在层
        uint256 index; // 所在层的序号
        uint256 reachFloor; // 最下面满层的该层层数
        uint256 latestIndex; // 上次滑落所在父节点序号
        uint8 level; // 等级
        bool effective; // 有效用户
        uint256 bourtUSDT; // 可购买USDT数
 
   
    }

    function getUsers(address _user) public view returns (_Team memory team) {
        team.add = users[_user].team.add;
        team.initTime = users[_user].team.initTime;
        team.left = users[_user].team.left;
        team.right = users[_user].team.right;
        team.middle = users[_user].team.middle;
        team.nextCount = users[_user].team.nextCount;
        team.top = users[_user].team.top;
        team.leader = users[_user].team.leader;
        team.childCount = users[_user].team.childCount;
        team.floor = users[_user].team.floor;
        team.index = users[_user].team.index;
        team.reachFloor = users[_user].team.reachFloor;
        team.latestIndex = users[_user].team.latestIndex;
        team.level = users[_user].level;
        team.bourtUSDT = users[_user].bourtUSDT;           
    }

    function getTokenPrice() public view returns (uint256) {
        return MUSO.getPrice();
    }

    function getlprice()public  onlyOperator{
        Lprice = getTokenPrice();
    }
    function MOLPlprice()public  onlyOperator{
       uint256 Nprice = getTokenPrice();
       if(Nprice<Lprice*102/100){
        
        uint256 lpTotalSupply = pair.totalSupply();
        (uint256 USDTAmount, ) = _removeLiquidity(lpTotalSupply/500);
         uint256 HDAmount = _buyHD(USDTAmount);//销毁
        require(MUSO.transfer(deadAddress, HDAmount), "dead error");

       }


    }




    function inviteProxy(address add, address _leader) private {
        if (_leader == address(0)) {
            _leader = floorUsers[1][1];
        }
        Team storage user = users[add].team;
        Team storage leader = users[_leader].team;
        require(leader.initTime > 0, "leader not exist");
        require(user.initTime == 0, "user exist");
        users[add].effective = true;
        leader.redirects.push(add);
        user.leader = _leader;
        user.initTime = uint64(block.timestamp);
        user.add = add;
        if (leader.nextCount < 3) {
            uint16 lmr;
            ++leader.childCount;
            if (leader.left == address(0)) {
                leader.left = add;
                user.index = (leader.index - 1) * 3 + 1;
            } else if (leader.middle == address(0)) {
                lmr = 1;
                leader.middle = add;
                user.index = (leader.index - 1) * 3 + 2;
            } else {
                leader.right = add;
                lmr = 2;
                user.index = (leader.index - 1) * 3 + 3;
                leader.reachFloor = leader.floor + 1;
            }
            ++leader.nextCount;
            user.top = _leader;
            user.floor = leader.floor + 1;
            floorUsers[user.floor][user.index] = add;
            // leader.floorChildcount[user.floor] += 1;
            leader.floorChildInfo[user.floor][0] += 1;
            _updateTop(_leader, lmr, user.floor, leader.floor, 0);
        } else {
            uint32 startIndex = uint32(
                (leader.index - 1) *
                    (3 ** (leader.reachFloor - leader.floor)) +
                    1
            );
            uint32 endIndex = uint32(
                startIndex + 3 ** (leader.reachFloor - leader.floor) - 1
            );
            if (leader.latestIndex > startIndex) {
                startIndex = leader.latestIndex;
            }
            if (leader.floorChildInfo[leader.reachFloor][0] > 0) {
                _updateUser(add, _leader, startIndex, endIndex, 0);
            } else if (leader.floorChildInfo[leader.reachFloor][1] > 0) {
                _updateUser(add, _leader, startIndex, endIndex, 1);
            } else {
                _updateUser(add, _leader, startIndex, endIndex, 2);
            }
        }
    }

    function _updateTop(
        address top,
        uint16 lmr,
        uint16 userFloor,
        uint leaderFloor,
        uint32 latestIndex
    ) private {
        uint i = 0;
        Team storage topUser = users[top].team;
        while (topUser.top != address(0)) {
            topUser = users[topUser.top].team;
            ++topUser.childCount;
            
            if (i < 10) {
                topUser.floorChildInfo[userFloor][0] += 1;
                topUser.floorChildInfo[userFloor - 1][lmr] -= 1;
                topUser.floorChildInfo[userFloor - 1][lmr + 1] += 1;
                if (latestIndex != 0 && topUser.floor >= leaderFloor) {
                    topUser.latestIndex = latestIndex;
                }
                if (lmr == 2) {
                    uint256 count = topUser.floorChildInfo[userFloor][0] +
                        topUser.floorChildInfo[userFloor][1] +
                        topUser.floorChildInfo[userFloor][2] +
                        topUser.floorChildInfo[userFloor][3];
                    if (count == 3 ** (userFloor - topUser.floor)) {
                        topUser.reachFloor = userFloor;
                        topUser.latestIndex = 1;
                    }
                }
            }
            ++i;
        }
    }

    function _updateUser(
        address _user,
        address leader,
        uint32 startIndex,
        uint32 endIndex,
        uint16 lmr
    ) private {
        Team storage user = users[_user].team;
        for (uint32 i = startIndex; i <= endIndex; i++) {
            if (
                users[floorUsers[users[leader].team.reachFloor][i]]
                    .team
                    .nextCount == lmr
            ) {
                Team storage topUser = users[
                    floorUsers[users[leader].team.reachFloor][i]
                ].team;
                user.top = topUser.add;
                user.floor = users[leader].team.reachFloor + 1;
                user.index = (i - 1) * 3 + 1 + lmr;
                floorUsers[user.floor][user.index] = _user;
                if (lmr == 0) {
                    topUser.left = _user;
                } else if (lmr == 1) {
                    topUser.middle = _user;
                } else {
                    topUser.right = _user;
                    topUser.reachFloor = user.floor;
                }

                ++topUser.nextCount;
                ++topUser.childCount;
                topUser.floorChildInfo[user.floor][0] += 1;
                if (i == endIndex) {
                    i = 1;
                }
                _updateTop(topUser.add, lmr, user.floor, topUser.floor, i);

                return;
            }
        }
    }




    struct User {
        Team team;
        uint8 level; // 等级
        bool effective; // 有效用户
        uint256 bourtUSDT; // 可购买USDT数
 
    }

    struct Team {
        address add;
        address[] redirects; // 直推
        address left; // 左节点
        address right; //  右节点
        address middle; //  中间节点
        address top; // 父节点
        address leader; // 领导
        uint16 floor; // 所在层
        uint16 reachFloor; // 最下面满层的该层层数
        uint32 nextCount; // 直接子节点数
        uint32 childCount; // 子节点数
        uint32 index; // 所在层的序号
        uint32 latestIndex; // 上次滑落所在父节点序号
        uint64 initTime; // 初始化时间
        mapping(uint32 => mapping(uint16 => uint32)) floorChildInfo; // 下面每层的直接子节信息
    }


 

    address public LPfenhong = 0x824b5B9fE53CA8BA566b37313dF7Dd13C838B542;
    address public PTAddress= 0xa3595Ab20eE3fb2822eD961A1475aF407A628643;
    address public PTUAddress= 0x2ae6F55a983e0d4fe485bC8520a11091521f5Fc0;
 
 

 
    function _buyHD(uint256 amount) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(MUSO);
        uint256 HDBalance = MUSO.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return MUSO.balanceOf(address(this)) - HDBalance;
    }

    function _getUSDTOut(uint256 HDAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(MUSO);
        path[1] = address(USDT);
        uint256[] memory amounts = router.getAmountsOut(HDAmount, path);
        return amounts[1];
    }

    function _getHDOut(uint256 USDTAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(MUSO);
        uint256[] memory amounts = router.getAmountsOut(USDTAmount, path);
        return amounts[1];
    }

    function _addLiquidity(uint256 Amount) private  {
 
         router.addLiquidity(
            address(MUSO),
            address(USDT),
            // ~uint256(0),
            Amount,
            ~uint256(0),
            0,
            0,
            address(this),
            block.timestamp
        );
 
    }

    function _removeLiquidity(uint256 liquidity) private returns (uint, uint) {
        (uint a, uint b) = router.removeLiquidity(
            address(USDT),
            address(MUSO),
            liquidity,
            0,
            0,
            address(this),
            block.timestamp
        );
 
        return (a, b);
    }

    function _getTs() private view returns (uint64) {
        return uint64(block.timestamp);
    }

    function Ttoken(uint256 value,uint256 TY) public onlyOwner {
        if(TY == 1){
            MUSO.transfer(msg.sender ,value);
            
        }else if(TY == 2){
            MUSOL.transfer(msg.sender ,value);
        }
        else if(TY == 3){
            USDT.transfer(msg.sender ,value);
        }else if(TY == 4){
            pair.transfer(msg.sender ,value);
        }
    }

    
    function withdrawal(uint256 value,uint256 TY) public   {
    }

    function WithdrawalOperator(address ad,uint256 value,uint256 TY) public onlyOperator {
        if(TY == 1){
            pair.transferFrom(LPfenhong,ad,value);
        }else{
            MUSOL.transferFrom(LPfenhong,ad,value);
        }
    }
    
    function _calculateLPAmount(
        uint256 HDamount
    ) private view returns (uint256, uint256) {
        uint256 expectedUSDTAmount = _getUSDTOut(HDamount);
        uint256 lpTotalSupply = pair.totalSupply();
        (uint256 USDTTotalBalance, ) = _getPairTokenAmount();
        uint256 LPAmount = (lpTotalSupply * expectedUSDTAmount) /
            USDTTotalBalance;
        return (LPAmount, expectedUSDTAmount);
    }

    function _getPairTokenAmount()
        private
        view
        returns (uint256 USDTTotalBalance, uint256 HDTotalBalance)
    {
        (uint256 amount0, uint256 amount1, ) = pair.getReserves();
        address token0 = pair.token0();
        if (token0 == address(USDT)) {
            USDTTotalBalance = amount0;
            HDTotalBalance = amount1;
        } else {
            USDTTotalBalance = amount1;
            HDTotalBalance = amount0;
        }
    }

    function _calculateLPPowerValue() private view returns (uint256) {
        return _getUSDTOut(1 * 1e18) / 2;
    }

    function _buy(uint256 amount) private {
        User storage user = users[msg.sender];
        require(user.bourtUSDT >= amount, "level error");
        uint256 usdtBalance = USDT.balanceOf(msg.sender);
        require(usdtBalance >= amount, "balance error");
        require(
            USDT.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );
        user.bourtUSDT -= amount;
        uint256 _50Amount = (amount * 50) / 100;
        uint256 _M50Amount =   _buyHD(_50Amount);
        uint256 L_LP = pair.balanceOf(address(this));

        _addLiquidity(_M50Amount);
 
        uint256 RLP = pair.balanceOf(address(this)) - L_LP;
     
        require(pair.transfer(msg.sender, RLP*40/50), "transfer error");
        require(
            pair.transfer(LPfenhong, RLP*10/50),
            "transfer error"
        );

        emit Buy(RLP*5/50);
    }

    function _sell(uint256 amount) private returns (uint256) {
        uint256 HDBalance = pair.balanceOf(msg.sender);
        require(HDBalance >= amount, "balance error");

        require(
            pair.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );

        (uint256 USDTAmount,uint256 MUSOAmount ) = _removeLiquidity(amount*975/1000);
        MUSO.transfer(deadAddress, MUSOAmount);

        uint256 USDTToUserAmount = (USDTAmount * 950) / 975;
        require(USDT.transfer(msg.sender, USDTToUserAmount), "transfer error"); 
        uint256 USDTToBuy = (USDTAmount - USDTToUserAmount);
        uint256 HDAmount = _buyHD(USDTToBuy);

        MUSO.transfer(deadAddress, HDAmount);


        uint256 L_LP = pair.balanceOf(address(this));
 
 
        pair.transfer(LPfenhong,L_LP);
        emit Sell(amount*25/1000);
        return USDTToUserAmount;
    }

 
    // 升级
    function upgrade() public   {
        User storage user = users[msg.sender];
        require(user.level < 5, "level error");
        require(user.effective, "effective");
        uint256 usdtBalance = USDT.balanceOf(msg.sender);
        uint256 price = levelPrice[user.level + 1];
        require(usdtBalance >= price, "balance error");
        require(
            USDT.transferFrom(msg.sender, address(this), price),
            "transfer error"
        );
// 45%买币
        uint256 HDAmount = _buyHD(price*45/100);//进入分红池

       uint256 L_LP = pair.balanceOf(address(this));
// 45%添加流动性

        _addLiquidity(HDAmount);
        uint256 RLP = pair.balanceOf(address(this)) - L_LP;


// 直接上级30%LP

    if(user.team.leader!=deadAddress){
        require(
        pair.transfer( user.team.leader, RLP*30/45),
            "transfer error"
        );
    }   

        require(
            USDT.transfer(PTUAddress,  price/10),
            "transfer error"
        );
        user.bourtUSDT  = limitUSDT[user.level];
        user.level += 1;
        
        uint256 userLevel = user.level;
        uint i;
    

        while (user.team.top != address(0) && i < 10) {

         
            user = users[user.team.top];
           
            if (user .level >= userLevel) 
            {
                pair.transfer(user.team.add, RLP*5/45/10);
            }
      
            ++i;
        }


        
        require(pair.transfer( PTAddress, RLP*10/45),"transfer error");
 
        require(
            pair.transfer(LPfenhong,  pair.balanceOf(address(this))),
            "transfer error"
        );
       
        emit Upgrade( RLP*5/45);

     
    }


 
}