// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
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
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
                /// @solidity memory-safe-assembly
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governance contract
 * @author dlabs.hu
 * @dev This contract is for handling governance and configuration changes
 */

import "../Interfaces/IVault.sol";
import "../Interfaces/IAffiliate.sol";
import "../Interfaces/IGoverned.sol";

contract Governance {

mapping(address => uint256) public curator_proportions;                             // Proportions of the curators
address[] public governedContracts;                                                 // The governed addresses

/* ConfManager system mappings and vars */
mapping(string => config_struct) public Configuration;
mapping(string => config_struct) public invoteConfiguration;
mapping(uint256 => string) public ID_to_name;

mapping(address => uint256) public conf_curator_timer;                           // Last action time by curator for locking
mapping(uint256 => uint256) public conf_votes;                                   // ID to see if threshold is passed
mapping(uint256 => uint256) public conf_time_limit;                              // Actions needs to be triggered in time
uint256 public conf_counter = 6;                                                 // Starting from 6+1, 0-6 are reserved for global config

struct config_struct {
  string name;
  bool Running;
  address govaddr;
  address[] managers;
  bool[] boolslot;
  address[] address_slot;
  uint256[] uint256_slot;
  bytes32[] bytes32_slot;
}

mapping(uint256 => bool) public triggered;                                          // If true, it was triggered before and will be blocked
string constant Core = "Main";                                                               // Core string for consistency

/* Action manager system mappings */
mapping(address => uint256) public action_curator_timer;                            // Last action time by curator for locking
mapping(uint256 => uint256) public action_id_to_vote;                               // ID to see if threshold is passed
mapping(uint256 => uint256) public action_time_limit;                               // Actions needs to be triggered in time
mapping(uint256 => address) public action_can_be_triggered_by;                      // Address which can trigger the action after threshold is passed

/* This is used to store calldata and make it takeable from external contracts.
@dev be careful with this, low level calls can be tricky. */
mapping(uint256 => bytes) public action_id_to_calldata;                             // Mapping actions to relevant calldata.

// Action threshold and time limit, so the community can react to changes
uint256 public action_threshold;                                                    // This threshold needs to be passed for action to happen
uint256 public vote_time_threshold;                                                 // You can only vote once per timer - this is for security and gas optimization
uint256 public vote_conf_time_threshold;                                            // Config

event Transfer_Proportion(uint256 beneficiary_proportion);
event Action_Proposed(uint256 id);
event Action_Support(uint256 id);
event Action_Trigger(uint256 id);
event Config_Proposed(string name);
event Config_Supported(string name);

modifier onlyCurators(){
  require(curator_proportions[msg.sender] > 0, "Not a curator");
  _;
}

// The Governance contract needs to be deployed first, before all
// Max proportions are 100, shared among curators
 constructor(
    address[] memory _curators,
    uint256[] memory _curator_proportions,
    address[] memory _managers
) {
    action_threshold = 30;                                        // Threshold -> from this, configs and actions can be triggered
    vote_time_threshold = 600;                                    // Onc conf change per 10 mins, in v2 we can make it longer
    vote_conf_time_threshold = 0;

    require(_curators.length == _curator_proportions.length, "Curators and proportions length mismatch");

    uint totalProp;
    for (uint256 i = 0; i < _curators.length; i++) {
        curator_proportions[_curators[i]] = _curator_proportions[i];
        totalProp += _curator_proportions[i];
    }

    require(totalProp == 100, "Total proportions must be 100");

    ID_to_name[0] = Core;                                         // Core config init
    core_govAddr_conf(address(this));                             // Global governance address
    core_emergency_conf();                                        // Emergency stop value is enforced to be Running==true from start.
    core_managers_conf(_managers);
}

// Core functions, only used during init
function core_govAddr_conf(address _address) private {
    Configuration[Core].name = Core;
    Configuration[Core].govaddr = _address;}

function core_emergency_conf() private {
    Configuration[Core].Running = true;}

function core_managers_conf(address[] memory _addresses) private {
    Configuration[Core].managers = _addresses;
    address[] storage addGovAddr = Configuration[Core].managers; // Constructor memory -> Storage
    addGovAddr.push(address(this));
    Configuration[Core].managers = addGovAddr;
    }

// Only the addresses on the manager list are allowed to execute
function onlyManagers() internal view {
      bool ok;
          address [] memory tempman =  read_core_managers();
          for (uint i=0; i < tempman.length; i++) {
              if (tempman[i] == msg.sender) {ok = true;}
          }
          if (ok == true){} else {revert("0");} //Not manager*/
}

bool public deployed = false;
function setToDeployed() public returns (bool) {
  onlyManagers();
  deployed = true;
  return deployed;
}

function ActivateDeployedMosaic(
    address _userProfile,
    address _affiliate,
    address _fees,
    address _register,
    address _poolFactory,
    address _feeTo,
    address _swapsContract,
    address _oracle,
    address _deposit,
    address _burner,
    address _booster
) public {
    onlyManagers();
    require(deployed == false, "It is done.");

        Configuration[Core].address_slot.push(msg.sender); //0 owner
        Configuration[Core].address_slot.push(_userProfile); //1
        Configuration[Core].address_slot.push(_affiliate); //2
        Configuration[Core].address_slot.push(_fees); //3
        Configuration[Core].address_slot.push(_register); //4
        Configuration[Core].address_slot.push(_poolFactory); //5
        Configuration[Core].address_slot.push(_feeTo); //6 - duplicate? fees and feeToo are same?
        Configuration[Core].address_slot.push(_swapsContract); //7
        Configuration[Core].address_slot.push(_oracle); //8
        Configuration[Core].address_slot.push(_deposit); //9
        Configuration[Core].address_slot.push(_burner); //10
        Configuration[Core].address_slot.push(_booster); //11

        IAffiliate(_affiliate).selfManageMe();
}

/* Transfer proportion */
function transfer_proportion(address _address, uint256 _amount) external returns (uint256) {
    require(curator_proportions[msg.sender] >= _amount, "Not enough proportions");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet, your votes need to conclude");
    action_curator_timer[msg.sender] = block.timestamp;
    curator_proportions[msg.sender] = curator_proportions[msg.sender] - _amount;
    curator_proportions[_address] = curator_proportions[_address] + _amount;
    emit Transfer_Proportion(curator_proportions[_address]);
    return curator_proportions[_address];
  }

/* Configuration manager */

// Add or update config.
function update_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
  ) internal returns (string memory){
  Configuration[_name].name = _name;
  Configuration[_name].Running = _Running;
  Configuration[_name].govaddr = _govaddr;
  Configuration[_name].managers = _managers;
  Configuration[_name].boolslot = _boolslot;
  Configuration[_name].address_slot = _address_slot;
  Configuration[_name].uint256_slot = _uint256_slot;
  Configuration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Create temp configuration
function votein_config(string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) internal returns (string memory){
  invoteConfiguration[_name].name = _name;
  invoteConfiguration[_name].Running = _Running;
  invoteConfiguration[_name].govaddr = _govaddr;
  invoteConfiguration[_name].managers = _managers;
  invoteConfiguration[_name].boolslot = _boolslot;
  invoteConfiguration[_name].address_slot = _address_slot;
  invoteConfiguration[_name].uint256_slot = _uint256_slot;
  invoteConfiguration[_name].bytes32_slot = _bytes32_slot;
  return _name;
}

// Propose config
function propose_config(
  string memory _name,
  bool _Running,
  address _govaddr,
  address[] memory _managers,
  bool[] memory _boolslot,
  address[] memory _address_slot,
  uint256[] memory _uint256_slot,
  bytes32[] memory _bytes32_slot
) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    conf_counter = conf_counter + 1;
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = _name;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value
    votein_config(
        _name,
        _Running,
        _govaddr,
        _managers,
        _boolslot,
        _address_slot,
        _uint256_slot,
        _bytes32_slot
    );
    emit Config_Proposed(_name);
    return conf_counter;
  }

// Use this with caution!
function propose_core_change(address _govaddr, bool _Running, address[] memory _managers, address[] memory _owners) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
    require(conf_time_limit[conf_counter] == 0, "In progress");
    conf_curator_timer[msg.sender] = block.timestamp;
    conf_time_limit[conf_counter] = block.timestamp + vote_time_threshold;
    conf_votes[conf_counter] = curator_proportions[msg.sender];
    ID_to_name[conf_counter] = Core;
    triggered[conf_counter] = false; // It keep rising, so can't be overwritten from true in past value

    invoteConfiguration[Core].name = Core;
    invoteConfiguration[Core].govaddr = _govaddr;
    invoteConfiguration[Core].Running = _Running;
    invoteConfiguration[Core].managers = _managers;
    invoteConfiguration[Core].address_slot = _owners;
    return conf_counter;
}

