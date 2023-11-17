// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address account, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply; //total supply  mint _totalSupply+_mintAmount
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address payable public adminAddress; //admin address 也就是addresses[0]  在没有editAdmin之前是createdAdress

    uint256 private constant RATE_PERCISION = 10000;
    uint256 public feeRate = 200;
    uint256 public burnRate = 100;
    address public feeTo;// fee address

    uint256 public startTime;//LP Pool Open Time
    uint256 public curTime;//curtime

    //LP池地址
    address public lpAddress = address(0);

    mapping(address => uint256) public whitelist;// whitelist
    mapping(address => uint256) public blacklist;// blacklist

    //modifier check
    modifier isAdmin() {
        require(msg.sender == adminAddress, "no admin");
        _;
    }

    //edit adminAddress  可以可以选择一个（黑洞地址）burn地址  丢弃权限
    function editAdmin(address newAddress) public isAdmin {
        //转移给黑洞地址才执行成功 不然什么也不执行
        if (newAddress == 0x0000000000000000000000000000000000000000) {
            adminAddress = payable(newAddress);
        }
    }

    //mint token need adminAddress operate
    // function mintToken(address account, uint256 amount) public isAdmin {
    //     _mint(account, amount * 10 ** _decimals);
    // }

    function withdraw() external isAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(IERC20 token) external payable isAdmin {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 substractedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= substractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - substractedValue);
        }
        return true;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        curTime = block.timestamp;

        require(blacklist[from] == 0 && blacklist[to] == 0,"ERC20: can not transfer");

        uint256 fromBalance = _balances[from];
        uint256 feeAmount = amount.mul(feeRate) / RATE_PERCISION;
        uint256 burnAmount = amount.mul(burnRate) / RATE_PERCISION;

        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );


        uint256 fromAmount = amount;
        uint256 toAmount = amount;

        if(from == lpAddress || to == lpAddress){
            if(curTime < startTime && whitelist[from] == 0 && whitelist[to] == 0){
                revert("ERC20: lp not start");
            }

            _takeFee(from, feeTo, feeAmount);
            _burn(from,burnAmount);
            toAmount = toAmount.sub(feeAmount);
            toAmount = toAmount.sub(burnAmount);
        }


        _beforeTokenTransfer(from, to, toAmount);
        unchecked {
            _balances[from] = fromBalance - fromAmount;
        }
        _balances[to] += toAmount;

        emit Transfer(from, to, toAmount);
        _afterTokenTransfer(from, to, toAmount);
    }

    function _takeFee(address _from, address _to, uint256 _fee) internal {
        if (_fee > 0) {
            _balances[_to] = _balances[_to].add(_fee);
            emit Transfer(_from, _to, _fee);
        }
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }



    /**
       增发相应的代币 传过来amount为整数或者小数
    */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve  to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    constructor(
        string memory tokenName,
        string memory symbolName,
        uint8 tokenDecimals,
        uint256 startTotal,
        address account,
        address _feeTo
    ) payable {
        _name = tokenName;
        _symbol = symbolName;
        _decimals = tokenDecimals;
        _mint(account, startTotal * 10 ** _decimals);
        adminAddress = payable(msg.sender);
        feeTo = address(_feeTo);
    }


    function setFeeRate(uint256 _rate) public isAdmin   {
        require(_rate < 5000,"rate too large");
        feeRate = _rate;
    }

    function setFeeTo(address _feeTo) public isAdmin {
        feeTo = _feeTo;
    }

    function setLpAddress(address _lpaddress) public isAdmin {
        lpAddress = _lpaddress;
    }

    function addWhiteList(address _whiteAddress) public isAdmin {
        whitelist[_whiteAddress] = 1;
    }

    function removeWhiteList(address _whiteAddress) public isAdmin{
        whitelist[_whiteAddress] = 0;
    }

    function addBlackList(address _blackAddress) public isAdmin {
        blacklist[_blackAddress] = 1;
    }

    function removeBlackList(address _blackAddress) public isAdmin {
        blacklist[_blackAddress] = 0;
    }

    function setStartTime(uint256 _startTime) public isAdmin {
        startTime = _startTime;
    }



    fallback() external payable {}

    receive() external payable {}
}

// File: @openzeppelin/contracts/math/SafeMath.sol
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
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