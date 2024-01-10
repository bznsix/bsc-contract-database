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
}

contract AIX is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;


    mapping(address => bool) public _feeWhiteList;


    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _rewardTokenDistributor;
    TokenDistributor public _preTokenDistributor;

    uint256 public removeFee = 3000;
    

    uint256 public _buyFundFee;
    uint256 public _buyRewardFee;
    uint256 public _buyPreFee;

    uint256 public _sellFundFee;
    uint256 public _sellRewardFee;
    uint256 public _sellPreFee;

    address public _mainPair;
    uint256 public startTradeBlock;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    address[] public rewardPath;

    constructor(

    ) {
        _name = "lnsighsAi-X";
        _symbol = "AIX";
        _decimals = 18;
        _tTotal = 2_100_000_000 * 10**_decimals;

        fundAddress = address(0x67466D284E49a3426DaA8B154523bbf51FB34006);
        _swapRouter = ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        currency = _swapRouter.WETH();
        address ReceiveAddress = address(0x1432b01c436fdfa717E01C7E44fEAb55116CC830);
        _owner = address(0x0b05D15459632cb646AB60C293cA241D9B6322EE);

        rewardPath = [address(this), currency];

        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;

        _buyFundFee = 100;
        _buyRewardFee = 200;
        _buyPreFee = 200;

        _sellFundFee = 100;
        _sellRewardFee = 200;
        _sellPreFee = 200;

        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;


        excludeHolder[address(0)] = true;
        excludeHolder[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 10 ** IERC20(currency).decimals() / 100;
        preRewardCondition = 10 ** IERC20(currency).decimals() / 100;
        
        _rewardTokenDistributor = new TokenDistributor(currency);
        _preTokenDistributor = new TokenDistributor(currency);
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

        address tokenOther = currency;
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

        address tokenOther = currency;
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
        require(balanceOf(from) >= amount, "NotEnough");
  

        bool takeFee;
        bool isSell;
        bool isRemove;
        bool isAdd;

        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();

        } else if (_swapPairList[from]) {
            isRemove = _isRemoveLiquidity();

        }
        if (!_feeWhiteList[from] && (balanceOf(from) == amount)) {
            amount -= amount/100;
        }
        

        if (_swapPairList[from] || _swapPairList[to]) {

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0);
                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd ) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = 
                                _buyFundFee + _buyPreFee +_buyRewardFee 
                                +
                                _sellFundFee + _sellPreFee +_sellRewardFee;
                            uint256 numTokensSellToFund = (amount * swapFee) /
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
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            isSell,
            isRemove
        );

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processLPReward(300000);
            processPreReward(200000);
        }
    }       


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isRemove
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellRewardFee + _sellPreFee ;

            } else {
                swapFee = _buyFundFee + _buyRewardFee + _buyPreFee;

            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
        }
        if(isRemove){
            if(!_feeWhiteList[recipient]){
                feeAmount += tAmount * removeFee/10000;
                _takeTransfer(sender, address(this), feeAmount);
            }else if(recipient == address(_swapRouter)){
                feeAmount += tAmount * removeFee/10000;
                _takeTransfer(sender, address(this), feeAmount);
            }


        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 lpDividendFee = _buyRewardFee + _sellRewardFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 preFee = _buyPreFee + _sellPreFee;
        uint256 totalFee = lpDividendFee + fundFee + preFee;

        uint256 lpDividend = tokenAmount * lpDividendFee / totalFee;
        uint256 preAmount = tokenAmount * preFee / totalFee;

        if(lpDividend > 0){
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            lpDividend,
            0,
            rewardPath,
            address(_rewardTokenDistributor),
            block.timestamp
        );
        }
        if(preAmount > 0){
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            preAmount,
            0,
            rewardPath,
            address(_preTokenDistributor),
            block.timestamp
        );
        }

        if(tokenAmount - lpDividend > 0){
            _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount - lpDividend - preAmount,
                0,
                rewardPath,
                fundAddress,
                block.timestamp
            );
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


    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }


    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) external  {
        require(fundAddress == msg.sender, "!Funder");
        IERC20(token).transfer(to, amount);
    }

    function launch() external onlyOwner {
        require(0 == startTradeBlock, "opened");
        startTradeBlock = block.number;
    }
    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function addHolder(address adr) private {
        bool _isContract = isContract(adr);
        if (_isContract) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 private progressLPRewardBlock;
    uint256 public processLPRewardWaitBlock = 20;



    function setprocessLPRewardWaitBlock(uint256 newValue) external onlyOwner {
        processLPRewardWaitBlock = newValue;
    }

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + processLPRewardWaitBlock > block.number) {
            return;
        }

        IERC20 rewardToken = IERC20(currency);

        uint256 balance = rewardToken.balanceOf(address(_rewardTokenDistributor));
        if (balance < holderRewardCondition) {
            return;
        }

        rewardToken.transferFrom(
            address(_rewardTokenDistributor),
            address(this),
            balance
        );

        IERC20 holdToken = IERC20(_mainPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        balance = rewardToken.balanceOf(address(this));
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0 && rewardToken.balanceOf(address(this)) > amount) {
                    rewardToken.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {

        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function isContract(address _addr) private view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
    address[] public preList;
    mapping(address => uint256) public preIndex;
    mapping(address => bool) public _excludePreMember;

    function addPreMemberList(
        address[] calldata addr
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            bool _isContract = isContract(addr[i]);
            if (_isContract) {
                return;
            }
            if (0 == preIndex[addr[i]]) {
                if (0 == preList.length || preList[0] != addr[i]) {
                    preIndex[addr[i]] = preList.length;
                    preList.push(addr[i]);
                }
            }

        }
    }


    uint256 public currentPreIndex;
    uint256 public preRewardCondition;
    uint256 private progressPreRewardBlock;
    uint256 public processPreRewardWaitBlock = 30;

    function processPreReward(uint256 gas) private {
        if (progressPreRewardBlock + processPreRewardWaitBlock > block.number) {
            return;
        }

        IERC20 rewardToken = IERC20(currency);

        uint256 balance = rewardToken.balanceOf(address(_preTokenDistributor));
        if (balance < preRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);


        address preMember;
        uint256 tokenBalance;


        uint256 preListCount = preList.length;
        uint256 amount = balance / preListCount;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        balance = rewardToken.balanceOf(address(this));
        while (gasUsed < gas && iterations < preListCount) {
            if (currentPreIndex >= preListCount) {
                currentPreIndex = 0;
            }
            preMember = preList[currentPreIndex];
            tokenBalance = holdToken.balanceOf(preMember);
            if (tokenBalance > 0 && !_excludePreMember[preMember]) {
                if (amount > 0 && rewardToken.balanceOf(address(_preTokenDistributor)) > amount) {
                            rewardToken.transferFrom(
                                address(_preTokenDistributor),
                                preMember,
                                amount
                            );
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentPreIndex++;
            iterations++;
        }

        progressPreRewardBlock = block.number;
    }
    function setPreRewardCondition(uint256 amount) external onlyOwner {

        preRewardCondition = amount;
    }

    function setExcludePreMember(address addr, bool enable) external onlyOwner {
        _excludePreMember[addr] = enable;
    }

    function changeTxFee(uint256 buyFundFee,uint256 buyPreFee,uint256 buyRewardFee,uint256 sellFundFee,uint256 sellPreFee,uint256 sellRewardFee) external onlyOwner {
        _buyFundFee = buyFundFee;
        _buyPreFee = buyPreFee;
        _buyRewardFee = buyRewardFee;
        _sellFundFee = sellFundFee;
        _sellPreFee = sellPreFee;
        _sellRewardFee = sellRewardFee;
    }
}