// ID and name are requested together for supporting a config because of awareness.
function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory) {
  require(curator_proportions[msg.sender] > 0, "You are not a curator");
  require(block.timestamp >= conf_curator_timer[msg.sender] + vote_conf_time_threshold, "Curator timer not yet expired");
  require(conf_time_limit[_confCount] > block.timestamp, "Timed out");
  require(conf_time_limit[_confCount] != 0, "Not started");
  require(keccak256(abi.encodePacked(ID_to_name[_confCount])) == keccak256(abi.encodePacked(_name)), "You are not aware, Neo.");
  conf_curator_timer[msg.sender] = block.timestamp;
  conf_votes[_confCount] = conf_votes[_confCount] + curator_proportions[msg.sender];
  if (conf_votes[_confCount] >= action_threshold && triggered[_confCount] == false) {
    triggered[_confCount] = true;
    string memory name = ID_to_name[_confCount];
    update_config(
    invoteConfiguration[name].name,
    invoteConfiguration[name].Running,
    invoteConfiguration[name].govaddr,
    invoteConfiguration[name].managers,
    invoteConfiguration[name].boolslot,
    invoteConfiguration[name].address_slot,
    invoteConfiguration[name].uint256_slot,
    invoteConfiguration[name].bytes32_slot
    );

    delete invoteConfiguration[name].name;
    delete invoteConfiguration[name].Running;
    delete invoteConfiguration[name].govaddr;
    delete invoteConfiguration[name].managers;
    delete invoteConfiguration[name].boolslot;
    delete invoteConfiguration[name].address_slot;
    delete invoteConfiguration[name].uint256_slot;
    delete invoteConfiguration[name].bytes32_slot;

    conf_votes[_confCount] = 0;
  }
  emit Config_Supported(_name);
  return Configuration[_name].name = _name;
}

/* Read configurations */

function read_core_Running() public view returns (bool) {return Configuration[Core].Running;}
function read_core_govAddr() public view returns (address) {return Configuration[Core].govaddr;}
function read_core_managers() public view returns (address[] memory) {return Configuration[Core].managers;}
function read_core_owners() public view returns (address[] memory) {return Configuration[Core].address_slot;}

function read_config_Main_addressN(uint256 _n) public view returns (address) {
  return Configuration["Main"].address_slot[_n];
}

// Can't read full because of stack too deep limit
function read_config_core(string memory _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  Configuration[_name].name,
  Configuration[_name].Running,
  Configuration[_name].govaddr,
  Configuration[_name].managers);}
function read_config_name(string memory _name) public view returns (string memory) {return Configuration[_name].name;}
function read_config_emergencyStatus(string memory _name) public view returns (bool) {return Configuration[_name].Running;}
function read_config_governAddress(string memory _name) public view returns (address) {return Configuration[_name].govaddr;}
function read_config_Managers(string memory _name) public view returns (address[] memory) {return Configuration[_name].managers;}

function read_config_bool_slot(string memory _name) public view returns (bool[] memory) {return Configuration[_name].boolslot;}
function read_config_address_slot(string memory _name) public view returns (address[] memory) {return Configuration[_name].address_slot;}
function read_config_uint256_slot(string memory _name) public view returns (uint256[] memory) {return Configuration[_name].uint256_slot;}
function read_config_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return Configuration[_name].bytes32_slot;}

function read_config_Managers_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].managers[_ids[i]];
    }
    return result;
}

function read_config_bool_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bool[] memory) {
    bool[] memory result = new bool[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].boolslot[_ids[i]];
    }
    return result;
}

function read_config_address_slot_batched(string memory _name, uint256[] memory _ids) public view returns (address[] memory) {
    address[] memory result = new address[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].address_slot[_ids[i]];
    }
    return result;
}

function read_config_uint256_slot_batched(string memory _name, uint256[] memory _ids) public view returns (uint256[] memory) {
    uint256[] memory result = new uint256[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].uint256_slot[_ids[i]];
    }
    return result;
}

function read_config_bytes32_slot_batched(string memory _name, uint256[] memory _ids) public view returns (bytes32[] memory) {
    bytes32[] memory result = new bytes32[](_ids.length);
    for (uint256 i = 0; i < _ids.length; i++) {
        result[i] = Configuration[_name].bytes32_slot[_ids[i]];
    }
    return result;
}


// Read invote configuration
// Can't read full because of stack too deep limit
function read_invoteConfig_core(string calldata _name) public view returns (
  string memory,
  bool,
  address,
  address[] memory){
  return (
  invoteConfiguration[_name].name,
  invoteConfiguration[_name].Running,
  invoteConfiguration[_name].govaddr,
  invoteConfiguration[_name].managers);}
function read_invoteConfig_name(string memory _name) public view returns (string memory) {return invoteConfiguration[_name].name;}
function read_invoteConfig_emergencyStatus(string memory _name) public view returns (bool) {return invoteConfiguration[_name].Running;}
function read_invoteConfig_governAddress(string memory _name) public view returns (address) {return invoteConfiguration[_name].govaddr;}
function read_invoteConfig_Managers(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].managers;}
function read_invoteConfig_boolslot(string memory _name) public view returns (bool[] memory) {return invoteConfiguration[_name].boolslot;}
function read_invoteConfig_address_slot(string memory _name) public view returns (address[] memory) {return invoteConfiguration[_name].address_slot;}
function read_invoteConfig_uint256_slot(string memory _name) public view returns (uint256[] memory) {return invoteConfiguration[_name].uint256_slot;}
function read_invoteConfig_bytes32_slot(string memory _name) public view returns (bytes32[] memory) {return invoteConfiguration[_name].bytes32_slot;}


/* Action manager system */

// Propose an action, regardless of which contract/address it resides in
function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(action_id_to_calldata[_id].length == 0, "Calldata already set");
    require(action_time_limit[_id] == 0, "Create a new one");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    action_curator_timer[msg.sender] = block.timestamp;
    action_time_limit[_id] = block.timestamp + vote_time_threshold;
    action_can_be_triggered_by[_id] = _trigger_address;
    action_id_to_vote[_id] = curator_proportions[msg.sender];
    action_id_to_calldata[_id] = _calldata;
    triggered[_id] = false;
    emit Action_Proposed(_id);
    return _id;
  }

// Support an already submitted action
function support_actions(uint256 _id) external returns (uint256) {
    require(curator_proportions[msg.sender] > 0, "You are not a curator");
    require(block.timestamp >= action_curator_timer[msg.sender] + vote_time_threshold, "Not yet");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    action_curator_timer[msg.sender] = block.timestamp;
    action_id_to_vote[_id] = action_id_to_vote[_id] + curator_proportions[msg.sender];
    emit Action_Support(_id);
    return _id;
  }

// Trigger action by allowed smart contract address
// Only returns calldata, does not guarantee execution success! Triggerer is responsible, choose wisely.
function trigger_action(uint256 _id) external returns (bytes memory) {
    require(action_id_to_vote[_id] >= action_threshold, "Threshold not passed");
    require(action_time_limit[_id] > block.timestamp, "Action timed out");
    require(action_can_be_triggered_by[_id] == msg.sender, "You are not the triggerer");
    require(triggered[_id] == false, "Already triggered");
    triggered[_id] = true;
    action_id_to_vote[_id] = 0;
    emit Action_Trigger(_id);
    return action_id_to_calldata[_id];
}

/* Pure function for generating signatures */
function generator(string memory _func) public pure returns (bytes memory) {
        return abi.encodeWithSignature(_func);
    }

/* Execution and mass config updates */

/* Update contracts address list */
function update_All(address [] memory _addresses) external onlyCurators returns (address [] memory) {
  governedContracts = _addresses;
  return governedContracts;
}

/* Update all contracts from address list */
function selfManageMe_All() external onlyCurators {
  for (uint256 i = 0; i < governedContracts.length; i++) {
    _execute_Manage(governedContracts[i]);
  }
}

/* Execute external contract call: selfManageMe() */
function execute_Manage(address _contractA) external onlyCurators {
    _execute_Manage(_contractA);
}

function _execute_Manage(address _contractA) internal {
    require(_contractA != address(this),"You can't call Governance on itself");
    IGoverned(_contractA).selfManageMe();
}

