// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

interface IStake2 {
    function onDeposited(address user, uint256 amount) external;
    function onWithdrawn(address user, uint256 amount) external;
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
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

// MasterChef is the master of ERC20 token. He can make rewardToken and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once  rewardToken is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    uint256 constant _PRECISION = 1e12;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 index; // index is the cumulative value of each share's reward.
            // See explanation below.
            //
            // We do some fancy math here. Basically, any point in time, the amount of Rewards
            // entitled to a user but is pending to be distributed is:
            //
            //   pending reward = user.amount * ( pool.accRewardPerShareIndex -  user.index)
            //
            // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
            //   1. The pool's `accRewardPerShareIndex` (and `lastRewardTime`) gets updated.
            //   2. User receives the pending reward sent to his/her address.
            //   3. User's `amount` gets updated.
            //   4. User's `index` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        address lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint256 lastRewardTime; // Last block time that Rewards distribution occurs.
        uint256 accRewardPerShareIndex; // Accumulated Rewards per share, times 1e12. See below.
        IStake2 stake2; // Stake2 contract address, will be called when deposit/withdraw.
    }
    // The block number when Reward mining starts.

    uint256 public immutable startTime;
    // The Reward TOKEN!
    ERC20 public rewardToken;
    // Reward tokens created per second.
    uint256 public rewardPerSecond;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;

    constructor(uint256 rewardPerSecond_, uint256 start_) {
        rewardPerSecond = rewardPerSecond_;
        startTime = start_;
    }

    // Deposit LP tokens to MasterChef for Reward allocation.
    function deposit(uint256 pid, uint256 amount) public payable {
        if (amount == 0) revert DEPOSIT_AMOUNT_ZERO();

        _updateReward(pid, msg.sender);

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        _transferTokenIn(pool.lpToken, amount);
        user.amount += amount;

        // call stake2 contract when deposit
        if (address(pool.stake2) != address(0)) pool.stake2.onDeposited(msg.sender, amount);

        emit Deposit(msg.sender, pid, amount, user.index);
    }

    // Deposit LP tokens to MasterChef for Reward allocation.
    // Deposit with permit for approval.
    function depositWithPermit(uint256 pid, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        ERC20(poolInfo[pid].lpToken).permit(msg.sender, address(this), amount, deadline, v, r, s);
        deposit(pid, amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 pid, uint256 amount) external {
        if (amount == 0) revert WITHDRAW_AMOUNT_ZERO();

        _updateReward(pid, msg.sender);

        UserInfo storage user = userInfo[pid][msg.sender];
        if (user.amount < amount) revert WITHDRAW_AMOUNT_TOO_LARGE();

        PoolInfo storage pool = poolInfo[pid];
        unchecked {
            user.amount -= amount;
        }
        _transferTokenOut(pool.lpToken, amount);

        // call stake2 contract when withdraw
        if (address(pool.stake2) != address(0)) pool.stake2.onWithdrawn(msg.sender, amount);

        emit Withdraw(msg.sender, pid, amount, user.index);
    }

    function claim(uint256 pid) external {
        _updateReward(pid, msg.sender);
    }

    function claimFor(uint256 pid, address user) external {
        _updateReward(pid, user);
    }

    function batchClaim(uint256[] calldata pids) external {
        for (uint256 i = 0; i < pids.length; i++) {
            _updateReward(pids[i], msg.sender);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 pid) public {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.index = 0;
        _transferTokenOut(address(pool.lpToken), amount);
        emit EmergencyWithdraw(msg.sender, pid, amount);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 pid) public {
        PoolInfo storage pool = poolInfo[pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        pool.accRewardPerShareIndex = _currentRewardPerShare(pid);
        pool.lastRewardTime = block.timestamp;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Return reward multiplier over the given _from to _to block.
    // View function to see pending Rewards on frontend.
    function pendingReward(uint256 pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[pid][_user];
        // ignore big amount
        unchecked {
            return user.amount * (_currentRewardPerShare(pid) - user.index) / _PRECISION;
        }
    }

    //********************************************************
    //****************** ADMIN FUNCTIONS *********************
    //********************************************************

    function setRewardPerSecond(uint256 rewardPerSecond_) external onlyOwner {
        massUpdatePools();
        rewardPerSecond = rewardPerSecond_;
        emit RewardPerSecondUpdated(rewardPerSecond);
    }

    // Add a new lpToken to the pool. Can only be called by the owner.
    // XXX DO NOT add the same lpToken token more than once. Rewards will be messed up if you do.
    function add(uint256 allocPoint, address lpToken, IStake2 stake2, bool withUpdate) external onlyOwner {
        if (withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        unchecked {
            totalAllocPoint += allocPoint;
        }
        poolInfo.push(
            PoolInfo({
                lpToken: lpToken,
                allocPoint: allocPoint,
                lastRewardTime: lastRewardTime,
                accRewardPerShareIndex: 0,
                stake2: stake2
            })
        );

        emit PoolUpdated(poolInfo.length - 1, allocPoint);
    }

    // Update the given pool's Reward allocation point. Can only be called by the owner.
    function set(uint256 pid, uint256 allocPoint, bool withUpdate) external onlyOwner {
        if (withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[pid].allocPoint;
        poolInfo[pid].allocPoint = allocPoint;

        unchecked {
            totalAllocPoint = totalAllocPoint - prevAllocPoint + allocPoint;
        }

        emit PoolUpdated(pid, allocPoint);
    }

    function setRewardToken(ERC20 newToken) external onlyOwner {
        rewardToken = newToken;
        emit RewardTokenUpdated(address(newToken));
    }

    //********************************************************
    //****************** INTERNAL FUNCTIONS ******************
    //********************************************************

    function _currentRewardPerShare(uint256 pid) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[pid];
        uint256 accRewardPerShareIndex = pool.accRewardPerShareIndex;
        uint256 lpSupply =
            pool.lpToken == address(0) ? address(this).balance : ERC20(pool.lpToken).balanceOf(address(this));
        if (block.timestamp > pool.lastRewardTime && lpSupply > 0) {
            // We can ignore the overflow issue, which will not happen during the continuous operation of the protocol.
            // (block.timestamp - pool.lastRewardTime)  will not cause an overflow.
            // (rewardPerSecond * pool.allocPoint) will not cause an overflow.

            uint256 index;
            unchecked {
                uint256 rewards =
                    (block.timestamp - pool.lastRewardTime) * rewardPerSecond * pool.allocPoint / totalAllocPoint / 20;

                index = rewards * _PRECISION / lpSupply;
            }
            accRewardPerShareIndex += index;
        }
        return accRewardPerShareIndex;
    }

    function _updateReward(uint256 pid, address account) private {
        // Rewards should only be sent to a staker after the pool state has been updated.
        updatePool(pid);

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][account];

        if (user.amount > 0) {
            uint256 pending = user.amount * (pool.accRewardPerShareIndex - user.index) / _PRECISION;
            // update reward index before transfer for reentrancy.
            user.index = pool.accRewardPerShareIndex;
            if (pending > 0) SafeTransferLib.safeTransfer(ERC20(rewardToken), account, pending);
        } else {
            user.index = pool.accRewardPerShareIndex;
        }
    }

    function _transferTokenIn(address token, uint256 amount) private {
        if (token == address(0)) {
            if (amount != msg.value) revert AMOUNT_IS_NOT_ENOUGH();
        } else {
            SafeTransferLib.safeTransferFrom(ERC20(token), msg.sender, address(this), amount);
        }
    }

    function _transferTokenOut(address token, uint256 amount) private {
        if (amount == 0) return;
        if (token == address(0)) {
            SafeTransferLib.safeTransferETH(msg.sender, amount);
        } else {
            SafeTransferLib.safeTransfer(ERC20(token), msg.sender, amount);
        }
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 index);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 index);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPerSecondUpdated(uint256 newRewards);
    event PoolUpdated(uint256 pid, uint256 allocPoint);
    event RewardTokenUpdated(address newToken);

    error AMOUNT_IS_NOT_ENOUGH();
    error DEPOSIT_AMOUNT_ZERO();
    error WITHDRAW_AMOUNT_TOO_LARGE();
    error WITHDRAW_AMOUNT_ZERO();
}