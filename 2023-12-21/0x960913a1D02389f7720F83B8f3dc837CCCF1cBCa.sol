// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
}

library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeApprove: approve failed'); }
    function safeTransfer(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeTransfer: transfer failed'); }
    function safeTransferFrom(address token, address from, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::transferFrom: transferFrom failed'); }
    function safeTransferETH(address to, uint256 value) internal { (bool success, ) = to.call{value: value}(new bytes(0)); require(success, 'TransferHelper::safeTransferETH: ETH transfer failed'); }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IRouter {
    function WETH() external view returns (address);
    function factory() external view returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IBTM {
    function mintPerBlock() external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _transferOwnership(_msgSender()); }
    modifier onlyOwner() { _checkOwner(); _; }
    function owner() public view virtual returns (address) { return _owner; }
    function _checkOwner() internal view virtual { require(owner() == _msgSender(), "Ownable: caller is not the owner"); }
    function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }
    function transferOwnership(address newOwner) public virtual onlyOwner { require(newOwner != address(0), "Ownable: new owner is the zero address"); _transferOwnership(newOwner); }
    function _transferOwnership(address newOwner) internal virtual { address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner); }
}

abstract contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) { _name = name_; _symbol = symbol_; _decimals = decimals_; }
    function name() public view virtual override returns (string memory) { return _name; }
    function symbol() public view virtual override returns (string memory) { return _symbol; }
    function decimals() public view virtual override returns (uint8) { return _decimals; }
    function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }
    function transfer(address to, uint256 amount) public virtual override returns (bool) { address owner = _msgSender(); _transfer(owner, to, amount); return true; }
    function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender]; }
    function approve(address spender, uint256 amount) public virtual override returns (bool) { address owner = _msgSender(); _approve(owner, spender, amount); return true; }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) { address spender = _msgSender(); _spendAllowance(from, spender, amount); _transfer(from, to, amount); return true; }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) { address owner = _msgSender(); _approve(owner, spender, allowance(owner, spender) + addedValue); return true; }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked { _approve(owner, spender, currentAllowance - subtractedValue); }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked { _balances[from] = fromBalance - amount; _balances[to] += amount; }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked { _balances[account] += amount; }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked { _balances[account] = accountBalance - amount; _totalSupply -= amount; }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked { _approve(owner, spender, currentAllowance - amount); }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;

    enum TradeType { TRANSFER, BUY, SELL, ADDLP, REMOVELP }
    struct Tax {
        uint256 lpReward;
        uint256 marketing1;
        uint256 marketing2;
        uint256 burn;
    }
    struct TaxAmount {
        uint256 lpReward;
        uint256 marketing1;
        uint256 marketing2;
    }

    Tax public buyTax = Tax(100, 50, 50, 0);      // base 10000
    Tax public sellTax = Tax(100, 150, 100, 150); // base 10000
    TaxAmount public taxAmount;

    address public WETH;
    address public USDT;
    address public BTM;

    address public mainpair; // mainpair = dzm-usdt
    mapping(address => bool) public _isPair;

    address public routerAddr;
    address public marketingAddr1;
    address public marketingAddr2;

    uint256 public launchblock;
    bool    private _swapping;
    uint256 private _lastProcess;

    uint256 public lpRewardLimit;
    uint256 public swapLimit;
    uint256 public referrerLimit = 2 * 1e18 / 100;

    address[] public _lpHolders;
    uint256 private _idx;
    mapping(address => bool) public _isLpHolder;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => address) public _referrer;
    mapping(address => uint256) public _lpRewardClaimedAt;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address usdt_,
        address routerAddr_,
        address marketingAddr1_,
        address marketingAddr2_
    ) ERC20(name_, symbol_, decimals_) {
        {
            require(address(this) > usdt_, "invalid token address, try next nonce");
        }

        {
            USDT = usdt_;
            WETH = IRouter(routerAddr_).WETH();
            routerAddr = routerAddr_;
            marketingAddr1 = marketingAddr1_;
            marketingAddr2 = marketingAddr2_;
        }

        {
            lpRewardLimit = totalSupply_.div(1000);
            swapLimit = totalSupply_.div(1000);
        }

        {
            _isExcludedFromFees[marketingAddr1] = true;
            _isExcludedFromFees[marketingAddr2] = true;
            _isExcludedFromFees[address(this)] = true;
            _isExcludedFromFees[msg.sender] = true;
        }

        {
            _mint(msg.sender, totalSupply_);
            _approve(address(this), routerAddr, ~uint256(0));
        }
    }

    receive() external payable {}

    function launch() external payable onlyOwner {
        require(mainpair != address(0), "not set lp");
        require(launchblock == 0, "already launched");
        launchblock = block.number;
    }

    function excludeFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function sweep(address token, address to) public onlyOwner {
        if (token == address(0)) TransferHelper.safeTransferETH(to, address(this).balance);
        else TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
    }

    function set_btm(address btm) public onlyOwner {
        BTM = btm;
    }

    function set_tax(Tax memory buy, Tax memory sell) public onlyOwner {
        uint256 totalBuy = buy.lpReward + buy.marketing1 + buy.marketing2 + buy.burn;
        uint256 totalSell = sell.lpReward + sell.marketing1 + sell.marketing2 + sell.burn;
        require(totalBuy <= 5000, "invalid tax");
        require(totalSell <= 5000, "invalid tax");
        buyTax.lpReward = buy.lpReward; buyTax.marketing1 = buy.marketing1; buyTax.marketing2 = buy.marketing2; buyTax.burn = buy.burn;
        sellTax.lpReward = sell.lpReward; sellTax.marketing1 = sell.marketing1; sellTax.marketing2 = sell.marketing2; sellTax.burn = sell.burn;
    }

    function set_blacklist(address[] memory accounts, bool isBlacklist) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = isBlacklist;
        }
    }

    function set_mainpair(address lp) public onlyOwner {
        require(mainpair == address(0), "already set lp");
        mainpair = lp;
        _isPair[lp] = true;
    }

    function set_pairs(address[] memory pairs, bool is_) public onlyOwner {
        for (uint256 i = 0; i < pairs.length; i++) {
            _isPair[pairs[i]] = is_;
        }
    }

    function set_referrerLimit(uint256 limit) public onlyOwner {
        referrerLimit = limit;
    }

    // 手动修复lp持有者
    function set_lpHolders(address[] memory holders, bool is_) public onlyOwner {
        if (is_) {
            for (uint256 i = 0; i < holders.length; i++) {
                _addHolder(holders[i]);
            }
        } else {
            for (uint256 i = 0; i < holders.length; i++) {
                _removeHolder(holders[i]);
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(!_isBlacklisted[from], "blacklisted");
        require(from != address(0) && to != address(0));
        require(from != to, "no self");

        if (amount == 0) { super._transfer(from, to, 0); return; }
        if (_swapping || _isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        /* ----------------- */

        TradeType tradeType = _tradeType(from, to, amount);
        uint256 marketing1Amount;
        uint256 marketing2Amount;
        uint256 lpRewardAmount;
        uint256 burnAmount;

        if (tradeType == TradeType.BUY) {
            require(launchblock > 0, "not launched");

            lpRewardAmount = amount.mul(buyTax.lpReward).div(10000);
            marketing1Amount = amount.mul(buyTax.marketing1).div(10000);
            marketing2Amount = amount.mul(buyTax.marketing2).div(10000);
            burnAmount = amount.mul(buyTax.burn).div(10000);

            amount = _airdrop(amount, from, 2);
        }
        if (tradeType == TradeType.SELL) {
            require(launchblock > 0, "not launched");

            lpRewardAmount = amount.mul(sellTax.lpReward).div(10000);
            marketing1Amount = amount.mul(sellTax.marketing1).div(10000);
            marketing2Amount = amount.mul(sellTax.marketing2).div(10000);
            burnAmount = amount.mul(sellTax.burn).div(10000);
            if (taxAmount.marketing1 + taxAmount.marketing2 > swapLimit) {
                _swap(taxAmount.marketing1, marketingAddr1);
                _swap(taxAmount.marketing2, marketingAddr2);
                taxAmount.marketing1 = 0;
                taxAmount.marketing2 = 0;
            }

            amount = _airdrop(amount, from, 2);
        }
        if (tradeType == TradeType.REMOVELP) {
            require(launchblock > 0, "not launched");

            // 一天内 40%撤除税收，之后为5%, 直接转入基金会钱包
            uint256 toMarketing1 = amount.mul(block.number < launchblock + 28800 ? 4000 : 500).div(10000);
            amount = amount.sub(toMarketing1);
            super._transfer(from, marketingAddr1, toMarketing1);
        }
        if (tradeType == TradeType.TRANSFER) {
            if (amount == referrerLimit) _bindReferrer(from, to);
        }
        if (tradeType == TradeType.ADDLP) {
            _addHolder(from);
        }

        /* ----------------- */

        if (burnAmount > 0) { amount = amount.sub(burnAmount); super._transfer(from, address(0xdead), burnAmount); }
        if (marketing1Amount > 0) { amount = amount.sub(marketing1Amount); taxAmount.marketing1 += marketing1Amount; }
        if (marketing2Amount > 0) { amount = amount.sub(marketing2Amount); taxAmount.marketing2 += marketing2Amount; }
        if (lpRewardAmount > 0) { amount = amount.sub(lpRewardAmount); taxAmount.lpReward += lpRewardAmount; }
        if (marketing1Amount + marketing2Amount + lpRewardAmount > 0) { super._transfer(from, address(this), marketing1Amount + marketing2Amount + lpRewardAmount); }

        super._transfer(from, to, amount); 

        if (!_swapping && tradeType != TradeType.ADDLP) _process(500000);
    }

    function _airdrop(uint256 amount, address from, uint256 count) internal returns (uint256) {
        if (amount <= count) return amount;
        address ad;
        for (uint i = 0; i < count; i++) {
            ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
            super._transfer(from, ad, 1);
        }
        return amount.sub(count);
    }

    function _tradeType(address from, address to, uint256 amount) internal view returns (TradeType) {
        bool isRemoveLp;
        bool isAddLp;

        if (from == mainpair || to == mainpair) {
            IPair mainPair = IPair(mainpair);

            (uint256 rUSDT, uint256 rThis,) = mainPair.getReserves();
            uint256 balanceUSDT = IERC20(USDT).balanceOf(mainpair);
            uint256 amountUSDT = rUSDT > 0 && rThis > 0 ? (amount * rUSDT) / rThis : 0;

            isRemoveLp = balanceUSDT <= rUSDT; // if use pair.swap->router.callback to sent token0, 'sell' maybe be judged as 'removelp'
            isAddLp = balanceUSDT >= rUSDT + amountUSDT;
        }

        if (_isPair[from]) return isRemoveLp ? TradeType.REMOVELP : TradeType.BUY;
        if (_isPair[to]) return isAddLp ? TradeType.ADDLP : TradeType.SELL;
        return TradeType.TRANSFER;
    }

    function _isContract(address adr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(adr) }
        return size > 0;
    }

    function _addHolder(address adr) internal {
        if (_isContract(adr)) return;
        if (_isLpHolder[adr]) return;

        _lpHolders.push(adr);
        _isLpHolder[adr] = true;
        _lpRewardClaimedAt[adr] = block.number;
    }

    function _removeHolder(address adr) internal {
        if (!_isLpHolder[adr]) return;
        if (IERC20(mainpair).balanceOf(adr) >= IERC20(mainpair).totalSupply().div(10000)) return;

        // find index
        uint256 idx = 0;
        for (uint256 i = 0; i < _lpHolders.length; i++) {
            if (_lpHolders[i] == adr) {
                idx = i;
                break;
            }
        }

        _isLpHolder[adr] = false;
        _lpHolders[idx] = _lpHolders[_lpHolders.length - 1];
        _lpHolders.pop();
    }

    function _bindReferrer(address from, address to) internal {
        if (_referrer[to] != address(0)) return;
        if (from != tx.origin) return;
        if (_isContract(to)) return;
        if (_isContract(from)) return;
        _referrer[to] = from;
    }

    function _swap(uint256 tokenAmount, address to) internal lockSwap {
        if (tokenAmount == 0) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
        IRouter(routerAddr).swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, to, block.timestamp);
    }

    // 分红子币和母币
    function _process(uint256 gas) internal {
        if (taxAmount.lpReward < lpRewardLimit) return;
        if (_lastProcess == block.number) return;

        _lastProcess = block.number;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        address holder;
        uint256 holderBalance;
        uint256 dzmAmount;
        uint256 btmAmount;
        uint256 remainUSDT = lpRewardLimit;
        uint256 ts;
        uint256 perBlock = IBTM(BTM).mintPerBlock();

        for (uint256 i = 0; i < _lpHolders.length; i++) {
            holder = _lpHolders[i];
            holderBalance = IERC20(mainpair).balanceOf(holder);
            ts += IERC20(mainpair).balanceOf(holder);
        }

        while (gasUsed < gas && iterations < _lpHolders.length && remainUSDT > 0) {
            if (_idx >= _lpHolders.length) _idx = 0;
            holder = _lpHolders[_idx];
            holderBalance = IERC20(mainpair).balanceOf(holder);

            if (holderBalance == 0) {
                _removeHolder(holder);
            } else {
                dzmAmount = lpRewardLimit.mul(holderBalance).div(ts);
                btmAmount = dzmAmount.mul(perBlock).mul(block.number - _lpRewardClaimedAt[holder]).div(ts);

                if (dzmAmount > remainUSDT) dzmAmount = remainUSDT;
                if (dzmAmount > 0) {
                    TransferHelper.safeTransfer(address(this), holder, dzmAmount);
                    remainUSDT = remainUSDT.sub(dzmAmount);
                    taxAmount.lpReward = taxAmount.lpReward.sub(dzmAmount);
                }

                if (btmAmount > 0 && btmAmount.mul(2) <= IERC20(BTM).balanceOf(address(this))) {
                    TransferHelper.safeTransfer(BTM, holder, btmAmount);
                    _lpRewardClaimedAt[holder] = block.number;

                    address lastReferrer = _referrer[holder];
                    for (uint level = 1; level <= 3; level++) {
                        if (lastReferrer == address(0)) break;
                        uint256 referrerReward = btmAmount.mul(2 ** (4 - level)).div(100); // 8% 4% 2%
                        TransferHelper.safeTransfer(BTM, lastReferrer, referrerReward);
                        lastReferrer = _referrer[lastReferrer];
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _idx++;
            iterations++;
        }
    }
}

contract DZM is TOKEN {
    constructor()
    TOKEN(
        /* name */             "DZM",
        /* symbol */           "DZM",
        /* decimals */         18,
        /* totalSupply */      9999 * (10**18),
        /* usdt */             0x55d398326f99059fF775485246999027B3197955,
        /* router */           0x10ED43C718714eb63d5aA57B78B54704E256024E,
        /* marketingAddr1 */   0xCb91524993c9cb019A0d2EB0C83E2B94CA13e00c,
        /* marketingAddr2 */   0xF731c19F2919628FD3a11bca75aB5DB798C80004
    )
    {}
}