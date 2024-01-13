/**
 *Submitted for verification at BscScan.com on 2023-12-21
*/

// SPDX-License-Identifier: MIT
// File: contracts/IAward.sol


pragma solidity ^0.8.0;
interface IAward {
    function drawToken(address userAddr_, uint256 sum_) external;
}
// File: contracts/ISwapRouter.sol


pragma solidity ^0.8.0;
interface ISwapRouter {

    function swapEstimate(address[2] calldata path,bool status_b,uint256 amount_) external view returns (uint256,uint256,uint256);

    function swap(address[2] calldata path,bool status_b,uint256 amount_) external;

    //添加LP
    function addLP(address[2] calldata path,uint256 tokenAmount_, uint256 uAmount_) external;
    
    //提取LP
    function extractLP(address[2] calldata path) external;

    //获取价格
    function priceOf(address[2] calldata path) external view returns (uint256);
}
// File: contracts/ILP.sol


pragma solidity ^0.8.0;
interface ILP {

    //添加LP
    function addLP(uint256 tokenAmount_, address msg_sender_) external;
    
    //提取LP
    function extractLP(uint256 tokenAmount_, address msg_sender_) external;

    //获取LP
    function getLP(address msg_sender_) external view returns (uint256[2] memory);

    //获取奖励
    function getAward(address msg_sender_) external view returns (uint256[3] memory);

    //领取奖励
    function drawAward(address msg_sender_) external;
}
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.19;

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

// File: contracts/Ownable.sol



