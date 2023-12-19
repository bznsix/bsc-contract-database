// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

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
        _owner = address(0x9A5968F5aFdF74937E9D0546ea587868F0336e0c);
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor() {
        _owner = msg.sender;
    }
    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner);
        IERC20(token).transfer(to, amount);
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
}

contract KCAL is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0xA014cE43aDF8cfaDbbA18Da4c5f8454107428Cf2);

    string private _name = "KCAL";
    string private _symbol = "KCAL";
    uint256 private _decimals = 18;


    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal = 100_000_000 *10**_decimals;
    uint256 public mineRate = 60;
    address public routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    ISwapRouter public _swapRouter;
    address public BETH = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);

    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);
    mapping(address => bool) public _swapPairList;


    uint256 private constant MAX = ~uint256(0);

    TokenDistributor public mineRewardDistributor;
    
    uint256 public _buyFundFee = 100;
    uint256 public sell_burnFee = 200;
    uint256 public addLiquidityFee = 250;
    uint256 public removeLiquidityFee = 250;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => mapping(address => bool)) public _maybeInvitor;


    uint256 public startTradeTime;

    mapping(address => uint256) public _userLPAmount;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    mapping(address => uint256) public mineReward;
    mapping(address => uint256) public invitorReward;



    uint256 public oneLPNum = 20*10**_decimals;
    uint256 public twoLPNum = 40*10**_decimals;
    uint256 public threeLPNum = 100*10**_decimals;
    uint256 public fourLPNum = 200*10**_decimals;
    uint256 public fiveLPNum = 600*10**_decimals;


    uint256 public oneInvitorReward = 500 *10**_decimals;
    uint256 public twoInvitorReward = 1000 *10**_decimals;
    uint256 public threeInvitorReward = 2000 *10**_decimals;
    uint256 public fourInvitorReward = 4000 *10**_decimals;

    uint256 public _currentMineLPIndex;
    uint256 public _progressMineLPBlock;
    uint256 public _progressMineLPBlockDebt = 5;
    mapping(address => uint256) public _lastMineLPRewardTimes;

    uint256 public _mineTimeDebt = 7 days;
    bool public isMining = true;

    uint256 public lastCycleTimestamp;
    uint256 public cycleTimeDebt = 90 days;
    uint256 public cycleAmount;
    uint256 public cycleMineAmount;
    uint256 public cycleInvitorAmount;

    uint256 public lastEachTimestamp;
    uint256 public eachMineAmount;
    uint256 public eachInvitorAmount;
    uint256 public eachInvitorMin = 10**_decimals;
    uint256 public MinerMin = 10**_decimals;

    address public _mainPair;
    address[] public rewardPath;
    bool private inSwap;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {

        rewardPath = [address(this), BETH];
        _swapRouter = ISwapRouter(routerAddress);
        IERC20(BETH).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), BETH);

        _swapPairList[_mainPair] = true;

        mineRewardDistributor = new TokenDistributor();


        uint256 _mineTotal = _tTotal * mineRate / 100;
        _balances[address(mineRewardDistributor)] = _mineTotal;
        emit Transfer(address(0), address(mineRewardDistributor), _mineTotal);

        uint256 ReceiveAddress1Amount = 5_190_000 *10**_decimals;
        address ReceiveAddress1 = address(0xde58d48Ebc6b388dF87F4cAeFf85561e91D0888e);
        _balances[ReceiveAddress1] = ReceiveAddress1Amount;
        emit Transfer(address(0), ReceiveAddress1, ReceiveAddress1Amount);
        uint256 liquidityTotal = _tTotal - _mineTotal - ReceiveAddress1Amount;
        address ReceiveAddress2 = address(0x503F5ED458925c13676051F5aC0e3975FcA780A3);
        _balances[ReceiveAddress2] = liquidityTotal;
        emit Transfer(address(0), ReceiveAddress2, liquidityTotal);

        _feeWhiteList[ReceiveAddress1] = true;
        _feeWhiteList[ReceiveAddress2] = true;
        _feeWhiteList[address(this)] = true;
        // _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(mineRewardDistributor)] = true;        

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        _addLpProvider(fundAddress);

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
    ) public override returns (bool)  {
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

     function _isAddLiquidity() internal view returns (bool isAdd) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = BETH;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = BETH;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(balanceOf(from) >= amount);
        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(_mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(_mainPair).totalSupply() / _balances[_mainPair];
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                        if (_lastMineLPRewardTimes[lastMaybeAddLPAddress] == 0) {
                            _lastMineLPRewardTimes[lastMaybeAddLPAddress] = block.timestamp;
                        }
                    }
                }
            }
        }

        bool takeFee;
        bool isSell;
        bool isRemove;
        bool isAdd;


        if (_swapPairList[from] || _swapPairList[to]) {
            if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();
            isSell = true;

            }
            if (_swapPairList[from]) {
                isRemove = _isRemoveLiquidity();

            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(block.timestamp > startTradeTime || isAdd);
                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 numTokensSellToFund = (amount * _buyFundFee) /
                                5000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund);
                        }
                    }
                }


                if (!isAdd && !isRemove) takeFee = true; // just swap fee
            }
        }else {
            if (_inviter[to] == address(0) && amount > 0 && from != to) {
                _maybeInvitor[to][from] = true;
            }
            if (_inviter[from] == address(0) && amount > 0 && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
        }

        if (isRemove) {
            if (!_feeWhiteList[to] && isMining) {
                // takeFee = true;
                uint256 liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) / (balanceOf(_mainPair) - 1);
                // if (from != address(_swapRouter)) {
                //     liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) / (balanceOf(_mainPair) - amount - 1);
                // } 
                require(_userLPAmount[to] >= liquidity);
                _userLPAmount[to] -= liquidity;
            }
        }


        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell,
            isRemove,
            isAdd
        );

        if (from != address(this) && isMining) {
            if (isSell) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }
            if (!_feeWhiteList[from] && !isAdd ) {
                updateMineCycle();
                processMineLP(500000);
            }
            
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isRemove,
        bool isAdd
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            if (isSell) {
                uint256 sellBurnAmount = tAmount * sell_burnFee /10000;
                feeAmount += sellBurnAmount;
                _takeTransfer(sender, deadAddress, sellBurnAmount);

            } else {
                uint256 buyFundAmount = tAmount * _buyFundFee/10000; 
                feeAmount += buyFundAmount;
                _takeTransfer(sender, address(this), buyFundAmount);

            }

        }


        if (isRemove && !_feeWhiteList[recipient]) {
            uint256 removeLiquidityFeeAmount;
            removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

            
            feeAmount += removeLiquidityFeeAmount;
            _takeTransfer(sender, address(fundAddress), removeLiquidityFeeAmount);
            
        }
        if (isAdd && !_feeWhiteList[sender]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            feeAmount += addLiquidityFeeAmount;
            _takeTransfer(sender, address(fundAddress), addLiquidityFeeAmount);

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

    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );
    
    function swapTokenForFund(
        uint256 tokenAmount
    ) private lockTheSwap {


        try
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    rewardPath,
                    fundAddress,
                    block.timestamp
                )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(1);
            }
        
    }

    function _bindInvitor(address account, address invitor) private  returns(bool) {
        if (invitor != address(0) && invitor != account && _inviter[account] == address(0)) {
            uint256 size;
            assembly {size := extcodesize(invitor)}
            if (size > 0) {
                return false ;
            }else{
                _inviter[account] = invitor;
                _binders[invitor].push(account);
                
                return true;
            }
        }
        else{
            return false;
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }

    function setLaunchTime(uint256 launchTime) external onlyOwner {
        require(0 == startTradeTime);
        startTradeTime = launchTime;
    }


    
    event Received(address sender, uint256 amount);
    event Sended(address sender, address to,uint256 amount);
    receive() external payable {
        uint256 receivedAmount = msg.value;
        emit Received(msg.sender, receivedAmount);
    }



    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
        _addLpProvider(addr);
    }


    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }





    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external  {
        require(fundAddress == msg.sender);
        IERC20(token).transfer(to, amount);
    }

    function claimContractToken(address contractAddress, address token, uint256 amount) external {
        require(fundAddress == msg.sender);
        TokenDistributor(contractAddress).claimToken(token, fundAddress, amount);
    }


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
    function checkLowerCount(address account) view private returns(uint256 lowerHoldCount,uint256 lowerLPCount ){
        uint256 lowerCount =  _binders[account].length;
        for (uint256 i; i < lowerCount; ++i) {
            address lowAddress = _binders[account][i];
            uint256 pairBalance = IERC20(_mainPair).balanceOf(lowAddress);
            if(_balances[lowAddress] >= 100*10**_decimals){
                lowerHoldCount +=1;
                if(pairBalance >= 10**15){
                    lowerLPCount +=1;
                }

            }
        }
        
    }

    function checkMineLv(address account) public view returns(uint8){
        uint256 accLPBalance = IERC20(_mainPair).balanceOf(account);
        (uint256 lowerHoldCount,uint256 lowerLPCount) = checkLowerCount(account);
        if(accLPBalance >= fiveLPNum && lowerHoldCount>=6 && lowerLPCount>= 5){
            return 5;

        }
        else if(accLPBalance >= fourLPNum && lowerHoldCount>=5 && lowerLPCount>= 4){
            return 4;

        }
        else if(accLPBalance >= threeLPNum && lowerHoldCount>=4 && lowerLPCount>= 3){
            return 3;

        }
        else if(accLPBalance >= twoLPNum && lowerHoldCount>=3 && lowerLPCount>= 2){
            return 2;

        }
        else if(accLPBalance >= oneLPNum && lowerHoldCount>=2 && lowerLPCount>= 1){
            return 1;

        }else{
            return 0;
        }

    }






    function processMineLP(uint256 gas) private {

        if (_progressMineLPBlock + _progressMineLPBlockDebt > block.number) {
            return;
        }


        uint totalPair = IERC20(_mainPair).totalSupply();
        if (0 == totalPair) {
            return;
        }
        address sender = address(mineRewardDistributor);

        if (_balances[sender] < MinerMin) { 
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 amount;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();


        while (gasUsed < gas && iterations < lpProviders.length) {
            if (_currentMineLPIndex >= lpProviders.length) {
                _currentMineLPIndex = 0;
            }
            shareHolder = lpProviders[_currentMineLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = IERC20(_mainPair).balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                }

                if (block.timestamp > _lastMineLPRewardTimes[shareHolder] + _mineTimeDebt) {
                    amount = eachMineAmount * pairBalance / totalPair;
                    
                    if (amount > 0) {
                        mineReward[shareHolder] += amount;
                        procesInvitorReward(shareHolder,amount);
                        _lastMineLPRewardTimes[shareHolder] = block.timestamp;
                    }
                    

                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _currentMineLPIndex++;
            iterations++;
        }
        
        _progressMineLPBlock = block.number;
        
    }

    function updateMineCycle() private {

        if(block.timestamp > lastCycleTimestamp + cycleTimeDebt ){
            cycleAmount = _balances[address(mineRewardDistributor)] / 10;
            cycleMineAmount = cycleAmount * 6 /10;
            cycleInvitorAmount = cycleAmount - cycleMineAmount;
            lastCycleTimestamp = block.timestamp;
        }

        if(block.timestamp > lastEachTimestamp + _mineTimeDebt ){
            eachMineAmount = cycleMineAmount /13;
            eachInvitorAmount = cycleInvitorAmount/13;
            lastEachTimestamp = block.timestamp;
        }
    }

    function manuallyUpdateCycle() external {
        require(fundAddress == msg.sender);
        cycleAmount = _balances[address(mineRewardDistributor)]  / 10;
        cycleMineAmount = cycleAmount * 6 /10;
        cycleInvitorAmount = cycleAmount - cycleMineAmount;
        lastCycleTimestamp = block.timestamp;
    }
    function manuallyUpdateEach() external {
        require(fundAddress == msg.sender);
        eachMineAmount = cycleMineAmount /13;
        eachInvitorAmount = cycleInvitorAmount/13;
        lastEachTimestamp = block.timestamp;
    }
    function setEachInvitorAmount(uint256 eachAmount) external  {
        require(fundAddress == msg.sender);
        eachInvitorAmount = eachAmount;
    }
    function setMining(bool enable) external  {
        require(fundAddress == msg.sender);
        isMining = enable;
    }
    function procesInvitorReward(address current, uint256 reward) private {

        for (uint256 i; i < 5;i++) {
            address invitor = _inviter[current];
            uint256 invitorAmount;
            uint8 invitorLv = checkMineLv(invitor);
            if (address(0) == invitor || deadAddress == invitor || eachInvitorAmount < eachInvitorMin) {
                break;
            }

            if (i ==0){
                if (invitorLv > 0){
                    invitorAmount = reward * 20 / 100;
                    
                }else{
                    invitorAmount = 0;
                }
            }else if(i ==1){
                if (invitorLv > 1){
                    invitorAmount = reward * 10 / 100;
                }else{
                    invitorAmount = 0;
                }        
            }else if(i ==2){
                if (invitorLv > 2){
                    invitorAmount = reward * 5 / 100;
                }else{
                    invitorAmount = 0;
                }

            
            }else if(i ==3){
                if (invitorLv > 3){
                    invitorAmount = reward * 2 / 100;
                }else{
                    invitorAmount = 0;
                }

            }else {
                if (invitorLv > 4){
                    invitorAmount = reward * 1 / 100;
                }else{
                    invitorAmount = 0;
                }
            }


            if(invitorAmount >0){

                if(eachInvitorAmount - invitorAmount>0){
                    invitorReward[invitor] += invitorAmount;
                    eachInvitorAmount -= invitorAmount;
                    procesUpInvitorReward(invitor,invitorAmount);

                    
                }else{
                    break;
                }


            }

            current = invitor;

        }

    }
    function procesUpInvitorReward(address current, uint256 reward) private {
        address invitor;
        uint256 invitorAmount;

        for (uint256 i; i < 5;i++) {
            invitor = _inviter[current];
            uint8 invitorLv = checkMineLv(invitor);
            
            if (address(0) == invitor || deadAddress == invitor || eachInvitorAmount < eachInvitorMin ||invitorLv ==0) {
                break;
            }
            
            if(invitorLv == 1){
                invitorAmount = reward * 5 / 100;

            }
            else if(invitorLv == 2){
                invitorAmount = reward * 10 / 100;

            }
            else if(invitorLv == 3){
                invitorAmount = reward * 15 / 100;

            }
            else if(invitorLv == 4){
                invitorAmount = reward * 20 / 100;

            }else{
                invitorAmount = reward * 30 / 100;
            }
            
            if(eachInvitorAmount - invitorAmount > 0){
                invitorReward[invitor] += invitorAmount;
                eachInvitorAmount -= invitorAmount;
                reward = invitorAmount;
                current = invitor;

            }else{
                break;
            }

        }

    }

    function getMineReward()external{
        uint256 totalMineReward = mineReward[msg.sender];
        require(totalMineReward > 0);
        address sender = address(mineRewardDistributor);
        uint256 techAmount = totalMineReward * 3/100;
        mineReward[msg.sender] = 0;
        TokenDistributor(sender).claimToken(address(this), fundAddress, techAmount);
        TokenDistributor(sender).claimToken(address(this), msg.sender, totalMineReward - techAmount);
        
    }
    function getInvitorReward()external{
        uint256 totalInvitorReward = invitorReward[msg.sender];
        uint256 availableInvitorReward;
        require(totalInvitorReward > 0);
        address sender = address(mineRewardDistributor);
        uint8 accountrLv = checkMineLv(msg.sender);
        if(accountrLv == 0){
            availableInvitorReward = 0;
            invitorReward[msg.sender] = 0;
        }
        else if(accountrLv == 1){
            if(totalInvitorReward > oneInvitorReward){
                availableInvitorReward = oneInvitorReward;
            }else{
                availableInvitorReward = totalInvitorReward;
            }

        }
        else if(accountrLv == 2){
            if(totalInvitorReward > twoInvitorReward){
                availableInvitorReward = twoInvitorReward;
            }else{
                availableInvitorReward = totalInvitorReward;
            }

        }
        else if(accountrLv == 3){
            if(totalInvitorReward > threeInvitorReward){
                availableInvitorReward = threeInvitorReward;
            }else{
                availableInvitorReward = totalInvitorReward;
            }
        }else if(accountrLv == 4){
            if(totalInvitorReward > fourInvitorReward){
                availableInvitorReward = fourInvitorReward;
            }else{
                availableInvitorReward = totalInvitorReward;
            }

        }else{
            availableInvitorReward = totalInvitorReward;
            
        }

        if(availableInvitorReward >0){
            uint256 techAmount = availableInvitorReward * 10 / 100;
            invitorReward[msg.sender] = 0;
            TokenDistributor(sender).claimToken(address(this), deadAddress, techAmount);
            TokenDistributor(sender).claimToken(address(this), msg.sender, availableInvitorReward - techAmount);
        }



    }

    function setExcludeLPProvider(address addr, bool enable) external  {
        require(fundAddress == msg.sender);
        excludeLpProvider[addr] = enable;
    }

}