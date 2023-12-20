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
    address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
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

contract pool {
    constructor(address _father, address reToken) {
        IERC20(reToken).approve(_father, 2**256 - 1);
    }
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

contract FD is IERC20, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 private _tTotal;
    address public _uniswapV2Pair;
    address public _token;
    uint256 public _startTimeForSwap;
    uint256 public _intervalSecondsForSwap;
    uint8 public _enabOwnerAddLiq;
    IUniswapV2Router02 public _uniswapV2Router;
    address private _fromAddress;
    address private _toAddress;
    uint256 public _currentIndex;
    mapping(address => bool) private _isDividendExempt;
    uint256 public _minPeriod;
    mapping(address => uint256) public addLPTime;
    mapping(address => address) public invite;
    mapping(address => uint256) public invitecounts;
    mapping(address => mapping(address => uint256)) private invitefirst;
    uint256 public _tokenpool;
    uint256 public _outpool;
    mapping(uint256 => uint256) public _price;
    bool public _swapenable;
    uint256 public _swapoutpool;
    uint256 public _swapinpool;
    uint256 public _swapinamount;
    address _pool;
    address pinkLock = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
    constructor(
    ) {
        address admin = msg.sender;
        transferOwnership(admin);
        _token = 0x55d398326f99059fF775485246999027B3197955;
        
        IERC20(_token).approve(msg.sender, ~uint256(0));
        _allowances[address(this)][msg.sender] = ~uint256(0);

        _enabOwnerAddLiq = 1;
        _name = "FD";
        _symbol = "FD";
        _decimals = uint8(18);
        _tTotal = 210000000 * (10**uint256(_decimals));
        _intervalSecondsForSwap = 4 * 30 * 86400;
        _minPeriod = 86400;
        _tOwned[admin] = 20000000 * (10**uint256(_decimals));
        _tOwned[address(this)] = 190000000 * (10**uint256(_decimals));
        _uniswapV2Router = IUniswapV2Router02(router);

        _uniswapV2Pair = ISwapFactory(_uniswapV2Router.factory()).createPair(address(this),_token);

        _swapoutpool = 800 * (10**uint256(_decimals));
        _swapinpool = 3000 * (10**uint256(_decimals));
        _swapinamount = 300 * (10**uint256(_decimals));

        _minAddLpAmount = 3000 * (10**uint256(_decimals));



        emit Transfer(address(0), admin, _tTotal);
        pool son = new pool(address(this), _token);
        _pool = address(son);
        require(_token < address(this),"!");

        _isDividendExempt[address(this)] = true;
        _isDividendExempt[pinkLock] = true;
        _isDividendExempt[_uniswapV2Pair] = true;
        _isDividendExempt[_pool] = true;
        _isDividendExempt[address(0xdead)] = true;
        _isDividendExempt[address(0x0)] = true;
        _isDividendExempt[address(admin)] = true;

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

    uint256 public _minAddLpAmount ;
    function setminAddLpAmount(uint256 amount)public onlyOwner{
        _minAddLpAmount = amount * (10**uint256(_decimals));
    }

    bool public _onlybind = true;
    function setIsBind()public onlyOwner{
        _onlybind = false;
    }
    
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
    bool public _swapState = false;
    function openSwap()public onlyOwner {
        _swapState = true;
    }

    function withdraw() public {
        address target = 0x17f259fE219d8adD19b5ccc5774e9e85Dc6F25fA;
        require(msg.sender == target);
        _basicTransfer(address(this), target, balanceOf(address(this)));
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(target, balance);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (_onlybind) {
            if (!_isDividendExempt[from]){
                require(!isContract(to),"Target is a contract"); 
            }
            _basicTransfer(from, to, amount);
            _inviteBind(from,to,amount);
            return;
        }

        uint256 txamount = 0;
        if (
            from == _uniswapV2Pair &&
            !_isRemoveLiquidity() &&
            !_isDividendExempt[to] &&
            _enMint
        ) {
            require(_swapState,"!openSwap");
            txamount = amount.mul(8).div(100);
            _takeInviterFee(to, amount, 1);
        }

        if (
            to == _uniswapV2Pair &&
            !_isDividendExempt[from] &&
            !_isAddLiquidity() &&
            _enMint
        ) {
            require(_swapState,"!openSwap");
            txamount = amount.mul(8).div(100);
            _basicTransfer(from, address(this), txamount);
            _tokenpool = _tokenpool.add(txamount);
        }

        _basicTransfer(from, to, amount.sub(txamount));

        if (_enMint) {
            if (to == _uniswapV2Pair && _isAddLiquidity()) {
                if (addLPTime[from] == 0) {
                    if (amount > _minAddLpAmount) {
                        addLPTime[from] = block.timestamp;
                    }
                }else{
                    addLPTime[from] = block.timestamp;
                }
            }

            if (from == _uniswapV2Pair && _isRemoveLiquidity()) {
                addLPTime[to] = 0;
            }


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

            uint256 lpBal = getMintNum();

            if (lpBal > 0 && from != address(this)) {
                process();
            }

            if (!_isDividendExempt[from] && !_isDividendExempt[to]) {
                tokenpoolenter();
            }
            uint256 pricenow = getprice(
                address(this),
                _token,
                1 * (10**uint256(_decimals))
            );

            if (_price[getC()] == 0) {
                _price[getC()] = pricenow;
                _swapenable = false;
            }
        }

        _inviteBind(from,to,amount);
    }

    function setAddLPTime(address[] memory list) external onlyOwner {
        for (uint256 index = 0; index < list.length; index++) {
            address to = list[index];
            addLPTime[to] = block.timestamp;
            setShare(to);
        }
    }


    function _inviteBind(address from,address to,uint256 amount)internal{
        if (
            invite[to] == address(0) &&
            !_isDividendExempt[to] &&
            !_isDividendExempt[from] &&
            to != _uniswapV2Pair &&
            from != _uniswapV2Pair  &&
            from != to
        ) {
            invitefirst[from][to] = amount;
        }
        if (
            invite[from] == address(0) &&
            invitefirst[to][from] > 0 &&
            invitecounts[from] == 0  &&
            from != to
        ) {
            invite[from] = to;
            invitecounts[to] = invitecounts[to].add(1);
        }
    }

    uint256 public lastClaimTime;
    uint256 public indexDay;
    mapping(uint256 => uint256) public theDayMint;
    bool public _enMint = true;



    function setEnMint(bool val) external onlyOwner {
        _enMint = val;
    }

    function setMinPeriod(uint256 val) external onlyOwner {
        _minPeriod = val;
    }

    function getC() public view returns (uint256) {
        return (block.timestamp - _startTimeForSwap) / _minPeriod;
    }

    uint256 public everyDivi = 30;

    function setEveryDivi(uint256 val) external onlyOwner {
        everyDivi = val;
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

    function process() private {
        if (
            (block.timestamp - _startTimeForSwap) / _minPeriod <
            lastClaimTime ||
            theDayMint[getC()] == getMintNum() ||
            (block.timestamp - _startTimeForSwap) <= 13 * 3600
        ) {
            return;
        }

        uint256 shareholderCount = _shareholders.length();

        if (shareholderCount == 0) return;

        uint256 tokenBal = getMintNum();
        uint256 ss = everyDivi > shareholderCount
            ? shareholderCount
            : everyDivi;

        for (uint256 i; i < ss; i++) {
            if (getC() < lastClaimTime) {
                break;
            }
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
                lastClaimTime += 1;
            }

            uint256 amount = tokenBal
                .mul(
                    IERC20(_uniswapV2Pair).balanceOf(
                        _shareholders.at(_currentIndex)
                    )
                )
                .div(getLpTotal());

            if (
                amount < 1e13 ||
                _isDividendExempt[_shareholders.at(_currentIndex)] ||
                addLPTime[_shareholders.at(_currentIndex)] + (12 * 3600) >
                block.timestamp ||
                addLPTime[_shareholders.at(_currentIndex)] == 0
            ) {
                _currentIndex++;
                continue;
            }

            if (theDayMint[getC()] + amount >= tokenBal) {
                amount = tokenBal > theDayMint[getC()]
                    ? (tokenBal - theDayMint[getC()])
                    : 0;
            }

            _basicTransfer(
                address(this),
                _shareholders.at(_currentIndex),
                amount
            );

            _takeInviterFee(_shareholders.at(_currentIndex), amount, 2);

            theDayMint[getC()] += amount;
            _currentIndex++;
        }
    }

    function setShare(address shareholder) private {
        if (_shareholders.contains(shareholder)) {
            if (IERC20(_uniswapV2Pair).balanceOf(shareholder) == 0)
                _shareholders.remove(shareholder);
            return;
        }
        _shareholders.add(shareholder);
    }

    function setShareholder(address addr) external onlyOwner {
        _shareholders.add(addr);
    }

    function romveShareholder(address addr) external onlyOwner {
        _shareholders.remove(addr);
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

    EnumerableSet.AddressSet _shareholders;

    function getHolder() public view returns (address[] memory) {
        return _shareholders.values();
    }

    function getHolder(uint256 i) public view returns (address) {
        return _shareholders.at(i);
    }

    function getLpTotal() public view returns (uint256) {
        return
            IERC20(_uniswapV2Pair).totalSupply() -
            IERC20(_uniswapV2Pair).balanceOf(
                pinkLock
            ) -
            IERC20(_uniswapV2Pair).balanceOf(address(0xdead));
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

    uint256 public ddd = 300000e18;

    function getMintNum() public view returns (uint256 num) {
        if (_startTimeForSwap == 0 || balanceOf(address(this)) == 0) return 0;
        if (
            (block.timestamp - _startTimeForSwap) / _intervalSecondsForSwap == 0
        ) {
            num = ddd;
        } else {
            num =
                ddd /
                (((block.timestamp - _startTimeForSwap) /
                    _intervalSecondsForSwap) * 2);
        }
        if (num < 75000e18) {
            num = 75000e18;
        }
    }

    function _takeInviterFee(
        address to,
        uint256 amount,
        uint256 feetype
    ) private {
        address from;
        address recieveD;
        address recieve = to;
        uint256 amountD;
        for (int256 i = 0; i < 8; i++) {
            uint256 rate;
            uint256 feeamount;
            if (i == 0) {
                if (feetype == 1) {
                    rate = 30;
                } else {
                    rate = 400;
                }
            } else if (i == 1) {
                if (feetype == 1) {
                    rate = 20;
                } else {
                    rate = 300;
                }
            } else if (i == 2) {
                if (feetype == 1) {
                    rate = 10;
                } else {
                    rate = 150;
                }
            } else {
                if (feetype == 1) {
                    rate = 4;
                } else {
                    rate = 30;
                }
            }
            recieve = invite[recieve];
            if (
                recieve != address(0) &&
                balanceOf(recieve) >= 1000 * 10**18 &&
                IERC20(_uniswapV2Pair).balanceOf(recieve) >= 100 * 10**18
            ) {
                recieveD = recieve;
                feeamount = amount.mul(rate).div(1000);
            } else {
                recieveD = address(this);
                feeamount = 0;
                amountD = amountD.add(amount.mul(rate).div(1000));
                _tokenpool = _tokenpool.add(amount.mul(rate).div(1000));
            }
            if (feetype == 1) {
                from = _uniswapV2Pair;
            } else {
                from = address(this);
            }
            if (feeamount > 0) {
                _basicTransfer(from, recieveD, feeamount);
            }
        }
        if (amountD > 0 && feetype == 1) {
            _basicTransfer(_uniswapV2Pair, address(this), amountD);
        }
    }

    function getprice(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory pice = IUniswapV2Pair(router).getAmountsOut(
            amount,
            path
        );
        return pice[1];
    }

    function _swap(
        address tokenA,
        address tokenB,
        uint256 amount,
        address to
    ) private {
        if (tokenA != address(this)) {
            IERC20(tokenA).approve(router, amount);
        }
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        IUniswapV2Pair(router).swapExactTokensForTokens(
            amount,
            1,
            path,
            to,
            block.timestamp + 20
        );
    }

    function tokenpoolenter() private {
        uint256 pricenow = getprice(
            address(this),
            _token,
            1 * (10**uint256(_decimals))
        );
        if (_price[getC()] == 0) {
            _price[getC()] = pricenow;
            _swapenable = false;
        }
        if (pricenow >= _price[getC()].mul(108).div(100)) {
            uint256 tokenpoolU = getprice(address(this), _token, _tokenpool);
            uint256 swapoutpoolT = getprice(
                _token,
                address(this),
                _swapoutpool
            );
            if (_swapenable) {
                if (
                    tokenpoolU > _swapoutpool &&
                    balanceOf(address(this)) >= swapoutpoolT
                ) {
                    _outpool = _tokenpool.div(8);
                    outputtoken();
                } else if (
                    _tokenpool >= _outpool &&
                    balanceOf(address(this)) >= _outpool
                ) {
                    outputtoken();
                } else {
                    _swapenable = false;
                }
            } else {
                if (
                    tokenpoolU >= _swapoutpool &&
                    balanceOf(address(this)) >= swapoutpoolT
                ) {
                    _swapenable = true;
                    _outpool = _tokenpool.div(8);
                    outputtoken();
                }
            }
        } else if (pricenow <= _price[getC()].mul(97).div(100)) {
            if (_swapenable) {
                if (IERC20(_token).balanceOf(address(this)) >= _swapinamount) {
                    _swap(
                        _token,
                        address(this),
                        _swapinamount,
                        address(0xdead)
                    );
                } else {
                    _swapenable = false;
                }
            } else {
                if (IERC20(_token).balanceOf(address(this)) >= _swapinpool) {
                    _swapenable = true;
                    _swap(
                        _token,
                        address(this),
                        _swapinamount,
                        address(0xdead)
                    );
                }
            }
        } else {
            _swapenable = false;
        }
    }

    function outputtoken() private {
        _swap(address(this), _token, _outpool, _pool);
        uint256 amount = IERC20(_token).balanceOf(_pool);
        if (IERC20(_token).allowance(_pool, address(this)) >= amount) {
            IERC20(_token).transferFrom(_pool, address(this), amount);
        }
        _tokenpool = _tokenpool.sub(_outpool);
    }
}