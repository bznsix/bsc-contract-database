// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


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


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

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
/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost

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
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "SafeMath: addition overflow");
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
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "SafeMath: subtraction overflow");
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
     function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y, "SafeMath: multiplication overflow");
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
    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y > 0, "SafeMath: division by zero");
        return x / y;
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
    function mod(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "SafeMath: modulo by zero");
        return x % y;
    }
}

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x > y ? x : y;
    }

     // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function feeTo() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function kLast() external view returns (uint);
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IPinkLock {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external returns (uint256 id);
}

interface IMintRouter {
    function factory() external view returns (address);
}

interface IMintFactory {
    function conf(uint x) external view returns (uint begin, address token, uint period, uint m, uint n, uint s);
    function set0(uint256 x) external;
    function mint(address h, uint256 t, uint256 x, uint256 y, uint256 z) external view returns (uint256);
}

interface IEcologyFactory {
    function feeTo() external view returns (address);
}

contract WjToken is Context, IERC20, Ownable{
    using Address for address;
    using SafeMath for uint256;

    event Invited(address indexed from, address indexed to);
    event MintUnlock(address indexed token);
    event MintLocked(address indexed token, address indexed to, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = 'WJ3.0 Token';
    string private _symbol = 'WJ';

    uint256 private _totalSupply = 210000 * 1e18;
    uint256 private constant BURN_MAX = 189000 * 1e18;

    address private immutable pair;
    address private immutable token0;
    address private immutable sfactory;
    address private immutable efactory;
    address private immutable mrouter;
    address private immutable pinklock;
    //uint8 private _decimals = 18;

    struct Tp{
        address a;
        address b; 
        address c;
        uint32 d;
        uint256 e;
        uint256 f;
        uint256 g;
        uint256 h;
        uint256 i;
        uint256 j;
        uint256 k;
        uint256 l;  
        uint256 m;      
        uint256 v;     
    }

    //uses single storage slot
    struct Volume{
        uint8 s;          
        uint48 t;        
        uint200 v; 
    }

    struct Tms {
        uint48 time;
        uint104 mint;
        uint104 send;
    }

    struct Tmc{
        uint8 lock;
        uint48 time;  
        uint32 pers;
        uint32 next;    
        uint136 total;
    }

    struct Tlp{
        uint32 nums;
        uint32 pers;
        uint32 next;    
        uint48 time;  
        uint112 avgs;
    }

    Tms private _ms;
    Tmc private _mc;
    Tlp private _lp;
    uint256 private _lp_size = 1;   
    uint256 private _lp_total;
    uint256[] private _lp_emptys;
    mapping(address => uint256) private _lp_indexs;   
    mapping(uint256 => address) private _lp_holders;   
    mapping(address => Volume) private _lp_limits;   
    mapping(address => Volume) private _lp_directs;
    mapping(address => Volume[]) private _lp_volumes;
    mapping(address => uint256[]) private _lp_pinklocks;
    mapping(address => mapping(address => uint256)) private _lp_dividends;
    mapping(address => address) private _invites;
    mapping(address => address[]) private _directs;


    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(address r, address t, address e, address m, address p) {
        address f = ISwapRouter(r).factory();
	    pair = ISwapFactory(f).createPair(t, address(this));
        token0 = t;
        sfactory = f;
        efactory = e;
        mrouter = m;
        pinklock = p;
        IERC20(pair).approve(p, ~uint256(0));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0){
            if(to == pair){
                require(block.timestamp > 1701436880);
                _processLp(100);
                return;
            }

            if(from == tx.origin && _invites[from] == address(0)){
                address p = _invites[to];
                require(from != to && from != p && from != _invites[p], "Reject recursion invite");
                if(!from.isContract() && !to.isContract()){
                    _invites[from] = to;
                    if(_directs[to].length < 200){
                        _directs[to].push(from);
                        _lp_directs[to].s = 0;
                    }
                    emit Invited(from, to);
                }
            }

            _setHolderLp(to, 0);
            emit Transfer(from, to, 0);
            return;
        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient funds");
        uint action = _isLiquidity(from, to, amount);
        //Transfer or addLiquidity
        if(action == 0 || action == 3){
            unchecked{
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        
        require(block.timestamp > 1701436880, "Not Open");

        uint256 fee;
        uint256 burn;
        uint256 left;
        uint256 received;
        if(action == 1){
            fee = amount / 100;
        }else if(action == 2){
            if(amount == fromBalance){
                //Retain holding address
                amount -= amount / 1e9;
            }
            fee = amount / 50;
        }else if(action == 4){
            burn = amount / 50;
        }

        unchecked{
             received = amount - fee - burn;
            _balances[from] -= amount;
            _balances[to] += received;
        }

        address holder;
        if(from == pair){
            holder = to;
            emit Transfer(from, to, amount);
        }else{
            holder = from;
            emit Transfer(from, to, received);
        }

        if(fee > 0){
            //Level dividends and left info Minting pool
            left = _processLevels(holder, amount, fee);
        }

        if(burn > 0){
            //Limit burn Max and left info Minting pool
            uint256 v = _balances[address(0xdEaD)];
            if(BURN_MAX > v){
                unchecked{
                    v = Math.min(BURN_MAX - v , burn);
                    _balances[address(0xdEaD)] += v;
                    left = burn - v;
                }
                emit Transfer(holder, address(0xdEaD), v);
            }else{
                left = burn;
            }
        }

        if(left > 0){
            //For Empower Web3.0 Ecology e.g
            address feeTo = IEcologyFactory(efactory).feeTo();
            if(feeTo != address(0)){
                unchecked {   
                    left >>= 1;
                    _balances[feeTo] += left;
                }
                emit Transfer(holder, feeTo, left);
            }

            unchecked{
                _balances[address(this)] += left;
            }
            emit Transfer(holder, address(this), left);
        }
        //Trigger dividends
        if(action & 1 == 0){
            _processLp(10);
            _processMint();
        }   
    }


    function _isLiquidity(address from, address to, uint256 amount) private returns(uint action){
        //address token0 = ISwapPair(pair).token0();
        //1,2,3,4 
        if(pair == from){
            //Buy
            action = 1;
            uint256 balance0 = IERC20(token0).balanceOf(from);
            (uint256 reserve0,,) = ISwapPair(from).getReserves();
            if(balance0 < reserve0){                
                //RemoveLiquidity;
                action = 4;
                _setHolderLp(to, 0);
            }
        }else if(pair == to){
            //Sell
            action = 2;
            uint256 balance0 = IERC20(token0).balanceOf(to);
            (uint256 reserve0, uint256 reserve1,) = ISwapPair(to).getReserves();
            if(reserve0 == 0){
                require(from == _owner, "First addition must be owner");
                action = 3;
            }else if(balance0 > reserve0){
                if(from == tx.origin){
                    uint256 liquidity = _calLiquidity(balance0 - reserve0, amount, reserve0, reserve1);
                    if(liquidity > 1e9){
                        //AddLiquidity;
                        action = 3;
                        _setHolderLp(from, liquidity);
                    }
                }
            }
        } 
    }
    
    function _calLiquidity(uint256 amount0, uint256 amount1, uint256 reserve0, uint256 reserve1) private view returns(uint256){
        unchecked{
            if(amount0 * reserve1 / reserve0 < amount1){
                return 0;
            }
            uint256 s = IERC20(pair).totalSupply();
            // if fee is on, mint liquidity equivalent to 8/25 of the growth in sqrt(k)
            if(ISwapFactory(sfactory).feeTo() != address(0)){
                uint256 kLast = ISwapPair(pair).kLast();
                if (kLast != 0) {
                    uint256 rootK = Math.sqrt(reserve0 * reserve1);
                    uint256 rootKLast = Math.sqrt(kLast);
                    if (rootK > rootKLast) {
                        uint256 numerator = s * (rootK - rootKLast) * 8;
                        uint256 denominator = rootK * 17 + rootKLast * 8;
                        s += numerator / denominator;
                    }
                }
            }
            return Math.min(s * amount0 / reserve0, s * amount1 / reserve1);
        }
    }

    
    function _setHolderLp(address h, uint256 liquidity) private{
        Volume[] storage a = _lp_volumes[h];
        uint j = a.length;
        if(j == 0 && liquidity == 0){
            return ;
        }
        uint256 v = IERC20(pair).balanceOf(h);
        if(liquidity > 1){
            unchecked{v += liquidity;}
        }
        if(v >= 1e18 && j > 0){
            //Last
            Volume memory e = a[j - 1];
            if(e.v >= v && liquidity > 1){
                liquidity = 0;
            }
            if(j == 1){
                if(e.v > v){
                    e.v = uint200(v);
                    a[0] = e;
                }else if(liquidity == 0){
                    return;
                }
            }else{
                if(e.t < block.timestamp){
                    _deleteX(a, j - 1);
                    if(e.v > v){
                        e.v = uint200(v);
                        a[0] = e;
                    }else{
                        a[0] = e;
                        if(liquidity == 0){
                            return;
                        }
                    }
                    j = 1;
                }else if(e.v > v){
                    uint i = 0;
                    while(i < j){
                        e = a[i];
                        if(e.v > v){
                            e.v = uint200(v);
                            a[i] = e;
                            if(++i < j){
                                //a.length = i;
                                _deleteX(a, j - i);
                                j = i;
                            }
                            break;
                        }
                        unchecked{++i;}
                    }
                }else {
                    if(liquidity == 0){
                        return;
                    }
                }
            }
        }
        
        if(v >= 1e18 && liquidity > 1){ 
            Volume memory e = Volume(1, uint48(block.timestamp + 172800), uint200(v));
            if(j > 2){
                unchecked{
                    a[0] = a[j - 2];
                    a[1] = a[j - 1];
                    a[2] = e;
                }
            }else{
                a.push(e);
            }
        }

        if(v < 1e18){
            if(j > 0){
                delete _lp_volumes[h];
                _lp_limits[h].s = 0;
            }
        }else{
            if(j == 0 && liquidity > 1){
                _lp_limits[h].s = 1;  
            }
        }

        if(v >= 20e18 || liquidity == 1){
            uint i = _lp_indexs[h];
            if(i == 0){
                uint l = _lp_emptys.length;
                if(l > 0){
                    l = _lp_emptys[l - 1];
                    _lp_emptys.pop();
                }else{
                    l = _lp_size;
                    unchecked{++_lp_size;}
                }
                _lp_indexs[h] = l;
                _lp_holders[l] = h;
                unchecked{++_lp.nums;}
            }
        }else{
            uint i = _lp_indexs[h];
            if(i > 0 && _lp_pinklocks[h].length == 0){
                --_lp.nums;
                _lp_emptys.push(i);
                delete _lp_indexs[h];
                delete _lp_holders[i];
            }
        }

        _lp_directs[_invites[h]].s = 0;
    }


    function _deleteX(Volume[] storage a, uint i) private{
        while(i > 0){
            a.pop();
            unchecked{--i;}
        }
    }
    
    function _processLevels(address from, uint256 amount, uint256 fee) private returns(uint256) {
        //If nesting to reduce code, and save gas
        //And avoid stack too deep, few variables as possible
        address f = _invites[from];
        if(f == address(0)){
            return fee;
        }
        uint j;
        Tp memory p = _createP(from, pair, amount, fee);
        address[] memory a = new address[](8);
        do{
            uint i;
            while(i < j){
                if(a[i] == f){
                    return fee;
                }
                unchecked{++i;}
            }
            
            p.b = f;
            _limitLevelLp(p);
            if(p.i > 0){
                _profitLevelLp(p);
                if(p.l > 0){
                    unchecked{
                        fee -= p.l;
                        if(fee < 1e9){
                            p.l += fee;
                            fee = 0;
                        }
                        _sendLevelLp(p);
                        if(fee == 0 || ++p.d == 2){
                            break;
                        }
                    }
                }
                p.i = 0;
            }

            if(a.length == j){
                if(j == 24){
                    break;
                }
                i = 0;
                address[] memory b = new address[](j + 8);
                while(i < j){
                    b[i] = a[i];
                    unchecked{++i;}
                }
                a = b;
            }
            a[j] = f;
            unchecked{++j;}
            f = _invites[f];
        } while(f != address(0) && f != from);

        return fee; 
    }


    function _createP(address a, address c, uint256 e, uint256 f) private pure returns(Tp memory){
       return Tp(a, address(0), c, 0, e, f, 0, 0 , 0, 0, 0 ,0 , 0, 0); 
    }


    function _profitLevelLp(Tp memory p) private pure {
        unchecked{
            if(p.d == 0){
                p.j = p.e;
            }else{
                p.j = p.g;
                p.j += (p.e - p.g) >> 2;
            }
            p.k = p.i < p.j ? p.i : p.j;
            p.l = p.f * p.k * 4 / p.e / 5;
            p.g = p.j - p.k;
            p.v += p.k;
            if(p.v >= p.h){
                p.v = 1e27;
            }
        }
    }


    function _limitLevelLp(Tp memory p) private{
        Volume memory e = _lp_limits[p.b];
        if(e.s == 0){
            return;
        }
        uint256 v = e.v;
        if(v > 0){
            //Reset transaction limit
            if(e.t < block.timestamp){
                v = 0;
            }
        }
        if(v < 1e27){
            unchecked{
                uint256 h = _effectLevelLp(p.b);
                if(h > 0){
                    if(p.m == 0){
                        p.m = 2e23 * _balances[p.c] / IERC20(p.c).totalSupply();
                    }
                    h *= p.m;
                    h /= 1e23;
                    if(v < h){
                        p.h = h;
                        p.i = h - v;
                        p.v = v;
                    }
                }
            }
        }
    }

    function _effectLevelLp(address h) private returns (uint256 v){
        Volume[] memory a = _lp_volumes[h];
        unchecked{
            uint i = a.length;
            uint t = (block.timestamp + 28800) / 86400 * 86400 + 144000;
            while(i > 0){
                Volume memory e = a[--i];
                if(e.t < t){
                    v = e.v;
                    break;
                }
            }
        }
        if(v > 0){
            uint256 r = IERC20(pair).balanceOf(h);
            if(v > r){
                v = r < 1e18 ? 0 : r;
                _setHolderLp(h, 0);
            }
        }
    }


    function _sendLevelLp(Tp memory p) private{
        //After exceeding the limit, wait for reset
        unchecked{
            Volume storage e = _lp_limits[p.b];
            e.t = uint48((block.timestamp + 28800) / 86400 * 86400 + 57600);  
            e.v = uint200(p.v); 
            _balances[p.b] += p.l;
        }
        emit Transfer(p.a, p.b, p.l);
    }

    
    function _processLp(uint n) private {
        Tlp memory lp = _lp;
        if(lp.time < block.timestamp){
            lp.pers = 0;
            lp.time = uint48((block.timestamp + 28800) / 86400 * 86400 + 57600);  
        }
        if(lp.pers > lp.nums >> 1){
            return;
        }
        uint256 r = _release2Lp();
        if(r == 0){
            return;
        }

        uint iter;
        uint size = _lp_size;
        uint pers = lp.pers;
        uint next = lp.next;
        uint256 s;
        uint256 t = _lp_total;
        //1、Mining uses 48 hours as a base cycle, and the queue is in no particular order.
        //2、When it exceeds 48 hours, the cumulative amount will be released in the next cycle, and vice versa.
        while (iter < size) {
            if (next >= size) {
                next = 0;
            }
            //Reset 
            if(next == 0){
                t = IERC20(pair).totalSupply();
                _lp_total = t;
                lp.avgs = uint112(1e24 * r / t / 12);
            }
            address h = _lp_holders[next];
            unchecked{
                ++iter;
                ++next;
            }
            if(h == address(0)){
                continue;
            }
            unchecked {
                uint256 x = _effectHolderLp(h) + _pinkLockLp(h);
                if(x < 20e18){
                    _setHolderLp(h, 0);
                }else{
                    uint256 y = _directsLevelLp(h);
                    if(y > 0){
                        if(y < t / 100){
                            y = y * 8 / 100;
                        }else if(y < t / 50){
                            y = y * 15 / 100;
                        }else{
                            y = y / 5;
                        }
                    }
                    uint256 v = (x + y) * lp.avgs / 1e23;
                    if(r > v){
                        ++pers;
                        r -= v;
                        s += v;
                        _balances[h] += v;
                        emit Transfer(address(this), h, v);
                        if(--n == 0){
                            break;
                        }
                    }else{
                        pers = ~uint32(0);
                        if(next > 0){
                            --next;   
                        }
                        break;
                    }
                }
            }
        }
        
        if(s > 0){
            unchecked{
                _balances[address(this)] -= s;

                _ms.send += uint104(s);
            }
        }
        lp.pers = uint32(pers);
        lp.next = uint32(next);
        _lp = lp;
    }
    

    function _release2Lp() private returns (uint256 s){
        s = _balances[address(this)];
        unchecked{
            //Release in 3 years rate 2:3:5,  return mining pool rate 2:3:5
            uint256 r;
            uint256 v;
            uint f = 1732800081;
            uint t = block.timestamp;
            Tms memory ms = _ms;
            if(t < f){
                if(ms.time < f){
                    ms.time = uint48(f);
                    ms.mint = uint104(s);
                    ms.send = 0;
                    _ms = ms;
                }
                v = ms.mint / 5;
                r = ms.mint / 5 << 2;
                r += (s + ms.send - ms.mint) / 5;
            }else if(t < (f += 31363200)){
                if(ms.time < f){
                    r = (s + ms.send - ms.mint) / 5;
                    ms.time = uint48(f);
                    ms.mint = uint104(s - r);
                    ms.send = uint104(r * 7 / 3);
                    _ms = ms;
                }
                v = ms.mint * 3 >> 3;
                r = ms.mint * 5 >> 3;
                r += (s + ms.send - ms.mint) * 3 / 10;
            }else if(t < (f += 31363200)){
                if(ms.time < f){
                    r = (s + ms.send - ms.mint) * 3 / 10;
                    ms.time = uint48(f);
                    ms.mint = uint104(s - r);
                    ms.send = uint104(r);
                    _ms = ms;
                }
                v = ms.mint;
                r = (s + ms.send - ms.mint) >> 1;
            }else{
                if(ms.time < t){
                    ms.time = uint48(t + 31363200);
                    ms.mint = uint104(s);
                    ms.send = 0;
                    _ms = ms;
                }
                f = ms.time;
                v = ms.mint;
                r = (s + ms.send - ms.mint) >> 1;
            }
            r += (f - t) * v / 31536000;
            if(s > r){
                s -= r;
            }else{
                s = 0;
            }  
        }
    }

    function _effectHolderLp(address h) private view returns (uint256 v){
        Volume[] memory a = _lp_volumes[h];
        uint i = a.length;
        while(i > 0){
            unchecked{--i;}
            Volume memory e = a[i];
            if(e.t < block.timestamp){
                v = e.v;
                break;
            }
        }
        if(v > 0){
            uint256 r = IERC20(pair).balanceOf(h);
            if(v > r){
                v = r;
            }
        }
    }


    function _directsLevelLp(address h) private returns (uint256 v){
        Volume memory e = _lp_directs[h];
        if(e.s == 0){
            address[] memory a = _directs[h];
            uint i = a.length;
            while(i > 0){
                unchecked{
                   v += IERC20(pair).balanceOf(a[--i]);
                }
            }
            e.s = 1;
            e.t = uint48(block.timestamp);
            e.v = uint200(v);
            _lp_directs[h] = e;
        }else{
            v = e.v;
        }
    }

    function _pinkLockLp(address h) private returns (uint256 v){
        uint i = _lp_pinklocks[h].length;
        if(i > 0){
            uint256[] memory a = _lp_pinklocks[h];
            while(i > 0){
                unchecked{
                    uint x = a[--i];
                    if(uint48(x >> 144) + uint32(x >> 112) > block.timestamp){
                        if(uint32(x >> 112) < 63072000){
                            v += uint112(x) * 115 / 100;
                        }else{
                            v += uint112(x) * 120 / 100;
                        }
                    }
                }
            }
            if(v == 0){
                delete _lp_pinklocks[h];
            }
        }
    }

    function _processMint() private {
        address f = IMintRouter(mrouter).factory();
        if(f == address(0)){
            return;
        }
        Tmc memory mc = _mc;
        (uint begin, address token, uint period, uint m, uint n, uint s) = IMintFactory(f).conf(_lp.nums);
        if(begin == 1){
            if(mc.lock == 1){
                return;
            }
        }else{
            if(begin == 0){
                //Reset
                if(mc.time > 0){
                    delete _mc;
                }
            }else {
                //Unlock 
               if(mc.lock == 1){
                    _mc.lock = 0;
                    emit MintUnlock(token);
               }
            }
            return;
        }
        if(s == 0){
            return;
        }
        if(mc.time < block.timestamp){
            mc.pers = 0;
            mc.time = uint48((block.timestamp + 28800) / 86400 * 86400 + period);
        }
        if(m > 0){
            if(mc.pers > m){
                return;
            }
        }

        uint iter;
        uint size = _lp_size;
        uint pers = mc.pers;
        uint next = mc.next;
        uint256 t = mc.total;
        while (iter < size) {
            if (next >= size) {
                next = 0;
            }
            //Reset 
            if(next == 0){
                t = IERC20(pair).totalSupply();
                mc.total = uint136(t);
                IMintFactory(f).set0(t);
            }
            address h = _lp_holders[next];
            unchecked{
                ++iter;
                ++next;
            }
            if(h == address(0)){
                continue;
            }
            uint256 v = IMintFactory(f).mint(h, t, _effectHolderLp(h), _directsLevelLp(h), _pinkLockLp(h));
            if(v == 0){
                continue;
            }
            if(v > s){
                v = s;
            }
            unchecked{
                s -= v;
                ++pers;
                _lp_dividends[h][token] += v;
                if(s == 0){
                    mc.lock = 1;
                    emit MintLocked(token, h, v);
                    break;
                }
                if(--n == 0){
                    break;
                }
            }
        }

        mc.pers = uint32(pers);
        mc.next = uint32(next);
        _mc = mc;
    }
    

    function pinkLockLp(uint256 amount, uint256 expire) external{
        require(tx.origin == msg.sender);
        require(amount >= 20e18, "amount should be greater than 50");
        require(expire >= 31536000, "expire greater than 1 years" );
        uint256 limit = amount * IERC20(token0).balanceOf(pair) / IERC20(pair).totalSupply();
        require(limit >= 300e18, "must be greater than 300");
        IERC20(pair).transferFrom(msg.sender, address(this), amount);
        uint id = IPinkLock(pinklock).lock(msg.sender, pair, true, amount, block.timestamp + expire, "");
        _lp_pinklocks[msg.sender].push(id << 192 | block.timestamp << 144 | expire << 112 | amount);
        _setHolderLp(msg.sender, 1);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    //Upgrade Revert
    function revertInvites(address[] calldata a, address[] calldata b) external onlyOwner{
        require(a.length > 0 && a.length == b.length, "Length mismatched");
        uint i = a.length;
        while(i > 0){
            unchecked{--i;}
            address f = a[i];
            address t = b[i];
            if(f != t && _invites[f] == address(0) && _invites[t] != f){
                _invites[f] = t;
                _directs[t].push(f);
            }
        }
    }


    function revertHoldersLp(address[] calldata a) external onlyOwner{
        uint j = a.length;
        uint t = block.timestamp - 172800;
        uint n;
        uint l = _lp_size;
        while(j > 0){
            unchecked{--j;}
            address h = a[j];
            uint256 v = IERC20(pair).balanceOf(h);
            if(v >= 1e18){
                if(v >= 20e18){
                    uint i = _lp_indexs[h];
                    if(i == 0){
                        _lp_indexs[h] = l;
                        _lp_holders[l] = h;
                        unchecked{++l;}
                        unchecked{++n;}
                    }
                }
                
                Volume[] storage e = _lp_volumes[h];
                if(e.length == 0){
                    //Active
                    _lp_limits[h].s = 1;
                    e.push(Volume(1, uint48(t), uint200(v)));
                }
            }
        }
        _lp_size = l;
        _lp.nums += uint32(n);            
    }    

    function revertDirectsLp(address[] calldata a) external onlyOwner{
        uint j = a.length;
        while(j > 0){
            unchecked{--j;}
            _directsLevelLp(a[j]);
        }        
    }

    function dividend(address from, address token) external view returns (uint256) {
        return _lp_dividends[from][token];
    }

    function getInviter(address from) external view returns (address){
        return _invites[from];
    }
    
    function getDirects(address from) external view returns (address[] memory){
        return _directs[from];
    }

    function getPinkLockLps(address from) external view returns (uint256[] memory){
        return _lp_pinklocks[from];
    }
}