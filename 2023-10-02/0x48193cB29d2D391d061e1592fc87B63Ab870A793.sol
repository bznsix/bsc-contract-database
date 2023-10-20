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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Reswaper.sol


pragma solidity ^0.8.18;



contract Reswaper is Ownable {

    address public lastParticipant5;
    uint256 public depositAmount5 = 0.05 ether;

    address public lastParticipant10;
    uint256 public depositAmount10 = 0.05 ether;

    struct User {
        uint256 deposit;
        uint256 cycleNumber;
    }

    mapping(address => User) public coopBalances5;
    mapping(address => User) public coopBalances10;

    mapping(uint256 => bool) public cycleResult5;
    mapping(uint256 => bool) public cycleResult10;
    uint256 minDeposit = 0.01 ether;

    uint256 public sumDeposits5 = 0;
    uint256 public sumDeposits10 = 0;

    uint256 public targetDeposits5 = 0.5 ether;
    uint256 public targetDeposits10 = 0.5 ether;

    uint256 public numberCycleCoop5 = 1;
    uint256 public numberCycleCoop10 = 1;

    constructor() {
        lastParticipant5 = msg.sender;
        lastParticipant10 = msg.sender;
    }

    function depositSolo5() public payable {
        require(msg.value >= depositAmount5);
        payable(lastParticipant5).transfer(depositAmount5);
        lastParticipant5 = msg.sender;
        depositAmount5 = depositAmount5 * 105 / 100;
    }

    function restartSolo5() external onlyOwner {
        lastParticipant5 = msg.sender;
        depositAmount5 = 0.05 ether;
    }

    function depositSolo10() public payable {
        require(msg.value >= depositAmount10);
        payable(lastParticipant10).transfer(depositAmount10);
        lastParticipant10 = msg.sender;
        depositAmount10 = depositAmount10 * 110 / 100;
    }

    function restartSolo10() external onlyOwner {
        lastParticipant10 = msg.sender;
        depositAmount10 = 0.05 ether;
    }

    function depositCoop5() public payable {
        require(msg.value >= minDeposit, "Add BNB");
        if (coopBalances5[msg.sender].deposit > 0) {
            require(coopBalances5[msg.sender].cycleNumber == numberCycleCoop5, "Withdraw or reinvest");
        }
        sumDeposits5 += msg.value;
        coopBalances5[msg.sender].deposit += msg.value;
        coopBalances5[msg.sender].cycleNumber = numberCycleCoop5;
        if (sumDeposits5 >= targetDeposits5) {
            uint256 overpay = sumDeposits5 - targetDeposits5;
            targetDeposits5 = targetDeposits5 * 105 / 100;
            cycleResult5[numberCycleCoop5 - 1] = true;
            coopBalances5[msg.sender].deposit -= overpay;
            numberCycleCoop5 += 1;
            sumDeposits5 = 0;
            if (overpay > 0) {
                payable(msg.sender).transfer(overpay);
            }
        }
    }

    function reinvestCoop5() public {
        require(cycleResult5[coopBalances5[msg.sender].cycleNumber]);
        uint256 reinvestAmount = coopBalances5[msg.sender].deposit * 105 / 100;
        require(reinvestAmount >= minDeposit, "Add BNB");
        sumDeposits5 += reinvestAmount;
        coopBalances5[msg.sender].deposit = reinvestAmount;
        coopBalances5[msg.sender].cycleNumber = numberCycleCoop5;
        if (sumDeposits5 >= targetDeposits5) {
            uint256 overpay = sumDeposits5 - targetDeposits5;
            targetDeposits5 = targetDeposits5 * 105 / 100;
            cycleResult5[numberCycleCoop5 - 1] = true;
            coopBalances5[msg.sender].deposit -= overpay;
            numberCycleCoop5 += 1;
            sumDeposits5 = 0;
            if (overpay > 0) {
                payable(msg.sender).transfer(overpay);
            }
        }
    }

    function withdrawCoop5() public {
        require(cycleResult5[coopBalances5[msg.sender].cycleNumber]);
        payable(msg.sender).transfer(coopBalances5[msg.sender].deposit * 105 / 100);
        coopBalances5[msg.sender].deposit = 0;
        coopBalances5[msg.sender].cycleNumber = 0;
    }

    function restartCoop5() external onlyOwner {
        payable(msg.sender).transfer(sumDeposits5 + 0.5 ether);
        numberCycleCoop5 += 2;
        sumDeposits5 = 0;
        targetDeposits5 = 0.5 ether;
    }

    function depositCoop10() public payable {
        require(msg.value >= minDeposit, "Add BNB");
        if (coopBalances10[msg.sender].deposit > 0) {
            require(coopBalances10[msg.sender].cycleNumber == numberCycleCoop10, "Withdraw or reinvest");
        }
        sumDeposits10 += msg.value;
        coopBalances10[msg.sender].deposit += msg.value;
        coopBalances10[msg.sender].cycleNumber = numberCycleCoop10;
        if (sumDeposits10 >= targetDeposits10) {
            uint256 overpay = sumDeposits10 - targetDeposits10;
            targetDeposits10 = targetDeposits10 * 110 / 100;
            cycleResult10[numberCycleCoop10 - 1] = true;
            coopBalances10[msg.sender].deposit -= overpay;
            numberCycleCoop10 += 1;
            sumDeposits10 = 0;
            if (overpay > 0) {
                payable(msg.sender).transfer(overpay);
            }
        }
    }

    function reinvestCoop10() public {
        require(cycleResult10[coopBalances10[msg.sender].cycleNumber]);
        uint256 reinvestAmount = coopBalances10[msg.sender].deposit * 110 / 100;
        require(reinvestAmount >= minDeposit, "Add BNB");
        sumDeposits10 += reinvestAmount;
        coopBalances10[msg.sender].deposit = reinvestAmount;
        coopBalances10[msg.sender].cycleNumber = numberCycleCoop10;
        if (sumDeposits10 >= targetDeposits10) {
            uint256 overpay = sumDeposits10 - targetDeposits10;
            targetDeposits10 = targetDeposits10 * 110 / 100;
            cycleResult10[numberCycleCoop10 - 1] = true;
            coopBalances10[msg.sender].deposit -= overpay;
            numberCycleCoop10 += 1;
            sumDeposits10 = 0;
            if (overpay > 0) {
                payable(msg.sender).transfer(overpay);
            }
        }
    }

    function withdrawCoop10() public {
        require(cycleResult10[coopBalances10[msg.sender].cycleNumber]);
        payable(msg.sender).transfer(coopBalances10[msg.sender].deposit * 110 / 100);
        coopBalances10[msg.sender].deposit = 0;
        coopBalances10[msg.sender].cycleNumber = 0;
    }

    function restartCoop10() external onlyOwner {
        payable(msg.sender).transfer(sumDeposits10 + 0.5 ether);
        numberCycleCoop10 += 2;
        sumDeposits10 = 0;
        targetDeposits10 = 0.5 ether;
    }

    receive() external payable {}

}