/* Execute external contract call: selfManageMe() */
function execute_batch_Manage(address[] calldata _contracts) external onlyCurators {
  for (uint i; i < _contracts.length; i++) {
    _execute_Manage(_contracts[i]);
  }
}

/* Execute external contract calls with any string */
function execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) external onlyCurators {
  _execute_ManageBytes(_contractA, _call, _data);
}

function execute_batch_ManageBytes(address[] calldata _contracts, string[] calldata _calls, bytes[] calldata _datas) external onlyCurators {
  require(_contracts.length == _calls.length, "Governance: _conracts and _calls length does not match");
  require(_calls.length == _datas.length, "Governance: _calls and _datas length does not match");
  for (uint i; i < _contracts.length; i++) {
    _execute_ManageBytes(_contracts[i], _calls[i], _datas[i]);
  }
}

function _execute_ManageBytes(address _contractA, string calldata _call, bytes calldata _data) internal {
  require(_contractA != address(this),"You can't call Governance on itself");
  require(bytes(_call).length == 0 || bytes(_call).length >=3, "provide a valid function specification");

  for (uint256 i = 0; i < bytes(_call).length; i++) {
    require(bytes(_call)[i] != 0x20, "No spaces in fun please");
  }

  bytes4 signature;
  if (bytes(_call).length != 0) {
      signature = (bytes4(keccak256(bytes(_call))));
  } else {
      signature = "";
  }

  (bool success, bytes memory retData) = _contractA.call(abi.encodePacked(signature, _data));
  _evaluateCallReturn(success, retData);
}

/* Execute external contract calls with address array */
function execute_ManageList(address _contractA, string calldata _funcName, address[] calldata address_array) external onlyCurators {
  require(_contractA != address(this),"You can't call Governance on itself");
  (bool success, bytes memory retData) = _contractA.call(abi.encodeWithSignature(_funcName, address_array));
  _evaluateCallReturn(success, retData);
}

/* Update Vault values */
function execute_Vault_update(address _vaultAddress) external onlyCurators {
  IVault(_vaultAddress).selfManageMe();
}

function _evaluateCallReturn(bool success, bytes memory retData) internal pure {
    if (!success) {
      if (retData.length >= 68) {
          bytes memory reason = new bytes(retData.length - 68);
          for (uint i = 0; i < reason.length; i++) {
              reason[i] = retData[i + 68];
          }
          revert(string(reason));
      } else revert("Governance: FAILX");
  }
}
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Governed base contract
 * @author dlabs.hu
 * @dev This contract is base for contracts governed by Governance
 */

import "./Governance.sol";
import "../Interfaces/IGovernance.sol";
import "../Interfaces/IGoverned.sol";

abstract contract Governed is IGoverned {
    GovernanceState internal governanceState;

    constructor() {
      governanceState.running = true;
      governanceState.governanceAddress = address(this);
    }

    function getGovernanceState() public view returns (GovernanceState memory govState) {
      return governanceState;
    }

    // Modifier responsible for checking if emergency stop was triggered, default is Running == true
    modifier Live {
        LiveFun();
        _;
    }

    modifier notLive {
        notLiveFun();
        _;
    }


    error Governed__EmergencyStopped();
    function LiveFun() internal virtual view {
        if (!governanceState.running) revert Governed__EmergencyStopped();
    }

    error Governed__NotStopped();
    function notLiveFun() internal virtual view {
        if (governanceState.running) revert Governed__NotStopped();
    }

    modifier onlyManagers() {
        onlyManagersFun();
        _;
    }

    error Governed__NotManager(address caller);
    function onlyManagersFun() internal virtual view {
        if (!isManagerFun(msg.sender)) revert Governed__NotManager(msg.sender);
    }


    function isManagerFun(address a) internal virtual view returns (bool) {
        if (a == governanceState.governanceAddress) {
            return true;
        }
        for (uint i=0; i < governanceState.managers.length; i++) {
            if (governanceState.managers[i] == a) {
                return true;
            }
        }
        return false;
    }

    function selfManageMe() external virtual {
        onlyManagersFun();
        LiveFun();
        _selfManageMeBefore();
        address governAddress = governanceState.governanceAddress;
        bool nextRunning = IGovernance(governAddress).read_core_Running();
        if (governanceState.running != nextRunning) _onBeforeEmergencyChange(nextRunning);
        governanceState.running = nextRunning;
        governanceState.managers = IGovernance(governAddress).read_core_managers();               // List of managers
        governanceState.governanceAddress = IGovernance(governAddress).read_core_govAddr();
        _selfManageMeAfter();
    }

    function _selfManageMeBefore() internal virtual;
    function _selfManageMeAfter() internal virtual;
    function _onBeforeEmergencyChange(bool nextRunning) internal virtual;
}
// SPDX-License-Identifier: GPL-3.0-or-later


pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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
}// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IUserProfile.sol";
import "../Interfaces/IGoverned.sol";

interface IAffiliate is IGoverned {
    struct AffiliateLevel {
        uint8 rank;
        uint8 commissionLevels; // eligibility for how many levels affiliate comission
        uint16 referralBuyFeeDiscount; // buy fee disccount for the referrals refistering for the user - 10000 = 100%
        uint16 referralCountThreshold; // minimum amount of direct referrals needed for level
        uint16 stakingBonus;
        uint16 conversionRatio;
        uint32 claimLimit; // max comission per month claimable - in usd value, not xe18!
        uint256 kdxStakeThreshold; // minimum amount of kdx stake needed
        uint256 purchaseThreshold; // minimum amount of self basket purchase needed
        uint256 referralPurchaseThreshold; // minimum amount of referral basket purchase needed
        uint256 traderPurchaseThreshold; // minimum amount of user basket purchase (for traders) needed

        string rankName;
    }

    struct AffiliateUserData {
        uint32 affiliateRevision;
        uint32 activeReferralCount;
        uint256 userPurchase;
        uint256 referralPurchase;
        uint256 traderPurchase;
        uint256 kdxStake;
    }

    struct AffiliateConfig {
        uint16 level1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
        uint240 activeReferralPurchaseThreshold; // the min amount of (usdt) purchase in wei to consider a referral active
    }

    function getCommissionLevelsForRanks(uint8 rank, uint8 rank2) external view returns (uint8 commissionLevels, uint8 commissionLevels2);

    function getLevelsAndConversionAndClaimLimitForRank(uint8 rank) external view returns (uint8 commissionLevels, uint16 conversionRatio, uint32 claimLimit);

    function getConfig() external view returns (AffiliateConfig memory config);

    // get the number of affiliate levels
    function getLevelCount() external view returns (uint256 count);

    function getLevelDetails(uint256 _idx) external view returns (AffiliateLevel memory level);

    function getAllLevelDetails() external view returns (AffiliateLevel[] memory levels);

    function getAffiliateUserData(address user) external view returns (AffiliateUserData memory data);

    function getUserPurchaseAmount(address user) external view returns (uint256 amount);

    function getReferralPurchaseAmount(address user) external view returns (uint256 amount);

    function userStakeChanged(address user, address referredBy, uint256 kdxAmount) external;

    function registerUserPurchase(address user, address referredBy, address trader, uint256 usdAmount) external;
    function registerUserPurchaseAsTokens(address user, address referredBy, address trader, address[] memory tokens, uint256[] memory tokenAmounts) external;

    event AffiliateConfigUpdated(AffiliateConfig _newConfig, AffiliateConfig config);

}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../Interfaces/IGoverned.sol";

interface IFees is IGoverned {
    struct MosaicFeeRanges {
        uint16 buyFeeMin;          // 10000 = 100%
        uint16 buyFeeMax;
        uint16 trailingFeeMin;
        uint16 trailingFeeMax;
        uint16 performanceFeeMin;
        uint16 performanceFeeMax;
    }

    struct MosaicFeeDistribution {
        uint16 userBuyFeeDiscountMax;
        uint16 userTrailingFeeDiscountMax;
        uint16 userPerformanceFeeDiscountMax;
        uint16 traderBuyFeeShareMin;          // 10000 = 100%
        uint16 traderBuyFeeShareMax;
        uint16 traderTrailingFeeShareMin;
        uint16 traderTrailingFeeShareMax;
        uint16 traderPerformanceFeeShareMin;
        uint16 traderPerformanceFeeShareMax;
        uint16 affiliateBuyFeeShare;
        uint16 affiliateTrailingFeeShare;
        uint16 affiliatePerformanceFeeShare;
        uint16 affiliateTraderFeeShare;
        uint16 affiliateLevel1RewardShare; // 0..10000. 6000 -> 60% of affiliate rewards go to level 1, 40% to level2
    }

