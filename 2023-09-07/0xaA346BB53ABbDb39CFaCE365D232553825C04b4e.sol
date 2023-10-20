/**
 *Submitted for verification at BscScan.com on 2023-07-30
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.9;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
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

// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)
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
        assembly {
            size := extcodesize(account)
        }
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20Mintable is IERC20 {
    function mint(address to, uint256 amount) external;

    function addUser(address userAddress, address refAddress) external;

    function _stake(address add)
        external
        view
        returns (
            uint256 amount,
            address userAddress,
            address ref,
            uint256 timestamp,
            uint256 received,
            uint256 timestampEnd,
            uint256 pt,
            uint256 totalF1,
            uint256 commission,
            uint256 reward,
            uint256 receivedUSDT
        );

    function getParents(address userAddress, uint256 upToLevels)
        external
        returns (address[] memory);
}

contract Farm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20Mintable public tokenCs;
    IERC20Mintable public tree;
    IERC20 public token_lp;
    IERC20 public token_co2;

    uint256 public priceLP = 75000;
    uint256 public priceCo2 = 1000000;
    uint256 public timeClaim = 0;
    uint256 public secentSubProfit = 60;
    uint256 public percentProfit = 100;
    uint256 public denominatorTimeProfit = 2592000000;
    bool public sttReceive = false;

    uint256 public feeDeposit = 0.004 * 1e18;
    uint256 public feeClaim = 0.004 * 1e18;
    uint256 public feeUnDeposit = 0.004 * 1e18;
    uint256 public feeClaimCommission = 0.004 * 1e18;

    // uint256 public feeDeposit = 0.004 * 1e18;

    function configsUm(
        uint256 _priceLP,
        uint256 _timeClaim,
        uint256 _secentSubProfit,
        uint256 _percentProfit,
        uint256 _denominatorTimeProfit
    ) public onlyOwner {
        priceLP = _priceLP;
        timeClaim = _timeClaim;
        secentSubProfit = _secentSubProfit;
        percentProfit = _percentProfit;
        denominatorTimeProfit = _denominatorTimeProfit;
    }

    function configsFee(
        uint256 _feeDeposit,
        uint256 _feeClaim,
        uint256 _feeUnDeposit,
        uint256 _feeClaimCommission
    ) public onlyOwner {
        feeDeposit = _feeDeposit;
        feeClaim = _feeClaim;
        feeUnDeposit = _feeUnDeposit;
        feeClaimCommission = _feeClaimCommission;
    }

    function updatePriceCo2(uint256 _priceCo2) public onlyOwner {
        priceCo2 = _priceCo2;
    }

    function openClaim() public onlyOwner {
        timeClaim = block.timestamp;
        sttReceive = true;
    }

    function closeClaim() public onlyOwner {
        sttReceive = false;
    }

    struct Join {
        uint256 amount;
        address userAddress;
    }

    struct Stake {
        uint256 amount;
        address userAddress;
        address ref;
        uint256 timestamp;
        uint256 received;
        uint256 timestampEnd;
        uint256 pt;
        uint256 totalF1;
        uint256 commission;
        uint256 directSales;
        uint256 receivedUSDT;
        uint256 compounding;
    }

    uint256[] public stakedNft;

    mapping(address => Stake) public _stake;

    constructor(
        IERC20 _tokenLP,
        IERC20 _tokenCo2,
        IERC20Mintable _tree,
        IERC20Mintable _tokenCs
    ) {
        tokenCs = _tokenCs;
        token_lp = _tokenLP;
        token_co2 = _tokenCo2;
        tree = _tree;
    }

    function getRefValue(address userAddress) public view returns (address) {
        (, , address ref, , , , , , , , ) = tree._stake(userAddress);
        return ref;
    }

    function mintCo2(uint256 amount) external payable {
        require(feeDeposit == msg.value, "not fee");
        token_lp.safeTransferFrom(msg.sender, address(this), amount);
        address _ref = getRefValue(msg.sender);
        _stake[msg.sender].ref = _ref;
        _stake[msg.sender].userAddress = msg.sender;
        _stake[msg.sender].amount += amount;
        _stake[msg.sender].timestamp = block.timestamp;
        _stake[msg.sender].received = 0;
        // addSale(_ref, amount);
    }

    function unStaking() external payable {
        require(
            _stake[msg.sender].amount > 0,
            "amount must be greater than zero"
        );
        require(feeUnDeposit == msg.value, "not fee");
        token_lp.safeTransfer(msg.sender, _stake[msg.sender].amount);
        _stake[msg.sender].amount = 0;
        _stake[msg.sender].timestamp = 0;
        _stake[msg.sender].received = 0;
    }

    function withdraw() public payable {
        require(feeClaim == msg.value, "not fee");
        require(sttReceive, "receive not active");
        require(
            integerDivision((block.timestamp - timeClaim), secentSubProfit) <
                20,
            "receive not active"
        );
        require(
            _stake[msg.sender].timestampEnd + 3600 < block.timestamp, "not active"
        );

        uint256 _amount = _stake[msg.sender].amount;
        _amount = _amount.mul(priceLP).div(priceCo2);
        _amount = _amount.mul(percentProfit).div(10000);

        _stake[msg.sender].received = _stake[msg.sender].received.add(_amount);
        _stake[msg.sender].timestampEnd = block.timestamp;

        _amount = _amount
            .mul(
                100 -
                    integerDivision(
                        (block.timestamp - timeClaim),
                        secentSubProfit
                    ).mul(5)
            )
            .div(100);

        tokenCs.mint(address(this), _amount);
        token_co2.safeTransfer(msg.sender, _amount);

        address ref1 = addCmmBrand((_amount * 20) / 100, msg.sender);
        address ref2 = addCmmBrand((_amount * 15) / 100, ref1);
        address ref3 = addCmmBrand((_amount * 10) / 100, ref2);
        address ref4 = addCmmBrand((_amount * 5) / 100, ref3);
        address ref5 = addCmmBrand((_amount * 5) / 100, ref4);
        address ref6 = addCmmBrand((_amount * 10) / 100, ref5);
        address ref7 = addCmmBrand((_amount * 15) / 100, ref6);
        addCmmBrand((_amount * 20) / 100, ref7);
    }

    function withdrawCommission() public payable {
        require(feeClaimCommission == msg.value, "not fee");
        tokenCs.mint(address(this), _stake[msg.sender].compounding);
        token_co2.safeTransfer(msg.sender, _stake[msg.sender].compounding);
        _stake[msg.sender].compounding = 0;
    }

    function addCmmBrand(uint256 amounts, address add)
        internal
        returns (address)
    {
        address ref = getRefValue(add);
        if (
            ref != 0x0000000000000000000000000000000000000000 &&
            _stake[ref].amount > 0
        ) {
            _stake[ref].compounding += amounts;
        }
        return ref;
    }

    function integerDivision(uint256 numerator, uint256 denominator)
        public
        pure
        returns (uint256)
    {
        uint256 result = numerator / denominator;
        return result;
    }

    function withdrawCoin() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawErc20(IERC20 _token) public onlyOwner {
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }
}