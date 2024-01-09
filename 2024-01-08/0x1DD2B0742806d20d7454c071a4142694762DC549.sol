/**
 *Submitted for verification at testnet.bscscan.com on 2024-01-03
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-12-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

pragma experimental ABIEncoderV2;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

contract BUYSWIPE {
    using SafeMath for uint256;
    address payable public owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "Called is not a Owner");
        _;
    }

    struct Plan {
        uint256 _amount;
        uint256 _validity;
        uint256 _minIvestment;
        uint256 _maxIvestment;
        bool _isDiscount;
        uint256 _DisPercent;
        bool _isEnable;
    }

    struct Periods {
        uint256 _duration;
        bool _isAutoCompound;
        bool _isActive;
    }

    struct UserBot {
        uint256 _planID;
        uint256 _periodsID;
        uint256 _expiredOn;
        uint256 _investedAmount;
        uint256 _profit;
        uint256 _buyTime;
        bool _enable;
        bool _isExpriy;
    }

    mapping(address => mapping(uint256 => UserBot)) public _userBot;
    mapping(address => bool) public _tokens;
    mapping(address => address) public parentOf;
    Plan[] public _plans;
    Periods[] public _periods;
    uint256 affilateFee = 10 * 10**18;

    constructor() public {
        owner = payable(msg.sender);
    }

    function purchaseBot(
        uint256 _planID,
        uint256 _periodID,
        address _token,
        address _referrer
    ) public {
        // STABLE TOKENS
        require(_tokens[_token], "Token is not supported !");

        if (_plans[_planID]._isDiscount) {
            uint256 DiscountFee = _plans[_planID]._amount.sub(
                _plans[_planID]._amount.mul(_plans[_planID]._DisPercent).div(
                    10**20
                ));
            IERC20(_token).transferFrom(msg.sender, address(this), DiscountFee);
        } else {
            IERC20(_token).transferFrom(
                msg.sender,
                address(this),
                _plans[_planID]._amount
            );
        }

        UserBot storage user = _userBot[msg.sender][_planID];
        user._planID = _planID;
        user._periodsID = _periodID;
        user._buyTime = block.timestamp;
        user._enable = false;
        user._isExpriy = false;
        _userBot[msg.sender][_planID] = user;
        parentOf[msg.sender] = _referrer;

        // affilate Transfer
        if (_plans[_planID]._amount.mul(affilateFee).div(10**20) > 0)
            IERC20(_token).transfer(
                _referrer,
                _plans[_planID]._amount.mul(affilateFee).div(10**20)
            );
    }

    function addPlan(
        uint256 _planAmount,
        uint256 _validity,
        uint256 _min,
        uint256 _max,
        bool _isDiscount,
        uint256 _DisPercent,
        bool _isEnable
    ) external onlyOwner {
        _plans.push(
            Plan(_planAmount, _validity, _min, _max, _isDiscount, _DisPercent,_isEnable)
        );
    }

    function getLastPlanIndex () external view returns (uint256){
        return  _plans.length;
    }
    function setPlan(
        uint256 _planID,
        uint256 _planAmount,
        uint256 _validity,
        uint256 _min,
        uint256 _max,
        bool _isDiscount,
        uint256 _DisPercent,
        bool _isEnable
    ) external onlyOwner {
        Plan storage plan = _plans[_planID];
        plan._amount = _planAmount;
        plan._minIvestment = _min;
        plan._maxIvestment = _max;
        plan._validity = _validity;
        plan._isDiscount = _isDiscount;
        plan._DisPercent = _DisPercent;
        plan._isEnable = _isEnable;
        _plans[_planID] = plan;
    }

    function addPeriod(uint256 _duration, bool autoCompound,bool isActive)
        external
        onlyOwner
    {
        _periods.push(Periods(_duration, autoCompound,isActive));
    }

    function setPeriod(
        uint256 _pid,
        uint256 _duration,
        bool autoCompound,
        bool isActive
    ) external onlyOwner {
        Periods storage period = _periods[_pid];
        period._duration = _duration;
        period._isAutoCompound = autoCompound;
        period._isActive = isActive;
    }

    function getLastPeriodIndex () external view returns (uint256){
        return  _periods.length;
    }

    function getTotalPeriod() external view returns (Periods[] memory) {
        return _periods;
    }

    function getPeriod(uint256 _pid) external view returns (Periods memory) {
        return _periods[_pid];
    }

    function addToken(address _token, bool _allowed) external onlyOwner {
        _tokens[_token] = _allowed;
    }

    function setAffilateFee(uint256 _fee) external onlyOwner {
        affilateFee = _fee;
    }

    function getAffilateFee()external view returns (uint256){
        return affilateFee;
    }
    
    function transferOwnership(address _newOwner) external onlyOwner {
        owner = payable(_newOwner);
    }

    function botsubscribe(uint256 _planID) public {
        UserBot storage user = _userBot[msg.sender][_planID];
        user._enable = true;
        user._expiredOn = block.timestamp.add(_plans[_planID]._validity);
    }

    function getuserPlan(address user, uint256 _planID)
        external
        view
        returns (UserBot memory)
    {
        return _userBot[user][_planID];
    }

    function getPlan(uint256 _planID) external view returns (Plan memory) {
        return _plans[_planID];
    }

    function getTotalPlan() external view returns (Plan[] memory) {
        return _plans;
    }
}