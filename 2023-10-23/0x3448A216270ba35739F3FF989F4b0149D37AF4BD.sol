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

contract TY is IERC20, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint8 private _decimals;
    uint8 private _sellRate;
    uint8 private _buyRate;
    uint8 private _transferRate;
    uint8 private _subLiquidityRate;
    uint256 private _lpBonusLimit = 10;
    uint256 private _allTyBonus = 0;
    uint256 private _marketBonus;

    uint32 private _startTradeBlock;
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
    mapping(address => uint256) private _lpMap;
    mapping(address => uint256) private _tyMap;
    address[] private _lpAddress;
    EnumerableSet.AddressSet private _excludeFeeSet;
    EnumerableSet.AddressSet private _tradeSet;
    address[] private _path;

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
        _path.push(address(this));
        _path.push(UsdtAddress);

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
        _addPriceTokenAmount=1;
        _sellRate = 6;
        _buyRate = 5;
        _transferRate = 5;
        _subLiquidityRate = 10;
    }

    function getAllParams() external view returns (
        uint8  sellRate,
        uint8  buyRate,
        uint8  transferRate,
        uint8  subLiquidityRate,
        uint32  startTradeBlock,
        uint256  addPriceTokenAmount,
        address  addressA,
        uint256  lpBonusLimit,
        uint256  allTyBonus,
        uint256  marketBonus
    ){
        sellRate = _sellRate;
        buyRate = _buyRate;
        transferRate = _transferRate;
        subLiquidityRate = _subLiquidityRate;
        startTradeBlock = _startTradeBlock;
        addPriceTokenAmount = _addPriceTokenAmount;
        addressA = _addressA;
        lpBonusLimit = _lpBonusLimit;
        allTyBonus = _allTyBonus;
        marketBonus = _marketBonus;
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
        return _balances[account];
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

    function _isLiquidity(address from,address to) internal view returns(bool isAdd,bool isDel){
        (uint r0,uint r1,) = IUniswapV2Pair(_usdtPairAddress).getReserves();
        uint rUsdt = r0;
        uint bUsdt = IERC20(_usdtAddress).balanceOf(_usdtPairAddress);
        if(address(this)<_usdtAddress){
            rUsdt = r1;
        }
        if( _swapPairMap[to] ){
            if( bUsdt >= rUsdt ){
                isAdd = bUsdt - rUsdt > _addPriceTokenAmount;
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
        require(amount > 0, "TY: transfer amount must be bg 0");
        require(!_tradeSet.contains(from),"from address is blocked");
        require(!(_tradeSet.contains(to) && _swapPairMap[from]),"to address buy or remove is blocked");
        uint isIn = 0;
        for(uint256 s = 0; s < _lpAddress.length; s++){
            if(_lpAddress[s] == from){
                isIn = 1;
            }
        }
        if(isIn == 0){
            _lpMap[from] = 0;
            _tyMap[from] = 0;
        }else{
            //lptongji
            uint256 myLp = IERC20(_usdtPairAddress).balanceOf(from);
            _lpMap[from] = myLp;
        }

        if (_excludeFeeSet.contains(from) || _excludeFeeSet.contains(to) ){
            _tokenTransfer(from, to, amount);
        }else{
            require(_startTradeBlock > 0, "TY: trade do not start");
            (bool isAddLiquidity, bool isDelLiquidity) = _isLiquidity(from,to);
            uint feeRate = _sellRate;
            uint marketFee = 0;
            uint burnFee = 0;
            if(isAddLiquidity || isDelLiquidity){
                if(isDelLiquidity) {
                    //去除流动性
                    feeRate = _subLiquidityRate;
                    //给营销
                    marketFee = amount*feeRate*6/100/10;
                    _balances[address(this)] = _balances[address(this)] + marketFee;
                    emit Transfer(from, address(this),marketFee);
                    _marketBonus = _marketBonus + marketFee;
                    //销毁
                    burnFee = amount*feeRate*4/100/10;
                    _tokenTransfer(from, address(0x000000000000000000000000000000000000dEaD), burnFee);
                    amount = amount*(100-feeRate)/100;

                }else{
                    //添加流动性
                    if(isIn == 0){
                        _lpAddress.push(from);
                    }
                }
                _tokenTransfer(from, to, amount);
            }else{
                if(_swapPairMap[from]){
                    //买122
                    feeRate = _buyRate;
                    marketFee = amount*feeRate*4/100/10;
                    burnFee = amount*feeRate*4/100/10;
                    _tokenTransfer(from, to, amount*(100-feeRate)/100);
                    //给营销+分红
                    _balances[address(this)] = _balances[address(this)] + amount*feeRate*6/100/10;
                    emit Transfer(from, address(this), amount*feeRate*6/100/10);
                    _marketBonus = _marketBonus + marketFee;
                    //lp分红累计,分配,
                    if(amount*feeRate*2/100/10 > 0){
                        _lpBonus(amount*feeRate*2/100/10);
                    }
                }else if(_swapPairMap[to]){
                    //卖222
                    marketFee = amount*feeRate/100/3;
                    burnFee = amount*feeRate/100/3;

                    _tokenTransfer(from, to, amount*(100-feeRate)/100);
                    //给营销
                    _balances[address(this)] = _balances[address(this)] + marketFee*2;
                    emit Transfer(from, address(this), marketFee*2);
                    _marketBonus = _marketBonus + marketFee;
                    //lp分红累计,分配,
                    if(amount*feeRate/100/3 > 0){
                        _lpBonus(amount*feeRate/100/3);
                    }
                }else{
                    //转账
                    feeRate = _transferRate;
                    marketFee = amount*feeRate*6/100/10;
                    burnFee = amount*feeRate*4/100/10;

                    _tokenTransfer(from, to, amount*(100-feeRate)/100);
                    //给营销
                    _tokenTransfer(from, address(this), marketFee);
                    _marketBonus = _marketBonus + marketFee;
                    //触发分红
                    if(_tyMap[from] > _lpBonusLimit * 1e18){
                        //开始分红
                        uniswapV2Router.swapExactTokensForTokens(_tyMap[from], 0, _path, from, block.timestamp+60);
                        _tyMap[from] = 0;
                    }
                    //触发营销
                    if(_marketBonus > 0){
                        uniswapV2Router.swapExactTokensForTokens(_marketBonus, 0, _path, _addressA, block.timestamp+60);
                        _marketBonus = 0;
                    }
                }

                //销毁
                _tokenTransfer(from, address(0x000000000000000000000000000000000000dEaD), burnFee);

            }
        }
    }
    function _lpBonus(
        uint256 lpFee
    ) private {
        //将TY给合约
        uint256 allLp = IERC20(_usdtPairAddress).totalSupply();
        _allTyBonus = _allTyBonus + lpFee;

        if(allLp > 0){
            for(uint i=0;i<_lpAddress.length;i++){
                _tyMap[_lpAddress[i]] = _tyMap[_lpAddress[i]] + _allTyBonus * _lpMap[_lpAddress[i]] / allLp;
            }
            _allTyBonus = 0;
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

    function setAddPriceTokenAmount(uint256 amount) external onlyOwner {
        _addPriceTokenAmount = amount;
    }
    function setLpBonusLimit(uint256 amount) external onlyOwner {
        _lpBonusLimit = amount;
    }
    function getLpAddressList() external view returns(address [] memory){
        return _lpAddress;
    }
    function getLpMapList(address from) external view returns(uint256){
        return _lpMap[from];
    }
    function getTyMapList(address from) external view returns(uint256){
        return _tyMap[from];
    }
    function withdrawToken(address tokenContract, address recipient, uint256 amount) external onlyOwner {
        IERC20 _tokenContract = IERC20(tokenContract);

        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        _tokenContract.transfer(recipient, amount);
    }
    function withdrawEth(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "ERC20: transfer amount exceeds allowance");
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Failed to send Ether");
    }
    receive() external payable {}
}
