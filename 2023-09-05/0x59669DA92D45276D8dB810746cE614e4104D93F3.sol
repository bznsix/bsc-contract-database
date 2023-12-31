//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;



import "./ozeppelin/Ownable.sol";
import "./ozeppelin/SafeMath.sol";

import "./interfaces/IERC20.sol";
import "./interfaces/IHonorRouter.sol";
import "./interfaces/IHonorFactory.sol";
import "./interfaces/IHonorPair.sol";
import "./interfaces/IHonorController.sol";
import "./interfaces/IRouterManager.sol";

contract HonorTreasureV1 is Ownable {
  using SafeMath for uint256;


  address public _busdToken;
  address public _honorToken;
  address public _wethToken;
  address public _honorRouter;

  IRouterManager private _routerManager;

  IHonorController public _honorController;

  address private _busdWETHPair;
  address private _busdHONORPair;
  address private _wethHONORPair;

  bool public _isLiq;

  struct FINANCE_CONTRACTS {
    bool isActive;
    uint256 totalWidthdraw;
    uint256 limit;
  }

  struct TreasureCoin 
  {
    address _wethPair;
    address _honorPair;
    uint256 deposited;
    uint256 widthdrawed;
    uint8 isLiq;
  }

  mapping(address=>TreasureCoin) public _treasureCoins;

  address[] public _treasureCoinList;

  mapping(address => FINANCE_CONTRACTS) public financeContracts;

  constructor(address busd,address honor,address honorRouter,address honorController) public {
    _honorRouter=honorRouter;
    _busdToken=busd;
    _honorToken=honor;

    _wethToken=IHonorRouter(_honorRouter).WETH();
    _honorController=IHonorController(honorController);

    IERC20(_busdToken).approve(_honorRouter,type(uint256).max);
    IERC20(_honorToken).approve(_honorRouter,type(uint256).max);
    IERC20(_wethToken).approve(_honorRouter,type(uint256).max);


    IHonorFactory factory=IHonorFactory(IHonorRouter(_honorRouter).factory());
    _busdWETHPair=factory.getPair(_busdToken, _wethToken);
    _busdHONORPair=factory.getPair(_busdToken, _honorToken);
    _wethHONORPair=factory.getPair(_honorToken, _wethToken);

    IERC20(_busdWETHPair).approve(_honorRouter,type(uint256).max);
    IERC20(_busdHONORPair).approve(_honorRouter,type(uint256).max);
    IERC20(_wethHONORPair).approve(_honorRouter,type(uint256).max);

    TreasureCoin storage tHonor=_treasureCoins[_honorToken];
    TreasureCoin storage tWeth=_treasureCoins[_wethToken];
    tHonor._honorPair=address(0);
    tWeth._wethPair=address(0);
    tHonor.isLiq=1;
    tWeth.isLiq=1;
    tHonor._wethPair=_wethHONORPair;
    tWeth._honorPair=_wethHONORPair;

    _treasureCoinList.push(_honorToken);
    _treasureCoinList.push(_wethToken);

  }


  function setRouterManager(address manager) public onlyOwner {
    _routerManager=IRouterManager(manager);

    _routerManager.setTreasureTokens(_treasureCoinList);
    
  }

  function setIsLiq(address token,uint8 set) public onlyOwner {
    TreasureCoin storage treasure=_treasureCoins[token];
    treasure.isLiq=set;
  }

  function addTreasureToken(address _token,uint8 isLiq) public onlyOwner {
    TreasureCoin storage tcoin=_treasureCoins[_token];
    IHonorFactory factory=IHonorFactory(IHonorRouter(_honorRouter).factory());

    tcoin._honorPair=factory.getPair(_token, _honorToken);
    tcoin._wethPair=factory.getPair(_token,_wethToken);
    IERC20 _ercToken=IERC20(_token);

    _ercToken.approve(_honorRouter,type(uint256).max);

    IERC20(tcoin._honorPair).approve(_honorRouter,type(uint256).max);
    IERC20(tcoin._wethPair).approve(_honorRouter,type(uint256).max);
    tcoin.isLiq=isLiq;

    _treasureCoinList.push(_token);
    
    if(address(_routerManager) !=address(0))
    {
      _routerManager.addTreasureToken(_token);
    }
  }

  function setFinanceContract(address _contract,bool isActive,uint256 limit) public onlyOwner {
    FINANCE_CONTRACTS storage fc=financeContracts[_contract];
    fc.isActive=isActive;
    fc.limit=limit;
  }

  function _removeLiquidity(address token0,address token1,uint256 amount) public onlyOwner {
    uint deadline=block.timestamp + 300;
     IHonorRouter(_honorRouter).removeLiquidity(token0, token1, amount, 1, 1, address(this), deadline);
  }

  function depositToken(address _token,uint256 amount) public {
    TreasureCoin storage tcoin=_treasureCoins[_token];
    
    IERC20(_token).transferFrom(msg.sender,address(_routerManager),amount);
    
    _routerManager.depositToken(_token,amount,tcoin.isLiq);
    
  }

  function depositWBNB(uint256 amount) public {
    TreasureCoin storage tcoin=_treasureCoins[_wethToken];

    IERC20(_wethToken).transferFrom(msg.sender,address(_routerManager),amount);
  
    _routerManager.depositWBNB(amount,tcoin.isLiq);
  }

  function depositHonor(uint256 amount) public {
     TreasureCoin storage tcoin=_treasureCoins[_honorToken];

    IERC20(_honorToken).transferFrom(msg.sender,address(_routerManager),amount);
  
    _routerManager.depositHonor(amount,tcoin.isLiq);
  }

  
    function widthdrawWETH(uint256 amount,address _to) public {
      FINANCE_CONTRACTS storage finance=financeContracts[msg.sender];
      require(finance.isActive==true && finance.limit>=amount,"Not Finance");

      uint deadline=block.timestamp+300;
      uint256 liquidity=IHonorPair(_wethHONORPair).balanceOf(address(this));
      if(liquidity>0)
      {
        IHonorRouter(_honorRouter).removeLiquidity(_wethToken, _honorToken, liquidity, 1, 1, address(this), deadline);
      }

      uint256 balance=IERC20(_wethToken).balanceOf(address(this));
      if(balance>=amount)
      {
        IERC20(_wethToken).transfer(_to,amount);
        
        balance=balance.sub(amount);
        if(balance>0)
        {
          IHonorRouter(_honorRouter).addLiquidity(_wethToken, _honorToken, balance, type(uint256).max, 1, 1, address(this), deadline);
        }
      }
      else
      {
        revert("Not WETH Balance");
      }
    }

    function widthdrawToken(address _token,uint256 amount,address _to) public {
      FINANCE_CONTRACTS storage finance=financeContracts[msg.sender];
      require(finance.isActive==true && finance.limit>=amount,"Not Finance");

      TreasureCoin storage tcoin=_treasureCoins[_token];
      require(tcoin._wethPair!=address(0),"NOT TOKEN");

      uint deadline=block.timestamp + 300;

      uint256 liquidity=IHonorPair(tcoin._honorPair).balanceOf(address(this));
      if(liquidity>0)
      {
        IHonorRouter(_honorRouter).removeLiquidity(_token, _honorToken, liquidity, 1, 1, address(this), deadline);
      }

      uint256 balance=IERC20(_token).balanceOf(address(this));
      if(balance>=amount)
      {
        IERC20(_token).transfer(_to,amount);
        
        balance=balance.sub(amount);
        if(balance>0)
        {
          IHonorRouter(_honorRouter).addLiquidity(_token, _honorToken, balance, type(uint256).max, 1, 1, address(this), deadline);
        }
      }
      else
      {
        revert("Not Balance");
      }
      tcoin.widthdrawed += amount;

    }
    

    function getPairReserve(address pair) public view returns(uint256 res0,uint256 res1) {
      (uint112 res_0,uint112 res_1,)=IHonorPair(pair).getReserves();
      uint256 balance=IHonorPair(pair).balanceOf(address(this));
      uint256 totalSupply=IHonorPair(pair).totalSupply();
      res0=uint256(res_0);
      res1=uint256(res_1);

      res0=res0.mul(balance).div(totalSupply);
      res1=res1.mul(balance).div(totalSupply);
    }

    function widthdrawHonor(uint256 amount,address _to) public {
      FINANCE_CONTRACTS storage finance=financeContracts[msg.sender];
      require(finance.isActive==true && finance.limit>=amount,"Not Finance");

      _honorController.getHonor(amount);

      IERC20(_honorToken).transfer(_to,amount);
    }
    
    function getWETHReserve() public view returns(uint256) {
      (uint256 res0,uint256 res1)=getPairReserve(_wethHONORPair);

      uint256 wethTotal=IHonorPair(_wethHONORPair).token0() == _wethToken ? res0 : res1;

      return wethTotal;
    } 

    function getTokenReserve(address token) public view returns(uint256) {
      TreasureCoin memory coins=_treasureCoins[token];
      (uint256 res0,uint256 res1)=getPairReserve(coins._honorPair);
      uint256 tokenTotal =  IHonorPair(coins._honorPair).token0() == token ? res0 : res1;

      return tokenTotal;
    }


    function getPairTokenReserve(address pair,address token) public view returns(uint256) {
      (uint112 res_0,uint112 res_1,)=IHonorPair(pair).getReserves();
      uint256 balance=IHonorPair(pair).balanceOf(address(this));
      uint256 totalSupply=IHonorPair(pair).totalSupply();

      uint112 _res=IHonorPair(pair).token0() == token ? res_0 : res_1;

      uint256 res=uint256(_res);
      
      return res.mul(balance).div(totalSupply);

    }

    function getPairAllReserve(address token0,address token1) public view returns(uint112 ,uint112 ) {
      address pair=IHonorFactory(IHonorRouter(_honorRouter).factory()).getPair(token0,token1);
      (uint112 res_0,uint112 res_1,)=IHonorPair(pair).getReserves();

      if(IHonorPair(pair).token0()==token0)
      {
        return (res_0,res_1);
      }
      else
      {
        return (res_1,res_0);
      }

    }

    function getHonorBUSDValue(uint256 amount) public view returns(uint256) {
      (uint112 res_0,uint112 res_1,)=IHonorPair(_busdHONORPair).getReserves();
      (uint256 honorRes,uint256 busdRes) = IHonorPair(_busdHONORPair).token0()==_honorToken ? (uint256(res_0),uint256(res_1)) : (uint256(res_1),uint256(res_0));
      return amount.mul(busdRes).div(honorRes);
    }

    function getBUSDHonorValue(uint256 amount) public view returns(uint256) {
      (uint112 res_0,uint112 res_1,)=IHonorPair(_busdHONORPair).getReserves();
      (uint256 honorRes,uint256 busdRes) = IHonorPair(_busdHONORPair).token0()==_honorToken ? (uint256(res_0),uint256(res_1)) : (uint256(res_1),uint256(res_0));
      return amount.mul(honorRes).div(busdRes);
    }
  
  function recoverEth() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function recoverTokens(address tokenAddress) external onlyOwner {
    IERC20 token = IERC20(tokenAddress);
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

}//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;


interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

interface IHonorController {
  function getHonor(uint256 amount) external;
}//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

interface IHonorFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

interface IHonorPair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function swap(uint256 amount0Out,	uint256 amount1Out,	address to,	bytes calldata data) external;
}//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

interface IHonorRouter {
  function factory() external pure returns (address);
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}
//SPDX-License-Identifier: MIT
pragma solidity =0.6.12;


interface IRouterManager 
{
  function depositToken(address tokenIn,uint256 amount,uint8 isLiq) external;
    
  function depositWBNB(uint256 amount,uint8 isLiq) external;

  function depositHonor(uint256 amount,uint8 isLiq) external;

  function setTreasureTokens(address[] memory tokens) external;

  function addTreasureToken(address token) external;

}// SPDX-License-Identifier: MIT


pragma solidity =0.6.12;


contract Context {

    constructor()  public {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// SPDX-License-Identifier: MIT


pragma solidity =0.6.12;

import  "./Context.sol";



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;



library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}