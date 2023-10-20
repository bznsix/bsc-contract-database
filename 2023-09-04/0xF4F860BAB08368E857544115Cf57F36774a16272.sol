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

abstract contract Ownable {
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

contract CTSStake is Ownable {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        bool isValid;
        uint256 balance;
        uint256 level;
        uint256 userForce;
        uint256 teamForce;
        uint256 mining;
        uint256 inviteReward;
        uint256 teams;
        uint256 invites;
        uint256 v2;
        uint256 v3;
        uint256 v4;
        uint256 v5;
    }
    struct OrderInfo {
        bool isValid;
        uint256 total;
        uint256 surplus;
        uint256 startTime;
        uint256 startBlock;
        uint256 endBlock;
        uint256 lastBlock;
        uint256 perBlock;
        uint256 fz;
        uint256 cts;
    }
    mapping(address => mapping(uint256 => OrderInfo)) public userOrders;
    mapping(address => uint256) public userOrderNum;
    mapping(address => uint256) public userOrderValidNum;
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    mapping(address => address) public userRefers;
    mapping(address => uint256) public userFZ;
    mapping(address => mapping(uint256 => address)) public userInvites;
    mapping(address => uint256) public userInviteTotals;
    uint256 public userTotal;
    uint256 public totalForce;
    uint256 public achievementV1;
    uint256 public achievementV2;
    uint256 public validFZ = 1000e18;
    address public marketA;
    address public marketB;
    ISwapRouter private _swapRouter;
    IERC20 private _ETH;
    IERC20 private _USDT;
    IERC20 private _CTS;
    IERC20 private _FZ;
    event DepositHP(address account, uint256 hp, uint256 usdt, address refer);
    event DepositFZ(address account, uint256 fz, uint256 usdt, address refer);
    event Withdraw(address account, uint256 amount);

    constructor() {
        marketA = 0x251F50343f1AE7FBd9461fA59F1bFEeb12e55753;
        marketB = 0xe5CC8e63ec619929FC3A58341375462b716c5d90;
        _ETH = IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
        _CTS = IERC20(0x8a19083CC8f3aE5DCbd55f7E405cbf6898234eD9);
        _FZ = IERC20(0x351241F08Eff9F72B15afB276Ec0d34Ef63C8692);
        _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        achievementV1 = 1_0000e18;
        achievementV2 = 15_0000e18;
    }

    function withdrawToken(
        IERC20 token,
        address account,
        uint256 amount
    ) public onlyOwner {
        token.transfer(account, amount);
    }

    function setAchievement(
        uint256 v1,
        uint256 v2,
        uint256 valid
    ) public onlyOwner {
        achievementV1 = v1;
        achievementV2 = v2;
        validFZ = valid;
    }

    function setToken(
        address eth,
        address usdt,
        address cts,
        address fz
    ) public onlyOwner {
        _ETH = IERC20(eth);
        _USDT = IERC20(usdt);
        _CTS = IERC20(cts);
        _FZ = IERC20(fz);
    }

    function setMarket(address dataA, address dataB) public onlyOwner {
        marketA = dataA;
        marketB = dataB;
    }

    function getPriceCTS() public view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = address(_CTS);
        path[1] = address(_ETH);
        path[2] = address(_USDT);
        return _swapRouter.getAmountsOut(1e18, path)[2];
    }

    function getOrders(
        address account
    ) public view returns (OrderInfo[] memory ordes) {
        ordes = new OrderInfo[](userOrderNum[account]);
        for (uint256 i = userOrderNum[account]; i > 0; i--) {
            ordes[userOrderNum[account] - i] = userOrders[account][i - 1];
        }
    }

    function getInvites(
        address account
    ) public view returns (address[] memory invites) {
        invites = new address[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
        }
    }

    function getInvitesInfo(
        address account
    ) public view returns (address[] memory invites, UserInfo[] memory infos) {
        invites = new address[](userInviteTotals[account]);
        infos = new UserInfo[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
            infos[i] = users[invites[i]];
        }
    }

    function depositFZ(uint256 fz, uint256 usdt, address refer) public {
        address account = msg.sender;
        require(fz % (20e18) == 0, "Multiple Error FZ");
        require(usdt % (3e18) == 0, "Multiple Error CTS");
        require(usdt == (fz / (20e18)) * 3e18, "CTS Match FZ");
        require(_FZ.balanceOf(account) >= fz, "Insufficient FZ");
        uint256 priceCTS = getPriceCTS();
        uint256 cts = (usdt * 1e18) / priceCTS;
        require(_CTS.balanceOf(account) >= cts, "Insufficient CTS");
        _FZ.transferFrom(account, address(1), fz);
        _CTS.transferFrom(account, address(1), (cts * 96) / 100);
        _CTS.transferFrom(account, marketA, (cts * 2) / 100);
        _CTS.transferFrom(account, marketB, (cts * 2) / 100);
        _handleUserAndRefer(account, refer);
        {
            userOrders[account][userOrderNum[account]] = OrderInfo({
                isValid: true,
                total: cts * 2,
                surplus: cts * 2,
                startTime: block.timestamp,
                startBlock: block.number,
                endBlock: block.number + 360 * 28800,
                lastBlock: block.number,
                perBlock: (cts * 2) / (360 * 28800),
                fz: fz,
                cts: cts
            });
            userOrderNum[account]++;
            users[account].userForce += cts * 2;
            userFZ[account] += fz;
            if (
                !users[account].isValid &&
                userRefers[account] != address(0) &&
                userFZ[account] >= validFZ
            ) {
                users[account].isValid = true;
                users[userRefers[account]].invites += 1;
            }
        }
        _handleTeam(account, fz, true);
        totalForce += cts * 2;
        emit DepositFZ(account, fz, usdt, refer);
    }

    function withdraw() public {
        address account = msg.sender;
        UserInfo storage user = users[account];
        uint256 total;
        for (
            uint256 i = userOrderValidNum[account];
            i < userOrderNum[account];
            i++
        ) {
            OrderInfo storage order = userOrders[account][i];
            if (block.number < order.endBlock) {
                uint256 reward = order.perBlock *
                    (block.number - order.lastBlock);
                total += reward;
                order.lastBlock = block.number;
                if (order.surplus > reward) order.surplus -= reward;
                else order.surplus = 0;
            } else if (order.endBlock > order.lastBlock) {
                uint256 reward = order.perBlock *
                    (order.endBlock - order.lastBlock);
                total += reward;
                order.lastBlock = order.endBlock;
                order.isValid = false;
                order.surplus = 0;
                userOrderValidNum[account]++;
            }
        }
        if (total > 0) {
            user.balance += total;
            user.mining += total;
        }
        if (user.balance > 0) {
            _handleInviteReward(account, user.balance);
            _CTS.transfer(account, user.balance);
            emit Withdraw(account, user.balance);
            if (user.userForce > user.balance) {
                user.userForce -= user.balance;
            } else {
                user.userForce = 0;
            }
            if (totalForce > user.balance) {
                totalForce -= user.balance;
            } else {
                totalForce = 0;
            }
            user.balance = 0;
        }
    }

    function getPending(address account) public view returns (uint256 total) {
        for (
            uint256 i = userOrderValidNum[account];
            i < userOrderNum[account];
            i++
        ) {
            OrderInfo memory order = userOrders[account][i];
            if (block.number < order.endBlock) {
                uint256 reward = order.perBlock *
                    (block.number - order.lastBlock);
                total += reward;
            } else if (order.endBlock > order.lastBlock) {
                uint256 reward = order.perBlock *
                    (order.endBlock - order.lastBlock);
                total += reward;
            }
        }
        total += users[account].balance;
    }

    function _handleUserAndRefer(address account, address refer) private {
        if (refer != address(0) && !users[refer].isExist) {
            UserInfo storage parent = users[refer];
            parent.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = refer;
        }
        UserInfo storage user = users[account];
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = account;
        }
        if (refer != address(0) && userRefers[account] == address(0)) {
            userRefers[account] = refer;
            userInviteTotals[refer] = userInviteTotals[refer].add(1);
            userInvites[refer][userInviteTotals[refer]] = account;
        }
    }

    function _handleTeam(address account, uint256 amount, bool isAdd) private {
        uint256 index;
        uint256 v1;
        uint256 v2;
        uint256 v3;
        uint256 v4;
        uint256 v5;
        address refer = userRefers[account];
        address[] memory refers = new address[](11);
        refers[index] = refer;
        while (refer != address(0) && index < 10) {
            UserInfo storage user = users[refer];
            if (isAdd) {
                user.teams += amount;
                if (v5 > 0) {
                    user.v5 += v5;
                    if (user.level < 6 && user.v5 >= 2 && user.invites >= 12)
                        user.level = 6;
                }
                if (v4 > 0) {
                    user.v4 += v4;
                    if (user.level < 5 && user.v4 >= 2 && user.invites >= 9) {
                        user.level = 5;
                        v5++;
                    }
                }
                if (v3 > 0) {
                    user.v3 += v3;
                    if (user.level < 4 && user.v3 >= 2 && user.invites >= 7) {
                        user.level = 4;
                        v4++;
                    }
                }
                if (v2 > 0) {
                    user.v2 += v2;
                    if (user.level < 3 && user.v2 >= 2 && user.invites >= 5) {
                        user.level = 3;
                        v3++;
                    }
                }
                if (
                    user.level < 2 &&
                    user.teams >= achievementV2 &&
                    user.invites >= 3
                ) {
                    user.level = 2;
                    v2++;
                }
                if (
                    user.level == 0 &&
                    user.teams >= achievementV1 &&
                    user.invites >= 1
                ) {
                    user.level = 1;
                    v1++;
                }
                user.teamForce += amount;
            } else {
                if (user.teamForce > amount) {
                    user.teamForce -= amount;
                } else {
                    user.teamForce = 0;
                }
            }
            index++;
            bool isExist;
            for (uint256 i = 0; i < refers.length; i++) {
                if (userRefers[refer] == refers[i]) {
                    isExist = true;
                    break;
                }
            }
            refer = userRefers[refer];
            if (isExist) {
                break;
            }
            refers[index] = refer;
        }
    }

    function _handleInviteReward(address account, uint256 amount) private {
        address refer = userRefers[account];
        uint256 index;
        uint256 current;
        uint256 level;
        uint256 times;
        uint8[6] memory rates = [5, 10, 15, 20, 25, 30];
        while (refer != address(0) && index < 20) {
            UserInfo memory parent = users[refer];
            if (parent.level > level) {
                _updateOrder(
                    refer,
                    (amount * (rates[parent.level - 1] - current)) / 100
                );
                current = rates[parent.level - 1];
                level = parent.level;
            } else if (level == 6 && parent.level == 6 && times < 1) {
                _updateOrder(refer, (amount * 3) / 100);
                times++;
            }
            if (times > 0) break;
            refer = userRefers[refer];
            index++;
        }
    }

    function _updateOrder(address account, uint256 amount) private {
        UserInfo storage user = users[account];
        uint256 total = amount;
        uint256 rewardTotal;
        uint256 rewardMining;
        for (
            uint256 i = userOrderValidNum[account];
            i < userOrderNum[account];
            i++
        ) {
            OrderInfo storage order = userOrders[account][i];
            if (block.number < order.endBlock) {
                uint256 pending = order.perBlock *
                    (block.number - order.lastBlock);
                rewardMining += pending;
                uint256 reward = order.perBlock *
                    (order.endBlock - block.number);
                bool isEnd;
                if (reward > total) {
                    reward = order.perBlock * (total / order.perBlock);
                    total = 0;
                } else {
                    isEnd = true;
                    total -= reward;
                }
                rewardTotal += (reward + pending);
                order.endBlock = order.endBlock - reward / order.perBlock;
                order.lastBlock = block.number;
                if (order.surplus > (reward + pending) && !isEnd) {
                    order.surplus -= (reward + pending);
                } else {
                    order.surplus = 0;
                    order.isValid = false;
                    userOrderValidNum[account]++;
                }
            } else if (order.endBlock > order.lastBlock) {
                uint256 reward = order.perBlock *
                    (order.endBlock - order.lastBlock);
                rewardTotal += reward;
                rewardMining += reward;
                order.lastBlock = order.endBlock;
                order.isValid = false;
                order.surplus = 0;
                userOrderValidNum[account]++;
            }
            if (total == 0) {
                break;
            }
        }
        if (rewardTotal > 0) {
            user.balance += rewardTotal;
            user.mining += rewardMining;
            user.inviteReward += rewardTotal - rewardMining;
        }
    }
}