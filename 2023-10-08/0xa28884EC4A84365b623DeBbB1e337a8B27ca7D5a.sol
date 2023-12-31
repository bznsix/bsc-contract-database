// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

interface IDEXRouter {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract permission {

    address private _owner;
    mapping(address => mapping(string => bytes32)) private _permit;

    modifier forRole(string memory str) {
        require(checkpermit(msg.sender,str),"Permit Revert!");
        _;
    }

    constructor() {
        newpermit(msg.sender,"owner");
        newpermit(msg.sender,"permit");
        _owner = msg.sender;
    }

    function owner() public view returns (address) { return _owner; }
    function newpermit(address adr,string memory str) internal { _permit[adr][str] = bytes32(keccak256(abi.encode(adr,str))); }
    function clearpermit(address adr,string memory str) internal { _permit[adr][str] = bytes32(keccak256(abi.encode("null"))); }
    function checkpermit(address adr,string memory str) public view returns (bool) {
        if(_permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }

    function grantRole(address adr,string memory role) public forRole("owner") returns (bool) { newpermit(adr,role); return true; }
    function revokeRole(address adr,string memory role) public forRole("owner") returns (bool) { clearpermit(adr,role); return true; }

    function transferOwnership(address adr) public forRole("owner") returns (bool) {
        newpermit(adr,"owner");
        clearpermit(msg.sender,"owner");
        _owner = adr;
        return true;
    }

    function renounceOwnership() public forRole("owner") returns (bool) {
        newpermit(address(0),"owner");
        clearpermit(msg.sender,"owner");
        _owner = address(0);
        return true;
    }
}

contract SMPMarketplacePayment is permission {

    event SMPPayment(address indexed account,uint256 amountSMP,uint256 amountUSDT,uint256 feeAmount,uint256 timestamp);
    event SMPWithdraw(address indexed account,uint256 amountSMP,uint256 amountUSDT,uint256 feeAmount,uint256 timestamp);

    IDEXRouter router;

    uint256 gasFee = 3e15;
    uint256 public feeOnShop = 300;
    uint256 public feeOnWithdraw = 500;
    uint256 public denominator = 10000;

    address public feeReceiverSMP = 0x6752Fd7fF28Fcf8eaf7B70a0a511d2518FF6dD3b;
    address public feeReceiverUSDT = 0x07165369Ae5657717b6b7A9fA9afB8b3fe21D0cF;

    address private SMPF = 0x515e62a3Ac560FD5dF08536D08336e63aed3B182;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private USDT = 0x55d398326f99059fF775485246999027B3197955;

    address deployer;
    address[] private path = [SMPF,WBNB,USDT];

    struct recipePayment {
        address account;
        uint256 amountSMP;
        uint256 amountUSDT;
        uint256 feeAmount;
        uint256 timestamp;
    }

    recipePayment[] recipePayments;

    struct recipeWithdraw {
        address account;
        uint256 amountSMP;
        uint256 amountUSDT;
        uint256 feeAmount;
        uint256 timestamp;
    }

    recipeWithdraw[] recipeWithdraws;

    mapping (address => uint256) public totalRecipePayment;
    mapping (address => uint256) public totalRecipeWithdraw;

    constructor() {
        deployer = msg.sender;
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function USDT2SMP(uint256 amountUSDT,uint256 overpayAmount) public view returns (uint256 amountSMP) {
        uint256 amountAfterFee = amountUSDT * denominator / (denominator - overpayAmount);
        uint256[] memory amounts = router.getAmountsIn(amountAfterFee,path);
        return amounts[0];
    }

    function SMP2USDT(uint256 amountSMP) public view returns (uint256 amountUSDT) {
        uint256[] memory amounts = router.getAmountsOut(amountSMP,path);
        return amounts[2];
    }

    function getRecipePayments() public view returns (recipePayment[] memory) {
        return recipePayments;
    }

    function getRecipeWithdraws() public view returns (recipeWithdraw[] memory) {
        return recipeWithdraws;
    }

    function getOwnerRecipePayment(address account) public view returns (recipePayment[] memory) {
        recipePayment[] memory result = new recipePayment[](totalRecipePayment[account]);
        uint256 counter = 0;
        for (uint256 i = 0; i < recipePayments.length; i++) {
            if (recipePayments[i].account == account) {
                result[counter] = recipePayments[i];
                counter++;
            }
        }
        return result;
    }

    function getOwnerRecipeWithdraw(address account) public view returns (recipeWithdraw[] memory) {
        recipeWithdraw[] memory result = new recipeWithdraw[](totalRecipeWithdraw[account]);
        uint256 counter = 0;
        for (uint256 i = 0; i < recipeWithdraws.length; i++) {
            if (recipeWithdraws[i].account == account) {
                result[counter] = recipeWithdraws[i];
                counter++;
            }
        }
        return result;
    }

    function requestPayment(uint256 amountUSDT) public payable returns (bool success,uint256 recipePaymentId) {
        if(msg.value>gasFee){ gasFee = msg.value; } sendValue(deployer,gasFee);
        uint256 requireAmount = USDT2SMP(amountUSDT,feeOnShop);
        IERC20(SMPF).transferFrom(msg.sender,feeReceiverSMP,requireAmount);
        emit SMPPayment(msg.sender,requireAmount,amountUSDT,feeOnShop,block.timestamp);
        recipePayment memory newRecipe = recipePayment(msg.sender,requireAmount,amountUSDT,feeOnShop,block.timestamp);
        recipePayments.push(newRecipe);
        totalRecipePayment[msg.sender] += 1;
        return (true,recipePayments.length);
    }

    function requestWithdraw(uint256 amountUSDT) public payable returns (bool success,uint256 recipeWithdrawId) {
        if(msg.value>gasFee){ gasFee = msg.value; } sendValue(deployer,gasFee);
        uint256 requireAmount = USDT2SMP(amountUSDT,feeOnWithdraw);
        IERC20(SMPF).transferFrom(msg.sender,address(this),requireAmount);
        IERC20(SMPF).approve(address(router),requireAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            requireAmount,
            0,
            path,
            feeReceiverUSDT,
            block.timestamp
        );
        emit SMPWithdraw(msg.sender,requireAmount,amountUSDT,feeOnWithdraw,block.timestamp);
        recipeWithdraw memory newRecipe = recipeWithdraw(msg.sender,requireAmount,amountUSDT,feeOnWithdraw,block.timestamp);
        recipeWithdraws.push(newRecipe);
        totalRecipeWithdraw[msg.sender] += 1;
        return (true,recipeWithdraws.length);
    }

    function settingContract(address feeWalletSMP,address feeWalletUSDT,uint256 feeShop,uint256 feeWithdraw,uint256 deno) public forRole("permit") returns (bool) {
        feeReceiverSMP = feeWalletSMP;
        feeReceiverUSDT = feeWalletUSDT;
        feeOnShop = feeShop;
        feeOnWithdraw = feeWithdraw;
        denominator = deno;
        return true;
    }

    function rescueToken(address to,address token,uint256 amount) public forRole("permit") returns (bool) {
        IERC20(token).transfer(to,amount);
        return true;
    }

    function rescueETH(address to,uint256 amount) public forRole("permit") returns (bool) {
        sendValue(to,amount);
        return true;
    }

    function sendValue(address receiver,uint256 amount) internal {
        (bool success,) = receiver.call{ value: amount }("");
        require(success, "!fail to send eth");
    }

    receive() external payable {}
}