    struct MosaicPlatformFeeShares {
        uint8 executorShare;
        uint8 traderExecutorShare;
        uint8 userExecutorShare;
    }

    struct MosaicUserFeeLevels {
        //slot1
        bool parentsCached;
        uint8 levels;
        uint16 conversionRatio;
        uint32 traderRevenueShareLevel; // 10 ** 9 = 100%
        uint32 userFeeDiscountLevel; // 10 ** 9 = 100%
        address parent;
        // slot2
        address parent2;
        uint32 lastTime;
        uint32 level1xTime;
        uint32 level2xTime;
        // slot3
        uint64 userFeeDiscountLevelxTime;
        uint32 claimLimit;
        uint64 claimLimitxTime;

        //uint48 conversionRatioxTime;
    }

    struct BuyFeeDistribution {
        uint userRebateAmount;
        uint traderAmount;
        uint affiliateAmount;
        // remaining is system fee
    }

    struct TraderFeeDistribution {
        uint traderAmount;
        uint affiliateAmount;
        // remaining is system fee
    }

    struct MosaicPoolFees {
        uint16 buyFee;
        uint16 trailingFee;
        uint16 performanceFee;
    }

    struct PoolFeeStatus {
        uint256 claimableUserFeePerLp;
        uint256 claimableAffiliateL1FeePerLp;
        uint256 claimableAffiliateL2FeePerLp;
        uint128 claimableTotalFixedTraderFee;
        uint128 claimableTotalVariableTraderFee;
        uint128 feesContractSelfBalance;
    }

    struct UserPoolFeeStatus {
        uint32 lastClaimTime;
        uint32 lastLevel1xTime;
        uint32 lastLevel2xTime;
        //uint48 lastConversionRatioxTime;
        uint64 lastUserFeeDiscountLevelxTime;
        uint128 userDirectlyClaimableFee;
       // uint128 userAffiliateClaimableFee;
        uint128 userClaimableFee;
        uint128 userClaimableL1Fee;
        uint128 userClaimableL2Fee;
        uint128 traderClaimableFee;
        // uint128 balance;
        uint128 l1Balance;
        uint128 l2Balance;
        uint256 lastClaimableUserFeePerLp;
        uint256 lastClaimableAffiliateL1FeePerLp;
        uint256 lastClaimableAffiliateL2FeePerLp;
    }

    struct OnBeforeTransferPayload {
        uint128 feesContractBalanceBefore;
        uint128 trailingLpToMint;
        uint128 performanceLpToMint;
    }

    /** HOOKS **/
    /** UserProfile **/
    function userRankChanged(address _user, uint8 _level) external;

    /** Staking **/
    function userStakeChanged(address _user, uint256 _amount) external;

    /** Pool **/
    function allocateBuyFee(address _pool, address _buyer, address _trader, uint _buyFeeAmount) external;
    function allocateTrailingFee(address _pool, address _trader, uint _feeAmount, uint _totalSupplyBefore, address _executor) external;
    function allocatePerformanceFee(address _pool, address _trader, uint _feeAmount, uint _totalSupplyBefore, address _executor) external;
    function onBeforeTransfer(address _pool, address _from, address _to, uint _fromBalanceBefore, uint _toBalanceBefore, uint256 _amount, uint256 _totalSupplyBefore, address _trader, OnBeforeTransferPayload memory payload) external;
    function getFeeRanges() external view returns (MosaicFeeRanges memory fees);
    function getFeeDistribution() external view returns (MosaicFeeDistribution memory fees);
    function getUserFeeLevels(address user) external view returns (MosaicUserFeeLevels memory userFeeLevels);
    function isValidFeeRanges(MosaicFeeRanges calldata ranges) external view returns (bool valid);
    function isValidFeeDistribution(MosaicFeeDistribution calldata distribution) external view returns (bool valid);
    function isValidPoolFees(MosaicPoolFees calldata poolFees) external view returns (bool valid);
    function isValidBuyFee(uint16 fee) external view returns (bool valid);
    function isValidTrailingFee(uint16 fee) external view returns (bool valid);
    function isValidPerformanceFee(uint16 fee) external view returns (bool valid);

    function calculateBuyFeeDistribution(address user, address trader, uint feeAmount, uint16 buyFeeDiscount) external view returns (BuyFeeDistribution memory distribution);
    function calculateTraderFeeDistribution(uint amount) external view returns (TraderFeeDistribution memory distribution);
    function calculateTrailingFeeTraderDistribution(address trader, uint feeAmount) external view returns (uint amount);
    /** GETTERS **/
    // get the fee reduction percentage the user has achieved. 100% = 10 ** 9
    function getUserFeeDiscountLevel(address user) external view returns (uint32 level);

    // get the fee reduction percentage the user has achieved. 100% = 10 ** 9
    function getTraderRevenueShareLevel(address user) external view returns (uint32 level);

    event FeeRangesUpdated(MosaicFeeRanges newRanges, MosaicFeeRanges oldRanges);
    event FeeDistributionUpdated(MosaicFeeDistribution newRanges, MosaicFeeDistribution oldRanges);
    event PlatformFeeSharesUpdated(MosaicPlatformFeeShares newShares, MosaicPlatformFeeShares oldShares);
    event UserFeeLevelsChanged(address indexed user, MosaicUserFeeLevels newLevels);
    event PerformanceFeeAllocated(address pool, uint256 performanceExp);
    event TrailingFeeAllocated(address pool, uint256 trailingExp);
}// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGovernance {
    function propose_action(uint256 _id, address _trigger_address, bytes memory _calldata) external returns (uint256) ;
    function support_actions(uint256 _id) external returns (uint256) ;
    function trigger_action(uint256 _id) external returns (bytes memory) ;
    function transfer_proportion(address _address, uint256 _amount) external returns (uint256) ;

    function read_core_Running() external view returns (bool);
    function read_core_govAddr() external view returns (address);
    function read_core_managers() external view returns (address[] memory);
    function read_core_owners() external view returns (address[] memory);

    function read_config_core(string memory _name) external view returns (string memory);
    function read_config_emergencyStatus(string memory _name) external view returns (bool);
    function read_config_governAddress(string memory _name) external view returns (address);
    function read_config_Managers(string memory _name) external view returns (address [] memory);

    function read_config_bool_slot(string memory _name) external view returns (bool[] memory);
    function read_config_address_slot(string memory _name) external view returns (address[] memory);
    function read_config_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_config_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function read_invoteConfig_core(string memory _name) external view returns (string memory);
    function read_invoteConfig_name(string memory _name) external view returns (string memory);
    function read_invoteConfig_emergencyStatus(string memory _name) external view returns (bool);
    function read_invoteConfig_governAddress(string memory _name) external view returns (address);
    function read_invoteConfig_Managers(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_boolslot(string memory _name) external view returns (bool[] memory);
    function read_invoteConfig_address_slot(string memory _name) external view returns (address[] memory);
    function read_invoteConfig_uint256_slot(string memory _name) external view returns (uint256[] memory);
    function read_invoteConfig_bytes32_slot(string memory _name) external view returns (bytes32[] memory);

    function propose_config(string memory _name, bool _bool_val, address _address_val, address[] memory _address_list, uint256 _uint256_val, bytes32 _bytes32_val) external returns (uint256);
    function support_config_proposal(uint256 _confCount, string memory _name) external returns (string memory);
    function generator() external pure returns (bytes memory);
}
// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.17;

interface IGoverned {
    struct GovernanceState {
      bool running;
      address governanceAddress;
      address[] managers;
    }

    function selfManageMe() external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./IFees.sol";
import "./IVault.sol";

interface IPool {
    // Versioning
    function VERSION() external view returns (uint256 version);

    // Ownable
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() external view returns (address);
    function creator() external view returns (address);

    // Only Vault address should be allowed to call
    // hook for notifying the pool about the initial library being added
    function initialLiquidityProvided(address[] calldata _tokens, uint[] calldata _liquidity) external returns (uint lpTokens, uint dust);

    // function to set managers
    function setManagers(address[] calldata _managers) external;

    // ERC20 stuff
    // Pool name
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function getTrailingFeeAmount(IVault.TotalSupplyBase memory ts) external view returns (uint256);
    function updatePerfFeePricePerLp(IVault.TotalSupplyBase calldata ts, uint256 pricePerLp) external returns (uint128);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function safeTransfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function safeTransferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Minted(address indexed sender, uint liquidity, uint feeLiquidity);
    event Burned(address indexed sender, uint liquidity);

