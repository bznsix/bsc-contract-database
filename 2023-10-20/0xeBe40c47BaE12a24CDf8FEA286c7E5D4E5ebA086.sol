// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ISwapRouter {
    function factory() external pure returns (address);
   function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function totalSupply() external view returns (uint256);

    function kLast() external view returns (uint256);

    function sync() external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

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

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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
}

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            )))));
    }
}

contract TokenHelper is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    address public  uniswapV2Pair;
    address public lpRewardToken;

    constructor(address uniswapV2Pair_, address lpRewardToken_){
        uniswapV2Pair = uniswapV2Pair_;
        lpRewardToken = lpRewardToken_;
    }
    
    function process(uint256 gas) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        uint256 totalLp = IERC20(uniswapV2Pair).totalSupply();
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                return;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(totalLp);
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true; 
    }
    
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function withdrawToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        if (address(0) == coin) {
            payable(receiver).transfer(amount);
        } else {
            IERC20 coinContract = IERC20(coin);
            coinContract.transfer(receiver, amount);
        }
    }
    
}

contract BuyBackHelper is Ownable {

    ISwapRouter public immutable uniswapV2Router;
    address public constant bep20usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public targetToken;

    constructor(address uniswapV2Router_, address targetToken_){
        uniswapV2Router = ISwapRouter(uniswapV2Router_);
        targetToken = targetToken_;
    }

    function buyBack(uint256 buyBackAmount) public onlyOwner {
        address[] memory path = new address[](2);
        path[0] = bep20usdt;
        path[1] = targetToken;
        if (IERC20(bep20usdt).balanceOf(address(this)) >= buyBackAmount) {
            IERC20(bep20usdt).approve(address(uniswapV2Router), buyBackAmount);
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buyBackAmount,
                0,
                path,
                address(0xdead),
                block.timestamp
            );
        }
    }

    function withdrawToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        if (address(0) == coin) {
            payable(receiver).transfer(amount);
        } else {
            IERC20 coinContract = IERC20(coin);
            coinContract.transfer(receiver, amount);
        }
    }
}

