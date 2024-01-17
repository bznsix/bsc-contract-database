// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**w
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` amount of tokens of type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the value of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155BatchReceived} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
}

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

interface INanoGen is IERC1155 {
    function balanceOf(address account,uint256 id) external view returns (uint256);
    function burn(address from, uint256 id, uint256 amount) external;
}

interface INTCoin is IERC20 {
    function burn(uint256 amount) external;
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

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

contract PledgeNano is Ownable, ReentrancyGuard {

    event NtTokenClaimed(address indexed player, uint256 indexed stakeId, uint256 amount);
    event NanoStakingEvent(address indexed player,uint256 indexed amount);
    event BindEvent(address indexed parent, address indexed child,uint256 indexed time);
    event AllClaimed(address indexed player, uint256 totalClaimedAmount);

    INanoGen public nanoGenContract;
    IERC20 public busdContract;
    IERC20 public ntCoinContract;

    struct LockInfo {
        uint256 stakeId;
        address player;
        uint256 ntAmounts;
        uint256 releaseStartTime;
        uint256 releaseEndTime;
        uint256 dailyReleaseAmount;
        uint256 norelease;
        uint256 hasreleaseall;
        uint256 waitforclaim;
        uint256 hasclaimallamount;
        uint256 speedCount;
    }

    struct ChildInfo {
        address child;
        uint256 bindTime;
    }

    struct ClaimInfo {
        uint256 claimedAmount;
        uint256 claimedTimestamp;
    }

    error ParameterError(uint256 arg,string message);
    error ErrorMsg(string message);

    uint256 private constant lockDurationTime = 300 days; 
    uint256 public constant lockDuration = 300; 
    uint256 public constant releaseNtTokenPerDay = 33e16; 
    uint256 public constant releaseInterval = 1 days; 

    uint256 constant fixSpeedAmount = 10 * 10**18;

    mapping(address=>mapping(uint256=>LockInfo)) public stakes;
    mapping(address => uint256) public userStakeIds;
    mapping(address => address[]) public parentToChilds;
    mapping(address => address) public childToParent;
    mapping(address=>mapping(address=>uint256)) public pcTime;
    mapping(address => bool) public hasParent;
    mapping(address=>bool) public isStaked;
    mapping(address => uint256[]) public accountHasStakeIdAmounts;
    mapping(address=>mapping(address=>bool)) public pchasbindornot;
    mapping(address => ClaimInfo[]) public userClaimInfo;
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public isSpeedCountMarked;

    constructor(
        address _ntCoinContract,
        address _busdContract
    ) Ownable(msg.sender) {
        ntCoinContract = IERC20(_ntCoinContract);
        busdContract = IERC20(_busdContract);
    }

    function NanoStaking(uint256 _amount) external nonReentrant {
        if (_amount == 0) {
            revert ParameterError(_amount, "Stake amount must be greater than 0");
        }

        if(nanoGenContract.balanceOf(msg.sender, 0) < 1) {
            revert ErrorMsg("You must own at least 1 Nano token with ID 0");
        }

        uint256 ntTokenAmount = _amount * 100 * 10**18;

        nanoGenContract.burn(msg.sender, 0, _amount);

        userStakeIds[msg.sender]++;
        uint256 stakeId = userStakeIds[msg.sender];

        LockInfo memory newLockInfo = stakes[msg.sender][stakeId];

        newLockInfo = LockInfo({
            stakeId: stakeId,
            player: msg.sender,
            ntAmounts: ntTokenAmount,
            releaseStartTime: block.timestamp,
            releaseEndTime: block.timestamp + lockDurationTime,
            dailyReleaseAmount: releaseNtTokenPerDay,
            norelease: ntTokenAmount,
            hasreleaseall: 0,
            waitforclaim: 0,
            hasclaimallamount: 0,
            speedCount: 0
            });

        stakes[msg.sender][stakeId] = newLockInfo;

        accountHasStakeIdAmounts[msg.sender].push(stakeId);

        isStaked[msg.sender] = true;

        accumulateRealease2(msg.sender, stakeId);

        speedForParent(_amount);

        emit NanoStakingEvent(msg.sender,_amount);

    }

     function speedForParent(uint256 _amount) private {
        address _parent = getParentByChild(msg.sender);

        if (hasParent[msg.sender] == true && isStaked[_parent] == true) {
            uint256[] memory parentStakeIds = accountHasStakeIdAmounts[_parent];
            bool accelerateParent = false; 

            for (uint256 i = 0; i < parentStakeIds.length; i++) {
                uint256 parentStakeId = parentStakeIds[i];
                
                LockInfo storage parentLock = stakes[_parent][parentStakeId];

                uint256 totalSpeedCount = parentLock.speedCount + _amount;
                uint256 canSpeedCount = parentLock.ntAmounts / fixSpeedAmount;

                (,,,,,,uint256 norelease,,,,) = getUserStakeInfo(_parent, parentStakeId);

                if (norelease > 0) {
                    if (norelease >= fixSpeedAmount * _amount) {
                        parentLock.hasreleaseall += fixSpeedAmount * _amount;
                        parentLock.norelease = parentLock.ntAmounts - parentLock.hasreleaseall;
                    } else {
                        parentLock.hasreleaseall = parentLock.norelease;
                        parentLock.norelease = 0;
                    }
                    
                    if(totalSpeedCount > canSpeedCount) {
                        parentLock.speedCount = canSpeedCount;
                    }else {
                        parentLock.speedCount += _amount;
                    }

                    isSpeedCountMarked[_parent][parentStakeId][parentLock.speedCount] = true;
                    accelerateParent = true;
                    break;
                }
            }
        }      
    }

     function accumulateRealease2(address _player, uint256 _stakeId) public view returns(uint256) {
        LockInfo storage userLockInfo = stakes[_player][_stakeId];
        uint256 daysPassed = (block.timestamp - userLockInfo.releaseStartTime) / releaseInterval;
        uint256 accumulatedRelease = 0;

        if (daysPassed < lockDuration && userLockInfo.norelease >= fixSpeedAmount) {
            accumulatedRelease = daysPassed * releaseNtTokenPerDay * userLockInfo.ntAmounts / 100 / 10**18 + userLockInfo.speedCount * fixSpeedAmount;
        }

        if(daysPassed < lockDuration && userLockInfo.norelease < fixSpeedAmount && isSpeedCountMarked[_player][_stakeId][userLockInfo.speedCount] == false) {
            accumulatedRelease = daysPassed * releaseNtTokenPerDay * userLockInfo.ntAmounts / 100 / 10**18;
        }

        if(daysPassed < lockDuration && userLockInfo.norelease < fixSpeedAmount && isSpeedCountMarked[_player][_stakeId][userLockInfo.speedCount] == true) {
            accumulatedRelease = userLockInfo.ntAmounts;
        }

        accumulatedRelease = min(accumulatedRelease, userLockInfo.ntAmounts);

        if(daysPassed >= lockDuration) {
            accumulatedRelease = userLockInfo.ntAmounts;
        }

        return accumulatedRelease;
    }

    function cycle(address _player, uint256 _stakeId) public view returns(uint256) {
        LockInfo storage lock = stakes[_player][_stakeId];

        uint256 daysPassed = (block.timestamp - lock.releaseStartTime) / releaseInterval;

        return daysPassed;
    }

    function claimNtToken() external nonReentrant {
        uint256[] storage stakeIds = accountHasStakeIdAmounts[msg.sender];

        if(getAllStakeidsAmounts(msg.sender) <= 0){
            revert ErrorMsg("you don't have enough nt token to claim");
        }

        uint256 totalClaimedAmount = 0;

        for (uint256 i = 0; i < stakeIds.length; i++) {
            uint256 stakeId = stakeIds[i];
            LockInfo storage lock = stakes[msg.sender][stakeId];

            if(lock.player != msg.sender) {
                revert ErrorMsg("You can only claim for your own stakes");
            }

            (,,,,,,,,uint256 waitforclaim,,) = getUserStakeInfo(msg.sender,stakeId);

            if (waitforclaim > 0) {
                uint256 claimableAmount = waitforclaim;

                ntCoinContract.transfer(msg.sender, claimableAmount);

                lock.hasclaimallamount += claimableAmount;
                lock.waitforclaim = 0;

                totalClaimedAmount += claimableAmount;
            }
        }

        if (totalClaimedAmount == 0) {
            revert ErrorMsg("There are no nt tokens to claim");
        }

        userClaimInfo[msg.sender].push(ClaimInfo(totalClaimedAmount, block.timestamp));

        emit AllClaimed(msg.sender, totalClaimedAmount);
    }

    function bind(address _parent, address _child) external nonReentrant {

        if(msg.sender != _child) {
            revert ErrorMsg("Only the child can call this method");
        }

        if(_parent == _child) {
            revert ErrorMsg("Parent and child cannot be the same address");
        }

        if(_parent == address(0x0) || _child == address(0x0)) {
            revert ErrorMsg("account isn't zero address");
        }

        if(hasParent[_child] == true) {
            revert ErrorMsg("_child only had one parent just");
        }

        if(pchasbindornot[_parent][_child] == true || pchasbindornot[_child][_parent] == true) {
            revert ErrorMsg("these two accounts had binded before");
        }

        address[] storage children = parentToChilds[_parent];

        for (uint256 i = 0; i < children.length; i++) {
            if(children[i] == _child) {
                revert ErrorMsg("Child already exists in parent's array");
            }
        }

        parentToChilds[_parent].push(_child);

        childToParent[_child] = _parent;

        hasParent[_child] = true;

        pchasbindornot[_parent][_child] = true;
        pchasbindornot[_child][_parent] = true;

        uint bindTime = block.timestamp;

        pcTime[_parent][_child] = bindTime;

        emit BindEvent(_parent, _child, bindTime);
    }

    function getUserStakeInfo(address _user, uint256 _stakeId) public view returns (
        uint256 stakeId,
        address player,
        uint256 ntAmounts,
        uint256 releaseStartTime,
        uint256 releaseEndTime,
        uint256 dailyReleaseAmount,
        uint256 norelease,
        uint256 hasreleaseall,
        uint256 waitforclaim,
        uint256 hasclaimallamount,
        uint256 speedCount
    ) {
        if (_stakeId <= 0) {
            revert ParameterError(_stakeId, "Invalid stake ID");
        }

        LockInfo storage userLockInfo = stakes[_user][_stakeId];

        uint256 accumulatedRelease = accumulateRealease2(_user, _stakeId);

        return (
            userLockInfo.stakeId,
            userLockInfo.player,
            userLockInfo.ntAmounts,
            userLockInfo.releaseStartTime,
            userLockInfo.releaseEndTime,
            userLockInfo.dailyReleaseAmount,
            userLockInfo.ntAmounts - accumulatedRelease,
            accumulatedRelease,
            accumulatedRelease - userLockInfo.hasclaimallamount,
            userLockInfo.hasclaimallamount,
            userLockInfo.speedCount
        );
    }

    function getAllStakeIdsByAddress(address _address) public view returns(uint256[] memory) {
        return accountHasStakeIdAmounts[_address];
    }

    function getAllStakeidsAmounts(address _address) public view returns(uint256) {
        uint256 totalAmount = 0;
        uint256[] memory stakeIds = accountHasStakeIdAmounts[_address];
        for (uint256 i = 0; i < stakeIds.length; i++) {
            uint256 stakeId = stakeIds[i];
            
            (,,uint256 ntAmounts,,,,,,,,) = getUserStakeInfo(_address,stakeId);
            uint256 ntAmounts_res = ntAmounts / 100 / 10**18;
            totalAmount += ntAmounts_res;
        }
        return totalAmount;
    }

    function getAllChildsByParent(address _parent) external view returns (ChildInfo[] memory childrenInfo) {
        address[] storage childAddresses = parentToChilds[_parent];
        ChildInfo[] memory childrenInfoArray = new ChildInfo[](childAddresses.length);

        for (uint256 i = 0; i < childAddresses.length; i++) {
            address child = childAddresses[i];
            uint256 bindTime = pcTime[_parent][child];
            childrenInfoArray[i] = ChildInfo(child, bindTime);
        }
        return childrenInfoArray;
    }

    function getParentByChild(address _child) public view returns(address) {
        return childToParent[_child];
    }

    function getTotalHasReleaseAllAmount(address user) public view returns (uint256) {
        uint256 totalAmount = 0;
        uint256[] memory stakeIds = accountHasStakeIdAmounts[user];

        for (uint256 i = 0; i < stakeIds.length; i++) {
            uint256 stakeId = stakeIds[i];
            (,,,,,,,uint256 hasreleaseall,,,) = getUserStakeInfo(user,stakeId);
            totalAmount += hasreleaseall;
        }

        return totalAmount;
    }

    function getTotalWaitforclaimAmount(address user) public view returns (uint256) {
        uint256 totalAmount = 0;
        uint256[] memory stakeIds = accountHasStakeIdAmounts[user];

        for (uint256 i = 0; i < stakeIds.length; i++) {
            uint256 stakeId = stakeIds[i];
            (,,,,,,,,uint256 waitforclaim,,) = getUserStakeInfo(user,stakeId);
            totalAmount += waitforclaim;
        }

        return totalAmount;
    }

    function getTotalhasclaimallAmount(address user) public view returns (uint256) {
        uint256 totalAmount = 0;
        uint256[] memory stakeIds = accountHasStakeIdAmounts[user];

        for (uint256 i = 0; i < stakeIds.length; i++) {
            uint256 stakeId = stakeIds[i];
            (,,,,,,,,,uint256 hasclaimallamount,) = getUserStakeInfo(user,stakeId);
            totalAmount += hasclaimallamount;
        }

        return totalAmount;
    }

    function getSpeedCountByAddress(address user) public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory stakeIds = accountHasStakeIdAmounts[user];
        uint256[] memory speedCounts = new uint256[](stakeIds.length);

        for (uint256 i = 0; i < stakeIds.length; i++) {
            uint256 stakeId = stakeIds[i];
            (,,,,,,,,,,uint256 speedCount) = getUserStakeInfo(user, stakeId);
            speedCounts[i] = speedCount;
        }

        return (stakeIds, speedCounts);
    }

    function getUserClaimInfo(address _user) external view returns (ClaimInfo[] memory) {
        return userClaimInfo[_user];
    }

    function withdrawTokens(uint256 _amount) external nonReentrant onlyOwner {
        ntCoinContract.transfer(msg.sender, _amount);
    }

    function emergencyWithdraw() external nonReentrant onlyOwner {
        ntCoinContract.transfer(msg.sender,ntCoinContract.balanceOf(address(this)));
    }

    function setNanoGenContract(address _nanoGenContract) external nonReentrant onlyOwner {
        nanoGenContract = INanoGen(_nanoGenContract);
    }

    function setNTCoinContract(address _ntCoinContract) external nonReentrant onlyOwner {
        ntCoinContract = INTCoin(_ntCoinContract);
    }

    function setBusdContract(address _busdContract) external nonReentrant onlyOwner {
        busdContract = IERC20(_busdContract);
    }

    function isHasParent(address user) public view returns(bool) {
        return hasParent[user];
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

}