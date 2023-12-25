// SPDX-License-Identifier: MIT
//
// ###    ###   ###          ##########   ##########   ##########   ###    ###
//  ###  ###    ###          ##########   ##########   ##########   ###    ###
//   ######     ###          ###          ###    ###   ###          ###    ###
//    ####      ###          ##########   ##########   ##########   ##########
//    ####      ###          ##########   ##########   ##########   ##########
//   ######     ###          ###          ###    ###          ###   ###    ###
//  ###  ###    ##########   ##########   ###    ###   ##########   ###    ###
// ###    ###   ##########   ##########   ###    ###   ##########   ###    ###

pragma solidity ^0.8.16;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) { unchecked { uint256 c = a + b; if (c < a) return (false, 0); return (true, c); } }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) { unchecked { if (b > a) return (false, 0); return (true, a - b); } }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) { unchecked { if (a == 0) return (true, 0); uint256 c = a * b; if (c / a != b) return (false, 0); return (true, c); } }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) { unchecked { if (b == 0) return (false, 0); return (true, a / b); } }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) { unchecked { if (b == 0) return (false, 0); return (true, a % b); } }
    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { return a * b; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) { return a % b; }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { unchecked { require(b <= a, errorMessage); return a - b; } }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { unchecked { require(b > 0, errorMessage); return a / b; } }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { unchecked { require(b > 0, errorMessage); return a % b; } }
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

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external view returns (address);
    function WETH() external view returns (address);
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}

interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint256);
    function kLast() external view returns (uint256);
    function sync() external;
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

