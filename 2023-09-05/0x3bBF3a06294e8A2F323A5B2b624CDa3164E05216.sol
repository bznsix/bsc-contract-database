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
pragma solidity ^0.8.8;

library StructData {
    // struct to store staked NFT information
    struct StakedNFT {
        address stakerAddress;
        uint256 startTime;
        uint256 unlockTime;
        uint256[] nftIds;
        uint256 totalValueStakeUsdWithDecimal;
        uint16 apr;
        uint256 totalClaimedAmountUsdWithDecimal;
        uint256 totalRewardAmountUsdWithDecimal;
        bool isUnstaked;
    }

    struct ChildListData {
        address[] childList;
        uint256 memberCounter;
    }

    struct ListBuyData {
        StructData.InfoBuyData[] childList;
    }

    struct InfoBuyData {
        uint256 timeBuy;
        uint256 valueUsd;
    }

    struct ListSwapData {
        StructData.InfoSwapData[] childList;
    }

    struct InfoSwapData {
        uint256 timeSwap;
        uint256 valueSwap;
    }

    struct ListMaintenance {
        StructData.InfoMaintenanceNft[] childList;
    }

    struct InfoMaintenanceNft {
        uint256 startTimeRepair;
        uint256 endTimeRepair;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMarketplace.sol";
import "../oracle/Oracle.sol";
import "../token/FitZenERC20.sol";
import "../data/StructData.sol";

contract DistributionCommission is Ownable {
    address public currency;
    address public marketplaceContract;
    address public oracleContract;
    uint256 private maxNumberDistributionCommission = 250; // 2,5 lan earned hoa hong phan bo
    uint256 private maxDayDistributionCommissionEarn = 180; //day nhan hoa hong phan bo
    uint256 private totalLevelEarn = 8; //day nhan hoa hong phan bo

    mapping(address => StructData.ListBuyData) nftBuyByTimestamp;
    mapping(uint8 => uint16) public commissionPercent;
    mapping(uint8 => uint8) public conditionF1Commission;
    mapping(uint8 => uint16) public orConditionF1Commission;

    constructor(address _currency, address _marketplaceAddress){
        currency = _currency;
        marketplaceContract = _marketplaceAddress;
        oracleContract = address(0);
        initCommissionPercent();
        initConditionF1Commission();
        initOrConditionF1Commission();
    }

    function initCommissionPercent() internal {
        commissionPercent[1] = 480;
        commissionPercent[2] = 360;
        commissionPercent[3] = 300;
        commissionPercent[4] = 180;
        commissionPercent[5] = 180;
        commissionPercent[6] = 120;
        commissionPercent[7] = 120;
        commissionPercent[8] = 60;
    }


    function initConditionF1Commission() internal {
        conditionF1Commission[1] = 0;
        conditionF1Commission[2] = 0;
        conditionF1Commission[3] = 2;
        conditionF1Commission[4] = 3;
        conditionF1Commission[5] = 4;
        conditionF1Commission[6] = 5;
        conditionF1Commission[7] = 6;
        conditionF1Commission[8] = 8;
    }

    function initOrConditionF1Commission() internal {
        orConditionF1Commission[1] = 0;
        orConditionF1Commission[2] = 0;
        orConditionF1Commission[3] = 500;
        orConditionF1Commission[4] = 1000;
        orConditionF1Commission[5] = 2000;
        orConditionF1Commission[6] = 3000;
        orConditionF1Commission[7] = 4000;
        orConditionF1Commission[8] = 5000;
    }

    function getCommissionPercent(uint8 _level) external view returns (uint16) {
        return commissionPercent[_level];
    }

    function setCommissionPercent(uint8 _level, uint16 _percent) external onlyOwner {
        commissionPercent[_level] = _percent;
    }

    function getConditionF1Commission(uint8 _level) external view returns (uint8) {
        return conditionF1Commission[_level];
    }

    function setConditionF1Commission(uint8 _level, uint8 _value) external onlyOwner {
        conditionF1Commission[_level] = _value;
    }

    function getOrConditionF1Commission(uint8 _level) external view returns (uint16) {
        return orConditionF1Commission[_level];
    }

    function setOrConditionF1Commission(uint8 _level, uint16 _value) external onlyOwner {
        orConditionF1Commission[_level] = _value;
    }

    function setMaxDayDistributionCommissionEarn(uint256 _value) external onlyOwner {
        require(_value > 0, "DISTRIBUTE COMMISSION: INVALID VALUE");
        maxDayDistributionCommissionEarn = _value;
    }

    function setMaxNumberDistributionCommission(uint256 _value) external onlyOwner {
        require(_value >= 100, "DISTRIBUTE COMMISSION: INVALID VALUE");
        maxNumberDistributionCommission = _value;
    }

    function setMarketplaceContract(address _marketplaceAddress) external onlyOwner {
        require(_marketplaceAddress != address(0), "DISTRIBUTE COMMISSION: INVALID MARKETPLACE ADDRESS");
        marketplaceContract = _marketplaceAddress;
    }

    function setOracleContract(address _oracleContract) external onlyOwner {
        require(_oracleContract != address(0), "DISTRIBUTE COMMISSION: INVALID ORACLE ADDRESS");
        oracleContract = _oracleContract;
    }

    function setValueBuyAddress(address _wallet, uint256 _totalValue, uint256 timestamp) external {
        require(
            marketplaceContract != address(0) && msg.sender == marketplaceContract,
            "NFT: INVALID CALLER TO SET VALUE BUY DATA"
        );
        StructData.InfoBuyData memory item;
        item.timeBuy = timestamp;
        item.valueUsd = _totalValue;
        nftBuyByTimestamp[_wallet].childList.push(item);
    }

    function getNftBuyByTimestamp(
        address _wallet
    ) external view returns (StructData.InfoBuyData memory) {
        return nftBuyByTimestamp[_wallet].childList[0];
    }

    function calculateEarnMoney(
        uint256 _valueUsd,
        uint16 percent,
        uint256 timeClaim
    ) internal view returns (uint256) {
        uint256 valueClaim = _valueUsd * percent * timeClaim / (maxDayDistributionCommissionEarn * 100 * 100) / (60 * 60 * 24);
        return valueClaim;
    }

    function getClaimDistributeByAddress(address _wallet) external view returns (uint256) {
        uint256 realMaxCommission = getRealMaxCommission(_wallet);
        uint256 maxValueCommission = IMarketplace(marketplaceContract).getMaxCommissionByAddressInUsd(_wallet);
        if (realMaxCommission == 0) {
            return 0;
        }
        uint256 nftCommissionEarned = IMarketplace(marketplaceContract).getNftCommissionEarnedForAccount(_wallet);
        uint256 nftStakeCommissionEarned = IMarketplace(marketplaceContract).getTotalCommissionStakeByAddressInUsd(_wallet);
        uint256 distributeCommissionEarned = IMarketplace(marketplaceContract).getNftDistributeCommissionEarnedForAccount(_wallet);
        uint256 totalReceived = nftCommissionEarned + nftStakeCommissionEarned + distributeCommissionEarned;
        uint256 canReceive = maxValueCommission - nftCommissionEarned - nftStakeCommissionEarned;
        if (realMaxCommission > canReceive) {
            realMaxCommission = canReceive;
        }
        uint256 maxReceive = realMaxCommission - distributeCommissionEarned;
        if (totalReceived >= maxValueCommission) {
            return 0;
        }
        if (distributeCommissionEarned >= realMaxCommission) {
            return 0;
        }
        address[] memory allF1s = IMarketplace(marketplaceContract).getF1ListForAccount(_wallet);
        uint countF1Meaning = getCountF1BuyMin(allF1s);
        uint256 total = getTotalClaim(allF1s, _wallet, countF1Meaning);
        uint256 totalCanReceive = total - distributeCommissionEarned;
        uint256 realReceive = totalCanReceive;
        if (totalCanReceive > maxReceive) {
            realReceive = maxReceive;
        }
        return realReceive;
    }

    function getF1Next(address[] memory allF1s) internal view returns (address[] memory)  {
        uint256 totalFNext = 0;
        address[] memory allF1Result;
        for (uint i = 0; i < allF1s.length; i++) {
            address[] memory allF1Index = IMarketplace(marketplaceContract).getF1ListForAccount(allF1s[i]);
            totalFNext = totalFNext + allF1Index.length;
        }
        if (totalFNext == 0) {
            allF1Result = new address[](0);
        } else {
            uint256 counter = 0;
            address[] memory allFNext = new address[](totalFNext);
            for (uint i = 0; i < allF1s.length; i++) {
                address[] memory allF1Index = IMarketplace(marketplaceContract).getF1ListForAccount(allF1s[i]);
                for (uint j = 0; j < allF1Index.length; j++) {
                    allFNext[counter] = allF1Index[j];
                    counter++;
                }
            }
            allF1Result = allFNext;
        }
        return allF1Result;
    }

    function getCountF1BuyMin(address[] memory allF1s) internal view returns (uint256) {
        uint countF1Meaning = 0;
        for (uint i = 0; i < allF1s.length; i++) {
            bool isCheckBuyMin = IMarketplace(marketplaceContract).checkIsBuyMinValuePackage(allF1s[i]);
            if (isCheckBuyMin) {
                countF1Meaning++;
            }
        }
        return countF1Meaning;
    }

    function getTotalClaim(address[] memory allF1s, address _wallet, uint countF1Meaning) internal view returns (uint256) {
        uint8 index = 1;
        uint256 total = 0;
        uint256 timeCheck = block.timestamp;
        uint256 totalSale = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_wallet);
        while (allF1s.length != 0 && index <= totalLevelEarn) {
            uint256 totalClaimByLevel = getClaimableData(allF1s, timeCheck, index, totalSale, countF1Meaning);
            total = total + totalClaimByLevel;
            address[] memory addressNext = getF1Next(allF1s);
            allF1s = addressNext;
            index++;
        }
        return total;
    }

    function getRealMaxCommission(address _wallet) internal view returns (uint256)  {
        uint256 currentNftSaleValue = IMarketplace(marketplaceContract).getNftSaleValueForAccountInUsdDecimal(_wallet);
        uint256 maxCommission = currentNftSaleValue * maxNumberDistributionCommission / 100;
        uint256 realMaxCommission = maxCommission;
        uint256 maxValueDistributionCommission = IMarketplace(marketplaceContract).getMaxCommissionByAddressInUsd(_wallet);
        if (realMaxCommission == 0) {
            realMaxCommission = maxValueDistributionCommission;
        }
        return realMaxCommission;
    }

    function getClaimableData(
        address[] memory allF1s,
        uint256 _timeCheck,
        uint8 _level,
        uint256 _totalBuy,
        uint _countF1Meaning
    ) internal view returns (uint256) {
        uint256 total = 0;
        uint256 timeCheck = _timeCheck;
        uint256 totalBuy = _totalBuy;
        uint256 countF1Meaning = _countF1Meaning;
        uint8 level = _level;
        for (uint i = 0; i < allF1s.length; i++) {
            StructData.InfoBuyData[] memory listBuyNft = nftBuyByTimestamp[allF1s[i]].childList;
            if (listBuyNft.length == 0) {
                continue;
            }
            uint256 totalF1 = 0;
            for (uint j = 0; j < listBuyNft.length; j++) {
                uint256 timeBuy = listBuyNft[j].timeBuy;
                uint256 valueUsd = listBuyNft[j].valueUsd;
                uint256 endCheckTime = timeBuy + maxDayDistributionCommissionEarn * 24 * 60 * 60;
                uint256 timeClaim = (timeCheck - timeBuy);
                if (timeCheck <= endCheckTime) {
                    uint16 percent = commissionPercent[level];
                    uint8 condition1 = conditionF1Commission[level];
                    uint256 condition2 = orConditionF1Commission[level] * (10 ** FitZenERC20(currency).decimals());
                    if (condition1 == 0 || condition2 == 0) {
                        uint256 claimUsd = calculateEarnMoney(valueUsd, percent, timeClaim);
                        totalF1 = totalF1 + claimUsd;
                    } else {
                        if (totalBuy >= condition2 || countF1Meaning >= condition1) {
                            uint256 claimUsd = calculateEarnMoney(valueUsd, percent, timeClaim);
                            totalF1 = totalF1 + claimUsd;
                        }
                    }
                }
            }
            total = total + totalF1;
        }
        return total;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IMarketplace {
    event Buy(address seller, address buyer, uint256 nftId, address refAddress);

    event Sell(address seller, address buyer, uint256 nftId);

    event PayCommission(address buyer, address refAccount, uint256 commissionAmount);

    event ErrorLog(bytes message);

    function buyByCurrency(uint256[] memory _nftIds, address _refAddress) external;

    function buyByToken(uint256[] memory _nftIds, address _refAddress) external;

    function sell(uint256[] memory _nftIds) external;

    function setSaleWalletAddress(address _saleAddress) external;

    function setStakingContractAddress(address _stakingAddress) external;

    function setRankingContractAddress(address _stakingAddress) external;

    function setDistributeWalletAddress(address _distributeAddress) external;

    function setNetworkWalletAddress(address _networkWallet) external;

    function setDiscountPercent(uint8 _discount) external;

    function setMaxNumberStakeValue(uint8 _percent) external;

    function setDefaultMaxCommission(uint256 _value) external;

    function setSaleStrategyOnlyCurrencyStart(uint256 _newSaleStart) external;

    function setSaleStrategyOnlyCurrencyEnd(uint256 _newSaleEnd) external;

    function setSalePercent(uint256 _newSalePercent) external;

    function setOracleAddress(address _oracleAddress) external;

    function setNftAddress(address _nftAddress) external;

    function allowBuyNftByCurrency(bool _activePayByCurrency) external;

    function allowBuyNftByToken(bool _activePayByToken) external;

    function setToken(address _address) external;

    function allowSellNft(bool _activeSellNft) external;

    function setTypePayCommission(uint256 _typePayCommission) external;

    function claimDistributeByAddress() external;

    function getActiveMemberForAccount(address _wallet) external returns (uint256);

    function checkIsBuyMinValuePackage(address _wallet) external view returns (bool);

    function getClaimDistributeByAddress(address _wallet) external returns (uint256);

    function getTotalCommission(address _wallet) external view returns (uint256);

    function getReferredNftValueForAccount(address _wallet) external returns (uint256);

    function getNftCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftDistributeCommissionEarnedForAccount(address _wallet) external view returns (uint256);

    function getNftDistributeCommissionEarnedByTokenForAccount(address _wallet) external view returns (uint256);

    function getNftSaleValueForAccountInUsdDecimal(address _wallet) external view returns (uint256);

    function getTotalCommissionStakeByAddressInUsd(address _wallet) external view returns (uint256);

    function getMaxCommissionByAddressInUsd(address _wallet) external view returns (uint256);

    function updateCommissionStakeValueData(address _user, uint256 _valueInUsdWithDecimal) external;

    function updateReferralData(address _user, address _refAddress) external;

    function getReferralAccountForAccount(address _user) external view returns (address);

    function getReferralAccountForAccountExternal(address _user) external view returns (address);

    function getF1ListForAccount(address _wallet) external view returns (address[] memory);

    function getTeamNftSaleValueForAccountInUsdDecimal(address _wallet) external returns (uint256);

    function possibleChangeReferralData(address _wallet) external returns (bool);

    function lockedReferralDataForAccount(address _user) external;

    function setSystemWallet(address _newSystemWallet) external;

    function isBuyByToken(uint256 _nftId) external view returns (bool);

    function setCurrencyAddress(address _currency) external;

    function withdrawTokenEmergency(address _token, uint256 _amount) external;

    function withdrawTokenEmergencyFrom(address _from, address _to, address _currency, uint256 _amount) external;

    function tranferNftEmergency(address _receiver, uint256 _nftId) external;

    function tranferMultiNftsEmergency(
        address[] memory _receivers,
        uint256[] memory _nftIds
    ) external;

    function checkValidRefCodeAdvance(address _user, address _refAddress) external returns (bool);

    function getCommissionPercent(uint8 _level) external returns (uint16);

    function setCommissionPercent(uint8 _level, uint16 _percent) external;

    function getConditionF1Commission(uint8 _level) external returns (uint8);

    function setConditionF1Commission(uint8 _level, uint8 _value) external;

    function setIsEnableBurnToken(bool _isEnableBurnToken) external;

    function setBurnAddress(address _burnAddress) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../swap/InternalSwap.sol";

interface IPancakePair {
    function getReserves() external view returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 _blockTimestampLast
    );
}

contract Oracle is Ownable {
    uint256 private minTokenAmount = 0;
    uint256 private maxTokenAmount = 0;

    address public pairAddress;
    address public stableToken;
    address public tokenAddress;
    address public swapAddress;
    uint8 private typeConvert = 1; // 0:average 1: only swap 2: only pancake

    constructor(address _swapAddress, address _stableToken, address _tokenAddress) {
        swapAddress = _swapAddress;
        stableToken = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function convertInternalSwap (uint256 _value, bool toToken) public view returns (uint256) {
        uint256 usdtAmount = InternalSwap(swapAddress).getUsdtAmount();
        uint256 tokenAmount = InternalSwap(swapAddress).getTokenAmount();
        if (tokenAmount > 0 && usdtAmount > 0) {
            uint256 amountTokenDecimal;
            if (toToken) {
                amountTokenDecimal = (_value * tokenAmount) / usdtAmount;
            } else {
                amountTokenDecimal = (_value * usdtAmount) / tokenAmount;
            }

            return amountTokenDecimal;
        }
        return 0;
    }

    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) public view returns (uint256) {
        uint256 tokenInternalSwap = convertInternalSwap(_balanceUsdDecimal, true);
        uint256 tokenPairConvert;
        if (pairAddress != address(0)) {
            (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pairAddress).getReserves();
            (uint256 _tokenBalance, uint256 _stableBalance) = address(tokenAddress) < address(stableToken) ? (_reserve0, _reserve1) : (_reserve1, _reserve0);

            uint256 _minTokenAmount = (_balanceUsdDecimal * minTokenAmount) / 1000000;
            uint256 _maxTokenAmount = (_balanceUsdDecimal * maxTokenAmount) / 1000000;
            uint256 _tokenAmount = (_balanceUsdDecimal * _tokenBalance) / _stableBalance;

            if (_tokenAmount < _minTokenAmount) {
                tokenPairConvert = _minTokenAmount;
            }

            if (_tokenAmount > _maxTokenAmount) {
                tokenPairConvert = _maxTokenAmount;
            }

            tokenPairConvert = _tokenAmount;
        }
        if (typeConvert == 1) {
            return tokenInternalSwap;
        } else if (typeConvert == 2) {
            return tokenPairConvert;
        } else {
            if (tokenPairConvert == 0 || tokenInternalSwap == 0) {
                return tokenPairConvert + tokenInternalSwap;
            } else {
                return (tokenPairConvert + tokenInternalSwap) / 2;
            }
        }
    }

    function setPairAddress(address _address) external onlyOwner {
        require(_address != address(0), "ORACLE: INVALID PAIR ADDRESS");
        pairAddress = _address;
    }

    function setSwapAddress(address _address) external onlyOwner {
        require(_address != address(0), "ORACLE: INVALID SWAP ADDRESS");
        swapAddress = _address;
    }

    function setTypeConvertPrice(uint8 _type) external onlyOwner {
        require(_type <= 2, "ORACLE: INVALID TYPE CONVERT");
        typeConvert = _type;
    }

    function getTypeConvert() external view returns (uint8) {
        return typeConvert;
    }

    function setMinTokenAmount(uint256 _tokenAmount) external onlyOwner {
        minTokenAmount = _tokenAmount;
    }

    function setMaxTokenAmount(uint256 _tokenAmount) external onlyOwner {
        maxTokenAmount = _tokenAmount;
    }

    /**
     * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
     * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public onlyOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../token/FitZenERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../data/StructData.sol";

contract InternalSwap is Ownable {
    using SafeMath for uint256;
    uint256 private usdtAmount = 0;
    uint256 private tokenAmount = 0;
    address public currency;
    address public tokenAddress;
    uint8 private typeSwap = 0; //0: all, 1: usdt -> token only, 2: token -> usdt only

    address private _taxAddress;
    uint256 private _taxSellFee = 0;
    uint256 private _taxBuyFee = 0;
    uint8 private limitDay = 1;
    uint256 private limitValue = 0;
    mapping(address => bool) private _addressSellHasTaxFee;
    mapping(address => bool) private _addressBuyHasTaxFee;
    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;
    mapping(address => StructData.ListSwapData) addressBuyTokenData;
    mapping(address => StructData.ListSwapData) addressSellTokenData;
    bool private reentrancyGuardForBuying = false;
    bool private reentrancyGuardForSelling = false;

    event ChangeRate(uint256 _usdtAmount, uint256 _tokenAmount, uint256 _time);
    constructor(address _stableToken, address _tokenAddress) {
        currency = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function getLimitDay() external view returns (uint8) {
        return limitDay;
    }

    function getUsdtAmount() external view returns (uint256) {
        return usdtAmount;
    }

    function getTokenAmount() external view returns (uint256) {
        return tokenAmount;
    }

    function getLimitValue() external view returns (uint256) {
        return limitValue;
    }

    function setLimitDay(uint8 _limitDay) external onlyOwner {
        limitDay = _limitDay;
    }

    function setLimitValue(uint256 _valueToLimit) external onlyOwner {
        limitValue = _valueToLimit;
    }

    function getTaxSellFee() external view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() external view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() external view returns (address) {
        return _taxAddress;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) external onlyOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) external onlyOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress_) external onlyOwner {
        _taxAddress = taxAddress_;
    }

    function setAddressSellHasTaxFee(address account, bool hasFee) external onlyOwner {
        _addressSellHasTaxFee[account] = hasFee;
    }

    function isAddressSellHasTaxFee(address account) external view returns (bool) {
        return _addressSellHasTaxFee[account];
    }

    function setAddressBuyHasTaxFee(address account, bool hasFee) external onlyOwner {
        _addressBuyHasTaxFee[account] = hasFee;
    }

    function isAddressBuyHasTaxFee(address account) external view returns (bool) {
        return _addressBuyHasTaxFee[account];
    }

    function setAddressBuyExcludeTaxFee(address account, bool hasFee) external onlyOwner {
        _addressBuyExcludeTaxFee[account] = hasFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool hasFee) external onlyOwner {
        _addressSellExcludeHasTaxFee[account] = hasFee;
    }

    function calculateSellTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxSellFee).div(10000);
    }

    function calculateBuyTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxBuyFee).div(10000);
    }

    function setPriceData(uint256 _usdtAmount, uint256 _tokenAmount) external onlyOwner {
        usdtAmount = _usdtAmount;
        tokenAmount = _tokenAmount;
        emit ChangeRate(_usdtAmount, _tokenAmount, block.timestamp);
    }

    function getTypeSwap() external view returns (uint8) {
        return typeSwap;
    }

    function setPriceType(uint8 _type) external onlyOwner {
        require(
           _type <= 2,
            "SWAP: INVALID TYPE SWAP (0, 1, 2)"
        );
        typeSwap = _type;
    }

    function updateBuyTokenData(address _wallet, uint256 _value, uint256 _time) internal {
        StructData.InfoSwapData memory item;
        item.timeSwap = _time;
        item.valueSwap = _value;
        addressBuyTokenData[_wallet].childList.push(item);
    }

    function updateSellTokenData(address _wallet, uint256 _value, uint256 _time) internal {
        StructData.InfoSwapData memory item;
        item.timeSwap = _time;
        item.valueSwap = _value;
        addressSellTokenData[_wallet].childList.push(item);
    }

    function checkCanSellToken(address _wallet, uint256 _value) internal view returns (bool) {
        if (limitValue == 0 || limitDay == 0) {
            return true;
        }
        StructData.InfoSwapData[] memory listSellToken = addressSellTokenData[_wallet].childList;
        bool canSell = true;
        uint256 today = block.timestamp;
        uint256 maxValue = limitValue * (10 ** FitZenERC20(tokenAddress).decimals());
        uint256 timeCheck = block.timestamp - limitDay * 24 * 60 * 60;
        uint256 totalSellValue;
        for (uint i = 0; i < listSellToken.length; i++) {
            uint256 timeBuy = listSellToken[i].timeSwap;
            uint256 valueSwap = listSellToken[i].valueSwap;
            if (timeBuy >= timeCheck && timeBuy <= today) {
                totalSellValue = totalSellValue + valueSwap;
            }
        }
        uint256 valueAfterSell = totalSellValue + _value;
        if (valueAfterSell > maxValue) {
            canSell = false;
        }
        return canSell;
    }

    function buyToken(uint256 _values) external {
        require(
            typeSwap == 1 || typeSwap == 0,
            "SWAP: CANNOT BUY TOKEN NOW"
        );
        require(_values > 0, "SWAP: INVALID VALUE");
        require(!reentrancyGuardForBuying, "SWAP: REENTRANCY DETECTED");
        reentrancyGuardForBuying = true;
        uint256 amountTokenDecimal = 0;
        uint256 amountBuyFee = 0;
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[msg.sender];
        uint256 usdtValue = _values;
        if (tokenAmount > 0 && usdtAmount > 0) {
            amountTokenDecimal = (usdtValue * tokenAmount) / usdtAmount;
            if (_taxBuyFee != 0 && !_isExcludeUserBuy) {
                amountBuyFee = calculateBuyTaxFee(amountTokenDecimal);
                amountTokenDecimal = amountTokenDecimal - amountBuyFee;
            }
        }
        if (amountTokenDecimal != 0) {
            require(
                FitZenERC20(currency).balanceOf(msg.sender) >= usdtValue,
                "SWAP: NOT ENOUGH BALANCE CURRENCY TO BUY TOKEN"
            );
            require(
                FitZenERC20(currency).allowance(msg.sender, address(this)) >= usdtValue,
                "SWAP: MUST APPROVE FIRST"
            );
            require(
                FitZenERC20(currency).transferFrom(
                    msg.sender,
                    address(this),
                    usdtValue
                ),
                "SWAP: FAIL TO SWAP"
            );
            require(
                FitZenERC20(tokenAddress).transfer(
                    msg.sender,
                    amountTokenDecimal
                ),
                "SWAP: FAIL TO SWAP"
            );
            if (amountBuyFee != 0) {
                require(
                    FitZenERC20(tokenAddress).transfer(
                        _taxAddress,
                        amountBuyFee
                    ),
                    "SWAP: FAIL TO SWAP"
                );
            }
            updateBuyTokenData(msg.sender, amountTokenDecimal, block.timestamp);
        }
        reentrancyGuardForBuying = false;
    }

    function sellToken(uint256 _values) external {
        require(
            typeSwap == 2 || typeSwap == 0,
            "SWAP: CANNOT SELL TOKEN NOW"
        );
        require(_values > 0, "SWAP: INVALID VALUE");
        require(!reentrancyGuardForSelling, "SWAP: REENTRANCY DETECTED");
        reentrancyGuardForSelling = true;
        uint256 amountUsdtDecimal = 0;
        uint256 amountSellFee = 0;
        uint256 tokenValue = _values;
        bool checkUserCanSellToken = checkCanSellToken(msg.sender, tokenValue);
        require(checkUserCanSellToken, "SWAP: MAXIMUM SWAP TODAY");
        uint256 realTokenValue = tokenValue;
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[msg.sender];
        if (_taxSellFee != 0 && !_isExcludeUserBuy) {
            amountSellFee = calculateSellTaxFee(tokenValue);
            realTokenValue = realTokenValue - amountSellFee;
        }
        if (tokenAmount > 0 && usdtAmount > 0) {
            amountUsdtDecimal = (realTokenValue * usdtAmount) / tokenAmount;
        }
        if (amountUsdtDecimal != 0) {
            require(
                FitZenERC20(tokenAddress).balanceOf(msg.sender) >= tokenValue,
                "SWAP: NOT ENOUGH BALANCE TOKEN TO SELL"
            );
            require(
                FitZenERC20(tokenAddress).allowance(msg.sender, address(this)) >= tokenValue,
                "SWAP: MUST APPROVE FIRST"
            );
            require(
                FitZenERC20(tokenAddress).transferFrom(
                    msg.sender,
                    address(this),
                    tokenValue
                ),
                "SWAP: FAIL TO SWAP"
            );
            if (amountSellFee != 0) {
                require(
                    FitZenERC20(tokenAddress).transfer(
                        _taxAddress,
                        amountSellFee
                    ),
                    "SWAP: FAIL TO SWAP"
                );
            }
            require(
                FitZenERC20(currency).transfer(
                    msg.sender,
                    amountUsdtDecimal
                ),
                "SWAP: FAIL TO SWAP"
            );
            updateSellTokenData(msg.sender, tokenValue, block.timestamp);
        }
        reentrancyGuardForSelling = false;
    }
    /**
        * @dev Recover lost bnb and send it to the contract owner
     */
    function recoverLostBNB() public onlyOwner {
        address payable recipient = payable(msg.sender);
        recipient.transfer(address(this).balance);
    }

    /**
        * @dev withdraw some token balance from contract to owner account
     */
    function withdrawTokenEmergency(address _token, uint256 _amount) public onlyOwner {
        require(_amount > 0, "INVALID AMOUNT");
        require(IERC20(_token).transfer(msg.sender, _amount), "CANNOT WITHDRAW TOKEN");
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/FitZenERC20.sol.sol/FitZenERC20.sol.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
 * conventional and does not conflict with the expectations of FitZenERC20.sol.sol
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
contract FitZenERC20 is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _taxAddress;
    uint256 private _taxSellFee;
    uint256 private _taxBuyFee;
    mapping(address => bool) private _addressSellHasTaxFee;
    mapping(address => bool) private _addressBuyHasTaxFee;
    mapping(address => bool) private _addressBuyExcludeTaxFee;
    mapping(address => bool) private _addressSellExcludeHasTaxFee;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address taxAddress_,
        uint16 taxFeeBps_
    )
    {
        _name = name_;
        _symbol = symbol_;
        _taxSellFee = taxFeeBps_;
        _taxAddress = taxAddress_;
        _taxBuyFee = 0;
    }

    function getTaxSellFee() public view returns (uint256) {
        return _taxSellFee;
    }

    function getTaxBuyFee() public view returns (uint256) {
        return _taxBuyFee;
    }

    function getTaxAddress() public view returns (address) {
        return _taxAddress;
    }

    function setTaxSellFeePercent(uint256 taxFeeBps) public onlyOwner {
        _taxSellFee = taxFeeBps;
    }

    function setTaxBuyFeePercent(uint256 taxFeeBps) public onlyOwner {
        _taxBuyFee = taxFeeBps;
    }

    function setTaxAddress(address taxAddress_) public onlyOwner {
        _taxAddress = taxAddress_;
    }

    function setAddressSellHasTaxFee(address account, bool hasFee) public onlyOwner {
        _addressSellHasTaxFee[account] = hasFee;
    }

    function isAddressSellHasTaxFee(address account) public view returns (bool) {
        return _addressSellHasTaxFee[account];
    }

    function setAddressBuyHasTaxFee(address account, bool hasFee) public onlyOwner {
        _addressBuyHasTaxFee[account] = hasFee;
    }

    function isAddressBuyHasTaxFee(address account) public view returns (bool) {
        return _addressBuyHasTaxFee[account];
    }

    function setAddressBuyExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        _addressBuyExcludeTaxFee[account] = hasFee;
    }

    function setAddressSellExcludeTaxFee(address account, bool hasFee) public onlyOwner {
        _addressSellExcludeHasTaxFee[account] = hasFee;
    }

    function calculateSellTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxSellFee).div(10000);
    }

    function calculateBuyTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxBuyFee).div(10000);
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
     * required by the EIP. See the note at the beginning of {FitZenERC20.sol}.
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
        uint256 amountToReceive = amount;
        uint256 amountToTax = 0;
        bool _isHasTaxSellFeeTransfer = _addressSellHasTaxFee[to];
        bool _isExcludeUserSell = _addressSellExcludeHasTaxFee[from];
        bool _isHasTaxBuyFeeTransfer = _addressBuyHasTaxFee[from];
        bool _isExcludeUserBuy = _addressBuyExcludeTaxFee[to];
        if (_taxAddress != address(0) && _isHasTaxSellFeeTransfer && _taxSellFee != 0 && !_isExcludeUserSell) {
            uint256 amountSellFee = calculateSellTaxFee(amount);
            amountToReceive = amount - amountSellFee;
            amountToTax = amountToTax + amountSellFee;
        }
        if (_taxAddress != address(0) && _isHasTaxBuyFeeTransfer && _taxBuyFee != 0 && !_isExcludeUserBuy ) {
            uint256 amountBuyFee = calculateBuyTaxFee(amount);
            amountToReceive = amount - amountBuyFee;
            amountToTax = amountToTax + amountBuyFee;
        }
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[_taxAddress] += amountToTax; //increase tax Address tax Fee
            _balances[to] += amountToReceive;
        }
        emit Transfer(from, to, amountToReceive);
        if (amountToTax != 0) {
            emit Transfer(from, _taxAddress, amountToTax);
        }
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
