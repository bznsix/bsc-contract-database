// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
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

contract FCN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _blackList;
    mapping(address => bool) private _updated;
    mapping(address => uint256) private _dividendTime;

    mapping(address => bool) public ammPairs;
   
    uint8 private _decimals = 18;
    uint256 private _tTotal;
    uint256 public supply = 1 * (10 ** 15) * (10 ** 18);

    string private _name = "FaCaiNiu";
    string private _symbol = "FCN";
    
    uint256 public _buyLpFee = 150;
    uint256 public _sellLpFee = 150;

    uint256 public _buyLiquidityFee = 50;
    uint256 public _sellLiquidityFee = 50;

    uint256 public _buyMarketFee = 100;
    uint256 public _sellMarketFee = 100;
    address public marketAddress = 0x68B54164b6B00e3164FE70cE01FeE8AedA5d6061;

    uint256 public _buyBuyBackFee = 100;
    uint256 public _sellBuyBackFee = 100;
    address public buyBackAddress = 0x3Bf212f6DC47d895Bb9713991FC86606536B0A27;

    uint256 public totalBuyFee = 400;
    uint256 public totalSellFee = 400;
    uint256 feeUnit = 10000;

    IUniswapV2Router02 public uniswapV2Router;

    IERC20 public uniswapV2Pair;
    address public wbnb;
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    address public initPoolAddress = 0xaeA0EA7863115B47970EFc6F48d069efee686A1e;
    address constant rootAddress = address(0x000000000000000000000000000000000000dEaD);

    uint public lpCondition = 1 * 10 ** 14;
    uint256 lpInitAmount;
    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 600;

    address private fromAddress;
    address private toAddress;

    bool public openTransaction;
    uint256 public launchedAt = 1697457600;

    EnumerableSet.AddressSet lpProviders;

    bool public swapEnabled = true;
    uint256 public swapThreshold = supply / 5000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    constructor () {
        _tOwned[owner()] = supply;
        _tTotal = supply;
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[rootAddress] = true;
        _isExcludedFromFee[marketAddress] = true;
        _isExcludedFromFee[buyBackAddress] = true;
        _isExcludedFromFee[initPoolAddress] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Router = _uniswapV2Router;

        address bnbPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        wbnb = _uniswapV2Router.WETH();

        uniswapV2Pair = IERC20(bnbPair);
        ammPairs[bnbPair] = true;

        emit Transfer(address(0), owner(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    receive() external payable {}

    function _take(uint256 tValue,address from,address to) private {
        _tOwned[to] = _tOwned[to].add(tValue);
        emit Transfer(from, to, tValue);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    struct Param{
        bool takeFee;
        uint tTransferAmount;
        uint tContract;
        address user;
    }

     function _initParam(uint256 tAmount,Param memory param, address to) private view  {
        uint tFee;
        if (block.timestamp - launchedAt < 11) {
            tFee = tAmount * 90 / 100;
            param.tContract = tFee;
        } else {
            if(ammPairs[to] == true){
                param.tContract = tAmount * (_sellBuyBackFee.add(_sellLiquidityFee).add(_sellMarketFee).add(_sellLpFee)) / feeUnit;
                tFee = tAmount * totalSellFee / feeUnit;
            } else {
                param.tContract = tAmount * (_buyBuyBackFee.add(_buyLiquidityFee).add(_buyMarketFee).add(_buyLpFee)) / feeUnit;
                tFee = tAmount * totalBuyFee / feeUnit;
            }
        }
        
        param.tTransferAmount = tAmount.sub(tFee);
    }

    function _takeFee(Param memory param,address from)private {
        if( param.tContract > 0 ){
            _take(param.tContract, from, address(this));
        }
    }

    function shouldSwapBack(address to) internal view returns (bool) {
        return ammPairs[to]
        && !inSwap
        && swapEnabled
        && balanceOf(address(this)) >= swapThreshold;
    }

    function swapBack() internal swapping {
        _allowances[address(this)][address(uniswapV2Router)] = swapThreshold;

        uint256 amountToLiquify = swapThreshold.mul(_sellLiquidityFee).div(totalSellFee).div(2);
        uint256 amountToUsdt = swapThreshold.mul(_sellLpFee).div(totalSellFee);
        uint256 amountToBnb = swapThreshold.sub(amountToUsdt).sub(amountToLiquify);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;
        uint256 balanceBefore = address(this).balance;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToBnb,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 amountBNBToMarket = amountBNB.mul(_sellMarketFee).div(totalSellFee);
        uint256 amountBNBToBuyBack = amountBNB.mul(_sellBuyBackFee).div(totalSellFee);
        uint256 amountBNBToLiquidity = amountBNB.sub(amountBNBToBuyBack).sub(amountBNBToMarket);

        payable(marketAddress).transfer(amountBNBToMarket);
        payable(buyBackAddress).transfer(amountBNBToBuyBack);

        address[] memory pathToUsdt = new address[](3);
        pathToUsdt[0] = address(this);
        pathToUsdt[1] = wbnb;
        pathToUsdt[2] = usdt;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToUsdt,
            0,
            pathToUsdt,
            address(this),
            block.timestamp
        );

        if(amountToLiquify > 0){
            uniswapV2Router.addLiquidityETH{value: amountBNBToLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                initPoolAddress,
                block.timestamp
            );
            emit AutoLiquify(amountBNBToLiquidity, amountToLiquify);
        } 
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee;
        Param memory param;
        param.tTransferAmount = amount;

        if( ammPairs[from] ){
            param.user = to;
        } else {
            param.user = address(this);
        }

        if( ammPairs[to] == true && IERC20(to).totalSupply() == 0 ){
            require(from == initPoolAddress,"Not allow init");
        }

        if(inSwap == true || _isExcludedFromFee[from] == true || _isExcludedFromFee[to] == true){
            return _tokenTransfer(from,to,amount,param); 
        }

        if (openTransaction == false && block.timestamp > launchedAt) {
            openTransaction = true;
        }
        require(openTransaction == true,"Not allow");
        require(!_blackList[from],"In blackList");

        if(ammPairs[to] == true || ammPairs[from] == true){
            takeFee = true;
        }

        if(shouldSwapBack(to)){ swapBack(); }

        param.takeFee = takeFee;
        if( takeFee ){
            _initParam(amount,param,to);
        }
        
        _tokenTransfer(from,to,amount,param);

        if( address(uniswapV2Pair) != address(0) ){
            if (fromAddress == address(0)) fromAddress = from;
            if (toAddress == address(0)) toAddress = to;
            if ( !ammPairs[fromAddress] ) setShare(fromAddress);
            if ( !ammPairs[toAddress] ) setShare(toAddress);
            fromAddress = from;
            toAddress = to;

            if (
                from != address(this) 
                && IERC20(usdt).balanceOf(address(this)) > 0
                && uniswapV2Pair.totalSupply() > 0 ) {

                process(distributorGas);
            }
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }
    
     function process(uint256 gas) private {
        uint256 shareholderCount = lpProviders.length();

        if (shareholderCount == 0) return;

        uint256 nowbanance = IERC20(usdt).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        if (lpInitAmount == 0){
            lpInitAmount = uniswapV2Pair.balanceOf(initPoolAddress);
        }
        uint ts = uniswapV2Pair.totalSupply().sub(lpInitAmount);
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowbanance.mul(uniswapV2Pair.balanceOf(lpProviders.at(currentIndex))).div(ts);

            if (IERC20(usdt).balanceOf(address(this)) < amount) return;

            if (amount >= lpCondition && _dividendTime[lpProviders.at(currentIndex)].add(minPeriod) <= block.timestamp) {
                IERC20(usdt).transfer(lpProviders.at(currentIndex), amount);
                _dividendTime[lpProviders.at(currentIndex)] = block.timestamp; 
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (uniswapV2Pair.balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (uniswapV2Pair.balanceOf(shareholder) == 0) return;
        if (shareholder == initPoolAddress) return;
        if (isContract(shareholder) == true) return;
        lpProviders.add(shareholder);
        _updated[shareholder] = true;
    }

    function quitShare(address shareholder) private {
        lpProviders.remove(shareholder);
        _updated[shareholder] = false;
    }

    function setOpenTransaction() external onlyOwner {
        require(openTransaction == false, "Already opened");
        openTransaction = true;
        launchedAt = block.timestamp;
    }

    function setAddress(address _marketAddress, address _buyBackAddress, address _initPoolAddress) external onlyOwner {
        marketAddress = _marketAddress;
        buyBackAddress = _buyBackAddress;
        initPoolAddress = _initPoolAddress;
        _isExcludedFromFee[marketAddress] = true;
        _isExcludedFromFee[buyBackAddress] = true;
        _isExcludedFromFee[initPoolAddress] = true;
    }

    function setLaunchedAt(uint256 _timestamp) external onlyOwner {
        launchedAt = _timestamp;
    }

    function setCondition(uint lc) external onlyOwner {
        lpCondition = lc;
    }

    function setMinPeriod(uint period) external onlyOwner {
        minPeriod = period;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function muliSetExcludeFromFee(address[] calldata users, bool _isExclude) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            _isExcludedFromFee[users[i]] = _isExclude;
        }
    }

    function setExcludeFromFee(address account, bool _isExclude) external onlyOwner {
        _isExcludedFromFee[account] = _isExclude;
    }

    function setBlackList(address account, bool _isBlackList) external onlyOwner {
        _blackList[account] = _isBlackList;
    }

    function setFees(uint256 buyBuyBackFee, uint256 buyLpFee, uint256 buyLiquidityFee, uint256 buyMarketFee,uint256 sellBuyBackFee, uint256 sellLpFee, uint256 sellLiquidityFee, uint256 sellMarketFee) external onlyOwner {
        _buyBuyBackFee = buyBuyBackFee;
        _buyLpFee = buyLpFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyMarketFee = buyMarketFee;
        _sellBuyBackFee = sellBuyBackFee;
        _sellLpFee = sellLpFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellMarketFee = sellMarketFee;
        totalBuyFee = _buyBuyBackFee.add(_buyLpFee).add(_buyLiquidityFee).add(_buyMarketFee);
        totalSellFee = _sellBuyBackFee.add(_sellLpFee).add(_sellLiquidityFee).add(_sellMarketFee);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}