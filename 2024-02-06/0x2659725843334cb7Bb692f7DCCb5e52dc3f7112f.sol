// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface ISwapPair {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

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

interface ISwapFactory {
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
}

interface ISwapRouter {
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

contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalCirculation;
    uint256 private _minTotalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function totalCirculation() public view virtual returns (uint256) {
        return _totalCirculation;
    }

    function minTotalSupply() public view virtual returns (uint256) {
        return _minTotalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function _transfer(
        address from,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        address to = recipient;
        if (address(1) == recipient) to = address(0);
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _totalCirculation += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burnSafe(
        address account,
        uint256 amount
    ) internal virtual returns (bool) {
        require(account != address(0), "ERC20: burn from the zero address");
        if (_totalCirculation > _minTotalSupply + amount) {
            _beforeTokenTransfer(account, address(0), amount);
            uint256 accountBalance = _balances[account];
            require(
                accountBalance >= amount,
                "ERC20: burn amount exceeds balance"
            );
            unchecked {
                _balances[account] = accountBalance - amount;
                _balances[address(0)] += amount;
            }
            emit Transfer(account, address(0), amount);
            _afterTokenTransfer(account, address(0), amount);
            return true;
        }
        return false;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _balances[address(0)] += amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (to == address(0) && _totalCirculation >= amount) {
            _totalCirculation -= amount;
        }
    }

    function _setMinTotalSupply(uint256 amount) internal {
        _minTotalSupply = amount;
    }
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Manager is Ownable {
    address public manager;
    modifier onlyManager() {
        require(manager == _msgSender(), "Ownable: Not Manager");
        _;
    }

    function setManager(address account) public virtual onlyManager {
        manager = account;
    }
}

contract LPDividend is Manager {
    using Address for address;
    struct UserInfo {
        bool isValid;
        bool isBlackList;
        uint index;
        uint lp;
        uint reward;
    }
    uint private _userTotal;
    mapping(uint => address) public userAdds;
    mapping(address => UserInfo) public users;
    uint private _currentIndex;
    uint private _rewardMin = 10e8;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    IERC20 private _TOKEN;
    IERC20 private _LP;

    constructor(address _manager, address token, address lp) {
        manager = _manager;
        _TOKEN = IERC20(token);
        _LP = IERC20(lp);
    }

    function withdrawToken(IERC20 token, uint256 amount) public onlyManager {
        token.transfer(msg.sender, amount);
    }

    function setToken(address token) public onlyManager {
        _TOKEN = IERC20(token);
    }

    function setLP(address lp) public onlyManager {
        _LP = IERC20(lp);
    }

    function setRewardMin(uint rewardMin) public onlyManager {
        _rewardMin = rewardMin;
    }

    function setIsBlackList(address account, bool enable) public onlyManager {
        users[account].isBlackList = enable;
    }

    function addUser(address account) public onlyManager {
        if (account.isContract() || account == _dead) return;
        if (account == address(0) || account == address(1)) return;
        if (users[account].index == 0) {
            _userTotal++;
            userAdds[_userTotal] = account;
            users[account].isValid = true;
            users[account].index = _userTotal;
        } else if (!users[account].isValid) {
            users[account].isValid = true;
        }
    }

    function sendReward(uint gas) public {
        uint totalPair = _LP.totalSupply();
        if (0 == totalPair) {
            return;
        }
        if (address(_TOKEN) == address(0)) return;
        if (_TOKEN.balanceOf(address(this)) < _rewardMin) {
            return;
        }
        uint reward;
        uint gasUsed = 0;
        uint gasLeft = gasleft();
        address account;
        for (uint i = 0; i < _userTotal; i++) {
            if (_currentIndex >= _userTotal) {
                _currentIndex = 0;
                break;
            }
            account = userAdds[_currentIndex + 1];
            if (users[account].isValid && !users[account].isBlackList) {
                if (_LP.balanceOf(account) != users[account].lp) {
                    users[account].lp = _LP.balanceOf(account);
                }
                if (users[account].lp > 0) {
                    reward = (_rewardMin * users[account].lp) / totalPair;
                    if (reward > 0) {
                        _TOKEN.transfer(account, reward);
                        users[account].reward += reward;
                    }
                } else {
                    users[account].isValid = false;
                }
            }
            _currentIndex++;
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            if (gasUsed > gas) {
                break;
            }
        }
    }

    function getConfig()
        public
        view
        returns (
            uint currentIndex,
            uint userTotal,
            uint rewardMin,
            address token,
            address lp
        )
    {
        currentIndex = _currentIndex;
        userTotal = _userTotal;
        rewardMin = _rewardMin;
        token = address(_TOKEN);
        lp = address(_LP);
    }

    function getUsersAll()
        public
        view
        returns (address[] memory accounts, UserInfo[] memory infos)
    {
        accounts = new address[](_userTotal);
        infos = new UserInfo[](_userTotal);
        for (uint256 i = 0; i < _userTotal; i++) {
            accounts[i] = userAdds[i + 1];
            infos[i] = users[accounts[i]];
        }
    }

    function getUsers(
        uint startIndex,
        uint endIndex
    ) public view returns (address[] memory accounts, UserInfo[] memory infos) {
        require(endIndex > startIndex, "Index Error");
        uint total = endIndex - startIndex + 1;
        accounts = new address[](total);
        infos = new UserInfo[](total);
        for (uint256 i = 0; i < total; i++) {
            if (i + startIndex + 1 < _userTotal) {
                accounts[i] = userAdds[i + startIndex + 1];
                infos[i] = users[accounts[i]];
            }
        }
    }
}

contract ALONG is ERC20, Manager {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => bool) public isFeeExempt;
    mapping(address => uint) public userMints;
    uint private _mintTotal;
    uint private _openTime = 1707480000;
    uint private _startBlock;
    uint private _burnBlock;
    uint private _lpSurplus;
    uint private _backSurplus;
    uint private _dividendGas = 300000;
    uint private _swapMin = 1e10;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    address private _recieve;
    address private _market;
    address private _swapPair;
    IERC20 private _DOGE;
    ISwapRouter private _swapRouter;
    LPDividend private _lpDividend;
    bool _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor() ERC20("\u4e2d\u56fd\u9f8d", "\u9f8d") {
        manager = 0xbb851112cB5912311bf4EDC83011819B52c3679e;
        _recieve = 0xEB883eF77e3159607B3cFaf57B8c29C16aa9DC5A;
        _market = 0x722E0A5Eda997AC55E16a445f61467d4419888eC;
        _DOGE = IERC20(0xbA2aE424d960c26247Dd6c32edC70B295c744C43);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _swapPair = pairFor(
            _swapRouter.factory(),
            address(this),
            _swapRouter.WETH()
        );
        isFeeExempt[address(this)] = true;
        isFeeExempt[_recieve] = true;
        isFeeExempt[_market] = true;
        _lpDividend = new LPDividend(manager, address(_DOGE), _swapPair);
        _mint(address(this), 2100_0000_0000_0000 * 10 ** decimals());
        renounceOwnership();
    }

    receive() external payable {
        address account = msg.sender;
        uint cellMin = 5e15;
        require(msg.value <= cellMin * 10, "BNB Over Max");
        require(msg.value >= cellMin, "BNB Lower Min");
        require(msg.value % cellMin == 0, "BNB Error");
        require(_startBlock == 0, "Has End");
        require(block.timestamp < _openTime, "Has End");
        uint copies = msg.value / cellMin;
        require(_mintTotal + copies <= 21_0000, "Mint Over Max");
        require(userMints[account] + copies <= 100, "Mint Over User");
        super._transfer(address(this), account, copies * 5e27);
        super._transfer(address(this), _dead, copies * 2e27);
        _addLiquidityEth(copies * 3e27, (copies * cellMin * 3) / 10);
        payable(_recieve).transfer(address(this).balance);
        _mintTotal += copies;
        userMints[account] += copies;
    }

    function withdrawToken(IERC20 token, uint256 amount) public {
        if (manager == _msgSender()) {
            token.transfer(msg.sender, amount);
        }
    }

    function setMarket(address data) public {
        if (manager == _msgSender()) {
            _market = data;
        }
    }

    function setLPDividend(address data) public {
        if (manager == _msgSender()) {
            _lpDividend = LPDividend(data);
        }
    }

    function setSwapMin(uint data) public {
        if (manager == _msgSender()) {
            _swapMin = data;
        }
    }

    function setIsFeeExempt(address account, bool enable) public {
        if (manager == _msgSender()) {
            isFeeExempt[account] = enable;
        }
    }

    function setIsDividend(address account, bool enable) public {
        if (manager == _msgSender()) {
            _lpDividend.setIsBlackList(account, enable);
        }
    }

    function setRewardMin(uint rewardMin) public {
        if (manager == _msgSender()) {
            _lpDividend.setRewardMin(rewardMin);
        }
    }

    function setDividendGas(uint gasLimit) public {
        if (manager == _msgSender()) {
            _dividendGas = gasLimit;
        }
    }

    function addUser(address account) public {
        if (manager == _msgSender()) {
            _lpDividend.addUser(account);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (_startBlock == 0 && block.timestamp >= _openTime) {
            super._transfer(address(this), _dead, balanceOf(address(this)));
            _startBlock = block.number;
            _burnBlock = block.number;
        }
        if (_inSwapAndLiquify || isFeeExempt[from] || isFeeExempt[to]) {
            super._transfer(from, to, amount);
        } else if (from == _swapPair || to == _swapPair) {
            if (_startBlock == 0) {
                super._transfer(from, address(0), amount);
            } else {
                if (to == _swapPair) {
                    _burnPool();
                    _backPool();
                    _swapToDevidend();
                    _swapAndLiquify();
                }
                uint256 every = amount.div(100);
                super._transfer(from, address(this), every * 5);
                _lpSurplus += every * 3;
                _backSurplus += every;
                super._transfer(from, to, amount - every * 5);
                if (
                    !_inSwapAndLiquify && !isFeeExempt[from] && _startBlock > 0
                ) {
                    _inSwapAndLiquify = true;
                    _lpDividend.sendReward(_dividendGas);
                    _inSwapAndLiquify = false;
                }
            }
        } else {
            uint256 every = amount.div(100);
            super._transfer(from, address(this), every * 5);
            _lpSurplus += every * 3;
            _backSurplus += every;
            super._transfer(from, to, amount - every * 5);
            if (_startBlock > 0) {
                _burnPool();
                _backPool();
            }
        }
        if (_startBlock > 0 && from == _swapPair) {
            _lpDividend.addUser(to);
        } else if (_startBlock > 0 && to == _swapPair) {
            _lpDividend.addUser(from);
        }
    }

    function getConfig()
        public
        view
        returns (
            uint swapMin,
            uint mintTotal,
            uint openTime,
            uint startBlock,
            uint burnBlock,
            uint lpSurplus,
            uint backSurplus,
            uint dividendGas
        )
    {
        swapMin = _swapMin;
        mintTotal = _mintTotal;
        openTime = _openTime;
        startBlock = _startBlock;
        burnBlock = _burnBlock;
        lpSurplus = _lpSurplus;
        backSurplus = _backSurplus;
        dividendGas = _dividendGas;
    }

    function getToken()
        public
        view
        returns (
            address recieve,
            address market,
            address swapPair,
            address doge,
            address router,
            address lpDividend
        )
    {
        recieve = _recieve;
        market = _market;
        swapPair = _swapPair;
        doge = address(_DOGE);
        router = address(_swapRouter);
        lpDividend = address(_lpDividend);
    }

    function getAutoSwapMin() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _swapRouter.WETH();
        path[1] = address(this);
        address swapPair = ISwapFactory(_swapRouter.factory()).getPair(
            _swapRouter.WETH(),
            address(this)
        );
        if (swapPair == address(0)) return totalSupply();
        (uint256 reserve1, uint256 reserve2, ) = ISwapPair(swapPair)
            .getReserves();
        if (reserve1 == 0 || reserve2 == 0) {
            return totalSupply();
        } else {
            return _swapRouter.getAmountsOut(_swapMin, path)[1];
        }
    }

    function _burnPool() private lockTheSwap returns (bool) {
        if (_startBlock == 0) return false;
        if (_burnBlock < block.number && _burnBlock > 0) {
            _burnBlock += 28800 / 24 / 4;
            address swapPair = ISwapFactory(_swapRouter.factory()).getPair(
                _swapRouter.WETH(),
                address(this)
            );
            if (swapPair == address(0)) return false;
            uint256 burnAmount = (balanceOf(swapPair) * 1) / 10000;
            if (burnAmount > 1) {
                super._transfer(swapPair, _dead, burnAmount);
                try ISwapPair(swapPair).sync() {} catch {}
                return true;
            }
        }
        return false;
    }

    function _backPool() private lockTheSwap returns (bool) {
        if (_startBlock == 0) return false;
        uint256 amount = balanceOf(address(this));
        if (_backSurplus > 0 && amount >= _backSurplus) {
            address swapPair = ISwapFactory(_swapRouter.factory()).getPair(
                _swapRouter.WETH(),
                address(this)
            );
            if (swapPair == address(0)) return false;
            super._transfer(address(this), swapPair, _backSurplus);
            _backSurplus = 0;
            try ISwapPair(swapPair).sync() {} catch {}
            return true;
        }
        return false;
    }

    function _swapToDevidend() private lockTheSwap returns (bool) {
        if (_startBlock == 0) return false;
        uint256 amount = balanceOf(address(this));
        if (amount >= _lpSurplus && _lpSurplus > getAutoSwapMin()) {
            _swapTokensForDOGE(_lpSurplus);
            _lpSurplus = 0;
            return true;
        }
        return false;
    }

    function _swapAndLiquify() private lockTheSwap returns (bool) {
        if (_startBlock == 0) return false;
        if (balanceOf(address(this)) <= _lpSurplus + _backSurplus) return false;
        uint amount = (balanceOf(address(this)) - _lpSurplus - _backSurplus);
        if (amount > getAutoSwapMin()) {
            _swapTokensForETH(amount);
            return true;
        }
        return false;
    }

    function _swapTokensForETH(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        IERC20(address(this)).approve(address(_swapRouter), tokenAmount);
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _market,
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    event SwapTokensForETH(uint256 amountIn, address[] path);

    function _swapTokensForDOGE(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(_swapRouter.WETH());
        path[2] = address(_DOGE);
        _approve(address(this), address(_swapRouter), tokenAmount);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_lpDividend),
            block.timestamp
        );
        emit SwapTokensForTokens(tokenAmount, path);
    }

    event SwapTokensForTokens(uint256 amountIn, address[] path);

    function _addLiquidityEth(uint256 tokenAmount, uint256 ethAmount) internal {
        IERC20(address(this)).approve(address(_swapRouter), tokenAmount);
        _swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _dead,
            block.timestamp
        );
        emit AddLiquidity(tokenAmount, ethAmount);
    }

    event AddLiquidity(uint256 tokenAmount, uint256 ethAmount);

    function sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5"
                        )
                    )
                )
            )
        );
    }
}