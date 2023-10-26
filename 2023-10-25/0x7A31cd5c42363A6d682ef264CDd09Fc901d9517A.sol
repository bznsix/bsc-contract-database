/**
 *Submitted for verification at BscScan.com on 2023-06-28
*/

// SPDX-License-Identifier: MIT

// File: dependencies/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// File: dependencies/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// File: IERC20.sol

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function limitSupply() external view returns (uint256);

    function availableSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// File: BUSDBANK.sol

pragma solidity ^0.8.0;



contract BUSDBANK2 {
    
    struct User {
        uint256 stakedAmount;
        uint256 lastUpdateTime;
        uint256 rewards;
    }
    
    IERC20 private busdToken;
    IERC721 private bankKeyNFT;
    IERC721 private gemNFT;


    uint256 private constant MIN_INVEST = 10 ether; // min 10 BUSD
    uint256 private constant DAILY_RETURN = 5; // 0.5% daily return
    uint256 private constant NFT_BOOST = 5; // +0.5% on daily return
    uint256 private constant PRECISION = 1000; // Precision for percentage calculations
    uint256 private constant TIME_STEP = 1 days; // time step for daily apr

    
    mapping(address => User) private users;
    address[] private userAddresses;

    
    event Staked(address indexed user, uint256 amount);
    event ReferralReward(address indexed referrer, uint256 amount);
    
    constructor(address busdTokenAddress, address bankKeyNFTAddress, address gemNFTAddress) {
        busdToken = IERC20(busdTokenAddress);
        bankKeyNFT = IERC721(bankKeyNFTAddress);
        gemNFT = IERC721(gemNFTAddress);
    }

    function ownsNFT(address user) public view returns(bool) {
        uint256 balance = bankKeyNFT.balanceOf(user) + gemNFT.balanceOf(user);

        if (balance > 0){
            return true;
        }
        return false;
    }
    
    function stake(uint256 amount) external {
        require(amount >= MIN_INVEST, "Amount must be greater than or equal to 10");
        require(busdToken.balanceOf(msg.sender) >= amount, "Insufficient BUSD balance");
        require(busdToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        
        busdToken.transferFrom(msg.sender, address(this), amount); // Transfer the staked BUSD to the contract

        
        updateReward(msg.sender); // Update the rewards before changing the staked amount
        
        
        users[msg.sender].stakedAmount += amount;
        users[msg.sender].lastUpdateTime = block.timestamp;

        
        addUser(msg.sender); // add the user
        
        updateReward(msg.sender); // Update
        emit Staked(msg.sender, amount);
    }

    function compound() external {
        require(users[msg.sender].stakedAmount > 0, "No staked amount to compound");

        updateReward(msg.sender);

        uint256 reward = users[msg.sender].rewards;

        require(reward > 0, "No rewards to compound");

        uint256 compoundAmount = reward;

        users[msg.sender].rewards -= compoundAmount;
        users[msg.sender].stakedAmount += compoundAmount;

        emit Staked(msg.sender, compoundAmount);
    }

    function withdrawRewards() external {
        require(users[msg.sender].stakedAmount > 0, "No staked amount to withdraw rewards");
        
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to withdraw");
        require(reward < busdToken.balanceOf(address(this)));
        
        updateReward(msg.sender);
        
        users[msg.sender].rewards = 0;
        
        busdToken.transfer(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        uint256 stakedAmount = users[user].stakedAmount;
        uint256 lastUpdateTime = users[user].lastUpdateTime;
        uint256 rewards = users[user].rewards;
        
        uint256 reward = rewards;
        
        if (stakedAmount > 0) {
            uint256 timeDifference = block.timestamp - lastUpdateTime;
            
            if (ownsNFT(user)) {
                reward = rewards + ((stakedAmount * (DAILY_RETURN + NFT_BOOST) * timeDifference) / TIME_STEP / PRECISION);
            }
            else {
                reward = rewards + ((stakedAmount * DAILY_RETURN * timeDifference) / TIME_STEP / PRECISION);
            }
            
        }
        
        return reward;
    }

    function updateReward(address user) internal {
        uint256 reward = calculateReward(user);
        users[user].rewards = reward;
        users[user].lastUpdateTime = block.timestamp;
    }

    

    function addUser(address user) internal {
        for (uint256 i = 0; i < userAddresses.length; i++) {
            if (userAddresses[i] == user) {
                return; // do not re-add user
            }
        }
        
        userAddresses.push(user);
    }


    function viewUserInfo(address user) external view returns (uint256, uint256, uint256){
        return (users[user].stakedAmount, users[user].lastUpdateTime, users[user].rewards);
    }

    function viewUserEstYield(address user) external view returns (uint256) {
        uint256 estYield;

        if (ownsNFT(user)) {
            estYield = (users[user].stakedAmount * (DAILY_RETURN + NFT_BOOST)) / PRECISION;
        }
        else{
            estYield = (users[user].stakedAmount * DAILY_RETURN) / PRECISION;
        }
        return estYield;
    }

}