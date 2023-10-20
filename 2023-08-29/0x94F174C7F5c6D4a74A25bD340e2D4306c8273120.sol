// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface TokenBalanceOf {
    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IERC721_TM {
    function safeMint(address _to) external;
}


// File: @openzeppelin/contracts/GSN/Context.sol

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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
    constructor () {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
// import "./interfaces/IMerkleDistributor.sol";

contract HolderDistributor is Ownable {
    IERC721_TM public nft;
    // As long as msgSender proccess more than qualified amount of token
    // 0 means false no matter how by default
    mapping(address => uint256) public qualifiedThreshold;
    mapping(address => bool) public claimed;

    address[] public _tokens;
    event ThresholdAdded(address token, uint256 threshold);
    event ThresholdRemoved(address token);

    constructor(address token_) {
        nft = IERC721_TM(token_);
    }

    function isClaimed(address holder) public view returns (bool) {
        if (claimed[holder]) { return true; } //Already claimed, so not claimable
        for (uint256 i = 0; i < _tokens.length; ++i) { 
            if (TokenBalanceOf(_tokens[i]).balanceOf(holder) > qualifiedThreshold[_tokens[i]]) {
                return false; // As long as qualified for one token holder category
            }
        } 
        return true;
    }

    function claim(address account) external {
        require(!isClaimed(account), 'MerkleDistributor: Drop already claimed or not qualified');
        
        nft.safeMint(account);

        // Mark it claimed
        claimed[account] = true;
    }

    function addThreshold(address token, uint256 value) onlyOwner external {
        qualifiedThreshold[token] = value;
        _tokens.push(token);
        emit ThresholdAdded(token, value);
    }

    function removeThreshold(address token) onlyOwner external {
        for (uint256 i = 0; i < _tokens.length; ++i) {
            if (_tokens[i] == token) {
                _tokens[i] = _tokens[_tokens.length - 1];
                _tokens.pop();
                qualifiedThreshold[token] = 0;
                emit ThresholdRemoved(token);
                break;
            }
        }
    }
}