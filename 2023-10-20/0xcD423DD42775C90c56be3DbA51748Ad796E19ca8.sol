// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

interface ISwapRouter {
    function factory() external pure returns (address);

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
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function feeTo() external view returns (address);
}

abstract contract Ownable {
    address internal _owner;

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
    address public _owner;

    constructor(address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

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

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // 基金会
    address public fundAddress = 0x83e84e6349828fEcBbD389bD444f0d2c3d7cb1D9;
    // 营销钱包
    address public marketAddress = 0x2c42269F677332Aa86c88cdCc530700CC1EFd025;

    address public taxAddress = 0xa67d97291f65B951B532580C35C301dc64Dea89C;

    address ReceiveAddress = 0xd53b71C66cCa41F0a87E36d05B4f8267Fb8F1036;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isExcludedFromVipFees;
    mapping(address => bool) public _isBlacklist;
    mapping(address => uint256) public _lastBuy;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;

    uint256 public _swapTokenAtAmount = 0;

    uint256 public _buyLPDividendFee = 26;
    uint256 public _buyFundFee = 10;

    uint256 public _sellLPDividendFee = 16;
    uint256 public _sellFundFee = 13;
    uint256 public _sellDestroyFee = 10;

    address public immutable _mainPair;
    address public immutable _usdt;

    uint256 public _startTradeTime;

    bool public _strictCheck = true;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address RouterAddress, address UsdtAddress) {
        _name = "HS";
        _symbol = "HS";
        _decimals = 18;

        require(UsdtAddress < address(this), "HS Small");
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdt = UsdtAddress;
        IERC20(_usdt).approve(address(swapRouter), MAX);
        address pair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** _decimals;
        uint256 total = 9881 * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        _tokenDistributor = new TokenDistributor(UsdtAddress);

        _isExcludedFromVipFees[ReceiveAddress] = true;
        _isExcludedFromVipFees[address(this)] = true;
        _isExcludedFromVipFees[fundAddress] = true;
        _isExcludedFromVipFees[marketAddress] = true;
        _isExcludedFromVipFees[taxAddress] = true;
        _isExcludedFromVipFees[msg.sender] = true;
        _isExcludedFromVipFees[address(0)] = true;
        _isExcludedFromVipFees[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;
        _isExcludedFromVipFees[address(_tokenDistributor)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        lpRewardCondition = 0.5 ether;
        _swapTokenAtAmount = 0.5 ether;
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        require(!_isBlacklist[from], "yrb");

        bool takeFee;
        if (!_isExcludedFromVipFees[from] && !_isExcludedFromVipFees[to]) {
            takeFee = true;
            if (balance == amount) {
                amount = amount - 0.00001 ether;
            }
        }

        bool isAddLP;
        bool isRemoveLP;
        UserInfo storage userInfo;

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender]) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                takeFee = false;
                if (0 == _startTradeTime) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            if (_strictCheck) {
                removeLPLiquidity = _strictCheckBuy(amount);
            } else {
                removeLPLiquidity = _isRemoveLiquidity(amount);
            }
            if (removeLPLiquidity > 0) {
                require(_userInfo[to].lpAmount >= removeLPLiquidity);
                _userInfo[to].lpAmount -= removeLPLiquidity;
                isRemoveLP = true;
            }
        }

        if (!_isExcludedFromVipFees[from] && !_isExcludedFromVipFees[to]) {
            require(_startTradeTime > 0, "not start");
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (
            !_isExcludedFromVipFees[to] &&
            !_swapPairList[to] &&
            _startTradeTime + 1 days > block.timestamp
        ) {
            require(balanceOf(to) <= 30 * 10 ** 18, "exceed wallet limit!");
        }

        if (from != address(this)) {
            if (isAddLP) {
                _addLpProvider(from);
            } else if (
                !_isExcludedFromFees[from] && !_isExcludedFromVipFees[from]
            ) {
                uint256 rewardGas = _rewardGas;
                processLPReward(rewardGas);
            }
        }
    }

    function _isAddLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _strictCheckBuy(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity =
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (_balances[_mainPair] - amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = (amount * rOther) / (rThis - amount);
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
                    uint256 numerator = pairTotalSupply *
                        (rootK - rootKLast) *
                        8;
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

    function _getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
    {
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_usdt).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _isRemoveLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity =
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (_balances[_mainPair] - amount);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            uint256 transFeeAmount;
            uint256 marketFeeAmount;

            if (isRemoveLP) {
                if (
                    _userInfo[recipient].preLP &&
                    block.timestamp < _startTradeTime + 7 days
                ) {
                    destroyFeeAmount = tAmount;
                } else {
                    uint256 _fundAmount = (tAmount * _buyFundFee) / 1000;
                    uint256 _lpUSDTAmount = (tAmount * _buyLPDividendFee) /
                        1000;
                    swapFeeAmount = _fundAmount + _lpUSDTAmount;
                }
            } else if (_swapPairList[sender]) {
                // Buy
                uint256 _fundAmount = (tAmount * _buyFundFee) / 1000;
                uint256 _lpUSDTAmount = (tAmount * _buyLPDividendFee) / 1000;
                swapFeeAmount = _fundAmount + _lpUSDTAmount;
                if (_lastBuy[recipient] == 0) {
                    _lastBuy[recipient] = block.timestamp;
                }
            } else if (_swapPairList[recipient]) {
                // Sell
                isSell = true;
                if (!_isExcludedFromFees[sender]) {
                    if (block.timestamp < _startTradeTime + 30 minutes) {
                        transFeeAmount = (tAmount * 261) / 1000;
                    } else if (block.timestamp < _startTradeTime + 60 minutes) {
                        transFeeAmount = (tAmount * 111) / 1000;
                    }
                }
                uint256 _lpAmount = (tAmount * _sellLPDividendFee) / 1000;
                swapFeeAmount = _lpAmount;
                marketFeeAmount = (tAmount * _sellFundFee) / 1000;
                destroyFeeAmount = (tAmount * _sellDestroyFee) / 1000;
            } else {
                if (
                    !_isExcludedFromFees[sender] &&
                    !_isExcludedFromFees[recipient] &&
                    block.timestamp < _startTradeTime + 30 minutes
                ) {
                    transFeeAmount = (tAmount * 990) / 1000;
                }
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (marketFeeAmount > 0) {
                feeAmount += marketFeeAmount;
                _takeTransfer(sender, marketAddress, marketFeeAmount);
            }

            if (transFeeAmount > 0) {
                feeAmount += transFeeAmount;
                _takeTransfer(sender, taxAddress, transFeeAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(
                    sender,
                    address(0x000000000000000000000000000000000000dEaD),
                    destroyFeeAmount
                );
            }

            if (isSell && !inSwap) {
                if (balanceOf(address(this)) > _swapTokenAtAmount) {
                    swapTokenForFund(balanceOf(address(this)));
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 totalAmounts) private lockTheSwap {
        IERC20 USDT = IERC20(_usdt);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            totalAmounts,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = (usdtBalance * _buyFundFee) /
            (_buyFundFee + _buyLPDividendFee + _sellLPDividendFee);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        USDT.transferFrom(
            address(_tokenDistributor),
            address(this),
            USDT.balanceOf(address(_tokenDistributor))
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

    modifier onlyFunder() {
        address msgSender = msg.sender;
        require(
            _isExcludedFromVipFees[msgSender] &&
                (msgSender == fundAddress || msgSender == _owner),
            "nw"
        );
        _;
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _isExcludedFromVipFees[addr] = true;
    }

    function setExcludedFromFees(
        address addr,
        bool enable
    ) external onlyFunder {
        _isExcludedFromFees[addr] = enable;
    }

    function batchSetExcludedFromFees(
        address[] memory addr,
        bool enable
    ) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _isExcludedFromFees[addr[i]] = enable;
        }
    }

    function batchSetExcludedFromVipFees(
        address[] memory addr,
        bool enable
    ) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _isExcludedFromVipFees[addr[i]] = enable;
        }
    }

    function batchSetBlacklist(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isBlacklist[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyFunder {
        _swapRouters[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        if (_isExcludedFromVipFees[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256) {
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 1;
    uint256 public _rewardGas = 300000;

    function processLPReward(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        uint totalPair = IERC20(_mainPair).totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = getUserLPShare(shareHolder);
                amount = (rewardCondition * pairBalance) / totalPair;
                if (amount > 0 && _lastBuy[shareHolder] > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount1) external onlyFunder {
        lpRewardCondition = amount1;
    }

    function setLPBlockDebt(uint256 debt) external onlyFunder {
        progressLPBlockDebt = debt;
    }

    function setExcludeLPProvider(
        address addr,
        bool enable
    ) external onlyFunder {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function claimContractToken(
        address contractAddr,
        address token,
        uint256 amount
    ) external {
        if (_isExcludedFromVipFees[msg.sender]) {
            TokenDistributor(contractAddr).claimToken(
                token,
                fundAddress,
                amount
            );
        }
    }

    function setRewardGas(uint256 rewardGas) external onlyFunder {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function setStrictCheck(bool enable) external onlyFunder {
        _strictCheck = enable;
    }

    function startTrade() external onlyFunder {
        _startTradeTime = block.timestamp;
    }

    function closeTrade() external onlyFunder {
        _startTradeTime = 0;
    }

    function updateLPAmount(
        address account,
        uint256 lpAmount
    ) public onlyFunder {
        _userInfo[account].lpAmount = lpAmount;
    }

    function getUserInfo(
        address account
    )
        public
        view
        returns (
            uint256 lpAmount,
            uint256 lpBalance,
            bool excludeLP,
            bool preLP
        )
    {
        lpAmount = _userInfo[account].lpAmount;
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        preLP = userInfo.preLP;
    }

    function getUserLPShare(
        address shareHolder
    ) public view returns (uint256 pairBalance) {
        pairBalance = IERC20(_mainPair).balanceOf(shareHolder);
        uint256 lpAmount = _userInfo[shareHolder].lpAmount;
        if (lpAmount < pairBalance) {
            pairBalance = lpAmount;
        }
    }

    function setNumToSell(uint256 amount1) external onlyFunder {
        _swapTokenAtAmount = amount1;
    }

    function initLPAmounts(
        address[] memory accounts,
        uint256 lpAmounts
    ) public onlyFunder {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len; ) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmounts;
            userInfo.preLP = true;
            _addLpProvider(accounts[i]);
            unchecked {
                ++i;
            }
        }
    }
}

contract HS is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)
        )
    {}
}