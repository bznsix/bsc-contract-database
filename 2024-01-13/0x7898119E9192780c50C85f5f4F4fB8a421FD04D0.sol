// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function getAddresses() external view returns (address pairAddress, address routerAddress, address usdtAddress, address wbnbAddress, address marketAddress); 
}

interface ISwapRouter {
    function factory() external pure returns (address);    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

contract Matrix is Ownable {
    ISwapRouter private _swapRouter;

    constructor (){        
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }


    function swapToken(uint inputUsdtAmount, address usdtAddress, address tokenAddress, address toAddress) internal{

        if(IERC20(usdtAddress).allowance(address(this), address(_swapRouter))==0) IERC20(usdtAddress).approve(address(_swapRouter),~uint256(0));

        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = tokenAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            inputUsdtAmount,
            0,
            path,
            address(this),
            block.timestamp
        );        
        IERC20(tokenAddress).transfer(toAddress, IERC20(tokenAddress).balanceOf(address(this))); 
    }


    function buyAndSend(address toAddress, uint inputUsdtAmount, address tokenAddress, address usdtAddress, address[] calldata recvBonusAddress, uint[] calldata usdtBonusAmount, uint[] calldata tokenBonusAmount) external onlyOwner{ 
        
        assert(recvBonusAddress.length==usdtBonusAmount.length && recvBonusAddress.length==tokenBonusAmount.length);
        address addressThis = address(this);  
        IERC20(usdtAddress).transferFrom(msg.sender, addressThis, inputUsdtAmount);
        swapToken(inputUsdtAmount,usdtAddress, tokenAddress, toAddress);
        
        for(uint i=0;i<recvBonusAddress.length;++i){
            if(usdtBonusAmount[i]>0)  IERC20(usdtAddress).transferFrom(msg.sender, recvBonusAddress[i], usdtBonusAmount[i]);
            if(tokenBonusAmount[i]>0)  IERC20(tokenAddress).transferFrom(msg.sender, recvBonusAddress[i], tokenBonusAmount[i]);
        }
    }
     
}