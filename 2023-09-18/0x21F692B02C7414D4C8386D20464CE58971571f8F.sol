// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.0/security/Pausable.sol";

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";


interface IBiBiShareHolder {

    function getBanlance() external view returns(uint256);

    function addBonus(uint256 bonusAmount) external;

    function withdrawReward(address to, uint256 amount) external;

}

contract BiBiDAO is Ownable {
    
    event BiBiDAOAdded(address indexed bibiDAO);

    event BiBiDAORemoved(address indexed bibiDAO);

    mapping(address => bool) public bibiDAOMap;

    function addBiBiDAO(address bibiDAO) external onlyOwner {
        bibiDAOMap[bibiDAO] = true;
        emit BiBiDAOAdded(bibiDAO);
    }

    function removeBiBiDAO(address bibiDAO) external onlyOwner {
        delete bibiDAOMap[bibiDAO];
        emit BiBiDAORemoved(bibiDAO);
    }

    modifier onlyBiBiDAO() {
        require(bibiDAOMap[_msgSender()], "BiBiDAO: caller is not the BiBiDAO");
        _;
    }
}

interface IBiBiToMercuryFee {

    function getBuyPriceAfterFee(uint256 price, uint256 supply, uint256 baseAmount) external pure returns (uint256 protocolFee, uint256 subjectFee, uint256 totalAmount);

    function getSellPriceAfterFee(uint256 price, uint256 supply, uint256 baseAmount) external pure returns (uint256 protocolFee, uint256 subjectFee, uint256 planetShareHolderFee, uint256 totalAmount);

}

