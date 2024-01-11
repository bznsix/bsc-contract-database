// SPDX-License-Identifier: No
pragma solidity = 0.8.19;

//--- Context ---//

abstract contract Context {

    function _msgData() internal view virtual returns (bytes calldata) {
         // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691 
        return msg.data;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeToSetter(address) external;
    function allPairs(uint) external view returns (address pair);
    function feeTo() external view returns (address);
    function setFeeTo(address) external;
    function allPairsLength() external view returns (uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);

}



//--- Pair ---//

interface IV2Pair {
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function factory() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);

}



interface IRouter01 {
        function WETH() external pure returns (address);

        function factory() external pure returns (address);

        function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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
    
}

interface IRouter02 is IRouter01 {
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

        function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

        function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

        function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    
}






interface IERC20 {
        event Approval(address indexed owner, address indexed spender, uint256 value);
        function balanceOf(address account) external view returns (uint256);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
        function name() external view returns (string memory);
        function symbol() external view returns (string memory);
        event Transfer(address indexed from, address indexed to, uint256 value);
        function decimals() external view returns (uint8);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function totalSupply() external view returns (uint256);
    
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
        function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
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
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
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

        function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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

    
}




contract NYX is Context, Ownable, IERC20 {

    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }
    function totalSupply() external pure override returns (uint256) { if (_Tsup == 0) { revert(); } return _Tsup; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function decimals() external pure override returns (uint8) { if (_Tsup == 0) { revert(); } return _decimals; }


    mapping (address => bool) private _pad;
    mapping (address => bool) private liqAdd;
    mapping (address => uint256) private balance;
    mapping (address => bool) private _nofeewallet;
    mapping (address => bool) private isLpPair;
    mapping (address => mapping (address => uint256)) private _allowances;


    address payable private marketingAddress = payable(0x5c6BA1e3E8706Cadb9805124b19f7F88afdE468F);
    bool public fet_bool = false;
    address payable private devWallet = payable(0xdCe4A59E9491FADe0D61cA4519e0979C259fAAd5);
    IRouter02 public _router02;
    uint256 private sellAllocation = 50;
    uint16 public _maxWalletSize_b_;
    uint256 constant public _swapth = _Tsup / 1_000;
    bool public _is_trading_enabled = false;
    address public lppairaddress;
    uint256 private _liq_Allocation = 0;
    uint256 constant public fee_denominator = 1_000;
    uint256 constant public _Tsup = 42000000000000000000000000;
    string constant private _symbol = "NYX";
    uint8 public _maxTxAmount_b_;
    uint256 private constant _buy_count_th = 20;
    string constant private _name = "Nyx Token";
    uint8 constant private _decimals = 8;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private bCount = 0;
    uint16 public swapTokensAtAmount_b_;
    uint256 constant public transferfee = 0;
    uint128 public _public_Count_b_;
    bool private canSwapFees = true;
    uint16 public swapWithLimit_b_;
    uint8 private ten_num = 10;
    uint256 constant public bfee = 0;
    uint256 constant public sellfee = 0;
    string constant public copyright = "None";
    uint256 private buyAllocation = 50;

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
        balance[msg.sender] = _Tsup;

        emit Transfer(address(0), msg.sender, _Tsup);

        lppairaddress = IFactoryV2(_router02.factory()).createPair(_router02.WETH(), address(this));
        isLpPair[lppairaddress] = true;

        _approve(msg.sender, address(_router02), 2**256 - 1);
        _approve(address(this), address(_router02), type(uint256).max);
    }

    receive() external payable {}

    function _can_swap_check(address ins, address out) internal view returns (bool) {
        bool canswap = canSwapFees && !_pad[ins] && !_pad[out];
        return canswap;
    }

    function internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        
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

        if(mktAmount > 0) (success,) = marketingAddress.call{value: mktAmount, gas: 35000}("");
        if(devAmount > 0) (success,) = devWallet.call{value: devAmount, gas: 35000}("");
    }


        function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
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

    function _transfer(address from, address to, uint256 amount) internal returns  (bool) {
        bool _takefee = true;
                require(to != address(0), "ERC20: transfer to the zero address");
                require(from != address(0), "ERC20: transfer from the zero address");
                require(amount > 0, "Transfer amount must be greater than zero");
        
        if (_islimitedadd(from,to)) {
            require(_is_trading_enabled);
        }

        if (_isbuy(from, to)) {
            bCount++;
            if (bCount >= _buy_count_th && !_is_trading_enabled) {
                _is_trading_enabled = true;
                emit _enableTrading();
            }
        }

        if(_issell(from, to) &&  !inSwap && _can_swap_check(from, to)) {
            uint256 _contract_token_b = balanceOf(address(this));
            if(_contract_token_b >= _swapth) { 
                if(buyAllocation > 0 || sellAllocation > 0) internalSwap((_contract_token_b * (buyAllocation + sellAllocation)) / 100);
                if(_liq_Allocation > 0) {swap_AndLiq(_contract_token_b * _liq_Allocation / 100);}
             }
        }

        if (_nofeewallet[from] || _nofeewallet[to]){
            _takefee = false;
        }
        balance[from] -= amount; uint256 amountAfterFee = (_takefee) ? _take_taxes(from, _isbuy(from, to), _issell(from, to), amount) : amount;
        balance[to] += amountAfterFee; emit Transfer(from, to, amountAfterFee);

        return true;

    }


        function _approve(address sender, address spender, uint256 amount) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }



function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function _islimitedadd(address ins, address out) internal view returns (bool) {

        bool isLimited = ins != owner()
            && out != owner()
            && msg.sender != owner()
            && !liqAdd[ins]  && !liqAdd[out] && out != address(0) && out != address(this);
            return isLimited;
    }

    function _issell(address ins, address out) internal view returns (bool) { 
        bool _is_sell = isLpPair[out] && !isLpPair[ins];
        return _is_sell;
    }

    function setPresaleAddress(address[] memory presaleAddresses, bool yesno) external onlyOwner {
        for (uint i = 0; i < presaleAddresses.length; i++) {
            address presale = presaleAddresses[i];
            if (_pad[presale] != yesno) {
                _pad[presale] = yesno;
                _nofeewallet[presale] = yesno;
                liqAdd[presale] = yesno;
            }
        }
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


    function _isbuy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !isLpPair[out] && isLpPair[ins];
        return _is_buy;
    }



        function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }



    function _take_taxes(address from, bool isbuy, bool issell, uint256 amount) internal returns (uint256) {
        uint256 fee;
        if (isbuy)  fee = bfee;  else if (issell)  fee = sellfee;  else  fee = transferfee; 
        if (fee == 0)  return amount; 
        uint256 feeAmount = amount * fee / fee_denominator;
        if (feeAmount > 0) {

            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
            
        }
        return amount - feeAmount;
    }



}