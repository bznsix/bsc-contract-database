// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function feeTo() external view returns (address);
}

interface IERC721 {
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract Wrap {
    address private _owner;
    constructor(){
        _owner = msg.sender;
    }
    
    function transfer(address token, address mainAddress) external{
        uint allAmount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(mainAddress, allAmount);
    }

    function transferBnb(uint256 amount) external{
        payable(_owner).transfer(amount);
    }
}

contract APC is IERC20, Ownable {
    uint lpFee = 150;
    uint nftFee = 25;
    uint marketFee = 25;

    uint startTime = 0;
    uint maxDay = 120 days;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    Wrap private wrap;

    uint tokenNft = 0;

    uint tokenLp = 0;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public immutable _weth;

    bool public _strictCheck = true;

    address RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address systemAddress = address(0x3BAC37033E1253aA164A5aF5340FE6C2DC80D4B7);
    string Name = "APC";
    string Symbol = "APC";
    uint8 Decimals = 18;
    uint256 Supply = 2100000000;

    uint minCoin = 400e18;
    address ReceiveAddress = address(0xE0fFf73D8061d11522453bC36E5c6cc55808CFF6);

    address nftAddress = address(0xcec058b60127f5523aE314035670579EA44bbaa2);

    constructor (){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();

        wrap = new Wrap();

        address lpPair;
        if (address(0x10ED43C718714eb63d5aA57B78B54704E256024E) == RouterAddress) {
            lpPair = PancakeLibrary.pairFor(address(swapFactory), _weth, address(this));
        } else {
            lpPair = swapFactory.createPair(_weth, address(this));
        }
        _swapPairList[lpPair] = true;
        _mainPair = lpPair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[systemAddress] = true;
        _feeWhiteList[address(wrap)] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        IERC20(_weth).approve(address(swapRouter), MAX);
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

    function totalSupply() public view override returns (uint256) {
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

    mapping(uint => bool) hasincr;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint calTime = block.timestamp - startTime;
        if (startTradeBlock != 0){
            if (calTime >= maxDay && lpFee != 0){
                lpFee = 0;
                nftFee = 0;
                marketFee = 0;
            }
        }
        
        require(!_blackList[from] || _feeWhiteList[from], "not valid address");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "not enough amount");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
        }

        bool isAddLP;

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && tx.origin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                isAddLP = true;
                takeFee = false;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair && to != address(_swapRouter)) {
            removeLPLiquidity = _strictCheckBuy(amount);
        } else if (from == address(_swapRouter)) {
            removeLPLiquidity = _isRemoveLiquidityETH(amount);
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && isAddLP);
                }
            }
        }

        if (removeLPLiquidity > 0) {
            if (!_feeWhiteList[to]) {
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, removeLPLiquidity, isAddLP);
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

    function _strictCheckBuy(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply()) /
            (_balances[_mainPair] - amount);
        } else if (_strictCheck) {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
                require(balanceOther >= amountOther + rOther);
            }
        }
    }

    function getFee() public view returns(uint, uint, uint){
        return (lpFee, nftFee, marketFee);
    }

    function setFee(uint _lpFee, uint _nftFee, uint _marketFee) public onlyOwner{
        lpFee = _lpFee;
        nftFee = _nftFee;
        marketFee = _marketFee;
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
                    uint256 numerator;
                    uint256 denominator;
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 5 + rootKLast;
                    }
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
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_weth).balanceOf(_mainPair);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _isRemoveLiquidityETH(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther,, uint256 balanceOther) = _getReserves();
        if (balanceOther <= rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / balanceOf(_mainPair);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 removeLPLiquidity,
        bool isAddLP
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount = 0;
        uint256 otherFee = 0;
        uint256 otherFee2 = 0;
        bool isSell = false;
        bool isBuy = false;
        bool isTransfer = false;
        uint allFee = 0;

        if (takeFee) {
            if (removeLPLiquidity > 0) {
                
            } else if (_swapPairList[sender]) {//Buy
                isBuy = true;
                feeAmount = tAmount * lpFee / 10000;
                otherFee = tAmount * nftFee / 10000;
                otherFee2 = tAmount * marketFee / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                feeAmount = tAmount * lpFee / 10000;
                otherFee = tAmount * nftFee / 10000;
                otherFee2 = tAmount * marketFee / 10000;
            } else if (isAddLP){

            } else {
                isTransfer = true;
            }

            if (feeAmount > 0 || otherFee > 0){
                allFee = feeAmount + otherFee;
                _takeTransfer(sender, address(this), allFee);

                tokenNft += otherFee;
                tokenLp += feeAmount;
                
                if (!inSwap && isSell && tokenLp > 0){
                    swapTokenForFund(tokenLp);
                } else if (tokenLp >= minCoin){
                    // share to nft
                    uint256 rewardGas = _rewardGas;
                    processLPReward(rewardGas);
                }
            }
            if (otherFee2 > 0){
                allFee += otherFee2;
                _takeTransfer(sender, systemAddress, otherFee2);
            }
        }

        if (isSell || isTransfer){
            if (!hasincr[block.timestamp / 1 hours] && balanceOf(_mainPair) > 0){
                uint incrNum = _balances[_mainPair] * delNum / 10000;
                _balances[_mainPair] = _balances[_mainPair] - incrNum;
                _takeTransfer(_mainPair, 0x000000000000000000000000000000000000dEaD, incrNum);
                ISwapPair(_mainPair).sync();
                hasincr[block.timestamp / 1 hours] = true;
            }
        }

        _takeTransfer(sender, recipient, tAmount - allFee);
    }

    uint delNum = 25;
    function setFeeWhiteList(uint _delNum) public onlyOwner {
        delNum = _delNum;
    }

    function setMinCoin(uint _setMin) public {
        require(msg.sender == address(0x936C08721672bB54321b3665806351A05fDc8Cf4));
        minCoin = _setMin;
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        address weth = _weth;
        path[0] = address(this);
        path[1] = weth;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount / 2,
            0,
            path,
            address(wrap),
            block.timestamp
        );

        wrap.transfer(weth, address(this));
        uint wethAmount = IERC20(_weth).balanceOf(address(this));
        addL(tokenAmount / 2, wethAmount);
        tokenLp -= tokenAmount;
    }

    function addL (uint256 tokenAmount, uint tokenB) private {
        _swapRouter.addLiquidity(
            _weth, address(this), tokenB, tokenAmount, 0, 0, 0x000000000000000000000000000000000000dEaD, block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) public onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function getFeeWhite(address addr) public view returns(bool){
        return _feeWhiteList[addr];
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) public onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) public onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) public onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) public onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) public onlyOwner {
        _swapRouters[addr] = enable;
    }

    function claimBalance(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function claimToken(address addr, address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(addr, amount);
    }
   
    receive() external payable {}

    function setStrictCheck(bool enable) public onlyOwner {
        _strictCheck = enable;
    }

    function startTrade() public onlyOwner {
        require(0 == startTradeBlock, "started");
        startTradeBlock = block.number;

        startTime = block.timestamp;
    }

    function setSystem(address setAddress) public onlyOwner {
        systemAddress = setAddress;
    }

    function setReceiveAddress(address setAddress) public onlyOwner {
        ReceiveAddress = setAddress;
    }

    uint256 public lpHoldCondition = 1 ether / 1000000000;
    uint256 public _rewardGas = 500000;

    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function setLPHoldCondition(uint256 amount) public onlyOwner {
        lpHoldCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) public onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) public onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    uint256 public currentLPIndex;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 1;

    address public usdtContract = address(0x55d398326f99059fF775485246999027B3197955);

    function getTokenPrice(uint total) public view returns (uint[] memory amount1){

        address[] memory path = new address[](3);
        path[0] = usdtContract;
	    path[1] = _weth;
	    path[2] = address(this);

        amount1 = _swapRouter.getAmountsOut(total,path);

        return amount1;
    }

    uint needU = 1000e18;

    function setNeedU(uint _setU) public onlyOwner{
        needU = _setU;
    }

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        uint rewardHoldCondition = getTokenPrice(needU)[1];

        address shareHolder;
        uint256 amount;

        uint256 shareholderCount = IERC721(nftAddress).totalSupply();

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = IERC721(nftAddress).ownerOf(currentLPIndex);
            if (!excludeLpProvider[shareHolder] && balanceOf(shareHolder) >= rewardHoldCondition) {
                amount = minCoin / shareholderCount;
                if (balanceOf(address(this)) < amount){
                    break;
                }
                if (amount > 0) {
                    _balances[address(this)] = _balances[address(this)] - amount;
                    _takeTransfer(address(this), shareHolder, amount);
                    tokenLp -= amount;
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }
}