//
//  ██    ██ ██       █████  ███    ██ ██████       ██  ██████
//  ██    ██ ██      ██   ██ ████   ██ ██   ██      ██ ██    ██
//  ██    ██ ██      ███████ ██ ██  ██ ██   ██      ██ ██    ██
//  ██    ██ ██      ██   ██ ██  ██ ██ ██   ██      ██ ██    ██
//   ██████  ███████ ██   ██ ██   ████ ██████   ██  ██  ██████
//
// @title dApp / uland.io
// @author 57pixels@uland.io
// @whitepaper https://whitepaper.uland.io/
//
// SPDX-License-Identifier: MIT

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


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.1


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.1


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


// File contracts/IUlandToken.sol



pragma solidity ^0.8.4;
/**
 * @dev Uland token Interface
 */
interface IUlandToken is IERC20 {
	function setRewardsFactor(address holder, uint256 balance) external;

	function addStaticReward(address recipient, uint256 amount) external;

	function addAirdropReward(address recipient, uint256 amount) external;

	function allowNftTrade(address account, bool value) external;
}


// File @openzeppelin/contracts/utils/math/SafeMath.sol@v4.9.1


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File contracts/IUlandNFT.sol



pragma solidity ^0.8.4;

//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IUlandAsset {
	struct Asset {
		uint256 id; // token id
		uint256 parentId;
		uint256 price;	// Price $ULAND
		uint256 priceBNB;
		uint256 population; // Population. Rewards distributed based on population
		uint256 totalTax; // Accumulated tax earned through distribution
		uint256 assetType; // Asset type
		uint16 taxRate; // Asset Distribution tax rate
		string tag; // tag|titleid|0|Henry, eg. Promiseland|1|Henry
		string logoUrl; // Custom logo
		string attributes; // bgColour|future expansion		
	}
}

/**
 * @dev Uland NFT Interface
 */
interface IUlandNFT {

	function mint(uint256 tokenId, uint256 parentId, uint256 population, uint256 assetType) external;
	function buy(uint256 tokenId) external;
	function airdrop(uint256 tokenId, uint256 parentId,	uint256 population,uint256 assetType) external;

	function setTokenMetadata(uint256 tokenId, uint256 assetType, uint16 taxRate,string memory tag,string memory logoUrl,string memory attributes) external;
	function setTokenPrice(uint256 tokenId, uint256 price, uint256 priceBNB) external;

	function exists(uint256 tokenId) external view returns (bool);

	function increaseTokenTotalTax(uint256 tokenId,	uint256 balance) external;
	function getTokenDetail(uint256 tokenId) external view returns (IUlandAsset.Asset memory);
	function getTokenOwner(uint256 tokenId) external view returns (address);
	function getTotalPopulationByOwner(address _owner) external view returns (uint256);
}


// File contracts/IUniswapV2Factory.sol



pragma solidity ^0.8.4;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// File contracts/IUniswapV2Pair.sol



pragma solidity ^0.8.4;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// File contracts/IUniswapV2Router.sol



pragma solidity ^0.8.4;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File contracts/UlandVerifyAsset.sol


pragma solidity ^0.8.4;