    event WeightsChanged(address[] affectedTokens, uint32[] weights, uint32[] newWeights, uint weightChangeStart, uint weightChangeEnd);

    event LockingChanged(bool locked);

    // Callback from vault to raise ERC20 event
    function emitTransfer(address _from, address _to, uint256 _value) external;

    // Custom stuff
    // Returns pool type:
    // 0: REBALANCING: (30% ETH, 30% BTC, 40% MKR). Weight changes gradually in time.
    // 1: NON_REBALANCING: (100 ETH, 5 BTC, 200 MKR). Weight changes gradually in time.
    // 2: DAYTRADE: Non rebalancing pool. Weight changes immediately.
    function poolType() external view returns (uint8 poolType);

    function vaultAddress() external view returns (address vaultAddress);

    function isUnlocked() external view returns (bool isUnlocked);

    // Pool Id registered in the Vault
    function poolId() external view returns (uint32 poolId);

    // Fees associated with the pool
    function getPoolFees() external view returns (IFees.MosaicPoolFees memory poolFees);

    // Get pool token list
    function getTokens() external view returns (address[] memory _tokens);

    // Add new token to the pool. Only pool admin can call
    function addToken(address _token) external returns (address[] memory _tokenList);

    // Remove token from the pool. Anyone can call. Reverts if token weight is greater than 0
    function removeToken(uint _index) external returns (address[] memory _tokenList);

    // Change buy fee. Only poo16 newBuyFee) external;

    // Start a Dutch auction. Only pool admin can call
    function dutchAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external returns (uint auctionId);

    // Mint function. Called by the Vault.
    function _mint(uint LPTokens, IVault.TotalSupplyBase calldata ts) external returns (uint[] memory requestedAmounts, uint FeeLPTokens, uint expansion);

    // Burn function. Called by the Vault.
    function _burn(uint LPTokens, IVault.TotalSupplyBase calldata ts) external returns (uint[] memory amountsToBeReturned, uint expansion);

    // Calculate the amount of each tokens to be sent in order to get LPTokensToMint amount of LP tokens
    function calcMintAmounts(uint LPTokensToMint) external view returns (uint[] memory amountsToSend, uint FeeLPTokens);

    // Calculates the number of tokens to be received upon burning LP tokens
    function calcBurnAmounts(uint LPTokensToBurn) external view returns (uint[] memory amountsToGet);

    // get amount out
    function getAmountOut(address tokenA, address tokenB, uint256 amountIn, uint16 swapFee) external view returns (uint256 amountOut);

    // get amount in
    function getAmountIn(address tokenA, address tokenB, uint256 amountOut, uint16 swapFee) external view returns (uint256 amountIn);

    // Calculates the maximum number of tokens that can be withdrawn from the pool by sending a specified amountIn, taking into account the current balances and weights.
    function queryExactTokensForTokens(address tokenIn, address tokenOut, uint balanceIn, uint balanceOut, uint amountIn, uint16 swapFee) external view returns (uint _amountOut, uint _fees);

    // Calculates the minimum number of tokens required to be sent to the pool to withdraw a specified amountOut, based on the current balances and weights.
    function queryTokensForExactTokens(address tokenIn, address tokenOut,  uint balanceIn, uint balanceOut, uint amountOut, uint16 swapFee) external view returns (uint _amountIn, uint _fees);

    // Returns the current weights
    function getWeights() external view returns (uint32[] memory _weights);

    // Gradually changes the weights. Only pool admin can call
    function updateWeights(uint32 duration, uint32[] memory _newWeights) external;

    // Update buy fee. Only pool admin can call
    function updateBuyFee(uint16 newFee) external;

