// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import './Interfaces/IActivePool.sol';
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";

/*
 * The Active Pool holds the BNB collateral and USDS debt (but not USDS tokens) for all active troves.
 *
 * When a trove is liquidated, it's BNB and USDS debt are transferred from the Active Pool, to either the
 * Stability Pool, the Default Pool, or both, depending on the liquidation conditions.
 *
 */
contract ActivePool is Ownable, CheckContract, IActivePool {
    using SafeMath for uint256;

    string constant public NAME = "ActivePool";

    address public borrowerOperationsAddress;
    address public troveManagerAddress;
    address public stabilityPoolAddress;
    address public defaultPoolAddress;
    uint256 internal BNB;  // deposited ether tracker
    uint256 internal USDSDebt;

    // --- Events ---

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolUSDSDebtUpdated(uint _USDSDebt);
    event ActivePoolBNBBalanceUpdated(uint _BNB);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _defaultPoolAddress
    )
        external
        onlyOwner
    {
        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_defaultPoolAddress);

        borrowerOperationsAddress = _borrowerOperationsAddress;
        troveManagerAddress = _troveManagerAddress;
        stabilityPoolAddress = _stabilityPoolAddress;
        defaultPoolAddress = _defaultPoolAddress;

        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit StabilityPoolAddressChanged(_stabilityPoolAddress);
        emit DefaultPoolAddressChanged(_defaultPoolAddress);

        _renounceOwnership();
    }

    // --- Getters for public variables. Required by IPool interface ---

    /*
    * Returns the BNB state variable.
    *
    *Not necessarily equal to the the contract's raw BNB balance - ether can be forcibly sent to contracts.
    */
    function getBNB() external view override returns (uint) {
        return BNB;
    }

    function getUSDSDebt() external view override returns (uint) {
        return USDSDebt;
    }

    // --- Pool functionality ---

    function sendBNB(address _account, uint _amount) external override {
        _requireCallerIsBOorTroveMorSP();
        BNB = BNB.sub(_amount);
        emit ActivePoolBNBBalanceUpdated(BNB);
        emit EtherSent(_account, _amount);

        (bool success, ) = _account.call{ value: _amount }("");
        require(success, "ActivePool: sending BNB failed");
    }

    function increaseUSDSDebt(uint _amount) external override {
        _requireCallerIsBOorTroveM();
        USDSDebt  = USDSDebt.add(_amount);
        ActivePoolUSDSDebtUpdated(USDSDebt);
    }

    function decreaseUSDSDebt(uint _amount) external override {
        _requireCallerIsBOorTroveMorSP();
        USDSDebt = USDSDebt.sub(_amount);
        ActivePoolUSDSDebtUpdated(USDSDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsBorrowerOperationsOrDefaultPool() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == defaultPoolAddress,
            "ActivePool: Caller is neither BO nor Default Pool");
    }

    function _requireCallerIsBOorTroveMorSP() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress ||
            msg.sender == stabilityPoolAddress,
            "ActivePool: Caller is neither BorrowerOperations nor TroveManager nor StabilityPool");
    }

    function _requireCallerIsBOorTroveM() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress,
            "ActivePool: Caller is neither BorrowerOperations nor TroveManager");
    }

    // --- Fallback function ---

    receive() external payable {
        _requireCallerIsBorrowerOperationsOrDefaultPool();
        BNB = BNB.add(msg.value);
        emit ActivePoolBNBBalanceUpdated(BNB);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPool.sol";


interface IActivePool is IPool {
    // --- Events ---
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolUSDSDebtUpdated(uint _USDSDebt);
    event ActivePoolBNBBalanceUpdated(uint _BNB);

    // --- Functions ---
    function sendBNB(address _account, uint _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

/**
 * Based on OpenZeppelin's SafeMath:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
 *
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

/**
 * Based on OpenZeppelin's Ownable contract:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
 *
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     *
     * NOTE: This function is not safe, as it doesn’t check owner is calling it.
     * Make sure you check it before calling it.
     */
    function _renounceOwnership() internal {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;


contract CheckContract {
    /**
     * Check that the account is an already deployed non-destroyed contract.
     * See: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol#L12
     */
    function checkContract(address _account) internal view {
        require(_account != address(0), "0addr");

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(_account) }
        require(size > 0, "0code");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

// Buidler's helper contract for console logging
library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function log() internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log()"));
		ignored;
	}	function logInt(int p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(int)", p0));
		ignored;
	}

	function logUint(uint p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint)", p0));
		ignored;
	}

	function logString(string memory p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string)", p0));
		ignored;
	}

	function logBool(bool p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool)", p0));
		ignored;
	}

	function logAddress(address p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address)", p0));
		ignored;
	}

	function logBytes(bytes memory p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes)", p0));
		ignored;
	}

	function logByte(byte p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(byte)", p0));
		ignored;
	}

	function logBytes1(bytes1 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes1)", p0));
		ignored;
	}

	function logBytes2(bytes2 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes2)", p0));
		ignored;
	}

	function logBytes3(bytes3 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes3)", p0));
		ignored;
	}

	function logBytes4(bytes4 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes4)", p0));
		ignored;
	}

	function logBytes5(bytes5 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes5)", p0));
		ignored;
	}

	function logBytes6(bytes6 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes6)", p0));
		ignored;
	}

	function logBytes7(bytes7 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes7)", p0));
		ignored;
	}

	function logBytes8(bytes8 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes8)", p0));
		ignored;
	}

	function logBytes9(bytes9 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes9)", p0));
		ignored;
	}

	function logBytes10(bytes10 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes10)", p0));
		ignored;
	}

	function logBytes11(bytes11 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes11)", p0));
		ignored;
	}

	function logBytes12(bytes12 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes12)", p0));
		ignored;
	}

	function logBytes13(bytes13 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes13)", p0));
		ignored;
	}

	function logBytes14(bytes14 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes14)", p0));
		ignored;
	}

	function logBytes15(bytes15 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes15)", p0));
		ignored;
	}

	function logBytes16(bytes16 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes16)", p0));
		ignored;
	}

	function logBytes17(bytes17 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes17)", p0));
		ignored;
	}

	function logBytes18(bytes18 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes18)", p0));
		ignored;
	}

	function logBytes19(bytes19 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes19)", p0));
		ignored;
	}

	function logBytes20(bytes20 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes20)", p0));
		ignored;
	}

	function logBytes21(bytes21 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes21)", p0));
		ignored;
	}

	function logBytes22(bytes22 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes22)", p0));
		ignored;
	}

	function logBytes23(bytes23 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes23)", p0));
		ignored;
	}

	function logBytes24(bytes24 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes24)", p0));
		ignored;
	}

	function logBytes25(bytes25 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes25)", p0));
		ignored;
	}

	function logBytes26(bytes26 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes26)", p0));
		ignored;
	}

	function logBytes27(bytes27 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes27)", p0));
		ignored;
	}

	function logBytes28(bytes28 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes28)", p0));
		ignored;
	}

	function logBytes29(bytes29 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes29)", p0));
		ignored;
	}

	function logBytes30(bytes30 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes30)", p0));
		ignored;
	}

	function logBytes31(bytes31 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes31)", p0));
		ignored;
	}

	function logBytes32(bytes32 p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bytes32)", p0));
		ignored;
	}

	function log(uint p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint)", p0));
		ignored;
	}

	function log(string memory p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string)", p0));
		ignored;
	}

	function log(bool p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool)", p0));
		ignored;
	}

	function log(address p0) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address)", p0));
		ignored;
	}

	function log(uint p0, uint p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint)", p0, p1));
		ignored;
	}

	function log(uint p0, string memory p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string)", p0, p1));
		ignored;
	}

	function log(uint p0, bool p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool)", p0, p1));
		ignored;
	}

	function log(uint p0, address p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address)", p0, p1));
		ignored;
	}

	function log(string memory p0, uint p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint)", p0, p1));
		ignored;
	}

	function log(string memory p0, string memory p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string)", p0, p1));
		ignored;
	}

	function log(string memory p0, bool p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool)", p0, p1));
		ignored;
	}

	function log(string memory p0, address p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address)", p0, p1));
		ignored;
	}

	function log(bool p0, uint p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint)", p0, p1));
		ignored;
	}

	function log(bool p0, string memory p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string)", p0, p1));
		ignored;
	}

	function log(bool p0, bool p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool)", p0, p1));
		ignored;
	}

	function log(bool p0, address p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address)", p0, p1));
		ignored;
	}

	function log(address p0, uint p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint)", p0, p1));
		ignored;
	}

	function log(address p0, string memory p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string)", p0, p1));
		ignored;
	}

	function log(address p0, bool p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool)", p0, p1));
		ignored;
	}

	function log(address p0, address p1) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address)", p0, p1));
		ignored;
	}

	function log(uint p0, uint p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, string memory p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, bool p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, address p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, uint p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, bool p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(string memory p0, address p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, uint p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, string memory p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, bool p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(bool p0, address p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, uint p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, string memory p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, bool p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, uint p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, string memory p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, bool p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
		ignored;
	}

	function log(address p0, address p1, address p2) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
		ignored;
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		(bool ignored, ) = CONSOLE_ADDRESS.staticcall(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
		ignored;
	}

}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

// Common interface for the Pools.
interface IPool {
    
    // --- Events ---
    
    event BNBBalanceUpdated(uint _newBalance);
    event USDSBalanceUpdated(uint _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event EtherSent(address _to, uint _amount);

    // --- Functions ---
    
    function getBNB() external view returns (uint);

    function getUSDSDebt() external view returns (uint);

    function increaseUSDSDebt(uint _amount) external;

    function decreaseUSDSDebt(uint _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../TroveManager.sol";
import "../BorrowerOperations.sol";
import "../ActivePool.sol";
import "../DefaultPool.sol";
import "../StabilityPool.sol";
import "../GasPool.sol";
import "../CollSurplusPool.sol";
import "../USDSToken.sol";
import "./PriceFeedTestnet.sol";
import "../SortedTroves.sol";
import "./EchidnaProxy.sol";
import "../SystemState.sol";
import "../TimeLock.sol";
import "../OracleRateCalculation.sol";
import "../TroveHelper.sol";
import "../Interfaces/IBorrowerOperations.sol";
import "../Interfaces/ITroveManager.sol";
import "../Interfaces/ITroveHelper.sol";

//import "../Dependencies/console.sol";

// Run with:
// rm -f fuzzTests/corpus/* # (optional)
// ~/.local/bin/echidna-test contracts/TestContracts/EchidnaTester.sol --contract EchidnaTester --config fuzzTests/echidna_config.yaml

contract EchidnaTester {
    using SafeMath for uint;

    uint private constant NUMBER_OF_ACTORS = 100;
    uint private constant INITIAL_BALANCE = 1e24;
    uint private MCR;
    uint private CCR;
    uint private USDS_GAS_COMPENSATION;

    TroveManager public troveManager;
    BorrowerOperations public borrowerOperations;
    ActivePool public activePool;
    DefaultPool public defaultPool;
    StabilityPool public stabilityPool;
    GasPool public gasPool;
    CollSurplusPool public collSurplusPool;
    USDSToken public usdsToken;
    PriceFeedTestnet priceFeedTestnet;
    SortedTroves sortedTroves;
    SystemState systemState;
    TimeLock timeLock;
    OracleRateCalculation oracleRateCalc;
    TroveHelper troveHelper;

    EchidnaProxy[NUMBER_OF_ACTORS] public echidnaProxies;

    uint private numberOfTroves;

    constructor() public payable {
        troveManager = new TroveManager();
        borrowerOperations = new BorrowerOperations();
        activePool = new ActivePool();
        defaultPool = new DefaultPool();
        stabilityPool = new StabilityPool();
        gasPool = new GasPool();
        address[] memory paramsTimeLock;
        timeLock = new TimeLock(100, paramsTimeLock, paramsTimeLock);
        systemState = new SystemState();
        usdsToken = new USDSToken(
            address(troveManager),
            address(stabilityPool), 
            address(borrowerOperations)
        );

        collSurplusPool = new CollSurplusPool();
        priceFeedTestnet = new PriceFeedTestnet();

        sortedTroves = new SortedTroves();
        troveHelper = new TroveHelper();

        ITroveManager.DependencyAddressParam memory troveManagerAddressParam = ITroveManager
            .DependencyAddressParam({
                borrowerOperationsAddress: address(borrowerOperations),
                activePoolAddress: address(activePool),
                defaultPoolAddress: address(defaultPool),
                stabilityPoolAddress: address(stabilityPool),
                gasPoolAddress: address(gasPool),
                collSurplusPoolAddress: address(collSurplusPool),
                priceFeedAddress: address(priceFeedTestnet),
                usdsTokenAddress: address(usdsToken),
                sortedTrovesAddress: address(sortedTroves),
                sableTokenAddress: address(0),
                sableStakingAddress: address(0),
                systemStateAddress: address(systemState),
                oracleRateCalcAddress: address(oracleRateCalc),
                troveHelperAddress: address(troveHelper)
            });

        troveManager.setAddresses(troveManagerAddressParam);

        IBorrowerOperations.DependencyAddressParam memory borrowerAddressParam = IBorrowerOperations
            .DependencyAddressParam({
                troveManagerAddress: address(troveManager),
                activePoolAddress: address(activePool),
                defaultPoolAddress: address(defaultPool),
                stabilityPoolAddress: address(stabilityPool),
                gasPoolAddress: address(gasPool),
                collSurplusPoolAddress: address(collSurplusPool),
                priceFeedAddress: address(priceFeedTestnet),
                sortedTrovesAddress: address(sortedTroves),
                usdsTokenAddress: address(usdsToken),
                sableStakingAddress: address(0),
                systemStateAddress: address(systemState),
                oracleRateCalcAddress: address(oracleRateCalc)
            });

        borrowerOperations.setAddresses(borrowerAddressParam);

        activePool.setAddresses(
            address(borrowerOperations),
            address(troveManager),
            address(stabilityPool),
            address(defaultPool)
        );

        defaultPool.setAddresses(address(troveManager), address(activePool));

        stabilityPool.setParams(
            address(borrowerOperations),
            address(troveManager),
            address(activePool),
            address(usdsToken),
            address(sortedTroves),
            address(priceFeedTestnet),
            address(0),
            address(systemState)
        );

        collSurplusPool.setAddresses(
            address(borrowerOperations),
            address(troveManager),
            address(activePool)
        );

        systemState.setConfigs(
            address(timeLock),
            1100000000000000000,
            1500000000000000000,
            200e18,
            1800e18,
            5e15,
            5e15
        );

        sortedTroves.setParams(1e18, address(troveManager), address(borrowerOperations));

        for (uint i = 0; i < NUMBER_OF_ACTORS; i++) {
            echidnaProxies[i] = new EchidnaProxy(
                troveManager,
                borrowerOperations,
                stabilityPool,
                usdsToken
            );
            (bool success, ) = address(echidnaProxies[i]).call{value: INITIAL_BALANCE}("");
            require(success);
        }

        MCR = systemState.getMCR();
        CCR = systemState.getCCR();
        USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();
        require(MCR > 0);
        require(CCR > 0);

        // TODO:
        priceFeedTestnet.setPrice(1e22);
    }

    // TroveManager

    function liquidateExt(
        uint _i,
        address _user,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].liquidatePrx(_user, priceFeedUpdateData);
    }

    function liquidateTrovesExt(
        uint _i,
        uint _n,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].liquidateTrovesPrx(_n, priceFeedUpdateData);
    }

    function batchLiquidateTrovesExt(
        uint _i,
        address[] calldata _troveArray,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].batchLiquidateTrovesPrx(_troveArray, priceFeedUpdateData);
    }

    function redeemCollateralExt(
        uint _i,
        uint _USDSAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].redeemCollateralPrx(
            _USDSAmount,
            _firstRedemptionHint,
            _upperPartialRedemptionHint,
            _lowerPartialRedemptionHint,
            _partialRedemptionHintNICR,
            0,
            0,
            priceFeedUpdateData
        );
    }

    // Borrower Operations

    function getAdjustedBNB(uint actorBalance, uint _BNB, uint ratio) internal view returns (uint) {
        uint price = priceFeedTestnet.getPrice();
        require(price > 0);
        uint minBNB = ratio.mul(USDS_GAS_COMPENSATION).div(price);
        require(actorBalance > minBNB);
        uint BNB = minBNB + (_BNB % (actorBalance - minBNB));
        return BNB;
    }

    function getAdjustedUSDS(uint BNB, uint _USDSAmount, uint ratio) internal view returns (uint) {
        uint price = priceFeedTestnet.getPrice();
        uint USDSAmount = _USDSAmount;
        uint compositeDebt = USDSAmount.add(USDS_GAS_COMPENSATION);
        uint ICR = LiquityMath._computeCR(BNB, compositeDebt, price);
        if (ICR < ratio) {
            compositeDebt = BNB.mul(price).div(ratio);
            USDSAmount = compositeDebt.sub(USDS_GAS_COMPENSATION);
        }
        return USDSAmount;
    }

    function openTroveExt(
        uint _i,
        uint _BNB,
        uint _USDSAmount,
        bytes[] calldata priceFeedUpdateData
    ) public payable {
        uint actor = _i % NUMBER_OF_ACTORS;
        EchidnaProxy echidnaProxy = echidnaProxies[actor];
        uint actorBalance = address(echidnaProxy).balance;

        // we pass in CCR instead of MCR in case it’s the first one
        uint BNB = getAdjustedBNB(actorBalance, _BNB, CCR);
        uint USDSAmount = getAdjustedUSDS(BNB, _USDSAmount, CCR);

        //console.log('BNB', BNB);
        //console.log('USDSAmount', USDSAmount);

        echidnaProxy.openTrovePrx(BNB, USDSAmount, address(0), address(0), 0, priceFeedUpdateData);

        numberOfTroves = troveManager.getTroveOwnersCount();
        assert(numberOfTroves > 0);
        // canary
        //assert(numberOfTroves == 0);
    }

    function openTroveRawExt(
        uint _i,
        uint _BNB,
        uint _USDSAmount,
        address _upperHint,
        address _lowerHint,
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) public payable {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].openTrovePrx(
            _BNB,
            _USDSAmount,
            _upperHint,
            _lowerHint,
            _maxFee,
            priceFeedUpdateData
        );
    }

    function addCollExt(uint _i, uint _BNB, bytes[] calldata priceFeedUpdateData) external payable {
        uint actor = _i % NUMBER_OF_ACTORS;
        EchidnaProxy echidnaProxy = echidnaProxies[actor];
        uint actorBalance = address(echidnaProxy).balance;

        uint BNB = getAdjustedBNB(actorBalance, _BNB, MCR);

        echidnaProxy.addCollPrx(BNB, address(0), address(0), priceFeedUpdateData);
    }

    function addCollRawExt(
        uint _i,
        uint _BNB,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].addCollPrx(_BNB, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function withdrawCollExt(
        uint _i,
        uint _amount,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].withdrawCollPrx(_amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function withdrawUSDSExt(
        uint _i,
        uint _amount,
        address _upperHint,
        address _lowerHint,
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].withdrawUSDSPrx(
            _amount,
            _upperHint,
            _lowerHint,
            _maxFee,
            priceFeedUpdateData
        );
    }

    function repayUSDSExt(
        uint _i,
        uint _amount,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].repayUSDSPrx(_amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function closeTroveExt(uint _i, bytes[] calldata priceFeedUpdateData) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].closeTrovePrx(priceFeedUpdateData);
    }

    function adjustTroveExt(
        uint _i,
        uint _BNB,
        uint _collWithdrawal,
        uint _debtChange,
        bool _isDebtIncrease,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        uint actor = _i % NUMBER_OF_ACTORS;
        EchidnaProxy echidnaProxy = echidnaProxies[actor];
        uint actorBalance = address(echidnaProxy).balance;

        uint BNB = getAdjustedBNB(actorBalance, _BNB, MCR);
        uint debtChange = _debtChange;
        if (_isDebtIncrease) {
            // TODO: add current amount already withdrawn:
            debtChange = getAdjustedUSDS(BNB, uint(_debtChange), MCR);
        }
        // TODO: collWithdrawal, debtChange

        IBorrowerOperations.AdjustTroveParam memory adjustParam = IBorrowerOperations
            .AdjustTroveParam({
                collWithdrawal: _collWithdrawal,
                USDSChange: debtChange,
                isDebtIncrease: _isDebtIncrease,
                upperHint: address(0),
                lowerHint: address(0),
                maxFeePercentage: 0
            });
        echidnaProxy.adjustTrovePrx(BNB, adjustParam, priceFeedUpdateData);
    }

    function adjustTroveRawExt(
        uint _i,
        uint _BNB,
        IBorrowerOperations.AdjustTroveParam memory adjustParam,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].adjustTrovePrx(_BNB, adjustParam, priceFeedUpdateData);
    }

    // Pool Manager

    function provideToSPExt(uint _i, uint _amount, address _frontEndTag) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].provideToSPPrx(_amount, _frontEndTag);
    }

    function withdrawFromSPExt(
        uint _i,
        uint _amount,
        bytes[] calldata priceFeedUpdateData
    ) external {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].withdrawFromSPPrx(_amount, priceFeedUpdateData);
    }

    // USDS Token

    function transferExt(uint _i, address recipient, uint256 amount) external returns (bool) {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].transferPrx(recipient, amount);
    }

    function approveExt(uint _i, address spender, uint256 amount) external returns (bool) {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].approvePrx(spender, amount);
    }

    function transferFromExt(
        uint _i,
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].transferFromPrx(sender, recipient, amount);
    }

    function increaseAllowanceExt(
        uint _i,
        address spender,
        uint256 addedValue
    ) external returns (bool) {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].increaseAllowancePrx(spender, addedValue);
    }

    function decreaseAllowanceExt(
        uint _i,
        address spender,
        uint256 subtractedValue
    ) external returns (bool) {
        uint actor = _i % NUMBER_OF_ACTORS;
        echidnaProxies[actor].decreaseAllowancePrx(spender, subtractedValue);
    }

    // PriceFeed

    function setPriceExt(uint256 _price) external {
        bool result = priceFeedTestnet.setPrice(_price);
        assert(result);
    }

    // --------------------------
    // Invariants and properties
    // --------------------------

    function echidna_canary_number_of_troves() public view returns (bool) {
        if (numberOfTroves > 20) {
            return false;
        }

        return true;
    }

    function echidna_canary_active_pool_balance() public view returns (bool) {
        if (address(activePool).balance > 0) {
            return false;
        }
        return true;
    }

    function echidna_troves_order() external view returns (bool) {
        address currentTrove = sortedTroves.getFirst();
        address nextTrove = sortedTroves.getNext(currentTrove);

        while (currentTrove != address(0) && nextTrove != address(0)) {
            if (troveManager.getNominalICR(nextTrove) > troveManager.getNominalICR(currentTrove)) {
                return false;
            }
            // Uncomment to check that the condition is meaningful
            //else return false;

            currentTrove = nextTrove;
            nextTrove = sortedTroves.getNext(currentTrove);
        }

        return true;
    }

    /**
     * Status
     * Minimum debt (gas compensation)
     * Stake > 0
     */
    function echidna_trove_properties() public view returns (bool) {
        address currentTrove = sortedTroves.getFirst();
        while (currentTrove != address(0)) {
            // Status
            if (
                ITroveManager.Status(troveManager.getTroveStatus(currentTrove)) !=
                ITroveManager.Status.active
            ) {
                return false;
            }
            // Uncomment to check that the condition is meaningful
            //else return false;

            // Minimum debt (gas compensation)
            if (troveManager.getTroveDebt(currentTrove) < USDS_GAS_COMPENSATION) {
                return false;
            }
            // Uncomment to check that the condition is meaningful
            //else return false;

            // Stake > 0
            if (troveManager.getTroveStake(currentTrove) == 0) {
                return false;
            }
            // Uncomment to check that the condition is meaningful
            //else return false;

            currentTrove = sortedTroves.getNext(currentTrove);
        }
        return true;
    }

    function echidna_BNB_balances() public view returns (bool) {
        if (address(troveManager).balance > 0) {
            return false;
        }

        if (address(borrowerOperations).balance > 0) {
            return false;
        }

        if (address(activePool).balance != activePool.getBNB()) {
            return false;
        }

        if (address(defaultPool).balance != defaultPool.getBNB()) {
            return false;
        }

        if (address(stabilityPool).balance != stabilityPool.getBNB()) {
            return false;
        }

        if (address(usdsToken).balance > 0) {
            return false;
        }

        if (address(priceFeedTestnet).balance > 0) {
            return false;
        }

        if (address(sortedTroves).balance > 0) {
            return false;
        }

        return true;
    }

    // TODO: What should we do with this? Should it be allowed? Should it be a canary?
    function echidna_price() public view returns (bool) {
        uint price = priceFeedTestnet.getPrice();

        if (price == 0) {
            return false;
        }
        // Uncomment to check that the condition is meaningful
        //else return false;

        return true;
    }

    // Total USDS matches
    function echidna_USDS_global_balances() public view returns (bool) {
        uint totalSupply = usdsToken.totalSupply();
        uint gasPoolBalance = usdsToken.balanceOf(address(gasPool));

        uint activePoolBalance = activePool.getUSDSDebt();
        uint defaultPoolBalance = defaultPool.getUSDSDebt();
        if (totalSupply != activePoolBalance + defaultPoolBalance) {
            return false;
        }

        uint stabilityPoolBalance = stabilityPool.getTotalUSDSDeposits();
        address currentTrove = sortedTroves.getFirst();
        uint trovesBalance;
        while (currentTrove != address(0)) {
            trovesBalance += usdsToken.balanceOf(address(currentTrove));
            currentTrove = sortedTroves.getNext(currentTrove);
        }
        // we cannot state equality because tranfers are made to external addresses too
        if (totalSupply <= stabilityPoolBalance + trovesBalance + gasPoolBalance) {
            return false;
        }

        return true;
    }

    /*
    function echidna_test() public view returns(bool) {
        return true;
    }
    */
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./Interfaces/ITroveManager.sol";

contract TroveManager is LiquityBase, CheckContract, Ownable, ITroveManager {
    // --- Connected contract declarations ---

    address public borrowerOperationsAddress;

    IStabilityPool public override stabilityPool;

    address gasPoolAddress;

    ICollSurplusPool collSurplusPool;

    IUSDSToken public override usdsToken;

    ISABLEToken public override sableToken;

    ISableStakingV2 public override sableStaking;

    // A doubly linked list of Troves, sorted by their sorted by their collateral ratios
    ISortedTroves public sortedTroves;

    // Oracle rate calculation contract
    IOracleRateCalculation public override oracleRateCalc;

    ITroveHelper public troveHelper;

    // --- Data structures ---

    uint public constant SECONDS_IN_ONE_MINUTE = 60;

    /*
     * Half-life of 12h. 12h = 720 min
     * (1/2) = d^720 => d = (1/2)^(1/720)
     */
    uint public constant MINUTE_DECAY_FACTOR = 999037758833783000;
    uint public constant MAX_BORROWING_FEE = (DECIMAL_PRECISION / 100) * 5; // 5%

    // During bootsrap period redemptions are not allowed
    uint public constant BOOTSTRAP_PERIOD = 0 days;

    /*
     * BETA: 18 digit decimal. Parameter by which to divide the redeemed fraction, in order to calc the new base rate from a redemption.
     * Corresponds to (1 / ALPHA) in the white paper.
     */
    uint public constant BETA = 2;

    uint public baseRate;

    // The timestamp of the latest fee operation (redemption or new USDS issuance)
    uint public lastFeeOperationTime;

    mapping(address => Trove) public Troves;

    uint public totalStakes;

    // Snapshot of the value of totalStakes, taken immediately after the latest liquidation
    uint public totalStakesSnapshot;

    // Snapshot of the total collateral across the ActivePool and DefaultPool, immediately after the latest liquidation.
    uint public totalCollateralSnapshot;

    /*
     * L_BNB and L_USDSDebt track the sums of accumulated liquidation rewards per unit staked. During its lifetime, each stake earns:
     *
     * An BNB gain of ( stake * [L_BNB - L_BNB(0)] )
     * A USDSDebt increase  of ( stake * [L_USDSDebt - L_USDSDebt(0)] )
     *
     * Where L_BNB(0) and L_USDSDebt(0) are snapshots of L_BNB and L_USDSDebt for the active Trove taken at the instant the stake was made
     */
    uint public L_BNB;
    uint public L_USDSDebt;

    // Map addresses with active troves to their RewardSnapshot
    mapping(address => RewardSnapshot) public rewardSnapshots;

    // Array of all active trove addresses - used to to compute an approximate hint off-chain, for the sorted list insertion
    address[] public TroveOwners;

    // Error trackers for the trove redistribution calculation
    uint public lastBNBError_Redistribution;
    uint public lastUSDSDebtError_Redistribution;

    // --- Dependency setter ---

    function setAddresses(DependencyAddressParam memory param) external override onlyOwner {

        checkContract(param.borrowerOperationsAddress);
        checkContract(param.activePoolAddress);
        checkContract(param.defaultPoolAddress);
        checkContract(param.stabilityPoolAddress);
        checkContract(param.gasPoolAddress);
        checkContract(param.collSurplusPoolAddress);
        checkContract(param.priceFeedAddress);
        checkContract(param.usdsTokenAddress);
        checkContract(param.sortedTrovesAddress);
        checkContract(param.sableTokenAddress);
        checkContract(param.sableStakingAddress);
        checkContract(param.systemStateAddress);
        checkContract(param.oracleRateCalcAddress);
        checkContract(param.troveHelperAddress);

        borrowerOperationsAddress = param.borrowerOperationsAddress;
        activePool = IActivePool(param.activePoolAddress);
        defaultPool = IDefaultPool(param.defaultPoolAddress);
        stabilityPool = IStabilityPool(param.stabilityPoolAddress);
        gasPoolAddress = param.gasPoolAddress;
        collSurplusPool = ICollSurplusPool(param.collSurplusPoolAddress);
        priceFeed = IPriceFeed(param.priceFeedAddress);
        usdsToken = IUSDSToken(param.usdsTokenAddress);
        sortedTroves = ISortedTroves(param.sortedTrovesAddress);
        sableToken = ISABLEToken(param.sableTokenAddress);
        sableStaking = ISableStakingV2(param.sableStakingAddress);
        systemState = ISystemState(param.systemStateAddress);
        oracleRateCalc = IOracleRateCalculation(param.oracleRateCalcAddress);
        troveHelper = ITroveHelper(param.troveHelperAddress);

        emit AddressesChanged(param);

        _renounceOwnership();
    }

    // --- Getters ---

    function getTroveOwnersCount() external view override returns (uint) {
        return TroveOwners.length;
    }

    function getTroveFromTroveOwnersArray(uint _index) external view override returns (address) {
        return TroveOwners[_index];
    }

    // --- Trove Liquidation functions ---

    // Single liquidation function. Closes the trove if its ICR is lower than the minimum collateral ratio.
    function liquidate(
        address _borrower,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        _requireTroveIsActive(_borrower);

        address[] memory borrowers = new address[](1);
        borrowers[0] = _borrower;
        batchLiquidateTroves(borrowers, priceFeedUpdateData);
    }

    // --- Inner single liquidation functions ---

    // Liquidate one trove, in Normal Mode.
    function _liquidateNormalMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        address _borrower,
        uint _USDSInStabPool
    ) internal returns (LiquidationValues memory singleLiquidation) {
        LocalVariables_InnerSingleLiquidateFunction memory vars;

        (
            singleLiquidation.entireTroveDebt,
            singleLiquidation.entireTroveColl,
            vars.pendingDebtReward,
            vars.pendingCollReward
        ) = getEntireDebtAndColl(_borrower);

        _movePendingTroveRewardsToActivePool(
            _activePool,
            _defaultPool,
            vars.pendingDebtReward,
            vars.pendingCollReward
        );
        _removeStake(_borrower);

        singleLiquidation.collGasCompensation = _getCollGasCompensation(
            singleLiquidation.entireTroveColl
        );
        singleLiquidation.USDSGasCompensation = systemState.getUSDSGasCompensation();
        uint collToLiquidate = singleLiquidation.entireTroveColl.sub(
            singleLiquidation.collGasCompensation
        );

        (
            singleLiquidation.debtToOffset,
            singleLiquidation.collToSendToSP,
            singleLiquidation.debtToRedistribute,
            singleLiquidation.collToRedistribute
        ) = _getOffsetAndRedistributionVals(
            singleLiquidation.entireTroveDebt,
            collToLiquidate,
            _USDSInStabPool
        );

        _closeTrove(_borrower, Status.closedByLiquidation);
        emit TroveLiquidated(
            _borrower,
            singleLiquidation.entireTroveDebt,
            singleLiquidation.entireTroveColl,
            TroveManagerOperation.liquidateInNormalMode
        );
        emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInNormalMode);
        return singleLiquidation;
    }

    // Liquidate one trove, in Recovery Mode.
    function _liquidateRecoveryMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        address _borrower,
        uint _ICR,
        uint _USDSInStabPool,
        uint _TCR,
        uint _price
    ) internal returns (LiquidationValues memory singleLiquidation) {
        LocalVariables_InnerSingleLiquidateFunction memory vars;
        if (TroveOwners.length <= 1) {
            return singleLiquidation;
        } // don't liquidate if last trove
        (
            singleLiquidation.entireTroveDebt,
            singleLiquidation.entireTroveColl,
            vars.pendingDebtReward,
            vars.pendingCollReward
        ) = getEntireDebtAndColl(_borrower);

        singleLiquidation.collGasCompensation = _getCollGasCompensation(
            singleLiquidation.entireTroveColl
        );
        uint MCR = systemState.getMCR();

        singleLiquidation.USDSGasCompensation = systemState.getUSDSGasCompensation();
        vars.collToLiquidate = singleLiquidation.entireTroveColl.sub(
            singleLiquidation.collGasCompensation
        );

        // If ICR <= 100%, purely redistribute the Trove across all active Troves
        if (_ICR <= _100pct) {
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                vars.pendingDebtReward,
                vars.pendingCollReward
            );
            _removeStake(_borrower);

            singleLiquidation.debtToOffset = 0;
            singleLiquidation.collToSendToSP = 0;
            singleLiquidation.debtToRedistribute = singleLiquidation.entireTroveDebt;
            singleLiquidation.collToRedistribute = vars.collToLiquidate;

            _closeTrove(_borrower, Status.closedByLiquidation);
            emit TroveLiquidated(
                _borrower,
                singleLiquidation.entireTroveDebt,
                singleLiquidation.entireTroveColl,
                TroveManagerOperation.liquidateInRecoveryMode
            );
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInRecoveryMode);

            // If 100% < ICR < MCR, offset as much as possible, and redistribute the remainder
        } else if ((_ICR > _100pct) && (_ICR < MCR)) {
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                vars.pendingDebtReward,
                vars.pendingCollReward
            );
            _removeStake(_borrower);

            (
                singleLiquidation.debtToOffset,
                singleLiquidation.collToSendToSP,
                singleLiquidation.debtToRedistribute,
                singleLiquidation.collToRedistribute
            ) = _getOffsetAndRedistributionVals(
                singleLiquidation.entireTroveDebt,
                vars.collToLiquidate,
                _USDSInStabPool
            );

            _closeTrove(_borrower, Status.closedByLiquidation);
            emit TroveLiquidated(
                _borrower,
                singleLiquidation.entireTroveDebt,
                singleLiquidation.entireTroveColl,
                TroveManagerOperation.liquidateInRecoveryMode
            );
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInRecoveryMode);
            /*
             * If 110% <= ICR < current TCR (accounting for the preceding liquidations in the current sequence)
             * and there is USDS in the Stability Pool, only offset, with no redistribution,
             * but at a capped rate of 1.1 and only if the whole debt can be liquidated.
             * The remainder due to the capped rate will be claimable as collateral surplus.
             */
        } else if (
            (_ICR >= MCR) && (_ICR < _TCR) && (singleLiquidation.entireTroveDebt <= _USDSInStabPool)
        ) {
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                vars.pendingDebtReward,
                vars.pendingCollReward
            );
            assert(_USDSInStabPool != 0);

            _removeStake(_borrower);

            singleLiquidation = troveHelper.getCappedOffsetVals(
                singleLiquidation.entireTroveDebt,
                singleLiquidation.entireTroveColl,
                _price
            );

            _closeTrove(_borrower, Status.closedByLiquidation);
            if (singleLiquidation.collSurplus > 0) {
                collSurplusPool.accountSurplus(_borrower, singleLiquidation.collSurplus);
            }

            emit TroveLiquidated(
                _borrower,
                singleLiquidation.entireTroveDebt,
                singleLiquidation.collToSendToSP,
                TroveManagerOperation.liquidateInRecoveryMode
            );
            emit TroveUpdated(_borrower, 0, 0, 0, TroveManagerOperation.liquidateInRecoveryMode);
        } else {
            // if (_ICR >= MCR && ( _ICR >= _TCR || singleLiquidation.entireTroveDebt > _USDSInStabPool))
            LiquidationValues memory zeroVals;
            return zeroVals;
        }

        return singleLiquidation;
    }

    /* In a full liquidation, returns the values for a trove's coll and debt to be offset, and coll and debt to be
     * redistributed to active troves.
     */
    function _getOffsetAndRedistributionVals(
        uint _debt,
        uint _coll,
        uint _USDSInStabPool
    )
        internal
        pure
        returns (
            uint debtToOffset,
            uint collToSendToSP,
            uint debtToRedistribute,
            uint collToRedistribute
        )
    {
        if (_USDSInStabPool > 0) {
            /*
             * Offset as much debt & collateral as possible against the Stability Pool, and redistribute the remainder
             * between all active troves.
             *
             *  If the trove's debt is larger than the deposited USDS in the Stability Pool:
             *
             *  - Offset an amount of the trove's debt equal to the USDS in the Stability Pool
             *  - Send a fraction of the trove's collateral to the Stability Pool, equal to the fraction of its offset debt
             *
             */
            debtToOffset = LiquityMath._min(_debt, _USDSInStabPool);
            collToSendToSP = _coll.mul(debtToOffset).div(_debt);
            debtToRedistribute = _debt.sub(debtToOffset);
            collToRedistribute = _coll.sub(collToSendToSP);
        } else {
            debtToOffset = 0;
            collToSendToSP = 0;
            debtToRedistribute = _debt;
            collToRedistribute = _coll;
        }
    }

    /*
     * Liquidate a sequence of troves. Closes a maximum number of n under-collateralized Troves,
     * starting from the one with the lowest collateral ratio in the system, and moving upwards
     */
    function liquidateTroves(
        uint _n,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        ContractsCache memory contractsCache = ContractsCache(
            activePool,
            defaultPool,
            IUSDSToken(address(0)),
            ISableStakingV2(address(0)),
            sortedTroves,
            ICollSurplusPool(address(0)),
            address(0)
        );
        IStabilityPool stabilityPoolCached = stabilityPool;

        LocalVariables_OuterLiquidationFunction memory vars;

        LiquidationTotals memory totals;

        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(
            priceFeedUpdateData
        );
        vars.price = fetchPriceResult.price;

        vars.USDSInStabPool = stabilityPoolCached.getTotalUSDSDeposits();
        vars.recoveryModeAtStart = _checkRecoveryMode(vars.price);

        // Perform the appropriate liquidation sequence - tally the values, and obtain their totals
        if (vars.recoveryModeAtStart) {
            totals = _getTotalsFromLiquidateTrovesSequence_RecoveryMode(
                contractsCache,
                vars.price,
                vars.USDSInStabPool,
                _n
            );
        } else {
            // if !vars.recoveryModeAtStart
            totals = _getTotalsFromLiquidateTrovesSequence_NormalMode(
                contractsCache.activePool,
                contractsCache.defaultPool,
                vars.price,
                vars.USDSInStabPool,
                _n
            );
        }

        // require(totals.totalDebtInSequence > 0, "1");
        assert(totals.totalDebtInSequence > 0);

        // Move liquidated BNB and USDS to the appropriate pools
        stabilityPoolCached.offset(totals.totalDebtToOffset, totals.totalCollToSendToSP);
        _redistributeDebtAndColl(
            contractsCache.activePool,
            contractsCache.defaultPool,
            totals.totalDebtToRedistribute,
            totals.totalCollToRedistribute
        );
        if (totals.totalCollSurplus > 0) {
            contractsCache.activePool.sendBNB(address(collSurplusPool), totals.totalCollSurplus);
        }

        // Update system snapshots
        _updateSystemSnapshots_excludeCollRemainder(
            contractsCache.activePool,
            totals.totalCollGasCompensation
        );

        vars.liquidatedDebt = totals.totalDebtInSequence;
        vars.liquidatedColl = totals.totalCollInSequence.sub(totals.totalCollGasCompensation).sub(
            totals.totalCollSurplus
        );
        emit Liquidation(
            vars.liquidatedDebt,
            vars.liquidatedColl,
            totals.totalCollGasCompensation,
            totals.totalUSDSGasCompensation
        );
        // Send gas compensation to caller
        _sendGasCompensation(
            contractsCache.activePool,
            msg.sender,
            totals.totalUSDSGasCompensation,
            totals.totalCollGasCompensation
        );
    }

    /*
     * This function is used when the liquidateTroves sequence starts during Recovery Mode. However, it
     * handle the case where the system *leaves* Recovery Mode, part way through the liquidation sequence
     */
    function _getTotalsFromLiquidateTrovesSequence_RecoveryMode(
        ContractsCache memory _contractsCache,
        uint _price,
        uint _USDSInStabPool,
        uint _n
    ) internal returns (LiquidationTotals memory totals) {
        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;

        vars.remainingUSDSInStabPool = _USDSInStabPool;
        vars.backToNormalMode = false;
        vars.entireSystemDebt = getEntireSystemDebt();
        vars.entireSystemColl = getEntireSystemColl();

        vars.user = _contractsCache.sortedTroves.getLast();
        vars.firstUser = _contractsCache.sortedTroves.getFirst();
        vars.MCR = systemState.getMCR();
        for (vars.i = 0; vars.i < _n && vars.user != vars.firstUser; vars.i++) {
            // we need to cache it, because current user is likely going to be deleted
            address nextUser = _contractsCache.sortedTroves.getPrev(vars.user);

            vars.ICR = getCurrentICR(vars.user, _price);
            if (!vars.backToNormalMode) {
                // Break the loop if ICR is greater than MCR and Stability Pool is empty
                if (vars.ICR >= vars.MCR && vars.remainingUSDSInStabPool == 0) {
                    break;
                }

                uint TCR = LiquityMath._computeCR(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );

                singleLiquidation = _liquidateRecoveryMode(
                    _contractsCache.activePool,
                    _contractsCache.defaultPool,
                    vars.user,
                    vars.ICR,
                    vars.remainingUSDSInStabPool,
                    TCR,
                    _price
                );

                // Update aggregate trackers
                vars.remainingUSDSInStabPool = vars.remainingUSDSInStabPool.sub(
                    singleLiquidation.debtToOffset
                );
                vars.entireSystemDebt = vars.entireSystemDebt.sub(singleLiquidation.debtToOffset);
                vars.entireSystemColl = vars
                    .entireSystemColl
                    .sub(singleLiquidation.collToSendToSP)
                    .sub(singleLiquidation.collGasCompensation)
                    .sub(singleLiquidation.collSurplus);

                // Add liquidation values to their respective running totals
                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);

                vars.backToNormalMode = !_checkPotentialRecoveryMode(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );
            } else if (vars.backToNormalMode && vars.ICR < vars.MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _contractsCache.activePool,
                    _contractsCache.defaultPool,
                    vars.user,
                    vars.remainingUSDSInStabPool
                );

                vars.remainingUSDSInStabPool = vars.remainingUSDSInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                // Add liquidation values to their respective running totals
                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            } else break; // break if the loop reaches a Trove with ICR >= MCR

            vars.user = nextUser;
        }
    }

    function _getTotalsFromLiquidateTrovesSequence_NormalMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint _price,
        uint _USDSInStabPool,
        uint _n
    ) internal returns (LiquidationTotals memory totals) {
        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;
        ISortedTroves sortedTrovesCached = sortedTroves;

        vars.remainingUSDSInStabPool = _USDSInStabPool;
        uint MCR = systemState.getMCR();
        for (vars.i = 0; vars.i < _n; vars.i++) {
            vars.user = sortedTrovesCached.getLast();
            vars.ICR = getCurrentICR(vars.user, _price);

            if (vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.remainingUSDSInStabPool
                );

                vars.remainingUSDSInStabPool = vars.remainingUSDSInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                // Add liquidation values to their respective running totals
                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            } else break; // break if the loop reaches a Trove with ICR >= MCR
        }
    }

    /*
     * Attempt to liquidate a custom list of troves provided by the caller.
     */
    function batchLiquidateTroves(
        address[] memory _troveArray,
        bytes[] calldata priceFeedUpdateData
    ) public override {
        require(_troveArray.length != 0, "2");

        IActivePool activePoolCached = activePool;
        IDefaultPool defaultPoolCached = defaultPool;
        IStabilityPool stabilityPoolCached = stabilityPool;

        LocalVariables_OuterLiquidationFunction memory vars;
        LiquidationTotals memory totals;

        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(
            priceFeedUpdateData
        );
        vars.price = fetchPriceResult.price;

        vars.USDSInStabPool = stabilityPoolCached.getTotalUSDSDeposits();
        vars.recoveryModeAtStart = _checkRecoveryMode(vars.price);

        // Perform the appropriate liquidation sequence - tally values and obtain their totals.
        if (vars.recoveryModeAtStart) {
            totals = _getTotalFromBatchLiquidate_RecoveryMode(
                activePoolCached,
                defaultPoolCached,
                vars.price,
                vars.USDSInStabPool,
                _troveArray
            );
        } else {
            //  if !vars.recoveryModeAtStart
            totals = _getTotalsFromBatchLiquidate_NormalMode(
                activePoolCached,
                defaultPoolCached,
                vars.price,
                vars.USDSInStabPool,
                _troveArray
            );
        }

        require(totals.totalDebtInSequence > 0, "3");

        // Move liquidated BNB and USDS to the appropriate pools
        stabilityPoolCached.offset(totals.totalDebtToOffset, totals.totalCollToSendToSP);
        _redistributeDebtAndColl(
            activePoolCached,
            defaultPoolCached,
            totals.totalDebtToRedistribute,
            totals.totalCollToRedistribute
        );
        if (totals.totalCollSurplus > 0) {
            activePoolCached.sendBNB(address(collSurplusPool), totals.totalCollSurplus);
        }

        // Update system snapshots
        _updateSystemSnapshots_excludeCollRemainder(
            activePoolCached,
            totals.totalCollGasCompensation
        );

        vars.liquidatedDebt = totals.totalDebtInSequence;
        vars.liquidatedColl = totals.totalCollInSequence.sub(totals.totalCollGasCompensation).sub(
            totals.totalCollSurplus
        );
        emit Liquidation(
            vars.liquidatedDebt,
            vars.liquidatedColl,
            totals.totalCollGasCompensation,
            totals.totalUSDSGasCompensation
        );

        // Send gas compensation to caller
        _sendGasCompensation(
            activePoolCached,
            msg.sender,
            totals.totalUSDSGasCompensation,
            totals.totalCollGasCompensation
        );
    }

    /*
     * This function is used when the batch liquidation sequence starts during Recovery Mode. However, it
     * handle the case where the system *leaves* Recovery Mode, part way through the liquidation sequence
     */
    function _getTotalFromBatchLiquidate_RecoveryMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint _price,
        uint _USDSInStabPool,
        address[] memory _troveArray
    ) internal returns (LiquidationTotals memory totals) {
        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;

        vars.remainingUSDSInStabPool = _USDSInStabPool;
        vars.backToNormalMode = false;
        vars.entireSystemDebt = getEntireSystemDebt();
        vars.entireSystemColl = getEntireSystemColl();
        uint MCR = systemState.getMCR();

        for (vars.i = 0; vars.i < _troveArray.length; vars.i++) {
            vars.user = _troveArray[vars.i];
            // Skip non-active troves
            if (Troves[vars.user].status != Status.active) {
                continue;
            }
            vars.ICR = getCurrentICR(vars.user, _price);

            if (!vars.backToNormalMode) {
                // Skip this trove if ICR is greater than MCR and Stability Pool is empty
                if (vars.ICR >= MCR && vars.remainingUSDSInStabPool == 0) {
                    continue;
                }

                uint TCR = LiquityMath._computeCR(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );

                singleLiquidation = _liquidateRecoveryMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.ICR,
                    vars.remainingUSDSInStabPool,
                    TCR,
                    _price
                );

                // Update aggregate trackers
                vars.remainingUSDSInStabPool = vars.remainingUSDSInStabPool.sub(
                    singleLiquidation.debtToOffset
                );
                vars.entireSystemDebt = vars.entireSystemDebt.sub(singleLiquidation.debtToOffset);
                vars.entireSystemColl = vars
                    .entireSystemColl
                    .sub(singleLiquidation.collToSendToSP)
                    .sub(singleLiquidation.collGasCompensation)
                    .sub(singleLiquidation.collSurplus);

                // Add liquidation values to their respective running totals
                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);

                vars.backToNormalMode = !_checkPotentialRecoveryMode(
                    vars.entireSystemColl,
                    vars.entireSystemDebt,
                    _price
                );
            } else if (vars.backToNormalMode && vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.remainingUSDSInStabPool
                );
                vars.remainingUSDSInStabPool = vars.remainingUSDSInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                // Add liquidation values to their respective running totals
                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            } else continue; // In Normal Mode skip troves with ICR >= MCR
        }
    }

    function _getTotalsFromBatchLiquidate_NormalMode(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint _price,
        uint _USDSInStabPool,
        address[] memory _troveArray
    ) internal returns (LiquidationTotals memory totals) {
        LocalVariables_LiquidationSequence memory vars;
        LiquidationValues memory singleLiquidation;

        vars.remainingUSDSInStabPool = _USDSInStabPool;
        uint MCR = systemState.getMCR();

        for (vars.i = 0; vars.i < _troveArray.length; vars.i++) {
            vars.user = _troveArray[vars.i];
            vars.ICR = getCurrentICR(vars.user, _price);

            if (vars.ICR < MCR) {
                singleLiquidation = _liquidateNormalMode(
                    _activePool,
                    _defaultPool,
                    vars.user,
                    vars.remainingUSDSInStabPool
                );
                vars.remainingUSDSInStabPool = vars.remainingUSDSInStabPool.sub(
                    singleLiquidation.debtToOffset
                );

                // Add liquidation values to their respective running totals
                totals = _addLiquidationValuesToTotals(totals, singleLiquidation);
            }
        }
    }

    // --- Liquidation helper functions ---

    function _addLiquidationValuesToTotals(
        LiquidationTotals memory oldTotals,
        LiquidationValues memory singleLiquidation
    ) internal pure returns (LiquidationTotals memory newTotals) {
        // Tally all the values with their respective running totals
        newTotals.totalCollGasCompensation = oldTotals.totalCollGasCompensation.add(
            singleLiquidation.collGasCompensation
        );
        newTotals.totalUSDSGasCompensation = oldTotals.totalUSDSGasCompensation.add(
            singleLiquidation.USDSGasCompensation
        );
        newTotals.totalDebtInSequence = oldTotals.totalDebtInSequence.add(
            singleLiquidation.entireTroveDebt
        );
        newTotals.totalCollInSequence = oldTotals.totalCollInSequence.add(
            singleLiquidation.entireTroveColl
        );
        newTotals.totalDebtToOffset = oldTotals.totalDebtToOffset.add(
            singleLiquidation.debtToOffset
        );
        newTotals.totalCollToSendToSP = oldTotals.totalCollToSendToSP.add(
            singleLiquidation.collToSendToSP
        );
        newTotals.totalDebtToRedistribute = oldTotals.totalDebtToRedistribute.add(
            singleLiquidation.debtToRedistribute
        );
        newTotals.totalCollToRedistribute = oldTotals.totalCollToRedistribute.add(
            singleLiquidation.collToRedistribute
        );
        newTotals.totalCollSurplus = oldTotals.totalCollSurplus.add(singleLiquidation.collSurplus);

        return newTotals;
    }

    function _sendGasCompensation(
        IActivePool _activePool,
        address _liquidator,
        uint _USDS,
        uint _BNB
    ) internal {
        if (_USDS > 0) {
            usdsToken.returnFromPool(gasPoolAddress, _liquidator, _USDS);
        }

        if (_BNB > 0) {
            _activePool.sendBNB(_liquidator, _BNB);
        }
    }

    // Move a Trove's pending debt and collateral rewards from distributions, from the Default Pool to the Active Pool
    function _movePendingTroveRewardsToActivePool(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint _USDS,
        uint _BNB
    ) internal {
        _defaultPool.decreaseUSDSDebt(_USDS);
        _activePool.increaseUSDSDebt(_USDS);
        _defaultPool.sendBNBToActivePool(_BNB);
    }

    // --- Redemption functions ---

    // Redeem as much collateral as possible from _borrower's Trove in exchange for USDS up to _maxUSDSamount
    function _redeemCollateralFromTrove(
        RedeemCollateralFromTroveParam memory param
    ) internal returns (SingleRedemptionValues memory singleRedemption) {
        // Determine the remaining amount (lot) to be redeemed, capped by the entire debt of the Trove minus the liquidation reserve
        LocalVariables_RedeemCollateralFromTrove memory v;

        v.usdsGasCompensation = systemState.getUSDSGasCompensation();

        v.minNetDebt = systemState.getMinNetDebt();

        singleRedemption.USDSLot = LiquityMath._min(
            param.maxUSDSamount,
            Troves[param.borrower].debt.sub(v.usdsGasCompensation)
        );

        // Get the BNBLot of equivalent value in USD
        singleRedemption.BNBLot = singleRedemption.USDSLot.mul(DECIMAL_PRECISION).div(param.price);

        // Decrease the debt and collateral of the current Trove according to the USDS lot and corresponding BNB to send
        v.newDebt = (Troves[param.borrower].debt).sub(singleRedemption.USDSLot);

        v.newColl = (Troves[param.borrower].coll).sub(singleRedemption.BNBLot);

        if (v.newDebt == v.usdsGasCompensation) {
            // No debt left in the Trove (except for the liquidation reserve), therefore the trove gets closed
            _removeStake(param.borrower);
            _closeTrove(param.borrower, Status.closedByRedemption);
            _redeemCloseTrove(param.contractsCache, param.borrower, v.usdsGasCompensation, v.newColl);
            emit TroveUpdated(param.borrower, 0, 0, 0, TroveManagerOperation.redeemCollateral);
        } else {
            uint newNICR = LiquityMath._computeNominalCR(v.newColl, v.newDebt);

            /*
             * If the provided hint is out of date, we bail since trying to reinsert without a good hint will almost
             * certainly result in running out of gas.
             *
             * If the resultant net debt of the partial is less than the minimum, net debt we bail.
             */
            if (newNICR != param.partialRedemptionHintNICR || _getNetDebt(v.newDebt) < v.minNetDebt) {
                singleRedemption.cancelledPartial = true;
                return singleRedemption;
            }

            ISortedTroves.SortedTrovesInsertParam memory sortedTrovesParam = ISortedTroves
                .SortedTrovesInsertParam({
                    id: param.borrower,
                    newNICR: newNICR,
                    prevId: param.upperPartialRedemptionHint,
                    nextId: param.lowerPartialRedemptionHint
                });

            param.contractsCache.sortedTroves.reInsert(sortedTrovesParam);

            Troves[param.borrower].debt = v.newDebt;
            Troves[param.borrower].coll = v.newColl;
            _updateStakeAndTotalStakes(param.borrower);

            emit TroveUpdated(
                param.borrower,
                v.newDebt,
                v.newColl,
                Troves[param.borrower].stake,
                TroveManagerOperation.redeemCollateral
            );
        }

        return singleRedemption;
    }

    /*
     * Called when a full redemption occurs, and closes the trove.
     * The redeemer swaps (debt - liquidation reserve) USDS for (debt - liquidation reserve) worth of BNB, so the USDS liquidation reserve left corresponds to the remaining debt.
     * In order to close the trove, the USDS liquidation reserve is burned, and the corresponding debt is removed from the active pool.
     * The debt recorded on the trove's struct is zero'd elswhere, in _closeTrove.
     * Any surplus BNB left in the trove, is sent to the Coll surplus pool, and can be later claimed by the borrower.
     */
    function _redeemCloseTrove(
        ContractsCache memory _contractsCache,
        address _borrower,
        uint _USDS,
        uint _BNB
    ) internal {
        _contractsCache.usdsToken.burn(gasPoolAddress, _USDS);
        // Update Active Pool USDS, and send BNB to account
        _contractsCache.activePool.decreaseUSDSDebt(_USDS);

        // send BNB from Active Pool to CollSurplus Pool
        _contractsCache.collSurplusPool.accountSurplus(_borrower, _BNB);
        _contractsCache.activePool.sendBNB(address(_contractsCache.collSurplusPool), _BNB);
    }

    /* Send _USDSamount USDS to the system and redeem the corresponding amount of collateral from as many Troves as are needed to fill the redemption
     * request.  Applies pending rewards to a Trove before reducing its debt and coll.
     *
     * Note that if _amount is very large, this function can run out of gas, specially if traversed troves are small. This can be easily avoided by
     * splitting the total _amount in appropriate chunks and calling the function multiple times.
     *
     * Param `_maxIterations` can also be provided, so the loop through Troves is capped (if it’s zero, it will be ignored).This makes it easier to
     * avoid OOG for the frontend, as only knowing approximately the average cost of an iteration is enough, without needing to know the “topology”
     * of the trove list. It also avoids the need to set the cap in stone in the contract, nor doing gas calculations, as both gas price and opcode
     * costs can vary.
     *
     * All Troves that are redeemed from -- with the likely exception of the last one -- will end up with no debt left, therefore they will be closed.
     * If the last Trove does have some remaining debt, it has a finite ICR, and the reinsertion could be anywhere in the list, therefore it requires a hint.
     * A frontend should use getRedemptionHints() to calculate what the ICR of this Trove will be after redemption, and pass a hint for its position
     * in the sortedTroves list along with the ICR value that the hint was found for.
     *
     * If another transaction modifies the list between calling getRedemptionHints() and passing the hints to redeemCollateral(), it
     * is very likely that the last (partially) redeemed Trove would end up with a different ICR than what the hint is for. In this case the
     * redemption will stop after the last completely redeemed Trove and the sender will keep the remaining USDS amount, which they can attempt
     * to redeem later.
     */
    function redeemCollateral(
        uint _USDSamount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFeePercentage,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        ContractsCache memory contractsCache = ContractsCache(
            activePool,
            defaultPool,
            usdsToken,
            sableStaking,
            sortedTroves,
            collSurplusPool,
            gasPoolAddress
        );
        RedemptionTotals memory totals;

        uint oracleRate;

        {
            troveHelper.requireValidMaxFeePercentage(_maxFeePercentage);
            troveHelper.requireAfterBootstrapPeriod();

            IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(
                priceFeedUpdateData
            );
            totals.price = fetchPriceResult.price;

            // calculate oracleRate
            oracleRate = oracleRateCalc.getOracleRate(
                fetchPriceResult.oracleKey,
                fetchPriceResult.deviationPyth,
                fetchPriceResult.publishTimePyth
            );
        }

        troveHelper.requireTCRoverMCR(totals.price);
        troveHelper.requireAmountGreaterThanZero(_USDSamount);
        troveHelper.requireUSDSBalanceCoversRedemption(
            contractsCache.usdsToken,
            msg.sender,
            _USDSamount
        );

        totals.totalUSDSSupplyAtStart = getEntireSystemDebt();
        // Confirm redeemer's balance is less than total USDS supply
        assert(contractsCache.usdsToken.balanceOf(msg.sender) <= totals.totalUSDSSupplyAtStart);

        totals.remainingUSDS = _USDSamount;
        address currentBorrower;

        if (
            troveHelper.isValidFirstRedemptionHint(
                contractsCache.sortedTroves,
                _firstRedemptionHint,
                totals.price
            )
        ) {
            currentBorrower = _firstRedemptionHint;
        } else {
            currentBorrower = contractsCache.sortedTroves.getLast();
            // Find the first trove with ICR >= MCR
            while (
                currentBorrower != address(0) &&
                getCurrentICR(currentBorrower, totals.price) < systemState.getMCR()
            ) {
                currentBorrower = contractsCache.sortedTroves.getPrev(currentBorrower);
            }
        }

        // Loop through the Troves starting from the one with lowest collateral ratio until _amount of USDS is exchanged for collateral
        if (_maxIterations == 0) {
            _maxIterations = uint(-1);
        }
        while (currentBorrower != address(0) && totals.remainingUSDS > 0 && _maxIterations > 0) {
            _maxIterations--;
            // Save the address of the Trove preceding the current one, before potentially modifying the list
            address nextUserToCheck = contractsCache.sortedTroves.getPrev(currentBorrower);

            _applyPendingRewards(
                contractsCache.activePool,
                contractsCache.defaultPool,
                currentBorrower
            );

            RedeemCollateralFromTroveParam memory redeemParam = RedeemCollateralFromTroveParam({
                contractsCache: contractsCache,
                borrower: currentBorrower,
                maxUSDSamount: totals.remainingUSDS,
                price: totals.price,
                upperPartialRedemptionHint: _upperPartialRedemptionHint,
                lowerPartialRedemptionHint: _lowerPartialRedemptionHint,
                partialRedemptionHintNICR: _partialRedemptionHintNICR
            });

            SingleRedemptionValues memory singleRedemption = _redeemCollateralFromTrove(redeemParam);

            if (singleRedemption.cancelledPartial) break; // Partial redemption was cancelled (out-of-date hint, or new net debt < minimum), therefore we could not redeem from the last Trove

            totals.totalUSDSToRedeem = totals.totalUSDSToRedeem.add(singleRedemption.USDSLot);
            totals.totalBNBDrawn = totals.totalBNBDrawn.add(singleRedemption.BNBLot);

            totals.remainingUSDS = totals.remainingUSDS.sub(singleRedemption.USDSLot);
            currentBorrower = nextUserToCheck;
        }
        require(totals.totalBNBDrawn > 0, "4");

        // Decay the baseRate due to time passed, and then increase it according to the size of this redemption.
        // Use the saved total USDS supply value, from before it was reduced by the redemption.
        _updateBaseRateFromRedemption(
            totals.totalBNBDrawn,
            totals.price,
            totals.totalUSDSSupplyAtStart
        );

        // Calculate the BNB fee
        totals.BNBFee = _getRedemptionFee(totals.totalBNBDrawn, oracleRate);

        _requireUserAcceptsFee(totals.BNBFee, totals.totalBNBDrawn, _maxFeePercentage);

        // Send the BNB fee to the SABLE staking contract
        contractsCache.activePool.sendBNB(address(contractsCache.sableStaking), totals.BNBFee);
        contractsCache.sableStaking.increaseF_BNB(totals.BNBFee);

        totals.BNBToSendToRedeemer = totals.totalBNBDrawn.sub(totals.BNBFee);

        emit Redemption(_USDSamount, totals.totalUSDSToRedeem, totals.totalBNBDrawn, totals.BNBFee);

        // Burn the total USDS that is cancelled with debt, and send the redeemed BNB to msg.sender
        contractsCache.usdsToken.burn(msg.sender, totals.totalUSDSToRedeem);
        // Update Active Pool USDS, and send BNB to account
        contractsCache.activePool.decreaseUSDSDebt(totals.totalUSDSToRedeem);
        contractsCache.activePool.sendBNB(msg.sender, totals.BNBToSendToRedeemer);
    }

    // --- Helper functions ---

    // Return the nominal collateral ratio (ICR) of a given Trove, without the price. Takes a trove's pending coll and debt rewards from redistributions into account.
    function getNominalICR(address _borrower) public view override returns (uint) {
        (uint currentBNB, uint currentUSDSDebt) = _getCurrentTroveAmounts(_borrower);

        // uint NICR = LiquityMath._computeNominalCR(currentBNB, currentUSDSDebt);
        return LiquityMath._computeNominalCR(currentBNB, currentUSDSDebt);
    }

    // Return the current collateral ratio (ICR) of a given Trove. Takes a trove's pending coll and debt rewards from redistributions into account.
    function getCurrentICR(address _borrower, uint _price) public view override returns (uint) {
        (uint currentBNB, uint currentUSDSDebt) = _getCurrentTroveAmounts(_borrower);

        uint ICR = LiquityMath._computeCR(currentBNB, currentUSDSDebt, _price);
        return ICR;
    }

    function _getCurrentTroveAmounts(address _borrower) internal view returns (uint, uint) {
        uint pendingBNBReward = getPendingBNBReward(_borrower);
        uint pendingUSDSDebtReward = getPendingUSDSDebtReward(_borrower);

        return (
            Troves[_borrower].coll.add(pendingBNBReward),
            Troves[_borrower].debt.add(pendingUSDSDebtReward)
        );
    }

    function applyPendingRewards(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        return _applyPendingRewards(activePool, defaultPool, _borrower);
    }

    // Add the borrowers's coll and debt rewards earned from redistributions, to their Trove
    function _applyPendingRewards(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        address _borrower
    ) internal {
        if (hasPendingRewards(_borrower)) {
            _requireTroveIsActive(_borrower);

            // Compute pending rewards
            uint pendingBNBReward = getPendingBNBReward(_borrower);
            uint pendingUSDSDebtReward = getPendingUSDSDebtReward(_borrower);

            // Apply pending rewards to trove's state
            Troves[_borrower].coll = Troves[_borrower].coll.add(pendingBNBReward);
            Troves[_borrower].debt = Troves[_borrower].debt.add(pendingUSDSDebtReward);

            _updateTroveRewardSnapshots(_borrower);

            // Transfer from DefaultPool to ActivePool
            _movePendingTroveRewardsToActivePool(
                _activePool,
                _defaultPool,
                pendingUSDSDebtReward,
                pendingBNBReward
            );

            emit TroveUpdated(
                _borrower,
                Troves[_borrower].debt,
                Troves[_borrower].coll,
                Troves[_borrower].stake,
                TroveManagerOperation.applyPendingRewards
            );
        }
    }

    // Update borrower's snapshots of L_BNB and L_USDSDebt to reflect the current values
    function updateTroveRewardSnapshots(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        return _updateTroveRewardSnapshots(_borrower);
    }

    function _updateTroveRewardSnapshots(address _borrower) internal {
        rewardSnapshots[_borrower].BNB = L_BNB;
        rewardSnapshots[_borrower].USDSDebt = L_USDSDebt;
        emit TroveSnapshotsUpdated(L_BNB, L_USDSDebt);
    }

    // Get the borrower's pending accumulated BNB reward, earned by their stake
    function getPendingBNBReward(address _borrower) public view override returns (uint) {
        uint snapshotBNB = rewardSnapshots[_borrower].BNB;
        uint rewardPerUnitStaked = L_BNB.sub(snapshotBNB);

        if (rewardPerUnitStaked == 0 || Troves[_borrower].status != Status.active) {
            return 0;
        }

        uint stake = Troves[_borrower].stake;

        uint pendingBNBReward = stake.mul(rewardPerUnitStaked).div(DECIMAL_PRECISION);

        return pendingBNBReward;
    }

    // Get the borrower's pending accumulated USDS reward, earned by their stake
    function getPendingUSDSDebtReward(address _borrower) public view override returns (uint) {
        uint snapshotUSDSDebt = rewardSnapshots[_borrower].USDSDebt;
        uint rewardPerUnitStaked = L_USDSDebt.sub(snapshotUSDSDebt);

        if (rewardPerUnitStaked == 0 || Troves[_borrower].status != Status.active) {
            return 0;
        }

        uint stake = Troves[_borrower].stake;

        uint pendingUSDSDebtReward = stake.mul(rewardPerUnitStaked).div(DECIMAL_PRECISION);

        return pendingUSDSDebtReward;
    }

    function hasPendingRewards(address _borrower) public view override returns (bool) {
        /*
         * A Trove has pending rewards if its snapshot is less than the current rewards per-unit-staked sum:
         * this indicates that rewards have occured since the snapshot was made, and the user therefore has
         * pending rewards
         */
        if (Troves[_borrower].status != Status.active) {
            return false;
        }

        return (rewardSnapshots[_borrower].BNB < L_BNB);
    }

    // Return the Troves entire debt and coll, including pending rewards from redistributions.
    function getEntireDebtAndColl(
        address _borrower
    )
        public
        view
        override
        returns (uint debt, uint coll, uint pendingUSDSDebtReward, uint pendingBNBReward)
    {
        debt = Troves[_borrower].debt;
        coll = Troves[_borrower].coll;

        pendingUSDSDebtReward = getPendingUSDSDebtReward(_borrower);
        pendingBNBReward = getPendingBNBReward(_borrower);

        debt = debt.add(pendingUSDSDebtReward);
        coll = coll.add(pendingBNBReward);
    }

    function removeStake(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        return _removeStake(_borrower);
    }

    // Remove borrower's stake from the totalStakes sum, and set their stake to 0
    function _removeStake(address _borrower) internal {
        // uint stake = Troves[_borrower].stake;
        totalStakes = totalStakes.sub(Troves[_borrower].stake);
        Troves[_borrower].stake = 0;
    }

    function updateStakeAndTotalStakes(address _borrower) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        return _updateStakeAndTotalStakes(_borrower);
    }

    // Update borrower's stake based on their latest collateral value
    function _updateStakeAndTotalStakes(address _borrower) internal returns (uint) {
        uint newStake = _computeNewStake(Troves[_borrower].coll);
        uint oldStake = Troves[_borrower].stake;
        Troves[_borrower].stake = newStake;

        totalStakes = totalStakes.sub(oldStake).add(newStake);
        emit TotalStakesUpdated(totalStakes);

        return newStake;
    }

    // Calculate a new stake based on the snapshots of the totalStakes and totalCollateral taken at the last liquidation
    function _computeNewStake(uint _coll) internal view returns (uint) {
        uint stake;
        if (totalCollateralSnapshot == 0) {
            stake = _coll;
        } else {
            /*
             * The following assert() holds true because:
             * - The system always contains >= 1 trove
             * - When we close or liquidate a trove, we redistribute the pending rewards, so if all troves were closed/liquidated,
             * rewards would’ve been emptied and totalCollateralSnapshot would be zero too.
             */
            assert(totalStakesSnapshot > 0);
            stake = _coll.mul(totalStakesSnapshot).div(totalCollateralSnapshot);
        }
        return stake;
    }

    function _redistributeDebtAndColl(
        IActivePool _activePool,
        IDefaultPool _defaultPool,
        uint _debt,
        uint _coll
    ) internal {
        if (_debt == 0) {
            return;
        }

        /*
         * Add distributed coll and debt rewards-per-unit-staked to the running totals. Division uses a "feedback"
         * error correction, to keep the cumulative error low in the running totals L_BNB and L_USDSDebt:
         *
         * 1) Form numerators which compensate for the floor division errors that occurred the last time this
         * function was called.
         * 2) Calculate "per-unit-staked" ratios.
         * 3) Multiply each ratio back by its denominator, to reveal the current floor division error.
         * 4) Store these errors for use in the next correction when this function is called.
         * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
         */
        uint BNBNumerator = _coll.mul(DECIMAL_PRECISION).add(lastBNBError_Redistribution);
        uint USDSDebtNumerator = _debt.mul(DECIMAL_PRECISION).add(lastUSDSDebtError_Redistribution);

        // Get the per-unit-staked terms
        uint BNBRewardPerUnitStaked = BNBNumerator.div(totalStakes);
        uint USDSDebtRewardPerUnitStaked = USDSDebtNumerator.div(totalStakes);

        lastBNBError_Redistribution = BNBNumerator.sub(BNBRewardPerUnitStaked.mul(totalStakes));
        lastUSDSDebtError_Redistribution = USDSDebtNumerator.sub(
            USDSDebtRewardPerUnitStaked.mul(totalStakes)
        );

        // Add per-unit-staked terms to the running totals
        L_BNB = L_BNB.add(BNBRewardPerUnitStaked);
        L_USDSDebt = L_USDSDebt.add(USDSDebtRewardPerUnitStaked);

        emit LTermsUpdated(L_BNB, L_USDSDebt);

        // Transfer coll and debt from ActivePool to DefaultPool
        _activePool.decreaseUSDSDebt(_debt);
        _defaultPool.increaseUSDSDebt(_debt);
        _activePool.sendBNB(address(_defaultPool), _coll);
    }

    function closeTrove(address _borrower) external override {
        _requireCallerIsBorrowerOperations();
        return _closeTrove(_borrower, Status.closedByOwner);
    }

    function _closeTrove(address _borrower, Status closedStatus) internal {
        assert(closedStatus != Status.nonExistent && closedStatus != Status.active);

        uint TroveOwnersArrayLength = TroveOwners.length;
        troveHelper.requireMoreThanOneTroveInSystem(TroveOwnersArrayLength);

        Troves[_borrower].status = closedStatus;
        Troves[_borrower].coll = 0;
        Troves[_borrower].debt = 0;

        rewardSnapshots[_borrower].BNB = 0;
        rewardSnapshots[_borrower].USDSDebt = 0;

        _removeTroveOwner(_borrower, TroveOwnersArrayLength);
        sortedTroves.remove(_borrower);
    }

    /*
     * Updates snapshots of system total stakes and total collateral, excluding a given collateral remainder from the calculation.
     * Used in a liquidation sequence.
     *
     * The calculation excludes a portion of collateral that is in the ActivePool:
     *
     * the total BNB gas compensation from the liquidation sequence
     *
     * The BNB as compensation must be excluded as it is always sent out at the very end of the liquidation sequence.
     */
    function _updateSystemSnapshots_excludeCollRemainder(
        IActivePool _activePool,
        uint _collRemainder
    ) internal {
        totalStakesSnapshot = totalStakes;

        totalCollateralSnapshot = _activePool.getBNB().sub(_collRemainder).add(defaultPool.getBNB());

        emit SystemSnapshotsUpdated(totalStakesSnapshot, totalCollateralSnapshot);
    }

    // Push the owner's address to the Trove owners list, and record the corresponding array index on the Trove struct
    function addTroveOwnerToArray(address _borrower) external override returns (uint index) {
        _requireCallerIsBorrowerOperations();
        /* Max array size is 2**128 - 1, i.e. ~3e30 troves. No risk of overflow, since troves have minimum USDS
        debt of liquidation reserve plus MIN_NET_DEBT. 3e30 USDS dwarfs the value of all wealth in the world ( which is < 1e15 USD). */

        // Push the Troveowner to the array
        TroveOwners.push(_borrower);

        // Record the index of the new Troveowner on their Trove struct
        uint128 idx = uint128(TroveOwners.length.sub(1));
        Troves[_borrower].arrayIndex = idx;

        index = uint(idx);
        return index;
    }

    /*
     * Remove a Trove owner from the TroveOwners array, not preserving array order. Removing owner 'B' does the following:
     * [A B C D E] => [A E C D], and updates E's Trove struct to point to its new array index.
     */
    function _removeTroveOwner(address _borrower, uint TroveOwnersArrayLength) internal {
        Status troveStatus = Troves[_borrower].status;
        // It’s set in caller function `_closeTrove`
        assert(troveStatus != Status.nonExistent && troveStatus != Status.active);

        uint128 index = Troves[_borrower].arrayIndex;
        uint idxLast = TroveOwnersArrayLength.sub(1);

        assert(index <= idxLast);

        address addressToMove = TroveOwners[idxLast];

        TroveOwners[index] = addressToMove;
        Troves[addressToMove].arrayIndex = index;
        emit TroveIndexUpdated(addressToMove, index);

        TroveOwners.pop();
    }

    // --- Recovery Mode and TCR functions ---

    function getTCR(uint _price) external view override returns (uint) {
        return _getTCR(_price);
    }

    function checkRecoveryMode(uint _price) external view override returns (bool) {
        return _checkRecoveryMode(_price);
    }

    // Check whether or not the system *would be* in Recovery Mode, given an BNB:USD price, and the entire system coll and debt.
    function _checkPotentialRecoveryMode(
        uint _entireSystemColl,
        uint _entireSystemDebt,
        uint _price
    ) internal view returns (bool) {
        return
            LiquityMath._computeCR(_entireSystemColl, _entireSystemDebt, _price) <
            systemState.getCCR();
    }

    // --- Redemption fee functions ---

    /*
     * This function has two impacts on the baseRate state variable:
     * 1) decays the baseRate based on time passed since last redemption or USDS borrowing operation.
     * then,
     * 2) increases the baseRate based on the amount redeemed, as a proportion of total supply
     */
    function _updateBaseRateFromRedemption(
        uint _BNBDrawn,
        uint _price,
        uint _totalUSDSSupply
    ) internal returns (uint) {
        /* Convert the drawn BNB back to USDS at face value rate (1 USDS:1 USD), in order to get
         * the fraction of total supply that was redeemed at face value. */
        uint redeemedUSDSFraction = _BNBDrawn.mul(_price).div(_totalUSDSSupply);

        uint newBaseRate = LiquityMath._min(
            _calcDecayedBaseRate().add(redeemedUSDSFraction.div(BETA)),
            DECIMAL_PRECISION
        );
        //assert(newBaseRate <= DECIMAL_PRECISION); // This is already enforced in the line above
        assert(newBaseRate > 0); // Base rate is always non-zero after redemption

        // Update the baseRate state variable
        baseRate = newBaseRate;
        emit BaseRateUpdated(newBaseRate);

        _updateLastFeeOpTime();

        return newBaseRate;
    }

    function getRedemptionRate(uint _oracleRate) public view override returns (uint) {
        return _calcRedemptionRate(baseRate, _oracleRate);
    }

    function getRedemptionRateWithDecay(uint _oracleRate) public view override returns (uint) {
        return _calcRedemptionRate(_calcDecayedBaseRate(), _oracleRate);
    }

    function _calcRedemptionRate(uint _baseRate, uint _oracleRate) internal view returns (uint) {
        return
            LiquityMath._min(
                systemState.getRedemptionFeeFloor().add(_baseRate).add(_oracleRate),
                DECIMAL_PRECISION // cap at a maximum of 100%
            );
    }

    function _getRedemptionFee(uint _BNBDrawn, uint _oracleRate) internal view returns (uint) {
        return _calcRedemptionFee(getRedemptionRate(_oracleRate), _BNBDrawn);
    }

    function getRedemptionFeeWithDecay(
        uint _BNBDrawn,
        uint _oracleRate
    ) external view override returns (uint) {
        return _calcRedemptionFee(getRedemptionRateWithDecay(_oracleRate), _BNBDrawn);
    }

    function _calcRedemptionFee(uint _redemptionRate, uint _BNBDrawn) internal pure returns (uint) {
        uint redemptionFee = _redemptionRate.mul(_BNBDrawn).div(DECIMAL_PRECISION);
        require(redemptionFee < _BNBDrawn, "5");
        return redemptionFee;
    }

    // --- Borrowing fee functions ---

    function getBorrowingRate(uint _oracleRate) public view override returns (uint) {
        return _calcBorrowingRate(baseRate, _oracleRate);
    }

    function getBorrowingRateWithDecay(uint _oracleRate) public view override returns (uint) {
        return _calcBorrowingRate(_calcDecayedBaseRate(), _oracleRate);
    }

    function _calcBorrowingRate(uint _baseRate, uint _oracleRate) internal view returns (uint) {
        return
            LiquityMath._min(
                systemState.getBorrowingFeeFloor().add(_baseRate).add(_oracleRate),
                MAX_BORROWING_FEE
            );
    }

    function getBorrowingFee(
        uint _USDSDebt,
        uint _oracleRate
    ) external view override returns (uint) {
        return _calcBorrowingFee(getBorrowingRate(_oracleRate), _USDSDebt);
    }

    function getBorrowingFeeWithDecay(
        uint _USDSDebt,
        uint _oracleRate
    ) external view override returns (uint) {
        return _calcBorrowingFee(getBorrowingRateWithDecay(_oracleRate), _USDSDebt);
    }

    function _calcBorrowingFee(uint _borrowingRate, uint _USDSDebt) internal pure returns (uint) {
        return _borrowingRate.mul(_USDSDebt).div(DECIMAL_PRECISION);
    }

    // Updates the baseRate state variable based on time elapsed since the last redemption or USDS borrowing operation.
    function decayBaseRateFromBorrowing() external override {
        _requireCallerIsBorrowerOperations();

        uint decayedBaseRate = _calcDecayedBaseRate();
        assert(decayedBaseRate <= DECIMAL_PRECISION); // The baseRate can decay to 0

        baseRate = decayedBaseRate;
        emit BaseRateUpdated(decayedBaseRate);

        _updateLastFeeOpTime();
    }

    // --- Internal fee functions ---

    // Update the last fee operation time only if time passed >= decay interval. This prevents base rate griefing.
    function _updateLastFeeOpTime() internal {
        uint timePassed = block.timestamp.sub(lastFeeOperationTime);

        if (timePassed >= SECONDS_IN_ONE_MINUTE) {
            lastFeeOperationTime = block.timestamp;
            emit LastFeeOpTimeUpdated(block.timestamp);
        }
    }

    function _calcDecayedBaseRate() internal view returns (uint) {
        uint minutesPassed = (block.timestamp.sub(lastFeeOperationTime)).div(SECONDS_IN_ONE_MINUTE);
        uint decayFactor = LiquityMath._decPow(MINUTE_DECAY_FACTOR, minutesPassed);

        return baseRate.mul(decayFactor).div(DECIMAL_PRECISION);
    }

    // --- 'require' wrapper functions ---

    function _requireCallerIsBorrowerOperations() internal view {
        require(msg.sender == borrowerOperationsAddress, "6");
    }

    function _requireTroveIsActive(address _borrower) internal view {
        require(Troves[_borrower].status == Status.active, "7");
    }

    // --- Trove property getters ---

    function getTroveStatus(address _borrower) external view override returns (uint) {
        return uint(Troves[_borrower].status);
    }

    function getTroveStake(address _borrower) external view override returns (uint) {
        return Troves[_borrower].stake;
    }

    function getTroveDebt(address _borrower) external view override returns (uint) {
        return Troves[_borrower].debt;
    }

    function getTroveColl(address _borrower) external view override returns (uint) {
        return Troves[_borrower].coll;
    }

    // --- Trove property setters, called by BorrowerOperations ---

    function setTroveStatus(address _borrower, uint _num) external override {
        _requireCallerIsBorrowerOperations();
        Troves[_borrower].status = Status(_num);
    }

    function increaseTroveColl(
        address _borrower,
        uint _collIncrease
    ) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        uint newColl = Troves[_borrower].coll.add(_collIncrease);
        Troves[_borrower].coll = newColl;
        return newColl;
    }

    function decreaseTroveColl(
        address _borrower,
        uint _collDecrease
    ) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        uint newColl = Troves[_borrower].coll.sub(_collDecrease);
        Troves[_borrower].coll = newColl;
        return newColl;
    }

    function increaseTroveDebt(
        address _borrower,
        uint _debtIncrease
    ) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        uint newDebt = Troves[_borrower].debt.add(_debtIncrease);
        Troves[_borrower].debt = newDebt;
        return newDebt;
    }

    function decreaseTroveDebt(
        address _borrower,
        uint _debtDecrease
    ) external override returns (uint) {
        _requireCallerIsBorrowerOperations();
        uint newDebt = Troves[_borrower].debt.sub(_debtDecrease);
        Troves[_borrower].debt = newDebt;
        return newDebt;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./Interfaces/IBorrowerOperations.sol";
import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IUSDSToken.sol";
import "./Interfaces/ICollSurplusPool.sol";
import "./Interfaces/ISortedTroves.sol";
import "./Interfaces/ISableStakingV2.sol";
import "./Interfaces/IOracleRateCalculation.sol";
import "./Dependencies/LiquityBase.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";

contract BorrowerOperations is LiquityBase, Ownable, CheckContract, IBorrowerOperations {
    string public constant NAME = "BorrowerOperations";

    // --- Connected contract declarations ---

    ITroveManager public troveManager;

    address stabilityPoolAddress;

    address gasPoolAddress;

    ICollSurplusPool collSurplusPool;

    ISableStakingV2 public sableStaking;
    address public sableStakingAddress;

    IUSDSToken public usdsToken;

    // A doubly linked list of Troves, sorted by their collateral ratios
    ISortedTroves public sortedTroves;

    // Oracle rate calculation contract
    IOracleRateCalculation public oracleRateCalc;

    /* --- Variable container structs  ---

    Used to hold, return and assign variables inside a function, in order to avoid the error:
    "CompilerError: Stack too deep". */

    struct LocalVariables_adjustTrove {
        uint price;
        uint collChange;
        uint netDebtChange;
        bool isCollIncrease;
        uint debt;
        uint coll;
        uint oldICR;
        uint newICR;
        uint newTCR;
        uint USDSFee;
        uint newDebt;
        uint newColl;
        uint stake;
    }

    struct LocalVariables_openTrove {
        uint price;
        uint USDSFee;
        uint netDebt;
        uint compositeDebt;
        uint ICR;
        uint NICR;
        uint stake;
        uint arrayIndex;
    }

    struct ContractsCache {
        ITroveManager troveManager;
        IActivePool activePool;
        IUSDSToken usdsToken;
    }

    struct MoveTokensAndBNBFromAdjustmentParam {
        IActivePool activePool;
        IUSDSToken usdsToken;
        bool isCollIncrease;
        bool isDebtIncrease;
        address borrower;
        uint collChange;
        uint USDSChange;
        uint netDebtChange;
    }

    enum BorrowerOperation {
        openTrove,
        closeTrove,
        adjustTrove
    }

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event USDSTokenAddressChanged(address _usdsTokenAddress);
    event SableStakingAddressChanged(address _sableStakingAddress);
    event SystemStateAddressChanged(address _systemStateAddress);
    event OracleRateCalcAddressChanged(address _oracleRateCalcAddress);

    event TroveCreated(address indexed _borrower, uint arrayIndex);
    event TroveUpdated(
        address indexed _borrower,
        uint _debt,
        uint _coll,
        uint stake,
        BorrowerOperation operation
    );
    event USDSBorrowingFeePaid(address indexed _borrower, uint _USDSFee);

    // --- Dependency setters ---

    function setAddresses(DependencyAddressParam memory param) external override onlyOwner {
        checkContract(param.troveManagerAddress);
        checkContract(param.activePoolAddress);
        checkContract(param.defaultPoolAddress);
        checkContract(param.stabilityPoolAddress);
        checkContract(param.gasPoolAddress);
        checkContract(param.collSurplusPoolAddress);
        checkContract(param.priceFeedAddress);
        checkContract(param.sortedTrovesAddress);
        checkContract(param.usdsTokenAddress);
        checkContract(param.sableStakingAddress);
        checkContract(param.systemStateAddress);
        checkContract(param.oracleRateCalcAddress);

        troveManager = ITroveManager(param.troveManagerAddress);
        activePool = IActivePool(param.activePoolAddress);
        defaultPool = IDefaultPool(param.defaultPoolAddress);
        stabilityPoolAddress = param.stabilityPoolAddress;
        gasPoolAddress = param.gasPoolAddress;
        collSurplusPool = ICollSurplusPool(param.collSurplusPoolAddress);
        priceFeed = IPriceFeed(param.priceFeedAddress);
        sortedTroves = ISortedTroves(param.sortedTrovesAddress);
        usdsToken = IUSDSToken(param.usdsTokenAddress);
        sableStakingAddress = param.sableStakingAddress;
        sableStaking = ISableStakingV2(param.sableStakingAddress);
        systemState = ISystemState(param.systemStateAddress);
        oracleRateCalc = IOracleRateCalculation(param.oracleRateCalcAddress);



        emit TroveManagerAddressChanged(param.troveManagerAddress);
        emit ActivePoolAddressChanged(param.activePoolAddress);
        emit DefaultPoolAddressChanged(param.defaultPoolAddress);
        emit StabilityPoolAddressChanged(param.stabilityPoolAddress);
        emit GasPoolAddressChanged(param.gasPoolAddress);
        emit CollSurplusPoolAddressChanged(param.collSurplusPoolAddress);
        emit PriceFeedAddressChanged(param.priceFeedAddress);
        emit SortedTrovesAddressChanged(param.sortedTrovesAddress);
        emit USDSTokenAddressChanged(param.usdsTokenAddress);
        emit SableStakingAddressChanged(param.sableStakingAddress);
        emit SystemStateAddressChanged(param.systemStateAddress);
        emit OracleRateCalcAddressChanged(param.oracleRateCalcAddress);

        _renounceOwnership();
    }

    // --- Borrower Trove Operations ---

    function openTrove(
        uint _maxFeePercentage,
        uint _USDSAmount,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable override {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, usdsToken);
        LocalVariables_openTrove memory vars;

        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(priceFeedUpdateData);
        vars.price = fetchPriceResult.price;

        // calculate oracleRate
        uint oracleRate = oracleRateCalc.getOracleRate(
            fetchPriceResult.oracleKey, 
            fetchPriceResult.deviationPyth, 
            fetchPriceResult.publishTimePyth
        );

        bool isRecoveryMode = _checkRecoveryMode(vars.price);

        _requireValidMaxFeePercentage(_maxFeePercentage, isRecoveryMode);
        _requireTroveisNotActive(contractsCache.troveManager, msg.sender);

        vars.USDSFee;
        vars.netDebt = _USDSAmount;

        TriggerBorrowingFeeParam memory triggerBorrowingFeeParam = TriggerBorrowingFeeParam({
            troveManager: contractsCache.troveManager,
            usdsToken: contractsCache.usdsToken,
            USDSAmount: _USDSAmount,
            maxFeePercentage: _maxFeePercentage,
            oracleRate: oracleRate
        });

        if (!isRecoveryMode) {
            vars.USDSFee = _triggerBorrowingFee(triggerBorrowingFeeParam);
            vars.netDebt = vars.netDebt.add(vars.USDSFee);
        }
        _requireAtLeastMinNetDebt(vars.netDebt);

        // ICR is based on the composite debt, i.e. the requested USDS amount + USDS borrowing fee + USDS gas comp.
        vars.compositeDebt = _getCompositeDebt(vars.netDebt);
        assert(vars.compositeDebt > 0);

        uint collateral = msg.value;

        vars.ICR = LiquityMath._computeCR(collateral, vars.compositeDebt, vars.price);
        vars.NICR = LiquityMath._computeNominalCR(collateral, vars.compositeDebt);

        if (isRecoveryMode) {
            _requireICRisAboveCCR(vars.ICR);
        } else {
            _requireICRisAboveMCR(vars.ICR);
            uint newTCR = _getNewTCRFromTroveChange(
                collateral,
                true,
                vars.compositeDebt,
                true,
                vars.price
            ); // bools: coll increase, debt increase
            _requireNewTCRisAboveCCR(newTCR);
        }

        {
            // Set the trove struct's properties
            contractsCache.troveManager.setTroveStatus(msg.sender, 1);
            contractsCache.troveManager.increaseTroveColl(msg.sender, collateral);
            contractsCache.troveManager.increaseTroveDebt(msg.sender, vars.compositeDebt);

            contractsCache.troveManager.updateTroveRewardSnapshots(msg.sender);
            vars.stake = contractsCache.troveManager.updateStakeAndTotalStakes(msg.sender);

            ISortedTroves.SortedTrovesInsertParam memory sortedTrovesInsertParam = ISortedTroves.SortedTrovesInsertParam({
                id: msg.sender,
                newNICR: vars.NICR,
                prevId: _upperHint,
                nextId: _lowerHint
            });
            sortedTroves.insert(sortedTrovesInsertParam);
            vars.arrayIndex = contractsCache.troveManager.addTroveOwnerToArray(msg.sender);
            emit TroveCreated(msg.sender, vars.arrayIndex);
        }

        {
            // Move the ether to the Active Pool, and mint the USDSAmount to the borrower
            _activePoolAddColl(contractsCache.activePool, collateral);
            
            WithdrawUSDSParam memory withdrawParam1 = WithdrawUSDSParam({
                activePool: contractsCache.activePool,
                usdsToken: contractsCache.usdsToken,
                account: msg.sender,
                USDSAmount: _USDSAmount,
                netDebtIncrease: vars.netDebt
            });

            _withdrawUSDS(withdrawParam1);
            // Move the USDS gas compensation to the Gas Pool
            uint USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();

            WithdrawUSDSParam memory withdrawParam2 = WithdrawUSDSParam({
                activePool: contractsCache.activePool,
                usdsToken: contractsCache.usdsToken,
                account: gasPoolAddress,
                USDSAmount: USDS_GAS_COMPENSATION,
                netDebtIncrease: USDS_GAS_COMPENSATION
            });
            _withdrawUSDS(withdrawParam2);

            emit TroveUpdated(
                msg.sender,
                vars.compositeDebt,
                collateral,
                vars.stake,
                BorrowerOperation.openTrove
            );
            emit USDSBorrowingFeePaid(msg.sender, vars.USDSFee);
        }
    }

    // Send BNB as collateral to a trove
    function addColl(
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable override {
        AdjustTroveParam memory adjustTroveParam = AdjustTroveParam({
            collWithdrawal: 0,
            USDSChange: 0,
            isDebtIncrease: false,
            upperHint: _upperHint,
            lowerHint: _lowerHint,
            maxFeePercentage: 0
        });
        _adjustTrove(msg.sender, adjustTroveParam, priceFeedUpdateData);
    }

    // Send BNB as collateral to a trove. Called by only the Stability Pool.
    function moveBNBGainToTrove(
        address _borrower,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable override {
        _requireCallerIsStabilityPool();
        AdjustTroveParam memory adjustTroveParam = AdjustTroveParam({
            collWithdrawal: 0,
            USDSChange: 0,
            isDebtIncrease: false,
            upperHint: _upperHint,
            lowerHint: _lowerHint,
            maxFeePercentage: 0
        });
        _adjustTrove(_borrower, adjustTroveParam, priceFeedUpdateData);
    }

    // Withdraw BNB collateral from a trove
    function withdrawColl(
        uint _collWithdrawal,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        AdjustTroveParam memory adjustTroveParam = AdjustTroveParam({
            collWithdrawal: _collWithdrawal,
            USDSChange: 0,
            isDebtIncrease: false,
            upperHint: _upperHint,
            lowerHint: _lowerHint,
            maxFeePercentage: 0
        });
        _adjustTrove(msg.sender, adjustTroveParam, priceFeedUpdateData);
    }

    // Withdraw USDS tokens from a trove: mint new USDS tokens to the owner, and increase the trove's debt accordingly
    function withdrawUSDS(
        uint _maxFeePercentage,
        uint _USDSAmount,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        AdjustTroveParam memory adjustTroveParam = AdjustTroveParam({
            collWithdrawal: 0,
            USDSChange: _USDSAmount,
            isDebtIncrease: true,
            upperHint: _upperHint,
            lowerHint: _lowerHint,
            maxFeePercentage: _maxFeePercentage
        });
        _adjustTrove(msg.sender, adjustTroveParam, priceFeedUpdateData);
    }

    // Repay USDS tokens to a Trove: Burn the repaid USDS tokens, and reduce the trove's debt accordingly
    function repayUSDS(
        uint _USDSAmount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        AdjustTroveParam memory adjustTroveParam = AdjustTroveParam({
            collWithdrawal: 0,
            USDSChange: _USDSAmount,
            isDebtIncrease: false,
            upperHint: _upperHint,
            lowerHint: _lowerHint,
            maxFeePercentage: 0
        });
        _adjustTrove(msg.sender, adjustTroveParam, priceFeedUpdateData);
    }

    function adjustTrove(
        AdjustTroveParam memory adjustParam,
        bytes[] calldata priceFeedUpdateData
    ) external payable override {
        _adjustTrove(
            msg.sender,
            adjustParam,
            priceFeedUpdateData
        );
    }

    /*
     * _adjustTrove(): Alongside a debt change, this function can perform either a collateral top-up or a collateral withdrawal.
     *
     * It therefore expects either a positive msg.value, or a positive _collWithdrawal argument.
     *
     * If both are positive, it will revert.
     */

    function _adjustTrove(
        address _borrower,
        AdjustTroveParam memory adjustTroveParam,
        bytes[] calldata priceFeedUpdateData
    ) internal {
        ContractsCache memory contractsCache = ContractsCache(troveManager, activePool, usdsToken);
        LocalVariables_adjustTrove memory vars;

        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(priceFeedUpdateData);
        vars.price = fetchPriceResult.price;

        // calculate oracleRate
        uint oracleRate = oracleRateCalc.getOracleRate(
            fetchPriceResult.oracleKey, 
            fetchPriceResult.deviationPyth, 
            fetchPriceResult.publishTimePyth
        );

        uint collateral = msg.value;

        bool isRecoveryMode = _checkRecoveryMode(vars.price);

        {
            if (adjustTroveParam.isDebtIncrease) {
                _requireValidMaxFeePercentage(adjustTroveParam.maxFeePercentage, isRecoveryMode);
                _requireNonZeroDebtChange(adjustTroveParam.USDSChange);
            }
            _requireSingularCollChange(adjustTroveParam.collWithdrawal);
            _requireNonZeroAdjustment(adjustTroveParam.collWithdrawal, adjustTroveParam.USDSChange);
            
            TroveIsActiveParam memory troveIsActiveParam = TroveIsActiveParam({
                troveManager: contractsCache.troveManager,
                borrower: _borrower
            });
            _requireTroveisActive(troveIsActiveParam);

            // Confirm the operation is either a borrower adjusting their own trove, or a pure BNB transfer from the Stability Pool to a trove
            assert(
                msg.sender == _borrower ||
                    (msg.sender == stabilityPoolAddress && collateral > 0 && adjustTroveParam.USDSChange == 0)
            );

            contractsCache.troveManager.applyPendingRewards(_borrower);
        }

        {
            // Get the collChange based on whether or not BNB was sent in the transaction
            (vars.collChange, vars.isCollIncrease) = _getCollChange(collateral, adjustTroveParam.collWithdrawal);

            vars.netDebtChange = adjustTroveParam.USDSChange;

            TriggerBorrowingFeeParam memory triggerBorrowingFeeParam = TriggerBorrowingFeeParam({
                troveManager: contractsCache.troveManager,
                usdsToken: contractsCache.usdsToken,
                USDSAmount: adjustTroveParam.USDSChange,
                maxFeePercentage: adjustTroveParam.maxFeePercentage,
                oracleRate: oracleRate
            });

            // If the adjustment incorporates a debt increase and system is in Normal Mode, then trigger a borrowing fee
            if (adjustTroveParam.isDebtIncrease && !isRecoveryMode) {
                vars.USDSFee = _triggerBorrowingFee(triggerBorrowingFeeParam);
                vars.netDebtChange = vars.netDebtChange.add(vars.USDSFee); // The raw debt change includes the fee
            }

            vars.debt = contractsCache.troveManager.getTroveDebt(_borrower);
            vars.coll = contractsCache.troveManager.getTroveColl(_borrower);

            // Get the trove's old ICR before the adjustment, and what its new ICR will be after the adjustment
            vars.oldICR = LiquityMath._computeCR(vars.coll, vars.debt, vars.price);

            NewICRFromTroveChangeParam memory newICRParam = NewICRFromTroveChangeParam({
                coll: vars.coll,
                debt: vars.debt,
                collChange: vars.collChange,
                isCollIncrease: vars.isCollIncrease,
                debtChange: vars.netDebtChange,
                isDebtIncrease: adjustTroveParam.isDebtIncrease,
                price: vars.price
            });
            vars.newICR = _getNewICRFromTroveChange(newICRParam);
            assert(adjustTroveParam.collWithdrawal <= vars.coll);

            // Check the adjustment satisfies all conditions for the current system mode
            _requireValidAdjustmentInCurrentMode(isRecoveryMode, adjustTroveParam.collWithdrawal, adjustTroveParam.isDebtIncrease, vars);

            // When the adjustment is a debt repayment, check it's a valid amount and that the caller has enough USDS
            if (!adjustTroveParam.isDebtIncrease && adjustTroveParam.USDSChange > 0) {
                _requireAtLeastMinNetDebt(_getNetDebt(vars.debt).sub(vars.netDebtChange));
                _requireValidUSDSRepayment(vars.debt, vars.netDebtChange);
                _requireSufficientUSDSBalance(contractsCache.usdsToken, _borrower, vars.netDebtChange);
            }
        }

        {
            UpdateTroveFromAdjustmentParam memory updateTroveFromAdjustmentParam = UpdateTroveFromAdjustmentParam({
                troveManager: contractsCache.troveManager,
                borrower: _borrower,
                collChange: vars.collChange,
                isCollIncrease: vars.isCollIncrease,
                debtChange: vars.netDebtChange,
                isDebtIncrease: adjustTroveParam.isDebtIncrease
            });

            (vars.newColl, vars.newDebt) = _updateTroveFromAdjustment(updateTroveFromAdjustmentParam);
            vars.stake = contractsCache.troveManager.updateStakeAndTotalStakes(_borrower);
        }

        {
            // Re-insert trove in to the sorted list
            NewNomialICRFromTroveChangeParam memory newNomialICRFromTroveChangeParam = NewNomialICRFromTroveChangeParam({
                coll: vars.coll,
                debt: vars.debt,
                collChange: vars.collChange,
                isCollIncrease: vars.isCollIncrease,
                debtChange: vars.netDebtChange,
                isDebtIncrease: adjustTroveParam.isDebtIncrease
            });
            uint newNICR = _getNewNominalICRFromTroveChange(newNomialICRFromTroveChangeParam);

            ISortedTroves.SortedTrovesInsertParam memory sortedTrovesParam = ISortedTroves.SortedTrovesInsertParam({
                id: _borrower,
                newNICR: newNICR,
                prevId: adjustTroveParam.upperHint,
                nextId: adjustTroveParam.lowerHint
            });
            sortedTroves.reInsert(sortedTrovesParam);
        }

        emit TroveUpdated(
            _borrower,
            vars.newDebt,
            vars.newColl,
            vars.stake,
            BorrowerOperation.adjustTrove
        );
        emit USDSBorrowingFeePaid(msg.sender, vars.USDSFee);

        // Use the unmodified _USDSChange here, as we don't send the fee to the user

        MoveTokensAndBNBFromAdjustmentParam memory moveParam = MoveTokensAndBNBFromAdjustmentParam({
            activePool: contractsCache.activePool,
            usdsToken: contractsCache.usdsToken,
            borrower: msg.sender,
            collChange: vars.collChange,
            isCollIncrease: vars.isCollIncrease,
            USDSChange: adjustTroveParam.USDSChange,
            isDebtIncrease: adjustTroveParam.isDebtIncrease,
            netDebtChange: vars.netDebtChange
        });

        _moveTokensAndBNBfromAdjustment(moveParam);
    }

    function closeTrove(bytes[] calldata priceFeedUpdateData) external override {
        ITroveManager troveManagerCached = troveManager;
        IActivePool activePoolCached = activePool;
        IUSDSToken usdsTokenCached = usdsToken;

        TroveIsActiveParam memory troveIsActiveParam = TroveIsActiveParam({
            troveManager: troveManagerCached,
            borrower: msg.sender
        });
        _requireTroveisActive(troveIsActiveParam);
        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(priceFeedUpdateData);
        _requireNotInRecoveryMode(fetchPriceResult.price);

        troveManagerCached.applyPendingRewards(msg.sender);

        uint coll = troveManagerCached.getTroveColl(msg.sender);
        uint debt = troveManagerCached.getTroveDebt(msg.sender);

        uint USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();

        _requireSufficientUSDSBalance(usdsTokenCached, msg.sender, debt.sub(USDS_GAS_COMPENSATION));

        uint newTCR = _getNewTCRFromTroveChange(coll, false, debt, false, fetchPriceResult.price);
        _requireNewTCRisAboveCCR(newTCR);

        troveManagerCached.removeStake(msg.sender);
        troveManagerCached.closeTrove(msg.sender);

        emit TroveUpdated(msg.sender, 0, 0, 0, BorrowerOperation.closeTrove);

        // Burn the repaid USDS from the user's balance and the gas compensation from the Gas Pool
        _repayUSDS(activePoolCached, usdsTokenCached, msg.sender, debt.sub(USDS_GAS_COMPENSATION));
        _repayUSDS(activePoolCached, usdsTokenCached, gasPoolAddress, USDS_GAS_COMPENSATION);

        // Send the collateral back to the user
        activePoolCached.sendBNB(msg.sender, coll);
    }

    /**
     * Claim remaining collateral from a redemption or from a liquidation with ICR > MCR in Recovery Mode
     */
    function claimCollateral() external override {
        // send BNB from CollSurplus Pool to owner
        collSurplusPool.claimColl(msg.sender);
    }

    // --- Helper functions ---

    function _triggerBorrowingFee(TriggerBorrowingFeeParam memory param) internal returns (uint) {
        param.troveManager.decayBaseRateFromBorrowing(); // decay the baseRate state variable
        uint USDSFee = param.troveManager.getBorrowingFee(param.USDSAmount, param.oracleRate);

        _requireUserAcceptsFee(USDSFee, param.USDSAmount, param.maxFeePercentage);

        // Send fee to SABLE staking contract
        sableStaking.increaseF_USDS(USDSFee);
        param.usdsToken.mint(sableStakingAddress, USDSFee);

        return USDSFee;
    }

    function _getUSDValue(uint _coll, uint _price) internal pure returns (uint) {
        uint usdValue = _price.mul(_coll).div(DECIMAL_PRECISION);

        return usdValue;
    }

    function _getCollChange(
        uint _collReceived,
        uint _requestedCollWithdrawal
    ) internal pure returns (uint collChange, bool isCollIncrease) {
        if (_collReceived != 0) {
            collChange = _collReceived;
            isCollIncrease = true;
        } else {
            collChange = _requestedCollWithdrawal;
        }
    }

    // Update trove's coll and debt based on whether they increase or decrease
    function _updateTroveFromAdjustment(UpdateTroveFromAdjustmentParam memory param) internal returns (uint, uint) {
        uint newColl = (param.isCollIncrease)
            ? param.troveManager.increaseTroveColl(param.borrower, param.collChange)
            : param.troveManager.decreaseTroveColl(param.borrower, param.collChange);
        uint newDebt = (param.isDebtIncrease)
            ? param.troveManager.increaseTroveDebt(param.borrower, param.debtChange)
            : param.troveManager.decreaseTroveDebt(param.borrower, param.debtChange);

        return (newColl, newDebt);
    }

    function _moveTokensAndBNBfromAdjustment(MoveTokensAndBNBFromAdjustmentParam memory param) internal {
        if (param.isDebtIncrease) {
            WithdrawUSDSParam memory withdrawParam = WithdrawUSDSParam({
                activePool: param.activePool,
                usdsToken: param.usdsToken,
                account: param.borrower,
                USDSAmount: param.USDSChange,
                netDebtIncrease: param.netDebtChange
            });
            _withdrawUSDS(withdrawParam);
        } else {
            _repayUSDS(param.activePool, param.usdsToken, param.borrower, param.USDSChange);
        }

        if (param.isCollIncrease) {
            _activePoolAddColl(param.activePool, param.collChange);
        } else {
            param.activePool.sendBNB(param.borrower, param.collChange);
        }
    }

    // Send BNB to Active Pool and increase its recorded BNB balance
    function _activePoolAddColl(IActivePool _activePool, uint _amount) internal {
        (bool success, ) = address(_activePool).call{value: _amount}("");
        require(success, "BorrowerOps: Sending BNB to ActivePool failed");
    }

    // Issue the specified amount of USDS to _account and increases the total active debt (_netDebtIncrease potentially includes a USDSFee)

    function _withdrawUSDS(WithdrawUSDSParam memory param) internal {
        param.activePool.increaseUSDSDebt(param.netDebtIncrease);
        param.usdsToken.mint(param.account, param.USDSAmount);
    }

    // Burn the specified amount of USDS from _account and decreases the total active debt
    function _repayUSDS(
        IActivePool _activePool,
        IUSDSToken _usdsToken,
        address _account,
        uint _USDS
    ) internal {
        _activePool.decreaseUSDSDebt(_USDS);
        _usdsToken.burn(_account, _USDS);
    }

    // --- 'Require' wrapper functions ---

    function _requireSingularCollChange(uint _collWithdrawal) internal view {
        require(
            msg.value == 0 || _collWithdrawal == 0,
            "BorrowerOperations: Cannot withdraw and add coll"
        );
    }

    function _requireCallerIsBorrower(address _borrower) internal view {
        require(
            msg.sender == _borrower,
            "BorrowerOps: Caller must be the borrower for a withdrawal"
        );
    }

    function _requireNonZeroAdjustment(uint _collWithdrawal, uint _USDSChange) internal view {
        require(
            msg.value != 0 || _collWithdrawal != 0 || _USDSChange != 0,
            "BorrowerOps: There must be either a collateral change or a debt change"
        );
    }

    function _requireTroveisActive(TroveIsActiveParam memory param) internal view {
        uint status = param.troveManager.getTroveStatus(param.borrower);
        require(status == 1, "BorrowerOps: Trove does not exist or is closed");
    }

    function _requireTroveisNotActive(ITroveManager _troveManager, address _borrower) internal view {
        uint status = _troveManager.getTroveStatus(_borrower);
        require(status != 1, "BorrowerOps: Trove is active");
    }

    function _requireNonZeroDebtChange(uint _USDSChange) internal pure {
        require(_USDSChange > 0, "BorrowerOps: Debt increase requires non-zero debtChange");
    }

    function _requireNotInRecoveryMode(uint _price) internal view {
        require(
            !_checkRecoveryMode(_price),
            "BorrowerOps: Operation not permitted during Recovery Mode"
        );
    }

    function _requireNoCollWithdrawal(uint _collWithdrawal) internal pure {
        require(
            _collWithdrawal == 0,
            "BorrowerOps: Collateral withdrawal not permitted Recovery Mode"
        );
    }

    function _requireValidAdjustmentInCurrentMode(
        bool _isRecoveryMode,
        uint _collWithdrawal,
        bool _isDebtIncrease,
        LocalVariables_adjustTrove memory _vars
    ) internal view {
        /*
         *In Recovery Mode, only allow:
         *
         * - Pure collateral top-up
         * - Pure debt repayment
         * - Collateral top-up with debt repayment
         * - A debt increase combined with a collateral top-up which makes the ICR >= 150% and improves the ICR (and by extension improves the TCR).
         *
         * In Normal Mode, ensure:
         *
         * - The new ICR is above MCR
         * - The adjustment won't pull the TCR below CCR
         */
        if (_isRecoveryMode) {
            _requireNoCollWithdrawal(_collWithdrawal);
            if (_isDebtIncrease) {
                _requireICRisAboveCCR(_vars.newICR);
                _requireNewICRisAboveOldICR(_vars.newICR, _vars.oldICR);
            }
        } else {
            // if Normal Mode
            _requireICRisAboveMCR(_vars.newICR);
            _vars.newTCR = _getNewTCRFromTroveChange(
                _vars.collChange,
                _vars.isCollIncrease,
                _vars.netDebtChange,
                _isDebtIncrease,
                _vars.price
            );
            _requireNewTCRisAboveCCR(_vars.newTCR);
        }
    }

    function _requireICRisAboveMCR(uint _newICR) internal view {
        uint MCR = systemState.getMCR();
        require(
            _newICR >= MCR,
            "BorrowerOps: An operation that would result in ICR < MCR is not permitted"
        );
    }

    function _requireICRisAboveCCR(uint _newICR) internal view {
        uint CCR = systemState.getCCR();
        require(_newICR >= CCR, "BorrowerOps: Operation must leave trove with ICR >= CCR");
    }

    function _requireNewICRisAboveOldICR(uint _newICR, uint _oldICR) internal pure {
        require(
            _newICR >= _oldICR,
            "BorrowerOps: Cannot decrease your Trove's ICR in Recovery Mode"
        );
    }

    function _requireNewTCRisAboveCCR(uint _newTCR) internal view {
        uint CCR = systemState.getCCR();
        require(
            _newTCR >= CCR,
            "BorrowerOps: An operation that would result in TCR < CCR is not permitted"
        );
    }

    function _requireAtLeastMinNetDebt(uint _netDebt) internal view {
        uint MIN_NET_DEBT = systemState.getMinNetDebt();
        require(
            _netDebt >= MIN_NET_DEBT,
            "BorrowerOps: Trove's net debt must be greater than minimum"
        );
    }

    function _requireValidUSDSRepayment(uint _currentDebt, uint _debtRepayment) internal view {
        uint USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();
        require(
            _debtRepayment <= _currentDebt.sub(USDS_GAS_COMPENSATION),
            "BorrowerOps: Amount repaid must not be larger than the Trove's debt"
        );
    }

    function _requireCallerIsStabilityPool() internal view {
        require(msg.sender == stabilityPoolAddress, "BorrowerOps: Caller is not Stability Pool");
    }

    function _requireSufficientUSDSBalance(
        IUSDSToken _usdsToken,
        address _borrower,
        uint _debtRepayment
    ) internal view {
        require(
            _usdsToken.balanceOf(_borrower) >= _debtRepayment,
            "BorrowerOps: Caller doesnt have enough USDS to make repayment"
        );
    }

    function _requireValidMaxFeePercentage(
        uint _maxFeePercentage,
        bool _isRecoveryMode
    ) internal view {
        if (_isRecoveryMode) {
            require(
                _maxFeePercentage <= DECIMAL_PRECISION,
                "Max fee percentage must less than or equal to 100%"
            );
        } else {
            uint BORROWING_FEE_FLOOR = systemState.getBorrowingFeeFloor();
            require(
                _maxFeePercentage >= BORROWING_FEE_FLOOR && _maxFeePercentage <= DECIMAL_PRECISION,
                "Max fee percentage must be between 0.5% and 100%"
            );
        }
    }

    // --- ICR and TCR getters ---

    // Compute the new collateral ratio, considering the change in coll and debt. Assumes 0 pending rewards.
    function _getNewNominalICRFromTroveChange(NewNomialICRFromTroveChangeParam memory param) internal pure returns (uint) {
        (uint newColl, uint newDebt) = _getNewTroveAmounts(
            param.coll,
            param.debt,
            param.collChange,
            param.isCollIncrease,
            param.debtChange,
            param.isDebtIncrease
        );

        uint newNICR = LiquityMath._computeNominalCR(newColl, newDebt);
        return newNICR;
    }

    // Compute the new collateral ratio, considering the change in coll and debt. Assumes 0 pending rewards.
    function _getNewICRFromTroveChange(
        NewICRFromTroveChangeParam memory param
    ) internal pure returns (uint) {
        (uint newColl, uint newDebt) = _getNewTroveAmounts(
            param.coll,
            param.debt,
            param.collChange,
            param.isCollIncrease,
            param.debtChange,
            param.isDebtIncrease
        );

        uint newICR = LiquityMath._computeCR(newColl, newDebt, param.price);
        return newICR;
    }

    function _getNewTroveAmounts(
        uint _coll,
        uint _debt,
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease
    ) internal pure returns (uint, uint) {
        uint newColl = _coll;
        uint newDebt = _debt;

        newColl = _isCollIncrease ? _coll.add(_collChange) : _coll.sub(_collChange);
        newDebt = _isDebtIncrease ? _debt.add(_debtChange) : _debt.sub(_debtChange);

        return (newColl, newDebt);
    }

    function _getNewTCRFromTroveChange(
        uint _collChange,
        bool _isCollIncrease,
        uint _debtChange,
        bool _isDebtIncrease,
        uint _price
    ) internal view returns (uint) {
        uint totalColl = getEntireSystemColl();
        uint totalDebt = getEntireSystemDebt();

        totalColl = _isCollIncrease ? totalColl.add(_collChange) : totalColl.sub(_collChange);
        totalDebt = _isDebtIncrease ? totalDebt.add(_debtChange) : totalDebt.sub(_debtChange);

        uint newTCR = LiquityMath._computeCR(totalColl, totalDebt, _price);
        return newTCR;
    }

    function getCompositeDebt(uint _debt) external view override returns (uint) {
        return _getCompositeDebt(_debt);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import './Interfaces/IDefaultPool.sol';
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";

/*
 * The Default Pool holds the BNB and USDS debt (but not USDS tokens) from liquidations that have been redistributed
 * to active troves but not yet "applied", i.e. not yet recorded on a recipient active trove's struct.
 *
 * When a trove makes an operation that applies its pending BNB and USDS debt, its pending BNB and USDS debt is moved
 * from the Default Pool to the Active Pool.
 */
contract DefaultPool is Ownable, CheckContract, IDefaultPool {
    using SafeMath for uint256;

    string constant public NAME = "DefaultPool";

    address public troveManagerAddress;
    address public activePoolAddress;
    uint256 internal BNB;  // deposited BNB tracker
    uint256 internal USDSDebt;  // debt

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolUSDSDebtUpdated(uint _USDSDebt);
    event DefaultPoolBNBBalanceUpdated(uint _BNB);

    // --- Dependency setters ---

    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress
    )
        external
        onlyOwner
    {
        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);

        troveManagerAddress = _troveManagerAddress;
        activePoolAddress = _activePoolAddress;

        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);

        _renounceOwnership();
    }

    // --- Getters for public variables. Required by IPool interface ---

    /*
    * Returns the BNB state variable.
    *
    * Not necessarily equal to the the contract's raw BNB balance - ether can be forcibly sent to contracts.
    */
    function getBNB() external view override returns (uint) {
        return BNB;
    }

    function getUSDSDebt() external view override returns (uint) {
        return USDSDebt;
    }

    // --- Pool functionality ---

    function sendBNBToActivePool(uint _amount) external override {
        _requireCallerIsTroveManager();
        address activePool = activePoolAddress; // cache to save an SLOAD
        BNB = BNB.sub(_amount);
        emit DefaultPoolBNBBalanceUpdated(BNB);
        emit EtherSent(activePool, _amount);

        (bool success, ) = activePool.call{ value: _amount }("");
        require(success, "DefaultPool: sending BNB failed");
    }

    function increaseUSDSDebt(uint _amount) external override {
        _requireCallerIsTroveManager();
        USDSDebt = USDSDebt.add(_amount);
        emit DefaultPoolUSDSDebtUpdated(USDSDebt);
    }

    function decreaseUSDSDebt(uint _amount) external override {
        _requireCallerIsTroveManager();
        USDSDebt = USDSDebt.sub(_amount);
        emit DefaultPoolUSDSDebtUpdated(USDSDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsActivePool() internal view {
        require(msg.sender == activePoolAddress, "DefaultPool: Caller is not the ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == troveManagerAddress, "DefaultPool: Caller is not the TroveManager");
    }

    // --- Fallback function ---

    receive() external payable {
        _requireCallerIsActivePool();
        BNB = BNB.add(msg.value);
        emit DefaultPoolBNBBalanceUpdated(BNB);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./Interfaces/IBorrowerOperations.sol";
import "./Interfaces/IStabilityPool.sol";
import "./Interfaces/IBorrowerOperations.sol";
import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IUSDSToken.sol";
import "./Interfaces/ISortedTroves.sol";
import "./Interfaces/ICommunityIssuance.sol";
import "./Dependencies/LiquityBase.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/LiquitySafeMath128.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";

/*
 * The Stability Pool holds USDS tokens deposited by Stability Pool depositors.
 *
 * When a trove is liquidated, then depending on system conditions, some of its USDS debt gets offset with
 * USDS in the Stability Pool:  that is, the offset debt evaporates, and an equal amount of USDS tokens in the Stability Pool is burned.
 *
 * Thus, a liquidation causes each depositor to receive a USDS loss, in proportion to their deposit as a share of total deposits.
 * They also receive an BNB gain, as the BNB collateral of the liquidated trove is distributed among Stability depositors,
 * in the same proportion.
 *
 * When a liquidation occurs, it depletes every deposit by the same fraction: for example, a liquidation that depletes 40%
 * of the total USDS in the Stability Pool, depletes 40% of each deposit.
 *
 * A deposit that has experienced a series of liquidations is termed a "compounded deposit": each liquidation depletes the deposit,
 * multiplying it by some factor in range ]0,1[
 *
 *
 * --- IMPLEMENTATION ---
 *
 * We use a highly scalable method of tracking deposits and BNB gains that has O(1) complexity.
 *
 * When a liquidation occurs, rather than updating each depositor's deposit and BNB gain, we simply update two state variables:
 * a product P, and a sum S.
 *
 * A mathematical manipulation allows us to factor out the initial deposit, and accurately track all depositors' compounded deposits
 * and accumulated BNB gains over time, as liquidations occur, using just these two variables P and S. When depositors join the
 * Stability Pool, they get a snapshot of the latest P and S: P_t and S_t, respectively.
 *
 * The formula for a depositor's accumulated BNB gain is derived here:
 * https://github.com/liquity/dev/blob/main/packages/contracts/mathProofs/Scalable%20Compounding%20Stability%20Pool%20Deposits.pdf
 *
 * For a given deposit d_t, the ratio P/P_t tells us the factor by which a deposit has decreased since it joined the Stability Pool,
 * and the term d_t * (S - S_t)/P_t gives us the deposit's total accumulated BNB gain.
 *
 * Each liquidation updates the product P and sum S. After a series of liquidations, a compounded deposit and corresponding BNB gain
 * can be calculated using the initial deposit, the depositor’s snapshots of P and S, and the latest values of P and S.
 *
 * Any time a depositor updates their deposit (withdrawal, top-up) their accumulated BNB gain is paid out, their new deposit is recorded
 * (based on their latest compounded deposit and modified by the withdrawal/top-up), and they receive new snapshots of the latest P and S.
 * Essentially, they make a fresh deposit that overwrites the old one.
 *
 *
 * --- SCALE FACTOR ---
 *
 * Since P is a running product in range ]0,1] that is always-decreasing, it should never reach 0 when multiplied by a number in range ]0,1[.
 * Unfortunately, Solidity floor division always reaches 0, sooner or later.
 *
 * A series of liquidations that nearly empty the Pool (and thus each multiply P by a very small number in range ]0,1[ ) may push P
 * to its 18 digit decimal limit, and round it to 0, when in fact the Pool hasn't been emptied: this would break deposit tracking.
 *
 * So, to track P accurately, we use a scale factor: if a liquidation would cause P to decrease to <1e-9 (and be rounded to 0 by Solidity),
 * we first multiply P by 1e9, and increment a currentScale factor by 1.
 *
 * The added benefit of using 1e9 for the scale factor (rather than 1e18) is that it ensures negligible precision loss close to the
 * scale boundary: when P is at its minimum value of 1e9, the relative precision loss in P due to floor division is only on the
 * order of 1e-9.
 *
 * --- EPOCHS ---
 *
 * Whenever a liquidation fully empties the Stability Pool, all deposits should become 0. However, setting P to 0 would make P be 0
 * forever, and break all future reward calculations.
 *
 * So, every time the Stability Pool is emptied by a liquidation, we reset P = 1 and currentScale = 0, and increment the currentEpoch by 1.
 *
 * --- TRACKING DEPOSIT OVER SCALE CHANGES AND EPOCHS ---
 *
 * When a deposit is made, it gets snapshots of the currentEpoch and the currentScale.
 *
 * When calculating a compounded deposit, we compare the current epoch to the deposit's epoch snapshot. If the current epoch is newer,
 * then the deposit was present during a pool-emptying liquidation, and necessarily has been depleted to 0.
 *
 * Otherwise, we then compare the current scale to the deposit's scale snapshot. If they're equal, the compounded deposit is given by d_t * P/P_t.
 * If it spans one scale change, it is given by d_t * P/(P_t * 1e9). If it spans more than one scale change, we define the compounded deposit
 * as 0, since it is now less than 1e-9'th of its initial value (e.g. a deposit of 1 billion USDS has depleted to < 1 USDS).
 *
 *
 *  --- TRACKING DEPOSITOR'S BNB GAIN OVER SCALE CHANGES AND EPOCHS ---
 *
 * In the current epoch, the latest value of S is stored upon each scale change, and the mapping (scale -> S) is stored for each epoch.
 *
 * This allows us to calculate a deposit's accumulated BNB gain, during the epoch in which the deposit was non-zero and earned BNB.
 *
 * We calculate the depositor's accumulated BNB gain for the scale at which they made the deposit, using the BNB gain formula:
 * e_1 = d_t * (S - S_t) / P_t
 *
 * and also for scale after, taking care to divide the latter by a factor of 1e9:
 * e_2 = d_t * S / (P_t * 1e9)
 *
 * The gain in the second scale will be full, as the starting point was in the previous scale, thus no need to subtract anything.
 * The deposit therefore was present for reward events from the beginning of that second scale.
 *
 *        S_i-S_t + S_{i+1}
 *      .<--------.------------>
 *      .         .
 *      . S_i     .   S_{i+1}
 *   <--.-------->.<----------->
 *   S_t.         .
 *   <->.         .
 *      t         .
 *  |---+---------|-------------|-----...
 *         i            i+1
 *
 * The sum of (e_1 + e_2) captures the depositor's total accumulated BNB gain, handling the case where their
 * deposit spanned one scale change. We only care about gains across one scale change, since the compounded
 * deposit is defined as being 0 once it has spanned more than one scale change.
 *
 *
 * --- UPDATING P WHEN A LIQUIDATION OCCURS ---
 *
 * Please see the implementation spec in the proof document, which closely follows on from the compounded deposit / BNB gain derivations:
 * https://github.com/liquity/liquity/blob/master/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
 *
 * --- SABLE ISSUANCE TO STABILITY POOL DEPOSITORS ---
 *
 * An SABLE issuance event occurs at every deposit operation, and every liquidation.
 *
 * Each deposit is tagged with the address of the front end through which it was made.
 *
 * All deposits earn a share of the issued SABLE in proportion to the deposit as a share of total deposits. The SABLE earned
 * by a given deposit, is split between the depositor and the front end through which the deposit was made, based on the front end's kickbackRate.
 *
 * Please see the system Readme for an overview:
 * https://github.com/liquity/dev/blob/main/README.md#lqty-issuance-to-stability-providers
 *
 * We use the same mathematical product-sum approach to track SABLE gains for depositors, where 'G' is the sum corresponding to SABLE gains.
 * The product P (and snapshot P_t) is re-used, as the ratio P/P_t tracks a deposit's depletion due to liquidations.
 *
 */
contract StabilityPool is LiquityBase, Ownable, CheckContract, IStabilityPool {
    using LiquitySafeMath128 for uint128;

    string public constant NAME = "StabilityPool";

    IBorrowerOperations public borrowerOperations;

    ITroveManager public troveManager;

    IUSDSToken public usdsToken;

    // Needed to check if there are pending liquidations
    ISortedTroves public sortedTroves;

    ICommunityIssuance public communityIssuance;

    uint256 internal BNB; // deposited ether tracker

    // Tracker for USDS held in the pool. Changes when users deposit/withdraw, and when Trove debt is offset.
    uint256 internal totalUSDSDeposits;

    // --- Data structures ---

    struct FrontEnd {
        uint kickbackRate;
        bool registered;
    }

    struct Deposit {
        uint initialValue;
        address frontEndTag;
    }

    struct Snapshots {
        uint S;
        uint P;
        uint G;
        uint128 scale;
        uint128 epoch;
    }

    mapping(address => Deposit) public deposits; // depositor address -> Deposit struct
    mapping(address => Snapshots) public depositSnapshots; // depositor address -> snapshots struct

    mapping(address => FrontEnd) public frontEnds; // front end address -> FrontEnd struct
    mapping(address => uint) public frontEndStakes; // front end address -> last recorded total deposits, tagged with that front end
    mapping(address => Snapshots) public frontEndSnapshots; // front end address -> snapshots struct

    /*  Product 'P': Running product by which to multiply an initial deposit, in order to find the current compounded deposit,
     * after a series of liquidations have occurred, each of which cancel some USDS debt with the deposit.
     *
     * During its lifetime, a deposit's value evolves from d_t to d_t * P / P_t , where P_t
     * is the snapshot of P taken at the instant the deposit was made. 18-digit decimal.
     */
    uint public P = DECIMAL_PRECISION;

    uint public constant SCALE_FACTOR = 1e9;

    // Each time the scale of P shifts by SCALE_FACTOR, the scale is incremented by 1
    uint128 public currentScale;

    // With each offset that fully empties the Pool, the epoch is incremented by 1
    uint128 public currentEpoch;

    /* BNB Gain sum 'S': During its lifetime, each deposit d_t earns an BNB gain of ( d_t * [S - S_t] )/P_t, where S_t
     * is the depositor's snapshot of S taken at the time t when the deposit was made.
     *
     * The 'S' sums are stored in a nested mapping (epoch => scale => sum):
     *
     * - The inner mapping records the sum S at different scales
     * - The outer mapping records the (scale => sum) mappings, for different epochs.
     */
    mapping(uint128 => mapping(uint128 => uint)) public epochToScaleToSum;

    /*
     * Similarly, the sum 'G' is used to calculate SABLE gains. During it's lifetime, each deposit d_t earns a SABLE gain of
     *  ( d_t * [G - G_t] )/P_t, where G_t is the depositor's snapshot of G taken at time t when  the deposit was made.
     *
     *  SABLE reward events occur are triggered by depositor operations (new deposit, topup, withdrawal), and liquidations.
     *  In each case, the SABLE reward is issued (i.e. G is updated), before other state changes are made.
     */
    mapping(uint128 => mapping(uint128 => uint)) public epochToScaleToG;

    // Error tracker for the error correction in the SABLE issuance calculation
    uint public lastSABLEError;
    // Error trackers for the error correction in the offset calculation
    uint public lastBNBError_Offset;
    uint public lastUSDSLossError_Offset;

    // --- Events ---

    event StabilityPoolBNBBalanceUpdated(uint _newBalance);
    event StabilityPoolUSDSBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event USDSTokenAddressChanged(address _newUSDSTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);
    event SystemStateAddressChanged(address _newSystemStateAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(
        address indexed _frontEnd,
        uint _newFrontEndStake,
        address _depositor
    );

    event BNBGainWithdrawn(address indexed _depositor, uint _BNB, uint _USDSLoss);
    event SABLEPaidToDepositor(address indexed _depositor, uint _SABLE);
    event SABLEPaidToFrontEnd(address indexed _frontEnd, uint _SABLE);
    event EtherSent(address _to, uint _amount);

    // --- Contract setters ---

    function setParams(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _usdsTokenAddress,
        address _sortedTrovesAddress,
        address _priceFeedAddress,
        address _communityIssuanceAddress,
        address _systemStateAddress
    ) external override onlyOwner {
        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);
        checkContract(_usdsTokenAddress);
        checkContract(_sortedTrovesAddress);
        checkContract(_priceFeedAddress);
        checkContract(_communityIssuanceAddress);
        checkContract(_systemStateAddress);

        borrowerOperations = IBorrowerOperations(_borrowerOperationsAddress);
        troveManager = ITroveManager(_troveManagerAddress);
        activePool = IActivePool(_activePoolAddress);
        usdsToken = IUSDSToken(_usdsTokenAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        priceFeed = IPriceFeed(_priceFeedAddress);
        communityIssuance = ICommunityIssuance(_communityIssuanceAddress);
        systemState = ISystemState(_systemStateAddress);

        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);
        emit USDSTokenAddressChanged(_usdsTokenAddress);
        emit SortedTrovesAddressChanged(_sortedTrovesAddress);
        emit PriceFeedAddressChanged(_priceFeedAddress);
        emit CommunityIssuanceAddressChanged(_communityIssuanceAddress);
        emit SystemStateAddressChanged(_systemStateAddress);

        _renounceOwnership();
    }

    // --- Getters for public variables. Required by IPool interface ---

    function getBNB() external view override returns (uint) {
        return BNB;
    }

    function getTotalUSDSDeposits() external view override returns (uint) {
        return totalUSDSDeposits;
    }

    // --- External Depositor Functions ---

    /*  provideToSP():
     *
     * - Triggers a SABLE issuance, based on time passed since the last issuance. The SABLE issuance is shared between *all* depositors and front ends
     * - Tags the deposit with the provided front end tag param, if it's a new deposit
     * - Sends depositor's accumulated gains (SABLE, BNB) to depositor
     * - Sends the tagged front end's accumulated SABLE gains to the tagged front end
     * - Increases deposit and tagged front end's stake, and takes new snapshots for each.
     */
    function provideToSP(uint _amount, address _frontEndTag) external override {
        _requireFrontEndIsRegisteredOrZero(_frontEndTag);
        _requireFrontEndNotRegistered(msg.sender);
        _requireNonZeroAmount(_amount);

        uint initialDeposit = deposits[msg.sender].initialValue;

        ICommunityIssuance communityIssuanceCached = communityIssuance;

        _triggerSABLEIssuance(communityIssuanceCached);

        if (initialDeposit == 0) {
            _setFrontEndTag(msg.sender, _frontEndTag);
        }
        uint depositorBNBGain = getDepositorBNBGain(msg.sender);
        uint compoundedUSDSDeposit = getCompoundedUSDSDeposit(msg.sender);
        uint USDSLoss = initialDeposit.sub(compoundedUSDSDeposit); // Needed only for event log

        // First pay out any SABLE gains
        address frontEnd = deposits[msg.sender].frontEndTag;
        _payOutSABLEGains(communityIssuanceCached, msg.sender, frontEnd);

        // Update front end stake
        uint compoundedFrontEndStake = getCompoundedFrontEndStake(frontEnd);
        uint newFrontEndStake = compoundedFrontEndStake.add(_amount);
        _updateFrontEndStakeAndSnapshots(frontEnd, newFrontEndStake);
        emit FrontEndStakeChanged(frontEnd, newFrontEndStake, msg.sender);

        _sendUSDStoStabilityPool(msg.sender, _amount);

        uint newDeposit = compoundedUSDSDeposit.add(_amount);
        _updateDepositAndSnapshots(msg.sender, newDeposit);
        emit UserDepositChanged(msg.sender, newDeposit);

        emit BNBGainWithdrawn(msg.sender, depositorBNBGain, USDSLoss); // USDS Loss required for event log

        _sendBNBGainToDepositor(depositorBNBGain);
    }

    /*  withdrawFromSP():
     *
     * - Triggers a SABLE issuance, based on time passed since the last issuance. The SABLE issuance is shared between *all* depositors and front ends
     * - Removes the deposit's front end tag if it is a full withdrawal
     * - Sends all depositor's accumulated gains (SABLE, BNB) to depositor
     * - Sends the tagged front end's accumulated SABLE gains to the tagged front end
     * - Decreases deposit and tagged front end's stake, and takes new snapshots for each.
     *
     * If _amount > userDeposit, the user withdraws all of their compounded deposit.
     */
    function withdrawFromSP(uint _amount, bytes[] calldata priceFeedUpdateData) external override {
        if (_amount != 0) {
            _requireNoUnderCollateralizedTroves(priceFeedUpdateData);
        }
        uint initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);

        ICommunityIssuance communityIssuanceCached = communityIssuance;

        _triggerSABLEIssuance(communityIssuanceCached);

        uint depositorBNBGain = getDepositorBNBGain(msg.sender);

        uint compoundedUSDSDeposit = getCompoundedUSDSDeposit(msg.sender);
        uint USDStoWithdraw = LiquityMath._min(_amount, compoundedUSDSDeposit);
        uint USDSLoss = initialDeposit.sub(compoundedUSDSDeposit); // Needed only for event log

        // First pay out any SABLE gains
        address frontEnd = deposits[msg.sender].frontEndTag;
        _payOutSABLEGains(communityIssuanceCached, msg.sender, frontEnd);

        // Update front end stake
        uint compoundedFrontEndStake = getCompoundedFrontEndStake(frontEnd);
        uint newFrontEndStake = compoundedFrontEndStake.sub(USDStoWithdraw);
        _updateFrontEndStakeAndSnapshots(frontEnd, newFrontEndStake);
        emit FrontEndStakeChanged(frontEnd, newFrontEndStake, msg.sender);

        _sendUSDSToDepositor(msg.sender, USDStoWithdraw);

        // Update deposit
        uint newDeposit = compoundedUSDSDeposit.sub(USDStoWithdraw);
        _updateDepositAndSnapshots(msg.sender, newDeposit);
        emit UserDepositChanged(msg.sender, newDeposit);

        emit BNBGainWithdrawn(msg.sender, depositorBNBGain, USDSLoss); // USDS Loss required for event log

        _sendBNBGainToDepositor(depositorBNBGain);
    }

    function ownerTriggerIssuance() external override {
        _requireCallerIsCommunityIssuance();
        _triggerSABLEIssuance(communityIssuance);
    }

    /* withdrawBNBGainToTrove:
     * - Triggers a SABLE issuance, based on time passed since the last issuance. The SABLE issuance is shared between *all* depositors and front ends
     * - Sends all depositor's SABLE gain to  depositor
     * - Sends all tagged front end's SABLE gain to the tagged front end
     * - Transfers the depositor's entire BNB gain from the Stability Pool to the caller's trove
     * - Leaves their compounded deposit in the Stability Pool
     * - Updates snapshots for deposit and tagged front end stake */
    function withdrawBNBGainToTrove(
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external override {
        uint initialDeposit = deposits[msg.sender].initialValue;
        _requireUserHasDeposit(initialDeposit);
        _requireUserHasTrove(msg.sender);
        _requireUserHasBNBGain(msg.sender);

        ICommunityIssuance communityIssuanceCached = communityIssuance;

        _triggerSABLEIssuance(communityIssuanceCached);

        uint depositorBNBGain = getDepositorBNBGain(msg.sender);

        uint compoundedUSDSDeposit = getCompoundedUSDSDeposit(msg.sender);
        uint USDSLoss = initialDeposit.sub(compoundedUSDSDeposit); // Needed only for event log

        // First pay out any SABLE gains
        address frontEnd = deposits[msg.sender].frontEndTag;
        _payOutSABLEGains(communityIssuanceCached, msg.sender, frontEnd);

        // Update front end stake
        uint compoundedFrontEndStake = getCompoundedFrontEndStake(frontEnd);
        uint newFrontEndStake = compoundedFrontEndStake;
        _updateFrontEndStakeAndSnapshots(frontEnd, newFrontEndStake);
        emit FrontEndStakeChanged(frontEnd, newFrontEndStake, msg.sender);

        _updateDepositAndSnapshots(msg.sender, compoundedUSDSDeposit);

        /* Emit events before transferring BNB gain to Trove.
         This lets the event log make more sense (i.e. so it appears that first the BNB gain is withdrawn
        and then it is deposited into the Trove, not the other way around). */
        emit BNBGainWithdrawn(msg.sender, depositorBNBGain, USDSLoss);
        emit UserDepositChanged(msg.sender, compoundedUSDSDeposit);

        BNB = BNB.sub(depositorBNBGain);
        emit StabilityPoolBNBBalanceUpdated(BNB);
        emit EtherSent(msg.sender, depositorBNBGain);

        borrowerOperations.moveBNBGainToTrove{value: depositorBNBGain}(
            msg.sender,
            _upperHint,
            _lowerHint,
            priceFeedUpdateData
        );
    }

    // --- SABLE issuance functions ---

    function _triggerSABLEIssuance(ICommunityIssuance _communityIssuance) internal {
        uint SABLEIssuance = _communityIssuance.issueSABLE();
        _updateG(SABLEIssuance);
    }

    function _updateG(uint _SABLEIssuance) internal {
        uint totalUSDS = totalUSDSDeposits; // cached to save an SLOAD
        /*
         * When total deposits is 0, G is not updated. In this case, the SABLE issued can not be obtained by later
         * depositors - it is missed out on, and remains in the balanceof the CommunityIssuance contract.
         *
         */
        if (totalUSDS == 0 || _SABLEIssuance == 0) {
            return;
        }

        uint SABLEPerUnitStaked;
        SABLEPerUnitStaked = _computeSABLEPerUnitStaked(_SABLEIssuance, totalUSDS);

        uint marginalSABLEGain = SABLEPerUnitStaked.mul(P);
        epochToScaleToG[currentEpoch][currentScale] = epochToScaleToG[currentEpoch][currentScale]
            .add(marginalSABLEGain);

        emit G_Updated(epochToScaleToG[currentEpoch][currentScale], currentEpoch, currentScale);
    }

    function _computeSABLEPerUnitStaked(
        uint _SABLEIssuance,
        uint _totalUSDSDeposits
    ) internal returns (uint) {
        /*
         * Calculate the SABLE-per-unit staked.  Division uses a "feedback" error correction, to keep the
         * cumulative error low in the running total G:
         *
         * 1) Form a numerator which compensates for the floor division error that occurred the last time this
         * function was called.
         * 2) Calculate "per-unit-staked" ratio.
         * 3) Multiply the ratio back by its denominator, to reveal the current floor division error.
         * 4) Store this error for use in the next correction when this function is called.
         * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
         */
        uint SABLENumerator = _SABLEIssuance.mul(DECIMAL_PRECISION).add(lastSABLEError);

        uint SABLEPerUnitStaked = SABLENumerator.div(_totalUSDSDeposits);
        lastSABLEError = SABLENumerator.sub(SABLEPerUnitStaked.mul(_totalUSDSDeposits));

        return SABLEPerUnitStaked;
    }

    // --- Liquidation functions ---

    /*
     * Cancels out the specified debt against the USDS contained in the Stability Pool (as far as possible)
     * and transfers the Trove's BNB collateral from ActivePool to StabilityPool.
     * Only called by liquidation functions in the TroveManager.
     */
    function offset(uint _debtToOffset, uint _collToAdd) external override {
        _requireCallerIsTroveManager();
        uint totalUSDS = totalUSDSDeposits; // cached to save an SLOAD
        if (totalUSDS == 0 || _debtToOffset == 0) {
            return;
        }

        _triggerSABLEIssuance(communityIssuance);

        (uint BNBGainPerUnitStaked, uint USDSLossPerUnitStaked) = _computeRewardsPerUnitStaked(
            _collToAdd,
            _debtToOffset,
            totalUSDS
        );

        _updateRewardSumAndProduct(BNBGainPerUnitStaked, USDSLossPerUnitStaked); // updates S and P

        _moveOffsetCollAndDebt(_collToAdd, _debtToOffset);
    }

    // --- Offset helper functions ---

    function _computeRewardsPerUnitStaked(
        uint _collToAdd,
        uint _debtToOffset,
        uint _totalUSDSDeposits
    ) internal returns (uint BNBGainPerUnitStaked, uint USDSLossPerUnitStaked) {
        /*
         * Compute the USDS and BNB rewards. Uses a "feedback" error correction, to keep
         * the cumulative error in the P and S state variables low:
         *
         * 1) Form numerators which compensate for the floor division errors that occurred the last time this
         * function was called.
         * 2) Calculate "per-unit-staked" ratios.
         * 3) Multiply each ratio back by its denominator, to reveal the current floor division error.
         * 4) Store these errors for use in the next correction when this function is called.
         * 5) Note: static analysis tools complain about this "division before multiplication", however, it is intended.
         */
        uint BNBNumerator = _collToAdd.mul(DECIMAL_PRECISION).add(lastBNBError_Offset);

        assert(_debtToOffset <= _totalUSDSDeposits);
        if (_debtToOffset == _totalUSDSDeposits) {
            USDSLossPerUnitStaked = DECIMAL_PRECISION; // When the Pool depletes to 0, so does each deposit
            lastUSDSLossError_Offset = 0;
        } else {
            uint USDSLossNumerator = _debtToOffset.mul(DECIMAL_PRECISION).sub(
                lastUSDSLossError_Offset
            );
            /*
             * Add 1 to make error in quotient positive. We want "slightly too much" USDS loss,
             * which ensures the error in any given compoundedUSDSDeposit favors the Stability Pool.
             */
            USDSLossPerUnitStaked = (USDSLossNumerator.div(_totalUSDSDeposits)).add(1);
            lastUSDSLossError_Offset = (USDSLossPerUnitStaked.mul(_totalUSDSDeposits)).sub(
                USDSLossNumerator
            );
        }

        BNBGainPerUnitStaked = BNBNumerator.div(_totalUSDSDeposits);
        lastBNBError_Offset = BNBNumerator.sub(BNBGainPerUnitStaked.mul(_totalUSDSDeposits));

        return (BNBGainPerUnitStaked, USDSLossPerUnitStaked);
    }

    // Update the Stability Pool reward sum S and product P
    function _updateRewardSumAndProduct(
        uint _BNBGainPerUnitStaked,
        uint _USDSLossPerUnitStaked
    ) internal {
        uint currentP = P;
        uint newP;

        assert(_USDSLossPerUnitStaked <= DECIMAL_PRECISION);
        /*
         * The newProductFactor is the factor by which to change all deposits, due to the depletion of Stability Pool USDS in the liquidation.
         * We make the product factor 0 if there was a pool-emptying. Otherwise, it is (1 - USDSLossPerUnitStaked)
         */
        uint newProductFactor = uint(DECIMAL_PRECISION).sub(_USDSLossPerUnitStaked);

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentS = epochToScaleToSum[currentEpochCached][currentScaleCached];

        /*
         * Calculate the new S first, before we update P.
         * The BNB gain for any given depositor from a liquidation depends on the value of their deposit
         * (and the value of totalDeposits) prior to the Stability being depleted by the debt in the liquidation.
         *
         * Since S corresponds to BNB gain, and P to deposit loss, we update S first.
         */
        uint marginalBNBGain = _BNBGainPerUnitStaked.mul(currentP);
        uint newS = currentS.add(marginalBNBGain);
        epochToScaleToSum[currentEpochCached][currentScaleCached] = newS;
        emit S_Updated(newS, currentEpochCached, currentScaleCached);

        // If the Stability Pool was emptied, increment the epoch, and reset the scale and product P
        if (newProductFactor == 0) {
            currentEpoch = currentEpochCached.add(1);
            emit EpochUpdated(currentEpoch);
            currentScale = 0;
            emit ScaleUpdated(currentScale);
            newP = DECIMAL_PRECISION;

            // If multiplying P by a non-zero product factor would reduce P below the scale boundary, increment the scale
        } else if (currentP.mul(newProductFactor).div(DECIMAL_PRECISION) < SCALE_FACTOR) {
            newP = currentP.mul(newProductFactor).mul(SCALE_FACTOR).div(DECIMAL_PRECISION);
            currentScale = currentScaleCached.add(1);
            emit ScaleUpdated(currentScale);
        } else {
            newP = currentP.mul(newProductFactor).div(DECIMAL_PRECISION);
        }

        require(newP > 0);
        P = newP;

        emit P_Updated(newP);
    }

    function _moveOffsetCollAndDebt(uint _collToAdd, uint _debtToOffset) internal {
        IActivePool activePoolCached = activePool;

        // Cancel the liquidated USDS debt with the USDS in the stability pool
        activePoolCached.decreaseUSDSDebt(_debtToOffset);
        _decreaseUSDS(_debtToOffset);

        // Burn the debt that was successfully offset
        usdsToken.burn(address(this), _debtToOffset);

        activePoolCached.sendBNB(address(this), _collToAdd);
    }

    function _decreaseUSDS(uint _amount) internal {
        uint newTotalUSDSDeposits = totalUSDSDeposits.sub(_amount);
        totalUSDSDeposits = newTotalUSDSDeposits;
        emit StabilityPoolUSDSBalanceUpdated(newTotalUSDSDeposits);
    }

    // --- Reward calculator functions for depositor and front end ---

    /* Calculates the BNB gain earned by the deposit since its last snapshots were taken.
     * Given by the formula:  E = d0 * (S - S(0))/P(0)
     * where S(0) and P(0) are the depositor's snapshots of the sum S and product P, respectively.
     * d0 is the last recorded deposit value.
     */
    function getDepositorBNBGain(address _depositor) public view override returns (uint) {
        uint initialDeposit = deposits[_depositor].initialValue;

        if (initialDeposit == 0) {
            return 0;
        }

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint BNBGain = _getBNBGainFromSnapshots(initialDeposit, snapshots);
        return BNBGain;
    }

    function _getBNBGainFromSnapshots(
        uint initialDeposit,
        Snapshots memory snapshots
    ) internal view returns (uint) {
        /*
         * Grab the sum 'S' from the epoch at which the stake was made. The BNB gain may span up to one scale change.
         * If it does, the second portion of the BNB gain is scaled by 1e9.
         * If the gain spans no scale change, the second portion will be 0.
         */
        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint S_Snapshot = snapshots.S;
        uint P_Snapshot = snapshots.P;

        uint firstPortion = epochToScaleToSum[epochSnapshot][scaleSnapshot].sub(S_Snapshot);
        uint secondPortion = epochToScaleToSum[epochSnapshot][scaleSnapshot.add(1)].div(
            SCALE_FACTOR
        );

        uint BNBGain = initialDeposit.mul(firstPortion.add(secondPortion)).div(P_Snapshot).div(
            DECIMAL_PRECISION
        );

        return BNBGain;
    }

    /*
     * Calculate the SABLE gain earned by a deposit since its last snapshots were taken.
     * Given by the formula:  SABLE = d0 * (G - G(0))/P(0)
     * where G(0) and P(0) are the depositor's snapshots of the sum G and product P, respectively.
     * d0 is the last recorded deposit value.
     */
    function getDepositorSABLEGain(address _depositor) public view override returns (uint) {
        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) {
            return 0;
        }

        address frontEndTag = deposits[_depositor].frontEndTag;

        /*
         * If not tagged with a front end, the depositor gets a 100% cut of what their deposit earned.
         * Otherwise, their cut of the deposit's earnings is equal to the kickbackRate, set by the front end through
         * which they made their deposit.
         */
        uint kickbackRate = frontEndTag == address(0)
            ? DECIMAL_PRECISION
            : frontEnds[frontEndTag].kickbackRate;

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint SABLEGain = kickbackRate.mul(_getSABLEGainFromSnapshots(initialDeposit, snapshots)).div(
            DECIMAL_PRECISION
        );

        return SABLEGain;
    }

    /*
     * Return the SABLE gain earned by the front end. Given by the formula:  E = D0 * (G - G(0))/P(0)
     * where G(0) and P(0) are the depositor's snapshots of the sum G and product P, respectively.
     *
     * D0 is the last recorded value of the front end's total tagged deposits.
     */
    function getFrontEndSABLEGain(address _frontEnd) public view override returns (uint) {
        uint frontEndStake = frontEndStakes[_frontEnd];
        if (frontEndStake == 0) {
            return 0;
        }

        uint kickbackRate = frontEnds[_frontEnd].kickbackRate;
        uint frontEndShare = uint(DECIMAL_PRECISION).sub(kickbackRate);

        Snapshots memory snapshots = frontEndSnapshots[_frontEnd];

        uint SABLEGain = frontEndShare.mul(_getSABLEGainFromSnapshots(frontEndStake, snapshots)).div(
            DECIMAL_PRECISION
        );
        return SABLEGain;
    }

    function _getSABLEGainFromSnapshots(
        uint initialStake,
        Snapshots memory snapshots
    ) internal view returns (uint) {
        /*
         * Grab the sum 'G' from the epoch at which the stake was made. The SABLE gain may span up to one scale change.
         * If it does, the second portion of the SABLE gain is scaled by 1e9.
         * If the gain spans no scale change, the second portion will be 0.
         */
        uint128 epochSnapshot = snapshots.epoch;
        uint128 scaleSnapshot = snapshots.scale;
        uint G_Snapshot = snapshots.G;
        uint P_Snapshot = snapshots.P;

        uint firstPortion = epochToScaleToG[epochSnapshot][scaleSnapshot].sub(G_Snapshot);
        uint secondPortion = epochToScaleToG[epochSnapshot][scaleSnapshot.add(1)].div(SCALE_FACTOR);

        uint SABLEGain = initialStake.mul(firstPortion.add(secondPortion)).div(P_Snapshot).div(
            DECIMAL_PRECISION
        );

        return SABLEGain;
    }

    // --- Compounded deposit and compounded front end stake ---

    /*
     * Return the user's compounded deposit. Given by the formula:  d = d0 * P/P(0)
     * where P(0) is the depositor's snapshot of the product P, taken when they last updated their deposit.
     */
    function getCompoundedUSDSDeposit(address _depositor) public view override returns (uint) {
        uint initialDeposit = deposits[_depositor].initialValue;
        if (initialDeposit == 0) {
            return 0;
        }

        Snapshots memory snapshots = depositSnapshots[_depositor];

        uint compoundedDeposit = _getCompoundedStakeFromSnapshots(initialDeposit, snapshots);
        return compoundedDeposit;
    }

    /*
     * Return the front end's compounded stake. Given by the formula:  D = D0 * P/P(0)
     * where P(0) is the depositor's snapshot of the product P, taken at the last time
     * when one of the front end's tagged deposits updated their deposit.
     *
     * The front end's compounded stake is equal to the sum of its depositors' compounded deposits.
     */
    function getCompoundedFrontEndStake(address _frontEnd) public view override returns (uint) {
        uint frontEndStake = frontEndStakes[_frontEnd];
        if (frontEndStake == 0) {
            return 0;
        }

        Snapshots memory snapshots = frontEndSnapshots[_frontEnd];

        uint compoundedFrontEndStake = _getCompoundedStakeFromSnapshots(frontEndStake, snapshots);
        return compoundedFrontEndStake;
    }

    // Internal function, used to calculcate compounded deposits and compounded front end stakes.
    function _getCompoundedStakeFromSnapshots(
        uint initialStake,
        Snapshots memory snapshots
    ) internal view returns (uint) {
        uint snapshot_P = snapshots.P;
        uint128 scaleSnapshot = snapshots.scale;
        uint128 epochSnapshot = snapshots.epoch;

        // If stake was made before a pool-emptying event, then it has been fully cancelled with debt -- so, return 0
        if (epochSnapshot < currentEpoch) {
            return 0;
        }

        uint compoundedStake;
        uint128 scaleDiff = currentScale.sub(scaleSnapshot);

        /* Compute the compounded stake. If a scale change in P was made during the stake's lifetime,
         * account for it. If more than one scale change was made, then the stake has decreased by a factor of
         * at least 1e-9 -- so return 0.
         */
        if (scaleDiff == 0) {
            compoundedStake = initialStake.mul(P).div(snapshot_P);
        } else if (scaleDiff == 1) {
            compoundedStake = initialStake.mul(P).div(snapshot_P).div(SCALE_FACTOR);
        } else {
            // if scaleDiff >= 2
            compoundedStake = 0;
        }

        /*
         * If compounded deposit is less than a billionth of the initial deposit, return 0.
         *
         * NOTE: originally, this line was in place to stop rounding errors making the deposit too large. However, the error
         * corrections should ensure the error in P "favors the Pool", i.e. any given compounded deposit should slightly less
         * than it's theoretical value.
         *
         * Thus it's unclear whether this line is still really needed.
         */
        if (compoundedStake < initialStake.div(1e9)) {
            return 0;
        }

        return compoundedStake;
    }

    // --- Sender functions for USDS deposit, BNB gains and SABLE gains ---

    // Transfer the USDS tokens from the user to the Stability Pool's address, and update its recorded USDS
    function _sendUSDStoStabilityPool(address _address, uint _amount) internal {
        usdsToken.sendToPool(_address, address(this), _amount);
        uint newTotalUSDSDeposits = totalUSDSDeposits.add(_amount);
        totalUSDSDeposits = newTotalUSDSDeposits;
        emit StabilityPoolUSDSBalanceUpdated(newTotalUSDSDeposits);
    }

    function _sendBNBGainToDepositor(uint _amount) internal {
        if (_amount == 0) {
            return;
        }
        uint newBNB = BNB.sub(_amount);
        BNB = newBNB;
        emit StabilityPoolBNBBalanceUpdated(newBNB);
        emit EtherSent(msg.sender, _amount);

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "StabilityPool: sending BNB failed");
    }

    // Send USDS to user and decrease USDS in Pool
    function _sendUSDSToDepositor(address _depositor, uint USDSWithdrawal) internal {
        if (USDSWithdrawal == 0) {
            return;
        }

        usdsToken.returnFromPool(address(this), _depositor, USDSWithdrawal);
        _decreaseUSDS(USDSWithdrawal);
    }

    // --- External Front End functions ---

    // Front end makes a one-time selection of kickback rate upon registering
    function registerFrontEnd(uint _kickbackRate) external override {
        _requireFrontEndNotRegistered(msg.sender);
        _requireUserHasNoDeposit(msg.sender);
        _requireValidKickbackRate(_kickbackRate);

        frontEnds[msg.sender].kickbackRate = _kickbackRate;
        frontEnds[msg.sender].registered = true;

        emit FrontEndRegistered(msg.sender, _kickbackRate);
    }

    // --- Stability Pool Deposit Functionality ---

    function _setFrontEndTag(address _depositor, address _frontEndTag) internal {
        deposits[_depositor].frontEndTag = _frontEndTag;
        emit FrontEndTagSet(_depositor, _frontEndTag);
    }

    function _updateDepositAndSnapshots(address _depositor, uint _newValue) internal {
        deposits[_depositor].initialValue = _newValue;

        if (_newValue == 0) {
            delete deposits[_depositor].frontEndTag;
            delete depositSnapshots[_depositor];
            emit DepositSnapshotUpdated(_depositor, 0, 0, 0);
            return;
        }
        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentP = P;

        // Get S and G for the current epoch and current scale
        uint currentS = epochToScaleToSum[currentEpochCached][currentScaleCached];
        uint currentG = epochToScaleToG[currentEpochCached][currentScaleCached];

        // Record new snapshots of the latest running product P, sum S, and sum G, for the depositor
        depositSnapshots[_depositor].P = currentP;
        depositSnapshots[_depositor].S = currentS;
        depositSnapshots[_depositor].G = currentG;
        depositSnapshots[_depositor].scale = currentScaleCached;
        depositSnapshots[_depositor].epoch = currentEpochCached;

        emit DepositSnapshotUpdated(_depositor, currentP, currentS, currentG);
    }

    function _updateFrontEndStakeAndSnapshots(address _frontEnd, uint _newValue) internal {
        frontEndStakes[_frontEnd] = _newValue;

        if (_newValue == 0) {
            delete frontEndSnapshots[_frontEnd];
            emit FrontEndSnapshotUpdated(_frontEnd, 0, 0);
            return;
        }

        uint128 currentScaleCached = currentScale;
        uint128 currentEpochCached = currentEpoch;
        uint currentP = P;

        // Get G for the current epoch and current scale
        uint currentG = epochToScaleToG[currentEpochCached][currentScaleCached];

        // Record new snapshots of the latest running product P and sum G for the front end
        frontEndSnapshots[_frontEnd].P = currentP;
        frontEndSnapshots[_frontEnd].G = currentG;
        frontEndSnapshots[_frontEnd].scale = currentScaleCached;
        frontEndSnapshots[_frontEnd].epoch = currentEpochCached;

        emit FrontEndSnapshotUpdated(_frontEnd, currentP, currentG);
    }

    function _payOutSABLEGains(
        ICommunityIssuance _communityIssuance,
        address _depositor,
        address _frontEnd
    ) internal {
        // Pay out front end's SABLE gain
        if (_frontEnd != address(0)) {
            uint frontEndSABLEGain = getFrontEndSABLEGain(_frontEnd);
            _communityIssuance.sendSABLE(_frontEnd, frontEndSABLEGain);
            emit SABLEPaidToFrontEnd(_frontEnd, frontEndSABLEGain);
        }

        // Pay out depositor's SABLE gain
        uint depositorSABLEGain = getDepositorSABLEGain(_depositor);
        _communityIssuance.sendSABLE(_depositor, depositorSABLEGain);
        emit SABLEPaidToDepositor(_depositor, depositorSABLEGain);
    }

    // --- 'require' functions ---

    function _requireCallerIsActivePool() internal view {
        require(msg.sender == address(activePool), "StabilityPool: Caller is not ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == address(troveManager), "StabilityPool: Caller is not TroveManager");
    }

    function _requireCallerIsCommunityIssuance() internal view {
        require(
            msg.sender == address(communityIssuance),
            "StabilityPool: Callier is not CommunityIssuance"
        );
    }

    function _requireNoUnderCollateralizedTroves(bytes[] calldata priceFeedUpdateData) internal {
        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(
            priceFeedUpdateData
        );
        address lowestTrove = sortedTroves.getLast();
        uint ICR = troveManager.getCurrentICR(lowestTrove, fetchPriceResult.price);
        uint MCR = systemState.getMCR();
        require(ICR >= MCR, "StabilityPool: Cannot withdraw while there are troves with ICR < MCR");
    }

    function _requireUserHasDeposit(uint _initialDeposit) internal pure {
        require(_initialDeposit > 0, "StabilityPool: User must have a non-zero deposit");
    }

    function _requireUserHasNoDeposit(address _address) internal view {
        uint initialDeposit = deposits[_address].initialValue;
        require(initialDeposit == 0, "StabilityPool: User must have no deposit");
    }

    function _requireNonZeroAmount(uint _amount) internal pure {
        require(_amount > 0, "StabilityPool: Amount must be non-zero");
    }

    function _requireUserHasTrove(address _depositor) internal view {
        require(
            troveManager.getTroveStatus(_depositor) == 1,
            "StabilityPool: caller must have an active trove to withdraw BNBGain to"
        );
    }

    function _requireUserHasBNBGain(address _depositor) internal view {
        uint BNBGain = getDepositorBNBGain(_depositor);
        require(BNBGain > 0, "StabilityPool: caller must have non-zero BNB Gain");
    }

    function _requireFrontEndNotRegistered(address _address) internal view {
        require(
            !frontEnds[_address].registered,
            "StabilityPool: must not already be a registered front end"
        );
    }

    function _requireFrontEndIsRegisteredOrZero(address _address) internal view {
        require(
            frontEnds[_address].registered || _address == address(0),
            "StabilityPool: Tag must be a registered front end, or the zero address"
        );
    }

    function _requireValidKickbackRate(uint _kickbackRate) internal pure {
        require(
            _kickbackRate <= DECIMAL_PRECISION,
            "StabilityPool: Kickback rate must be in range [0,1]"
        );
    }

    // --- Fallback function ---

    receive() external payable {
        _requireCallerIsActivePool();
        BNB = BNB.add(msg.value);
        StabilityPoolBNBBalanceUpdated(BNB);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;


/**
 * The purpose of this contract is to hold USDS tokens for gas compensation:
 * https://github.com/liquity/dev#gas-compensation
 * When a borrower opens a trove, an additional 50 USDS debt is issued,
 * and 50 USDS is minted and sent to this contract.
 * When a borrower closes their active trove, this gas compensation is refunded:
 * 50 USDS is burned from the this contract's balance, and the corresponding
 * 50 USDS debt on the trove is cancelled.
 * See this issue for more context: https://github.com/liquity/dev/issues/186
 */
contract GasPool {
    // do nothing, as the core contracts have permission to send to and burn from this address
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./Interfaces/ICollSurplusPool.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";


contract CollSurplusPool is Ownable, CheckContract, ICollSurplusPool {
    using SafeMath for uint256;

    string constant public NAME = "CollSurplusPool";

    address public borrowerOperationsAddress;
    address public troveManagerAddress;
    address public activePoolAddress;

    // deposited ether tracker
    uint256 internal BNB;
    // Collateral surplus claimable by trove owners
    mapping (address => uint) internal balances;

    // --- Events ---

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account, uint _newBalance);
    event EtherSent(address _to, uint _amount);
    
    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress
    )
        external
        override
        onlyOwner
    {
        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);

        borrowerOperationsAddress = _borrowerOperationsAddress;
        troveManagerAddress = _troveManagerAddress;
        activePoolAddress = _activePoolAddress;

        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);

        _renounceOwnership();
    }

    /* Returns the BNB state variable at ActivePool address.
       Not necessarily equal to the raw ether balance - ether can be forcibly sent to contracts. */
    function getBNB() external view override returns (uint) {
        return BNB;
    }

    function getCollateral(address _account) external view override returns (uint) {
        return balances[_account];
    }

    // --- Pool functionality ---

    function accountSurplus(address _account, uint _amount) external override {
        _requireCallerIsTroveManager();

        uint newAmount = balances[_account].add(_amount);
        balances[_account] = newAmount;

        emit CollBalanceUpdated(_account, newAmount);
    }

    function claimColl(address _account) external override {
        _requireCallerIsBorrowerOperations();
        uint claimableColl = balances[_account];
        require(claimableColl > 0, "CollSurplusPool: No collateral available to claim");

        balances[_account] = 0;
        emit CollBalanceUpdated(_account, 0);

        BNB = BNB.sub(claimableColl);
        emit EtherSent(_account, claimableColl);

        (bool success, ) = _account.call{ value: claimableColl }("");
        require(success, "CollSurplusPool: sending BNB failed");
    }

    // --- 'require' functions ---

    function _requireCallerIsBorrowerOperations() internal view {
        require(
            msg.sender == borrowerOperationsAddress,
            "CollSurplusPool: Caller is not Borrower Operations");
    }

    function _requireCallerIsTroveManager() internal view {
        require(
            msg.sender == troveManagerAddress,
            "CollSurplusPool: Caller is not TroveManager");
    }

    function _requireCallerIsActivePool() internal view {
        require(
            msg.sender == activePoolAddress,
            "CollSurplusPool: Caller is not Active Pool");
    }

    // --- Fallback function ---

    receive() external payable {
        _requireCallerIsActivePool();
        BNB = BNB.add(msg.value);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./Interfaces/IUSDSToken.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";
/*
*
* Based upon OpenZeppelin's ERC20 contract:
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
*  
* and their EIP2612 (ERC20Permit / ERC712) functionality:
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/53516bc555a454862470e7860a9b5254db4d00f5/contracts/token/ERC20/ERC20Permit.sol
* 
*
* --- Functionality added specific to the USDSToken ---
* 
* 1) Transfer protection: blacklist of addresses that are invalid recipients (i.e. core Sable contracts) in external 
* transfer() and transferFrom() calls. The purpose is to protect users from losing tokens by mistakenly sending USDS directly to a Sable 
* core contract, when they should rather call the right function. 
*
* 2) sendToPool() and returnFromPool(): functions callable only Sable core contracts, which move USDS tokens between Sable <-> user.
*/

contract USDSToken is CheckContract, IUSDSToken {
    using SafeMath for uint256;
    
    uint256 private _totalSupply;
    string constant internal _NAME = "USDS Stablecoin";
    string constant internal _SYMBOL = "USDS";
    string constant internal _VERSION = "1";
    uint8 constant internal _DECIMALS = 18;
    
    // --- Data for EIP2612 ---
    
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant _TYPE_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    
    mapping (address => uint256) private _nonces;
    
    // User data for USDS token
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;  
    
    // --- Addresses ---
    address public immutable troveManagerAddress;
    address public immutable stabilityPoolAddress;
    address public immutable borrowerOperationsAddress;
    
    // --- Events ---
    event TroveManagerAddressChanged(address _troveManagerAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);

    constructor
    ( 
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _borrowerOperationsAddress
    ) 
        public 
    {  
        checkContract(_troveManagerAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_borrowerOperationsAddress);

        troveManagerAddress = _troveManagerAddress;
        emit TroveManagerAddressChanged(_troveManagerAddress);

        stabilityPoolAddress = _stabilityPoolAddress;
        emit StabilityPoolAddressChanged(_stabilityPoolAddress);

        borrowerOperationsAddress = _borrowerOperationsAddress;        
        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        
        bytes32 hashedName = keccak256(bytes(_NAME));
        bytes32 hashedVersion = keccak256(bytes(_VERSION));
        
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _chainID();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(_TYPE_HASH, hashedName, hashedVersion);
    }

    // --- Functions for intra-Liquity calls ---

    function mint(address _account, uint256 _amount) external override {
        _requireCallerIsBorrowerOperations();
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) external override {
        _requireCallerIsBOorTroveMorSP();
        _burn(_account, _amount);
    }

    function sendToPool(address _sender,  address _poolAddress, uint256 _amount) external override {
        _requireCallerIsStabilityPool();
        _transfer(_sender, _poolAddress, _amount);
    }

    function returnFromPool(address _poolAddress, address _receiver, uint256 _amount) external override {
        _requireCallerIsTroveMorSP();
        _transfer(_poolAddress, _receiver, _amount);
    }

    // --- External functions ---

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _requireValidRecipient(recipient);
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _requireValidRecipient(recipient);
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    // --- EIP 2612 Functionality ---

    function domainSeparator() public view override returns (bytes32) {    
        if (_chainID() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function permit
    (
        address owner, 
        address spender, 
        uint amount, 
        uint deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external 
        override 
    {            
        require(deadline >= now, 'USDS: expired deadline');
        bytes32 digest = keccak256(abi.encodePacked('\x19\x01', 
                         domainSeparator(), keccak256(abi.encode(
                         _PERMIT_TYPEHASH, owner, spender, amount, 
                         _nonces[owner]++, deadline))));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == owner, 'USDS: invalid signature');
        _approve(owner, spender, amount);
    }

    function nonces(address owner) external view override returns (uint256) { // FOR EIP 2612
        return _nonces[owner];
    }

    // --- Internal operations ---

    function _chainID() private pure returns (uint256 chainID) {
        assembly {
            chainID := chainid()
        }
    }
    
    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, name, version, _chainID(), address(this)));
    }

    // --- Internal operations ---
    // Warning: sanity checks (for sender and recipient) should have been done before calling these internal functions

    function _transfer(address sender, address recipient, uint256 amount) internal {
        assert(sender != address(0));
        assert(recipient != address(0));

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        assert(account != address(0));

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        assert(account != address(0));
        
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        assert(owner != address(0));
        assert(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // --- 'require' functions ---

    function _requireValidRecipient(address _recipient) internal view {
        require(
            _recipient != address(0) && 
            _recipient != address(this),
            "USDS: Cannot transfer tokens directly to the USDS token contract or the zero address"
        );
        require(
            _recipient != stabilityPoolAddress && 
            _recipient != troveManagerAddress && 
            _recipient != borrowerOperationsAddress, 
            "USDS: Cannot transfer tokens directly to the StabilityPool, TroveManager or BorrowerOps"
        );
    }

    function _requireCallerIsBorrowerOperations() internal view {
        require(msg.sender == borrowerOperationsAddress, "USDSToken: Caller is not BorrowerOperations");
    }

    function _requireCallerIsBOorTroveMorSP() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress ||
            msg.sender == stabilityPoolAddress,
            "USDS: Caller is neither BorrowerOperations nor TroveManager nor StabilityPool"
        );
    }

    function _requireCallerIsStabilityPool() internal view {
        require(msg.sender == stabilityPoolAddress, "USDS: Caller is not the StabilityPool");
    }

    function _requireCallerIsTroveMorSP() internal view {
        require(
            msg.sender == troveManagerAddress || msg.sender == stabilityPoolAddress,
            "USDS: Caller is neither TroveManager nor StabilityPool");
    }

    // --- Optional functions ---

    function name() external view override returns (string memory) {
        return _NAME;
    }

    function symbol() external view override returns (string memory) {
        return _SYMBOL;
    }

    function decimals() external view override returns (uint8) {
        return _DECIMALS;
    }

    function version() external view override returns (string memory) {
        return _VERSION;
    }

    function permitTypeHash() external view override returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Interfaces/IPriceFeed.sol";
import "../Interfaces/IPyth.sol";
import "../Dependencies/console.sol";

/*
* PriceFeed placeholder for testnet and development. The price is simply set manually and saved in a state 
* variable. The contract does not connect to a live Chainlink price feed. 
*/
contract PriceFeedTestnet is IPriceFeed {
    uint256 private _price = 200 * 1e18;

    IPriceFeed.FetchPriceResult private _fetchPriceResult = IPriceFeed.FetchPriceResult({
        price: _price,
        oracleKey: bytes32("LINK"),
        deviationPyth: 0,
        publishTimePyth: 0
    });

    IPyth mockPyth;

    address borrowerOperationsAddress;
    address troveManagerAddress;
    address stabilityPoolAddress;
    address public owner;
    modifier onlyOwner() {
      require(msg.sender == owner, "Only the owner can call this function.");
      _;
    }
    constructor() public {
      owner = msg.sender;
    }
    // --- Functions ---

    // View price getter for simplicity in tests
    function getPrice() external view returns (uint256) {
        return _price;
    }

    function setAddressesTestnet(
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _stabilityPoolAddress
    )
        external
    {
        troveManagerAddress = _troveManagerAddress;
        borrowerOperationsAddress = _borrowerOperationsAddress;
        stabilityPoolAddress = _stabilityPoolAddress;
    }

    function fetchPrice(bytes[] calldata priceFeedUpdateData) external override returns (IPriceFeed.FetchPriceResult memory) {
        // Fire an event just like the mainnet version would.
        // This lets the subgraph rely on events to get the latest price even when developing locally.
        emit LastGoodPriceUpdated(_price);

        return _fetchPriceResult;
    }

    // Manual external price setter.
    function setPrice(uint256 price) external onlyOwner returns (bool) {
        _price = price;
        _fetchPriceResult.price = _price;
        return true;
    }

    function setFetchPriceResult(uint _deviationPyth, uint _publishTimePyth, bool isPythPrice) external {
        _fetchPriceResult.price = _price;
        if (isPythPrice) {
            _fetchPriceResult.deviationPyth = _deviationPyth;
            _fetchPriceResult.publishTimePyth = _publishTimePyth;
            _fetchPriceResult.oracleKey = bytes32("PYTH");
        } else {
            _fetchPriceResult.oracleKey = bytes32("LINK");
        }        
    }

    function pyth() external view override returns (IPyth) {
        return mockPyth;
    }

    function setMockPyth(address _mockPythAddress) external {
        mockPyth = IPyth(_mockPythAddress);
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./Interfaces/ISortedTroves.sol";
import "./Interfaces/ITroveManager.sol";
import "./Interfaces/IBorrowerOperations.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";

/*
* A sorted doubly linked list with nodes sorted in descending order.
*
* Nodes map to active Troves in the system - the ID property is the address of a Trove owner.
* Nodes are ordered according to their current nominal individual collateral ratio (NICR),
* which is like the ICR but without the price, i.e., just collateral / debt.
*
* The list optionally accepts insert position hints.
*
* NICRs are computed dynamically at runtime, and not stored on the Node. This is because NICRs of active Troves
* change dynamically as liquidation events occur.
*
* The list relies on the fact that liquidation events preserve ordering: a liquidation decreases the NICRs of all active Troves,
* but maintains their order. A node inserted based on current NICR will maintain the correct position,
* relative to it's peers, as rewards accumulate, as long as it's raw collateral and debt have not changed.
* Thus, Nodes remain sorted by current NICR.
*
* Nodes need only be re-inserted upon a Trove operation - when the owner adds or removes collateral or debt
* to their position.
*
* The list is a modification of the following audited SortedDoublyLinkedList:
* https://github.com/livepeer/protocol/blob/master/contracts/libraries/SortedDoublyLL.sol
*
*
* Changes made in the Liquity implementation:
*
* - Keys have been removed from nodes
*
* - Ordering checks for insertion are performed by comparing an NICR argument to the current NICR, calculated at runtime.
*   The list relies on the property that ordering by ICR is maintained as the BNB:USD price varies.
*
* - Public functions with parameters have been made internal to save gas, and given an external wrapper function for external access
*/
contract SortedTroves is Ownable, CheckContract, ISortedTroves {
    using SafeMath for uint256;

    string constant public NAME = "SortedTroves";

    event TroveManagerAddressChanged(address _troveManagerAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint _NICR);
    event NodeRemoved(address _id);

    address public borrowerOperationsAddress;

    ITroveManager public troveManager;

    // Information for a node in the list
    struct Node {
        bool exists;
        address nextId;                  // Id of next node (smaller NICR) in the list
        address prevId;                  // Id of previous node (larger NICR) in the list
    }

    // Information for the list
    struct Data {
        address head;                        // Head of the list. Also the node in the list with the largest NICR
        address tail;                        // Tail of the list. Also the node in the list with the smallest NICR
        uint256 maxSize;                     // Maximum size of the list
        uint256 size;                        // Current size of the list
        mapping (address => Node) nodes;     // Track the corresponding ids for each node in the list
    }

    Data public data;

    // --- Dependency setters ---

    function setParams(uint256 _size, address _troveManagerAddress, address _borrowerOperationsAddress) external override onlyOwner {
        require(_size > 0, "SortedTroves: Size can’t be zero");
        checkContract(_troveManagerAddress);
        checkContract(_borrowerOperationsAddress);

        data.maxSize = _size;

        troveManager = ITroveManager(_troveManagerAddress);
        borrowerOperationsAddress = _borrowerOperationsAddress;

        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);

        _renounceOwnership();
    }

    /*
     * @dev Add a node to the list
     * @param _id Node's id
     * @param _NICR Node's NICR
     * @param _prevId Id of previous node for the insert position
     * @param _nextId Id of next node for the insert position
     */

    function insert(SortedTrovesInsertParam memory param) external override {
        ITroveManager troveManagerCached = troveManager;

        _requireCallerIsBOorTroveM(troveManagerCached);
        _insert(troveManagerCached, param);
    }

    function _insert(ITroveManager _troveManager, SortedTrovesInsertParam memory param) internal {
        // List must not be full
        require(!isFull(), "SortedTroves: List is full");
        // List must not already contain node
        require(!contains(param.id), "SortedTroves: List already contains the node");
        // Node id must not be null
        require(param.id != address(0), "SortedTroves: Id cannot be zero");
        // NICR must be non-zero
        require(param.newNICR > 0, "SortedTroves: NICR must be positive");

        address prevId = param.prevId;
        address nextId = param.nextId;

        if (!_validInsertPosition(_troveManager, param.newNICR, prevId, nextId)) {
            // Sender's hint was not a valid insert position
            // Use sender's hint to find a valid insert position
            (prevId, nextId) = _findInsertPosition(_troveManager, param.newNICR, prevId, nextId);
        }

         data.nodes[param.id].exists = true;

        if (prevId == address(0) && nextId == address(0)) {
            // Insert as head and tail
            data.head = param.id;
            data.tail = param.id;
        } else if (prevId == address(0)) {
            // Insert before `prevId` as the head
            data.nodes[param.id].nextId = data.head;
            data.nodes[data.head].prevId = param.id;
            data.head = param.id;
        } else if (nextId == address(0)) {
            // Insert after `nextId` as the tail
            data.nodes[param.id].prevId = data.tail;
            data.nodes[data.tail].nextId = param.id;
            data.tail = param.id;
        } else {
            // Insert at insert position between `prevId` and `nextId`
            data.nodes[param.id].nextId = nextId;
            data.nodes[param.id].prevId = prevId;
            data.nodes[prevId].nextId = param.id;
            data.nodes[nextId].prevId = param.id;
        }

        data.size = data.size.add(1);
        emit NodeAdded(param.id, param.newNICR);
    }

    function remove(address _id) external override {
        _requireCallerIsTroveManager();
        _remove(_id);
    }

    /*
     * @dev Remove a node from the list
     * @param _id Node's id
     */
    function _remove(address _id) internal {
        // List must contain the node
        require(contains(_id), "SortedTroves: List does not contain the id");

        if (data.size > 1) {
            // List contains more than a single node
            if (_id == data.head) {
                // The removed node is the head
                // Set head to next node
                data.head = data.nodes[_id].nextId;
                // Set prev pointer of new head to null
                data.nodes[data.head].prevId = address(0);
            } else if (_id == data.tail) {
                // The removed node is the tail
                // Set tail to previous node
                data.tail = data.nodes[_id].prevId;
                // Set next pointer of new tail to null
                data.nodes[data.tail].nextId = address(0);
            } else {
                // The removed node is neither the head nor the tail
                // Set next pointer of previous node to the next node
                data.nodes[data.nodes[_id].prevId].nextId = data.nodes[_id].nextId;
                // Set prev pointer of next node to the previous node
                data.nodes[data.nodes[_id].nextId].prevId = data.nodes[_id].prevId;
            }
        } else {
            // List contains a single node
            // Set the head and tail to null
            data.head = address(0);
            data.tail = address(0);
        }

        delete data.nodes[_id];
        data.size = data.size.sub(1);
        NodeRemoved(_id);
    }

    /*
     * @dev Re-insert the node at a new position, based on its new NICR
     * @param _id Node's id
     * @param _newNICR Node's new NICR
     * @param _prevId Id of previous node for the new insert position
     * @param _nextId Id of next node for the new insert position
     */

    function reInsert(SortedTrovesInsertParam memory param) external override {
        ITroveManager troveManagerCached = troveManager;

        _requireCallerIsBOorTroveM(troveManagerCached);
        // List must contain the node
        require(contains(param.id), "SortedTroves: List does not contain the id");
        // NICR must be non-zero
        require(param.newNICR > 0, "SortedTroves: NICR must be positive");

        // Remove node from the list
        _remove(param.id);

        _insert(troveManagerCached, param);
    }

    /*
     * @dev Checks if the list contains a node
     */
    function contains(address _id) public view override returns (bool) {
        return data.nodes[_id].exists;
    }

    /*
     * @dev Checks if the list is full
     */
    function isFull() public view override returns (bool) {
        return data.size == data.maxSize;
    }

    /*
     * @dev Checks if the list is empty
     */
    function isEmpty() public view override returns (bool) {
        return data.size == 0;
    }

    /*
     * @dev Returns the current size of the list
     */
    function getSize() external view override returns (uint256) {
        return data.size;
    }

    /*
     * @dev Returns the maximum size of the list
     */
    function getMaxSize() external view override returns (uint256) {
        return data.maxSize;
    }

    /*
     * @dev Returns the first node in the list (node with the largest NICR)
     */
    function getFirst() external view override returns (address) {
        return data.head;
    }

    /*
     * @dev Returns the last node in the list (node with the smallest NICR)
     */
    function getLast() external view override returns (address) {
        return data.tail;
    }

    /*
     * @dev Returns the next node (with a smaller NICR) in the list for a given node
     * @param _id Node's id
     */
    function getNext(address _id) external view override returns (address) {
        return data.nodes[_id].nextId;
    }

    /*
     * @dev Returns the previous node (with a larger NICR) in the list for a given node
     * @param _id Node's id
     */
    function getPrev(address _id) external view override returns (address) {
        return data.nodes[_id].prevId;
    }

    /*
     * @dev Check if a pair of nodes is a valid insertion point for a new node with the given NICR
     * @param _NICR Node's NICR
     * @param _prevId Id of previous node for the insert position
     * @param _nextId Id of next node for the insert position
     */
    function validInsertPosition(uint256 _NICR, address _prevId, address _nextId) external view override returns (bool) {
        return _validInsertPosition(troveManager, _NICR, _prevId, _nextId);
    }

    function _validInsertPosition(ITroveManager _troveManager, uint256 _NICR, address _prevId, address _nextId) internal view returns (bool) {
        if (_prevId == address(0) && _nextId == address(0)) {
            // `(null, null)` is a valid insert position if the list is empty
            return isEmpty();
        } else if (_prevId == address(0)) {
            // `(null, _nextId)` is a valid insert position if `_nextId` is the head of the list
            return data.head == _nextId && _NICR >= _troveManager.getNominalICR(_nextId);
        } else if (_nextId == address(0)) {
            // `(_prevId, null)` is a valid insert position if `_prevId` is the tail of the list
            return data.tail == _prevId && _NICR <= _troveManager.getNominalICR(_prevId);
        } else {
            // `(_prevId, _nextId)` is a valid insert position if they are adjacent nodes and `_NICR` falls between the two nodes' NICRs
            return data.nodes[_prevId].nextId == _nextId &&
                   _troveManager.getNominalICR(_prevId) >= _NICR &&
                   _NICR >= _troveManager.getNominalICR(_nextId);
        }
    }

    /*
     * @dev Descend the list (larger NICRs to smaller NICRs) to find a valid insert position
     * @param _troveManager TroveManager contract, passed in as param to save SLOAD’s
     * @param _NICR Node's NICR
     * @param _startId Id of node to start descending the list from
     */
    function _descendList(ITroveManager _troveManager, uint256 _NICR, address _startId) internal view returns (address, address) {
        // If `_startId` is the head, check if the insert position is before the head
        if (data.head == _startId && _NICR >= _troveManager.getNominalICR(_startId)) {
            return (address(0), _startId);
        }

        address prevId = _startId;
        address nextId = data.nodes[prevId].nextId;

        // Descend the list until we reach the end or until we find a valid insert position
        while (prevId != address(0) && !_validInsertPosition(_troveManager, _NICR, prevId, nextId)) {
            prevId = data.nodes[prevId].nextId;
            nextId = data.nodes[prevId].nextId;
        }

        return (prevId, nextId);
    }

    /*
     * @dev Ascend the list (smaller NICRs to larger NICRs) to find a valid insert position
     * @param _troveManager TroveManager contract, passed in as param to save SLOAD’s
     * @param _NICR Node's NICR
     * @param _startId Id of node to start ascending the list from
     */
    function _ascendList(ITroveManager _troveManager, uint256 _NICR, address _startId) internal view returns (address, address) {
        // If `_startId` is the tail, check if the insert position is after the tail
        if (data.tail == _startId && _NICR <= _troveManager.getNominalICR(_startId)) {
            return (_startId, address(0));
        }

        address nextId = _startId;
        address prevId = data.nodes[nextId].prevId;

        // Ascend the list until we reach the end or until we find a valid insertion point
        while (nextId != address(0) && !_validInsertPosition(_troveManager, _NICR, prevId, nextId)) {
            nextId = data.nodes[nextId].prevId;
            prevId = data.nodes[nextId].prevId;
        }

        return (prevId, nextId);
    }

    /*
     * @dev Find the insert position for a new node with the given NICR
     * @param _NICR Node's NICR
     * @param _prevId Id of previous node for the insert position
     * @param _nextId Id of next node for the insert position
     */
    function findInsertPosition(uint256 _NICR, address _prevId, address _nextId) external view override returns (address, address) {
        return _findInsertPosition(troveManager, _NICR, _prevId, _nextId);
    }

    function _findInsertPosition(ITroveManager _troveManager, uint256 _NICR, address _prevId, address _nextId) internal view returns (address, address) {
        address prevId = _prevId;
        address nextId = _nextId;

        if (prevId != address(0)) {
            if (!contains(prevId) || _NICR > _troveManager.getNominalICR(prevId)) {
                // `prevId` does not exist anymore or now has a smaller NICR than the given NICR
                prevId = address(0);
            }
        }

        if (nextId != address(0)) {
            if (!contains(nextId) || _NICR < _troveManager.getNominalICR(nextId)) {
                // `nextId` does not exist anymore or now has a larger NICR than the given NICR
                nextId = address(0);
            }
        }

        if (prevId == address(0) && nextId == address(0)) {
            // No hint - descend list starting from head
            return _descendList(_troveManager, _NICR, data.head);
        } else if (prevId == address(0)) {
            // No `prevId` for hint - ascend list starting from `nextId`
            return _ascendList(_troveManager, _NICR, nextId);
        } else if (nextId == address(0)) {
            // No `nextId` for hint - descend list starting from `prevId`
            return _descendList(_troveManager, _NICR, prevId);
        } else {
            // Descend list starting from `prevId`
            return _descendList(_troveManager, _NICR, prevId);
        }
    }

    // --- 'require' functions ---

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == address(troveManager), "SortedTroves: Caller is not the TroveManager");
    }

    function _requireCallerIsBOorTroveM(ITroveManager _troveManager) internal view {
        require(msg.sender == borrowerOperationsAddress || msg.sender == address(_troveManager),
                "SortedTroves: Caller is neither BO nor TroveM");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../TroveManager.sol";
import "../BorrowerOperations.sol";
import "../StabilityPool.sol";
import "../USDSToken.sol";

contract EchidnaProxy {
    TroveManager troveManager;
    BorrowerOperations borrowerOperations;
    StabilityPool stabilityPool;
    USDSToken usdsToken;

    constructor(
        TroveManager _troveManager,
        BorrowerOperations _borrowerOperations,
        StabilityPool _stabilityPool,
        USDSToken _usdsToken
    ) public {
        troveManager = _troveManager;
        borrowerOperations = _borrowerOperations;
        stabilityPool = _stabilityPool;
        usdsToken = _usdsToken;
    }

    receive() external payable {
        // do nothing
    }

    // TroveManager

    function liquidatePrx(
        address _user,
        bytes[] calldata priceFeedUpdateData
    ) external {
        troveManager.liquidate(_user, priceFeedUpdateData);
    }

    function liquidateTrovesPrx(
        uint _n,
        bytes[] calldata priceFeedUpdateData
    ) external {
        troveManager.liquidateTroves(_n, priceFeedUpdateData);
    }

    function batchLiquidateTrovesPrx(
        address[] calldata _troveArray,
        bytes[] calldata priceFeedUpdateData
    ) external {
        troveManager.batchLiquidateTroves(_troveArray, priceFeedUpdateData);
    }

    function redeemCollateralPrx(
        uint _USDSAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) external {
        troveManager.redeemCollateral(_USDSAmount, _firstRedemptionHint, _upperPartialRedemptionHint, _lowerPartialRedemptionHint, _partialRedemptionHintNICR, _maxIterations, _maxFee, priceFeedUpdateData);
    }

    // Borrower Operations
    function openTrovePrx(
        uint _BNB, 
        uint _USDSAmount, 
        address _upperHint, 
        address _lowerHint, 
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        borrowerOperations.openTrove{value: _BNB}(_maxFee, _USDSAmount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function addCollPrx(
        uint _BNB, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        borrowerOperations.addColl{value: _BNB}(_upperHint, _lowerHint, priceFeedUpdateData);
    }

    function withdrawCollPrx(
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        borrowerOperations.withdrawColl(_amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function withdrawUSDSPrx(
        uint _amount, 
        address _upperHint, 
        address _lowerHint, 
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) external {
        borrowerOperations.withdrawUSDS(_maxFee, _amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function repayUSDSPrx(
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        borrowerOperations.repayUSDS(_amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function closeTrovePrx(bytes[] calldata priceFeedUpdateData) external {
        borrowerOperations.closeTrove(priceFeedUpdateData);
    }

    function adjustTrovePrx(
        uint _BNB, 
        IBorrowerOperations.AdjustTroveParam memory adjustParam,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        borrowerOperations.adjustTrove{value: _BNB}(adjustParam, priceFeedUpdateData);
    }

    // Pool Manager
    function provideToSPPrx(uint _amount, address _frontEndTag) external {
        stabilityPool.provideToSP(_amount, _frontEndTag);
    }

    function withdrawFromSPPrx(
        uint _amount,
        bytes[] calldata priceFeedUpdateData
    ) external {
        stabilityPool.withdrawFromSP(_amount, priceFeedUpdateData);
    }

    // USDS Token

    function transferPrx(address recipient, uint256 amount) external returns (bool) {
        return usdsToken.transfer(recipient, amount);
    }

    function approvePrx(address spender, uint256 amount) external returns (bool) {
        return usdsToken.approve(spender, amount);
    }

    function transferFromPrx(address sender, address recipient, uint256 amount) external returns (bool) {
        return usdsToken.transferFrom(sender, recipient, amount);
    }

    function increaseAllowancePrx(address spender, uint256 addedValue) external returns (bool) {
        return usdsToken.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowancePrx(address spender, uint256 subtractedValue) external returns (bool) {
        return usdsToken.decreaseAllowance(spender, subtractedValue);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./Dependencies/LiquityMath.sol";
import "./Dependencies/CheckContract.sol";
import "./Interfaces/ISystemState.sol";
import "./Dependencies/Ownable.sol";

/*
 * Base contract for TroveManager, BorrowerOperations and StabilityPool. Contains global system constants and
 * common functions.
 */
contract SystemState is CheckContract, ISystemState, Ownable {
    using SafeMath for uint;

    // Minimum collateral ratio for individual troves
    uint private mcr; // 1100000000000000000; // 110%

    // Critical system collateral ratio. If the system's total collateral ratio (TCR) falls below the CCR, Recovery Mode is triggered.
    uint private ccr; // 1500000000000000000; // 150%

    // Amount of USDS to be locked in gas pool on opening troves
    uint private USDSGasCompensation; //  10e18;

    // Minimum amount of net USDS debt a trove must have
    uint private minNetDebt; // 90e18

    uint private borrowingFeeFloor; // 0.05%

    uint private redemptionFeeFloor; // 0.05%

    address private timeLock;

    function setConfigs(
        address _timelock,
        uint _mcr,
        uint _ccr,
        uint _USDSGasCompensation,
        uint _minNetDebt,
        uint _borrowingFeeFloor,
        uint _redemptionFeeFloor
    ) public onlyOwner {
        checkContract(_timelock);
        timeLock = _timelock;

        _setCCR(_ccr);
        _setMCR(_mcr);
        _setUSDSGasCompensation(_USDSGasCompensation);
        _setMinNetDebt(_minNetDebt);
        _setBorrowingFeeFloor(_borrowingFeeFloor);
        _setRedemptionFeeFloor(_redemptionFeeFloor);

        _renounceOwnership();
    }

    modifier onlyTimeLock() {
        require(msg.sender == timeLock, "Caller is not from timelock");
        _;
    }

    // External function

    function setUSDSGasCompensation(uint _value) external override onlyTimeLock {
        _setUSDSGasCompensation(_value);
    }

    function setBorrowingFeeFloor(uint _value) external override onlyTimeLock {
        _setBorrowingFeeFloor(_value);
    }

    function setRedemptionFeeFloor(uint _value) external override onlyTimeLock {
        _setRedemptionFeeFloor(_value);
    }

    function setMinNetDebt(uint _value) external override onlyTimeLock {
        _setMinNetDebt(_value);
    }

    function setMCR(uint _value) external override onlyTimeLock {
        _setMCR(_value);
    }

    function setCCR(uint _value) external override onlyTimeLock {
        _setCCR(_value);
    }

    function getUSDSGasCompensation() external view override returns (uint) {
        return USDSGasCompensation;
    }

    function getBorrowingFeeFloor() external view override returns (uint) {
        return borrowingFeeFloor;
    }

    function getRedemptionFeeFloor() external view override returns (uint) {
        return redemptionFeeFloor;
    }

    function getMinNetDebt() external view override returns (uint) {
        return minNetDebt;
    }

    function getMCR() external view override returns (uint) {
        return mcr;
    }

    function getCCR() external view override returns (uint) {
        return ccr;
    }

    // internal function
     function _setUSDSGasCompensation(uint _value) internal {
        uint oldValue = USDSGasCompensation;
        USDSGasCompensation = _value;
        emit USDSGasCompensationChanged(oldValue, _value);
    }

    function _setBorrowingFeeFloor(uint _value) internal {
        uint oldValue = borrowingFeeFloor;
        borrowingFeeFloor = _value;
        emit BorrowingFeeFloorChanged(oldValue, _value);
    }

    function _setRedemptionFeeFloor(uint _value) internal {
        uint oldValue = redemptionFeeFloor;
        redemptionFeeFloor = _value;
        emit RedemptionFeeFloorChanged(oldValue, _value);
    }

    function _setMinNetDebt(uint _value) internal {
        require(_value > 0, "SystemState: Min net debt must > 0");
        uint oldValue = minNetDebt;
        minNetDebt = _value;
        emit MinNetDebtChanged(oldValue, _value);
    }

    function _setMCR(uint _value) internal {
        require(_value > 1000000000000000000 && _value < ccr, "SystemState: 100% < MCR < CCR");
        uint oldValue = mcr;
        mcr = _value;
        emit MCR_Changed(oldValue, _value);
    }

    function _setCCR(uint _value) internal {
        require(_value > mcr, "SystemState: CCR > MCR");
        uint oldValue = ccr;
        ccr = _value;
        emit CCR_Changed(oldValue, _value);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.9 <0.8.0;
pragma experimental ABIEncoderV2;

import "./Dependencies/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 *
 * _Available since v3.3._
 */
contract TimeLock is AccessControl {
    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data
    );

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with a given `minDelay`.
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) public {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);

        // deployer + self administration
        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        // register proposers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRole(bytes32 role) {
        require(
            hasRole(role, _msgSender()) || hasRole(role, address(0)),
            "TimelockController: sender requires permission"
        );
        _;
    }

    /**
     * @dev Contract might receive/hold BNB as part of the maintenance process.
     */
    receive() external payable {}

    /**
     * @dev Returns whether an id correspond to a registered operation. This
     * includes both Pending, Ready and Done operations.
     */
    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    /**
     * @dev Returns whether an operation is pending or not.
     */
    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns whether an operation is ready or not.
     */
    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        // solhint-disable-next-line not-rely-on-time
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns the timestamp at with an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    /**
     * @dev Returns the minimum delay for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256 duration) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits a {CallScheduled} event.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    /**
     * @dev Schedule an operation that is to becomes valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        // solhint-disable-next-line not-rely-on-time
        _timestamps[id] = SafeMath.add(block.timestamp, delay);
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute an (ready) operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    /**
     * @dev Execute an (ready) operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 predecessor) private view {
        require(
            predecessor == bytes32(0) || isOperationDone(predecessor),
            "TimelockController: missing dependency"
        );
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    /**
     * @dev Execute an operation's call.
     *
     * Emits a {CallExecuted} event.
     */
    function _call(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes calldata data
    ) private {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) external virtual {
        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./Interfaces/IOracleRateCalculation.sol";
import "./Dependencies/LiquityMath.sol";
import "./Dependencies/BaseMath.sol";

contract OracleRateCalculation is BaseMath, IOracleRateCalculation {
    using SafeMath for uint;

    uint constant public MAX_ORACLE_RATE_PERCENTAGE = 25 * DECIMAL_PRECISION / 10000; // 0.25% * DECIMAL_PRECISION

    function getOracleRate(
        bytes32 oracleKey, 
        uint deviationPyth, 
        uint publishTimePyth
    ) external view override returns (uint oracleRate) {
        if (oracleKey == bytes32("PYTH")) {
            uint absDelayTime = block.timestamp > publishTimePyth 
                ? block.timestamp.sub(publishTimePyth)
                : publishTimePyth.sub(block.timestamp);
            
            oracleRate = deviationPyth.add(absDelayTime.mul(DECIMAL_PRECISION).div(10000));
            if (oracleRate > MAX_ORACLE_RATE_PERCENTAGE) {
                oracleRate = MAX_ORACLE_RATE_PERCENTAGE;
            }
        } else {
            oracleRate = MAX_ORACLE_RATE_PERCENTAGE;
        }
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./TroveManager.sol";
import "./Interfaces/ITroveHelper.sol";

contract TroveHelper is LiquityBase, Ownable, CheckContract, ITroveHelper {
    TroveManager public troveManager;
    ISortedTroves public sortedTroves;
    ISABLEToken public sableToken;

    function setAddresses(
        address _troveManagerAddress,
        address _systemStateAddress,
        address _sortedTrovesAddress,
        address _sableTokenAddress,
        address _activePoolAddress,
        address _defaultPoolAddress
    ) external override onlyOwner {
        checkContract(_troveManagerAddress);
        checkContract(_systemStateAddress);
        checkContract(_sortedTrovesAddress);
        checkContract(_sableTokenAddress);
        troveManager = TroveManager(_troveManagerAddress);
        systemState = ISystemState(_systemStateAddress);
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        sableToken = ISABLEToken(_sableTokenAddress);
        activePool = IActivePool(_activePoolAddress);
        defaultPool = IDefaultPool(_defaultPoolAddress);
    }

    /*
     *  Get its offset coll/debt and BNB gas comp, and close the trove.
     */
    function getCappedOffsetVals(
        uint _entireTroveDebt,
        uint _entireTroveColl,
        uint _price
    ) external view override returns (ITroveManager.LiquidationValues memory singleLiquidation) {
        _requireCallerIsTroveManager();

        singleLiquidation.entireTroveDebt = _entireTroveDebt;
        singleLiquidation.entireTroveColl = _entireTroveColl;
        uint cappedCollPortion = _entireTroveDebt.mul(systemState.getMCR()).div(_price);
        singleLiquidation.collGasCompensation = _getCollGasCompensation(cappedCollPortion);
        singleLiquidation.USDSGasCompensation = systemState.getUSDSGasCompensation();

        singleLiquidation.debtToOffset = _entireTroveDebt;
        singleLiquidation.collToSendToSP = cappedCollPortion.sub(
            singleLiquidation.collGasCompensation
        );
        singleLiquidation.collSurplus = _entireTroveColl.sub(cappedCollPortion);
        singleLiquidation.debtToRedistribute = 0;
        singleLiquidation.collToRedistribute = 0;
    }

    function isValidFirstRedemptionHint(
        ISortedTroves _sortedTroves,
        address _firstRedemptionHint,
        uint _price
    ) external view override returns (bool) {
        _requireCallerIsTroveManager();

        uint MCR = systemState.getMCR();
        if (
            _firstRedemptionHint == address(0) ||
            !_sortedTroves.contains(_firstRedemptionHint) ||
            troveManager.getCurrentICR(_firstRedemptionHint, _price) < MCR
        ) {
            return false;
        }

        address nextTrove = _sortedTroves.getNext(_firstRedemptionHint);
        return nextTrove == address(0) || troveManager.getCurrentICR(nextTrove, _price) < MCR;
    }

    // Require wrappers

    function requireValidMaxFeePercentage(uint _maxFeePercentage) external view override {
        _requireCallerIsTroveManager();

        uint REDEMPTION_FEE_FLOOR = systemState.getRedemptionFeeFloor();
        require(
            _maxFeePercentage >= REDEMPTION_FEE_FLOOR && _maxFeePercentage <= DECIMAL_PRECISION,
            "Max fee percentage must be between 0.5% and 100%"
        );
    }

    function requireAfterBootstrapPeriod() external view override {
        _requireCallerIsTroveManager();

        uint systemDeploymentTime = sableToken.getDeploymentStartTime();
        require(
            block.timestamp >= systemDeploymentTime.add(troveManager.BOOTSTRAP_PERIOD()),
            "TroveManager: Redemptions are not allowed during bootstrap phase"
        );
    }

    function requireUSDSBalanceCoversRedemption(
        IUSDSToken _usdsToken,
        address _redeemer,
        uint _amount
    ) external view override {
        _requireCallerIsTroveManager();

        require(
            _usdsToken.balanceOf(_redeemer) >= _amount,
            "TroveManager: Requested redemption amount must be <= user's USDS token balance"
        );
    }

    function requireMoreThanOneTroveInSystem(uint TroveOwnersArrayLength) external view override {
        _requireCallerIsTroveManager();

        require(
            TroveOwnersArrayLength > 1 && sortedTroves.getSize() > 1,
            "TroveManager: Only one trove in the system"
        );
    }

    function requireAmountGreaterThanZero(uint _amount) external view override {
        _requireCallerIsTroveManager();

        require(_amount > 0, "TroveManager: Amount must be greater than zero");
    }

    function requireTCRoverMCR(uint _price) external view override {
        _requireCallerIsTroveManager();

        require(
            _getTCR(_price) >= systemState.getMCR(),
            "TroveManager: Cannot redeem when TCR < MCR"
        );
    }

    // Check whether or not the system *would be* in Recovery Mode, given an BNB:USD price, and the entire system coll and debt.
    function checkPotentialRecoveryMode(
        uint _entireSystemColl,
        uint _entireSystemDebt,
        uint _price
    ) external view override returns (bool) {
        _requireCallerIsTroveManager();

        return
            LiquityMath._computeCR(_entireSystemColl, _entireSystemDebt, _price) <
            systemState.getCCR();
    }

    function _requireCallerIsTroveManager() internal view {
        require(
            msg.sender == address(troveManager),
            "TroveHelper: Caller is not the TroveManager contract"
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./IActivePool.sol";
import "./ITroveManager.sol";

// Common interface for the Trove Manager.
interface IBorrowerOperations {
    // --- Events ---

    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event USDSTokenAddressChanged(address _usdsTokenAddress);
    event SableStakingAddressChanged(address _sableStakingAddress);
    event OracleRateCalcAddressChanged(address _oracleRateCalcAddress);

    event TroveCreated(address indexed _borrower, uint arrayIndex);
    event TroveUpdated(
        address indexed _borrower,
        uint _debt,
        uint _coll,
        uint stake,
        uint8 operation
    );
    event USDSBorrowingFeePaid(address indexed _borrower, uint _USDSFee);

    // --- Functions ---

    struct DependencyAddressParam {
        address troveManagerAddress;
        address activePoolAddress;
        address defaultPoolAddress;
        address stabilityPoolAddress;
        address gasPoolAddress;
        address collSurplusPoolAddress;
        address priceFeedAddress;
        address sortedTrovesAddress;
        address usdsTokenAddress;
        address sableStakingAddress;
        address systemStateAddress;
        address oracleRateCalcAddress;
    }

    struct TriggerBorrowingFeeParam {
        ITroveManager troveManager;
        IUSDSToken usdsToken;
        uint USDSAmount;
        uint maxFeePercentage;
        uint oracleRate;
    }

    struct WithdrawUSDSParam {
        IActivePool activePool;
        IUSDSToken usdsToken;
        address account;
        uint USDSAmount;
        uint netDebtIncrease;
    }

    struct TroveIsActiveParam {
        ITroveManager troveManager;
        address borrower;
    }

    function setAddresses(DependencyAddressParam memory param) external;

    function openTrove(
        uint _maxFee,
        uint _USDSAmount,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdatedata
    ) external payable;

    function addColl(
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdatedata
    ) external payable;

    function moveBNBGainToTrove(
        address _user,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdatedata
    ) external payable;

    function withdrawColl(
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdatedata
    ) external;

    function withdrawUSDS(
        uint _maxFee,
        uint _amount,
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdatedata
    ) external;

    function repayUSDS(
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdatedata
    ) external;

    function closeTrove(bytes[] calldata priceFeedUpdatedata) external;

    struct AdjustTroveParam {
        uint collWithdrawal;
        uint USDSChange;
        bool isDebtIncrease;
        address upperHint;
        address lowerHint;
        uint maxFeePercentage;
    }

    struct NewICRFromTroveChangeParam {
        uint coll;
        uint debt;
        uint collChange;
        bool isCollIncrease;
        uint debtChange;
        bool isDebtIncrease;
        uint price;
    }

    struct UpdateTroveFromAdjustmentParam {
        ITroveManager troveManager;
        address borrower;
        uint collChange;
        bool isCollIncrease;
        uint debtChange;
        bool isDebtIncrease;
    }

    struct NewNomialICRFromTroveChangeParam {
        uint coll;
        uint debt;
        uint collChange;
        bool isCollIncrease;
        uint debtChange;
        bool isDebtIncrease;
    }

    function adjustTrove(
        AdjustTroveParam memory adjustParam,
        bytes[] calldata priceFeedUpdateData
    ) external payable;

    function claimCollateral() external;

    function getCompositeDebt(uint _debt) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./ILiquityBase.sol";
import "./IStabilityPool.sol";
import "./IUSDSToken.sol";
import "./ISABLEToken.sol";
import "./ISableStakingV2.sol";
import "./IOracleRateCalculation.sol";
import "./ICollSurplusPool.sol";
import "./ISortedTroves.sol";
import "./ITroveHelper.sol";
import "../Dependencies/LiquityBase.sol";
import "../Dependencies/Ownable.sol";
import "../Dependencies/CheckContract.sol";

// Common interface for the Trove Manager.
interface ITroveManager is ILiquityBase {
    // --- Events ---
    event AddressesChanged(DependencyAddressParam param);

    event Liquidation(
        uint _liquidatedDebt,
        uint _liquidatedColl,
        uint _collGasCompensation,
        uint _USDSGasCompensation
    );
    event Redemption(uint _attemptedUSDSAmount, uint _actualUSDSAmount, uint _BNBSent, uint _BNBFee);
    event TroveUpdated(
        address indexed _borrower,
        uint _debt,
        uint _coll,
        uint _stake,
        TroveManagerOperation _operation
    );
    event TroveLiquidated(
        address indexed _borrower,
        uint _debt,
        uint _coll,
        TroveManagerOperation _operation
    );
    event BaseRateUpdated(uint _baseRate);
    event LastFeeOpTimeUpdated(uint _lastFeeOpTime);
    event TotalStakesUpdated(uint _newTotalStakes);
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);
    event LTermsUpdated(uint _L_BNB, uint _L_USDSDebt);
    event TroveSnapshotsUpdated(uint _L_BNB, uint _L_USDSDebt);
    event TroveIndexUpdated(address _borrower, uint _newIndex);

    enum TroveManagerOperation {
        applyPendingRewards,
        liquidateInNormalMode,
        liquidateInRecoveryMode,
        redeemCollateral
    }

    enum Status {
        nonExistent,
        active,
        closedByOwner,
        closedByLiquidation,
        closedByRedemption
    }

    // Store the necessary data for a trove
    struct Trove {
        uint debt;
        uint coll;
        uint stake;
        Status status;
        uint128 arrayIndex;
    }

    // Object containing the BNB and USDS snapshots for a given active trove
    struct RewardSnapshot {
        uint BNB;
        uint USDSDebt;
    }

    /*
     * --- Variable container structs for liquidations ---
     *
     * These structs are used to hold, return and assign variables inside the liquidation functions,
     * in order to avoid the error: "CompilerError: Stack too deep".
     **/

    struct LocalVariables_OuterLiquidationFunction {
        uint price;
        uint USDSInStabPool;
        bool recoveryModeAtStart;
        uint liquidatedDebt;
        uint liquidatedColl;
    }

    struct LocalVariables_InnerSingleLiquidateFunction {
        uint collToLiquidate;
        uint pendingDebtReward;
        uint pendingCollReward;
    }

    struct LocalVariables_LiquidationSequence {
        uint remainingUSDSInStabPool;
        uint i;
        uint ICR;
        address user;
        address firstUser;
        bool backToNormalMode;
        uint entireSystemDebt;
        uint entireSystemColl;
        uint MCR;
    }

    struct LiquidationValues {
        uint entireTroveDebt;
        uint entireTroveColl;
        uint collGasCompensation;
        uint USDSGasCompensation;
        uint debtToOffset;
        uint collToSendToSP;
        uint debtToRedistribute;
        uint collToRedistribute;
        uint collSurplus;
    }

    struct LiquidationTotals {
        uint totalCollInSequence;
        uint totalDebtInSequence;
        uint totalCollGasCompensation;
        uint totalUSDSGasCompensation;
        uint totalDebtToOffset;
        uint totalCollToSendToSP;
        uint totalDebtToRedistribute;
        uint totalCollToRedistribute;
        uint totalCollSurplus;
    }

    struct ContractsCache {
        IActivePool activePool;
        IDefaultPool defaultPool;
        IUSDSToken usdsToken;
        ISableStakingV2 sableStaking;
        ISortedTroves sortedTroves;
        ICollSurplusPool collSurplusPool;
        address gasPoolAddress;
    }
    // --- Variable container structs for redemptions ---

    struct RedemptionTotals {
        uint remainingUSDS;
        uint totalUSDSToRedeem;
        uint totalBNBDrawn;
        uint BNBFee;
        uint BNBToSendToRedeemer;
        uint decayedBaseRate;
        uint price;
        uint totalUSDSSupplyAtStart;
    }

    struct SingleRedemptionValues {
        uint USDSLot;
        uint BNBLot;
        bool cancelledPartial;
    }

    // Struct to avoid stack too deep
    struct LocalVariables_RedeemCollateralFromTrove {
        uint usdsGasCompensation;
        uint minNetDebt;
        uint newDebt;
        uint newColl;
    }

    struct RedeemCollateralFromTroveParam {
        ContractsCache contractsCache;
        address borrower;
        uint maxUSDSamount;
        uint price;
        address upperPartialRedemptionHint;
        address lowerPartialRedemptionHint;
        uint partialRedemptionHintNICR;
    }
    
    struct DependencyAddressParam {
        address borrowerOperationsAddress;
        address activePoolAddress;
        address defaultPoolAddress;
        address stabilityPoolAddress;
        address gasPoolAddress;
        address collSurplusPoolAddress;
        address priceFeedAddress;
        address usdsTokenAddress;
        address sortedTrovesAddress;
        address sableTokenAddress;
        address sableStakingAddress;
        address systemStateAddress;
        address oracleRateCalcAddress;
        address troveHelperAddress;
    }

    // --- Functions ---

    function setAddresses(DependencyAddressParam memory param) external;

    function stabilityPool() external view returns (IStabilityPool);

    function usdsToken() external view returns (IUSDSToken);

    function sableToken() external view returns (ISABLEToken);

    function sableStaking() external view returns (ISableStakingV2);

    function oracleRateCalc() external view returns (IOracleRateCalculation);

    function getTroveOwnersCount() external view returns (uint);

    function getTroveFromTroveOwnersArray(uint _index) external view returns (address);

    function getNominalICR(address _borrower) external view returns (uint);

    function getCurrentICR(address _borrower, uint _price) external view returns (uint);

    function liquidate(
        address _borrower,
        bytes[] calldata priceFeedUpdateData
    ) external;

    function liquidateTroves(
        uint _n,
        bytes[] calldata priceFeedUpdateData
    ) external;

    function batchLiquidateTroves(
        address[] calldata _troveArray,
        bytes[] calldata priceFeedUpdateData    
    ) external;

    function redeemCollateral(
        uint _USDSAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) external;

    function updateStakeAndTotalStakes(address _borrower) external returns (uint);

    function updateTroveRewardSnapshots(address _borrower) external;

    function addTroveOwnerToArray(address _borrower) external returns (uint index);

    function applyPendingRewards(address _borrower) external;

    function getPendingBNBReward(address _borrower) external view returns (uint);

    function getPendingUSDSDebtReward(address _borrower) external view returns (uint);

    function hasPendingRewards(address _borrower) external view returns (bool);

    function getEntireDebtAndColl(
        address _borrower
    )
        external
        view
        returns (uint debt, uint coll, uint pendingUSDSDebtReward, uint pendingBNBReward);

    function closeTrove(address _borrower) external;

    function removeStake(address _borrower) external;

    function getRedemptionRate(uint _oracleRate) external view returns (uint);

    function getRedemptionRateWithDecay(uint _oracleRate) external view returns (uint);

    function getRedemptionFeeWithDecay(uint _BNBDrawn, uint _oracleRate) external view returns (uint);

    function getBorrowingRate(uint _oracleRate) external view returns (uint);

    function getBorrowingRateWithDecay(uint _oracleRate) external view returns (uint);

    function getBorrowingFee(uint USDSDebt, uint _oracleRate) external view returns (uint);

    function getBorrowingFeeWithDecay(uint _USDSDebt, uint _oracleRate) external view returns (uint);

    function decayBaseRateFromBorrowing() external;

    function getTroveStatus(address _borrower) external view returns (uint);

    function getTroveStake(address _borrower) external view returns (uint);

    function getTroveDebt(address _borrower) external view returns (uint);

    function getTroveColl(address _borrower) external view returns (uint);

    function setTroveStatus(address _borrower, uint num) external;

    function increaseTroveColl(address _borrower, uint _collIncrease) external returns (uint);

    function decreaseTroveColl(address _borrower, uint _collDecrease) external returns (uint);

    function increaseTroveDebt(address _borrower, uint _debtIncrease) external returns (uint);

    function decreaseTroveDebt(address _borrower, uint _collDecrease) external returns (uint);

    function getTCR(uint _price) external view returns (uint);

    function checkRecoveryMode(uint _price) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./ILiquityBase.sol";
import "./IStabilityPool.sol";
import "./IUSDSToken.sol";
import "./ISABLEToken.sol";
import "./ISableStakingV2.sol";
import "./IOracleRateCalculation.sol";
import "./ICollSurplusPool.sol";
import "./ISortedTroves.sol";
import "./ITroveManager.sol";
import "../Dependencies/LiquityBase.sol";
import "../Dependencies/Ownable.sol";
import "../Dependencies/CheckContract.sol";

// Common interface for the Trove Manager.
interface ITroveHelper {
    function setAddresses(
        address _troveManagerAddress,
        address _systemStateAddress,
        address _sortedTrovesAddress,
        address _sableTokenAddress,
        address _activePoolAddress,
        address _defaultPoolAddress
    ) external;

    function getCappedOffsetVals(
        uint _entireTroveDebt,
        uint _entireTroveColl,
        uint _price
    ) external view returns (ITroveManager.LiquidationValues memory singleLiquidation);

    function isValidFirstRedemptionHint(
        ISortedTroves _sortedTroves,
        address _firstRedemptionHint,
        uint _price
    ) external view returns (bool);

    function requireValidMaxFeePercentage(uint _maxFeePercentage) external view;

    function requireAfterBootstrapPeriod() external view;

    function requireUSDSBalanceCoversRedemption(
        IUSDSToken _usdsToken,
        address _redeemer,
        uint _amount
    ) external view;

    function requireMoreThanOneTroveInSystem(uint TroveOwnersArrayLength) external view;

    function requireAmountGreaterThanZero(uint _amount) external view;

    function requireTCRoverMCR(uint _price) external view;

    function checkPotentialRecoveryMode(
        uint _entireSystemColl,
        uint _entireSystemDebt,
        uint _price
    ) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPriceFeed.sol";


interface ILiquityBase {
    function priceFeed() external view returns (IPriceFeed);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

/*
 * The Stability Pool holds USDS tokens deposited by Stability Pool depositors.
 *
 * When a trove is liquidated, then depending on system conditions, some of its USDS debt gets offset with
 * USDS in the Stability Pool:  that is, the offset debt evaporates, and an equal amount of USDS tokens in the Stability Pool is burned.
 *
 * Thus, a liquidation causes each depositor to receive a USDS loss, in proportion to their deposit as a share of total deposits.
 * They also receive an BNB gain, as the BNB collateral of the liquidated trove is distributed among Stability depositors,
 * in the same proportion.
 *
 * When a liquidation occurs, it depletes every deposit by the same fraction: for example, a liquidation that depletes 40%
 * of the total USDS in the Stability Pool, depletes 40% of each deposit.
 *
 * A deposit that has experienced a series of liquidations is termed a "compounded deposit": each liquidation depletes the deposit,
 * multiplying it by some factor in range ]0,1[
 *
 * Please see the implementation spec in the proof document, which closely follows on from the compounded deposit / BNB gain derivations:
 * https://github.com/liquity/liquity/blob/master/papers/Scalable_Reward_Distribution_with_Compounding_Stakes.pdf
 *
 * --- SABLE ISSUANCE TO STABILITY POOL DEPOSITORS ---
 *
 * An SABLE issuance event occurs at every deposit operation, and every liquidation.
 *
 * Each deposit is tagged with the address of the front end through which it was made.
 *
 * All deposits earn a share of the issued SABLE in proportion to the deposit as a share of total deposits. The SABLE earned
 * by a given deposit, is split between the depositor and the front end through which the deposit was made, based on the front end's kickbackRate.
 *
 * Please see the system Readme for an overview:
 * https://github.com/liquity/dev/blob/main/README.md#lqty-issuance-to-stability-providers
 */
interface IStabilityPool {

    // --- Events ---
    
    event StabilityPoolBNBBalanceUpdated(uint _newBalance);
    event StabilityPoolUSDSBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event USDSTokenAddressChanged(address _newUSDSTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(address indexed _frontEnd, uint _newFrontEndStake, address _depositor);

    event BNBGainWithdrawn(address indexed _depositor, uint _BNB, uint _USDSLoss);
    event SABLEPaidToDepositor(address indexed _depositor, uint _SABLE);
    event SABLEPaidToFrontEnd(address indexed _frontEnd, uint _SABLE);
    event EtherSent(address _to, uint _amount);

    // --- Functions ---

    /*
     * Called only once on init, to set addresses of other Sable contracts
     * Callable only by owner, renounces ownership at the end
     */
    function setParams(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _usdsTokenAddress,
        address _sortedTrovesAddress,
        address _priceFeedAddress,
        address _communityIssuanceAddress,
        address _systemStateAddress
    ) external;

    /*
     * Initial checks:
     * - Frontend is registered or zero address
     * - Sender is not a registered frontend
     * - _amount is not zero
     * ---
     * - Triggers a SABLE issuance, based on time passed since the last issuance. The SABLE issuance is shared between *all* depositors and front ends
     * - Tags the deposit with the provided front end tag param, if it's a new deposit
     * - Sends depositor's accumulated gains (SABLE, BNB) to depositor
     * - Sends the tagged front end's accumulated SABLE gains to the tagged front end
     * - Increases deposit and tagged front end's stake, and takes new snapshots for each.
     */
    function provideToSP(uint _amount, address _frontEndTag) external;

    /*
     * Initial checks:
     * - _amount is zero or there are no under collateralized troves left in the system
     * - User has a non zero deposit
     * ---
     * - Triggers a SABLE issuance, based on time passed since the last issuance. The SABLE issuance is shared between *all* depositors and front ends
     * - Removes the deposit's front end tag if it is a full withdrawal
     * - Sends all depositor's accumulated gains (SABLE, BNB) to depositor
     * - Sends the tagged front end's accumulated SABLE gains to the tagged front end
     * - Decreases deposit and tagged front end's stake, and takes new snapshots for each.
     *
     * If _amount > userDeposit, the user withdraws all of their compounded deposit.
     */
    function withdrawFromSP(uint _amount, bytes[] calldata priceFeedUpdateData) external;

    /*
     * Initial checks:
     * - User has a non zero deposit
     * - User has an open trove
     * - User has some BNB gain
     * ---
     * - Triggers a SABLE issuance, based on time passed since the last issuance. The SABLE issuance is shared between *all* depositors and front ends
     * - Sends all depositor's SABLE gain to  depositor
     * - Sends all tagged front end's SABLE gain to the tagged front end
     * - Transfers the depositor's entire BNB gain from the Stability Pool to the caller's trove
     * - Leaves their compounded deposit in the Stability Pool
     * - Updates snapshots for deposit and tagged front end stake
     */
    function withdrawBNBGainToTrove(
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external;

    /*
     * Initial checks:
     * - Frontend (sender) not already registered
     * - User (sender) has no deposit
     * - _kickbackRate is in the range [0, 100%]
     * ---
     * Front end makes a one-time selection of kickback rate upon registering
     */
    function registerFrontEnd(uint _kickbackRate) external;

    /*
     * Initial checks:
     * - Caller is TroveManager
     * ---
     * Cancels out the specified debt against the USDS contained in the Stability Pool (as far as possible)
     * and transfers the Trove's BNB collateral from ActivePool to StabilityPool.
     * Only called by liquidation functions in the TroveManager.
     */
    function offset(uint _debt, uint _coll) external;

    /*
     * Returns the total amount of BNB held by the pool, accounted in an internal variable instead of `balance`,
     * to exclude edge cases like BNB received from a self-destruct.
     */
    function getBNB() external view returns (uint);

    /*
     * Returns USDS held in the pool. Changes when users deposit/withdraw, and when Trove debt is offset.
     */
    function getTotalUSDSDeposits() external view returns (uint);

    /*
     * Calculates the BNB gain earned by the deposit since its last snapshots were taken.
     */
    function getDepositorBNBGain(address _depositor) external view returns (uint);

    /*
     * Calculate the SABLE gain earned by a deposit since its last snapshots were taken.
     * If not tagged with a front end, the depositor gets a 100% cut of what their deposit earned.
     * Otherwise, their cut of the deposit's earnings is equal to the kickbackRate, set by the front end through
     * which they made their deposit.
     */
    function getDepositorSABLEGain(address _depositor) external view returns (uint);

    /*
     * Return the SABLE gain earned by the front end.
     */
    function getFrontEndSABLEGain(address _frontEnd) external view returns (uint);

    /*
     * Return the user's compounded deposit.
     */
    function getCompoundedUSDSDeposit(address _depositor) external view returns (uint);

    /*
     * Return the front end's compounded stake.
     *
     * The front end's compounded stake is equal to the sum of its depositors' compounded deposits.
     */
    function getCompoundedFrontEndStake(address _frontEnd) external view returns (uint);

    function ownerTriggerIssuance() external;

    /*
     * Fallback function
     * Only callable by Active Pool, it just accounts for BNB received
     * receive() external payable;
     */
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/IERC20.sol";
import "../Dependencies/IERC2612.sol";

interface IUSDSToken is IERC20, IERC2612 { 
    
    // --- Events ---

    event TroveManagerAddressChanged(address _troveManagerAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);

    event USDSTokenBalanceUpdated(address _user, uint _amount);

    // --- Functions ---

    function mint(address _account, uint256 _amount) external;

    function burn(address _account, uint256 _amount) external;

    function sendToPool(address _sender,  address poolAddress, uint256 _amount) external;

    function returnFromPool(address poolAddress, address user, uint256 _amount ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/IERC20.sol";
import "../Dependencies/IERC2612.sol";

interface ISABLEToken is IERC20, IERC2612 { 
   
    // --- Events ---
    
    event CommunityIssuanceAddressSet(address _communityIssuanceAddress);
    event SABLEStakingAddressSet(address _sableStakingAddress);

    // --- Functions ---
    
    function getDeploymentStartTime() external view returns (uint256);

}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

interface ISableStakingV2 {

    // --- Events --
    
    event SABLETokenAddressSet(address _sableTokenAddress);
    event USDSTokenAddressSet(address _usdsTokenAddress);
    event TroveManagerAddressSet(address _troveManager);
    event BorrowerOperationsAddressSet(address _borrowerOperationsAddress);
    event SableRewarderAddressSet(address _sableRewarderAddress);
    event ActivePoolAddressSet(address _activePoolAddress);

    event StakeChanged(address indexed staker, uint newStake);
    event StakingGainsWithdrawn(address indexed staker, uint USDSGain, uint BNBGain, uint SABLEGain);
    event F_BNBUpdated(uint _F_BNB);
    event F_USDSUpdated(uint _F_USDS);
    event F_SABLEUpdated(uint _F_SABLE);
    event TotalSableLPStakedUpdated(uint _totalSableLPStaked);
    event EtherSent(address _account, uint _amount);
    event StakerSnapshotsUpdated(address _staker, uint _F_BNB, uint _F_USDS, uint _F_SABLE);

    event SableLPTokenAddressSet(address _sableLPTokenAddress);

    // --- Functions ---

    function setAddresses
    (
        address _sableTokenAddress,
        address _usdsTokenAddress,
        address _troveManagerAddress, 
        address _borrowerOperationsAddress,
        address _sableRewarderAddress,
        address _activePoolAddress
    )  external;

    function setSableLPAddress(address _sableLPTokenAddress) external;

    function stake(uint _SABLEamount) external;

    function unstake(uint _SABLEamount) external;

    function increaseF_BNB(uint _BNBFee) external; 

    function increaseF_USDS(uint _USDSFee) external;

    function increaseF_SABLE(uint _SABLEGain) external;

    function getPendingBNBGain(address _user) external view returns (uint);

    function getPendingUSDSGain(address _user) external view returns (uint);

    function getPendingSABLEGain(address _user) external view returns (uint);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

interface IOracleRateCalculation {
    // --- Functions ---

    function getOracleRate(
        bytes32 oracleKey, 
        uint deviationPyth, 
        uint publishTimePyth
    ) external view returns (uint);
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;


interface ICollSurplusPool {

    // --- Events ---
    
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account, uint _newBalance);
    event EtherSent(address _to, uint _amount);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress
    ) external;

    function getBNB() external view returns (uint);

    function getCollateral(address _account) external view returns (uint);

    function accountSurplus(address _account, uint _amount) external;

    function claimColl(address _account) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

// Common interface for the SortedTroves Doubly Linked List.
interface ISortedTroves {

    // --- Events ---
    
    event SortedTrovesAddressChanged(address _sortedDoublyLLAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint _NICR);
    event NodeRemoved(address _id);

    struct SortedTrovesInsertParam {
        address id;
        uint256 newNICR;
        address prevId;
        address nextId;
    }

    // --- Functions ---
    
    function setParams(uint256 _size, address _TroveManagerAddress, address _borrowerOperationsAddress) external;

    function insert(SortedTrovesInsertParam memory param) external;

    function remove(address _id) external;

    function reInsert(SortedTrovesInsertParam memory param) external;

    function contains(address _id) external view returns (bool);

    function isFull() external view returns (bool);

    function isEmpty() external view returns (bool);

    function getSize() external view returns (uint256);

    function getMaxSize() external view returns (uint256);

    function getFirst() external view returns (address);

    function getLast() external view returns (address);

    function getNext(address _id) external view returns (address);

    function getPrev(address _id) external view returns (address);

    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);

    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./BaseMath.sol";
import "./LiquityMath.sol";
import "../Interfaces/IActivePool.sol";
import "../Interfaces/IDefaultPool.sol";
import "../Interfaces/IPriceFeed.sol";
import "../Interfaces/ILiquityBase.sol";
import "../Interfaces/ISystemState.sol";

/*
 * Base contract for TroveManager, BorrowerOperations and StabilityPool. Contains global system constants and
 * common functions.
 */
contract LiquityBase is BaseMath, ILiquityBase {
    using SafeMath for uint;

    uint public constant _100pct = 1000000000000000000; // 1e18 == 100%

    uint public constant PERCENT_DIVISOR = 200; // dividing by 200 yields 0.5%

    address public timeLock;

    IActivePool public activePool;

    IDefaultPool public defaultPool;

    IPriceFeed public override priceFeed;

    ISystemState public systemState;

    // --- Gas compensation functions ---

    // Returns the composite debt (drawn debt + gas compensation) of a trove, for the purpose of ICR calculation
    function _getCompositeDebt(uint _debt) internal view returns (uint) {
        uint USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();
        return _debt.add(USDS_GAS_COMPENSATION);
    }

    function _getNetDebt(uint _debt) internal view returns (uint) {
        uint USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();
        return _debt.sub(USDS_GAS_COMPENSATION);
    }

    // Return the amount of BNB to be drawn from a trove's collateral and sent as gas compensation.
    function _getCollGasCompensation(uint _entireColl) internal pure returns (uint) {
        return _entireColl / PERCENT_DIVISOR;
    }

    function getEntireSystemColl() public view returns (uint entireSystemColl) {
        uint activeColl = activePool.getBNB();
        uint liquidatedColl = defaultPool.getBNB();

        return activeColl.add(liquidatedColl);
    }

    function getEntireSystemDebt() public view returns (uint entireSystemDebt) {
        uint activeDebt = activePool.getUSDSDebt();
        uint closedDebt = defaultPool.getUSDSDebt();

        return activeDebt.add(closedDebt);
    }

    function _getTCR(uint _price) internal view returns (uint TCR) {
        uint entireSystemColl = getEntireSystemColl();
        uint entireSystemDebt = getEntireSystemDebt();

        TCR = LiquityMath._computeCR(entireSystemColl, entireSystemDebt, _price);

        return TCR;
    }

    function _checkRecoveryMode(uint _price) internal view returns (bool) {
        uint TCR = _getTCR(_price);
        uint CCR = systemState.getCCR();
        return TCR < CCR;
    }

    function _requireUserAcceptsFee(uint _fee, uint _value, uint _maxFeePercentage) internal pure {
        uint feePercentage = _fee.mul(DECIMAL_PRECISION).div(_value);
        require(feePercentage <= _maxFeePercentage, "Fee exceeded provided maximum");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./IPyth.sol";

interface IPriceFeed {

    // --- Events ---
    event LastGoodPriceUpdated(uint _lastGoodPrice);

    struct FetchPriceResult {
        uint price;
        bytes32 oracleKey;
        uint deviationPyth;
        uint publishTimePyth;
    }
   
    // --- Function ---
    // return price, oracleKey, deviationPyth, publishTimePyth
    // if get price from Chainlink, deviationPyth = publishTimePyth = 0
    function fetchPrice(bytes[] calldata priceFeedUpdateData) external returns (FetchPriceResult memory);

    function pyth() external view returns (IPyth);
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./PythStructs.sol";
import "./IPythEvents.sol";

/// @title Consume prices from the Pyth Network (https://pyth.network/).
/// @dev Please refer to the guidance at https://docs.pyth.network/consumers/best-practices for how to consume prices safely.
/// @author Pyth Data Association
interface IPyth is IPythEvents {
    /// @notice Returns the period (in seconds) that a price feed is considered valid since its publish time
    function getValidTimePeriod() external view returns (uint validTimePeriod);

    /// @notice Returns the price and confidence interval.
    /// @dev Reverts if the price has not been updated within the last `getValidTimePeriod()` seconds.
    /// @param id The Pyth Price Feed ID of which to fetch the price and confidence interval.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPrice(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price and confidence interval.
    /// @dev Reverts if the EMA price is not available.
    /// @param id The Pyth Price Feed ID of which to fetch the EMA price and confidence interval.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPrice(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the price of a price feed without any sanity checks.
    /// @dev This function returns the most recent price update in this contract without any recency checks.
    /// This function is unsafe as the returned price update may be arbitrarily far in the past.
    ///
    /// Users of this function should check the `publishTime` in the price to ensure that the returned price is
    /// sufficiently recent for their application. If you are considering using this function, it may be
    /// safer / easier to use either `getPrice` or `getPriceNoOlderThan`.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPriceUnsafe(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the price that is no older than `age` seconds of the current time.
    /// @dev This function is a sanity-checked version of `getPriceUnsafe` which is useful in
    /// applications that require a sufficiently-recent price. Reverts if the price wasn't updated sufficiently
    /// recently.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getPriceNoOlderThan(
        bytes32 id,
        uint age
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price of a price feed without any sanity checks.
    /// @dev This function returns the same price as `getEmaPrice` in the case where the price is available.
    /// However, if the price is not recent this function returns the latest available price.
    ///
    /// The returned price can be from arbitrarily far in the past; this function makes no guarantees that
    /// the returned price is recent or useful for any particular application.
    ///
    /// Users of this function should check the `publishTime` in the price to ensure that the returned price is
    /// sufficiently recent for their application. If you are considering using this function, it may be
    /// safer / easier to use either `getEmaPrice` or `getEmaPriceNoOlderThan`.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPriceUnsafe(
        bytes32 id
    ) external view returns (PythStructs.Price memory price);

    /// @notice Returns the exponentially-weighted moving average price that is no older than `age` seconds
    /// of the current time.
    /// @dev This function is a sanity-checked version of `getEmaPriceUnsafe` which is useful in
    /// applications that require a sufficiently-recent price. Reverts if the price wasn't updated sufficiently
    /// recently.
    /// @return price - please read the documentation of PythStructs.Price to understand how to use this safely.
    function getEmaPriceNoOlderThan(
        bytes32 id,
        uint age
    ) external view returns (PythStructs.Price memory price);

    /// @notice Update price feeds with given update messages.
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    /// Prices will be updated if they are more recent than the current stored prices.
    /// The call will succeed even if the update is not the most recent.
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid.
    /// @param updateData Array of price update data.
    function updatePriceFeeds(bytes[] calldata updateData) external payable;

    /// @notice Wrapper around updatePriceFeeds that rejects fast if a price update is not necessary. A price update is
    /// necessary if the current on-chain publishTime is older than the given publishTime. It relies solely on the
    /// given `publishTimes` for the price feeds and does not read the actual price update publish time within `updateData`.
    ///
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    ///
    /// `priceIds` and `publishTimes` are two arrays with the same size that correspond to senders known publishTime
    /// of each priceId when calling this method. If all of price feeds within `priceIds` have updated and have
    /// a newer or equal publish time than the given publish time, it will reject the transaction to save gas.
    /// Otherwise, it calls updatePriceFeeds method to update the prices.
    ///
    /// @dev Reverts if update is not needed or the transferred fee is not sufficient or the updateData is invalid.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param publishTimes Array of publishTimes. `publishTimes[i]` corresponds to known `publishTime` of `priceIds[i]`
    function updatePriceFeedsIfNecessary(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64[] calldata publishTimes
    ) external payable;

    /// @notice Returns the required fee to update an array of price updates.
    /// @param updateData Array of price update data.
    /// @return feeAmount The required fee in Wei.
    function getUpdateFee(
        bytes[] calldata updateData
    ) external view returns (uint feeAmount);

    /// @notice Parse `updateData` and return price feeds of the given `priceIds` if they are all published
    /// within `minPublishTime` and `maxPublishTime`.
    ///
    /// You can use this method if you want to use a Pyth price at a fixed time and not the most recent price;
    /// otherwise, please consider using `updatePriceFeeds`. This method does not store the price updates on-chain.
    ///
    /// This method requires the caller to pay a fee in wei; the required fee can be computed by calling
    /// `getUpdateFee` with the length of the `updateData` array.
    ///
    ///
    /// @dev Reverts if the transferred fee is not sufficient or the updateData is invalid or there is
    /// no update for any of the given `priceIds` within the given time range.
    /// @param updateData Array of price update data.
    /// @param priceIds Array of price ids.
    /// @param minPublishTime minimum acceptable publishTime for the given `priceIds`.
    /// @param maxPublishTime maximum acceptable publishTime for the given `priceIds`.
    /// @return priceFeeds Array of the price feeds corresponding to the given `priceIds` (with the same order).
    function parsePriceFeedUpdates(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable returns (PythStructs.PriceFeed[] memory priceFeeds);
}// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.6.11;

contract PythStructs {
    // A price with a degree of uncertainty, represented as a price +- a confidence interval.
    //
    // The confidence interval roughly corresponds to the standard error of a normal distribution.
    // Both the price and confidence are stored in a fixed-point numeric representation,
    // `x * (10^expo)`, where `expo` is the exponent.
    //
    // Please refer to the documentation at https://docs.pyth.network/consumers/best-practices for how
    // to how this price safely.
    struct Price {
        // Price
        int64 price;
        // Confidence interval around the price
        uint64 conf;
        // Price exponent
        int32 expo;
        // Unix timestamp describing when the price was published
        uint publishTime;
    }

    // PriceFeed represents a current aggregate price from pyth publisher feeds.
    struct PriceFeed {
        // The price ID.
        bytes32 id;
        // Latest available price
        Price price;
        // Latest available exponentially-weighted moving average price
        Price emaPrice;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

/// @title IPythEvents contains the events that Pyth contract emits.
/// @dev This interface can be used for listening to the updates for off-chain and testing purposes.
interface IPythEvents {
    /// @dev Emitted when the price feed with `id` has received a fresh update.
    /// @param id The Pyth Price Feed ID.
    /// @param publishTime Publish time of the given price update.
    /// @param price Price of the given price update.
    /// @param conf Confidence interval of the given price update.
    event PriceFeedUpdate(
        bytes32 indexed id,
        uint64 publishTime,
        int64 price,
        uint64 conf
    );

    /// @dev Emitted when a batch price update is processed successfully.
    /// @param chainId ID of the source chain that the batch price update comes from.
    /// @param sequenceNumber Sequence number of the batch price update.
    event BatchPriceFeedUpdate(uint16 chainId, uint64 sequenceNumber);
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

/**
 * Based on the OpenZeppelin IER20 interface:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 *
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
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
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

/**
 * @dev Interface of the ERC2612 standard as defined in the EIP.
 *
 * Adds the {permit} method, which can be used to change one's
 * {IERC20-allowance} without having to send a transaction, by signing a
 * message. This allows users to spend tokens without having to hold Ether.
 *
 * See https://eips.ethereum.org/EIPS/eip-2612.
 * 
 * Code adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237/
 */
interface IERC2612 {
    /**
     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 amount, 
                    uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    /**
     * @dev Returns the current ERC2612 nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases `owner`'s nonce by one. This
     * prevents a signature from being used multiple times.
     *
     * `owner` can limit the time a Permit is valid for by setting `deadline` to 
     * a value in the near future. The deadline argument can be set to uint(-1) to 
     * create Permits that effectively never expire.
     */
    function nonces(address owner) external view returns (uint256);
    
    function version() external view returns (string memory);
    function permitTypeHash() external view returns (bytes32);
    function domainSeparator() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;


contract BaseMath {
    uint constant public DECIMAL_PRECISION = 1e18;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./SafeMath.sol";
import "./console.sol";

library LiquityMath {
    using SafeMath for uint;

    uint internal constant DECIMAL_PRECISION = 1e18;

    /* Precision for Nominal ICR (independent of price). Rationale for the value:
     *
     * - Making it “too high” could lead to overflows.
     * - Making it “too low” could lead to an ICR equal to zero, due to truncation from Solidity floor division. 
     *
     * This value of 1e20 is chosen for safety: the NICR will only overflow for numerator > ~1e39 BNB,
     * and will only truncate to 0 if the denominator is at least 1e20 times greater than the numerator.
     *
     */
    uint internal constant NICR_PRECISION = 1e20;

    function _min(uint _a, uint _b) internal pure returns (uint) {
        return (_a < _b) ? _a : _b;
    }

    function _max(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a : _b;
    }

    /* 
    * Multiply two decimal numbers and use normal rounding rules:
    * -round product up if 19'th mantissa digit >= 5
    * -round product down if 19'th mantissa digit < 5
    *
    * Used only inside the exponentiation, _decPow().
    */
    function decMul(uint x, uint y) internal pure returns (uint decProd) {
        uint prod_xy = x.mul(y);

        decProd = prod_xy.add(DECIMAL_PRECISION / 2).div(DECIMAL_PRECISION);
    }

    /* 
    * _decPow: Exponentiation function for 18-digit decimal base, and integer exponent n.
    * 
    * Uses the efficient "exponentiation by squaring" algorithm. O(log(n)) complexity. 
    * 
    * Called by two functions that represent time in units of minutes:
    * 1) TroveManager._calcDecayedBaseRate
    * 2) CommunityIssuance._getCumulativeIssuanceFraction 
    * 
    * The exponent is capped to avoid reverting due to overflow. The cap 525600000 equals
    * "minutes in 1000 years": 60 * 24 * 365 * 1000
    * 
    * If a period of > 1000 years is ever used as an exponent in either of the above functions, the result will be
    * negligibly different from just passing the cap, since: 
    *
    * In function 1), the decayed base rate will be 0 for 1000 years or > 1000 years
    * In function 2), the difference in tokens issued at 1000 years and any time > 1000 years, will be negligible
    */
    function _decPow(uint _base, uint _minutes) internal pure returns (uint) {
       
        if (_minutes > 525600000) {_minutes = 525600000;}  // cap to avoid overflow
    
        if (_minutes == 0) {return DECIMAL_PRECISION;}

        uint y = DECIMAL_PRECISION;
        uint x = _base;
        uint n = _minutes;

        // Exponentiation-by-squaring
        while (n > 1) {
            if (n % 2 == 0) {
                x = decMul(x, x);
                n = n.div(2);
            } else { // if (n % 2 != 0)
                y = decMul(x, y);
                x = decMul(x, x);
                n = (n.sub(1)).div(2);
            }
        }

        return decMul(x, y);
  }

    function _getAbsoluteDifference(uint _a, uint _b) internal pure returns (uint) {
        return (_a >= _b) ? _a.sub(_b) : _b.sub(_a);
    }

    function _computeNominalCR(uint _coll, uint _debt) internal pure returns (uint) {
        if (_debt > 0) {
            return _coll.mul(NICR_PRECISION).div(_debt);
        }
        // Return the maximal value for uint256 if the Trove has a debt of 0. Represents "infinite" CR.
        else { // if (_debt == 0)
            return 2**256 - 1;
        }
    }

    function _computeCR(uint _coll, uint _debt, uint _price) internal pure returns (uint) {
        if (_debt > 0) {
            uint newCollRatio = _coll.mul(_price).div(_debt);

            return newCollRatio;
        }
        // Return the maximal value for uint256 if the Trove has a debt of 0. Represents "infinite" CR.
        else { // if (_debt == 0)
            return 2**256 - 1; 
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPool.sol";


interface IDefaultPool is IPool {
    // --- Events ---
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolUSDSDebtUpdated(uint _USDSDebt);
    event DefaultPoolBNBBalanceUpdated(uint _BNB);

    // --- Functions ---
    function sendBNBToActivePool(uint _amount) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

interface ISystemState {
    function setUSDSGasCompensation(uint _value) external;

    function setBorrowingFeeFloor(uint _value) external;

    function setRedemptionFeeFloor(uint _value) external;

    function setMinNetDebt(uint _value) external;

    function setMCR(uint _value) external;

    function setCCR(uint _value) external;

    function getUSDSGasCompensation() external view returns (uint);

    function getBorrowingFeeFloor() external view returns (uint);

    function getRedemptionFeeFloor() external view returns (uint);

    function getMinNetDebt() external view returns (uint);

    function getMCR() external view returns (uint);

    function getCCR() external view returns (uint);

    event USDSGasCompensationChanged(uint _o, uint _n);
    event BorrowingFeeFloorChanged(uint _o, uint _n);
    event RedemptionFeeFloorChanged(uint _o, uint _n);
    event MinNetDebtChanged(uint _o, uint _n);
    event MCR_Changed(uint _o, uint _n);
    event CCR_Changed(uint _o, uint _n);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

interface ICommunityIssuance { 
    
    // --- Events ---
    
    event SABLETokenAddressSet(address _sableTokenAddress);
    event StabilityPoolAddressSet(address _stabilityPoolAddress);
    event RewardPerSecUpdated(uint256 _newRewardPerSec);

    // --- Functions ---

    function setParams
    (
        address _sableTokenAddress, 
        address _stabilityPoolAddress,
        uint256 _latestRewardPerSec
    ) external;

    function issueSABLE() external returns (uint);

    function sendSABLE(address _account, uint _SABLEamount) external;

    function balanceSABLE() external returns (uint);

    function updateRewardPerSec(uint _newRewardPerSec) external;

    function transferOwnership(address _newOwner) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

// uint128 addition and subtraction, with overflow protection.

library LiquitySafeMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "LiquitySafeMath128: addition overflow");

        return c;
    }
   
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "LiquitySafeMath128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
 * ```
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

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
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
            set._indexes[value] = set._values.length;
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
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
     * @dev Returns the number of values on the set. O(1).
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
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../USDSToken.sol";

contract USDSTokenTester is USDSToken {
    
    bytes32 private immutable _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    
    constructor( 
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _borrowerOperationsAddress
    ) public USDSToken(_troveManagerAddress,
                      _stabilityPoolAddress,
                      _borrowerOperationsAddress) {}
    
    function unprotectedMint(address _account, uint256 _amount) external {
        // No check on caller here

        _mint(_account, _amount);
    }

    function unprotectedBurn(address _account, uint _amount) external {
        // No check on caller here
        
        _burn(_account, _amount);
    }

    function unprotectedSendToPool(address _sender,  address _poolAddress, uint256 _amount) external {
        // No check on caller here

        _transfer(_sender, _poolAddress, _amount);
    }

    function unprotectedReturnFromPool(address _poolAddress, address _receiver, uint256 _amount ) external {
        // No check on caller here

        _transfer(_poolAddress, _receiver, _amount);
    }

    function callInternalApprove(address owner, address spender, uint256 amount) external returns (bool) {
        _approve(owner, spender, amount);
    }

    function getChainId() external pure returns (uint256 chainID) {
        //return _chainID(); // it’s private
        assembly {
            chainID := chainid()
        }
    }

    function getDigest(address owner, address spender, uint amount, uint nonce, uint deadline) external view returns (bytes32) {
        return keccak256(abi.encodePacked(
                uint16(0x1901),
                domainSeparator(),
                keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, amount, nonce, deadline))
            )
        );
    }

    function recoverAddress(bytes32 digest, uint8 v, bytes32 r, bytes32 s) external pure returns (address) {
        return ecrecover(digest, v, r, s);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/AggregatorV3Interface.sol";
import "../Dependencies/console.sol";

contract MockAggregator is AggregatorV3Interface {
    
    // storage variables to hold the mock data
    uint8 private decimalsVal = 8;
    int private price;
    int private prevPrice;
    uint private updateTime;
    uint private prevUpdateTime;

    uint80 private latestRoundId;
    uint80 private prevRoundId;

    bool latestRevert;
    bool prevRevert;
    bool decimalsRevert;

    // --- Functions ---

    function setDecimals(uint8 _decimals) external {
        decimalsVal = _decimals;
    }

    function setPrice(int _price) external {
        price = _price;
    }

    function setPrevPrice(int _prevPrice) external {
        prevPrice = _prevPrice;
    }

    function setPrevUpdateTime(uint _prevUpdateTime) external {
        prevUpdateTime = _prevUpdateTime;
    }

    function setUpdateTime(uint _updateTime) external  {
        updateTime = _updateTime;
    }

    function setLatestRevert() external  {
        latestRevert = !latestRevert;
    }

    function setPrevRevert() external  {
        prevRevert = !prevRevert;
    }

    function setDecimalsRevert() external {
        decimalsRevert = !decimalsRevert;
    }

    function setLatestRoundId(uint80 _latestRoundId) external {
        latestRoundId = _latestRoundId;
    }

      function setPrevRoundId(uint80 _prevRoundId) external {
        prevRoundId = _prevRoundId;
    }
    

    // --- Getters that adhere to the AggregatorV3 interface ---

    function decimals() external override view returns (uint8) {
        if (decimalsRevert) {require(1== 0, "decimals reverted");}

        return decimalsVal;
    }

    function latestRoundData()
        external
        override
        view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) 
    {    
        if (latestRevert) { require(1== 0, "latestRoundData reverted");}

        return (latestRoundId, price, 0, updateTime, 0); 
    }

    function getRoundData(uint80)
    external
    override 
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) {
        if (prevRevert) {require( 1== 0, "getRoundData reverted");}

        return (prevRoundId, prevPrice, 0, updateTime, 0);
    }

    function description() external override view returns (string memory) {
        return "";
    }
    function version() external override view returns (uint256) {
        return 1;
    }
}
// SPDX-License-Identifier: MIT
// Code from https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

pragma solidity 0.6.11;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./Interfaces/IPriceFeed.sol";
import "./Interfaces/IPyth.sol";
import "./Interfaces/PythStructs.sol";
import "./Dependencies/AggregatorV3Interface.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/BaseMath.sol";
import "./Dependencies/LiquityMath.sol";
import "./Dependencies/console.sol";

/*
 * PriceFeed for mainnet deployment, to be connected to Pyth network
 * contract, and Chainlink's live BNB:USD aggregator reference contract.
 *
 * The PriceFeed uses Pyth as primary oracle, and Chainlink as fallback. It contains logic for
 * switching oracles based on oracle failures, timeouts, and conditions for returning to the primary
 * Pyth oracle.
 */
contract PriceFeed is Ownable, CheckContract, BaseMath, IPriceFeed {
    using SafeMath for uint256;

    string public constant NAME = "PriceFeed";

    AggregatorV3Interface public priceAggregator; // Mainnet Chainlink aggregator
    IPyth public override pyth; // Wrapper contract that calls the Pyth system

    // Core Sable contracts
    address borrowerOperationsAddress;
    address troveManagerAddress;
    address stabilityPoolAddress;

    // Use to convert a price answer to an 18-digit precision uint
    uint public constant TARGET_DIGITS = 18;
    uint public constant PYTH_DIGITS = 8;

    // Maximum time period allowed since Pyth's latest data timestamp, beyond which Pyth is considered frozen.
    uint public constant TIMEOUT = 14400; // 4 hours: 60 * 60 * 4

    // Maximum deviation allowed between two consecutive Chainlink oracle prices. 18-digit precision.
    uint public constant MAX_PRICE_DEVIATION_FROM_PREVIOUS_ROUND = 5e17; // 50%

    /*
     * The maximum relative price difference between two oracle responses allowed in order for the PriceFeed
     * to return to using the Pyth oracle. 18-digit precision.
     */
    uint public constant MAX_PRICE_DIFFERENCE_BETWEEN_ORACLES = 5e16; // 5%

    // If deviationPyth > 0.25%, use Chainlink
    uint public constant MAX_SCALED_DEVIATION_PYTH = (25 * DECIMAL_PRECISION) / 10000; // 0.25% * DEVIATION_PRECISION

    bytes32 public BNBFeed; // id of Pyth price feed for BNB:USD
    uint public age = 120; // seconds pyth price confidence

    // The last good price seen from an oracle by Sable
    uint public lastGoodPrice;

    struct PythResponse {
        bool success;
        uint256 pricePyth;
        uint256 deviationPyth;
        uint256 publishTimePyth;
    }

    struct ChainlinkResponse {
        uint80 roundId;
        int256 answer;
        uint256 timestamp;
        bool success;
        uint8 decimals;
    }

    enum Status {
        pythWorking,
        usingChainlinkPythUntrusted,
        bothOraclesUntrusted,
        usingChainlinkPythFrozen,
        usingPythChainlinkUntrusted
    }

    // The current status of the PricFeed, which determines the conditions for the next price fetch attempt
    Status public status;

    event LastGoodPriceUpdated(uint _lastGoodPrice);
    event PriceFeedStatusChanged(Status newStatus);
    event PriceAggregatorAddressChanged(address _priceAggregatorAddress);
    event PythAddressChanged(address _pythAddress);
    event TroveManagerAddressChanged(address _troveManagerAddress);
    event BorrowerOperationAddressChanged(address _borrowerOperationsAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event BNBFeedPythChanged(bytes32 _bnbFeedPyth);

    // --- Dependency setters ---

    function _setBNBFeed(bytes32 _BNBFeed) internal {
        BNBFeed = _BNBFeed;
    }

    function setAddresses(
        address _priceAggregatorAddress,
        address _pythAddress,
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _stabilityPoolAddress,
        bytes32 _bnbFeedPyth,
        bytes[] calldata priceFeedUpdateData
    ) external payable onlyOwner {
        checkContract(_priceAggregatorAddress);
        checkContract(_pythAddress);
        checkContract(_troveManagerAddress);
        checkContract(_borrowerOperationsAddress);
        checkContract(_stabilityPoolAddress);

        troveManagerAddress = _troveManagerAddress;
        borrowerOperationsAddress = _borrowerOperationsAddress;
        stabilityPoolAddress = _stabilityPoolAddress;

        priceAggregator = AggregatorV3Interface(_priceAggregatorAddress);
        pyth = IPyth(_pythAddress);

        // Explicitly set initial system status
        status = Status.pythWorking;

        _setBNBFeed(_bnbFeedPyth);

        // Get an initial price from Pyth to serve as first reference for lastGoodPrice
        PythResponse memory pythResponse = _getCurrentPythResponse(priceFeedUpdateData);
        require(
            !_pythResponseFailed(pythResponse) && !_pythIsFrozen(pythResponse),
            "PriceFeed: Pyth must be working and current"
        );

        _storePythPrice(pythResponse);

        emit PriceAggregatorAddressChanged(_priceAggregatorAddress);
        emit PythAddressChanged(_pythAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit BorrowerOperationAddressChanged(_borrowerOperationsAddress);
        emit StabilityPoolAddressChanged(_stabilityPoolAddress);
        emit BNBFeedPythChanged(_bnbFeedPyth);

        _renounceOwnership();
    }

    function _restrictCaller() internal view {
        require(
            msg.sender == address(this) ||
                msg.sender == troveManagerAddress ||
                msg.sender == borrowerOperationsAddress ||
                msg.sender == stabilityPoolAddress,
            "PriceFeed: Only restricted contract can call fetchPrice"
        );
    }

    // --- Functions ---

    /*
     * fetchPrice():
     * Returns the latest price obtained from the Oracle. Called by Sable functions that require a current price.
     *
     * Also callable by anyone externally.
     *
     * Non-view function - it stores the last good price seen by Sable.
     *
     * Uses a main oracle (Pyth) and a fallback oracle (Chainlink) in case Pyth fails. If both fail,
     * it uses the last good price seen by Sable.
     *
     */
    function fetchPrice(
        bytes[] calldata priceFeedUpdateData
    ) external override returns (FetchPriceResult memory result) {
        _restrictCaller();
        // Get current and previous price data from Pyth, and current price data from Chainlink
        ChainlinkResponse memory chainlinkResponse = _getCurrentChainlinkResponse();
        ChainlinkResponse memory prevChainlinkResponse = _getPrevChainlinkResponse(
            chainlinkResponse.roundId,
            chainlinkResponse.decimals
        );
        PythResponse memory pythResponse = _getCurrentPythResponse(priceFeedUpdateData);

        result.price = 0;
        result.deviationPyth = 0;
        result.publishTimePyth = 0;
        result.oracleKey = bytes32("PYTH");

        // --- CASE 1: System fetched last price from Pyth  ---
        if (status == Status.pythWorking) {
            // If Pyth is broken, try Chainlink
            if (_pythIsBroken(pythResponse)) {
                // If Chainlink is broken then both oracles are untrusted, so return the last good price
                if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.bothOraclesUntrusted);
                    result.price = lastGoodPrice;
                }
                /*
                 * If Chainlink is only frozen but otherwise returning valid data, return the last good price.
                 */
                else if (_chainlinkIsFrozen(chainlinkResponse)) {
                    _changeStatus(Status.usingChainlinkPythUntrusted);
                    result.price = lastGoodPrice;
                    result.oracleKey = bytes32("LINK");
                } else {
                    // If Pyth is broken and Chainlink is working, switch to Chainlink and return current Chainlink price
                    _changeStatus(Status.usingChainlinkPythUntrusted);
                    result.price = _storeChainlinkPrice(chainlinkResponse);
                    result.oracleKey = bytes32("LINK");
                }
            }
            // If Pyth is frozen, try Chainlink
            else if (_pythIsFrozen(pythResponse)) {
                // If Chainlink is broken too, remember Chainlink broke, and return last good price
                if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.usingPythChainlinkUntrusted);
                    result.price = lastGoodPrice;
                } else {
                    // If Chainlink is frozen or working, remember Pyth froze, and switch to Chainlink
                    _changeStatus(Status.usingChainlinkPythFrozen);
                    result.oracleKey = bytes32("LINK");

                    if (_chainlinkIsFrozen(chainlinkResponse)) {
                        result.price = lastGoodPrice;
                    } else {
                        // If Chainlink is working, use it
                        result.price = _storeChainlinkPrice(chainlinkResponse);
                    }
                }
            }
            // If Pyth is working
            else {
                // If Pyth is working and Chainlink is broken, remember Chainlink is broken
                if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.usingPythChainlinkUntrusted);
                }

                // If Pyth is working, return Pyth current price (no status change)
                result.price = _storePythPrice(pythResponse);
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            }
            return result;
        }

        // --- CASE 2: The system fetched last price from Chainlink ---
        if (status == Status.usingChainlinkPythUntrusted) {
            // If both Chainlink and Pyth are live, unbroken, and reporting similar prices, switch back to Pyth
            if (
                _bothOraclesLiveAndUnbrokenAndSimilarPrice(
                    chainlinkResponse,
                    prevChainlinkResponse,
                    pythResponse
                )
            ) {
                _changeStatus(Status.pythWorking);
                result.price = _storePythPrice(pythResponse);
                result.oracleKey = bytes32("PYTH");
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            } else if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                _changeStatus(Status.bothOraclesUntrusted);
                result.price = lastGoodPrice;
            }
            /*
             * If Chainlink is only frozen but otherwise returning valid data, just return the last good price.
             */
            else if (_chainlinkIsFrozen(chainlinkResponse)) {
                result.price = lastGoodPrice;
            }
            // Otherwise, use Chainlink price
            else {
                // If Chainlink is live but deviated >50% from it's previous price and Pyth is still untrusted, switch
                // to bothOraclesUntrusted and return last good price
                if (_chainlinkPriceChangeAboveMax(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.bothOraclesUntrusted);
                    result.price = lastGoodPrice;
                } else {
                    result.price = _storeChainlinkPrice(chainlinkResponse);
                    result.oracleKey = bytes32("LINK");
                }
            }
            return result;
        }

        // --- CASE 3: Both oracles were untrusted at the last price fetch ---
        if (status == Status.bothOraclesUntrusted) {
            /*
             * If both oracles are now live, unbroken and similar price, we assume that they are reporting
             * accurately, and so we switch back to Pyth.
             */
            if (
                _bothOraclesLiveAndUnbrokenAndSimilarPrice(
                    chainlinkResponse,
                    prevChainlinkResponse,
                    pythResponse
                )
            ) {
                _changeStatus(Status.pythWorking);
                result.oracleKey = bytes32("PYTH");
                result.price = _storePythPrice(pythResponse);
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            } else {
                // Otherwise, return the last good price - both oracles are still untrusted (no status change)
                result.price = lastGoodPrice;
            }
            return result;
        }

        // --- CASE 4: Using Chainlink, and Pyth is frozen ---
        if (status == Status.usingChainlinkPythFrozen) {
            if (_pythIsBroken(pythResponse)) {
                // If both Oracles are broken, return last good price
                if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.bothOraclesUntrusted);
                    result.price = lastGoodPrice;
                } else {
                    // If Pyth is broken, remember it and switch to using Chainlink
                    _changeStatus(Status.usingChainlinkPythUntrusted);
                    result.oracleKey = bytes32("LINK");

                    if (_chainlinkIsFrozen(chainlinkResponse)) {
                        result.price = lastGoodPrice;
                    } else {
                        // If Chainlink is live but deviated >50% from it's previous price and Pyth is still untrusted, switch
                        // to bothOraclesUntrusted and return last good price
                        if (
                            _chainlinkPriceChangeAboveMax(chainlinkResponse, prevChainlinkResponse)
                        ) {
                            _changeStatus(Status.bothOraclesUntrusted);
                            result.price = lastGoodPrice;
                        } else {
                            result.price = _storeChainlinkPrice(chainlinkResponse);
                        }
                    }
                }
            } else if (_pythIsFrozen(pythResponse)) {
                // if Pyth is frozen and Chainlink is broken, remember Chainlink broke, and return last good price
                if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.usingPythChainlinkUntrusted);
                    result.oracleKey = bytes32("PYTH");
                    result.price = lastGoodPrice;
                }
                // If both are frozen, just use lastGoodPrice
                else if (_chainlinkIsFrozen(chainlinkResponse)) {
                    result.price = lastGoodPrice;
                } else {
                    // If Chainlink is live but deviated >50% from it's previous price and Pyth is still untrusted, switch
                    // to bothOraclesUntrusted and return last good price
                    if (_chainlinkPriceChangeAboveMax(chainlinkResponse, prevChainlinkResponse)) {
                        _changeStatus(Status.bothOraclesUntrusted);
                        result.price = lastGoodPrice;
                    } else {
                        // if Pyth is frozen and Chainlink is working, keep using Chainlink (no status change)
                        result.price = _storeChainlinkPrice(chainlinkResponse);
                        result.oracleKey = bytes32("LINK");
                    }
                }
            }
            // if Pyth is live and Chainlink is broken, remember Chainlink broke, and return Pyth price
            else if (_chainlinkIsBroken(chainlinkResponse, prevChainlinkResponse)) {
                _changeStatus(Status.usingPythChainlinkUntrusted);
                result.oracleKey = bytes32("PYTH");
                result.price = _storePythPrice(pythResponse);
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            }
            // If Pyth is live and Chainlink is frozen, just use last good price (no status change) since we have no basis for comparison
            else if (_chainlinkIsFrozen(chainlinkResponse)) {
                result.price = lastGoodPrice;
            }
            // If Pyth is live and Chainlink is working, compare prices. Switch to Pyth
            // if prices are within 5%, and return Pyth price.
            else if (_bothOraclesSimilarPrice(chainlinkResponse, pythResponse)) {
                _changeStatus(Status.pythWorking);
                result.oracleKey = bytes32("PYTH");
                result.price = _storePythPrice(pythResponse);
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            } else {
                // Otherwise if Pyth is live but price not within 5% of Chainlink, distrust Pyth, and return Chainlink price

                // If Chainlink is live but deviated >50% from it's previous price and Pyth is still untrusted, switch
                // to bothOraclesUntrusted and return last good price
                if (_chainlinkPriceChangeAboveMax(chainlinkResponse, prevChainlinkResponse)) {
                    _changeStatus(Status.bothOraclesUntrusted);
                    result.price = lastGoodPrice;
                } else {
                    // if Pyth is frozen and Chainlink is working, keep using Chainlink (no status change)
                    result.price = _storeChainlinkPrice(chainlinkResponse);
                    _changeStatus(Status.usingChainlinkPythUntrusted);
                    result.oracleKey = bytes32("LINK");
                }
            }
            return result;
        }

        // --- CASE 5: Using Pyth, Chainlink is untrusted ---
        if (status == Status.usingPythChainlinkUntrusted) {
            // If Pyth breaks, now both oracles are untrusted
            if (_pythIsBroken(pythResponse)) {
                _changeStatus(Status.bothOraclesUntrusted);
                result.price = lastGoodPrice;
            }
            // If Pyth is frozen, return last good price (no status change)
            else if (_pythIsFrozen(pythResponse)) {
                result.price = lastGoodPrice;
            }
            // If Pyth and Chainlink are both live, unbroken and similar price, switch back to Pyth and return Pyth price
            else if (
                _bothOraclesLiveAndUnbrokenAndSimilarPrice(
                    chainlinkResponse,
                    prevChainlinkResponse,
                    pythResponse
                )
            ) {
                _changeStatus(Status.pythWorking);
                result.price = _storePythPrice(pythResponse);
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            } else {
                // return Pyth price (no status change)
                result.price = _storePythPrice(pythResponse);
                result.deviationPyth = pythResponse.deviationPyth;
                result.publishTimePyth = pythResponse.publishTimePyth;
            }
            return result;
        }
    }

    // --- Helper functions ---

    // Chainlink is considered broken if its current or previous round data is in any way bad
    function _chainlinkIsBroken(
        ChainlinkResponse memory _currentResponse,
        ChainlinkResponse memory _prevResponse
    ) internal view returns (bool) {
        return _badChainlinkResponse(_currentResponse) || _badChainlinkResponse(_prevResponse);
    }

    function _badChainlinkResponse(ChainlinkResponse memory _response) internal view returns (bool) {
        // Check for response call reverted
        if (!_response.success) {
            return true;
        }
        // Check for an invalid roundId that is 0
        if (_response.roundId == 0) {
            return true;
        }
        // Check for an invalid timeStamp that is 0, or in the future
        if (_response.timestamp == 0 || _response.timestamp > block.timestamp) {
            return true;
        }
        // Check for non-positive price
        if (_response.answer <= 0) {
            return true;
        }

        return false;
    }

    function _chainlinkIsFrozen(ChainlinkResponse memory _response) internal view returns (bool) {
        return block.timestamp.sub(_response.timestamp) > TIMEOUT;
    }

    function _chainlinkPriceChangeAboveMax(
        ChainlinkResponse memory _currentResponse,
        ChainlinkResponse memory _prevResponse
    ) internal pure returns (bool) {
        uint currentScaledPrice = _scaleChainlinkPriceByDigits(
            uint256(_currentResponse.answer),
            _currentResponse.decimals
        );
        uint prevScaledPrice = _scaleChainlinkPriceByDigits(
            uint256(_prevResponse.answer),
            _prevResponse.decimals
        );

        uint minPrice = LiquityMath._min(currentScaledPrice, prevScaledPrice);
        uint maxPrice = LiquityMath._max(currentScaledPrice, prevScaledPrice);

        /*
         * Use the larger price as the denominator:
         * - If price decreased, the percentage deviation is in relation to the the previous price.
         * - If price increased, the percentage deviation is in relation to the current price.
         */
        uint percentDeviation = maxPrice.sub(minPrice).mul(DECIMAL_PRECISION).div(maxPrice);

        // Return true if price has more than doubled, or more than halved.
        return percentDeviation > MAX_PRICE_DEVIATION_FROM_PREVIOUS_ROUND;
    }

    function _pythIsBroken(PythResponse memory _response) internal view returns (bool) {
        // Check for response call reverted
        if (!_response.success) {
            return true;
        }

        // Check for an invalid publishTimePyth that is 0
        if (_response.publishTimePyth == 0) {
            return true;
        }

        // If the publishTimePyth - block.timestamp > 5, use Chainlink.
        if (_response.publishTimePyth > block.timestamp) {
            if (_response.publishTimePyth.sub(block.timestamp) > 5) {
                return true;
            }
        }

        // Check for zero price
        if (_response.pricePyth <= 0) {
            return true;
        }

        // If deviationPyth > 0.25%, use Chainlink
        if (_response.deviationPyth > MAX_SCALED_DEVIATION_PYTH) {
            return true;
        }

        return false;
    }

    function _pythResponseFailed(PythResponse memory _response) internal pure returns (bool) {
        // Check for response call reverted
        if (!_response.success) {
            return true;
        }

        // Check for an invalid publishTimePyth that is 0
        if (_response.publishTimePyth == 0) {
            return true;
        }

        // Check for zero price
        if (_response.pricePyth <= 0) {
            return true;
        }

        return false;
    }

    function _pythIsFrozen(PythResponse memory _pythResponse) internal view returns (bool) {
        // If the block.timestamp - publishTimePyth > 30, use Chainlink.
        if (block.timestamp > _pythResponse.publishTimePyth) {
            return block.timestamp.sub(_pythResponse.publishTimePyth) > 30;
        }
        return false;
    }

    function _bothOraclesLiveAndUnbrokenAndSimilarPrice(
        ChainlinkResponse memory _chainlinkResponse,
        ChainlinkResponse memory _prevChainlinkResponse,
        PythResponse memory _pythResponse
    ) internal view returns (bool) {
        // Return false if either oracle is broken or frozen
        if (
            _pythIsBroken(_pythResponse) ||
            _pythIsFrozen(_pythResponse) ||
            _chainlinkIsBroken(_chainlinkResponse, _prevChainlinkResponse) ||
            _chainlinkIsFrozen(_chainlinkResponse)
        ) {
            return false;
        }

        return _bothOraclesSimilarPrice(_chainlinkResponse, _pythResponse);
    }

    function _bothOraclesSimilarPrice(
        ChainlinkResponse memory _chainlinkResponse,
        PythResponse memory _pythResponse
    ) internal pure returns (bool) {
        uint scaledChainlinkPrice = _scaleChainlinkPriceByDigits(
            uint256(_chainlinkResponse.answer),
            _chainlinkResponse.decimals
        );
        uint scaledPythPrice = _pythResponse.pricePyth;

        // Get the relative price difference between the oracles. Use the lower price as the denominator, i.e. the reference for the calculation.
        uint minPrice = LiquityMath._min(scaledPythPrice, scaledChainlinkPrice);
        uint maxPrice = LiquityMath._max(scaledPythPrice, scaledChainlinkPrice);
        uint percentPriceDifference = maxPrice.sub(minPrice).mul(DECIMAL_PRECISION).div(minPrice);

        /*
         * Return true if the relative price difference is <= 5%: if so, we assume both oracles are probably reporting
         * the honest market price, as it is unlikely that both have been broken/hacked and are still in-sync.
         */
        return percentPriceDifference <= MAX_PRICE_DIFFERENCE_BETWEEN_ORACLES;
    }

    function _scaleChainlinkPriceByDigits(
        uint _price,
        uint _answerDigits
    ) internal pure returns (uint) {
        /*
         * Convert the price returned by the Chainlink oracle to an 18-digit decimal for use by Sable.
         * At date of Sable launch, Chainlink uses an 8-digit price, but we also handle the possibility of
         * future changes.
         *
         */
        uint price;
        if (_answerDigits >= TARGET_DIGITS) {
            // Scale the returned price value down to Sable's target precision
            price = _price.div(10 ** (_answerDigits - TARGET_DIGITS));
        } else if (_answerDigits < TARGET_DIGITS) {
            // Scale the returned price value up to Sable's target precision
            price = _price.mul(10 ** (TARGET_DIGITS - _answerDigits));
        }
        return price;
    }

    function _scalePythPrice(
        PythStructs.Price memory price,
        uint8 targetDecimals
    ) internal pure returns (uint256) {
        if (price.price < 0 || price.expo > 0 || price.expo < -255) {
            // revert();
            return 0;
        }

        uint8 priceDecimals = uint8(uint32(-1 * price.expo));

        if (targetDecimals - priceDecimals >= 0) {
            return uint(price.price).mul(uint(10) ** uint(targetDecimals).sub(priceDecimals));
        } else {
            return uint(price.price).div(uint(10) ** uint(priceDecimals).sub(targetDecimals));
        }
    }

    function _changeStatus(Status _status) internal {
        status = _status;
        emit PriceFeedStatusChanged(_status);
    }

    function _storePrice(uint _currentPrice) internal {
        lastGoodPrice = _currentPrice;
        emit LastGoodPriceUpdated(_currentPrice);
    }

    function _storePythPrice(PythResponse memory _pythResponse) internal returns (uint) {
        _storePrice(_pythResponse.pricePyth);

        return _pythResponse.pricePyth;
    }

    function _storeChainlinkPrice(
        ChainlinkResponse memory _chainlinkResponse
    ) internal returns (uint) {
        uint scaledChainlinkPrice = _scaleChainlinkPriceByDigits(
            uint256(_chainlinkResponse.answer),
            _chainlinkResponse.decimals
        );
        _storePrice(scaledChainlinkPrice);

        return scaledChainlinkPrice;
    }

    // --- Oracle response wrapper functions ---

    function _getCurrentPythResponse(
        bytes[] calldata priceFeedUpdateData
    ) internal returns (PythResponse memory pythResponse) {
        uint updateFee = pyth.getUpdateFee(priceFeedUpdateData);
        pyth.updatePriceFeeds{value: updateFee}(priceFeedUpdateData);

        try pyth.getPriceNoOlderThan(BNBFeed, age) returns (PythStructs.Price memory bnbPrice) {
            pythResponse.pricePyth = _scalePythPrice(bnbPrice, 18);
            uint256 scaledConfidenceInterval = uint(bnbPrice.conf).mul(DECIMAL_PRECISION);
            if (pythResponse.pricePyth != 0) {
                pythResponse.deviationPyth = scaledConfidenceInterval.div(uint(bnbPrice.price)).div(100);
            }
            pythResponse.publishTimePyth = bnbPrice.publishTime;
            if (pythResponse.pricePyth != 0 && pythResponse.publishTimePyth != 0) {
                pythResponse.success = true;
            }
        } catch {
            return pythResponse;
        }
    }

    function _getCurrentChainlinkResponse()
        internal
        view
        returns (ChainlinkResponse memory chainlinkResponse)
    {
        // First, try to get current decimal precision:
        try priceAggregator.decimals() returns (uint8 decimals) {
            // If call to Chainlink succeeds, record the current decimal precision
            chainlinkResponse.decimals = decimals;
        } catch {
            // If call to Chainlink aggregator reverts, return a zero response with success = false
            return chainlinkResponse;
        }

        // Secondly, try to get latest price data:
        try priceAggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 /* startedAt */,
            uint256 timestamp,
            uint80 /* answeredInRound */
        ) {
            // If call to Chainlink succeeds, return the response and success = true
            chainlinkResponse.roundId = roundId;
            chainlinkResponse.answer = answer;
            chainlinkResponse.timestamp = timestamp;
            chainlinkResponse.success = true;
            return chainlinkResponse;
        } catch {
            // If call to Chainlink aggregator reverts, return a zero response with success = false
            return chainlinkResponse;
        }
    }

    function _getPrevChainlinkResponse(
        uint80 _currentRoundId,
        uint8 _currentDecimals
    ) internal view returns (ChainlinkResponse memory prevChainlinkResponse) {
        /*
         * NOTE: Chainlink only offers a current decimals() value - there is no way to obtain the decimal precision used in a
         * previous round.  We assume the decimals used in the previous round are the same as the current round.
         */

        // Try to get the price data from the previous round:
        try priceAggregator.getRoundData(_currentRoundId - 1) returns (
            uint80 roundId,
            int256 answer,
            uint256 /* startedAt */,
            uint256 timestamp,
            uint80 /* answeredInRound */
        ) {
            // If call to Chainlink succeeds, return the response and success = true
            prevChainlinkResponse.roundId = roundId;
            prevChainlinkResponse.answer = answer;
            prevChainlinkResponse.timestamp = timestamp;
            prevChainlinkResponse.decimals = _currentDecimals;
            prevChainlinkResponse.success = true;
            return prevChainlinkResponse;
        } catch {
            // If call to Chainlink aggregator reverts, return a zero response with success = false
            return prevChainlinkResponse;
        }
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../PriceFeed.sol";

contract PriceFeedTester is PriceFeed {

    uint256 private _price = 200 * 1e18;

    IPriceFeed.FetchPriceResult private _fetchPriceResult = IPriceFeed.FetchPriceResult({
        price: _price,
        oracleKey: bytes32("LINK"),
        deviationPyth: 0,
        publishTimePyth: 0
    });

    function setLastGoodPrice(uint _lastGoodPrice) external {
        lastGoodPrice = _lastGoodPrice;
    }

    function setPrice(uint _lastGoodPrice) external {
        lastGoodPrice = _lastGoodPrice;
    }

    function setStatus(Status _status) external {
        status = _status;
    }

    function setAddressesTestnet(
        address _priceAggregatorAddress,
        address _pythAddress,
        address _troveManagerAddress,
        address _borrowerOperationsAddress,
        address _stabilityPoolAddress,
        bytes32 _bnbPriceFeedId
    )
        external
        payable
        onlyOwner
    {
        troveManagerAddress = _troveManagerAddress;
        borrowerOperationsAddress = _borrowerOperationsAddress;
        stabilityPoolAddress = _stabilityPoolAddress;
       
        priceAggregator = AggregatorV3Interface(_priceAggregatorAddress);
        pyth = IPyth(_pythAddress);

        // Explicitly set initial system status
        status = Status.pythWorking;

        _setBNBFeed(_bnbPriceFeedId);

        _storePrice(_price);

        _renounceOwnership();
    }

    function logPythFetchPriceResult(bytes[] calldata priceFeedUpdateData)
        payable 
        public 
    {
        uint updateFee = pyth.getUpdateFee(priceFeedUpdateData);
        pyth.updatePriceFeeds{value: updateFee}(priceFeedUpdateData);

        _fetchPriceResult = this.fetchPrice(priceFeedUpdateData);
    }

    function getInternalFetchPriceResult() public view returns (IPriceFeed.FetchPriceResult memory) {
        return _fetchPriceResult;
    }

}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/LiquityMath.sol";

/* Tester contract for math functions in Math.sol library. */

contract LiquityMathTester {

    function callMax(uint _a, uint _b) external pure returns (uint) {
        return LiquityMath._max(_a, _b);
    }

    // Non-view wrapper for gas test
    function callDecPowTx(uint _base, uint _n) external pure returns (uint) {
        return LiquityMath._decPow(_base, _n);
    }

    // External wrapper
    function callDecPow(uint _base, uint _n) external pure returns (uint) {
        return LiquityMath._decPow(_base, _n);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import '../Interfaces/ITroveManager.sol';
import '../Interfaces/ISortedTroves.sol';
import '../Interfaces/IPriceFeed.sol';
import '../Dependencies/LiquityMath.sol';

/* Wrapper contract - used for calculating gas of read-only and internal functions. 
Not part of the Liquity application. */
contract FunctionCaller {

    ITroveManager troveManager;
    address public troveManagerAddress;

    ISortedTroves sortedTroves;
    address public sortedTrovesAddress;

    IPriceFeed priceFeed;
    address public priceFeedAddress;

    // --- Dependency setters ---

    function setTroveManagerAddress(address _troveManagerAddress) external {
        troveManagerAddress = _troveManagerAddress;
        troveManager = ITroveManager(_troveManagerAddress);
    }
    
    function setSortedTrovesAddress(address _sortedTrovesAddress) external {
        troveManagerAddress = _sortedTrovesAddress;
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
    }

     function setPriceFeedAddress(address _priceFeedAddress) external {
        priceFeedAddress = _priceFeedAddress;
        priceFeed = IPriceFeed(_priceFeedAddress);
    }

    // --- Non-view wrapper functions used for calculating gas ---
    
    function troveManager_getCurrentICR(address _address, uint _price) external returns (uint) {
        return troveManager.getCurrentICR(_address, _price);  
    }

    function sortedTroves_findInsertPosition(uint _NICR, address _prevId, address _nextId) external returns (address, address) {
        return sortedTroves.findInsertPosition(_NICR, _prevId, _nextId);
    }
}
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./PythStructs.sol";
import "./IPyth.sol";

abstract contract AbstractPyth is IPyth {
    /// @notice Returns the price feed with given id.
    /// @dev Reverts if the price does not exist.
    /// @param id The Pyth Price Feed ID of which to fetch the PriceFeed.
    function queryPriceFeed(
        bytes32 id
    ) public view virtual returns (PythStructs.PriceFeed memory priceFeed);

    /// @notice Returns true if a price feed with the given id exists.
    /// @param id The Pyth Price Feed ID of which to check its existence.
    function priceFeedExists(
        bytes32 id
    ) public view virtual returns (bool exists);

    function getValidTimePeriod()
        public
        view
        virtual
        override
        returns (uint validTimePeriod);

    function getPrice(
        bytes32 id
    ) external view virtual override returns (PythStructs.Price memory price) {
        return getPriceNoOlderThan(id, getValidTimePeriod());
    }

    function getEmaPrice(
        bytes32 id
    ) external view virtual override returns (PythStructs.Price memory price) {
        return getEmaPriceNoOlderThan(id, getValidTimePeriod());
    }

    function getPriceUnsafe(
        bytes32 id
    ) public view virtual override returns (PythStructs.Price memory price) {
        PythStructs.PriceFeed memory priceFeed = queryPriceFeed(id);
        return priceFeed.price;
    }

    function getPriceNoOlderThan(
        bytes32 id,
        uint age
    ) public view virtual override returns (PythStructs.Price memory price) {
        price = getPriceUnsafe(id);

        assert(diff(block.timestamp, price.publishTime) <= age);

        return price;
    }

    function getEmaPriceUnsafe(
        bytes32 id
    ) public view virtual override returns (PythStructs.Price memory price) {
        PythStructs.PriceFeed memory priceFeed = queryPriceFeed(id);
        return priceFeed.emaPrice;
    }

    function getEmaPriceNoOlderThan(
        bytes32 id,
        uint age
    ) public view virtual override returns (PythStructs.Price memory price) {
        price = getEmaPriceUnsafe(id);

        assert(diff(block.timestamp, price.publishTime) <= age);

        return price;
    }

    function diff(uint x, uint y) internal pure returns (uint) {
        if (x > y) {
            return x - y;
        } else {
            return y - x;
        }
    }

    // Access modifier is overridden to public to be able to call it locally.
    function updatePriceFeeds(
        bytes[] calldata updateData
    ) public payable virtual override;

    function updatePriceFeedsIfNecessary(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64[] calldata publishTimes
    ) external payable virtual override {
        assert(priceIds.length == publishTimes.length);

        for (uint i = 0; i < priceIds.length; i++) {
            if (
                !priceFeedExists(priceIds[i]) ||
                queryPriceFeed(priceIds[i]).price.publishTime < publishTimes[i]
            ) {
                updatePriceFeeds(updateData);
                return;
            }
        }
    }

    function parsePriceFeedUpdates(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64 minPublishTime,
        uint64 maxPublishTime
    )
        external
        payable
        virtual
        override
        returns (PythStructs.PriceFeed[] memory priceFeeds);
}// SPDX-License-Identifier: MIT
// pragma solidity 0.6.11;
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Interfaces/AbstractPyth.sol";
import "../Interfaces/PythStructs.sol";

contract MockPyth is AbstractPyth {
    mapping(bytes32 => PythStructs.PriceFeed) priceFeeds;
    uint64 sequenceNumber;

    uint singleUpdateFeeInWei;
    uint validTimePeriod;

    PythStructs.PriceFeed private _priceFeed;

    constructor(uint _validTimePeriod, uint _singleUpdateFeeInWei) public {
        singleUpdateFeeInWei = _singleUpdateFeeInWei;
        validTimePeriod = _validTimePeriod;
    }

    function queryPriceFeed(
        bytes32 id
    ) public view override returns (PythStructs.PriceFeed memory priceFeed) {
        assert(priceFeeds[id].id != 0);
        return priceFeeds[id];
    }

    function priceFeedExists(bytes32 id) public view override returns (bool) {
        return (priceFeeds[id].id != 0);
    }

    function getValidTimePeriod() public view override returns (uint) {
        return validTimePeriod;
    }

    // Takes an array of encoded price feeds and stores them.
    // You can create this data either by calling createPriceFeedData or
    // by using web3.js or ethers abi utilities.
    function updatePriceFeeds(
        bytes[] calldata updateData
    ) public payable override {
        uint requiredFee = getUpdateFee(updateData);
        assert(msg.value >= requiredFee);
        // Chain ID is id of the source chain that the price update comes from. Since it is just a mock contract
        // We set it to 1.
        uint16 chainId = 1;

        // for (uint i = 0; i < updateData.length; i++) {
        //     PythStructs.PriceFeed memory priceFeed = abi.decode(
        //         updateData[i],
        //         (PythStructs.PriceFeed)
        //     );
        //     uint lastPublishTime = priceFeeds[priceFeed.id].price.publishTime;

        //     //if (lastPublishTime < priceFeed.price.publishTime) {
        //     // Price information is more recent than the existing price information.
        //     priceFeeds[priceFeed.id] = priceFeed;
        //     uint256 convertedNumber = uint256(uint64(priceFeed.price.price));
        //     emit PriceFeedUpdate(
        //         priceFeed.id,
        //         uint64(lastPublishTime),
        //         priceFeed.price.price,
        //         priceFeed.price.conf
        //     );
        //     //}
        // }

        // In the real contract, the input of this function contains multiple batches that each contain multiple prices.
        // This event is emitted when a batch is processed. In this mock contract we consider there is only one batch of prices.
        // Each batch has (chainId, sequenceNumber) as it's unique identifier. Here chainId is set to 1 and an increasing sequence number is used.
        emit BatchPriceFeedUpdate(chainId, sequenceNumber);
        sequenceNumber += 1;
    }

    function getUpdateFee(
        bytes[] calldata updateData
    ) public view override returns (uint feeAmount) {
        feeAmount = singleUpdateFeeInWei * updateData.length;
        return feeAmount;
    }

    function parsePriceFeedUpdates(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable override returns (PythStructs.PriceFeed[] memory) {
        uint requiredFee = getUpdateFee(updateData);
        assert(msg.value >= requiredFee);

        PythStructs.PriceFeed[] memory feeds = new PythStructs.PriceFeed[](priceIds.length);

        for (uint i = 0; i < priceIds.length; i++) {
            for (uint j = 0; j < updateData.length; j++) {
                feeds[i] = abi.decode(updateData[j], (PythStructs.PriceFeed));

                if (feeds[i].id == priceIds[i]) {
                    uint publishTime = feeds[i].price.publishTime;
                    if (
                        minPublishTime <= publishTime &&
                        publishTime <= maxPublishTime
                    ) {
                        break;
                    } else {
                        feeds[i].id = 0;
                    }
                }
            }

            assert(feeds[i].id == priceIds[i]);
        }
        return feeds;
    }

    function createPriceFeedUpdateData(
        bytes32 id,
        int64 price,
        uint64 conf,
        int32 expo,
        int64 emaPrice,
        uint64 emaConf,
        uint64 publishTime
    ) public pure returns (bytes memory priceFeedData) {
        PythStructs.PriceFeed memory priceFeed;

        priceFeed.id = id;

        priceFeed.price.price = price;
        priceFeed.price.conf = conf;
        priceFeed.price.expo = expo;
        priceFeed.price.publishTime = publishTime;

        priceFeed.emaPrice.price = emaPrice;
        priceFeed.emaPrice.conf = emaConf;
        priceFeed.emaPrice.expo = expo;
        priceFeed.emaPrice.publishTime = publishTime;

        priceFeedData = abi.encode(priceFeed);

        return priceFeedData;
    }

    function setNewFeedId(bytes32 id) public {
        PythStructs.PriceFeed memory priceFeed;
        priceFeed.id = id;
        priceFeeds[id] = priceFeed;
    }

    function mockPrices(
        bytes32 id,
        int64 price,
        uint64 conf,
        int32 expo,
        int64 emaPrice,
        uint64 emaConf,
        uint64 publishTime
    ) public {

        priceFeeds[id].price.price = price;
        priceFeeds[id].price.conf = conf;
        priceFeeds[id].price.expo = expo;
        priceFeeds[id].price.publishTime = publishTime;

        priceFeeds[id].emaPrice.price = emaPrice;
        priceFeeds[id].emaPrice.conf = emaConf;
        priceFeeds[id].emaPrice.expo = expo;
        priceFeeds[id].emaPrice.publishTime = publishTime;
    }

}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Dependencies/SafeMath.sol";
import "../Dependencies/LiquityMath.sol";
import "../Dependencies/IERC20.sol";
import "../Interfaces/IBorrowerOperations.sol";
import "../Interfaces/ITroveManager.sol";
import "../Interfaces/IStabilityPool.sol";
import "../Interfaces/IPriceFeed.sol";
import "../Interfaces/ISableStakingV2.sol";
import "../Interfaces/IOracleRateCalculation.sol";
import "./BorrowerOperationsScript.sol";
import "./BNBTransferScript.sol";
import "./SableStakingV2Script.sol";
import "../Dependencies/console.sol";

// TODO: Fix staking and commented lines

contract BorrowerWrappersScript is BorrowerOperationsScript, BNBTransferScript, SableStakingV2Script {
    using SafeMath for uint;

    string constant public NAME = "BorrowerWrappersScript";

    ITroveManager immutable troveManager;
    IStabilityPool immutable stabilityPool;
    IPriceFeed immutable priceFeed;
    IERC20 immutable usdsToken;
    IERC20 immutable sableToken;
    ISableStakingV2 immutable sableStaking;
    IOracleRateCalculation immutable oracleRateCalc;

    constructor(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _sableStakingAddress
    )
        BorrowerOperationsScript(IBorrowerOperations(_borrowerOperationsAddress))
        SableStakingV2Script(_sableStakingAddress)
        public
    {
        checkContract(_troveManagerAddress);
        ITroveManager troveManagerCached = ITroveManager(_troveManagerAddress);
        troveManager = troveManagerCached;

        IStabilityPool stabilityPoolCached = troveManagerCached.stabilityPool();
        checkContract(address(stabilityPoolCached));
        stabilityPool = stabilityPoolCached;

        IPriceFeed priceFeedCached = troveManagerCached.priceFeed();
        checkContract(address(priceFeedCached));
        priceFeed = priceFeedCached;

        address usdsTokenCached = address(troveManagerCached.usdsToken());
        checkContract(usdsTokenCached);
        usdsToken = IERC20(usdsTokenCached);

        address sableTokenCached = address(troveManagerCached.sableToken());
        checkContract(sableTokenCached);
        sableToken = IERC20(sableTokenCached);

        ISableStakingV2 sableStakingCached = troveManagerCached.sableStaking();
        require(_sableStakingAddress == address(sableStakingCached), "BorrowerWrappersScript: Wrong SableStaking address");
        sableStaking = sableStakingCached;

        IOracleRateCalculation oracleRateCalcCached = troveManagerCached.oracleRateCalc();
        checkContract(address(oracleRateCalcCached));
        oracleRateCalc = oracleRateCalcCached;
    }

    function claimCollateralAndOpenTrove(
        uint _maxFee, 
        uint _USDSAmount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        uint balanceBefore = address(this).balance;

        // Claim collateral
        borrowerOperations.claimCollateral();

        uint balanceAfter = address(this).balance;

        // already checked in CollSurplusPool
        assert(balanceAfter > balanceBefore);

        uint totalCollateral = balanceAfter.sub(balanceBefore).add(msg.value);

        // Open trove with obtained collateral, plus collateral sent by user
        borrowerOperations.openTrove{ value: totalCollateral }(_maxFee, _USDSAmount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function claimSPRewardsAndRecycle(
        uint _maxFee, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        console.log("start claimspand recycle");
        uint collBalanceBefore = address(this).balance;
        uint sableBalanceBefore = sableToken.balanceOf(address(this));

        // Claim rewards
        stabilityPool.withdrawFromSP(0, priceFeedUpdateData);

        uint collBalanceAfter = address(this).balance;
        console.log("pre bal");
        uint sableBalanceAfter = sableToken.balanceOf(address(this));
        uint claimedCollateral = collBalanceAfter.sub(collBalanceBefore);
        console.log("withdraw from sp ok");

        // Add claimed BNB to trove, get more USDS and stake it into the Stability Pool
        if (claimedCollateral > 0) {
            _requireUserHasTrove(address(this));
            console.log("require ok");
            uint USDSAmount = _getNetUSDSAmount(claimedCollateral, priceFeedUpdateData);
            console.log("before predict error");
            IBorrowerOperations.AdjustTroveParam memory adjustParam = IBorrowerOperations.AdjustTroveParam({
                collWithdrawal: 0,
                USDSChange: USDSAmount,
                isDebtIncrease: true,
                upperHint: _upperHint,
                lowerHint: _lowerHint,
                maxFeePercentage: _maxFee
            });
            console.log("adjust trove param ok");
            borrowerOperations.adjustTrove{ value: claimedCollateral }(
                adjustParam,
                priceFeedUpdateData
            );
            console.log("adjuts trove ok");
            // Provide withdrawn USDS to Stability Pool
            if (USDSAmount > 0) {
                stabilityPool.provideToSP(USDSAmount, address(0));
            }
        }
        console.log("before sableBalance");
        // Stake claimed SABLE
        uint claimedSABLE = sableBalanceAfter.sub(sableBalanceBefore);
        // if (claimedSABLE > 0) {
        //     sableStaking.stake(claimedSABLE);
        // }
    }

    function claimStakingGainsAndRecycle(
        uint _maxFee, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        uint collBalanceBefore = address(this).balance;
        uint usdsBalanceBefore = usdsToken.balanceOf(address(this));
        uint sableBalanceBefore = sableToken.balanceOf(address(this));

        // Claim gains
        sableStaking.unstake(0);

        uint gainedCollateral = address(this).balance.sub(collBalanceBefore); // stack too deep issues :'(
        uint gainedUSDS = usdsToken.balanceOf(address(this)).sub(usdsBalanceBefore);

        uint netUSDSAmount;
        // Top up trove and get more USDS, keeping ICR constant
        if (gainedCollateral > 0) {
            _requireUserHasTrove(address(this));
            netUSDSAmount = _getNetUSDSAmount(gainedCollateral, priceFeedUpdateData);
            IBorrowerOperations.AdjustTroveParam memory adjustParam = IBorrowerOperations.AdjustTroveParam({
                maxFeePercentage: _maxFee,
                upperHint: _upperHint,
                lowerHint: _lowerHint,
                USDSChange: netUSDSAmount,
                isDebtIncrease: true,
                collWithdrawal: 0
            });
            borrowerOperations.adjustTrove{ value: gainedCollateral }(
                adjustParam,
                priceFeedUpdateData
            );
        }

        uint totalUSDS = gainedUSDS.add(netUSDSAmount);
        if (totalUSDS > 0) {
            stabilityPool.provideToSP(totalUSDS, address(0));

            // Providing to Stability Pool also triggers SABLE claim, so stake it if any
            uint sableBalanceAfter = sableToken.balanceOf(address(this));
            uint claimedSABLE = sableBalanceAfter.sub(sableBalanceBefore);
            // if (claimedSABLE > 0) {
            //     sableStaking.stake(claimedSABLE);
            // }
        }

    }

    function _getNetUSDSAmount(
        uint _collateral,
        bytes[] calldata priceFeedUpdateData
    ) internal returns (uint) {
        // console.log("begin get net usds amt");
        IPriceFeed.FetchPriceResult memory fetchPriceResult = priceFeed.fetchPrice(priceFeedUpdateData);
        // console.log("fetch price ok");

        // calculate oracleRate
        uint oracleRate = oracleRateCalc.getOracleRate(
            fetchPriceResult.oracleKey, 
            fetchPriceResult.deviationPyth, 
            fetchPriceResult.publishTimePyth
        );
        // console.log("calc oraclerate ok");


        uint ICR = troveManager.getCurrentICR(address(this), fetchPriceResult.price);
        // console.log("getcurr icr ok");

        uint USDSAmount = _collateral.mul(fetchPriceResult.price).div(ICR);
        console.log("usdsamt calc ok");
        uint borrowingRate = troveManager.getBorrowingRateWithDecay(oracleRate);
        console.log("get b r decay ok");
        uint netDebt = USDSAmount.mul(LiquityMath.DECIMAL_PRECISION).div(LiquityMath.DECIMAL_PRECISION.add(borrowingRate));
        console.log("net debt calc ok");

        return netDebt;
    }

    function _requireUserHasTrove(address _depositor) internal view {
        require(troveManager.getTroveStatus(_depositor) == 1, "BorrowerWrappersScript: caller must have an active trove");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Dependencies/CheckContract.sol";
import "../Interfaces/IBorrowerOperations.sol";


contract BorrowerOperationsScript is CheckContract {
    IBorrowerOperations immutable borrowerOperations;

    constructor(IBorrowerOperations _borrowerOperations) public {
        checkContract(address(_borrowerOperations));
        borrowerOperations = _borrowerOperations;
    }

    function openTrove(
        uint _maxFee, 
        uint _USDSAmount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        borrowerOperations.openTrove{ value: msg.value }(_maxFee, _USDSAmount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function addColl(
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        borrowerOperations.addColl{ value: msg.value }(_upperHint, _lowerHint, priceFeedUpdateData);
    }

    function withdrawColl(
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        borrowerOperations.withdrawColl(_amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function withdrawUSDS(
        uint _maxFee, 
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        borrowerOperations.withdrawUSDS(_maxFee, _amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function repayUSDS(
        uint _amount, 
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        borrowerOperations.repayUSDS(_amount, _upperHint, _lowerHint, priceFeedUpdateData);
    }

    function closeTrove(bytes[] calldata priceFeedUpdateData) external {
        borrowerOperations.closeTrove(priceFeedUpdateData);
    }

    function adjustTrove(
        IBorrowerOperations.AdjustTroveParam memory adjustParam,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        borrowerOperations.adjustTrove{ value: msg.value }(
            adjustParam, 
            priceFeedUpdateData
        );
    }

    function claimCollateral() external {
        borrowerOperations.claimCollateral();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;


contract BNBTransferScript {
    function transferBNB(address _recipient, uint256 _amount) external returns (bool) {
        (bool success, ) = _recipient.call{value: _amount}("");
        return success;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/CheckContract.sol";
import "../Interfaces/ISableStakingV2.sol";


contract SableStakingV2Script is CheckContract {
    ISableStakingV2 immutable SableStakingV2;

    constructor(address _sableStakingAddress) public {
        checkContract(_sableStakingAddress);
        SableStakingV2 = ISableStakingV2(_sableStakingAddress);
    }

    function stake(uint _SABLEamount) external {
        SableStakingV2.stake(_SABLEamount);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/BaseMath.sol";
import "../Dependencies/SafeMath.sol";
import "../Dependencies/Ownable.sol";
import "../Dependencies/CheckContract.sol";
import "../Dependencies/console.sol";
import "../Interfaces/ISABLEToken.sol";
import "../Interfaces/ISableStakingV2.sol";
import "../Interfaces/ISableRewarder.sol";
import "../Dependencies/LiquityMath.sol";
import "../Interfaces/IUSDSToken.sol";
import "../Interfaces/ISableLPToken.sol";

contract SableStakingV2 is ISableStakingV2, Ownable, CheckContract, BaseMath {
    using SafeMath for uint;

    // --- Data ---
    string constant public NAME = "SableStaking";

    mapping(address => uint) public stakes;
    uint public totalSableLPStaked;

    uint public F_BNB;  // Running sum of BNB fees per-SABLE-staked
    uint public F_USDS; // Running sum of USDS fees per-SABLE-staked
    uint public F_SABLE; // Running sum of SABLE gains per-SABLE-staked

    // User snapshots of F_BNB, F_USDS and F_SABLE, taken at the point at which their latest deposit was made
    mapping (address => Snapshot) public snapshots; 

    struct Snapshot {
        uint F_BNB_Snapshot;
        uint F_USDS_Snapshot;
        uint F_SABLE_Snapshot;
    }
    
    ISABLEToken public sableToken;
    IUSDSToken public usdsToken;
    ISableLPToken public sableLPToken;
    ISableRewarder public sableRewarder;

    address public troveManagerAddress;
    address public borrowerOperationsAddress;
    address public sableRewarderAddress;
    address public activePoolAddress;

    bool public initialized;

    // --- Events ---

    event SABLETokenAddressSet(address _sableTokenAddress);
    event USDSTokenAddressSet(address _usdsTokenAddress);
    event TroveManagerAddressSet(address _troveManager);
    event BorrowerOperationsAddressSet(address _borrowerOperationsAddress);
    event SableRewarderAddressSet(address _sableRewarderAddress);
    event ActivePoolAddressSet(address _activePoolAddress);

    event StakeChanged(address indexed staker, uint newStake);
    event StakingGainsWithdrawn(address indexed staker, uint USDSGain, uint BNBGain, uint SABLEGain);
    event F_BNBUpdated(uint _F_BNB);
    event F_USDSUpdated(uint _F_USDS);
    event F_SABLEUpdated(uint _F_SABLE);
    event TotalSableLPStakedUpdated(uint _totalSableLPStaked);
    event EtherSent(address _account, uint _amount);
    event StakerSnapshotsUpdated(address _staker, uint _F_BNB, uint _F_USDS, uint _F_SABLE);

    event SableLPTokenAddressSet(address _sableLPTokenAddress);

    // --- Functions ---

    function setAddresses
    (
        address _sableTokenAddress,
        address _usdsTokenAddress,
        address _troveManagerAddress, 
        address _borrowerOperationsAddress,
        address _sableRewarderAddress,
        address _activePoolAddress
    ) 
        external 
        onlyOwner 
        override 
    {
        checkContract(_sableTokenAddress);
        checkContract(_usdsTokenAddress);
        checkContract(_troveManagerAddress);
        checkContract(_borrowerOperationsAddress);
        checkContract(_sableRewarderAddress);
        checkContract(_activePoolAddress);

        sableToken = ISABLEToken(_sableTokenAddress);
        usdsToken = IUSDSToken(_usdsTokenAddress);
        sableRewarder = ISableRewarder(_sableRewarderAddress);
        troveManagerAddress = _troveManagerAddress;
        borrowerOperationsAddress = _borrowerOperationsAddress;
        sableRewarderAddress = _sableRewarderAddress;
        activePoolAddress = _activePoolAddress;

        emit SABLETokenAddressSet(_sableTokenAddress);
        emit USDSTokenAddressSet(_usdsTokenAddress);
        emit TroveManagerAddressSet(_troveManagerAddress);
        emit BorrowerOperationsAddressSet(_borrowerOperationsAddress);
        emit SableRewarderAddressSet(_sableRewarderAddress);
        emit ActivePoolAddressSet(_activePoolAddress);
    }

    function setSableLPAddress(address _sableLPTokenAddress) external onlyOwner override {
        checkContract(_sableLPTokenAddress);
        sableLPToken = ISableLPToken(_sableLPTokenAddress);
        
        emit SableLPTokenAddressSet(_sableLPTokenAddress);

        initialized = true;
    }

    function renounceOwnership() external onlyOwner {
        _renounceOwnership();
    }

    // If caller has a pre-existing stake, send any accumulated BNB, USDS and SABLE to them. 
    function stake(uint _sableLPAmount) external override {
        _requireInitialized();
        _requireNonZeroAmount(_sableLPAmount);

        sableRewarder.issueSABLE();

        uint currentStake = stakes[msg.sender];

        uint BNBGain;
        uint USDSGain;
        uint SABLEGain;
        // Grab any accumulated BNB, USDS and SABLE from the current stake
        if (currentStake != 0) {
            BNBGain = _getPendingBNBGain(msg.sender);
            USDSGain = _getPendingUSDSGain(msg.sender);
            SABLEGain = _getPendingSABLEGain(msg.sender);
        }
    
        _updateUserSnapshots(msg.sender);

        uint newStake = currentStake.add(_sableLPAmount);

        // Increase user’s stake and total SABLE staked
        stakes[msg.sender] = newStake;
        totalSableLPStaked = totalSableLPStaked.add(_sableLPAmount);
        emit TotalSableLPStakedUpdated(totalSableLPStaked);

        // Transfer SABLE from caller to this contract
        sableLPToken.transferFrom(msg.sender, address(this), _sableLPAmount);

        emit StakeChanged(msg.sender, newStake);
        emit StakingGainsWithdrawn(msg.sender, USDSGain, BNBGain, SABLEGain);

         // Send accumulated BNB, USDS and SABLE to the caller
        if (currentStake != 0) {
            usdsToken.transfer(msg.sender, USDSGain);
            sableToken.transfer(msg.sender, SABLEGain);
            _sendBNBGainToUser(BNBGain);
        }
    }

    // Unstake the SABLE and send the it back to the caller, along with their accumulated BNB, USDS & SABLE. 
    // If requested amount > stake, send their entire stake.
    function unstake(uint _sableLPAmount) external override {
        _requireInitialized();
        
        sableRewarder.issueSABLE();
        
        uint currentStake = stakes[msg.sender];
        _requireUserHasStake(currentStake);

        // Grab any accumulated BNB, USDS and SABLE from the current stake
        uint BNBGain = _getPendingBNBGain(msg.sender);
        uint USDSGain = _getPendingUSDSGain(msg.sender);
        uint SABLEGain  = _getPendingSABLEGain(msg.sender);
        
        _updateUserSnapshots(msg.sender);

        if (_sableLPAmount > 0) {
            uint SableLPToWithdraw = LiquityMath._min(_sableLPAmount, currentStake);

            uint newStake = currentStake.sub(SableLPToWithdraw);

            // Decrease user's stake and total SABLE staked
            stakes[msg.sender] = newStake;
            totalSableLPStaked = totalSableLPStaked.sub(SableLPToWithdraw);
            emit TotalSableLPStakedUpdated(totalSableLPStaked);

            // Transfer unstaked SABLE to user
            sableLPToken.transfer(msg.sender, SableLPToWithdraw);

            emit StakeChanged(msg.sender, newStake);
        }

        emit StakingGainsWithdrawn(msg.sender, USDSGain, BNBGain, SABLEGain);

        // Send accumulated USDS, BNB and SABLE gains to the caller
        usdsToken.transfer(msg.sender, USDSGain);
        sableToken.transfer(msg.sender, SABLEGain);
        _sendBNBGainToUser(BNBGain);
    }

    // --- Reward-per-unit-staked increase functions. Called by Sable core contracts ---

    function increaseF_BNB(uint _BNBFee) external override {
        _requireCallerIsTroveManager();
        uint BNBFeePerSABLEStaked;
     
        if (totalSableLPStaked > 0) {BNBFeePerSABLEStaked = _BNBFee.mul(DECIMAL_PRECISION).div(totalSableLPStaked);}

        F_BNB = F_BNB.add(BNBFeePerSABLEStaked); 
        emit F_BNBUpdated(F_BNB);
    }

    function increaseF_USDS(uint _USDSFee) external override {
        _requireCallerIsBorrowerOperations();
        uint USDSFeePerSABLEStaked;
        
        if (totalSableLPStaked > 0) {USDSFeePerSABLEStaked = _USDSFee.mul(DECIMAL_PRECISION).div(totalSableLPStaked);}
        
        F_USDS = F_USDS.add(USDSFeePerSABLEStaked);
        emit F_USDSUpdated(F_USDS);
    }

    function increaseF_SABLE(uint _SABLEGain) external override {
        _requireCallerIsSableRewarder();
        uint SABLEGainPerSABLEStaked;
        
        if (totalSableLPStaked > 0) {SABLEGainPerSABLEStaked = _SABLEGain.mul(DECIMAL_PRECISION).div(totalSableLPStaked);}
        
        F_SABLE = F_SABLE.add(SABLEGainPerSABLEStaked);
        emit F_SABLEUpdated(F_SABLE);
    }

    // --- Pending reward functions ---

    function getPendingBNBGain(address _user) external view override returns (uint) {
        return _getPendingBNBGain(_user);
    }

    function _getPendingBNBGain(address _user) internal view returns (uint) {
        uint F_BNB_Snapshot = snapshots[_user].F_BNB_Snapshot;
        uint BNBGain = stakes[_user].mul(F_BNB.sub(F_BNB_Snapshot)).div(DECIMAL_PRECISION);
        return BNBGain;
    }

    function getPendingUSDSGain(address _user) external view override returns (uint) {
        return _getPendingUSDSGain(_user);
    }

    function _getPendingUSDSGain(address _user) internal view returns (uint) {
        uint F_USDS_Snapshot = snapshots[_user].F_USDS_Snapshot;
        uint USDSGain = stakes[_user].mul(F_USDS.sub(F_USDS_Snapshot)).div(DECIMAL_PRECISION);
        return USDSGain;
    }

    function getPendingSABLEGain(address _user) external view override returns (uint) {
        return _getPendingSABLEGain(_user);
    }

    function _getPendingSABLEGain(address _user) internal view returns (uint) {
        uint F_SABLE_Snapshot = snapshots[_user].F_SABLE_Snapshot;
        uint SABLEGain = stakes[_user].mul(F_SABLE.sub(F_SABLE_Snapshot)).div(DECIMAL_PRECISION);
        return SABLEGain;
    }

    // --- Internal helper functions ---

    function _updateUserSnapshots(address _user) internal {
        snapshots[_user].F_BNB_Snapshot = F_BNB;
        snapshots[_user].F_USDS_Snapshot = F_USDS;
        snapshots[_user].F_SABLE_Snapshot = F_SABLE;
        emit StakerSnapshotsUpdated(_user, F_BNB, F_USDS, F_SABLE);
    }

    function _sendBNBGainToUser(uint BNBGain) internal {
        emit EtherSent(msg.sender, BNBGain);
        (bool success, ) = msg.sender.call{value: BNBGain}("");
        require(success, "SableStaking: Failed to send accumulated BNBGain");
    }

    // --- 'require' functions ---

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == troveManagerAddress, "SableStaking: caller is not TroveM");
    }

    function _requireCallerIsBorrowerOperations() internal view {
        require(msg.sender == borrowerOperationsAddress, "SableStaking: caller is not BorrowerOps");
    }

    function _requireCallerIsSableRewarder() internal view {
        require(msg.sender == sableRewarderAddress, "SableStaking: caller is not SableRe");
    }

     function _requireCallerIsActivePool() internal view {
        require(msg.sender == activePoolAddress, "SableStaking: caller is not ActivePool");
    }

    function _requireUserHasStake(uint currentStake) internal pure {  
        require(currentStake > 0, "SableStaking: User must have a non-zero stake");  
    }

    function _requireNonZeroAmount(uint _amount) internal pure {
        require(_amount > 0, "SableStaking: Amount must be non-zero");
    }

    function _requireInitialized() internal view {
        require(initialized, "SableStaking: Staking not ready");
    }
    
    receive() external payable {
        _requireCallerIsActivePool();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

interface ISableRewarder { 
    
    // --- Events ---
    
    event SABLETokenAddressSet(address _sableTokenAddress);
    event StabilityPoolAddressSet(address _stabilityPoolAddress);
    event RewardPerSecUpdated(uint256 _newRewardPerSec);

    // --- Functions ---

    function setParams
    (
        address _sableTokenAddress, 
        address _stabilityPoolAddress,
        uint256 _latestRewardPerSec
    ) external;

    function issueSABLE() external;

    function balanceSABLE() external returns (uint);

    function updateRewardPerSec(uint _newRewardPerSec) external;

    function transferOwnership(address _newOwner) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/IERC20.sol";

interface ISableLPToken is IERC20 { 
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../SABLE/SableStakingV2.sol";


contract SABLEStakingTester is SableStakingV2 {
    function requireCallerIsTroveManager() external view {
        _requireCallerIsTroveManager();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../Dependencies/IERC20.sol";
import "../Dependencies/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract MockSableLP is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal constant _name = "MockSableLP";
    string internal constant _symbol = "SLP";
    uint8 internal constant _decimals = 18;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address _vaultAddress, uint256 _mintAmount) public {
        _mint(_vaultAddress, _mintAmount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../StabilityPool.sol";

contract StabilityPoolTester is StabilityPool {
    
    function unprotectedPayable() external payable {
        BNB = BNB.add(msg.value);
    }

    function setCurrentScale(uint128 _currentScale) external {
        currentScale = _currentScale;
    }

    function setTotalDeposits(uint _totalUSDSDeposits) external {
        totalUSDSDeposits = _totalUSDSDeposits;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Dependencies/CheckContract.sol";
import "../Interfaces/ITroveManager.sol";


contract TroveManagerScript is CheckContract {
    string constant public NAME = "TroveManagerScript";

    ITroveManager immutable troveManager;

    constructor(ITroveManager _troveManager) public {
        checkContract(address(_troveManager));
        troveManager = _troveManager;
    }

    function redeemCollateral(
        uint _USDSAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee,
        bytes[] calldata priceFeedUpdateData
    ) external returns (uint) {
        troveManager.redeemCollateral(
            _USDSAmount,
            _firstRedemptionHint,
            _upperPartialRedemptionHint,
            _lowerPartialRedemptionHint,
            _partialRedemptionHintNICR,
            _maxIterations,
            _maxFee,
            priceFeedUpdateData
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./Interfaces/ITroveManager.sol";
import "./Interfaces/ISortedTroves.sol";
import "./Dependencies/LiquityBase.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";

contract HintHelpers is LiquityBase, Ownable, CheckContract {
    string public constant NAME = "HintHelpers";

    ISortedTroves public sortedTroves;
    ITroveManager public troveManager;

    // --- Events ---

    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event TroveManagerAddressChanged(address _troveManagerAddress);

    // --- Dependency setters ---

    function setAddresses(
        address _sortedTrovesAddress,
        address _troveManagerAddress,
        address _systemStateAddress
    ) external onlyOwner {
        checkContract(_sortedTrovesAddress);
        checkContract(_troveManagerAddress);

        sortedTroves = ISortedTroves(_sortedTrovesAddress);
        troveManager = ITroveManager(_troveManagerAddress);
        systemState = ISystemState(_systemStateAddress);

        emit SortedTrovesAddressChanged(_sortedTrovesAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);

        _renounceOwnership();
    }

    // --- Functions ---

    /* getRedemptionHints() - Helper function for finding the right hints to pass to redeemCollateral().
     *
     * It simulates a redemption of `_USDSamount` to figure out where the redemption sequence will start and what state the final Trove
     * of the sequence will end up in.
     *
     * Returns three hints:
     *  - `firstRedemptionHint` is the address of the first Trove with ICR >= MCR (i.e. the first Trove that will be redeemed).
     *  - `partialRedemptionHintNICR` is the final nominal ICR of the last Trove of the sequence after being hit by partial redemption,
     *     or zero in case of no partial redemption.
     *  - `truncatedUSDSamount` is the maximum amount that can be redeemed out of the the provided `_USDSamount`. This can be lower than
     *    `_USDSamount` when redeeming the full amount would leave the last Trove of the redemption sequence with less net debt than the
     *    minimum allowed value (i.e. MIN_NET_DEBT).
     *
     * The number of Troves to consider for redemption can be capped by passing a non-zero value as `_maxIterations`, while passing zero
     * will leave it uncapped.
     */

    function getRedemptionHints(
        uint _USDSamount,
        uint _price,
        uint _maxIterations
    )
        external
        view
        returns (
            address firstRedemptionHint,
            uint partialRedemptionHintNICR,
            uint truncatedUSDSamount
        )
    {
        ISortedTroves sortedTrovesCached = sortedTroves;

        uint remainingUSDS = _USDSamount;
        address currentTroveuser = sortedTrovesCached.getLast();

        uint MCR = systemState.getMCR();
        while (
            currentTroveuser != address(0) &&
            troveManager.getCurrentICR(currentTroveuser, _price) < MCR
        ) {
            currentTroveuser = sortedTrovesCached.getPrev(currentTroveuser);
        }

        firstRedemptionHint = currentTroveuser;

        if (_maxIterations == 0) {
            _maxIterations = uint(-1);
        }

        while (currentTroveuser != address(0) && remainingUSDS > 0 && _maxIterations-- > 0) {
            uint netUSDSDebt = _getNetDebt(troveManager.getTroveDebt(currentTroveuser)).add(
                troveManager.getPendingUSDSDebtReward(currentTroveuser)
            );

            if (netUSDSDebt > remainingUSDS) {
                uint MIN_NET_DEBT = systemState.getMinNetDebt();
                if (netUSDSDebt > MIN_NET_DEBT) {
                    uint maxRedeemableUSDS = LiquityMath._min(
                        remainingUSDS,
                        netUSDSDebt.sub(MIN_NET_DEBT)
                    );

                    uint BNB = troveManager.getTroveColl(currentTroveuser).add(
                        troveManager.getPendingBNBReward(currentTroveuser)
                    );

                    uint newColl = BNB.sub(maxRedeemableUSDS.mul(DECIMAL_PRECISION).div(_price));
                    uint newDebt = netUSDSDebt.sub(maxRedeemableUSDS);

                    uint compositeDebt = _getCompositeDebt(newDebt);
                    partialRedemptionHintNICR = LiquityMath._computeNominalCR(
                        newColl,
                        compositeDebt
                    );

                    remainingUSDS = remainingUSDS.sub(maxRedeemableUSDS);
                }
                break;
            } else {
                remainingUSDS = remainingUSDS.sub(netUSDSDebt);
            }

            currentTroveuser = sortedTrovesCached.getPrev(currentTroveuser);
        }

        truncatedUSDSamount = _USDSamount.sub(remainingUSDS);
    }

    /* getApproxHint() - return address of a Trove that is, on average, (length / numTrials) positions away in the 
    sortedTroves list from the correct insert position of the Trove to be inserted. 
    
    Note: The output address is worst-case O(n) positions away from the correct insert position, however, the function 
    is probabilistic. Input can be tuned to guarantee results to a high degree of confidence, e.g:

    Submitting numTrials = k * sqrt(length), with k = 15 makes it very, very likely that the ouput address will 
    be <= sqrt(length) positions away from the correct insert position.
    */
    function getApproxHint(
        uint _CR,
        uint _numTrials,
        uint _inputRandomSeed
    ) external view returns (address hintAddress, uint diff, uint latestRandomSeed) {
        uint arrayLength = troveManager.getTroveOwnersCount();

        if (arrayLength == 0) {
            return (address(0), 0, _inputRandomSeed);
        }

        hintAddress = sortedTroves.getLast();
        diff = LiquityMath._getAbsoluteDifference(_CR, troveManager.getNominalICR(hintAddress));
        latestRandomSeed = _inputRandomSeed;

        uint i = 1;

        while (i < _numTrials) {
            latestRandomSeed = uint(keccak256(abi.encodePacked(latestRandomSeed)));

            uint arrayIndex = latestRandomSeed % arrayLength;
            address currentAddress = troveManager.getTroveFromTroveOwnersArray(arrayIndex);
            uint currentNICR = troveManager.getNominalICR(currentAddress);

            // check if abs(current - CR) > abs(closest - CR), and update closest if current is closer
            uint currentDiff = LiquityMath._getAbsoluteDifference(currentNICR, _CR);

            if (currentDiff < diff) {
                diff = currentDiff;
                hintAddress = currentAddress;
            }
            i++;
        }
    }

    function computeNominalCR(uint _coll, uint _debt) external pure returns (uint) {
        return LiquityMath._computeNominalCR(_coll, _debt);
    }

    function computeCR(uint _coll, uint _debt, uint _price) external pure returns (uint) {
        return LiquityMath._computeCR(_coll, _debt, _price);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../TroveManager.sol";
import "../Interfaces/ISystemState.sol";

/* Tester contract inherits from TroveManager, and provides external functions 
for testing the parent's internal functions. */

contract TroveManagerTester is TroveManager {

    ISystemState private _systemState;
    function setSystemState(address _systemStateAddress) external {
        _systemState = ISystemState(_systemStateAddress);
    }

    function computeICR(uint _coll, uint _debt, uint _price) external pure returns (uint) {
        return LiquityMath._computeCR(_coll, _debt, _price);
    }

    function getCollGasCompensation(uint _coll) external pure returns (uint) {
        return _getCollGasCompensation(_coll);
    }

    function getUSDSGasCompensation() external view returns (uint) {
        // uint USDS_GAS_COMPENSATION = systemState.getUSDSGasCompensation();
        uint USDS_GAS_COMPENSATION = _systemState.getUSDSGasCompensation();
        return USDS_GAS_COMPENSATION;
    }

    function getCompositeDebt(uint _debt) external view returns (uint) {
        // return _getCompositeDebt(_debt);
        uint USDS_GAS_COMPENSATION = _systemState.getUSDSGasCompensation();
        return _debt.add(USDS_GAS_COMPENSATION);
    }

    function unprotectedDecayBaseRateFromBorrowing() external returns (uint) {
        baseRate = _calcDecayedBaseRate();
        assert(baseRate >= 0 && baseRate <= DECIMAL_PRECISION);

        _updateLastFeeOpTime();
        return baseRate;
    }

    function minutesPassedSinceLastFeeOp() external view returns (uint) {
        // return _minutesPassedSinceLastFeeOp();
        return (block.timestamp.sub(lastFeeOperationTime)).div(SECONDS_IN_ONE_MINUTE);
    }

    function setLastFeeOpTimeToNow() external {
        lastFeeOperationTime = block.timestamp;
    }

    function setBaseRate(uint _baseRate) external {
        baseRate = _baseRate;
    }

    function callGetRedemptionFee(uint _BNBDrawn, uint _oracleRate) external view returns (uint) {
        _getRedemptionFee(_BNBDrawn, _oracleRate);
    }

    function getActualDebtFromComposite(uint _debtVal) external view returns (uint) {
        return _getNetDebt(_debtVal);
    }

    function callInternalRemoveTroveOwner(address _troveOwner) external {
        uint troveOwnersArrayLength = TroveOwners.length;
        _removeTroveOwner(_troveOwner, troveOwnersArrayLength);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../DefaultPool.sol";

contract DefaultPoolTester is DefaultPool {
    
    function unprotectedIncreaseUSDSDebt(uint _amount) external {
        USDSDebt  = USDSDebt.add(_amount);
    }

    function unprotectedPayable() external payable {
        BNB = BNB.add(msg.value);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Interfaces/ISABLEToken.sol";
import "../Interfaces/ISableRewarder.sol";
import "../Interfaces/ISableStakingV2.sol";
import "../Dependencies/BaseMath.sol";
import "../Dependencies/LiquityMath.sol";
import "../Dependencies/OwnableTransfer.sol";
import "../Dependencies/CheckContract.sol";
import "../Dependencies/SafeMath.sol";

contract SableRewarder is ISableRewarder, OwnableTransfer, CheckContract, BaseMath {
    using SafeMath for uint;

    // --- Data ---

    string public constant NAME = "SableRewarder";

    ISABLEToken public sableToken;

    ISableStakingV2 public sableStaking;
    address public sableStakingAddress;

    uint public totalSABLEIssued;
    uint public immutable deploymentTime;

    uint public lastIssuanceTime;
    uint public latestRewardPerSec;

    bool private initialized;

    // --- Events ---

    event SABLETokenAddressSet(address _sableTokenAddress);
    event SableStakingAddressSet(address _sableStakingddress);
    event TotalSABLEIssuedUpdated(uint _totalSABLEIssued);

    // --- Functions ---

    constructor() public {
        deploymentTime = block.timestamp;
        lastIssuanceTime = block.timestamp;
    }

    function setParams(
        address _sableTokenAddress,
        address _sableStakingAddress,
        uint256 _latestRewardPerSec
    ) external override onlyOwner {
        require(!initialized, "Contract instance already set param");

        checkContract(_sableTokenAddress);
        checkContract(_sableStakingAddress);

        latestRewardPerSec = _latestRewardPerSec;

        sableToken = ISABLEToken(_sableTokenAddress);
        sableStaking = ISableStakingV2(_sableStakingAddress);
        sableStakingAddress = _sableStakingAddress;

        emit SABLETokenAddressSet(_sableTokenAddress);
        emit SableStakingAddressSet(_sableStakingAddress);
        emit RewardPerSecUpdated(_latestRewardPerSec);

        initialized = true;
    }

    function issueSABLE() external override {
        _requireCallerIsSableStaking();
        _issueSABLE();
    }

    function _issueSABLE() internal {
        uint timeSinceLastIssue = block.timestamp.sub(lastIssuanceTime);
        uint issuance = latestRewardPerSec.mul(timeSinceLastIssue);
        
        totalSABLEIssued = totalSABLEIssued.add(issuance);
        lastIssuanceTime = block.timestamp;

        sendSABLE(issuance);
        sableStaking.increaseF_SABLE(issuance);

        emit TotalSABLEIssuedUpdated(totalSABLEIssued);
    }

    function updateRewardPerSec(uint newRewardPerSec) external override onlyOwner {
        _issueSABLE();
        require(lastIssuanceTime == block.timestamp);
        latestRewardPerSec = newRewardPerSec;
        emit RewardPerSecUpdated(newRewardPerSec);
    }

    function sendSABLE(uint _SABLEamount) internal {
        sableToken.transfer(sableStakingAddress, _SABLEamount);
    }

    function balanceSABLE() external override returns (uint) {
        return sableToken.balanceOf(address(this));
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        _transferOwnership(newOwner);
    }

    // --- 'require' functions ---

    function _requireCallerIsSableStaking() internal view {
        require(msg.sender == address(sableStaking), "SableRewarder: caller is not Staking");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

/**
 * Based on OpenZeppelin's Ownable contract:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
 *
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableTransfer {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     *
     * NOTE: This function is not safe, as it doesn’t check owner is calling it.
     * Make sure you check it before calling it.
     */
    function _renounceOwnership() internal {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Interfaces/ISABLEToken.sol";
import "../Interfaces/ICommunityIssuance.sol";
import "../Interfaces/IStabilityPool.sol";
import "../Dependencies/BaseMath.sol";
import "../Dependencies/LiquityMath.sol";
import "../Dependencies/OwnableTransfer.sol";
import "../Dependencies/CheckContract.sol";
import "../Dependencies/SafeMath.sol";

contract CommunityIssuance is ICommunityIssuance, OwnableTransfer, CheckContract, BaseMath {
    using SafeMath for uint;

    // --- Data ---

    string public constant NAME = "CommunityIssuance";

    ISABLEToken public sableToken;

    // address public stabilityPoolAddress;
    IStabilityPool public stabilityPool;

    uint public totalSABLEIssued;
    uint public immutable deploymentTime;

    uint public lastIssuanceTime;
    uint public latestRewardPerSec;

    bool private initialized;

    // --- Events ---

    event SABLETokenAddressSet(address _sableTokenAddress);
    event StabilityPoolAddressSet(address _stabilityPoolAddress);
    event TotalSABLEIssuedUpdated(uint _totalSABLEIssued);

    // --- Functions ---

    constructor() public {
        deploymentTime = block.timestamp;
        lastIssuanceTime = block.timestamp;
    }

    function setParams(
        address _sableTokenAddress,
        address _stabilityPoolAddress,
        uint256 _latestRewardPerSec
    ) external override onlyOwner {
        require(!initialized, "Contract instance already set param");

        checkContract(_sableTokenAddress);
        checkContract(_stabilityPoolAddress);

        latestRewardPerSec = _latestRewardPerSec;

        sableToken = ISABLEToken(_sableTokenAddress);
        stabilityPool = IStabilityPool(_stabilityPoolAddress);

        emit SABLETokenAddressSet(_sableTokenAddress);
        emit StabilityPoolAddressSet(_stabilityPoolAddress);
        emit RewardPerSecUpdated(_latestRewardPerSec);

        initialized = true;
    }

    function issueSABLE() external override returns (uint) {
        _requireCallerIsStabilityPool();

        uint timeSinceLastIssue = block.timestamp.sub(lastIssuanceTime);
        uint issuance = latestRewardPerSec.mul(timeSinceLastIssue);
        
        totalSABLEIssued = totalSABLEIssued.add(issuance);
        lastIssuanceTime = block.timestamp;

        emit TotalSABLEIssuedUpdated(totalSABLEIssued);
        return issuance;
    }

    function updateRewardPerSec(uint newRewardPerSec) external override onlyOwner {
        stabilityPool.ownerTriggerIssuance();
        require(lastIssuanceTime == block.timestamp);
        latestRewardPerSec = newRewardPerSec;
        emit RewardPerSecUpdated(newRewardPerSec);
    }

    function sendSABLE(address _account, uint _SABLEamount) external override {
        _requireCallerIsStabilityPool();

        sableToken.transfer(_account, _SABLEamount);
    }

    function balanceSABLE() external override returns (uint) {
        return sableToken.balanceOf(address(this));
    }

    function transferOwnership(address _newOwner) onlyOwner external override {
        _transferOwnership(_newOwner);
    }

    // --- 'require' functions ---

    function _requireCallerIsStabilityPool() internal view {
        require(msg.sender == address(stabilityPool), "CommunityIssuance: caller is not SP");
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../SABLE/CommunityIssuance.sol";

contract CommunityIssuanceTester is CommunityIssuance {
    function obtainSABLE(uint _amount) external {
        sableToken.transfer(msg.sender, _amount);
    }

    function getCumulativeIssuanceFraction() external pure returns (uint) {
        return 0; // TODO: for test issurance
    }

    function unprotectedIssueSABLE() external pure returns (uint) {
        // No checks on caller address

        return 0; // TODO: for test issurance
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Dependencies/CheckContract.sol";
import "../Interfaces/IStabilityPool.sol";


contract StabilityPoolScript is CheckContract {
    string constant public NAME = "StabilityPoolScript";

    IStabilityPool immutable stabilityPool;

    constructor(IStabilityPool _stabilityPool) public {
        checkContract(address(_stabilityPool));
        stabilityPool = _stabilityPool;
    }

    function provideToSP(uint _amount, address _frontEndTag) external {
        stabilityPool.provideToSP(_amount, _frontEndTag);
    }

    function withdrawFromSP(
        uint _amount,
        bytes[] calldata priceFeedUpdateData
    ) external {
        stabilityPool.withdrawFromSP(_amount, priceFeedUpdateData);
    }

    function withdrawBNBGainToTrove(
        address _upperHint, 
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external {
        stabilityPool.withdrawBNBGainToTrove(_upperHint, _lowerHint, priceFeedUpdateData);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/CheckContract.sol";
import "../Dependencies/SafeMath.sol";
import "../Interfaces/ISABLEToken.sol";
import "../Dependencies/console.sol";

/*
* Based upon OpenZeppelin's ERC20 contract:
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
*  
* and their EIP2612 (ERC20Permit / ERC712) functionality:
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/53516bc555a454862470e7860a9b5254db4d00f5/contracts/token/ERC20/ERC20Permit.sol
* 
*
*  --- Functionality added specific to the SABLEToken ---
* 
* 1) Transfer protection: blacklist of addresses that are invalid recipients (i.e. core Sable contracts) in external 
* transfer() and transferFrom() calls. The purpose is to protect users from losing tokens by mistakenly sending SABLE directly to a Sable
* core contract, when they should rather call the right function.
*
* 2) sendToSABLEStaking(): callable only by Sable core contracts, which move SABLE tokens from user -> SABLEStaking contract.
*
* 3) Supply hard-capped at 100 million
*
* 4) CommunityIssuance address is set at deployment
*/

contract SABLEToken is CheckContract, ISABLEToken {
    using SafeMath for uint256;

    // --- ERC20 Data ---

    string internal constant _NAME = "SABLE";
    string internal constant _SYMBOL = "SABLE";
    string internal constant _VERSION = "1";
    uint8 internal constant _DECIMALS = 18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint private _totalSupply;

    // --- EIP 2612 Data ---

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant _PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant _TYPE_HASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;

    mapping(address => uint256) private _nonces;

    // --- SABLEToken specific data ---

    uint internal immutable deploymentStartTime;

    address public immutable sableStakingAddress;

    address public immutable sableRewarderAddress;

    // --- Events ---

    event SABLEStakingAddressSet(address _sableStakingAddress);

    // --- Functions ---

    constructor(address _sableStakingAddress, address _sableRewarderAddress, address _vaultAddress, uint256 _mintAmount) public {
        checkContract(_sableStakingAddress);

        deploymentStartTime = block.timestamp;

        sableStakingAddress = _sableStakingAddress;
        sableRewarderAddress = _sableRewarderAddress;

        bytes32 hashedName = keccak256(bytes(_NAME));
        bytes32 hashedVersion = keccak256(bytes(_VERSION));

        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _chainID();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(_TYPE_HASH, hashedName, hashedVersion);

        // --- Initial SABLE allocations ---

        _mint(_vaultAddress, _mintAmount);

    }

    // --- External functions ---

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function getDeploymentStartTime() external view override returns (uint256) {
        return deploymentStartTime;
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _requireValidRecipient(recipient);

        // Otherwise, standard transfer functionality
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {

        _requireValidRecipient(recipient);

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external override returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external override returns (bool) {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    
    // --- EIP 2612 functionality ---

    function domainSeparator() public view override returns (bytes32) {
        if (_chainID() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function permit(
        address owner,
        address spender,
        uint amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= now, "SABLE: expired deadline");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator(),
                keccak256(
                    abi.encode(_PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner]++, deadline)
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == owner, "SABLE: invalid signature");
        _approve(owner, spender, amount);
    }

    function nonces(address owner) external view override returns (uint256) {
        // FOR EIP 2612
        return _nonces[owner];
    }

    // --- Internal operations ---

    function _chainID() private pure returns (uint256 chainID) {
        assembly {
            chainID := chainid()
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 name,
        bytes32 version
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, name, version, _chainID(), address(this)));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }



    // --- 'require' functions ---

    function _requireValidRecipient(address _recipient) internal view {
        require(
            _recipient != address(0) && _recipient != address(this),
            "SABLE: Cannot transfer tokens directly to the SABLE token contract or the zero address"
        );
        if (msg.sender != sableRewarderAddress) {
            require(
                _recipient != sableStakingAddress,
                "SABLE: Cannot transfer tokens directly to staking contract"
            );
        }
    }


    // --- Optional functions ---

    function name() external view override returns (string memory) {
        return _NAME;
    }

    function symbol() external view override returns (string memory) {
        return _SYMBOL;
    }

    function decimals() external view override returns (uint8) {
        return _DECIMALS;
    }

    function version() external view override returns (string memory) {
        return _VERSION;
    }

    function permitTypeHash() external view override returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../SABLE/SABLEToken.sol";

contract SABLETokenTester is SABLEToken {
    constructor(
        address _sableStakingAddress,
        address _sableRewarderAddress,
        address _vaultAddress,
        uint256 _mintAmount
    ) public SABLEToken(_sableStakingAddress, _sableRewarderAddress, _vaultAddress, _mintAmount) {}

    function unprotectedMint(address account, uint256 amount) external {
        // No check for the caller here

        _mint(account, amount);
    }

    function unprotectedSendToSABLEStaking(address _sender, uint256 _amount) external {
        // No check for the caller here
        _transfer(_sender, sableStakingAddress, _amount);
    }

    function callInternalApprove(
        address owner,
        address spender,
        uint256 amount
    ) external returns (bool) {
        _approve(owner, spender, amount);
    }

    function callInternalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
    }

    function getChainId() external pure returns (uint256 chainID) {
        //return _chainID(); // it’s private
        assembly {
            chainID := chainid()
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Interfaces/IUSDSToken.sol";

contract USDSTokenCaller {
    IUSDSToken USDS;

    function setUSDS(IUSDSToken _USDS) external {
        USDS = _USDS;
    }

    function usdsMint(address _account, uint _amount) external {
        USDS.mint(_account, _amount);
    }

    function usdsBurn(address _account, uint _amount) external {
        USDS.burn(_account, _amount);
    }

    function usdsSendToPool(address _sender,  address _poolAddress, uint256 _amount) external {
        USDS.sendToPool(_sender, _poolAddress, _amount);
    }

    function usdsReturnFromPool(address _poolAddress, address _receiver, uint256 _amount ) external {
        USDS.returnFromPool(_poolAddress, _receiver, _amount);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../BorrowerOperations.sol";

/* Tester contract inherits from BorrowerOperations, and provides external functions 
for testing the parent's internal functions. */
contract BorrowerOperationsTester is BorrowerOperations {

    function getNewICRFromTroveChange
    (
        uint _coll, 
        uint _debt, 
        uint _collChange, 
        bool isCollIncrease, 
        uint _debtChange, 
        bool isDebtIncrease, 
        uint _price
    ) 
    external
    pure
    returns (uint)
    {
        NewICRFromTroveChangeParam memory newICRParam = NewICRFromTroveChangeParam({
            coll: _coll,
            debt: _debt,
            collChange: _collChange,
            isCollIncrease: isCollIncrease,
            debtChange: _debtChange,
            isDebtIncrease: isDebtIncrease,
            price: _price
        });
        return _getNewICRFromTroveChange(newICRParam);
    }

    function getNewTCRFromTroveChange
    (
        uint _collChange, 
        bool isCollIncrease,  
        uint _debtChange, 
        bool isDebtIncrease, 
        uint _price
    ) 
    external 
    view
    returns (uint) 
    {
        return _getNewTCRFromTroveChange(_collChange, isCollIncrease, _debtChange, isDebtIncrease, _price);
    }

    function getUSDValue(uint _coll, uint _price) external pure returns (uint) {
        return _getUSDValue(_coll, _price);
    }

    function callInternalAdjustLoan(
        address _borrower, 
        uint _collWithdrawal, 
        uint _debtChange, 
        bool _isDebtIncrease, 
        address _upperHint,
        address _lowerHint,
        bytes[] calldata priceFeedUpdateData
    ) external payable {
        AdjustTroveParam memory adjustTroveParam = AdjustTroveParam({
            collWithdrawal: _collWithdrawal,
            USDSChange: _debtChange,
            isDebtIncrease: _isDebtIncrease,
            upperHint: _upperHint,
            lowerHint: _lowerHint,
            maxFeePercentage: 0
        });
        _adjustTrove(_borrower, adjustTroveParam, priceFeedUpdateData);
    }


    // Payable fallback function
    receive() external payable { }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "../Interfaces/ISortedTroves.sol";


contract SortedTrovesTester {
    ISortedTroves sortedTroves;

    function setSortedTroves(address _sortedTrovesAddress) external {
        sortedTroves = ISortedTroves(_sortedTrovesAddress);
    }

    function insert(ISortedTroves.SortedTrovesInsertParam memory param) external {
        sortedTroves.insert(param);
    }

    function remove(address _id) external {
        sortedTroves.remove(_id);
    }

    function reInsert(ISortedTroves.SortedTrovesInsertParam memory param) external {
        sortedTroves.reInsert(param);
    }

    function getNominalICR(address) external pure returns (uint) {
        return 1;
    }

    function getCurrentICR(address, uint) external pure returns (uint) {
        return 1;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./TroveManager.sol";
import "./SortedTroves.sol";

/*  Helper contract for grabbing Trove data for the front end. Not part of the core Sable system. */
contract MultiTroveGetter {
    struct CombinedTroveData {
        address owner;

        uint debt;
        uint coll;
        uint stake;

        uint snapshotBNB;
        uint snapshotUSDSDebt;
    }

    TroveManager public troveManager; // XXX Troves missing from ITroveManager?
    ISortedTroves public sortedTroves;

    constructor(TroveManager _troveManager, ISortedTroves _sortedTroves) public {
        troveManager = _troveManager;
        sortedTroves = _sortedTroves;
    }

    function getMultipleSortedTroves(int _startIdx, uint _count)
        external view returns (CombinedTroveData[] memory _troves)
    {
        uint startIdx;
        bool descend;

        if (_startIdx >= 0) {
            startIdx = uint(_startIdx);
            descend = true;
        } else {
            startIdx = uint(-(_startIdx + 1));
            descend = false;
        }

        uint sortedTrovesSize = sortedTroves.getSize();

        if (startIdx >= sortedTrovesSize) {
            _troves = new CombinedTroveData[](0);
        } else {
            uint maxCount = sortedTrovesSize - startIdx;

            if (_count > maxCount) {
                _count = maxCount;
            }

            if (descend) {
                _troves = _getMultipleSortedTrovesFromHead(startIdx, _count);
            } else {
                _troves = _getMultipleSortedTrovesFromTail(startIdx, _count);
            }
        }
    }

    function _getMultipleSortedTrovesFromHead(uint _startIdx, uint _count)
        internal view returns (CombinedTroveData[] memory _troves)
    {
        address currentTroveowner = sortedTroves.getFirst();

        for (uint idx = 0; idx < _startIdx; ++idx) {
            currentTroveowner = sortedTroves.getNext(currentTroveowner);
        }

        _troves = new CombinedTroveData[](_count);

        for (uint idx = 0; idx < _count; ++idx) {
            _troves[idx].owner = currentTroveowner;
            (
                _troves[idx].debt,
                _troves[idx].coll,
                _troves[idx].stake,
                /* status */,
                /* arrayIndex */
            ) = troveManager.Troves(currentTroveowner);
            (
                _troves[idx].snapshotBNB,
                _troves[idx].snapshotUSDSDebt
            ) = troveManager.rewardSnapshots(currentTroveowner);

            currentTroveowner = sortedTroves.getNext(currentTroveowner);
        }
    }

    function _getMultipleSortedTrovesFromTail(uint _startIdx, uint _count)
        internal view returns (CombinedTroveData[] memory _troves)
    {
        address currentTroveowner = sortedTroves.getLast();

        for (uint idx = 0; idx < _startIdx; ++idx) {
            currentTroveowner = sortedTroves.getPrev(currentTroveowner);
        }

        _troves = new CombinedTroveData[](_count);

        for (uint idx = 0; idx < _count; ++idx) {
            _troves[idx].owner = currentTroveowner;
            (
                _troves[idx].debt,
                _troves[idx].coll,
                _troves[idx].stake,
                /* status */,
                /* arrayIndex */
            ) = troveManager.Troves(currentTroveowner);
            (
                _troves[idx].snapshotBNB,
                _troves[idx].snapshotUSDSDebt
            ) = troveManager.rewardSnapshots(currentTroveowner);

            currentTroveowner = sortedTroves.getPrev(currentTroveowner);
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/CheckContract.sol";
import "../Dependencies/IERC20.sol";


contract TokenScript is CheckContract {
    string constant public NAME = "TokenScript";

    IERC20 immutable token;

    constructor(address _tokenAddress) public {
        checkContract(_tokenAddress);
        token = IERC20(_tokenAddress);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        token.transfer(recipient, amount);
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        token.allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        token.approve(spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        token.transferFrom(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        token.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        token.decreaseAllowance(spender, subtractedValue);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/LiquitySafeMath128.sol";

/* Tester contract for math functions in LiquitySafeMath128.sol library. */

contract LiquitySafeMath128Tester {
    using LiquitySafeMath128 for uint128;

    function add(uint128 a, uint128 b) external pure returns (uint128) {
        return a.add(b);
    }

    function sub(uint128 a, uint128 b) external pure returns (uint128) {
        return a.sub(b);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../ActivePool.sol";

contract ActivePoolTester is ActivePool {
    
    function unprotectedIncreaseUSDSDebt(uint _amount) external {
        USDSDebt  = USDSDebt.add(_amount);
    }

    function unprotectedPayable() external payable {
        BNB = BNB.add(msg.value);
    }
}
