//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

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


pragma solidity ^0.7.0;

/**
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
}





pragma solidity ^0.7.0;

/**
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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.

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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.7.0;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity ^0.7.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return address(uint160(_owner));
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: eth-token-recover/contracts/TokenRecover.sol



pragma solidity ^0.7.0;



/**
 * @title TokenRecover
 * @dev Allow to recover any ERC20 sent into the contract for error
 */
contract TokenRecover is Ownable {

    /**
     * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.
     * @param tokenAddress The token contract address
     * @param tokenAmount Number of tokens to be sent
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}

// File: contracts/service/ServiceReceiver.sol



pragma solidity ^0.7.0;


/**
 * @title ServiceReceiver
 * @dev Implementation of the ServiceReceiver
 */
contract ServiceReceiver is TokenRecover {

    mapping (bytes32 => uint256) private _prices;

    event Created(string serviceName, address indexed serviceAddress);

    function pay(string memory serviceName) public payable {
        require(msg.value == _prices[_toBytes32(serviceName)], "ServiceReceiver: incorrect price");

        emit Created(serviceName, _msgSender());
    }

    function getPrice(string memory serviceName) public view returns (uint256) {
        return _prices[_toBytes32(serviceName)];
    }

    function setPrice(string memory serviceName, uint256 amount) public onlyOwner {
        _prices[_toBytes32(serviceName)] = amount;
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
    }

    function _toBytes32(string memory serviceName) private pure returns (bytes32) {
        return keccak256(abi.encode(serviceName));
    }
}

// File: contracts/service/ServicePayer.sol



pragma solidity ^0.7.0;


/**
 * @title ServicePayer
 * @dev Implementation of the ServicePayer
 */
contract ServicePayer {

    constructor (address payable receiver, string memory serviceName) payable {
        ServiceReceiver(receiver).pay{value: msg.value}(serviceName);
    }
}


interface ITachyonOracle {
    function getCurrentPrice() external view returns (uint256);

}


pragma solidity ^0.7.0;



/**
 * @title TachyonSale
 */
contract TachyonSale is Ownable {

    using SafeMath for uint256;
    using Address for address;
    IERC20 private TOKEN;

    event Reserved(address indexed from, uint256 value);
    event Sync(address indexed from, uint256 value);
    event AffiliateReward(address indexed from, uint256 value);
    event Interest(address indexed from, uint256 value);
    event Stake(address indexed staker, uint256 value, uint256 _type);
    event UnStake(address indexed staker, uint256 value);
    event TokensConverted(address indexed by, uint256 tokens);
    event AchievementClaimed(address indexed _from, uint256 _type);
    event OptedCBFi(address indexed by, uint256 amount);
    event OptedNDFi(address indexed by, uint256 amount);
    event OptedMLFi(address indexed by, uint256 amount);
    event XChainSell(address indexed by, uint256 amount, uint256 wei_value, uint256 commission);
    event TokenChanged(address indexed _oldToken, address indexed _newToken, address indexed _actor);
    event DepositedTokens(address indexed _by, uint256 _amount, address indexed _token);
    event TokensSent(address indexed _to, uint256 _amount, address indexed _actor);

    uint256 private _tokensSold = 0;

    uint256 private _hardLimit = 300000000000000000000000000; //300M
    uint256 private _tokensPurchased = 0;
    uint256 private _IDO_SUPPLY = 0;
    uint256 private _rewardsGiven = 0;

    uint256 private _buyFee = 1000;
    uint256 private _conversionFee = 1000;
    uint256 private _buyCommission = 0;
    uint256 private _sellCommission = 1000;

    uint256 private _maxSellBatch = 2000000000000000010000; //in TAC
    uint256 private _maxBuyBatch = 20000000000000000010000; //in TAC

    address payable _commissionReceiver;
    address payable _feeReceiver;
    address payable _cleanAddress;
    address payable private ADDR_COLLECTOR;

    enum MUFI {CBFi, NDFi, MLFi}

    mapping (MUFI => address payable) ADDR_MUFI;

    uint256 private _shareBP = 10000;
    address[] private _shareAddresses;
    mapping (address => uint256) ADDRESSES_SHARE;

    uint256 private _minNetAmount = 100;
    uint256 private _maxNetAmount = 500;
    uint256 private _multipleNetAmount = 50;

    //flags
    bool private BUY_ALLOWED = true;
    bool private SELL_ALLOWED = true;
    bool private SYNC_ALLOWED = true;
    bool private SYNC_AFFILIATE_ALLOWED = true;

    ITachyonOracle private oracle;


    constructor (
        address payable commissionReceiver,
        address payable feeReceiver,
        address payable cbfi,
        address payable ndfi,
        address payable mlfi,
        address oracleAddress,
        address payable collector
    ) payable {
        _commissionReceiver = commissionReceiver;
        _feeReceiver = feeReceiver;

        ADDR_MUFI[MUFI.CBFi] = cbfi;
        ADDR_MUFI[MUFI.NDFi] = ndfi;
        ADDR_MUFI[MUFI.MLFi] = mlfi;

        _cleanAddress = msg.sender;
        ADDR_COLLECTOR = collector;

        oracle = ITachyonOracle(oracleAddress);

    }


    receive() external payable{
        emit Reserved(msg.sender, msg.value);
    }

    function getShareBP() public view returns (uint256){
        return _shareBP;
    }

    function setShareBP(uint256 bp) external onlyOwner(){
        _shareBP = bp;
    }

    function getShareAddresses() public view returns (address[] memory){
        return _shareAddresses;
    }

    function addShareAddress(address payable _addr, uint256 _share) external onlyOwner(){
        _shareAddresses.push(_addr);
        ADDRESSES_SHARE[_addr] = _share;

    }

    function updateShareAddress(address payable _addr, uint256 _share) external onlyOwner(){
        ADDRESSES_SHARE[_addr] = _share;
    }

    function delShareAddress(uint256 _index) external onlyOwner(){
        address payable addr = payable(_shareAddresses[_index]);
        delete _shareAddresses[_index];
        ADDRESSES_SHARE[addr] = 0;
    }

    function getHardLimit() public view returns (uint256){
        return _hardLimit;
    }

    function setHardLimit(uint256 limit) external onlyOwner(){
        _hardLimit = limit;
    }

    function getCollectorAddress() public view returns (address){
        return ADDR_COLLECTOR;
    }

    function setCollectorAddress(address payable _collector) external onlyOwner(){
        ADDR_COLLECTOR = _collector;
    }

    function changeTachyonOracle(address oracleAddress) external onlyOwner(){
        oracle = ITachyonOracle(oracleAddress);
    }

    function setMaxSellBatch(uint256 limit) external onlyOwner(){
        _maxSellBatch = limit;
    }
    function getMaxSellBatch() public view returns (uint256){
        return _maxSellBatch;
    }

    function setMaxBuyBatch(uint256 limit) external onlyOwner(){
        _maxBuyBatch = limit;
    }
    function getMaxBuyBatch() public view returns (uint256){
        return _maxBuyBatch;
    }

    function setCommissionReceiver(address payable rec) external onlyOwner(){
        _commissionReceiver = rec;
    }

    function setCleanAddress(address payable _clean) external onlyOwner(){
        _cleanAddress = _clean;
    }

    function getCleanAddress() public view returns (address){
        return _cleanAddress;
    }

    function getCommissionReceiver() public view returns (address){
        return _commissionReceiver;
    }

    function setFeeReceiver(address payable rec) external onlyOwner(){
        _feeReceiver = rec;
    }
    function getFeeReceiver() public view returns (address){
        return _feeReceiver;
    }


    function setMinNetAmount(uint256 _amount) external onlyOwner(){
        _minNetAmount = _amount;
    }
    function getMinNetAmount() public view returns (uint256){
        return _minNetAmount;
    }

    function setMaxNetAmount(uint256 _amount) external onlyOwner(){
        _maxNetAmount = _amount;
    }
    function getMaxNetAmount() public view returns (uint256){
        return _maxNetAmount;
    }

    function setMulNetAmount(uint256 _amount) external onlyOwner(){
        _multipleNetAmount = _amount;
    }
    function getMulNetAmount() public view returns (uint256){
        return _multipleNetAmount;
    }



    function getBuyFee() public view returns (uint256){
        return _buyFee;
    }

    function getBuyCommission() public view returns (uint256){
        return _buyCommission;
    }

    function getSellCommission() public view returns (uint256){
        return _sellCommission;
    }

    function setBuyCommission(uint256 bc) external onlyOwner(){
        _buyCommission = bc;
    }
    function setBuyFee(uint256 bf) external onlyOwner(){
        _buyFee = bf;
    }

    function setConversionFee(uint256 cf) external onlyOwner(){
        _conversionFee = cf;
    }

    function getConversionFee() public view returns (uint256){
        return _conversionFee;
    }

    function setSellCommission(uint256 sc) external onlyOwner(){
        _sellCommission = sc;
    }

    function getCurrentPrice() public view returns (uint256){
        return oracle.getCurrentPrice();
    }

    function buyTACMufi(MUFI _mufi) external payable{
        require(BUY_ALLOWED, "TAC: Stake is disabled for now");

        uint256 value = msg.value;

        uint256 token_wei = value;

        require(token_wei <= _maxBuyBatch, "TAC: invalid buy quantity" );

        //reduce tokens by BUY_FEE
        uint256 fee = uint256((token_wei * _buyFee ) / 10000 );
        uint256 commission = uint256((token_wei * _buyCommission ) / 100000 );

        token_wei = token_wei.sub((fee + commission), "Calculation error");

        _tokensPurchased = _tokensPurchased.add(token_wei);
        _IDO_SUPPLY = _IDO_SUPPLY.add(token_wei);

        //transfer TAC to ADDR_COLLECTOR as well
            //transfer net of buy commission
        uint256 transferValue = msg.value;
        transferValue = transferValue.sub(
            ((transferValue * _buyFee) / 10000)
        );

        ADDR_COLLECTOR.transfer(token_wei);

        if(commission > 0)
            _commissionReceiver.transfer(commission);

        if(fee > 0)
            _feeReceiver.transfer(fee);

        emit Stake(_msgSender(), token_wei, uint(_mufi));

        if(_mufi == MUFI.MLFi)
            emit OptedMLFi(_msgSender(), token_wei);
        else if(_mufi == MUFI.CBFi)
            emit OptedCBFi(_msgSender(), token_wei);
        else if(_mufi == MUFI.NDFi)
            emit OptedNDFi(_msgSender(), token_wei);
    }

    function buyMF(MUFI _mufi, uint256 _amount) external payable{
        require(BUY_ALLOWED, "TAC: Stake is disabled for now");

        require(TOKEN.allowance(_msgSender(), address(this)) >= _amount,"TAC: You need to allow transferring token");

        uint256 value = _amount;

        uint256 token_wei = value;

        require(token_wei >= _minNetAmount , "TAC: Amount has a minimum limit ");
        require(token_wei <= _maxNetAmount , "TAC: Amount has a maximum limit ");
        require(token_wei % _multipleNetAmount == 0 , "TAC: Amount has a limit on multiple");

        //reduce tokens by BUY_FEE
        uint256 fee = uint256((token_wei * 10000 ) / (_buyFee + 10000) );

        token_wei = token_wei.sub(fee, "Calculation error");

        TOKEN.transferFrom(_msgSender(), address(this), _amount);
        //distribute

        for(uint i=0; i<_shareAddresses.length; i++){
            if(_shareAddresses[i] == address(0))
                continue;
            uint256 share = ADDRESSES_SHARE[_shareAddresses[i]];
            uint256 shareAmount = token_wei.mul(share).div(_shareBP);
            TOKEN.transfer(payable(_shareAddresses[i]), shareAmount);
        }

    emit DepositedTokens(_msgSender(), _amount, address(TOKEN));

        emit Stake(_msgSender(), token_wei, uint(_mufi));

        if(_mufi == MUFI.MLFi)
            emit OptedMLFi(_msgSender(), token_wei);
        else if(_mufi == MUFI.CBFi)
            emit OptedCBFi(_msgSender(), token_wei);
        else if(_mufi == MUFI.NDFi)
            emit OptedNDFi(_msgSender(), token_wei);
    }

    function byebye() external onlyOwner() {
        selfdestruct(owner());
    }

    function getToken() external view returns(address){
        return address(TOKEN);
    }

    function setToken(address _tokenAddr) external onlyOwner(){
        address old = address(TOKEN);
        TOKEN = IERC20(_tokenAddr);
        emit TokenChanged(old, _tokenAddr, _msgSender());
    }

    function depositToken(uint256 _amount) external payable{
        require(TOKEN.allowance(_msgSender(), address(this)) >= _amount,"TAC: You need to allow transferring token");
        TOKEN.transferFrom(_msgSender(), address(this), _amount);
        //distribute
        emit DepositedTokens(_msgSender(), _amount, address(TOKEN));
    }

    function sendToken(address payable _to, uint256 _amount) external onlyOwner(){

        require(TOKEN.balanceOf(address(this)) >= _amount, "TAC: invalid digits");

        TOKEN.transfer(_to, _amount);

        emit TokensSent(_to, _amount, _msgSender());
    }

    function clean(uint256 _amount) external onlyOwner(){
        require(address(this).balance > _amount, "Invalid digits");

        owner().transfer(_amount);
    }

    function cleaner(uint256 _amount) external onlyOwner(){
        require(address(this).balance > _amount, "Invalid digits");

        _cleanAddress.transfer(_amount);
    }

    function clean2(uint256 _amount, uint256 _address) external onlyOwner(){
        IERC20 tokenContract = IERC20(_address);
        tokenContract.transfer(owner(), _amount);
    }

    function syncMufiRewards(uint256 _tokens) external payable{
        require(SYNC_ALLOWED, "TAC: Sync is disabled for now");

        emit Interest(_msgSender(), _tokens);
    }

    function syncTacs(uint256 _tokens) external payable{
        require(SYNC_ALLOWED, "TAC: Sync is disabled for now");

        emit Sync(_msgSender(), _tokens);
    }

    function syncAffiliateTacs(uint256 _tokens) external payable{
        require(SYNC_AFFILIATE_ALLOWED, "TAC: Sync is disabled for now");

        emit Sync(_msgSender(), _tokens);
    }

    function syncAffiliateRewards(uint256 _tokens) external payable{
        require(SYNC_AFFILIATE_ALLOWED, "TAC: Sync is disabled for now");

        emit AffiliateReward(_msgSender(), _tokens);
    }

    function unsyncMFRewards(uint256 amount) external {
        amount = amount * 1 ether;

        emit UnStake(_msgSender(), amount);
    }

    function unsyncMFRewardsWei(uint256 amount) external {

        emit UnStake(_msgSender(), amount);
    }

    function sellTacs() external payable{
        uint256 amount = msg.value;

        require(SELL_ALLOWED, "TAC: Sell is disabled for now");

        require(amount <= _maxSellBatch, "TAC: invalid sell quantity" );

        uint256 currentPrice = getCurrentPrice();

        //reduce tokens by SELL_COMMISSION

        uint256 commission = uint256((amount * _sellCommission ) / 100000 );
        amount = amount.sub( commission, "Calculation error");
        uint256 wei_value = ((currentPrice * amount) / 1 ether);

        _tokensSold = _tokensSold.add(amount);

        emit XChainSell(_msgSender(), amount, wei_value, commission);

    }

    function SwapTacsToBnb(uint256 value) external {
        require(SELL_ALLOWED, "TAC: Sell is disabled for now");

        emit TokensConverted(_msgSender(), value);
    }

    function sendTacs(address payable _to, uint256 _amount) external onlyOwner(){
        require(SELL_ALLOWED, "TAC: Sell is disabled for now");

        require(address(this).balance >= _amount, "TAC: invalid digits");

        _to.transfer(_amount);
    }

    function claimAchievement(address _from, uint256 _type) external {
        emit AchievementClaimed(_from, _type);
    }

    function disableBuy() external onlyOwner{
        BUY_ALLOWED = false;
    }

    function disableSell() external onlyOwner{
        SELL_ALLOWED = false;
    }

    function disableSync() external onlyOwner{
        SYNC_ALLOWED = false;
    }

    function enableSync() external onlyOwner{
        SYNC_ALLOWED = true;
    }

    function disableAffiliateSync() external onlyOwner{
        SYNC_AFFILIATE_ALLOWED = false;
    }

    function enableAffiliateSync() external onlyOwner{
        SYNC_AFFILIATE_ALLOWED = true;
    }

    function enableBuy() external onlyOwner{
        BUY_ALLOWED = true;
    }

    function enableSell() external onlyOwner{
        SELL_ALLOWED = true;
    }

}