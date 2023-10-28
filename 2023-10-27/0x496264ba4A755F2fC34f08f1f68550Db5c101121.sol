/**
 *Submitted for verification at BscScan.com on 2023-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2023-10-11
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

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
        require(
            owner() == _msgSender() || manager == _msgSender(),
            "Ownable: Not Manager"
        );
        _;
    }

    function setManager(address account) public virtual onlyManager {
        manager = account;
    }
}

contract LPDividend is Manager {
    address[] private _userAdds;
    mapping(address => uint256) public userIndex;
    mapping(address => bool) public isBlackList;
    uint private _currentIndexTOKEN;
    uint private _currentIndexUSDT;
    uint private _rewardMinTOKEN = 30e18;
    uint private _rewardMinUSDT = 20e18;
    uint public blackPairTOKEN= 0;
    IERC20 private _TOKEN;
    IERC20 private _USDT;
    IERC20 private _LP;

    // constructor(address _manager, address token, address lp) {
        // manager = _manager;
        // _TOKEN = IERC20(token);
        // _LP = IERC20(lp);
    // }

    constructor() {
        manager = 0x4704E156Bb768cbCBa553CAd23e159fdD1baCb52;
        _TOKEN = IERC20(0x7784F4DC4aBC9D33F167C3d9A290E900A3C78777);
        _USDT = IERC20(0x5fB8D4a72Bd8eBc4bc6804B66f44B67e2Bb57C65);
        _LP = IERC20(0xBf2BF240C645933f51c85cbD5402ba2982Bba72F);
        blackPairTOKEN = _LP.balanceOf(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
        setIsBlackList(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE,true);
        
        addUserByHandle(0x0c7E70cFD4F6ADc27B08d0F659EC5850d3A5A92f);
        addUserByHandle(0x166CA1bEF2bED011A0534881390fB32D1f49789B);
        addUserByHandle(0x4B648b2eEed265C4CddA5Bc0abD1aaa6ec869d67);
        addUserByHandle(0x591b38AEd574CA2fEF78330A2Fb3279bf075D2E5);
        addUserByHandle(0x7C41f9f3cB19aC9374899b5525C701D953390b80);
        transferOwnership(0x7784F4DC4aBC9D33F167C3d9A290E900A3C78777);
    }

    function withdrawToken(IERC20 token, uint256 amount) public onlyManager {
        token.transfer(msg.sender, amount);
    }

    function setToken(address token) public onlyManager {
        _TOKEN = IERC20(token);
    }

    function setUSDT(address data) public onlyManager {
        _USDT = IERC20(data);
    }

    function setLP(address lp) public onlyManager {
        _LP = IERC20(lp);
    }

    function setRewardMinTOKEN(uint rewardMin) public onlyManager {
        _rewardMinTOKEN = rewardMin;
    }

    function setRewardMinUSDT(uint rewardMin) public onlyManager {
        _rewardMinUSDT = rewardMin;
    }

    function setIsBlackList(address account, bool enable) public onlyManager {
        isBlackList[account] = enable;
    }

    function addUser(address account) public onlyManager {
        // GPMM TOKEN will invoke it ,replace handle ,so empty code  
        //                                       use  ---->  addUserByHandle
        
        // if (userIndex[account] == 0) {
            // if (_userAdds.length == 0 || _userAdds[0] != account) {
                // userIndex[account] = _userAdds.length;
                // _userAdds.push(account);
            // }
        // }
    }

    function addUserList(address[] memory users) public onlyManager{
        for (uint i = 0; i < users.length; i++) {
            addUserByHandle(users[i]);
        }
    }

    function addUserByHandle(address  account) public onlyManager {

        if (userIndex[account] == 0) {
            if (_userAdds.length == 0 || _userAdds[0] != account) {
                userIndex[account] = _userAdds.length;
                _userAdds.push(account);
            }
        }
    }

    function removeUser(address account) public onlyManager {
        require(userIndex[account] > 0 || (_userAdds.length > 0 && _userAdds[0] == account) , "User not found in the list");
        uint256 indexToRemove = userIndex[account];
        address lastUser = _userAdds[_userAdds.length - 1];

        // Move the last user to the position of the user to be removed
        _userAdds[indexToRemove] = lastUser;
        userIndex[lastUser] = indexToRemove;
        
        // Remove the last element
        _userAdds.pop();
        userIndex[account] = 0;
    }



    function sendReward(uint gas) public {
        sendRewardToken(gas);
    }

    function setblackPairTOKEN(uint token) public onlyManager{
        blackPairTOKEN = token;
    }

    function sendRewardToken(uint gas) public {
        uint totalPair = _LP.totalSupply() - blackPairTOKEN;
        if (0 == totalPair) {
            return;
        }
        if (address(_TOKEN) == address(0)) return;
        if (_TOKEN.balanceOf(address(this)) < _rewardMinTOKEN) {
            return;
        }
        uint rewardToken = _TOKEN.balanceOf(address(this));
        uint reward;
        uint gasUsed = 0;
        uint gasLeft = gasleft();
        uint total = _userAdds.length;
        for (uint i = 0; i < total; i++) {
            if (_currentIndexTOKEN >= total) {
                _currentIndexTOKEN = 0;
            }
            if (
                _LP.balanceOf(_userAdds[_currentIndexTOKEN]) > 0 &&
                !isBlackList[_userAdds[_currentIndexTOKEN]]
            ) {
                reward =
                    (rewardToken *
                        _LP.balanceOf(_userAdds[_currentIndexTOKEN])) /
                    totalPair;
                if (reward > 0) {
                    _TOKEN.transfer(_userAdds[_currentIndexTOKEN], reward);
                }
            }
            _currentIndexTOKEN++;
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            if (gasUsed > gas) {
                break;
            }
        }
    }

    function getTokenRewardByUser(address _addr) public view returns(uint){
        uint totalPair = _LP.totalSupply() - blackPairTOKEN;
        uint rewardToken = _TOKEN.balanceOf(address(this));
        uint reward = (rewardToken * _LP.balanceOf(_addr)) /  totalPair;
        return reward;
    }

    function getUSDTRewardByUser(address _addr) public view returns(uint){
        uint totalPair = _LP.totalSupply() - blackPairTOKEN;
        uint rewardToken = _USDT.balanceOf(address(this));
        uint reward = (rewardToken * _LP.balanceOf(_addr)) /  totalPair;
        return reward;
    }

    function sendRewardUSDT(uint gas) public {
        uint totalPair = _LP.totalSupply() - blackPairTOKEN;
        if (0 == totalPair) {
            return;
        }
        if (address(_USDT) == address(0)) return;
        if (_USDT.balanceOf(address(this)) < _rewardMinUSDT) {
            return;
        }
        uint rewardToken = _USDT.balanceOf(address(this));
        uint reward;
        uint gasUsed = 0;
        uint gasLeft = gasleft();
        uint total = _userAdds.length;
        for (uint i = 0; i < total; i++) {
            if (_currentIndexUSDT >= total) {
                _currentIndexUSDT = 0;
            }
            if (
                _LP.balanceOf(_userAdds[_currentIndexUSDT]) > 0 &&
                !isBlackList[_userAdds[_currentIndexUSDT]]
            ) {
                reward =
                    (rewardToken *
                        _LP.balanceOf(_userAdds[_currentIndexUSDT])) /
                    totalPair;
                if (reward > 0) {
                    _USDT.transfer(_userAdds[_currentIndexUSDT], reward);
                }
            }
            _currentIndexUSDT++;
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
            uint currentIndexTOKEN,
            uint currentIndexUSDT,
            uint userTotal,
            uint rewardMinTOKEN,
            uint rewardMinUSDT,
            address token,
            address usdt,
            address lp
        )
    {
        currentIndexTOKEN = _currentIndexTOKEN;
        currentIndexUSDT = _currentIndexTOKEN;
        userTotal = _userAdds.length;
        rewardMinTOKEN = _rewardMinTOKEN;
        rewardMinUSDT = _rewardMinUSDT;
        token = address(_TOKEN);
        usdt = address(_USDT);
        lp = address(_LP);
    }

    function getUsers() public view returns (address[] memory users) {
        users = new address[](_userAdds.length);
        for (uint256 i = 0; i < _userAdds.length; i++) {
            users[i] = _userAdds[i];
        }
    }
}