// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/SafeMath.sol";
import "./libs/SafeERC20.sol";
import "./libs/DaoOwnable.sol";
import "./libs/interface/IWETH.sol";
import "./libs/interface/IwsMeta.sol";
import "./libs/interface/IBond.sol";
import "./libs/interface/IStaking.sol";
import "./libs/interface/IStakingHelper.sol";
import "./libs/interface/IPancakePair.sol";
import "./libs/interface/IPancakeRouter02.sol";

contract MetaZap is DaoOwnable{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private constant DAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
    address private constant Meta = 0x0a2046C7fAa5a5F2b38C0599dEB4310AB781CC83;
    address private constant sMeta = 0x09f33EC33052Cd253Db79fFA883E9c12Eb578309;
    address private constant wsMeta = 0x29EB42FeE61A516d1fa514a93A3067Da4C13f9d8;
    IPancakeRouter02 private constant ROUTER = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IStakingHelper private constant MetaStakingHelper = IStakingHelper(0x696737aB721bde6b53c118EE67FcE6C0eC55E9A3);
    IStaking private constant MetaStaking = IStaking(0xB91Db0C2551AAe4784119cE4c33234C9E3c9aF71);

    mapping(address => bool) private HasApprovedRouter;
    address[] public supportTokens;
    mapping(IBond => uint8) public BondIsLP; // 0 not whitelisted, 1 not LP, 2 is LP

    // === management functions starts ===

    function approveForRouter(address token) public onlyManager{
        if(HasApprovedRouter[token]) return;
        IERC20(token).approve(address(ROUTER), uint(-1));
        HasApprovedRouter[token] = true;
        supportTokens.push(token);
    }

    function addBond(IBond bond, bool isLP) public onlyManager{
        BondIsLP[bond] = isLP ? 2 : 1;
        address p = bond.principle();
        IERC20(p).approve(address(bond), uint(-1));
        if(isLP){
            IPancakePair pair = IPancakePair(p);
            approveForRouter(pair.token0());
            approveForRouter(pair.token1());
        }
    }

    function rescueToken(address[] calldata tokens) external onlyManager {
        for (uint i=0; i < tokens.length; i++){
            IERC20 token = IERC20(tokens[i]);
            uint amount = token.balanceOf(address(this));
            token.safeTransfer(manager(), amount);
        }
    }

    function sweep() external onlyManager {
        for (uint i = 0; i < supportTokens.length; i++) {
            address token = supportTokens[i];
            if (token == address(0) || token == WBNB) continue;
            uint amount = IERC20(token).balanceOf(address(this));
            if (amount > 0) {
                _swapDirect(token, amount, WBNB);
            }
        }
        IWETH(WBNB).withdraw(IERC20(WBNB).balanceOf(address(this)));
        payable(manager()).transfer(payable(address(this)).balance);
    }

    receive() external payable {} // allow receiving BNB

    // === manage functions ends ===

    constructor(){
        require(ROUTER.WETH() == WBNB);
        approveForRouter(WBNB);
        approveForRouter(BUSD);
        approveForRouter(USDT);
        approveForRouter(USDC);
        approveForRouter(DAI);
        approveForRouter(Meta);
        IERC20(Meta).approve(address(MetaStakingHelper), uint(-1));
        IERC20(sMeta).approve(address(MetaStaking), uint(-1)); // allow for sMeta -> Meta
        IERC20(sMeta).approve(address(wsMeta), uint(-1)); // allow for sMeta -> wsMeta
        addBond(IBond(0xf7a38B0B960BaF5ECD065b915dDeD7d938d628bF), true); //Meta-USDT
        addBond(IBond(0x117A10D6944b18d652cbF428b0D7c97A65887063), true); //Meta-USDC
        addBond(IBond(0xa70694Ed3675D7fA8c453e77E905Bbf5Ba1c46A7), true); //Meta-BUSD
        addBond(IBond(0x839Ee222E84849C752Bff1bB129cf34578BcDEc1), false); //WBNB
        addBond(IBond(0x689615f501b1e143aa1Ed1C5736E9A57198B7173), false); //BUSD
		addBond(IBond(0x295923D9ED2De2f7164669b90328E9Bc43523256), false); //USDC
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) { 
        // convert uint to string, used in revert message
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

    function _swapDirect(address _from, uint amount, address _to) internal returns (uint){
        if(_from == _to) return amount; // no need to swap
        address[] memory path;
        path = new address[](2);
        path[0] = _from;
        path[1] = _to;
        uint[] memory amounts = ROUTER.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);
        return amounts[amounts.length - 1];
    }

    // === ZapAndStake starts ===
    // user input a token or BNB, swap it to Meta (direct or byPath), stake to sMeta, and output sMeta to user

    event ZapAndStaked(address indexed, uint256);

    function _ZapAndStake(address token, uint256 amount, uint256 minOutAmount) internal{
        uint256 MetaAmount;
        if(token != Meta){
            MetaAmount = _swapDirect(token, amount, Meta);
        }else{
            MetaAmount = amount;
        }
        require(MetaAmount >= minOutAmount, string(abi.encodePacked("slippage exceeds, can only receive ", uint2str(MetaAmount))));
        MetaStakingHelper.stake(MetaAmount, msg.sender);
        emit ZapAndStaked(msg.sender, MetaAmount);
    }

    function ZapAndStake(address token, uint256 amount, uint256 minOutAmount) public {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        return _ZapAndStake(token, amount, minOutAmount);
    }

    function BNBZapAndStake(uint256 minOutAmount) external payable{
        uint256 amount = msg.value;
        IWETH(WBNB).deposit{value: amount}();
        return _ZapAndStake(WBNB, amount, minOutAmount);
    }

    function _swapByPath(address[] calldata path, uint amount) internal returns (uint){
        if(path.length==1) return amount; // no need to swap
        uint[] memory amounts = ROUTER.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _ZapAndStakeByPath(address[] calldata path, uint256 amount, uint256 minOutAmount) public {
        require(path[path.length - 1]==Meta, "path should ends with Meta");
        uint256 MetaAmount = _swapByPath(path, amount);
        require(MetaAmount >= minOutAmount, string(abi.encodePacked("slippage exceeds, can only receive ", uint2str(MetaAmount))));
        MetaStakingHelper.stake(MetaAmount, msg.sender);
    }

    function ZapAndStakeByPath(address[] calldata path, uint256 amount, uint256 minOutAmount) external {
        address token = path[0];
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        return _ZapAndStakeByPath(path, amount, minOutAmount);
    }

    function BNBZapAndStakeByPath(address[] calldata path, uint256 minOutAmount) external payable{
        uint256 amount = msg.value;
        IWETH(WBNB).deposit{value: amount}();
        require(path[0]==WBNB, "path should start with WBNB");
        return _ZapAndStakeByPath(path, amount, minOutAmount);
    }

    // === ZapAndStake ends ===

    // === ZapAndBond starts ===
    // user input a token or BNB, swap it to bond principle (direct or byPath), buy bond for user

    // +++ ZapAndBond use direct swap starts +++

    function _swapToLPDirect(address token, uint256 amount, IPancakePair pair) internal returns (uint256 lpAmount) {
        //assume that token has been transfered to this contract
        //swap and add liquidity, receive LP to this
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint sellAmount = amount.div(2);
        pair.skim(address(this));
        uint token0Amount = _swapDirect(token, sellAmount, token0); // _swapDirect will not swap when token==token0
        uint token1Amount = _swapDirect(token, sellAmount, token1);
        (, , lpAmount) = ROUTER.addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, address(this), block.timestamp);
    }

    event ZapAndBonded(address indexed, address indexed, uint256);

    function _Bond(IBond bond, uint256 principleAmount, uint256 minOutAmount) internal{
		
		//redeem pending reward before deposit
		if(bond.pendingPayoutFor(msg.sender) > 0){
			bond.redeem(msg.sender, true);
		}
		
        uint256 bp = bond.bondPrice();
        uint256 outAmount = bond.deposit(principleAmount, bp, msg.sender);
        require(outAmount >= minOutAmount, string(abi.encodePacked("slippage exceeds, can only receive ", uint2str(outAmount))));
        emit ZapAndBonded(address(bond), msg.sender, outAmount);
    }

    function _ZapAndBond(address token, uint256 amount, IBond bond, uint256 minOutAmount) internal {
        uint8 isLP = BondIsLP[bond];
        require(isLP>0, "bond not whitelisted");
        address principle = bond.principle();
        uint256 principleAmount;
        if(isLP==2){
            IPancakePair pair = IPancakePair(principle);
            principleAmount = _swapToLPDirect(token, amount, pair); //token -> LP
        }else{
            principleAmount = _swapDirect(token, amount, principle); // token -> principle token
        }
        return _Bond(bond, principleAmount, minOutAmount);
    }

    function _getToken(address token, uint256 amount) internal returns (address){
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        if (token==wsMeta) {
            amount = IwsMeta(wsMeta).unwrap(amount);
            token = sMeta;
        }
        if (token==sMeta) {
            MetaStaking.unstake(amount, false);
            token = Meta;
        }
        return token;
    }

    function ZapAndBond(address token, uint256 amount, IBond bond, uint256 minOutAmount) external {
        token = _getToken(token, amount);
        return _ZapAndBond(token, amount, bond, minOutAmount);
    }

    function BNBZapAndBond( IBond bond, uint256 minOutAmount) external payable {
        uint256 amount = msg.value;
        IWETH(WBNB).deposit{value: amount}();
        return _ZapAndBond(WBNB, amount, bond, minOutAmount);
    }

    // +++ ZapAndBond use direct swap ends +++
    // +++ ZapAndBond use byPath swap for LP starts +++

    function _swapToLPByPath(address token, uint256 amount, address[] calldata path0, address[] calldata path1, IPancakePair pair) internal returns (uint256 lpAmount) {
        //assume that token has been transfered to this contract
        //swap and add liquidity, receive LP to this
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint sellAmount = amount.div(2);
        pair.skim(address(this));
        require(path0[0] == token && path0[path0.length-1]==token0, "incorrect path0");
        uint token0Amount = _swapByPath(path0, sellAmount);
        require(path1[0] == token && path1[path1.length-1]==token1, "incorrect path1");
        uint token1Amount = _swapByPath(path1, sellAmount);
        (, , lpAmount) = ROUTER.addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, address(this), block.timestamp);
    }

    function _ZapAndBondByPathLP(address token, uint256 amount, address[] calldata path0, address[] calldata path1, IBond bond, uint256 minOutAmount) internal {
        uint8 isLP = BondIsLP[bond];
        require(isLP==2, "only LP is supported for _ZapAndBondByPathLP");
        address principle = bond.principle();
        IPancakePair pair = IPancakePair(principle);
        uint256 principleAmount = _swapToLPByPath(token, amount, path0, path1, pair); //token -> LP
        return _Bond(bond, principleAmount, minOutAmount);
    }

    function ZapAndBondByPathLP(address token, uint256 amount, address[] calldata path0, address[] calldata path1, IBond bond, uint256 minOutAmount) external {
        token = _getToken(token, amount);
        return _ZapAndBondByPathLP(token, amount, path0, path1, bond, minOutAmount);
    }

    function BNBZapAndBondByPathLP(address[] calldata path0, address[] calldata path1, IBond bond, uint256 minOutAmount) external payable {
        uint256 amount = msg.value;
        IWETH(WBNB).deposit{value: amount}();
        return _ZapAndBondByPathLP(WBNB, amount, path0, path1, bond, minOutAmount);
    }
    // +++ ZapAndBond use byPath swap for LP ends +++

    // +++ ZapAndBond use byPath swap for Token starts +++
    function _ZapAndBondByPathToken(address token, uint256 amount, address[] calldata path, IBond bond, uint256 minOutAmount) internal {
        uint8 isLP = BondIsLP[bond];
        require(isLP==1, "only Token is supported for _ZapAndBondByPathToken");
        address principle = bond.principle();
        require(path[0]==token && path[path.length-1]==principle, "incorrect path");
        uint256 principleAmount = _swapByPath(path, amount); //token -> LP
        return _Bond(bond, principleAmount, minOutAmount);
    }

    function ZapAndBondByPathToken(address token, uint256 amount, address[] calldata path, IBond bond, uint256 minOutAmount) external {
        token = _getToken(token, amount);
        return _ZapAndBondByPathToken(token, amount, path, bond, minOutAmount);
    }

    function BNBZapAndBondByPathToken(address[] calldata path, IBond bond, uint256 minOutAmount) external payable {
        uint256 amount = msg.value;
        IWETH(WBNB).deposit{value: amount}();
        require(path[0]==WBNB, "path should start with WBNB");
        return _ZapAndBondByPathToken(WBNB, amount, path, bond, minOutAmount);
    }
    // +++ ZapAndBond use byPath swap for Token ends +++
    // === ZapAndBond ends ===
	
	function stakeAndWrap(uint256 amount) external returns(uint256){
		//stake Meta, get sMeta
		IERC20(Meta).safeTransferFrom(msg.sender, address(this), amount);
		MetaStakingHelper.stake(amount, address(this));
		
		//wrap sMeta to wsMeta
		uint256 wsMetaAmount = IwsMeta(wsMeta).wrap(amount);
		
		//send wsMeta back
		IERC20(wsMeta).transfer(msg.sender, wsMetaAmount);
		
		return wsMetaAmount;
	}
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IwsMeta {
    function wrap( uint _amount ) external returns ( uint );
	function unwrap( uint _amount ) external returns ( uint );
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IWETH {
    function approve(address spender, uint value) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);

    function deposit() external payable;
    function withdraw(uint amount) external;
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IStakingHelper {
    function stake( uint _amount, address _recipient ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IStaking {
    function stake( uint _amount, address _recipient ) external returns ( bool );
    function claim( address _recipient ) external;
	function unstake( uint _amount, bool _trigger ) external;
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IPancakeRouter01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
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
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IBond {
	function principle() external returns (address); 
    function bondPrice() external view returns ( uint price_ );
    function deposit( uint _amount, uint _maxPrice, address _depositor) external returns ( uint );
	function redeem( address _recipient, bool _stake ) external returns ( uint );
    function pendingPayoutFor( address _depositor ) external view returns ( uint pendingPayout_ );
	
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
	
	
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

    /*
     * Expects percentage to be trailed by 00,
    */
    function percentageAmount( uint256 total_, uint8 percentage_ ) internal pure returns ( uint256 percentAmount_ ) {
        return div( mul( total_, percentage_ ), 1000 );
    }

    /*
     * Expects percentage to be trailed by 00,
    */
    function substractPercentage( uint256 total_, uint8 percentageToSub_ ) internal pure returns ( uint256 result_ ) {
        return sub( total_, div( mul( total_, percentageToSub_ ), 1000 ) );
    }

    function percentageOfTotal( uint256 part_, uint256 total_ ) internal pure returns ( uint256 percent_ ) {
        return div( mul(part_, 100) , total_ );
    }

    /**
     * Taken from Hypersonic https://github.com/M2629/HyperSonic/blob/main/Math.sol
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function quadraticPricing( uint256 payment_, uint256 multiplier_ ) internal pure returns (uint256) {
        return sqrrt( mul( multiplier_, payment_ ) );
    }

	function bondingCurve( uint256 supply_, uint256 multiplier_ ) internal pure returns (uint256) {
		return mul( multiplier_, supply_ );
	}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.5;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

	/**
     * @dev Returns the decimals of token.
     */
	function decimals() external view returns (uint8);
	
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.7.5;

import "./IERC20.sol";
import "./Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
	uint8 private _decimals;
	

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
		_decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

contract DaoOwnable{

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function manager() public view returns (address) {
        return _owner;
    }

    modifier onlyManager() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public onlyManager() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public onlyManager() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
