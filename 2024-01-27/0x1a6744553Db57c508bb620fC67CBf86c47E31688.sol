// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
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
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
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

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            )))));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        uint256 preLPAmount;
    }

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address private constant Dead = address(0x000000000000000000000000000000000000dEaD);

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _whileList;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _swapRouters;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public immutable _tokenDistributor;

    uint256 private constant _buyLPDividendFee = 100;
    uint256  private constant _buyLPFee = 100;
    uint256  private constant _buyNodeFee = 100;

    uint256 private constant _sellLPDividendFee = 100;
    uint256  private constant _sellLPFee = 100;
    uint256  private constant _sellNodeFee = 100;

    uint256 private constant _preFeeDuration = 30 minutes / 3;
    uint256 private constant _preBuyFundFee = 200;
    uint256 private constant _preSellFundFee = 2700;

    uint256 private constant _removeLPFee = 500;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;
    address public immutable _mainPair;
    address private  immutable _usdt;

    bool public _strictCheck = true;
    uint256 public _minTotal;
    address public _cake;
    address private immutable _weth;
    ISwapPair private immutable _wethUsdtPair;

    uint256 public  immutable _whiteBlock;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address UsdtAddress, address CakeAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress, uint256 MinTotal
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _weth = swapRouter.WETH();
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;
        _cake = CakeAddress;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdt = UsdtAddress;

        address swapPair;
        if (address(0x10ED43C718714eb63d5aA57B78B54704E256024E) == RouterAddress) {
            swapPair = PancakeLibrary.pairFor(address(swapFactory), _weth, address(this));
        } else {
            swapPair = swapFactory.createPair(_weth, address(this));
        }
        _swapPairList[swapPair] = true;
        _mainPair = swapPair;

        address wethUsdtPair = swapFactory.getPair(UsdtAddress, _weth);
        _wethUsdtPair = ISwapPair(wethUsdtPair);
        require(address(0) != wethUsdtPair, "NUE");

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        uint256 receiveTotal = total;
        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);

        fundAddress = FundAddress;
        _tokenDistributor = new TokenDistributor(CakeAddress);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(_tokenDistributor)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _minTotal = MinTotal * tokenUnit;
        lpRewardCondition = 50 * 10 ** IERC20(CakeAddress).decimals();
        lpHoldCondition = 88 * 10 ** IERC20(UsdtAddress).decimals();
        partnerRewardCondition = lpRewardCondition;

        uint256 whiteBlock = 7;
        if (block.chainid != 56) {
            whiteBlock = 40;
        }
        _whiteBlock = whiteBlock;
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

    function validSupply() public view returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = balance * 99999 / 100000;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                takeFee = true;
            }
            takeFee = true;
        }

        address txOrigin = tx.origin;
        UserInfo storage userInfo;
        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && txOrigin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                takeFee = false;
                userInfo = _userInfo[txOrigin];
                userInfo.lpAmount += addLPLiquidity;
                if (0 == startTradeBlock) {
                    userInfo.preLPAmount += addLPLiquidity;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                userInfo = _userInfo[txOrigin];
                require(userInfo.lpAmount >= removeLPLiquidity);
                userInfo.lpAmount -= removeLPLiquidity;
                if (_feeWhiteList[txOrigin]) {
                    takeFee = false;
                }
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && addLPLiquidity > 0);
                } else if (block.number < startTradeBlock + _whiteBlock) {
                    require(_whileList[to]);
                }
            }
        }

        if (from != _mainPair && addLPLiquidity == 0) {
            rebase();
        }

        _tokenTransfer(from, to, amount, takeFee, removeLPLiquidity);

        if (from != address(this)) {
            if (addLPLiquidity > 0) {
                _addLpProvider(from);
            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processPartnerDividend(rewardGas);
                uint256 blockNum = block.number;
                if (processPartnerBlock != blockNum) {
                    processLPReward(rewardGas);
                }
            }
        }
    }

    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther <= rOther) {
            liquidity = amount * ISwapPair(_mainPair).totalSupply() / (balanceOf(_mainPair) - amount);
        } else if (_strictCheck) {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
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
                    uint256 numerator;
                    uint256 denominator;
                    if (address(_swapRouter) == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) {// BSC Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (address(_swapRouter) == address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)) {//BSC testnet Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (address(_swapRouter) == address(0xE9d6f80028671279a28790bb4007B10B0595Def1)) {//PG W3Swap
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {//SushiSwap,UniSwap,OK Cherry Swap
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 5 + rootKLast;
                    }
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

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_weth).balanceOf(_mainPair);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _weth;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _fundTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 removeLPLiquidity
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            bool isPreFee;
            if (removeLPLiquidity > 0) {
                feeAmount += _calRemoveFeeAmount(sender, tAmount, removeLPLiquidity);
            } else if (_swapPairList[sender]) {//Buy
                swapFeeAmount = tAmount * (_buyLPDividendFee + _buyLPFee + _buyNodeFee) / 10000;
                isPreFee = block.number < startTradeBlock + _preFeeDuration;
                if (isPreFee) {
                    swapFeeAmount += tAmount * _preBuyFundFee / 10000;
                }
            } else if (_swapPairList[recipient]) {//Sell
                isSell = true;
                swapFeeAmount = tAmount * (_sellLPDividendFee + _sellLPFee + _sellNodeFee) / 10000;
                isPreFee = block.number < startTradeBlock + _preFeeDuration;
                if (isPreFee) {
                    swapFeeAmount += tAmount * _preSellFundFee / 10000;
                }
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = swapFeeAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }

                uint256 removeNumToSell = swapFeeAmount;
                uint256 distributorTokenBalance = _balances[address(_tokenDistributor)];
                if (removeNumToSell > distributorTokenBalance) {
                    removeNumToSell = distributorTokenBalance;
                }
                if (removeNumToSell > 0) {
                    _fundTransfer(address(_tokenDistributor), address(this), removeNumToSell, 0);
                }

                swapTokenForFund(numToSell + removeNumToSell, removeNumToSell, isPreFee);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _calRemoveFeeAmount(address sender, uint256 tAmount, uint256 removeLPLiquidity) private returns (uint256 feeAmount){
        UserInfo storage userInfo = _userInfo[tx.origin];
        uint256 selfLPAmount = userInfo.lpAmount + removeLPLiquidity - userInfo.preLPAmount;
        uint256 removeLockLPAmount = removeLPLiquidity;
        uint256 removeSelfLPAmount = removeLPLiquidity;
        if (removeLPLiquidity > selfLPAmount) {
            removeSelfLPAmount = selfLPAmount;
        }
        uint256 lpFeeAmount;
        if (removeSelfLPAmount > 0) {
            removeLockLPAmount -= removeSelfLPAmount;
            lpFeeAmount = tAmount * removeSelfLPAmount / removeLPLiquidity * _removeLPFee / 10000;
            feeAmount += lpFeeAmount;
        }
        uint256 destroyFeeAmount = tAmount * removeLockLPAmount / removeLPLiquidity;
        if (destroyFeeAmount > 0) {
            feeAmount += destroyFeeAmount;
            uint256 removeLPFeeAmount = destroyFeeAmount * _removeLPFee / 10000;
            _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount - removeLPFeeAmount);
            lpFeeAmount += removeLPFeeAmount;
        }
        if (lpFeeAmount > 0) {
            _takeTransfer(sender, address(_tokenDistributor), lpFeeAmount);
        }
        userInfo.preLPAmount -= removeLockLPAmount;
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 removeNumToSell, bool isPreFee) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 lpAmount = removeNumToSell / 2;

        uint256 fundFee = (isPreFee ? _preBuyFundFee + _preSellFundFee : 0);
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 nodeFee = _buyNodeFee + _sellNodeFee;
        uint256 totalSwapFee = fundFee + lpFee + nodeFee + _buyLPDividendFee + _sellLPDividendFee;
        lpAmount += (tokenAmount - removeNumToSell) * lpFee / totalSwapFee / 2;
        totalSwapFee -= lpFee;
        tokenAmount -= lpAmount;

        uint256 balance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        balance = address(this).balance - balance;

        uint256 lpFeeEth = balance * lpAmount / tokenAmount;
        uint256 swapFeeEth = balance - lpFeeEth;

        uint256 fundEth = swapFeeEth * fundFee / totalSwapFee;
        if (fundEth > 0) {
            payable(fundAddress).transfer(fundEth);
        }

        if (lpFeeEth > 0 && lpAmount > 0) {
            _swapRouter.addLiquidityETH{value : lpFeeEth}(address(this), lpAmount, 0, 0, Dead, block.timestamp);
        }

        uint256 cakeEth = swapFeeEth - fundEth;
        if (cakeEth > 0) {
            totalSwapFee -= fundFee;
            IERC20 Cake = IERC20(_cake);
            uint256 cakeBalance = Cake.balanceOf(address(this));
            path[0] = _weth;
            path[1] = address(Cake);
            _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : cakeEth}(
                0,
                path,
                address(this),
                block.timestamp
            );
            cakeBalance = Cake.balanceOf(address(this)) - cakeBalance;
            uint256 nodeCake = cakeBalance * nodeFee / totalSwapFee;
            if (nodeCake > 0) {
                Cake.transfer(address(_tokenDistributor), nodeCake);
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

    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setWhiteList(address addr, bool enable) external onlyWhiteList {
        _whileList[addr] = enable;
    }

    function batchSetWhiteList(address [] memory addr, bool enable) external onlyWhiteList {
        for (uint i = 0; i < addr.length; i++) {
            _whileList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function setSwapRouter(address addr, bool enable) external onlyWhiteList {
        _swapRouters[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyWhiteList {
        IERC20(token).transfer(fundAddress, amount);
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

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

    function setExcludeLPProvider(address addr, bool enable) external onlyWhiteList {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}

    function claimContractToken(address contractAddr, address token, uint256 amount) external onlyWhiteList {
        TokenDistributor(contractAddr).claimToken(token, fundAddress, amount);
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function getETHUSDTReserves() public view returns (uint256 rEth, uint256 rUsdt){
        (uint r0, uint256 r1,) = _wethUsdtPair.getReserves();
        if (_weth < _usdt) {
            rEth = r0;
            rUsdt = r1;
        } else {
            rEth = r1;
            rUsdt = r0;
        }
    }

    function getLPHolderCondition() public view returns (uint256){
        (uint256 rEth,uint256 rUsdt) = getETHUSDTReserves();
        uint256 lpEth = lpHoldCondition * rEth / rUsdt / 2;
        (rEth,) = __getReserves();
        uint256 totalLP = ISwapPair(_mainPair).totalSupply();
        return totalLP * lpEth / rEth;
    }

    uint256 public _rewardGas = 200000;
    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public progressLPRewardBlock;
    uint256 public progressLPBlockDebt = 1;
    uint256 public lpHoldCondition;
    mapping(address => uint256) public _lastLPRewardTimes;
    uint256 private constant _lpRewardTimeDebt = 1 hours;

    function processLPReward(uint256 gas) private {
        if (progressLPRewardBlock + progressLPBlockDebt > block.number) {
            return;
        }

        IERC20 Cake = IERC20(_cake);
        uint256 rewardCondition = lpRewardCondition;
        if (Cake.balanceOf(address(this)) < rewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        uint256 blockTime = block.timestamp;
        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 lpCondition = getLPHolderCondition();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder] && blockTime >= _lastLPRewardTimes[shareHolder] + _lpRewardTimeDebt) {
                pairBalance = holdToken.balanceOf(shareHolder);
                uint256 lpAmount = _userInfo[shareHolder].lpAmount;
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                }
                if (pairBalance >= lpCondition) {
                    amount = rewardCondition * pairBalance / holdTokenTotal;
                    if (amount > 0) {
                        Cake.transfer(shareHolder, amount);
                        _lastLPRewardTimes[shareHolder] = blockTime;
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
        progressLPRewardBlock = block.number;
    }

    function setLPHoldCondition(uint256 amount) external onlyWhiteList {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyWhiteList {
        lpRewardCondition = amount;
    }

    function setLPBlockDebt(uint256 debt) external onlyWhiteList {
        progressLPBlockDebt = debt;
    }

    function setLastLPRewardTime(address account, uint256 t) external onlyOwner {
        _lastLPRewardTimes[account] = t;
    }

    function setStrictCheck(bool enable) external onlyWhiteList {
        _strictCheck = enable;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _calPreList();
        _lastRebaseTime = block.timestamp;
    }

    address [] private _preList;

    function setPreList(address[] memory adrs) external onlyWhiteList {
        _preList = adrs;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount = lpAmount;
        _addLpProvider(account);
    }

    function getUserInfo(address account) public view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP, uint256 preLPAmount
    ) {
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLPAmount = userInfo.preLPAmount;
    }

    function _calPreList() private {
        uint256 balance = address(this).balance;
        if (0 == balance) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = _weth;
        path[1] = address(this);
        _swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value : balance}(
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        uint256 len = _preList.length;
        uint256 totalAmount = balanceOf(address(_tokenDistributor));
        uint256 perAmount = totalAmount / len;
        for (uint256 i; i < len;) {
            _fundTransfer(address(_tokenDistributor), _preList[i], perAmount, 0);
        unchecked{
            ++i;
        }
        }
    }

    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] && (msgSender == fundAddress || msgSender == _owner), "nw");
        _;
    }

    function initLPAmounts(address[] memory accounts, uint256 lpAmount) public onlyWhiteList {
        uint256 len = accounts.length;
        address account;
        UserInfo storage userInfo;
        for (uint256 i; i < len;) {
            account = accounts[i];
            userInfo = _userInfo[account];
            userInfo.lpAmount = lpAmount;
            userInfo.preLPAmount = lpAmount;
            _addLpProvider(account);
        unchecked{
            ++i;
        }
        }
    }

    function setCake(address cake) external onlyOwner {
        _cake = cake;
    }

    uint256 private constant _rebaseDuration = 1 hours;
    uint256 public _rebaseRate = 30;
    uint256 public _sellRate = 9;
    uint256 public _lastRebaseTime;

    function setRebaseRate(uint256 r) external onlyOwner {
        _rebaseRate = r;
    }

    function setSellRate(uint256 r) external onlyOwner {
        require(r <= _rebaseRate, "Max rebaseRate");
        _sellRate = r;
    }

    function setLastRebaseTime(uint256 t) external onlyOwner {
        _lastRebaseTime = t;
    }

    function setMinTotal(uint256 min) external onlyWhiteList {
        _minTotal = min;
    }

    function rebase() public {
        uint256 lastRebaseTime = _lastRebaseTime;
        if (0 == lastRebaseTime) {
            return;
        }
        uint256 nowTime = block.timestamp;
        if (nowTime < lastRebaseTime + _rebaseDuration) {
            return;
        }
        _lastRebaseTime = nowTime;
        address mainPair = _mainPair;
        uint256 rebaseRate = _rebaseRate;
        uint256 rebaseAmount = balanceOf(mainPair) * rebaseRate / 10000 * (nowTime - lastRebaseTime) / _rebaseDuration;
        if (rebaseAmount > 0) {
            uint256 destroyAmount = rebaseAmount;
            uint256 currentTotal = validSupply();
            uint256 maxDestroyAmount;
            if (currentTotal > _minTotal) {
                maxDestroyAmount = currentTotal - _minTotal;
            }
            if (destroyAmount > maxDestroyAmount) {
                destroyAmount = maxDestroyAmount;
            }
            if (destroyAmount > 0) {
                rebaseAmount = destroyAmount;
                _fundTransfer(mainPair, address(this), rebaseAmount, 0);
                ISwapPair(mainPair).sync();
                uint256 sellAmount = rebaseAmount * _sellRate / rebaseRate;
                _fundTransfer(address(this), address(0x000000000000000000000000000000000000dEaD), rebaseAmount - sellAmount, 0);
                if (sellAmount > 0) {
                    address[] memory path = new address[](3);
                    path[0] = address(this);
                    path[1] = _weth;
                    path[2] = _cake;
                    _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        sellAmount,
                        0,
                        path,
                        address(this),
                        block.timestamp
                    );
                    _fundTransfer(mainPair, address(0x000000000000000000000000000000000000dEaD), sellAmount, 0);
                    ISwapPair(mainPair).sync();
                }
            }
        }
    }

    address[] private _partnerList;

    function addPartner(address addr) external onlyWhiteList {
        _partnerList.push(addr);
    }

    function removePartner(address addr) external onlyWhiteList {
        uint256 len = _partnerList.length;
        for (uint256 i; i < len; ++i) {
            if (addr == _partnerList[i]) {
                _partnerList[i] = _partnerList[len - 1];
                _partnerList.pop();
                break;
            }
        }
    }

    function setPartnerList(address[] memory adrList) external onlyWhiteList {
        _partnerList = adrList;
    }

    function setPartner(uint256 i, address adr) external onlyWhiteList {
        _partnerList[i] = adr;
    }

    function getPartnerList() external view returns (address[] memory){
        return _partnerList;
    }

    uint256 public processPartnerBlock;
    uint256 public processPartnerBlockDebt = 100;
    uint256 public partnerRewardCondition;
    uint256 public currentPartnerIndex;
    mapping(address => uint256) public _lastPartnerRewardTimes;
    uint256 private constant _partnerRewardTimeDebt = 1 hours;

    function processPartnerDividend(uint256 gas) private {
        uint256 blockNum = block.number;
        if (blockNum < processPartnerBlock + processPartnerBlockDebt) {
            return;
        }
        uint256 len = _partnerList.length;
        if (0 == len) {
            return;
        }
        IERC20 Cake = IERC20(_cake);
        uint256 rewardCondition = partnerRewardCondition;
        address sender = address(_tokenDistributor);
        if (Cake.balanceOf(sender) < rewardCondition) {
            return;
        }
        uint256 perAmount = rewardCondition / len;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 blockTime = block.timestamp;

        while (gasUsed < gas && iterations < len) {
            if (currentPartnerIndex >= len) {
                currentPartnerIndex = 0;
            }
            address shareHolder = _partnerList[currentPartnerIndex];
            if (blockTime >= _lastPartnerRewardTimes[shareHolder] + _partnerRewardTimeDebt) {
                Cake.transferFrom(sender, shareHolder, perAmount);
                _lastPartnerRewardTimes[shareHolder] = blockTime;
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentPartnerIndex++;
            iterations++;
        }
        processPartnerBlock = blockNum;
    }

    function setPartnerRewardCondition(uint256 amount) external onlyWhiteList {
        partnerRewardCondition = amount;
    }

    function setProcessPartnerBlockDebt(uint256 debt) external onlyWhiteList {
        processPartnerBlockDebt = debt;
    }

    function setPartnerRewardTime(address account, uint256 t) external onlyOwner {
        _lastPartnerRewardTimes[account] = t;
    }
}

contract DragonBall is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Cake
        address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82),
    //Name
        "Dragon Ball",
    //Symbol
        "Dragon Ball",
        18,
    //Total
        10000000,
    //Receive
        address(0x88fFB46CD1dd9C0725ffe5c949886c9496aA876E),
    //Fund
        address(0x2E83f6D1F915048850FaD0454c6ecBB9B05106D5),
    //MinTotal
        10000
    ){

    }
}