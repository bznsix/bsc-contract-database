// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBEP20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
}

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

interface INftStake {
    function mintAndStakeNFTonBuy(
        uint nftType,
        address _user
    ) external returns (uint nftId, address nftAddress);
}

contract StepmintBuyNFTs is Ownable {
    using SafeMath for uint256;

    event TransferAnyBSC20Token(
        address indexed sender,
        address indexed recipient,
        uint256 tokens
    );
    event WithdrawAmount(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    event PurchaseNFT(
        address indexed buyer,
        address indexed nftAddress,
        uint indexed nftId,
        uint nftType,
        uint256 amount
    );
    event DepositMNT(address indexed user, uint amount);

    mapping(uint256 => uint256) public NftPriceInUSDByType; // 1 to 8 NFT types in USD
    address public stakeContract;

    uint256 public mtnPrice; // MNT price in USDT

    address public MNT = 0x3e81Aa8d6813Ec9D7E6ddB4e523fb1601a0e86F3; // Main : Payment token address
    

    address public minter;
    //multi-signature-wallet
    address public multiSignWallet;
    modifier onlyMultiSigWallet() {
        require(msg.sender == multiSignWallet, "Unauthorized Access");
        _;
    }

    constructor(address _multisignWallet, address _minter) {
        //assign multi sig wallet
        multiSignWallet = _multisignWallet;
        minter = _minter;

        NftPriceInUSDByType[1] = 100 ether; //amount in USDT
        NftPriceInUSDByType[2] = 200 ether; //amount in USDT
        NftPriceInUSDByType[3] = 400 ether; //amount in USDT
        NftPriceInUSDByType[4] = 500 ether; //amount in USDT
        NftPriceInUSDByType[5] = 1000 ether; //amount in USDT
        NftPriceInUSDByType[6] = 2500 ether; //amount in USDT
        NftPriceInUSDByType[7] = 5000 ether; //amount in USDT
        NftPriceInUSDByType[8] = 10000 ether; //amount in USDT
    }

    function getMNTprice() public view returns (uint256) {
        return mtnPrice;
    }

    modifier OnlyMinter() {
        require(
            msg.sender == minter || msg.sender == owner(),
            "Minter : Only minter can call this"
        );
        _;
    }

    function getMinter() public view returns (address) {
        return minter;
    }

    function getNftPriceInMNT(uint nftType) public view returns (uint256) {
        return (NftPriceInUSDByType[nftType] * 10 ** 18) / mtnPrice;
    }

    // Set Minter By Onwer
    function setMinter(address _newMinter) external onlyOwner {
        minter = _newMinter;
    }

    // Set MNT Price By Minter
    function setMNTprice(uint256 _price) external OnlyMinter {
        mtnPrice = _price;
    }

    // Set stakeContract Owner
    function setStakeContract(address _stakeContract) external onlyOwner {
        stakeContract = _stakeContract;
    }

    function purchaseNFT(uint nftType) external {
        require(nftType > 0 && nftType <= 8, "Invalid NFT Type");
        uint256 amount = getNftPriceInMNT(nftType);

        require(
            IBEP20(MNT).balanceOf(msg.sender) >= amount,
            "Insufficient balance"
        );
        require(
            IBEP20(MNT).allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );
        IBEP20(MNT).transferFrom(msg.sender, address(this), amount);

        (uint nftId, address nftAddress) = INftStake(stakeContract)
            .mintAndStakeNFTonBuy(nftType, msg.sender);

        emit PurchaseNFT(msg.sender, nftAddress, nftId, nftType, amount);
    }

    function depositMnt(uint256 amount) external {
        require(
            IBEP20(MNT).balanceOf(msg.sender) >= amount,
            "Insufficient balance"
        );
        require(
            IBEP20(MNT).allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );
        IBEP20(MNT).transferFrom(msg.sender, address(this), amount);
        emit DepositMNT(msg.sender, amount);
    }

    /*
       @dev function to withdraw BNB
       @param recipient address
       @param amount uint256
      */
    function withdraw(
        address recipient,
        uint256 amount
    ) external onlyMultiSigWallet {
        sendValue(recipient, amount);
        emit WithdrawAmount(address(this), recipient, amount);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = payable(recipient).call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /* 
   @dev function to transfer any BEP20 token
   @param tokenAddress token contract address
   @param tokens amount of tokens
   @return success boolean status
  */
    function transferAnyBSC20Token(
        address tokenAddress,
        address wallet,
        uint256 tokens
    ) public onlyMultiSigWallet returns (bool success) {
        success = IBEP20(tokenAddress).transfer(wallet, tokens);
        require(success, "BEP20 transfer failed");
        emit TransferAnyBSC20Token(address(this), wallet, tokens);
    }

    function getSignatureForWithdraw(
        address recipient,
        uint256 amount
    ) public pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "withdraw(address,uint256)",
                recipient,
                amount
            );
    }

    function getSignatureForTransferAnyBSC20Token(
        address tokenAddress,
        address wallet,
        uint256 tokens
    ) public pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "transferAnyBSC20Token(address,address,uint256)",
                tokenAddress,
                wallet,
                tokens
            );
    }
}