library UlandVerifyAsset {
	function getMessageHash(
		uint256 _tokenId,
		uint256 _amount,
		uint256 _validTo,
		uint256 _parentId,
		uint256 _population,
		uint256 _ulandreward,
		uint16 _payType,
		address _recipient		
	) internal pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					_tokenId,
					_amount,
					_validTo,
					_parentId,
					_population,
					_ulandreward,
					_payType,
					_recipient
				)
			);
	}

	function getEthSignedMessageHash(bytes32 _messageHash)
		internal
		pure
		returns (bytes32)
	{
		/*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
		return
			keccak256(
				abi.encodePacked(
					"\x19Ethereum Signed Message:\n32",
					_messageHash
				)
			);
	}

	function verify(
		address _signer,
		uint256 _tokenId,
		uint256 _amount,
		uint256 _validTo,
		uint256 _parentId,
		uint256 _population,
		uint256 _ulandreward,
		uint16 _payType,
		address _recipient,
		bytes memory signature
	) internal pure returns (bool) {
		bytes32 messageHash = getMessageHash(
			_tokenId,
			_amount,
			_validTo,
			_parentId,
			_population,
			_ulandreward,
			_payType,
			_recipient
		);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);		
		return recoverSigner(ethSignedMessageHash, signature) == _signer;
	}

	function verify2(
		address _signer,
		bytes32 messageHash,
		bytes memory signature
	) internal pure returns (bool) {
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);		
		return recoverSigner(ethSignedMessageHash, signature) == _signer;
	}

	function verifyMeta(
		address _signer,
		uint256 _tokenId,
		uint256 _validTo,
		uint16 _taxRate,
		string memory  _str1,
		string memory _str2,
		string memory _str3,
		bytes memory signature
	) internal pure returns (bool) {
		bytes32 messageHash = getMessageMetaHash(
			_tokenId,
			_validTo,
			_taxRate,
			_str1,
			_str2,
			_str3
		);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);		
		return recoverSigner(ethSignedMessageHash, signature) == _signer;
	}

	function getMessageMetaHash(
		uint256 _tokenId,
		uint256 _validTo,
		uint16 _taxRate,
		string memory _str1,
		string memory _str2,
		string memory _str3
	) internal pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					_tokenId,
					_validTo,
					_taxRate,
					_str1,
					_str2,
					_str3
				)
			);
	}

	function recoverSigner(
		bytes32 _ethSignedMessageHash,
		bytes memory _signature
	) internal pure returns (address) {
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

		return ecrecover(_ethSignedMessageHash, v, r, s);
	}

	function splitSignature(bytes memory sig)
		internal
		pure
		returns (
			bytes32 r,
			bytes32 s,
			uint8 v
		)
	{
		require(sig.length == 65, "invalid signature length");

		assembly {
			/*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

			// first 32 bytes, after the length prefix
			r := mload(add(sig, 32))
			// second 32 bytes
			s := mload(add(sig, 64))
			// final byte (first byte of the next 32 bytes)
			v := byte(0, mload(add(sig, 96)))
		}

		// implicitly return (r, s, v)
	}
}


// File contracts/UlandXCH.sol
pragma solidity ^0.8.4;

contract UlandXCH is Ownable {
	bool public ULAND_IS_AWESOME = true;

	address public signerAddress;
	string public _name;
	mapping(address => bool) public ulandContracts;

	using SafeMath for uint256;

	IUlandToken public _ulandToken;

	bool public paused = false;
	mapping(string => bool) public _usedNonces;

	address public rewardsWallet = 0x24554c414E440000000000000000000000000002; // $ULAND Internal Rewards Wallet

	modifier onlyUland() {
		require(ulandContracts[msg.sender]);
		_;
	}

	/**
	 * @dev Modifier to make a function callable only when the contract is not paused.
	 */
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	constructor(
		address ulandToken,
		address _signerAddress,
		string memory name
	) {
		_ulandToken = IUlandToken(ulandToken);
		signerAddress = _signerAddress;
		_name = name;
	}

	/**
	 * @dev Returns the name of the token.
	 */
	function name() public view returns (string memory) {
		return _name;
	}

	/**
	 * @dev Returns the symbol of the token
	 */
	function symbol() public pure returns (string memory) {
		return "UXCH";
	}

	enum Method {
		Null,
		Transfer,
		Reward
	}

	struct WithdrawParams {
		string nonce;
		Method method;
		uint32 validTo;
		uint256 amount;
	}

	function withdraw(
		WithdrawParams memory params,
		bytes32 hash,
		bytes memory signature
	) external whenNotPaused {
		require(block.timestamp <= params.validTo, "EXPIRED");
		require(!_usedNonces[params.nonce], "NONCE REUSED");
		bytes32 _hash = calculateHash(params);
		require(_hash == hash, "INVALID HASH");
		require(
			UlandVerifyAsset.verify2(signerAddress, _hash, signature) == true,
			"INVALIDSIG"
		);

		if (params.method == Method.Transfer) {
			_ulandToken.transfer(msg.sender, params.amount);
		} else if (params.method == Method.Reward) {
			_ulandToken.transfer(rewardsWallet, params.amount);
			_ulandToken.addStaticReward(msg.sender, params.amount);
		}

		_usedNonces[params.nonce] = true;
		emit Withdrawal(params.nonce, params.method, msg.sender, params.amount);
	}

	function dappwithdraw(WithdrawParams memory params) public onlyUland {

		if (params.method == Method.Transfer) {
			_ulandToken.transfer(msg.sender, params.amount);
		} else if (params.method == Method.Reward) {
			_ulandToken.transfer(rewardsWallet, params.amount);
			_ulandToken.addStaticReward(tx.origin, params.amount);
		}
		emit Withdrawal(params.nonce, params.method, tx.origin, params.amount);
	}

	function calculateHash(
		WithdrawParams memory params
	) private view returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					params.method,
					params.validTo,
					params.amount,
					params.nonce,
					msg.sender
				)
			);
	}

	/// @dev Withdraw funds that gets stuck in contract by accident
	function emergencyWithdraw() external onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}

	/// @dev Withdraw ULAND that gets stuck in contract by accident
	function emergencyWithdrawERC20(address tokenAddress) external onlyOwner {
		IERC20 token = IERC20(tokenAddress);
		token.transfer(owner(), token.balanceOf(address(this)));
	}

	/*
	 * onlyOwner
	 */

	function setSignerAddress(address _signerAddress) public onlyOwner {
		signerAddress = _signerAddress;
	}

	function setPause(bool _paused) public onlyOwner {
		paused = _paused;
	}

	function setUlandContractAllow(
		address contractAddress,
		bool access
	) public onlyOwner {
		ulandContracts[contractAddress] = access;
	}

	/*
	 * Events
	 */

	event Withdrawal(string nonce, Method method, address to, uint256 amount);
}