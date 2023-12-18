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
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5')))));
    }
}

contract TokenDistributor {

    constructor (address token) {

        IERC20(token).approve(msg.sender, ~uint256(0));
    }

}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        uint256 rewardDebt;
        uint256 nodeAmount;
        uint256 nodeRewardDebt;
        uint256 inviteLPAmount;
        uint256 claimedMintReward;
        uint256 claimedNodeReward;
        uint256 inviteReward;
    }

    struct PoolInfo {
        uint256 totalAmount;
        uint256 accMintPerShare;
        uint256 accMintReward;
        uint256 mintPerBlock;
        uint256 lastMintBlock;
        uint256 totalMintReward;
        uint256 totalNodeAmount;
        uint256 accNodeRewardPerShare;
        uint256 accNodeReward;
        uint256 mintAmountPerDay;
    }

    PoolInfo private _poolInfo;
    uint256 private constant _rewardFactor = 1e12;
    uint256 private constant _dailyBlockNum = 1 days / 3;
    uint256 public _startMintBlock;
    uint256 private constant _initMintRate = 600000;
    uint256 private constant _mintRateDiv = 100000000;
    uint256 private constant _minusMintRateDays = 200;
    uint256 private immutable _stableMintPerDay;

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

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
    uint256 private constant _buyFundFee = 200;
    uint256 private constant _buyRootFee = 300;
    uint256 private constant _sellFundFee = 200;
    uint256 private constant _sellRootFee = 300;

    uint256 public startTradeBlock;
    address public immutable _mainPair;
    address public  immutable _usdt;

    bool public _strictCheck = true;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binders;
    uint256 public _bindCondition;
    mapping(address => bool) public _rootList;
    mapping(address => address) public _rootInvitor;
    mapping(address => uint256) public _txTimes;
    uint256 public _freezeBlockNum = 4;
    uint256 public _startMintLPHolderNum = 30;

    uint256 private immutable _nodeSelfLPCondition;
    uint256 private immutable _nodeInviteLPCondition;
    TokenDistributor public immutable _usdtDistributor;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address UsdtAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdt = UsdtAddress;
        IERC20(_usdt).approve(address(swapRouter), MAX);

        address usdtPair;
        if (address(1) == RouterAddress) {
            usdtPair = PancakeLibrary.pairFor(address(swapFactory), _usdt, address(this));
        } else {
            usdtPair = swapFactory.createPair(_usdt, address(this));
        }
        _swapPairList[usdtPair] = true;
        _mainPair = usdtPair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = FundAddress;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _bindCondition = 100 * tokenUnit / 100000;
        _poolInfo.totalMintReward = 9500000 * tokenUnit;
        _stableMintPerDay = 555 * tokenUnit;

        uint256 usdtUnit = 10 ** IERC20(UsdtAddress).decimals();
        _minInviteLPUsdt = 200 * usdtUnit;
        _maxInviteLPUsdt = 2000 * usdtUnit;

        _nodeSelfLPCondition = 2000 * usdtUnit;
        _nodeInviteLPCondition = 6000 * usdtUnit;

        _usdtDistributor = new TokenDistributor(UsdtAddress);
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
        if (_swapPairList[account]) {
            return _balances[account];
        }
        (uint256 mintReward, uint256 nodeReward) = _calPendingMintReward(account);
        return _balances[account] + mintReward + nodeReward;
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
        if (!_feeWhiteList[from] && !_feeWhiteList[to] && !_rootList[from] && !_rootList[to]) {
            uint256 maxSellAmount = balance * 999999 / 1000000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }

        bool isAddLP;
        bool isRemoveLP;

        uint256 addLPLiquidity;
        bool updateNode = true;
        if (to == _mainPair && _swapRouters[msg.sender]) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                isAddLP = true;
                takeFee = false;
                updateNode = false;
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _strictCheckBuy(amount);
            if (removeLPLiquidity > 0) {
                if (to != fundAddress) {
                    require(_userInfo[to].lpAmount >= removeLPLiquidity);
                    if (0 == IERC20(_mainPair).balanceOf(to)) {
                        removeLPLiquidity = _userInfo[to].lpAmount;
                    }
                    isRemoveLP = true;
                    updateNode = false;
                } else {
                    removeLPLiquidity = 0;
                }
            }
        }

        (uint256 tokenPrice, uint256 totalLPValue) = getTokenPriceAndTotalLPValue();
        if (from != address(this)) {
            _claimMintReward(tx.origin, tokenPrice, totalLPValue, removeLPLiquidity, updateNode);
            _updateHighestPrice(tokenPrice);
        }

        if (addLPLiquidity > 0) {
            _deposit(from, addLPLiquidity, false);
        } else if (removeLPLiquidity > 0) {
            _withdraw(to, removeLPLiquidity, false, removeLPLiquidity);
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock);
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        } else {
            if (amount == _bindCondition && address(0) == _invitor[from] && 0 == _userInfo[from].lpAmount) {
                _bindInvitor(from, to);
                if (_rootList[to]) {
                    _rootInvitor[from] = to;
                } else {
                    _rootInvitor[from] = _rootInvitor[to];
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            if (isAddLP) {
                _addLpProvider(from);
            }
        }
    }

    function _bindInvitor(address account, address invitor) private {
        if (_invitor[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _invitor[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
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
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {numerator = pairTotalSupply * (rootK - rootKLast);
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
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            uint256 blockNum = block.number;
            address txOrigin = tx.origin;
            uint256 freezeBlockNum = _freezeBlockNum;
            require(blockNum > _txTimes[txOrigin] + freezeBlockNum);
            if (isRemoveLP) {
                require(blockNum > _txTimes[recipient] + freezeBlockNum);
                _txTimes[recipient] = blockNum;
            } else if (_swapPairList[sender]) {uint256 buyFundFeeAmount = tAmount * _buyFundFee / 10000;
                feeAmount += buyFundFeeAmount;
                _takeTransfer(sender, fundAddress, buyFundFeeAmount);

                uint256 buyRootFeeAmount = tAmount * _buyRootFee / 10000;
                feeAmount += buyRootFeeAmount;
                address rootInvitor = _rootInvitor[recipient];
                if (address(0) == rootInvitor) {
                    rootInvitor = fundAddress;
                }
                _takeTransfer(sender, rootInvitor, buyRootFeeAmount);

                require(blockNum > _txTimes[recipient] + freezeBlockNum);
                _txTimes[recipient] = blockNum;
                if (_isContract(recipient) || txOrigin != recipient) {
                    _blackList[recipient] = true;
                }
            } else if (_swapPairList[recipient]) {require(txOrigin == sender);
                require(blockNum > _txTimes[sender] + freezeBlockNum);
                _txTimes[sender] = blockNum;
                uint256 swapFeeAmount = tAmount * (_sellFundFee + _sellRootFee) / 10000;
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
                if (!inSwap) {
                    address rootInvitor = _rootInvitor[sender];
                    if (address(0) == rootInvitor) {
                        rootInvitor = fundAddress;
                    }
                    swapTokenForFund(swapFeeAmount, rootInvitor);
                }
            } else {
                require(blockNum > _txTimes[sender] + freezeBlockNum);
                _txTimes[sender] = blockNum;
            }
            _txTimes[txOrigin] = blockNum;
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, address rootInvitor) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }

        address usdt = _usdt;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        address usdtDistributor = address(_usdtDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            usdtDistributor,
            block.timestamp
        );
        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(usdtDistributor);
        uint256 fundUsdt = usdtBalance * _sellFundFee / (_sellFundFee + _sellRootFee);
        if (fundUsdt > 0) {
            USDT.transferFrom(usdtDistributor, fundAddress, fundUsdt);
            usdtBalance -= fundUsdt;
        }
        if (usdtBalance > 0) {
            USDT.transferFrom(usdtDistributor, rootInvitor, usdtBalance);
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

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
                if (0 == _startMintBlock && lpProviders.length >= _startMintLPHolderNum) {
                    _poolInfo.lastMintBlock = block.number + _dailyBlockNum;
                    _startMintBlock = block.number + _dailyBlockNum;
                }
            }
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchCheckWhiteList(address [] memory addr) external view returns (bool[] memory isWhiteList) {
        isWhiteList = new bool[](addr.length);
        for (uint i = 0; i < addr.length; i++) {
            isWhiteList[i] = _feeWhiteList[addr[i]];
        }
    }

    function setRootList(address addr, bool enable) external onlyOwner {
        _rootList[addr] = enable;
    }

    function batchSetRootList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _rootList[addr[i]] = enable;
        }
    }

    function batchCheckRootList(address [] memory addr) external view returns (bool[] memory isRootList) {
        isRootList = new bool[](addr.length);
        for (uint i = 0; i < addr.length; i++) {
            isRootList[i] = _rootList[addr[i]];
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

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    receive() external payable {}

    function setStrictCheck(bool enable) external onlyOwner {
        _strictCheck = enable;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
    }

    function setBindCondition(uint256 c) public onlyOwner {
        _bindCondition = c;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyOwner {
        UserInfo storage userInfo = _userInfo[account];
        uint256 preAmount = userInfo.lpAmount;
        if (preAmount > lpAmount) {
            _withdraw(account, preAmount - lpAmount, true, 0);
        } else {
            _deposit(account, lpAmount - preAmount, true);
        }
        _addLpProvider(account);
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount,
        uint256 rewardDebt,
        uint256 nodeAmount,
        uint256 nodeRewardDebt,
        uint256 inviteLPAmount,
        uint256 lpBalance,
        uint256 tokenBalance,
        uint256 claimedMintReward,
        uint256 claimedNodeReward,
        uint256 inviteReward,
        uint256 pendingMintReward,
        uint256 pendingNodeReward
    ) {
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        rewardDebt = userInfo.rewardDebt;
        nodeAmount = userInfo.nodeAmount;
        nodeRewardDebt = userInfo.nodeRewardDebt;
        inviteLPAmount = userInfo.inviteLPAmount;
        lpBalance = IERC20(_mainPair).balanceOf(account);
        tokenBalance = balanceOf(account);
        claimedMintReward = userInfo.claimedMintReward;
        claimedNodeReward = userInfo.claimedNodeReward;
        inviteReward = userInfo.inviteReward;
        (pendingMintReward, pendingNodeReward) = _calPendingMintReward(account);
    }

    function getPoolInfo() public view returns (
        uint256 totalAmount,
        uint256 accMintPerShare,
        uint256 accMintReward,
        uint256 mintPerBlock,
        uint256 lastMintBlock,
        uint256 totalMintReward,
        uint256 totalNodeAmount,
        uint256 accNodeRewardPerShare,
        uint256 accNodeReward,
        uint256 mintAmountPerDay,
        uint256 lpTotalSupply,
        uint256 tokenPrice,
        uint256 totalLPValue
    ) {
        totalAmount = _poolInfo.totalAmount;
        accMintPerShare = _poolInfo.accMintPerShare;
        accMintReward = _poolInfo.accMintReward;
        mintPerBlock = _poolInfo.mintPerBlock;
        lastMintBlock = _poolInfo.lastMintBlock;
        totalMintReward = _poolInfo.totalMintReward;
        totalNodeAmount = _poolInfo.totalNodeAmount;
        accNodeRewardPerShare = _poolInfo.accNodeRewardPerShare;
        accNodeReward = _poolInfo.accNodeReward;
        mintAmountPerDay = _poolInfo.mintAmountPerDay;
        lpTotalSupply = IERC20(_mainPair).totalSupply();
        (tokenPrice, totalLPValue) = getTokenPriceAndTotalLPValue();
    }

    function _testSetStartMintBlock(uint256 b) external onlyOwner {
        require(b > 0, "not 0");
        require(_startMintBlock > 0, "not started");
        _startMintBlock = b;
    }

    function _testSetFreezeBlockNum(uint256 n) external onlyOwner {
        _freezeBlockNum = n;
    }

    function _testSetStartMintLPHolderNum(uint256 n) external onlyOwner {
        _startMintLPHolderNum = n;
    }

    function _testStartMint() external onlyOwner {
        require(_poolInfo.lastMintBlock > block.number, "started");
        _poolInfo.lastMintBlock = block.number;
        _startMintBlock = block.number;
    }

    function _mintReward(uint256 amount, uint256 realReward) private {
        _tTotal += amount;
        uint256 destroyAmount = amount - realReward;
        if (destroyAmount > 0) {
            _balances[address(0x000000000000000000000000000000000000dEaD)] += destroyAmount;
            emit Transfer(address(0), address(0x000000000000000000000000000000000000dEaD), destroyAmount);
        }
        _balances[address(this)] += realReward;
        emit Transfer(address(0), address(this), realReward);
    }

    function _deposit(address account, uint256 amount, bool shouldClaim) private {
        require(account != fundAddress, "NF");
        (uint256 tokenPrice, uint256 totalLPValue) = getTokenPriceAndTotalLPValue();
        if (shouldClaim) {
            _claimMintReward(account, tokenPrice, totalLPValue, 0, false);
        }
        UserInfo storage user = _userInfo[account];
        user.lpAmount += amount;
        _poolInfo.totalAmount += amount;
        user.rewardDebt = user.lpAmount * _poolInfo.accMintPerShare / _rewardFactor;

        _updateNodeInfo(account, totalLPValue, 0);
        address invitor = _invitor[account];
        if (address(0) != invitor) {
            _userInfo[invitor].inviteLPAmount += amount;
            _updateNodeInfo(invitor, totalLPValue, 0);
        }
    }

    function _withdraw(address account, uint256 amount, bool shouldClaim, uint256 removeLPAmount) private {
        require(account != fundAddress, "NF");
        (uint256 tokenPrice, uint256 totalLPValue) = getTokenPriceAndTotalLPValue();
        if (shouldClaim) {
            _claimMintReward(account, tokenPrice, totalLPValue, 0, false);
        }
        UserInfo storage user = _userInfo[account];
        user.lpAmount -= amount;
        _poolInfo.totalAmount -= amount;
        user.rewardDebt = user.lpAmount * _poolInfo.accMintPerShare / _rewardFactor;

        _updateNodeInfo(account, totalLPValue, removeLPAmount);
        address invitor = _invitor[account];
        if (address(0) != invitor) {
            _userInfo[invitor].inviteLPAmount -= amount;
            _updateNodeInfo(invitor, totalLPValue, removeLPAmount);
        }
    }

    function claimMintReward(address account) public {
        require(tx.origin == msg.sender, "NC");
        (uint256 tokenPrice, uint256 totalLPValue) = getTokenPriceAndTotalLPValue();
        _claimMintReward(account, tokenPrice, totalLPValue, 0, true);
    }

    function _claimMintReward(address account, uint256 price, uint256 totalLPValue, uint256 removeLPLiquidity, bool updateNode) private {
        _updatePool(price);
        UserInfo storage user = _userInfo[account];
        uint256 pendingMint;
        uint256 lpAmount = user.lpAmount;
        if (lpAmount > 0) {
            uint256 accMintReward = lpAmount * _poolInfo.accMintPerShare / _rewardFactor;
            pendingMint = accMintReward - user.rewardDebt;
            if (pendingMint > 0) {
                user.rewardDebt = accMintReward;
            }
        }
        if (pendingMint > 0) {
            user.claimedMintReward += pendingMint;
            _giveMintReward(account, pendingMint);
            _claimNodeReward(account, totalLPValue, removeLPLiquidity, updateNode);

            uint256 inviteAmount = pendingMint * _lpMintInviteRate / 10000;
            uint256 destroyAmount = inviteAmount;
            address invitor = _invitor[account];
            if (address(0) != invitor) {
                uint256 invitorLPAmount = _userInfo[invitor].lpAmount;
                uint256 invitorLPValue = invitorLPAmount * totalLPValue / (IERC20(_mainPair).totalSupply() + removeLPLiquidity);
                if (invitorLPValue >= _maxInviteLPUsdt) {
                    destroyAmount = 0;
                } else if (invitorLPValue >= _minInviteLPUsdt) {
                    if (invitorLPAmount >= lpAmount) {
                        destroyAmount = 0;
                    } else {
                        inviteAmount = inviteAmount * invitorLPAmount / lpAmount;
                        destroyAmount -= inviteAmount;
                    }
                } else {
                    inviteAmount = 0;
                }
                if (inviteAmount > 0) {
                    _userInfo[invitor].inviteReward += inviteAmount;
                    _giveMintReward(invitor, inviteAmount);
                }
                _claimNodeReward(invitor, totalLPValue, removeLPLiquidity, updateNode);
            }
            if (destroyAmount > 0) {
                _giveMintReward(address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }
        }
    }

    function _claimNodeReward(address account, uint256 totalLPValue, uint256 removeLPLiquidity, bool updateNode) private {
        UserInfo storage user = _userInfo[account];
        uint256 pendingNodeMint;
        uint256 nodeAmount = user.nodeAmount;
        if (nodeAmount > 0) {
            uint256 accNodeMintReward = nodeAmount * _poolInfo.accNodeRewardPerShare / _rewardFactor;
            pendingNodeMint = accNodeMintReward - user.nodeRewardDebt;
            if (pendingNodeMint > 0) {
                user.nodeRewardDebt = accNodeMintReward;
                _giveMintReward(account, pendingNodeMint);
                user.claimedNodeReward += pendingNodeMint;
            }
        }
        if (updateNode) {
            _updateNodeInfo(account, totalLPValue, removeLPLiquidity);
        }
    }

    function _giveMintReward(address account, uint256 amount) private {
        _funTransfer(address(this), account, amount, 0);
    }

    function _updatePool(uint256 price) private {
        PoolInfo storage pool = _poolInfo;
        uint256 blockNum = block.number;
        uint256 lastRewardBlock = pool.lastMintBlock;
        if (0 == lastRewardBlock || blockNum <= lastRewardBlock) {
            return;
        }
        pool.lastMintBlock = blockNum;

        uint256 accReward = pool.accMintReward;
        uint256 totalReward = pool.totalMintReward;
        if (accReward >= totalReward) {
            return;
        }

        uint256 totalAmount = pool.totalAmount;
        uint256 rewardPerBlock = pool.mintPerBlock;
        if (0 < totalAmount && 0 < rewardPerBlock) {
            uint256 reward = rewardPerBlock * (blockNum - lastRewardBlock);
            uint256 remainReward = totalReward - accReward;
            if (reward > remainReward) {
                reward = remainReward;
            }
            if (reward > 0) {
                uint256 realReward = reward;
                uint256 highestPrice = _highestPrice;
                if (price < highestPrice * _mintDestroyTokenPriceRate / 10000) {
                    realReward = reward * price / highestPrice;
                }
                uint256 lpMintReward = realReward * _lpMintRate / 10000;
                pool.accMintPerShare += lpMintReward * _rewardFactor / totalAmount;
                pool.accMintReward += lpMintReward;

                _mintReward(reward, realReward);

                uint256 nodeMintReward = realReward * _nodeMintRate / 10000;
                uint256 totalNodeAmount = pool.totalNodeAmount;
                if (totalNodeAmount > 0) {
                    pool.accNodeRewardPerShare += nodeMintReward * _rewardFactor / totalNodeAmount;
                    pool.accNodeReward += nodeMintReward;
                } else {
                    _giveMintReward(address(0x000000000000000000000000000000000000dEaD), nodeMintReward);
                }
            }
        }
        _updateDailyMintAmount();
    }

    mapping(uint256 => uint256) public _dailyMintAmount;
    uint256 private constant _mintDestroyTokenPriceRate = 7000;
    uint256 private constant _lpMintRate = 6200;
    uint256 private constant _nodeMintRate = 700;
    uint256 private constant _lpMintInviteRate = 5000;
    uint256 private immutable _minInviteLPUsdt;
    uint256 private immutable _maxInviteLPUsdt;

    function getMintDayNum() public view returns (uint256){
        uint256 startBlock = _startMintBlock;
        uint256 nowBlock = block.number;
        if (0 == startBlock || nowBlock < startBlock) {
            return 0;
        }
        return (nowBlock - startBlock) / _dailyBlockNum + 1;
    }

    function _updateDailyMintAmount() private {
        uint256 dayNum = getMintDayNum();
        if (0 == dayNum) {
            return;
        }
        if (0 == _dailyMintAmount[dayNum]) {
            uint256 mintAmountPerDay = getMintAmountPerDay(dayNum);
            _dailyMintAmount[dayNum] = mintAmountPerDay;
            _poolInfo.mintPerBlock = mintAmountPerDay / _dailyBlockNum;
            _poolInfo.mintAmountPerDay = mintAmountPerDay;
        }
    }

    function getMintAmountPerDay(uint256 dayNum) public view returns (uint256){
        if (0 == dayNum) {
            return 0;
        }
        uint256 times = (dayNum - 1) / _minusMintRateDays;
        if (times >= 7) {
            return _stableMintPerDay;
        }
        return totalSupply() * _initMintRate / (2 ** times) / _mintRateDiv;
    }

    function _calPendingMintReward(address account) public view returns (uint256 mintReward, uint256 nodeReward) {
        UserInfo storage user = _userInfo[account];
        if (user.lpAmount > 0) {
            PoolInfo storage pool = _poolInfo;
            uint256 poolPendingReward;
            uint256 blockNum = block.number;
            uint256 lastRewardBlock = pool.lastMintBlock;
            if (lastRewardBlock > 0 && blockNum > lastRewardBlock) {
                poolPendingReward = pool.mintPerBlock * (blockNum - lastRewardBlock);
                uint256 totalReward = pool.totalMintReward;
                uint256 accReward = pool.accMintReward;
                uint256 remainReward;
                if (totalReward > accReward) {
                    remainReward = totalReward - accReward;
                }
                if (poolPendingReward > remainReward) {
                    poolPendingReward = remainReward;
                }
            }

            uint256 realReward = poolPendingReward;
            uint256 highestPrice = _highestPrice;
            (uint256 price,) = getTokenPriceAndTotalLPValue();
            if (price < highestPrice * _mintDestroyTokenPriceRate / 10000) {
                realReward = poolPendingReward * price / highestPrice;
            }
            uint256 lpMintReward = realReward * _lpMintRate / 10000;
            mintReward += user.lpAmount * (pool.accMintPerShare + lpMintReward * _rewardFactor / pool.totalAmount) / _rewardFactor - user.rewardDebt;

            uint256 nodeAmount = user.nodeAmount;
            if (nodeAmount > 0) {
                uint256 nodeMintReward = realReward * _nodeMintRate / 10000;
                nodeReward += nodeAmount * (pool.accNodeRewardPerShare + nodeMintReward * _rewardFactor / pool.totalNodeAmount) / _rewardFactor - user.nodeRewardDebt;
            }
        }
    }

    uint256 public _highestPrice;

    function _updateHighestPrice(uint256 price) private {
        if (price > _highestPrice) {
            _highestPrice = price;
        }
    }

    function getTokenPriceAndTotalLPValue() public view returns (uint256 price, uint256 totalLPValue){
        (uint256 rUsdt, uint256 rToken) = __getReserves();
        totalLPValue = 2 * rUsdt;
        if (rToken > 0) {
            price = 10 ** _decimals * rUsdt / rToken;
        }
    }

    function _updateNodeInfo(address account, uint256 totalLPValue, uint256 removeLPLiquidity) private {
        uint256 lpTotalSupply = IERC20(_mainPair).totalSupply() + removeLPLiquidity;
        if (0 == lpTotalSupply) {
            return;
        }
        UserInfo storage user = _userInfo[account];
        uint256 lpAmount = user.lpAmount;
        uint256 lpValue = lpAmount * totalLPValue / lpTotalSupply;
        uint256 inviteLPAmount = user.inviteLPAmount;
        uint256 inviteLPValue = inviteLPAmount * totalLPValue / lpTotalSupply;
        uint256 nodeAmount = user.nodeAmount;
        if (lpValue < _nodeSelfLPCondition || inviteLPValue < _nodeInviteLPCondition) {
            if (nodeAmount > 0) {
                _nodeWithdraw(account, nodeAmount);
            }
        } else {if (lpAmount + inviteLPAmount > nodeAmount) {_nodeDeposit(account, lpAmount + inviteLPAmount - nodeAmount);
        } else if (lpAmount + inviteLPAmount < nodeAmount) {_nodeWithdraw(account, nodeAmount - inviteLPAmount - lpAmount);
        }
        }
    }

    function _nodeDeposit(address account, uint256 amount) private {
        UserInfo storage user = _userInfo[account];
        user.nodeAmount += amount;
        _poolInfo.totalNodeAmount += amount;
        user.nodeRewardDebt = user.nodeAmount * _poolInfo.accNodeRewardPerShare / _rewardFactor;
    }

    function _nodeWithdraw(address account, uint256 amount) private {
        UserInfo storage user = _userInfo[account];
        user.nodeAmount -= amount;
        _poolInfo.totalNodeAmount -= amount;
        user.nodeRewardDebt = user.nodeAmount * _poolInfo.accNodeRewardPerShare / _rewardFactor;
    }

    function _isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function getBinderList(
        address account,
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        address[] memory binders,
        uint256[] memory binderLPAmounts,
        uint256[] memory binderLPBalances
    ){
        address[] storage tempBinders = _binders[account];
        uint256 recordLen = tempBinders.length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;
        binders = new address[](length);
        binderLPAmounts = new uint256[](length);
        binderLPBalances = new uint256[](length);
        uint256 index = 0;
        address binder;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, binders, binderLPAmounts, binderLPBalances);
            }
            binder = tempBinders[i];
            binders[index] = binder;
            binderLPAmounts[index] = _userInfo[binder].lpAmount;
            binderLPBalances[index] = IERC20(_mainPair).balanceOf(binder);
            index++;
        }
    }
}

contract DikeCoin is AbsToken {
    constructor() AbsToken(
    address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    address(0x55d398326f99059fF775485246999027B3197955),
    "Dike.Coin",
    "DIKE",
    18,
    500000,
    address(0x633cB8Df71Cd4eaF8B170b33455f2efDFa8167AF),
    address(0x013bCf42aE7420215Eb1B28ed9426AAb1E464C98)
    ){

    }
}