// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPancakeFactoryV2 {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IPancakeRouterV2 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BF is IERC20Metadata {
    using SafeMath for uint256;

    string public constant override name = "BF";
    string public constant override symbol = "BF";
    uint8 public constant override decimals = 18;
    uint256 public constant override totalSupply = 80_000_000e18;

    uint256 private constant MASK = type(uint256).max;
    uint256 private constant dexFee = 5;
    bool private dexFeeEnable = false;
    bool private buyLock = true;
    uint256 private lastFeeAmount;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private platformBuys;

    event Swap(uint256 token, uint256 usdt);

    address immutable usdt;
    address public immutable pair;
    address private immutable lockAddress;
    address private immutable feeAddress;
    IPancakeRouterV2 private immutable router;

    constructor(
        address factory_,
        address router_,
        address usdt_,
        address initReceive_,
        address feeAddress_,
        address lockAddress_,
        address[] memory accounts_
    ) {
        router = IPancakeRouterV2(router_);
        _allowances[address(this)][router_] = MASK;
        usdt = usdt_;
        pair = IPancakeFactoryV2(factory_).createPair(address(this), usdt_);
        platformBuys[pair] = true;
        platformBuys[address(this)] = true;
        platformBuys[router_] = true;
        for (uint8 i = 0; i < accounts_.length; i++) {
            platformBuys[accounts_[i]] = true;
        }
        lockAddress = lockAddress_;
        feeAddress = feeAddress_;
        _balances[initReceive_] = totalSupply;
        emit Transfer(address(this), initReceive_, totalSupply);
    }

    function _setBuyLock(bool lock) external {
        require(msg.sender == lockAddress);

        buyLock = lock;
    }

    function _setEnableDexFee(bool enable) external {
        require(msg.sender == lockAddress);

        dexFeeEnable = enable;
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(address(0) != spender, "BF: APPROVE_ADDRESS_ZERO");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transferTokens(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = _allowances[sender][spender];
        if (spender != sender && spenderAllowance != MASK) {
            uint256 newAllowance = spenderAllowance.sub(amount);
            _allowances[sender][spender] = newAllowance;
            emit Approval(sender, spender, newAllowance);
        }
        _transferTokens(sender, recipient, amount);
        return true;
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) internal {
        require(address(0) != src, "BF: ADDRESS_ZERO_TRANSFER");
        if (buyLock && src == pair) require(platformBuys[dst], "BF: BUY LOCK");

        _balances[src] = _balances[src].sub(amount);
        if (dexFeeEnable) {
            if (
                src == address(this) ||
                dst == address(this) ||
                (src != pair && dst != pair)
            ) {
                _balances[dst] = _balances[dst].add(amount);
                emit Transfer(src, dst, amount);
                return;
            }
            uint256 feeAmount = amount.mul(dexFee).div(100);
            uint256 actualAmount = amount.sub(feeAmount);
            _balances[dst] = _balances[dst].add(actualAmount);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(src, dst, actualAmount);
            emit Transfer(src, address(this), feeAmount);
        } else {
            _balances[dst] = _balances[dst].add(amount);
            emit Transfer(src, dst, amount);
        }
    }

    function swap() external {
        _swap();
    }

    function _swap() internal {
        uint256 number = _balances[address(this)];
        if (number == 0) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        router.swapExactTokensForTokens(
            number,
            0,
            path,
            feeAddress,
            block.timestamp + 15
        );
    }
}

library SafeMath {
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return sub(_a, _b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 _a,
        uint256 _b,
        string memory _errorMessage
    ) internal pure returns (uint256) {
        require(_b <= _a, _errorMessage);
        uint256 c = _a - _b;
        return c;
    }

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return div(_a, _b, "SafeMath: division by zero");
    }

    function div(
        uint256 _a,
        uint256 _b,
        string memory _errorMessage
    ) internal pure returns (uint256) {
        require(_b > 0, _errorMessage);
        uint256 c = _a / _b;
        return c;
    }
}