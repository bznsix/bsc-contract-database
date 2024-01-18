// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: UNLICENSED
// Powered by Agora

pragma solidity ^0.8.21;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IAgoraERC20Config} from "./IAgoraERC20Config.sol";

interface IAgoraERC20 is IAgoraERC20Config, IERC20, IERC20Metadata {
    function addLiquidity() external payable returns (address);

    event LiquidityLocked(uint256 lpTokens, uint256 daysLocked);
    event TaxesLowered(
        uint256 previousBuyTax,
        uint256 previousSellTax,
        uint256 newBuyTax,
        uint256 newSellTax
    );
    event LPTaxLowered(
        uint256 previousBuyTax,
        uint256 previousSellTax,
        uint256 newBuyTax,
        uint256 newSellTax
    );
    event LiquidityAdded(
        uint256 tokensSupplied,
        uint256 ethSupplied,
        uint256 lpTokensIssued
    );
    event LimitsRaised(
        uint128 oldBuyLimit,
        uint128 oldSellLimit,
        uint128 oldMaxWallet,
        uint128 newBuyLimit,
        uint128 newSellLimit,
        uint128 newMaxWallet
    );
    event LiquidityBurned(uint256 liquidityBurned);
    event LiquiditySupplied(uint256 tokens, uint256 eth);
    event ExternalCallError(uint256);
}
// SPDX-License-Identifier: UNLICENSED
// Powered by Agora
pragma solidity ^0.8.21;

interface IAgoraERC20Config {

    /**
     * @dev information used to construct the token.
     */
    struct TokenConstructorParameters {
        bytes baseParameters;
        bytes taxParameters;
        bytes tokenLPInfo;
    }

    /**
     * @dev Basic info of the token
     */
    struct TokenInfoParameters {
        string name;
        string symbol;
        bool autoCreateLiquidity;
        uint256 maxSupply;
        address tokensRecepient;
        uint256 maxTokensWallet;
        bool payInTax;
        bool protectLiquidity;
    }

    /**
     *  @dev This struct express the taxes on per 1000, to allow percetanges between 0 and 1. 
     */
    struct TaxParameters {
        uint256 buyTax;
        uint256 sellTax;
        uint256 lpBuyTax;
        uint256 lpSellTax;
        uint256 maxTxBuy;
        uint256 maxTxSell;
        address taxSwapRecepient;
    }

    /**
     * @dev Liquidity pool supply information
     */
    struct TokenLpInfo {
        uint256 lpTokensupply;
        uint256 ethForSupply;
        bool burnLP;
        uint256 lockFee;
        uint256 lpLockUpInDays;
    }
}// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IAuthErrors} from "./Errors.sol";
import {Revertible} from "../Utils/Revertible.sol";

