// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address user) external view returns(uint);
}

interface IXxx {
    function registrationFor(address userAddress) external;
    function levelPrice(uint8 level) external view returns(uint);
    function buyNewLevelFor(address userAddress, uint8 level) external;
}

interface IForsageExpress {
    function registrationFor(address userAddress) external;
    function levelPrice(uint8 level) external view returns(uint);
    function buyNewLevelFor(address userAddress, uint8 level) external;
}

interface IMaxDrive {
    function registrationFor(address userAddress) external;
    function levelPrice(uint8 level) external view returns(uint);
    function buyNewLevelFor(address userAddress, uint8 level) external;
}

interface IForsageLottery {
    function registrationFor(address userAddress) external;
    function levelPrice(uint8 level) external view returns(uint);
    function buyNewLevelFor(address userAddress, uint8 level) external;
}

interface IXGold {
    function buyNewLevel(uint8 level) external payable;
    function levelPrice(uint8 level) external view returns(uint);
    function buyNewLevelFor(address userAddress, uint8 level) external payable;
}

interface IXQore {
    function buyNewLevel(uint8 level) external payable;
    function levelPrice(uint8 level) external view returns(uint);
    function buyNewLevelFor(address userAddress, uint8 level) external payable;
}

interface IForsage {
    function registrationFor(address userAddress, address referrerAddress) external;
    function buyNewLevelFor(address userAddress, uint8 matrix, uint8 level) external;
    function BASIC_PRICE() external view returns(uint);
    function levelPrice(uint8 level) external view returns(uint);
    function users(address userAddress) external view returns(uint id, address referrer, uint partnersCount);
}

interface IPancakeRouter {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
}

interface IWBNB {
  function withdraw(uint amount) external;
}

abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

        // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal virtual view returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () payable external {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () payable external {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     * 
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}


contract RouterProxy is Proxy {

    address public impl;
    address public contractOwner;

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    constructor(address _impl) {
        impl = _impl;
        contractOwner = msg.sender;
    }

    function update(address newImpl) public onlyContractOwner {
        impl = newImpl;
    }

    function removeOwnership() public onlyContractOwner {
        contractOwner = address(0);
    }

    function _implementation() internal override view returns (address) {
        return impl;
    }
}

interface IForsageRouter {
    function forsageExpressRegistration(address referrerAddress) external payable;
}

contract ForsageRouterBasic {

    address public impl;
    address public contractOwner;

    IERC20 public busd;

    IPancakeRouter public pancakeRouter;
    IForsage public forsage;
    IForsageExpress public forsageExpress;
    IXGold public xGold;
    IXxx public xxx;
    IMaxDrive public maxDrive;

    address payable public feeWallet;
    uint public busdFee;

    IForsageLottery public forsageLottery;

    IXQore public xQore;
    IXQore public maxQore;
}

