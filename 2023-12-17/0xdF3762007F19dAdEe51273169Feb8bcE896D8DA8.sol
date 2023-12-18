// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.9/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts@4.9/access/Ownable.sol";
import "@openzeppelin/contracts@4.9/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract BTH is ERC20,Ownable{ 
    using SafeMath for uint256;
    struct UserInfo{
        address inviter;                
        uint256 ethAmount;              
        uint256 rewardBalance;          
        uint256 releaseWETHBalance;     
        uint256 nextRelease;            
        uint256 pendingTeamRewards;
        uint256 lastRewardBlock;
        uint256 shareActiveNums;
        uint256 teamAmount;        
    }

    bool inSwap;

    modifier swapping(){
        inSwap=true;
        _;
        inSwap=false;
    }

    uint256[] public shareRateList;
    uint256[] public teamRateList;

    uint256 public tokenId;

    uint256 public sosAmount;

    ISwapRouter public SwapRouter;
    IWETH public WETH;          
    IERC20 public USDT;          
    IFund public NFTFund;
    mapping(address=>bool) public isExcludeFee;
    mapping(address=>bool) public automatedMarketMakerPairs;

    AutoSwap public autoSwap;
    AutoSwap public autoSwapFund;

    address public foundation;
    INonfungiblePositionManager public V3Manage;
           
    address public sosAddress; 
    IV3CALC public v3_position_calc;
    
    bool public isStartup;
    bool public isEnableInviter;
    bool public isEnableBuy;
    mapping(address=>mapping(address=>bool)) public bindState;

    mapping(address => UserInfo) public userInfo;

    event Deposit(address from,uint256 amount);

    event Finished(address from,uint256 amount);
    
    event ShareReward(address shareUser,address rewardUser,uint256 amount);

    event BindUser(address from,address inviter);

    event Reward(address from ,uint256 bnbAmount,uint256 bthAmount);

    event TeamReward(address from,address claimUser,uint256 rewardAmount,bool isShare);
    
    constructor()ERC20("BTH-ERC20", "BTH") {
        shareRateList = [20,10,10,5,5];
        teamRateList =  [10,10,10,5,5,5,5,5,5,5];
        foundation=0x10c83b9eE5037DbE4D3138643771E3C281bf3D31;

        isExcludeFee[foundation]=true;

        _mint(foundation,3000000e18);

        _mint(address(this),17999000e18); 
        
        _mint(0xA515515e9Ee61a8995b6b287b776eff65720A5D3,1000e18);

        sosAddress=0x0305Fe450428D2723E3b1783bBCFCA6EAC8Fa7ed;                                                                 

        WETH=IWETH(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);                                 
        
        USDT=IERC20(0x55d398326f99059fF775485246999027B3197955);                                
        
        NFTFund=IFund(0x490E1C570539CFc8374C9D86eB4DcCF828AC19E1);                              

        SwapRouter=ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);                     

        V3Manage = INonfungiblePositionManager(0x46A15B0b27311cedF172AB29E4f4766fbE7F4364);     
        
        v3_position_calc = IV3CALC(0xdB8e871731789D40aC3CF2690Dba486B68bF3F9C);                

        tokenId=311746;

        address factory=SwapRouter.factory();
        
        address usdtPair = ISwapFactory(factory).createPair(address(this),address(USDT));

        address bnbPair =ISwapFactory(factory).createPair(address(this),address(WETH));

        automatedMarketMakerPairs[usdtPair]=true;

        automatedMarketMakerPairs[bnbPair]=true;

        autoSwap = new AutoSwap(address(this));

        autoSwapFund=new AutoSwap(address(this));

        userInfo[0xA515515e9Ee61a8995b6b287b776eff65720A5D3].inviter = 0xC80eB15e2d68695DE2A4366Fb22A250290388004;

        WETH.approve(address(SwapRouter), type(uint256).max);

        _approve(address(this), address(SwapRouter), type(uint256).max);

    }

    receive() external payable{
        address sender = msg.sender;
        uint256 ethAmount = msg.value; 
        bool isBot = isContract(sender);  
        if(isBot  || (tx.origin != sender)){
            return;
        }
        require(isStartup,"BTH-ERC20: Not yet open");

        UserInfo storage user=userInfo[sender];

        require(user.ethAmount ==0&&user.rewardBalance==0,"BTH-ERC20: Deposit exsists");
        require(ethAmount >= 1e18,"BTH-ERC20: pass 1 eth");

        address parent=user.inviter;
        
        if(parent != address(0)){
            UserInfo storage parentUser=userInfo[parent];
            parentUser.shareActiveNums+=1;
            parentUser.teamAmount+=ethAmount;

            uint256[] memory rateList=shareRateList;
            uint256 rewardAmount=ethAmount.mul(rateList[0]).div(1000);
            
            if(rewardAmount>=parentUser.rewardBalance){
                payable(parent).transfer(parentUser.rewardBalance);
                payable(sosAddress).transfer(rewardAmount.sub(parentUser.rewardBalance));
                emit ShareReward(sender,parent,parentUser.rewardBalance);
                finished(parent);
            }else{
                payable(parent).transfer(rewardAmount);
                parentUser.rewardBalance-=rewardAmount;
                emit ShareReward(sender,parent,rewardAmount);
            }

            for(uint i=1;i<5;i++){
                parent=parentUser.inviter;
                rewardAmount=ethAmount.mul(rateList[i]).div(1000);

                if(parent == address(0)){
                    payable(sosAddress).transfer(rewardAmount);
                    continue;
                }
                
                parentUser=userInfo[parent];
                parentUser.teamAmount+=ethAmount;
                
                if(parentUser.rewardBalance>0){
                    if(rewardAmount>=parentUser.rewardBalance){
                        payable(parent).transfer(parentUser.rewardBalance);
                        payable (sosAddress).transfer(rewardAmount.sub(parentUser.rewardBalance));
                        emit ShareReward(sender,parent,parentUser.rewardBalance);
                        finished(parent);
                    }else{
                        payable(parent).transfer(rewardAmount);
                        parentUser.rewardBalance-=rewardAmount;
                        emit ShareReward(sender,parent,rewardAmount);
                    }
                }else{
                    payable(sosAddress).transfer(rewardAmount);
                }
                
            }
        
            for(uint256 i=0;i<50;i++){
                if(parent ==address(0)){
                    break;
                }

                parentUser.teamAmount+=ethAmount;
                parent = parentUser.inviter;
                parentUser=userInfo[parent];
            }
        }

        user.ethAmount=ethAmount;
        user.releaseWETHBalance=ethAmount.mul(79).div(100);     
        user.rewardBalance=ethAmount.mul(150).div(100);
        user.nextRelease=ethAmount.div(100); 
        user.lastRewardBlock=block.number;

        WETH.deposit{value:user.nextRelease}();

        swapWETHToBTH(user.nextRelease);
                
        NFTFund.fund{value:ethAmount.div(10)}();

        payable(0x57c8E60641F283Fa40098189f9241dd6EA4A9329).transfer(ethAmount.div(20));

        uint256 WETHBalance = address(this).balance;
        
        if(WETHBalance>0){
            (uint128 lpAmount,,uint256 amount1) = V3Manage.increaseLiquidity{value: WETHBalance}(INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId:tokenId,
                amount0Desired:0,
                amount1Desired:WETHBalance,
                amount0Min:0,
                amount1Min:WETHBalance,
                deadline:block.timestamp
            }));

            require(lpAmount>0 && amount1 == WETHBalance,"DepositV3 Error");
        }
        
        emit Deposit(sender,ethAmount);
    
    }

    function finished(address from) internal {
        UserInfo storage user=userInfo[from];
        
        emit Finished(from,user.ethAmount);

        user.ethAmount=0;
        user.lastRewardBlock=0;
        user.nextRelease=0;
        user.pendingTeamRewards=0;
        user.rewardBalance=0;

        if(user.releaseWETHBalance>0){
            sosAmount+=user.releaseWETHBalance;
        }
        user.releaseWETHBalance=0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != to,"BTH-ERC20: must from != to");
        require(amount >0 ,"BTH-ERC20: must amount > 0");
        
        if(inSwap || ((isExcludeFee[from]||isExcludeFee[to])&&!isStartup)){ 
            return super._transfer(from,to,amount);
        }

        if(automatedMarketMakerPairs[from]){
            require(isEnableBuy,"BTH-ERC20: Swap BTH Disabled");
            uint256 fees=amount.div(20);
            super._transfer(from, address(autoSwapFund), fees);
            return super._transfer(from,to,amount.sub(fees));
        }else if(automatedMarketMakerPairs[to]){
            uint256 fees=amount.div(20);
            super._transfer(from, address(autoSwapFund), fees);
            process();
            return super._transfer(from,to,amount.sub(fees));
        }else if(!isContract(from)&&to == address(this)){
            reward(from);
        }else{
            doInviter(from,to);
        }

        super._transfer(from, to, amount);
    }
    

    function doInviter(address from,address to) internal {
        UserInfo memory fromUser=userInfo[from];
        UserInfo memory toUser=userInfo[to];
        if(isContract(from)||isContract(to)||!isEnableInviter){
            return;
        }

        if(toUser.inviter == address(0)&&fromUser.inviter !=address(0)){
            bindState[from][to] = true;
            return;
        }

        if(fromUser.inviter == address(0)&&toUser.inviter !=address(0)&&bindState[to][from]){
            userInfo[from].inviter = to;
            emit BindUser(from,to);
        }
        
    }


    function process() internal swapping {
        uint256 totalAmount=balanceOf(address(autoSwapFund));
        super._transfer(address(autoSwapFund), address(this), totalAmount);
        super._transfer(address(this), address(0xDead), totalAmount.div(5));

        uint256 swapAmount = totalAmount.mul(3).div(5);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WETH);

        SwapRouter.swapExactTokensForTokens(swapAmount,0,path,address(autoSwap),block.timestamp);

        uint256 wethAmount= WETH.balanceOf(address(autoSwap));

        autoSwap.withdraw(WETH, address(this), wethAmount);

        SwapRouter.addLiquidity(address(WETH), address(this) , wethAmount, totalAmount.div(5), 0, 0, 0x66aDD9Dd2dc3aAAff708bEaDb1219A5305C7C10e, block.timestamp);
        
        wethAmount=WETH.balanceOf(address(this));
        
        WETH.withdraw(wethAmount);
        uint256 halfAmount=wethAmount.div(2);
        payable(0xcad734be9eCAa4a90DB7A5E857701C106d4B90d9).transfer(halfAmount);
        NFTFund.fund{value:halfAmount}();
    }

    function reward(address from) internal {
        address sender = msg.sender;
        require(sender == from && sender == tx.origin,"BTH-ERC20: Bot Warning");  
        UserInfo storage fromUser=userInfo[from];

        uint256 ethAmount = fromUser.ethAmount;
        
        require(ethAmount>0,"BTH-ERC20: Insufficient Deposit Amount");

        require(fromUser.lastRewardBlock>0&&block.number>fromUser.lastRewardBlock+28800,"BTH-ERC20: Insufficient Reward Time");

        uint256 subDay = block.number.sub(fromUser.lastRewardBlock).div(28800);

        uint256 staticPending = ethAmount.mul(subDay).mul(15).div(1000);

        uint256 rewardPending=staticPending.add(fromUser.pendingTeamRewards);
        
        if(fromUser.releaseWETHBalance>0){
            
            uint256 releaseAmount=fromUser.nextRelease.mul(subDay);
            if(releaseAmount>fromUser.releaseWETHBalance){
                releaseAmount=fromUser.releaseWETHBalance;
            }
            releaseAndSwap(releaseAmount);
            fromUser.releaseWETHBalance=fromUser.releaseWETHBalance.sub(releaseAmount);
        }
        

        if(rewardPending>=fromUser.rewardBalance){
            uint256 sendAmount=_getAmountsOut(fromUser.rewardBalance);
            super._transfer(address(this), from, sendAmount);
            emit Reward(from, fromUser.rewardBalance,sendAmount);
            finished(from);
            
        }else{
            uint256 sendAmount=_getAmountsOut(rewardPending);
            super._transfer(address(this), from,sendAmount );
            fromUser.rewardBalance=fromUser.rewardBalance.sub(rewardPending);
            fromUser.lastRewardBlock=block.number;
            emit Reward(from, rewardPending,sendAmount);
        }
        
        rewardTeam(from,fromUser.inviter,staticPending);
    }

    function rewardTeam(address from,address inviter,uint256 rewardAmount) internal {
    
        uint256[] memory rateList=teamRateList;

        uint256 currSpendRate=0;
        
        for(uint8 i=0;i<50;i++){
            if(inviter == address(0)){
                break;
            }
            UserInfo storage parent=userInfo[inviter];
        
            if(parent.rewardBalance==0){
                continue ;
            }

            if(i<10&&i<parent.shareActiveNums&&parent.ethAmount>0){
                uint256 shareRewars = rewardAmount.mul(rateList[i]).div(100);
                parent.pendingTeamRewards+= shareRewars;
                emit TeamReward(from, inviter, shareRewars,true);
            }
            
            uint256 teamReward;
            if(parent.teamAmount >= 100000e18){
                teamReward = rewardAmount * (50 - currSpendRate) / 100;
                parent.pendingTeamRewards+=teamReward;
                emit TeamReward(from, inviter, teamReward,false);
                break;
            }else if(parent.teamAmount >= 50000e18&&currSpendRate<45){
                teamReward = rewardAmount * (45 - currSpendRate) / 100;
                currSpendRate=45;
            }else if(parent.teamAmount >= 20000e18&&currSpendRate<40){
                teamReward = rewardAmount * (40 - currSpendRate) / 100;
                currSpendRate=40;
            }else if(parent.teamAmount >= 10000e18&&currSpendRate<35){
                teamReward = rewardAmount * (35 - currSpendRate) / 100;
                currSpendRate=35;
            }else if(parent.teamAmount >= 5000e18&&currSpendRate<30){
                teamReward = rewardAmount * (30 - currSpendRate) / 100;
                currSpendRate=30;
            }else if(parent.teamAmount >= 2000e18&&currSpendRate<25){
                teamReward = rewardAmount * (25 - currSpendRate) / 100;
                currSpendRate=25;
            }else if(parent.teamAmount >= 1000e18&&currSpendRate<20){
                teamReward = rewardAmount * (20 - currSpendRate) / 100;
                currSpendRate=20;
            }else if(parent.teamAmount >= 500e18&&currSpendRate<15){
                teamReward = rewardAmount * (15 - currSpendRate) / 100;
                currSpendRate=15;
            }else if(parent.teamAmount >= 200e18&&currSpendRate<10){
                teamReward = rewardAmount * (10 - currSpendRate) / 100;
                currSpendRate=10;
            }else if(parent.teamAmount >= 50e18&&currSpendRate==0){
                teamReward = rewardAmount/20;
                currSpendRate=5;
            }

            if(teamReward>0){
                parent.pendingTeamRewards+=teamReward;
                emit TeamReward(from, inviter, teamReward,false);
            }

            inviter=parent.inviter;
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function releaseAndSwap(uint256 wethAmount) internal {

        (,,,,,int24 tickLower,int24 tickUpper,uint128 liquidity,,,,) = V3Manage.positions(tokenId);

        (,uint256 amountWETH) = IV3CALC(v3_position_calc).principal(0x36696169C63e42cd08ce11f5deeBbCeBae652050,tickLower,tickUpper,liquidity);

        require(amountWETH >= wethAmount&&liquidity>0,"BTH-ERC20:  Insufficient funds");

        uint256 calcRes = wethAmount * liquidity / amountWETH;

        uint128 deLpAmunt = uint128(calcRes)+1;
        
        if(deLpAmunt>liquidity){
            deLpAmunt = liquidity;
        }

        (,uint256 weth2) = V3Manage.decreaseLiquidity(INonfungiblePositionManager.DecreaseLiquidityParams({
             tokenId:tokenId,
             liquidity:deLpAmunt,
             amount0Min:0,
             amount1Min:0,
             deadline:block.timestamp
        }));

        require(weth2>0,"BTH-ERC20: Insufficient position");
        V3Manage.collect(INonfungiblePositionManager.CollectParams({
            tokenId:tokenId,
            recipient:address(this),
            amount0Max:340282366920938463463374607431768211455,
            amount1Max:340282366920938463463374607431768211455
        }));

        swapWETHToBTH(weth2);
        
    }

    function swapWETHToBTH(uint256 wethAmount) internal swapping returns(uint256){
        address[] memory path = new address[](2);
        path[0] = address(WETH);                                   
        path[1] = address(this);

        SwapRouter.swapExactTokensForTokens(wethAmount,0,path,address(autoSwap),block.timestamp);
        uint256 bthAmount=balanceOf(address(autoSwap));
        super._transfer(address(autoSwap), address(this), bthAmount);

        return bthAmount;
    }

    function _getAmountsOut(uint256 ethAmount) internal view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(this);
        uint256[] memory amounts = ISwapRouter(SwapRouter).getAmountsOut(ethAmount, path);
        return amounts[1];
    }
    
    function sosBuy(uint256 amount) external {
        require(sosAmount>=amount,"BTH-ERC20: err amount"); 
        require(msg.sender==sosAddress,"BTH-ERC20: err permission"); 
        
        WETH.approve(address(SwapRouter), type(uint256).max);
        _approve(address(this), address(SwapRouter), type(uint256).max);

        releaseAndSwap(amount);
        sosAmount-=amount;
    }

    function startup() public onlyOwner{
        require(!isStartup,"BTH-ERC20: inviter started");
        isStartup = true;
    }

    function enableInviter() public onlyOwner{
        require(!isEnableInviter,"BTH-ERC20: inviter started");
        isEnableInviter = true;
    }

    function enableBuy() public {
        require(msg.sender==sosAddress,"BTH-ERC20: err permission"); 
        require(!isEnableBuy,"BTH-ERC20: err status");
        isEnableBuy=true;
    }

    function withdrawV3NFT(address to) external onlyOwner{
        V3Manage.transferFrom(address(this), to, tokenId);
    }
}


interface IFund {
    function fund() external payable;
}

interface ISwapPair {
    function mint(address to) external returns (uint liquidity);
}

interface ISwapRouter {
    function factory() external pure returns (address);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract AutoSwap{
    address owner;
    constructor(address _owner){
        owner=_owner;
    }

    function withdraw(IERC20 token,address to,uint256 amount) external {
        require(msg.sender==owner,"AutoSwap: permission err");
        token.transfer(to,amount);
    }
}

interface INonfungiblePositionManager is IERC721{

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    function increaseLiquidity(IncreaseLiquidityParams calldata params) external payable returns (uint128 liquidity,uint256 amount0,uint256 amount1);

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
    external
    view
    returns (
        uint96 nonce,
        address operator,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    );
}

interface IV3CALC{
    function principal(
        address pool,
        int24 _tickLower,
        int24 _tickUpper,
        uint128 liquidity
    ) external view returns (uint256 amount0, uint256 amount1);
}

interface IWETH is IERC20{
    function deposit() external payable ;
    function withdraw(uint wad) external ;
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
