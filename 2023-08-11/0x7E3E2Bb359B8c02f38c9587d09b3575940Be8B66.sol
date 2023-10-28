{"Address.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nlibrary Address {\n\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n}\n"},"Context.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        return msg.data;\n    }\n}\n"},"DOGE.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.7;\n\nimport \"./Address.sol\";\nimport \"./Context.sol\";\nimport \"./Ownable.sol\";\nimport \"./IERC20.sol\";\nimport \"./IFactory.sol\";\nimport \"./IRouter.sol\";\n\ncontract BabyFloki is Context, Ownable, IERC20 {\n    using Address for address;\n    using Address for address payable;\n\n    mapping (address =\u003e uint256) private _rOwned;\n    mapping (address =\u003e uint256) private _tOwned;\n    mapping (address =\u003e mapping (address =\u003e uint256)) private _allowances;\n\n    mapping(address =\u003e bool) private _isBadActor;\n\n\n    mapping (address =\u003e bool) private _isExcludedFromFee;\n\n\n    mapping (address =\u003e bool) private _isExcluded;\n    address[] private _excluded;\n\n    uint256 private constant MAX = ~uint256(0);\n    uint256 private _tTotal = 500000 * (10**6 * 10**9);   // (*) = million tokens\n    uint256 private _rTotal = (MAX - (MAX % _tTotal));\n    uint256 private _tFeeTotal;\n\n\n    string private _name = \"Baby Floki Coin\";\n    string private _symbol = \"BabyFloki\";\n    uint8 private _decimals = 9;\n\n    uint256 internal MAX_INT = 2**256 - 1;\n\n    struct feeRatesStruct {\n        uint256 taxFee;\n        uint256 marketingFee;\n        uint256 rewardsFee;\n        uint256 liquidityFee;\n        uint256 swapFee;\n        uint256 totFees;\n    }\n\n    feeRatesStruct public buyFees = feeRatesStruct(\n    {taxFee: 2000,\n    marketingFee: 2000,\n    rewardsFee: 2000,\n    liquidityFee: 4000,\n    swapFee: 8000, // marketingFee+rewardsFee+liquidityFee\n    totFees: 0\n    });\n\n    feeRatesStruct public sellFees = feeRatesStruct(\n    {taxFee: 1432,\n    marketingFee: 1428,\n    rewardsFee: 2856,\n    liquidityFee: 4284,\n    swapFee: 8568, // marketingFee+rewardsFee+liquidityFee\n    totFees: 1\n    });\n\n    feeRatesStruct private appliedFees = buyFees; //default value\n    feeRatesStruct private previousFees;\n\n    struct valuesFromGetValues{\n        uint256 rAmount;\n        uint256 rTransferAmount;\n        uint256 rFee;\n        uint256 rSwap;\n        uint256 tTransferAmount;\n        uint256 tFee;\n        uint256 tSwap;\n    }\n\n    // MAIN\n    address payable public marketingWallet = payable(0x1B22C88937F18177d4e170e7a7661D17dD062aA6);\n    address payable public rewardsWallet = payable(0x1B22C88937F18177d4e170e7a7661D17dD062aA6);\n\n    //DEV\n    //address payable public marketingWallet = payable(0x7EE536e1FC3638EAdF5be06E8dCC562BDccBc340);\n    //address payable public rewardsWallet = payable(0x8400be10F230dE2E371224512153e6AC79d7eee8);\n\n\n\n    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);\n    address private deployerAddress = address(0x0000000000000000000000000000000000000000);\n\n    IRouter public pancakeRouter;\n    address public pancakePair;\n\n    bool internal inSwap;\n    bool public swapEnabled = true;\n    uint256 private minTokensToSwap = _tTotal/1000000; // 0.1%\n    uint256 public maxTxAmount = _tTotal/200000;\n    uint256 public maxWalletTokens = _tTotal/10000;\n\n\n    event swapEnabledUpdated(bool enabled);\n    event distributeThresholdPass(uint256 number);\n\n    modifier lockTheSwap {\n        inSwap = true;\n        _;\n        inSwap = false;\n    }\n\n    constructor () {\n        _rOwned[_msgSender()] = _rTotal;\n        _tOwned[_msgSender()] = _tTotal;\n\n\n        IRouter _pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);\n        //IRouter _pancakeRouter = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);   // Testnet\n        // Create a uniswap pair for this new token\n        pancakePair = IFactory(_pancakeRouter.factory())\n        .createPair(address(this), _pancakeRouter.WETH());\n\n        // set the rest of the contract variables\n        pancakeRouter = _pancakeRouter;\n\n        //exclude owner and this contract from fee\n        _isExcludedFromFee[owner()] = true;\n        _isExcludedFromFee[marketingWallet] = true;\n        _isExcludedFromFee[rewardsWallet] = true;\n        _isExcludedFromFee[address(this)] = true;\n\n        emit Transfer(address(0), _msgSender(), _tTotal);\n    }\n\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n\n    function decimals() public view returns (uint8) {\n        return _decimals;\n    }\n\n\n    function totalSupply() public view override returns (uint256) {\n        return _tTotal;\n    }\n\n\n    function balanceOf(address account) public view override returns (uint256) {\n        if (_isExcluded[account]) return _tOwned[account];\n        return tokenFromReflection(_rOwned[account]);\n    }\n\n\n    function transfer(address recipient, uint256 amount) public override returns (bool) {\n        _transfer(_msgSender(), recipient, amount);\n        return true;\n    }\n\n\n    function allowance(address owner, address spender) public view override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n\n    function approve(address spender, uint256 amount) public override returns (bool) {\n        _approve(_msgSender(), spender, amount);\n        return true;\n    }\n\n\n    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {\n        _transfer(sender, recipient, amount);\n\n        uint256 currentAllowance = _allowances[sender][_msgSender()];\n        require(currentAllowance \u003e= amount, \"ERC20: transfer amount exceeds allowance\");\n    unchecked {\n        _approve(sender, _msgSender(), currentAllowance - amount);\n    }\n\n        return true;\n    }\n\n\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);\n        return true;\n    }\n\n\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        uint256 currentAllowance = _allowances[_msgSender()][spender];\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\n    unchecked {\n        _approve(_msgSender(), spender, currentAllowance - subtractedValue);\n    }\n\n        return true;\n    }\n\n\n    function isExcludedFromReward(address account) public view returns (bool) {\n        return _isExcluded[account];\n    }\n\n\n    function totalFeesCharged() public view returns (uint256) {\n        return _tFeeTotal;\n    }\n\n\n    function deliver(uint256 tAmount) public {\n        address sender = _msgSender();\n        require(!_isExcluded[sender], \"Excluded addresses cannot call this function\");\n        valuesFromGetValues memory s = _getValues(tAmount, false);\n        _rOwned[sender] -= s.rAmount;\n        _rTotal -= s.rAmount;\n        _tFeeTotal += tAmount;\n    }\n\n\n    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {\n        require(tAmount \u003c= _tTotal, \"Amount must be less than supply\");\n        if (!deductTransferFee) {\n            valuesFromGetValues memory s = _getValues(tAmount, false);\n            return s.rAmount;\n        } else {\n            valuesFromGetValues memory s = _getValues(tAmount, true);\n            return s.rTransferAmount;\n        }\n    }\n\n\n    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {\n        require(rAmount \u003c= _rTotal, \"Amount must be less than total reflections\");\n        uint256 currentRate =  _getRate();\n        return rAmount/currentRate;\n    }\n\n\n    function excludeFromReward(address account) public onlyOwner() {\n        require(!_isExcluded[account], \"Account is already excluded\");\n        if(_rOwned[account] \u003e 0) {\n            _tOwned[account] = tokenFromReflection(_rOwned[account]);\n        }\n        _isExcluded[account] = true;\n        _excluded.push(account);\n    }\n\n    function excludeFromReward(address[] memory accounts) public onlyOwner() {\n        uint256 length = accounts.length;\n        for(uint256 i=0;i\u003clength;i++)\n        {\n            require(!_isExcluded[accounts[i]], \"Account is already excluded\");\n            if(_rOwned[accounts[i]] \u003e 0) {\n                _tOwned[accounts[i]] = tokenFromReflection(_rOwned[accounts[i]]);\n            }\n            _isExcluded[accounts[i]] = true;\n            _excluded.push(accounts[i]);\n        }\n    }\n\n\n    function includeInReward(address account) external onlyOwner() {\n        require(_isExcluded[account], \"Account is already excluded\");\n        for (uint256 i = 0; i \u003c _excluded.length; i++) {\n            if (_excluded[i] == account) {\n                _excluded[i] = _excluded[_excluded.length - 1];\n                _tOwned[account] = 0;\n                _isExcluded[account] = false;\n                _excluded.pop();\n                break;\n            }\n        }\n    }\n\n    function excludeFromFee(address account) public onlyOwner {\n        _isExcludedFromFee[account] = true;\n    }\n\n    function includeInFee(address account) public onlyOwner {\n        _isExcludedFromFee[account] = false;\n    }\n\n    //to receive ETH from pancakeRouter when swaping\n    receive() external payable {}\n\n\n    function _reflectFee(uint256 rFee, uint256 tFee) private {\n        _rTotal     = _rTotal-rFee;\n        _tFeeTotal  = _tFeeTotal+tFee;\n    }\n\n\n    function _getValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory to_return) {\n        to_return = _getTValues(tAmount, takeFee);\n        (to_return.rAmount, to_return.rTransferAmount, to_return.rFee, to_return.rSwap) = _getRValues(to_return,tAmount, takeFee, _getRate());\n        return to_return;\n    }\n\n\n    function _getTValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory s) {\n        if(!takeFee) {\n            s.tTransferAmount = tAmount;\n            return s;\n        }\n        s.tFee = tAmount*appliedFees.totFees*appliedFees.taxFee/1000000;\n        s.tSwap = tAmount*appliedFees.totFees*appliedFees.swapFee/1000000;\n        s.tTransferAmount = tAmount-s.tFee-s.tSwap;\n        return s;\n    }\n\n\n    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256, uint256, uint256, uint256) {\n        uint256 rAmount = tAmount*currentRate;\n        if(!takeFee)\n        {\n            return (rAmount,rAmount,0,0);\n        }\n        uint256 rFee = s.tFee*currentRate;\n        uint256 rSwap = s.tSwap*currentRate;\n        uint256 rTransferAmount = rAmount-rFee-rSwap;\n        return (rAmount, rTransferAmount, rFee, rSwap);\n    }\n\n\n    function _getRate() private view returns(uint256) {\n        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();\n        return rSupply/tSupply;\n    }\n\n\n    function _getCurrentSupply() private view returns(uint256, uint256) {\n        uint256 rSupply = _rTotal;\n        uint256 tSupply = _tTotal;\n        uint256 length = _excluded.length;\n        for (uint256 i = 0; i \u003c length; i++) {\n            if (_rOwned[_excluded[i]] \u003e rSupply || _tOwned[_excluded[i]] \u003e tSupply) return (_rTotal, _tTotal);\n            rSupply -=_rOwned[_excluded[i]];\n            tSupply -=_tOwned[_excluded[i]];\n        }\n        if (rSupply \u003c _rTotal/_tTotal) return (_rTotal, _tTotal);\n        return (rSupply, tSupply);\n    }\n\n    function _takeSwapFees(uint256 rSwap, uint256 tSwap) private {\n\n        _rOwned[address(this)] +=rSwap;\n        if(_isExcluded[address(this)])\n            _tOwned[address(this)] +=tSwap;\n    }\n\n\n    //////////////////////////\n    /// Setters functions  ///\n    //////////////////////////\n\n    function setMarketingWallet(address payable _address) external onlyOwner returns (bool){\n        marketingWallet = _address;\n        _isExcludedFromFee[marketingWallet] = true;\n        return true;\n    }\n\n    function setRewardsWallet(address payable _address) external onlyOwner returns (bool){\n        rewardsWallet = _address;\n        _isExcludedFromFee[rewardsWallet] = true;\n        return true;\n    }\n\n    function setDeployerAddress(address payable _address) external onlyOwner returns (bool){\n        deployerAddress = _address;\n        _isExcludedFromFee[deployerAddress] = true;\n        return true;\n    }\n\n    function setBuyFees(uint256 taxFee, uint256 marketingFee, uint256 rewardsFee, uint256 liquidityFee) external onlyOwner{\n        buyFees.taxFee = taxFee;\n        buyFees.marketingFee = marketingFee;\n        buyFees.rewardsFee = rewardsFee;\n        buyFees.liquidityFee = liquidityFee;\n        buyFees.swapFee = marketingFee+rewardsFee+liquidityFee;\n        require(buyFees.swapFee+buyFees.taxFee == 10000, \"sum of all percentages should be 10000\");\n    }\n\n    function setSellFees(uint256 sellTaxFee, uint256 sellMarketingFee, uint256 sellRewardsFee, uint256 sellLiquidityFee) external onlyOwner{\n        sellFees.taxFee = sellTaxFee;\n        sellFees.marketingFee = sellMarketingFee;\n        sellFees.rewardsFee = sellRewardsFee;\n        sellFees.liquidityFee = sellLiquidityFee;\n        sellFees.swapFee = sellMarketingFee+sellRewardsFee+sellLiquidityFee;\n        require(sellFees.swapFee+sellFees.taxFee == 10000, \"sum of all percentages should be 10000\");\n    }\n\n    function setTotalBuyFees(uint256 _totFees) external onlyOwner{\n        buyFees.totFees = _totFees;\n    }\n\n    function setTotalSellFees(uint256 _totSellFees) external onlyOwner{\n        sellFees.totFees = _totSellFees;\n    }\n\n    function setSwapEnabled(bool _enabled) public onlyOwner {\n        swapEnabled = _enabled;\n        emit swapEnabledUpdated(_enabled);\n    }\n\n    function setNumTokensToSwap(uint256 amount) external onlyOwner{\n        minTokensToSwap = amount * 10**9;\n    }\n\n    function setMaxTxAmount(uint256 amount) external onlyOwner{\n        maxTxAmount = amount * 10**9;\n    }\n\n    function setMaxWalletAmount(uint256 amount) external onlyOwner{\n        maxWalletTokens = amount * 10**9;\n    }\n\n    function isExcludedFromFee(address account) public view returns(bool) {\n        return _isExcludedFromFee[account];\n    }\n\n\n    function _approve(address owner, address spender, uint256 amount) private {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    function _transfer(\n        address from,\n        address to,\n        uint256 amount\n    ) private {\n        require(from != address(0), \"ERC20: transfer from the zero address\");\n        require(to != address(0), \"ERC20: transfer to the zero address\");\n        require(amount \u003e 0, \"Transfer amount must be greater than zero\");\n        require(!_isBadActor[from] \u0026\u0026 !_isBadActor[to], \"Bots are not allowed\");\n\n        if( to != address(pancakeRouter) \u0026\u0026 to != deadAddress \u0026\u0026 !_isExcludedFromFee[from] \u0026\u0026 !_isExcludedFromFee[to] ) {\n            require(amount \u003c= maxTxAmount, \u0027You are exceeding maxTxAmount\u0027);\n        }\n\n        if( to != owner() \u0026\u0026\n        to != address(this) \u0026\u0026\n        to != pancakePair \u0026\u0026\n        to != marketingWallet \u0026\u0026\n        to != rewardsWallet \u0026\u0026\n        to != deadAddress \u0026\u0026\n        to != address(pancakeRouter) \u0026\u0026\n            to != deployerAddress ){\n            uint256 heldTokens = balanceOf(to);\n            require((heldTokens + amount) \u003c= maxWalletTokens, \"Total Holding is currently limited, you can not hold that much.\");\n        }\n\n        uint256 contractTokenBalance = balanceOf(address(this));\n\n        bool overMinTokenBalance = contractTokenBalance \u003e= minTokensToSwap;\n        if (\n            overMinTokenBalance \u0026\u0026\n            !inSwap \u0026\u0026\n            from != pancakePair \u0026\u0026\n            swapEnabled\n        ) {\n            emit distributeThresholdPass(contractTokenBalance);\n            contractTokenBalance = minTokensToSwap;\n            swapAndSendToFees(contractTokenBalance);\n        }\n\n        //indicates if fee should be deducted from transfer\n        bool takeFee = true;\n        bool isSale = false;\n\n        //if any account belongs to _isExcludedFromFee account then remove the fee\n        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){\n            takeFee = false;\n        } else\n        {\n            if(to == pancakePair){\n                isSale = true;\n            }\n        }\n\n        // transfer amount, it will take tax, burn, liquidity fee\n        _tokenTransfer(from,to,amount,takeFee,isSale);\n    }\n\n    function swapAndSendToFees(uint256 tokens) private lockTheSwap {\n        uint256 tokensForLiquidity = tokens*appliedFees.liquidityFee/appliedFees.swapFee;               //TODO: Check Safemath\n        uint256 initialBalance = address(this).balance;                                                 // Balance of BNB\n        swapTokensForBNB(tokens - tokensForLiquidity/2);                                                //TODO: Check Safemath\n        uint256 transferBalance = address(this).balance-initialBalance;                                 // Check the new balance of BNB\n        rewardsWallet.sendValue(transferBalance*appliedFees.rewardsFee/appliedFees.swapFee);\n        marketingWallet.sendValue(transferBalance*appliedFees.marketingFee/appliedFees.swapFee);\n        addLiquidity(tokensForLiquidity/2,address(this).balance);\n    }\n\n\n    function swapTokensForBNB(uint256 tokenAmount) private {\n\n        // generate the pancakeswap pair path of token -\u003e wbnb\n        address[] memory path = new address[](2);\n        path[0] = address(this);\n        path[1] = pancakeRouter.WETH();\n\n        if(allowance(address(this), address(pancakeRouter)) \u003c tokenAmount) {\n            _approve(address(this), address(pancakeRouter), ~uint256(0));\n        }\n\n        // make the swap\n        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(\n            tokenAmount,\n            0, // accept any amount of BNB\n            path,\n            address(this),\n            block.timestamp\n        );\n    }\n\n    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {\n        // Approve token transfer to cover all possible scenarios\n        _approve(address(this), address(pancakeRouter), tokenAmount);\n        // Add the liquidity\n        pancakeRouter.addLiquidityETH{value: bnbAmount}(\n            address(this),\n            tokenAmount,\n            0, // Slippage is unavoidable\n            0, // Slippage is unavoidable\n            owner(),\n            block.timestamp\n        );\n    }\n\n\n    // this method is responsible for taking all fee, if takeFee is true\n    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, bool isSale) private {\n        if(takeFee){\n            if(isSale)\n            {\n                appliedFees = sellFees;\n            }\n            else\n            {\n                appliedFees = buyFees;\n            }\n        }\n\n        valuesFromGetValues memory s = _getValues(amount, takeFee);\n\n        if (_isExcluded[sender]) {\n            _tOwned[sender] -=amount;\n        }\n        if (_isExcluded[recipient]) {\n            _tOwned[recipient] += s.tTransferAmount;\n        }\n        _rOwned[sender] -= s.rAmount;\n        _rOwned[recipient] +=s.rTransferAmount;\n\n        if(takeFee)\n        {\n            _takeSwapFees(s.rSwap,s.tSwap);\n            _reflectFee(s.rFee, s.tFee);\n            emit Transfer(sender, address(this), s.tSwap);\n        }\n        emit Transfer(sender, recipient, s.tTransferAmount);\n    }\n\n    //////////////////////////\n    /// Emergency functions //\n    //////////////////////////\n\n\n    function rescueBNBFromContract() external onlyOwner {\n        address payable _owner = payable(msg.sender);\n        _owner.transfer(address(this).balance);\n    }\n\n    function manualSwap() external onlyOwner lockTheSwap {\n        uint256 tokensToSwap = balanceOf(address(this));\n        swapTokensForBNB(tokensToSwap);\n    }\n\n    function manualSend() external onlyOwner{\n        swapAndSendToFees(balanceOf(address(this)));\n    }\n\n\n    // To be used for snipe-bots and bad actors communicated on with the community.\n    function badActorDefenseMechanism(address account, bool isBadActor) external onlyOwner{\n        _isBadActor[account] = isBadActor;\n    }\n\n    function checkBadActor(address account) public view returns(bool){\n        return _isBadActor[account];\n    }\n\n    function setRouterAddress(address newRouter) external onlyOwner {\n        require(address(pancakeRouter) != newRouter, \u0027Router already set\u0027);\n        //give the option to change the router down the line\n        IRouter _newRouter = IRouter(newRouter);\n        address get_pair = IFactory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());\n        //checks if pair already exists\n        if (get_pair == address(0)) {\n            pancakePair = IFactory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());\n        }\n        else {\n            pancakePair = get_pair;\n        }\n        pancakeRouter = _newRouter;\n    }\n\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\ninterface IERC20 {\n\n\n    function totalSupply() external view returns (uint256);\n\n\n    function balanceOf(address account) external view returns (uint256);\n\n\n    function transfer(address recipient, uint256 amount) external returns (bool);\n\n\n    function allowance(address owner, address spender) external view returns (uint256);\n\n\n    function approve(address spender, uint256 amount) external returns (bool);\n\n\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}"},"IFactory.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface IFactory{\n    function createPair(address tokenA, address tokenB) external returns (address pair);\n    function getPair(address tokenA, address tokenB) external view returns (address pair);\n}\n"},"IRouter.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\ninterface IRouter {\n    function factory() external pure returns (address);\n    function WETH() external pure returns (address);\n    function addLiquidityETH(\n        address token,\n        uint amountTokenDesired,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\n\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline) external;\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\n\nabstract contract Ownable is Context {\n    address private _owner;\n\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}"}}