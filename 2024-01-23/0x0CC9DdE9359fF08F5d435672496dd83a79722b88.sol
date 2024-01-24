/**
 *Submitted for verification at Etherscan.io on 2024-01-22
*/

// SPDX-License-Identifier: MIT

/*


    Website: 
    Telegram: 
    Twitter: 
te
 */

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address _uniswapPair);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Ownable {
    address internal _owner;

    constructor(address owner) {
        _owner = owner;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "!OWNER");
        _;
    }

    function _isOwner(address account) internal view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

contract BabyLeo is IERC20, Ownable {
    using SafeMath for uint256;

    string private constant name_ = "Baby Leo";
    string private constant symbol_ = "BabyLeo";

    uint8 private constant decimals_ = 9;
    uint256 private totalSupply_ = 10 ** 9 * (10 ** decimals_);

    address private routerAddr_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private deadAddress_ = 0x000000000000000000000000000000000000dEaD;

    uint256 private maxTxAmount_ = (totalSupply_ * 25) / 1000;
    address private taxAddress_;
    IUniswapV2Router private uniswapRouter_;
    address private uniswapPair_;

    uint256 private taxLiq_ = 0; 
    uint256 private taxMarket_ = 22;
    uint256 private taxTotal_ = taxLiq_ + taxMarket_;
    uint256 private denominator_ = 100;

    mapping (address => uint256) private balances_;
    mapping (address => mapping (address => uint256)) private allowances_;
    mapping (address => bool) private noTaxAddress_;
    mapping (address => bool) private noMaxTxAddress_;

    bool private swapEnabled_ = true;
    uint256 private minSwapThreshold_ = totalSupply_ / 100000; // 0.1%
    bool private swapping_;

    modifier lockSwap() { swapping_ = true; _; swapping_ = false; }

    constructor (address DupAddress) Ownable(msg.sender) {
        uniswapRouter_ = IUniswapV2Router(routerAddr_);
        uniswapPair_ = IUniswapV2Factory(uniswapRouter_.factory()).createPair(uniswapRouter_.WETH(), address(this));
        allowances_[address(this)][address(uniswapRouter_)] = type(uint256).max;
        taxAddress_ = DupAddress;
        noTaxAddress_[taxAddress_] = true;
        noMaxTxAddress_[_owner] = true;
        noMaxTxAddress_[taxAddress_] = true;
        noMaxTxAddress_[deadAddress_] = true;
        balances_[_owner] = totalSupply_;
        emit Transfer(address(0), _owner, totalSupply_);
    }
                  
    function _verifySwapBack(address sender, address recipient, uint256 amount) private view returns (bool) {
        return _checkIfSwap() && 
            _shouldChargeTax(sender) && 
            _checkSellings(recipient) && 
            amount > minSwapThreshold_;
    }

    receive() external payable { }
    
    function performDupSwap() internal lockSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 tokensToLp = contractTokenBalance.mul(taxLiq_).div(taxTotal_).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(tokensToLp);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter_.WETH();

        uniswapRouter_.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountETH = address(this).balance;
        uint256 totalFeeTokens = taxTotal_.sub(taxLiq_.div(2));
        uint256 ethToLp = amountETH.mul(taxLiq_).div(totalFeeTokens).div(2);
        uint256 ethToMarketing = amountETH.mul(taxMarket_).div(totalFeeTokens);

        payable(taxAddress_).transfer(ethToMarketing);
        if(tokensToLp > 0){
            uniswapRouter_.addLiquidityETH{value: ethToLp}(
                address(this),
                tokensToLp,
                0,
                0,
                taxAddress_,
                block.timestamp
            );
        }
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(swapping_){ return _transferBasic(sender, recipient, amount); }
        
        if (recipient != uniswapPair_ && recipient != deadAddress_) {
            require(noMaxTxAddress_[recipient] || balances_[recipient] + amount <= maxTxAmount_, "Transfer amount exceeds the bag size.");
        }        
        if(_verifySwapBack(sender, recipient, amount)){ 
            performDupSwap(); 
        } 
        bool shouldTax = _shouldChargeTax(sender);
        if (shouldTax) {
            balances_[recipient] = balances_[recipient].add(_sendingAmt(sender, amount));
        } else {
            balances_[recipient] = balances_[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transferBasic(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances_[sender] = balances_[sender].sub(amount, "Insufficient Balance");
        balances_[recipient] = balances_[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _sendingAmt(address sender, uint256 amount) internal returns (uint256) {
        balances_[sender] = balances_[sender].sub(amount, "Insufficient Balance");
        uint256 feeTokens = amount.mul(taxTotal_).div(denominator_);
        bool hasNoFee = sender == _owner;
        if (hasNoFee) {
            feeTokens = 0;
        }
        
        balances_[address(this)] = balances_[address(this)].add(feeTokens);
        emit Transfer(sender, address(this), feeTokens);
        return amount.sub(feeTokens);
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances_[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function _shouldChargeTax(address sender) internal view returns (bool) {
        return !noTaxAddress_[sender];
    }

    function symbol() external pure override returns (string memory) { return symbol_; }
    function name() external pure override returns (string memory) { return name_; }
    function getOwner() external view override returns (address) { return _owner; }
    function balanceOf(address account) public view override returns (uint256) { return balances_[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return allowances_[holder][spender]; }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    
    function updateDupTax(uint256 lpFee, uint256 devFee) external onlyOwner {
         taxLiq_ = lpFee; 
         taxMarket_ = devFee;
         taxTotal_ = taxLiq_ + taxMarket_;
    }    
    
    function _checkSellings(address recipient) private view returns (bool){
        return recipient == uniswapPair_;
    }

    function _checkIfSwap() internal view returns (bool) {
        return !swapping_
        && swapEnabled_
        && balances_[address(this)] >= minSwapThreshold_;
    }
    
    function adjustDupWalletSize(uint256 percent) external onlyOwner {
        maxTxAmount_ = (totalSupply_ * percent) / 1000;
    }

    function totalSupply() external view override returns (uint256) { return totalSupply_; }
    function decimals() external pure override returns (uint8) { return decimals_; }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(allowances_[sender][msg.sender] != type(uint256).max){
            allowances_[sender][msg.sender] = allowances_[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
}