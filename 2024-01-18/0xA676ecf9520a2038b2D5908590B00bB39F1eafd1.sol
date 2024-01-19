// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract TokenSale is Ownable{
    // using EnumerableSet library
    using EnumerableSet for EnumerableSet.AddressSet;

    struct TokenSaleInfo{
        uint256 startTime;
        uint256 endTime;
        uint256 salePrice;
        uint256 minPurchasePerUser;
        uint256 maxPurchasePerUser;
        uint256 totalTokenSale;
        uint256 totalTokenSold;
        uint256 totalAmountRaised;
    }
    bool public isTokenSaleFinalized;

    address[] public contributors;
    address[] public founders;
    mapping(address => uint256) public founderBalances;
    uint256 public unlockTime;
    // price BNB/USDT
    uint256 public priceInBNB; // multiply 1e18

    TokenSaleInfo public tokenSaleInfo;
    mapping(address => uint256) public userTotalAmountContribution; // user => totalAmountContribution
    mapping(address => uint256) public userTotalTokenReceived; // user => totalTokenReceived
    mapping(address => bool) public isUserClaimed; // user => isUserClaimed

    // whitelist setting
    enum WhitelistOption { ENABLED, DISABLED }  // whitelist option
    WhitelistOption public whitelistOption = WhitelistOption.ENABLED; // default is enabled
    EnumerableSet.AddressSet private _whitelistAddresses; // whitelist addresses
    mapping(address => bool) public isWhitelisted; // if true, then whitelisted

    IERC20 public saleToken;

    // event
    event StartSale(uint256 totalTokenSale);
    event BuyToken(address indexed user, uint256 indexed amount);
    event ClaimToken(address indexed user, uint256 indexed amount);
    event Finalize(uint256 tokensSold, uint256 amountRaised);

    // error
    error InvalidTime(uint256 timestamp);
    error InvalidAmount(uint256 amount);
    error BuyExceed(uint256 amount);
    error NoWhitelistAddress(address userAddr);
    error SaleEnded();
    error WaitForOwnerConfirmation();
    error UserClaimed(address userAddr);
    error NoTokenToClaim(address userAddr);

    constructor(address _saleToken) Ownable(msg.sender){
        saleToken = IERC20(_saleToken);
        priceInBNB = 320 * 1e18;
        unlockTime = block.timestamp + 90 days;
    }

    function startSale(
        uint256 _totalTokenSale,
        uint256 _minPurchasePerUser,
        uint256 _maxPurchasePerUser,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _salePrice, // price was set in stable coin
        address[] calldata _founders,
        uint256 _founderTokenAmount
    ) external onlyOwner{
        if(_startTime > _endTime) revert InvalidTime(_startTime);
        tokenSaleInfo = TokenSaleInfo({
            startTime: _startTime,
            endTime: _endTime,
            salePrice: _salePrice,
            minPurchasePerUser: _minPurchasePerUser,
            maxPurchasePerUser: _maxPurchasePerUser,
            totalTokenSale: _totalTokenSale,
            totalTokenSold: 0,
            totalAmountRaised: 0
        });
        uint256 _amountOfFounders = 0;
        for(uint256 i = 0; i < _founders.length; i++){
            founders.push(_founders[i]);
            founderBalances[_founders[i]] = _founderTokenAmount;
            _amountOfFounders += _founderTokenAmount;
        }
        uint256 totalTokenInPool = _totalTokenSale + _amountOfFounders;
        // transfer sale token to the sale pool
        saleToken.transferFrom(msg.sender, address(this), totalTokenInPool);
        emit StartSale(_totalTokenSale);
    }

    // buy tokens
    function buyToken() public payable checkTimeValid returns(bool){
        address _user = msg.sender;
        uint256 _amount = msg.value;
        _buy(_user, _amount);
        return true;
    }

    function finalize() public whenSaleNotFinalized onlyOwner{
        isTokenSaleFinalized = true;
        emit Finalize(tokenSaleInfo.totalTokenSold, tokenSaleInfo.totalAmountRaised);
    }

    function claimToken() public whenSaleFinalized{
        address _user = msg.sender;
        uint256 _amount = userTotalTokenReceived[_user];
        _claim(_user, _amount);
    }

    function claimTokenByFounder() public whenSaleFinalized{
        address _user = msg.sender;
        _founderClaim(_user);
    }

    // set price in BNB
    function setPriceInBNB(uint256 _priceInBNB) external onlyOwner{
        priceInBNB = _priceInBNB; // 1 BNB = 320 USDT
    }

    // set time round
    function setTime(uint256 _startTime, uint256 _endTime) external onlyOwner{
        tokenSaleInfo.startTime = _startTime;
        tokenSaleInfo.endTime = _endTime;
    }

    // set unlock time
    function setUnlockTime(uint256 _unlockTime) external onlyOwner{
        unlockTime = _unlockTime;
    }

    // set whitelist option
    function setWhitelistOption(WhitelistOption _whitelistOption) external onlyOwner{
        whitelistOption = _whitelistOption;
    }

    // set Buy limit per user
    function setBuyLimitPerUser(uint256 _minPurchasePerUser, uint256 _maxPurchasePerUser) external onlyOwner{
        tokenSaleInfo.minPurchasePerUser = _minPurchasePerUser;
        tokenSaleInfo.maxPurchasePerUser = _maxPurchasePerUser;
    }

    // set price round
    function setSalePrice(uint256 _salePrice) external onlyOwner{
        tokenSaleInfo.salePrice = _salePrice;
    }

    // set sale token address
    function setSaleToken(address _saleToken) external onlyOwner{
        saleToken = IERC20(_saleToken);
    }

    function setSaleStatus(bool _isTokenSaleFinalized) external onlyOwner{
        isTokenSaleFinalized = _isTokenSaleFinalized;
    }

    // add users to whitelist
    function addWhitelistAddresses(address[] calldata _users) external onlyOwner{
        for(uint256 i = 0; i < _users.length; i++){
            if(!isWhitelisted[_users[i]]){
                _whitelistAddresses.add(_users[i]);
                isWhitelisted[_users[i]] = true;
            }
        }
    }
    // remove users from whitelist
    function removeWhitelistAddresses(address[] calldata _users) external onlyOwner{
        for(uint256 i = 0; i < _users.length; i++){
            if(isWhitelisted[_users[i]]){
                _whitelistAddresses.remove(_users[i]);
                isWhitelisted[_users[i]] = false;
            }
        }
    }

    // get whitelist addresses
    function getWhitelistAddresses() public view returns(address[] memory){
        return _whitelistAddresses.values();
    }

    // get number of contributors
    function getNumOfContributors() public view returns(uint256){
        return contributors.length;
    }

    // get contributor infor by address
    function getContributorInfo(address _user) public view returns(uint256, uint256){
        return (userTotalAmountContribution[_user], userTotalTokenReceived[_user]);
    }

    // get token sale left
    function tokenSaleLeft() public view returns(uint256){
        return tokenSaleInfo.totalTokenSale - tokenSaleInfo.totalTokenSold;
    }

    // get Amount to buy token left
    function amountToBuyTokenLeft() public view returns(uint256){
        uint256 tokenLeft = tokenSaleLeft();
        uint256 amountInStableCoin = tokenLeft * tokenSaleInfo.salePrice / 1e18;
        return amountInStableCoin * 1e18 / priceInBNB;
    }

    // withdraw eth
    function withdrawETH(address admin) external onlyOwner{
        payable(admin).transfer(address(this).balance);
    }
    // withdraw token
    function withdrawTokenERC20(address token, address admin) external onlyOwner{
        IERC20(token).transfer(admin, IERC20(token).balanceOf(address(this)));
    }

    // receive fallback
    receive() external payable{
        require(msg.value > 0, "Invalid amount");
    }

    function _claim(address _user, uint256 _amount) private {
        if(isUserClaimed[_user]) revert UserClaimed(_user);
        if(_amount == 0) revert NoTokenToClaim(_user);
        isUserClaimed[_user] = true;
        saleToken.transfer(_user, _amount);
        emit ClaimToken(_user, _amount);
    }

    function _buy(address _user, uint256 _amount) private {
        // check valid to buy token
        _eligibleToBuyToken(_user, _amount);
        // update contributor
        if(userTotalAmountContribution[_user] == 0){
            contributors.push(_user);
        }
        // calculate token amount
        uint256 tokenSold = _calculateTokenAmount(_amount);
        if(tokenSold + tokenSaleInfo.totalTokenSold > tokenSaleInfo.totalTokenSale) revert InvalidAmount(_amount);
        // update token sale info
        tokenSaleInfo.totalTokenSold += tokenSold;
        tokenSaleInfo.totalAmountRaised += _amount;
        // update user info
        userTotalAmountContribution[_user] += _amount;
        userTotalTokenReceived[_user] += tokenSold;

        emit BuyToken(_user, _amount);
    }

    function _founderClaim(address _user)  private {
        if(block.timestamp < unlockTime) revert InvalidTime(block.timestamp);
        uint256 amount = founderBalances[_user];
        if(amount == 0) revert NoTokenToClaim(_user);
        founderBalances[_user] = 0;
        saleToken.transfer(_user, amount);
        emit ClaimToken(_user, amount);
    }

    function _calculateTokenAmount(uint256 _amount) internal view returns(uint256 tokenAmount){
        uint256 amountInStableCoin = _amount * priceInBNB;
        tokenAmount = amountInStableCoin / tokenSaleInfo.salePrice;
    }

    // check valid to buy token
    function _eligibleToBuyToken(address _user, uint256 _amount) internal view{
        // check valid amount
        if(_amount == 0) revert InvalidAmount(_amount);
        uint256 totalAmountUserContribution = userTotalAmountContribution[_user] + _amount;
        if(totalAmountUserContribution < tokenSaleInfo.minPurchasePerUser
            || totalAmountUserContribution > tokenSaleInfo.maxPurchasePerUser) revert BuyExceed(totalAmountUserContribution);
        // check whitelist is enabled
        if(whitelistOption == WhitelistOption.ENABLED){
            if(!isWhitelisted[_user]) revert NoWhitelistAddress(_user);
        }
    }

    modifier checkTimeValid(){
        if(block.timestamp < tokenSaleInfo.startTime || block.timestamp > tokenSaleInfo.endTime) revert InvalidTime(block.timestamp);
        _;
    }

    modifier whenSaleNotFinalized(){
        if(block.timestamp < tokenSaleInfo.endTime) revert InvalidTime(block.timestamp);
        if(isTokenSaleFinalized) revert SaleEnded();
        _;
    }

    modifier whenSaleFinalized(){
        if(!isTokenSaleFinalized) revert WaitForOwnerConfirmation();
        _;
    }

}