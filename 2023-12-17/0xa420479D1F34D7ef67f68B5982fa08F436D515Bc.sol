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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPancakeRouter02.sol";
import "./Relation.sol";
import "./IOracle.sol";

contract EacMiner is Ownable {

    event addRelationEvent (
        address owner,
        address recommer
    );

    event buyViaEacEvent (
        address owner,
        uint256 tokenAmount,
        uint256 hashrate,
        uint256 eacBalance,
        uint256 ethBalance,
        uint256 outAmount
    );

    event buyViaUsdtEvent (
        address owner,
        uint256 tokenAmount,
        uint256 hashrate,
        uint256 eacBalance,
        uint256 ethBalance,
        uint256 outAmount
    );

    event increaseHashrateEvent (
        address owner,
        uint256 hashrate
    );

    event decreaseHashrateEvent(
        address owner,
        uint256 hashrate
    );

    event increaseTeamHashrateEvent (
        address buyer,
        uint256 payment,
        uint256 paymentUnit,
        address receiver,
        uint256 hashrate,
        uint256 reward,
        uint256 rewardScale
    );

    event decreaseTeamHashrateEvent (
        address buyer,
        address receiver,
        uint256 hashrate
    );

    event claimEacEvent(
        address owner,
        uint256 amount,
        uint256 eacBalance,
        uint256 ethBalance
    );

    event claimEthEvent (
        address owner,
        uint256 amount,
        uint256 eacBalance,
        uint256 ethBalance
    );

    struct Miner {
        address owner;
        uint256 hashrate;
        uint256 teamHashrate;
        uint256 outAmount;
        uint256 lastTimeForEth;
        uint256 lastTimeForEac;
        uint256 totalPurchase;
        uint256 totalEthClaimed;
        uint256 totalEacClaimed;
    }

    mapping(address => Miner) public minerInfo;
    mapping(address => uint256) public activeRecommendNum;
    mapping(address => bool) private bootAddress;
    mapping(address => mapping(address => uint256)) private additionHashrateMapping;
    address immutable private ctoAddress;
    address immutable private platformAddress;
    address public pledgeDividendsAddress;
    address immutable private router;
    address immutable public relation;
    address immutable private WETH_EAC_LP;
    address immutable public deadAddress;
    address immutable public USDT;
    address immutable public EAC;
    address immutable public WETH;
    address immutable public coo;
    address public oracle;
    uint256 private totalHashrate;
    uint256 immutable private claimInterval;
    uint256 public eacDistributeDenominator;
    uint256[] private additionCoefficient;
    uint256[] private additionCoefficientConditions;
    

    constructor(address _usdt,
                    address _eac,
                    address _weth_eac_lp,
                    address _weth,
                    address _cto,
                    address _pledge,
                    address _platform,
                    address _relation,
                    address _router,
                    address _coo,
                    address _oracle) {

       deadAddress = 0x000000000000000000000000000000000000dEaD;
       additionCoefficient = [50, 10, 10, 15, 15, 15, 20, 20, 20, 50];
       additionCoefficientConditions = [100 * 10**18, 300 * 10**18, 500 * 10**18, 800 * 10**18, 1000 * 10**18, 5000 * 10**18, 10000 * 10**18, 100000 * 10**18, 500000 * 10**18, 1000000 * 10**18];
       USDT = _usdt;
       EAC = _eac;
       WETH_EAC_LP = _weth_eac_lp;
       WETH = _weth;
       ctoAddress = _cto;
       pledgeDividendsAddress = _pledge;
       platformAddress = _platform;
       relation = _relation;
       router = _router;
       claimInterval = 60 * 60 * 24 * 5;
       eacDistributeDenominator = 10;
       coo = _coo;
       oracle = _oracle;
   }

   function setEacDistributeDenominator(uint256 _eacDistributeDenominator) external {
    require(msg.sender == coo, "caller is not the coo");
    eacDistributeDenominator = _eacDistributeDenominator;
   }

   function setOracle(address _oracle) external onlyOwner {
    oracle = _oracle;
   }

   function setPlege(address _pledge) external onlyOwner {
    pledgeDividendsAddress = _pledge;
   }

    function addRelationEx(address recommer) external returns (bool result) {
        require(minerInfo[recommer].owner != address(0), "Member does not exist");
        result =  Relation(relation).addRelationEx(msg.sender, recommer);
        minerInfo[msg.sender].owner = msg.sender;
        emit addRelationEvent(msg.sender, recommer);
    }

    function calViaEac(uint256 amount) external view returns (uint hashrate) {
        address[] memory path2 = new address[](2);
        path2[0] = EAC;
        path2[1] = USDT;
        uint256[] memory amounts = IPancakeRouter02(router).getAmountsOut(amount, path2);
        hashrate = amounts[1];
    }

   function depositUSDT(uint256 amount) external {
        minerInfo[msg.sender].owner = msg.sender;
        uint256 tokenAmount = amount;

        // transfer USDT
        IERC20(USDT).transferFrom(msg.sender, address(this), tokenAmount);

        // 50% to buy ETH
        uint256 swapEthAmountIn = tokenAmount / 2;
        address[] memory path1 = new address[](2);
        path1[0] = USDT;
        path1[1] = WETH;
        uint256 swapEthAmountOut = _swapUForToken(swapEthAmountIn, path1, address(this));
        // distribute Eth
        _distributeEth(swapEthAmountOut);

        // 40% to buy EAC
        uint256 swapEacAmountIn = tokenAmount * 4 / 10;
        address[] memory path2 = new address[](2);
        path2[0] = USDT;
        path2[1] = EAC;
        uint256 oracleEacAmountOut = IOracle(oracle).consult(USDT, swapEacAmountIn);
        uint256 swapEacAmountOut = _swapUForToken(swapEacAmountIn, path2, address(this));
        minerInfo[msg.sender].outAmount += oracleEacAmountOut * 25 / 10;
        // distribute eac
        _distributeEac(swapEacAmountOut);

        // 10% to addLP
        uint256 addLqEacAmount = swapEacAmountOut * 25 / 100;

        // 10% to USDT Market Cap
        uint256 addLqAmount2 = tokenAmount / 10;
        _addLiquidity(EAC, USDT, addLqEacAmount, addLqAmount2, deadAddress);

        // add hashrate
        _increaseHashrate(msg.sender, tokenAmount);

        // add recommer
        _addRecommend(msg.sender, Relation(relation).parentOf(msg.sender));

        // add team hashrate
        _increaseTeamHashrate(msg.sender, amount, 1, tokenAmount);

        emit buyViaUsdtEvent(msg.sender, tokenAmount, tokenAmount, IERC20(EAC).balanceOf(address(this)), IERC20(WETH).balanceOf(address(this)), minerInfo[msg.sender].outAmount);
   }

   function depositEAC(uint256 amount) external {
    require(amount <= IERC20(EAC).balanceOf(WETH_EAC_LP) * 5 / 100, "Must not exceed 5% of LP");
    minerInfo[msg.sender].owner = msg.sender;
    uint256 tokenAmount = amount;
    address[] memory path2 = new address[](2);
    path2[0] = EAC;
    path2[1] = USDT;
    uint256 hashrate = IOracle(oracle).consult(EAC, tokenAmount);

    // transfer EAC
    IERC20(EAC).transferFrom(msg.sender, address(this), tokenAmount);

    // 60% to buy eth
    uint256 swapEthAmountIn = tokenAmount * 60 / 100;
    address[] memory path1 = new address[](2);
    path1[0] = EAC;
    path1[1] = WETH;
    uint256 swapEthAmountOut = _swapUForToken(swapEthAmountIn, path1, address(this));

    // out amount
    minerInfo[msg.sender].outAmount += ((amount - swapEthAmountIn) * 25 / 10);

    // distribute Eth
    _distributeEth(swapEthAmountOut);

    // 10% addLq eac/usdt
    _addLiquidity(EAC, WETH, tokenAmount / 10, swapEthAmountOut * 167 / 1000 , deadAddress);

    // 5% to pledge
    IERC20(EAC).transfer(pledgeDividendsAddress, tokenAmount * 5 / 100);
    // add hashrate
    _increaseHashrate(msg.sender, hashrate);

    // add recommer
    _addRecommend(msg.sender, Relation(relation).parentOf(msg.sender));

    // add team hashrate
    _increaseTeamHashrate(msg.sender, amount, 2, hashrate);

    emit buyViaEacEvent(msg.sender, tokenAmount, hashrate, IERC20(EAC).balanceOf(address(this)), IERC20(WETH).balanceOf(address(this)), minerInfo[msg.sender].outAmount);
   }

    function calClaimETH(address owner) external view returns (uint256 amount) {
        Miner memory miner = minerInfo[owner];
        if (block.timestamp - miner.lastTimeForEth  < claimInterval ||
        miner.hashrate <= 0) {
            amount = 0;
        } else {
            amount = IERC20(WETH).balanceOf(address(this)) * (miner.hashrate + miner.teamHashrate) / 180 / totalHashrate;
        }
    }

    function calClaimEAC(address owner) external view returns (uint256 amount) {
        Miner memory miner = minerInfo[owner];
        if (block.timestamp - miner.lastTimeForEac < claimInterval ||
        miner.hashrate <= 0) {
            amount = 0;
        } else {
            uint256 claimAmount = IERC20(EAC).balanceOf(address(this)) * (miner.hashrate + miner.teamHashrate) / eacDistributeDenominator / totalHashrate;
            uint256 remainAmount = miner.outAmount - miner.totalEacClaimed;
            if (claimAmount > remainAmount) {
                claimAmount = remainAmount;
            }
            amount = claimAmount;
        }
    }

   function withdraw() external {
    Miner storage miner = minerInfo[msg.sender];
    require(miner.hashrate > 0, "Please buy hashrate first");
    if (block.timestamp - miner.lastTimeForEac >= claimInterval) {
     miner.lastTimeForEac = block.timestamp;
     uint256 claimAmount = IERC20(EAC).balanceOf(address(this)) * (miner.hashrate + miner.teamHashrate) / eacDistributeDenominator / totalHashrate;
     uint256 remainAmount = miner.outAmount - miner.totalEacClaimed;
     if (claimAmount > remainAmount) {
        claimAmount = remainAmount;
     }

     miner.totalEacClaimed += claimAmount;
     IERC20(EAC).transfer(msg.sender, claimAmount);

     // out or not
     _outOrNot(msg.sender);
     emit claimEacEvent(msg.sender, claimAmount, IERC20(EAC).balanceOf(address(this)), IERC20(WETH).balanceOf(address(this)));
    }

    if (block.timestamp - miner.lastTimeForEth >= claimInterval) {
     miner.lastTimeForEth = block.timestamp;
     uint256 claimAmount = IERC20(WETH).balanceOf(address(this)) * (miner.hashrate + miner.teamHashrate) / 180 / totalHashrate;
     miner.totalEthClaimed += claimAmount;
     IERC20(WETH).transfer(msg.sender, claimAmount);
     emit claimEthEvent(msg.sender, claimAmount, IERC20(EAC).balanceOf(address(this)), IERC20(WETH).balanceOf(address(this)));   
    }
   }

   function _addRecommend(address owner, address recommer) private {
    if (!bootAddress[owner]) {
        activeRecommendNum[recommer] += 1;
        bootAddress[owner] = true;
    }
   }

   function _outOrNot(address owner) private {
    Miner storage miner = minerInfo[owner];
    if (miner.totalEacClaimed >= miner.outAmount) {
        // decrease hashrate
        _decreaseHashrate(owner, miner.hashrate);
    }
   }

   function _swapUForToken(uint256 tokenAmount, address[] memory path, address to) private returns (uint amount) {

        uint oriBalance = IERC20(path[path.length - 1]).balanceOf(to);

        IERC20(path[0]).approve(router, tokenAmount);

        // make the swap
        IPancakeRouter02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
        amount = IERC20(path[path.length - 1]).balanceOf(to) - oriBalance;
    }

    function _distributeEth(uint256 tokenAmount) private {
        // 1% to cto
        IERC20(WETH).transfer(ctoAddress, tokenAmount / 100);

        // 4% to platform
        IERC20(WETH).transfer(platformAddress, tokenAmount * 4 / 100);

        // 95% to contract
    }

    function _distributeEac(uint256 tokenAmount) private {
        // 12.5% to pledge dividends
        IERC20(EAC).transfer(pledgeDividendsAddress, tokenAmount * 125 / 1000);

        // 25% to dead Address
//        IERC20(EAC).transfer(deadAddress, tokenAmount * 25 / 100);

        // 62.5% to miner
    }

    function _increaseHashrate(address owner, uint256 amount) private {
        Miner storage miner = minerInfo[owner];
        if (miner.hashrate <=0) {
            miner.lastTimeForEac = block.timestamp;
            miner.lastTimeForEth = block.timestamp;
        }
        miner.hashrate += amount;
        miner.totalPurchase += amount;
        totalHashrate += amount;
        emit increaseHashrateEvent(owner, amount);
    }

    function _increaseTeamHashrate(address owner, uint256 payment, uint256 paymentUnit, uint256 amount) private {
        address[] memory parents = Relation(relation).getForefathers(owner, 10);
        for (uint256 i = 0; i < parents.length; i++) {
            if (parents[i] == address(0)) {
                break;
            }
            Miner storage miner = minerInfo[parents[i]];
            if (miner.hashrate + miner.teamHashrate >= additionCoefficientConditions[i] && activeRecommendNum[parents[i]] >= i + 1) {
                uint256 additionHashrate = amount * additionCoefficient[i] / 100;
                miner.teamHashrate += additionHashrate;
                totalHashrate += additionHashrate;
                additionHashrateMapping[owner][parents[i]] += additionHashrate;
                emit increaseTeamHashrateEvent(owner, payment, paymentUnit, parents[i], amount, additionHashrate, additionCoefficient[i]);
            }
        }
    }

    function _decreaseHashrate(address owner, uint amount) private {
        // decrease own hashrate
        Miner storage miner = minerInfo[owner];
        miner.hashrate -= amount;
        totalHashrate -= amount;

        if (miner.hashrate <=0) {
            miner.lastTimeForEac = 0;
            miner.lastTimeForEth = 0;
        }

        //decrease team hashrate
        address[] memory parents = Relation(relation).getForefathers(owner, 10);
        for (uint256 i = 0; i < parents.length; i++) {
            if (parents[i] == address(0)) {
                break;
            }
            if (additionHashrateMapping[owner][parents[i]] != 0) {
                minerInfo[parents[i]].teamHashrate -= additionHashrateMapping[owner][parents[i]];
                totalHashrate -= additionHashrateMapping[owner][parents[i]];
                emit decreaseTeamHashrateEvent(owner, parents[i], additionHashrateMapping[owner][parents[i]]);
                additionHashrateMapping[owner][parents[i]] = 0;
            }
        }
        emit decreaseHashrateEvent(owner, amount);
    }

     // 增加流动性
    function _addLiquidity(address token1, address token2, uint256 tokenAmount1, uint256 tokenAmount2, address to) private {
        // approve token transfer to cover all possible scenarios
        IPancakeRouter02 r = IPancakeRouter02(router);
        IERC20(token1).approve(router, tokenAmount1);
        IERC20(token2).approve(router, tokenAmount2);

        // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
        r.addLiquidity(
            token1,
            token2,
            tokenAmount1,
            tokenAmount2,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            to,
            block.timestamp
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IOracle {

     function consult(address token, uint amountIn) external view returns (uint amountOut);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RelationStorage {

    struct RecommerData {
        uint256 ts;
        address addr;
    }

    uint public totalAddresses;
    // parent node
    mapping (address => address) public _recommerMapping;
    // child node
    mapping (address => address[]) internal _recommerList;
    // child node data
    mapping (address => RecommerData[]) internal _recommerDataList;
    
    constructor() {
    }
}

contract Relation is RelationStorage() {

    modifier onlyBoss() {
        require(bosses[msg.sender], "Relation: caller is not the boss");
        _;
    }

    mapping(address => bool) public bosses;

      constructor(address _boss) {
        bosses[_boss] = true;
    }

    function addBoss(address _boss) external onlyBoss {
        bosses[_boss] = true;
    }

    function removeBoss(address _boss) external onlyBoss {
        bosses[_boss] = false;
    }

    // bind
    function addRelationEx(address slef,address recommer) external onlyBoss returns (bool) {

        require(recommer != slef,"your_self");                   

        require(_recommerMapping[slef] == address(0),"binded");

        totalAddresses++;

        _recommerMapping[slef] = recommer;
        _recommerList[recommer].push(slef);
        _recommerDataList[recommer].push(RecommerData(block.timestamp, slef));
        return true;
    }

    // find parent
    function parentOf(address owner) external view returns(address){
        return _recommerMapping[owner];
    }
    
    // find parent
    function getForefathers(address owner,uint num) public view returns(address[] memory fathers){

        fathers = new address[](num);

        address parent  = owner;
        for( uint i = 0; i < num; i++){
            parent = _recommerMapping[parent];

            if(parent == address(0) ) break;

            fathers[i] = parent;
        }
    }
    
    // find child
    function childrenOf(address owner) external view returns(address[] memory){
        return _recommerList[owner];
    }

    function childrenDataOf(address owner) external view returns (RecommerData[] memory) {
        return _recommerDataList[owner];
    }
}