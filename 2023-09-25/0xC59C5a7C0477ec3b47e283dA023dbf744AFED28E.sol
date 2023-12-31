pragma solidity >=0.5.0;

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
pragma solidity >=0.6.2;

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
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Interfaces/IERC20.sol";
import "./Interfaces/ILiquidityManagerFactory.sol";
import "./Interfaces/ILiquidityManager.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./Utils/Ownable.sol";

/* 
Token Designed By @CosmicCommander
Want to join me?
Reach me at: https://t.me/ComicTokens
*/

contract CosmicPepe is Ownable, IERC20 {

    string private constant _name = 'CosmicPepe';
    string private constant _symbol = 'COSPEPE';

    uint8 private constant _decimals = 18;
    uint private constant _totalSupply = 100_000_000_000 * 10**_decimals;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    mapping(address => bool) taxExempt;

    mapping(address => bool) liquidityPool;
    address[] public liquidityPools;

    ILiquidityManager public liquidityManager;
    ILiquidityManagerFactory public lmFactory;

    IUniswapV2Router02 internal router;
    IUniswapV2Factory internal factory;

    address public developerAddress;

    uint public buyTax = 40;        // 4%
    uint public sellTax = 40;       // 4%
    uint public transferTax = 40;   // 4%
    uint public maxTax = 50;    // 5%

    struct TaxDestinations {
        uint burn;
        uint developer;
        uint liquidity;
    }

    TaxDestinations public taxDestinations;

    uint public liquifyTrigger = 10; // 1%
    
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint public percentageResolution = 1000;

    event TaxChanged(string taxType, uint value);
    event LiquifyTriggerChanged(uint newTrigger);
    event TaxExemptAdded(address indexed addr);
    event TaxExemptRemoved(address indexed addr);

    modifier onlyAuthorized() {
        require(msg.sender == owner() || msg.sender == address(liquidityManager), "onlyAuthorized: FORBIDDEN");
        _;
    }

    receive() external payable {}

    constructor(address _lmFactory, address _router) {
        router = IUniswapV2Router02(_router);
        factory = IUniswapV2Factory(router.factory());
        liquidityManager = ILiquidityManager(ILiquidityManagerFactory(_lmFactory).create(address(this), _router, owner()));
        address pair = liquidityManager.pair();
        liquidityPool[pair] = true;
        liquidityPools.push(pair);
        taxExempt[address(liquidityManager)] = true;
        taxExempt[msg.sender] = true;
        uint developerTokens = _totalSupply * 10 / 100;
        _balances[msg.sender] = developerTokens;
        _balances[address(liquidityManager)] = _totalSupply - developerTokens;
        taxDestinations = TaxDestinations({
            burn: 50,
            developer: 50,
            liquidity: 100
        });
        developerAddress = msg.sender;
    }

    /////////////////////////////////
    /////    ERC20 FUNCTIONS    /////
    /////////////////////////////////

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}

    function totalSupply() external pure returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view returns (uint) {
        return _allowances[holder][spender];
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        require(_allowances[from][msg.sender] >= value, "transferFrom: INSUFFICIENT_ALLOWANCE");
        if (_allowances[from][msg.sender] != type(uint).max) {
            _allowances[from][msg.sender] = _allowances[from][msg.sender] - value;
        }
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint value) private {
        require(_balances[from] >= value, "_transfer: INSUFFICIENT_BALANCE");
        _balances[from] -= value;
        uint fee;
        // buy
        if (liquidityPool[from]) {
            fee = value*buyTax/percentageResolution;
        }
        // sell
        else if (liquidityPool[to]) {
            fee = value*sellTax/percentageResolution;
        }
        // transfer
        else {
            fee = value*transferTax/percentageResolution;
        }
        if (taxExempt[from] || taxExempt[to]) {
            fee = 0;
        }
        _balances[to] = _balances[to] + value - fee;

        uint totalWeight = taxDestinations.burn + taxDestinations.developer + taxDestinations.liquidity;
        uint developerAmount = (fee * taxDestinations.developer) / totalWeight;
        uint burnAmount = (fee * taxDestinations.burn) / totalWeight;
        uint liquidityAmount = (fee * taxDestinations.liquidity) / totalWeight;

        _balances[deadAddress] += burnAmount;
        _balances[developerAddress] += developerAmount;
        _balances[address(liquidityManager)] += liquidityAmount + _balances[address(this)];
        _balances[address(this)] = 0;

        if (address(liquidityManager) != address(0) && liquidityManager.liquidityAdded() && !liquidityManager.addLiquidityLocked()) {
            uint circulatingSupply = _getCirculatingSupply();
            if (_balances[address(liquidityManager)] >= (circulatingSupply * liquifyTrigger)/percentageResolution ) {
                ILiquidityManager(liquidityManager).fromTokenAddLiquidity();
            }
        }
        emit Transfer(from, to, value - fee);
    }

    function approve(address spender, uint value) external returns (bool) {
		require(spender != address(0), "approve: ZERO_ADDRESS");
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseApproval(address spender, uint value) external returns (bool) {
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender] + value;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseApproval(address spender, uint value) external returns (bool) {
        uint oldValue = _allowances[msg.sender][spender];
        if (value > oldValue) {
            _allowances[msg.sender][spender] = 0;
        }
        else {
            _allowances[msg.sender][spender] = oldValue - value;
        }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    //////////////////////////////////
    /////   SUPPLY FUNCTIONS    /////
    /////////////////////////////////

    function getCirculatingSupply() public view returns (uint) {
        return _getCirculatingSupply();
    }

    function _getCirculatingSupply() internal view returns (uint) {
        return _totalSupply - (_balances[address(this)] + _balances[deadAddress]);
    }

    ////////////////////////////////////
    /////   LIQUIDITY FUNCTIONS    /////
    ////////////////////////////////////

    function setLiquifyTrigger(uint newTrigger) external onlyOwner {
        require(newTrigger > 0 && newTrigger <= percentageResolution, "setLiquifyTrigger: INVALID_VALUE");
        liquifyTrigger = newTrigger;
        emit LiquifyTriggerChanged(newTrigger);
    }

    ////////////////////////////////
    /////    TAX FUNCTIONS    /////
    ///////////////////////////////

    function addTaxExempt(address _addr) external onlyAuthorized {
        require(_addr != address(0), "addTaxExempt: ZERO_ADDRESS");
        require(!taxExempt[_addr], "addTaxExempt: ALREADY_ADDED");
        taxExempt[_addr] = true;
        emit TaxExemptAdded(_addr);
    }

    function removeTaxExempt(address _addr) external onlyAuthorized {
        require(_addr != address(0), "removeTaxExempt: ZERO_ADDRESS");
        require(taxExempt[_addr], "removeTaxExempt: NOT_FOUND");
        taxExempt[_addr] = false;
        emit TaxExemptRemoved(_addr);
    }

    function isTaxExempt(address _addr) external view returns (bool) {
        return taxExempt[_addr] == true;
    }

    function getBuyTax() external view returns (uint) {
        return buyTax;
    }

    function getSellTax() external view returns (uint) {
        return sellTax;
    }

    function getTransferTax() external view returns (uint) {
        return transferTax;
    }

    function setBuyTax(uint _tax) external onlyOwner {
        require(_tax <= maxTax, "setBuyTax: INVALID_VALUE");
        buyTax = _tax;
        emit TaxChanged("BuyTax", _tax);
    }

    function setSellTax(uint _tax) external onlyOwner {
        require(_tax <= maxTax, "setSellTax: INVALID_VALUE");
        sellTax = _tax;
        emit TaxChanged("SellTax", _tax);
    }

    function setTransferTax(uint _tax) external onlyOwner {
        require(_tax <= maxTax, "setTransferTax: INVALID_VALUE");
        transferTax = _tax;
        emit TaxChanged("TransferTax", _tax);
    }

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint value) external returns (bool);
  function approve(address spender, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILiquidityManager {
    function pair() external view returns (address);
    function liquidityAdded() external view returns (bool);
    function addLiquidityLocked() external view returns (bool);
    function liquidityLockTimes() external view returns (uint developer, uint protocol);
    function addLiquidity(uint ethAmount, uint tokenAmount) external returns (uint, uint, uint);
    function fromTokenAddLiquidity() external returns (uint256, uint256, uint256);
    function fromEthAddLiquidity() external returns (uint256, uint256, uint256);
    function removeLiquidityByPercentage(uint percentage) external returns (uint256, uint256);
    function removeLiquidity(uint lpAmount) external returns (uint256, uint256);
    function swapTokenForEth(uint tokenAmount) external returns (uint256);
    function swapEthForToken(uint ethAmount) external returns (uint256);
    function withdrawEthToAddress(uint _value, address to) external;
    function withdrawTokenToAddress(uint _value, address to) external;
    function withdrawLiquidityToAddress(uint lpTokens, address to) external;
    function withdrawDevLiquidityToAddress(address to) external;
    function getReserves() external view returns (uint256, uint256);
    function quoteTokenPrice(uint256 _amount) external view returns (uint256);
    function getBalanceOfEth() external view returns (uint);
    function getBalanceOfToken() external view returns (uint);
    function getBalanceOfLiquidity() external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ILiquidityManagerFactory {
    function create(address tokenAddress, address routerAddress, address owner) external returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Ownable {

  address private _owner;

  event OwnershipRenounced();
  event OwnershipTransferred();

  constructor() {
    _owner = msg.sender;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "Ownable: ONLY_OWNER");
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Ownable: INVALID_ADDRESS");
    _owner = _newOwner;
    emit OwnershipTransferred();
  }

  function renounceOwnership() public onlyOwner {
    _owner = address(0);
    emit OwnershipRenounced();
  }

}
