// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address _spender, uint _value) external;

    function transferFrom(address _from, address _to, uint _value) external;

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

contract QJKing is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;



    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public kb;

    mapping(address => bool) public _RqList;
    mapping(address => bool) public _rewardList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _swapPairList;

    bool public antiSYNC = true;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    TokenDistributor public _rewardTokenDistributor;

    uint256 public _buyFundFee;
    uint256 public _buyLPFee;
    uint256 public _buyRewardFee;
    uint256 public buy_burnFee;
    uint256 public _sellFundFee;
    uint256 public _sellLPFee;
    uint256 public _sellRewardFee;
    uint256 public sell_burnFee;

    uint256 public addLiquidityFee;
    uint256 public removeLiquidityFee;

    uint256 public airdropNumbs;
    bool public currencyIsEth;

    address public rewardToken;
    uint256 public startTradeBlock;
    uint256 public startLPBlock = block.number;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public enableOffTrade;
    bool public enableKillBlock;

    bool public enableChangeTax;
    bool public airdropEnable;

    address[] public rewardPath;


    uint256 public unfeeAddLPTime = 1705579680;//2014-01-18 20:08:00
    address public constant QJ = 0x6743665257C429605aa344ed04dFF7A183A50296;
    constructor() {
        _name = "QJKing";
        _symbol = "QJK";

        _decimals = 18;
        _tTotal = 66000000000 * (10 ** 18);


        currency = 0x55d398326f99059fF775485246999027B3197955;
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address ReceiveAddress = 0x34f169b560FA220fE9C09d8f1d0fF0e30FFf2011;//兑换币合约
        rewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //wbnb


        enableOffTrade = true;
        enableKillBlock = true;

        currencyIsEth = false;
        airdropEnable = true;

        _owner = tx.origin;
        rewardPath = [address(this), currency];
        if (currency != rewardToken) {
            if (currencyIsEth == false) {
                rewardPath.push(_swapRouter.WETH());
            }
            if (rewardToken != _swapRouter.WETH()) rewardPath.push(rewardToken);
        }

        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;

        //兑换QJ 销毁 0.75%
        _buyFundFee = 50;
        _buyLPFee = 0;
        //兑换bnb分红1.5%
        _buyRewardFee = 150;
        //销毁1%
        buy_burnFee = 100;

        //兑换QJ 销毁 0.5%
        _sellFundFee = 50;
        _sellLPFee = 0;
        //兑换bnb分红1.5%
        _sellRewardFee = 150;

        //销毁1%
        sell_burnFee = 100;

        kb = 10;
        airdropNumbs = 1;
        require(airdropNumbs <= 5, "!<= 5");

        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);


        _RqList[ReceiveAddress] = true;
        _RqList[address(this)] = true;
        _RqList[address(_swapRouter)] = true;
        _RqList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[
        address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        holderRewardCondition = 10 ** IERC20(currency).decimals() / 10;

        _tokenDistributor = new TokenDistributor(currency);
        _rewardTokenDistributor = new TokenDistributor(rewardToken);
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
        if (account == _mainPair && msg.sender == _mainPair && antiSYNC) {
            require(_balances[_mainPair] > 0, "!sync");
        }
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
    ) public override {
        _approve(msg.sender, spender, amount);

    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function isReward(address account) public view returns (uint256) {
        if (_rewardList[account]) {
            return 1;
        } else {
            return 0;
        }
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
        (uint r0, uint256 r1,) = mainPair.getReserves();

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
        (uint r0, uint256 r1,) = mainPair.getReserves();

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
        // uint256 balance = balanceOf(from);
        require(balanceOf(from) >= amount, "balanceNotEnough");
        require(isReward(from) == 0, "isReward != 0 !");


        bool takeFee = true;
        bool isSell;
        bool isRemove;
        bool isAdd;
        if(unfeeAddLPTime < block.number && startTradeBlock == 0){
            startTradeBlock = unfeeAddLPTime;

        }

        if (_swapPairList[to]) {
            isAdd = _isAddLiquidity();

        } else if (_swapPairList[from]) {
            isRemove = _isRemoveLiquidity();

        }

        if (
            !_RqList[from] &&
        !_RqList[to] &&
        airdropEnable &&
        airdropNumbs > 0
        ) {
            address ad;
            for (uint256 i = 0; i < airdropNumbs; i++) {
                ad = address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _basicTransfer(from, ad, 1);
            }
            amount -= airdropNumbs * 1;
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_RqList[from] && !_RqList[to]) {
                if (enableOffTrade) {
                    bool star = startTradeBlock > 0;
                    require(
                        star || (0 < startLPBlock && isAdd)
                    );
                }
                if (
                    enableOffTrade &&
                    enableKillBlock &&
                    block.number < startTradeBlock + kb &&
                    !_swapPairList[to]
                ) {
                    _rewardList[to] = true;
                }

                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee +
                                        _buyRewardFee +
                                        _buyLPFee +
                                        _sellFundFee +
                                        _sellRewardFee +
                                        _sellLPFee;
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
            isAdd,
            isRemove
        );

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
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
                swapFee = _sellFundFee + _sellRewardFee + _sellLPFee;

            } else {
                swapFee = _buyFundFee + _buyLPFee + _buyRewardFee;

            }

            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
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


        if (isAdd && !_RqList[sender] && !_RqList[recipient]) {
            uint256 addLiquidityFeeAmount;
            addLiquidityFeeAmount = (tAmount * addLiquidityFee) / 10000;

            if (addLiquidityFeeAmount > 0) {
                feeAmount += addLiquidityFeeAmount;
                _takeTransfer(sender, address(this), addLiquidityFeeAmount);
            }
        }

        if (isRemove && !_RqList[sender] && !_RqList[recipient]) {
            uint256 removeLiquidityFeeAmount;
            removeLiquidityFeeAmount = (tAmount * removeLiquidityFee) / 10000;

            if (removeLiquidityFeeAmount > 0) {
                feeAmount += removeLiquidityFeeAmount;
                _takeTransfer(sender, address(this), removeLiquidityFeeAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    event Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();
    event Failed_addLiquidityETH();
    event Failed_addLiquidity();

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        if (swapFee == 0) {
            return;
        }

        uint256 rewardAmount = (tokenAmount *
            (_buyRewardFee + _sellRewardFee)) / swapFee;
        if (rewardAmount > 0) {
            try
            _swapRouter
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                rewardAmount,
                0,
                rewardPath,
                address(_rewardTokenDistributor),
                block.timestamp
            )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    0
                );
            }
        }
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = (tokenAmount * lpFee) / swapFee;

        //===================兑换qj，销毁===================
        address[] memory path2 = new address[](3);
        path2[0] = address(this);
        path2[1] = currency;
        path2[2] = QJ;

        if (currencyIsEth) {
            try
            _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount - rewardAmount,
                0,
                path2,
                address(0xdead),
                block.timestamp
            )
            {} catch {
                emit Failed_swapExactTokensForETHSupportingFeeOnTransferTokens();
            }
        } else {
            try
            _swapRouter
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount - rewardAmount,
                0,
                path2,
                address(0xdead),
                block.timestamp
            )
            {} catch {
                emit Failed_swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    1
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


    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) private holderIndex;
    mapping(address => bool) private excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
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
    uint256 public holderRewardCondition = 0.1 ether;//默认大于0.1个币
    uint256 private progressRewardBlock;
    uint256 public processRewardWaitBlock = 20;


    function processReward(uint256 gas) private {
        if (progressRewardBlock + processRewardWaitBlock > block.number) {
            return;
        }

        IERC20 FIST = IERC20(rewardToken);

        uint256 balance = FIST.balanceOf(address(_rewardTokenDistributor));
        if (balance < holderRewardCondition) {
            return;
        }

        FIST.transferFrom(
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
        balance = FIST.balanceOf(address(this));
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = (balance * tokenBalance) / holdTokenTotal;
                if (amount > 0 && FIST.balanceOf(address(this)) > amount) {
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

}
