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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

contract TokenDistributor {
    mapping(address => bool) private _feeWhiteList;
    constructor (address token, address token2) {
        _feeWhiteList[msg.sender] = true;
        safeApprove(token, msg.sender, ~uint256(0));
        safeApprove(token2, msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            safeTransfer(token, to, amount);
        }
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
    }

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'AF');
    }
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

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerBalance(uint256 tokenId) external view returns (address own, uint256 balance);
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    //dao
    address private fundAddress;
    //mint
    address private fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    address private immutable _usdt;
    address private immutable _btcb;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;

    uint256 public _buyFee = 500;
    uint256 public _sellFee = 500;

    uint256 private _lpDividendRate = 5500;
    uint256 private _nftRate = 1000;
    uint256 private _buybackRate = 1000;
    uint256 private _mintRate = 1000;
    uint256 private _daoRate = 1500;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public immutable _mainPair;

    uint256 public _limitAmount;

    uint256 private constant _killBlock = 3;
    mapping(address => UserInfo) private _userInfo;

    mapping(address => bool) public _swapRouters;
    bool public _strictCheck = true;
    uint256 public _removeFee = 10000;

    INFT public _nft;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address BTCBAddress, address NFTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, address FundAddress2,
        uint256 LimitAmount
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _nft = INFT(NFTAddress);

        _swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        _usdt = usdt;
        _allowances[address(this)][address(_swapRouter)] = MAX;
        _swapRouters[address(_swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address usdtPair;
        if (address(0x10ED43C718714eb63d5aA57B78B54704E256024E) == address(_swapRouter)) {
            usdtPair = PancakeLibrary.pairFor(address(swapFactory), _usdt, address(this));
        } else {
            usdtPair = swapFactory.createPair(_usdt, address(this));
        }
        _mainPair = usdtPair;
        _swapPairList[usdtPair] = true;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        uint256 mintPoolAmount = 100000000 * tokenUnit;
        _balances[ReceiveAddress] = total - mintPoolAmount;
        emit Transfer(address(0), ReceiveAddress, total - mintPoolAmount);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _limitAmount = LimitAmount * tokenUnit;
        _btcb = BTCBAddress;
        holderRewardCondition = 3 * 10 ** IERC20(_btcb).decimals() / 1000;

        _tokenDistributor = new TokenDistributor(usdt, _btcb);
        _feeWhiteList[address(_tokenDistributor)] = true;
        _balances[address(_tokenDistributor)] = mintPoolAmount;
        emit Transfer(address(0), address(_tokenDistributor), mintPoolAmount);

        _userInfo[FundAddress].lpAmount = MAX / 10;

        _numTokensToSell = 50000 * tokenUnit;
        _inviteConditionMin = tokenUnit / 1000;
        _inviteConditionMax = tokenUnit;
        _inviteRewardCondition = 10000 * tokenUnit;
        _inviteRewardCondition4 = 100000 * tokenUnit;
        _inviteFee[0] = 200;
        _inviteFee[1] = 100;
        _inviteFee[2] = 50;
        _inviteFee[3] = 50;
        _inviteFee[4] = 100;
        _inviteFeeBinderLenCondition[0] = 1;
        _inviteFeeBinderLenCondition[1] = 3;
        _inviteFeeBinderLenCondition[2] = 5;
        _inviteFeeBinderLenCondition[3] = 7;
        _inviteFeeBinderLenCondition[4] = 9;

        nftRewardCondition = 3 * 10 ** IERC20(_btcb).decimals() / 1000;
        _nftHoldTokenCondition = 500000 * tokenUnit;
        excludeNFTHolder[address(0)] = true;
        excludeNFTHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
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
        uint256 balance = _balances[account];
        return balance;
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
        uint256 day = today();
        if (0 == dayPrice[day]) {
            dayPrice[day] = tokenPrice();
        }

        require(!_blackList[from] || _feeWhiteList[from], "BL");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;
        bool isAddLP;
        bool isRemoveLP;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && tx.origin == from) {
            uint256 addLPAmount = amount;
            addLPLiquidity = _isAddLiquidity(addLPAmount);
            if (addLPLiquidity > 0) {
                UserInfo storage userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _strictCheckBuy(amount);
            if (removeLPLiquidity > 0) {
                require(_userInfo[to].lpAmount >= removeLPLiquidity);
                _userInfo[to].lpAmount -= removeLPLiquidity;
                isRemoveLP = true;
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
                    require(0 < startAddLPBlock && isAddLP, "!Trade");
                } else {
                    if (!isAddLP && !isRemoveLP && block.number < startTradeBlock + _killBlock) {
                        _funTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        } else {
            if (address(0) == _inviter[to] && amount >= _inviteConditionMin && amount <= _inviteConditionMax && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _inviter[from] && amount >= _inviteConditionMin && amount <= _inviteConditionMax && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
        }

        if (isAddLP) {
            takeFee = false;
        } else if (!_swapPairList[from]) {
            buyback();
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "Limit");
        }

        if (from != address(this)) {
            if (isAddLP) {
                addHolder(from);
            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                uint256 nowNum = block.number;
                processNFTReward(rewardGas);
                if (processNFTBlock != nowNum) {
                    processReward(rewardGas);
                }
            }
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _strictCheckBuy(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply()) /
            (_balances[_mainPair] - amount);
        } else if (_strictCheck) {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
                //strictCheckBuy
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
        balanceOther = IERC20(_usdt).balanceOf(_mainPair);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
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
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 destroyFeeAmount;
        bool isSell;

        if (takeFee) {
            if (isRemoveLP) {
                if (_userInfo[recipient].preLP) {
                    destroyFeeAmount = tAmount * _removeFee / 10000;
                }
            } else if (_swapPairList[sender]) {//Buy
                feeAmount = tAmount * _buyFee / 10000;
                _calInviteReward(recipient, tAmount);

                //buyUsdtAmount
                address[] memory path = new address[](2);
                path[0] = _usdt;
                path[1] = address(this);
                uint[] memory amounts = _swapRouter.getAmountsIn(tAmount, path);
                uint256 usdtAmount = amounts[0];
                _buyUsdtAmount[recipient] += usdtAmount;
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                feeAmount = tAmount * getSellFee() / 10000;

                uint256 profitFeeAmount = _calProfitFeeAmount(sender, tAmount - feeAmount);
                if (profitFeeAmount > 0) {
                    feeAmount += profitFeeAmount;
                }
            } else {//Transfer

            }
        }
        if (feeAmount > 0) {
            uint256 mintAmount = feeAmount * _mintRate / 10000;
            if (mintAmount > 0) {
                _takeTransfer(sender, fundAddress2, mintAmount);
            }
            _takeTransfer(sender, address(this), feeAmount - mintAmount);
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = _numTokensToSell;
                if (contractTokenBalance >= numTokensSellToFund) {
                    uint256 maxSellNum = 10 * numTokensSellToFund;
                    if (contractTokenBalance > maxSellNum) {
                        contractTokenBalance = maxSellNum;
                    }
                    swapTokenForFund(contractTokenBalance);
                }
            }
        }
        if (destroyFeeAmount > 0) {
            feeAmount += destroyFeeAmount;
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 buybackRate = _buybackRate;
        uint256 nftRate = _nftRate;
        uint256 daoRate = _daoRate;
        uint256 lpDividendRate = _lpDividendRate;

        uint256 totalFee = buybackRate + nftRate + daoRate + lpDividendRate;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance);

        uint256 fundUsdt = usdtBalance * daoRate / totalFee;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }

        fundUsdt = usdtBalance * (lpDividendRate + nftRate) / totalFee;
        if (fundUsdt > 0) {
            path[0] = _usdt;
            path[1] = _btcb;
            uint256 btcBalance = IERC20(_btcb).balanceOf(address(this));
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                fundUsdt,
                0,
                path,
                address(this),
                block.timestamp
            );
            btcBalance = IERC20(_btcb).balanceOf(address(this)) - btcBalance;
            uint256 nftBTC = btcBalance * nftRate / (nftRate + lpDividendRate);
            if (nftBTC > 0) {
                safeTransfer(_btcb, address(_tokenDistributor), nftBTC);
            }
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

    function setFundAddress2(address addr) external onlyWhiteList {
        fundAddress2 = addr;
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

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyWhiteList {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyWhiteList {
        safeTransfer(token, fundAddress, amount);
    }

    function claimContractToken(address contractAddr, address token, uint256 amount) external onlyWhiteList {
        TokenDistributor(contractAddr).claimToken(token, fundAddress, amount);
    }

    receive() external payable {}

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool preLP
    ) {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLP = userInfo.preLP;
        lpBalance = IERC20(_mainPair).balanceOf(account);
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _lastBuybackTime = block.timestamp;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        _userInfo[account].lpAmount = lpAmount;
        addHolder(account);
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyWhiteList {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmount;
            userInfo.preLP = true;
            addHolder(accounts[i]);
        unchecked{
            ++i;
        }
        }
    }

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

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition = 1000000;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 1;

    function processReward(uint256 gas) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 usdt = IERC20(_btcb);

        uint256 rewardCondition = holderRewardCondition;
        if (usdt.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 lpBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            if (!excludeHolder[shareHolder]) {
                lpBalance = holdToken.balanceOf(shareHolder);
                if (lpBalance >= holdCondition) {
                    amount = rewardCondition * lpBalance / holdTokenTotal;
                    if (amount > 0) {
                        safeTransfer(address(usdt), shareHolder, amount);
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TFF');
    }

    function setHolderRewardCondition(uint256 amount) external onlyWhiteList {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyWhiteList {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyWhiteList {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyWhiteList {
        progressRewardBlockDebt = blockDebt;
    }

    uint256 public _rewardGas = 500000;

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function setBuyFee(
        uint256 buyFee
    ) external onlyOwner {
        _buyFee = buyFee;
    }

    function setRemoveFee(
        uint256 removeFee
    ) external onlyOwner {
        _removeFee = removeFee;
    }

    function setSellFee(
        uint256 sellFee
    ) external onlyOwner {
        _sellFee = sellFee;
    }

    function setFeeRate(
        uint256 lpDividendRate, uint256 nftRate, uint256 buybackRate, uint256 mintRate, uint256 daoRate
    ) external onlyWhiteList {
        require(10000 >= lpDividendRate + nftRate + buybackRate + mintRate + daoRate, "M1w");
        _lpDividendRate = lpDividendRate;
        _nftRate = nftRate;
        _buybackRate = buybackRate;
        _mintRate = mintRate;
        _daoRate = daoRate;
    }

    mapping(address => bool) public _blackList;

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function batchSetBlackList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setLimitAmount(uint256 a) external onlyWhiteList {
        _limitAmount = a;
    }

    uint256 public _numTokensToSell;

    function setNumTokensToSell(uint256 n) external onlyWhiteList {
        _numTokensToSell = n;
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => mapping(address => bool)) private _maybeInvitor;
    uint256 private immutable _inviteConditionMin;
    uint256 private immutable _inviteConditionMax;
    uint256 private immutable _inviteRewardCondition;
    uint256 private immutable _inviteRewardCondition4;

    uint256 private constant _invitorLength = 5;
    mapping(uint256 => uint256) private _inviteFee;
    mapping(uint256 => uint256) private _inviteFeeBinderLenCondition;

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function _calInviteReward(address account, uint256 tAmount) private {
        address mintPool = address(_tokenDistributor);
        uint256 mintBalance = balanceOf(mintPool);

        uint256 len = _invitorLength;
        address invitor;
        uint256 inviteAmount;
        address current = account;
        for (uint256 i; i < len; ++i) {
            invitor = _inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (_binders[invitor].length >= _inviteFeeBinderLenCondition[i]) {
                uint256 invitorBalance = balanceOf(invitor);
                if ((i < 4 && invitorBalance >= _inviteRewardCondition) || invitorBalance >= _inviteRewardCondition4) {
                    inviteAmount = tAmount * _inviteFee[i] / 10000;
                    if (inviteAmount > mintBalance) {
                        inviteAmount = mintBalance;
                    }
                    if (inviteAmount > 0) {
                        mintBalance -= inviteAmount;
                        _funTransfer(mintPool, invitor, inviteAmount, 0);
                        if (0 == mintBalance) {
                            break;
                        }
                    }
                }
            }
            current = invitor;
        }
    }

    mapping(uint256 => uint256) public dayPrice;
    uint256 public  priceRate1 = 8000;
    uint256 public  priceRate2 = 7000;
    uint256 public  priceFee1 = 2000;
    uint256 public  priceFee2 = 3000;

    function today() public view returns (uint256){
        return block.timestamp / 86400;
    }

    function tokenPrice() public view returns (uint256){
        (uint256 reverseUsdt,uint256 reverseToken) = __getReserves();
        if (0 == reverseToken) {
            return 0;
        }
        return 10 ** _decimals * reverseUsdt / reverseToken;
    }

    function getSellFee() public view returns (uint256){
        uint256 todayPrice = dayPrice[today()];
        uint256 price = tokenPrice();
        uint256 priceRate = price * 10000 / todayPrice;
        uint256 sellFee;
        if (priceRate <= priceRate2) {
            sellFee = priceFee2;
        } else if (priceRate <= priceRate1) {
            sellFee = priceFee1;
        } else {
            sellFee = _sellFee;
        }
        return sellFee;
    }

    function setPriceRateFee1(uint256 r, uint256 f) external onlyWhiteList {
        priceRate1 = r;
        priceFee1 = f;
    }

    function setPriceRateFee2(uint256 r, uint256 f) external onlyWhiteList {
        priceRate2 = r;
        priceFee2 = f;
    }

    mapping(address => uint256) public _buyUsdtAmount;
    uint256 public _sellProfitFee = 1000;

    function _calProfitFeeAmount(address sender, uint256 realSellAmount) private returns (uint256 profitFeeAmount){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        uint[] memory amounts = _swapRouter.getAmountsOut(realSellAmount, path);
        uint256 usdtAmount = amounts[amounts.length - 1];

        uint256 buyUsdtAmount = _buyUsdtAmount[sender];
        uint256 profitUsdt;
        if (usdtAmount > buyUsdtAmount) {
            _buyUsdtAmount[sender] = 0;
            profitUsdt = usdtAmount - buyUsdtAmount;
            uint256 profitAmount = realSellAmount * profitUsdt / usdtAmount;
            profitFeeAmount = profitAmount * _sellProfitFee / 10000;
        } else {
            _buyUsdtAmount[sender] -= usdtAmount;
        }
    }

    function updateBuyUsdtAmount(address account, uint256 usdtAmount) public onlyWhiteList {
        _buyUsdtAmount[account] = usdtAmount;
    }

    function setSellProfitFee(uint256 fee) external onlyWhiteList {
        _sellProfitFee = fee;
    }

    uint256 public _lastBuybackTime;
    uint256 public _payRate = 400;

    function setPayRate(uint256 r) external onlyWhiteList {
        _payRate = r;
    }

    function setLastBuybackTime(uint256 t) external onlyWhiteList {
        _lastBuybackTime = t;
    }

    function buyback() public {
        uint256 lastBuybackTime = _lastBuybackTime;
        if (0 == lastBuybackTime) {
            return;
        }
        uint256 nowTime = block.timestamp;
        if (nowTime >= lastBuybackTime + 1 days) {
            uint256 buyUsdt = IERC20(_usdt).balanceOf(address(this)) * _payRate / 10000;
            if (0 == buyUsdt) {
                return;
            }
            _lastBuybackTime = nowTime;
            address[] memory path = new address[](2);
            path[0] = _usdt;
            path[1] = address(this);
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buyUsdt,
                0,
                path,
                address(0x000000000000000000000000000000000000dEaD),
                nowTime
            );
        }
    }

    function setNFT(address adr) external onlyOwner {
        _nft = INFT(adr);
    }

    //NFT
    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTBlockDebt = 100;
    mapping(address => bool) public excludeNFTHolder;
    mapping(uint256 => bool) public excludeNFT;
    uint256 public _nftHoldTokenCondition;

    function processNFTReward(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = _nft;
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_tokenDistributor);
        if (IERC20(_btcb).balanceOf(sender) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdTokenCondition = _nftHoldTokenCondition;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            if (!excludeNFT[1 + currentNFTIndex]) {
                (address shareHolder,uint256 nftNum) = nft.ownerBalance(1 + currentNFTIndex);
                if (!excludeNFTHolder[shareHolder] && balanceOf(shareHolder) >= nftNum * holdTokenCondition) {
                    safeTransferFrom(_btcb, sender, shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }

        processNFTBlock = block.number;
    }

    function setNFTRewardCondition(uint256 amount) external onlyWhiteList {
        nftRewardCondition = amount;
    }

    function setNFTHoldTokenCondition(uint256 amount) external onlyWhiteList {
        _nftHoldTokenCondition = amount;
    }

    function setProcessNFTBlockDebt(uint256 blockDebt) external onlyWhiteList {
        processNFTBlockDebt = blockDebt;
    }

    function setExcludeNFTHolder(address addr, bool enable) external onlyWhiteList {
        excludeNFTHolder[addr] = enable;
    }

    function setExcludeNFT(uint256 id, bool enable) external onlyWhiteList {
        excludeNFT[id] = enable;
    }
}

contract GDC is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //BTCB
        address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c),
    //NFT
        address(0x392c2a3F9CAb0f04c8e392e5e21531c4a0bD2534),
    //
        "GDC",
    //
        "GDC",
    //
        18,
    //
        10000000000,
    //
        address(0x168874c1776C8fDEaFa3bA80564431e846E9B80f),
    //
        address(0x818cC32145f7a1e9F54607Dd5716bc5c0650300e),
    //
        address(0xd3A46E0324b0b58b45d56fe2D871cD306F5eB265),
    //
        10000000
    ){

    }
}