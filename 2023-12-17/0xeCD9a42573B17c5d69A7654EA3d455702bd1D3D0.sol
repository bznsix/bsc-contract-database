// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

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

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface ISwapPair {
    function burn(address to) external returns (uint amount0, uint amount1);

    function mint(address to) external returns (uint liquidity);

    function getReserves()
        external
        view
        returns (uint256 reserve0, uint256 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);
}

interface INFT {
    function totalSupply() external view returns (uint256);

    function getIdxs(address account) external view returns (uint256[] memory);
}

interface HSToken {
    function getLPProviderLength() external view returns (uint256);

    function lpProviders(uint256 idx) external view returns (address);
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

contract Token is IERC20, Ownable {
    address private RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public HS = 0xcD423DD42775C90c56be3DbA51748Ad796E19ca8;
    address public HSPAIR = 0x9A3A09e0304af7368fd6Dde0959b18e4b7Eb9622;

    string private constant _name = "777";
    string private constant _symbol = "777";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000000 * 10 ** _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    ISwapRouter private _swapRouter;
    address public mainPair;

    mapping(address => bool) public _feeWhiteList;

    NFTRewards public nftRewards;
    TokenDistribute public tokenDistribute;

    address public dev = 0x9F4016C75E019912DFb71B56671B1B62B48df606;
    address public genesisAddr = 0xBD3054B8F8028433D8F4C17b5fDf150307D70bf8;
    address public envAddr = 0x1126F64cd2532241788C51e68903665657964381;
    address public hsReceiver = 0x7F6694Fe02B22fc8cd809e1BC176fa9503E7AB06;
    address public bnbReceiver = 0x393dd7DeC436AAf8a8a00F79D0Ca2ED65af3734c;
    address[6] public envs = [
        0xc307a08E4172789f815dF976350d7cb4c0D64A6A,
        0x67fE96eD77B9De3bD7740e21A1Ad92a21349ad65,
        0x95B33cC99024B0AD02E914B8e2311868618EA144,
        0x983bEFF3ADf12084e10802D77dA5935a61b9a866,
        0x4c186F1D8480C5e7826F37C929c6beC6Bac8806B,
        0x47b4EadDD8C93fa3A084fC951d73B1760f6a67dc
    ];
    uint256[6] public envRates = [104, 104, 104, 208, 200, 280];
    mapping(address => bool) public nodes;

    uint256 public constant MAX = ~uint256(0);
    uint256 public constant buyDays = 30;
    uint256 public constant dayTs = 1 days;

    uint256 public lastPriceTimestamp;
    uint256 public lastPrice;
    uint256 public maxDepth = 100;
    uint256 public returnPercent = 100;
    uint256 public pumpPercent = 1200;
    uint256 public nodeSellPrice = 1 ether;
    uint256 public minInvestBNB = 1 ether;
    uint256 public minerAmount = 0.000001 ether;
    uint256 public groupMinCount = 20;

    uint256 public totalInverstBNB;
    mapping(address => uint256) public userTotalInvestBNB;
    mapping(address => uint256) public userTotalClaimedBNB;
    mapping(address => uint256) public userInvestBNB;
    mapping(address => uint256) public userClaimedBNB;
    mapping(address => uint256) public userReferBNB;
    mapping(address => uint256) public userRefersCount;
    mapping(address => uint256) public userPendingReferAmount;
    mapping(address => uint256) public userPendingGroupAmount;
    mapping(address => uint256) public userPerDayBuyBNB;
    mapping(address => address) public userRefers;
    mapping(address => address) public ancestors;
    mapping(address => uint256) public lastClaimedBlock;
    mapping(address => uint256) public userBuybackCounts;
    mapping(address => uint256) public groupTotalRecommendAcount;
    mapping(address => uint256) public groupTotalInverstBNB;

    uint256[3] public referRate = [3, 2, 1];
    uint256[3] public minerRate = [3, 2, 1];

    modifier onlyDev() {
        require(msg.sender == dev || msg.sender == owner(), "not dev");
        _;
    }

    constructor() {
        require(WBNB < address(this), "eeee");
        _swapRouter = ISwapRouter(RouterAddr);
        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        mainPair = swapFactory.createPair(address(this), WBNB);
        _feeWhiteList[address(0xdead)] = true;
        _feeWhiteList[address(0x1)] = true;
        _feeWhiteList[genesisAddr] = true;
        _feeWhiteList[envAddr] = true;
        nftRewards = new NFTRewards(dev, bnbReceiver, HS);
        tokenDistribute = new TokenDistribute(dev, HS, HSPAIR);
        _balances[genesisAddr] = (_tTotal * 25) / 100;
        emit Transfer(address(0), genesisAddr, (_tTotal * 25) / 100);

        _balances[address(this)] = (_tTotal * 75) / 100;
        emit Transfer(address(0), address(this), (_tTotal * 75) / 100);
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
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
        require(from != to, "Same");
        require(amount > 0, "Zero");
        uint256 balance = _balances[from];
        require(balance >= amount, "balance Not Enough");

        if (_feeWhiteList[from] || _feeWhiteList[to]) {
            _tokenTransfer(from, to, amount);
            return;
        }

        if (from == mainPair) {
            if (to == address(this)) {
                _tokenTransfer(from, to, amount);
                return;
            }
            revert("can not buy");
        }

        if (to == mainPair) {
            require(nodes[from], "can not sell");
            address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = WBNB;
            path[2] = USDT;
            uint256 price = ISwapRouter(RouterAddr).getAmountsOut(
                1 ether,
                path
            )[2];
            require(price >= nodeSellPrice, "under target price");
            _tokenTransfer(from, to, amount);
            return;
        }

        if (to == address(this)) {
            address sender = msg.sender;
            require(sender == from, "Bot");
            require(sender == tx.origin, "BOT");
            _tokenTransfer(from, to, amount);

            if (amount == minerAmount) {
                if (
                    0 == userInvestBNB[sender] ||
                    lastClaimedBlock[sender] == 0 ||
                    lastClaimedBlock[sender] + dayTs > block.timestamp
                ) {
                    return;
                }

                address[] memory path = new address[](2);
                path[0] = WBNB;
                path[1] = address(this);
                if (userBuybackCounts[sender] < buyDays) {
                    uint256 ccprice = ISwapRouter(RouterAddr).getAmountsIn(
                        1 ether,
                        path
                    )[0];
                    if (lastPriceTimestamp + dayTs < block.timestamp) {
                        lastPrice = ccprice;
                        lastPriceTimestamp = lastPriceTimestamp + dayTs;
                    }
                    if (ccprice < (lastPrice * pumpPercent) / 1000) {
                        buyHHH(userPerDayBuyBNB[sender], path);
                        userBuybackCounts[sender] =
                            userBuybackCounts[sender] +
                            1;
                    }
                }

                uint256 staticMint = _swapRouter.getAmountsOut(
                    (userPerDayBuyBNB[sender] * returnPercent) / 100,
                    path
                )[1];

                if (userPendingReferAmount[sender] > 0) {
                    _tokenTransfer(
                        address(this),
                        sender,
                        userPendingReferAmount[sender]
                    );
                }
                if (userPendingGroupAmount[sender] > 0) {
                    _tokenTransfer(
                        address(this),
                        sender,
                        userPendingGroupAmount[sender]
                    );
                }
                _tokenTransfer(address(this), sender, staticMint);
                lastClaimedBlock[sender] = block.timestamp;
                userPendingReferAmount[sender] = 0;
                userPendingGroupAmount[sender] = 0;

                address ancestor = userRefers[sender];
                for (uint256 i = 0; i < minerRate.length; i++) {
                    if (
                        ancestor != address(0) &&
                        userInvestBNB[ancestor] > 0 &&
                        userRefersCount[ancestor] >= i + 1
                    ) {
                        userPendingReferAmount[ancestor] =
                            userPendingReferAmount[ancestor] +
                            (staticMint * minerRate[i]) /
                            100;
                    }
                    ancestor = userRefers[ancestor];
                }

                address node = ancestors[sender];
                if (node != address(0) && userInvestBNB[node] > 0) {
                    userPendingReferAmount[node] =
                        userPendingReferAmount[node] +
                        staticMint /
                        200;
                }

                address group = userRefers[sender];
                uint256 maxRate = 20;
                uint256 sRate = 0;
                for (uint j = 0; j < maxDepth; j++) {
                    if (group != address(0)) {
                        if (
                            groupTotalInverstBNB[group] >= 50000 ether &&
                            userInvestBNB[group] > 0 &&
                            userRefersCount[group] >= groupMinCount &&
                            maxRate > sRate
                        ) {
                            userPendingGroupAmount[group] =
                                userPendingGroupAmount[group] +
                                (staticMint * (maxRate - sRate)) /
                                1000;
                            sRate = 20;
                        }

                        if (
                            groupTotalInverstBNB[group] < 50000 ether &&
                            groupTotalInverstBNB[group] >= 5000 ether &&
                            userInvestBNB[group] > 0 &&
                            userRefersCount[group] >= groupMinCount &&
                            maxRate > sRate
                        ) {
                            userPendingGroupAmount[group] =
                                userPendingGroupAmount[group] +
                                (staticMint * (10 - sRate)) /
                                1000;
                            sRate = 10;
                        }

                        if (
                            groupTotalInverstBNB[group] < 5000 ether &&
                            groupTotalInverstBNB[group] >= 500 ether &&
                            userInvestBNB[group] > 0 &&
                            userRefersCount[group] >= groupMinCount &&
                            maxRate > sRate
                        ) {
                            userPendingGroupAmount[group] =
                                userPendingGroupAmount[group] +
                                (staticMint * (5 - sRate)) /
                                1000;
                            sRate = 5;
                        }
                        group = userRefers[group];
                    } else {
                        break;
                    }
                }
            } else {
                if (0 == userInvestBNB[sender]) {
                    return;
                }
                address[] memory path = new address[](2);
                path[0] = WBNB;
                path[1] = address(this);

                uint256 canSellBNB = _swapRouter.getAmountsIn(amount, path)[0];

                uint256 claimedBNB = userClaimedBNB[sender];
                uint256 totalBNB = canSellBNB + claimedBNB;

                uint256 sBNB = totalBNB <= 3 * userInvestBNB[sender]
                    ? canSellBNB
                    : 3 * userInvestBNB[sender] - claimedBNB;

                (uint256 rwbnb, , ) = ISwapPair(mainPair).getReserves();
                uint256 lpTotalSupply = ISwapPair(mainPair).totalSupply();
                uint256 removeLPAmount = (((sBNB * lpTotalSupply) / rwbnb) *
                    777) / 1000;
                IERC20(mainPair).transfer(mainPair, removeLPAmount);
                (uint rb, ) = ISwapPair(mainPair).burn(address(this));
                IWETH(WBNB).withdraw(rb);
                uint256 totalEnv = (rb * 50) / 777;
                payable(sender).transfer((rb * 667) / 777);
                payable(address(tokenDistribute)).transfer(totalEnv);
                payable(genesisAddr).transfer((rb * 10) / 777);

                for (uint i = 0; i < envs.length; i++) {
                    payable(envs[i]).transfer((totalEnv * envRates[i]) / 1000);
                }
                userClaimedBNB[sender] = userClaimedBNB[sender] + sBNB;
                userTotalClaimedBNB[sender] =
                    userTotalClaimedBNB[sender] +
                    sBNB;
                if (userClaimedBNB[sender] >= 3 * userInvestBNB[sender]) {
                    userClaimedBNB[sender] = 0;
                    userInvestBNB[sender] = 0;
                    userPendingReferAmount[sender] = 0;
                    userPendingGroupAmount[sender] = 0;
                    _tokenTransfer(sender, address(this), balanceOf(sender));
                    if (userBuybackCounts[sender] < buyDays) {
                        payable(envAddr).transfer(
                            (buyDays - userBuybackCounts[sender]) *
                                userPerDayBuyBNB[sender]
                        );
                    }
                } else {
                    if (balanceOf(sender) < minerAmount) {
                        _tokenTransfer(address(this), sender, minerAmount * 2);
                    }
                }
                tokenDistribute.process(300000);
            }
        } else {
            revert("can not transfer");
        }
    }

    receive() external payable {
        if (msg.sender == WBNB) {
            return;
        }
        address account = msg.sender;
        uint256 value = msg.value;
        require(tx.origin == msg.sender && !isContract(msg.sender), "bot");
        require(userInvestBNB[account] == 0, "not end");
        require(value >= minInvestBNB, "Less investment");
        address refer = userRefers[account];
        require(refer != address(0), "need refer");

        lastClaimedBlock[account] = block.timestamp;
        totalInverstBNB += value;
        userInvestBNB[account] = value;
        userTotalInvestBNB[account] = userTotalInvestBNB[account] + value;
        userPerDayBuyBNB[account] = (value * 36) / 100 / buyDays;

        address ancestor = userRefers[account];
        for (uint256 i = 0; i < maxDepth; i++) {
            if (ancestor != address(0)) {
                groupTotalRecommendAcount[ancestor]++;
                groupTotalInverstBNB[ancestor] += value;
                ancestor = userRefers[ancestor];
            } else {
                break;
            }
        }

        if (nodes[account]) {
            payable(address(genesisAddr)).transfer((value * 4) / 100);
            ancestors[account] = account;
        } else {
            ancestor = ancestors[refer];
            if (ancestor == address(0)) {
                ancestor = genesisAddr;
            }
            ancestors[account] = ancestor;
            if (userInvestBNB[ancestor] > 0) {
                payable(address(ancestor)).transfer((value * 4) / 100);
                userReferBNB[ancestor] =
                    userReferBNB[ancestor] +
                    (value * 4) /
                    100;
            } else {
                payable(address(genesisAddr)).transfer((value * 4) / 100);
            }
        }
        nftRewards.addNftRewards{value: (value * 6) / 100}();
        payable(address(genesisAddr)).transfer((value * 1) / 100);
        ancestor = userRefers[account];
        for (uint i = 0; i < referRate.length; i++) {
            if (
                ancestor != address(0) &&
                userInvestBNB[ancestor] > 0 &&
                userRefersCount[ancestor] >= i + 1
            ) {
                payable(ancestor).transfer((value * referRate[i]) / 100);
                userReferBNB[ancestor] =
                    userReferBNB[ancestor] +
                    (value * referRate[i]) /
                    100;
            } else {
                payable(genesisAddr).transfer((value * referRate[i]) / 100);
            }
            ancestor = userRefers[ancestor];
        }
        burnHS((value * 3) / 100);
        if (_balances[account] == 0) {
            _tokenTransfer(address(this), account, 0.00002 ether);
        }
        addLP((value * 44) / 100);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function setFeeWhiteList(
        address[] calldata addList,
        bool enable
    ) external onlyDev {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setNodes(
        address[] calldata addList,
        bool enable
    ) external onlyDev {
        for (uint256 i = 0; i < addList.length; i++) {
            nodes[addList[i]] = enable;
        }
    }

    function setNodeSellPrice(uint256 _nodeSellPrice) external onlyDev {
        nodeSellPrice = _nodeSellPrice;
    }

    function setPumpPercent(uint256 _percent) external onlyDev {
        pumpPercent = _percent;
    }

    function setReturnPercent(uint256 _returnPercent) external onlyDev {
        returnPercent = _returnPercent;
    }

    function setlastPriceTimestamp(
        uint256 _lastPriceTimestamp
    ) external onlyDev {
        lastPriceTimestamp = _lastPriceTimestamp;
    }

    function setMinInvestBNB(uint256 _minInvestBNB) external onlyDev {
        minInvestBNB = _minInvestBNB;
    }

    function setMinerAmount(uint256 _minerAmount) external onlyDev {
        minerAmount = _minerAmount;
    }

    function setGroupMinCount(uint256 _groupMinCount) external onlyDev {
        groupMinCount = _groupMinCount;
    }

    function claimBalance() external onlyDev {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) public onlyDev {
        IERC20(token).transfer(to, amount);
    }

    function register(address _refer) public {
        require(userInvestBNB[_refer] > 0 || _refer == genesisAddr, "eee");
        require(userRefers[msg.sender] == address(0), "ddd");
        userRefers[msg.sender] = _refer;
        userRefersCount[_refer]++;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function addLP(uint256 bnbAmount) internal {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
        IWETH(WBNB).deposit{value: bnbAmount}();
        uint256 addLPTokenAmount = ISwapRouter(RouterAddr).getAmountsOut(
            bnbAmount,
            path
        )[1];
        _tokenTransfer(address(this), mainPair, addLPTokenAmount);
        IWETH(WBNB).transfer(mainPair, bnbAmount);
        ISwapPair(mainPair).mint(address(this));
    }

    function burnHS(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = HS;
        _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(1, path, hsReceiver, block.timestamp);
    }

    function buyHHH(uint256 amount, address[] memory path) internal {
        _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(0x1), block.timestamp);

        _tokenTransfer(address(0x1), address(this), balanceOf(address(0x1)));
    }
}

contract NFTRewards {
    INFT public nft = INFT(0xcce005E2c61eae599D8dCA7f7f83F6D4867258F8);
    uint256 public totalNFTRewards = 0;
    uint256 public totalClaimedNFTRewards = 0;
    mapping(uint256 => uint256) public pendingNFTRewards;
    mapping(uint256 => uint256) public claimedNFTRewards;
    address public owner;
    address public hs;
    uint256 public reinverstBNBs = 2 ether;
    uint256 public outsBNBs = 10 ether;
    uint256 public hsMinHolder = 5 ether;
    address public bnbReceiver;

    constructor(address _owner, address _bnbReceiver, address _hs) {
        owner = _owner;
        hs = _hs;
        bnbReceiver = _bnbReceiver;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function emergencyWithdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function setBnbReceiver(address _bnbReceiver) public onlyOwner {
        bnbReceiver = _bnbReceiver;
    }

    function setReinverstBNB(uint256 _bnbs) public onlyOwner {
        reinverstBNBs = _bnbs;
    }

    function setOutsBNB(uint256 _bnbs) public onlyOwner {
        outsBNBs = _bnbs;
    }

    function setMinHolder(uint256 _bnbs) public onlyOwner {
        hsMinHolder = _bnbs;
    }

    function claimReward() public {
        require(
            IERC20(hs).balanceOf(msg.sender) >= hsMinHolder,
            "need hold hs tokens"
        );
        uint256[] memory idxs = nft.getIdxs(msg.sender);
        for (uint i = 0; i < idxs.length; i++) {
            payable(msg.sender).transfer(pendingNFTRewards[idxs[i]]);
            claimedNFTRewards[idxs[i]] =
                claimedNFTRewards[idxs[i]] +
                pendingNFTRewards[idxs[i]];
            pendingNFTRewards[idxs[i]] = 0;
        }
    }

    function inverst(uint256 idx) public payable {
        require(msg.value == reinverstBNBs, "ppp");
        payable(bnbReceiver).transfer(msg.value);
        claimedNFTRewards[idx] = 0;
    }

    function addNftRewards() external payable {
        totalNFTRewards += msg.value;
        uint256 totalNFTs = nft.totalSupply();
        if (totalNFTs > 0) {
            uint256 totalLeft;
            uint256 shareAmount = msg.value / totalNFTs;
            for (uint i = 0; i < totalNFTs; i++) {
                if (claimedNFTRewards[i] + pendingNFTRewards[i] <= outsBNBs) {
                    pendingNFTRewards[i] = pendingNFTRewards[i] + shareAmount;
                } else {
                    totalLeft += shareAmount;
                }
            }
            if (totalLeft > 0) {
                payable(bnbReceiver).transfer(totalLeft);
            }
        }
    }

    receive() external payable {}
}

contract TokenDistribute {
    address public owner;

    address public hsPair;
    address public hs;

    constructor(address _owner, address _hs, address _hsPair) {
        owner = _owner;
        hs = _hs;
        hsPair = _hsPair;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function emergencyWithdraw(address _token, address to) public onlyOwner {
        IERC20(_token).transfer(to, IERC20(_token).balanceOf(address(this)));
    }

    function emergencyWithdrawBNB(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition = 1 ether;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 1;
    mapping(address => bool) public excludeHolders;

    function setHolderRewardCondition(
        uint256 _holderRewardCondition
    ) public onlyOwner {
        holderRewardCondition = _holderRewardCondition;
    }

    function setExcludeHolder(address _acc, bool status) public onlyOwner {
        excludeHolders[_acc] = status;
    }

    function process(uint256 gas) external {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }
        uint256 balance = address(this).balance;
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;

        IERC20 holdToken = IERC20(hsPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 shareholderCount = HSToken(hs).getLPProviderLength();

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = HSToken(hs).lpProviders(currentIndex);
            if (!excludeHolders[shareHolder]) {
                tokenBalance = holdToken.balanceOf(shareHolder);
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0) {
                    payable(shareHolder).transfer(amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = blockNum;
    }

    receive() external payable {}
}