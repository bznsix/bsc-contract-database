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
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MontyPyMultiSigWallet  {
    event Deposit(
        address indexed sender,
        uint indexed amount,
        uint indexed balance
    );
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value
    );
    event ConfirmTransaction(
        address indexed owner,
        uint indexed txIndex,
        uint indexed numConfirmations
    );
    event RevokeConfirmation(
        address indexed owner,
        uint indexed txIndex,
        uint indexed numConfirmations
    );
    event ExecuteTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to    
    );
    event AddOwner(address indexed owner);
    event UpdateNumConfirmationsRequired(uint indexed numConfirmationsRequired);

    address[] private owners;
    address public deployer;
    mapping(address => bool) private isOwner;
    uint private numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bool executed;
        uint numConfirmations;
    }

    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {

        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );
        deployer = msg.sender;
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint _value
    ) public onlyOwner {
        uint txIndex = transactions.length;
        require(_value > 0, "Amount must be greater than 0");
        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value);

        Transaction storage transaction = transactions[txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, txIndex, transaction.numConfirmations);
    }

    function confirmTransaction(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex, transaction.numConfirmations);
    }

    function executeTransaction(
        uint _txIndex,
        address paymentTokenAddress
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        require(transaction.value > 0, "Amount must be greater than 0");

        bool success = IERC20(paymentTokenAddress).transfer(transaction.to, transaction.value);

        require(success, "Token transfer failed");

        emit ExecuteTransaction(msg.sender, _txIndex, transaction.to);
    }

    function revokeConfirmation(
        uint _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex, transaction.numConfirmations);
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(
        uint _txIndex
    )
        public
        view
        returns (
            address to,
            uint value,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    function addOwner(address _owner) public {
        require(msg.sender == deployer, "only deployer can add owner");
        require(_owner != address(0), "invalid owner");
        require(!isOwner[_owner], "owner already exists");

        isOwner[_owner] = true;
        owners.push(_owner);

        emit AddOwner(_owner);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTokenBalance(address tokenAddress) public view returns(uint256 tokenBalance){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function updateNumConfirmationsRequired(uint _numConfirmationsRequired) public {
        require(msg.sender == deployer, "only deployer can update the num of confirmations required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= owners.length, "invalid number of required confirmations");
        numConfirmationsRequired = _numConfirmationsRequired;
        emit UpdateNumConfirmationsRequired(_numConfirmationsRequired);
    }

}