contract Bank {
    address public token;
    address public to;

    constructor (address token_) {
        token = token_;
        to = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function get() external {
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
    }
}

abstract contract TOKEN is ERC20, Ownable {
    using SafeMath for uint256;

    enum TradeType { TRANSFER, BUY, SELL, ADDLP, REMOVELP }

    address public WETH;
    address public USDT;

    address public XSHIB;
    address public XSHIB_NFT;
    address public XLEASH_NFT;

    address public mainpair;
    address public routerAddr;

    bool public enableLp;
    uint256 public launchblock;
    uint256 public tax;
    uint256 public kb = 3;

    bool    private _swapping;
    uint256 private _distributeAmount;

    address[] public lp_holders;

    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public _is_LPHolder;
    mapping(address => bool) private _isExcludedFromFees;

    uint256[] public rewardXshibNFTs;
    uint256[] public rewardXleashNFTs;

    Bank public usdtbus;

    modifier lockSwap() { _swapping = true; _; _swapping = false; }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        uint256 tax_,
        address usdt_,
        address routerAddr_,
        uint256 distributeAmount_,
        address xshib_,
        address xshibNFT_,
        address xleashNFT_
    ) ERC20(name_, symbol_, decimals_) {
        {
            require(address(this) > usdt_);
        }

        {
            WETH = IRouter(routerAddr_).WETH();
            USDT = usdt_;
            XSHIB = xshib_;
            XSHIB_NFT = xshibNFT_;
            XLEASH_NFT = xleashNFT_;
            tax = tax_;
            routerAddr = routerAddr_;
            _distributeAmount = distributeAmount_; // per distributeAmount_ usdt reward once

            usdtbus = new Bank(USDT);
        }

        {
            excludeFromFees(address(this), true);
            excludeFromFees(msg.sender, true);
        }

        {
            _mint(msg.sender, totalSupply_); // 10% for marketing
            _approve(address(this), routerAddr, ~uint256(0));
        }
    }

    receive() external payable {}

    function excludeFromFees(address account, bool excluded) public onlyOwner { _isExcludedFromFees[account] = excluded; }

    function sweep(address token, address to) public onlyOwner {
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
    }
    function sweepETH(address to) public onlyOwner {
        TransferHelper.safeTransferETH(to, address(this).balance);
    }

    function launch() external payable onlyOwner {
        require(launchblock == 0, "already launched");
        launchblock = block.number;
    }

    function set_enableLp(bool enable) external onlyOwner {
        enableLp = enable;
    }

    function set_tax(uint256 tax_) public onlyOwner {
        require(tax_ <= 20, "invalid tax");
        tax = tax_;
    }

    function set_bls(address[] calldata accounts, bool bled) public onlyOwner { for (uint256 i = 0; i < accounts.length; i++) _isBlacklisted[accounts[i]] = bled; }

    function set_mainpair(address lp) public onlyOwner {
        mainpair = lp;
    }

    function set_rewardXshibNFTs(uint256[] calldata add, uint256[] calldata remove) public onlyOwner {
        for (uint256 aidx = 0; aidx < add.length; aidx++) {
            bool abort;
            for (uint256 idx = 0; idx < rewardXshibNFTs.length; idx++) {
                if (rewardXshibNFTs[idx] == add[aidx]) {
                    abort = true;
                    break;
                }
            }
            if (abort) continue;
            rewardXshibNFTs.push(add[aidx]);
        }

        for (uint256 ridx = 0; ridx < remove.length; ridx++) {
            for (uint256 idx = 0; idx < rewardXshibNFTs.length; idx++) {
                if (rewardXshibNFTs[idx] == remove[ridx]) {
                    rewardXshibNFTs[idx] = rewardXshibNFTs[rewardXshibNFTs.length - 1];
                    rewardXshibNFTs.pop();
                    break;
                }
            }
        }
    }

    function set_rewardXleashNFTs(uint256[] calldata add, uint256[] calldata remove) public onlyOwner {
        for (uint256 aidx = 0; aidx < add.length; aidx++) {
            bool abort;
            for (uint256 idx = 0; idx < rewardXleashNFTs.length; idx++) {
                if (rewardXleashNFTs[idx] == add[aidx]) {
                    abort = true;
                    break;
                }
            }
            if (abort) continue;
            rewardXleashNFTs.push(add[aidx]);
        }

        for (uint256 ridx = 0; ridx < remove.length; ridx++) {
            for (uint256 idx = 0; idx < rewardXleashNFTs.length; idx++) {
                if (rewardXleashNFTs[idx] == remove[ridx]) {
                    rewardXleashNFTs[idx] = rewardXleashNFTs[rewardXleashNFTs.length - 1];
                    rewardXleashNFTs.pop();
                    break;
                }
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0) && to != address(0) && amount != 0);
        require(!_isBlacklisted[from]);

        if (_swapping || _isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        TradeType tradeType = _tradeType(from, to, amount);
        uint256 burnAmount;
        uint256 taxAmount;

        if (tradeType == TradeType.BUY) {
            require(launchblock > 0, "not launched");
            taxAmount = amount.mul(tax).div(100);

            if (block.number <= launchblock + kb) _isBlacklisted[to] = true;

            _addLPHolder(to); // must buy once, then will enable lp_holders reward
        }

        if (tradeType == TradeType.SELL) {
            require(launchblock > 0, "not launched");
            taxAmount = amount.mul(tax).div(100);
            burnAmount = block.number <= launchblock + 200 ? amount.mul(25).div(100) : 0;

            uint256 _swapAmount = balanceOf(mainpair).div(100);
            if (balanceOf(address(this)) >= _swapAmount) {
                _swapUSDT(_swapAmount.mul(4).div(5), address(usdtbus)); // 80% for usdtbus
                _swapXSHIB(_swapAmount.mul(1).div(5), address(this)); // 20% for swap xshib
            }
        }

        if (tradeType == TradeType.ADDLP) {
            require(enableLp);
        }

        if (tradeType == TradeType.REMOVELP) {
            taxAmount = amount.mul(tax).div(100);
            burnAmount = block.number <= launchblock + 200 ? amount.mul(25).div(100) : 0;
            _removeLPHolder(to);
        }

        if (burnAmount > 0) { amount = amount.sub(burnAmount); super._transfer(from, address(0xdead), burnAmount); }
        if (taxAmount > 0) { amount = amount.sub(taxAmount); super._transfer(from, address(this), taxAmount); }
        if (amount > 0) { super._transfer(from, to, amount.sub(1)); }

        _processReward();
    }

    function _swapXSHIB(uint256 amount, address to) internal lockSwap {
        if (amount == 0) return;
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = USDT;
        path[2] = XSHIB;
        IRouter(routerAddr).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);
    }

    function _swapUSDT(uint256 amount, address to) internal lockSwap {
        if (amount == 0) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
        IRouter(routerAddr).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);
        usdtbus.get();
    }

    function _tradeType(address from, address to, uint256 amount) internal view returns (TradeType) {
        IPair mainPair = IPair(mainpair);

        (uint256 rUsdt, uint256 rThis,) = mainPair.getReserves();
        uint256 balanceUsdt = IERC20(USDT).balanceOf(mainpair);
        uint256 amountUsdt = rUsdt > 0 && rThis > 0 ? (amount * rUsdt) / rThis : 0;

        bool isRemoveLp = balanceUsdt <= rUsdt;
        bool isAddLp = balanceUsdt >= rUsdt + amountUsdt;

        if (from == mainpair) return isRemoveLp ? TradeType.REMOVELP : TradeType.BUY;
        if (to == mainpair) return isAddLp ? TradeType.ADDLP : TradeType.SELL;
        return TradeType.TRANSFER;
    }

    function _isContract(address adr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(adr)
        }
        return size > 0;
    }

    function _addLPHolder(address adr) internal {
        if (_isContract(adr)) return;
        if (_is_LPHolder[adr]) return;
        if (_isBlacklisted[adr]) return;
        if (IERC20(mainpair).balanceOf(adr) < IERC20(mainpair).totalSupply().div(10000)) return;

        lp_holders.push(adr);
        _is_LPHolder[adr] = true;
    }

    function _removeLPHolder(address adr) internal {
        if (!_is_LPHolder[adr]) return;

        for (uint256 i = 0; i < lp_holders.length; i++) {
            if (lp_holders[i] == adr) {
                _is_LPHolder[adr] = false;
                lp_holders[i] = lp_holders[lp_holders.length - 1];
                lp_holders.pop();
                return;
            }
        }
    }

    /* FOR REWARD */

    uint256 private _processType; // 0: LP, 1: xshibNFT, 2: xleashNFT 3: xleashNFT
    uint256 private _lpidx;
    uint256 private _xshibNFTidx;
    uint256 private _xleashNFTidx;

    function _processReward() internal {
        if (IERC20(USDT).balanceOf(address(this)) < _distributeAmount) return;

        if (_processType == 0) _reward_lp();
        if (_processType == 1) _reward_xshibNFT();
        if (_processType == 2) _reward_xleashNFT();
        if (_processType == 3) _reward_xleashNFT();

        _processType = (_processType + 1) % 4;
    }

    function _reward_lp() internal {
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 rewardLPTotal;
        uint256 rewardRemain = _distributeAmount;
        address to;
        uint256 amount;

        for (uint256 i = 0; i < lp_holders.length; i++) {
            rewardLPTotal = rewardLPTotal.add(IERC20(mainpair).balanceOf(lp_holders[i]));
        }

        while (gasUsed < 500000 && iterations < lp_holders.length) {
            if (_lpidx >= lp_holders.length) _lpidx = 0;

            to = lp_holders[_lpidx];
            amount = _distributeAmount.mul(IERC20(mainpair).balanceOf(to)).div(rewardLPTotal);

            if (amount > rewardRemain) return;
            if (amount > 0) TransferHelper.safeTransfer(USDT, to, amount);

            gasUsed = gasUsed + (gasLeft - gasleft()); gasLeft = gasleft();
            _lpidx++; iterations++;
            rewardRemain = rewardRemain.sub(amount);
        }
    }

    function _reward_xshibNFT() internal {
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 count = rewardXshibNFTs.length;
        address to;
        uint256 amount = _distributeAmount.div(count);

        while (gasUsed < 500000 && iterations < count) {
            if (_xshibNFTidx >= count) _xshibNFTidx = 0;
            
            to = IERC721(XSHIB_NFT).ownerOf(rewardXshibNFTs[_xshibNFTidx]);

            if (to != address(0) && to != address(0xdead) && !_isContract(to)) TransferHelper.safeTransfer(USDT, to, amount);

            gasUsed = gasUsed + (gasLeft - gasleft()); gasLeft = gasleft(); _xshibNFTidx++; iterations++;
        }
    }

    function _reward_xleashNFT() internal {
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 count = rewardXleashNFTs.length;
        address to;
        uint256 amount = _distributeAmount.div(count);

        while (gasUsed < 500000 && iterations < count) {
            if (_xleashNFTidx >= count) _xleashNFTidx = 0;

            to = IERC721(XLEASH_NFT).ownerOf(rewardXleashNFTs[_xleashNFTidx]);

            if (to != address(0) && to != address(0xdead) && !_isContract(to)) TransferHelper.safeTransfer(USDT, to, amount);

            gasUsed = gasUsed + (gasLeft - gasleft()); gasLeft = gasleft(); _xleashNFTidx++; iterations++;
        }
    }
}

contract XLEASH is TOKEN {
    constructor()
    TOKEN(
        /* name */             "Xleash",
        /* symbol */           "Xleash",
        /* decimals */         18,
        /* totalSupply */      10000 * 10000 * (10**18),
        /* tax */              5,
        /* usdt */             0x55d398326f99059fF775485246999027B3197955,
        /* router */           0x10ED43C718714eb63d5aA57B78B54704E256024E,
        /* distributeAmount */ 50 * (10**18), // per 50 USDT reward once
        /* xshib */            0x64771885Fa0f6A49ae0e1B925242c3935Dbf6F34,
        /* xshibNFT */         0xA04Be0083E16c1baAB65532cAEb18F2b1D5bC880,
        /* xleashNFT */        0x8E1bC60b67a17964e021dc0a64F6778BBF725511
    )
    {}
}