contract ForsageRouter is ForsageRouterBasic {

    //forsage - 0x5acc84a3e955bdd76467d3348077d003f00ffb97
    //pancakeRouter - 0x10ED43C718714eb63d5aA57B78B54704E256024E
    function init(IForsage _forsage,
        IXxx _xxx,
        IXGold _xGold,
        IPancakeRouter _pancakeRouter,
        IXQore _xQore,
        IXQore _maxQore
    ) public {
        require(msg.sender == contractOwner, "onlyContractOwner");
        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        forsage = _forsage;
        pancakeRouter = _pancakeRouter;
        xQore = _xQore;
        xGold = _xGold;
        xxx = _xxx;
        maxQore = _maxQore; 

        busd.approve(address(pancakeRouter), type(uint256).max);
        busd.approve(address(forsage), type(uint256).max);
        busd.approve(address(xxx), type(uint256).max);
        busd.approve(address(xGold), type(uint256).max);
        busd.approve(address(xQore), type(uint256).max);
    }

    receive() external payable {

    }

    fallback() external payable {

    }

    function setFeeData(address payable _feeWallet, uint _busdFee) public {
        require(msg.sender == contractOwner, "onlyContractOwner");
        feeWallet = _feeWallet;
        busdFee = _busdFee;
    }

    // function forsageRegistration(address referrerAddress) public payable {
    //     uint fee = 0.003e18;
    //     feeWallet.transfer(fee);

    //     uint amountOut = forsage.BASIC_PRICE() * 2;

    //     address[] memory path = new address[](2);
    //     path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //     path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    //     address to = address(this);
    //     uint deadline = block.timestamp + 1000;

    //     pancakeRouter.swapETHForExactTokens{value: msg.value - fee}(amountOut, path, to, deadline);

    //     forsage.registrationFor(msg.sender, referrerAddress);

    //     if(address(this).balance > 0) {
    //         payable(msg.sender).transfer(address(this).balance);
    //     }
    // }


    function forsageRegistration(address referrerAddress) public payable {
        uint amountOut = forsage.BASIC_PRICE() * 2 + busdFee;

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);
        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        forsage.registrationFor(msg.sender, referrerAddress);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function forsageRegistrationBUSD(address referrerAddress) public payable {
        uint amountOut = forsage.BASIC_PRICE() * 2 + busdFee;

        busd.transferFrom(msg.sender, address(this), amountOut);

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        forsage.registrationFor(msg.sender, referrerAddress);
    }

    function forsageAndXGoldRegistration(address referrerAddress) public payable {
        uint amountOut = forsage.BASIC_PRICE() * 2 + xGold.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        forsage.registrationFor(msg.sender, referrerAddress);
        xGold.buyNewLevelFor(msg.sender, 1);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function forsageAndXxxRegistration(address referrerAddress) public payable {
        uint amountOut = forsage.BASIC_PRICE() * 2 + xxx.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        forsage.registrationFor(msg.sender, referrerAddress);
        xxx.buyNewLevelFor(msg.sender, 1);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function xxxActivation() public payable {
        uint amountOut = busdFee + xxx.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        xxx.buyNewLevelFor(msg.sender, 1);

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function xxxActivationBusd() public payable {
        uint amountOut = busdFee + xxx.levelPrice(1);
        busd.transferFrom(msg.sender, address(this), amountOut);

        xxx.buyNewLevelFor(msg.sender, 1);

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }
    }

    function xGoldActivation() public payable {
        uint amountOut = busdFee + xGold.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        xGold.buyNewLevelFor(msg.sender, 1);

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function xGoldActivationBusd() public {
        uint amountOut = busdFee + xGold.levelPrice(1);
        busd.transferFrom(msg.sender, address(this), amountOut);

        xGold.buyNewLevelFor(msg.sender, 1);

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }
    }

    function x3x4BuyLevelBatch(uint8 matrixType, uint8[] memory _levels) public payable {
        uint amountOut = busdFee;
        for(uint i = 0; i < _levels.length; i++) {
            amountOut+= forsage.levelPrice(_levels[i]);
        }

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        for(uint i = 0; i < _levels.length; i++) {
            forsage.buyNewLevelFor(msg.sender, matrixType, _levels[i]);
        }

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function x3x4BuyLevelBatchBusd(uint8 matrixType, uint8[] memory _levels) public {

        uint amountOut = busdFee;
        for(uint i = 0; i < _levels.length; i++) {
            amountOut+= forsage.levelPrice(_levels[i]);
        }

        busd.transferFrom(msg.sender, address(this), amountOut);
        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        for(uint i = 0; i < _levels.length; i++) {
            forsage.buyNewLevelFor(msg.sender, matrixType, _levels[i]);
        }
    }

    function xGoldBuyLevelBatch(uint8[] memory _levels) public payable {
        uint amountOut = busdFee;
        for(uint i = 0; i < _levels.length; i++) {
            amountOut+= xGold.levelPrice(_levels[i]);
        }

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        for(uint i = 0; i < _levels.length; i++) {
            xGold.buyNewLevelFor(msg.sender, _levels[i]);
        }

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function xGoldBuyLevelBatchBusd(uint8[] memory _levels) public {
        uint amountOut = busdFee;
        for(uint i = 0; i < _levels.length; i++) {
            amountOut+= xGold.levelPrice(_levels[i]);
        }

        busd.transferFrom(msg.sender, address(this), amountOut);
        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        for(uint i = 0; i < _levels.length; i++) {
            xGold.buyNewLevelFor(msg.sender, _levels[i]);
        }
    }

    function xxxBuyLevelBatch(uint8[] memory _levels) public payable {
        uint amountOut = busdFee;
        for(uint i = 0; i < _levels.length; i++) {
            amountOut+= xxx.levelPrice(_levels[i]);
        }

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        for(uint i = 0; i < _levels.length; i++) {
            xxx.buyNewLevelFor(msg.sender, _levels[i]);
        }

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function xxxBuyLevelBatchBusd(uint8[] memory _levels) public {
        uint amountOut = busdFee;
        for(uint i = 0; i < _levels.length; i++) {
            amountOut+= xxx.levelPrice(_levels[i]);
        }

        busd.transferFrom(msg.sender, address(this), amountOut);

        for(uint i = 0; i < _levels.length; i++) {
            xxx.buyNewLevelFor(msg.sender, _levels[i]);
        }

        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }


    //- Reg х3/х4 + xQore (BNB)
    function forsageAndXQoreRegistration(address referrerAddress) public payable {        
        uint amountOut = forsage.BASIC_PRICE() * 2;

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        uint xQoreRegistrationPrice = xQore.levelPrice(1);

        pancakeRouter.swapETHForExactTokens{value: msg.value - xQoreRegistrationPrice}(amountOut, path, to, deadline);

        forsage.registrationFor(msg.sender, referrerAddress);
        xQore.buyNewLevelFor{value: xQoreRegistrationPrice}(msg.sender, 1) ;

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    // - Reg х3/х4 + xQore (BUSD)
    function forsageAndXQoreRegistrationBusd(address referrerAddress, uint busdRequest) public {
        uint busdBalanceBefore = busd.balanceOf(address(this));
        uint amountOut = xQore.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        busd.transferFrom(msg.sender, address(this), busdRequest);
        pancakeRouter.swapTokensForExactETH(amountOut, busdRequest, path, to, deadline);
        // IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).withdraw(amountOut);

        forsage.registrationFor(msg.sender, referrerAddress);
        xQore.buyNewLevelFor{value: amountOut}(msg.sender, 1);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        uint busdBalanceAfter = busd.balanceOf(address(this));
        if(busdBalanceAfter > busdBalanceBefore) {
            busd.transfer(msg.sender, busdBalanceAfter - busdBalanceBefore);
        }
    }

    // - Activate xQore
    function xQoreRegistration() public payable {
        uint fee = 0.003e18;
        feeWallet.transfer(fee);

        xQore.buyNewLevelFor{value: msg.value - fee}(msg.sender, 1);
    }

    //- Activate xQore в BUSD
 function xQoreRegistrationBusd(uint busdRequest) public {
        uint busdBalanceBefore = busd.balanceOf(address(this));
        uint amountOut = xQore.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        busd.transferFrom(msg.sender, address(this), busdRequest + busdFee);
        if(busdFee > 0) {
            busd.transfer(feeWallet, busdFee);
        }

        pancakeRouter.swapTokensForExactETH(amountOut, busdRequest, path, to, deadline);
        // IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).withdraw(amountOut);

        xQore.buyNewLevelFor{value: amountOut}(msg.sender, 1);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        uint busdBalanceAfter = busd.balanceOf(address(this));
        if(busdBalanceAfter > busdBalanceBefore) {
            busd.transfer(msg.sender, busdBalanceAfter - busdBalanceBefore);
        }
    }

    // - Upgrade xQore
    function xQoreUpgrades(uint8 level) public payable {
        uint fee = 0.003e18;
        feeWallet.transfer(fee);
        xQore.buyNewLevelFor{value: msg.value - fee}(msg.sender, level);
    }

    // - Upgrade xQore BUSD
    function xQoreUpgradesBusd(uint8 level, uint busdRequest) public {
        uint fee = 0.003e18;
        uint busdBalanceBefore = busd.balanceOf(address(this));
        uint amountOut = xQore.levelPrice(level);

        address[] memory path = new address[](2);
        path[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        busd.transferFrom(msg.sender, address(this), busdRequest);
        pancakeRouter.swapTokensForExactETH(amountOut + fee, busdRequest, path, to, deadline);
        // IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).withdraw(amountOut + fee);

        feeWallet.transfer(fee);

        xQore.buyNewLevelFor{value: amountOut}(msg.sender, level);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        uint busdBalanceAfter = busd.balanceOf(address(this));
        if(busdBalanceAfter > busdBalanceBefore) {
            busd.transfer(msg.sender, busdBalanceAfter - busdBalanceBefore);
        }
    }

    // - Activate maxQore
    function maxQoreRegistration() public payable {
        uint fee = 0.003e18;
        feeWallet.transfer(fee);
        maxQore.buyNewLevelFor{value: msg.value - fee}(msg.sender, 1);
    }

    //- Activate maxQore в BUSD
    function maxQoreRegistrationBusd(uint busdRequest) public {
        uint fee = 0.003e18;
        uint busdBalanceBefore = busd.balanceOf(address(this));
        uint amountOut = maxQore.levelPrice(1);

        address[] memory path = new address[](2);
        path[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        busd.transferFrom(msg.sender, address(this), busdRequest);
        pancakeRouter.swapTokensForExactETH(amountOut + fee, busdRequest, path, to, deadline);
        // IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).withdraw(amountOut);
 
        feeWallet.transfer(fee);

        maxQore.buyNewLevelFor{value: amountOut}(msg.sender, 1);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        uint busdBalanceAfter = busd.balanceOf(address(this));
        if(busdBalanceAfter > busdBalanceBefore) {
            busd.transfer(msg.sender, busdBalanceAfter - busdBalanceBefore);
        }
    }

    // - Upgrade maxQore
    function maxQoreUpgrades(uint8 level) public payable {
        uint fee = 0.003e18;
        feeWallet.transfer(fee);
        maxQore.buyNewLevelFor{value: msg.value - fee}(msg.sender, level);
    }

    // - Upgrade maxQore BUSD
    function maxQoreUpgradesBusd(uint8 level, uint busdRequest) public {
        uint fee = 0.003e18;
        uint busdBalanceBefore = busd.balanceOf(address(this));
        uint amountOut = maxQore.levelPrice(level);

        address[] memory path = new address[](2);
        path[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        busd.transferFrom(msg.sender, address(this), busdRequest);
        pancakeRouter.swapTokensForExactETH(amountOut + fee, busdRequest, path, to, deadline);
        // IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).withdraw(amountOut + fee);

        feeWallet.transfer(fee);

        maxQore.buyNewLevelFor{value: amountOut}(msg.sender, level);

        if(address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        uint busdBalanceAfter = busd.balanceOf(address(this));
        if(busdBalanceAfter > busdBalanceBefore) {
            busd.transfer(msg.sender, busdBalanceAfter - busdBalanceBefore);
        }
    } 
}