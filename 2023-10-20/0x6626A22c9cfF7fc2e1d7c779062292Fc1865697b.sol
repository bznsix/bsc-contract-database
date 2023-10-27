// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";
import "./lib/VerifySignature.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract Pool is Owned, VerifySignature {
    event Withdraw(address indexed token, address indexed recipient, uint256 amount, uint256 timestamp);

    mapping(address => Request[]) public records;
    mapping(address => uint256) public userNonce;

    address public signer = 0x7D6FdA8f1278244609F8b81a45B127318135380b;

    constructor() Owned(msg.sender) {}

    function withdraw(Request calldata request, uint8 v, bytes32 r, bytes32 s) external {
        address recipient = request.recipient;
        require(request.deadline > block.timestamp, "deadline");
        require(request.nonce > userNonce[recipient], "nonce");
        require(verify(request, v, r, s) == signer, "not match");

        records[recipient].push(request);
        userNonce[recipient] = request.nonce;

        IERC20(request.token).transfer(recipient, request.amount);
        emit Withdraw(request.token, recipient, request.amount, block.timestamp);
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function requestCount(address account) external view returns (uint256) {
        return records[account].length;
    }

    function requestByAccount(address account) external view returns (Request[] memory) {
        return records[account];
    }

    function withdrawToken(IERC20 token, uint256 _amount) external onlyOwner {
        token.transfer(msg.sender, _amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

abstract contract VerifySignature {
    bytes32 public immutable DOMAIN_SEPARATOR;

    struct Request {
        address token;
        uint256 amount;
        address recipient;
        uint256 deadline;
        uint256 nonce;
    }

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encode(keccak256(bytes("VerifySignature")), block.chainid, address(this)));
    }

    function getMessageHash(Request calldata request) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(request.token, request.amount, request.recipient, request.deadline, request.nonce)
        );
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", DOMAIN_SEPARATOR, _messageHash));
    }

    function verify(Request calldata request, uint8 v, bytes32 r, bytes32 s) public view returns (address) {
        bytes32 messageHash = getMessageHash(request);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