contract BiBiToMercury is BiBiDAO, Pausable{

    struct SharesData{
        address sharesSubject;
        uint256 price;
    }

    struct UserData{
        uint256 baseAmount;
        string sharesAlias;
        string profileImgUrl;
        string mediumUrl;
        string descUrl;
        SharesData[] sharesDataList;
    }

    address public token;
    uint8 public sellMinNum;
    uint256 public totalProtocolFee;
    IBiBiToMercuryFee public bibiToMercuryFee;
    IBiBiShareHolder public bibiShareHolder;

    mapping(address => uint256) public sharesSupply;
    mapping(address => UserData) public userDataMapping;


    event Trade(address trader, address subject, bool isBuy, uint256 shareAmount, uint256 amount, uint256 protocolAmount, uint256 subjectAmount, uint256 planetShareHolderAmount, uint256 supply);

    constructor(address _token, address _bibiToMercuryFee, address _bibiShareHolder) {
        token = _token;
        sellMinNum = 10;
        bibiToMercuryFee = IBiBiToMercuryFee(_bibiToMercuryFee);
        bibiShareHolder = IBiBiShareHolder(_bibiShareHolder);
    }

    function setSellMinNum(uint8 _sellMinNum) external onlyOwner {
        sellMinNum = _sellMinNum;
    }

    function setBiBiToMercuryFee(address _bibiToMercuryFee) external onlyOwner {
        bibiToMercuryFee = IBiBiToMercuryFee(_bibiToMercuryFee);
    }

    function setBiBiShareHolder(address _bibiShareHolder) external onlyOwner {
        bibiShareHolder = IBiBiShareHolder(_bibiShareHolder);
    }

    function setSharesAlias(string memory sharesAlias) external {
        require(bytes(sharesAlias).length < 11, "Mercury: SharesAlias is too long");
        userDataMapping[_msgSender()].sharesAlias = sharesAlias;
    }

    function setProfileImgUrl(string memory profileImgUrl) external {
        userDataMapping[_msgSender()].profileImgUrl = profileImgUrl;
    }

    function setMediumUrl(string memory mediumUrl) external {
        userDataMapping[_msgSender()].mediumUrl = mediumUrl;
    }

    function setDescUrl(string memory descUrl) external {
        userDataMapping[_msgSender()].descUrl = descUrl;
    }

    function getPrice(uint256 supply, address sharesSubject) public view returns (uint256) {
        return supply**2 * userDataMapping[sharesSubject].baseAmount;
    }

    function getBuyPrice(address sharesSubject) public view returns (uint256) {
        return getPrice(sharesSupply[sharesSubject], sharesSubject);
    }
    
    function getSellPrice(address sharesSubject) public view returns (uint256) {
        return getPrice(sharesSupply[sharesSubject] - 1, sharesSubject);
    }

    function getSharesSupply(address share) external view returns(uint256) {
        return sharesSupply[share];
    }

    function internalBuyShares(address sharesSubject, uint256 supply, address user, uint256 buyPrice) internal {
        uint256 price = getBuyPrice(sharesSubject);
        (uint256 protocolFee, uint256 subjectFee, uint256 totalAmount) = bibiToMercuryFee.getBuyPriceAfterFee(price, supply, userDataMapping[sharesSubject].baseAmount); 

        require(buyPrice == totalAmount, "BuyPrice error");

        TransferHelper.safeTransferFrom(token, user, address(this), totalAmount);

        userDataMapping[user].sharesDataList.push(SharesData({
            sharesSubject : sharesSubject,
            price : totalAmount
        }));
        sharesSupply[sharesSubject] += 1;
        
        totalProtocolFee += protocolFee;
        TransferHelper.safeTransfer(token, sharesSubject, subjectFee);

        supply++;
        emit Trade(user, sharesSubject, true, 1, price, protocolFee, subjectFee, 0, supply);
    }

    function initShares(uint256 baseAmount, address user) external onlyBiBiDAO {
        uint256 supply = sharesSupply[user];
        require(supply == 0, "Mercury: Supply must equal 0");

        userDataMapping[user].baseAmount = baseAmount;

        internalBuyShares(user, supply, user, 0);
    }

    function buyShares(address sharesSubject, address user, uint256 buyPrice) external onlyBiBiDAO whenNotPaused {
        uint256 supply = sharesSupply[sharesSubject];
        require(supply > 0, "Mercury: Only the shares' subject can buy the first share");

        internalBuyShares(sharesSubject, supply, user, buyPrice);
    }

    function sellShares(uint256 index, address user) external onlyBiBiDAO {
        SharesData[] storage sharesDataList = userDataMapping[user].sharesDataList;
        require(sharesDataList.length > index, "Mercury: Insufficient shares");

        SharesData memory sharesData = sharesDataList[index];
        address sharesSubject = sharesData.sharesSubject;

        uint256 supply = sharesSupply[sharesSubject];
        require(supply > 1, "Mercury: Cannot sell the last share");
        if(sharesSubject == user) {
            require(supply > sellMinNum, "Mercury: sellMinNum error");
        }

        uint256 price = getSellPrice(sharesSubject);
        (uint256 protocolFee, uint256 subjectFee, uint256 planetShareHolderFee, uint256 totalAmount) = bibiToMercuryFee.getSellPriceAfterFee(price, supply, userDataMapping[sharesSubject].baseAmount);

        sharesDataList[index] = sharesDataList[sharesDataList.length-1];
        sharesDataList.pop();
        sharesSupply[sharesSubject] -= 1;

        totalProtocolFee += protocolFee;
        TransferHelper.safeTransfer(token, sharesSubject, subjectFee);
        TransferHelper.safeTransfer(token, address(bibiShareHolder), planetShareHolderFee);
        bibiShareHolder.addBonus(planetShareHolderFee);
        TransferHelper.safeTransfer(token, user, totalAmount);

        emit Trade(user, sharesSubject, false, 1, price, protocolFee, subjectFee, planetShareHolderFee, supply - 1);
    }

    function getUserData(address user) external view returns(uint256 baseAmount, string memory sharesAlias, string memory profileImgUrl, string memory mediumUrl, string memory descUrl) {
        baseAmount = userDataMapping[user].baseAmount;
        sharesAlias = userDataMapping[user].sharesAlias;
        profileImgUrl = userDataMapping[user].profileImgUrl;
        mediumUrl = userDataMapping[user].mediumUrl;
        descUrl = userDataMapping[user].descUrl;
    }

    function getBuySharesAmount(address user) external view returns(uint256) {
        return userDataMapping[user].sharesDataList.length;
    }

    function getBuyShares(address user, uint256 start, uint256 size) external view returns(address[] memory shares, string[] memory sharesAlias, string[] memory profileImgUrlList, uint256[] memory buyPriceList, uint256[] memory sellPriceList) {
        SharesData[] memory sharesDataList = userDataMapping[user].sharesDataList;

        shares = new address[](size);
        sharesAlias = new string[](size);
        profileImgUrlList = new string[](size);
        buyPriceList = new uint256[](size);
        sellPriceList = new uint256[](size);

        uint8 index = 0;
        uint256 end = start+size;
        for(start; start<end; start++) {
            SharesData memory sharesData = sharesDataList[start];
            address sharesSubject = sharesData.sharesSubject;

            UserData memory userData = userDataMapping[sharesSubject];

            shares[index] = sharesSubject;
            sharesAlias[index] = userData.sharesAlias;
            profileImgUrlList[index] = userData.profileImgUrl;
            buyPriceList[index] = sharesData.price;
            sellPriceList[index] = getSellPrice(sharesSubject);

            index++;
        }
    }

    function queryDevBonus() public view returns(uint256) {
        return totalProtocolFee;
    }

    function withdrawDevBonus(uint256 amount) external onlyOwner {
        require(amount <= queryDevBonus(), "Mercury: Insufficient balance");
        totalProtocolFee -= amount;
        TransferHelper.safeTransfer(token, _msgSender(), amount);
    }

    function safeTransferToken(address _token, address to, uint256 value) external onlyOwner {
        require(_token != token, "Mercury: Token error");
        TransferHelper.safeTransfer(_token, to, value);
    }

    function safeTransferETH(address to, uint value) external onlyOwner {
        TransferHelper.safeTransferETH(to, value);
    }

    function pause() external virtual onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external virtual onlyOwner whenPaused {
        _unpause();
    }

}// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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
