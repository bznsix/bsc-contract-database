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
    function getSupNodes() external view returns (address[] memory);
    function getNodes() external view returns (address[] memory);
    // function getMappingCount() external view returns (uint256);

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

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
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
contract old{
    mapping(address => address) public invite;
    mapping(address => uint256) public invitecounts;
    mapping(address => bool) public _nodefirst;
}

contract GDCTOKEN is IERC20, Ownable {
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
    uint256 public _currentIndex;
    mapping(address => bool) public _isDividendExempt;
    mapping(address => bool) public _nodefirst;
    uint256 public _minPeriod;
    mapping(address => uint256) public addLPTime;
    mapping(address => uint256) public addLPAmount;
    mapping(address => address) public invite;
    mapping(address => uint256) public invitecounts;
    mapping(address => mapping(address => uint256)) private invitefirst;
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) public  userpool;
    uint256 public _tokenpool;
    uint256 public _outpool;
    mapping(uint256 => uint256) public _price;
    mapping(uint256 => uint256) public _shareRate;
    mapping(uint256 => uint256) public _supnodepool;
    bool public _swapenable;
    uint256 public _lastburntime;
    uint256 public _swapoutpool;
    uint256 public _swapuserpool;
    uint256 public _swapinamount;
    address public _operator;
    address public router;
    address public _middlepool;
    address public _remainpool;
    uint256 public ddd = 300000e18;
    uint256 public recieveTime = 3;
    address admin = 0x12c5446ad3330b253BE60A97274425507503b8C4;
    
    EnumerableSet.AddressSet _shareholders;
    EnumerableSet.AddressSet _suppernodes;
    EnumerableSet.AddressSet _nodes;
    EnumerableSet.AddressSet _deletelist;

    constructor() {
        router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _token = 0x55d398326f99059fF775485246999027B3197955;
        _operator = 0xB8db8bD54c21b0a1E75C8c82aDda1151348A9508;
        transferOwnership(admin);
        setShareRate();
        _name = "GDC";
        _symbol = "GDC";
        _decimals = uint8(18);
        _tTotal = 210000000 * (10**uint256(_decimals));
        _intervalSecondsForSwap = 60 * 24 * 3600;
        _minPeriod = 24 * 3600;
        _tOwned[admin] = 20000000 * (10**uint256(_decimals));
        _tOwned[address(this)] = 190000000 * (10**uint256(_decimals));
        _swapoutpool = 800 * (10**uint256(_decimals));
        _swapinamount = 300 * (10**uint256(_decimals));
        emit Transfer(address(0), admin, _tTotal);
        Pool son = new Pool(address(this), _token);
        Pool som = new Pool(address(this),_token);
        _middlepool = address(son);
        _remainpool = address(som);
        
        _isDividendExempt[address(this)] = true;
        _isDividendExempt[_middlepool] = true;
        _isDividendExempt[_remainpool] = true;
        _isDividendExempt[_operator] = true;
        _isDividendExempt[admin] = true;
        _isDividendExempt[address(0)] = true;
        _isDividendExempt[address(0xdead)] = true;
        _isDividendExempt[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true;
    }

    receive() external payable {
        if(msg.value >= 4 *10**18){
            _suppernodes.add(msg.sender);
        }
        if(msg.value >= 8 *10**17){
            _nodes.add(msg.sender);
        }
        uint256 usdtBalance = IERC20(_token).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = _token;
        IUniswapV2Pair(router).swapExactETHForTokens{value:msg.value}( 1, path, address(this), block.timestamp + 100 );
        if(invite[msg.sender] != address(0) && (_suppernodes.contains(invite[msg.sender]) || _nodes.contains(invite[msg.sender]))){
            IERC20(_token).transfer(invite[msg.sender], (IERC20(_token).balanceOf(address(this)).sub(usdtBalance)).mul(20).div(100));
        }
    }
    function getusdt()external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner(), amount);
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
        if (_startTimeForSwap == 0 && msg.sender == router){
            _startTimeForSwap = block.timestamp;
            _uniswapV2Pair = recipient;
            _isDividendExempt[_uniswapV2Pair] = true;
            IERC20(address(this)).approve(router, _tTotal);
            _basicTransfer(sender, recipient, amount);
        }else{
            _transfer(sender, recipient, amount);
        }
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
            if (from == _uniswapV2Pair && !_isDividendExempt[to]) {
                if (isRemoveLiquidity()){
                    if(_nodefirst[to] && getprice( address(this), _token, 1e18) < 1e18){
                        txamount = amount.mul(9999).div(10000);
                        _basicTransfer(from, address(0xdead), txamount);
                    }
                    removenode(to);
                } else {
                    require(_enMint);
                    txamount = amount.mul(5).div(100);
                    _setmintdata(to, txamount, 1,from);
                }
            }else if (to == _uniswapV2Pair && !_isDividendExempt[from]) {
                if (isAddLiquidity()) {
                    if(!_enMint){
                        _nodefirst[from] = true;
                    }
                    uint256 amountU = getlpforu();
                    uint256 amountlp = getaddlp(amountU,amount);  
                    if(amountlp > 50*10**18){
                        _shareholders.add(from);
                        addLPTime[from] = block.timestamp;
                        addLPAmount[from] = addLPAmount[from].add(amountlp);
                    }
                } else {
                    require(_enMint);
                    txamount = amount.mul(5).div(100);
                    _setmintdata(from, txamount, 2,from);
                }
            }
        if (_enMint) {
            shareinfo(from,to);
        }
        if(to == _remainpool){
            _swapmint(from);
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
        _basicTransfer(from, to, amount.sub(txamount));
    }

    uint256 public lastClaimTime;
    uint256 public totalMint;
    mapping(uint256 => uint256) public theDayMint;
    bool public _enMint = false;

    function setEnMint(bool val) external onlyOwner {
        _enMint = val;
        _lastburntime = block.timestamp;
    }
    function setShareRate() private  {
        for (uint256 i = 0; i < 8; i++) {
            if( i == 0 ){
                _shareRate[i] = 40;
            }else if( i == 1 ){
                _shareRate[i] = 30;
            }else if( i == 2 ){
                _shareRate[i] = 15;
            }else{
                _shareRate[i] = 3;
            }
        }
    }
    function setMinTime(uint256 val) external onlyOwner {
        _startTimeForSwap = val;
    }
    function setRecieveTime(uint256 val) external onlyOwner {
        recieveTime = val;
    }
    function setMappingVal(address[] memory Holder,address oldToken) external onlyOwner {
        address user;
        uint256 amount;
        old p;
        p = old(oldToken);
        for (uint256 i = 0; i < Holder.length; i++) {
            user = Holder[i];
            amount = IERC20(oldToken).balanceOf(user);
            if( p.invite(user) != address(0)){
                invite[user] = p.invite(user);
            }
            if(p.invitecounts(user) > 0){
                invitecounts[user] = p.invitecounts(user);
            }
            if(p._nodefirst(user)){
                _nodefirst[user] = true;
            }
            if( amount > 0 ){
                _basicTransfer(admin, user, amount);
            }
        }
    }
    function setMappingNodes(address oldToken) external onlyOwner {
        address[] memory supNode = IERC20(oldToken).getSupNodes();
        for (uint256 i = 0; i < supNode.length; i++) {
            _suppernodes.add(supNode[i]);
        }
        address[] memory Nodes = IERC20(oldToken).getNodes();
        for (uint256 i = 0; i < Nodes.length; i++) {
            _nodes.add(Nodes[i]);
        }
    }
    function setMappingLP(address[] memory Holder,address LPaddress, uint256 amount) external onlyOwner {
        address user;
        for (uint256 i = 0; i < Holder.length; i++) {
            user = Holder[i];
            if(amount > 50e18){
                _shareholders.add(user);
                addLPTime[user] = block.timestamp;
                addLPAmount[user] = addLPAmount[user].add(amount);
            }
            IERC20(LPaddress).transferFrom(msg.sender,user,amount);
        }
    }

    function getC() public view returns (uint256) {
        return (block.timestamp - _startTimeForSwap) / _minPeriod;
    }
    function isMinner(address user) private  view returns (bool) {
        uint256 num = 100e18;
        if ( (block.timestamp - _startTimeForSwap) / _intervalSecondsForSwap > 0 ) {
            num = num / (((block.timestamp - _startTimeForSwap) / _intervalSecondsForSwap) * 2);
        }
        if (num < 25e18) {
            num = 25e18;
        }
        if(balanceOf(user) >= 1e18 && IERC20(_uniswapV2Pair).balanceOf(user) >= num){
            return true;
        }else{
            return false;
        }
    }
    uint256 public everyDivi = 30;

    function setEveryDivi(uint256 val) external onlyOwner {
        everyDivi = val;
    }

    function getHolder() public view returns (address[] memory) {
        return _shareholders.values();
    }
    function getSupNodes() public view override returns (address[] memory) {
        return _suppernodes.values();
    }
    function getNodes() public view override returns (address[] memory) {
        return _nodes.values();
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
    function getaddlp(
        uint256 amount0,
        uint256 amount1
    ) private  view returns (uint256) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 totallp = IERC20(_uniswapV2Pair).totalSupply();
        uint256 liquidity;
        if (_token < address(this)) {
            liquidity = Math.min(
                amount0.mul(totallp) / r0,
                amount1.mul(totallp) / r1
            );
        } else {
            liquidity = Math.min(
                amount1.mul(totallp) / r0,
                amount0.mul(totallp) / r1
            );
        }
        return liquidity;
    }
    function getlpforu()
        private
        view
        returns (uint256)
    {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (_token < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(_token).balanceOf(_uniswapV2Pair);
        if (bal > r) {
            return bal.sub(r);
        }
        if (r > bal) {
            return r.sub(bal);
        }
        return 0;
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

    function outputtoken() private {
        _swap(address(this), _token, _outpool, _middlepool);
        uint256 amount = IERC20(_token).balanceOf(_middlepool);
        if (IERC20(_token).allowance(_middlepool, address(this)) > amount) {
            IERC20(_token).transferFrom(_middlepool, address(this), amount);
        }
        _tokenpool = _tokenpool.sub(_outpool);
    }

    function removenode(address to) private {
        addLPTime[to] = 0;
        addLPAmount[to] = 0;
        if (_shareholders.contains(to)) _shareholders.remove(to);
    }

    function isRemoveLiquidity()
        private
        view
        returns (bool isRemove)
    {
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

    function isAddLiquidity()
        private
        view
        returns (bool isAdd)
    {
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

    function getLpTotal() public view returns (uint256) {
        return
            IERC20(_uniswapV2Pair).totalSupply() -
            IERC20(_uniswapV2Pair).balanceOf(
                0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE
            ) -
            IERC20(_uniswapV2Pair).balanceOf(address(0xdead));
    }

    function getprice( address tokenA, address tokenB, uint256 amount ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory pice = IUniswapV2Pair(router).getAmountsOut(
            amount,
            path
        );
        return pice[1];
    }

    function getMintNum() public view returns (uint256 num) {
        if (_startTimeForSwap == 0 || balanceOf(address(this)) == 0) return 0;
        if ( (block.timestamp - _startTimeForSwap) / _intervalSecondsForSwap == 0 ) {
            num = ddd;
        } else {
            num = ddd / (((block.timestamp - _startTimeForSwap) / _intervalSecondsForSwap) * 2);
        }
        if (num < 75000e18) {
            num = 75000e18;
        }
    }
    function process(uint256 tokenBal) private  {
        uint256 today = getC();
        uint256 amountlp = tokenBal.div(2);        
        if( today == 0 || block.timestamp < (today * 24 * 3600 + _startTimeForSwap + 12 * 3600 )){
            return;
        }
        if (today < lastClaimTime || theDayMint[today] >= amountlp || balanceOf(address(this)) < tokenBal ) {
            return;
        }
        uint256 shareholderCount = _shareholders.length();

        if (shareholderCount == 0) return;

        uint256 ss = everyDivi > shareholderCount
            ? shareholderCount
            : everyDivi;
        address user;

        for (uint256 i; i <= ss; i++) {
            if (today < lastClaimTime) {
                break;
            }
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
                lastClaimTime = today+1;
                totalMint = totalMint.add(tokenBal);
                break;
            }
            user = _shareholders.at(_currentIndex);

            if(addLPAmount[user] == 0 || IERC20(_uniswapV2Pair).balanceOf(user).mul(100) < addLPAmount[user].mul(99)){
                _currentIndex++;
                continue;
            }

            uint256 amount = amountlp.mul(addLPAmount[user]).div(getLpTotal());
            if (theDayMint[today] + amount > amountlp) {
                amount = amountlp > theDayMint[today] ? (amountlp - theDayMint[today]) : 0;
            }

            if ( amount < 1e13 || _isDividendExempt[user] || addLPTime[user] + (26 * 3600) > block.timestamp) {
                _currentIndex++;
                continue;
            }
            _basicTransfer(address(this), user, amount);

            _takeInviterFee(user, amount);
            
            theDayMint[today] += amount;
            _currentIndex++;
        }
    }

    function _takeInviterFee( address to, uint256 amount) private {
        address recieveD;
        address recieve = to;
        uint256 feeamount = 0;
        for (uint256 i = 0; i < 8; i++) {
            recieve = invite[recieve];
            if ( recieve != address(0) && isMinner(recieve)) {
                recieveD = recieve;
                feeamount = amount.mul(_shareRate[i]).div(100);
            } else {
                feeamount = 0;
                _tokenpool = _tokenpool.add(amount.mul(_shareRate[i]).div(100));
            }
            if (feeamount > 0) {
                _basicTransfer(address(this), recieveD, feeamount);
            }
        }
    }

    function tokenpoolout() private {
        uint256 tokenpoolU = getprice(address(this), _token, _tokenpool);

        if(!_swapenable && tokenpoolU > _swapoutpool && balanceOf(address(this)) > _tokenpool){
            _outpool = _tokenpool.div(8);
            _swapenable = true;
        }
        if(_swapenable && (balanceOf(address(this)) < _outpool || _tokenpool < _outpool)){
            _swapenable = false;
        }
        if(_swapenable){
            outputtoken();
        }
    }

    function tokenpoolin() private {
        uint256 myamount = IERC20(_token).balanceOf(address(this));
        if(myamount > _swapinamount){
            _swap( _token, address(this), _swapinamount, address(0xdead) );
        }
    }

    function tokenpoolenter(uint256 cnow,uint256 pricenow) private {
        if (pricenow > _price[cnow].mul(108).div(100)) {
            tokenpoolout();
        } else if (pricenow < _price[cnow].mul(97).div(100) && pricenow > _price[cnow].mul(90).div(100)) {
            tokenpoolin();
        } else {
            _swapenable = false;
        }
    }

    function shareinfo(address from, address to) private {
        uint256 cnow = getC();
        uint256 pricenow = getprice( address(this), _token, 1 * (10**uint256(_decimals)));        
        if (_price[cnow] == 0) {
            _price[cnow] = pricenow;
            _swapenable = false;
            address user;
            for (uint256 i = 0; i < _shareholders.length(); i++) {
                user = _shareholders.at(i);
                if(IERC20(_uniswapV2Pair).balanceOf(user).mul(100) < addLPAmount[user].mul(99)){
                    removenode(user);
                }
            }
            if(_supnodepool[cnow -1 ] > 1e18 && balanceOf(_remainpool) > _supnodepool[cnow -1 ]){
                for (uint256 i = 0; i < _suppernodes.length(); i++) {
                    _basicTransfer(_remainpool, _suppernodes.at(i), _supnodepool[cnow -1 ].div(_suppernodes.length()));
                }
            }
        }
        if (!_isDividendExempt[from] && !_isDividendExempt[to]) {
            uint256 uniswapamount = balanceOf(_uniswapV2Pair);
            if( (block.timestamp - _lastburntime) > recieveTime * 3600 && _tokenpool < (uniswapamount.mul(3).div(100))){
                _basicTransfer(_uniswapV2Pair, _operator, uniswapamount.mul(3).div(1000));
                _basicTransfer(_uniswapV2Pair, address(this), uniswapamount.mul(7).div(1000));
                _tokenpool = _tokenpool.add(uniswapamount.mul(7).div(1000));
                IUniswapV2Pair(_uniswapV2Pair).sync();
                _lastburntime = block.timestamp;
            }
            tokenpoolenter(cnow,pricenow);
        }

        uint256 lpBal = getMintNum();
        if (lpBal > 0 && from != address(this) && totalMint.add(lpBal) < 190000000e18 && pricenow > _price[cnow].mul(103).div(100)) {
            process(lpBal);
        }
    }

    function _setmintdata( address owner, uint256 amount, uint256 freetype,address from) private  {
        uint256 usamount = getprice( address(this), _token, amount);
        userpool[owner][getC()][freetype] = userpool[owner][getC()][freetype].add(usamount);
        userpool[owner][getC()][freetype.add(2)] = userpool[owner][getC()][freetype.add(2)].add(amount);
        (address nodeown, uint256 level) = _getpuser(owner,1);
        uint256 amounted = 0;
        if(nodeown != address(0)){
            if(level == 2){
                amounted = amounted + amount.mul(60).div(100);
                _basicTransfer(from, nodeown, amount.mul(60).div(100));
            }else{
                (address supnodeown,) = _getpuser(nodeown,2);
                if(supnodeown != address(0)){
                    amounted = amounted + amount.mul(40).div(100);
                    _basicTransfer(from, supnodeown, amount.mul(40).div(100));
                }
                amounted = amounted + amount.mul(20).div(100);
                _basicTransfer(from, nodeown, amount.mul(20).div(100));
            }
        }
        if(amount.mul(60).div(100) > amounted){
            _supnodepool[getC()] = _supnodepool[getC()].add(amount.mul(60).div(100).sub(amounted));
        }
        _basicTransfer(from, _remainpool, amount.sub(amounted));
    }

    function _getpuser( address owner, uint256 freetype ) private view returns (address,uint256) {
        address puser = address(0);
        address nuser = owner;
        uint256 level = 0;
        while (puser == address(0) && nuser != address(0)){
            nuser = invite[nuser];
            if (_nodes.contains(nuser) && freetype == 1){
                puser = nuser;
                level = 1;
            }
            if (_suppernodes.contains(nuser)){
                puser = nuser;
                level = 2;
            }
        }
        return (puser,level);
    }
    
    function _swapmint(address owner) private {
        uint256 amount = 0;
        uint256 add =0;
        uint256 usadd =0;
        uint256 usnow =0;
        uint256 toknow =0;
        for (uint256 i = 0; i < getC().sub(8); i++) {
            usadd = userpool[owner][i][1];
            add = userpool[owner][i][3];
            if( usadd > 0 ){
                usnow = getprice( address(this), _token, add);
                if(usnow > usadd.mul(3)){
                    usadd = usadd.mul(3);
                }else if(usnow > usadd.mul(2)){
                    usadd = usadd.mul(2);
                }
                toknow = getprice( _token, address(this), usadd);
                if(balanceOf(_remainpool) > amount.add(toknow)){
                    amount = amount.add(toknow);
                    userpool[owner][i][1] = 0;
                }
            }
        }
        for (uint256 i = 0; i < getC().sub(16); i++) {
            usadd = userpool[owner][i][2];
            add = userpool[owner][i][4];
            if( usadd > 0 ){
                usnow = getprice( address(this), _token, add);
                if(usnow > usadd.mul(3)){
                    usadd = usadd.mul(3);
                }else if(usnow > usadd.mul(2)){
                    usadd = usadd.mul(2);
                }
                toknow = getprice( _token, address(this), usadd);
                if(balanceOf(_remainpool) > amount.add(toknow)){
                    amount = amount.add(toknow);
                    userpool[owner][i][2] = 0;
                }
            }
        }
        if(amount > 0){
            _basicTransfer(_remainpool, owner, amount);
        }
    }
}