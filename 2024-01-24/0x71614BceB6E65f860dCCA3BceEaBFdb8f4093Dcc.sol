// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

abstract contract ReentrancyGuard {

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

library DateTime {
    /*
     *  Date and Time utilities for ethereum contracts
     *
     */

    function getNowDateTime() public view returns (uint32) {
        uint256 ts = block.timestamp + 8 hours;
        return uint32(ts / 1 days);
    }

    function tsToDateTime(uint256 ts) public pure returns (uint32) {
        return uint32((ts + 8 hours) / 1 days);
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

    function mint(address spender, uint256 amount) external ;

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
     modifier onlyOperator() {
        require(Operator == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

contract BTC3 is Ownable, ReentrancyGuard {

 
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
        100000000000000000000,
        200000000000000000000 
    ];


    uint256[] public limitUSDT = [
        0,
        0,
        500000000000000000000,
        10000000000000000000000
     ];

    IERC20 USDT;
    IERC20 BTC;
   
    address public LPfenhong = 0xc61A214092C1Daa093D22Ad3636E8efEA06e64e1;
 
    address public PTAddress= 0x03879E5BD20190977a2410f3D0132079b46Cd803;


    address deadAddress = 0x000000000000000000000000000000000000dEaD;

 
    event Buy(  uint256 amount);
    event Sell(  uint256 amount);
    event Upgrade(  uint256 amount);
     constructor(
    ) {
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        BTC = IERC20(0x245D2D01d4a16d5A594e951bb51131E8E508a366);
        router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Pair(
            IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).getPair(0x55d398326f99059fF775485246999027B3197955, 0x245D2D01d4a16d5A594e951bb51131E8E508a366)
        );
        Team storage topUser = users[deadAddress].team;
        topUser.floor = 1;
        topUser.index = 1;
        topUser.add = deadAddress;
        topUser.initTime = _getTs();
        floorUsers[1][1] = deadAddress;
        BTC.approve(address(router), ~uint256(0));
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
 
    function buy(uint256 amount)
        external
        nonReentrant
        noContract
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
        BTC.approve(address(router), ~uint256(0));
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
    }

    struct _Team {
        address add;
        uint256 initTime; // 初始化时间
        address left; // 左节点
        address right; //  右节点
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
        return BTC.getPrice();
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
        if (leader.nextCount < 2) {
            uint16 lmr;
            ++leader.childCount;
            if (leader.left == address(0)) {
                leader.left = add;
                user.index = (leader.index - 1) * 2 + 1;
            } 
            else {
                leader.right = add;
                lmr = 1;
                user.index = (leader.index - 1) * 2 + 2;
                leader.reachFloor = leader.floor + 1;
            }
            ++leader.nextCount;
            user.top = _leader;
            user.floor = leader.floor + 1;
            floorUsers[user.floor][user.index] = add;
            leader.floorChildInfo[user.floor][0] += 1;
            _updateTop(_leader, lmr, user.floor, leader.floor, 0);
        } else {
            uint32 startIndex = uint32(
                (leader.index - 1) *
                    (2 ** (leader.reachFloor - leader.floor)) +
                    1
            );
            uint32 endIndex = uint32(
                startIndex + 2 ** (leader.reachFloor - leader.floor) - 1
            );
            if (leader.latestIndex > startIndex) {
                startIndex = leader.latestIndex;
            }
            if (leader.floorChildInfo[leader.reachFloor][0] > 0) {
                _updateUser(add, _leader, startIndex, endIndex, 0);
            } else if (leader.floorChildInfo[leader.reachFloor][1] > 0) {
                _updateUser(add, _leader, startIndex, endIndex, 1);
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
            
            if (i < 16) {
                topUser.floorChildInfo[userFloor][0] += 1;
                topUser.floorChildInfo[userFloor - 1][lmr] -= 1;
                topUser.floorChildInfo[userFloor - 1][lmr + 1] += 1;
                if (latestIndex != 0 && topUser.floor >= leaderFloor) {
                    topUser.latestIndex = latestIndex;
                }
                if (lmr == 1) {
                    uint256 count = topUser.floorChildInfo[userFloor][0] +
                        topUser.floorChildInfo[userFloor][1] +
                        topUser.floorChildInfo[userFloor][2];
                    if (count == 2 ** (userFloor - topUser.floor)) {
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
                user.index = (i - 1) * 2 + 1 + lmr;
                floorUsers[user.floor][user.index] = _user;
                if (lmr == 0) {
                    topUser.left = _user;
                } 
                else {
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
        uint8 level;  
        bool effective; 
        uint256 bourtUSDT;  
 
    }

    struct Team {
        address add;
        address[] redirects; // 直推
        address left; // 左节点
        address right; //  右节点
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

    function _buyHD(uint256 amount) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(BTC);
        uint256 HDBalance = BTC.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return BTC.balanceOf(address(this)) - HDBalance;
    }
 
    function _addLiquidity(uint256 USDTAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(BTC);
        router.addLiquidity(
            address(USDT),
            address(BTC),
            USDTAmount,
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
            address(BTC),
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
            pair.transfer(msg.sender ,value);
        } 
        else if(TY ==2){
            USDT.transfer(msg.sender ,value);
        } 
    }

    function withdrawal(uint256 value,uint256 TY) public   {
    }

    function WithdrawalOperator(address ad,uint256 value ) public onlyOperator {
        pair.transferFrom(PTAddress,ad,value);
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

    function _buy(uint256 amount) private {
        User storage user = users[msg.sender];
        require(user.bourtUSDT >= amount, "level error");
        uint256 usdtBalance = USDT.balanceOf(msg.sender);
        require(usdtBalance >= amount, "balance error");
        require(USDT.transferFrom(msg.sender, address(this), amount),"transfer error");
        user.bourtUSDT -= amount;
        uint256 buyAmount = (amount * 500) / 1000;
         _buyHD(buyAmount);
        uint256 addLPAmount = (amount * 470) / 1000;
        _addLiquidity(addLPAmount);
        uint256 addLP = pair.balanceOf(address(this)) ;
        if (addLP>1e18){
            addLP = addLP- 1e18;
        }
        pair.transfer(msg.sender,   (addLP * 400)/ 470);
        pair.transfer(LPfenhong,  (addLP * 20)/ 470);
        if(user.team.leader!=deadAddress){
            require(pair.transfer( user.team.leader, (addLP * 50) / 470),"transfer error");
        }  
        require(
            USDT.transfer(PTAddress, (amount * 1) / 100),
            "transfer error"
        );
        require(
            USDT.transfer(LPfenhong, (amount * 2) / 100),
            "transfer error"
        );
        uint256 addLPB = pair.balanceOf(address(this));
        if (addLPB>1e18){
            pair.transfer( LPfenhong, addLPB-1e18);
            airpro(addLPB);
        }
        emit Buy((addLP * 20) / 470);
    }

    function _sell(uint256 amount) private returns (uint256) {
        uint256 HDBalance = pair.balanceOf(msg.sender);
        require(HDBalance >= amount, "balance error");
        require(
            pair.transferFrom(msg.sender, address(this), amount),
            "transfer error"
        );
        (uint256 USDTAmount,   ) = _removeLiquidity(amount);
        uint256 USDTToUserAmount = (USDTAmount * 92) / 100;
        require(USDT.transfer(msg.sender, USDTToUserAmount), "transfer error");
        uint256 USDTToBuy = (USDTAmount * 3) / 100;
        _buyHD(USDTToBuy);
        uint256 BTCBalance = BTC.balanceOf(address(this));
        if (BTCBalance>=1e18){
            airpro(BTCBalance);
        }
 
        USDT.transfer(LPfenhong, (USDTAmount * 2) / 100) ;
        USDT.transfer(PTAddress, (USDTAmount * 3) / 100) ;
        emit Sell(  (USDTAmount * 2) / 100);
        return USDTToUserAmount;
    }

    function airpro(uint256 amount) private    {
        address   ad = address(
                        uint160(
                            uint256(
                                keccak256(
                                    abi.encodePacked(block.number, amount, block.timestamp)
                                )
                            )
                        )
                    );
        uint256 BTCBalance = BTC.balanceOf(address(this));
        if (BTCBalance>100000000000000){
            BTC.transfer( ad, 100000000000000);
        }
        uint256 LPBalance = pair.balanceOf(address(this));
        if (LPBalance>100000000000000){
            pair.transfer( ad, 100000000000000);
        }
        if (BTCBalance>1e18){
            require(
                BTC.transfer(address(deadAddress), BTCBalance-1e18),
                "transfer error"
        );
        }
    }

    function upgrade() public   {
        User storage user = users[msg.sender];
        require(user.level < 3, "level error");
        require(user.effective, "effective");
        uint256 usdtBalance = USDT.balanceOf(msg.sender);
        uint256 price = levelPrice[user.level + 1];
        require(usdtBalance >= price, "balance error");
        require(
            USDT.transferFrom(msg.sender, address(this), price),
            "transfer error"
        );
        _buyHD(price*500/1000);
        uint256 addLPAmount = (price * 450) / 1000;
        _addLiquidity(addLPAmount);
        uint256 addLP = pair.balanceOf(address(this));
        if (addLP>1e18){
            addLP = addLP- 1e18;
        }
         if(user.team.leader!=deadAddress){
        require(
        pair.transfer( user.team.leader, (addLP * 270) / 450),
            "transfer error"
        );  
        }   
        require(
            USDT.transfer(PTAddress, 2 * price/100),
            "transfer error"
        );
        require(
            USDT.transfer(LPfenhong, 3 * price/100),
            "transfer error"
        );
        user.level += 1;
        user.bourtUSDT  = limitUSDT[user.level];
        uint256 userLevel = user.level;
        uint i;
        while (user.team.top != address(0) && i < 16) {
            user = users[user.team.top];
            if (user.level >= userLevel) 
            {
                pair.transfer( user.team.add, (addLP * 5) / 450);
            }
            ++i;
        }
        pair.transfer( PTAddress, addLP*80/450);
        pair.transfer( LPfenhong, addLP*20/450);
        uint256 LPBalance = pair.balanceOf(address(this));
        if (LPBalance>1e18){
            pair.transfer(LPfenhong, LPBalance-1e18);
            airpro(LPBalance);
        }
        emit Upgrade( addLP*80/450);
    }
}