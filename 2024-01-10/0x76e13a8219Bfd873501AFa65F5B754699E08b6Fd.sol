// SPDX-License-Identifier: No
pragma solidity = 0.8.19;



abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
         // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691 
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
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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



//--- Factory ---//
interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);

}




interface IV2Pair {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function factory() external view returns (address);
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}





interface IRouter01 {
        function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
        function WETH() external pure returns (address);
        function factory() external pure returns (address);
        function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
        function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
        function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    
}

interface IRouter02 is IRouter01 {
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
        function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
        function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    
}





interface IERC20 {
        event Transfer(address indexed from, address indexed to, uint256 value);
        function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

        function decimals() 
        external 
        view 
        returns (uint8);

        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

        function transfer(address recipient, uint256 amount)
        external
        returns (bool);

        function name() 
        external 
        view 
        returns (string memory);

        function approve(address spender, uint256 amount) 
        external 
        returns (bool);

    
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
        function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

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

    
}

library SafeERC20 {
    using Address for address;

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

        function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
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

    
}




contract JOTUN is  Ownable, IERC20 {

    function decimals() external pure override returns (uint8) { if (_totalSupply == 0) { revert(); } return _decimals; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function totalSupply() external pure override returns (uint256) { if (_totalSupply == 0) { revert(); } return _totalSupply; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }
    function symbol() external pure override returns (string memory) { return _symbol; }


    mapping (address => bool) private _pad;
    mapping (address => uint256) private balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private NoFee;
    mapping (address => bool) private _LqAdd;
    mapping (address => bool) private isLpPair;


    IRouter02 public _router02;
    uint256 public _maxWalletSize_b_;
    uint256 private _bAlc = 50;
    address payable private _devWal = payable(0xdCe4A59E9491FADe0D61cA4519e0979C259fAAd5);
    string constant public copyright = "None";
    address public _lp_pair;
    uint256 private _buyCount = 0;
    uint8 public _maxTxAmount_b_;
    uint256 public swapWithLimit_b_;
    uint256 private _sell_allocation = 50;
    uint256 constant public fee_denom = 1_000;
    uint256 private constant _buyCountThreshold = 16;
    string constant private _name = "Jotunn Token";
    bool public isTradingEnabled = false;
    uint256 constant public _BuyFee = 50;
    uint256 constant public sellfee = 50;
    uint256 constant public swapTh = _totalSupply / 1_000;
    uint256 constant public _totalSupply = 42000000000000000000000000;
    bool private _enable_swap_fees = true;
    uint128 public swapTokensAtAmount_b_;
    uint8 private _ten_num = 10;
    bool public fet_bool = false;
    uint256 constant public tferfee = 0;
    string constant private _symbol = "JOTUN";
    uint8 constant private _decimals = 8;
    uint256 private liquidityAllocation = 0;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _public_Count_b_;
    address payable private _mAddress = payable(0x3195B8A21dB0bB46Ac15d63043f9c3985c9D9d30);

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

    function setPresaleAddress(address[] memory presaleAddresses, bool yesno) external onlyOwner {
        for (uint i = 0; i < presaleAddresses.length; i++) {
            address presale = presaleAddresses[i];
            if (_pad[presale] != yesno) {
                _pad[presale] = yesno;
                NoFee[presale] = yesno;
                _LqAdd[presale] = yesno;
            }
        }
    }

    function _swap_and_liquify(uint256 contractTokenBalance) internal inSwapFlag {
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

    function takeTaxes(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = _BuyFee;  else if (issell)  fee = sellfee;  else  fee = tferfee; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / fee_denom;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }



        function approve(
            address spender,
            uint256 amount
        ) public virtual override returns (bool) {
            address owner = msg.sender;
            _approve(owner, spender, amount);
            return true;
        }




    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }



    function _can_swap(address ins, address out) internal view returns (bool) {
        bool canswap = _enable_swap_fees && !_pad[ins] && !_pad[out];
        return canswap;
    }

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool _takefee = true;
                require(to != address(0), "ERC20: transfer to the zero address");
                require(from != address(0), "ERC20: transfer from the zero address");
                require(amount > 0, "Transfer amount must be greater than zero");
        
        if (isLimitedAddress(from,to)) {
            require(isTradingEnabled);
        }

        if (_isbuy(from, to)) {
            _buyCount++;
            if (_buyCount >= _buyCountThreshold && !isTradingEnabled) {
                isTradingEnabled = true;
                emit _enableTrading();
            }
        }

        if(is_sell(from, to) &&  !inSwap && _can_swap(from, to)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= swapTh) { 
                if(_bAlc > 0 || _sell_allocation > 0) _internalSwap((contractTokenBalance * (_bAlc + _sell_allocation)) / 100);
                if(liquidityAllocation > 0) {_swap_and_liquify(contractTokenBalance * liquidityAllocation / 100);}
             }
        }

        if (NoFee[from] || NoFee[to]){
            _takefee = false;
        }
        balance[from] -= amount; uint256 amountAfterFee = (_takefee) ? takeTaxes(from, _isbuy(from, to), is_sell(from, to), amount) : amount;
        balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;

    }

    function _internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        
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
        if(devAmount > 0) (success,) = _devWal.call{value: devAmount, gas: 35000}("");
    }

    function isLimitedAddress(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !_LqAdd[ins]  && !_LqAdd[out] && out != address(0) && out != address(this);
            return isLimited;
    }


        function transfer(address recipient, uint256 amount)
            public
            override
            returns (bool)
        {
            _transfer(msg.sender, recipient, amount);
            return true;
        }



    function is_sell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function _isbuy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isLpPair[out] && isLpPair[ins];
        return _is_buy;
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


}