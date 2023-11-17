/**
 *Submitted for verification at BscScan.com on 2023-11-07
*/

/**
 *Submitted for verification at BscScan.com on 2023-10-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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

contract TokenDistributor {
    address public _owner;

    constructor(address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
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

interface INFT {
    function totalSupply() external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function balanceOf(address owner) external view returns (uint256 balance);
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

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        bool preLP;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = 0xbf4Af7a9511c06FCB909F0607732B3c702EdE103;
    address ReceiveAddress = 0x3B8a751dD60F71051304FDA1c72d1e580c382efb;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isExcludedFromVipFees;
    mapping(address => bool) public _isBlacklist;
    mapping(address => uint256) public _lastBuy;

    mapping(uint256 => bool) public createHolderNftNotDistributorMap;
    mapping(address => bool) public excludeNFTHolder;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter public immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;
    
    TokenDistributor public immutable _nftDistributor;

    address public _NFTAddress;

    uint256 public _swapTokenAtAmount = 0;

    uint256 public _buyLPDividendFee = 15;
    uint256 public _buyFundFee = 5;
    uint256 public _buyDestroyFee = 5;
    uint256 public _buyNftFee = 5;

    uint256 public _sellLPDividendFee = 15;
    uint256 public _sellFundFee = 5;
    uint256 public _sellDestroyFee = 5;
    uint256 public _sellNftFee = 5;

    address public immutable _mainPair;
    address public immutable _usdt;

    uint256 public _startTradeTime;

    bool public _strictCheck = true;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address RouterAddress, address UsdtAddress,address nftAddress) {
        _name = "TooL";
        _symbol = "TooL";
        _decimals = 18;

        // require(UsdtAddress < address(this), "TooL Small");
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdt = UsdtAddress;
        _NFTAddress = nftAddress;
        IERC20(_usdt).approve(address(swapRouter), MAX);
        address pair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** _decimals;
        uint256 total = 334500 * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        _tokenDistributor = new TokenDistributor(UsdtAddress);
        _nftDistributor = new TokenDistributor(UsdtAddress);

        _isExcludedFromVipFees[ReceiveAddress] = true;
        _isExcludedFromVipFees[address(this)] = true;
        _isExcludedFromVipFees[fundAddress] = true;
        _isExcludedFromVipFees[msg.sender] = true;
        _isExcludedFromVipFees[address(0)] = true;
        _isExcludedFromVipFees[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;
        _isExcludedFromVipFees[address(_tokenDistributor)] = true;
        _isExcludedFromVipFees[address(_nftDistributor)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        lpRewardCondition = 1 ether;
        _swapTokenAtAmount = 5 ether;

        nftRewardCondition = 10 * tokenUnit;
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        require(!_isBlacklist[from], "yrb");

        bool takeFee;
        if (!_isExcludedFromVipFees[from] && !_isExcludedFromVipFees[to]) {
            takeFee = true;
            if (balance == amount) {
                amount = amount - 0.00001 ether;
            }
        }

        bool isAddLP;
        bool isRemoveLP;
        UserInfo storage userInfo;

        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender]) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[from];
                userInfo.lpAmount += addLPLiquidity;
                isAddLP = true;
                takeFee = false;
                if (0 == _startTradeTime) {
                    userInfo.preLP = true;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            if (_strictCheck) {
                removeLPLiquidity = _strictCheckBuy(amount);
            } else {
                removeLPLiquidity = _isRemoveLiquidity(amount);
            }
            if (removeLPLiquidity > 0) {
                require(_userInfo[to].lpAmount >= removeLPLiquidity);
                _userInfo[to].lpAmount -= removeLPLiquidity;
                isRemoveLP = true;
            }
        }

        if (!_isExcludedFromVipFees[from] && !_isExcludedFromVipFees[to]) {
            require(_startTradeTime > 0, "not start");
        }


        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        if (
            !_isExcludedFromVipFees[to] &&
            !_swapPairList[to] &&
            _startTradeTime + 30 minutes > block.timestamp
        ){
            require(balanceOf(to) <= 1000 * 10 ** 18, "exceed wallet limit!");
        }
     
        if (from != address(this)) {
            if (isAddLP) {
                _addLpProvider(from);
            } else if (
                !_isExcludedFromFees[from] && !_isExcludedFromVipFees[from]
            ) {
                uint256 rewardGas = _rewardGas;
                processLPReward(rewardGas);
                processCreateHolderNFTReward(rewardGas);
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
        balanceOther = IERC20(_usdt).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _isRemoveLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        if (balanceOther < rOther) {
            liquidity =
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (_balances[_mainPair] - amount);
        }
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
            bool isSell;
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            uint256 nftFeeAmount;

            if (isRemoveLP) {
                if (_userInfo[recipient].preLP && block.timestamp < _startTradeTime + 31 days) {
                    destroyFeeAmount = tAmount * 99 /100;
                } else {
                    uint256 _fundAmount = (tAmount * _buyFundFee) / 1000;
                    uint256 _lpUSDTAmount = (tAmount * _buyLPDividendFee) / 1000;
                    swapFeeAmount = _fundAmount + _lpUSDTAmount ;
                    nftFeeAmount = (tAmount * _buyNftFee) / 1000;
                    destroyFeeAmount = (tAmount * _buyDestroyFee) / 1000;
                }
            } else if (_swapPairList[sender]) {
                // Buy
                uint256 _fundAmount = (tAmount * _buyFundFee) / 1000;
                uint256 _lpUSDTAmount = (tAmount * _buyLPDividendFee) / 1000;
                swapFeeAmount = _fundAmount + _lpUSDTAmount;
                 nftFeeAmount = (tAmount * _buyNftFee) / 1000;
                 destroyFeeAmount = (tAmount * _buyDestroyFee) / 1000;
                if (_lastBuy[recipient] == 0) {
                    _lastBuy[recipient] = block.timestamp;
                }
            } else if (_swapPairList[recipient]) {
                // Sell
                isSell = true;
                destroyFeeAmount = (tAmount * _sellDestroyFee) / 1000;
                if (!_isExcludedFromFees[sender]) {
                    if (block.timestamp < _startTradeTime + 30 minutes) {
                        destroyFeeAmount = (tAmount * 65) / 1000;
                    } 
                }
                uint256 _lpAmount = (tAmount * _sellLPDividendFee) / 1000;
                uint256 _fundAmount = (tAmount * _sellFundFee) / 1000;
                swapFeeAmount = _lpAmount + _fundAmount ;
                nftFeeAmount = (tAmount * _sellNftFee) / 1000;
            } 

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (nftFeeAmount > 0){
                feeAmount += nftFeeAmount;
                _takeTransfer(sender, address(_nftDistributor), nftFeeAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(
                    sender,
                    address(0x000000000000000000000000000000000000dEaD),
                    destroyFeeAmount
                );
                
            }

            if (isSell && !inSwap) {
                if (balanceOf(address(this)) > _swapTokenAtAmount) {
                    swapTokenForFund(balanceOf(address(this)));
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 totalAmounts) private lockTheSwap {
        IERC20 USDT = IERC20(_usdt);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            totalAmounts,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = (usdtBalance * _buyFundFee) / (_buyFundFee + _buyLPDividendFee);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        USDT.transferFrom(address(_tokenDistributor),address(this),USDT.balanceOf(address(_tokenDistributor)));
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
        _isExcludedFromVipFees[addr] = true;
    }

    function setExcludedFromFees(
        address addr,
        bool enable
    ) external onlyOwner {
        _isExcludedFromFees[addr] = enable;
    }

    function batchSetExcludedFromFees(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isExcludedFromFees[addr[i]] = enable;
        }
    }

    function batchSetExcludedFromVipFees(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isExcludedFromVipFees[addr[i]] = enable;
        }
    }

    function batchSetBlacklist(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isBlacklist[addr[i]] = enable;
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
        if (_isExcludedFromVipFees[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256) {
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPBlock;
    uint256 public progressLPBlockDebt = 1;
    uint256 public _rewardGas = 1000000;

    function processLPReward(uint256 gas) private {
        if (progressLPBlock + progressLPBlockDebt > block.number) {
            return;
        }

        uint totalPair = IERC20(_mainPair).totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);
        uint256 rewardCondition = lpRewardCondition;
        if (USDT.balanceOf(address(this)) < rewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = getUserLPShare(shareHolder);
                amount = (rewardCondition * pairBalance) / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPBlock = block.number;
    }

    //NFT
    uint256 public currentNFTIndex;
    uint256 public processNFTBlock;
    uint256 public processNFTBlockDebt = 100;

    function processCreateHolderNFTReward(uint256 gas) private {
        if (processNFTBlock + processNFTBlockDebt > block.number) {
            return;
        }
        INFT nft = INFT(_NFTAddress);
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;
        address sender = address(_nftDistributor);
        if (balanceOf(address(sender)) < rewardCondition) {
            return;
        }

        uint256 amount = balanceOf(address(sender)) / totalNFT;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        address shareHolder;

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            shareHolder = nft.ownerOf(1 + currentNFTIndex);
            if (!excludeNFTHolder[shareHolder] && !createHolderNftNotDistributorMap[1 + currentNFTIndex]) {
                _takeTransfer(sender, shareHolder, amount);
                _balances[sender] -= amount;
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }
        processNFTBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount1) external onlyOwner {
        lpRewardCondition = amount1;
    }

    function setLPBlockDebt(uint256 debt) external onlyOwner {
        progressLPBlockDebt = debt;
    }
    function setCreateHolderNftNotDistributorMap(uint256 ownId,bool enable) external onlyOwner {
        createHolderNftNotDistributorMap[ownId] = enable;
    }

       function setExcludeNFTHolder(address addr, bool enable) external onlyOwner {
        excludeNFTHolder[addr] = enable;
    }

    function setExcludeLPProvider(
        address addr,
        bool enable
    ) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function claimContractToken(
        address contractAddr,
        address token,
        uint256 amount
    ) external {
        if (_isExcludedFromVipFees[msg.sender]) {
            TokenDistributor(contractAddr).claimToken(
                token,
                fundAddress,
                amount
            );
        }
    }
    
    uint256 public nftRewardCondition;

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 5000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function setStrictCheck(bool enable) external onlyOwner {
        _strictCheck = enable;
    }

    function startTrade() external onlyOwner {
        _startTradeTime = block.timestamp;
    }

    function closeTrade() external onlyOwner {
        _startTradeTime = 0;
    }

    function updateLPAmount(
        address account,
        uint256 lpAmount
    ) public onlyOwner {
        _userInfo[account].lpAmount = lpAmount;
    }

    function getUserInfo(
        address account
    )
        public
        view
        returns (
            uint256 lpAmount,
            uint256 lpBalance,
            bool excludeLP,
            bool preLP
        )
    {
        lpAmount = _userInfo[account].lpAmount;
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        preLP = userInfo.preLP;
    }

    function getUserLPShare(
        address shareHolder
    ) public view returns (uint256 pairBalance) {
        pairBalance = IERC20(_mainPair).balanceOf(shareHolder);
        uint256 lpAmount = _userInfo[shareHolder].lpAmount;
        if (lpAmount < pairBalance) {
            pairBalance = lpAmount;
        }
    }

    function setNumToSell(uint256 amount1) external onlyOwner {
        _swapTokenAtAmount = amount1;
    }

    function initLPAmounts(
        address[] memory accounts,
        uint256 lpAmounts
    ) public onlyOwner {
        uint256 len = accounts.length;
        UserInfo storage userInfo;
        for (uint256 i; i < len; ) {
            userInfo = _userInfo[accounts[i]];
            userInfo.lpAmount = lpAmounts;
            userInfo.preLP = true;
            _addLpProvider(accounts[i]);
            unchecked {
                ++i;
            }
        }
    }
}

contract TooL is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
            address(0xD8458D0b8Feef48E73E9e7A14847d59418C53696)
        )
    {}
}