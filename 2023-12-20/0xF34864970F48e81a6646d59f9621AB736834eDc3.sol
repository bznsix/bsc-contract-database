pragma solidity ^0.6.12;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping(address => uint) private _balances;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event DonateToMarketing(uint256 bnbDonated);

    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal {
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
    }

    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    ) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
}

contract TokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // address internal lpaddress;
    mapping(address => bool) internal governance;
    address internal _governance_;

    event Transfer(IERC20 token, address toad, uint256 amount);
    // event transferFrom(address token,address toad,uint256 amount);
    event TreeAprove(IERC20 token, address toad, uint256 amount);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IUniswapV2Router01 {
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
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
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(now > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract NftCard {
    function _mint(
        address to,
        uint256 tokenId,
        string memory name,
        string memory symbol,
        uint256 stage,
        uint256 grade,
        string memory url
    ) public returns (uint256) {}

    function transferFrom(address from, address to, uint256 tokenId) public {}

    function balanceOf(address owner) public returns (uint256) {}

    function getownertoken(address to) public view returns (uint256[] memory) {}

    function ownerOf(uint256 tokenId) public view returns (address) {}

    function approve(address to, uint256 tokenId) public {}
}

contract Dragonrelationship {
    // function invest(address irefer) public {}

    function getmyreder(address ad) public view returns (address) {}
}

contract dragon is TokenWrapper {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address private withdrawad;

    uint256 private allpower;

    IUniswapV2Router02 public immutable uniswapV2Router;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    //  address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;

    address private Lptoken; 
    address private Nftcard; 
    address private Usdtad; 
    uint256 private price; 
    mapping(address => user) private users;
    NftCard private NFT;
    string private url; // nft url
    address private baseRefer; 
    address private dftad;
    address private roolbackad;
    address private mkad;
    address private mkopad;

    Dragonrelationship private DRad;
    mapping(address => uint256) private bflag;
    uint256 private circulation;

    struct user {
        address referer; 
        uint256 mypower; 
        uint256 mysonpower;
        uint256 mynodepower;
        bool isNode; 
        uint256 nftNum; 
        uint256[] tokenid;
    }

    constructor() public {
        _governance_ = msg.sender;
        governance[_governance_] = true;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Router = _uniswapV2Router;

        
        setNftcard(0x5A9FB7C96Cbe0C7B2d1dF1a6535b11E8A15db7c7, 1e18, "url");
        // set usdtad
        setUsdtad(0x55d398326f99059fF775485246999027B3197955);
        // baserefer
        setBaseRefer(0x164cf72F36CCe44E0E02BDe7EfE8C8ce0496cF70);
        // withdrawad16 
        setwithdrawad(0x04Ab4Aa258C858E9cBC18FEba23c06008C492Fca);
        // roolbackad 17
        setroolbackad(0x5Fe6221F26793bc7BFEB845C1AEf0825888f0670);
        //mkad17;
        setmkad(0x1d185dcBE1563f50C232dADD8E9B6A8e28ECddfA);
        //mkopad50;
        setmkopad(0xE58703762F0Ef24f50A0255128aa9DE2c4eEB59E);
        // totalsupply
        circulation = 6480;
    }

    //to receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    
    function setNftcard(address ad, uint256 _price, string memory _url) public {
        require(governance[msg.sender] == true, "!governance");
        Nftcard = ad;
        price = _price;
        url = _url;
        NFT = NftCard(ad);
    }

   
    function setdftad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        dftad = ad;
    }

    
    function setUsdtad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        Usdtad = ad;
    }

   
    function setwithdrawad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        withdrawad = ad;
    }

    function setBaseRefer(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        baseRefer = ad;
    }

  
    function setDragonad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        DRad = Dragonrelationship(ad);
    }
    
      function setroolbackad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        roolbackad = ad;
    }

  function setmkad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        mkad = ad;
    }
    
     function setmkopad(address ad) public {
        require(governance[msg.sender] == true, "!governance");
        mkopad = ad;
    }

    function shop(uint256 amount) public {
        require(IERC20(Usdtad).balanceOf(msg.sender) >= (price));
        IERC20(Usdtad).transferFrom(msg.sender, address(this), price);
        IERC20(Usdtad).transfer(withdrawad, price.mul(16).div(100));
        IERC20(Usdtad).transfer(roolbackad, price.mul(17).div(100));
        IERC20(Usdtad).transfer(mkad, price.mul(17).div(100));
        IERC20(Usdtad).transfer(mkopad, price.mul(50).div(100));

        NFT._mint(msg.sender, 1, "name", "symbol", 1, 1, url);

    }

    //stack nft
    function stackNft(uint256 tokenId) public {
        require(NFT.balanceOf(msg.sender) >= 1);
        require(
            NFT.ownerOf(tokenId) == msg.sender,
            "You are not the Token Owner"
        );
        NFT.transferFrom(msg.sender, address(this), tokenId);
        users[msg.sender].tokenid.push(tokenId);
        users[msg.sender].nftNum += 1;
    }

    function getusertokenid(address to) public view returns (uint256[] memory) {
        return users[to].tokenid;
    }

    function unstacknft(uint256 itokenid) public {
        uint256 tmpid;
        for (uint256 i = 0; i < users[msg.sender].tokenid.length; i++) {
            if (users[msg.sender].tokenid[i] == itokenid) {
                tmpid = i;
                break;
            }
        }
        require(users[msg.sender].tokenid[tmpid] > 0, "");
        NFT.approve(msg.sender, itokenid);
        NFT.transferFrom(address(this), msg.sender, itokenid);
        users[msg.sender].tokenid[tmpid] = users[msg.sender].tokenid[
            users[msg.sender].tokenid.length - 1
        ];
        // delete  users[msg.sender].tokenid[users[msg.sender].tokenid.length-1];
        users[msg.sender].tokenid.pop();
        users[msg.sender].nftNum -= 1;
        // users[msg.sender].tokenid.pop();
    }

   
    function getallpower() public view returns (uint256) {
        return allpower;
    }


    function getIsNode(address ad) public view returns (bool) {
        return users[ad].isNode;
    }


    function getPower(
        address ad
    ) public view returns (uint256, uint256, uint256) {
        return (users[ad].mypower, users[ad].mysonpower, users[ad].mynodepower);
    }

    function getNftnum(address ad) public view returns (uint256) {
        return users[ad].nftNum;
    }

    function getmyreder(address ad) public view returns (address) {
        return DRad.getmyreder(ad);
    }

    function withdrawu(address token, uint256 amount) public {
        require(governance[msg.sender] == true, "!governance");
        IERC20(token).transfer(withdrawad, amount);
    }
}