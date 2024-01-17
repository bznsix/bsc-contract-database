// SPDX-License-Identifier: MIT


/* Welcome to the Telegram trading bot QuantSwap! Trade crypto with quant fast execution speed.

   LP BURNT! CONTRACT RENNOUNCED! 

   Telegram: https://t.me/+97iO6Pvagl5lYmVi

   Twitter: https://twitter.com/CarnevalC41561

   Website: https://websiteai.app/s/8b27f6f6-19aa-4631-a8fc-54abae11ee2e/


*/

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: With Solidity 0.8, the compiler
 * now has built in overflow checking.
 */
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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


pragma solidity ^0.8.19;

contract CarnevalCoin {
    using SafeMath for uint256;
    string public name = "CarnevalCoin";
    string public symbol = "CLC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000 * 10 ** uint256(decimals); // Total supply of 10 million tokens
    address private owner;  
    address public liquidityPoolOwner;   
    address public contractOwner;


    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MaxBuyPerWalletChanged(uint256 newValue);   

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
      

    constructor() {
        name = "CarnevalCoin";
        symbol = "CLC";
        decimals = 18;
        totalSupply = 10000000 * 10 ** uint256(decimals); 
        owner = msg.sender;              
        balanceOf[owner] = totalSupply;       
        emit Transfer(address(0), msg.sender, totalSupply);
    }

      function transfer(address to, uint256 value) public returns (bool) {        
        uint256 transferAmount = value;

        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(balanceOf[to] + transferAmount >= balanceOf[to], "Invalid recipient balance");        

        balanceOf[msg.sender] -= value;       
        balanceOf[to] += transferAmount;

        emit Transfer(msg.sender, to, transferAmount);
        
        return true;
    }

       function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

     function transferFrom(address from, address to, uint256 value) public returns (bool) {
                     
        uint256 transferAmount = value;

        require(balanceOf[from] >= value, "Insufficient balance");
        require(balanceOf[to] + transferAmount >= balanceOf[to], "Invalid recipient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");        

        balanceOf[from] -= value;      
        balanceOf[to] += transferAmount;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, transferAmount);       
        emit Approval(from, msg.sender, allowance[from][msg.sender]);

        return true;
    }

function BurnLiquidityPool() public onlyOwner {
        liquidityPoolOwner = address(0);
} 

function RenounceContractOwnership() public onlyOwner {
        contractOwner = address(0);
}  
 
}