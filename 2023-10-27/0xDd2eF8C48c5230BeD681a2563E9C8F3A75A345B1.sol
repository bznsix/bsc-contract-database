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
    address public _owner;
    constructor(address token1,address token2) {
        _owner = msg.sender;
        IERC20(token1).approve(msg.sender, uint256(~uint256(0)));
        IERC20(token2).approve(msg.sender, uint256(~uint256(0)));

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

contract MCH is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public lpReceiveAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;


    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public currency;
    address public MRKCAddress;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) public _rewardList;
    bool public antiSYNC = true;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public lpDistributor;

    uint256 public _buyFundFee;
    uint256 public _buyBurnFee;
    uint256 public _buyLPFee;

    uint256 public _sellFundFee;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    address[] public rewardPath;
    address[] public lpPath;
    constructor(

    ) {
        _name = "MRKCoin Cash";
        _symbol = "MCH";
        _decimals = 18;
        _tTotal = 111694 * 10**_decimals;

        fundAddress = address(0x7167cdAFeF70E7C01059F44B560b0D1075683e7F);
        lpReceiveAddress = address(0x8315611BEbfA5238dC15fC7A4278D7D0585e4B7B);
        MRKCAddress = address(0x7D7E2FBD5F62288c46e095caa2c7480B332D8919);
        _swapRouter = ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));

        currency = _swapRouter.WETH();
        address ReceiveAddress = msg.sender;
        _owner = ReceiveAddress;

        rewardPath = [address(this), currency];
        lpPath = [currency,MRKCAddress];

        IERC20(currency).approve(address(_swapRouter), MAX);
        IERC20(MRKCAddress).approve(address(_swapRouter), MAX);
        
        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;

        _buyFundFee = 400;
        _buyBurnFee = 100;
        _buyLPFee = 100;


        _sellFundFee = 600;

        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        lpDistributor = new TokenDistributor(currency,MRKCAddress);

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

    function setAntiSYNCEnable(bool s) public onlyOwner {
        antiSYNC = s;
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
        require(isReward(from) == 0, "bl");


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
                
                if (_swapPairList[to]) {
                    if (!inSwap && !isAdd) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyBurnFee +
                                _buyLPFee +_sellFundFee;
                            uint256 numTokensSellToFund = (amount * swapFee) / 5000;
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
            uint256 swapAmount;
            if (isSell) {
                swapAmount = (tAmount * _sellFundFee) / 10000;

            } else {
                swapAmount = (tAmount * (_buyFundFee + _buyLPFee + _buyBurnFee)) / 10000;
            }

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }


    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }

        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 totalFee = _buyLPFee + _buyBurnFee + fundFee;
        IERC20 Currency = IERC20(currency);
        IERC20 MRKC = IERC20(MRKCAddress);

        uint256 swapMRKCAmount = tokenAmount * (_buyLPFee +_buyLPFee)  / totalFee;
        if(swapMRKCAmount > 0){
            uint256 currencyBalanceBefore = Currency.balanceOf(address(lpDistributor));
            
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapMRKCAmount,
            0,
            rewardPath,
            address(lpDistributor),
            block.timestamp
            );
            uint256 currencyBalanceAfter = Currency.balanceOf(address(lpDistributor));
            uint256 swapedWETH = currencyBalanceAfter - currencyBalanceBefore;
            if(swapedWETH > 0){
                Currency.transferFrom(address(lpDistributor), address(this), swapedWETH);

                uint256 burnMRKC = swapedWETH * _buyLPFee /(_buyLPFee + _buyLPFee);
                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                burnMRKC,
                0,
                lpPath,
                address(0xdead),
                block.timestamp
                );

                uint256 lpMRKC = swapedWETH - burnMRKC;
                uint256 halfWETH = lpMRKC / 2;
                uint256 MRKCBalanceBefore = MRKC.balanceOf(address(lpDistributor));

                _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                halfWETH,
                0,
                lpPath,
                address(lpDistributor),
                block.timestamp
                );
                uint256 MRKCBalanceAfter = MRKC.balanceOf(address(lpDistributor));
                uint256 swapedMRKC = MRKCBalanceAfter - MRKCBalanceBefore;
                if(swapedMRKC > 0){
                    MRKC.transferFrom(address(lpDistributor), address(this), swapedMRKC);
                    _swapRouter.addLiquidity(
                        address(MRKCAddress),
                        currency,
                        swapedMRKC,
                        halfWETH,
                        0,
                        0,
                        fundAddress,
                        block.timestamp
                    );
                }


            }



        }
        

        if(tokenAmount - swapMRKCAmount > 0){
            _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount - swapMRKCAmount,
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

    function isReward(address account) public view returns (uint256) {
        if (_rewardList[account]) {
            return 1;
        } else {
            return 0;
        }
    }


    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFeeWhiteList(address  addr,bool enable) public onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBClist(address  addr,bool enable) public onlyOwner {
        _rewardList[addr] = enable;
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

    function claimContractToken(address contractAddress, address token, uint256 amount) external {
        require(fundAddress == msg.sender);
        TokenDistributor(contractAddress).claimToken(token, fundAddress, amount);
    }

    receive() external payable {}

    

    
}