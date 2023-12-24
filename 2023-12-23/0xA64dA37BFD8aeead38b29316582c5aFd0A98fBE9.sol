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

    function transferFrom(address _from, address _to, uint _value) external ;

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

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}
abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = address(0xe241629149EcA71675B6400b5D3b1f27E3971fB8);
        emit OwnershipTransferred(address(0), _owner);
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
contract TokenSMARS is IERC20,Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _allowedList;
    mapping(address => bool) public isMaxEatExempt;

    ISwapRouter public _swapRouter;
    address public currency;
    mapping(address => bool) public _swapPairList;
    bool allowedTrade  = true;

    uint256 private constant MAX = ~uint256(0);
    uint256 public maxWalletAmount;
    
    uint256 public _buyFundFee;
    uint256 public _buyLPFee;
    uint256 public _buyReflectFee;

    uint256 public _sellFundFee;
    uint256 public _sellLPFee;
    uint256 public _sellReflectFee;

    address public _mainPair;
    address[] public rewardPath;    
    bool private inSwap;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        _name = "SMARS";
        _symbol = "SMARS";
        _decimals = 18;
        _tTotal = 120000000* 10 **_decimals;
        _rTotal = (MAX - (MAX % _tTotal));


        fundAddress = address(0xC47b5B192957701eC339917cCAda2Ed182e16Bea);

       // _swapRouter = ISwapRouter(address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1));
         _swapRouter = ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        currency = _swapRouter.WETH();
        rewardPath = [address(this), currency];
        address ReceiveAddress = address(0x92a42eb40d85eD832291e53e34E98C2c714bBb00);

        IERC20(currency).approve(address(_swapRouter), MAX);

        _allowances[address(this)][address(_swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), currency);

        _swapPairList[_mainPair] = true;

        _buyFundFee = 100;
        _buyLPFee = 100;
        _buyReflectFee = 300;

        _sellFundFee = 100;
        _sellLPFee = 100;
        _sellReflectFee = 300;

        _rOwned[ReceiveAddress] = _rTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[_owner] = true;

        maxWalletAmount = 200000 * 10 **_decimals;
        isMaxEatExempt[_owner] = true;
        isMaxEatExempt[fundAddress] = true;
        isMaxEatExempt[ReceiveAddress] = true;
        isMaxEatExempt[address(_swapRouter)] = true;
        isMaxEatExempt[address(_mainPair)] = true;
        isMaxEatExempt[address(this)] = true;
        isMaxEatExempt[address(0xdead)] = true;

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
        return tokenFromReflection(_rOwned[account]);
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
    ) public override  {
        _approve(msg.sender, spender, amount);
        
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override  {
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

    function _transfer(address from, address to, uint256 amount) private {
        require(balanceOf(from) >= amount, "balanceNotEnough");


        bool takeFee;
        bool isSell;


        if (_swapPairList[from] || _swapPairList[to]) {
            if(allowedTrade){
                if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                    takeFee = true; // just swap fee
                }
            if (_swapPairList[to]) {
                if (!inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    uint256 swapFee = _buyFundFee +
                        _buyLPFee +
                        _sellFundFee +
                        _sellLPFee;
                    if (contractTokenBalance > 0) {
                        uint256 numTokensSellToFund = (amount.mul(swapFee)).div(5000);
                        if (numTokensSellToFund > contractTokenBalance) {
                            numTokensSellToFund = contractTokenBalance;
                        }
                        swapTokenForFund(numTokensSellToFund,swapFee);
                    }
                }
            }
            }else{
                require(_allowedList[from] || _allowedList[to]);
                takeFee = true;
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
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        uint256 swapFee;
        if (takeFee) {
            uint256 swapAmount;
            if (isSell) {
                swapFee = _sellFundFee +_sellLPFee +_sellReflectFee;

                swapAmount = tAmount.div(10000).mul(_sellFundFee +_sellLPFee);
                if(swapAmount >0){
                    _takeTransfer(
                        sender,
                        address(this),
                        swapAmount,
                        currentRate
                    );
                }
                if(_sellReflectFee >0){
                    _reflectFee(rAmount.div(10000).mul(_sellReflectFee), tAmount.div(10000).mul(_sellReflectFee));
                }
                

            } else {
                swapFee = _buyFundFee +_buyLPFee +_buyReflectFee;

                swapAmount = tAmount.div(10000).mul(_buyFundFee +_buyLPFee );
                if(swapAmount >0){
                    _takeTransfer(
                        sender,
                        address(this),
                        swapAmount,
                        currentRate
                    );
                }
                if(_buyReflectFee>0){
                    _reflectFee(rAmount.div(10000).mul(_buyReflectFee), tAmount.div(10000).mul(_buyReflectFee));
                }

            }

        }
        uint256 recipientRate = 10000 - swapFee ;
        uint256 temrOwned = _rOwned[recipient].add(rAmount.div(10000).mul(recipientRate));
        if (!isMaxEatExempt[recipient] )
            require(
                tokenFromReflection(temrOwned) <= maxWalletAmount,
                "over limit"
            );


        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(10000).mul(recipientRate)
            );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

    event Failed_swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 value
    );
    event Failed_addLiquidityETH();

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 swapFee
    ) private lockTheSwap {
        uint256 swapAmount = tokenAmount.mul((_buyFundFee.add(_sellFundFee)) + (_buyLPFee.add(_sellLPFee)).div(2)).div(swapFee);
        uint256 lpAmount = tokenAmount.sub(swapAmount);
        uint256 balanceBefore = address(this).balance;
        try
            _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapAmount,
                0,
                rewardPath,
                address(this),
                block.timestamp
            )
        {} catch {
            emit Failed_swapExactTokensForETHSupportingFeeOnTransferTokens(swapAmount);
        }
        uint256 balanceAfter = address(this).balance;
        uint256 swapedETH = balanceAfter.sub(balanceBefore);
        if(swapedETH >0){
            uint256 fundETH = swapedETH.mul((_buyFundFee.add(_sellFundFee))).div((_buyFundFee.add(_sellFundFee)) + (_buyLPFee.add(_sellLPFee)).div(2));
            if(fundETH> 0){
                payable(fundAddress).transfer(fundETH);
            }
            uint256 lpETH = swapedETH.sub(fundETH);
            try
                _swapRouter.addLiquidityETH{value: lpETH}(
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
        
    }
    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function _getRate() public view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }


    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
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

    event Received(address sender, uint256 amount);
    receive() external payable {
        uint256 receivedAmount = msg.value;
        emit Received(msg.sender, receivedAmount);
    }

    function setFeeWhiteList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }
    function setAllowedList(
        address[] calldata addr,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addr.length; i++) {
            _allowedList[addr[i]] = enable;
        }
    }

    function setTradeMode(bool enable) external onlyOwner {
        allowedTrade = enable;
    }

    function setSellFundFee(uint256 sellFundFee) external onlyOwner {
        _sellFundFee= sellFundFee;
    }

    function changeWalletLimit(uint256 _amount) external onlyOwner {
        maxWalletAmount = _amount;
    }
    function setisMaxEatExempt(address holder, bool exempt) external onlyOwner {
        isMaxEatExempt[holder] = exempt;
    }
}