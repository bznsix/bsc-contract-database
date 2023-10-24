// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.19;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract EarnSphere is Context, IBEP20, Ownable {
    using Address for address payable;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping (address => bool) private _isBot;

    address[] private _excluded;

    bool public tradingEnabled;
    bool public swapEnabled;
    bool private swapping;

    //Anti Dump
    mapping(address => uint256) private _lastSell;

    IRouter public router;
    address public pair;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 864834758 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public swapTokensAtAmount = 500000 * 10**_decimals;

    uint256 public genesis_block;
    uint256 private deadline = 1;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public nftWallet = 0x6ED33b9Fe7EB1d500afC3BDB196A0015E9CFB4C3;
    address private treasuryWallet = 0x1aaE66E0e40cd1c4b4bBFca06Eda7032f94d42FC;
    address private dlcsWallet = 0xfbA2AD53b8F159018f4871F8810aEa71182b53c8;

    string private constant _name = "Earn Sphere";
    string private constant _symbol = "$ES";

    struct Taxes {
        uint256 rfi;
        uint256 nft;
        uint256 treasury;
        uint256 liquidity;
        uint256 dlcs;
    }

    Taxes public taxes = Taxes(20, 10, 60, 20, 40);
    Taxes public sellTaxes = Taxes(20, 10, 60, 20, 60);
    Taxes private launchtax = Taxes(0, 0, 990, 0, 0);

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 nft;
        uint256 treasury;
        uint256 liquidity;
        uint256 dlcs;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rNft;
        uint256 rTreasury;
        uint256 rLiquidity;
        uint256 rDlcs;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tNft;
        uint256 tTreasury;
        uint256 tLiquidity;
        uint256 tDlcs;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);
    event TradingEnabled(uint256 startDate);

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor(address routerAddress) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;

        excludeFromReward(pair);
        excludeFromReward(deadWallet);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[nftWallet] = true;
        _isExcludedFromFee[treasuryWallet] = true;
        _isExcludedFromFee[dlcsWallet] = true;
        _isExcludedFromFee[deadWallet] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    //std BEP20:
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override BEP20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rTransferAmount;
        }
    }

    function EnableTrading() external onlyOwner {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
        swapEnabled = true;
        genesis_block = block.number;
        emit TradingEnabled(block.timestamp);
    }

    function updatedeadline(uint256 _deadline) external onlyOwner {
        require(!tradingEnabled, "Can't change when trading has started");
        require(_deadline < 5,"Deadline should be less than 5 Blocks");
        deadline = _deadline;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //@dev kept original RFI naming -> "reward" as in reflection
    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -= rRfi;
        totFeesPaid.rfi += tRfi;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity += tLiquidity;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tLiquidity;
        }
        _rOwned[address(this)] += rLiquidity;
    }

    function _takeNft(uint256 rNft, uint256 tNft) private {
        totFeesPaid.nft += tNft;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tNft;
        }
        _rOwned[address(this)] += rNft;
    }

    function _takeTreasury(uint256 rTreasury, uint256 tTreasury) private {
        totFeesPaid.treasury += tTreasury;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tTreasury;
        }
        _rOwned[address(this)] += rTreasury;
    }

    function _takeDlcs(uint256 rDlcs, uint256 tDlcs) private {
        totFeesPaid.dlcs += tDlcs;

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tDlcs;
        }
        _rOwned[address(this)] += rDlcs;
    }

    function _getValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool useLaunchTax
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell, useLaunchTax);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rNft,
            to_return.rLiquidity
        ) = _getRValues1(to_return, tAmount, takeFee, _getRate());
        (to_return.rDlcs, to_return.rTreasury) = _getRValues2(
            to_return,
            takeFee,
            _getRate()
        );

        return to_return;
    }

    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool useLaunchTax
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        Taxes memory temp;
        if (isSell && !useLaunchTax) temp = sellTaxes;
        else if (!useLaunchTax) temp = taxes;
        else temp = launchtax;

        s.tRfi = (tAmount * temp.rfi) / 1000;
        s.tNft = (tAmount * temp.nft) / 1000;
        s.tTreasury = (tAmount * temp.treasury) / 1000;
        s.tLiquidity = (tAmount * temp.liquidity) / 1000;
        s.tDlcs = (tAmount * temp.dlcs) / 1000;
        s.tTransferAmount =
            tAmount -
            s.tRfi -
            s.tNft -
            s.tLiquidity -
            s.tDlcs -
            s.tTreasury;
        return s;
    }

    function _getRValues1(
        valuesFromGetValues memory s,
        uint256 tAmount,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rRfi,
            uint256 rNft,
            uint256 rLiquidity
        )
    {
        rAmount = tAmount * currentRate;

        if (!takeFee) {
            return (rAmount, rAmount, 0, 0, 0);
        }

        rRfi = s.tRfi * currentRate;
        rNft = s.tNft * currentRate;
        rLiquidity = s.tLiquidity * currentRate;
        uint256 rDlcs = s.tDlcs * currentRate;
        uint256 rTreasury = s.tTreasury * currentRate;
        rTransferAmount =
            rAmount -
            rRfi -
            rNft -
            rLiquidity -
            rDlcs -
            rTreasury;
        return (rAmount, rTransferAmount, rRfi, rNft, rLiquidity);
    }

    function _getRValues2(
        valuesFromGetValues memory s,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rDlcs, uint256 rTreasury
        )
    {
        if (!takeFee) {
            return (0, 0);
        }

        rDlcs = s.tDlcs * currentRate;
        rTreasury = s.tTreasury * currentRate;
        return (rDlcs,rTreasury);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
                return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from), "You are trying to transfer more than your balance");
        require(!_isBot[from] && !_isBot[to], "You are a bot");

        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(tradingEnabled, "Trading not active");
        }

        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (
            !swapping &&
            swapEnabled &&
            canSwap &&
            from != pair &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            if (to == pair) swapAndLiquify(swapTokensAtAmount, sellTaxes);
            else swapAndLiquify(swapTokensAtAmount, taxes);
        }
        bool takeFee = false;
        bool isSell = false;
        if (swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;

        if (to == pair) {
            isSell = true;
            takeFee = true;
        }

        if (from == pair) {
            isSell = false;
            takeFee = true;
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        bool useLaunchTax = !_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient] &&
            block.number < genesis_block + deadline;

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSell, useLaunchTax);

        if (_isExcluded[sender]) {
            //from excluded
            _tOwned[sender] = _tOwned[sender] - tAmount;
        }
        if (_isExcluded[recipient]) {
            //to excluded
            _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender] - s.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + s.rTransferAmount;

        if (s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if (s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity, s.tLiquidity);
            emit Transfer(
                sender,
                address(this),
                s.tLiquidity + s.tNft + s.tDlcs + s.tTreasury
            );
        }
        if (s.rNft > 0 || s.tNft > 0) _takeNft(s.rNft, s.tNft);
        if (s.rDlcs > 0 || s.tDlcs > 0) _takeDlcs(s.rDlcs, s.tDlcs);
        if (s.rTreasury > 0 || s.tTreasury > 0) _takeTreasury(s.rTreasury, s.tTreasury);
        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap {
        uint256 denominator = (temp.liquidity +
            temp.nft +
            temp.dlcs +
            temp.treasury) * 2;

        if (denominator == 0){
            return;
        }

        uint256 tokensToAddLiquidityWith = (contractBalance * temp.liquidity) / denominator;
        uint256 toSwap = contractBalance - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance = deltaBalance / (denominator - temp.liquidity);
        uint256 bnbToAddLiquidityWith = unitBalance * temp.liquidity;

        if (bnbToAddLiquidityWith > 0) {
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }

        uint256 nftAmt = unitBalance * 2 * temp.nft;
        if (nftAmt > 0) {
            payable(nftWallet).sendValue(nftAmt);
        }

        uint256 dlcsAmt = unitBalance * 2 * temp.dlcs;
        if (dlcsAmt > 0) {
            payable(dlcsWallet).sendValue(dlcsAmt);
        }

        uint256 treasuryAmt = unitBalance * 2 * temp.treasury;
        if (treasuryAmt > 0) {
            payable(treasuryWallet).sendValue(treasuryAmt);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{ value: bnbAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            treasuryWallet,
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function bulkExcludeFee(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = state;
        }
    }

    function updateNftWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        nftWallet = newWallet;
    }

    function updateDlcsWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        dlcsWallet = newWallet;
    }


    function updateTreasuryWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0),"Fee Address cannot be zero address");
        treasuryWallet = newWallet;
    }

    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner {
        require(amount <= 42e14, "Cannot set swap threshold amount higher than 1% of tokens");
        swapTokensAtAmount = amount * 10**_decimals;
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function setAntibot(address account, bool state) external onlyOwner{
        require(isContract(account), "only contract address, not allowed externally owned account");
        require(_isBot[account] != state, 'Value already set');
        _isBot[account] = state;
    }

    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = IRouter(newRouter);
        pair = newPair;
    }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    //Use this in case BEP20 Tokens are sent to the contract by mistake
    function rescueAnyBEP20Tokens(address _tokenAddr,address _to, uint256 _amount) public onlyOwner {
        require(_tokenAddr != address(this), "Owner can't claim contract's balance of its own tokens");
        IBEP20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable {}
}