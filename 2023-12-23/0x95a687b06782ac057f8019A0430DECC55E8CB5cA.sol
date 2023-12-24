// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@v4.9.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@v4.9.3/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@v4.9.3/access/Ownable.sol";
import "@openzeppelin/contracts@v4.9.3/token/ERC20/IERC20.sol";

contract MBGBToken is ERC20, ERC20Burnable, Ownable {
    mapping(address => address) public Team;
    mapping(address => bool) public DEXs;
    mapping(address => bool) public Excludes;
    address public market;
    bool public needFee;
    struct DividendStatus {
        uint8 counter;
        uint32 last;
    }
    mapping(address => DividendStatus) public TeamCounter;

    struct DayTrade {
        uint256 price;
        uint32 time;
    }
    enum trendState {
        normal,
        down,
        rise
    }

    struct FeeStat {
        uint32 time;
        uint yAmount;
        uint tAmount;
    }

    struct TradeCounter {
        uint lp;
        uint buy;
        uint sell;
        uint hold;
        uint all;
        uint u;
    }
    DayTrade[] public trend;
    FeeStat public feeStat;
    mapping(address => TradeCounter) public tradeCounter;
    IPancakeSwapV2Router02 public uniswapV2Router;
    address public uniswapUsdtV2Pair;
    address public uniswapFilV2Pair;

    mapping(address => address) public holderRank;
    uint rankCounter = 0;

    mapping(address => uint) public teamLpAmount;

    event TeamBouns(address indexed to, uint256 _day);

    uint temaBounsLine = 1 ether;
    uint timeLine = 10 minutes;
    uint rankLimiter = 3;

    address public usdtMintAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public filAddress = 0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153;

    //TODO: debug
    // address public usdtMintAddress = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
    // address public filAddress = 0xFa60D973F7642B748046464e165A65B7323b0DEE;

    constructor(
        address _market,
        address _owner
    ) ERC20("PepeToken", "PepeTest") {
        _mint(_owner, 4327000000000 * 10 ** decimals());
        _mint(address(this), 428373000000000 * 10 ** decimals());
        market = _market;
        feeStat = FeeStat(uint32(block.timestamp), 0, 0);
        //TODO:debug
        // IPancakeSwapV2Router02 _uniswapV2Router = IPancakeSwapV2Router02(
        //     0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // );
        IPancakeSwapV2Router02 _uniswapV2Router = IPancakeSwapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Router = _uniswapV2Router;

        uniswapUsdtV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtMintAddress);
        DEXs[uniswapUsdtV2Pair] = true;

        uniswapFilV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), filAddress);
        DEXs[uniswapFilV2Pair] = true;

        Excludes[address(this)] = true;
        needFee = true;
    }

    function updateTeamLp(
        address _sender,
        uint _amount,
        bool _positive
    ) internal {
        address _top = Team[_sender];
        uint _counter = 0;

        while (_top != address(0) && _counter < 10) {
            if (_positive) {
                teamLpAmount[_top] += _amount;
            } else {
                if (teamLpAmount[_top] > _amount) {
                    teamLpAmount[_top] -= _amount;
                }
            }
            _counter++;
            _top = Team[_top];
        }
    }

    function sortRank(address _holder) internal {
        uint _amount = balanceOf(_holder);
        address _last = address(0);
        uint _counter = 0;
        address _rank = holderRank[_last];
        while (_counter < rankLimiter) {
            if (_rank == address(0)) {
                holderRank[_last] = _holder;
                rankCounter += 1;
                return;
            }
            if (_amount > balanceOf(_rank)) {
                holderRank[_last] = _holder;
                holderRank[_holder] = _rank;
                if (rankCounter < rankLimiter) {
                    rankCounter += 1;
                }
                return;
            }
            if (_holder == _rank) {
                return;
            }
            _last = _rank;
            _rank = holderRank[_rank];
            _counter++;
        }
    }

    function checkRank(address _holder) public view returns (bool) {
        address _last = address(0);
        address _rank = holderRank[_last];
        uint _counter = 0;
        while (_rank != address(0) && _counter < rankLimiter) {
            if (_rank == _holder) {
                return true;
            }
            _last = _rank;
            _rank = holderRank[_rank];
            _counter++;
        }
        return false;
    }

    function listRank() public view returns (address[] memory) {
        address[] memory _list = new address[](rankCounter);
        address _last = address(0);
        address _rank = holderRank[_last];
        uint256 _counter = 0;
        while (_counter < rankCounter) {
            _list[_counter] = _rank;
            _last = _rank;
            _rank = holderRank[_rank];
            _counter++;
        }
        return _list;
    }

    function addDex(address _pair) external onlyOwner {
        if (DEXs[_pair]) {
            DEXs[_pair] = false;
        } else {
            DEXs[_pair] = true;
        }
    }

    function updateExcludes(address _owner) external onlyOwner {
        if (Excludes[_owner]) {
            Excludes[_owner] = false;
        } else {
            Excludes[_owner] = true;
        }
    }

    function updateFee() external onlyOwner {
        needFee = !needFee;
    }

    function teamDividend(address _owner, address to, uint256 amount) internal {
        if (amount >= 1000 ether && Team[to] == address(0)) {
            Team[to] = _owner;
            DividendStatus storage _status = TeamCounter[_owner];
            if (_status.counter < 5) {
                _status.counter += 1;
            }
            if (balanceOf(address(this)) > 2000 ether) {
                _transfer(address(this), _owner, 2000 ether);
            }
        }
    }

    function queryDays(uint32 _last) public view returns (uint32) {
        return (uint32(block.timestamp) - _last) / uint32(timeLine);
    }

    function checkTrend() internal view returns (trendState) {
        uint256 t_len = trend.length;
        if (t_len > 2) {
            DayTrade memory _a = trend[t_len - 1];
            DayTrade memory _b = trend[t_len - 2];
            DayTrade memory _c = trend[t_len - 3];
            if (_c.price > _b.price) {
                if (_b.price > _a.price) {
                    return trendState.down;
                } else {
                    return trendState.rise;
                }
            } else {
                return trendState.normal;
            }
        } else {
            return trendState.normal;
        }
    }

    function updateTrend() internal {
        uint256 price = queryPrice();
        if (price > 0) {
            if (trend.length > 0) {
                DayTrade memory tLast = trend[trend.length - 1];
                uint diff = queryDays(tLast.time);
                if (diff < 1) {
                    return;
                }
            }
            if (trend.length > 2) {
                trend[0] = trend[1];
                trend[1] = trend[2];
                trend[2] = DayTrade(price, uint32(block.timestamp));
            } else {
                trend.push(DayTrade(price, uint32(block.timestamp)));
            }
        }
    }

    function queryPrice() public view returns (uint256) {
        uint256 _a = ((IERC20(usdtMintAddress).balanceOf(uniswapUsdtV2Pair)) *
            1e18);
        uint256 _b = (IERC20(address(this)).balanceOf(uniswapUsdtV2Pair));
        if (_a > 0 && _b > 0) {
            return _a / _b;
        }
        return 0;
    }

    function queryTrendLen() external view returns (uint256) {
        return trend.length;
    }

    // function queryLiquidity(
    //     address _owner
    // ) public view returns (uint256 amount) {
    //     IPancakeSwapV2Pair _pair = IPancakeSwapV2Pair(uniswapUsdtV2Pair);
    //     uint256 balance0 = balanceOf(address(_pair));
    //     uint256 liquidity = _pair.balanceOf(_owner);
    //     uint256 total = _pair.totalSupply();
    //     if (balance0 > 0 && liquidity > 0 && total > 0) {
    //         amount = (balance0 * liquidity) / total;
    //         return amount;
    //     }
    //     IPancakeSwapV2Pair _pair2 = IPancakeSwapV2Pair(uniswapFilV2Pair);
    //     uint256 balance1 = balanceOf(address(_pair2));
    //     uint256 liquidity1 = _pair2.balanceOf(_owner);
    //     uint256 total1 = _pair2.totalSupply();
    //     if (balance1 > 0 && liquidity1 > 0 && total1 > 0) {
    //         amount = (balance1 * liquidity1) / total1;
    //         return amount;
    //     }
    //     return 0;
    // }

    function queryLiquBalance(address _holder) public view returns (uint) {
        uint256 _liquidityU = IERC20(uniswapUsdtV2Pair).balanceOf(_holder);
        uint256 _liquidityF = IERC20(uniswapFilV2Pair).balanceOf(_holder);
        if (_liquidityU > _liquidityF) {
            return _liquidityU;
        } else if (_liquidityF > _liquidityU) {
            return _liquidityF;
        } else {
            return 0;
        }
    }

    function burnFee(uint _amount) internal {
        uint256 _balance0 = balanceOf(address(uniswapUsdtV2Pair));
        uint256 _balance1 = balanceOf(address(uniswapFilV2Pair));
        if (_balance0 > _balance1) {
            _burn(address(uniswapUsdtV2Pair), _amount);
            IPancakeSwapV2Pair(uniswapUsdtV2Pair).sync();
        } else {
            _burn(address(uniswapFilV2Pair), _amount);
            IPancakeSwapV2Pair(uniswapFilV2Pair).sync();
        }
    }

    function getDividend(address _owner) internal {
        TradeCounter storage _trade = tradeCounter[_owner];
        if (_trade.u == 0) {
            return;
        }
        uint _uprice = queryPrice();
        if (_uprice == 0) {
            return;
        }
        // if (_trade.all * _uprice >= _trade.u * 2) {
        if (_trade.all * _uprice >= _trade.u / 2) {
            return;
        }
        trendState _tState = checkTrend();
        if (_tState == trendState.down) {
            return;
        }
        uint256 _amount = _trade.u / _uprice;
        uint256 _dividend;
        DividendStatus storage _status = TeamCounter[_owner];
        if (_status.counter > 0) {
            uint _rate = 0;
            if (_status.counter < 3) {
                _rate = 1;
            } else if (_status.counter < 5) {
                _rate = 3;
            } else {
                _rate = 8;
            }
            _dividend = (_amount * _rate) / 1000;
        } else {
            _dividend = _amount / 1000;
        }

        uint32 _days = queryDays(_status.last);
        if (_status.last == 0) {
            _days = 1;
        }
        if (_days > 0) {
            if (balanceOf(address(this)) > _dividend) {
                if (checkRank(_owner)) {
                    _dividend += _amount / 1000;
                }
                uint _team_rights = checkTeamRrights(_owner);
                if (_team_rights > 0) {
                    _dividend += (_team_rights * _amount) / 1000;
                }

                uint _all = _dividend * uint256(_days);
                _transfer(address(this), _owner, _all);
                _trade.all += _all;

                _status.last = uint32(block.timestamp);
                emit TeamBouns(_owner, _days);
            }
        }
    }

    function checkTeamRrights(address _holder) public view returns (uint) {
        uint _amount = teamLpAmount[_holder];
        uint _uTotal = IERC20(usdtMintAddress).balanceOf(uniswapUsdtV2Pair);
        uint _lpTotal = IERC20(uniswapUsdtV2Pair).totalSupply();
        uint _uAmount = (_amount * _uTotal) / _lpTotal;
        if (_uAmount >= temaBounsLine && _uAmount < temaBounsLine * 10) {
            return 1;
        } else if (
            _uAmount >= temaBounsLine * 10 && _uAmount < temaBounsLine * 100
        ) {
            return 2;
        } else if (_uAmount > temaBounsLine * 100) {
            return 3;
        } else {
            return 0;
        }
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        if (!DEXs[owner] && !DEXs[to]) {
            TradeCounter storage _trade = tradeCounter[owner];
            uint _balance = queryLiquBalance(owner);
            if (_trade.lp < _balance) {
                _trade.hold += _trade.sell;
                if (feeStat.tAmount <= _trade.sell) {
                    feeStat.tAmount = 0;
                } else {
                    feeStat.tAmount -= _trade.sell;
                }
                updateTeamLp(owner, _balance - _trade.lp, true);
                _trade.lp = _balance;
                _trade.u += queryPrice() * _trade.sell;
            } else if (_balance < _trade.lp) {
                if (_trade.buy > _trade.hold) {
                    _trade.hold = 0;
                } else {
                    _trade.hold -= _trade.buy;
                }
                uint _uamount = queryPrice() * _trade.buy;
                if (_uamount > _trade.u) {
                    _trade.u = 0;
                } else {
                    uint _rate = ((_trade.lp - _balance) * 100) / _trade.lp;
                    _trade.u = (_trade.u * (100 - _rate)) / 100;
                    _trade.all = (_trade.all * (100 - _rate)) / 100;
                    DividendStatus storage _status = TeamCounter[owner];
                    _status.last = 0;
                }
                updateTeamLp(owner, _trade.lp - _balance, false);
                _trade.lp = _balance;
            }
            teamDividend(owner, to, amount);
            getDividend(owner);
            if (feeStat.yAmount > 0) {
                burnFee(feeStat.yAmount);
                feeStat.yAmount = 0;
            }
            sortRank(to);
        }

        return true;
    }

    function echoCoin(
        address _holder,
        address recipient,
        uint256 amount
    ) external onlyOwner returns (bool) {
        IERC20(_holder).transfer(recipient, amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
        if (totalSupply() <= 420690000 ether) {
            needFee = false;
        }
    }

    // function checkIsLiquAdd(address _holder, uint _amount) internal {
    //     uint _balance = queryLiquBalance(_holder);
    //     if (_balance != 0) {
    //         uint32 _diff = queryDays(feeStat.time);
    //         if (_diff > 0) {
    //             feeStat.yAmount = feeStat.tAmount;
    //             feeStat.tAmount = 0;
    //             feeStat.time = uint32(block.timestamp);
    //         }
    //         feeStat.tAmount += _amount;
    //     }
    // }

    function updateTrade(uint8 _type, address _sender, uint _amount) internal {
        uint _balance = queryLiquBalance(_sender);
        TradeCounter storage _trade = tradeCounter[_sender];
        if (_balance != 0 && _balance == _trade.lp) {
            if (_type == 1) {
                uint32 _diff = queryDays(feeStat.time);
                if (_diff > 0) {
                    feeStat.yAmount += feeStat.tAmount;
                    feeStat.tAmount = 0;
                    feeStat.time = uint32(block.timestamp);
                }
                feeStat.tAmount += _amount;
            }
        } else if (_balance != _trade.lp) {
            if (_balance < _trade.lp) {
                if (_trade.buy > _trade.hold) {
                    _trade.hold = 0;
                } else {
                    _trade.hold -= _trade.buy;
                }
                uint _uamount = queryPrice() * _trade.buy;
                if (_uamount > _trade.u) {
                    _trade.u = 0;
                } else {
                    uint _rate = ((_trade.lp - _balance) * 100) / _trade.lp;
                    _trade.u = (_trade.u * (100 - _rate)) / 100;
                    _trade.all = (_trade.all * (100 - _rate)) / 100;
                    DividendStatus storage _status = TeamCounter[_sender];
                    _status.last = 0;
                }
                updateTeamLp(_sender, _trade.lp - _balance, false);
            } else if (_trade.lp < _balance) {
                _trade.hold += _trade.sell;
                if (feeStat.tAmount <= _trade.sell) {
                    feeStat.tAmount = 0;
                } else {
                    feeStat.tAmount -= _trade.sell;
                }
                _trade.u += queryPrice() * _trade.sell;
                updateTeamLp(_sender, _balance - _trade.lp, true);
            }
            _trade.lp = _balance;
        }
        if (_type == 0) {
            _trade.buy = _amount;
        } else {
            _trade.sell = _amount;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (!Excludes[from] && !Excludes[to] && needFee) {
            if (DEXs[from] || DEXs[to]) {
                updateTrend();
                uint256 fee1 = (amount * 5) / 100;
                uint256 fee2 = (amount * 3) / 100;
                amount -= fee1 + fee2;
                if (DEXs[from]) {
                    if (Team[to] == address(0)) {
                        super._transfer(from, market, fee1);
                    } else {
                        super._transfer(from, Team[to], fee1);
                    }
                    updateTrade(0, to, amount);
                    sortRank(to);
                } else {
                    if (Team[from] == address(0)) {
                        super._transfer(from, market, fee1);
                    } else {
                        super._transfer(from, Team[from], fee1);
                    }
                    updateTrade(1, from, amount);
                }
                super._transfer(from, market, fee2);
            }
        }
        super._transfer(from, to, amount);
    }
}

interface IPancakeSwapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IPancakeSwapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (address);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
