// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

interface ISwapFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IPancakePair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

abstract contract Ownable {
    address internal _owner;
    address internal _operator;

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        _operator = msgSender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!onlyOwner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "!onlyOperator");
        _;
    }

    function transferOperator(address newOwner) public virtual onlyOwner {
        _operator = newOwner;
    }
}

contract LuckyMiningContract is Ownable {
    event TokensBurned(uint256 amount);
    event MinerCreated(uint256 minerIndex, address recipient, uint256 amount);

    uint256 private constant MAX = ~uint256(0);
    ISwapRouter public _swapRouter;
    address public mainPair;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public free;

    IERC20 public usdt;
    IERC20 public lucky;

    uint256 public total_release;

    struct Miner {
        uint256 totalReleaseAmount;
        uint256 releaseSeconds;
        uint256 lastClaimTime;
        uint256 claimedAmount;
        uint256 createDate;
    }

    mapping(address => Miner[]) public miners;

    constructor(address _usdt, address _lucky) {
        usdt = IERC20(_usdt);
        lucky = IERC20(_lucky);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        mainPair = swapFactory.getPair(address(lucky), _swapRouter.WETH());

        lucky.approve(address(_swapRouter), MAX);
        usdt.approve(address(_swapRouter), MAX);

        free = 0.005 ether;
    }

    function createMiner(
        uint256 _releaseSeconds,
        uint256 _totalReleaseAmount,
        address _recipient
    ) external onlyOperator {
        require(
            lucky.balanceOf(address(this)) >= _totalReleaseAmount,
            "Insufficient tokens"
        );
        require(_releaseSeconds >= 8640000, "day error");
        total_release += _totalReleaseAmount;
        Miner memory newMiner = Miner({
            totalReleaseAmount: _totalReleaseAmount,
            releaseSeconds: _releaseSeconds,
            lastClaimTime: block.timestamp,
            claimedAmount: 0,
            createDate: block.timestamp
        });
        miners[_recipient].push(newMiner);
        emit MinerCreated(
            miners[_recipient].length,
            _recipient,
            _totalReleaseAmount
        );
    }

    function claimMiner(uint256 minerIndex) external payable returns (uint256) {
        require(msg.value >= free, "Insufficient fee");

        Miner storage miner = miners[msg.sender][minerIndex];
        require(block.timestamp > miner.lastClaimTime, "Cannot claim yet");
        uint256 timeElapsed = block.timestamp - miner.lastClaimTime;
        if (timeElapsed > 0) {
            uint256 amountPerSecond = miner.totalReleaseAmount /
                miner.releaseSeconds;
            uint256 claimAmount = timeElapsed * amountPerSecond;

            uint256 maxClaimAmount = miner.totalReleaseAmount -
                miner.claimedAmount;
            claimAmount = (claimAmount > maxClaimAmount)
                ? maxClaimAmount
                : claimAmount;
            require(claimAmount > 0, "Claim completed");
            require(
                lucky.balanceOf(address(this)) >= claimAmount,
                "Insufficient tokens"
            );

            miner.lastClaimTime = block.timestamp;
            miner.claimedAmount += claimAmount;
            lucky.transfer(msg.sender, claimAmount);
            return claimAmount;
        }
        return 0;
    }

    function getMinerNum(address _recipient) public view returns (uint256) {
        uint256 minerLeng = miners[_recipient].length;
        return minerLeng;
    }

    function setFree(uint256 _free) external onlyOperator {
        free = _free;
    }

    function getMinerInfo(
        uint256 _startIndex,
        address _recipient
    ) public view returns (Miner[] memory) {
        Miner[] memory result = new Miner[](5);
        uint256 maxLeng = getMinerNum(_recipient);
        for (uint256 i = 0; i < 5; i++) {
            if (_startIndex + i < maxLeng) {
                result[i] = miners[_recipient][_startIndex + i];
            }
        }
        return result;
    }

    // usdt -> bnb
    // bnb -> lucky
    // lucky -> DEAD
    function swapAndBurn(uint256 amount) external onlyOperator {
        uint256 initialBalance = address(this).balance;
        swapTokenForFund(amount);
        uint256 newBnbBalance = address(this).balance - initialBalance;
        swapBNBForLucky(newBnbBalance);
    }

    function swapTokenForFund(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBNBForLucky(uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = _swapRouter.WETH();
        path[1] = address(lucky);
        uint[] memory amounts = _swapRouter.swapExactETHForTokens{
            value: bnbAmount
        }(0, path, address(this), block.timestamp);
        uint256 luckyAmount = amounts[amounts.length - 1];
        lucky.transfer(DEAD, luckyAmount);
        emit TokensBurned(luckyAmount);
    }

    receive() external payable {}

    function claimBalance() external {
        payable(_operator).transfer(address(this).balance);
    }

    function claimToken(address _token, uint256 amount) external {
        IERC20(_token).transfer(_operator, amount);
    }
}