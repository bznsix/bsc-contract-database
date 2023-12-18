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
contract Pool {
    constructor(address _father, address reToken){
        IERC20(reToken).approve(_father, 2**256 - 1);
    }
}

contract MTCTOKEN is IERC20, Ownable {
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
    uint256 public _swaptime;
    uint256 public _minPeriod;
    uint256 public topValue;
    address public router;
    bool public _enMint = false;
    address public  bonuspool;
    address public  community;
    address public  sediment;
    address public  firstbonus;
    mapping(address => uint256) public addLPTime;
    mapping(address => uint256) public addLPAmount;
    mapping(address => bool) public _isDividendExempt;
    mapping(address => bool) public _nodefirst;
    mapping(uint256 => uint256) public advertrate;

    mapping(address => address) public invite;
    mapping(address => uint256) public invitecounts;
    mapping(address => uint256) public invitenodes;
    mapping(address => bool) public invitenodeown;
    mapping(address => mapping(address => uint256)) private invitefirst;
    
    EnumerableSet.AddressSet _shareholders;
    EnumerableSet.AddressSet _communitynodes;
    EnumerableSet.AddressSet _deletelist;
    address private  admin = 0x0f7F4E5acF0b58DB0be9e09f8fa4DE2bD064b0c2;

    constructor() {
        router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        transferOwnership(admin);
        setAdvertRate();
        _token = 0x55d398326f99059fF775485246999027B3197955;
        sediment = 0x1E7273def54b8f2499C31532880efD4406D704F1;
        firstbonus = 0x82d3CFd137bdfC7f9f6028b562E8b97D15AB493D;
        _name = "MTC";
        _symbol = "MTC";
        _decimals = uint8(18);
        _tTotal = 140000700000 * (10**uint256(_decimals));
        _minPeriod = 3600 * 24;
        _tOwned[admin] = _tTotal;
        topValue = 8;

        emit Transfer(address(0), admin, _tTotal);
        
        Pool snOne = new Pool(address(this), _token);
        bonuspool = address(snOne);
        
        Pool snTwo = new Pool(address(this), _token);
        community = address(snTwo);
        
        _isDividendExempt[address(this)] = true;
        _isDividendExempt[bonuspool] = true;
        _isDividendExempt[community] = true;
        _isDividendExempt[sediment] = true;
        _isDividendExempt[firstbonus] = true;
        _isDividendExempt[address(0)] = true;
        _isDividendExempt[address(0xdead)] = true;
        _isDividendExempt[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true;

        _communitynodes.add(0xF9Eb7b1c8395e8F796d5f76a2522e38A19E84336);
        _communitynodes.add(0xD9d19c2e191A70cA917781BB3D926b64B6A4E1f5);
        _communitynodes.add(0x9c6dBD3Ed1d0899b4da3363D71C6682f958342c2);
        _communitynodes.add(0x6bA6C753d021ae66d5c456dc7D2D41725B71Add3);
        _communitynodes.add(0x86Dc89E213187D9242Ab2499f27759FdF9b3220c);
        _communitynodes.add(0xF2a8e8adD98D529983DA4f09d7DaD61F419D1b22);
        _communitynodes.add(0x237A2620bA60bfB0DFA059dbA443902BDee707B6);
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
        if (_startTimeForSwap == 0 && msg.sender == router) {
            _startTimeForSwap = 1702468800;
            _uniswapV2Pair = recipient;
            _isDividendExempt[_uniswapV2Pair] = true;
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
        if(_currentIndex == 0 && _deletelist.length() > 0){
            for (uint256 i = 0; i < _deletelist.length(); i++) {
                if (_shareholders.contains(_deletelist.at(0))) _shareholders.remove(_deletelist.at(0));
                _deletelist.remove(_deletelist.at(0));
            }
        }
        if (_enMint) {
            uint256 pricenow = getprice( address(this), _token, amount.mul(97).div(100));
            if (!_isDividendExempt[to]) {
                _tOwnedU[to] = _tOwnedU[to].add(pricenow);
            }
            if (!_isDividendExempt[from]) {
                if (_tOwnedU[from] > pricenow) {
                    _tOwnedU[from] = _tOwnedU[from].sub(pricenow);
                } else if (_tOwnedU[from] > 0 && _tOwnedU[from] < pricenow) {
                    burnamount = getprice( _token, address(this), pricenow.sub(_tOwnedU[from]) ).mul(20).div(100);
                    _tOwnedU[from] = 0;
                } else {
                    burnamount = getprice(_token, address(this), pricenow).mul(20) .div(100);
                    _tOwnedU[from] = 0;
                }
            }
            if (from == _uniswapV2Pair && !_isDividendExempt[to]) {
                if (_isRemoveLiquidity()) {
                    uint256 removeLp = getremovelp(amount);
                    if(_nodefirst[to] || (removeLp.add(balanceOf(to))).mul(99) > addLPAmount[to].mul(100)){
                        removeLp = addLPAmount[to];
                        txamount = amount.mul(99).div(100);
                        _pushtxamount(from,amount,0,79,20);
                    }else {
                        txamount = amount.mul(4).div(100);                    
                        _pushtxamount(from,amount,1,2,1);
                    }
                    if(invitenodeown[to] && invitenodes[invite[to]] > 0){
                        invitenodes[invite[to]] -= 1 ;
                        invitenodeown[to] = false;
                    }
                    addLPAmount[to] = addLPAmount[to].sub(removeLp);
                } else {
                    if(block.timestamp < (_swaptime + 600)){
                        require(_getSwapU() <= 50*10**18);
                        txamount = amount.mul(30).div(100);
                        _basicTransfer(from, firstbonus, amount.mul(27).div(100));
                    }else{
                        txamount = amount.mul(3).div(100);
                    }
                    _pushtxamount(from,amount,1,1,1);
                }
            }
            if (to == _uniswapV2Pair && !_isDividendExempt[from]) {
                if (_isAddLiquidity()) {
                    burnamount = 0;
                    uint256 amountU = _getSwapU();
                    uint256 amountlp = getaddlp(amountU,amount);

                    _shareholders.add(from);
                    addLPTime[from] = block.timestamp;
                    addLPAmount[from] = addLPAmount[from].add(amountlp);

                    if( amountU >= 50*10**18 && invite[from] != address(0) && invitenodeown[from] == false){
                        invitenodes[invite[from]] += 1 ;
                        invitenodeown[from] = true;
                    }
                } else {
                    if(block.timestamp < (_swaptime + 600)){
                        txamount = amount.mul(30).div(100);
                        _basicTransfer(from, firstbonus, amount.mul(27).div(100));
                    }else{
                        txamount = amount.mul(3).div(100);
                    }
                    _pushtxamount(from,amount,1,1,1);
                }
            }
            process();
        }else{
            if(from == _uniswapV2Pair || (to == _uniswapV2Pair && !_isAddLiquidity())){
                require(from == owner());
            }
        }
        if( burnamount > 0 ){
            _advert(from,burnamount.mul(30).div(100));
            _basicTransfer(from, bonuspool, burnamount.mul(70).div(100));
        }

        if (!_isDividendExempt[from] && !_isDividendExempt[to]) {
            if (invite[to] == address(0) && from != to){
                invitefirst[from][to] = amount;
            }
        }
        if ( invite[from] == address(0) && invitefirst[to][from] > 0 && invitecounts[from] == 0 ) {
            invite[from] = to;
            invitecounts[to] = invitecounts[to].add(1);
        }
        
        uint256 comamount = balanceOf(community);
        uint256 comnumber = _communitynodes.length();
        if(comamount > 1*10**18 &&  comnumber > 0){
            for (uint256 j = 0; j < comnumber; j++) {
                _basicTransfer( community, _communitynodes.at(j), comamount.div(comnumber) );
            }                    
        }
        
        _basicTransfer(from, to, amount.sub(txamount).sub(burnamount));
    }

    function _pushtxamount(address from, uint256 amount, uint256 rate1, uint256 rate2, uint256 rate3) private {
        if( rate1 > 0 ){
            _basicTransfer(from, community, amount.mul(rate1).div(100));
        }
        if(rate2 > 0 ){
            _basicTransfer(from, bonuspool, amount.mul(rate2).div(100));
        }
        if(rate3 > 0 ){
            _basicTransfer(from, address(0xdead), amount.mul(rate3).div(100));
        }
    }

    function setEnMint(bool val) external onlyOwner {
        _enMint = val;
        _swaptime = block.timestamp;
    }

    function setTopValue(uint256 number) public {        
        require(admin == msg.sender);
        topValue = number;
    }

    function setSediment(address addr) public {        
        require(admin == msg.sender);
        sediment = addr;
    }

    function setNodeFirst(address addr, uint256 value) public {        
        require(admin == msg.sender);
        if(invite[addr] != address(0)){
            invitenodes[invite[addr]] += 1 ;
        }
        invitenodeown[addr] = true;
        _nodefirst[addr] = true;
        addLPAmount[addr] = value;
        addLPTime[addr] = block.timestamp;
        _shareholders.add(addr);
    }

    function setCommunity(address addr, bool value) public {        
        require(admin == msg.sender);
        if(value){
            _communitynodes.add(addr);
        }else{
            if (_communitynodes.contains(addr)) _communitynodes.remove(addr);
        }
    }

    function getCommunity() public view returns (address[] memory) {
        return _communitynodes.values();
    }

    function setAdvertRate(uint256 number, uint256 value) public {
        require(admin == msg.sender);
        advertrate[number] = value;
    }

    function setAdvertRate() private {
        for (uint256 i = 0; i < 11; i++) {
            advertrate[i] = 10;
        }
    }

    function setMinTime(uint256 val) external onlyOwner {
        _startTimeForSwap = val;
    }

    function getC() public view returns (uint256) {
        return (block.timestamp - _startTimeForSwap) / _minPeriod;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (_token < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(_token).balanceOf(_uniswapV2Pair);
        isRemove = r >= bal;
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (_token < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(_token).balanceOf(_uniswapV2Pair);
        isAdd = bal > r;
    }

    function _getSwapU() internal view returns (uint256 amount) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (_token < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(_token).balanceOf(_uniswapV2Pair);
        amount = bal.sub(r);
    }

    function getaddlp( uint256 amount0, uint256 amount1 ) private  view returns (uint256) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 totallp = IERC20(_uniswapV2Pair).totalSupply();
        uint256 liquidity;
        if (_token < address(this)) {
            liquidity = Math.min( amount0.mul(totallp) / r0, amount1.mul(totallp) / r1 );
        } else {
            liquidity = Math.min( amount1.mul(totallp) / r0, amount0.mul(totallp) / r1 );
        }
        return liquidity;
    }
    function getremovelp( uint256 amount) private  view returns (uint256) {
        return amount.mul( IERC20(_uniswapV2Pair).totalSupply() ).div( balanceOf(_uniswapV2Pair).sub(amount) );
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

    uint256 public lastClaimTime;
    uint256 public everyDivi = 100;
    uint256 public _currentIndex;
    mapping(uint256 => uint256) public theDayMint;
    mapping(uint256 => uint256) public theDayMinted;

    function process() private {
        uint256 today = getC();
        if (today < lastClaimTime) {
            return;
        }
        if(theDayMinted[today] >= theDayMint[today] && theDayMinted[today] > 0){
            return;
        }
        uint256 shareholderCount = _shareholders.length();
        if (shareholderCount == 0) return;
        if (_currentIndex == 0) {
            theDayMint[today] = balanceOf(bonuspool);
            theDayMinted[today] = 0;
        }

        uint256 ss = everyDivi > shareholderCount ? shareholderCount : everyDivi;
        address user;

        for (uint256 i; i <= ss; i++) {
            if (today < lastClaimTime) {
                break;
            }
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
                lastClaimTime = today + 1;
                break;
            }
            user = _shareholders.at(_currentIndex);

            if(addLPAmount[user] < 1*10**18 || IERC20(_uniswapV2Pair).balanceOf(user).mul(100) < addLPAmount[user].mul(99)){
                _deletelist.add(user);
                _currentIndex++;
                continue;
            }

            uint256 amount = theDayMint[today].mul(addLPAmount[user]).div(getLpTotal());
            uint256 amountnow = balanceOf(_uniswapV2Pair).mul(addLPAmount[user]).div(IERC20(_uniswapV2Pair).totalSupply()).mul(topValue).div(100);
            if(amount > amountnow){
                amount = amountnow;
            }

            if ( amount < 1e13 || balanceOf(bonuspool) < amount || addLPTime[user] + (26 * 3600) > block.timestamp) {
                _currentIndex++;
                continue;
            }

            if (theDayMinted[today] + amount >= theDayMint[today]) {
                amount = theDayMint[today] > theDayMinted[today] ? (theDayMint[today] - theDayMinted[today]) : 0;
            }
            if(amount > 0){
                _basicTransfer( bonuspool, user, amount );
            }

            theDayMinted[today] += amount;
            _currentIndex++;
        }
    }

    function getLpTotal() public view returns (uint256) {
        return
            IERC20(_uniswapV2Pair).totalSupply() -
            IERC20(_uniswapV2Pair).balanceOf( 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE ) -
            IERC20(_uniswapV2Pair).balanceOf(address(0xdead));
    }
    
    function _advert(address from, uint256 amount) private {
        address recieve = from;
        uint256 feeamount = 0;
        for (uint256 i = 0; i < advertrate[0]; i++) {
            recieve = invite[recieve];
            if( recieve == address(0)){
                break;
            }
            if (invitenodes[recieve] > i && invitenodeown[recieve]) {
                feeamount = feeamount.add(amount.mul(advertrate[i+1]).div(100));
                _basicTransfer(from, recieve, amount.mul(advertrate[i+1]).div(100));
            }
        }
        if ( amount > feeamount ) {
            _basicTransfer(from, sediment, amount.sub(feeamount));
        }
    }
}