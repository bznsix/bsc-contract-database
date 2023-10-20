// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: contracts\MutisigWallet.sol


pragma solidity ^0.8.13;



contract MultiSigWallet is Pausable {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data,
        TxType _txtype
    );
    event ConfirmTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        uint256 confirmations,
        TxType _txtype
    );
    event RevokeConfirmation(
        address indexed owner,
        uint256 indexed txIndex,
        uint256 confirmations,
        TxType _txtype
    );
    event ExecuteTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        uint256 confirmations,
        TxType _txtype
    );
    event CreateOwnerAddRequest(address requestBy, address probOwner);
    event OwnerAddition(address indexed owner);
    event CreateOwnerRemoveRequest(address requestBy, address probExOwner);
    event OwnerRemoval(address indexed owner);
    event CreateChangeRequirementRequest(
        address requester,
        uint256 numConfirmations
    );
    event ConfirmationRequirementChange(uint256 numConfirmationsRequired);
    event CreateTransferRequest(address receiver, uint256 value);
    event TransferUSDT(address receiver, uint256 value);
    event CreateUnpauseRequest();
    event ContractUnPaused();
    event ContractPaused();
    event EmergencyWithdraw(
        address receiver,
        address indexed owner,
        uint256 value
    );
    event EmergencyWithdrawETH(address receiver, address sender, uint256 value);

    address[] public owners;
    Transaction[] public transactions;
    address[] private _unPauseConfirmers;
    mapping(address => bool) public isOwner;
    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    uint256 public numConfirmationsRequired;
    uint256 public lockedAmount;
    IERC20 public USDT;
    uint256 private _unpauseVote;

    enum TxType {
        OWNER,
        FUND,
        CONFIRMATION
    }

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
        bool isUSDTtxn;
        TxType txtype;
    }

    modifier ownerExists() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner], "The requested owner is already owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(
            !isConfirmed[_txIndex][msg.sender],
            "tx already confirmed by this owner"
        );
        _;
    }

    modifier notNull(address _address) {
        require(!(_address == address(0)), "Address cannot be zero address");
        _;
    }

    modifier onlyContract() {
        require(
            msg.sender == address(this),
            "Only contract can call this method"
        );
        _;
    }

    constructor(
        address[] memory _owners,
        uint256 _numConfirmationsRequired,
        address usdt
    ) {
        require(_owners.length > 1, "owners required");
        require(
            _numConfirmationsRequired > 1 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
        USDT = IERC20(usdt);
        bytes memory data = abi.encodeWithSignature(
            "settingLengthTo1()" // this is dummy data so that it won't get executed and we are using it to set the length of array to 1
        );
        transactions.push(
            Transaction({
                to: address(0),
                value: 0,
                data: data,
                executed: false,
                numConfirmations: 0,
                isUSDTtxn: false,
                txtype: TxType.OWNER
            })
        );
    }

    function pause() public ownerExists {
        _pause();
        emit ContractPaused();
    }

    function unpause() public onlyContract {
        _unpause();
        emit ContractUnPaused();
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data,
        bool _isUSDTtxn,
        TxType _txtype
    ) internal {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 1,
                isUSDTtxn: _isUSDTtxn,
                txtype: _txtype
            })
        );
        isConfirmed[txIndex][msg.sender] = true;
        emit SubmitTransaction(
            msg.sender,
            txIndex,
            _to,
            _value,
            _data,
            _txtype
        );
    }

    function confirmTransaction(
        uint256 _txIndex
    )
        public
        whenNotPaused
        ownerExists
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        if (transaction.numConfirmations + 1 >= numConfirmationsRequired) {
            executeTransaction(_txIndex);
        } else {
            emit ConfirmTransaction(
                msg.sender,
                _txIndex,
                transaction.numConfirmations + 1,
                transaction.txtype
            );
        }
    }

    function executeTransaction(uint256 _txIndex) internal {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(
            msg.sender,
            _txIndex,
            transaction.numConfirmations,
            transaction.txtype
        );
    }

    function revokeConfirmation(
        uint256 _txIndex
    )
        public
        whenNotPaused
        ownerExists
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(
            msg.sender,
            _txIndex,
            transaction.numConfirmations,
            transaction.txtype
        );
    }

    function addOwner(address owner) public whenNotPaused onlyContract {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    function removeOwner(address owner) public whenNotPaused onlyContract {
        require(
            owners.length > 2,
            "you should at least have 3 owners to remove owner"
        );
        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.pop();
        if (numConfirmationsRequired > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    function changeRequirement(
        uint256 _required
    ) public whenNotPaused onlyContract {
        require(_required >= 2, "need at least 2 confirmations");
        numConfirmationsRequired = _required;
        emit ConfirmationRequirementChange(_required);
    }

    function transferUSDT(address receiver, uint256 value) public onlyContract {
        bool success = USDT.transfer(receiver, value);
        require(success, "Transfer of USDT failed");
        lockedAmount -= value;
        emit TransferUSDT(receiver, value);
    }

    function createAddOwnerTxn(
        address _newOwner
    )
        public
        whenNotPaused
        ownerExists
        ownerDoesNotExist(_newOwner)
        notNull(_newOwner)
    {
        bytes memory data = abi.encodeWithSignature(
            "addOwner(address)",
            _newOwner
        );
        submitTransaction(address(this), 0, data, false, TxType.OWNER);
        emit CreateOwnerAddRequest(msg.sender, _newOwner);
    }

    function createRemoveOwnerTxn(
        address exOwner
    ) public whenNotPaused ownerExists {
        require(owners.length > 2, "Can't create remove owner request");
        require(isOwner[exOwner], "Owner does not exist");
        bytes memory data = abi.encodeWithSignature(
            "removeOwner(address)",
            exOwner
        );
        submitTransaction(address(this), 0, data, false, TxType.OWNER);
        emit CreateOwnerRemoveRequest(msg.sender, exOwner);
    }

    function createChangeRequirementTxn(
        uint256 numConfirmations
    ) public whenNotPaused ownerExists {
        require(numConfirmations > 1, "confirmations should be at least 2");
        bytes memory data = abi.encodeWithSignature(
            "changeRequirement(uint256)",
            numConfirmations
        );
        submitTransaction(address(this), 0, data, false, TxType.CONFIRMATION);
        emit CreateChangeRequirementRequest(msg.sender, numConfirmations);
    }

    function createApproveTxn(
        address receiver,
        uint256 value
    ) public whenNotPaused ownerExists {
        require(
            USDT.balanceOf(address(this)) >= lockedAmount + value,
            "Insufficient USDT amount in contract"
        );
        bytes memory data = abi.encodeWithSignature(
            "transferUSDT(address,uint256)",
            receiver,
            value
        );
        submitTransaction(address(this), 0, data, true, TxType.FUND);
        lockedAmount += value;
        emit CreateTransferRequest(receiver, value);
    }

    function createUnpauseTxn() public whenPaused ownerExists {
        if (_unpauseVote == numConfirmationsRequired - 1) {
            bytes memory data = abi.encodeWithSignature("unpause()");
            (bool success, ) = address(this).call{value: 0}(data);
            require(success, "Unpause Contract failed");
            delete _unPauseConfirmers;
            _unpauseVote = 0;
            emit ContractUnPaused();
        } else {
            for (uint256 i = 0; i < _unPauseConfirmers.length; i++) {
                require(
                    _unPauseConfirmers[i] != msg.sender,
                    "owner already voted"
                );
            }
            _unPauseConfirmers.push(msg.sender);
            _unpauseVote += 1;
            emit CreateUnpauseRequest();
        }
    }

    function emergencyWithdraw(
        address receiver,
        uint256 value
    ) public whenPaused ownerExists {
        //TODO:: may be we need to add multisig here too
        require(USDT.balanceOf(address(this)) >= value, "Insufficient USDT");
        require(
            receiver != msg.sender && isOwner[receiver],
            "You cannot withdraw funds to that address"
        );
        bool success = USDT.transfer(receiver, value);
        require(success, "Emergency withdraw failed");
        emit EmergencyWithdraw(receiver, msg.sender, value);
    }

    function emergencyWithdrawETH(
        address receiver,
        uint256 value
    ) public whenPaused ownerExists {
        //TODO:: may be we need to add multisig here too
        require(address(this).balance >= value, "Insufficient ETH");
        (bool success, ) = payable(receiver).call{value: value}("");
        require(success, "Failed to send Ether");
        emit EmergencyWithdrawETH(receiver, msg.sender, value);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(
        uint256 _txIndex
    )
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}