pragma solidity ^0.8.0;

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _setOwner(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

// File: contracts/LPSet.sol




pragma solidity ^0.8.0;
contract LPSet is Ownable{
    address public _factory;//工厂合约
    address public _awardPair;//储蓄归集合约
    address public _tokenA;//代币
    address public _tokenB;//代币

    uint256 public _LPU;//总LP-USDT

    uint256 public _rewardLimits;//奖励限制

    mapping(address => uint256[2]) public _LP;//LP：用户地址 => [token,usdt]

    address[] public users; //总用户

    mapping(address => bool) public _userTr; //总用户

    mapping(address => uint256[3]) public _award;//奖励：用户地址 => [总奖励,已领取奖励，待领取奖励]

    //设置工厂合约
    function setFactory(address factory) public onlyOwner{
        _factory = factory;
    }

    //设置代币A
    function setTokenA(address tokenA) public onlyOwner{
        _tokenA = tokenA;
    }

    //设置代币B
    function setTokenB(address tokenB) public onlyOwner{
        _tokenB = tokenB;
    }

    //设置奖励限制
    function setRewardLimits(uint256 val) public onlyOwner{
        _rewardLimits = val;
    }

    //设置LP
    function setLP(address userAddr,uint256 tokenASum,uint256 tokenBSum) public onlyOwner{
        _LP[userAddr][0] = tokenASum;
        _LP[userAddr][1] = tokenBSum;
    }

    //设置Award
    function setAward(address userAddr,uint256 val1,uint256 val2,uint256 val3) public onlyOwner{
        _award[userAddr][0] = val1;
        _award[userAddr][1] = val2;
        _award[userAddr][2] = val3;
    }
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.19;


// File: contracts/IFactory.sol


pragma solidity ^0.8.0;

interface IFactory{
    function getPairAddr(address tokenA, address tokenB) external view returns(address);
    function getTokenAddr(address pairAddr) external view returns(address[2] memory);
    function getLPRouter() external view returns (address);
    function getUniswap() external view returns (IUniswapV2Router02);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
}

// File: contracts/Award.sol







pragma solidity ^0.8.0;
contract Award is Ownable,IAward{
    address public _factory;//工厂合约
    address public _tokenA;//代币
    address public _tokenB;//代币

    //设置工厂合约
    function setFactory(address factory) public onlyOwner{
        _factory = factory;
    }

    //设置代币A
    function setTokenA(address tokenA) public onlyOwner{
        _tokenA = tokenA;
    }

    //设置代币B
    function setTokenB(address tokenB) public onlyOwner{
        _tokenB = tokenB;
    }

    function drawToken(address userAddr_, uint256 sum_) external override onlyOwner{
        IERC20(_tokenA).transfer(userAddr_,sum_);
    }


}
// File: contracts/AwardPair.sol



pragma solidity ^0.8.0;
contract AwardPair is Award{
    constructor() {
        _factory = msg.sender;
    }
    

    function initialize( 
        address tokenA,
        address tokenB,
        address _owner) external {
        require(msg.sender == _factory, 'Pair: Not Factory');
        _tokenA = tokenA;
        _tokenB = tokenB;
        _setOwner(_owner);
    }
}
// File: contracts/LP.sol









pragma solidity ^0.8.0;
contract LP is LPSet,ILP{

    modifier permission(address msg_sender_) {
        require(msg_sender_ == msg.sender || msg.sender == IFactory(_factory).getLPRouter(),"LP: No operation permission");
        _;
    }

    /**
    * type  1：ADDLP，2：EXTRACTLP
    **/

    //ADDLP
    event ADDLP(uint256 type_,address userAddr,uint256 tokenSum,uint256 usdtSum,address pairAddr,address tokenA,address tokenB,uint256 time);

    //EXTRACTLP
    event EXTRACTLP(uint256 type_,address userAddr,uint256 tokenSum,uint256 usdtSum,address pairAddr,address tokenA,address tokenB,uint256 time);

    function getTokenPrice() public view returns (uint256 tokenPrice){
        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;
        tokenPrice = IFactory(_factory).getUniswap().getAmountsOut(1000000000000000000,path)[1];
        return tokenPrice;
    }

    //添加流动性
    function addLP(uint256 tokenAmount_, address msg_sender_) external permission(msg_sender_) override{
        require(tokenAmount_ > uint256(0),"LP: Amount exceeds limit");
        uint256 balance = IERC20(_tokenA).balanceOf(address(this));
        require(IERC20(_tokenA).allowance(msg_sender_,address(this)) >= tokenAmount_,"LP: Insufficient authorization balance");
        require(IERC20(_tokenA).balanceOf(msg_sender_) >= tokenAmount_,"LP: Insufficient balance");
        IERC20(_tokenA).transferFrom(msg_sender_, address(this), tokenAmount_);
        uint256 newBalance = IERC20(_tokenA).balanceOf(address(this));
        tokenAmount_ = newBalance - balance;
        uint256 uAmount = getTokenPrice() * tokenAmount_  / (10 ** 18);
        IERC20(_tokenB).transferFrom(msg_sender_, address(this), uAmount);
        _LP[msg_sender_][0] += tokenAmount_;
        _LP[msg_sender_][1] += uAmount;
        _LPU += uAmount;
        addToSet(msg_sender_);
        emit ADDLP(1,msg_sender_,tokenAmount_,uAmount,address(this),_tokenA,_tokenB,block.timestamp);
    }

    

    //提取流动性
    function extractLP(uint256 tokenAmount_,address msg_sender_) external permission(msg_sender_) override{
        require(tokenAmount_ > uint256(0) && tokenAmount_ <= _LP[msg_sender_][0],"LP: Amount exceeds limit");
        uint256 usdt_amount = tokenAmount_ * _LP[msg_sender_][1] / _LP[msg_sender_][0];
        _LP[msg_sender_][0] -= tokenAmount_;
        _LP[msg_sender_][1] -= usdt_amount;
        IERC20(_tokenA).transfer(msg_sender_, tokenAmount_);
        IERC20(_tokenB).transfer(msg_sender_, usdt_amount);
        _LPU-=usdt_amount;
        emit EXTRACTLP(2,msg_sender_,tokenAmount_,usdt_amount,address(this),_tokenA,_tokenB,block.timestamp);
    }

    function drawToken(address tokenAddr_, address userAddr_, uint256 sum_) public onlyOwner{
        IERC20(tokenAddr_).transfer(userAddr_,sum_);
    }


    function addToSet(address _value) internal {

        if(_userTr[_value] == false){
            _userTr[_value] = true;
            users.push(_value);
        }
    }

    //发放奖励
    function grantAward(uint256 startSub,uint256 stopSub,uint256 awardSum) public onlyOwner{
        require(awardSum > uint256(0),"LP: Amount exceeds limit");
        for(uint256 i = startSub;i<stopSub;i++){
            if(_LP[users[i]][1] >= _rewardLimits){
                uint256 aw = _LP[users[i]][1] * awardSum / _LPU;
                _award[users[i]][2] += aw;
                _award[users[i]][0] += aw;
            }
        }
    }

    //领取奖励
    function drawAward(address msg_sender_) external permission(msg_sender_) override{
        require(_award[msg_sender_][2] > 0,"LP: Amount exceeds limit");
        _award[msg_sender_][1] += _award[msg_sender_][2];
        uint256 a = _award[msg_sender_][2];
        _award[msg_sender_][2] = 0;
        IERC20(_tokenA).transfer(msg_sender_, a);
    }

    //设置用户
    function setUsers(address val) public onlyOwner{
        addToSet(val);
    }

    //获取LP
    function getLP(address msg_sender_) external view returns (uint256[2] memory){
        return _LP[msg_sender_];
    }

    //获取总人数
    function getUserSum() public view returns (uint256){
        return users.length;
    }

    //获取奖励
    function getAward(address msg_sender_) external view returns (uint256[3] memory){
        return _award[msg_sender_];
    }
}
// File: contracts/LPPair.sol



pragma solidity ^0.8.0;
contract LPPair is LP{
    constructor() {
        _factory = msg.sender;
    }
    

    function initialize( 
        address tokenA,
        address tokenB,
        address awardPair,
        address _owner) external {
        require(msg.sender == _factory, 'Pair: Not Factory');
        _tokenA = tokenA;
        _tokenB = tokenB;
        _awardPair = awardPair;
        _rewardLimits = 100000000000000000000;
        _setOwner(_owner);
    }
}
// File: contracts/Factory.sol






pragma solidity ^0.8.0;
contract Factory is Ownable,IFactory{
    mapping(address => mapping(address => address)) private getPair; // 通过两个代币地址查Pair地址
    address[] private allPairs; // 保存所有Pair地址
    mapping(address => bool) private isGroundPair; //是否上架
    mapping(address => address[2]) private getToken; // 通过Pair地址查两个代币地址
    mapping(address => address) private pairOwner;
    mapping(address => address) public awardPairs;
    IUniswapV2Router02 uniswap;
    address public _LPRouter = 0xe81c081752B822AcE9749b73B3248A9a079DafA7;
    // BSC-MainNet
    address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor(){
        _setOwner(msg.sender);
        uniswap = IUniswapV2Router02(ROUTER);
    }

    struct PairInfo {
        address pairAddr;
        address awardPair;
        address tokenA;
        address tokenB;
        bool flang;
    }

    struct PairInfos {
        PairInfo[10] pairInfo;
        bool flang;
    }

    event CreatePair(uint256 type_,address pairAddr);

    function createPair(
        address tokenA,
        address tokenB
    ) public onlyOwner returns (address pairAddr) {
        require(getPairAddr(tokenA,tokenB) == address(0),"Factory: repeat createPair");
        AwardPair aPair = new AwardPair();
        aPair.initialize(tokenA,tokenB,msg.sender);
        address aPairAddr = address(aPair);
        LPPair pair = new LPPair();
        // 调用新合约的initialize方法
        pair.initialize(tokenA,tokenB,aPairAddr,msg.sender);
        // 更新地址map
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        isGroundPair[pairAddr] = true;
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
        getToken[pairAddr] = [tokenA,tokenB];
        pairOwner[pairAddr] = msg.sender;
        awardPairs[pairAddr] = aPairAddr;
        emit CreatePair(5,pairAddr);
        return pairAddr;
    }

    //通过两个代币地址查Pair地址
    function getPairAddr(address tokenA, address tokenB) public override view returns(address){
        return getPair[tokenA][tokenB];
    }

    //查所有Pair地址
    function getAllPairAddr() public view returns(address[] memory){
        return allPairs;
    }

    //上下架
    function setPairGround(address pairAddr_,bool ground_) public{
        require(pairOwner[pairAddr_] == msg.sender,"0");
        isGroundPair[pairAddr_] = ground_;
    }

    //查allGroundPair
    function getAllGroundPair(uint256 page) public view returns(PairInfos memory){
        page = page * 10;
        uint pageSize = page + 10;
        bool flang = true;
        if(pageSize >= allPairs.length){
            pageSize = allPairs.length;
            flang = false;
        }
        PairInfos memory pairInfos;
        PairInfo[10] memory ppp;
        for(uint256 i = 0;i<page + 10;i++){
            if(i < pageSize){
                address pair = allPairs[page + i];
                address[2] memory tokens = getTokenAddr(pair);
                address awardPair = awardPairs[pair];
                if(isGroundPair[pair]){
                    PairInfo memory p = PairInfo(pair,awardPair,tokens[0],tokens[1],true);
                    ppp[i] = p;
                }else {
                    PairInfo memory p = PairInfo(pair,awardPair,tokens[0],tokens[1],false);
                    ppp[i] = p;
                }
            }else {
                PairInfo memory p = PairInfo(address(0),address(0),address(0),address(0),false);
                ppp[i] = p;
            }
            
        }
        pairInfos.pairInfo = ppp;
        pairInfos.flang = flang;
        return (pairInfos);
    }

    //根据pairAddr获取两个token地址
    function getTokenAddr(address pairAddr) public override view returns(address[2] memory){
        return getToken[pairAddr];
    }

    function getUniswap() external override view returns (IUniswapV2Router02){
        return uniswap;
    }


    function getLPRouter() external override view returns (address){
        return _LPRouter;
    }

    function setLPRouter(address val) public onlyOwner{
        _LPRouter = val;
    }
}