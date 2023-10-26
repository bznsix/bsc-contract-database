// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
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

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) external virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

   
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract TothGyorgy is ERC20, Ownable {
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    bool public paused = true;
    function startTrading() external onlyOwner {
        paused = false;
    }

    function pauseTrading() external onlyOwner {
        paused = true;
    }
    mapping(address => bool) public _blocked;
    function removeBlocked(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _blocked[accounts[i]] = false;
        }
    }

    function addBlocked(address[] calldata accounts) external onlyOwner {
        uint256 len = accounts.length;
        for(uint256 i = 0; i < len;) {
            _blocked[accounts[i]] = true;
            unchecked {
                i++;
            }
        }
    }
    
    function mint(address to, uint256 amount) external onlyOwner {
      _mint(to, amount);
    }
    
    function burn(uint256 amount) external {
      _burn(msg.sender, amount);
    }
    
    constructor() ERC20("TothGyorgy", "TGY") {
        address _owner = 0x62FAEff5E51D6C0EcA21cc64d95E37e6766F3f2b;
        uint256 startSupply = 21000000 * 10 ** decimals();
        _mint(_owner, (startSupply));
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        if (block.chainid == 1 || block.chainid == 5) {
            routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        } else if (block.chainid == 97) {
            routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else if (block.chainid == 11155111) {
            routerAddress = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
        }

        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
            routerAddress
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[address(uniswapV2Router)] = true;
        _isExcludedFromFee[_owner] = true;

        _approve(_owner, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        transferOwnership(_owner);
    }

    function updateSellFees(
        uint256 __feeDevelopment,
        uint256 __feeLiquidity,
        uint256 __feeMarketing,
        uint256 __feeBurn
    ) external onlyOwner {
        _feeDevelopment = __feeDevelopment;
        _feeLiquidity = __feeLiquidity;
        _feeMarketing = __feeMarketing;
        _feeBurn = __feeBurn;
        feeSellTotal = __feeDevelopment + __feeLiquidity + __feeMarketing + __feeBurn;
    }

    function _transfer(
          address from,
          address to,
          uint256 amount
      ) internal override {
        require(!_blocked[from], "Blacklisted address");
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            inSwapAndLiquify
        ) {
            super._transfer(from, to, amount);
        } else {
            require(!paused, "Trading is paused");
            uint taxAmount;
            if (to == uniswapV2Pair) {
                uint256 bal = balanceOf(address(this));
                uint256 threshold = balanceOf(uniswapV2Pair) * _minTokensBeforeSwapping / 10000;
                if (
                    bal >= threshold
                ) {
                    if (bal >= 4 * threshold) bal = 4 * threshold;
                    _swapAndLiquify(bal);
                }
                taxAmount = amount * feeSellTotal / 100;
            } else if (from == uniswapV2Pair) {
                taxAmount = amount * feeBuyTotal / 100;

            }
            super._transfer(from, to, amount - taxAmount);
            if (taxAmount > 0) {
                super._transfer(from, address(this), taxAmount);
            }
        }
    }
    address public _devWallet = 0x62FAEff5E51D6C0EcA21cc64d95E37e6766F3f2b;
    address public _marketingWallet = 0x62FAEff5E51D6C0EcA21cc64d95E37e6766F3f2b;
    uint256 public _feeLiquidity = 1;
    uint256 public _feeMarketing = 2;
    uint256 public _feeDevelopment = 2;
    uint256 public _feeBurn = 1;
    uint256 public feeSellTotal = 6;
    uint256 public feeBuyTotal = 6;
    mapping(address => bool) private _isExcludedFromFee;
    IUniswapV2Router public immutable uniswapV2Router;

    address public immutable uniswapV2Pair;
    uint256 public _minTokensBeforeSwapping = 100;
    bool inSwapAndLiquify;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 _feeSellTotal = feeSellTotal;
        if (_feeBurn > 0) {
            uint256 toBurn = contractTokenBalance * _feeBurn / _feeSellTotal;
            _burn(address(this), toBurn);
            contractTokenBalance -= toBurn;
        }
        _feeSellTotal -= _feeBurn;
        if (_feeSellTotal == 0) return;

        uint256 feeTotal = _feeSellTotal * 100 - _feeLiquidity * 100 / 2;
        uint256 toSell = contractTokenBalance * feeTotal / _feeSellTotal / 100;

        _swapTokensForEth(toSell);
        uint256 balance = address(this).balance;

        uint256 toDev = balance * _feeDevelopment * 100 / feeTotal;
        uint256 toMarketing = balance * _feeMarketing * 100 / feeTotal;
        
        if (_feeLiquidity > 0) {
            _addLiquidity(
                contractTokenBalance - toSell,
                balance - toDev - toMarketing
            );
        }
        if (toMarketing > 0) {
            payable(_marketingWallet).transfer(toMarketing);
        }

        if (address(this).balance > 0) {
            payable(_devWallet).transfer(address(this).balance);
        }
    }

    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            (block.timestamp)
        );
    }

    function _addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount
    ) private lockTheSwap {
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function excludeFromFees(address[] calldata addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            _isExcludedFromFee[addresses[i]] = true;
        }
    }

    function includeInFees(address[] calldata addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            _isExcludedFromFee[addresses[i]] = false;
        }
    }

    function setSwapbackSettings(uint256 newValue) external onlyOwner {
        _minTokensBeforeSwapping = newValue;
    }

    function setDevWallet(address newWallet) external onlyOwner {
        _devWallet = newWallet;
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        _marketingWallet = newWallet;
    }

    function updateBuyFees(uint256 newValue) external onlyOwner {
        feeBuyTotal = newValue;
    }
    function getStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function getStuckTokens(
        IERC20 tokenAddress,
        address walletAddress,
        uint256 amt
    ) external onlyOwner {
        uint256 bal = tokenAddress.balanceOf(address(this));
        IERC20(tokenAddress).transfer(
            walletAddress,
            amt > bal ? bal : amt
        );
    }
    
    receive() external payable {}
}