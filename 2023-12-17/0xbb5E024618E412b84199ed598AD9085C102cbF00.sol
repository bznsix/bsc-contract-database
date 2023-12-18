// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 *
 *
 *
 *┏━━━┓━━━┓┓┃┃┃━━━┓┃┃━━━┓━━┓━━━━┓┓┃┃┏┓
 *┃┏━┓┃┏━┓┃┃┃┃┃┓┏┓┃┃┃┏━┓┃┫┣┛┏┓┏┓┃┗┓┏┛┃
 *┃┃┃┗┛┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┗┛┃┃┃┛┃┃┗┛┓┗┛┏┛
 *┃┃┏━┓┃┃┃┃┃┃┏┓┃┃┃┃┃┃┃┃┏┓┃┃┃┃┃┃┃┃┗┓┏┛┃
 *┃┗┻━┃┗━┛┃┗━┛┃┛┗┛┃┃┃┗━┛┃┫┣┓┏┛┗┓┃┃┃┃┃┃
 *┗━━━┛━━━┛━━━┛━━━┛┃┃━━━┛━━┛┗━━┛┃┃┗┛┃┃
 *┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃
 *┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃
 *
 *░▄▀▀░█▄▒▄█▒▄▀▄▒█▀▄░▀█▀░░░▄▀▀░▄▀▄░█▄░█░▀█▀▒█▀▄▒▄▀▄░▄▀▀░▀█▀
 *▒▄██░█▒▀▒█░█▀█░█▀▄░▒█▒▒░░▀▄▄░▀▄▀░█▒▀█░▒█▒░█▀▄░█▀█░▀▄▄░▒█▒
 *
 *
 *  Gold City is an economic investment game built on a decentralized smart contract by Binance Smart Chain.
 *
 *  You build your city and make a profit.
 *
 *  Profit is accrued every second
 *
 *  Flexible interest rates
 *
 *  Works only with USDT BSC-BEP20
 *  
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

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
        if (_status == _ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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


contract GoldCity is Ownable, ReentrancyGuard {
    
    address public usdt = 0x55d398326f99059fF775485246999027B3197955; //Token Binance-Peg BSC-USD (BSC-USD)
    
    IERC20 public token;

    uint256 public INIT_MIN_DEPOSIT = 1;
    uint256 public INIT_MAX_DEPOSIT = 50;
    uint256 private INIT_MULTIPLIER = 1e18;
    uint256[2] private AFFILIATE_PERCENTS_BRICKS = [60, 30]; //6% for first-level partner, 3% for second-level partner
    uint256 private extraPercentageOfReinvest = 70; //7% - extra profit for reinvestment
    uint256 private minPercentage = 150; //1.5% min percentage
    uint256 private maxPercentage = 367; //3.67% max percentage
    uint256 private maxAmount = 10000; //the max amount for the max percentage    
    
    address public defaultRef = 0xb2407ab82f2a5B80C55412688B66201B16A07E79;
    uint256 public totalInvested;
    uint256 public totalInvestors;
    uint256 public totalBricks;

    struct Referrals {
        uint256 refsTotal;
        uint256 refs1level; 
        uint256 refearnBricks;
    }

    struct User {
        uint256 deposit;
        uint256 reinvested;
        uint256 earned;
        uint256 withdrawn;
        uint256 bucks;
        uint256 bricks;
        uint256 timestamp;        
        uint256 percentage;
        address partner;
        Referrals referrals;
    }

    mapping(address => User) public user;
    
    constructor() {
        token = IERC20(usdt);       
    }

    event ChangeUser(
        address indexed user,
        address indexed partner,
        uint256 amount
    );

    receive() external payable {}

    function BuildCity(uint256 amount, address partner) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        require(
            amount >= (INIT_MIN_DEPOSIT * INIT_MULTIPLIER),
            "Min deposit is 1 USDT"
        );
        require(
            (user[_msgSender()].deposit + amount) <=
                (INIT_MAX_DEPOSIT * INIT_MULTIPLIER),
            "Max deposit limit has been exceeded"
        );
        require(
            partner != _msgSender(),
            "Cannot set your own address as partner"
        );

        _updateprePayment(_msgSender());
        totalInvested += amount;
        
        user[_msgSender()].deposit += amount;

        if (user[_msgSender()].percentage == 0) {            
            totalInvestors += 1;
            address ref = user[partner].deposit == 0 ? defaultRef : partner;
            user[ref].referrals.refs1level++;
            user[ref].referrals.refsTotal++;
            user[user[ref].partner].referrals.refsTotal++;
            user[_msgSender()].partner = ref;
            user[_msgSender()].percentage = 1736111111111110; //1.5%
        }

        _updatePercentage(_msgSender());
        token.transferFrom(_msgSender(), address(this), amount);
        emit ChangeUser(
            _msgSender(),
            user[_msgSender()].partner,
            user[_msgSender()].deposit
        );

        // REF
        _traverseTree(user[_msgSender()].partner, amount);

        // OWNER FEE
        uint256 feeBricks = (amount * 3) / 100;
        user[owner()].bricks += feeBricks;
        totalBricks += feeBricks;
        uint256 feeUSDT = (amount * 5) / 100;
        token.transfer(owner(), feeUSDT);
    }

    function ReinvestBricks(uint256 amount) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        _updateprePayment(_msgSender());
        require(amount <= user[_msgSender()].bricks, "Insufficient funds");
        user[_msgSender()].bricks -= amount;
        user[_msgSender()].deposit += amount;
        user[_msgSender()].reinvested += amount;
        _updatePercentage(_msgSender());
        emit ChangeUser(
            _msgSender(),
            user[_msgSender()].partner,
            user[_msgSender()].deposit
        );
    }

    function ReinvestBucks(uint256 amount) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        _updateprePayment(_msgSender());
        require(amount <= user[_msgSender()].bucks, "Insufficient funds");
        user[_msgSender()].bucks -= amount;
        user[_msgSender()].deposit += (amount + amount*extraPercentageOfReinvest/1000); //extra profit for reinvestment
        user[_msgSender()].reinvested += amount;
        _updatePercentage(_msgSender());
        emit ChangeUser(
            _msgSender(),
            user[_msgSender()].partner,
            user[_msgSender()].deposit
        );
    }

    function Withdraw(uint256 amount) external nonReentrant {
        require(
            _msgSender() == tx.origin,
            "Function can only be called by a user account"
        );
        require(amount > 0, "Min withdrawal must be greater then 0");
        _updateprePayment(_msgSender());
        require(amount <= user[_msgSender()].bucks, "Insufficient funds");
        user[_msgSender()].bucks -= amount;
        user[_msgSender()].withdrawn += amount;
        token.transfer(_msgSender(), amount);
    }

    function checkReward(address account) public view returns (uint256) {
        uint256 RewardTime = block.timestamp - user[account].timestamp;
        RewardTime = (RewardTime >= 86400) ? 86400 : RewardTime;
        return ((((user[account].deposit / 10000) * user[account].percentage) /
            INIT_MULTIPLIER) * RewardTime);
    }

    function _updateprePayment(address account) internal {
        uint256 pending = checkReward(_msgSender());
        user[account].timestamp = block.timestamp;
        user[account].bucks += pending;
        user[account].earned += pending;
    }

    function isValidAddress(address _address) internal pure returns (bool) {
        return (_address != address(0));
    }

     function _traverseTree(address account, uint256 value) internal {        
        if (value != 0) {
            for (uint8 i; i < 2; i++) {
                if (isValidAddress(account)) {
                    uint256 feeBricks = ((value * AFFILIATE_PERCENTS_BRICKS[i]) /
                        1000);
                    totalBricks += feeBricks;
                    user[account].bricks += feeBricks;
                    user[account].referrals.refearnBricks += feeBricks;
                    account = user[account].partner;
                }
            }
        }
    }

    function _updatePercentage(address account) internal {
        uint256 availablePercent = getPercentage(user[account].deposit / INIT_MULTIPLIER);
        if (user[account].percentage != availablePercent) {
            user[account].percentage = availablePercent;
        }
    }

    function changeMaxDeposit(uint256 amount) external onlyOwner {
        require(amount > 50, "The amount must be more than 50");
        INIT_MAX_DEPOSIT = amount;
    }
    
    function  getPercentage(uint256 amount) public view returns (uint256) {                
        if (amount >= maxAmount)
            return maxPercentage*INIT_MULTIPLIER/86400;
        else 
            return (amount/100+minPercentage+amount/1000*2)*INIT_MULTIPLIER/86400;
        
    }  
}