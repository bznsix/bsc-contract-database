// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

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
}

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _values(set._inner);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

contract GVTOKEN is IERC20, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _tOwnedU;
    mapping(address => mapping(address => uint256)) private _allowances;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 private _tTotal;
    address public _uniswapV2Pair;
    address public _token;
    uint256 public _startTimeForSwap;
    mapping(address => bool) public _isDividendExempt;
    uint256 public _minPeriod;
    address router;
    IUniswapV2Router02 public _uniswapV2Router;
    EnumerableSet.AddressSet _shareholders;
    mapping(uint256 => address) public _dividendpool;
    bool public _enMint = false;
    address private _fromAddress;
    address private _toAddress;

    constructor() {
        router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address admin = 0x787F79866d1e74cf494F0693e544107832cb91e0;
        transferOwnership(admin);
        _token = 0x55d398326f99059fF775485246999027B3197955;
        _dividendpool[0] = 0x029106e2025578C830d56936D9EF9AD990019993;
        _dividendpool[1] = 0x9bfe75d65EA547AFA0c3899ab55ad6642884f330;
        _name = "GV";
        _symbol = "GV";
        _decimals = uint8(18);
        _tTotal = 13000000000 * (10**uint256(_decimals));
        _minPeriod = 3600 * 24;
        _tOwned[admin] = _tTotal;
        _uniswapV2Router = IUniswapV2Router02(router);

        emit Transfer(address(0), admin, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (_startTimeForSwap == 0 && msg.sender == address(_uniswapV2Router)) {
            _startTimeForSwap = block.timestamp;
            _uniswapV2Pair = recipient;
            IERC20(address(this)).approve(router, _tTotal);
        }
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 txamount = 0;
        uint256 burnamount = 0;
        if(amount == balanceOf(from)){
            amount = amount.mul(9999).div(10000);
        }
        if (_enMint) {
            uint256 pricenow = getprice(
                address(this),
                _token,
                amount.mul(98).div(100)
            );
            if (!_isDividendExempt[to]) {
                _tOwnedU[to] = _tOwnedU[to].add(pricenow);
            }

            if (!_isDividendExempt[from]) {
                if (_tOwnedU[from] > pricenow) {
                    _tOwnedU[from] = _tOwnedU[from].sub(pricenow);
                } else if (_tOwnedU[from] > 0 && _tOwnedU[from] < pricenow) {
                    burnamount = getprice(
                        _token,
                        address(this),
                        pricenow.sub(_tOwnedU[from])
                    ).mul(20).div(100);
                    _tOwnedU[from] = 0;
                } else {
                    burnamount = getprice(_token, address(this), pricenow)
                        .mul(20)
                        .div(100);
                    _tOwnedU[from] = 0;
                }
            }

            if (from == _uniswapV2Pair && !_isDividendExempt[to]) {
                if (_isRemoveLiquidity()) {
                    txamount = amount.mul(4).div(100);
                    _basicTransfer(from, _dividendpool[0], txamount.div(4));
                    _basicTransfer(from, address(0xdead), txamount.div(4));
                    _basicTransfer(from, _dividendpool[1], txamount.div(2));
                } else {
                    txamount = amount.mul(2).div(100);
                    _basicTransfer(from, _dividendpool[0], txamount.div(4));
                    _basicTransfer(from, address(0xdead), txamount.div(4));
                    _basicTransfer(from, _dividendpool[1], txamount.div(2));
                }
            }
            if (to == _uniswapV2Pair && !_isDividendExempt[from]) {
                if (_isAddLiquidity()) {
                    burnamount = 0;
                } else {
                    txamount = amount.mul(2).div(100);
                    _basicTransfer(from, _dividendpool[0], txamount.div(4));
                    _basicTransfer(from, address(0xdead), txamount.div(4));
                    _basicTransfer(from, _dividendpool[1], txamount.div(2));
                }
            }

            if (burnamount > 0) {
                _basicTransfer(from, _dividendpool[1], burnamount);
            }
        }

        _basicTransfer(from, to, amount.sub(txamount).sub(burnamount));
        if (_enMint) {
            if (_fromAddress == address(0)) _fromAddress = from;
            if (_toAddress == address(0)) _toAddress = to;
            if (
                !_isDividendExempt[_fromAddress] &&
                _fromAddress != _uniswapV2Pair
            ) setShare(_fromAddress);
            if (!_isDividendExempt[_toAddress] && _toAddress != _uniswapV2Pair)
                setShare(_toAddress);
            _fromAddress = from;
            _toAddress = to;
            process();
        }
    }

    function setEnMint(bool val) external onlyOwner {
        _enMint = val;
    }

    function setMinTime(uint256 val) external onlyOwner {
        _startTimeForSwap = val;
    }

    function getC() public view returns (uint256) {
        return (block.timestamp - _startTimeForSwap) / _minPeriod;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(_uniswapV2Pair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _token;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        IUniswapV2Pair mainPair = IUniswapV2Pair(_uniswapV2Pair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();
        address tokenOther = _token;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function getHolder() public view returns (address[] memory) {
        return _shareholders.values();
    }

    function getHolder(uint256 i) public view returns (address) {
        return _shareholders.at(i);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function setIsDividendExempt(address addr, bool value) external onlyOwner {
        _isDividendExempt[addr] = value;
    }

    function getprice(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory price = IUniswapV2Pair(router).getAmountsOut(
            amount,
            path
        );
        return price[1];
    }

    function setShare(address shareholder) private {
        if (_shareholders.contains(shareholder)) {
            if (IERC20(_uniswapV2Pair).balanceOf(shareholder) == 0)
                _shareholders.remove(shareholder);
            return;
        }
        _shareholders.add(shareholder);
    }

    uint256 public lastClaimTime;
    uint256 public everyDivi = 50;
    uint256 public _currentIndex;
    mapping(uint256 => uint256) public theDayMint;
    mapping(uint256 => uint256) public theDayMinted;

    function process() private {
        if (
            (block.timestamp - _startTimeForSwap) / _minPeriod < lastClaimTime
        ) {
            return;
        }
        if (
            theDayMint[getC()] == theDayMinted[getC()] &&
            theDayMinted[getC()] > 0
        ) {
            return;
        }

        uint256 shareholderCount = _shareholders.length();

        if (shareholderCount == 0) return;
        if (_currentIndex == 0) {
            theDayMint[getC()] = balanceOf(_dividendpool[1]);
            theDayMinted[getC()] = 0;
        }

        uint256 ss = everyDivi > shareholderCount
            ? shareholderCount
            : everyDivi;

        for (uint256 i; i < ss; i++) {
            if (getC() < lastClaimTime) {
                break;
            }
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
                lastClaimTime = getC().add(1);
                break;
            }

            uint256 amount = theDayMint[getC()]
                .mul(
                    IERC20(_uniswapV2Pair).balanceOf(
                        _shareholders.at(_currentIndex)
                    )
                )
                .div(getLpTotal());

            if (
                amount < 1e13 ||
                _isDividendExempt[_shareholders.at(_currentIndex)] ||
                balanceOf(_dividendpool[1]) < amount
            ) {
                _currentIndex++;
                continue;
            }

            if (theDayMinted[getC()] + amount >= theDayMint[getC()]) {
                amount = theDayMint[getC()] > theDayMinted[getC()]
                    ? (theDayMint[getC()] - theDayMinted[getC()])
                    : 0;
            }
            _basicTransfer(
                _dividendpool[1],
                _shareholders.at(_currentIndex),
                amount
            );

            theDayMinted[getC()] += amount;
            _currentIndex++;
        }
    }

    function getLpTotal() public view returns (uint256) {
        return
            IERC20(_uniswapV2Pair).totalSupply() -
            IERC20(_uniswapV2Pair).balanceOf(
                0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE
            ) -
            IERC20(_uniswapV2Pair).balanceOf(address(0xdead));
    }
}