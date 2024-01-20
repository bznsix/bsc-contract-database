//SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function burn(uint256 amount) external returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        transferOwnership(address(0));
    }

    function transferOwnership(address adr) public onlyOwner {
        require(owner != address(0), "Ownable: new owner is the zero address");
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract DollarCoin is IBEP20, Auth { using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Dollarcoin";
    string constant _symbol = "DC";
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1000000000 * (10**_decimals);
    uint256 public _maxWalletToken = _totalSupply / 1;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isMaxWalletExempt;
    
    address walletTS = 0x3976C55CF5480ab2AB00bb035885e219EA0Bd53F;
    uint256 public maximumRate = 2500;

    uint256 public liquidityBuyFee = 0;
    uint256 public marketingBuyFee = 0;
    uint256 public projectBuyFee = 0;    
    uint256 public buyfeeburn = 0;
    uint256 public BuybackBuyFee = 0;

    uint256 public totalBuyFee = 0;    
    uint256 buyFeeDenominator = 10000;

    uint256 public liquiditySellFee = 100;
    uint256 public marketingSellFee = 100;
    uint256 public projectSellFee = 0;
    uint256 public sellfeeburn = 400;
    uint256 public BuybackSellFee = 400;

    uint256 public totalSellFee = 1000;    
    uint256 sellFeeDenominator = 10000;

    uint256 liquidityTransferFee = 0;
    uint256 marketingTransferFee = 0;
    uint256 projectTransferFee = 0;

    uint256 public totalTransferFee = 0;
    uint256 TransferFeeDenominator = 10000;

    uint256 maxSwap;
    address public mktFeeReceiver;
    address public pjtFeeReceiver;

    uint256 targetLiquidity = 100;
    uint256 targetLiquidityDenominator = 100;
    IDEXRouter public router;
    address public pair;    
    uint256 public launchedAt = block.number;
    uint256 public launchedAtTimestamp = block.timestamp;

    bool public swapEnabled = true;
    bool public blockAddLiquidity = true;

    uint256 public swapThreshold = _totalSupply / 100; 
    bool inSwap;

    modifier swapping() { inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);
        address owner_ = 0x3976C55CF5480ab2AB00bb035885e219EA0Bd53F;

        isFeeExempt[owner_] = true;
        isFeeExempt[address(this)] = true;
        isMaxWalletExempt[owner_] = true;
        isMaxWalletExempt[address(this)] = true;        
        mktFeeReceiver = owner_;
        pjtFeeReceiver = owner_;

        _balances[walletTS] = _totalSupply;
        emit Transfer(address(0), walletTS, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getSellfee() external view returns (uint256) {
        uint256 tsellFee = totalSellFee/100;
        return tsellFee;
    }

    function getBuyfee() external view returns (uint256) {
        uint256 tBuyFee = totalBuyFee/100;
        return tBuyFee;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function setFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setMaxWalletExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isMaxWalletExempt[holder] = exempt;
    }

    function unblockAddLP() public onlyOwner {
        blockAddLiquidity = false;
    }    

    function setMaxWallet(uint256 amount) external onlyOwner {
        require(amount >= _totalSupply / 50);
        _maxWalletToken = amount;
    }

    function setBuyFees(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _projectFee,
        uint256 _buybackBuyFee,
        uint256 _buyfeeburn
    ) external onlyOwner {
        liquidityBuyFee = _liquidityFee;
        marketingBuyFee = _marketingFee;
        projectBuyFee = _projectFee;
        buyfeeburn = _buyfeeburn;
        BuybackBuyFee = _buybackBuyFee;
        totalBuyFee = _liquidityFee
            .add(_marketingFee)
            .add(_projectFee)
            .add(_buyfeeburn)
            .add(_buybackBuyFee);
        require(totalBuyFee + totalSellFee <= maximumRate, "Require BuyFees + SellFees <= 25%");
    }

    function setSellFees(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _projectFee,
        uint256 _sellfeeburn,
        uint256 _buybackSellFee
    ) external onlyOwner {
        liquiditySellFee = _liquidityFee;
        marketingSellFee = _marketingFee;
        projectSellFee = _projectFee;
        sellfeeburn = _sellfeeburn;
        BuybackSellFee = _buybackSellFee;
        totalSellFee = _liquidityFee
            .add(_marketingFee)
            .add(_projectFee)
            .add(_sellfeeburn)
            .add(_buybackSellFee);
        require(totalBuyFee + totalSellFee <= maximumRate, "Require BuyFees + SellFees <= 25%");
    }

    function burn(uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, DEAD, amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        
        if (
            recipient != address(this) &&
            recipient != address(DEAD) &&
            recipient != pair &&
            recipient != mktFeeReceiver &&
            !isMaxWalletExempt[recipient]
        ) {
            uint256 SendTokens = balanceOf(recipient);
            require(
                (SendTokens + amount) <= _maxWalletToken,
                "Total Holding is currently limited, you can not buy that much."
            );
        }
        if(blockAddLiquidity == true && recipient == pair){
            require(sender == owner);
        }

        if (inSwap) {
            
            return _basicTransfer(sender, recipient, amount);            
        }

        if (shouldSwapBack(recipient)) {
            swapBack(recipient == pair);
        }

        if (!launched() && recipient == pair) {
            require(_balances[sender] > 0);
        }

        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender)
            ? shouldTakeFee2(recipient)
                ? takeFee(sender, recipient, amount)
                : amount
            : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function shouldTakeFee2(address recipient) internal view returns (bool) {
        return !isFeeExempt[recipient];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        uint256 feeDenominator = selling
            ? sellFeeDenominator
            : buyFeeDenominator;
        uint256 totalFee = selling ? totalSellFee : totalBuyFee;
        if (launchedAt + 1 >= block.number) {
            return feeDenominator.sub(1);
        }
        if (selling) {
            return getMultipliedFee();
        }
        return totalFee;
    }

    function getMultipliedFee() public view returns (uint256) {
        if (launchedAtTimestamp + 1 days > block.timestamp) {
            return totalSellFee.mul(10000).div(sellFeeDenominator);
        }
        return totalSellFee;
    }    

    function takeFee(
        address sender,
        address receiver,
        uint256 amount
    ) internal returns (uint256) {
        
        bool isSenderPair = sender == pair;
        bool isReceiverPair = receiver == pair;

        if (!isSenderPair && !isReceiverPair) {
            uint256 feeAmount = amount.mul(totalTransferFee).div(
                TransferFeeDenominator
            );
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
            return amount.sub(feeAmount);
        } else {
            uint256 feeDenominator = receiver == pair
                ? sellFeeDenominator
                : buyFeeDenominator;
            uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(
                feeDenominator
            );
            uint256 feetoburn = receiver == pair ? sellfeeburn : buyfeeburn;
            uint256 amounttoburn = amount.mul(feetoburn).div(feeDenominator);
            
            uint256 feeamount2 = feeAmount.sub(amounttoburn);

            _balances[address(this)] = _balances[address(this)].add(feeamount2);
            emit Transfer(sender, address(this), feeamount2);

            _balances[DEAD] = _balances[DEAD].add(amounttoburn);
            emit Transfer(sender, DEAD, amounttoburn);

            return amount.sub(feeAmount);
        }
    }

    function shouldSwapBack(address _recip) internal view returns (bool) {
        return
            _recip == pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function swapBack(bool selling) internal swapping {
        uint256 liquidityFee = (liquiditySellFee.add(liquidityBuyFee)).div(2);
        uint256 totalFee = (totalSellFee.sub(sellfeeburn)).add(totalBuyFee.sub(buyfeeburn)).div(2);
        
        uint256 marketingFee = (marketingSellFee.add(marketingBuyFee)).div(2);
        uint256 projectFee = (projectSellFee.add(projectBuyFee)).div(2);
        uint256 buybackFee = (BuybackSellFee.add(BuybackBuyFee)).div(2); 

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator)
            ? 0
            : liquidityFee;
        uint256 amountToLiquify = balanceOf(address(this))
            .mul(dynamicLiquidityFee)
            .div(totalFee)
            .div(2);
        
        maxSwap = swapThreshold + ((swapThreshold / 100) * 30);
        uint256 amountToSwap = balanceOf(address(this)).sub(amountToLiquify) >
            maxSwap
            ? maxSwap
            : balanceOf(address(this)).sub(amountToLiquify);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);
        
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(
            totalBNBFee
        );
        uint256 amountBNBProject = amountBNB.mul(projectFee).div(totalBNBFee);
        uint256 amountBNBBuyback = amountBNB.mul(buybackFee).div(totalBNBFee);         

        if (amountBNBMarketing > 0) {
            (bool marketingSuccess, ) = payable(mktFeeReceiver).call{
                value: amountBNBMarketing,
                gas: 90000
            }("");
            require(marketingSuccess, "receiver rejected ETH transfer");
        }
        if (amountBNBProject > 0) {
            (bool projectSuccess, ) = payable(pjtFeeReceiver).call{
                value: amountBNBProject,
                gas: 90000
            }("");
            require(projectSuccess, "receiver rejected ETH transfer");
        }
        if (amountBNBBuyback > 0) {
            swapBNBForTokens(amountBNBBuyback); 
        }

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function swapBNBForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, 
            path,
            DEAD,
            block.timestamp
        );
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function setFeeReceivers(
        address _mktFeeReceiver,
        address _pjtFeeReceiver
    ) external onlyOwner {
        mktFeeReceiver = _mktFeeReceiver;
        pjtFeeReceiver = _pjtFeeReceiver;
    }

    function setSwapBackSet(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        require(_amount >= _totalSupply / 10000, "Minimum is 100,000");
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function recoverTo() external {
        uint256 contractETHBalance = address(this).balance;
        payable(pjtFeeReceiver).transfer(contractETHBalance);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}