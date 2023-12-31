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
// contracts/ENTIDO.sol.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ENTIDO is Ownable {
    uint public constant BASE_DIVIDER = 10000;

    struct Node {
        uint id;
        uint minAmount;
        uint timesAmount;
        uint totalAmount;
        bool enable;
    }

    struct UserNode {
        uint nodeId;
        uint buyAmount;
        uint incomeAmount;
        bool enable;
    }

    IERC20 public USDT;

    bool public presaleOpen;

    address public presaleWallet;

    Node[] public nodes;

    mapping(address => UserNode) public usersNode;

    uint public referrerRewardRate;

    mapping(address => address) public referrers;

    address public signerAddress;

    address public claimAddress;

    mapping(uint => address) public rands;

    event Referrer(address indexed owner, address referrer);

    event Presale(address indexed owner, uint nodeId, uint amount);

    event Withdraw(address indexed token, address indexed owner, uint amount, uint rand);

    constructor() {
        referrerRewardRate = 1000;

        nodes.push(Node(1, 100e18, 100e18, 1000e18, true));
        nodes.push(Node(2, 200e18, 100e18, 2000e18, true));
        nodes.push(Node(3, 300e18, 100e18, 3000e18, true));
    }

    function setReferer(address referrer) public {
        require(referrer != address(0), "ENTIDO: Invalid referrer");
        require(referrer != _msgSender(), "ENTIDO: Invalid referrer for owner");
        require(referrer != address(this), "ENTIDO: Invalid referrer for this");
        require(referrers[_msgSender()] == address(0), "ENTIDO: Referrer already set");

        _setReferrer(_msgSender(), referrer);
    }

    function presale(uint nodeId, uint usdtAmount) public {
        require(presaleOpen, "ENTIDO: Presale not open");
        require(referrers[_msgSender()] != address(0), "ENTIDO: Bind the referrer first");

        uint referrerRewardAmount = usdtAmount * referrerRewardRate / BASE_DIVIDER;
        if (referrerRewardAmount > 0) {
            USDT.transferFrom(_msgSender(), referrers[_msgSender()], referrerRewardAmount);
        }

        uint surplusAmount = usdtAmount - referrerRewardAmount;
        if (surplusAmount > 0) {
            USDT.transferFrom(_msgSender(), presaleWallet, surplusAmount);
        }

        _presale(_msgSender(), nodeId, usdtAmount);
    }

    function _presale(address owner, uint nodeId, uint amount) internal {
        Node memory node = getNodeById(nodeId);
        require(node.enable, "ENTIDO: Node id invalid");

        if (usersNode[owner].enable) {
            require(node.id == usersNode[owner].nodeId, "ENTIDO: Different presale nodes");
            require(amount % node.timesAmount == 0, "ENTIDO: USDT Amount invalid");

            usersNode[owner].buyAmount += amount;
            usersNode[owner].enable = true;
        } else {
            require(amount >= node.minAmount, "ENTIDO: USDT Amount too small");
            require(amount % node.timesAmount == 0, "ENTIDO: USDT Amount invalid");

            usersNode[owner].nodeId = nodeId;
            usersNode[owner].buyAmount = amount;
            usersNode[owner].enable = true;
        }

        for (uint i = 0; i < nodes.length; i++) {
            if (usersNode[owner].nodeId < nodes[i].id && usersNode[owner].buyAmount > nodes[i].totalAmount) {
                usersNode[owner].nodeId = nodes[i].id;
            }
        }

        emit Presale(_msgSender(), usersNode[owner].nodeId, amount);
    }

    function getNodeById(uint id) public view returns (Node memory) {
        Node memory node;
        for (uint i = 0; i < nodes.length; i++) {
            if (nodes[i].id == id) {
                node = nodes[i];
                break;
            }
        }

        return node;
    }

    function _setReferrer(address owner, address referrer) internal {
        bool result = false;
        address parent = referrer;
        while (true) {
            if (parent == address(0)) {
                result = true;
                break;
            }

            if (parent == owner) {
                result = false;
                break;
            }
            parent = referrers[parent];
        }

        require(result, "ENTIDO: Inviter address find loop");
        referrers[owner] = referrer;
        emit Referrer(owner, referrer);
    }

    function getNodes() public view returns (Node[] memory) {
        return nodes;
    }

    function claim(address token, uint amount, uint rand, uint8 v, bytes32 r, bytes32 s) public {
        require(rand > 0, "ENTIDO: Rand invalid");
        require(rands[rand] == address(0), "ENTIDO: Rand used");

        address signer = _recoverClaimSigner(token, _msgSender(), amount, rand, v, r, s);
        require(signer != address(0), "ENTIDO: Sign invalid");
        require(signer == signerAddress, "ENTIDO: Sign unauthorized");

        IERC20(token).transferFrom(claimAddress, _msgSender(), amount);
        rands[rand] = _msgSender();
        emit Withdraw(token, _msgSender(), amount, rand);
    }

    function _recoverClaimSigner(address token, address to, uint amount, uint rand, uint8 v, bytes32 r, bytes32 s) private view returns (address) {
        bytes32 message = keccak256(
            abi.encode(block.chainid, address(this), "claim", token, to, amount, rand)
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));

        return ecrecover(hash, v, r, s);
    }

    function airdrop(address token, address[] memory _tos, uint[] memory _values) public {
        require(_tos.length > 0, "ENTIDO: Address invalid");
        require(_values.length > 0, "ENTIDO: Amount invalid");
        require(_values.length == _tos.length, "ENTIDO: Address or values length not eq");

        IERC20 _token = IERC20(token);
        uint amount = 0;
        for (uint i = 0; i < _values.length; i++) {
            amount += _values[i];
        }
        require(_token.balanceOf(_msgSender()) >= amount, "ENTIDO: Insufficient funds");

        for (uint i = 0; i < _tos.length; i++) {
            require(_tos[i] != address(0), "ENTIDO: To address is zero");
            require(_values[i] > 0, "ENTIDO: Amount invalid");

            _token.transferFrom(_msgSender(), _tos[i], _values[i]);
        }
    }

    function setConfig(address _usdt, address _presaleWallet, address _signerAddress, address _claimAddress) public onlyOwner {
        USDT = IERC20(_usdt);
        presaleWallet = _presaleWallet;
        signerAddress = _signerAddress;
        claimAddress = _claimAddress;
    }

    function setNodes(Node memory _node) public onlyOwner {
        nodes.push(_node);
    }

    function ClearNodes() public onlyOwner {
        delete nodes;
    }

    function setPresaleOpen(bool _open) public onlyOwner {
        presaleOpen = _open;
    }
}
