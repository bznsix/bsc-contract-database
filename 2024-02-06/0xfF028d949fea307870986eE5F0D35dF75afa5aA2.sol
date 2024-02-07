// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);


    function totalSupply() external view returns (uint256);

 
    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function skim(address to) external;
    
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



contract Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _decimals;


    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;

    address public _mainPair;
    uint256 public lastLpBurnTime;
    uint256 public lpBurnFrequency;

    address public fundAddress;
    address public lpAddress;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    address[] public rewardPath;
    uint256 private constant MAX = ~uint256(0);
    
    uint256 public _buyFundFee = 200;
    uint256 public _buyLPFee = 200;

    uint256 public _sellFundFee = 300;
    uint256 public _sellLPFee = 200;
    
    uint256 public startTradeBlock;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        _name = unicode"China年";
        _symbol = unicode"China年";
        _decimals = 18;
        _tTotal = 10000000000000000000 * 10**_decimals;

        fundAddress = address(0x8Df6aEcB7cCEEfB47342b5e6857AD591015F891d);
        lpAddress = address(0x5477aE2220EBD159a55E5D08066a2E52bD535361);
        _swapRouter = ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        currency = _swapRouter.WETH();
        address ReceiveAddress = address(0xdBF0b58766835df509d5E5D00867B850217173fC);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;
        rewardPath = [address(this), currency];

        lpBurnFrequency = 3600;

        _owner = fundAddress;
        
        _swapPairList[_mainPair] = true;
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[lpAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

    }

    function symbol() external view  returns (string memory) {
        return _symbol;
    }

    function name() external view  returns (string memory) {
        return _name;
    }

    function decimals() external view  returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view  returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view  returns (uint256) {
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
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
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

        require(balanceOf(from) >= amount, "balanceNotEnough");


        bool takeFee;
        bool isSell;
        bool isRemove;
        bool isAdd;

        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();

        } else if (_swapPairList[from]) {
            isRemove = _isRemoveLiquidity();

        }
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                bool star = startTradeBlock > 0;
                require(star || isAdd);

                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        if (block.timestamp >= lastLpBurnTime + lpBurnFrequency ) {
                            autoBurnLiquidityPairTokens();
                        
                        }else{
                            uint256 contractTokenBalance = balanceOf(address(this));
                            if (contractTokenBalance > 0) {
                                uint256 swapFee = _buyLPFee + _buyFundFee + _sellLPFee + _sellFundFee;
                                uint256 numTokensSellToFund = (amount * swapFee) /
                                    5000;
                                if (numTokensSellToFund > contractTokenBalance) {
                                    numTokensSellToFund = contractTokenBalance;
                                }
                                swapTokenForFund(numTokensSellToFund, swapFee);
                            }
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
            isSell
        );


    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPFee ;

            } else {
                swapFee = _buyFundFee + _buyLPFee;

            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

        }


        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }


    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_addLiquidityETH();


    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        if (swapFee == 0) {
            return;
        }
        uint256 lpFee = _buyLPFee + _sellLPFee ;
        swapFee += swapFee;
        uint256 lpAmount = (tokenAmount *lpFee)  / swapFee;
        if (lpAmount > 0) {
            try
                _swapRouter
                    .swapExactTokensForETHSupportingFeeOnTransferTokens(
                        tokenAmount - lpAmount,
                        0,
                        rewardPath,
                        address(this),
                        block.timestamp
                    )
            {} catch {
                emit Failed_swapExactTokensForETHSupportingFeeOnTransferTokens(
                    0
                );
            }
        }

        uint256 ethBalance;
        uint256 lpFist;
        uint256 fundAmount;

        ethBalance = address(this).balance;
        lpFist = (ethBalance * lpFee ) / swapFee;
        fundAmount = ethBalance - lpFist;
        if (fundAmount > 0 && fundAddress != address(0)) {
            payable(fundAddress).transfer(fundAmount);
        }
        // add the liquidity
        try
            _swapRouter.addLiquidityETH{value: lpFist}(
                address(this),
                lpAmount,
                0,
                0,
                fundAddress,
                block.timestamp
            )
        {} catch {
            emit Failed_addLiquidityETH();
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

    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    receive() external payable {}

    event AutoNukeLP();

    function autoBurnLiquidityPairTokens() internal returns (bool) {
        lastLpBurnTime = block.timestamp;

        // get balance of liquidity pair
        uint256 liquidityPairBalance = balanceOf(_mainPair);

        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance  / 100;

        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            _basicTransfer(
            _mainPair,
            address(0xdead),
            amountToBurn
        );
        }

        //sync price since this is not in a swap transaction!
        ISwapPair pair = ISwapPair(_mainPair);
        pair.sync();
        emit AutoNukeLP();
        return true;
    }




    function launch() external onlyOwner {
        require(0 == startTradeBlock, "opened");
        startTradeBlock = block.number;
        lastLpBurnTime = block.timestamp;
    }
}