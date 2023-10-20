// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external pure returns (uint8);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// interface IWETH {
//     function deposit() external payable;

//     function transfer(address to, uint256 value) external returns (bool);

//     function withdraw(uint256) external;
// }

contract Dividend3 {
    using SafeMath for uint256;

    address public _owner;

    address public Router02 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    IERC20 public usdc;

    IERC20 public WBNB;

    address public _operator;

    mapping(uint256 => address) public _player;

    mapping(uint256 => uint256) public BL;

    mapping(string => address) public coinTypeMaping;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    IUniswapV2Router02 public immutable uniswapV2Router;

    // IWETH public immutable iWETH;

    constructor() {
        usdc = IERC20(0x55d398326f99059fF775485246999027B3197955);
        WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(Router02);
        uniswapV2Router = _uniswapV2Router;
        _owner = msg.sender;
        _operator = msg.sender;
        coinTypeMaping["USDT"] = 0x55d398326f99059fF775485246999027B3197955;
        coinTypeMaping["WBNB"] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        // iWETH = IWETH(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        _operator = 0x2d084Ef469905133BeF244CE837C9F7d68e634B7;
        BL[0] = 100;
        _player[0] = 0x940DFF297b5A1e567b9AC91ebC5dD4B7f57424d2;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    modifier onlyOperator() {
        require(
            msg.sender == _owner || msg.sender == _operator,
            "Permission denied"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        _operator = newOperator;
    }

    function setDividendAddressAndBlSingle(
        address NodeAddress,
        uint256 index,
        uint256 NodeBL
    ) public onlyOperator {
        BL[index] = NodeBL;
        _player[index] = NodeAddress;
    }

    function setDividendAddressAndBl(
        address[] calldata NodeAddress,
        uint256[] calldata NodeBL,
        uint256[] calldata index
    ) public onlyOperator {
        for (uint256 i = 0; i < NodeBL.length; i++) {
            uint256 bl = NodeBL[i];
            address add = NodeAddress[i];
            uint256 indexx = index[i];
            BL[indexx] = bl;
            _player[indexx] = add;
        }
    }

    function setCoinTypeMapping(string memory _coinType, address _coinTypeAddr)
        external
        onlyOwner
    {
        coinTypeMaping[_coinType] = _coinTypeAddr;
    }

    function getCoinTypeMapping(string memory _coinType)
        public
        view
        returns (address)
    {
        return coinTypeMaping[_coinType];
    }

    function getERC20Address(string memory _coinType)
        public
        view
        returns (IERC20)
    {
        require(bytes(_coinType).length != 0, "1");
        address _remoteAddr = coinTypeMaping[_coinType];
        require(_remoteAddr != address(0), "2");
        IERC20 _tokenTransfer = IERC20(_remoteAddr);
        return _tokenTransfer;
    }

    function exchange() private {
        uint256 balance = usdc.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(usdc);
        path[1] = address(WBNB);

        if (usdc.allowance(address(this), Router02) <= balance) {
            usdc.approve(
                address(Router02),
                10000000000000000000000000000000000000000000000000000
            );
        }

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // function changeWBNBToBNB() public onlyOperator {
    //     uint256 amount = WBNB.balanceOf(address(this));
    //     iWETH.withdraw(amount);
    // }

    function withdrawWBNB(uint256 len) public onlyOperator {
        require(len > 0);
        exchange();
        uint256 amount = WBNB.balanceOf(address(this));
        require(amount > 0, "balance is not enough~");
        for (uint256 i = 0; i < len; i++) {
            address account = _player[i];
            if (account != address(0)) {
                WBNB.transfer(account, amount.mul(BL[i]).div(100));
            }
        }
    }

    function withdrawSymbol(
        uint256 amount,
        string memory coinType,
        uint256 len
    ) public onlyOperator {
        require(len > 0);
        IERC20 _tokenTransfer = getERC20Address(coinType);
        for (uint256 i = 0; i < len; i++) {
            address account = _player[i];
            if (account != address(0)) {
                _tokenTransfer.transfer(account, amount.mul(BL[i]).div(100));
            }
        }
    }
}