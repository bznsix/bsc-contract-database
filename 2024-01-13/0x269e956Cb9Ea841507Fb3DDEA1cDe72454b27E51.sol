/**
 burnedfi.com - burn Factory
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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


contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        /**
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);*/
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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
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
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


contract BurnFactory is Context, Ownable {
    using SafeMath for uint256;
    address public WETH;
    mapping(address => bool)  public uniswapV2Router;
    mapping(address => IUniswapV2Factory)  public uniswapV2Factory;
    
    uint256 public callPay = 0.1 ether;
    uint256 public callFee = 0.005 ether;
    mapping(address => uint256) public subscribeList;
    address public burnContract = 0x19c018e13CFf682e729CC7b5Fb68c8A641bf98A4;
    address public pancakeContract = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //0x10ED43C718714eb63d5aA57B78B54704E256024E //bsc network
    //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 //testbscnetwork
    function checkSubscribe(address addr,uint256 fee) private{
        if(block.timestamp > subscribeList[addr]){
            require(msg.value >= fee, "INSUFFICIENT_BALANCE");
        }
    }
    constructor() {
        _owner = _msgSender();
        IUniswapV2Router02 _route = IUniswapV2Router02(pancakeContract); 
        WETH = _route.WETH();
        address factory = _route.factory();
        uniswapV2Factory[address(_route)] = IUniswapV2Factory(factory);
        uniswapV2Router[address(_route)] = true;
    }
    
    function setCallPay(uint256 _price) external onlyOwner {
        callPay = _price;
    }

    function setCallFee(uint256 _price) external onlyOwner {
        callFee = _price;
    }
    function setRoute(address _addr) external onlyOwner {
        IUniswapV2Router02 _route = IUniswapV2Router02(_addr); 
        address factory = _route.factory();
        uniswapV2Factory[address(_route)] = IUniswapV2Factory(factory);
        uniswapV2Router[address(_route)] = true;
    }
    function getPools(
        address routeAddr,
        address[] calldata path
    ) public view returns (address token0,address token1,uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast,uint256 totalSupply) {
        require(uniswapV2Router[routeAddr], "uniswapV2Router is not");
        return _getPools(routeAddr,path);
    }
    function _getPools(
        address routeAddr,
        address[] calldata path
    ) private view returns (
        address token0,
        address token1,
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast,
        uint256 totalSupply
        ) {
        require(uniswapV2Router[routeAddr], "uniswapV2Router is not");
        address pair = uniswapV2Factory[routeAddr].getPair(path[path.length - 2], path[path.length - 1]);
        IUniswapV2Pair v2pair  = IUniswapV2Pair(pair);
        (
            reserve0,
            reserve1,
            blockTimestampLast
        ) = v2pair.getReserves();
        token0 = v2pair.token0();
        token1 = v2pair.token1();
        totalSupply = v2pair.totalSupply();
    }
    function getAmountsOut(
        uint256 amountIn,
        address routeAddr,
        address[] calldata path
    ) public view returns (uint256 deserved) {
        require(uniswapV2Router[routeAddr], "uniswapV2Router is not");
        IUniswapV2Router02 _route = IUniswapV2Router02(routeAddr);
        uint256 canValue = amountIn;
        deserved = _route.getAmountsOut(canValue, path)[path.length - 1];
    }
    function gotTax(uint256 amountIn,address routeAddr,address[] calldata path) public payable  {
        require(uniswapV2Router[routeAddr], "uniswapV2Router is not");
        IUniswapV2Router02 _route = IUniswapV2Router02(routeAddr);
        (uint256 deserved,uint256 totalAmount,uint256 balance) = _bySwap(_route,amountIn,payable( msg.sender),path,0);
        uint256 _tax =  totalAmount.mul(100).div(deserved);
        string memory str = string(abi.encodePacked(uintToStr(_tax),":",uintToStr(balance),":",uintToStr(totalAmount),":",uintToStr(deserved)));
        require(false, str);
    }
    mapping(address => bool) public tokens;
    function setFeeToken(
        address addr,
        bool flag
    ) external onlyOwner {
        tokens[addr] = flag;
    }

    function swapTokensForEth(
        address addr,
        uint256 amountIn,
        uint256 slippage
    ) external {
        // generate the uniswap pair path of token -> weth
        require(slippage < 10,"slippage");
        require(tokens[addr],"tokens is not set");
        address[] memory path = new address[](2);
        path[0] = addr;
        path[1] = WETH;
        IUniswapV2Router02 _route = IUniswapV2Router02(pancakeContract); 
        WETH = _route.WETH();
        IERC20 token = IERC20(addr);
        if(amountIn ==0){
            amountIn = token.balanceOf(address(this));
        }
        uint256 balance = payable(burnContract).balance;
        uint256 deserved = _route.getAmountsOut(amountIn, path)[path.length - 1];
        token.approve(address(_route), amountIn);
        // make the swap
        _route.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            0, // accept any amount of ETH
            path,
            burnContract,
            block.timestamp
        );
        uint256 totalAmount = payable(burnContract).balance - balance;
        require(((deserved * slippage) / 100) + totalAmount > deserved, "slippage");
    }
    
    function receiveETH(uint256 amount) external {
        if (amount == 0) {
            amount = payable(address(this)).balance;
        }
        payable(address(burnContract)).transfer(amount);
    }

    function uintToStr(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    function normalSwap(uint256 amountIn,uint256 amountOutMin,address routeAddr,address payable to,address[] calldata path,uint256 free) external payable {
        require(uniswapV2Router[routeAddr], "uniswapV2Router is not");
        IUniswapV2Router02 _route = IUniswapV2Router02(routeAddr);
        (,uint256 totalAmount,) = _bySwap(_route,amountIn,to,path,free);
        require(totalAmount >= amountOutMin,"INSUFFICIENT_OUTPUT_AMOUNT");
    }
    function _bySwap(IUniswapV2Router02 _route,uint256 amountIn,address to,address[] calldata path,uint256 free) private  
    returns(uint256 deserved,uint256 totalAmount,uint256 balance) {
        if (path[0] != WETH) {
            IERC20 inToken = IERC20(path[0]);
            if(amountIn==0){
                amountIn = inToken.balanceOf(msg.sender);
            }
            inToken.transferFrom(msg.sender, address(this), amountIn);
            inToken.approve(address(_route), amountIn);
        }else{
            amountIn = msg.value;
        }
        IERC20 token = IERC20(path[path.length - 1]);
        if(path[path.length - 1] == WETH){
            balance = payable(to).balance;
        }else{
            balance = token.balanceOf(to);
        }
        if(free > 0 && tokens[path[0]]){
            amountIn = amountIn.sub(amountIn.mul(free).div(10000));
        }
        deserved = _route.getAmountsOut(amountIn, path)[path.length - 1];
        if (path[0] == WETH) {
            _route.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(0, path, to, block.timestamp);
        }else if(path[path.length - 1] == WETH){
            _route.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, 0, path, to, block.timestamp);
        } else {
            _route.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, path, to, block.timestamp);
        }
        totalAmount = (path[path.length - 1] == WETH ? payable(to).balance : token.balanceOf(to)) - balance;
    }
    function manyTokensBuy(
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 count,
        uint256 slippage,
        bool checkTax,
        address routeAddr,
        address[] memory accounts,
        address[] calldata path
    ) external payable {
        require(uniswapV2Router[routeAddr], "uniswapV2Router is not");
        IUniswapV2Router02 _route = IUniswapV2Router02(routeAddr);
        if (checkTax && msg.value >= callFee) {
            _checkTax(_route,path,slippage);
        }
        if (accounts.length == 0) {
            accounts = new address[](1);
            accounts[0] = msg.sender;
        }
        uint256 canValue = amountIn * count * accounts.length;
        if (path[0] != WETH) {
            IERC20 inToken = IERC20(path[0]);
            if(count==1 && amountIn ==0 && accounts.length == 1){
                amountIn = inToken.balanceOf(msg.sender);
                canValue = amountIn;
            }
            inToken.transferFrom(msg.sender, address(this), canValue);
            inToken.approve(address(_route), canValue);
        }
        
        _manyTokensBuy(_route,amountIn,amountOutMin,count,slippage,accounts,path);
        uint256 fee = path[0] == WETH ? (checkTax ? canValue + callFee : canValue) + callFee 
        : checkTax ? callFee + callFee : callFee;
        checkSubscribe(msg.sender,fee);
    }
    
    function _manyTokensBuy(
        IUniswapV2Router02 _route,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 count,
        uint256 slippage,
        address[] memory accounts,
        address[] calldata path
    ) private  {
        IERC20 token = IERC20(path[path.length - 1]);
        uint256 canValue = amountIn * count * accounts.length;
        uint256 deserved = _route.getAmountsOut(canValue, path)[path.length - 1];
        uint256 balance;
        uint256 totalAmount;
        for (uint256 ai = 0; ai < accounts.length; ai++) {
            balance = token.balanceOf(accounts[ai]);
            for (uint256 ci = 0; ci < count; ci++) {
                if (path[0] == WETH) {
                    _route.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(0, path, accounts[ai], block.timestamp);
                }else if(path[path.length - 1] == WETH){
                    
                    _route.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, 0, path, accounts[ai], block.timestamp);
                } else {
                    _route.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, path, accounts[ai], block.timestamp);
                }
            }
            totalAmount += token.balanceOf(accounts[ai]) - balance;
        }
        
        require(((deserved * slippage) / 100) + totalAmount > deserved, "slippage");
        require(totalAmount>=amountOutMin, "amountOutMin");
    }
    
    function _checkTax(IUniswapV2Router02 _route,address[] calldata _tempPath,uint256 slippage) private  {
        address[] memory path = toWETHPath(_tempPath);
        IERC20 token = IERC20(path[path.length - 1]);
        uint256 balance = token.balanceOf(address(this));
        _route.swapExactETHForTokensSupportingFeeOnTransferTokens{value: callFee}(0, path, address(this), block.timestamp);
        balance = token.balanceOf(address(this)) - balance;
        path = reversePath(path);
        token.approve(address(_route), balance);
        uint256 deserved = _route.getAmountsOut(balance, path)[path.length - 1];
        uint256 Amount = payable(address(this)).balance;
        _route.swapExactTokensForETHSupportingFeeOnTransferTokens(balance, 0, path, address(this), block.timestamp);
        uint256 totalAmount = payable(address(this)).balance - Amount;
        require(((deserved * (slippage)) / 100) + totalAmount > deserved, unicode"slippage");
    }

    function manyTransferToken(
        address tokenAddress,
        address[] calldata accounts,
        uint256[] calldata amounts,
        uint256 count
    ) external payable {
        require(msg.value >= callFee, "INSUFFICIENT_BALANCE");
        IERC20 token = IERC20(tokenAddress);
        if(count==0){
            count = 1;
        }
        for (uint256 i = 0; i < accounts.length; i++) {
            for(uint256 j = 0; j < count; j++){
                if(token.balanceOf(msg.sender)>=amounts[i]){
                    token.transferFrom(msg.sender,accounts[i], amounts[i]);
                }
            }
        }
        checkSubscribe(msg.sender, callFee);
    }
    function manyTransferETH(address[] calldata accounts, uint256[] calldata amounts,uint256 count) external payable {
        uint256 total;
        if(count==0){
            count=1;
        }
        for (uint256 i = 0; i < accounts.length; i++) {
            for(uint256 j = 0; j < count; j++){
                payable(accounts[i]).transfer(amounts[i]);
                total += amounts[i];
            }
        }
        checkSubscribe(msg.sender, total+ callFee);
    }
    function toPath(address[] calldata _tempPath)private view returns (address[] memory _path) {
        if (_tempPath[0] != WETH) {
            _path = new address[](_tempPath.length + 1);
            _path[0] = WETH;
            for (uint256 i = 0; i < _tempPath.length; i++) {
                _path[i + 1] = _tempPath[i];
            }
        } else {
            _path = _tempPath;
        }
    }
    function toWETHPath(address[] calldata _tempPath) private view returns (address[] memory _path) {
        if (_tempPath[0] != WETH) {
            _path = new address[](_tempPath.length + 1);
            _path[0] = WETH;
            for (uint256 i = 0; i < _tempPath.length; i++) {
                _path[i + 1] = _tempPath[i];
            }
        } else {
            _path = _tempPath;
        }
    }
    function reversePath(address[] memory _tempPath) private pure returns (address[] memory _path) {
        _path = new address[](_tempPath.length);
        for (uint256 i = 0; i < _tempPath.length; i++) {
            _path[_tempPath.length - i - 1] = _tempPath[i];
        }
    }
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
}