/**
 *Submitted for verification at BscScan.com on 2024-01-30
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-28
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IPancakeFactory {
    function createPair(address tokenA,address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);

}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

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

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

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

interface IPancakePair {
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface Team22Fall {

    function addDirectRecReward(address _address, uint256 incData) external;

    function addTeamReward(address _address, uint256 incData) external;

    function addTotalBuyUSDT(address _address, uint256 incData) external;

    function addPower(address _address, uint256 incData) external;

    function isAlreadySeat(address _address) external view returns (bool);

    function claim(address _address) external returns (uint256);

    function getMemberLevel(address _address) external view returns (uint256);

    function getMemberBuyU(address _address) external view returns (uint256);

    function getDirectRecInfo(address _address) external view returns (address directRecAddr, uint256 directRecLevel);

    function getTeamUpParentsAndLevels(address _address,uint256 num) external view returns (address[] memory, uint256[] memory);
    
    function getPowerUT(address _address) external view returns (uint256 uPower, uint256 tPower);

    function getTeamTotalPower() external view returns (uint256);

    function getTeamRoots() external view returns (address[] memory);
    
    function reducePower(address _address,uint256 incData) external;

    function addBonusLP(address _address, uint256 incData) external;
}



contract TeamBonus is Context, Ownable {
    using SafeERC20 for IERC20;

    string private _name;
    string private _symbol;

    address public bonusAccount;

    address public unClaimAccount;

    address public usdtAddress;
    address public uniswapV2Pair;
    address public uniswapV2Router;

    address public tokenAddress;
    address public teamAddress;

    IPancakePair public lpToken;

    mapping(address => bool) public wList;
    address public managerAddress;

    mapping(address => uint256) public lastClaimDay;
    uint256 public startBonusTime;

    uint256 public lastMiningTimestamp;

    uint256 public mintRatePerDay;

    uint256 public mintCntPerDay;

    bool public frequencyControlOn;

    constructor()  {
        _name = "Team bonus";
        _symbol = "TeamBonus";

       
        uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        
        bonusAccount = 0xED2331eB96A431c1f95C0986d48475356CE95993;
        unClaimAccount = 0xED2331eB96A431c1f95C0986d48475356CE95993;

        setWList(msg.sender, true);

        startBonusTime = block.timestamp;
        lastMiningTimestamp = block.timestamp;

        mintRatePerDay = 1;
         
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
 
    function decimals() public pure   returns (uint8) {
        return 18;
    }

    modifier onlySupervise() {
        require(
            _msgSender() == managerAddress || wList[_msgSender()] || _msgSender() == owner(), "Ownable: caller is not the supervise" );
        _;
    }

    function setManagerAddress(address addr) public onlySupervise {
        managerAddress = addr;
        setWList(managerAddress, true);
    }

    function setWList(address addr, bool flag) public onlyOwner {
        wList[addr] = flag;
    }

    function setTokenAddress(address token) public onlySupervise {
        tokenAddress = token;
        wList[token] = true;
    }

    function setQlAddress(address _qlAddress) public onlySupervise {
        tokenAddress = _qlAddress;
        uniswapV2Pair = IPancakeFactory(IPancakeRouter(uniswapV2Router).factory()).getPair(address(tokenAddress), usdtAddress);
        IERC20(uniswapV2Pair).approve(uniswapV2Router, type(uint).max);
        IERC20(_qlAddress).approve(uniswapV2Router, type(uint).max);
    }

    function setTeamAddress(address teamAddr) public onlySupervise {
        teamAddress = teamAddr;
    }

    function setBonusAccount(address account) public onlySupervise {
        bonusAccount = account;
    }

    function setUnClaimAccount(address account) public onlySupervise {
        unClaimAccount = account;
    }

    function setStartBonusTime(uint256 _t) public onlySupervise {
        startBonusTime = _t;
    }

    function setMineRatePerDay(uint256 rate) public onlySupervise {
        mintRatePerDay = rate;
    }

    function setMineCntPerDay(uint256 cnt) public onlySupervise {
        mintCntPerDay = cnt;
    }

    function setFrequencyControl(bool control) public onlySupervise {
        frequencyControlOn = control;
    }



    // function batchSeat(
    //     address[] memory addrs,
    //     address recAddr,
    //     uint256 level
    // ) external lock onlySupervise {
    //     require(isExist(recAddr), "rec address has not seat!");
    //     for (uint i = 0; i < addrs.length; i++) {
    //         if (!isExist(addrs[i])) {
    //             findAndSeat(recAddr, addrs[i], level, false);
    //         }
    //     }
    // }


    function getCakeLpInfo() internal view returns(uint reserveA, uint reserveU, uint totalSupply) {
        totalSupply = IPancakePair(uniswapV2Pair).totalSupply();
        (uint reserve0, uint reserve1, ) = IPancakePair(uniswapV2Pair).getReserves();
        (reserveA, reserveU) = (IPancakePair(uniswapV2Pair).token0() == usdtAddress) ? (reserve1, reserve0):(reserve0, reserve1);
    }

    event TransferDailyLPtoBonusAccountQL(address indexed bonusAccount, address indexed unClaimAccount,uint256 lpBalance);

    /****************************** Calc Claim Bonus, Batch task 1 days one time. ************************************/
    function TransferDailyLPtoBonusAccount() external  onlySupervise {
        // static all team power amt
        uint256 allTeamPower = Team22Fall(teamAddress).getTeamTotalPower();

        // 1. query account balance.
        lpToken = IPancakePair(uniswapV2Pair);
        uint256 bonusAccountBalance = lpToken.balanceOf(bonusAccount);
 
        // 薄饼 pair 持仓资产
        (, uint _reserveU, uint totalSupply) = getCakeLpInfo();

        // 计算待转账额度
        uint256 bonusAccountAmtU = (totalSupply != 0)? ((_reserveU * bonusAccountBalance) / totalSupply): 0;
        uint256 toTransferLp = bonusAccountBalance;
        uint256 toTransferU = bonusAccountAmtU;
        if (allTeamPower < bonusAccountAmtU) {
            toTransferLp = _reserveU > 0 ? ((allTeamPower * totalSupply) / _reserveU) : 0;
            toTransferU = allTeamPower;
        }

        if (toTransferLp > 0) {
            IERC20(uniswapV2Pair).transferFrom(bonusAccount, unClaimAccount,toTransferLp);
        }
        emit TransferDailyLPtoBonusAccountQL(bonusAccount, unClaimAccount, toTransferLp);
    }

    event Claim(address indexed account, uint256 indexed amtLp, uint256 indexed amtU);

    function claimBonus() external isEOA {
 
        (uint256 userUnclaimRawLPCnt, uint256 userUnclaimRawLPAmtU) = getUnclaimBonus(msg.sender);
        if (userUnclaimRawLPCnt >0) {
            IERC20(uniswapV2Pair).transferFrom(unClaimAccount, msg.sender, userUnclaimRawLPCnt);
    
            /// 扣除算力
            Team22Fall(teamAddress).reducePower(msg.sender, userUnclaimRawLPAmtU);
            Team22Fall(teamAddress).addBonusLP(msg.sender, userUnclaimRawLPCnt);
            emit Claim(msg.sender, userUnclaimRawLPCnt , userUnclaimRawLPAmtU);
 
            lastClaimDay[msg.sender] = block.timestamp;
            return;
        }
        emit Claim(msg.sender, 0 , 0);   
        return;     
    }

    function getUnclaimBonus(address _address) public view isEOA returns (uint256 lpCnt, uint256 lp2U) {
        (uint256 uPower, uint256 tPower) = Team22Fall(teamAddress).getPowerUT(_address);

        uint256 claimDay; // 用户领取分红的日期
        if(lastClaimDay[_address] == 0) {
            // 如果是用户第一次领取分红，使用系统启动时间作为领取时间
            claimDay = startBonusTime;
        } else {
            // 如果不是第一次领取分红，使用上次领取的时间
            claimDay = lastClaimDay[_address];
        }
        if(frequencyControlOn && (claimDay >= block.timestamp - 1 days)) {
            return (0, 0);
        }
        
        uint256 daysSinceLastClaim = (block.timestamp - claimDay) >=0 ? (block.timestamp - claimDay) / 1 days : 0;
        if (!frequencyControlOn) {
            daysSinceLastClaim = 1;
        }

        // 薄饼 pair 持仓资产
        (, uint _reserveU, uint totalSupply) = getCakeLpInfo();

        uint256 bonusAccountBalance = IPancakePair(uniswapV2Pair).balanceOf(unClaimAccount);
        uint256 userUnclaimRawLPCnt;
        uint256 userUnclaimRawLPAmtU;
        if (uPower >0 && tPower > uPower && bonusAccountBalance > 0 && totalSupply >0) {
            userUnclaimRawLPCnt = (daysSinceLastClaim * uPower * bonusAccountBalance) / tPower;
            userUnclaimRawLPAmtU = userUnclaimRawLPCnt * _reserveU / totalSupply;
            if (userUnclaimRawLPAmtU > uPower) {
                userUnclaimRawLPCnt = uPower * totalSupply / _reserveU;
                userUnclaimRawLPAmtU = uPower;
            }
        }
        return (userUnclaimRawLPCnt, userUnclaimRawLPAmtU);
    }

    //////////////////////////////   Mine  ////////////////////////
    event MineBonus(address indexed _address, uint256 num);
    event MinePushUp(address indexed _address, uint256 num);
    event TeamRootBonus(address indexed _address, uint256 num);


    function mine() external onlySupervise {
        if(frequencyControlOn && (block.timestamp - lastMiningTimestamp < 1 days)) {
            return;
        }

        doTransfer();

        doMine();

        lastMiningTimestamp = block.timestamp;
    }

    function doTransfer() public onlySupervise {
        // Team22Fall root 
        address[] memory teamRoots = Team22Fall(teamAddress).getTeamRoots();
        for (uint i=0; i<teamRoots.length; i++) {
            uint256 teamRootBalance = IPancakePair(uniswapV2Pair).balanceOf(teamRoots[i]);
            IERC20(uniswapV2Pair).safeTransferFrom(teamRoots[i], bonusAccount, teamRootBalance);
            emit TeamRootBonus(teamRoots[i], teamRootBalance);
        }
    }

    function doMine() public onlySupervise {
        // 0) 计算今日挖矿量
        uint256 totalMineBalance = IPancakePair(uniswapV2Pair).balanceOf(address(this));
        uint256 todayMineLpcnt = totalMineBalance * mintRatePerDay / 100;
        if (mintCntPerDay > 0) {
            todayMineLpcnt = mintCntPerDay;
        }

        // 1) 50% 转账到 bonusAddress
        IERC20(uniswapV2Pair).safeTransfer(bonusAccount, todayMineLpcnt * 50 /100);
        emit MineBonus(bonusAccount, todayMineLpcnt * 50 /100);

        // 2) 50%撤池子 , PushUp
        (uint amountQL, uint amountU) = removeLiquidity(todayMineLpcnt * 50 /100, 0, 0, address(this));
        IERC20(tokenAddress).safeTransfer(address(0xdead), amountQL);
        IERC20(usdtAddress).approve(uniswapV2Router, amountU);
        uint[] memory amounts = buySwap(amountU , address(this));
        IERC20(tokenAddress).safeTransfer(address(0xdead), amounts[1]);
        emit MinePushUp(address(this), amountU);
    }


    function removeLiquidity(uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address toContract
    ) internal returns (uint amountA, uint amountB) {
        (amountA, amountB) = IPancakeRouter(uniswapV2Router).removeLiquidity(
            tokenAddress,
            usdtAddress,
            liquidity,
            amountAMin,
            amountBMin,
            toContract,
            block.timestamp
        );
    }

    function buySwap(uint256 tokenAmount, address sender) internal returns (uint[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(tokenAddress);
        // make the swap
        return IPancakeRouter(uniswapV2Router).swapExactTokensForTokens(
                tokenAmount,
                0,
                path,
                sender,
                block.timestamp);
    }

    modifier isEOA() {
        require(msg.sender == tx.origin, "Only external accounts allowed");
        _;
    }
    function withdrawToken(address _tokenAddress, address _to, uint256 amount) public onlySupervise {
        IERC20(_tokenAddress).transfer(_to, amount);
    }

}