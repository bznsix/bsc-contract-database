// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

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
}

/*
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

contract ERC721Receiver is IERC721Receiver {
    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

interface INFT721 {
    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

    function mint(
        address _creator,
        address _wallet
    ) external returns (uint nftId);
}

/* Signature Verification

How to Sign and Verify
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/

contract VerifySignature {
    /* 1. Unlock MetaMask account
    ethereum.enable()
    */

    /* 2. Get message hash to sign
    getMessageHash(
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C,
        1,
        2,
        1702306317
    )

    hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
    */
    function getMessageHash(
        address _to,
        uint _nftType,
        uint _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _nftType, _timestamp));
    }

    /* 3. Sign message hash
    # using browser
    account = "copy paste account of signer here"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Signature will be different for different accounts
    0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
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

    /* 4. Verify signature
    signer = 0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd
    to = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
    amount = 123
    message = "coffee and donuts"
    nonce = 1
    signature =
        0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function verify(
        address _signer,
        address _to,
        uint _nftType,
        uint _timestamp,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _nftType, _timestamp);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
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

contract StepmintNFTstaking is Ownable, VerifySignature, ERC721Receiver {
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
    event MintAndStakeNFTonBuy(
        address indexed user,
        address indexed nftContract,
        uint indexed nftId
    );
    event MintAndStakeNFTbyUser(
        address indexed user,
        address indexed nftAddress,
        uint indexed nftType,
        uint nftId,
        uint timestamp
    );
    event ClaimNFT(
        address indexed user,
        address indexed nftAddress,
        uint indexed nftId
    );
    event StakeNFT(
        address indexed user,
        address indexed nftAddress,
        uint indexed nftId
    );
    event WithdrawNFTbyOwner(
        address indexed user,
        address indexed nftAddress,
        uint indexed nftId
    );

    mapping(address => mapping(uint => address)) public stakedNft;

    address public _signer;
    mapping(bytes => bool) public mintedSignHash;

    mapping(uint256 => address) public nftContracts; // [nftType(1-8) => NFT Contract(721)]
    address public NFTBuyContract;
    //multi-signature-wallet
    address public multiSignWallet;
    modifier onlyMultiSigWallet() {
        require(msg.sender == multiSignWallet, "Unauthorized Access");
        _;
    }

    modifier onlyBuyContract() {
        require(msg.sender == NFTBuyContract, "Unauthorized Access");
        _;
    }

    constructor(
        address _multisignWallet,
        address _NFTBuyContract,
        address _signerWallet
    ) {
        //assign multi sig wallet
        multiSignWallet = _multisignWallet;
        NFTBuyContract = _NFTBuyContract;
        _signer = _signerWallet;
    }

    // NFT contracts of Stepmint
    function setNftContracts(
        address _nftAddress,
        uint nftType
    ) external onlyOwner {
        nftContracts[nftType] = _nftAddress;
    }

    function setSingerWallet(address _signerWallet) external onlyOwner {
        _signer = _signerWallet;
    }

    function mintAndStakeNFTonBuy(
        uint nftType,
        address _user
    ) external onlyBuyContract returns (uint nftId, address nftAddress) {
        require(_user != address(0), "Zero address not accept");
        require(nftType > 0 && nftType <= 8, "Invalid NFT Type");

        nftAddress = nftContracts[nftType];

        (nftId) = INFT721(nftAddress).mint(_user, address(this));

        stakedNft[nftAddress][nftId] = _user;
        emit MintAndStakeNFTonBuy(_user, nftAddress, nftId);
    }

    function mintAndStakeNFTbyUser(
        uint nftType,
        uint256 _timestamp,
        bytes memory _signature
    ) external returns (uint nftId, address nftAddress) {
        require(nftType > 0 && nftType <= 8, "Invalid NFT Type");
        require(!mintedSignHash[_signature], "NFT already minted by signature");

        bool verifySignature = verify(
            _signer,
            msg.sender,
            nftType,
            _timestamp,
            _signature
        );
        require(verifySignature, "Invalid signature");
        mintedSignHash[_signature] = true;

        nftAddress = nftContracts[nftType];

        (nftId) = INFT721(nftAddress).mint(msg.sender, address(this));

        stakedNft[nftAddress][nftId] = msg.sender;

        emit MintAndStakeNFTbyUser(
            msg.sender,
            nftAddress,
            nftType,
            nftId,
            _timestamp
        );
    }

    function claimNft(address nftAddress, uint nftId) external {
        require(nftAddress != address(0), "Zero address not allowed");
        require(
            stakedNft[nftAddress][nftId] == msg.sender,
            "Invalid staking for NFT"
        );

        delete stakedNft[nftAddress][nftId];
        INFT721(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        emit ClaimNFT(msg.sender, nftAddress, nftId);
    }

    function stakeNFT(address nftAddress, uint nftId) external {
        require(nftAddress != address(0), "Zero address not allowed");
        require(
            INFT721(nftAddress).ownerOf(nftId) == msg.sender,
            "You don't have ownership of NFT"
        );
        require(
            INFT721(nftAddress).isApprovedForAll(msg.sender, address(this)),
            "Required approval"
        );
        stakedNft[nftAddress][nftId] = msg.sender;

        INFT721(nftAddress).safeTransferFrom(msg.sender, address(this), nftId);
        emit StakeNFT(msg.sender, nftAddress, nftId);
    }

    function withdrawNFTbyOwner(
        address nftAddress,
        uint nftId
    ) external onlyOwner {
        require(nftAddress != address(0), "Zero address not allowed");
        require(
            INFT721(nftAddress).ownerOf(nftId) == address(this),
            "Stak contract don't have ownership of NFT"
        );
        require(
            stakedNft[nftAddress][nftId] == address(0),
            "NFT already stake with other wallet"
        );

        INFT721(nftAddress).safeTransferFrom(address(this), msg.sender, nftId);
        emit WithdrawNFTbyOwner(msg.sender, nftAddress, nftId);
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