contract Authoritative is IAuthErrors, Revertible {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private Admins;
    address public SuperAdmin;

    event SuperAdminTransferred(address oldSuperAdmin, address newSuperAdmin);
    event PlatformAdminAdded(address platformAdmin);
    event PlatformAdminRevoked(address platformAdmin);

    modifier onlySuperAdmin() {
        if (!IsSuperAdmin(msg.sender)) {
            revert CallerIsNotSuperAdmin(msg.sender);
        }
        _;
    }

    modifier onlyPlatformAdmin() {
        if (!IsPlatformAdmin(msg.sender))
            revert CallerIsNotPlatformAdmin(msg.sender);
        _;
    }

    function IsSuperAdmin(address addressToCheck) public view returns (bool) {
        return (SuperAdmin == addressToCheck);
    }

    function IsPlatformAdmin(
        address addressToCheck
    ) public view returns (bool) {
        return (Admins.contains(addressToCheck));
    }

    function GrantPlatformAdmin(
        address newPlatformAdmin_
    ) public onlySuperAdmin {
        if (newPlatformAdmin_ == address(0)) {
            Revert(PlatformAdminCannotBeAddressZero.selector);
        }
        // Add this to the enumerated list:
        Admins.add(newPlatformAdmin_);
        emit PlatformAdminAdded(newPlatformAdmin_);
    }

    function RevokePlatformAdmin(address oldAdmin) public onlySuperAdmin {
        Admins.remove(oldAdmin);
        emit PlatformAdminRevoked(oldAdmin);
    }

    function TransferSuperAdmin(address newSuperAdmin) public onlySuperAdmin {
        address oldSuperAdmin = SuperAdmin;
        SuperAdmin = newSuperAdmin;
        emit SuperAdminTransferred(oldSuperAdmin, newSuperAdmin);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

interface IAuthErrors {
    error CallerIsNotSuperAdmin(address caller);
    error CallerIsNotPlatformAdmin(address caller);
    error PlatformAdminCannotBeAddressZero();
}// SPDX-License-Identifier: BUSL-1.1
// Starship Contract Factory
// Powered by Agora

pragma solidity 0.8.21;

contract Nukable {

    bool internal IsNuked;
    event Nuked();

    modifier IfNotNuked() {
        if(IsNuked) {
            revert("This contract has been nuked and it is not operational");
        }
        _;
    }

    function Nuke() internal {
        IsNuked = true;
        emit Nuked();
    }
    
}// SPDX-License-Identifier: MIT
// Powered by Agora

pragma solidity 0.8.21;

abstract contract Revertible {
    function Revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

interface IFactoryErrors {
    error TreasuryAddressCanNotBeNull();
    error RouterAddressCanNotBeNull();
    error TransactionUnderpriced();
}// SPDX-License-Identifier: UNLICENSED
// Powered by Agora

pragma solidity ^0.8.21;


interface IStarShipDeployer {
    error DeploymentError();
    error InvalidID();

    function DeployNewToken(
        bytes32 salt,
        bytes32 hash,
        bytes memory arguments
    ) external payable returns (address erc20Address);
}
// SPDX-License-Identifier: UNLICENSED
// Powered by Agora

pragma solidity ^0.8.21;

import {IAgoraERC20Config} from "../../Agora/IAgoraERC20Config.sol";

interface IStarShipFactory  is IAgoraERC20Config {

}// SPDX-License-Identifier: UNLICENSED
// Starship Contract Factory
// Powered by Agora

pragma solidity 0.8.21;

import {IAgoraERC20} from "../Agora/IAgoraERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IStarShipDeployer} from "./Interfaces/IStarShipDeployer.sol";
import {IStarShipFactory} from "./Interfaces/IStarShipFactory.sol";
import {IFactoryErrors} from "./IFactoryErrors.sol";
import {Nukable} from "../Agora/Security/Nukable.sol";
import {Authoritative} from "../Agora/Security/Authoritative.sol";
import {Revertible} from "../Agora/Utils/Revertible.sol";

/**
 * @dev Starship contract factory
 */
contract StarShipFactory is
    Context,
    Nukable,
    Authoritative,
    IStarShipFactory,
    IFactoryErrors
{
    uint256 internal constant CALL_GAS_LIMIT = 50000;

    // The contract implementing UniswapV2 protocol
    address public immutable uniswapRouterV2InterfaceAddress;

    mapping(address => address) _lastTokens;

    // Contract to deploy tokens
    address payable public deployerAddress;

    // The address where all the eth collected by the service will end up in.
    address public treasuryAddress;

    // LP locker
    address public locker;

    // The cost in ether to deploy a token
    uint256 public deploymentFee = 0.1 ether;

    uint256 public lockFee = 0.01 ether;

    /**
     *
     * @param superAdmin The supreme ruler of the factory, can do everything
     * @param admins The list of wallets that can perofrm operations with elevated privileges
     * @param treasury Where the collection of taxes will go
     */
    constructor(
        address superAdmin,
        address[] memory admins,
        address treasury,
        address tokenLocker,
        address uniswapRouter
    ) {
        SuperAdmin = superAdmin;
        GrantPlatformAdmin(superAdmin);
        for (uint256 i = 0; i < admins.length; ) {
            GrantPlatformAdmin(admins[i]);
            unchecked {
                i++;
            }
        }

        if (treasury == address(0)) {
            Revert(TreasuryAddressCanNotBeNull.selector);
        }

        if (uniswapRouter == address(0)) {
            Revert(RouterAddressCanNotBeNull.selector);
        }
        uniswapRouterV2InterfaceAddress = uniswapRouter;
        treasuryAddress = treasury;
        locker = tokenLocker;
    }

    function setTreasury(address newAddress) external onlySuperAdmin{
        treasuryAddress = newAddress;
    }

    function changeFee(uint256 newFee) external onlySuperAdmin {
        deploymentFee = newFee;
    }

    function withdrawEth() external onlySuperAdmin {
        uint256 gas = (CALL_GAS_LIMIT == 0 || CALL_GAS_LIMIT > gasleft())
            ? gasleft()
            : CALL_GAS_LIMIT;

        bool success;
        // We limit the gas passed so that a called address cannot cause a block out of gas error:
        (success, ) = SuperAdmin.call{value: address(this).balance, gas: gas}(
            ""
        );
    }

    function SetDeployerAddress(
        address newDeployerAddress
    ) external onlySuperAdmin {
        deployerAddress = payable(newDeployerAddress);
    }

    function GetLastCreatedToken() public view returns (address) {
        return _lastTokens[_msgSender()];
    }

    function NukeFactory() external onlySuperAdmin {
        Nuke();
    }

    function CreateNewERC20(
        bytes32 salt,
        string calldata deploymentID,
        TokenConstructorParameters calldata tokenConfig
    ) external payable IfNotNuked returns (address erc20Address) {
        address[5] memory integrationAddresses = [
            _msgSender(),
            uniswapRouterV2InterfaceAddress,
            locker,
            address(this),
            treasuryAddress
        ];

        TokenLpInfo memory tokenLpInfo = abi.decode(
            tokenConfig.tokenLPInfo,
            (TokenLpInfo)
        );
        tokenLpInfo.lockFee = lockFee;

        bytes memory args = abi.encode(
            integrationAddresses,
            tokenConfig.baseParameters,
            tokenConfig.taxParameters,
            abi.encode(tokenLpInfo)
        );

        address tokenAddress = IStarShipDeployer(deployerAddress)
            .DeployNewToken(
                salt,
                keccak256(abi.encodePacked(deploymentID)),
                args
            );
        _lastTokens[_msgSender()] = tokenAddress;

        // Decoding paramets
        TokenInfoParameters memory tokenInfo = abi.decode(
            tokenConfig.baseParameters,
            (TokenInfoParameters)
        );

        if (tokenInfo.autoCreateLiquidity) {
            TokenLpInfo memory lpInfo = abi.decode(
                tokenConfig.tokenLPInfo,
                (TokenLpInfo)
            );
            _processLiquidityParams(tokenAddress, lpInfo, tokenInfo);
        }

        return tokenAddress;
    }

    function _processLiquidityParams(
        address tokenAddress,
        TokenLpInfo memory params,
        TokenInfoParameters memory configParams
    ) internal {
        uint256 totalFee = params.ethForSupply;
        uint256 totalLiquidityFee = totalFee;
        if (!configParams.payInTax) {
            totalFee += deploymentFee;
        }

        if (!params.burnLP) {
            totalFee += lockFee;
            totalLiquidityFee += lockFee;
        }

        if (msg.value < totalFee) {
            Revert(TransactionUnderpriced.selector);
        }

        IAgoraERC20(tokenAddress).addLiquidity{value: totalLiquidityFee}();
    }
}
