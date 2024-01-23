// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.17 <= 0.9.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
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
interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
contract Ownable {
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnship(address newowner) public onlyOwner returns (bool) {
        owner = newowner;
        return true;
    }
}
abstract contract Context{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract BonusPool is Ownable {
    using SafeMath for uint256;

    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private ADE = address(0x9fE76B1c61681B2e30A3A79E202E2fC1597Efc09);
    address private ADEF = address(0xC3416a7ebfb50a05E37e3427BCE3844eA427A060);
    address private constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 leastAmount = 1;
    ISwapRouter private _swapRouter = ISwapRouter(PancakeRouter);
    ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
    address usdtPair = swapFactory.getPair(ADE, USDT);

    bool private inPlant;
    modifier lockThePlant {
        require(!inPlant, 'LOCKED');
        inPlant = true;
        _;
        inPlant = false;
    }
    constructor() {
        IERC20(ADE).approve(PancakeRouter, type(uint256).max);
        IERC20(USDT).approve(PancakeRouter, type(uint256).max);
    }
    function setADE(address token) public onlyOwner {
        IERC20(ADE).approve(PancakeRouter, 0);
        ADE = token;
        IERC20(ADE).approve(PancakeRouter, type(uint256).max);
        usdtPair = swapFactory.getPair(ADE, USDT);
    }
    function setADEF(address token) public onlyOwner {
        ADEF = token;
    }
    function setLeastAmount(uint _amount) external onlyOwner {
        leastAmount = _amount;
    }
    function getAmountsOut(uint256 value) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = ADE;
        return _swapRouter.getAmountsOut(value, path)[1];
    }

    function swap(uint256 _value) external lockThePlant{
        require(_value >  0, "value is zero");
        require(_value <= IERC20(USDT).balanceOf(msg.sender), "ERC20: transfer amount exceeds balance");

        require(_value >= leastAmount,"The planting quantity is too small");

        uint256 tokenAmount = getAmountsOut(_value).div(30).mul(100);

        require(IERC20(ADE).balanceOf(address(this)) >= tokenAmount,"Planting has ended");
        require(IERC20(ADEF).balanceOf(address(this)) >= tokenAmount,"Planting has ended");


        IERC20(USDT).transferFrom(msg.sender,address(this), _value);//付款U

        IERC20(ADEF).transfer(msg.sender, tokenAmount);

        uint reserveA = IERC20(USDT).balanceOf(usdtPair);
        uint reserveB = IERC20(ADE).balanceOf(usdtPair);
        
        uint amountB = _swapRouter.quote(_value, reserveA, reserveB);
        _addLiquidity(_value,amountB);

    }
    function _addLiquidity(uint256 _usdtAmount , uint256 _tokenAmount) private {
        _swapRouter.addLiquidity(
            USDT,
            ADE,
            _usdtAmount,
            _tokenAmount,
            0,
            0,
            address(0),
            (block.timestamp + 1)
        );
    }

    function withdraw(address token,address _to,uint256 amount) public onlyOwner returns(bool) {
        IERC20(token).transfer(_to,amount);
        return true; 
    }
}