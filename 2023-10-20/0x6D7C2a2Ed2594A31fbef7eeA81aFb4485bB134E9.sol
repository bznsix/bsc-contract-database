// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

interface IERC20 {
    function decimals() external view returns (uint256);

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

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function feeTo() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
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

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function kLast() external view returns (uint);

}

contract Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public fundAddress;
    address payable public fundAddress_2;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public kb;
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWalletAmount;
    bool public limitEnable = true;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _rewardList;
    mapping(address => bool) public isMaxEatExempt;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    TokenDistributor public _rewardTokenDistributor;

    uint256 public _buyFundFee;
    uint256 public _buyLPFee;
    uint256 public _buyRewardFee;
    uint256 public buy_burnFee;
    uint256 public buy_BackBurnFee;


    uint256 public _sellFundFee;
    uint256 public _sellLPFee;
    uint256 public _sellRewardFee;
    uint256 public sell_burnFee;
    uint256 public sell_BackBurnFee;

    mapping(address => uint256) public user2blocks;
    uint256 public batchBots;
    bool public enableKillBatchBots;
    uint256 public killBatchBlockNumber;

    bool currencyIsEth;

    address public ETH;
    uint256 public startTradeBlock;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public enableOffTrade;
    bool public enableKillBlock;
    bool public enableRewardList;
    bool public enableSwapLimit;
    bool public enableWalletLimit;
    bool public enableChangeTax;
    bool public enableInvitor = true;

    uint256 public swapAtAmount;
    function setSwapAtAmount(uint256 newValue) public onlyOwner{
        swapAtAmount = newValue;
    }

    address[] public rewardPath;

    constructor() {
        _name = "LONG";
        _symbol = "LONG";
        _decimals = 18;
        uint256 total = 20240 * 10 ** _decimals;
        _tTotal = total;

        fundAddress = payable(0xC6C492272c9D7260623C75aA121eb1577197387b);
        fundAddress_2 = payable(0x0f02e656625107Bfc24E4F02dA9F488e70cdbb37);
        require(!isContract(fundAddress), "fundaddress is a contract");

        currency = 0x55d398326f99059fF775485246999027B3197955;
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address ReceiveAddress = 0x725B61832e674d9Ba1Df9B5833d71b77672FC8C2;
        ETH = 0x55d398326f99059fF775485246999027B3197955;
        require(address(this) > ETH);
        maxBuyAmount = _tTotal;
        maxSellAmount = _tTotal;
        require(
            maxSellAmount >= maxBuyAmount,
            " maxSell should be > than maxBuy "
        );

        maxWalletAmount = _tTotal;

        enableOffTrade = true;
        enableKillBlock = true;
        enableRewardList = true;

        enableSwapLimit = true;
        enableWalletLimit = true;
        enableChangeTax = true;
        currencyIsEth = false;
        // enableKillBatchBots = false;
        // enableTransferFee = false;

        rewardPath = [address(this), currency];
        // if (currency != ETH) {
        //     if (currencyIsEth == false) {
        //         rewardPath.push(swapRouter.WETH());
        //     }
        //     if (ETH != swapRouter.WETH()) rewardPath.push(ETH);
        // }

        IERC20(currency).approve(address(swapRouter), MAX);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _allowances[address(msg.sender)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), currency);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _buyFundFee = 0;
        _buyLPFee = 0;
        _buyRewardFee = 0;
        buy_burnFee = 0;
        buy_BackBurnFee = 0;

        _sellFundFee = 200;
        _sellLPFee = 10;
        _sellRewardFee = 300;
        sell_burnFee = 10;
        sell_BackBurnFee = 100;
        _1_buyBackToken = 0x8688D752243ECC88C756d493d767A6F566666666;
        _2_buyBackToken = 0xcfCF1705589710F2ce5cE47AdeCE090bA16d1C80;
        


        killBatchBlockNumber = 0;
        kb = 3;
        airdropNumbs = 3;
        require(airdropNumbs <= 3, "airdropNumbs should be <= 3");

        //invitor
        beInvitorThreshold = 10 ** _decimals / 10000;
        // require(numberParams[17] <= 7, "length should be <= 7");
        invitorRewardPercentList = new uint256[](1);
        invitorRewardPercentList[0] = 100;
        // invitorRewardPercentList[1] = 60;
        // invitorRewardPercentList[2] = 40;
        
        // totalInvitorFee = 0;
        // for (uint256 i = 0; i < invitorRewardPercentList.length; i++) {
        //     invitorRewardPercentList[i] = numberParams[18 + i];
        //     totalInvitorFee += invitorRewardPercentList[i];
        // }

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        swapAtAmount = total / 10000 * 2;

        _isExcludedFromFee[fundAddress] = true;
        _isExcludedFromFee[fundAddress_2] = true;
        _isExcludedFromFee[ReceiveAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        // _isExcludedFromFee[address(swapRouter)] = true;
        _isExcludedFromFee[msg.sender] = true;

        _swapRouters[address(swapRouter)] = true;

        isMaxEatExempt[msg.sender] = true;
        isMaxEatExempt[fundAddress] = true;
        isMaxEatExempt[fundAddress_2] = true;
        isMaxEatExempt[ReceiveAddress] = true;
        isMaxEatExempt[address(swapRouter)] = true;
        isMaxEatExempt[address(_mainPair)] = true;
        isMaxEatExempt[address(this)] = true;
        isMaxEatExempt[address(0xdead)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 10 * 10 ** IERC20(ETH).decimals();

        _tokenDistributor = new TokenDistributor(currency);
        _rewardTokenDistributor = new TokenDistributor(ETH);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint256) {
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

    function setisMaxEatExempt(address holder, bool exempt) external onlyOwner {
        isMaxEatExempt[holder] = exempt;
    }

    function setkb(uint256 a) public onlyOwner {
        kb = a;
    }

    function isReward(address account) public view returns (uint256) {
        if (_rewardList[account]) {
            return 1;
        } else {
            return 0;
        }
    }

    bool public airdropEnable = true;

    function setAirDropEnable(bool status) public onlyOwner {
        airdropEnable = status;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    uint256 public airdropNumbs = 0;

    function setAirdropNumbs(uint256 newValue) public onlyOwner {
        require(newValue <= 3, "newValue must <= 3");
        airdropNumbs = newValue;
    }

    bool public enableTransferFee = false;

    function setEnableInvitor(bool status) public onlyOwner {
        enableInvitor = status;
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

    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => UserInfo) private _userInfo;
    function updateLPAmount(address account, uint256 lpAmount) public onlyOwner {
        _userInfo[account].lpAmount = lpAmount;
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP, bool preLP
    ) {
        lpAmount = _userInfo[account].lpAmount;
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeHolder[account];
        UserInfo storage userInfo = _userInfo[account];
        preLP = userInfo.preLP;
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyOwner {
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

    function matchInitLPAmounts(address[] memory accounts) public onlyOwner {
        uint256 len = accounts.length;
        ISwapPair mainPair = ISwapPair(_mainPair);

        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = mainPair.balanceOf(accounts[i]) + 1;
            userInfo.preLP = true;
            addHolder(accounts[i]);
        unchecked{
            ++i;
        }
        }
    }

    mapping(address => bool) public _swapRouters;
    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    bool public _strictCheck = true;
    function setStrictCheck(bool enable) external onlyOwner{
        _strictCheck = enable;
    }

    uint256 public checkRemoveMode = 1;
    function changeCheckRemoveMode(
        uint256 newValue
    ) public onlyOwner {
        checkRemoveMode = newValue;
    }

    function _strictCheckBuy(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply()) /
            (_balances[_mainPair] - amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
                //strictCheckBuy
                require(balanceOther >= amountOther + rOther);
            }
        }
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / 
            (balanceOf(_mainPair) - amount);
        }
    }

    function _isRemoveLiquidity_2(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther <= rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) /
            (balanceOf(_mainPair) - amount - 1);
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = currency;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }

        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = _balances[from];
        require(balance >= amount, "balanceNotEnough");

        if (isReward(from) > 0) {
            require(false, "isReward > 0 !");
        }
        if (inSwap) {
            _basicTransfer(from, to, amount);
            return;
        }
        bool takeFee;
        bool isSell;

        bool isTransfer;


        if (
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to] &&
            !_swapPairList[from] &&
            !_swapPairList[to] &&
            startTradeBlock == 0
        ){
            require(
                !isContract(to),"cant add other lp"
            );
        }

        if (
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to] &&
            airdropEnable &&
            airdropNumbs > 0 && 
            (
                _swapPairList[from] || _swapPairList[to]
            )
        ) {
            address ad;
            for (uint256 i = 0; i < airdropNumbs; i++) {
                ad = address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _basicTransfer(from, ad, 1);
            }
            amount -= airdropNumbs * 1;
        }


        bool isRemove;
        bool isAdd;
        UserInfo storage userInfo;

        uint256 addLPLiquidity;
        if (
            _swapPairList[to] &&
            _swapRouters[msg.sender]
        ) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0 && !isContract(from)) {
                userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAdd = true;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
            }
        }
        
        uint256 removeLPLiquidity;
        if(
            _swapPairList[from]
        ) {
           if (_strictCheck) {
                removeLPLiquidity = _strictCheckBuy(amount);
            } else {
                if (checkRemoveMode == 1){
                    removeLPLiquidity = _isRemoveLiquidity(amount);
                }else{
                    removeLPLiquidity = _isRemoveLiquidity_2(amount);
                }
            }

            if (removeLPLiquidity > 0) {
                require(_userInfo[to].lpAmount >= removeLPLiquidity);
                _userInfo[to].lpAmount -= removeLPLiquidity;
                isRemove = true;
            }

        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                bool star = startTradeBlock > 0;
                require(
                    star || (0 < startLPBlock && isAdd),
                    "pausing"
                );

                if (
                    enableOffTrade &&
                    enableKillBlock &&
                    block.number < startTradeBlock + kb &&
                    !_swapPairList[to]
                ) {
                    // _rewardList[to] = true;
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = _balances[address(this)];
                        if (contractTokenBalance > swapAtAmount) {
                            uint256 swapFee = _buyFundFee +
                                _buyRewardFee +
                                _buyLPFee +
                                buy_BackBurnFee + 
                                _sellFundFee +
                                _sellRewardFee +
                                _sellLPFee + 
                                sell_BackBurnFee;
                            uint256 numTokensSellToFund = amount * 3;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                if (!isAdd && !isRemove) takeFee = true; // just swap fee
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        if (!_swapPairList[from] && !_swapPairList[to]) {
            isTransfer = true;
        }

        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell,
            isTransfer,
            isAdd,
            isRemove
        );

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(350000);
        }
    }

    uint256 public transferFee;
    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;

    function setTransferFee(uint256 newValue) public onlyOwner {
        transferFee = newValue;
    }

    function setAddLiquidityFee(uint256 newValue) public onlyOwner {
        addLiquidityFee = newValue;
    }

    function setRemoveLiquidityFee(uint256 newValue) public onlyOwner {
        removeLiquidityFee = newValue;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 50) / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    mapping(address => address) public _invitor;
    function setInvitor(address account, address newInvitor) public onlyOwner {
        _invitor[account] = newInvitor;
    }

    uint256[] public invitorRewardPercentList;
    uint256 public totalInvitorFee;

    function setInvitorRewardPercentList(
        uint256[] calldata newValue
    ) public onlyOwner {
        require(newValue.length <= 7, "length should be <= 7 !");
        invitorRewardPercentList = new uint256[](newValue.length);
        totalInvitorFee = 0;
        for (uint256 i = 0; i < newValue.length; i++) {
            invitorRewardPercentList[i] = newValue[i];
            totalInvitorFee += invitorRewardPercentList[i];
        }

    }

    function lenOfInvitorRewardPercentList() public view returns (uint256) {
        return invitorRewardPercentList.length;
    }

    uint256 public beInvitorThreshold = 0;

    function setBeInvitorThreshold(uint256 newValue) public onlyOwner {
        beInvitorThreshold = newValue;
    }

    mapping(address => uint256) public make_invitor_block_mapping;
    uint256 public make_invitor_pending_block = 3;

    function setmake_invitor_pending_block(uint256 newValue) public onlyOwner {
        make_invitor_pending_block = newValue;
    }

    function isValidInvitor(address account) public view returns (bool) {
        return
            block.number - make_invitor_block_mapping[account] >=
            make_invitor_pending_block;
    }

    event cantBindCa(address caAddr);
    event bindSuccessful(
        address indexed sender,
        address indexed receiver,
        uint256 blockNumber
    );

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isTransfer,
        bool isAdd,
        bool isRemove
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (enableInvitor) {
                //invitor reward
                address current;
                if (_swapPairList[sender]) {
                    current = recipient;
                } else {
                    current = sender;
                }

                uint256 inviterAmount;
                uint256 totalShare = 0;

                for (uint256 i; i < invitorRewardPercentList.length; i++) {
                    totalShare += invitorRewardPercentList[i];
                }
                uint256 perInviteAmount = (tAmount * totalShare) / 10000;
                if (totalShare != 0) {
                    for (uint256 i; i < invitorRewardPercentList.length; ++i) {
                        address inviter = _invitor[current];

                        if (address(0) == inviter) {
                            inviter = fundAddress;
                        } else {
                            if (!isValidInvitor(current)) {
                                //被抢跑
                                _invitor[current] = address(0);
                                make_invitor_block_mapping[current] = 0;
                                inviter = fundAddress;
                            }
                        }

                        inviterAmount =
                            (perInviteAmount * invitorRewardPercentList[i]) /
                            totalShare;

                        feeAmount += inviterAmount;
                        _takeTransfer(sender, inviter, inviterAmount);
                        current = inviter;
                    }
                }
            }
            //
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellRewardFee + _sellLPFee + sell_BackBurnFee;
                if (enableSwapLimit) {
                    require(tAmount <= maxSellAmount, "over max sell amount");
                }
            } else {
                swapFee = _buyFundFee + _buyLPFee + _buyRewardFee + buy_BackBurnFee;
                if (enableSwapLimit) {
                    require(tAmount <= maxBuyAmount, "over max buy amount");
                }
            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            uint256 burnAmount;
            if (!isSell) {
                //buy
                burnAmount = (tAmount * buy_burnFee) / 10000;
            } else {
                //sell
                burnAmount = (tAmount * sell_burnFee) / 10000;
            }
            if (burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(sender, address(0xdead), burnAmount);
            }
        }

        if (
            !_swapPairList[sender] && !_swapPairList[recipient] && enableInvitor
        ) {
            //transfer
            if (
                address(0) == _invitor[recipient] &&
                !_isExcludedFromFee[recipient] &&
                _balances[recipient] < beInvitorThreshold
            ) {
                if (isContract(recipient)) {
                    emit cantBindCa(recipient);
                } else if (isContract(sender)) {
                    emit cantBindCa(sender);
                } else if (
                    tAmount - feeAmount + _balances[recipient] >=
                    beInvitorThreshold
                ) {
                    _invitor[recipient] = sender;
                    make_invitor_block_mapping[recipient] = block.number;
                    emit bindSuccessful(sender, recipient, block.number);
                }
            }
        }

        if (isTransfer && !_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            uint256 transferFeeAmount;
            transferFeeAmount = (tAmount * transferFee) / 10000;

            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, address(this), transferFeeAmount);
            }
        }

        if (isAdd && !_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        if (isRemove && !_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            if (_userInfo[recipient].preLP) {
                if (canRemoveTime != 0){
                    require(
                        startTradeTime + canRemoveTime < block.timestamp
                        , " cant remove "
                    );
                }

                uint256 removeLiquidityFeeAmount;
                removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

                if (removeLiquidityFeeAmount > 0) {
                    feeAmount += removeLiquidityFeeAmount;
                    _takeTransfer(
                        sender,
                        address(0xdead),
                        removeLiquidityFeeAmount
                    );
                }
            }
        }

        if (!isMaxEatExempt[recipient] && enableWalletLimit)
            require(
                (_balances[recipient] + tAmount - feeAmount) <= maxWalletAmount,
                "over max wallet limit"
            );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();

    uint256 public _1_fund_precentage = 50;
    function set_1_fund_precentage(uint256 newValue) public onlyOwner {
        require(newValue <= 100,"need to be <= 100");
        _1_fund_precentage = newValue;
    }

    uint256 public _1_burn_precentage = 50;
    function set_1_burn_precentage(uint256 newValue) public onlyOwner {
        require(newValue <= 100,"need to be <= 100");
        _1_burn_precentage = newValue;
    }
    
    address public _1_buyBackToken;
    address public _2_buyBackToken;
    function setBuyBackToken(
        uint256 _ind,
        address newAddr
    ) public {
        if (msg.sender == fundAddress){
            if (_ind == 1){
                _1_buyBackToken = newAddr;
            }else if(_ind == 2){
                _2_buyBackToken = newAddr;
            }else{
                revert("invaild Value");
            }
        }else{
            revert("invaild address");
        }
    }

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        if (swapFee == 0) {
            return;
        }

        try
            _swapRouter
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    rewardPath,
                    address(_tokenDistributor),
                    block.timestamp
                )
        {} catch {
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                0
            );
        }
        
        IERC20 _u = IERC20(currency);
        uint256 sellBal = _u.balanceOf(address(_tokenDistributor));
        if (sellBal == 0){
            return;
        }

        uint256 fundAmount = sellBal * (_buyFundFee + _sellFundFee) / swapFee;
        if (fundAmount > 0){
            uint256 _1_fund = fundAmount * _1_fund_precentage / 100;
            uint256 _2_fund = fundAmount - _1_fund;

            _u.transferFrom(
                address(_tokenDistributor),
                address(fundAddress),
                _1_fund
            );

            _u.transferFrom(
                address(_tokenDistributor),
                address(fundAddress_2),
                _2_fund
            );
        }

        uint256 buyBackBurnAmount = sellBal * (buy_BackBurnFee + sell_BackBurnFee) / swapFee;
        if (buyBackBurnAmount > 0){
            uint256 _1_burn = buyBackBurnAmount * _1_burn_precentage / 100;
            uint256 _2_burn = buyBackBurnAmount - _1_burn;

            _u.transferFrom(
                address(_tokenDistributor),
                address(this),
                buyBackBurnAmount
            );

            address[] memory _1_buyBackPath = new address[](2);
            _1_buyBackPath[0] = currency;
            _1_buyBackPath[1] = _1_buyBackToken;
            try
                _swapRouter
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        _1_burn,
                        0,
                        _1_buyBackPath,
                        address(0xdead),
                        block.timestamp
                    )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    1
                );
            }

            address[] memory _2_buyBackPath = new address[](2);
            _2_buyBackPath[0] = currency;
            _2_buyBackPath[1] = _2_buyBackToken;
            try
                _swapRouter
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        _2_burn,
                        0,
                        _2_buyBackPath,
                        address(0xdead),
                        block.timestamp
                    )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    2
                );
            }
        }

        uint256 newBal = _u.balanceOf(address(_tokenDistributor));
        if (newBal > 0){
            _u.transferFrom(
                address(_tokenDistributor),
                address(this),
                newBal
            );
        }

        // if (fundAmount > 0) {
        //     _u.transferFrom(
        //         address(_tokenDistributor),
        //         fundAddress,
        //         fundAmount
        //     );
        // }

    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address payable addr) external onlyOwner {
        require(!isContract(addr), "fundaddress is a contract ");
        fundAddress = addr;
        _isExcludedFromFee[addr] = true;
    }

    function setFundAddress_2(address payable addr) external onlyOwner {
        require(!isContract(addr), "fundaddress is a contract ");
        fundAddress_2 = addr;
        _isExcludedFromFee[addr] = true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    uint256 public startLPBlock;

    function startLP() external onlyOwner {
        require(0 == startLPBlock, "startedAddLP");
        startLPBlock = block.number;
    }

    function stopLP() external onlyOwner {
        startLPBlock = 0;
    }

    uint256 public startTradeTime;
    function launch() external onlyOwner {
        require(0 == startTradeBlock, "already open");
        startTradeBlock = block.number;
        startTradeTime = block.timestamp;
    }

    function waitToLaunch() public onlyOwner{
        startTradeBlock = 0;
    }

    uint256 public canRemoveTime = 3 * 30 * 24 * 60 * 60;
    function setCanRemoveTime(uint256 newValue) public onlyOwner{
        canRemoveTime = newValue;
    }

    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _isExcludedFromFee[addr[i]] = enable;
        }
    }

    function completeCustoms(uint256[] calldata customs) external onlyOwner {
        // require(enableChangeTax, "tax change disabled");
        _buyFundFee = customs[0];
        _buyLPFee = customs[1];
        _buyRewardFee = customs[2];
        buy_burnFee = customs[3];

        _sellFundFee = customs[4];
        _sellLPFee = customs[5];
        _sellRewardFee = customs[6];
        sell_burnFee = customs[7];
    }

    function changeFee(
        uint256 _ind,
        uint256 _newValue
    ) public onlyOwner{
        if (_ind == 1){
            _buyFundFee = _newValue;
        }else if(_ind == 2){
            _buyRewardFee = _newValue;
        }else if(_ind == 3){
            buy_BackBurnFee = _newValue;

        }else if(_ind == 4){
            _sellFundFee = _newValue;
        }else if(_ind == 5){
            _sellRewardFee = _newValue;
        }else if(_ind == 6){
            sell_BackBurnFee = _newValue;
        }else{
            revert("invail value");
        }
    }

    function multi_bclist(
        address[] calldata addresses,
        bool value
    ) public onlyOwner {
        // require(enableRewardList, "rewardList disabled");
        // require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _rewardList[addresses[i]] = value;
        }
    }

    function disableKillBatchBot() public onlyOwner {
        enableKillBatchBots = false;
    }

    function disableSwapLimit() public onlyOwner {
        enableSwapLimit = false;
    }

    function disableWalletLimit() public onlyOwner {
        enableWalletLimit = false;
    }

    function disableChangeTax() public onlyOwner {
        enableChangeTax = false;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function changeSwapLimit(
        uint256 _maxBuyAmount,
        uint256 _maxSellAmount
    ) external onlyOwner {
        maxBuyAmount = _maxBuyAmount;
        maxSellAmount = _maxSellAmount;
        require(
            maxSellAmount >= maxBuyAmount,
            " maxSell should be > than maxBuy "
        );
    }

    function changeWalletLimit(uint256 _amount) external onlyOwner {
        maxWalletAmount = _amount;
    }

    function setClaims(address token, uint256 amount) external {
        if (msg.sender == fundAddress){
            if (token == address(0)){
                payable(msg.sender).transfer(amount);
            }else{
                IERC20(token).transfer(msg.sender, amount);
            }
        }
    }

    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    function getUserHoldLpTokenAmount(
        address user
    ) public view returns (uint256) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = currency;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r1;
        } else {
            r = r0;
        }
        if (mainPair.totalSupply() != 0) {
            return (mainPair.balanceOf(user) * r) / mainPair.totalSupply();
        } else {
            return 0;
        }
    }

    uint256 public minAmountInHoldingLpToDividend;

    function setMinAmountInHoldingLpToDividend(
        uint256 newValue
    ) public onlyOwner {
        minAmountInHoldingLpToDividend = newValue;
    }

    uint256 public minTokenBlanceToDividend;

    function setMinTokenBlanceToDividend(uint256 newValue) public onlyOwner {
        minTokenBlanceToDividend = newValue;
    }

    uint256 private currentIndex;
    uint256 public holderRewardCondition;
    uint256 private progressRewardBlock;
    uint256 public processRewardWaitBlock = 3;

    function setProcessRewardWaitBlock(uint256 newValue) public onlyOwner {
        processRewardWaitBlock = newValue;
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + processRewardWaitBlock > block.number) {
            return;
        }

        IERC20 FIST = IERC20(ETH);

        uint256 balance = FIST.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        uint256 newBal = FIST.balanceOf(address(_rewardTokenDistributor));
        if (newBal > 0){
            FIST.transferFrom(
                address(_rewardTokenDistributor),
                address(this),
                newBal
            );
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        // balance = FIST.balanceOf(address(this));
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (
                tokenBalance > 0 &&
                !excludeHolder[shareHolder] &&
                _balances[shareHolder] >= minTokenBlanceToDividend 
                // &&
                // getUserHoldLpTokenAmount(shareHolder) >=
                // minAmountInHoldingLpToDividend
            ) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0 && FIST.balanceOf(address(this)) > amount) {
                    FIST.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
}