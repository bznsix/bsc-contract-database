// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./libraries/TransferHelper.sol";
import "./common/Adminable.sol";
import "./common/ReentrancyGuard.sol";
import "./interface/IXOLE.sol";
import "./interface/IUniV2ClassPair.sol";

contract RewardDistributor is Adminable, ReentrancyGuard {
    using TransferHelper for IERC20;
    using TransferHelper for IUniV2ClassPair;

    error InvalidAmount();
    error InvalidTime();
    error InvalidPenalty();
    error InsufficientTransfersIn();
    error NotStarted();
    error Expired();
    error NotExpired();
    error AlreadyRecycled();
    error AlreadyVested();
    error IncorrectMerkleProof();
    error ExceedMax(uint256 amount);

    struct Epoch {
        bytes32 merkleRoot;
        uint256 total;
        uint256 vested;
        uint256 startTime; // vest start time
        uint256 expireTime; // vest expire time
        uint256 vestDuration; // vest duration, in seconds
        uint16 penaltyBase; // exit penalty base percentage, 2000 => 20%
        uint16 penaltyAdd; // exit penalty add percentage, 6000 => 60%
        bool recycled;
    }

    struct Reward {
        uint256 amount; // total amount to be vested
        uint256 withdrawn; // withdrawn amount by the user
        uint256 vestStartTime; // vest start time
    }

    uint256 internal constant PERCENT_DIVISOR = 10000;
    uint256 private constant WEEK = 7 * 86400;  // XOLE lock times are rounded by week
    uint256 private constant MIN_DURATION = 7 * 86400;  // 7 days
    uint256 private constant MAX_DURATION = 4 * 365 * 86400;  // 4 years

    IERC20 public immutable oleToken;
    IUniV2ClassPair public immutable pair;
    address public immutable token1;  // token1 of lp
    address public immutable xole;
    uint256 public epochIdx;
    uint256 public minXOLELockDuration; // min XOLE lock duration in seconds when converting
    uint256 public withdrawablePenalty; // the withdrawable penalty for admin

    // mapping of epochId, user to reward info
    mapping(uint256 => mapping(address => Reward)) public rewards;
    // mapping of epochId to epoch info
    mapping(uint256 => Epoch) public epochs;

    constructor(address _oleToken, address _pair, address _token1, address _xole, uint256 _minXOLELockDuration) verifyDuration(_minXOLELockDuration){
        oleToken = IERC20(_oleToken);
        pair = IUniV2ClassPair(_pair);
        token1 = _token1;
        xole = _xole;
        minXOLELockDuration = _minXOLELockDuration;
        admin = payable(msg.sender);
    }

    event VestStarted(uint256 epochId, address account, uint256 balance, uint256 vestTime);
    event Withdrawn(uint256 epochId, address account, uint256 amount, uint256 penalty);
    event ConvertedToXOLE(uint256 epochId, address account, uint256 amount);

    event EpochAdded(uint256 epochId, bytes32 merkleRoot, uint256 total, uint256 startTime, uint256 expireTime, uint256 vestDuration, uint16 penaltyBase, uint16 penaltyAdd);
    event Recycled(uint256 epochId, uint256 recycledAmount);
    event PenaltyWithdrawn(uint256 amount);

    function vest(uint256 _epochId, uint256 _balance, bytes32[] calldata _merkleProof) external {
        Epoch storage epoch = epochs[_epochId];
        if (block.timestamp < epoch.startTime) revert NotStarted();
        if (block.timestamp > epoch.expireTime) revert Expired();
        if (_balance == 0 || _balance + epoch.vested > epoch.total) revert InvalidAmount();

        Reward memory reward = rewards[_epochId][msg.sender];
        if (reward.amount > 0) revert AlreadyVested();
        if (!_verifyVest(msg.sender, epoch.merkleRoot, _balance, _merkleProof)) revert IncorrectMerkleProof();
        epoch.vested += _balance;
        rewards[_epochId][msg.sender] = Reward(_balance, 0, block.timestamp);
        emit VestStarted(_epochId, msg.sender, _balance, block.timestamp);
    }

    function withdrawMul(uint256[] calldata _epochIds) external {
        uint256 total;
        for (uint256 i = 0; i < _epochIds.length; i++) {
            total += _withdrawReward(_epochIds[i]);
        }
        oleToken.safeTransfer(msg.sender, total);
    }

    function withdraw(uint256 epochId) external {
        uint256 withdrawing = _withdrawReward(epochId);
        oleToken.safeTransfer(msg.sender, withdrawing);
    }

    function earlyExit(uint256 epochId) external {
        Reward storage reward = rewards[epochId][msg.sender];
        if (reward.amount == 0 || reward.amount == reward.withdrawn) revert InvalidAmount();
        (uint256 withdrawable, uint256 penalty) = _earlyExitWithdrawable(reward, epochId);
        reward.withdrawn = reward.amount;
        withdrawablePenalty += penalty;
        emit Withdrawn(epochId, msg.sender, withdrawable, penalty);
        oleToken.safeTransfer(msg.sender, withdrawable);
    }

    /// @param token1MaxAmount, The token1 max supply amount when adding liquidity
    /// @param unlockTime, The unlock time for the XOLE lock
    function convertToNewXole(uint256 epochId, uint256 token1MaxAmount, uint256 unlockTime) external nonReentrant {
        uint256 conversion = _convertOLE(epochId, msg.sender);
        _convertToNewXole(msg.sender, conversion, token1MaxAmount, unlockTime);
    }

    function convertToNewXoleForOthers(uint256 epochId, address account, uint256 token1MaxAmount, uint256 unlockTime) external nonReentrant {
        uint256 conversion = _convertOLE(epochId, msg.sender);
        _convertToNewXole(account, conversion, token1MaxAmount, unlockTime);
    }

    function convertAndIncreaseXoleAmount(uint256 epochId, uint256 token1MaxAmount) external nonReentrant {
        uint256 conversion = _convertOLE(epochId, msg.sender);
        _convertAndIncreaseXoleAmount(msg.sender, conversion, token1MaxAmount);
    }

    function convertAndIncreaseXoleAmountForOthers(uint256 epochId, address account, uint256 token1MaxAmount) external nonReentrant {
        uint256 conversion = _convertOLE(epochId, msg.sender);
        _convertAndIncreaseXoleAmount(account, conversion, token1MaxAmount);
    }

    /*** View Functions ***/
    function verifyVest(address account, uint256 _epochId, uint256 _balance, bytes32[] calldata _merkleProof) external view returns (bool valid){
        return _verifyVest(account, epochs[_epochId].merkleRoot, _balance, _merkleProof);
    }

    function getWithdrawable(address account, uint256[] calldata _epochIds) external view returns (uint256[] memory results){
        uint256 len = _epochIds.length;
        results = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            Reward memory reward = rewards[_epochIds[i]][account];
            if (reward.amount == reward.withdrawn) {
                results[i] = 0;
                continue;
            }
            Epoch memory epoch = epochs[_epochIds[i]];
            uint256 releaseAble = _releaseable(reward, epoch);
            results[i] = releaseAble - reward.withdrawn;
        }
    }

    function getEarlyExitWithdrawable(address account, uint256 _epochId) external view returns (uint256 amount, uint256 penalty){
        Reward memory reward = rewards[_epochId][account];
        if (reward.amount == reward.withdrawn) {
            (amount, penalty) = (0, 0);
        } else {
            (amount, penalty) = _earlyExitWithdrawable(reward, _epochId);
        }
    }

    /*** Admin Functions ***/
    function newEpoch(
        bytes32 merkleRoot,
        uint256 total,
        uint256 startTime,
        uint256 expireTime,
        uint256 vestDuration,
        uint16 penaltyBase,
        uint16 penaltyAdd)
    external onlyAdminOrDeveloper verifyDuration(vestDuration) {
        if (expireTime <= startTime || expireTime <= block.timestamp) revert InvalidTime();
        if (total == 0 || penaltyBase + penaltyAdd >= PERCENT_DIVISOR) revert InvalidAmount();
        uint256 received = oleToken.safeTransferFrom(msg.sender, address(this), total);
        if(received != total) revert InsufficientTransfersIn();
        uint256 epochId = ++epochIdx;
        epochs[epochId] = Epoch(merkleRoot, total, 0, startTime, expireTime, vestDuration, penaltyBase, penaltyAdd, false);
        emit EpochAdded(epochId, merkleRoot, total, startTime, expireTime, vestDuration, penaltyBase, penaltyAdd);
    }

    function recycle(uint256[] calldata _epochIds) external onlyAdmin {
        uint256 total;
        for (uint256 i = 0; i < _epochIds.length; i++) {
            Epoch storage epoch = epochs[_epochIds[i]];
            if (epoch.recycled) revert AlreadyRecycled();
            if (block.timestamp <= epoch.expireTime) revert NotExpired();
            uint256 recycleAmount = epoch.total - epoch.vested;
            total += recycleAmount;
            epoch.recycled = true;
            emit Recycled(_epochIds[i], recycleAmount);
        }
        if (total == 0) revert InvalidAmount();
        oleToken.safeTransfer(admin, total);
    }

    function withdrawPenalty() external onlyAdmin {
        if (withdrawablePenalty == 0) revert InvalidAmount();
        uint256 _withdrawablePenalty = withdrawablePenalty;
        withdrawablePenalty = 0;
        oleToken.safeTransfer(admin, _withdrawablePenalty);
        emit PenaltyWithdrawn(_withdrawablePenalty);
    }

    function setMinXOLELockDuration(uint256 _minXOLELockDuration) external onlyAdmin verifyDuration(_minXOLELockDuration) {
        minXOLELockDuration = _minXOLELockDuration;
    }

    /*** Internal Functions ***/
    function _verifyVest(address account, bytes32 root, uint256 _balance, bytes32[] memory _merkleProof) internal pure returns (bool valid) {
        bytes32 leaf = keccak256(abi.encodePacked(account, _balance));
        return MerkleProof.verify(_merkleProof, root, leaf);
    }

    function _withdrawReward(uint256 epochId) internal returns (uint256){
        Reward storage reward = rewards[epochId][msg.sender];
        if (reward.amount == 0 || reward.amount == reward.withdrawn) revert InvalidAmount();
        Epoch memory epoch = epochs[epochId];
        uint256 withdrawing = _releaseable(reward, epoch) - reward.withdrawn;
        if (withdrawing == 0) revert InvalidAmount();
        reward.withdrawn += withdrawing;
        emit Withdrawn(epochId, msg.sender, withdrawing, 0);
        return withdrawing;
    }

    function _releaseable(Reward memory reward, Epoch memory epoch) internal view returns (uint256) {
        uint256 endTime = reward.vestStartTime + epoch.vestDuration;
        if (block.timestamp > endTime) {
            return reward.amount;
        } else {
            return (block.timestamp - reward.vestStartTime) * reward.amount / epoch.vestDuration;
        }
    }

    function _earlyExitWithdrawable(Reward memory reward, uint256 epochId) internal view returns (uint256 withdrawable, uint256 penalty) {
        Epoch memory epoch = epochs[epochId];
        uint256 releaseable = _releaseable(reward, epoch);
        withdrawable = releaseable - reward.withdrawn;
        // cal penalty
        uint256 endTime = reward.vestStartTime + epoch.vestDuration;
        uint256 penaltyFactor = (endTime - block.timestamp) * epoch.penaltyAdd / epoch.vestDuration + epoch.penaltyBase;
        uint256 locked = reward.amount - releaseable;
        penalty = locked * penaltyFactor / PERCENT_DIVISOR;
        if (penalty >= locked) revert InvalidPenalty();
        withdrawable += locked - penalty;
        return (withdrawable, penalty);
    }

    function _convertOLE(uint256 epochId, address account) internal returns (uint256) {
        Reward storage reward = rewards[epochId][account];
        uint256 convertible = reward.amount - reward.withdrawn;
        if (reward.amount == 0 || convertible == 0) revert InvalidAmount();
        reward.withdrawn = reward.amount;
        emit ConvertedToXOLE(epochId, account, convertible);
        return convertible;
    }

    function _convertToNewXole(address account, uint256 oleAmount, uint256 token1MaxAmount, uint256 unlockTime) internal {
        unlockTime = unlockTime / WEEK * WEEK;
        verifyUnlockTime(unlockTime);
        uint256 liquidity = formLp(oleAmount, token1MaxAmount);
        pair.safeApprove(xole, liquidity);
        IXOLE(xole).create_lock_for(account, liquidity, unlockTime);
    }

    function _convertAndIncreaseXoleAmount(address account, uint256 oleAmount, uint256 token1MaxAmount) internal {
        (,uint256 lockTime) = IXOLE(xole).locked(account);
        verifyUnlockTime(lockTime);
        uint256 liquidity = formLp(oleAmount, token1MaxAmount);
        pair.safeApprove(xole, liquidity);
        IXOLE(xole).increase_amount_for(account, liquidity);
    }

    function formLp(uint256 oleAmount, uint256 token1MaxAmount) internal returns (uint256 liquidity){
        (uint256 reserveA, uint256 reserveB) = getReserves(address(oleToken), token1);
        uint256 amountBOptimal = oleAmount * reserveB / reserveA;
        if (amountBOptimal > token1MaxAmount) revert ExceedMax(amountBOptimal);
        IERC20(token1).safeTransferFrom(msg.sender, address(pair), amountBOptimal);
        oleToken.safeTransfer(address(pair), oleAmount);
        liquidity = pair.mint(address(this));
    }

    function getReserves(address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        (address _token0,) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        (reserveA, reserveB) = tokenA == _token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function verifyUnlockTime(uint256 _unlockTime) internal view {
        if (_unlockTime < block.timestamp + minXOLELockDuration || _unlockTime > block.timestamp + MAX_DURATION) revert InvalidTime();
    }

    modifier verifyDuration(uint256 _duration) {
        if (_duration < MIN_DURATION || _duration > MAX_DURATION) revert InvalidTime();
        _;
    }

}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TransferHelper
 * @dev Wrappers around ERC20 operations that returns the value received by recipent and the actual allowance of approval.
 * To use this library you can add a `using TransferHelper for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library TransferHelper {
    function safeTransfer(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) internal returns (uint256 amountReceived) {
        if (_amount > 0) {
            bool success;
            uint256 balanceBefore = _token.balanceOf(_to);
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            require(success, "TF");
            uint256 balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256 amountReceived) {
        if (_amount > 0) {
            bool success;
            uint256 balanceBefore = _token.balanceOf(_to);
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            require(success, "TFF");
            uint256 balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TFF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal returns (uint256) {
        bool success;
        if (_token.allowance(address(this), _spender) != 0) {
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");

        return _token.allowance(address(this), _spender);
    }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IXOLE{

    function create_lock_for(address to, uint256 _value, uint256 _unlock_time) external;

    function increase_amount_for(address to, uint256 _value) external;

    function balanceOf(address addr) external view returns (uint256);

    function locked(address addr) external view returns (uint256 amount, uint256 lockTime);

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniV2ClassPair is IERC20{

    function mint(address to) external returns (uint liquidity);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        check();
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    function check() private view {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    }
}
// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() {
        developer = payable(msg.sender);
    }

    modifier onlyAdmin() {
        checkAdmin();
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "Only admin or dev");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;
        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;
        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "Only pendingAdmin");
        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        // Store admin with value pendingAdmin
        admin = pendingAdmin;
        // Clear the pending value
        pendingAdmin = payable(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function checkAdmin() private view {
        require(msg.sender == admin, "caller must be admin");
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.2) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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
