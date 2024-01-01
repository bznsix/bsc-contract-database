/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC-721 compliant contract.
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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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

/**
 * @title ERC-721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC-721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
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

pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


pragma solidity 0.8.19;




contract NftStaking {
   
   
    uint256 private constant MONTH = 30 days;
    uint256 public minimumStakingPeriod=15 days;
    uint256 public apy=20;
    uint256 public perNftReward;
    uint256 public noofDays=30;
    uint256 public totalItemsStaked;
    uint256 public totalSupply;

    IERC721 immutable public nft;
    IERC20 immutable public token;

    address public owner;

    struct Stake {
        address owner;
        uint64 stakedAt;
        uint256 firstStakeTime;
    }

   
    mapping(uint256 => Stake) vault;
    mapping(uint256=> uint256) public earnedReward;

    event ItemsStaked(uint256[] tokenId, address owner);
    event ItemsUnstaked(uint256[] tokenIds, address owner);
    event Claimed(address owner, uint256 reward);


    error NFTStakingVault__ItemAlreadyStaked();
    error NFTStakingVault__NotItemOwner();

    constructor(address _nftAddress, address _tokenAddress,uint256 _perNftReward,uint256 _totalSupply) {
        nft = IERC721(_nftAddress);
        token = IERC20(_tokenAddress);
        perNftReward=_perNftReward;
        owner=msg.sender;
        totalSupply=_totalSupply;
    }

   
    function stake(uint256[] calldata tokenIds) external {
        uint256 stakedCount = tokenIds.length;

        for (uint256 i; i < stakedCount; ) {
            uint256 tokenId = tokenIds[i];
            if (vault[tokenId].owner != address(0)) {
                revert NFTStakingVault__ItemAlreadyStaked();
            }
            if (nft.ownerOf(tokenId) != msg.sender) {
                revert NFTStakingVault__NotItemOwner();
            }

            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            vault[tokenId] = Stake(msg.sender, uint64(block.timestamp),block.timestamp);

            unchecked {
                ++i;
            }
        }
        totalItemsStaked = totalItemsStaked + stakedCount;

       
        emit ItemsStaked(tokenIds, msg.sender);
    }

   
    function unstake(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, true);
    }

    
    function claim(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, false);
    }

    
    function _claim(
        address user,
        uint256[] calldata tokenIds,
        bool unstakeAll
    ) internal {
        
        uint256 tokenId;
        uint256 rewardEarned;
        uint256 len = tokenIds.length;

        for (uint256 i; i < len; ) {
            tokenId = tokenIds[i];
            if (vault[tokenId].owner != user) {
                revert NFTStakingVault__NotItemOwner();
            }
            uint256 _stakedAt = uint256(vault[tokenId].stakedAt);

            uint256 stakingPeriod = block.timestamp - _stakedAt;
            uint256 _dailyReward = _calculateReward();
            earnedReward[tokenId]+=(_dailyReward * stakingPeriod * 1e18)/ 1 days ;
            rewardEarned += (_dailyReward * stakingPeriod * 1e18)/ 1 days ;
            vault[tokenId].stakedAt = uint64(block.timestamp);
           
            unchecked {
                ++i;
            }
        }

        if (rewardEarned != 0) {
            IERC20(token).transfer(user, rewardEarned);
            emit Claimed(user, rewardEarned);
           
        }

        if (unstakeAll) {
            uint256 _stakedAt = uint256(vault[tokenId].firstStakeTime);
            require( block.timestamp >= _stakedAt+minimumStakingPeriod,'Minimum Staking Period not completed');
            _unstake(user, tokenIds);
        }
    }

   
    function _unstake(address user, uint256[] calldata tokenIds) internal {
        uint256 unstakedCount = tokenIds.length;
        for (uint256 i; i < unstakedCount; ) {
            uint256 tokenId = tokenIds[i];
            require(vault[tokenId].owner == user, "Not Owner");
            earnedReward[tokenId]=0;
            delete vault[tokenId];
            nft.safeTransferFrom(address(this), user, tokenId);
            
            unchecked {
                ++i;
            }
        }
        totalItemsStaked = totalItemsStaked - unstakedCount;
       

        emit ItemsUnstaked(tokenIds, user);
    }

   
    function _calculateReward(
     
    ) public  view returns (uint256 dailyReward) {
       
            uint256 reward = (apy*perNftReward)/100;
            dailyReward=reward/noofDays;
       
    }



    function getEarnedReward( uint256 tokenid) public view returns(uint256){
        return earnedReward[tokenid];
    }

  
    function getTotalRewardEarned(
        address user
    ) external view returns (uint256 rewardEarned) {
        uint256[] memory tokens = tokensOfOwner(user);

        uint256 len = tokens.length;
        for (uint256 i; i < len; ) {
            uint256 _stakedAt = uint256(vault[tokens[i]].stakedAt);
            uint256 stakingPeriod = block.timestamp - _stakedAt;
            uint256 _dailyReward = _calculateReward();
            rewardEarned += (_dailyReward * stakingPeriod * 1e18)/ 1 days;
            unchecked {
                ++i;
            }
        }
    }

  
    function getRewardEarnedPerNft(
        uint256 _tokenId
    ) external view returns (uint256 rewardEarned) {
        uint256 _stakedAt = uint256(vault[_tokenId].stakedAt);
        uint256 stakingPeriod = block.timestamp - _stakedAt;
        uint256 _dailyReward = _calculateReward();
        rewardEarned = (_dailyReward * stakingPeriod * 1e18)/ 1 days ;
    }

    
    function balanceOf(
        address user
    ) public view returns (uint256 nftStakedbalance) {
        uint256 supply = totalSupply;
        unchecked {
            for (uint256 i; i <= supply; ++i) {
                if (vault[i].owner == user) {
                    nftStakedbalance += 1;
                }
            }
        }
    }

  
    function tokensOfOwner(
        address user
    ) public view returns (uint256[] memory tokens) {
        uint256 balance = balanceOf(user);
        if (balance == 0) return tokens;
        uint256 supply = 75;
        tokens = new uint256[](balance);

        uint256 counter;
        unchecked {
            for (uint256 i; i <= supply; ++i) {
                if (vault[i].owner == user) {
                    tokens[counter] = i;
                    counter++;
                    if (counter == balance) return tokens;
                }
            }
        }
    }

    function rescueNft(uint256 _tokenid) public onlyOwner{
        nft.transferFrom(address(this), owner, _tokenid);
    }

    function updateMinimumStakingDays(uint256 _minimumStakingPeriod) public onlyOwner{ 
        minimumStakingPeriod=_minimumStakingPeriod;
    }

    function changeApy(uint256 _apy) public onlyOwner{
        apy=_apy;
    }

    function changePerNftReward(uint256 _perNftReward) public onlyOwner{
        perNftReward=_perNftReward;
    }

    function changeOwner( address _owner) public onlyOwner{
        owner=_owner;
    }

    function updateNoOfDays(uint256 _noofdays) public onlyOwner{
        noofDays=_noofdays;
    }

    function changeTotalSupply(uint256 _totalSupply) public onlyOwner{
        totalSupply=_totalSupply;
    }

    function getFirstStake(uint256 tokenid) public view returns(uint256){
        return vault[tokenid].firstStakeTime;
    }


    function onERC721Received(
        address /**operator*/,
        address /**from*/,
        uint256 /**amount*/,
        bytes calldata //data
    ) external pure returns (bytes4) {
        return IERC721Receiver(0x30eEDD9977f5233411e130C45928660594598Ae7).onERC721Received.selector;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,'You are not the owner');
        _;
    }
}