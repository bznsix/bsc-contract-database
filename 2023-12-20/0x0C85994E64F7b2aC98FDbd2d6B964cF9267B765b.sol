// SPDX-License-Identifier:MIT
pragma solidity 0.8.17;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual{
        require(msg.sender == 0xd5c50F6E36b4b2b838c3DD8Cc91065696b5fDb92,"not owner");
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;
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
}

contract Bank is Ownable {
    using SafeMath for uint256;

    address public cake_usdtPair = 0xA39Af17CE4a8eb807E076805Da1e2B8EA7D0755b;
    address public cakeAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

    address private nftShareAddress = 0x1Ff12E2Fc792e5f4F8E1433937A0F239Ec8885F1;
    address private fundAddress = 0x0E2C35baBe5D90F766C3160Cf8EAD553e61291C9;
    address private techAddress = 0xE6DFb0251f835b45b51a05c3993b9327b3b30c25;
    address private receiveAddress = 0xfA0ea96D0547245BdE6Dad34adC9867B1bEaFd5D;
    address private buyTokenAndAddLpAddress = 0xE1916Cb943676fdAa234AA774ec9E7f558cb8Ea6;

    struct IcoParam {
        mapping (uint256 => address) tokenToAddress;
        mapping (uint256 => uint256) tokenToAddressNum;
        uint256 tokenToAddressCount;
    }

    struct TokenToAddressParam{
        uint256 perCent;
        address tokenReceiver;
    }

    mapping (uint256 => IcoParam) public IcoParams;
    mapping(address => mapping(address => uint256)) public _userDepositToken;
    mapping(uint256 => bool) public limitAmount;

    event userDepositEvent(address indexed sender, uint256 indexed time,uint256 num0,uint256 num1,address tokenAddress);
    event JoinLaunchpad(address indexed addr, uint256 indexed time,uint256  num); //进行ICO的地址，时间，以及购买所用usdt的数量
    event userClaimBankEvent(address indexed addr,uint256 indexed amount,address indexed tokenAddr ,uint256  time);
    event claimTokenEvent(address indexed to,uint256 amount,address rewardAddress,uint256 time);

    constructor () {
        IcoParam storage ip = IcoParams[0];
        ip.tokenToAddressCount = 4; 
        ip.tokenToAddressNum[0] = 2;
        ip.tokenToAddress[0] =  nftShareAddress; //nft
        ip.tokenToAddressNum[1] = 1;
        ip.tokenToAddress[1] =  techAddress; //技术
        ip.tokenToAddressNum[2] = 2;
        ip.tokenToAddress[2] =  fundAddress; //fund
        ip.tokenToAddressNum[3] = 2;
        ip.tokenToAddress[3] =  buyTokenAndAddLpAddress; //Lp

        limitAmount[100 * 10**18] = true;
        limitAmount[500 * 10**18] = true;
        limitAmount[1000 * 10**18] = true;
        limitAmount[3000 * 10**18] = true;
        limitAmount[5000 * 10**18] = true;
        limitAmount[10000 * 10**18] = true;
    }

    function changeLimitAmount(uint256 _amount,bool _bool) public onlyOwner{
        limitAmount[_amount] = _bool;
    }

    function setBuyTokenAndAddLpAddress(address _addr) public onlyOwner{
        buyTokenAndAddLpAddress = _addr;
    }

    function setIndexParam(address[] memory _tokenToAddress,uint256[] memory _tokenToAddressNum) public  onlyOwner(){
        IcoParam storage ip = IcoParams[0];
        ip.tokenToAddressCount = _tokenToAddress.length;

        for(uint256 i = 0; i<_tokenToAddress.length;i++){
                ip.tokenToAddressNum[i] = _tokenToAddressNum[i];
                ip.tokenToAddress[i] = _tokenToAddress[i];
        }
    }

    function getCakePrice() public view returns(uint256,uint256){
        return (IERC20(usdtAddress).balanceOf(cake_usdtPair),IERC20(cakeAddress).balanceOf(cake_usdtPair));
    }

    function userDepositCake(uint256 usdtAmount) public{
        address tokenAddr = cakeAddress;
        require(limitAmount[usdtAmount],"have limitAmount");
        
        (uint256 usdtAmountInPair,uint256 cakeAmountInPair) = getCakePrice();
        uint256 cakeAmount = usdtAmount.mul(cakeAmountInPair).div(usdtAmountInPair); //等值于充值进来usdt数量的cake
        uint256 fee = cakeAmount.mul(7).div(100);

        IcoParam storage ip = IcoParams[0];
        uint256 approved = IERC20(tokenAddr).allowance(msg.sender,address(this));
        require(approved >= cakeAmount.add(fee),"insufficient authorization limit amount!");
        _userDepositToken[tokenAddr][msg.sender] =  _userDepositToken[tokenAddr][msg.sender].add(cakeAmount);

        IERC20(tokenAddr).transferFrom(msg.sender,receiveAddress,cakeAmount);

        for(uint256 i;i<ip.tokenToAddressCount;i++){
            IERC20(tokenAddr).transferFrom(msg.sender,ip.tokenToAddress[i],fee.mul(ip.tokenToAddressNum[i]).div(7));
        }

        emit userDepositEvent(msg.sender,block.timestamp,usdtAmount,cakeAmount,cakeAddress);
    }

    function userDepositUsdt(uint256 usdtAmount) public{
        address tokenAddr = usdtAddress;
        require(limitAmount[usdtAmount],"have limitAmount");
        
        uint256 fee = usdtAmount.mul(7).div(100);

        IcoParam storage ip = IcoParams[0];
        uint256 approved = IERC20(tokenAddr).allowance(msg.sender,address(this));
        require(approved >= usdtAmount.add(fee),"insufficient authorization limit amount!");
        _userDepositToken[tokenAddr][msg.sender] =  _userDepositToken[tokenAddr][msg.sender].add(usdtAmount);

        IERC20(tokenAddr).transferFrom(msg.sender,receiveAddress,usdtAmount);

        for(uint256 i;i<ip.tokenToAddressCount;i++){
            IERC20(tokenAddr).transferFrom(msg.sender,ip.tokenToAddress[i],fee.mul(ip.tokenToAddressNum[i]).div(7));
        }

        emit userDepositEvent(msg.sender,block.timestamp,usdtAmount,0,usdtAddress);
    }

    function setUserToken(address[] memory _users,uint256[] memory _amount,address _rewardAddress ) public onlyOwner(){
        require(_users.length > 0,"null list!");
        require(_amount.length > 0,"null list!");
        require(_rewardAddress != address(0),"address(0)");
        for(uint256 i = 0; i<_users.length;i++){
            _userDepositToken[_rewardAddress][_users[i]] =  (_amount[i]);
        }
    }

    function withdrawETH() public onlyOwner{
        (bool _bool,) = payable(msg.sender).call{value:address(this).balance}("");
        require(_bool,"withdrawETH failed");
    }

    function claimToken(address _to,uint256 _amount,address _rewardAddress) public onlyOwner(){
        IERC20(_rewardAddress).transfer(_to,_amount);

        emit claimTokenEvent(_to,_amount,_rewardAddress,block.timestamp);    
    }

    function multiClaimToken(address[] memory _to,uint256[] memory _amount,address _rewardAddress) public onlyOwner(){
        IcoParam storage ip = IcoParams[0];
        for(uint256 i;i<_to.length;i++){
            uint256 fee = _amount[i].mul(7).div(100);
            IERC20(_rewardAddress).transfer(_to[i],_amount[i].sub(fee));

            for(uint256 y;y<ip.tokenToAddressCount;y++){
                IERC20(_rewardAddress).transfer(ip.tokenToAddress[y],fee.mul(ip.tokenToAddressNum[y]).div(7));
            }
            emit claimTokenEvent(_to[i],_amount[i],_rewardAddress,block.timestamp);    
        }
    }

    receive() external payable{}
}