// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract RWA is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

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

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    // 管理员函数修饰符
    modifier onlyOwner() {
        require(owner_bool[msg.sender] == true, "must owner address");
        _;
    }

    event Ownerchange(address indexed add, bool status);
    event UpdateWhiteList(address indexed whiteAddr, bool whiteOn);
    event NewFees(
        uint64 destruction_ratio,
        uint64 dividend_ratio,
        uint64 promotion_ratio,
        uint64 recipient_ratio
    );

    mapping(address => address) public Invite_add; // 邀请人
    mapping(address => bool) public owner_bool; // 管理员地址
    mapping(address => bool) public whitelist; // 白名单地址
    address public Dividend_add; //分红地址
    address public pair; //交易池地址
    uint256 public total_destruction_amount = 100000 * 10 ** 18; //总销毁量
    uint256 public current_destruction_amount; //已销毁数量
    uint256 public deployment_time; // 合约部署时间
    uint64 public destruction_ratio; // 销毁比例
    uint64 public dividend_ratio; //分红比例
    uint64 public promotion_ratio; //团队推广比例
    uint64 public recipient_ratio; //接受者比例

    constructor(address owner) {
        _name = "Real World Assets";
        _symbol = "$RWA";
        // 管理员地址
        owner_bool[owner] = true;
        // 分红地址
        Dividend_add = 0x43F0B63076e0df0c4c49A781Bf9c113323FE2a55;
        // 白名单
        whitelist[0x9eaD15FF2A97a18C56d549AF4eF46D67F8A7BE05] = true;
        whitelist[0x966285CF957e6933eb8E68A3BafCd570CB5add6A] = true;
        whitelist[0x3Cc8B0ed15F85E458EE435b3Fe48E798A42910EE] = true;
        whitelist[0x656f43d1B157db07c3873B51A55CCBD323CF63D1] = true;
        whitelist[0x78fafFF98fadA85Da0AB500d706d559D021DEA85] = true;
        _mint(owner, 194000 * 10 ** 18);
        modification_commission(1, 1, 3, 95);
        deployment_time = block.timestamp;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        // 为swap交易
        if (sender == pair || recipient == pair) {
            if (
                current_destruction_amount == total_destruction_amount ||
                whitelist[sender] ||
                whitelist[recipient]
            ) {
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
            } else {
                amount /= 100;
                // 销毁
                current_destruction_amount += amount * destruction_ratio;
                if (current_destruction_amount > total_destruction_amount) {
                    _totalSupply -=
                        total_destruction_amount +
                        amount *
                        destruction_ratio - 
                        current_destruction_amount;
                    emit Transfer(
                        sender,
                        address(0),
                        amount * destruction_ratio
                    );
                    current_destruction_amount = total_destruction_amount;
                } else {
                    _totalSupply -= amount * destruction_ratio;
                    emit Transfer(
                        sender,
                        address(0),
                        amount * destruction_ratio
                    );
                }
                // 分红
                _balances[Dividend_add] += amount * dividend_ratio;
                emit Transfer(sender, Dividend_add, amount * dividend_ratio);
                // 团队推广收益
                Intergenerational_rewards(sender, amount * promotion_ratio);
                // 接受者
                _balances[recipient] += (amount * recipient_ratio);
                emit Transfer(sender, recipient, amount * recipient_ratio);
            }
        } else {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }

    // 绑定邀请关系
    function add_next_add(address inviter, address invitee) public {
        require(msg.sender == invitee);
        require(Invite_add[invitee] == address(0));
        Invite_add[invitee] = inviter;
    }

    function Intergenerational_rewards(address sender, uint256 amount) private {
        address inviter = Invite_add[sender];
        uint256 total = amount;
        uint256 a;
        if (inviter != address(0)) {
            // 一代奖励
            a = (amount / 10) * 4;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 二代奖励
            a = (amount / 25) * 7;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 三代奖励
            a = amount / 10;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 四代奖励
            a = (amount / 25) * 2;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 五代奖励
            a = (amount / 50) * 3;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 六代奖励
            a = amount / 25;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 七代奖励
            a = amount / 50;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (inviter != address(0)) {
            // 八代奖励
            a = amount / 50;
            _balances[inviter] += a;
            total -= a;
            emit Transfer(sender, inviter, a);
            inviter = Invite_add[inviter];
        }
        if (total != 0) {
            emit Transfer(sender, address(0), total);
        }
    }

    // 锁仓一年
    function release_lock(address to) public onlyOwner {
        require(block.timestamp >= deployment_time + 365 days);
        _mint(to, 16000 * 10 ** 18);
    }

    // 管理员改变
    function setowner_bool(address to, bool flag) public onlyOwner {
        require(owner_bool[to] != flag);
        owner_bool[to] = flag;
        emit Ownerchange(to, flag);
    }

    // 手续费比例修改(占比%)
    function modification_commission(
        uint64 destruction,
        uint64 dividend,
        uint64 promotion,
        uint64 recipient
    ) public onlyOwner {
        require((destruction + dividend + promotion + recipient) == 100);
        destruction_ratio = destruction;
        dividend_ratio = dividend;
        promotion_ratio = promotion;
        recipient_ratio = recipient;
        emit NewFees(destruction, dividend, promotion, recipient);
    }
    // 交易对修改
    function setPair(address _pair) public onlyOwner {
        require(_pair != address(0));
        pair = _pair;
    }
}