    // Returns reserves of each token stored in the Vault
    function getReserves() external view returns (uint256[] memory reserves);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface ISwaps {

    // Get price from Pancakeswap
    function getPrice(address tokenToSell, uint amountToSell, address tokenToBuy) external view returns (uint);

    // Returns the USDT amount to spend for a fix amount of LP tokens. Default routing: Token - USDT
    function quickQuoteMint(address _poolAddr, address usdAddr, uint LPTokensRequested) external view returns (uint usdtToSpend);

    function quickQuoteBurn(address _poolAddr, address usdAddr, uint LPTokensToBurn) external view returns (uint usdtToReceive);

    // Returns the USDT amount to spend for a fix amount of LP tokens. Requires routing.
    // If the pool has USDT token, simply provide an empty address[] for its routing
    // Example: KDX-USDT pool
    // _routing = [ [USDT_ADDRESS, KDX_ADDRESS], [] ]
    function quoteMint(address _poolAddr, address[][] memory _routing, uint LPTokensRequested) external view returns (uint usdtToSpend);

    function quoteBurn(address _poolAddr, address[][] memory _routing, uint LPTokensToBurn) external view returns (uint usdtToReceive);

    // Mint fixed amount of LP tokens from poolId pool. If usdtMaxSpend smaller than the requested amount, reverts
    function mint(address _poolAddr, address usdAddr, address[][] memory _routing, uint LPTokensRequested, uint usdMaxSpend, address referredBy, uint deadline) external returns (uint amountsSpent);

    // Burn fixed amount of LP tokens from poolId pool. If usdMinReceive smaller than the requested amount, reverts
    function burn(address _poolAddr, address usdAddr, address[][] memory _routing, uint LPTokens, uint usdMinReceive, uint deadline) external returns (uint amountsReceived);

    // Mint with default routing
    function quickMint(address _poolAddr, address usdAddr, uint LPTokensRequested, uint usdMaxSpend, address referredBy, uint deadline) external returns (uint amountsSpent);

    // Burn with default routing
    function quickBurn(address _poolAddr, address usdAddr, uint LPTokens, uint usdMinReceive, uint deadline) external returns (uint amountReceived);

    // Get a quote to swap on a given pool.
    // If givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, and the fees to pay
    // If givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, and the fees to pay
    function swapQuote(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount) external view returns (uint _amount, uint _fees);

    function addTokens(address[] calldata _tokens) external;
    function removeTokens(address[] calldata _tokens) external;

    event tokenAdded(address indexed token);
    event tokenRemoved(address indexed token);
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

interface IUserProfile {

    struct UserProfile {                           /// Storage - We map the affiliated person to the affiliated_by person
        bool exists;
        uint8 rank;
        uint8 referredByRank;                       /// Rank of referrer at transaction time
        uint16 buyFeeDiscount;                            /// buy discount - 10000 = 100%
        uint32 referralCount;                          /// Number of referred by referee
        uint32 activeReferralCount;                    /// Number of active users referred by referee
        address referredBy;                            /// Address is referred by this user
        address referredByBefore;                     /// We store the 2nd step here to save gas (no interation needed)
    }

    struct Parent {
        uint8 rank;
        address user;
    }

    // returns the parent of the address
    function getParent(address _user) external view returns (address parent);
    // returns the parent and the parent of the parent of the address
    function getParents(address _user) external view returns (address parent, address parentOfParent);


    // returns user's parents and ranks of parents in 1 call
    function getParentsAndParentRanks(address _user) external view returns (Parent memory parent, Parent memory parent2);
    // returns user's parents and ranks of parents and use rbuy fee discount in 1 call
    function getParentsAndBuyFeeDiscount(address _user) external view returns (Parent memory parent, Parent memory parent2, uint16 discount);
    // returns number of referrals of address
    function getReferralCount(address _user) external view returns (uint32 count);
    // returns number of active referrals of address
    function getActiveReferralCount(address _user) external view returns (uint32 count);

    // returns up to _count referrals of _user
    function getAllReferrals(address _user) external view returns (address[] memory referrals);

    // returns up to _count referrals of _user starting from _index
    function getReferrals(address _user, uint256 _index, uint256 _count) external view returns (address[] memory referrals);

    function getDefaultReferral() external view returns (address defaultReferral);

    // get user information of _user
    function getUser(address _user) external view returns (UserProfile memory user);

    function getUserRank(address _user) external view returns (uint8 rank);

    // returns the total number of registered users
    function getUserCount() external view returns (uint256 count);

    // return true if user exists
    function userExists(address _user) external view returns (bool exists);

    function registerUser(address _user) external;

    function increaseActiveReferralCount(address _user) external;

    function registerUser(address _user, address _referredBy) external;

    function registerUserWoBooster(address _user) external;

    function setUserRank(address _user, uint8 _rank) external;

    // function setDefaultReferral(address _referral) external;

    // events
    event UserRegistered(address user, address referredBy, uint8 referredByRank, uint16 buyFeeDiscount);
}// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/IGoverned.sol";

interface IVault is IGoverned {

    struct VaultState {
        bool userPoolTrackingDisabled;
        // bool paused;
        bool emergencyMode;
        bool whitelistingEnabled;
        bool flashEnabled;
        uint8 maxPoolTokenCount;
        uint8 feeToProtocol;
        uint8 bidMultiplier;
        uint16 flashFee;
        uint16 swapFee;
        uint16 bidMinDuration;
        uint16 rebalancingMinDuration;
        uint32 emergencyModeTimestamp;
        address feeTo;
    }

    struct PoolState {
        bool poolInitialized;
        bool poolEmergencyMode;
        bool feeless;
        bool boosted;
        uint8 poolTokenCount;
        uint32 emergencyModeTime;
        uint48 lastTrailingTimestamp;
        uint48 lastPerformanceTimestamp;
        uint216 emergencyModeLPs;
        TotalSupplyBase totalSupplyBase;
    }

    function getVaultState() external view returns (VaultState memory _vaultState);


    /************************************************************************************/
    /* Admin functions                                                                  */
    /************************************************************************************/
    // Check if given address is admin or not
    function isAdmin(address _address) external view returns (bool _isAdmin);

    // Add or remove vault admin. Only admin can call this function
    function AddRemoveAdmin(address _address, bool _ShouldBeAdmin) external;// returns (address, bool);

    // Boost or unboost pool. Boosted pools get 100% of their swap fees.
    // For non boosted pools, a part of the swap fees go to the platform.
    // Only admin can call this function
    function AddRemoveBoostedPool(address _address, bool _ShouldBeBoosted) external;// returns (address, bool);


    /************************************************************************************/
    /* Token whitelist                                                                  */
    /************************************************************************************/

    // Only admin can call this function. Only the whitelisted tokens can be added to a Pool
    // If empty: No whitelist, all tokens are allowed
    function setWhitelistedTokens(address[] calldata _tokens, bool[] calldata _whitelisted) external;

    function isTokenWhitelisted(address token) external view returns (bool whitelisted);
    event TokenWhitelistChanged(address indexed token, bool isWhitelisted);

    /************************************************************************************/
    /* Internal Balances                                                                */
    /************************************************************************************/

    // Users can deposit tokens into the Vault to have an internal balance in the Mosaic platform.
    // This internal balance can be used to deposit tokens into a Pool (Mint), withdraw tokens from
    // a Pool (Burn), or perform a swap. The internal balance can also be transferred or withdrawn.

    // Get a specific user's internal balance for one given token
    function getInternalBalance(address user, address token) external view returns (uint balance);

    // Get a specific user's internal balances for the given token array
    function getInternalBalances(address user, address[] memory tokens) external view returns (uint[] memory balances);

    // Deposit tokens to the msg.sender's  internal balance
    function depositToInternalBalance(address token, uint amount) external;

    // Deposit tokens to the recipient internal balance
    function depositToInternalBalanceToAddress(address token, address to, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to their address
    function withdrawFromInternalBalance(address token, uint amount) external;

    // ERC20 token transfer from the message sender's internal balance to the given address
    function withdrawFromInternalBalanceToAddress(address token, address to, uint amount) external;

    // Transfer tokens from the message sender's internal balance to another user's internal balance
    function transferInternalBalance(address token, address to, uint amount) external;

    // Event emitted when user's internal balance changes by delta amount. Positive delta means internal balance increase
    event InternalBalanceChanged(address indexed user, address indexed token, int256 delta);

    /************************************************************************************/
    /* Pool ERC20 helper                                                                */
    /************************************************************************************/

    function transferFromAsTokenContract(address from, address to, uint amount) external returns (bool success);
    function mintAsTokenContract(address to, uint amount) external returns (bool success);
    function burnAsTokenContract(address from, uint amount) external returns (bool success);

    /************************************************************************************/
    /* Pool                                                                             */
    /************************************************************************************/

    struct TotalSupplyBase {
        uint32 timestamp;
        uint224 amount;
    }

    event TotalSupplyBaseChanged(address indexed poolAddr, TotalSupplyBase supplyBase);
    // Each pool should be one of the following based on poolType:
    // 0: REBALANCING: (30% ETH, 30% BTC, 40% MKR). Weight changes gradually in time.
    // 1: NON_REBALANCING: (100 ETH, 5 BTC, 200 MKR). Weight changes gradually in time.
    // 2: DAYTRADE: Non rebalancing pool. Weight changes immediately.

    function tokenInPool(address pool, address token) external view returns (bool inPool);

    function poolIdToAddress(uint32 poolId) external view returns (address poolAddr);

    function poolAddressToId(address poolAddr) external view returns (uint32 poolId);

    // pool calls this to move the pool to zerofee status
    function disableFees() external;

    // Returns the total pool count
    function poolCount() external view returns (uint32 count);

    // Returns a list of pool IDs where the user has assets
    function userJoinedPools(address user) external view returns (uint32[] memory poolIDs);

    // Returns a list of pool the user owns
    function userOwnedPools(address user) external view returns (uint32[] memory poolIDs);

    //Get pool tokens and their balances
    function getPoolTokens(uint32 poolId) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTokensByAddr(address poolAddr) external view returns (address[] memory tokens, uint[] memory balances);

    function getPoolTotalSupplyBase(uint32 poolId) external view returns (TotalSupplyBase memory totalSupplyBase);

    function getPoolTotalSupplyBaseByAddr(address poolAddr) external view returns (TotalSupplyBase memory totalSupplyBase);

    // Register a new pool. Pool type can not be changed after the creation. Emits a PoolRegistered event.
    function registerPool(address _poolAddr, address _user, address _referredBy) external returns (uint32 poolId);
    event PoolRegistered(uint32 indexed poolId, address indexed poolAddress);

    // Registers tokens for the Pool. Must be called by the Pool's contract. Emits a TokensRegistered event.
    function registerTokens(address[] memory _tokenList, bool onlyWhitelisted) external;
    event TokensRegistered(uint32 indexed poolId, address[] newTokens);

    // Adds initial liquidity to the pool
    function addInitialLiquidity(uint32 _poolId, address[] memory _tokens, uint[] memory _liquidity, address tokensTo, bool fromInternalBalance) external;
    event InitialLiquidityAdded(uint32 indexed poolId, address user, uint lpTokens, address[] tokens, uint[] amounts);

    // Deegisters tokens for the poolId Pool. Must be called by the Pool's contract.
    // Tokens to be deregistered should have 0 balance. Emits a TokensDeregistered event.
    function deregisterToken(address _tokenAddress, uint _remainingAmount) external;
    event TokensDeregistered(uint32 indexed poolId, address tokenAddress);

    // This function is called when a liquidity provider adds liquidity to the pool.
    // It mints additional liquidity tokens as a reward.
    // If fromInternalBalance is true, the amounts will be deducted from user's internal balance
    function Mint(uint32 poolId, uint LPTokensRequested, uint[] memory amountsMax, address to, address referredBy, bool fromInternalBalance, uint deadline, uint usdValue) external returns (uint[] memory amountsSpent);
    event Minted(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    // This function is called when a liquidity provider removes liquidity from the pool.
    // It burns the liquidity tokens and sends back the tokens as ERC20 transfer.
    // If toInternalBalance is true, the tokens will be deposited to user's internal balance
    function Burn(uint32 poolId, uint LPTokensToBurn, uint[] memory amountsMin, bool toInternalBalance, uint deadline, address from) external returns (uint[] memory amountsReceived);
    event Burned(uint32 indexed poolId, address txFrom, address user, uint lpTokens, address[] tokens, uint[] amounts, bool fromInternalBalance);

    /************************************************************************************/
    /* Swap                                                                             */
    /************************************************************************************/

    // Executes a swap operation on a single Pool. Called by the user
    // If the swap is initiated with givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, which should not be less than limit.
    // If the swap is initiated with givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, which should not exceed limit.
    // Emits a Swap event
    function swap(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);
    event Swap(uint32 indexed poolId, address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut, address user);

    // Execute a multi-hop token swap between multiple pairs of tokens on their corresponding pools
    // Example: 100 tokenA -> tokenB -> tokenC
    // pools = [pool1, pool2], tokens = [tokenA, tokenB, tokenC], amountIn = 100
    // The returned amount of tokenC should not be less than limit
    function multiSwap(address[] memory pools, address[] memory tokens, uint amountIn, bool fromInternalBalance, uint limit, uint64 deadline) external returns (uint calculatedAmount);

    /************************************************************************************/
    /* Dutch Auction                                                                    */
    /************************************************************************************/
    // Non rebalancing pools (where poolId is not 0) can use Dutch auction to change their
    // balance sheet. A Dutch auction (also called a descending price auction) refers to a
    // type of auction in which an auctioneer starts with a very high price, incrementally
    // lowering the price. User can bid for the entire amount, or just a fraction of that.

    struct AuctionInfo {
        address poolAddress;
        uint32 startsAt;
        uint32 duration;
        uint32 expiration;
        address tokenToSell;
        address tokenToBuy;
        uint startingAmount;
        uint remainingAmount;
        uint startingPrice;
        uint endingPrice;
    }

    // Get total (lifetime) auction count
    function getAuctionCount() external view returns (uint256 auctionCount);

    // Get all information of the given auction
    function getAuctionInfo(uint auctionId) external view returns (AuctionInfo memory);

    // Returns 'true' if the auction is still running and there are tokens available for purchase
    // Returns 'false' if the auction has expired or if all tokens have been sold.
    function isRunning(uint auctionId) external view returns (bool);

    // Called by pool owner. Emits an auctionStarted event
    function startAuction(address tokenToSell, uint amountToSell, address tokenToBuy, uint32 duration, uint32 expiration, uint endingPrice) external returns (uint auctionId);
    event AuctionStarted(uint32 poolId, uint auctionId, AuctionInfo _info);

    // Called by pool owner. Emits an auctionStopped event
    function stopAuction(uint auctionId) external;
    event AuctionStopped(uint auctionId);

    // Get the current price for 'remainingAmount' number of tokens
    function getBidPrice(uint auctionId) external view returns (uint currentPrice, uint remainingAmount);

    // Place a bid for the specified 'auctionId'. Fractional bids are supported, with the 'amount'
    // representing the number of tokens to purchase. The amounts are deducted from and credited to the
    // user's internal balance. If there are insufficient tokens in the user's internal balance, the function reverts.
    // If there are fewer tokens available for the auction than the specified 'amount' and enableLessAmount == 1,
    // the function purchases all remaining tokens (which may be less than the specified amount).
    // If enableLessAmount is set to 0, the function reverts. Emits a 'newBid' event
    function bid(uint auctionId, uint amount, bool enableLessAmount, bool fromInternalBalance, uint deadline) external returns (uint spent);
    event NewBid(uint auctionId, address buyer, uint tokensBought, uint paid, address tokenToBuy, address tokenToSell, uint remainingAmount);

    /************************************************************************************/
    /* Emergency                                                                        */
    /************************************************************************************/
    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    // Only an admin can call this function.
    function setEmergencyMode() external;

    // Activate emergency mode. Once the contract enters emergency mode, it cannot be reverted or cancelled.
    function setPoolEmergencyMode(address poolAddress) external;
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

/**
 * @title Mosaic Alpha Swaps contract
 * @author dlabs.hu
 * @dev This contract is for handling pool purchase/sale exchanges from/for USDT
 */

import "../Interfaces/IVault.sol";
import "../Interfaces/IPool.sol";
import "../Interfaces/ISwaps.sol";
import "../Interfaces/IGovernance.sol";
import "../helpers/pancake/interfaces/IPancakeRouter02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Interfaces/IGovernance.sol";
import "../Governance/Governed.sol";

contract Swaps is ISwaps, Governed {
    using SafeERC20 for IERC20;

    address public pancakeRouterAddress;
    address public vaultAddress;
    address public usdtAddress;
    address[] public managers;
    mapping(address => bool) public tokens;
 
    
    function _approveToken(address _token, uint _amount) internal {
        IERC20(_token).approve(vaultAddress, _amount);
        IERC20(_token).approve(pancakeRouterAddress, _amount);
    }

    function addTokens(address[] calldata _tokens) external {
        for (uint i; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (!tokens[token]) {
                _approveToken(token, type(uint256).max);
                tokens[token] = true;
                emit tokenAdded(token);
            }
        }
    }

    function removeTokens(address[] calldata _tokens) external {
        for (uint i; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (tokens[token]) {
                _approveToken(token, 0);
                tokens[token] = false;
                emit tokenRemoved(token);
            }
        }
    }

    constructor(address _pancakeRouter, address _usdtAddress, address _vaultAddress, address _governAddress) {
        pancakeRouterAddress = _pancakeRouter;
        vaultAddress = _vaultAddress;
        usdtAddress = _usdtAddress;
        governanceState.governanceAddress = _governAddress;
    }

    function _selfManageMeBefore() internal override {}
    function _selfManageMeAfter() internal override {}
    function _onBeforeEmergencyChange(bool nexRunning) internal override {}

    function getPrice(address tokenToSell, uint amountToSell, address tokenToBuy) external view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = tokenToSell;
        path[1] = tokenToBuy;
        return IPancakeRouter02(pancakeRouterAddress).getAmountsOut(amountToSell, path)[1];
    }

    // Pancakeswap quick quote. Token - USDT pair
    function quickQuoteMint(address _poolAddr, address usdAddr, uint LPTokensRequested) external view returns (uint usdToSpend) {
        (uint[] memory _requestedAmounts,) = IPool(_poolAddr).calcMintAmounts(LPTokensRequested);
        address[] memory _tokens = IPool(_poolAddr).getTokens();
        uint _usdNeeded;

        for (uint i = 0; i < _requestedAmounts.length; i++) {
            address[] memory path = new address[](2);
            path[0] = usdAddr;
            if (_tokens[i] != usdAddr) {
                path[1] = _tokens[i];
                _usdNeeded += IPancakeRouter02(pancakeRouterAddress).getAmountsIn(_requestedAmounts[i], path)[0];
            }
            else {
                // If token is USDT
                _usdNeeded += _requestedAmounts[i];
            }
        }
        return _usdNeeded;
    }

    // Pancakeswap quick quote. Token - USDT pair
    function quickQuoteBurn(address _poolAddr, address usdAddr, uint LPTokensToBurn) external view returns (uint usdToReceive) {
        uint[] memory _amounts = IPool(_poolAddr).calcBurnAmounts(LPTokensToBurn);
        address[] memory _tokens = IPool(_poolAddr).getTokens();

        for (uint i = 0; i < _amounts.length; i++) {
            address[] memory path = new address[](2);
            path[1] = usdAddr;
            if (_tokens[i] != usdAddr) {
                path[0] = _tokens[i];
                usdToReceive += IPancakeRouter02(pancakeRouterAddress).getAmountsOut(_amounts[i], path)[1];
            }
            else {
                // If token is USDT
                usdToReceive += _amounts[i];
            }
        }
        return usdToReceive;
    }

    function quoteMint(address _poolAddr, address[][] memory _routing, uint LPTokensRequested) external view returns (uint usdToSpend) {
        (uint[] memory _requestedAmounts,) = IPool(_poolAddr).calcMintAmounts(LPTokensRequested);
        uint _usdNeeded;

        for (uint i = 0; i < _requestedAmounts.length; i++) {
            if (_routing[i].length > 1) {
                // If length of the routing is greater than 1: Do the swap
                _usdNeeded += IPancakeRouter02(pancakeRouterAddress).getAmountsIn(_requestedAmounts[i], _routing[i])[0];
            }
            else {
                // If length of the routing is not greater than 1: No swap needed
                _usdNeeded += _requestedAmounts[i];
            }
        }
        return _usdNeeded;
    }

    function quoteBurn(address _poolAddr, address[][] memory _routing, uint LPTokensToBurn) external view returns (uint usdToReceive) {
        uint[] memory _amounts = IPool(_poolAddr).calcBurnAmounts(LPTokensToBurn);
        uint _usdReceived;

        for (uint i = 0; i < _amounts.length; i++) {
            if (_routing[i].length > 1) {
                // If length of the routing is greater than 1: Do the swap
                _usdReceived += IPancakeRouter02(pancakeRouterAddress).getAmountsOut(_amounts[i], _routing[i])[_routing[i].length - 1];
            } else {
                // If length of the routing is not greater than 1: No swap needed
                _usdReceived += _amounts[i];
            }
        }
        return _usdReceived;
    }

    // IMPORTANT: Before calling this function, user needs to set allowance for at least usdtMaxSpend amount of USDT
    function mint(address _poolAddr, address usdAddr, address[][] memory _routing, uint lpTokensRequested, uint usdMaxSpend, address referredBy, uint deadline/*, bool fromInternalBalance*/) external Live returns (uint amountsSpent) {
        require(lpTokensRequested > 0, "TRYING TO MINT 0");
        (uint[] memory _requestedAmounts,) = IPool(_poolAddr).calcMintAmounts(lpTokensRequested);
        require(_routing.length == _requestedAmounts.length, "assset count mismatch");

        // Before swapping, the Swap smart contract needs to be in control of the required USDT
        require(IERC20(usdAddr).transferFrom(msg.sender, address(this), usdMaxSpend), 'transferFrom failed.');

        for (uint i = 0; i < _requestedAmounts.length; i++) {
            if (_routing[i].length > 1) {
                // If length of the routing is greater than 1: Do the swap
                address[] memory path = _routing[i];
                require(path[0] == usdAddr, "Invalid path in routing");
                uint lastIndex = _routing[i].length - 1;
                // Contract has the required token, deposit to Vault internal balance
                address token = _routing[i][lastIndex];
                uint amountOut = _requestedAmounts[i];
                if (amountOut > 0) {
                    if (path[0] != token) {
                        uint amountInMax = IPancakeRouter02(pancakeRouterAddress).getAmountsIn(amountOut, path)[0];
                        address to = address(this);
                        IPancakeRouter02(pancakeRouterAddress).swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
                    }
                    IVault(vaultAddress).depositToInternalBalance(token, amountOut);
                }
            }
            else if (_requestedAmounts[i] > 0) {
                // If length of the routing is not greater than 1: No swap needed
                IVault(vaultAddress).depositToInternalBalance(usdAddr, _requestedAmounts[i]);

            }
        }
        // Now all tokens are at the Swap contract's internal balance. Let's mint!
        // LP tokens are credited towards the user (msg.sender)
        uint32 poolId = IPool(_poolAddr).poolId();
        uint remainingUSDT = IERC20(usdAddr).balanceOf(address(this));

        IVault(vaultAddress).Mint(poolId, lpTokensRequested, _requestedAmounts, msg.sender, referredBy, true, deadline, (usdAddr == usdtAddress) ? (usdMaxSpend - remainingUSDT) : 0);
        // return excess USDT to user

        IERC20(usdAddr).safeTransfer(msg.sender, remainingUSDT);

        return usdMaxSpend - remainingUSDT;
    }

    function burn(address _poolAddr, address usdAddr, address[][] memory _routing, uint lpTokensToBurn, uint usdMinReceive, uint deadline/*, bool fromInternalBalance*/) external Live returns (uint amountsReceived) {
        require(lpTokensToBurn > 0, "TRYING TO BURN 0");
        require(IERC20(_poolAddr).transferFrom(msg.sender, address(this), lpTokensToBurn), 'transferFrom failed.');
        uint[] memory _amountsToGet = IPool(_poolAddr).calcBurnAmounts(lpTokensToBurn);
        require(_routing.length == _amountsToGet.length, "assset count mismatch");

        uint32 poolId = IPool(_poolAddr).poolId();
        uint[] memory amountsToReceive = IVault(vaultAddress).Burn(poolId, lpTokensToBurn, _amountsToGet, false, deadline, msg.sender);
        address[] memory path;

        for (uint i = 0; i < amountsToReceive.length; i++) {
            uint amountIn = amountsToReceive[i];
            if (amountIn > 0) {
                path = _routing[i];
                require(path[path.length - 1] == usdAddr, "Invalid path in routing");
                if (path[0] != usdAddr) {

                    uint amountOutMin = IPancakeRouter02(pancakeRouterAddress).getAmountsOut(amountsToReceive[i], path)[path.length - 1];
                    IPancakeRouter02(pancakeRouterAddress).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), deadline);
                }
            }
        }

        uint transferUSD = IERC20(usdAddr).balanceOf(address(this));
        require(transferUSD >= usdMinReceive, "MAX SLIPPAGE EXCEEDED");
        require(IERC20(usdAddr).transfer(msg.sender, transferUSD), "transfer failed.");

        return transferUSD;
    }

    function quickMint(address _poolAddr, address usdAddr, uint lpTokensRequested, uint usdMaxSpend, address referredBy, uint deadline) external Live returns (uint amountsSpent) {
        require(lpTokensRequested > 0, "TRYING TO MINT 0");
        (uint[] memory _requestedAmounts,) = IPool(_poolAddr).calcMintAmounts(lpTokensRequested);
        address[] memory _tokens = IPool(_poolAddr).getTokens();
        require(IERC20(usdAddr).transferFrom(msg.sender, address(this), usdMaxSpend), "transferFrom failed.");
   
        address swapAddr = address(this);
        address[] memory path = new address[](2);
        path[0] = usdAddr;

        for (uint i = 0; i < _requestedAmounts.length; i++) {
            uint amountOut = _requestedAmounts[i];
            if (amountOut > 0) {
                if (_tokens[i] != usdAddr) {
                    path[1] = _tokens[i];
                    uint amountInMax = IPancakeRouter02(pancakeRouterAddress).getAmountsIn(_requestedAmounts[i], path)[0];
                    require(amountInMax <= IERC20(usdAddr).balanceOf(address(this)), "MAX SLIPPAGE EXCEEDED");
                    IPancakeRouter02(pancakeRouterAddress).swapTokensForExactTokens(amountOut, amountInMax, path, swapAddr, deadline);
                }
                IVault(vaultAddress).depositToInternalBalance(_tokens[i], amountOut);
            }
        }

        uint32 poolId = IPool(_poolAddr).poolId();
        uint remainingUSD = IERC20(usdAddr).balanceOf(address(this));

        IVault(vaultAddress).Mint(poolId, lpTokensRequested, _requestedAmounts, msg.sender, referredBy, true, deadline, (usdAddr == usdtAddress) ? (usdMaxSpend - remainingUSD) : 0);

        IERC20(usdAddr).safeTransfer(msg.sender, remainingUSD);

        return usdMaxSpend - remainingUSD;
    }

    function quickBurn(address _poolAddr, address usdAddr, uint lpTokensToBurn, uint usdMinReceive, uint deadline) external Live returns (uint amountReceived)
    {
        require(lpTokensToBurn > 0, "TRYING TO BURN 0");
        require(IERC20(_poolAddr).transferFrom(msg.sender, address(this), lpTokensToBurn), 'transferFrom failed.');
        uint[] memory _amountsToGet = IPool(_poolAddr).calcBurnAmounts(lpTokensToBurn);
        address[] memory _tokens = IPool(_poolAddr).getTokens();
        address[] memory path = new address[](2);
        path[1] = usdAddr;
        uint32 poolId = IPool(_poolAddr).poolId();
        uint[] memory amountsToReceive = IVault(vaultAddress).Burn(poolId, lpTokensToBurn, _amountsToGet, false, deadline, msg.sender);
        for (uint i = 0; i < amountsToReceive.length; i++) {
            uint amountIn = amountsToReceive[i];
            if (amountIn > 0 && _tokens[i] != usdAddr) {
                path[0] = _tokens[i];
                uint amountOutMin = IPancakeRouter02(pancakeRouterAddress).getAmountsOut(amountsToReceive[i], path)[1];
                IPancakeRouter02(pancakeRouterAddress).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), deadline);
            }
        }
        uint transferUSD = IERC20(usdAddr).balanceOf(address(this));
        require(transferUSD >= usdMinReceive, "MAX SLIPPAGE EXCEEDED");
        require(IERC20(usdAddr).transfer(msg.sender, transferUSD), "transfer failed.");

        return transferUSD;
    }

    // Get a quote to swap on a given pool.
    // If givenInOrOut == 1 (i.e., the number of tokens to be sent to the Pool is specified),
    // it returns the amount of tokens taken from the Pool, and the fees to pay
    // If givenInOrOut == 0 parameter (i.e., the number of tokens to be taken from the Pool is specified),
    // it returns the amount of tokens sent to the Pool, and the fees to pay
    function swapQuote(address poolAddress, bool givenInOrOut, address tokenIn, address tokenOut, uint amount) external view returns (uint _amount, uint _fees) {

        uint balanceIn = IVault(vaultAddress).getInternalBalance(poolAddress, tokenIn);
        uint balanceOut = IVault(vaultAddress).getInternalBalance(poolAddress, tokenOut);
        uint16 swapFee = IVault(vaultAddress).getVaultState().swapFee;

        if (givenInOrOut) {
           return IPool(poolAddress).queryExactTokensForTokens(tokenIn, tokenOut, balanceIn, balanceOut, amount, swapFee);
        }
        else {
           return IPool(poolAddress).queryTokensForExactTokens(tokenIn, tokenOut, balanceIn, balanceOut, amount, swapFee);
        }
    }

}
