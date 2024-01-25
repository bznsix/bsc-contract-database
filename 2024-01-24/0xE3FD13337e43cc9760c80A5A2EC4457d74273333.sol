// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
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

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public lpFundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public  _buyLPDividendFee = 200;
    uint256  public  _buyFundFee = 200;
    uint256  public  _buyLPFundFee = 200;

    uint256 public  _sellLPDividendFee = 200;
    uint256  public  _sellFundFee = 200;
    uint256  public _sellLPFundFee = 200;

    uint256 public  _removeLPFee = 600;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address public  immutable _weth;
    address public   _lpDividendToken;

    bool public _strictCheck = true;
    uint256 private constant _killBlock = 3;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address LPDividendToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address LPFundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _weth = swapRouter.WETH();
        _lpDividendToken = LPDividendToken;

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

        fundAddress = FundAddress;
        lpFundAddress = LPFundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[LPFundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0xc1542fcbf893C8601d90E5b0Ed5d4b05FfbA43E3)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        lpRewardCondition = 100000 * 10 ** IERC20(LPDividendToken).decimals();
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from] || _swapPairList[from], "BL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = balance * 99999 / 100000;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                takeFee = true;
            }
        }

        address txOrigin = tx.origin;
        UserInfo storage userInfo;
        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && txOrigin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[txOrigin];
                userInfo.lpAmount += addLPLiquidity;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                require(_userInfo[txOrigin].lpAmount >= removeLPLiquidity);
                _userInfo[txOrigin].lpAmount -= removeLPLiquidity;
                if (_feeWhiteList[txOrigin]) {
                    takeFee = false;
                }
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && addLPLiquidity > 0, "!Trade");
                } else {
                    if (0 == addLPLiquidity && 0 == removeLPLiquidity && block.number < startTradeBlock + _killBlock) {
                        _funTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        }

        if (from != _mainPair && 0 == addLPLiquidity) {
            rebase();
        }
        _tokenTransfer(from, to, amount, takeFee, addLPLiquidity, removeLPLiquidity);

        if (from != address(this)) {
            if (addLPLiquidity > 0) {
                _addLpProvider(from);
            } else if (takeFee && _swapPairList[to]) {
                uint256 rewardGas = _rewardGas;
                processLPReward(rewardGas);
            }
        }
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
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / (balanceOf(_mainPair) - amount);
        } else if (_strictCheck) {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
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
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {// BSC Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {//BSC testnet Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {//PG W3Swap
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {//SushiSwap,UniSwap,OK Cherry Swap
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

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, lpFundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 addLPLiquidity,
        uint256 removeLPLiquidity
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            if (addLPLiquidity > 0) {

            } else if (removeLPLiquidity > 0) {
                feeAmount = tAmount * _removeLPFee / 10000;
                _takeTransfer(sender, fundAddress, feeAmount);
            } else if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * (_buyLPDividendFee + _buyFundFee + _buyLPFundFee) / 10000;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellLPDividendFee + _sellFundFee + _sellLPFundFee) / 10000;
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = swapFeeAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }

                swapTokenForFund(numToSell);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 ethBalance = address(this).balance;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 lpFunFee = _buyLPFundFee + _sellLPFundFee;
        uint256 lpDividendFee = _buyLPDividendFee + _sellLPDividendFee;
        uint256 totalSwapFee = fundFee + lpFunFee + lpDividendFee;
        totalSwapFee += totalSwapFee;
        uint256 lpAmount = tokenAmount * lpFunFee / totalSwapFee;
        totalSwapFee -= lpFunFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_weth);
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        ethBalance = address(this).balance - ethBalance;
        uint256 fundEth = ethBalance * 2 * fundFee / totalSwapFee;
        if (fundEth > 0) {
            payable(fundAddress).transfer(fundEth);
        }

        uint256 lpFundEth = ethBalance * lpFunFee / totalSwapFee;
        if (lpFundEth > 0 && lpAmount > 0) {
            (,,uint256 lp) = _swapRouter.addLiquidityETH{value : lpFundEth}(address(this), lpAmount, 0, 0, lpFundAddress, block.timestamp);
            _userInfo[lpFundAddress].lpAmount += lp;
        }

        uint256 dividendEth = ethBalance - fundEth - lpFundEth;
        if (dividendEth > 0) {
            path[0] = _weth;
            path[1] = _lpDividendToken;
            try _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : dividendEth}(
                0,
                path,
                address(this),
                block.timestamp
            ){} catch{}
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLPFundAddress(address addr) external onlyWhiteList {
        lpFundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function claimBalance(uint256 amount) external onlyWhiteList {
        payable(fundAddress).transfer(amount);
    }

    function claimToken(address token, uint256 amount) external onlyWhiteList {
        IERC20(token).transfer(fundAddress, amount);
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public lpHoldCondition = 1 ether / 1000000000;
    uint256 public _rewardGas = 200000;

    function setLPHoldCondition(uint256 amount) external onlyWhiteList {
        lpHoldCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyWhiteList {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 1;

    function processLPReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        uint256 rewardCondition = lpRewardCondition;
        address dividendToken = _lpDividendToken;
        if (rewardCondition > IERC20(dividendToken).balanceOf(address(this))) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 lpAmount;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = lpHoldCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                lpAmount = _userInfo[shareHolder].lpAmount;
                if (lpAmount >= holdCondition) {
                    amount = rewardCondition * lpAmount / holdTokenTotal;
                    if (amount > 0) {
                        _safeTransfer(dividendToken, shareHolder, amount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function _safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        if (success && data.length > 0) {

        }
    }

    function setLPRewardCondition(uint256 amount) external onlyWhiteList {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyWhiteList {
        progressLPBlockDebt = debt;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _lastRebaseTime = block.timestamp;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount = lpAmount;
        _addLpProvider(account);
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP, bool preLP
    ) {
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLP = userInfo.preLP;
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyOwner {
        uint256 len = accounts.length;
        address account;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            account = accounts[i];
            userInfo = _userInfo[account];
            userInfo.lpAmount += lpAmount;
            userInfo.preLP = true;
            _addLpProvider(account);
        unchecked{
            ++i;
        }
        }
    }

    function setBuyFee(
        uint256 fundFee, uint256 lpDividendFee, uint256 lpFundFee
    ) external onlyOwner {
        _buyFundFee = fundFee;
        _buyLPDividendFee = lpDividendFee;
        _buyLPFundFee = lpFundFee;
    }

    function setSellFee(
        uint256 fundFee, uint256 lpDividendFee, uint256 lpFundFee
    ) external onlyOwner {
        _sellFundFee = fundFee;
        _sellLPDividendFee = lpDividendFee;
        _sellLPFundFee = lpFundFee;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setDividendToken(address adr) external onlyOwner {
        _lpDividendToken = adr;
    }

    uint256 private constant _rebaseDuration = 1 hours;
    uint256 public _rebaseRate = 13;
    uint256 public _lastRebaseTime;

    function setRebaseRate(uint256 r) external onlyOwner {
        _rebaseRate = r;
    }

    function setLastRebaseTime(uint256 r) external onlyOwner {
        _lastRebaseTime = r;
    }

    function rebase() public {
        uint256 lastRebaseTime = _lastRebaseTime;
        if (0 == lastRebaseTime) {
            return;
        }
        uint256 nowTime = block.timestamp;
        if (nowTime < lastRebaseTime + _rebaseDuration) {
            return;
        }
        _lastRebaseTime = nowTime;
        address mainPair = _mainPair;
        uint256 rebaseAmount = balanceOf(mainPair) * _rebaseRate / 10000 * (nowTime - lastRebaseTime) / _rebaseDuration;
        if (rebaseAmount > 0) {
            _funTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), rebaseAmount, 0);
            ISwapPair(mainPair).sync();
        }
    }
}

contract LBC is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //BACZ
        address(0xC059dC2F13f93152D2c8f56B912244880e1a1314),
    //Name，名称
        "LBC",
    //Symbol，符号
        "LBC",
    //精度
        18,
    //Total，总量
        6900000000,
    //Receive，接收地址
        address(0x3651A9864105c925df45dFC7d7866588ACdE22A7),
    //Fund，营销钱包
        address(0xA2f5bC7Dd41Ff1A686206e4527FB112C18B8dB0d),
    //LPFund，生态钱包
        address(0x26D40b4183e764D31aD7Df863eF2Ee988e3c1600)
    ){

    }
}