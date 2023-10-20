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

// File: Lottery/Lottery.sol


pragma solidity ^0.8.0;


interface IFiveSkyCore {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Lottery {

    address public owner;
    uint256 public drawDate;
    uint256 public constant DURATION = 25 days;
    mapping(uint256 => uint256) public chances;
    uint256[] public participants;
    address public charityWallet;
    address public authorizedContract;
    IERC20 public token;
    IFiveSkyCore public fiveSkyCore;

    event ChanceAdded(uint256 tokenId, uint256 chanceCount);

    event WinnersDrawn(
    address winner1, uint256 prize1, uint256 tokenId1,
    address winner2, uint256 prize2, uint256 tokenId2,
    address winner3, uint256 prize3, uint256 tokenId3,
    address charity, uint256 charityPrize);

    event WinnersSelected(
    uint256 winnerTokenId1, uint256 prize1,
    uint256 winnerTokenId2, uint256 prize2,
    uint256 winnerTokenId3, uint256 prize3
);

    constructor(
        address _charityWallet,
        address _tokenAddress,
        address _fiveSkyCoreAddress
    ) 
    {
        owner = msg.sender;
        drawDate = block.timestamp + DURATION;
        charityWallet = _charityWallet;
        token = IERC20(_tokenAddress);

        fiveSkyCore = IFiveSkyCore(_fiveSkyCoreAddress);
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

    function addChance(uint256 tokenId, uint256 chanceCount)  external  {
        require(chanceCount > 0, "Chance count must be greater than zero");
        chances[tokenId] = chanceCount;

        for (uint256 i = 0; i < chanceCount; i++) {
            participants.push(tokenId);
        }

        emit ChanceAdded(tokenId, chanceCount);
    }

    function drawWinner() external {
        uint256 totalTokens = token.balanceOf(address(this));
        uint256[] memory prizes = new uint256[](4);
        prizes[0] = (totalTokens * 55) / 100;
        prizes[1] = (totalTokens * 25) / 100;
        prizes[2] = (totalTokens * 15) / 100;
        prizes[3] = (totalTokens * 5) / 100;

        uint256[] memory winnerTokenIds = new uint256[](3);
        uint256 maxIndex = participants.length - 1;

       for (uint i = 0; i < 3; i++) {
            uint256 randomIndex = getRandomNumber(0, maxIndex);
            winnerTokenIds[i] = participants[randomIndex];
        }

    emit WinnersSelected(winnerTokenIds[0], prizes[0], winnerTokenIds[1], prizes[1], winnerTokenIds[2], prizes[2]);

    }


    function distributePrizes(uint256[] memory winnerTokenIds, uint256[] memory prizes) internal {
        address[] memory winners = new address[](3);
        for (uint i = 0; i < 3; i++) {
            winners[i] = fiveSkyCore.ownerOf(winnerTokenIds[i]);
            token.transfer(winners[i], prizes[i]);
        }
        token.transfer(charityWallet, prizes[3]);

        emit WinnersDrawn(
            winners[0], prizes[0], winnerTokenIds[0],
            winners[1], prizes[1], winnerTokenIds[1],
            winners[2], prizes[2], winnerTokenIds[2],
            charityWallet, prizes[3]
        );

        resetLottery();
    }

    function resetLottery() internal {
        // Set the next draw date
        drawDate = block.timestamp + DURATION;
    }

    function getRandomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return random % (max - min + 1) + min;
    }

    receive() external payable {}
}