/**
 *Submitted for verification at testnet.bscscan.com on 2023-12-01
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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


interface IXSurge is IERC20{

    function burn(uint256 amount) external;
    function mintWithNative(address recipient, uint256 minOut) external payable returns (uint256);
    function mintWithBacking(address backingToken, uint256 numTokens, address recipient) external returns (uint256);
    function requestPromiseTokens(address stable, uint256 amount) external returns (uint256);
    function sell(uint256 tokenAmount) external returns (address, uint256);
    function calculatePrice() external view returns (uint256);
    function getValueOfHoldings(address holder) external view returns(uint256);
    function isUnderlyingAsset(address token) external view returns (bool);
    function getUnderlyingAssets() external view returns(address[] memory);
    function requestFlashLoan(address stable, address stableToRepay, uint256 amount) external returns (bool);
    function resourceCollector() external view returns (address);
}

interface IPromiseUSD {
    function setApprovedContract(address Contract, bool _isApproved) external;
    function mint(uint256 amountUnderlyingAsset) external returns (bool);
    function takeLoan(address desiredStable, uint256 amount) external returns (uint256);
    function burnCollateral(uint256 ID, uint256 amount) external;
    function makePayment(uint256 ID, uint256 amountUSD) external returns (uint256);
}

/**
    NEXUS's Lending Token

    Over 1:1 Tied With USD
        - Total Supply = USD To Be Repaid
        - Total Locked = NEXUS Held As Collateral

        Total Locked should always be worth more than Total Supply

    Locks NEXUS Inside Of Itself And Redeems Its USD Without Burning Its Supply
    Can Only Release NEXUS If USD Debt Is Repaid

    Intended to be a bare bones contract that does not implement any specific functionality
    But enables approved contracts to utilize itself to benefit NEXUS.

    On its own pUSD is price neutral for NEXUS, but if used correctly it can be used to bring
    external profits into the system via lending, leveraged yield farming, and other services
*/
contract PromiseUSD is IERC20, IPromiseUSD {

    using SafeMath for uint256;
    
    // Relevant Tokens
    address public NEXUS;
    address public constant underlying = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    // Token Data
    string private constant _name = "PromiseUSD";
    string private constant _symbol = "pUSD";
    uint8 private constant _decimals = 18;
    
    // 0 Initial
    uint256 private _totalSupply = 0;

    // total NEXUS locked
    uint256 public totalLocked = 0;

    // Tracks USD lent vs collateral collected
    struct Promise {
        uint256 debt;
        uint256 collateral;
    }
    
    // User -> ID -> Promise
    mapping ( address => mapping ( uint256 => Promise ) ) public userPromise;

    // User -> Current ID ( nonce )
    mapping ( address => uint256 ) public nonces;

    /**
        Allows Platforms + Models To Implement Lending And Preserve Upgradability
        Being Forced To Preserve The Truths Enforced In This Smart Contract
        With LeeWay For Adding External Fees And Usability
    */
    mapping ( address => bool ) public isApproved;

    // Approved Contracts Only
    modifier onlyApproved(){
        require(isApproved[msg.sender], 'Only Approved Miners');
        _;
    }

    // Only NEXUS Itself
    modifier onlyNEXUS(){
        require(msg.sender == NEXUS, 'Only NEXUS');
        _;
    }

    // Events
    event CollateralBurned(uint NEXUSBurned, uint pUSDBurned);
    event PromisePaymentReceived(uint usdReceived, uint NEXUSRedeemed);
    event PromiseCreated(address user, uint usdBorrowed, uint NEXUSCollateral);
    event ContractApproval(address newContract, bool _isApproved);

    // Necessary Token Data
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return account == NEXUS ? _totalSupply : 0; }
    function allowance(address holder, address spender) external pure override returns (uint256) { holder; spender; return 0; }
    function name() public pure override returns (string memory) {
        return _name;
    }
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    /** Transfer Function */
    function transferFrom(address, address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256) internal returns (bool) {
        emit Transfer(sender, recipient, 0);
        return false;
    }

    /**
        Pairs NEXUS With Its Current Contract
        Can Only Be Performed Once
     */
    function pairNEXUS(address NEXUS_) external {
        require(
            NEXUS == address(0) &&
            NEXUS_ != address(0),
            'Already Paired'
        );
        NEXUS = NEXUS_;
    }

    /**
        Approves External Contract To Utilize pUSD
        NOTE: Only NEXUS Can Call This Function
    */
    function setApprovedContract(address Contract, bool _isApproved) external override onlyNEXUS {
        isApproved[Contract] = _isApproved;
        emit ContractApproval(Contract, _isApproved);
    }

    /**
        Burns NEXUS Held As Collateral, Reduces Debt in proportion to burn amount
        Allowing an approved contract to burn their locked NEXUS and associated pUSD tokens

        @param ID - nonce for calling contract to burn from
        @param amount - amount of NEXUS to burn
    */
    function burnCollateral(uint256 ID, uint256 amount) external override onlyApproved {
        require(
            userPromise[msg.sender][ID].collateral > 0 && 
            userPromise[msg.sender][ID].collateral >= amount, 
            'Insufficient Collateral'
        );
        
        // BE SURE TO BURN APPROPRIATE AMOUNT OF pUSD AFTER SO NEXUS DOES NOT OVER-VALUE ITSELF
        uint256 burnAmount = ( amount * userPromise[msg.sender][ID].debt ) / userPromise[msg.sender][ID].collateral;

        // reduce collateral
        userPromise[msg.sender][ID].collateral = userPromise[msg.sender][ID].collateral.sub(amount, 'Underflow');
        // reduce total locked
        totalLocked -= amount;

        // reduce debt
        userPromise[msg.sender][ID].debt = userPromise[msg.sender][ID].debt.sub(burnAmount, 'Debt Underflow');

        // burn NEXUS amount
        IXSurge(NEXUS).burn(amount);

        // reduce pUSD amount in relation to NEXUS tokens burned to not overinflate pUSD backing in NEXUS
        _totalSupply = _totalSupply.sub(burnAmount);
        emit Transfer(NEXUS, address(0), burnAmount);
        emit CollateralBurned(amount, burnAmount);
    }
    
    /**
        Repayes the debt tracked by `ID` in underlying, and releases NEXUS 
        Back to the user who staked the NEXUS in the first place, proportional to
        how much debt has been repaid
        Can only be triggered by Approved Contracts

        @param ID - ID or nonce of calling contract to repay
        @param amountUSD - amount of USD stable coins to make the payment for
     */
    function makePayment(uint256 ID, uint256 amountUSD) external override onlyApproved returns (uint256) {
        return _makePayment(msg.sender, ID, amountUSD);
    }

    /**
        Takes NEXUS As Collateral and releases its underlying USD Without Deleting Tokens
        pUSD is minted to NEXUS to sustain its price
        It's up to the implementing smart contract to add a fee to this system to benefit NEXUS
        there is no intrinsic benefit to this contract or function alone, what is built from it
        however has all the potential

        This uses the calling contract's current nonce and increments it
        @param collateral - Amount of NEXUS to lock up and borrow from
        @return ID - The ID Utilized For This Loan
    */
    function takeLoan(address desiredStable, uint256 collateral) external override onlyApproved returns (uint256) {
        uint ID = nonces[msg.sender];
        require(!IDInUse(msg.sender, ID), 'ID in Use');
        _takeLoan(ID, desiredStable, collateral);
        unchecked {
            ++nonces[msg.sender];
        }
        return ID;
    }

    /**
        Whehter or not the nonce of a calling contract is in use or not
     */
    function IDInUse(address borrower, uint256 ID) public view returns (bool) {
        return userPromise[borrower][ID].collateral > 0 || userPromise[borrower][ID].debt > 0;
    }

    /**
        Repayes the debt tracked by `ID` in USD, and releases the NEXUS 
        Back to the user who staked the NEXUS in the first place
     */
    function _makePayment(address user, uint256 ID, uint256 amountUSD) internal returns (uint256 amountCollateral) {
        require(userPromise[user][ID].debt > 0, 'Zero Debt');
        require(amountUSD <= userPromise[user][ID].debt && amountUSD > 0, 'Invalid Amount');
        
        // transfer in USD
        uint256 received = _transferIn(underlying, amountUSD);

        // Repay USD Amount To NEXUS
        bool s = IERC20(underlying).transfer(NEXUS, received);
        require(s, 'Failure On USD Transfer');

        // Burn pUSD Supply
        _totalSupply = _totalSupply.sub(received, 'Underflow');
        emit Transfer(NEXUS, address(0), received);

        // check debt and locked NEXUS Amount
        if (userPromise[user][ID].debt <= received) {

            // clear collateral
            amountCollateral = userPromise[user][ID].collateral;
            _release(ID, user, amountCollateral);

            // emit event
            emit PromisePaymentReceived(amountUSD, amountCollateral);

            // free storage
            delete userPromise[user][ID];

        } else {

            // get portion of remaining debt
            amountCollateral = ( userPromise[user][ID].collateral * received ) / userPromise[user][ID].debt;

            // update remaining debt and supply
            userPromise[user][ID].debt = userPromise[user][ID].debt.sub(received, 'Underflow');

            // clear collateral
            _release(ID, user, amountCollateral);

            // emit event
            emit PromisePaymentReceived(received, amountCollateral);
        }
    }

    /**
        Takes NEXUS As Collateral and releases its underlying USD Without Deleting Tokens
        pUSD is minted to NEXUS to sustain its price
    */
    function _takeLoan(uint256 ID, address desiredStable, uint256 collateral) internal {

        // transfer in NEXUS
        uint256 xReceived = _transferIn(NEXUS, collateral);

        // set collateral
        userPromise[msg.sender][ID].collateral = xReceived;

        // increment total locked
        totalLocked = totalLocked.add(xReceived);

        // sells NEXUS tax exempt, calls back to mint to create an equal amount of pUSD as USD that is removed
        uint256 received = IXSurge(NEXUS).requestPromiseTokens(desiredStable, xReceived);
        require(
            received > 0 && 
            IERC20(desiredStable).balanceOf(address(this)) >= received,
            'NEXUS Promise Request Failed'
        );

        // set debt
        userPromise[msg.sender][ID].debt = received;

        // send USD to caller
        require(
            IERC20(desiredStable).transfer(msg.sender, received),
            'Stable Transfer Failure'
        );

        // emit event
        emit PromiseCreated(msg.sender, received, xReceived);
    }

    /**
        Function Triggered By NEXUS Itself
        After NEXUS Calculates It's USD Amount To Redeem
        It Must Be Minted pUSD So RequireProfit Does Not Fail
        NEXUS Will Send USD Into pUSD, assuming it does not ask for too much
        pUSD will Route USD To Desired Source, and Lock the NEXUS Received

        NEXUS May Only Be Unlocked From USD Being Repaid

    */
    function mint(uint256 amount) external override onlyNEXUS returns (bool) {
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), NEXUS, amount);
        return true;
    }

    /**
        Transfers in `amount` of `token` from the sender of the message
     */
    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        uint256 before = IERC20(token).balanceOf(address(this));
        bool s = IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 received = IERC20(token).balanceOf(address(this)).sub(before, 'Underflow');
        require(s && received <= amount && received > 0, 'Transfer Error');
        return received;
    }

    /**
        Unlocks NEXUS For User
        Reduces Collateral
    */
    function _release(uint256 ID, address to, uint256 amount) internal {

        bool s;
        // ensure token transfer success
        if (userPromise[to][ID].collateral <= amount) { // collateral is paid back
            // transfer collateral to owner
            s = IERC20(NEXUS).transfer(to, userPromise[to][ID].collateral);
            // decrement total locked
            totalLocked = totalLocked.sub(userPromise[to][ID].collateral, 'Total Locked Underflow');
            // reset storage
            delete userPromise[to][ID];
        } else {                                        // only part of collateral is paid back
            // update collateral
            userPromise[to][ID].collateral = userPromise[to][ID].collateral.sub(amount, 'Underflow');
            // transfer NEXUS
            s = IERC20(NEXUS).transfer(to, amount); 
            // decrement total locked
            totalLocked = totalLocked.sub(amount, 'Total Locked Underflow');
        }
        // require success
        require(s, 'NEXUS Transfer Failure');
    }

}