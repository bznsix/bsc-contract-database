/**
 *Submitted for verification at Arbiscan.io on 2023-11-02
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-21
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);


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


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

   
}

contract lingx is Ownable {
    using SafeMath for uint256;
    address public uusdt;
    address public utoken;
    address public ueth;

    IERC20 public USDT ;
    IERC20 public Token;
    IERC20 public Eth;
    IERC20 public Btc;

    mapping(address => uint256) public guanli;
    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    uint256 public huiliu = 0;//
    uint256 public listCount = 0;
    uint256 public xianzhi = 10;
    mapping (uint256 => address) public listToOwner;
    mapping (uint256 => uint256) public listnum;
    mapping (uint256 => uint256) public listtype;
    address public uniswapV2Pair;
    address public uniswapV2Pairold;
    address public pair_btc;
    address public pair_eth;
    address public pair_arb;
    address public fund1Address = address(0x1CA27A7C18bEde4bF336ba08fdCe9306c38b7030);
    address public haveAddress = address(0x310cE302cD69bA11E87070a057A9032881c269E3);
    address public shouAddress = address(0x9139c1aAE5E9D229C25dA805C86cA40200aE8681);
    uint256 public _mintTotal;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //0x10ED43C718714eb63d5aA57B78B54704E256024E 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    // arbiscan   0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506    
    constructor(address tokenOwner) {
        setMintTotal(_mintTotal);
        guanli[_owner]=1;
        guanli[haveAddress]=1;
        guanli[msg.sender]=1;
        _owner = tokenOwner;
    }

    receive() external payable {}


    function changeRouter(address _router,address _routerold,address _pair_btc,address _pair_eth)public onlyOwner  {
        uniswapV2Pair = _router;
        uniswapV2Pairold = _routerold;
        pair_btc = _pair_btc;
        pair_eth = _pair_eth;
        //pair_arb = _pair_arb;
    }

    function setMintTotal(uint256 mintTotal) private {
        _mintTotal = mintTotal;
    }

    function kill() public onlyOwner{
        selfdestruct(payable(msg.sender));
    }

    function swapusdtbuy
        (uint256 tokenAmount) public {
        require(guanli[msg.sender]==1,"no sir");
        require(USDT.balanceOf(msg.sender)>=tokenAmount,"no usdt");
		address[] memory path = new address[](3);
        path[0] = uusdt;
        path[1] = ueth;
        path[2] = utoken;
        USDT.transferFrom(msg.sender,address(this), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            shouAddress,
            block.timestamp
        );
    }

    function userbaodan(uint256 _num) public {
        require(USDT.balanceOf(msg.sender)>=_num*10**18,"no usdt");
        require(_num>=xianzhi,"no usdt");
        address[] memory path = new address[](3);
        path[0] = uusdt;
        path[1] = ueth;
        path[2] = utoken;
        uint256 shuliang = _num*10**18;
        
        USDT.transferFrom(msg.sender,shouAddress, shuliang.div(100).mul(70));
        USDT.transferFrom(msg.sender,address(this), shuliang.div(100).mul(30));
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            shuliang.div(100).mul(30),
            0,
            path,
            _destroyAddress,
            block.timestamp
        );
        Token.transfer(msg.sender, 100000000000000000);
        listCount = listCount+1;
        listToOwner[listCount] = msg.sender;
        listnum[listCount] = _num;
        listtype[listCount] = 1;
    }
    /*
    function userbaodan2(uint256 _num) public {
        //require(USDT.balanceOf(msg.sender)>=_num*10**18,"no usdt");
        //require(_num>=xianzhi,"no usdt");
        address[] memory path = new address[](3);
        path[0] = uusdt;
        path[1] = ueth;
        path[2] = utoken;
        uint256 shuliang = _num*10**18;
        
        USDT.transferFrom(msg.sender,shouAddress, shuliang.div(100).mul(70));
        USDT.transferFrom(msg.sender,address(this), shuliang.div(100).mul(30));
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            shuliang.div(100).mul(30),
            0,
            path,
            _destroyAddress,
            block.timestamp
        );
        //Token.transfer(msg.sender, 100000000000000000);
        //listCount = listCount+1;
        //listToOwner[listCount] = msg.sender;
        //listnum[listCount] = _num;
        //listtype[listCount] = 1;
    }
    function userbaodan3(uint256 _num) public {
        require(USDT.balanceOf(msg.sender)>=_num*10**18,"no usdt");
        require(_num>=xianzhi,"no usdt");
        address[] memory path = new address[](3);
        path[0] = uusdt;
        path[1] = ueth;
        path[2] = utoken;
        uint256 shuliang = _num*10**18;
        

        Token.transfer(msg.sender, 100000000000000000);
        listCount = listCount+1;
        listToOwner[listCount] = msg.sender;
        listnum[listCount] = _num;
        listtype[listCount] = 1;
    }
    function userbaodan4(uint256 _num) public {

        uint256 shuliang = _num*10**18;
        
        USDT.transferFrom(msg.sender,shouAddress, shuliang.div(100).mul(70));
        USDT.transferFrom(msg.sender,address(this), shuliang.div(100).mul(30));

       
    }*/
    
    function userbaodantoken(uint256 _num) public {
        uint256 shuliang = _num*10**18;
        require(USDT.balanceOf(msg.sender)>=shuliang.div(100).mul(70),"no usdt");
        require(_num>=xianzhi,"no usdt");
        uint256 _priceu_a=(USDT.balanceOf(uniswapV2Pairold)*1000000/Eth.balanceOf(uniswapV2Pairold));//usdt/arb
        uint256 _pricea_t=(Eth.balanceOf(uniswapV2Pair)*1000000/Token.balanceOf(uniswapV2Pair));//usdt/token
        uint256 _price = (_priceu_a*_pricea_t)/1000000;
        require(Token.balanceOf(msg.sender)>=(shuliang.div(100).mul(30)*1000000/_price),"no token ");
        //require(Token.balanceOf(msg.sender)>=100000000000000000,"no token 0.1");
        USDT.transferFrom(msg.sender,shouAddress, shuliang.div(100).mul(70));
        Token.transferFrom(msg.sender,_destroyAddress,((shuliang.div(100).mul(30)*1000000/_price)));
        Token.transfer(msg.sender, 100000000000000000);
        listCount = listCount+1;
        listToOwner[listCount] = msg.sender;   
        listnum[listCount] =_num;
        listtype[listCount] = 2;
    }
    
    function get_token_num(  uint256  _num) public view returns(uint256 _getnum) {
        uint256 shuliang = _num*10**18;
        uint256 _priceu_a=(USDT.balanceOf(uniswapV2Pairold)*1000000/Eth.balanceOf(uniswapV2Pairold));//usdt/arb
        uint256 _pricea_t=(Eth.balanceOf(uniswapV2Pair)*1000000/Token.balanceOf(uniswapV2Pair));//usdt/token
        uint256 _price = (_priceu_a*_pricea_t)/1000000;
        _getnum = shuliang.div(100).mul(30)*1000000/_price;
        return _getnum;
    }


    function get_list_one(  uint256  _id) public view returns(address _user,uint256 _num,uint256 _type) {
        _user = listToOwner[_id];
        _num = listnum[_id];
        _type = listtype[_id];
        return (_user,_num,_type);
    }


    function a_set_token(IERC20 _USDT,IERC20 _Token,IERC20 _Eth  ,address _uusdt,address _utoken ,address _ueth,IERC20 _Btc) public {
        require(guanli[msg.sender]==1,"no sir");////uarb Arb
        USDT = _USDT;
        Token = _Token;
        Eth = _Eth;
        uusdt = _uusdt;
        utoken = _utoken;
        ueth = _ueth;
        Btc = _Btc;
    }




    function admin_tixian(address payable _to)  public {
        require(guanli[msg.sender]==1,"no sir");
        _to.transfer(address(this).balance);
    }
      
    function sir_set_sir(address _user,uint256 _ttype) public {
        require(guanli[msg.sender]==1,"no sir");
        guanli[_user]=_ttype;
    }
    
    function sir_set_xianzhi(uint256 _xianzhi) public {
        require(guanli[msg.sender]==1,"no sir");
        xianzhi=_xianzhi;
    }
    //ueth Eth
    function get_price() external view returns(uint256 _price) {
        uint256 _priceu_a=(USDT.balanceOf(uniswapV2Pairold)*1000000/Eth.balanceOf(uniswapV2Pairold));//usdt/arb
        uint256 _pricea_t=(Eth.balanceOf(uniswapV2Pair)*1000000/Token.balanceOf(uniswapV2Pair));//usdt/token
        _price = (_priceu_a*_pricea_t)/1000000;
    }
//get_price get_price_btc get_price_eth get_price_arb
    function get_price_btc() external view returns(uint256 _price) {
        _price=(USDT.balanceOf(pair_btc)*1000000/Btc.balanceOf(pair_btc));//usdt/btc
    }
    function get_price_eth() external view returns(uint256 _price) {
        _price = (USDT.balanceOf(pair_eth)*1000000/Eth.balanceOf(pair_eth));//usdt/eth
    }


    function  token_take(address toaddress,uint256 amount ) public {
        require(guanli[msg.sender]==1,"no sir");
        Token.transfer(toaddress, amount);
    }
    function  usdt_take(address toaddress,uint256 amount ) public {
        require(guanli[msg.sender]==1,"no sir");
        USDT.transfer(toaddress, amount);
    }

    function a_approve() public {
        require(guanli[msg.sender]==1,"no sir");//uarb Arb
        USDT.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 1000000000000000000000000000);
        Token.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 100000000000000000000000000);
        Eth.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 100000000000000000000000000);
    }//0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    //0x9a489505a00cE272eAa5e07Dba6491314CaE3796
    //0x10ED43C718714eb63d5aA57B78B54704E256024E
    


}