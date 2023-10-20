// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: Lottery/lottery_band.sol


pragma solidity ^0.8.17;

interface IVRFConsumer {
    function consume(string calldata seed, uint64 time, bytes32 result) external;
}

interface IVRFProvider {
    function requestRandomData(string calldata _clientSeed) external payable;
}

interface IFiveSkyCore {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Lottery is IVRFConsumer {

    address public owner;
    uint256 public drawDate;
    uint256 public constant DURATION = 25 days;
    mapping(uint256 => uint256) public chances;
    uint256[] public participants;
    address public charityWallet;
    address public authorizedContract;
    IERC20 public token;
    IFiveSkyCore public fiveSkyCore;
    IVRFProvider public provider;
    string public latestSeed;
    bool public isResolvingCurrentRound;

    event WinnersSelected(
        uint256 winnerTokenId1, uint256 prize1,
        uint256 winnerTokenId2, uint256 prize2,
        uint256 winnerTokenId3, uint256 prize3
    );

    constructor(
        address _charityWallet,
        address _tokenAddress,
        address _fiveSkyCoreAddress,
        address _providerAddress
    ) {
        owner = msg.sender;
        drawDate = block.timestamp + DURATION;
        charityWallet = _charityWallet;
        token = IERC20(_tokenAddress);
        fiveSkyCore = IFiveSkyCore(_fiveSkyCoreAddress);
        provider = IVRFProvider(_providerAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier afterDrawDate() {
        require(block.timestamp >= drawDate, "Draw date has not arrived yet");
        _;
    }

    function setAuthorizedContract(address _authorizedContract) external onlyOwner {
        authorizedContract = _authorizedContract;
    }

    modifier onlyAuthorizedContract() {
        require(msg.sender == authorizedContract, "Only the authorized contract can call this function");
        _;
    }

    function addChance(uint256 tokenId, uint256 chanceCount) external {
        require(chanceCount > 0, "Chance count must be greater than zero");
        chances[tokenId] = chanceCount;

        for (uint256 i = 0; i < chanceCount; i++) {
            participants.push(tokenId);
        }
    }

    function drawWinner() external payable {
        require(!isResolvingCurrentRound, "Round is resolving");

        latestSeed = "YourSeedHere";  // Replace with your seed logic
        isResolvingCurrentRound = true;

        provider.requestRandomData(latestSeed);
    }

    function consume(string calldata seed, uint64 time, bytes32 result) external override {
        require(msg.sender == address(provider), "Caller is not the provider");
        require(isResolvingCurrentRound, "Round is not resolving");

        uint256[] memory winnerTokenIds = new uint256[](3);
        uint256 maxIndex = participants.length - 1;

        for (uint i = 0; i < 3; i++) {
            uint256 randomIndex = uint256(keccak256(abi.encode(result, i))) % (maxIndex + 1);
            winnerTokenIds[i] = participants[randomIndex];
        }

        emit WinnersSelected(winnerTokenIds[0], 0, winnerTokenIds[1], 0, winnerTokenIds[2], 0);

        isResolvingCurrentRound = false;
    }

}