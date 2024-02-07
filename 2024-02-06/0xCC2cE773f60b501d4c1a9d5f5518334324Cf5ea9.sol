// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

    function _burnDead(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(
            account,
            0x000000000000000000000000000000000000dEaD,
            amount
        );
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _balances[0x000000000000000000000000000000000000dEaD] += amount;
        }
        emit Transfer(
            account,
            0x000000000000000000000000000000000000dEaD,
            amount
        );
        _afterTokenTransfer(
            account,
            0x000000000000000000000000000000000000dEaD,
            amount
        );
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

interface burnedFiAbi {
    function launch() external view returns (bool);

    function setLaunch(bool flag) external;
}

contract burnAirdrop is Context {
    using SafeMath for uint256;
    uint256 public totalDroped;
    uint256 public threshold;
    uint256 public _block;
    uint256 private _countBlock;
    burnedFiAbi public _burnedFi;
    ISwapRouter public uniswapRouter;
    bool inits = false;
    struct User {
		address referrer; //上级
        uint256 idoBonus;  // IDO奖励
        uint[2] refs;  //每代人数
        uint256[2] refStageIncome;  //每代mint数量
    }
    mapping (address => User) internal users;

    function init(address burnedFiAddr, address routeAddr) public {
        require(!inits, 'initsd');
        inits = true;
        _burnedFi = burnedFiAbi(burnedFiAddr);
        ISwapRouter _uniswapV2Router = ISwapRouter(routeAddr);
        uniswapRouter = _uniswapV2Router;
    }

    event Upline(address indexed addr, address indexed upline);
    function mint(address referrer) public payable {
        uint256 singleAmount = 50000 * 10 ** 18; //基础token数
        uint256 _value = 0.02 * 10 ** 18; //基础bnb数
        //计算转的BNB和基础的是多少倍
        uint256 beishu = msg.value / _value;
        //计算应该给多少token
        uint256 dropAmount = singleAmount * beishu;

        require(msg.value >= _value , "Minimum drop amount not met");
        address _msgSender = msg.sender;
        User storage user = users[_msgSender];
        if(user.referrer == address(0)){
            user.referrer = referrer;
            emit Upline(msg.sender,referrer);
            address upline = user.referrer;
            for (uint256 i = 0; i < 2; i++) {
                if (upline != address(0)) {
                    users[upline].refs[i] = users[upline].refs[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (!_burnedFi.launch() && _msgSender != address(this)) {
            require(_msgSender == tx.origin, "Only EOA");
            if (_countBlock < 10) {
                ++_countBlock;
                ++totalDroped;
                ++threshold;
                IERC20 token = IERC20(address(_burnedFi));
                require(token.balanceOf(address(this)) >= dropAmount, "Droped out");
                token.transfer(_msgSender, dropAmount);
                _takeInviterFee(_msgSender, msg.value);
            } else if (_block != block.number) {
                _block = block.number;
                _countBlock = 0;
            }
        }
    }

    //团队奖励
    function _takeInviterFee(address sender, uint amount) internal {
        User storage user = users[sender];
        address upline = user.referrer;
        uint8[2] memory inviteRate =  [8, 4];
        for (uint8 i = 0; i < 2; i++) {
            if(upline == address(0)){upline = address(this);}
            uint8 rate = inviteRate[i];
            uint256 curTAmount = amount * rate / 100;
            users[upline].idoBonus = users[upline].idoBonus.add(curTAmount);  //奖励的U
            users[upline].refStageIncome[i] = users[upline].refStageIncome[i].add(amount);
            upline = users[upline].referrer;
        }
    }

    //团队信息  用户第index代人数、 购买数量U、奖励U、提现
	function referral_stage(address _user,uint _index)external view returns(uint _noOfUser,uint256 _investment){
		return (users[_user].refs[_index],users[_user].refStageIncome[_index]);
	}

    //用户信息 用户购买时间点/上级/U奖励/总邀请人数/token数量
	function getUserInfo(address userAddress) public view returns(address,uint256){
		User storage user = users[userAddress];

		return (user.referrer,user.idoBonus);
	}

    //提现
    function withdrawal() external {
        User storage user = users[msg.sender];
        uint256 TotalBonus = user.idoBonus;
        if(TotalBonus > 0){
            payable(address(msg.sender)).transfer(TotalBonus);
            user.idoBonus = 0;
        }
    }

    function recover() public {
        if (_burnedFi.launch()) {
            uint256 amount = payable(address(this)).balance;
            payable(address(_burnedFi)).transfer(amount);

            IERC20 token = IERC20(address(_burnedFi));
            uint256 tokenAmount = token.balanceOf(address(this));
            token.transfer(address(_burnedFi), tokenAmount);
        }
    }
}

contract ALTS is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bool public isOpenSwap;
    mapping(address => bool) public isFeeExempt;
    uint private _burnBlock;
    uint private _openTime;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    address private _swapPair;
    IERC20 private _WETH;
    ISwapRouter private _ROUTER;
    bool _inSwapAndLiquify;
    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    bytes32 private hashPair;
    burnAirdrop public airdropAddr;

    constructor() ERC20("ALTS", "ALTS") {
        address recieve = msg.sender;
        if (block.chainid == 56) {
            _ROUTER = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            hashPair = 0x00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5;
        } else if (block.chainid == 97) {
            _ROUTER = ISwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
            hashPair = 0xd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66;
        }
        burnAirdrop _airdrop = new burnAirdrop();
        _airdrop.init(address(this), address(_ROUTER));
        airdropAddr = _airdrop;
        _WETH = IERC20(_ROUTER.WETH());
        _swapPair = pairFor(_ROUTER.factory(), address(this), address(_WETH));
        isFeeExempt[address(this)] = true;
        isFeeExempt[address(1)] = true;
        isFeeExempt[_dead] = true;
        isFeeExempt[recieve] = true;
        isFeeExempt[address(_airdrop)] = true;
        _mint(recieve, 100000000 * 10 ** decimals());
        _mint(address(_airdrop), 1000000000 * 10 ** 18);
    }

    receive() external payable {}

    bool public launch = false;

    function setLaunch(bool flag) public {
        require(address(airdropAddr) == msg.sender, 'only AirDrop');
        launch = flag;
        launch = false;
    }

    function manLaunch(bool flag) public onlyOwner {
        launch = flag;
    }

    function withdrawETH(uint256 _amount) public onlyOwner {
        uint256 amount = (_amount < address(this).balance) ? _amount : address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }

    function setIsFeeExempt(address account, bool newValue) public onlyOwner {
        isFeeExempt[account] = newValue;
    }

    function setOpenTime(uint openTime) public onlyOwner {
        _openTime = openTime;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (_inSwapAndLiquify || isFeeExempt[from] || isFeeExempt[to]) {
            super._transfer(from, to, amount);
            if (!isOpenSwap && to == _swapPair && isFeeExempt[from]) {
                isOpenSwap = true;
                _burnBlock = block.number;
            }
        } else if (from == _swapPair) {
            require(isOpenSwap && _openTime > 0 && _openTime < block.timestamp);
            uint256 every = amount.div(100);
            super._burnDead(from, every);
            super._transfer(from, address(this), every * 3);
            super._transfer(from, to, amount - every * 4);
        } else if (to == _swapPair) {
            if (!isOpenSwap || _openTime == 0 || _openTime > block.timestamp) {
                super._burnDead(from, amount);
            } else {
                _burnPool();
                _swapAndLiquify();
                uint256 every = amount.div(100);
                super._burnDead(from, every);
                super._transfer(from, address(this), every * 3);
                super._transfer(from, to, amount - every * 4);
            }
        } else {
            super._transfer(from, to, amount);
            _burnPool();
        }
    }

    function getToken()
        public
        view
        returns (
            address swapPair,
            address usdt,
            address router,
            uint burnBlock,
            uint openTime
        )
    {
        swapPair = _swapPair;
        usdt = address(_WETH);
        router = address(_ROUTER);
        burnBlock = _burnBlock;
        openTime = _openTime;
    }

    function getAddLiquidityToken(uint otherAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(_WETH);
        path[1] = address(this);
        address pair = ISwapFactory(_ROUTER.factory()).getPair(
            address(_WETH),
            address(this)
        );
        if (pair == address(0)) return 0;
        (uint256 reserve1, uint256 reserve2, ) = ISwapPair(pair).getReserves();
        address token0 = ISwapPair(pair).token0();
        if (reserve1 == 0 || reserve2 == 0) {
            return 0;
        } else if (token0 == address(this)) {
            return (otherAmount * reserve1) / reserve2;
        } else if (token0 == address(_WETH)) {
            return (otherAmount * reserve2) / reserve1;
        } else return 0;
    }

    function swapAndTrans() public {
        _burnPool();
        _swapAndLiquify();
    }

    function _burnPool() private lockTheSwap returns (bool) {
        if (_burnBlock < block.number && _burnBlock > 0) {
            _burnBlock += 28800 / 24;
            uint256 burnAmount = (balanceOf(_swapPair) * 4) / 1000; //余额的千分之四
            if (burnAmount > 1) {
                super._burn(_swapPair, burnAmount);
                try ISwapPair(_swapPair).sync() {} catch {}
                return true;
            }
        }
        return false;
    }

    function _swapAndLiquify() private lockTheSwap returns (bool) {
        uint every = balanceOf(address(this)) / 10;
        uint amount = every * 6;
        if (amount > 1e9) {
            address token0 = ISwapPair(_swapPair).token0();
            (uint256 reserve0, uint256 reserve1, ) = ISwapPair(_swapPair)
                .getReserves();
            uint256 tokenPool = reserve0;
            if (token0 != address(this)) tokenPool = reserve1;
            if (amount > tokenPool / 100) {
                amount = tokenPool / 100;
            }
            _swapTokensForETH(amount);
            _addLiquidityEth(every * 3, address(this).balance / 2);
            return true;
        }
        return false;
    }

    function _swapTokensForETH(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _ROUTER.WETH();
        IERC20(address(this)).approve(address(_ROUTER), tokenAmount);
        _ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    event SwapTokensForETH(uint256 amountIn, address[] path);

    function _addLiquidityEth(uint256 tokenAmount, uint256 ethAmount) internal {
        IERC20(address(this)).approve(address(_ROUTER), tokenAmount);
        _ROUTER.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
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
    ) internal view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hashPair
                        )
                    )
                )
            )
        );
    }
}