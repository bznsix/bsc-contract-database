// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _Cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: Cast to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface ISupportAssist {
    function withdrawAward(address to) external;
}

contract ABC is ERC20, Ownable {
    using SafeMath for uint256;

    ISupportAssist public assist;
    IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;

    uint256[3] public buyFee = [1, 1, 1];
    uint256[3] public sellFee = [1, 1, 1];
    uint256 public lpBurnScale = 15;
    uint256[2] public burnScale = [70, 30];
    uint256[2] public feeDisScale = [50, 50];
    uint256 public swapTime;
    uint256 public swapBlockNumber;
    uint256 public lastLpBurnTime;
    uint256 public lastLpBurnAmount;
    bool public launch = false;
    bool private swapIng;
    uint256 public minBalanceSwapToken = 300 * 10 ** 18;
    uint256 public sendLpAwardTokenAmount = 10 ** 17;

    address public ecologicalAddress;
    address public protectAddress;
    address public blackholeAddress =
        0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) private isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private managers;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address[5] memory walletAddr_
    ) payable ERC20(name_, symbol_, decimals_) {
        ecologicalAddress = walletAddr_[2];
        protectAddress = walletAddr_[3];
        assist = ISupportAssist(walletAddr_[4]);

        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
            0x10ED43C718714eb63d5aA57B78B54704E256024E //  bsc network
            // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //testbscnetwork
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        managers[owner()] = true;
        managers[walletAddr_[1]] = true;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(ecologicalAddress, true);
        excludeFromFees(protectAddress, true);
        excludeFromFees(address(assist), true);
        excludeFromFees(walletAddr_[0], true);
        excludeFromFees(walletAddr_[1], true);

        _approve(address(this), address(uniswapV2Router), ~uint256(0));
        _Cast(address(walletAddr_[0]), totalSupply_ * (10 ** decimals_));
    }

    modifier onlyManager() {
        require(managers[msg.sender], "Not manager");
        _;
    }

    function setManager(address _manager, bool _status) public onlyOwner {
        managers[_manager] = _status;
    }

    function setLaunch(bool flag) public onlyManager {
        launch = flag;
        swapTime = block.timestamp;
        swapBlockNumber = block.number;
    }

    function setAssist(address _assist) external onlyManager {
        require(address(assist) != _assist, "Token: Repeat Set");
        assist = ISupportAssist(_assist);
        excludeFromFees(_assist, true);
    }

    function excludeFromFees(
        address account,
        bool excluded
    ) public onlyManager {
        if (isExcludedFromFees[account] != excluded) {
            isExcludedFromFees[account] = excluded;
        }
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyManager {
        for (uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setEcologicalAddress(address wallet) external onlyOwner {
        ecologicalAddress = wallet;
    }

    function setProtectAddress(address wallet) external onlyOwner {
        protectAddress = wallet;
    }

    function setMinBalanceSwapToken(uint256 amount) external onlyManager {
        minBalanceSwapToken = amount;
    }

    function setSendLpAwardTokenAmount(uint256 amount) external onlyOwner {
        sendLpAwardTokenAmount = amount;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
        uniswapV2Pair = pair;
    }

    function setBuyFee(uint256[] calldata settings) public onlyOwner {
        if (settings.length == 3) {
            for (uint256 i = 0; i < settings.length; i++) {
                buyFee[i] = settings[i];
            }
        }
    }

    function setSellFee(uint256[] calldata settings) public onlyOwner {
        if (settings.length == 3) {
            for (uint256 i = 0; i < settings.length; i++) {
                sellFee[i] = settings[i];
            }
        }
    }

    function setLpBurnScale(uint256 settings) public onlyManager {
        lpBurnScale = settings;
    }

    function setBurnScale(uint256[] calldata settings) public onlyOwner {
        if (settings.length == 2) {
            for (uint256 i = 0; i < settings.length; i++) {
                burnScale[i] = settings[i];
            }
        }
    }

    function setFeeDisScale(uint256[] calldata settings) public onlyOwner {
        if (settings.length == 2) {
            for (uint256 i = 0; i < settings.length; i++) {
                feeDisScale[i] = settings[i];
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (!isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            require(launch, "unlaunch");
            uint256 fees = calculateFee(from, to, amount);
            if (fees > 0) {
                amount -= fees;
            }

            if (automatedMarketMakerPairs[to]) {
                uint256 contractBalance = balanceOf(address(this));
                if (!swapIng && contractBalance > minBalanceSwapToken) {
                    swapIng = true;
                    swapTokensForBnb(contractBalance);
                    swapIng = false;
                }
            }
        }
        if (
            from != address(uniswapV2Pair) &&
            address(assist) != address(0) &&
            to == address(assist) &&
            amount >= sendLpAwardTokenAmount
        ) {
            assist.withdrawAward(from);
        }
        super._transfer(from, to, amount);
    }

    function calculateFee(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256) {
        uint256 bFee;
        uint256 oFee;
        if (swapBlockNumber + 3 >= block.number) {
            return amount;
        }
        if (block.timestamp <= swapTime + 30 minutes) {
            if (automatedMarketMakerPairs[from]) {
                //buy 10%
                bFee = amount.mul(2).div(100);
                oFee = amount.mul(8).div(100);
                super._transfer(from, blackholeAddress, bFee);
                super._transfer(from, address(this), oFee);
                return bFee + oFee;
            }

            if (automatedMarketMakerPairs[to]) {
                //sell 30%
                bFee = amount.mul(2).div(100);
                oFee = amount.mul(28).div(100);
                super._transfer(from, blackholeAddress, bFee);
                super._transfer(from, address(this), oFee);
                return bFee + oFee;
            }
            return 0;
        }

        if (automatedMarketMakerPairs[from]) {
            bFee = amount.mul(buyFee[0]).div(100);
            oFee = amount.mul(buyFee[1].add(buyFee[2])).div(100);
            super._transfer(from, blackholeAddress, bFee);
            super._transfer(from, address(this), oFee);
            return bFee.add(oFee);
        }

        if (automatedMarketMakerPairs[to]) {
            bFee = amount.mul(sellFee[0]).div(100);
            oFee = amount.mul(sellFee[1].add(sellFee[2])).div(100);
            super._transfer(from, blackholeAddress, bFee);
            super._transfer(from, address(this), oFee);
            return bFee.add(oFee);
        }
        return 0;
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        // _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        assignFee();
    }

    function withdrawFee(uint256 withdrawType, address to) public onlyManager {
        if (withdrawType == 0) {
            uint256 bnb = payable(address(this)).balance;
            require(bnb > 0, "Insufficient balance");
            payable(to).transfer(bnb);
        } else if (withdrawType == 1) {
            uint256 ana = balanceOf(address(this));
            require(ana > 0, "Insufficient balance");
            super._transfer(address(this), to, ana);
        }
    }

    function assignFee() private {
        uint256 _balance = payable(address(this)).balance;
        if (_balance > 0) {
            payable(address(ecologicalAddress)).transfer(
                _balance.mul(feeDisScale[0]).div(100)
            );
            payable(address(protectAddress)).transfer(
                _balance.mul(feeDisScale[1]).div(100)
            );
        }
    }

    function burnLp() public onlyManager {
        lastLpBurnTime = block.timestamp;
        uint256 liquidityPairBalance = balanceOf(uniswapV2Pair);
        if (liquidityPairBalance == 0) return;
        lastLpBurnAmount = liquidityPairBalance.mul(lpBurnScale).div(1000);
        uint256 deadAmount = lastLpBurnAmount.mul(burnScale[0]).div(100);
        uint256 lpAmount = lastLpBurnAmount.mul(burnScale[1]).div(100);
        if (deadAmount > 0) {
            super._transfer(uniswapV2Pair, blackholeAddress, deadAmount);
        }
        if (lpAmount > 0) {
            super._transfer(uniswapV2Pair, address(assist), lpAmount);
        }
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    receive() external payable {}
}
