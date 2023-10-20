// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import './ReentrancyGuard.sol';

// transfers bnb
// transfers tokens
// should not be called by another contract
// issuer can add owners and set validations
// non issuer can add owners [but must be approved by others]
contract MultiSigWallet is ReentrancyGuard{
    using SafeERC20 for IERC20;
    using Address for address;

    struct NewOwner {
        uint uid;
        address _newOwner;
        address _addedBy;
        uint validations;
        string _code;
        bool _add;
        bool executed;
    }

    struct Transaction {
        uint uid;
        uint amount;
        uint validations;
        address destination; // required if sending 
        IERC20 token; // required if sending custom token
        bool _isToken;
        bool executed;
    }

    uint internal constant DIVIDER = 10000;
    uint internal validators;
    uint public validations; // required approvals [make in %??]
    uint public _lastTransaction;
    uint internal ownerRq;
    mapping (address => bool) public isOwner;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (uint => Transaction) public transactions;
    
    mapping (uint => NewOwner) public newOwnerRequest;

    mapping (uint => mapping (address => bool)) public newOwnerApvl;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier isNotOwner(address _newOwner) {
        require(!isOwner[_newOwner], "Already an owner");
        _;
    }

    modifier isRequested(uint _reqId) {
        require(_reqId == newOwnerRequest[_reqId].uid, 'Invalid Request');
        _;
    }

    modifier ownerNAdd (uint _reqId) {
        require(!newOwnerRequest[_reqId].executed, "Already Executed");
        _;
    }

    modifier hasNotAppvdOwner(uint _reqId) {
        require(!newOwnerApvl[_reqId][msg.sender], "You've already approved");
        _;
    }

    modifier ownerNtProcsd(uint _reqId) {
        require(!newOwnerRequest[_reqId].executed, "Already Executed");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].uid == transactionId, "Transaction doesn't exist");
        _;
    }

    modifier trxNotProcessed(uint transactionId) {
        require(!transactions[transactionId].executed, "Already Executed");
        _;
    }

    modifier trxHasEnoughApprovals(uint transactionId) {
        require(getValidations(transactions[transactionId].validations), "Not Enough Approvals");
        _;
    }

    modifier hasNotConfirmed(uint transactionId) {
        require(!confirmations[transactionId][msg.sender], "Transaction already confirmed");
        _;
    }

    modifier hasConfirmed(uint transactionId) {
        require(confirmations[transactionId][msg.sender], "Transaction already Revoqued");
        _;
    }

    modifier notZeroAddress(address _to) {
        require(address(_to) != address(0), 'Zero Address found');
        _;
    }

    event Deposit(address indexed _sender, uint value);
    event SubmitRequest(address indexed _sender, uint indexed transactionId);
    event Confirmation(address indexed _sender, uint indexed transactionId);
    event RvqdConfirmation(address indexed _sender, uint indexed transactionId);
    event TransactionExecution(address indexed _sender, uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event NewOwnerRequested(address indexed _sender, address indexed _newOwner, string _codeName);
    event ApproveNewOwner(address indexed _sender, uint requestId);
    event NewOwnerAdded(address indexed newOwner, uint requestId);
    event OwnerRemvd(address indexed newOwner, uint requestId);
    constructor(){
        isOwner[msg.sender] = true;
        validations = 6000; // 60 %
        validators++;
    }

    function addOwner(address _newOwner, string memory _codeName, bool _action) public onlyOwner nonReentrant notZeroAddress(_newOwner) isNotOwner(_newOwner){
        ownerRq++;
        NewOwner storage newOwner = newOwnerRequest[ownerRq];
        newOwner.uid              = ownerRq;
        newOwner._newOwner        = _newOwner;
        newOwner._addedBy         = msg.sender;
        newOwner.validations      = 1;
        newOwner._add             = _action;
        newOwner.executed         = false;
        emit NewOwnerRequested(msg.sender, _newOwner, _codeName);
    }

    function approveOwnerAction(uint _reqId) public nonReentrant onlyOwner isRequested(_reqId) hasNotAppvdOwner(_reqId) ownerNtProcsd(_reqId) {
        newOwnerApvl[_reqId][msg.sender] = true;
        newOwnerRequest[_reqId].validations++;
        emit ApproveNewOwner(msg.sender, _reqId);
        processOwnrRqt(_reqId);
    }

    function processOwnrRqt(uint _reqId) public nonReentrant isRequested(_reqId) ownerNtProcsd(_reqId) {
        bool _validations = getValidations(newOwnerRequest[_reqId].validations);
        if(_validations) {
            newOwnerRequest[_reqId].executed = true;
            if(newOwnerRequest[_reqId]._add) {
                isOwner[newOwnerRequest[_reqId]._newOwner] = true;
                emit NewOwnerAdded(newOwnerRequest[_reqId]._newOwner, _reqId);
                validators++;
            }
            else {
                isOwner[newOwnerRequest[_reqId]._newOwner] = false;
                emit OwnerRemvd(newOwnerRequest[_reqId]._newOwner, _reqId);
                validators--;
            }
        }
    }

    // create a transaction
    function requestTransaction(address _to, IERC20 _token, uint _amount, bool _isToken) 
        public nonReentrant onlyOwner notZeroAddress(_to){
        _lastTransaction++;
        Transaction storage _transaction =  transactions[_lastTransaction];
        _transaction.uid = _lastTransaction;
        _transaction.amount = _amount;
        _transaction.destination = _to;
        _transaction.validations = 0;
        _transaction.token = _token;
        _transaction._isToken = _isToken;
        _transaction.executed = false;
        emit SubmitRequest(msg.sender, _lastTransaction);
    }

    // approve
    function approveTransaction(uint trxId) public nonReentrant onlyOwner 
        transactionExists(trxId) hasNotConfirmed(trxId) trxNotProcessed(trxId)
    {
        confirmations[trxId][msg.sender] = true;
        transactions[trxId].validations++;
        emit Confirmation(msg.sender, trxId);
        if(transactions[trxId].validations >= validations) executeTransaction(trxId);
    }

    // execute
    function executeTransaction(uint trxId) public nonReentrant onlyOwner trxNotProcessed(trxId) trxHasEnoughApprovals(trxId) {
        Transaction storage _transaction = transactions[trxId];
        _transaction.executed = true;
        IERC20 _token = _transaction.token;
        uint _amount = _transaction.amount;
        
        if(!_transaction._isToken){
            // sending BNB, requires available balance
            require(address(this).balance >= _amount, 'Insufficient Balance');
        }
        else if(_transaction._isToken && address(_token) != address(0)){
            require(_token.balanceOf(address(this)) >= _amount, 'Insufficient Balance');
        }
        transferFunds(trxId, _transaction._isToken, _token);
    }

    function transferFunds(uint trxId, bool _isToken, IERC20 _token) private {
        if(!_isToken){
            (bool success, ) = transactions[trxId].destination.call{
                                    value: transactions[trxId].amount
                                }("");
            require(success, "Transaction execution failed");
        }
        else{
            require(_token.transfer(transactions[trxId].destination, transactions[trxId].amount), 'Transaction execution failed');
        }
        emit TransactionExecution(msg.sender, trxId);
    }

    // revoque Confirmation
    function revoqueConfirmation(uint trxId) public onlyOwner 
        transactionExists(trxId) hasConfirmed(trxId) trxNotProcessed(trxId)
    {
        confirmations[trxId][msg.sender] = false;
        transactions[trxId].validations--;
        emit RvqdConfirmation(msg.sender, trxId);
    }

    function getValidations(uint _validations) internal view returns(bool _validated){
        uint _validationPercentage = (_validations / validators) * DIVIDER;
        if(_validationPercentage >= validations) return true;
    }

    // receive funds
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

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

contract ReentrancyGuard {
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
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}