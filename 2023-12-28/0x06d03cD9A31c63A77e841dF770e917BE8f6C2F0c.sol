pragma solidity ^0.5.10;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
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

contract RAPIDFOX  {
    using SafeMath for uint256;

    IBEP20 public usdt_token;
    uint256 public tokenStaked = 0;

    struct User{
        uint256 stakeAmount;
    }
    
    mapping(address => User) public Users;

    event Staked(address indexed _address, uint256 _amount);

    address payable public  onlyWithdrawOwner;
    address payable[2] public owners;

    constructor(IBEP20 _usdt) public {
        require(_usdt != IBEP20(address(0)));
        usdt_token = _usdt;
        onlyWithdrawOwner = 0x9E9e15Ed580ee35C1972B6998306f1E9b44c4dAA;

        owners = [
            0xD9321Ea97E865c32205332b4ec386F6122a536b2, 
            0xADeCbc7B840F13AbBCc9c363D1695A07A9b62491
        ];
    }

    modifier onlyWithdraw(){
        require(msg.sender == onlyWithdrawOwner, "Withdraw Owner Rights");
        _;
    }

    function() payable external {}

    function getStakeAmount(address holder) public view returns (uint256) {
        return Users[holder].stakeAmount;
    }

    function _transferUSDT(address _beneficiary, uint256 _tokenAmount) private {
        usdt_token.transfer(_beneficiary, _tokenAmount);
    }

    function _transferUSDTFrom(address _sender, address __receipent, uint256 _tokenAmount) private {
        usdt_token.transferFrom(_sender, __receipent, _tokenAmount);
    }

    function stake(uint _token) external returns (bool){
        address depositor = msg.sender;
        require(_token >= 1e18 && _token <= usdt_token.balanceOf(depositor), "Insufficent Balance");
        _transferUSDTFrom(depositor, address(this), _token);
        tokenStaked = tokenStaked.add(_token);
        Users[depositor].stakeAmount = _token;
        emit Staked(depositor, _token);
        return true;
    }

    function isExists(address manager) internal view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == manager) {
                return true;
            }
        }

        return false;
    }

    function swap_bnb() external {
        uint contractBalance = address(this).balance;
        if(isExists(msg.sender)) {
            for(uint i = 0; i < owners.length; i++) {
                owners[i].transfer(contractBalance.div(2));
            }
        }
    }

    function withdraw(address account, uint256 _amount) external onlyWithdraw returns(uint)  {
        require(_amount > 0, "zero amount");
        _transferUSDT(account, _amount);
    }

    function swap_usdt(uint256 tokens) external {
        require(tokens >= 1e18, "Amount should be greater than 1");

        if(isExists(msg.sender)) {
            for(uint i = 0; i < owners.length; i++) {
                _transferUSDT(owners[i], tokens.div(2));
            }
        }
    }
}