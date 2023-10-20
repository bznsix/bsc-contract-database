// SPDX-License-Identifier: MIT

interface ISocialStakeNft {
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function mint(address to, uint256 id) external;

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);

    function renounceOwnership() external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setStakeContract(address _address) external;

    function stakeContract() external view returns (address);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferOwnership(address newOwner) external;
}

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

pragma solidity ^0.8.17;

interface IStakeV {
    function increaseApr(uint256 tokenId, uint256 voteCountOrAvaragePoints)
        external;
}

contract SocialVote is Ownable {
    error InvalidNft();
    error LinkIsAlreadyUsed();
    error InvalidPoint();
    error VoterMustBeNftOwner();
    error InvalidArrayLen();
    error AlreadyVoted();
    error NumberOfVotesMustBeAtLeast25PercentForPost();
    error InvalidAvaragePoint();
    error VoteDoesNotStarted();
    error InvalidPost();
    error PostAlreadyFinalized();

    event AddVote(string link, uint256 indexed tokenId);
    event LinkAdded(string link, uint256 indexed tokenId);
    event PostFinalized(string link, uint256 indexed tokenId);

    ISocialStakeNft public immutable nft;
    IStakeV public immutable stake;

    constructor(address _nft, address _stake) {
        nft = ISocialStakeNft(_nft);
        stake = IStakeV(_stake);
    }

    struct SocialPost {
        string url;
        uint256 totalNumberOfVotes;
        uint256 totalVotePoints;
        uint256 creationTimeStamp;
    }

    //link => post
    mapping(string => SocialPost) public userPosts;
    //link => tokenId
    mapping(string => uint256) public linkToTokenId;
    //tokenId => link => voted
    mapping(uint256 => mapping(string => bool)) public isVoted;
    //all links array
    string[] public allLinks;

    // min time between addLink and voteLink
    uint256 public timeUntilVote = 24 hours;

    // 25_000 / 100_000
    uint256 public postFinalizePercantage = 25000;

    mapping(string => bool) isFinalized;

    function addLink(uint256 tokenId, string calldata socialPostUrl) external {
        if (nft.ownerOf(tokenId) != msg.sender) revert InvalidNft();
        if (linkToTokenId[socialPostUrl] != 0) revert LinkIsAlreadyUsed();

        userPosts[socialPostUrl] = SocialPost(
            socialPostUrl,
            0,
            0,
            block.timestamp
        );
        linkToTokenId[socialPostUrl] = tokenId;
        emit LinkAdded(socialPostUrl, tokenId);
        allLinks.push(socialPostUrl);
    }

    function getAllLinks() external view returns (string[] memory) {
        return allLinks;
    }

    function _voteLink(
        uint256 tokenId,
        string calldata socialPostUrl,
        uint256 point
    ) internal {
        if (point > 10) revert InvalidPoint();

        if (isVoted[tokenId][socialPostUrl]) revert AlreadyVoted();
        SocialPost storage post = userPosts[socialPostUrl];

        uint256 timestamp = post.creationTimeStamp;
        if (timestamp == 0) revert InvalidPost();
        if (block.timestamp < timestamp + timeUntilVote)
            revert VoteDoesNotStarted();

        post.totalVotePoints += point;
        post.totalNumberOfVotes++;
        isVoted[tokenId][socialPostUrl] = true;
    }

    function voteLinks(
        uint256 tokenId,
        string[] calldata urls,
        uint256[] calldata points
    ) external {
        if (nft.ownerOf(tokenId) != msg.sender) revert VoterMustBeNftOwner();
        if (urls.length != points.length) revert InvalidArrayLen();

        uint256 len = urls.length;

        for (uint256 i = 0; i < len; i++) {
            _voteLink(tokenId, urls[i], points[i]);
            SocialPost memory post = userPosts[urls[i]];
            uint256 totalSupply = nft.totalSupply();
            if (
                post.totalNumberOfVotes >=
                (totalSupply * postFinalizePercantage) / 100000 &&
                !isFinalized[urls[i]]
            ) {
                uint256 postTokenId = linkToTokenId[urls[i]];

                uint256 avaragePoint = (post.totalVotePoints * 10) /
                    post.totalNumberOfVotes;

                stake.increaseApr(postTokenId, avaragePoint);

                isFinalized[urls[i]] = true;

                emit PostFinalized(urls[i], postTokenId);
            }
            emit AddVote(urls[i], tokenId);
        }

        stake.increaseApr(tokenId, len);
    }

    function finalizeVotedPost(string calldata socialPostUrl) external {
        uint256 tokenId = linkToTokenId[socialPostUrl];
        uint256 totalSupply = nft.totalSupply();

        SocialPost memory post = userPosts[socialPostUrl];

        if (isFinalized[socialPostUrl]) revert PostAlreadyFinalized();

        if (
            post.totalNumberOfVotes <
            (totalSupply * postFinalizePercantage) / 100000
        ) revert NumberOfVotesMustBeAtLeast25PercentForPost();

        uint256 avaragePoint = (post.totalVotePoints * 10) /
            post.totalNumberOfVotes;
        if (avaragePoint == 0 || avaragePoint > 100)
            revert InvalidAvaragePoint();

        stake.increaseApr(tokenId, avaragePoint);

        emit PostFinalized(socialPostUrl, tokenId);
    }

    function setTimeUntilVote(uint256 time) external onlyOwner {
        timeUntilVote = time;
    }

    function setPostFinalizePercantage(uint256 _postFinalizePercantage)
        external
        onlyOwner
    {
        postFinalizePercantage = _postFinalizePercantage;
    }
}