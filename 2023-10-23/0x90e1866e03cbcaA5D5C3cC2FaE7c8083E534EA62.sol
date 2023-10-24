// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

library Math {
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

abstract contract AbsToken is IERC20, Ownable {
    
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    struct LpHoldInfo{
        address user;
        uint256 amount;
    }

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _dividendFee;
    uint256 public _transferFee;
    uint256 public _burnFee;

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public addLPAddress;
    address public firstClassBuyAddress;
    address public miningGdpAddress;
    address private _usdt;
    address public immutable _mainPair;
    mapping(address => bool) private marketManageList;

    uint256 public startTradeBlock;

    ISwapRouter private immutable _swapRouter;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;

    mapping(address => bool) private _swapPairList;

    constructor (string memory Name, 
            string memory Symbol, 
            uint8 Decimals, 
            uint256 Supply, 
            uint256 DividendFee,
            uint256 TransferFee, 
            uint256 BurnFee,
            address ReceivedAddress
        ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _dividendFee = DividendFee;
        _transferFee = TransferFee;
        _burnFee = BurnFee;
        
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _allowances[address(this)][address(swapRouter)] = MAX;
        address usdt =  address(0x55d398326f99059fF775485246999027B3197955);
        IERC20(usdt).approve(address(swapRouter), MAX);
        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        address mainPair = ISwapFactory(swapRouter.factory()).createPair(address(this), usdt);
        _mainPair = mainPair;
        _swapPairList[_mainPair] = true;
        excludeHolder[_mainPair] = true;
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeHolder[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
        
        uint256 tTotal = Supply * 10 ** _decimals;
        _balances[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _tTotal = tTotal;
        marketManageList[address(this)] = true;
        marketManageList[ReceivedAddress] = true;
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

    
    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

     function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        
        if (balanceOther <= rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) /
            (balanceOf(_mainPair) - amount - 1);
        }
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = ISwapPair(_mainPair).totalSupply();
        address feeTo = ISwapFactory(_swapRouter.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = ISwapPair(_mainPair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
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
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }

        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee = false;
        
        bool isAddLP = false;
        
        bool isRemoveLP = false;
        
        if (!marketManageList[from] && !marketManageList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        uint256 addLPLiquidity;
        if (to == _mainPair) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                isAddLP = true;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                isRemoveLP = true;
            }
        }

        if (isAddLP || isRemoveLP) {
            takeFee = false;
        }
        if(takeFee){
            if (_swapPairList[from]){
                if (0 == startTradeBlock) {
                    if (_swapPairList[to] && IERC20(to).totalSupply() == 0) {
                        require(marketManageList[from], "!Trading");
                    }
                }

                if (!marketManageList[from] && !marketManageList[to]) {
                    if (0 == startTradeBlock) {
                        _funTransfer(from, to, amount, 9999);
                        return;
                    }
                }
            }
        }
        _tokenTransfer(from, to, amount, takeFee);
        if (from != address(this)) {
            if (isAddLP) {
                addHolder(from);
            } else if (!marketManageList[from]) {
                processReward(5000000);
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 lpDividendFeeAmount;
        uint256 burnFeeAmount;
        uint256 transferFeeAmount;
        if (takeFee) {
            if(_swapPairList[sender]){ // buy
                lpDividendFeeAmount = tAmount * _dividendFee / 1000;
                burnFeeAmount = tAmount * _burnFee / 1000;
            }else if (_swapPairList[recipient]){ //sell
                lpDividendFeeAmount = tAmount * _dividendFee*2 / 1000;
                burnFeeAmount = tAmount * 20 / 1000;
            }
            if (!_swapPairList[sender] && !_swapPairList[recipient]) { 
                transferFeeAmount = tAmount * _transferFee / 1000;
            }
        }
        if (burnFeeAmount > 0) {
            feeAmount += burnFeeAmount;
            _takeTransfer(sender, burnAddress, burnFeeAmount);
        }
        if (lpDividendFeeAmount > 0) {
            feeAmount += lpDividendFeeAmount;
            _takeTransfer(sender, address(this), lpDividendFeeAmount);
        }
        if(transferFeeAmount > 0){
            feeAmount += transferFeeAmount;
            _takeTransfer(sender, burnAddress, transferFeeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 10000;
        if (feeAmount > 0) {
            _takeTransfer(sender, address(this), feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    
    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }


    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    function quickSort(LpHoldInfo[] memory arr, int left, int right) internal pure{
        int i = left;
        int j = right;
        if(i==j) return;
        uint256 pivot = arr[uint(left + (right - left) / 2)].amount;
        while (i <= j) {
            while (arr[uint(i)].amount < pivot) i++;
            while (pivot < arr[uint(j)].amount) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    uint256 public holderRewardCondition = 500 * 1e18;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 100;
    uint256 public rankNums = 100;

    function processReward(uint256 gas) private {

        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        uint256 rewardCondition = holderRewardCondition;
        address sender = address(this);
        if (balanceOf(address(sender)) < rewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }
        uint256 lpBalance;
        uint256 _amount;
        
        LpHoldInfo[] memory lpHoldInfoList = new LpHoldInfo[](holders.length);
        for (uint i = 0; i < holders.length; i++){
            lpHoldInfoList[i] = LpHoldInfo({
                user:holders[i],
                amount:holdToken.balanceOf(holders[i])
            });
        }
        quickSort(lpHoldInfoList, int(0), int(lpHoldInfoList.length - 1));
        uint256 total = 0;
        uint256 gasUsed = 0;
        bool haveNext = true;
        uint256 gasLeft = gasleft();
        uint256 currentIndex = lpHoldInfoList.length - 1;
        while (gasUsed < gas && haveNext && total < rankNums) {
            lpBalance = holdToken.balanceOf(lpHoldInfoList[currentIndex].user);
            _amount = holderRewardCondition * lpBalance / holdTokenTotal;
            if (_amount > 0) {
                _tokenTransfer(sender, lpHoldInfoList[currentIndex].user, _amount, false);
            }
            total++;
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            if (currentIndex > 0){
                currentIndex--;
            } else {
                haveNext = false;
            }
        }
        progressRewardBlock = blockNum;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner() {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
        if (enable) {
            
            excludeHolder[addr] = true;
        }
    }

    function setExcludeReward(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }


    function setMarketAddress(address addr, bool _enable) external onlyOwner {
        marketManageList[addr] = _enable;
    }

    function setRankNums(uint256 nums) external onlyOwner {
        rankNums = nums;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
}


contract M7Token is AbsToken {
    constructor() AbsToken( 
        "M7",
        "M7",
        18,
        2270000,
        15,
        10,
        15,
        address(0xEe783D0693262C4350eb59eEe1E00B7F9B137209)
    ){
    }
}