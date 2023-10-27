/**
 *Submitted for verification at BscScan.com on 2021-11-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
interface relationship {
    function defultFather() external returns(address);
    function father(address _addr) external returns(address);
    function grandFather(address _addr) external returns(address);
    function otherCallSetRelationship(address _son, address _father) external;
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}
interface Ipair{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
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
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address _addr) {
        _owner = _addr;
        emit OwnershipTransferred(address(0), _addr);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view  returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract ERC20 {

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;


    uint256 public _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _name = "BDD";
        _symbol = "BDD";
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);


        _balances[sender] = _balances[sender] - amount;//修改了这个致命bug
        _balances[recipient] = _balances[recipient] + trueAmount;
        emit Transfer(sender, recipient, trueAmount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual  returns (uint256) { }
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


contract BDD is ERC20, Ownable{
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address public USDT = 0x55d398326f99059fF775485246999027B3197955;

    mapping(address => bool) public isPair;
    mapping(address => bool) public isFree;
    mapping(address => address) public parentList;

    uint256 public rate1 = 0;
    uint256 public rate2 = 200;
    uint256 public rate3 = 700;
    uint256 public rate4 = 0;
    uint256 public rate5 = 600;

    address public devAddr2=0xD76a060359EE6C2820385580953205c58133015d;
    address public holdAddr=0x0000000000000000000000000000000000000000;

    constructor () Ownable(msg.sender){

        IUniswapV2Router02 _uniswapV2Router =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this),USDT);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _mint(msg.sender, 2100 * 10**8 * 10**18);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    )internal override returns (uint256){

        if(parentList[_to]==address(0) && _from!=uniswapV2Pair && _to!=uniswapV2Pair){
            parentList[_to]=_from;
        }
        if ( _balances[holdAddr]>=209979000000 * 10**18 && rate5!=0){
            rate5=0;
        }

        if (isFree[_from] || isFree[_to]){
            return _amount;
        }

        uint256 _trueAmount;
        if (_from==uniswapV2Pair){

            _trueAmount = _amount * (10000 - (rate1 + rate2 + rate3 + rate4 + rate5)) / 10000;

            _balances[uniswapV2Pair] = _balances[uniswapV2Pair] + (_amount * rate2 / 10000 );
            _balances[holdAddr] = _balances[holdAddr] + (_amount * rate5 / 10000 );
            _takeInviterFee(_to,_amount);

            emit Transfer(_from, uniswapV2Pair, (_amount * rate2 / 10000 ));
            emit Transfer(_from, holdAddr, (_amount * rate5 / 10000 ));
        }else if (_to==uniswapV2Pair){

            _trueAmount = _amount * (10000 - (rate1 + rate2 + rate3 + rate4 + rate5)) / 10000;

            _balances[uniswapV2Pair] = _balances[uniswapV2Pair] + (_amount * rate2 / 10000 );
            _balances[holdAddr] = _balances[holdAddr] + (_amount * rate5 / 10000 );
            _takeInviterFee(_from,_amount);

            emit Transfer(_from, uniswapV2Pair, (_amount * rate2 / 10000 ));
            emit Transfer(_from, holdAddr, (_amount * rate5 / 10000 ));
        }else{
            return _amount;
        }



        return _trueAmount;
    }

    function _takeInviterFee(
        address addr,
        uint256 _amount
    ) private {

        address currAddr=addr;
        for (int256 i = 0; i < 7; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 20;
            } else if (i == 1) {
                rate = 5;
            } else if (i == 2) {
                rate = 6;
            } else if (i == 3) {
                rate = 7;
            } else if (i == 4) {
                rate = 8;
            } else if (i == 5) {
                rate = 9;
            } else {
                rate = 15;
            }
            address paddr=parentList[currAddr];
            if (paddr == address(0)) {
                _balances[devAddr2] = _balances[devAddr2].add(_amount * rate / 1000 );
                emit Transfer(addr, devAddr2, (_amount * rate / 1000 ));
            }else{
                _balances[paddr] = _balances[paddr].add(_amount * rate / 1000 );
                emit Transfer(addr, paddr, (_amount * rate / 1000 ));
            }
            currAddr=paddr;

        }
    }

    function setFree(
        address _addr,
        bool _bool
    ) external onlyOwner{
        isFree[_addr] = _bool;
    }

}