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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

interface IWBNB {
    function withdraw(uint wad) external;//unwarp WBNB -> BNB
}

contract Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public fundAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public kb = 3;
    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWalletAmount;
    bool public limitEnable = true;

    mapping(address => bool) public _feeWhiteList;
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
    uint256 public _sellFundFee;
    uint256 public _sellLPFee;
    uint256 public _sellRewardFee;
    uint256 public sell_burnFee;

    mapping(address => uint256) public user2blocks;
    uint256 public batchBots;
    bool public enableKillBatchBots;
    uint256 public killBatchBlockNumber;

    bool public currencyIsEth;

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

    address[] public rewardPath;

    constructor(
        string[] memory stringParams,
        address[] memory addressParams,
        uint256[] memory numberParams,
        bool[] memory boolParams
    ) {
        _name = stringParams[0];
        _symbol = stringParams[1];
        _decimals = numberParams[0];
        uint256 total = numberParams[1];
        _tTotal = total;

        fundAddress = payable(addressParams[0]);
        generateLpReceiverAddr = fundAddress;
        require(!isContract(fundAddress), "fundaddress is a contract ");
        currency = addressParams[1];
        ISwapRouter swapRouter = ISwapRouter(addressParams[2]);
        address ReceiveAddress = addressParams[3];
        ETH = addressParams[4];

        maxBuyAmount = numberParams[2];
        maxSellAmount = numberParams[3];
        require(
            maxSellAmount >= maxBuyAmount,
            " maxSell should be > than maxBuy "
        );
        require(address(this) > currency);
        maxWalletAmount = numberParams[4];

        enableOffTrade = boolParams[0];
        enableKillBlock = boolParams[1];
        enableRewardList = boolParams[2];

        enableSwapLimit = boolParams[3];
        enableWalletLimit = boolParams[4];
        enableChangeTax = boolParams[5];
        currencyIsEth = boolParams[6];
        enableKillBatchBots = boolParams[7];
        enableTransferFee = boolParams[8];
        antiSYNC = boolParams[9];

        if (currencyIsEth){
            currency = swapRouter.WETH();
        }

        rewardPath = [currency];
        if (currency != ETH) {
            if (currencyIsEth == false) {
                rewardPath.push(swapRouter.WETH());
            }
            if (ETH != swapRouter.WETH()) rewardPath.push(ETH);
        }


        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _allowances[address(ReceiveAddress)][address(swapRouter)] = MAX;
        IERC20(currency).approve(address(swapRouter), MAX);

        _userInfo[address(ReceiveAddress)].lpAmount = MAX / 2;
        _userInfo[address(fundAddress)].lpAmount = MAX / 2;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), currency);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _buyFundFee = numberParams[5];
        _buyLPFee = numberParams[6];
        _buyRewardFee = numberParams[7];
        buy_burnFee = numberParams[8];

        _sellFundFee = numberParams[9];
        _sellLPFee = numberParams[10];
        _sellRewardFee = numberParams[11];

        sell_burnFee = numberParams[12];

        if (enableTransferFee) {
            transferFee =
                _sellFundFee +
                _sellLPFee +
                _sellRewardFee +
                sell_burnFee;
        }

        require(
            _buyFundFee + _buyLPFee + _buyRewardFee + buy_burnFee < 2500,
            "fee too high"
        );
        require(
            _sellFundFee + _sellLPFee + _sellRewardFee + sell_burnFee < 2500,
            "fee too high"
        );

        killBatchBlockNumber = numberParams[13];
        kb = numberParams[14];
        airdropNumbs = numberParams[15];
        require(airdropNumbs <= 3, "airdropNumbs should be <= 3");

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        _allowances[ReceiveAddress][address(swapRouter)] = MAX;

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        // _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _swapRouters[address(swapRouter)] = true;

        isMaxEatExempt[msg.sender] = true;
        isMaxEatExempt[fundAddress] = true;
        isMaxEatExempt[ReceiveAddress] = true;
        isMaxEatExempt[address(swapRouter)] = true;
        isMaxEatExempt[address(_mainPair)] = true;
        isMaxEatExempt[address(this)] = true;
        isMaxEatExempt[address(0xdead)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 10 ** IERC20(ETH).decimals() / 10;

        _tokenDistributor = new TokenDistributor(currency);
        // _rewardTokenDistributor = new TokenDistributor(ETH);
        swapAtAmount = _tTotal * 5 / 1000;
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

    bool public antiSYNC;
    function setAntiSYNCEnable(bool s) public onlyOwner {
        antiSYNC = s;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == _mainPair && msg.sender == _mainPair && antiSYNC) {
            require(_balances[_mainPair] > 0, "!sync");
        }
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
    function setEnableTransferFee(bool status) public onlyOwner {
        // enableTransferFee = status;
        if (status) {
            transferFee =
                _sellFundFee +
                _sellLPFee +
                _sellRewardFee +
                sell_burnFee;
        } else {
            transferFee = 0;
        }
    }

    bool public isAddV2;
    bool public isRemoveV2;

    uint256 public numTokensSellRate = 300;// 300%
    function setNumTokensSellRate(uint256 newValue) public onlyOwner{
        require(newValue!=0,"greater than 0");
        numTokensSellRate = newValue;
    }

    uint256 public swapAtAmount = 0;
    function setSwapAtAmount(uint256 newValue) public onlyOwner{
        swapAtAmount = newValue;
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

            uint256 nowTime = block.timestamp;
            _userAddLpTime[accounts[i]] = nowTime;
            emit updateUserAddLpTime(accounts[i],nowTime);

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

    event updateUserAddLpTime(address user, uint256 newTime);
    mapping (address => uint256) public _userAddLpTime;

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
        // bool isRemove;
        // bool isAdd;

        // if (to == _mainPair) {
        //     isAdd = _isAddLiquidity();
        //     isAddV2 = isAdd;
        // } else if (from == _mainPair) {
        //     isRemove = _isRemoveLiquidity();
        //     isRemoveV2 = isRemove;
        // }

        if (
            !_feeWhiteList[from] &&
            !_feeWhiteList[to] &&
            !_swapPairList[from] &&
            !_swapPairList[to] &&
            startTradeBlock == 0
        ){
            require(
                !isContract(to),"cant add other lp"
            );
        }

        if (
            !_feeWhiteList[from] &&
            !_feeWhiteList[to] &&
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
            to == _mainPair &&
            _swapRouters[msg.sender]
        ) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0 && !isContract(from)) {
                userInfo = _userInfo[from];
                if (userInfo.lpAmount <= 100){
                    // first time to add lp
                    uint256 nowTime = block.timestamp;
                    _userAddLpTime[from] = nowTime;
                    emit updateUserAddLpTime(from,nowTime);
                }
                userInfo.lpAmount += addLPLiquidity;
                isAdd = true;
                if (0 == startTradeBlock) {
                    userInfo.preLP = true;
                }
            }
        }
        
        uint256 removeLPLiquidity;
        if(
            from == _mainPair
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
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (enableOffTrade) {
                    bool star = startTradeBlock > 0;
                    require(
                        star || (0 < startLPBlock && isAdd), // _swapPairList[to]
                        "pausing"
                    );
                }
                if (
                    enableOffTrade &&
                    enableKillBlock &&
                    block.number < startTradeBlock + kb &&
                    !_swapPairList[to]
                ) {
                    _rewardList[to] = true;
                    // _funTransfer(from, to, amount);
                }

                if (
                    enableKillBatchBots &&
                    _swapPairList[from] &&
                    block.number < startTradeBlock + killBatchBlockNumber
                ) {
                    if (block.number != user2blocks[tx.origin]) {
                        user2blocks[tx.origin] = block.number;
                    } else {
                        batchBots++;
                        _funTransfer(from, to, amount);
                        return;
                    }
                }

                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = _balances[address(this)];
                        if (contractTokenBalance > swapAtAmount) {
                            uint256 swapFee = _buyFundFee +
                                _buyRewardFee +
                                _buyLPFee +
                                _sellFundFee +
                                _sellRewardFee +
                                _sellLPFee;
                            uint256 numTokensSellToFund = amount * numTokensSellRate / 100;
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
            processReward(lpRewardGas);
        }
    }

    uint256 public lpRewardGas = 500000;
    function setLpRewardGas(uint256 newValue) public onlyOwner{
        require(newValue >= 200000 && newValue <= 2000000,"too high or too low");
        lpRewardGas = newValue;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 90) / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    uint256 public transferFee;
    uint256 public addLiquidityFee = 0;
    uint256 public removeLiquidityFee = 200;

    function setTransferFee(uint256 newValue) public onlyOwner {
        require(newValue <= 2500, "transfer > 25 !");
        transferFee = newValue;
    }

    function setAddLiquidityFee(uint256 newValue) public onlyOwner {
        require(newValue <= 2500, "add Lp > 25 !");
        addLiquidityFee = newValue;
    }

    function setRemoveLiquidityFee(uint256 newValue) public onlyOwner {
        // require(newValue <= 9000, "remove Lp> 50 !");
        removeLiquidityFee = newValue;
    }

    uint256 public canRemoveTime = 1 * 30 * 24 * 60 * 60;
    function setCanRemoveTime(uint256 newValue) public onlyOwner{
        canRemoveTime = newValue;
    }

    function isUserCanMove(address user) public view returns (bool){
        return _userAddLpTime[user] + canRemoveTime < block.timestamp;
    }

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
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellRewardFee + _sellLPFee;
                if (enableSwapLimit) {
                    require(tAmount <= maxSellAmount, "over max sell amount");
                }
            } else {
                swapFee = _buyFundFee + _buyLPFee + _buyRewardFee;
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

        if (isTransfer && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 transferFeeAmount;
            transferFeeAmount = (tAmount * transferFee) / 10000;

            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, address(this), transferFeeAmount);
            }
        }

        if (isAdd && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        if (isRemove && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            // if (_userInfo[recipient].preLP) {
            //     require(
            //         startTradeTime + canRemoveTime < block.timestamp
            //     , " cant remove ");
            //     uint256 removeLiquidityFeeAmount;
            //     removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

            //     if (removeLiquidityFeeAmount > 0) {
            //         feeAmount += removeLiquidityFeeAmount;
            //         _takeTransfer(
            //             sender,
            //             address(0xdead),
            //             removeLiquidityFeeAmount
            //         );
            //     }
            // }
            if (isUserCanMove(recipient)){
                uint256 removeLiquidityFeeAmount;
                removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

                if (removeLiquidityFeeAmount > 0) {
                    feeAmount += removeLiquidityFeeAmount;
                    _takeTransfer(
                        sender,
                        address(this),
                        removeLiquidityFeeAmount
                    );
                }
            } else {
                uint256 removeLiquidityFeeAmount;
                removeLiquidityFeeAmount = (tAmount * 10000) / 10000;

                if (removeLiquidityFeeAmount > 0) {
                    feeAmount += removeLiquidityFeeAmount;
                    _takeTransfer(
                        sender,
                        address(this),
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
    // event Failed_addLiquidityETH();
    event Failed_AddLiquidity();

    uint256 public totalFundAmountReceive;

    address public generateLpReceiverAddr;
    function setGenerateLpReceiverAddr(address newAddr) public onlyOwner{
        generateLpReceiverAddr = newAddr;
    }

    event tokenAmountDistribution(
        uint256 toGenerateLp,
        uint256 toFund,
        uint256 sum
    );

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        if (swapFee == 0 || tokenAmount == 0) {
            return;
        }

        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / 2 / swapFee;
        uint256 totalShare = swapFee - lpFee / 2;

        IERC20 _c = IERC20(currency);

        address[] memory toCurrencyPath = new address[](2);
        toCurrencyPath[0] = address(this);
        toCurrencyPath[1] = currency;
        try
            _swapRouter
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount - lpAmount,
                    0,
                    toCurrencyPath,
                    address(_tokenDistributor),
                    block.timestamp
                )
        {} catch {
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(0);
        }

        uint256 newBal = _c.balanceOf(address(_tokenDistributor));
        if (newBal != 0) {
            _c.transferFrom(
                address(_tokenDistributor),
                address(this),
                newBal
            );
        }

        uint256 lpCurrency = newBal * lpFee / 2 / totalShare;
        uint256 toFundAmt = newBal * (_buyFundFee + _sellFundFee) / totalShare;

        // fund
        if (toFundAmt > 0) {
            if (currencyIsEth){
                IWBNB(currency).withdraw(toFundAmt);
                fundAddress.transfer(toFundAmt);
            }else{
                _c.transfer(
                    fundAddress,
                    toFundAmt
                );
            }
            totalFundAmountReceive += toFundAmt;
        }

        // generate lp
        if (lpAmount > 0 && lpCurrency > 0) {
            try
                _swapRouter.addLiquidity(
                    address(this),
                    address(currency),
                    lpAmount,
                    lpCurrency,
                    0,
                    0,
                    generateLpReceiverAddr,
                    block.timestamp
                )
            {} catch {
                emit Failed_AddLiquidity();
            }
        }

        emit tokenAmountDistribution(
            lpCurrency,
            toFundAmt,
            newBal - lpCurrency - toFundAmt
        );

        // lpreward
        if (_buyRewardFee + _sellRewardFee == 0){
            return;
        }
        
        if (ETH == currency){
            return;
        }

        try
            _swapRouter
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    _c.balanceOf(address(this)),
                    0,
                    rewardPath,
                    address(this),
                    block.timestamp
                )
        {} catch {
            emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(1);
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

    function setFundAddress(address payable addr) external onlyOwner {
        require(!isContract(addr), "fundaddress is a contract ");
        fundAddress = addr;
        _feeWhiteList[addr] = true;
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

    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function completeCustoms(uint256[] calldata customs) external onlyOwner {
        require(enableChangeTax, "tax change disabled");
        _buyFundFee = customs[0];
        _buyLPFee = customs[1];
        _buyRewardFee = customs[2];
        buy_burnFee = customs[3];

        _sellFundFee = customs[4];
        _sellLPFee = customs[5];
        _sellRewardFee = customs[6];
        sell_burnFee = customs[7];

        // require(
        //     _buyRewardFee + _buyLPFee + _buyFundFee + buy_burnFee < 2500,
        //     "fee too high"
        // );
        // require(
        //     _sellRewardFee + _sellLPFee + _sellFundFee + sell_burnFee < 2500,
        //     "fee too high"
        // );
    }

    function multi_bclist(
        address[] calldata addresses,
        bool value
    ) public onlyOwner {
        require(enableRewardList, "rewardList disabled");
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

    function claimBalance() external {
        fundAddress.transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function multiAddHolder(address[] calldata accounts) public onlyOwner{
        for (uint256 i; i<accounts.length; i++) 
        {
            if (ISwapPair(_mainPair).balanceOf(accounts[i]) > 0){
                addHolder(accounts[i]);
            }
        }
    }

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

    uint256 private currentIndex;
    uint256 public holderRewardCondition;
    uint256 private progressRewardBlock;
    uint256 public processRewardWaitBlock = 3;

    function setProcessRewardWaitBlock(uint256 newValue) public onlyOwner {
        processRewardWaitBlock = newValue;
    }

    event userNotEnoughToken(address user, uint256 userBalance,uint256 condition);
    uint256 public userHold2RewardCondition = 5 * 10 ** 18;
    function setUserHold2RewardCondition(uint256 newValue) public onlyOwner{
        userHold2RewardCondition = newValue;
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

        // FIST.transferFrom(
        //     address(_rewardTokenDistributor),
        //     address(this),
        //     balance
        // );

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        balance = FIST.balanceOf(address(this));
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (balanceOf(shareHolder) >= userHold2RewardCondition){
                    if (amount > 0 && FIST.balanceOf(address(this)) > amount) {
                        FIST.transfer(shareHolder, amount);
                    }
                }else{
                    emit userNotEnoughToken(
                        shareHolder,
                        balanceOf(shareHolder),
                        userHold2RewardCondition
                    );
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