contract JJG is ERC20, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    ISwapRouter public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address public bep20usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public walletA = 0x16eA315E7DE9b5d195dfEea9Cad4DBE271c3476B;
    address public walletB = 0x08De65C2a020b8B372e345013Aab29275A1811c5;

    uint256 public buyFee = 400;
    uint256 public sellFee = 3000;
    uint256 public transferFee = 400;

    uint256 public SwapFeeAmount;
    uint256 public BuyBackAmount;

    bool public enableSwap;
    uint256 public openTime;
    TokenHelper public tokenHelper;
    BuyBackHelper public buyBackHelper;
    uint256 public swapTokensAtAmount;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 days;
    uint256 public minAmount = 200 * (10**18);
    uint256 public minBuyBackAmt = 10 * (10**18);
    bool public enableBuyBack;
    uint256 public maxHold = 10 * (10**18);

    bool public _strictCheck = true;
    bool private swapping;
    mapping(address => bool) public blackList;
    mapping(address => bool) public _isExcludedFromFees;
    mapping (address => bool) public isDividendExempt;

    EnumerableSet.AddressSet private group0;
    // max 100
    EnumerableSet.AddressSet private whiteGroup0;
    // max 300
    EnumerableSet.AddressSet private whiteGroup1;
    uint256 public sellOrderCount;

    mapping(address => UserInfo) private _userInfo;


    constructor() ERC20("xx10", "xx10") {
        uint256 totalSupply = 12888 * (10**18);
        swapTokensAtAmount = 3 * (10**18);

        require(address(this) > bep20usdt, "try next nonce transaction");
        ISwapRouter _uniswapV2Router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = ISwapFactory(_uniswapV2Router.factory())
            .createPair(address(this), bep20usdt);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        tokenHelper = new TokenHelper(_uniswapV2Pair, bep20usdt);
        buyBackHelper = new BuyBackHelper(address(_uniswapV2Router), address(this));

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(tokenHelper)] = true;
        _isExcludedFromFees[address(buyBackHelper)] = true;
        _isExcludedFromFees[address(uniswapV2Router)] = true;
        _isExcludedFromFees[walletA] = true;
        _isExcludedFromFees[walletB] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(tokenHelper)] = true;

        _mint(owner(), totalSupply);
    }

    receive() external payable {}

    function withdrawToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        if (address(0) == coin) {
            payable(receiver).transfer(amount);
        } else {
            IERC20 coinContract = IERC20(coin);
            coinContract.transfer(receiver, amount);
        }
    }

    function withdrawHelperToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        tokenHelper.withdrawToken(coin, receiver, amount);
    }

    function withdrawBuyBackHelperToken(
        address coin,
        address receiver,
        uint256 amount
    ) public onlyOwner {
        buyBackHelper.withdrawToken(coin, receiver, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!blackList[from] && !blackList[to], "ERC20: banned address");
        if(amount == 0) { super._transfer(from, to, 0); return;}

        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        bool isAddLP;
        bool isRemoveLP;
        UserInfo storage userInfo;

        uint256 addLPLiquidity;
        if (to == uniswapV2Pair) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                takeFee = false;
            }
        }

        uint256 removeLPLiquidity;
        if (from == uniswapV2Pair) {
            if (_strictCheck) {
                removeLPLiquidity = _strictCheckBuy(amount);
            } else {
                removeLPLiquidity = _isRemoveLiquidity(amount);
            }
            if (removeLPLiquidity > 0) {
                require(_userInfo[to].lpAmount >= removeLPLiquidity);
                _userInfo[to].lpAmount -= removeLPLiquidity;
                isRemoveLP = true;
            }
        }

        if (BuyBackAmount >= minBuyBackAmt && from != uniswapV2Pair) {
            try buyBackHelper.buyBack(BuyBackAmount) {} catch {}
            BuyBackAmount = 0;
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        uint256 usdtAmt = IERC20(bep20usdt).balanceOf(address(tokenHelper));
        if (from != address(this)) {
            if (isAddLP && !isDividendExempt[from]) {
                tokenHelper.setShare(from);
            } else if (!_isExcludedFromFees[from] && usdtAmt >= minAmount) {
                try tokenHelper.process(distributorGas) {} catch {}
            }
        }
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        
        if (takeFee) {
            bool isSell;
            if (isRemoveLP) {
                if (block.timestamp < openTime) {
                    to = address(0xdead);
                } else {
                    if (_userInfo[to].preLP) {
                        to = address(0xdead);
                    }
                }
            } else if (from == uniswapV2Pair) { // Buy
                require(enableSwap, "stop swap");
                buyCheck(to, amount);
                amount = takeBuyFee(from, amount);
                require(balanceOf(to) + amount <= maxHold, "Exceeded maximum hold limit");
                if (enableBuyBack) {
                    buyBack(amount);
                }
            } else if (to == uniswapV2Pair) { // Sell
                require(enableSwap, "stop swap");
                isSell = true;
                uint256 minHolderAmount = balanceOf(from).mul(99).div(100);
                if(amount > minHolderAmount) {
                    amount = minHolderAmount;
                }
                amount = takeSellFee(from, amount);
            } else {
                amount = takeTransferFee(from, amount);
            }

            bool canSwap = SwapFeeAmount >= swapTokensAtAmount;
            if(canSwap && !swapping && isSell) {
                swapping = true;
                (uint256 usdtAmount, uint lpAmount) = _swap2USDT(SwapFeeAmount);
                SwapFeeAmount = 0;
                _distributeSwapFee(usdtAmount, lpAmount);
                swapping = false;
            }
        }
        super._transfer(from, to, amount);
    }

    function takeBuyFee(address from, uint256 amount) private returns (uint256 amountAfter) {
        amountAfter = amount;
        
        uint256 BFee = amount.mul(buyFee).div(10000);
        if (BFee > 0) {
            super._transfer(from, address(this), BFee);
            amountAfter = amountAfter.sub(BFee);
            SwapFeeAmount = SwapFeeAmount.add(BFee);
        }
        
    }

    function takeSellFee(address from, uint256 amount) private returns (uint256 amountAfter) {
        amountAfter = amount;
        
        uint256 SFee = amount.mul(sellFee).div(10000);
        if (SFee > 0) {
            super._transfer(from, address(this), SFee);
            amountAfter = amountAfter.sub(SFee);
            SwapFeeAmount = SwapFeeAmount.add(SFee);
        }
    }

    function takeTransferFee(address from, uint256 amount) private returns (uint256 amountAfter) {
        amountAfter = amount;

        uint256 TFee = amount.mul(transferFee).div(10000);
        if (TFee > 0) {
            super._transfer(from, address(0xdead), TFee);
            amountAfter = amountAfter.sub(TFee);
        }
    }

    function _swap2USDT(uint256 amount) internal returns (uint256 usdtAmount, uint256 lpAmount) {
        IERC20 invoke = IERC20(bep20usdt);
        uint256 initalUSDT = invoke.balanceOf(address(tokenHelper));
        swapToken2USDT(amount, address(tokenHelper));
        usdtAmount = invoke.balanceOf(address(tokenHelper)).sub(initalUSDT);
        
        lpAmount = usdtAmount.mul(2).div(10);
        tokenHelper.withdrawToken(bep20usdt, address(this), usdtAmount.sub(lpAmount));
    }

    function swapToken2USDT(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = bep20usdt;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _distributeSwapFee(uint256 usdtAmount, uint lpAmount) internal {
        uint256 walletAmt = usdtAmount.mul(5).div(10);
        IERC20 usdtToken = IERC20(bep20usdt);
        {
            uint256 walletAAmt = walletAmt.div(2);
            usdtToken.transfer(walletA, walletAAmt);
            usdtToken.transfer(walletB, walletAmt.sub(walletAAmt));
        }

        {
            uint256 group0Length = group0.length();
            uint256 group0Amt = usdtAmount.sub(lpAmount).sub(walletAmt);
            if (group0Length > 0) {
                uint256 per = group0Amt.div(group0Length);
                for (uint i = 0; i < group0Length; i++) {
                    usdtToken.transfer(group0.at(i), per);
                }
            }
        }
    }

    function buyBack(uint256 amount) private {
        uint256 buyBackAmount = amount.div(4);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = bep20usdt;
        uint[] memory amounts = uniswapV2Router.getAmountsOut(buyBackAmount, path);
        uint256 needUsdtAmt = amounts[1];
        BuyBackAmount = BuyBackAmount.add(needUsdtAmt);
    }

    function buyCheck(address to, uint256 amount) internal view {
        uint256 nt = block.timestamp;
        if (nt > openTime && nt < (openTime + 60)) {
              if (whiteGroup0.contains(to)) {
                require(amount <= 8 * (10**18));
              } else if (whiteGroup1.contains(to)) {
                require(amount <= 4 * (10**18));
              } else {
                revert();
              }
        }
    }
    
    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _strictCheckBuy(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(uniswapV2Pair).totalSupply()) /
            (balanceOf(uniswapV2Pair) - amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
                //strictCheckBuy
                require(balanceOther >= amountOther + rOther);
            }
        }
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = ISwapPair(uniswapV2Pair).totalSupply();
        address feeTo = ISwapFactory(uniswapV2Router.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = ISwapPair(uniswapV2Pair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = SafeMath.sqrt(r0 * r1);
                uint256 rootKLast = SafeMath.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = SafeMath.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = SafeMath.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(bep20usdt).balanceOf(uniswapV2Pair);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
        ISwapPair mainPair = ISwapPair(uniswapV2Pair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = bep20usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity = (amount * ISwapPair(uniswapV2Pair).totalSupply() + 1) /
            (balanceOf(uniswapV2Pair) - amount - 1);
        }
    }


    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP, bool preLP
    ) {
        lpAmount = _userInfo[account].lpAmount;
        lpBalance = IERC20(uniswapV2Pair).balanceOf(account);
        excludeLP = isDividendExempt[account];
        UserInfo storage userInfo = _userInfo[account];
        preLP = userInfo.preLP;
    }

    function getUserLPShare(address shareHolder) public view returns (uint256 pairBalance){
        pairBalance = IERC20(uniswapV2Pair).balanceOf(shareHolder);
        uint256 lpAmount = _userInfo[shareHolder].lpAmount;
        if (lpAmount < pairBalance) {
            pairBalance = lpAmount;
        }
    }

    //###########################################################################
    //#                                                                         #
    //#                              Setter                                     #
    //#                                                                         #
    //###########################################################################

    function updateDividendExempt(address account, bool dividend) public onlyOwner {
        isDividendExempt[account] = dividend;
    }
    
    function updateBlackList(address account, bool isBlack) public onlyOwner {
        if (blackList[account] != isBlack) {
            blackList[account] = isBlack;
        }
    }

    function updateBlackListBatch(address[] calldata accounts, bool isBlack) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blackList[accounts[i]] = isBlack;
        }
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }

    function setMinPeriod(uint256 period_) public onlyOwner {
        minPeriod = period_;
    }

    function setMinAmount(uint256 _amount) public onlyOwner {
        minAmount = _amount;
    }

    function setMaxHold(uint256 _amount) public onlyOwner {
        maxHold = _amount;
    }

    function setMinBuyBackAmt(uint256 _amount) public onlyOwner {
        minBuyBackAmt = _amount;
    }

    function setEnableSwap(bool _enable) public onlyOwner {
        enableSwap = _enable;
    }

    function setEnableBuyBack(bool _enable) public onlyOwner {
        enableBuyBack = _enable;
    }

    function setWalletA(address _new) public onlyOwner {
        walletA = _new;
    }

    function setWalletB(address _new) public onlyOwner {
        walletB = _new;
    }

    function peekGroup0() view public returns (address[] memory) {
        return group0.values();
    }

    function group0Add(address address_) public onlyOwner {
        require(group0.length() <= 8, "cannot exceed 8 addresses");
        require(!group0.contains(address_), "address already exists");
        group0.add(address_);
    }

    function group0BatchAdd(address[] calldata addresses_) public onlyOwner {
        for (uint i = 0; i < addresses_.length; i++) {
            group0Add(addresses_[i]);
        }
    }

    function group0Remove(address address_) public onlyOwner {
        require(group0.contains(address_), "address does't exist");
        group0.remove(address_);
    }

    function setSellFee(uint256 _fee) public onlyOwner {
        sellFee = _fee;
    }

    function setBuyFee(uint256 _fee) public onlyOwner {
        buyFee = _fee;
    }

    function setTransferFee(uint256 _fee) public onlyOwner {
        transferFee = _fee;
    }

    function setOpenTime(uint256 _ts) public onlyOwner {
        openTime = _ts;
    }

    function peekWhiteGroup0() view public returns (address[] memory) {
        return whiteGroup0.values();
    }

    function whiteGroup0Add(address address_) public onlyOwner {
        require(whiteGroup0.length() <= 100, "cannot exceed 300 addresses");
        require(!whiteGroup0.contains(address_), "address already exists");
        whiteGroup0.add(address_);
    }

    function whiteGroup0BatchAdd(address[] calldata addresses_) public onlyOwner {
        for (uint i = 0; i < addresses_.length; i++) {
            whiteGroup0Add(addresses_[i]);
        }
    }

    function whiteGroup0Remove(address address_) public onlyOwner {
        require(whiteGroup0.contains(address_), "address does't exist");
        whiteGroup0.remove(address_);
    }

    function peekWhiteGroup1() view public returns (address[] memory) {
        return whiteGroup1.values();
    }

    function whiteGroup1Add(address address_) public onlyOwner {
        require(whiteGroup1.length() <= 300, "cannot exceed 300 addresses");
        require(!whiteGroup1.contains(address_), "address already exists");
        whiteGroup1.add(address_);
    }

    function whiteGroup1BatchAdd(address[] calldata addresses_) public onlyOwner {
        for (uint i = 0; i < addresses_.length; i++) {
            whiteGroup1Add(addresses_[i]);
        }
    }

    function whiteGroup1Remove(address address_) public onlyOwner {
        require(whiteGroup1.contains(address_), "address does't exist");
        whiteGroup1.remove(address_);
    }

    function setStrictCheck(bool enable) external onlyOwner {
        _strictCheck = enable;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyOwner {
        _userInfo[account].lpAmount = lpAmount;
    }

    function initLPAmounts(address[] memory accounts, uint256[] memory lpAmounts) public onlyOwner {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmounts[i];
            userInfo.preLP = true;
            tokenHelper.setShare(accounts[i]);
            unchecked{
                ++i;
            }
        }
    }

}